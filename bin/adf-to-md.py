#!/usr/bin/env python3
"""Convert Atlassian Document Format (ADF) to readable Markdown-ish text.

The Jira MCP's `description` field and each comment's `body` come back as ADF
JSON (`"type": "doc"`), not plain text. This renders that node tree as prose
so ticket summaries don't dump raw JSON or hand-roll a one-off parser per run.

    adf-to-md.py FILE        # single ADF doc (e.g. an issue `description`)
    cat body.json | adf-to-md.py -

Input shape is auto-detected:
- A bare ADF doc (`{"type": "doc", ...}`): renders it.
- A `jira_get_comments` response (`{"comments": [...], "total": N, ...}`):
  renders each comment as `=== <author> | <created> ===` then its body.
- The raw MCP tool-result wrapper (`[{"type": "text", "text": "<json str>"}]`):
  unwraps the inner JSON string first, then applies the two rules above.

Handles: paragraph, heading (folded into a bold lead-in, no literal `#`),
bulletList/orderedList/listItem, codeBlock, blockquote, rule, text marks
(strong/em/code), hardBreak, mention, inlineCard. mediaSingle/media/table
are summarized as a placeholder rather than rendered, since this is for
reading a ticket, not round-tripping it.
"""

import json
import sys


def render_inline(nodes):
    out = []
    for n in nodes or []:
        t = n.get("type")
        if t == "text":
            text = n["text"]
            for m in n.get("marks", []):
                if m["type"] == "strong":
                    text = f"**{text}**"
                elif m["type"] == "em":
                    text = f"_{text}_"
                elif m["type"] == "code":
                    text = f"`{text}`"
            out.append(text)
        elif t == "hardBreak":
            out.append("\n")
        elif t == "mention":
            out.append("@" + n["attrs"].get("text", n["attrs"].get("id", "")).lstrip("@"))
        elif t == "inlineCard":
            out.append(n["attrs"].get("url", ""))
        elif t == "emoji":
            out.append(n["attrs"].get("shortName", ""))
    return "".join(out)


def render_node(n, indent=0):
    t = n.get("type")
    if t == "paragraph":
        return render_inline(n.get("content"))
    if t == "heading":
        return "**" + render_inline(n.get("content")) + "**"
    if t == "bulletList":
        lines = []
        for li in n.get("content", []):
            sub = [render_node(c, indent + 1) for c in li.get("content", [])]
            lines.append("  " * indent + "- " + " ".join(s for s in sub if s))
        return "\n".join(lines)
    if t == "orderedList":
        lines = []
        for i, li in enumerate(n.get("content", []), 1):
            sub = [render_node(c, indent + 1) for c in li.get("content", [])]
            lines.append("  " * indent + f"{i}. " + " ".join(s for s in sub if s))
        return "\n".join(lines)
    if t == "listItem":
        sub = [render_node(c, indent) for c in n.get("content", [])]
        return " ".join(s for s in sub if s)
    if t == "codeBlock":
        return f"```\n{render_inline(n.get('content'))}\n```"
    if t == "blockquote":
        sub = [render_node(c, indent) for c in n.get("content", [])]
        return "> " + " ".join(s for s in sub if s)
    if t == "rule":
        return "---"
    if t in ("mediaSingle", "media", "mediaGroup"):
        return "[attachment]"
    if t == "table":
        return "[table omitted]"
    return render_inline(n.get("content")) if n.get("content") else ""


def adf_to_text(doc):
    if not doc:
        return ""
    return "\n\n".join(r for r in (render_node(n) for n in doc.get("content", [])) if r)


def render(parsed):
    if isinstance(parsed, dict) and parsed.get("type") == "doc":
        sys.stdout.write(adf_to_text(parsed) + "\n")
        return
    if isinstance(parsed, dict) and "comments" in parsed:
        print(f"TOTAL: {parsed.get('total')}, RETURNED: {len(parsed['comments'])}\n")
        for c in parsed["comments"]:
            author = c.get("author", {}).get("displayName", "unknown")
            created = c.get("created", "")
            print(f"=== {author} | {created} ===")
            print(adf_to_text(c.get("body")))
            print()
        return
    sys.exit("adf-to-md: unrecognized shape (expected an ADF doc or a jira_get_comments response)")


def main():
    args = sys.argv[1:]
    if not args:
        sys.exit(__doc__)
    src = sys.stdin.read() if args[0] == "-" else open(args[0]).read()
    parsed = json.loads(src)
    # Unwrap the raw MCP tool-result wrapper: [{"type": "text", "text": "<json str>"}]
    if isinstance(parsed, list) and parsed and "text" in parsed[0]:
        parsed = json.loads(parsed[0]["text"])
    render(parsed)


if __name__ == "__main__":
    main()
