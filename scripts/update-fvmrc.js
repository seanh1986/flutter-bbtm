const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

// Get the root directory (parent of the scripts folder)
const rootPath = path.join(__dirname, '..');

// Read pubspec.yaml from the root
const pubspecPath = path.join(rootPath, 'pubspec.yaml');
let pubspecContent;

try {
  pubspecContent = fs.readFileSync(pubspecPath, 'utf8');
} catch (error) {
  console.error(`Error reading pubspec.yaml: ${error.message}`);
  process.exit(1);
}

// Parse pubspec.yaml
let pubspec;
try {
  pubspec = yaml.load(pubspecContent);
} catch (error) {
  console.error(`Error parsing pubspec.yaml: ${error.message}`);
  process.exit(1);
}

// Extract Flutter SDK version from environment field
const pubspecFlutterVersion = pubspec.environment?.flutter;

if (!pubspecFlutterVersion) {
  console.error('Flutter SDK version not found in pubspec.yaml');
  process.exit(1);
}

// Clean up the version string (remove ^, ~, or >=)
const fvmFlutterVersion = pubspecFlutterVersion.replace(/[^0-9.]/g, '');

// Create the JSON content
const fvmrcContent = JSON.stringify({ flutter: fvmFlutterVersion }, null, 2);

// Path to .fvmrc file
const fvmrcPath = path.join(rootPath, '.fvmrc');

// Check if .fvmrc exists and read its content
let currentFvmrcVersion = '';
try {
  currentFvmrcVersion = fs.readFileSync(fvmrcPath, 'utf8').trim();
} catch (error) {
  // File doesn't exist or can't be read, we'll create/update it
}

// Compare versions and update only if necessary
if (currentFvmrcVersion !== fvmrcContent) {
  try {
    fs.writeFileSync(fvmrcPath, fvmrcContent);
    console.log(`.fvmrc updated with Flutter SDK version ${fvmFlutterVersion}`);
  } catch (error) {
    console.error(`Error writing .fvmrc: ${error.message}`);
    process.exit(1);
  }
}
