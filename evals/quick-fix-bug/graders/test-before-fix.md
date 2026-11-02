---
type: tool_order
before:
  tool: Edit
  input_match: 'test_cart'
after:
  tool: Edit
  input_match: '"file_path"\s*:\s*"[^"]*/cart\.py"'
---
The regression test is edited before the source file (test-first). Note: this only recognises `Edit`; a run that uses `Write` for the test will fail this grader, so treat a single failure as a signal to check the trace, not proof.
