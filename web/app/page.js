"use client";

import { useState } from "react";

const SEATS = ["A1", "A2", "A3", "A4", "A5"];
const SESSION = "show-1";

const STATUS_COLOR = {
  PENDING: "#eab308",
  RESERVED: "#3b82f6",
  CONFIRMED: "#22c55e",
  REJECTED: "#ef4444",
  PAYMENT_FAILED: "#f97316",
};

const TERMINAL = ["CONFIRMED", "REJECTED", "PAYMENT_FAILED"];

export default function Home() {
  const [failPay, setFailPay] = useState(false);
  const [order, setOrder] = useState(null);
  const [busy, setBusy] = useState(false);

  async function buy(seat) {
    setBusy(true);
    setOrder({ seat, status: "PENDING" });
    const userId = failPay ? "failuser" : "cliente";
    const res = await fetch("/api/buy", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ session_id: SESSION, seat_id: seat, user_id: userId }),
    });
    const created = await res.json();
    if (!created.id) {
      setOrder({ seat, status: "REJECTED", reason: "erro ao criar pedido" });
      setBusy(false);
      return;
    }
    // poll status até estado terminal
    for (let i = 0; i < 20; i++) {
      await new Promise((r) => setTimeout(r, 1200));
      const r = await fetch(`/api/order/${created.id}`);
      const o = await r.json();
      setOrder({ seat, status: o.status, reason: o.reason, id: o.id });
      if (TERMINAL.includes(o.status)) break;
    }
    setBusy(false);
  }

  return (
    <main style={{ maxWidth: 720, margin: "0 auto", padding: "48px 20px" }}>
      <h1 style={{ fontSize: 30, marginBottom: 4 }}>🎟️ Fila</h1>
      <p style={{ color: "#9aa3b8", marginTop: 0 }}>
        Compre um ingresso e acompanhe a <b>saga event-driven</b> em tempo real.
      </p>

      <label style={{ display: "flex", alignItems: "center", gap: 8, margin: "20px 0" }}>
        <input type="checkbox" checked={failPay} onChange={(e) => setFailPay(e.target.checked)} />
        Simular falha no pagamento (dispara a compensação)
      </label>

      <div style={{ display: "flex", gap: 10, flexWrap: "wrap" }}>
        {SEATS.map((s) => (
          <button
            key={s}
            disabled={busy}
            onClick={() => buy(s)}
            style={{
              padding: "14px 20px",
              fontSize: 16,
              fontWeight: 700,
              borderRadius: 10,
              border: "1px solid #2b3350",
              background: busy ? "#1a1f33" : "#232a45",
              color: "#e6e8ef",
              cursor: busy ? "not-allowed" : "pointer",
            }}
          >
            Assento {s}
          </button>
        ))}
      </div>

      {order && (
        <div
          style={{
            marginTop: 32,
            padding: 20,
            borderRadius: 12,
            background: "#161a2c",
            border: "1px solid #2b3350",
          }}
        >
          <div style={{ color: "#9aa3b8", fontSize: 14 }}>
            Sessão <b>{SESSION}</b> · Assento <b>{order.seat}</b>
          </div>
          <div
            style={{
              marginTop: 12,
              fontSize: 24,
              fontWeight: 800,
              color: STATUS_COLOR[order.status] || "#e6e8ef",
            }}
          >
            {order.status}
            {order.reason ? (
              <span style={{ fontSize: 14, color: "#9aa3b8", fontWeight: 400 }}>
                {" "}— {order.reason}
              </span>
            ) : null}
          </div>
          {order.status === "PENDING" || order.status === "RESERVED" ? (
            <div style={{ marginTop: 8, color: "#9aa3b8", fontSize: 13 }}>processando…</div>
          ) : null}
        </div>
      )}

      <p style={{ marginTop: 40, color: "#5b6478", fontSize: 12 }}>
        github.com/janailsonf-a/fila
      </p>
    </main>
  );
}
