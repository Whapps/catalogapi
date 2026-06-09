#!/usr/bin/env node
// The "Order Lifecycle" quickstart: a single runnable sequence that takes a
// developer straight from search to a tracked order. Each step's test script
// captures the IDs the next step needs (catalog_item_id -> line_item_id +
// cart_version -> external_order_id), so the whole flow runs with just `apiKey`
// and `socket_id` set in the environment.
//
// This is hand-authored (not derived from the spec). It is welded into the
// generated reference collection as a folder by weld-lifecycle.js, so regen
// never clobbers it. Required as a module for its `items`/`runtimeVars`; run
// directly to emit a standalone collection.
//
//   node build-lifecycle.js <out.json>   # optional standalone build

const fs = require("fs");

const FOLDER_NAME = "Quickstart — Order Lifecycle";
const RUNTIME_VARS = ["catalog_item_id", "cart_version", "line_item_id", "line_item_price", "external_order_id"];
const HEADERS = [{ key: "Content-Type", value: "application/json" }];
const url = (...segs) => ({ raw: ["{{baseUrl}}", ...segs].join("/"), host: ["{{baseUrl}}"], path: segs });
const body = (raw) => ({ mode: "raw", raw, options: { raw: { language: "json" } } });
const test = (exec) => ({ listen: "test", script: { type: "text/javascript", exec } });
const prerequest = (exec) => ({ listen: "prerequest", script: { type: "text/javascript", exec } });

const cart = (...segs) => url("sockets", "{{socket_id}}", "cart", "{{external_user_id}}", ...segs);

const items = [
  {
    name: "1. Search items",
    event: [
      test([
        "const res = pm.response.json();",
        "pm.test('search returned items', () => pm.expect(res.items.length).to.be.above(0));",
        "const item = res.items[0];",
        "pm.collectionVariables.set('catalog_item_id', item.catalog_item_id);",
        "console.log('picked item', item.catalog_item_id, '-', item.name);",
      ]),
    ],
    request: {
      method: "POST",
      header: HEADERS,
      body: body('{\n  "per_page": 5\n}'),
      url: url("sockets", "{{socket_id}}", "items", "search"),
    },
  },
  {
    name: "2. Add item to cart",
    event: [
      test([
        "const cartObj = pm.response.json().cart;",
        "pm.test('item is in the cart', () => pm.expect(cartObj.line_items.length).to.be.above(0));",
        "const li = cartObj.line_items[0];",
        "pm.collectionVariables.set('cart_version', cartObj.cart_version);",
        "pm.collectionVariables.set('line_item_id', li.line_item_id);",
        "pm.collectionVariables.set('line_item_price', li.price);",
        "console.log('line_item', li.line_item_id, 'price', li.price, 'cart_version', cartObj.cart_version);",
      ]),
    ],
    request: {
      method: "POST",
      header: HEADERS,
      body: body('{\n  "items": [\n    { "catalog_item_id": {{catalog_item_id}} }\n  ]\n}'),
      url: cart(),
    },
  },
  {
    name: "3. Set shipping address",
    event: [
      test([
        "const cartObj = pm.response.json().cart;",
        "pm.collectionVariables.set('cart_version', cartObj.cart_version);",
      ]),
    ],
    request: {
      method: "POST",
      header: HEADERS,
      body: body(
        [
          "{",
          '  "given_name": "Ada",',
          '  "surname": "Lovelace",',
          '  "address_1": "1 Demo Street",',
          '  "city": "Austin",',
          '  "state_or_region": "TX",',
          '  "postal_code": "78701",',
          '  "country": "US",',
          '  "email": "ada@example.com",',
          '  "phone_number": "+15125550100"',
          "}",
        ].join("\n")
      ),
      url: cart("set_address"),
    },
  },
  {
    name: "4. Validate & lock cart",
    event: [
      test([
        "const cartObj = pm.response.json().cart;",
        "pm.collectionVariables.set('cart_version', cartObj.cart_version);",
        "pm.test('cart is locked for checkout', () => pm.expect(cartObj.is_locked).to.eql(true));",
      ]),
    ],
    request: {
      method: "POST",
      header: HEADERS,
      body: body('{\n  "lock": true\n}'),
      url: cart("validate"),
    },
  },
  {
    name: "5. Place order",
    event: [
      prerequest(["pm.collectionVariables.set('external_order_id', 'qs-' + Date.now());"]),
      test([
        "pm.test('order placed (201)', () => pm.response.to.have.status(201));",
        "const res = pm.response.json();",
        "pm.collectionVariables.set('external_order_id', res.external_order_id);",
        "console.log('order', res.external_order_id, 'order_number', res.order_number);",
      ]),
    ],
    request: {
      method: "POST",
      header: HEADERS,
      body: body(
        [
          "{",
          '  "cart_version": "{{cart_version}}",',
          '  "external_order_id": "{{external_order_id}}",',
          '  "line_item_payments": [',
          "    {",
          '      "line_item_id": "{{line_item_id}}",',
          '      "price_paid": "{{line_item_price}}"',
          "    }",
          "  ]",
          "}",
        ].join("\n")
      ),
      url: cart("order_place"),
    },
  },
  {
    name: "6. Track order",
    event: [
      test([
        "pm.test('order is retrievable', () => pm.response.to.have.status(200));",
        "const order = pm.response.json().order;",
        "console.log('tracked order', JSON.stringify(order));",
      ]),
    ],
    request: {
      method: "GET",
      header: [],
      url: url("orders", "{{external_order_id}}"),
    },
  },
];

const DESCRIPTION =
  "End-to-end sandbox walkthrough: search -> add to cart -> set address -> " +
  "validate -> place order -> track. Set `apiKey` and `socket_id` in the " +
  "CatalogAPI Sandbox environment, then run the steps in order. Each step " +
  "captures the IDs the next one needs.";

// Welded into the reference collection by weld-lifecycle.js.
const folder = () => ({ name: FOLDER_NAME, description: DESCRIPTION, item: items });

module.exports = { FOLDER_NAME, RUNTIME_VARS, items, folder };

// Run directly -> emit a standalone collection (optional; the welded folder is
// the shipped form).
if (require.main === module) {
  const out = process.argv[2];
  if (!out) {
    console.error("usage: build-lifecycle.js <out.json>");
    process.exit(1);
  }
  const collection = {
    info: {
      name: "CatalogAPI Quickstart — Order Lifecycle",
      description: DESCRIPTION,
      schema: "https://schema.getpostman.com/json/collection/v2.1.0/collection.json",
    },
    auth: { type: "bearer", bearer: [{ key: "token", value: "{{apiKey}}", type: "string" }] },
    variable: RUNTIME_VARS.map((key) => ({ key, value: "" })),
    item: items,
  };
  fs.writeFileSync(out, JSON.stringify(collection, null, 2) + "\n");
  console.log(`wrote ${out} (${items.length} chained steps)`);
}
