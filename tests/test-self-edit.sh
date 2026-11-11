#!/usr/bin/env bash
# test-self-edit.sh — an update must survive the agent rewriting the file that
# bash is running.
#
# bash reads a script from disk as it goes. `bash doc.o-o.html` runs the agent,
# the agent rewrites doc.o-o.html, and when the agent returns bash reads its
# next command from its old byte offset in the NEW content. On 2026-11-11 that
# landed mid-function in ai-model-landscape.o-o.html and aborted --update-all.
#
# The stand-in `claude` inserts a command at that offset: the byte position of
# the first line after the command router. If bash reads the file after the
# agent returns, the command runs and leaves a marker. Costs $0.
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail() { echo "FAIL: $*"; exit 1; }

WORK="$(mktemp -d /tmp/oo-test.XXXXXX)"
trap 'rm -rf "$WORK"' EXIT

mkdir -p "$WORK/docs" "$WORK/bin"
perl -pe 's/("as_of"\s*:\s*")[^"]*(")/${1}2000-01-01${2}/' \
  "$REPO/example/openclaw.o-o.html" > "$WORK/docs/openclaw.o-o.html"

MARK="$WORK/stale-read"
cat > "$WORK/bin/claude" <<STUB
#!/usr/bin/env bash
cat > /dev/null
doc="\$(printf '%s\n' "\$*" | grep -o '/[^ ]*\.o-o\.html' | head -1)"
# Insert a command where the old file had the line after the router. Write in
# place, as the agent does: \`perl -i\` would swap in a new file, and bash keeps
# reading the old one, so the test would pass without exercising anything.
perl -0777 -pe 's{(\n)(# OO:SHELL:END\n)}{\$1touch "$MARK"\n\$2}' "\$doc" > "\$doc.new"
cat "\$doc.new" > "\$doc"
STUB
chmod +x "$WORK/bin/claude"

( cd "$WORK/docs" && PATH="$WORK/bin:$PATH" bash openclaw.o-o.html </dev/null ) \
  > "$WORK/run.log" 2>&1
rc=$?

grep -q "touch \"$MARK\"" "$WORK/docs/openclaw.o-o.html" \
  || fail "stand-in agent did not edit the doc; test is not exercising anything"
[[ ! -e "$MARK" ]] || fail "bash read the rewritten file after the agent returned"
[[ "$rc" -eq 0 ]] || fail "update exited $rc. log:
$(cat "$WORK/run.log")"

echo "PASS: bash did not read the file after the agent rewrote it"
