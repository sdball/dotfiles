#!/usr/bin/env python3
"""Render Jira API results (ADF JSON) as readable Markdown-ish text.

The Jira MCP's `description` field and each comment's `body` come back as ADF
JSON (`"type": "doc"`), not plain text. This renders that node tree as prose
so ticket summaries don't dump raw JSON or hand-roll a one-off parser per run.

    adf-to-md.py FILE [FILE ...]   # one or more results; comment pages merge
    cat result.json | adf-to-md.py # stdin when no FILE is given (or `-`)

Each input's shape is auto-detected:
- The raw MCP tool-result wrapper (`[{"type": "text", "text": "<json str>"}]`)
  is unwrapped first, so a persisted tool-results file can be passed as-is.
- An issue (`jira_get_issue` or REST `issue/KEY`, anything with `fields`):
  key, summary and the scalar fields that are set, issue links, attachments,
  the description, then any comments embedded under `fields.comment`.
- A comments page (`jira_get_comments` or REST `issue/KEY/comment`).
- A single comment object (REST `comment/ID`).
- A bare ADF doc (e.g. one `description`).

Comments from every input are merged by id and sorted by creation time, each
rendered under `=== <author> | <created> | id <id> ===`. When fewer comments
are present than the reported `total`, the header says so: fetch the missing
page with `startAt` and pass all pages together.

Handles: paragraph, heading (folded into a bold lead-in, no literal `#`),
bullet/ordered/task lists, codeBlock, blockquote, panel, expand, rule, table
(as a pipe table), text marks (strong/em/code/strike/link), hardBreak, mention,
inlineCard/blockCard/embedCard, emoji, date, status. Media becomes an
`[attachment]` placeholder; it is for reading a ticket, not round-tripping it.
"""

import json
import sys
from datetime import datetime, timezone


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
                elif m["type"] == "strike":
                    text = f"~~{text}~~"
            for m in n.get("marks", []):
                if m["type"] == "link":
                    href = m.get("attrs", {}).get("href", "")
                    text = text if text == href else f"[{text}]({href})"
            out.append(text)
        elif t == "hardBreak":
            out.append("\n")
        elif t == "mention":
            out.append("@" + n["attrs"].get("text", n["attrs"].get("id", "")).lstrip("@"))
        elif t == "inlineCard":
            out.append(n["attrs"].get("url", ""))
        elif t == "emoji":
            out.append(n["attrs"].get("shortName", ""))
        elif t == "date":
            ts = int(n["attrs"]["timestamp"]) / 1000
            out.append(datetime.fromtimestamp(ts, timezone.utc).strftime("%Y-%m-%d"))
        elif t == "status":
            out.append(f"[{n['attrs'].get('text', '')}]")
        elif t == "mediaInline":
            out.append("[attachment]")
    return "".join(out)


def render_blocks(nodes, indent=0, sep="\n\n"):
    return sep.join(r for r in (render_node(c, indent) for c in nodes or []) if r)


def render_list_item(li, indent):
    parts = []
    for c in li.get("content", []):
        r = render_node(c, indent + 1)
        if not r:
            continue
        if c.get("type") in ("bulletList", "orderedList", "taskList"):
            parts.append("\n" + r)
        else:
            parts.append((" " if parts else "") + r)
    return "".join(parts)


def render_table(n):
    rows = []
    for row in n.get("content", []):
        cells = [render_blocks(cell.get("content"), sep=" ").replace("\n", " ").replace("|", "\\|")
                 for cell in row.get("content", [])]
        rows.append(cells)
    if not rows:
        return ""
    width = max(len(r) for r in rows)
    lines = ["| " + " | ".join(r + [""] * (width - len(r))) + " |" for r in rows]
    lines.insert(1, "|" + " --- |" * width)
    return "\n".join(lines)


def quote(text):
    return "\n".join("> " + line if line else ">" for line in text.split("\n"))


def render_node(n, indent=0):
    t = n.get("type")
    pad = "  " * indent
    if t == "paragraph":
        return render_inline(n.get("content"))
    if t == "heading":
        return "**" + render_inline(n.get("content")) + "**"
    if t == "bulletList":
        return "\n".join(pad + "- " + render_list_item(li, indent) for li in n.get("content", []))
    if t == "orderedList":
        start = n.get("attrs", {}).get("order", 1)
        return "\n".join(pad + f"{i}. " + render_list_item(li, indent)
                         for i, li in enumerate(n.get("content", []), start))
    if t == "taskList":
        lines = []
        for item in n.get("content", []):
            box = "[x]" if item.get("attrs", {}).get("state") == "DONE" else "[ ]"
            lines.append(pad + f"- {box} " + render_inline(item.get("content")))
        return "\n".join(lines)
    if t == "listItem":
        return render_list_item(n, indent - 1)
    if t == "codeBlock":
        lang = n.get("attrs", {}).get("language") or ""
        return f"```{lang}\n{render_inline(n.get('content'))}\n```"
    if t == "blockquote":
        return quote(render_blocks(n.get("content")))
    if t == "panel":
        kind = n.get("attrs", {}).get("panelType", "info")
        return quote(f"**[{kind}]** " + render_blocks(n.get("content")))
    if t in ("expand", "nestedExpand"):
        title = n.get("attrs", {}).get("title") or "expand"
        return f"**{title}**\n\n" + render_blocks(n.get("content"))
    if t in ("blockCard", "embedCard"):
        return n.get("attrs", {}).get("url", "")
    if t == "rule":
        return "---"
    if t in ("mediaSingle", "media", "mediaGroup"):
        return "[attachment]"
    if t == "table":
        return render_table(n)
    if t == "text":
        return render_inline([n])
    return render_blocks(n.get("content"), indent) if n.get("content") else ""


