const ORDERS = process.env.ORDERS_API_URL || "http://orders:8000";

export async function POST(request) {
  const body = await request.json();
  const res = await fetch(`${ORDERS}/api/orders`, {
    method: "POST",
    headers: { "Content-Type": "application/json", Accept: "application/json" },
    body: JSON.stringify(body),
    cache: "no-store",
  });
  const data = await res.json();
  return Response.json(data, { status: res.status });
}
