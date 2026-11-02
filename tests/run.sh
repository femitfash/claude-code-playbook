#!/usr/bin/env bash
# Deterministic checks for the playbook (no model needed). Run: tests/run.sh
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
fail=0; pass=0
ok()   { pass=$((pass+1)); echo "  ok   $1"; }
bad()  { fail=$((fail+1)); echo "  FAIL $1"; }
check() { if eval "$2" >/dev/null 2>&1; then ok "$1"; else bad "$1"; fi; }

fm() { awk '/^---[[:space:]]*$/{c++; next} c==1{print} c==2{exit}' "$1"; }

echo "Skills"
for f in skills/*/SKILL.md; do
  d="$(basename "$(dirname "$f")")"
  front="$(fm "$f")"
  check "$d: name matches directory" "printf '%s' \"\$front\" | grep -qE '^name:[[:space:]]*${d}[[:space:]]*\$'"
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
check "debug: read-only guard hook is wired and executable" "fm skills/debug/SKILL.md | grep -q 'readonly-guard.sh' && [ -x skills/debug/readonly-guard.sh ]"
check "phase-gate: reports which reviews actually ran" "grep -q 'Reviews run:' skills/phase-gate/SKILL.md && grep -q 'Never say a bundled review ran if it did not' skills/phase-gate/SKILL.md"
check "phase-gate: runs in a fresh forked context" "fm skills/phase-gate/SKILL.md | grep -qE '^context:[[:space:]]*fork'"
for s in implementer phase-gate resume project-init; do
  check "$s: user-invoked only" "fm skills/$s/SKILL.md | grep -qE '^disable-model-invocation:[[:space:]]*true'"
done

echo "Manifests and templates"
check "plugin.json is valid JSON" "python3 -c 'import json;json.load(open(\".claude-plugin/plugin.json\"))'"
check "marketplace.json is valid JSON" "python3 -c 'import json;json.load(open(\".claude-plugin/marketplace.json\"))'"
check "hooks.json is valid JSON" "python3 -c 'import json;json.load(open(\"hooks/hooks.json\"))'"
check "settings baseline is valid JSON" "python3 -c 'import json;json.load(open(\"templates/settings.baseline.json\"))'"
for pat in '.env' 'cat .env' 'rm -rf' 'rm -fr' 'rm -r -f' 'rm -f -r' 'rm --recursive' '-delete' 'git push --force' 'git push -f' 'push * +'; do
  check "baseline denies: $pat" "python3 -c 'import json,sys;d=json.load(open(\"templates/settings.baseline.json\"))[\"permissions\"][\"deny\"];sys.exit(0 if any(sys.argv[1] in x for x in d) else 1)' '$pat'"
done
check "baseline asks (not denies) on plain rm -r" "python3 -c 'import json,sys;d=json.load(open(\"templates/settings.baseline.json\"))[\"permissions\"];sys.exit(0 if any(\"rm -r *\" in x for x in d[\"ask\"]) and not any(x == \"Bash(rm -r *)\" for x in d[\"deny\"]) else 1)'"
check "sandbox template: enabled, no opt-out, valid JSON" "python3 -c 'import json,sys;d=json.load(open(\"templates/settings.sandbox.json\"))[\"sandbox\"];sys.exit(0 if d[\"enabled\"] is True and d[\"allowUnsandboxedCommands\"] is False else 1)'"
for v in templates/verify*.example; do
  check "$v: bash syntax and strict mode" "bash -n '$v' && head -n 1 '$v' | grep -q '^#!/usr/bin/env bash' && grep -q 'set -euo pipefail' '$v'"
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
# The hook section pointed these at $T, which is now gone; later sections must not inherit them.
unset TMPDIR CLAUDE_PROJECT_DIR

echo "Stop hook skips unchanged trees"
T2="$(mktemp -d)"; P="$T2/g"; mkdir -p "$P/.claude"
( cd "$P" && git init -q && git -c user.name=t -c user.email=t@example.com commit -q --allow-empty -m init )
vlog="$T2/verify.log"
printf '#!/bin/bash\necho run >> %s\nexit 0\n' "$vlog" > "$P/.claude/verify.sh"; chmod +x "$P/.claude/verify.sh"
runs() { wc -l < "$vlog" 2>/dev/null | tr -d ' '; }
hrun() { printf '{"session_id":"%s"}' "$1" | TMPDIR="$T2" CLAUDE_PROJECT_DIR="$P" "$H" >/dev/null 2>&1; echo $?; }
hrun s1 >/dev/null;  check "first stop runs verify"                        "[ \"\$(runs)\" = 1 ]"
hrun s1 >/dev/null;  check "unchanged tree skips verify"                   "[ \"\$(runs)\" = 1 ]"
echo a > "$P/new.txt"; hrun s1 >/dev/null
check "a new file triggers verify"                                         "[ \"\$(runs)\" = 2 ]"
hrun s1 >/dev/null;  check "unchanged again skips verify"                  "[ \"\$(runs)\" = 2 ]"
echo b >> "$P/new.txt"; hrun s1 >/dev/null
check "editing an untracked file's content triggers verify"                "[ \"\$(runs)\" = 3 ]"
( cd "$P" && git add -A && git -c user.name=t -c user.email=t@example.com commit -q -m c ); hrun s1 >/dev/null
check "a commit triggers verify"                                           "[ \"\$(runs)\" = 4 ]"
PLAYBOOK_VERIFY_ALWAYS=1 hrun s1 >/dev/null
check "PLAYBOOK_VERIFY_ALWAYS=1 runs on an unchanged tree"                 "[ \"\$(runs)\" = 5 ]"
printf '#!/bin/bash\necho boom\nexit 1\n' > "$P/.claude/verify.sh"; echo c >> "$P/new.txt"
check "failing verify blocks"                                              "[ \"\$(hrun f1)\" = 2 ]"
check "a failure is not skipped on the next stop (tree unchanged)"         "[ \"\$(hrun f1)\" = 2 ]"
rm -rf "$T2"

echo "Debug read-only guard (skills/debug/readonly-guard.sh)"
GUARD="$PWD/skills/debug/readonly-guard.sh"
gtool() { # gtool <allow|deny> <tool_name>
  local rc; printf '{"tool_name":"%s","tool_input":{"file_path":"x"}}' "$2" | "$GUARD" >/dev/null 2>&1; rc=$?
  if { [[ $1 == allow && $rc -eq 0 ]] || [[ $1 == deny && $rc -eq 2 ]]; }; then ok "guard $1: tool $2"; else bad "guard $1: tool $2 (exit $rc)"; fi
}
gcase() { # gcase <allow|deny> <JSON-escaped bash command>
  local rc; printf '{"tool_name":"Bash","tool_input":{"command":"%s","description":"x"}}' "$2" | "$GUARD" >/dev/null 2>&1; rc=$?
  if { [[ $1 == allow && $rc -eq 0 ]] || [[ $1 == deny && $rc -eq 2 ]]; }; then ok "guard $1: $2"; else bad "guard $1: $2 (exit $rc)"; fi
}
for t in Edit Write NotebookEdit MultiEdit; do gtool deny "$t"; done
for t in Read Grep Glob; do gtool allow "$t"; done
for c in 'python3 -m unittest' 'python3 -m unittest 2>&1 | tail -14' 'git log --oneline -5' 'git diff --stat' \
         'git status --short | wc -l' 'git branch' 'grep -rn reserve .' 'cat -n inventory.py' 'ls -la' 'pytest -q 2>/dev/null' \
         'python3 -c \"print(2 > 1)\"' "python3 -c \\\"from inventory import reserve; s={'ABC': 3}; print(reserve(s, 'ABC', 3), s)\\\""; do
  gcase allow "$c"
done
for c in 'echo x > f.py' 'echo x >> f.py' 'cat a | tee b' 'sed -i s/a/b/ f.py' 'sed -i.bak s/a/b/ f.py' 'perl -pi -e s/a/b/ f' \
         'rm f' 'rm -rf build' 'mv a b' 'cp a b' 'touch f' 'mkdir d' 'dd if=a of=b' 'git checkout -- .' 'git commit -am x' 'git stash' \
         'git reset --hard' 'git -C . add .' 'git branch -D x' 'pip install requests' 'npm install' 'find . -name x -delete' \
         'curl -o out http://x' 'python3 -m unittest > out.txt'; do
  gcase deny "$c"
done
printf '{"tool_name":"Bash","tool_input":{}}' | "$GUARD" >/dev/null 2>&1
check "guard fails closed when the command cannot be read" "[ $? -eq 2 ]"

echo "Outcome checks (evals/check-outcomes.sh)"
check "outcome checker is executable" "[ -x evals/check-outcomes.sh ]"
check "hidden tests are not in any fixture" "! grep -rq 'hidden_test' evals/*/fixture.sh"
if st_out="$(tests/outcomes-selftest.sh 2>&1)"; then
  ok "outcomes self-test: good passes, bad fails"
