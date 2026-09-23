export const metadata = {
  title: "Fila — comprar ingresso",
  description: "Demo da saga event-driven (Fila)",
};

export default function RootLayout({ children }) {
  return (
    <html lang="pt-BR">
      <body
        style={{
          margin: 0,
          fontFamily: "Segoe UI, system-ui, Arial, sans-serif",
          background: "#0f1220",
          color: "#e6e8ef",
        }}
      >
        {children}
      </body>
    </html>
  );
}
