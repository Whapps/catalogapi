#!/usr/bin/env node
// Post-process the generated Postman collection so it is safe and runnable:
//   1. Force the baseUrl variable to the sandbox host (never production).
//   2. Strip auth from operations the spec marks public (security: []), so a
//      placeholder bearer token doesn't turn an unauthenticated call (e.g.
//      /ping) into a 401.
//   3. Belt-and-braces: rewrite any literal production host left in the file.
//
// Usage: node polish-postman.js <spec.json> <collection.json> <sandboxUrl>

const fs = require("fs");

const [, , specPath, collectionPath, sandboxUrl] = process.argv;
if (!specPath || !collectionPath || !sandboxUrl) {
  console.error("usage: polish-postman.js <spec.json> <collection.json> <sandboxUrl>");
  process.exit(1);
}

const spec = JSON.parse(fs.readFileSync(specPath, "utf8"));
const collection = JSON.parse(fs.readFileSync(collectionPath, "utf8"));

// Build the set of public operations as "METHOD /normalized/path".
// The spec uses {param}; Postman uses :param, so normalize to match.
const toPostmanPath = (p) => p.replace(/\{(\w+)\}/g, ":$1");
const publicOps = new Set();
for (const [path, methods] of Object.entries(spec.paths)) {
  for (const [method, op] of Object.entries(methods)) {
    if (!/^(get|post|put|patch|delete)$/.test(method)) continue;
    if (Array.isArray(op.security) && op.security.length === 0) {
      publicOps.add(`${method.toUpperCase()} ${toPostmanPath(path)}`);
    }
  }
}

// 1. Sandbox-only base URL.
collection.variable = (collection.variable || []).map((v) =>
  v.key === "baseUrl" ? { ...v, value: sandboxUrl } : v
);

// 1b. The bearer token is an opaque API key the server decodes (its format has
// changed over time, so the client must not parse it). Present a single key and
// do no client-side credential building. Strip any pre-request helper we may
// have added on a previous run.
collection.event = (collection.event || []).filter((e) => e.listen !== "prerequest");

// 2. Drop auth on public operations.
let stripped = 0;
const visit = (items) => {
  for (const item of items || []) {
    if (item.item) {
      visit(item.item);
      continue;
    }
    if (!item.request) continue;
    const path = "/" + ((item.request.url && item.request.url.path) || []).join("/");
    if (publicOps.has(`${item.request.method} ${path}`)) {
      item.request.auth = { type: "noauth" };
      stripped++;
    }
  }
};
visit(collection.item);

// 3. Scrub any literal production host, and present auth as a single opaque
//    {{apiKey}} variable rather than the converter's default {{bearerToken}}.
const prodHost = sandboxUrl.replace("/sandbox/", "/");
const json = JSON.stringify(collection, null, 2)
  .split(prodHost)
  .join(sandboxUrl)
  .split("{{bearerToken}}")
  .join("{{apiKey}}");

fs.writeFileSync(collectionPath, json);
console.log(
  `polished: baseUrl -> sandbox, auth stripped from ${stripped} public request(s)`
);
