#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Error: expected exactly one Markdown file path" >&2
  echo "Usage: md-to-pdf.sh <markdown_file_path>" >&2
  exit 1
fi

input_file=$1
input_file="${input_file/#\~/$HOME}"

if [[ ! -f "$input_file" ]]; then
  echo "Error: file not found: $input_file" >&2
  exit 1
fi

if ! command -v pandoc >/dev/null 2>&1; then
  echo "Error: pandoc not found. Install with: brew install pandoc" >&2
  exit 1
fi

if ! command -v weasyprint >/dev/null 2>&1; then
  echo "Error: weasyprint not found. Install with: pipx install weasyprint" >&2
  exit 1
fi

output_dir="$HOME/Downloads"
mkdir -p "$output_dir"

input_dir=$(cd "$(dirname "$input_file")" && pwd)
base_href=$(python3 -c 'from pathlib import Path; import sys; print(Path(sys.argv[1]).resolve().as_uri())' "$input_dir")

input_name=$(basename "$input_file")
base_name="${input_name%.*}"
if [[ -z "$base_name" || "$base_name" == "$input_name" ]]; then
  base_name="$input_name"
fi

output_pdf="$output_dir/${base_name}.pdf"
if [[ -f "$output_pdf" ]]; then
  timestamp=$(date +%Y%m%d_%H%M%S)
  output_pdf="$output_dir/${base_name}_${timestamp}.pdf"
fi

temp_dir=$(mktemp -d /tmp/md-to-pdf.XXXXXX)
temp_html="$temp_dir/document.html"
cleanup() {
  rm -rf "$temp_dir"
}
trap cleanup EXIT

cat >"$temp_html" <<'HTMLHEAD'
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<base href="BASE_HREF_PLACEHOLDER/">
<style>
@page { size: A4; margin: 20mm 15mm; }
body {
    font-family: "Apple SD Gothic Neo", "AppleGothic", -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
    font-size: 14px;
    line-height: 1.6;
    max-width: 900px;
    margin: 0 auto;
    color: #1a1a1a;
}
h1, h2, h3, h4, h5, h6 { margin-top: 24px; margin-bottom: 16px; font-weight: 600; line-height: 1.25; }
h1 { font-size: 2em; border-bottom: 1px solid #eaecef; padding-bottom: 0.3em; }
h2 { font-size: 1.5em; border-bottom: 1px solid #eaecef; padding-bottom: 0.3em; }
h3 { font-size: 1.25em; }
p { margin-top: 0; margin-bottom: 16px; }
a { color: #0366d6; text-decoration: none; }
code {
    font-family: "SFMono-Regular", Consolas, "Liberation Mono", Menlo, monospace;
    font-size: 85%;
    background-color: rgba(27,31,35,0.05);
    padding: 0.2em 0.4em;
    border-radius: 3px;
}
pre {
    background-color: #f6f8fa;
    padding: 16px;
    overflow: auto;
    font-size: 85%;
    line-height: 1.45;
    border-radius: 6px;
}
pre code { background-color: transparent; padding: 0; }
blockquote { margin: 16px 0; padding: 12px 16px; background-color: #f8f9fa; border-left: 4px solid #4a90d9; color: #333; }
blockquote p { margin: 0; }
table { border-collapse: collapse; width: 100%; margin-bottom: 16px; }
table th, table td { padding: 10px 13px; border: 1px solid #d0d7de; }
table th { background-color: #f6f8fa; font-weight: 600; }
table tr:nth-child(even) { background-color: #f6f8fa; }
ul, ol { padding-left: 2em; margin-top: 0; margin-bottom: 16px; }
li + li { margin-top: 0.25em; }
img { max-width: 100%; height: auto; }
hr { height: 0.25em; padding: 0; margin: 24px 0; background-color: #d0d7de; border: 0; }
</style>
</head>
<body>
HTMLHEAD

python3 - "$temp_html" "$base_href" <<'PY'
from pathlib import Path
import sys

html_path = Path(sys.argv[1])
base_href = sys.argv[2]
html_path.write_text(
    html_path.read_text(encoding="utf-8").replace("BASE_HREF_PLACEHOLDER", base_href),
    encoding="utf-8",
)
PY

pandoc "$input_file" -f markdown+wikilinks_title_after_pipe -t html >>"$temp_html"
printf '%s\n' '</body></html>' >>"$temp_html"

weasyprint "$temp_html" "$output_pdf"

printf '%s\n' "$output_pdf"
