# BB Tournament Manager

BB Tournament Manager is a web app for managing BB tournaments. In includes the following key features.

Admin
- Tournament Creation
- Tournament Editing
- Round Management/Editing/Processing

Participant
- Enter Results
- View Pairings
- View Rankings

# Setup Guide

This guide will walk you through setting up the necessary tools and environment to run this project. We'll be using Homebrew, Node Version Manager (NVM), and Flutter Version Manager (FVM).

## Prerequisites

- macOS (for Homebrew installation)
- Terminal access

## Step 1: Install [Homebrew](https://brew.sh/)

Homebrew is a package manager for macOS. If you don't have it installed, run this command in your terminal:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

After installation, follow the instructions in the terminal to add Homebrew to your PATH.

## Step 2: Install [NVM (Node Version Manager)](https://github.com/nvm-sh/nvm?tab=readme-ov-file#installing-and-updating)

NVM allows you to install and manage multiple versions of Node.js. Install it using Homebrew:

```bash
brew install nvm
```

And follow the provided steps to update and re-source your profile.

## Step 3: Install Node.js

Install the Node.js version required for this project:

```bash
nvm use
```

## Step 4: Install [FVM (Flutter Version Manager)](https://fvm.app/documentation/getting-started/installation)

FVM helps manage Flutter SDK versions.

```bash
brew install fvm
```

And follow the provided steps to update and re-source your profile.

## Step 4b: Automatically select the correct Node.js and Flutter versions when changing working directory

See below (optional but useful)

## Step 5: Install Flutter & Dart

Install the Flutter and Dart version required for this project:

```bash
fvm use
```

## Step 6: Install Project Dependencies

Install Node.js dependencies:

```bash
npm install
```

Install Flutter dependencies:

```bash
fvm flutter pub get
```

## Step 7: Run the Project

To run the Flutter part of your project:

```bash
fvm flutter run
```

To run any Node.js scripts:

```bash
npm run [script-name]
```

## Additional Notes

- Always use `fvm flutter` and `fvm dart` commands within this project to ensure you're using the correct Flutter version.
- If you switch between different projects, run `nvm use` and `fvm use` to use the correct framework version.

## Automatically select the correct Node.js and Flutter versions when changing working directory

Currently examples are specific to zsh terminal

### NVM

Use the `zsh-nvm` plugin e.g. with `zinit`:

```bash
# Load zsh-nvm plugin
export NVM_AUTO_USE=true
zinit ice wait lucid
zinit light lukechilds/zsh-nvm
```

### FVM

Copy this script to a file `.zsh_fvm_auto_use.zsh` and source it from within your `.zshrc`

```bash
# Function to auto-switch Flutter version using FVM
fvm_auto_use() {
  if [[ -x "$(command -v fvm)" ]]; then
    echo "Warning: FVM is not installed or not in PATH. Please install FVM to enable auto-use."
    return 1
  fi

  local fvmrc_file=".fvmrc"
  local fvm_release_file=".fvm/release"

  if [[ -f "$fvmrc_file" ]]; then
    local npmrc_version=$(grep '"flutter":' "$fvmrc_file" | sed 's/.*"flutter": *"\(.*\)".*/\1/')

    if [[ -n "$npmrc_version" ]]; then
      echo "Found $fvmrc_file with version <$npmrc_version>"

      if [[ ! -f "$fvm_release_file" || $(cat "$fvm_release_file") != "$npmrc_version" ]]; then
        echo "Switching Flutter version to $npmrc_version"
        fvm use "$npmrc_version"
      fi
      echo "Now using Flutter version $npmrc_version."
    fi
  fi
}

# Add the function to the chpwd hook (called when changing directories)
autoload -U add-zsh-hook
add-zsh-hook chpwd fvm_auto_use

# Run the function on shell startup
fvm_auto_use
```
