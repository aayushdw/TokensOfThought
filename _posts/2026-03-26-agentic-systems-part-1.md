---
title: "Agentic AI Systems — Part 1: Foundations"
date: 2026-03-26 12:00:00 -0400
categories: [AI Systems, Agentic AI]
tags: [agents, tool-use, reasoning, planning]
math: true
toc: true
description: >-
  Part 1 of our series on Agentic AI systems. We cover the foundational concepts —
  what makes a system "agentic," the observe-think-act loop, and key architectural patterns.
---

> This is **Part 1** of a multi-part series on Agentic AI Systems.
> - **Part 1: Foundations** (you are here)
> - [Part 2: Planning and Tool Use](/TokensOfThought/posts/agentic-systems-part-2/)
{: .prompt-info }

## What Makes a System "Agentic"?

The term "agentic" has become central to modern AI discourse, but what does it actually mean? An **agentic system** is one that can autonomously perceive its environment, reason about goals, and take actions to achieve them — going beyond simple prompt-in, response-out interaction.

More formally, we can define an agent as a tuple:

$$
\mathcal{A} = (\mathcal{S}, \mathcal{O}, \mathcal{A}ct, \pi, \mathcal{T}, \mathcal{R})
$$

where:
- $\mathcal{S}$ is the state space
- $\mathcal{O}: \mathcal{S} \rightarrow \Omega$ is the observation function
- $\mathcal{A}ct$ is the set of available actions (including tool calls)
- $\pi: \Omega^* \rightarrow \mathcal{A}ct$ is the policy (the LLM + prompting strategy)
- $\mathcal{T}: \mathcal{S} \times \mathcal{A}ct \rightarrow \mathcal{S}$ is the transition function
- $\mathcal{R}: \mathcal{S} \times \mathcal{A}ct \rightarrow \mathbb{R}$ is the reward signal

## The Observe-Think-Act Loop

At the heart of every agentic system is a loop:

```
while not done:
    observation = observe(environment)
    thought = reason(observation, memory, goal)
    action = decide(thought)
    result = execute(action)
    memory.update(observation, action, result)
```

This is a modernized version of the classical **sense-plan-act** paradigm from robotics, adapted for LLM-based agents where:

1. **Observe**: Gather information from the environment (user input, tool outputs, file contents, API responses)
2. **Think**: Use the LLM to reason about the current state and what to do next
3. **Act**: Execute a concrete action — call a tool, write code, send a message

## Levels of Agency

Not all AI systems are equally agentic. We can think of a spectrum:

| Level | Description | Example |
|-------|-------------|---------|
| **L0** | Fixed response | Template-based chatbot |
| **L1** | Single LLM call | Basic Q&A with GPT/Claude |
| **L2** | Chain of calls | RAG pipeline |
| **L3** | Dynamic routing | Router that picks tools based on input |
| **L4** | Autonomous loop | Agent that plans, executes, and iterates |
| **L5** | Multi-agent | Multiple agents collaborating on a task |

Most production systems today operate at L2-L3, with L4-L5 being an active area of research.

## Key Architectural Patterns

### The ReAct Pattern

ReAct (Reasoning + Acting) interleaves chain-of-thought reasoning with action execution:

```
Thought: I need to find the current stock price of AAPL.
Action: search("AAPL stock price")
Observation: AAPL is trading at $187.42
Thought: Now I can answer the user's question.
Action: respond("Apple (AAPL) is currently trading at $187.42")
```

This pattern grounds the model's reasoning in real-world observations, reducing hallucination.

### Memory Systems

Agentic systems typically maintain multiple types of memory:

- **Working memory**: The current conversation context (context window)
- **Short-term memory**: Scratchpad for the current task (often maintained as structured state)
- **Long-term memory**: Persistent knowledge across sessions (vector stores, databases)

The challenge is that LLM context windows, while growing (from 4K to 200K+ tokens), are still finite. Effective memory management is crucial for agents that need to work on complex, long-running tasks.

## What's Next

In [Part 2](/TokensOfThought/posts/agentic-systems-part-2/), we'll explore:
- **Planning algorithms** for agents (tree search, decomposition)
- **Tool use** — how agents interact with external systems
- **Error recovery** — what happens when actions fail

## References

1. Yao, S., et al. "ReAct: Synergizing Reasoning and Acting in Language Models." *ICLR*, 2023.
2. Sumers, T., et al. "Cognitive Architectures for Language Agents." *arXiv*, 2023.
