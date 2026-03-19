# Too Many Cooks

A delegator pattern for OpenCode. One orchestrator plans and delegates; specialized subagents execute. Think head chef directing line cooks.

## Why?

Small contexts minimize hallucinations and ensure focus. Delegation leverages task-specific models, optimizes token costs, and enables parallel execution.

## Agents

NOTE: These models are subject to change, feel free to pick what works for you.

| Agent | Model | Role |
| :--- | :--- | :--- |
| **@orchestrator** | `claude-opus-4-6` | Plans, coordinates, delegates |
| **@coder** | `claude-opus-4-6` | Backend logic, algorithms, APIs |
| **@frontend** | `claude-opus-4-6` | UI components, styling |
| **@tester** | `claude-opus-4-6` | E2E testing, full-flow verification |
| **@reviewer** | `gpt-5.3-codex` | Code review, security, best practices |
| **@explorer** | `gpt-5.3-codex` | Codebase search, context gathering |
| **@research** | `claude-sonnet-4-5` | Web research, external docs |
| **@writer** | `claude-opus-4-6` | Documentation |

## How It Works

1. **Plan**: Orchestrator breaks the task into subtasks
2. **Delegate**: Tasks go to specialists via the `task` tool
3. **Execute**: Subagents do the work
4. **Deliver**: Orchestrator reviews and presents results

## Project Structure

```
agent/          # Agent prompt specs (one .md per agent)
skills/         # Skill workflows (one directory per skill)
docs/           # Architecture diagrams and troubleshooting
install.sh      # Installer script
opencode.json   # OpenCode config (disables built-in agents)
```

## Installation

**Prerequisites**: [jq](https://jqlang.github.io/jq/) (optional, for safe JSON merge with existing config)

```bash
git clone https://github.com/your-username/too-many-cooks.git
cd too-many-cooks
./install.sh
```

The installer:
- Backs up any existing config to a timestamped directory
- Copies agent specs from `agent/` to `~/.config/opencode/agent/`
- Installs skills from `skills/` to `~/.config/opencode/skills/`
- Merges (or creates) `~/.config/opencode/opencode.json`

## Usage

The orchestrator delegates automatically. You can also call agents directly:

```
@coder Implement JWT validation middleware
@frontend Create a responsive Navbar with Tailwind
@tester Verify the login flow works end-to-end
@reviewer Review src/auth/ for security issues
@explorer Find all usages of useAuth hook
@research Find Stripe API docs for payment intents
@writer Document the API endpoints
```

## Customization

Edit files in `agent/`:
- **Model**: Change the `model` field in frontmatter
- **Tools**: Toggle tool access in the `tools` section
- **New agents**: Add a `.md` file and update orchestrator instructions

## Skills

Skills are specialized workflows agents can invoke. Installed to `~/.config/opencode/skills/`.

| Skill | Description |
| :--- | :--- |
| `read-arxiv-paper` | Downloads arXiv TeX source and produces a local summary |

Add custom skills by creating `skills/<name>/SKILL.md`.

## License

MIT
