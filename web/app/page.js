"use client";

import { useEffect, useState, useCallback } from "react";

const SESSION = "cinema-1";
const MOVIE = "NEBULOSA";
const SHOWTIME = "Sala 3 · 20:00";
const TERMINAL = ["CONFIRMED", "REJECTED", "PAYMENT_FAILED"];

const STATUS_LABEL = {
  PENDING: "Reservando…",
  RESERVED: "Pagando…",
  CONFIRMED: "Confirmado ✅",
  REJECTED: "Recusado ❌",
  PAYMENT_FAILED: "Pagamento falhou — assento liberado ↩️",
};
const STATUS_COLOR = {
  PENDING: "#eab308",
  RESERVED: "#3b82f6",
  CONFIRMED: "#22c55e",
  REJECTED: "#ef4444",
  PAYMENT_FAILED: "#f97316",
};

export default function Home() {
  const [seats, setSeats] = useState([]);
  const [failPay, setFailPay] = useState(false);
  const [busySeat, setBusySeat] = useState(null);
  const [order, setOrder] = useState(null);

  const loadSeats = useCallback(async () => {
    try {
      const r = await fetch(`/api/seats?session=${SESSION}`, { cache: "no-store" });
      const data = await r.json();
      if (Array.isArray(data)) setSeats(data);
    } catch {}
  }, []);

  useEffect(() => {
    loadSeats();
    const t = setInterval(loadSeats, 2500);
    return () => clearInterval(t);
  }, [loadSeats]);

  async function buy(seatId) {
    setBusySeat(seatId);
    setOrder({ seat: seatId, status: "PENDING" });
    const userId = failPay ? "failuser" : "cliente";
    try {
      const res = await fetch("/api/buy", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ session_id: SESSION, seat_id: seatId, user_id: userId }),
      });
      const created = await res.json();
      if (!created.id) {
        setOrder({ seat: seatId, status: "REJECTED", reason: "erro" });
        setBusySeat(null);
        return;
      }
      for (let i = 0; i < 20; i++) {
        await new Promise((r) => setTimeout(r, 1200));
        const o = await (await fetch(`/api/order/${created.id}`)).json();
        setOrder({ seat: seatId, status: o.status, reason: o.reason });
        loadSeats();
        if (TERMINAL.includes(o.status)) break;
      }
    } finally {
      setBusySeat(null);
      loadSeats();
    }
  }

  // agrupa por fileira (A, B, C...)
  const rows = {};
  for (const s of seats) {
    const row = s.seat_id[0];
    (rows[row] ||= []).push(s);
  }
  for (const r of Object.values(rows)) r.sort((a, b) => a.seat_id.localeCompare(b.seat_id, undefined, { numeric: true }));

  return (
    <main style={{ maxWidth: 760, margin: "0 auto", padding: "40px 20px" }}>
      <div style={{ display: "flex", alignItems: "baseline", gap: 12 }}>
        <h1 style={{ fontSize: 28, margin: 0 }}>🎬 {MOVIE}</h1>
        <span style={{ color: "#9aa3b8" }}>{SHOWTIME}</span>
      </div>
      <p style={{ color: "#9aa3b8", marginTop: 6 }}>
        Escolha um assento. Acompanhe a <b>saga event-driven</b> em tempo real.
      </p>

      {/* Tela */}
      <div style={{ margin: "28px auto 8px", maxWidth: 520 }}>
        <div
          style={{
            height: 10,
            borderRadius: "50% 50% 6px 6px / 100% 100% 6px 6px",
            background: "#e6e8ef",
            boxShadow: "0 0 40px 6px rgba(230,232,239,.25)",
          }}
        />
        <div style={{ textAlign: "center", color: "#6b7280", fontSize: 12, letterSpacing: 6, marginTop: 6 }}>
          T E L A
        </div>
      </div>

      {/* Grade de assentos */}
      <div style={{ display: "flex", flexDirection: "column", gap: 10, alignItems: "center", marginTop: 20 }}>
        {Object.keys(rows).sort().map((row) => (
          <div key={row} style={{ display: "flex", gap: 10, alignItems: "center" }}>
            <span style={{ width: 16, color: "#6b7280", fontSize: 13 }}>{row}</span>
            {rows[row].map((s) => {
              const taken = s.status === "held" || s.status === "sold";
              const processing = busySeat === s.seat_id;
              const bg = processing ? "#eab308" : taken ? "#5b2a2a" : "#234b39";
              const border = processing ? "#eab308" : taken ? "#7a3a3a" : "#2f6b4f";
              return (
                <button
                  key={s.seat_id}
                  disabled={taken || busySeat !== null}
                  onClick={() => buy(s.seat_id)}
                  title={`${s.seat_id} — ${taken ? "ocupado" : "livre"}`}
                  style={{
                    width: 34,
                    height: 30,
                    borderRadius: "6px 6px 3px 3px",
                    border: `1px solid ${border}`,
                    background: bg,
                    color: "#e6e8ef",
                    fontSize: 11,
                    cursor: taken || busySeat ? "not-allowed" : "pointer",
                  }}
                >
                  {s.seat_id.slice(1)}
                </button>
              );
            })}
          </div>
        ))}
        {seats.length === 0 && <div style={{ color: "#6b7280" }}>carregando sala…</div>}
      </div>

      {/* Legenda */}
      <div style={{ display: "flex", gap: 18, justifyContent: "center", marginTop: 22, fontSize: 13, color: "#9aa3b8" }}>
        <Legend color="#234b39" label="Livre" />
        <Legend color="#eab308" label="Processando" />
        <Legend color="#5b2a2a" label="Ocupado" />
      </div>

      <label style={{ display: "flex", alignItems: "center", gap: 8, justifyContent: "center", margin: "22px 0" }}>
        <input type="checkbox" checked={failPay} onChange={(e) => setFailPay(e.target.checked)} />
        Simular falha no pagamento (dispara a compensação)
      </label>

      {order && (
        <div
          style={{
            margin: "0 auto",
            maxWidth: 420,
            padding: 16,
            borderRadius: 12,
            background: "#161a2c",
            border: `1px solid ${STATUS_COLOR[order.status] || "#2b3350"}`,
            textAlign: "center",
          }}
        >
          <div style={{ color: "#9aa3b8", fontSize: 13 }}>Assento {order.seat}</div>
          <div style={{ marginTop: 6, fontSize: 18, fontWeight: 800, color: STATUS_COLOR[order.status] || "#e6e8ef" }}>
            {STATUS_LABEL[order.status] || order.status}
          </div>
        </div>
      )}

      <p style={{ marginTop: 40, textAlign: "center", color: "#5b6478", fontSize: 12 }}>
        github.com/janailsonf-a/fila
      </p>
    </main>
  );
}

function Legend({ color, label }) {
  return (
    <span style={{ display: "flex", alignItems: "center", gap: 6 }}>
      <span style={{ width: 14, height: 14, borderRadius: 4, background: color, display: "inline-block" }} />
      {label}
    </span>
  );
}
