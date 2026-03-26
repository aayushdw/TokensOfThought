---
title: "Agentic AI Systems — Part 2: Planning and Tool Use"
date: 2026-03-26 14:00:00 -0400
categories: [AI Systems, Agentic AI]
tags: [agents, tool-use, planning, function-calling]
math: true
toc: true
description: >-
  Part 2 of our series on Agentic AI systems. We dive into planning algorithms,
  tool use patterns, and error recovery strategies.
---

> This is **Part 2** of a multi-part series on Agentic AI Systems.
> - [Part 1: Foundations](/TokensOfThought/posts/agentic-systems-part-1/)
> - **Part 2: Planning and Tool Use** (you are here)
{: .prompt-info }

## Planning in Agentic Systems

A key capability that separates truly agentic systems from simple LLM wrappers is the ability to **plan** — to decompose a complex goal into a sequence of achievable steps.

### Task Decomposition

Given a high-level goal $G$, a planning agent decomposes it into subtasks:

$$
G \xrightarrow{\text{decompose}} [g_1, g_2, \ldots, g_k]
$$

where each $g_i$ is achievable through a small number of actions. The decomposition should satisfy:

$$
\bigcup_{i=1}^{k} \text{effects}(g_i) \supseteq \text{requirements}(G)
$$

In practice, LLM-based planners generate these decompositions through prompting:

```
Given the goal: "Set up a CI/CD pipeline for this Python project"

Plan:
1. Analyze the project structure and dependencies
2. Create a GitHub Actions workflow file
3. Configure test runners (pytest)
4. Add linting step (ruff/flake8)
5. Configure deployment to staging
6. Test the pipeline with a sample PR
```

### Tree-of-Thought Planning

For complex decisions, Tree-of-Thought (ToT) extends chain-of-thought by exploring multiple reasoning paths:

$$
V(s) = \max_{a \in \mathcal{A}ct} \left[ R(s, a) + \gamma \sum_{s'} P(s' | s, a) V(s') \right]
$$

This is analogous to Monte Carlo Tree Search (MCTS) in game-playing AI, where the agent:

1. **Generates** multiple candidate next steps
2. **Evaluates** each candidate using the LLM as a heuristic
3. **Selects** the most promising path
4. **Backtracks** if a path leads to a dead end

## Tool Use

Tools transform LLMs from knowledge retrievers into action-taking agents.

### The Function Calling Pattern

Modern LLM APIs support structured tool/function calling:

```json
{
  "name": "search_database",
  "description": "Search the product database",
  "parameters": {
    "type": "object",
    "properties": {
      "query": { "type": "string" },
      "limit": { "type": "integer", "default": 10 }
    },
    "required": ["query"]
  }
}
```

The LLM decides **when** to call a tool, **which** tool to use, and **what arguments** to pass — all based on the conversation context.

### Tool Selection as a Decision Problem

Given a set of $m$ tools $\mathcal{T} = \{t_1, \ldots, t_m\}$ and the current context $c$, the agent must select the optimal tool:

$$
t^* = \arg\max_{t \in \mathcal{T}} \, P(\text{success} \mid t, c) \cdot U(t, c)
$$

where $P(\text{success} \mid t, c)$ is the probability of the tool successfully completing the subtask, and $U(t, c)$ is the utility of the result.

### Common Tool Categories

| Category | Examples | Purpose |
|----------|----------|---------|
| **Information retrieval** | Web search, RAG, DB queries | Grounding in external knowledge |
| **Code execution** | Python REPL, shell commands | Computation and system interaction |
| **File operations** | Read, write, edit files | Persistent state management |
| **API integration** | HTTP requests, SDK calls | Connecting to external services |
| **Communication** | Email, Slack, GitHub | Interacting with humans and systems |

## Error Recovery

Real-world agents encounter failures. Robust error recovery is essential.

### Retry with Reflection

When an action fails, the agent can:

1. **Observe** the error message
2. **Reflect** on what went wrong
3. **Revise** the approach
4. **Retry** with a different strategy

```
Action: execute_sql("SELECT * FROM users WHERE id = '123'")
Error: relation "users" does not exist
Reflection: The table might be named differently. Let me check the schema.
Action: execute_sql("SELECT table_name FROM information_schema.tables")
Observation: Tables are: customers, orders, products
Action: execute_sql("SELECT * FROM customers WHERE id = '123'")
Result: {id: 123, name: "Alice", ...}
```

### Graceful Degradation

When a tool is unavailable or an approach fails repeatedly, the agent should degrade gracefully:

$$
\text{fallback}(a) = \begin{cases}
a_{\text{retry}} & \text{if attempts} < \text{max\_retries} \\
a_{\text{alternative}} & \text{if alternative tool exists} \\
a_{\text{ask\_user}} & \text{if human in the loop} \\
a_{\text{abort}} & \text{otherwise}
\end{cases}
$$

## Conclusion

Agentic systems represent a fundamental shift in how we build AI applications — from static input-output functions to dynamic, goal-directed systems that can plan, use tools, and recover from failures.

The field is evolving rapidly, and we'll continue to explore emerging patterns in future posts.

## References

1. Yao, S., et al. "Tree of Thoughts: Deliberate Problem Solving with Large Language Models." *NeurIPS*, 2023.
2. Schick, T., et al. "Toolformer: Language Models Can Teach Themselves to Use Tools." *NeurIPS*, 2023.
3. Shinn, N., et al. "Reflexion: Language Agents with Verbal Reinforcement Learning." *NeurIPS*, 2023.
