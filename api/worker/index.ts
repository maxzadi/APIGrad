export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (url.pathname === "/api/health") {
      if (request.method !== "GET") {
        return Response.json(
          { error: "Método no permitido" },
          { status: 405, headers: { Allow: "GET" } },
        );
      }

      try {
        await env.DB.prepare("SELECT 1 AS ok").first();

        return Response.json(
          { ok: true, database: "connected" },
          { headers: { "Cache-Control": "no-store" } },
        );
      } catch (error) {
        console.error("Error de conexión con D1:", error);

        return Response.json(
          { ok: false, database: "unavailable" },
          {
            status: 503,
            headers: { "Cache-Control": "no-store" },
          },
        );
      }
    }

    // Conserva la respuesta utilizada por la plantilla.
    if (url.pathname === "/api/") {
      return Response.json({ name: "Cloudflare" });
    }

    return new Response(null, { status: 404 });
  },
} satisfies ExportedHandler<Env>;