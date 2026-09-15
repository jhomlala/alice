# Changelog Rules

These are the rules for managing `CHANGELOG.md`:

1.  **Never remove previous changelog**: All historical entries must be preserved.
2.  **Use an "Unreleased" section**: When modifying the `CHANGELOG.md`, ALWAYS place new changes under an "## Unreleased" heading at the very top of the file, rather than adding them to the latest version. Create the section if it does not exist.
3.  **Group changes**: When working on a feature, do not add new lines for every small fix. Read the current "Unreleased" section and group similar changes together to avoid bloat.
4.  **Attribute authors**: If a change is contributed by someone else, please refer to them using their GitHub handle (e.g., @githubname).
