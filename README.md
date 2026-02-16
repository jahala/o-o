# LIKI v2 — Living Documents

LIKI (LLM Insight and Knowledge Interface) is a format for **self-updating living documents**. Each `.ld.html` file is a polyglot — simultaneously a readable HTML page and a bash script that updates itself via an LLM research agent.

**Open it in a browser** to read. **Run it with bash** to update.

```
browser:  open example/anthropic-leadership.ld.html
update:   bash example/anthropic-leadership.ld.html
```

## How It Works

A `.ld.html` file has three zones:

```
┌─────────────────────────────────────────┐
│  Shell preamble (hidden from browser    │  ← bash reads this
│  via : << 'LIKI_HTML' heredoc)          │
├─────────────────────────────────────────┤
│  HTML + CSS + Article content           │  ← browser renders this
│  Manifest, Binder JS, Contract          │
├── window.stop() ────────────────────────┤
│  Machine-readable zone                  │  ← agent reads this
│  (source cache, changelog)              │
├── LIKI_HTML ────────────────────────────┤
│  Shell execution code                   │  ← bash runs this
│  (arg parsing, agent dispatch)          │
└─────────────────────────────────────────┘
```

When you run `bash file.ld.html`:

1. The shell preamble is skipped (it's a heredoc comment)
2. The shell code at the bottom parses `--agent` / `--model` flags
3. It extracts the budget from the embedded contract
4. It launches `claude -p` with a minimal prompt telling the agent to read the file itself
5. The agent reads the update contract (`liki-contract` JSON), researches via web search, and edits the article content in-place using the Edit tool

The agent never receives the whole file as prompt context — it reads the file itself and only modifies the `<article>`, manifest, source cache, and changelog.

## File Anatomy

Each document contains:

| Block | Purpose |
|---|---|
| **Shell preamble** | `#!/usr/bin/env bash` + heredoc to hide HTML from bash |
| **CSS** | Self-contained styles, no external dependencies |
| **Article** | `<article id="article">` with `<!-- pid:section:hash -->` paragraph IDs |
| **Manifest** | `liki-manifest` JSON — title, version, as_of date, quality scores |
| **Binder JS** | Runtime JS — TOC generation, citation linking, scroll highlighting, contract panel |
| **Contract** | `liki-contract` JSON — agent instructions, research intents, quality thresholds, budget |
| **`window.stop()`** | Rendering boundary — browser stops here |
| **Source cache** | `liki-source-cache` JSON — previous research for incremental updates |
| **Changelog** | `liki-changelog` JSON — version history |
| **Shell code** | Argument parsing, agent dispatch |

## The Update Contract

The contract is a JSON block that tells the agent everything:

- **identity** — subject, scope, audience, tone
- **research** — search intents, required sections, source policy (preferred/denied domains, min tier, max age)
- **quality** — veracity and coverage thresholds, min sources
- **budget** — max cost, max searches, max page fetches
- **images** — whether to embed base64 images, size limits, layout guidance

Click the **version badge** in the header to inspect the contract in-browser.

## Images

Documents can include base64-embedded images. The agent downloads, resizes (preserving PNG transparency), and encodes images inline as data URIs. Four layout classes:

| Class | Use case | Width |
|---|---|---|
| `fig-right` | Portraits, headshots | 28%, floated right |
| `fig-left` | Logos, icons | 28%, floated left |
| `fig-full` | Diagrams, charts, group photos | 100% |
| `fig-center` | Standalone feature photos | 70%, centered |

All images include source attribution. Floats collapse to full-width on mobile.

## Index / Library Manager

`index.ld.html` serves as both a browsable document library and a management tool:

```bash
bash index.ld.html                                    # Rebuild index
bash index.ld.html --new "Topic / extended scope"     # Create new document
bash index.ld.html --update-all                       # Update all stale documents
```

The `--new` command scaffolds a complete `.ld.html` from the embedded template, then immediately runs the first update to populate it.

## Requirements

- **bash 3.2+** (ships with macOS) or any modern Linux bash
- **[Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)** (`claude` command)
- No Python, Node, jq, or GNU coreutils needed

All shell code is portable across macOS (BSD) and Linux (GNU). No `sed -i`, no `realpath`, no `chmod --reference`.

## Options

```
bash document.ld.html [OPTIONS]

  --agent NAME    Agent backend (default: claude)
  --model NAME    Override model (e.g. opus, sonnet, haiku)
  --help, -h      Show help
```

## Example

```bash
# Create a new living document about quantum computing
bash example/index.ld.html --new "Quantum Computing / Overview of quantum computing technology, major players, recent breakthroughs, and practical applications"

# Update an existing document
bash example/anthropic-leadership.ld.html

# Update with a specific model
bash example/anthropic-leadership.ld.html --model opus

# Rebuild the index after manual changes
bash example/index.ld.html
```

## Cost

Each update costs roughly $0.50–$3.00 depending on the budget set in the contract and the model used. The budget is extracted from the contract automatically — no separate configuration needed.

## License

MIT
