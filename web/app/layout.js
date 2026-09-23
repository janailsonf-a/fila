import "./globals.css";

export const metadata = {
  title: "Fila — comprar ingresso",
  description: "Demo da saga event-driven (Fila)",
};

export default function RootLayout({ children }) {
  return (
    <html lang="pt-BR">
      <body className="min-h-screen text-slate-100 antialiased">{children}</body>
    </html>
  );
}
