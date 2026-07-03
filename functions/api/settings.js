export async function onRequestPost({ request, env }) {
  try {
    const payload = await request.json()
    if (env.GBM_KV) {
      await env.GBM_KV.put('workspace', JSON.stringify(payload))
      return Response.json({ ok: true, source: 'kv' })
    }

    return Response.json({ ok: true, source: 'memory' })
  } catch (error) {
    return Response.json({ ok: false, error: error.message }, { status: 500 })
  }
}

export async function onRequestGet({ env }) {
  if (env.GBM_KV) {
    const value = await env.GBM_KV.get('workspace')
    return Response.json(value ? JSON.parse(value) : { ok: false, message: 'No saved workspace yet.' })
  }

  return Response.json({ ok: false, message: 'KV binding not configured yet.' })
}