else
  bad "outcomes self-test: good passes, bad fails"
  printf '%s\n' "$st_out" | sed 's/^/       /'
fi

echo "Eval coverage (every skill has an in-sample and a held-out case)"
for f in skills/*/SKILL.md; do
  s="$(basename "$(dirname "$f")")"
  check "$s: has an in-sample eval case" "grep -lE '^tags:.*[[ ,]${s}[],]' evals/*/prompt.md | grep -q ."
  check "$s: has a held-out eval case"   "grep -lE '^tags:.*[[ ,]${s}[],]' evals/holdout/*/prompt.md | grep -q ."
done
check "held-out case names start with holdout-" "! grep -L '^name: holdout-' evals/holdout/*/case.yaml | grep -q ."
check "held-out cases are tagged holdout"       "! grep -L '^tags:.*holdout' evals/holdout/*/prompt.md | grep -q ."
check "every eval case has a skill-fired indicator" "! ls -d evals/*/graders evals/holdout/*/graders | while read -r g; do [ -f \"\$g/skill-fired.md\" ] || echo \"\$g\"; done | grep -q ."

echo "Held-out set is frozen (evals/holdout/FROZEN.sha256)"
check "held-out files match the frozen manifest" "(cd evals/holdout && find . -type f ! -name FROZEN.sha256 ! -name README.md | LC_ALL=C sort | xargs sha256sum | diff -u FROZEN.sha256 -)"

