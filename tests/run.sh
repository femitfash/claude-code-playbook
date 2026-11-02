#!/usr/bin/env bash
# Deterministic checks for the playbook (no model needed). Run: tests/run.sh
set -uo pipefail
cd "$(dirname "$0")/.."
fail=0; pass=0
ok()   { pass=$((pass+1)); echo "  ok   $1"; }
bad()  { fail=$((fail+1)); echo "  FAIL $1"; }
check() { if eval "$2" >/dev/null 2>&1; then ok "$1"; else bad "$1"; fi; }

fm() { awk '/^---[[:space:]]*$/{c++; next} c==1{print} c==2{exit}' "$1"; }

echo "Skills"
for f in skills/*/SKILL.md; do
  d="$(basename "$(dirname "$f")")"
  front="$(fm "$f")"
  check "$d: name matches directory" "printf '%s' \"\$front\" | grep -qE '^name:[[:space:]]*$d[[:space:]]*\$'"
  check "$d: has description" "printf '%s' \"\$front\" | grep -qE '^description:[[:space:]]*.+'"
  check "$d: README lists /playbook:$d" "grep -q '/playbook:$d' README.md"
  # No pinned model versions in skills.
  check "$d: no hard-coded model names" "! grep -qiE '\\b(opus|sonnet|haiku)\\b|claude-[a-z]+-[0-9]' '$f'"
  # Interactive skills must not be forks (a fork runs as a background subagent).
  if printf '%s' "$front" | grep -q '^context:[[:space:]]*fork'; then
    check "$d: fork skill does not ask the user questions" "! grep -qiE 'AskUserQuestion|ask the user|one question at a time' '$f'"
  fi
done
check "debug: edit tools disabled" "fm skills/debug/SKILL.md | grep -E '^disallowed-tools:' | grep -q Edit && fm skills/debug/SKILL.md | grep -E '^disallowed-tools:' | grep -q Write"
for s in implementer phase-gate resume project-init; do
  check "$s: user-invoked only" "fm skills/$s/SKILL.md | grep -qE '^disable-model-invocation:[[:space:]]*true'"
done

echo "Manifests and templates"
check "plugin.json is valid JSON" "python3 -c 'import json;json.load(open(\".claude-plugin/plugin.json\"))'"
check "marketplace.json is valid JSON" "python3 -c 'import json;json.load(open(\".claude-plugin/marketplace.json\"))'"
check "hooks.json is valid JSON" "python3 -c 'import json;json.load(open(\"hooks/hooks.json\"))'"
check "settings baseline is valid JSON" "python3 -c 'import json;json.load(open(\"templates/settings.baseline.json\"))'"
for pat in '.env' 'rm -rf' 'rm -fr' 'git push --force' 'git push -f' 'push * +'; do
  check "baseline denies: $pat" "python3 -c 'import json,sys;d=json.load(open(\"templates/settings.baseline.json\"))[\"permissions\"][\"deny\"];sys.exit(0 if any(sys.argv[1] in x for x in d) else 1)' '$pat'"
done
check "no v1 skill references remain" "! grep -rqE '/playbook:(reviewer|security-auditor)|\`(reviewer|security-auditor)\` skill' skills README.md"

echo "Stop hook (hooks/verify-on-stop.sh)"
H="$PWD/hooks/verify-on-stop.sh"; T="$(mktemp -d)"; mkdir -p "$T/p/.claude"
export TMPDIR="$T"; export CLAUDE_PROJECT_DIR="$T/p"
run() { printf '{"session_id":"%s"}' "${1:-s1}" | "$H" >/dev/null 2>&1; echo $?; }
check "no verify.sh -> allow" "[ \"\$(run)\" = 0 ]"
printf '#!/bin/bash\necho boom; exit 1\n' > "$T/p/.claude/verify.sh"; chmod +x "$T/p/.claude/verify.sh"
check "failing verify blocks (1)" "[ \"\$(run)\" = 2 ]"
check "failing verify blocks (2)" "[ \"\$(run)\" = 2 ]"
check "failing verify blocks (3)" "[ \"\$(run)\" = 2 ]"
check "cap reached -> allow stop"  "[ \"\$(run)\" = 0 ]"
check "counter resets after cap"    "[ \"\$(run)\" = 2 ]"
check "sessions counted separately" "[ \"\$(run other)\" = 2 ]"
check "cap is configurable" "[ \"\$(PLAYBOOK_VERIFY_MAX_RETRIES=1 run cfg)\" = 2 ] && [ \"\$(PLAYBOOK_VERIFY_MAX_RETRIES=1 run cfg)\" = 0 ]"
printf '#!/bin/bash\nexit 0\n' > "$T/p/.claude/verify.sh"
check "passing verify allows" "[ \"\$(run)\" = 0 ]"
printf '#!/bin/bash\nexit 1\n' > "$T/p/.claude/verify.sh"
check "PLAYBOOK_VERIFY_DISABLE=1 skips" "[ \"\$(PLAYBOOK_VERIFY_DISABLE=1 run)\" = 0 ]"
check "missing session_id still works" "[ \"\$(printf '{}' | \"$H\" >/dev/null 2>&1; echo \$?)\" = 2 ]"
rm -rf "$T"

echo "Outcome checks (evals/check-outcomes.sh)"
check "outcome checker is executable" "[ -x evals/check-outcomes.sh ]"
check "hidden tests are not in any fixture" "! grep -rq 'hidden_test' evals/*/fixture.sh"
check "outcomes self-test: good passes, bad fails" "tests/outcomes-selftest.sh"

echo "Plugin validation"
if command -v claude >/dev/null 2>&1; then
  check "claude plugin validate --strict" "claude plugin validate --strict ."
else
  echo "  skip claude CLI not installed"
fi

echo; echo "passed=$pass failed=$fail"
[ "$fail" = 0 ]
