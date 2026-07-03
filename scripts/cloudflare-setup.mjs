import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, "..");
const configPath = path.join(rootDir, ".cloudflare-setup.json");
const wranglerPath = path.join(rootDir, "wrangler.toml");
const functionsDir = path.join(rootDir, "functions", "api");

const ensureDir = (dirPath) => fs.mkdirSync(dirPath, { recursive: true });

const writeFile = (targetPath, content) => {
  fs.writeFileSync(targetPath, content, "utf8");
};

const compileFunctions = () => {
  ensureDir(functionsDir);
  const settingsRoute = `export async function onRequestPost({ request, env }) {
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
`;
  const healthRoute = `export async function onRequestGet() {
  return Response.json({ ok: true, service: 'googlebusinessmanager' })
}
`;

  writeFile(path.join(functionsDir, "settings.js"), settingsRoute);
  writeFile(path.join(functionsDir, "health.js"), healthRoute);
};

const compileWranglerConfig = () => {
  const wranglerContent = `[vars]
APP_NAME = "googlebusinessmanager"

[[kv_namespaces]]
binding = "GBM_KV"
preview_id = "preview-kv-namespace"
queue = "kv"

[site]
bucket = "./dist"
`;
  writeFile(wranglerPath, wranglerContent);
};

const createCloudflareSetup = () => {
  if (fs.existsSync(configPath)) {
    console.log("Cloudflare setup already initialized. Skipping re-creation.");
    return;
  }

  const setupState = {
    createdAt: new Date().toISOString(),
    namespaceName: "googlebusinessmanager-kv",
    bindingName: "GBM_KV",
    pagesFunctionRoutes: ["/api/settings", "/api/health"],
    status: "ready-for-cloudflare-setup",
  };

  writeFile(configPath, JSON.stringify(setupState, null, 2));
  compileFunctions();
  compileWranglerConfig();
  console.log(
    "Cloudflare setup scaffold written. Add your Cloudflare token and account ID to create the KV namespace for real.",
  );
};

createCloudflareSetup();
