print("🔍 Starting scan and cleanup of test references...\n");

// 👇 ONLY these collections will be scanned
const allowedCollections = (() => {
  const dbName = db.getName();

  if (dbName === "fg-gas-backend") return ["inbox", "outbox", "applications"];
  if (dbName === "fg-cw-backend") return ["inbox", "outbox", "cases"];

  throw new Error(
    `❌ Refusing to run. Unknown DB: ${dbName}. Only allowed: fg-gas-backend, fg-cw-backend`
  );
})();

print(`✅ Connected DB: ${db.getName()}`);
print(`✅ Collections targeted: ${allowedCollections.join(", ")}\n`);

allowedCollections.forEach((collection) => {

  if (!db.getCollectionNames().includes(collection)) {
    print(`⚠️ Collection not found, skipping: ${collection}`);
    return;
  }

  const cursor = db.getCollection(collection).find({
    $where: function () {

      const docStr = JSON.stringify(this);

      const CASE_REF_RE  = /case-ref-\d{10,}-\d+/i;
      const SHORT_REF_RE = /\b[a-z0-9]{3}-[a-z0-9]{3}-[a-z0-9]{3}\b/i;
      const CLIENT_REF_RE = /\bclient[a-z0-9]{6,20}\b/i;

      return (
        docStr.includes("perf-test-client-ref") ||
        docStr.includes("frps-perf-test-client-ref") ||
        docStr.includes("client-perf") ||
        CASE_REF_RE.test(docStr) ||
        SHORT_REF_RE.test(docStr) ||
        CLIENT_REF_RE.test(docStr)
      );
    }
  });

  let count = 0;

  cursor.forEach((doc) => {
    db.getCollection(collection).deleteOne({ _id: doc._id });
    print(`🗑️ Deleted from ${collection}: ${doc._id}`);
    count++;
  });

  if (count > 0) {
    print(`✅ ${count} matching docs deleted from: ${collection}\n`);
  } else {
    print(`ℹ️ No matches in: ${collection}\n`);
  }
});

print("\n🎉 Cleanup complete!");