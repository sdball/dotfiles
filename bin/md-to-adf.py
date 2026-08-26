#!/usr/bin/env python3
"""Convert a Markdown subset to Atlassian Document Format (ADF).

The Jira MCP's `description` parameter takes plain text and wraps it in
paragraphs, so fenced code blocks, tables and inline code all render as literal
characters. This produces real ADF so those render as nodes.

    md-to-adf.py FILE            # ADF JSON on stdout
    md-to-adf.py FILE --wrap doc # same (default)
    cat body.md | md-to-adf.py -

Handles the constructs our Jira drafts actually use: ATX headings, fenced code
blocks, GFM tables with a header row, bullet and ordered lists, blockquotes,
horizontal rules, paragraphs, and inline `code`, **strong**, *em* and bare URLs.
Everything else passes through as plain text.

Known ADF gotcha this deliberately avoids: a strong mark spanning inline code
gets truncated on render, so inline code is always emitted as its own text node
carrying only the `code` mark, never `code` plus `strong`.
"""

import json
import re
import sys

INLINE = re.compile(
    r'(?P<code>`[^`]+`)'
    r'|(?P<strong>\*\*[^*]+\*\*)'
    r'|(?P<em>(?<![*\w])\*[^*\s][^*]*\*(?![*\w]))'
    r'|(?P<link>\[[^\]]+\]\([^)]+\))'
    r'|(?P<url>https?://[^\s)\]]+)'
)


def text_node(value, marks=None):
    node = {"type": "text", "text": value}
    if marks:
        node["marks"] = [{"type": m} if isinstance(m, str) else m for m in marks]
    return node


def inline_nodes(line):
    """Split a line into ADF text nodes, honouring inline marks."""
    nodes, pos = [], 0
    for m in INLINE.finditer(line):
        if m.start() > pos:
            nodes.append(text_node(line[pos:m.start()]))
        kind = m.lastgroup
        raw = m.group()
        if kind == 'code':
            # code mark alone: never combined with strong, which ADF truncates
            nodes.append(text_node(raw[1:-1], ['code']))
        elif kind == 'strong':
            inner = raw[2:-2]
            if '`' in inner:
                # ADF truncates a strong span containing inline code, and this
                # converter does not recurse into marks, so the backticks would
                # be emitted literally. Refuse rather than ship it silently.
                print('md-to-adf: inline code inside bold, move the backticks '
                      'outside the bold run: %r' % raw[:70], file=sys.stderr)
            nodes.append(text_node(inner, ['strong']))
        elif kind == 'em':
            nodes.append(text_node(raw[1:-1], ['em']))
        elif kind == 'link':
            label, href = re.match(r'\[([^\]]+)\]\(([^)]+)\)', raw).groups()
            nodes.append(text_node(label, [{"type": "link", "attrs": {"href": href}}]))
        else:
            nodes.append(text_node(raw, [{"type": "link", "attrs": {"href": raw}}]))
        pos = m.end()
    if pos < len(line):
        nodes.append(text_node(line[pos:]))
    return nodes or [text_node("")]


def paragraph(lines):
    return {"type": "paragraph", "content": inline_nodes(" ".join(lines).strip())}


def table(rows):
    """rows[0] is the header. Separator row is already stripped by the caller."""
    def cell(kind, value):
        return {"type": kind, "attrs": {}, "content": [
            {"type": "paragraph", "content": inline_nodes(value.strip())}]}
    out = []
    for i, row in enumerate(rows):
        kind = "tableHeader" if i == 0 else "tableCell"
        out.append({"type": "tableRow", "content": [cell(kind, c) for c in row]})
    return {"type": "table", "attrs": {"isNumberColumnEnabled": False,
                                       "layout": "default"}, "content": out}


def split_row(line):
    line = line.strip()
    if line.startswith('|'):
        line = line[1:]
    if line.endswith('|'):
        line = line[:-1]
    return line.split('|')


def is_separator(line):
    return bool(re.match(r'^\s*\|?[\s:|-]+\|[\s:|-]*$', line)) and '-' in line


def convert(md):
    content, lines, i = [], md.split('\n'), 0
    para, listbuf, listkind = [], [], None

    def flush_para():
        nonlocal para
        if para:
            content.append(paragraph(para))
            para = []

    def flush_list():
        nonlocal listbuf, listkind
        if listbuf:
            content.append({
                "type": "bulletList" if listkind == 'ul' else "orderedList",
                "content": [{"type": "listItem",
                             "content": [{"type": "paragraph",
                                          "content": inline_nodes(it)}]} for it in listbuf]})
            listbuf, listkind = [], None

    def flush():
        flush_para()
        flush_list()

    while i < len(lines):
        line = lines[i]

        if line.strip().startswith('```'):
            flush()
            lang = line.strip()[3:].strip() or None
            body, i = [], i + 1
            while i < len(lines) and not lines[i].strip().startswith('```'):
                body.append(lines[i])
                i += 1
            i += 1
            node = {"type": "codeBlock", "attrs": {}, "content": [
                text_node('\n'.join(body))] if body else []}
            if lang:
                node["attrs"]["language"] = lang
            content.append(node)
            continue

        heading = re.match(r'^(#{1,6})\s+(.*)$', line)
        if heading:
            flush()
            content.append({"type": "heading",
                            "attrs": {"level": min(len(heading.group(1)), 6)},
                            "content": inline_nodes(heading.group(2).strip())})
            i += 1
            continue

        if re.match(r'^\s*(\*\s*){3,}$|^\s*(-\s*){3,}$|^\s*(_\s*){3,}$', line):
            flush()
            content.append({"type": "rule"})
            i += 1
            continue

        # GFM table: a pipe row followed by a separator row
        if '|' in line and i + 1 < len(lines) and is_separator(lines[i + 1]):
            flush()
            rows = [split_row(line)]
            i += 2
            while i < len(lines) and '|' in lines[i] and lines[i].strip():
                rows.append(split_row(lines[i]))
                i += 1
            content.append(table(rows))
            continue

        bullet = re.match(r'^\s*[-*+]\s+(.*)$', line)
        ordered = re.match(r'^\s*\d+[.)]\s+(.*)$', line)
        if bullet or ordered:
            flush_para()
            kind = 'ul' if bullet else 'ol'
            if listkind and listkind != kind:
                flush_list()
            listkind = kind
            listbuf.append((bullet or ordered).group(1).strip())
            i += 1
            continue

        quote = re.match(r'^\s*>\s?(.*)$', line)
        if quote:
            flush()
            body = [quote.group(1)]
            i += 1
            while i < len(lines) and re.match(r'^\s*>\s?', lines[i]):
                body.append(re.sub(r'^\s*>\s?', '', lines[i]))
                i += 1
            content.append({"type": "blockquote", "content": [paragraph(body)]})
            continue

        if not line.strip():
            flush()
            i += 1
            continue

        flush_list()
        para.append(line.strip())
        i += 1

    flush()
    return {"type": "doc", "version": 1, "content": content or [
        {"type": "paragraph", "content": [text_node("")]}]}


def main():
    args = sys.argv[1:]
    if not args:
        sys.exit(__doc__)
    as_fields = '--fields' in args
    args = [a for a in args if not a.startswith('--')]
    if not args:
        sys.exit(__doc__)
    src = sys.stdin.read() if args[0] == '-' else open(args[0]).read()
    doc = convert(src)
    # --fields emits a ready-to-PUT issue payload, as /tmp/md2adf.py did
    json.dump({"fields": {"description": doc}} if as_fields else doc, sys.stdout)
    sys.stdout.write('\n')


if __name__ == '__main__':
    main()
