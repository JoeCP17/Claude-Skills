---
name: md-to-pdf
description: Convert Markdown files to PDF with pandoc and WeasyPrint. Use when the user wants to export a `.md` note, document, README, or Obsidian page as a PDF, preserve readable styling, or produce a PDF copy of Markdown content without manually rebuilding the conversion pipeline.
---

# Markdown To PDF

Convert one Markdown file into a PDF and save it to `~/Downloads`.

Keep the workflow deterministic by using the bundled shell script instead of rewriting the conversion steps inline.

## Workflow

1. Validate that the user provided exactly one Markdown file path.
2. Expand `~` in the input path and confirm the file exists.
3. Confirm `pandoc` and `weasyprint` are installed.
4. Run `scripts/md-to-pdf.sh "<markdown-file>"`.
5. Report the final PDF path from the script output.

## Behavior

- Write the PDF to `~/Downloads/<input-basename>.pdf`.
- If that file already exists, append a timestamp suffix before `.pdf`.
- Use embedded CSS for a clean document-style layout.
- Resolve standard Markdown image paths and Obsidian `![[image.png]]` embeds relative to the source note.
- Keep the operation single-file and local. Do not upload content anywhere.

## Prerequisites

- `pandoc`
- `weasyprint`

If either command is missing, stop and tell the user exactly which install command to run:

- `brew install pandoc`
- `pipx install weasyprint`

## Execution

Run:

```bash
./scripts/md-to-pdf.sh "/path/to/file.md"
```

Use the exact user-supplied path when possible. Preserve spaces in paths by quoting the argument.

## Output

After conversion, tell the user the exact PDF path and whether a timestamped filename was used to avoid overwriting an existing file.
