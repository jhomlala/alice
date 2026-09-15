---
name: Prepare Alice Release
description: Workflow and rules for preparing packages for a new release (bumping versions, updating changelogs and docs).
---

# Prepare Alice Release

When instructed to prepare a release for the `alice` project, you must analyze the packages, determine the correct version bumps, and update all necessary files following these rules.

## 1. Analyze Changes
For every package in the `packages/` directory **except `alice_test`** (which is `publish_to: none` and never released):
- Look at the `CHANGELOG.md` file.
- If there is an `## Unreleased` section with bullet points, this package needs a release.
- If there is no `## Unreleased` section (or it's empty), skip this package.

## 2. Determine Version Bump
Packages are versioned independently. For each package that needs a release:
- Read the current version from `pubspec.yaml`.
- Use your best judgement based on the bullet points in the `## Unreleased` section to decide whether to bump **PATCH** (bug fixes, small tweaks) or **MINOR** (new features, significant changes).
- **CRITICAL RULE**: Never automatically bump the MAJOR version. Major version bumps require explicit human approval.

## 3. Apply the Updates
For each package being updated, make the following modifications:

### A. Changelog Update
- In `CHANGELOG.md`, rename `## Unreleased` to `## [New Version]` (e.g., `## 1.3.0`).
- Do **NOT** add the current date to the changelog heading.

### B. Pubspec Update
- In `pubspec.yaml`, update the `version:` field to the new version.

### C. Dependency Sync
- After bumping a package, check if any *other* packages in `packages/` depend on it.
- For each dependent package, always update the dependency's lower bound to the new version — even if the old constraint technically still satisfies semver. For example, if `alice` bumps from `1.2.0` to `1.3.0`, update dependents from `alice: ^1.2.0` to `alice: ^1.3.0`. This ensures the workspace always tracks the latest release as the minimum.
- Do **NOT** update version pins in `examples/` — those use workspace path resolution, not pub.dev version pins.

### D. Documentation Updates
- Search for references to the old version in the root `README.md` and in each package's own `README.md` (installation/dependency snippets that show a version number).
- Update any such snippets to reflect the new version.

## 4. Final Review
After applying all changes, summarize the version bumps you prepared and ask the user to review before proceeding to the actual publish phase (which uses the `publish.md` workflow).
