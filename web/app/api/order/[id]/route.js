const ORDERS = process.env.ORDERS_API_URL || "http://orders:8000";

export async function GET(_request, { params }) {
  const res = await fetch(`${ORDERS}/api/orders/${params.id}`, {
    headers: { Accept: "application/json" },
    cache: "no-store",
  });
  const data = await res.json();
  return Response.json(data, { status: res.status });
}
