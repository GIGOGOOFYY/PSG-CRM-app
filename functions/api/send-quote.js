/**
 * Cloudflare Pages Function — /api/send-quote
 *
 * Proxies POST /api/send-quote → Worker /wa-send-quote
 * server-side so the browser never has to reach workers.dev directly
 * (the corporate network blocks it, but Cloudflare→Cloudflare works fine).
 *
 * The caller sends X-Worker-Base with the Worker's base URL so this
 * function stays generic and doesn't hard-code a specific Worker domain.
 */

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, X-API-Key, X-Worker-Base',
};

export async function onRequestOptions() {
  return new Response(null, { status: 204, headers: CORS });
}

export async function onRequestPost({ request }) {
  try {
    const workerBase = (request.headers.get('X-Worker-Base') || '').replace(/\/$/, '');
    if (!workerBase) {
      return Response.json(
        { ok: false, error: 'X-Worker-Base header missing — set Bot Worker URL in Admin settings' },
        { status: 400, headers: CORS }
      );
    }

    const apiKey = request.headers.get('X-API-Key') || '';
    const body   = await request.text();

    const workerRes = await fetch(`${workerBase}/wa-send-quote`, {
      method:  'POST',
      headers: { 'Content-Type': 'application/json', 'X-API-Key': apiKey },
      body,
    });

    const text = await workerRes.text();
    return new Response(text, {
      status:  workerRes.status,
      headers: { 'Content-Type': 'application/json', ...CORS },
    });
  } catch (err) {
    return Response.json(
      { ok: false, error: err.message },
      { status: 500, headers: CORS }
    );
  }
}
