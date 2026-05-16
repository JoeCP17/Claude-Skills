---
name: copy-meaningful-snippet
description: Copy only the meaningful, paste-ready artifact from the current task to the clipboard, usually code, SQL, JSON, shell commands, or a clean text snippet without surrounding explanation. Use when the user asks to put something on the clipboard, copy only the useful part, copy just the query/code, remove commentary, or prepare a clean paste-ready result from recent work.
---

# Copy Meaningful Snippet

## Overview

Extract the smallest complete artifact that the user is likely to paste next, copy it to the clipboard, and exclude surrounding explanation.

Prefer exact executable content over summaries.

## Workflow

1. Identify the target artifact.
   Default to the most recent artifact produced for the current task.
   Prefer the user's latest narrowing instruction over recency when they specify a block, section, file, or format.

2. Keep only meaningful content.
   Copy code, SQL, JSON, shell commands, config, or the exact text snippet the user needs.
   Remove prose, bullet lists, status text, commentary, and duplicated context unless the user explicitly wants them.

3. Preserve execution integrity.
   Keep indentation, line breaks, quoting, and ordering intact.
   Do not rewrite content just to make it shorter if that would change behavior.

4. Normalize the wrapper only when useful.
   Remove Markdown fences by default.
   Keep notebook magics like `%sql` only when the destination is likely a notebook cell.
   Keep surrounding statements like `USE hmmall;` when they are part of the runnable artifact.

5. Copy with the platform-native clipboard command.
   On macOS, use `pbcopy`.
   Verify by reading back a short preview with `pbpaste`.

## Selection Rules

- Choose one artifact, not a recap, unless the user explicitly asks for multiple things.
- Prefer the final corrected version over earlier drafts.
- Prefer the exact contents of a code block over reconstructing it from prose.
- When the user asks for "only" something, obey that literally and strip nearby extras.
- If two plausible artifacts exist and the choice would materially change what gets pasted, ask one short clarifying question.

## Common Cases

### Query Only

Copy the final SQL body exactly as it should be pasted.
Keep `%sql` only for notebook-oriented requests.

### Code Only

Copy the final function, file contents, patch target snippet, or command sequence without explanation.

### Text Snippet

Copy the final wording only.
Exclude framing like "here is", "use this", or result summaries.

## Output

After copying, respond briefly.

Example:

`Copied to clipboard.`
