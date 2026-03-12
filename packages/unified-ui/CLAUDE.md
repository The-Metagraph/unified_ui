# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is the **unified-ui** configuration repository for a multi-agent Claude Code orchestration system. It contains agent definitions, commands, hooks, and workflow documentation for managing development of Elixir-based user interface applications across multiple platforms.

### The Project Vision

Creating a unified, declarative UI DSL powered by the Spark library that allows developers to:

- Define UIs once using a common declarative syntax
- Target terminal, desktop, and web platforms from a single codebase
- Leverage the Jido ecosystem for agent-based component communication
- Build on proven patterns from The Elm Architecture (init/update/view)

### Target Frameworks

| Framework | Status | Platform | Description |
|-----------|--------|----------|-------------|
| **TermUi** | Mature | Terminal | 20+ widgets, 60 FPS rendering, double-buffered differential updates |
| **DesktopUi** | Early Stage | Desktop | Multi-platform desktop UI (implementation TBD) |
| **WebUi** | Conceptual | Web | Phoenix + Elm SPA architecture |

### Key Technologies

- **Spark** - DSL building framework (entities, sections, transformers, verifiers)
- **Jido.Agent.Server** - Component lifecycle and state management
- **JidoSignal** - Signal-based inter-component communication
- **Elm Architecture** - Predictable state management pattern

The actual Elixir projects are managed through this configuration system but live elsewhere:
- [term_ui](https://github.com/pcharbon70/term_ui)
- [desktop_ui](https://github.com/pcharbon70/desktop_ui)
- [jido_signal](https://github.com/agentjido/jido_signal)

## Architecture

### Multi-Agent Orchestration System

This repository implements a specialized agent system where the Implementation Lead (you) coordinates multiple expert agents:

- **Expert Agents (Opus model)**: elixir-expert, research-agent, architecture-agent - for complex analysis and domain knowledge
- **Planning Agents (Sonnet model)**: feature-planner, fix-planner, task-planner - for creating structured plans
- **Implementation Agents (Sonnet model)**: implementation-agent, test-developer, test-fixer - for execution
- **Review Agents (Sonnet model)**: qa-reviewer, security-reviewer, consistency-reviewer, factual-reviewer, redundancy-reviewer, senior-engineer-reviewer, elixir-reviewer, documentation-reviewer
- **Domain Experts**: neovim-expert, lua-expert, logseq-expert, chezmoi-expert

### Directory Structure

```
.claude/
├── agent-definitions/    # 24 specialized agent definitions with YAML frontmatter
├── commands/             # 24 workflow commands (feature, fix, task, research, plan, etc.)
├── hooks/                # Shell scripts for automatic formatting after edits
├── AGENTS.md             # Complete agent orchestration documentation
├── AGENT-SYSTEM-GUIDE.md # Model specifications and tool permissions
└── HOOKS-GUIDE.md        # Hook system documentation

notes/
└── research/             # Research and planning documents
    └── 1.01-domain-specific-language/
        └── 1.01.1-spark-dsl.md  # Comprehensive research on Spark-powered DSL
```

## Key Commands (via Skill tool)

### Four-Phase Workflow (for complex features)
- `/research` - Codebase impact analysis and third-party integration detection
- `/plan` - Strategic implementation planning
- `/breakdown` - Task decomposition into numbered checklists
- `/execute` - Sequential implementation execution

### Traditional Planning Commands
- `/feature` - Comprehensive feature planning (uses feature-planner)
- `/fix` - Focused fix planning (uses fix-planner)
- `/task` - Lightweight task planning (uses task-planner)

### Testing Commands
- `/add-tests` - Systematic test development (uses test-developer)
- `/fix-tests` - Test failure resolution (uses test-fixer)

### Workflow Commands
- `/review` - Runs ALL review agents in parallel
- `/commit` - Analyzes changes for commit
- `/pr` - Creates GitHub pull request
- `/implement` - Direct implementation
- `/cleanup` - Elixir project cleanup

### Documentation Commands
- `/document` - Create documentation
- `/update-docs` - Update existing documentation
- `/update-plan` - Update planning documents

## Critical Workflow Rules

### 1. Agent Consultation is Mandatory
- **Elixir work**: ALWAYS consult elixir-expert first
- **Architecture decisions**: ALWAYS consult architecture-agent
- **Research needs**: ALWAYS consult research-agent
- **Documentation**: ALWAYS consult documentation-expert

### 2. Parallel Review is Required
After ANY implementation, run ALL review agents in parallel:
```
├── qa-reviewer → Test coverage
├── security-reviewer → Security assessment
├── consistency-reviewer → Pattern compliance
├── factual-reviewer → Implementation verification
├── redundancy-reviewer → Duplication detection
├── elixir-reviewer → Elixir code quality (for Elixir changes)
├── documentation-reviewer → Documentation quality
└── senior-engineer-reviewer → Strategic review
```

### 3. Four-Phase Workflow for Complex Topics
Use `/research` → `/plan` → `/breakdown` → `/execute` for:
- Complex features requiring multi-dimensional research
- Large features needing strategic planning
- Unfamiliar technology integration
- Projects benefiting from systematic breakdown

## Hooks

The `format-code.sh` hook automatically runs `mix format` after Edit/Write operations on Elixir files. This is configured in `.claude/settings.local.json`.

## Tool Permissions

Pre-configured in `.claude/settings.local.json`:
- All `mix:*` commands allowed (Elixir build tool)
- Common git commands allowed
- WebSearch allowed
- Skill commands allowed for workflow

## Agent Model Assignments

- **Opus**: elixir-expert, research-agent, architecture-agent (highest capability)
- **Sonnet**: All review, planning, and implementation agents (balanced)
- **Haiku**: Currently unused

## Commit Guidelines

From global user instructions:
- NEVER mention Claude or AI assistants in commit messages
- NEVER commit without explicit user permission
- No sycophant language in commits or documentation

## Related Documentation

- `AGENTS.md` - Complete agent orchestration patterns and workflows
- `AGENT-SYSTEM-GUIDE.md` - Model specs, tool permissions, expert guidance formats
- `HOOKS-GUIDE.md` - Complete hook system reference with examples
- `notes/research/1.01-domain-specific-language/1.01.1-spark-dsl.md` - Comprehensive research on the Spark-powered DSL approach, including widget library analysis, architecture patterns, and implementation roadmap

## Research Summary

The research document (`1.01.1-spark-dsl.md`) outlines a complete strategy for building the unified UI DSL:

**Proposed DSL Structure:**
```elixir
ui do
  vbox do
    text "Welcome", style: [fg: :cyan, attrs: [:bold]]
    hbox style: [spacing: 2] do
      button "Submit", on_click: fn -> {:submit_form, %{}} end
      button "Cancel", on_click: fn -> {:cancel, %{}} end
    end
    table data: @source, columns: [...], on_row_select: &{:row_selected, %{id: &1.id}}
  end
end
```

**TermUi Widget Library (20+ components):**
Gauge, Sparkline, Table, Menu, TextInput, Dialog, AlertDialog, PickList, Tabs, ContextMenu, Toast, Viewport, SplitPane, TreeView, FormBuilder, CommandPalette, BarChart, LineChart, Canvas, LogViewer, StreamWidget, ProcessMonitor, SupervisionTreeViewer, ClusterDashboard

**Implementation Roadmap:**
1. Phase 1: Core DSL + TermUi integration
2. Phase 2: Widget expansion + advanced layouts/theming
3. Phase 3: Desktop/Web backends
4. Phase 4: Testing, optimization, ecosystem
