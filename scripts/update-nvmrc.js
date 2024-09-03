const fs = require("fs");
const path = require("path");

// Get the root directory (parent of the scripts folder)
const rootPath = path.join(__dirname, "..");

// Read package.json from the root
const packageJsonPath = path.join(rootPath, "package.json");
let packageJson;

try {
  packageJson = require(packageJsonPath);
} catch (error) {
  console.error(`Error reading package.json: ${error.message}`);
  process.exit(1);
}

// Extract Node.js version from engines field
const packageNodeVersion = packageJson.engines.node;

if (!packageNodeVersion) {
  console.error("Node.js version not found in package.json");
  process.exit(1);
}

// Clean up the version string (remove ^, ~, or >=)
const nvmNodeVersion = packageNodeVersion.replace(/[^0-9.]/g, '');

// Path to .nvmrc file
const nvmrcPath = path.join(rootPath, ".nvmrc");

// Check if .nvmrc exists and read its content
let currentNvmrcVersion = "";
try {
  currentNvmrcVersion = fs.readFileSync(nvmrcPath, "utf8").trim();
} catch (error) {
  // File doesn't exist or can't be read, we'll create/update it
}

// Compare versions and update only if necessary
if (currentNvmrcVersion !== nvmNodeVersion) {
  try {
    fs.writeFileSync(nvmrcPath, nvmNodeVersion);
    console.log(`.nvmrc updated with Node.js version ${nvmNodeVersion}`);
  } catch (error) {
    console.error(`Error writing .nvmrc: ${error.message}`);
    process.exit(1);
  }
}