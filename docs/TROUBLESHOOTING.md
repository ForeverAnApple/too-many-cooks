# 🛠️ Troubleshooting Guide

Welcome to the troubleshooting guide for Too Many Cooks! This document is designed to help you quickly resolve common issues you might encounter while running or developing with the agent orchestration framework.

## 1. Common Issues and Solutions

### Issue: API Key Not Found or Invalid

**Symptom:** The application fails to initialize or an agent throws an authentication error (e.g., HTTP 401 Unauthorized).

**Solution:**
1.  **Check Environment Variables:** Ensure your API keys (e.g., `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`) are correctly set in your shell environment or your project's configuration file (e.g., `.env`).
2.  **Verify Key Validity:** Double-check that the key has not expired and has the necessary permissions for the models you are trying to use.
3.  **Configuration File:** If using a configuration file, ensure the file is being loaded correctly by the application at startup.

### Issue: Rate Limit Exceeded

**Symptom:** Agents suddenly stop responding or return errors indicating too many requests.

**Solution:**
1.  **Check Provider Dashboard:** Review your usage limits and current consumption on the respective LLM provider's dashboard (e.g., OpenAI, Anthropic).
2.  **Implement Backoff:** If you are running concurrent tasks, consider implementing an exponential backoff and retry mechanism in your agent logic to handle transient rate limit errors gracefully.
3.  **Increase Limits:** If the issue persists, you may need to request a rate limit increase from your LLM provider.

## 2. Debugging Agent Delegation Problems

Agent delegation is the core of Too Many Cooks. When a task fails, the issue often lies in how agents communicate or how the delegation chain is structured.

### Step 1: Review the Delegation Chain

1.  **Visualize the Flow:** Draw out the intended flow of the task. Which agent delegates to whom? What is the expected output at each step?
2.  **Check Agent Prompts:** A common failure point is a poorly defined prompt for the delegating agent. Ensure the prompt clearly instructs the agent on:
    *   **When** to delegate (the condition).
    *   **To whom** to delegate (the target agent/tool).
    *   **What** information to pass (the input).
    *   **What** to expect back (the required format).

### Step 2: Inspect Agent Logs

The most critical step is to inspect the detailed logs for the agents involved.

*   **Input/Output:** Look at the exact input the delegating agent sent and the exact output the receiving agent returned.
*   **Tool Calls:** If an agent is using a tool, check the logs for the tool's invocation and result. A failure in a tool call is often misinterpreted as a delegation failure.

### Step 3: Simplify and Isolate

If a complex delegation chain is failing, try to isolate the problem:
1.  **Test Agents in Isolation:** Run the individual agents with the exact inputs they would receive in the chain.
2.  **Reduce the Chain:** Temporarily remove intermediate agents to see if the core task (Agent A -> Agent B) works.

## 3. Model Availability Issues

### Model is Deprecated or Unavailable

**Symptom:** The application throws an error that a specified model name is unknown or retired.

**Solution:**
1.  **Update Configuration:** Check the official documentation of your LLM provider for the latest model names.
2.  **Change Model:** Update your `config.yaml` or relevant configuration files to use a currently supported model (e.g., migrating from `gpt-3.5-turbo-0613` to `gpt-3.5-turbo-0125`).

### Model Performance is Poor

**Symptom:** Agents are producing low-quality, irrelevant, or hallucinated outputs.

**Solution:**
1.  **Improve Prompts:** The quality of the output is directly tied to the quality of the prompt. Refine the system and user prompts to be more specific, provide better examples (few-shot learning), and clearly define constraints.
2.  **Increase Temperature:** For creative tasks, a higher temperature (e.g., 0.7-0.9) might be needed. For deterministic, logical tasks, a lower temperature (e.g., 0.0-0.2) is recommended.
3.  **Use a Better Model:** If all else fails, consider upgrading to a more capable model (e.g., from a 3.5 series to a 4 series model).

## 4. Configuration Errors

### YAML/JSON Syntax Errors

**Symptom:** The application fails to load configuration files at startup with a parsing error.

**Solution:**
1.  **Use a Linter:** Use an online YAML/JSON linter or a linter extension in your IDE to check for common issues like incorrect indentation, missing colons, or unclosed quotes.
2.  **Check Indentation:** YAML is sensitive to whitespace. Ensure you are using consistent spacing (usually 2 or 4 spaces) and not mixing tabs and spaces.

### Incorrect Environment Variables

**Symptom:** A setting that should be overridden by an environment variable is not taking effect.

**Solution:**
1.  **Check Variable Name:** Verify the exact name of the environment variable (case-sensitivity matters, e.g., `API_KEY` vs `api_key`).
2.  **Check Loading Order:** Ensure that the environment variable is loaded *before* the application attempts to read the configuration. If you are using a tool like `dotenv`, verify it's initialized early in the startup process.

## 5. Frequently Asked Questions (FAQ)

### Q: How do I add a new tool for my agents to use?

**A:** Tools are typically defined as functions or classes that the agent framework can introspect. You usually need to:
1.  Define the tool function/class with clear docstrings (for the LLM to understand its purpose and parameters).
2.  Register the tool with the agent framework's tool registry.
3.  Update the agent's system prompt to inform it about the new tool's existence and when to use it.

### Q: Can I run multiple agents concurrently?

**A:** Yes, Too Many Cooks is designed for concurrent operations. Ensure your underlying LLM client library is configured for asynchronous calls (e.g., using `asyncio` in Python) to prevent blocking while waiting for model responses.

### Q: Where are the agent logs stored?

**A:** By default, logs are often printed to `stdout` (your console). Check your main configuration file for a `logging` section. You can usually configure it to write logs to a file (e.g., `logs/app.log`) for easier debugging.