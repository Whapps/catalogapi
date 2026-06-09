# CatalogAPI v2 — Examples

Everything here targets the **CatalogAPI v2** JSON/REST API and the **sandbox**
environment, so you can explore and place test orders without touching
production. The canonical contract is the OpenAPI spec
([`openapi.json`](openapi.json)); the Postman collection and the examples below
are generated from it.

> Looking for the legacy v1 (XML) interface packages? Those live in the
> language folders at the repo root (`perl/`, `php/`, `java/`, `dotnet/`).

## Quick start (Postman)

1. **Import two files** into Postman:
   - `postman/catalogapi.postman_collection.json` — the full API, in folders by area
   - `postman/catalogapi.sandbox.postman_environment.json` — the **CatalogAPI Sandbox** environment
2. **Select** the *CatalogAPI Sandbox* environment (top-right in Postman).
3. **Fill in two values** in that environment:
   - `apiKey` — your sandbox API key (see [Authentication](#authentication))
   - `socket_id` — the catalog socket you want to browse/sell from
4. Open **Quickstart — Order Lifecycle** and **Run** the folder.

That's it — the Quickstart walks an item from search all the way to a tracked
order, carrying the IDs forward for you at each step.

### No Postman? Use newman (CLI)

```bash
# Smoke test — no key required (health check is public)
npx newman run postman/catalogapi.postman_collection.json --folder Health

# Run the full lifecycle against sandbox
npx newman run postman/catalogapi.postman_collection.json \
  -e postman/catalogapi.sandbox.postman_environment.json \
  --folder "Quickstart — Order Lifecycle" \
  --env-var apiKey=YOUR_SANDBOX_KEY \
  --env-var socket_id=YOUR_SOCKET_ID
```

## Authentication

Every request (except the public `/ping` health check) authenticates with a
single bearer token:

```
Authorization: Bearer <apiKey>
```

Treat the key as **opaque** — it's an account credential the server decodes; its
internal format is not something your client should parse or construct. Paste it
into the environment's `apiKey` field and the collection applies it to every
request.

## What's in the collection

| Folder | Contents |
|--------|----------|
| **Quickstart — Order Lifecycle** | A single runnable sequence: search → add to cart → set address → validate & lock → place order → track. Each step captures the IDs the next one needs. |
| **Catalog** | Browse and search: sockets, items, item details, categories, brands, tags, stock, marketing. |
| **Cart** | Cart lifecycle: add/update/remove line items, address, metadata, validate, place order. |
| **Order** | Order tracking and history. |
| **Health** | Public `/ping` health check (no auth). |

Carts are scoped per socket and keyed by an `external_user_id` you choose (the
environment ships with a sample `demo-user-1`) — it's how you address a specific
shopper's cart.

## Environments

The repo ships **sandbox only** — there is intentionally no production
environment file here.

| Variable | Purpose |
|----------|---------|
| `baseUrl` | `https://api.catalogapi.com/sandbox/api/v2` (preset) |
| `apiKey` | Your sandbox API key (you provide) |
| `socket_id` | Catalog socket to use (you provide) |
| `external_user_id` | Cart owner id of your choosing (sample: `demo-user-1`) |

## Regenerating

The collection is produced from the spec, so don't hand-edit it — change the
inputs and re-run:

```bash
scripts/generate.sh            # fetch the latest spec, then convert + polish + weld
scripts/generate.sh --no-fetch # rebuild from the committed openapi.json
```

The pipeline:

1. **fetch** the spec → `openapi.json`
2. **convert** it to a Postman collection (`openapi-to-postmanv2`)
3. **polish** (`scripts/polish-postman.js`) — force the sandbox host, drop auth
   from public endpoints, and expose the credential as `{{apiKey}}`
4. **weld** (`scripts/weld-lifecycle.js`) — insert the hand-authored Quickstart
   lifecycle (`scripts/build-lifecycle.js`) as the top folder

The Quickstart steps are the only hand-authored part; everything else comes
straight from the spec. Requires Node 18+ (`npx` for the converter/newman).
