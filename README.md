# ai-sec-tests

Automated AI red teaming against `ai-sec-lab` with promptfoo, garak and PyRIT.
Goal: reproducible results and success rates, runnable with one command.

- promptfoo: `promptfoo redteam run` (config: `promptfooconfig.yaml`)
- garak: `garak --model_type ollama --model_name qwen3:8b --probes promptinject`
- PyRIT: `uv run python pyrit_scripts/<script>.py`
