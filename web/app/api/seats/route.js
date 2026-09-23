const INVENTORY = process.env.INVENTORY_API_URL || "http://inventory-api:8000";

export async function GET(request) {
  const session = new URL(request.url).searchParams.get("session") || "cinema-1";
  const res = await fetch(`${INVENTORY}/api/sessions/${session}/seats`, {
    headers: { Accept: "application/json" },
    cache: "no-store",
  });
  const data = await res.json();
  return Response.json(data, { status: res.status });
}