def adf_to_text(doc):
    if not doc:
        return ""
    if isinstance(doc, str):
        return doc
    return render_blocks(doc.get("content"))


def field_text(v):
    """A one-line rendering of a field value, or None if it has no short form."""
    if v is None or v == "" or v == []:
        return None
    if isinstance(v, (str, int, float, bool)):
        return str(v)
    if isinstance(v, dict):
        if v.get("type") == "doc":
            return None
        if "key" in v and "fields" in v:
            return f"{v['key']} {v['fields'].get('summary', '')}".strip()
        for k in ("name", "displayName", "value", "key"):
            if k in v:
                return str(v[k])
        return None
    if isinstance(v, list):
        parts = [p for p in (field_text(x) for x in v) if p]
        return ", ".join(parts) if parts else None
    return None


ISSUE_FIELDS = ["status", "resolution", "priority", "issuetype", "assignee", "reporter",
                "created", "updated", "resolutiondate", "labels", "components",
                "versions", "fixVersions", "parent"]
SKIP_FIELDS = {"summary", "description", "comment", "issuelinks", "attachment", "subtasks",
               "lastViewed", "statuscategorychangedate", "workratio", "project"}


def render_issue(issue):
    f = issue["fields"]
    print(f"# {issue.get('key', '')}: {f.get('summary', '')}".rstrip(": "))
    print()
    others = sorted(k for k in f if k not in ISSUE_FIELDS and k not in SKIP_FIELDS)
    for k in ISSUE_FIELDS + others:
        v = field_text(f.get(k))
        if v:
            print(f"{k}: {v}")
    links = f.get("issuelinks") or []
    if links:
        print("\nlinks:")
        for link in links:
            if "outwardIssue" in link:
                rel, other = link["type"]["outward"], link["outwardIssue"]
            else:
                rel, other = link["type"]["inward"], link["inwardIssue"]
            of = other.get("fields", {})
            status = field_text(of.get("status"))
            print(f"- {rel} {other['key']}" + (f" [{status}]" if status else "")
                  + f" {of.get('summary', '')}".rstrip())
    for sub in f.get("subtasks") or []:
        print(f"- subtask {field_text(sub)}")
    atts = f.get("attachment") or []
    if atts:
        print("\nattachments:")
        for a in atts:
            print(f"- {a.get('filename')} ({a.get('size')} bytes, {a.get('created', '')})")
    desc = adf_to_text(f.get("description"))
    print("\n=== description ===")
    print(desc or "(empty)")
    for k in others:
        if isinstance(f.get(k), dict) and f[k].get("type") == "doc":
            print(f"\n=== {k} ===")
            print(adf_to_text(f[k]))
    print()


def load(path):
    src = sys.stdin.read() if path == "-" else open(path).read()
    parsed = json.loads(src)
    # Unwrap the raw MCP tool-result wrapper: [{"type": "text", "text": "<json str>"}]
    if isinstance(parsed, list) and parsed and "text" in parsed[0]:
        parsed = json.loads(parsed[0]["text"])
    return parsed


def main():
    args = sys.argv[1:]
    if not args:
        if sys.stdin.isatty():
            sys.exit(__doc__)
        args = ["-"]
    comments, totals, saw_comments = {}, [], False

    def add_page(page):
        nonlocal saw_comments
        saw_comments = True
        if page.get("total") is not None:
            totals.append(page["total"])
        for c in page.get("comments", []):
            comments[c.get("id") or id(c)] = c

    for path in args:
        parsed = load(path)
        if isinstance(parsed, dict) and isinstance(parsed.get("fields"), dict):
            render_issue(parsed)
            if isinstance(parsed["fields"].get("comment"), dict):
                add_page(parsed["fields"]["comment"])
        elif isinstance(parsed, dict) and isinstance(parsed.get("comments"), list):
            add_page(parsed)
        elif isinstance(parsed, dict) and parsed.get("type") == "doc":
            print(adf_to_text(parsed) + "\n")
        elif isinstance(parsed, dict) and "body" in parsed and "author" in parsed:
            add_page({"comments": [parsed]})
        else:
            sys.exit(f"adf-to-md: {path}: unrecognized shape (expected an issue, comments, "
                     "a comment, or an ADF doc)")

    if not saw_comments:
        return
    total = max(totals) if totals else len(comments)
    header = f"=== comments: {len(comments)} of {total} ==="
    if len(comments) < total:
        header += f" MISSING {total - len(comments)}: fetch the rest with startAt and pass every page"
    print(header + "\n")
    for c in sorted(comments.values(), key=lambda c: c.get("created", "")):
        author = (c.get("author") or {}).get("displayName", "unknown")
        print(f"=== {author} | {c.get('created', '')} | id {c.get('id', '')} ===")
        print(adf_to_text(c.get("body")))
        print()


if __name__ == "__main__":
    main()
