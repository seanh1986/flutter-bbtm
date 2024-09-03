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
const nodeVersion = packageJson.engines.node.replace(">=", "");

if (!nodeVersion) {
  console.error("Node.js version not found in package.json");
  process.exit(1);
}

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
if (currentNvmrcVersion !== nodeVersion) {
  try {
    fs.writeFileSync(nvmrcPath, nodeVersion);
    console.log(`.nvmrc updated with Node.js version ${nodeVersion}`);
  } catch (error) {
    console.error(`Error writing .nvmrc: ${error.message}`);
    process.exit(1);
  }
}