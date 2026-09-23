"use client";

import { useCallback, useEffect, useState } from "react";

const SESSION = "cinema-1";
const MOVIE = "Homem-Aranha: Novo Dia";
const META = "Sala 3 · 20:00 · Dublado · IMAX";
const SYNOPSIS = "Peter Parker recomeça do zero numa Nova York que esqueceu quem ele é.";
const PRICE = "R$ 32,00";
const TERMINAL = ["CONFIRMED", "REJECTED", "PAYMENT_FAILED"];

const BANNER = {
  PENDING: ["Reservando assento…", "bg-amber-500/15 text-amber-300 border-amber-500/30"],
  RESERVED: ["Processando pagamento…", "bg-blue-500/15 text-blue-300 border-blue-500/30"],
  CONFIRMED: ["Ingresso confirmado ✅", "bg-emerald-500/15 text-emerald-300 border-emerald-500/30"],
  REJECTED: ["Assento indisponível ❌", "bg-rose-500/15 text-rose-300 border-rose-500/30"],
  PAYMENT_FAILED: ["Pagamento falhou — assento liberado ↩️", "bg-orange-500/15 text-orange-300 border-orange-500/30"],
};

export default function Home() {
  const [seats, setSeats] = useState([]);
  const [selected, setSelected] = useState(null);
  const [failPay, setFailPay] = useState(false);
  const [busy, setBusy] = useState(false);
  const [order, setOrder] = useState(null);

  const loadSeats = useCallback(async () => {
    try {
      const data = await (await fetch(`/api/seats?session=${SESSION}`, { cache: "no-store" })).json();
      if (Array.isArray(data)) setSeats(data);
    } catch {}
  }, []);

  useEffect(() => {
    loadSeats();
    const t = setInterval(loadSeats, 2500);
    return () => clearInterval(t);
  }, [loadSeats]);

  async function confirm() {
    if (!selected) return;
    const seatId = selected;
    setBusy(true);
    setOrder({ seat: seatId, status: "PENDING" });
    try {
      const created = await (
        await fetch("/api/buy", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ session_id: SESSION, seat_id: seatId, user_id: failPay ? "failuser" : "cliente" }),
        })
      ).json();
      if (!created.id) {
        setOrder({ seat: seatId, status: "REJECTED" });
        return;
      }
      for (let i = 0; i < 20; i++) {
        await new Promise((r) => setTimeout(r, 1200));
        const o = await (await fetch(`/api/order/${created.id}`)).json();
        setOrder({ seat: seatId, status: o.status });
        loadSeats();
        if (TERMINAL.includes(o.status)) break;
      }
    } finally {
      setBusy(false);
      setSelected(null);
      loadSeats();
    }
  }

  const rows = {};
  for (const s of seats) (rows[s.seat_id[0]] ||= []).push(s);
  for (const r of Object.values(rows))
    r.sort((a, b) => a.seat_id.localeCompare(b.seat_id, undefined, { numeric: true }));

  return (
    <main className="mx-auto max-w-4xl px-4 py-14">
      {/* Card do filme */}
      <section className="flex gap-4 rounded-2xl border border-white/10 bg-white/5 p-4 shadow-xl backdrop-blur">
        <div className="flex h-48 w-32 shrink-0 items-end justify-center rounded-xl bg-gradient-to-br from-red-600 via-rose-700 to-blue-700 p-2 text-4xl">
          🕷️
        </div>
        <div className="min-w-0 py-1">
          <h1 className="text-3xl font-extrabold tracking-tight">{MOVIE}</h1>
          <p className="mt-0.5 text-sm text-slate-400">{META}</p>
          <p className="mt-2 text-sm text-slate-300">{SYNOPSIS}</p>
          <span className="mt-3 inline-block rounded-full border border-white/10 bg-white/5 px-3 py-1 text-xs text-slate-300">
            Ingresso {PRICE}
          </span>
        </div>
      </section>

      {/* Tela */}
      <div className="mx-auto mt-12 max-w-2xl">
        <div className="h-2.5 rounded-[100%] bg-gradient-to-b from-white to-slate-400 shadow-[0_0_60px_14px_rgba(255,255,255,0.28)]" />
        <p className="mt-3 text-center text-sm tracking-[0.6em] text-slate-500">TELA</p>
      </div>

      {/* Mapa de assentos */}
      <div className="mt-10 flex flex-col items-center gap-3">
        {Object.keys(rows).sort().map((row) => {
          const left = rows[row].filter((s) => Number(s.seat_id.slice(1)) <= 4);
          const right = rows[row].filter((s) => Number(s.seat_id.slice(1)) > 4);
          return (
            <div key={row} className="flex items-center gap-5">
              <span className="w-5 text-right text-sm text-slate-500">{row}</span>
              <div className="flex gap-2.5">{left.map((s) => <Seat key={s.seat_id} s={s} selected={selected} busy={busy} onPick={setSelected} />)}</div>
              <div className="w-12" />
              <div className="flex gap-2.5">{right.map((s) => <Seat key={s.seat_id} s={s} selected={selected} busy={busy} onPick={setSelected} />)}</div>
            </div>
          );
        })}
        {seats.length === 0 && <p className="text-slate-500">carregando sala…</p>}
      </div>

      {/* Legenda */}
      <div className="mt-8 flex flex-wrap justify-center gap-5 text-sm text-slate-400">
        <Legend cls="bg-emerald-900/50 border-emerald-600" label="Livre" />
        <Legend cls="bg-indigo-500 border-indigo-300" label="Selecionado" />
        <Legend cls="bg-rose-950 border-rose-900" label="Ocupado" />
      </div>

      <label className="mt-6 flex items-center justify-center gap-2 text-sm text-slate-300">
        <input type="checkbox" checked={failPay} onChange={(e) => setFailPay(e.target.checked)} className="accent-indigo-500" />
        Simular falha no pagamento (dispara a compensação)
      </label>

      {/* Banner de status */}
      {order && (
        <div className={`mx-auto mt-6 max-w-lg rounded-xl border px-4 py-3 text-center text-sm font-semibold ${(BANNER[order.status] || ["", "border-white/10 text-slate-300"])[1]}`}>
          Assento {order.seat} · {(BANNER[order.status] || [order.status])[0]}
        </div>
      )}

      {/* Barra de confirmação */}
      <div className="sticky bottom-4 mx-auto mt-8 flex max-w-lg items-center justify-between gap-4 rounded-2xl border border-white/10 bg-slate-900/80 px-6 py-5 shadow-2xl backdrop-blur">
        <div className="text-sm">
          {selected ? (
            <>
              <span className="text-slate-400">Assento </span>
              <span className="font-bold">{selected}</span>
              <span className="text-slate-400"> · {PRICE}</span>
            </>
          ) : (
            <span className="text-slate-500">Selecione um assento</span>
          )}
        </div>
        <button
          onClick={confirm}
          disabled={!selected || busy}
          className="rounded-xl bg-indigo-500 px-5 py-2.5 text-sm font-bold text-white transition hover:bg-indigo-400 disabled:cursor-not-allowed disabled:bg-slate-700 disabled:text-slate-400"
        >
          {busy ? "Processando…" : "Confirmar compra"}
        </button>
      </div>

      <p className="mt-10 text-center text-xs text-slate-600">github.com/janailsonf-a/fila</p>
    </main>
  );
}

function Seat({ s, selected, busy, onPick }) {
  const taken = s.status === "held" || s.status === "sold";
  const isSel = selected === s.seat_id;
  const base = "h-11 w-11 rounded-t-lg border text-sm font-semibold transition";
  const cls = taken
    ? "bg-rose-950 border-rose-900 text-rose-800 cursor-not-allowed"
    : isSel
      ? "bg-indigo-500 border-indigo-300 text-white ring-2 ring-indigo-300/50"
      : "bg-emerald-900/50 border-emerald-600 text-emerald-200 hover:bg-emerald-700 hover:text-white";
  return (
    <button
      disabled={taken || busy}
      onClick={() => onPick(isSel ? null : s.seat_id)}
      title={`${s.seat_id} — ${taken ? "ocupado" : "livre"}`}
      className={`${base} ${cls} ${busy && !isSel ? "opacity-60" : ""}`}
    >
      {s.seat_id.slice(1)}
    </button>
  );
}

function Legend({ cls, label }) {
  return (
    <span className="flex items-center gap-1.5">
      <span className={`inline-block h-3.5 w-3.5 rounded border ${cls}`} />
      {label}
    </span>
  );
}
