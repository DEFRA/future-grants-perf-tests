// Run this script in mongosh connected to fg-cw-backend database:
// mongosh <connection-string> < scripts/export-case-refs.js

const cases = db.cases.find({}, { _id: 1, caseRef: 1 }).sort({ caseRef: 1 }).toArray();

print(`Found ${cases.length} cases`);

if (cases.length === 0) {
  print('No cases found');
  quit();
}

// Generate CSV content
const csvContent = 'caseRef,caseId\n' + cases.map(c => `${c.caseRef},${c._id.toString()}`).join('\n');

// Write to file
const fs = require('fs');
const outputPath = '/Users/nitinmali/workspace/farming/future-grants-perf-tests/data/perf_test_case_refs_frps.csv';

// Ensure directory exists
const path = require('path');
const outputDir = path.dirname(outputPath);
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

fs.writeFileSync(outputPath, csvContent, 'utf8');

print(`✅ Exported ${cases.length} cases to ${outputPath}`);
print(`   First: ${cases[0].caseRef} (${cases[0]._id})`);
print(`   Last: ${cases[cases.length - 1].caseRef} (${cases[cases.length - 1]._id})`);
