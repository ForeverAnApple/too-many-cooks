# Too Many Cooks - Delegator Pattern for OpenCode

> **Goal**: Orchestrator-only primary agent that delegates all work to specialized subagents
> **Status**: Implemented
> **Updated**: 2025-12-26

---

## Architecture

```
┌────────────────────────────────────────────────────────┐
│                   USER MESSAGE                          │
└─────────────────────────┬──────────────────────────────┘
                          ▼
┌────────────────────────────────────────────────────────┐
│           ORCHESTRATOR (claude-opus-4-5)                │
│                                                         │
│  - Plans and breaks down tasks                          │
│  - Reads files for context (read-only)                  │
│  - Delegates ALL implementation to subagents            │
│  - Coordinates results                                  │
│  - NEVER writes code directly                           │
└─────────────────────────┬──────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        ▼                 ▼                 ▼
   ┌─────────┐      ┌──────────┐      ┌──────────┐
   │  coder  │      │ frontend │      │ explorer │
   │ glm-4.7 │      │ gemini-3 │      │grok-code │
   └─────────┘      └──────────┘      └──────────┘
                          │
                          ▼
                    ┌──────────┐
                    │  writer  │
                    │gemini-3  │
                    └──────────┘
```

---

## Agents

### Primary Agent

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| **orchestrator** | `anthropic/claude-opus-4-5` | read, glob, grep, task, todoread, todowrite | Plan, delegate, coordinate |

The orchestrator:
- Has **read-only** access to the codebase
- Uses **TodoWrite** to track task breakdown
- Invokes subagents via **@mention** or auto-delegation
- Cannot write/edit files or run bash commands

### Subagents

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| **coder** | `zai-coding-plan/glm-4.7` | read, glob, grep, write, edit, bash | Backend code, algorithms, APIs |
| **frontend** | `google/gemini-3-pro-high` | read, glob, grep, write, edit, bash | React, CSS, UI components |
| **explorer** | `opencode/grok-code` | read, glob, grep | Fast codebase search |
| **writer** | `google/gemini-3-flash` | read, glob, grep, write, edit | Documentation, README |

All subagents have `task: false` to prevent recursive delegation.

---

## File Structure

```
.opencode/
├── agent/
│   ├── orchestrator.md   # Primary - plans & delegates
│   ├── coder.md          # Backend implementation
│   ├── frontend.md       # UI implementation
│   ├── explorer.md       # Codebase search
│   └── writer.md         # Documentation
└── plugin/               # (future plugins)

opencode.json             # Disables default build/plan agents
```

---

## How It Works

1. **User sends request** → Orchestrator receives it
2. **Orchestrator analyzes** → Reads relevant files, understands context
3. **Orchestrator plans** → Creates todo list with subtasks
4. **Orchestrator delegates** → `@coder implement X in file Y`
5. **Subagent executes** → Writes code, runs tests
6. **Results return** → Orchestrator reviews, delegates next task
7. **Loop continues** → Until all tasks complete

---

## Usage

### Automatic Delegation
The orchestrator will automatically invoke subagents based on the task:
- Code changes → `@coder`
- UI work → `@frontend`
- Finding files → `@explorer`
- Documentation → `@writer`

### Manual Delegation
You can also invoke subagents directly:
```
@explorer find all API endpoint definitions
@coder refactor the auth module to use JWT
@frontend add a dark mode toggle to settings
```

### Switching Agents
- **Tab** cycles through primary agents (only orchestrator in this setup)
- **Leader+Right/Left** navigates parent ↔ child sessions

---

## Configuration

### opencode.json
```json
{
  "$schema": "https://opencode.ai/config.json",
  "agent": {
    "build": { "disable": true },
    "plan": { "disable": true }
  }
}
```

This disables OpenCode's default agents, leaving only our custom ones.

### Adding New Agents
Create a new markdown file in `.opencode/agent/`:

```markdown
---
description: What this agent does
mode: subagent
model: provider/model-id
tools:
  read: true
  write: false
---

# System prompt goes here
```

---

## Cost Optimization

The pattern optimizes costs by using:
- **Expensive model** (Opus) only for planning/coordination
- **Cheaper models** for actual implementation work
- **Fast models** (Grok) for search/exploration

Typical task flow:
1. Opus plans (small context, few tokens)
2. GLM-4.7 writes code (larger output, cheaper model)
3. Opus reviews (small context)

---

## Future Enhancements

- [ ] Add `reviewer` agent for code review (gpt-4o or similar)
- [ ] Add `architect` agent for design decisions
- [ ] Add `tester` agent for test generation
- [ ] Plugin for cost tracking across agents
- [ ] Plugin for session summarization

---

## Notes

- OpenCode natively supports this pattern via `.opencode/agent/` markdown files
- No custom plugins required for basic delegation
- Subagent results appear in child sessions (navigate with Leader+arrows)
- The orchestrator's system prompt explicitly forbids direct code changes
