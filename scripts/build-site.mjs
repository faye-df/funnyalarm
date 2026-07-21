import { cpSync, mkdirSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const projectRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const distRoot = resolve(projectRoot, "dist");
const html = readFileSync(resolve(projectRoot, "voice_alarm.html"), "utf8");
const worker = [
  "const html = " + JSON.stringify(html) + ";",
  "",
  "export default {",
  "  async fetch(request) {",
  "    const url = new URL(request.url);",
  "    if (url.pathname === \"/\" || url.pathname === \"/voice_alarm.html\") {",
  "      return new Response(html, {",
  "        headers: {",
  "          \"content-type\": \"text/html; charset=utf-8\",",
  "          \"cache-control\": \"public, max-age=300\"",
  "        }",
  "      });",
  "    }",
  "    return new Response(\"Not found\", { status: 404 });",
  "  }",
  "};",
  "",
].join("\n");

rmSync(distRoot, { recursive: true, force: true });
mkdirSync(resolve(distRoot, "server"), { recursive: true });
mkdirSync(resolve(distRoot, ".openai"), { recursive: true });
writeFileSync(resolve(distRoot, "server/index.js"), worker);
cpSync(
  resolve(projectRoot, ".openai/hosting.json"),
  resolve(distRoot, ".openai/hosting.json"),
);

console.log("Built Funny Alarm for Sites.");
