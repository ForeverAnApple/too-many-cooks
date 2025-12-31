# 🧑‍🍳 Too Many Cooks 🧑‍🍳

## The Delegator Pattern for OpenCode

"Too Many Cooks" transforms OpenCode into a high-efficiency kitchen. Instead of one expensive agent doing everything, it uses a **delegator pattern**: a top-tier **Orchestrator** plans the work and delegates execution to a team of specialized, cost-optimized **Subagents**.

---

## 🧑‍🍳 The Kitchen Staff

| Agent | Model | Role | Cost |
| :--- | :--- | :--- | :--- |
| **@orchestrator** | `claude-opus-4-5` | **Head Chef**: Plans, coordinates, and delegates. | 🔴 High |
| **@coder** | `zai-coding-plan/glm-4.7` | **Line Cook**: Backend logic and complex algorithms. | 🟡 Med |
| **@frontend** | `gemini-3-pro-high` | **Pastry Chef**: UI components and styling. | 🟡 Med |
| **@reviewer** | `gpt-4o` | **Sous Chef**: Code quality, security, and best practices. | 🟡 Med |
| **@explorer** | `opencode/grok-code` | **Food Runner**: Codebase search and context gathering. | 🟢 Low |
| **@research** | `zai-coding-plan/glm-4.7` | **Forager**: Web research, external docs, and API references. | 🟢 Low |
| **@writer** | `gemini-flash-latest` | **Menu Writer**: Documentation and READMEs. | 🟢 Low |

---

## 🧠 How It Works

The Orchestrator **never** writes code directly. It analyzes your request, creates a plan, and uses the `task` tool to hire specialists.

1.  **Plan**: `@orchestrator` breaks the task into subtasks.
2.  **Delegate**: Tasks are sent to specialists (e.g., `@coder` for logic, `@reviewer` for quality).
3.  **Execute**: Subagents use their specific tools (`write`, `edit`, `bash`) to finish the job.
4.  **Deliver**: `@orchestrator` reviews the work and presents the final result.

---

## ✨ Why It's Better

*   **Cost Efficiency**: Use expensive models (Opus) only for reasoning. Use cheaper models (Flash/Grok) for high-volume tasks like searching or documenting.
*   **Higher Quality**: Each agent is a specialist. `@frontend` knows React; `@reviewer` knows security; `@coder` knows performance.
*   **Reliability**: Clear separation of concerns prevents "context drift" and keeps the primary agent focused on the big picture.

---

## ⚙️ Installation

1.  **Clone** this repository.
2.  **Run** the installation script:
    ```bash
    ./install.sh
    ```
    *This copies configurations from `agent/` to `~/.config/opencode/agent/` and merges `opencode.json`.*

---

## 🚀 Usage Examples

The Orchestrator handles delegation automatically, but you can also call specialists directly:

*   **Logic**: `@coder Implement a JWT validation middleware in Express.`
*   **UI**: `@frontend Create a responsive Navbar component with Tailwind.`
*   **Review**: `@reviewer Review the changes in src/auth/ for security risks.`
*   **Search**: `@explorer Find all usages of the 'useAuth' hook.`
*   **Research**: `@research Find the Stripe API docs for creating payment intents.`
*   **Docs**: `@writer Document the new API endpoints in API.md.`

---

## 🛠️ Customization

Modify agent behavior by editing files in the `agent/` directory:
*   **Change Model**: Update the `model` field in the frontmatter.
*   **Adjust Tools**: Toggle tool access (e.g., `bash: false`) in the `tools` section.
*   **Add Agents**: Create a new `.md` file in `agent/` and update `@orchestrator`'s instructions.

---

## 📜 License

This project is licensed under the MIT License.

