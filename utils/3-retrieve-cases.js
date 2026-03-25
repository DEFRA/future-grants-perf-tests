const fs = require("fs");
const filePath = "./cases_export.csv";
const rows = ["caseRef,_id"]; // swapped header

db.cases.find(
  {},
  { _id: 1, caseRef: 1 }
).forEach((doc) => {
  const id = doc._id ? doc._id.toString() : "";
  const caseRef = doc.caseRef ? String(doc.caseRef) : ""; // no quotes
  rows.push(caseRef + "," + id); // swapped order
});

fs.writeFileSync(filePath, rows.join("\n"), "utf8");

print("✅ CSV written to " + filePath);
print("✅ Total records: " + (rows.length - 1));


// print(require("fs").readFileSync("/home/cdpshell/cases_export.csv", "utf8"))
// Copy the entire output from mongosh

// Then run this on your Mac:

// pbpaste > ../data/perf_test_case_refs_frps.csv

// (assuming you are in future-grants-perf-tests/utils)