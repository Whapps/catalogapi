#!/usr/bin/env node
// Weld the hand-authored Order Lifecycle into the generated reference
// collection as a top-level folder, and register the runtime variables it
// chains through. Idempotent: re-running replaces any previously welded folder
// rather than duplicating it, so it is safe inside generate.sh.
//
// The folder carries no auth of its own, so it inherits the collection's
// {{apiKey}} bearer.
//
// Usage: node weld-lifecycle.js <collection.json>

const fs = require("fs");
const { FOLDER_NAME, RUNTIME_VARS, folder } = require("./build-lifecycle.js");

const collectionPath = process.argv[2];
if (!collectionPath) {
  console.error("usage: weld-lifecycle.js <collection.json>");
  process.exit(1);
}

const collection = JSON.parse(fs.readFileSync(collectionPath, "utf8"));

// Quickstart folder on top, with any prior copy removed first (idempotent).
collection.item = [folder(), ...(collection.item || []).filter((it) => it.name !== FOLDER_NAME)];

// Register the runtime variables the chain writes to (skip any already present).
const have = new Set((collection.variable || []).map((v) => v.key));
collection.variable = [
  ...(collection.variable || []),
  ...RUNTIME_VARS.filter((k) => !have.has(k)).map((key) => ({ key, value: "" })),
];

fs.writeFileSync(collectionPath, JSON.stringify(collection, null, 2) + "\n");
console.log(`welded "${FOLDER_NAME}" (${folder().item.length} steps) into ${collectionPath}`);
