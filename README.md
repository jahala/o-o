# o-o (looky-looky)

**The page has eyes.** Each `.o-o.html` file is a self-updating living document — open it in a browser to read, run it with `bash` to update.

```
open  article.o-o.html   # read it
bash  article.o-o.html   # update it
```

No build step, no server, no database. The file *is* the app.

Every `.o-o.html` is a polyglot — valid HTML *and* valid bash. The browser renders a formatted article with TOC, citations, and embedded images. Bash reads an embedded update contract, launches an LLM research agent, and the agent edits the article in-place with fresh information from the web.

## Quick Start

```bash
# Update an existing document
bash example/anthropic-leadership.o-o.html

# Create a new living document
bash example/index.o-o.html --new "Quantum Computing / Overview of recent breakthroughs and practical applications"

# Update all stale documents
bash example/index.o-o.html --update-all
```

## How It Works

```
┌─────────────────────────────────────────┐
│  Shell preamble (hidden from browser    │  ← bash reads this
│  via : << 'OO_HTML' heredoc)            │
├─────────────────────────────────────────┤
│  HTML + CSS + Article content           │  ← browser renders this
│  Manifest, Binder JS, Contract          │
├── window.stop() ────────────────────────┤
│  Machine-readable zone                  │  ← agent reads this
│  (source cache, changelog)              │
├── OO_HTML ──────────────────────────────┤
│  Shell execution code                   │  ← bash runs this
│  (arg parsing, agent dispatch)          │
└─────────────────────────────────────────┘
```

When you run `bash file.o-o.html`:

1. The shell preamble hides the HTML via a heredoc
2. The shell code at the bottom parses flags and extracts the budget
3. It launches `claude -p` with a minimal prompt: *read the file yourself*
4. The agent reads the embedded contract, searches the web, and edits the article in-place

The agent never receives the whole file as prompt context — it reads the file itself and only modifies the `<article>`, manifest, source cache, and changelog.

## The Update Contract

Each document embeds a JSON contract that tells the agent everything:

- **Identity** — subject, scope, audience, tone
- **Research** — search intents, required sections, source policy (preferred/denied domains)
- **Budget** — max cost per update ($0.50–$3.00 typical)
- **Images** — whether to embed base64 images, size limits, layout guidance
- **Freshness** — daily/weekly/monthly — the file self-checks before spending money

Click the **version badge** in the header to inspect the contract in-browser.

## Index / Library Manager

`index.o-o.html` serves as both a browsable document library and a management tool:

```bash
bash index.o-o.html                                    # Rebuild index
bash index.o-o.html --new "Topic / extended scope"     # Create new document
bash index.o-o.html --new                              # Create (interactive)
bash index.o-o.html --update-all                       # Update stale documents
bash index.o-o.html --update-all --force               # Force update all
```

## Images

Documents can include base64-embedded images. The agent downloads, resizes, and encodes images inline as data URIs.

| Class | Use case | Width |
|---|---|---|
| `fig-right` | Portraits, headshots | 28%, floated right |
| `fig-left` | Logos, icons | 28%, floated left |
| `fig-full` | Diagrams, charts, group photos | 100% |
| `fig-center` | Standalone feature photos | 70%, centered |

## Options

```
bash document.o-o.html [OPTIONS]

  --agent NAME    Agent backend (default: claude)
  --model NAME    Override model (e.g. opus, sonnet, haiku)
  --force         Update even if document is still fresh
  --help, -h      Show help
```

## Requirements

- **bash 3.2+** (ships with macOS) or any modern Linux bash
- **[Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)** (`claude` command)

No Python, Node, jq, or GNU coreutils. Portable across macOS and Linux.

## License

MIT
