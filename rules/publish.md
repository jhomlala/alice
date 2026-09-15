---
name: Publish Alice Packages
description: Workflow and instructions for publishing alice packages and creating a GitHub tag release.
---

# Publish Alice Packages

When instructed to publish the `alice` packages, you must follow this workflow carefully to ensure dependencies are published in the correct order and the release is properly documented.

## Prerequisites
- Ensure `GITHUB_TOKEN` is set in your environment (required for creating the GitHub release):
  ```powershell
  $env:GITHUB_TOKEN="your_token_here"
  ```
- All packages must be versioned and their `CHANGELOG.md` files must be up-to-date before publishing.

## 1. Check for Unreleased Sections

Before starting the publish process, verify that there are no `## Unreleased` sections in any `CHANGELOG.md` file. **If there is any `## Unreleased` section, then block the process and do not proceed!** You must ask the user to fix the changelog before continuing.

## 2. Publish Order

Packages must be published from least dependent to most complicated. Run `flutter pub publish --force` inside each package directory in this **strict order**. Do not run a dry-run, use `--force`. Only publish packages that actually have a new version (if a package is not needed to be released, skip it).

### Step 1 — Main Package
```powershell
cd packages/alice
flutter pub publish --force
```
Wait for this to complete successfully before proceeding.

### Step 2 — Other Packages (can be done in sequence)
```powershell
cd packages/alice_chopper
flutter pub publish --force

cd packages/alice_dio
flutter pub publish --force

cd packages/alice_graphql_client
flutter pub publish --force

cd packages/alice_http
flutter pub publish --force

cd packages/alice_http_client
flutter pub publish --force

cd packages/alice_objectbox
flutter pub publish --force
```
If any package fails to publish because the version already exists, you can ignore the error for that package, as it means it didn't need to be released. If it fails for another reason, **stop immediately**.

## 3. Create GitHub Tag and Release

After all packages have been published successfully, you must create a GitHub Release using the automated script.

This script checks each package against pub.dev: if the local version does not yet exist on pub.dev, it is included in the release notes. The release version (git tag name) is based on the `alice` main package version.

```powershell
# Make sure your user token is set
$env:GITHUB_TOKEN = [Environment]::GetEnvironmentVariable("GITHUB_TOKEN", "User")

# Run the release script
dart run scripts/create_github_release.dart
```
