#!/usr/bin/env bash
# Run the eval suite with a mandatory total cost cap. Each case is run with and without the plugin
# (the CLI's with-without ablation), once per model.
#
# Usage: evals/run-suite.sh --set insample|holdout|all --budget USD [--runs N] [--models "m1 m2"] [--out DIR] [--dry-run]
#   --set      insample: every case outside evals/holdout; holdout: evals/holdout cases; all: both.
#              Tune only against insample results. Report holdout results separately.
#   --budget   REQUIRED total cost cap in USD. It is split evenly across the invocations (one per
#              case per model) and passed to each as --max-cost-usd. There is no default on purpose.
#   --runs     runs per case per arm (default 3; the v3.0 plan calls for at least 10).
#   --models   space-separated model aliases or ids; empty means the CLI default.
#   --out      results directory (default evals/results/<UTC timestamp>, which is gitignored).
#   --dry-run  print the commands instead of running them (no cost).
#
# Each invocation keeps its scaffold directories (--keep-temp) so that evals/check-outcomes.sh can be run on them.
# Needs, on Linux, bubblewrap and socat for the Bash sandbox (apt install bubblewrap socat).
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

usage() {
  echo 'usage: evals/run-suite.sh --set insample|holdout|all --budget USD [--runs N] [--models "m1 m2"] [--out DIR] [--dry-run]' >&2
  exit 2
}

set_name=""; runs=3; models=""; budget=""; out=""; dry=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --set) set_name="${2:-}"; shift 2 ;;
    --runs) runs="${2:-}"; shift 2 ;;
    --models) models="${2:-}"; shift 2 ;;
    --budget) budget="${2:-}"; shift 2 ;;
    --out) out="${2:-}"; shift 2 ;;
    --dry-run) dry=1; shift ;;
    *) usage ;;
  esac
done

if [[ -z "$budget" ]]; then
  echo "refusing to run: --budget (total USD cap) is required" >&2; exit 2
fi
[[ "$budget" =~ ^[0-9]+([.][0-9]+)?$ ]] || { echo "--budget must be a number" >&2; usage; }
[[ "$runs" =~ ^[0-9]+$ ]] && (( runs >= 1 )) || { echo "--runs must be a positive integer" >&2; usage; }
case "$set_name" in insample|holdout|all) ;; *) usage ;; esac

names=()
if [[ "$set_name" == insample || "$set_name" == all ]]; then
  for d in evals/*/; do
    n="${d%/}"; n="${n##*/}"
    case "$n" in holdout|outcomes|results) continue ;; esac
    [[ -f "$d/prompt.md" ]] && names+=("$n")
  done
fi
if [[ "$set_name" == holdout || "$set_name" == all ]]; then
  for d in evals/holdout/*/; do
    n="${d%/}"; n="${n##*/}"
    case "$n" in outcomes) continue ;; esac
    [[ -f "$d/prompt.md" ]] && names+=("$n")
  done
fi
(( ${#names[@]} > 0 )) || { echo "no eval cases found" >&2; exit 2; }

# Intentional word splitting of the model list.
# shellcheck disable=SC2206
model_list=($models)
(( ${#model_list[@]} > 0 )) || model_list=("")
total=$(( ${#names[@]} * ${#model_list[@]} ))
per="$(awk -v b="$budget" -v n="$total" 'BEGIN { printf "%.2f", b / n }')"
if awk -v p="$per" 'BEGIN { exit !(p < 0.01) }'; then
  echo "budget $budget across $total invocations is under \$0.01 each; raise the budget or narrow the set" >&2; exit 2
fi
[[ -n "$out" ]] || out="evals/results/$(date -u +%Y%m%dT%H%M%SZ)"

if (( ! dry )); then
  command -v claude >/dev/null 2>&1 || { echo "claude CLI not found" >&2; exit 2; }
  if [[ "$(uname -s)" == Linux ]]; then
    command -v bwrap >/dev/null 2>&1 && command -v socat >/dev/null 2>&1 \
      || echo "warning: bubblewrap or socat missing; Bash-enabled runs will be refused (apt install bubblewrap socat)" >&2
  fi
  mkdir -p "$out"
fi

failed=0
for m in "${model_list[@]}"; do
  label="${m:-default}"
  for n in "${names[@]}"; do
    cmd=(claude plugin eval . --case "$n" --runs "$runs" --scaffold --keep-temp --no-publish --trust-plugin
         --allow-tools Bash Edit Write --max-cost-usd "$per"
         --json "$out/$label-$n.json" --output-dir "$out/$label-$n")
    [[ -n "$m" ]] && cmd+=(--model "$m")
    if (( dry )); then
      printf '%q ' "${cmd[@]}"; echo
    else
      echo "== $label / $n (cap \$$per)"
      "${cmd[@]}" || { echo "   invocation failed (exit $?)" >&2; failed=$((failed+1)); }
    fi
  done
done
(( dry )) && exit 0
echo "done: $total invocations, $failed failed. Results in $out"
[[ $failed -eq 0 ]]