echo "Eval runner (evals/run-suite.sh, dry runs only)"
check "runner refuses to run without a budget"   "! evals/run-suite.sh --set holdout --dry-run"
check "runner rejects a non-numeric budget"      "! evals/run-suite.sh --set holdout --budget abc --dry-run"
check "runner rejects an unknown set"            "! evals/run-suite.sh --set nope --budget 5 --dry-run"
# These are read inside the eval strings below, which ShellCheck cannot see.
# shellcheck disable=SC2034
hold_out="$(evals/run-suite.sh --set holdout --budget 9 --runs 2 --dry-run 2>&1)"
# shellcheck disable=SC2034
insm_out="$(evals/run-suite.sh --set insample --budget 10 --dry-run 2>&1)"
# shellcheck disable=SC2034
two_out="$(evals/run-suite.sh --set holdout --budget 18 --models "sonnet opus" --dry-run 2>&1)"
n_hold="$(find evals/holdout -mindepth 1 -maxdepth 1 -type d -name 'holdout-*' | wc -l | tr -d ' ')"
check "holdout set: one invocation per held-out case" "[ \"\$(printf '%s\n' \"\$hold_out\" | grep -c 'holdout-')\" = \"$n_hold\" ]"
check "in-sample set never includes a held-out case" "! printf '%s\n' \"\$insm_out\" | grep -q 'holdout-'"
check "every invocation is capped"                   "! printf '%s\n%s\n' \"\$hold_out\" \"\$insm_out\" | grep -v -- '--max-cost-usd' | grep -q ."
check "every invocation stays local (--no-publish)"  "! printf '%s\n%s\n' \"\$hold_out\" \"\$insm_out\" | grep -v -- '--no-publish' | grep -q ."
check "budget is split evenly (9 over 9 cases)"      "printf '%s\n' \"\$hold_out\" | grep -q -- '--max-cost-usd 1.00'"
check "two models double the invocations"            "[ \"\$(printf '%s\n' \"\$two_out\" | wc -l | tr -d ' ')\" = \"$(( 2 * n_hold ))\" ]"
check "manual workflow: dispatch only, budget required" "grep -q 'workflow_dispatch' .github/workflows/evals.yml && ! grep -qE '^[[:space:]]*(pull_request|push|schedule):' .github/workflows/evals.yml && grep -A3 'budget:' .github/workflows/evals.yml | grep -q 'required: true'"

echo "AI log and time-box docs"
check "AI-LOG template has the notes block and the pushback structure" "grep -q 'Asked:' templates/AI-LOG.md && grep -q 'Kept:' templates/AI-LOG.md && grep -q 'The pushback moment' templates/AI-LOG.md && grep -q 'Only real interactions' templates/AI-LOG.md"
check "AI-LOG example is labelled illustrative" "grep -qi 'made-up project' templates/AI-LOG.md"
check "TIMEBOXED plan covers spec, verify, build and the skip list" "grep -q 'Write the spec file first' docs/TIMEBOXED.md && grep -q 'verify.sh' docs/TIMEBOXED.md && grep -q 'Skip these in a time box' docs/TIMEBOXED.md"
check "README links both docs" "grep -q 'docs/TIMEBOXED.md' README.md && grep -q 'templates/AI-LOG.md' README.md"

echo "Plugin validation"
if command -v claude >/dev/null 2>&1; then
  check "claude plugin validate --strict" "claude plugin validate --strict ."
else
  echo "  skip claude CLI not installed"
fi

echo; echo "passed=$pass failed=$fail"
[ "$fail" = 0 ]
