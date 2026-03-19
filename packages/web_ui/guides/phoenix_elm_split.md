# Phoenix + Elm Split Architecture

This guide covers the split runtime architecture of web_ui.

## Overview

web_ui uses a split runtime model:

1. **Phoenix (Server)** - Handles initial rendering, server-authoritative state
2. **Elm (Client)** - Handles client-side interactivity and local state

## Communication Flow

```
┌─────────────┐              ┌─────────────┐
│   Phoenix   │◄────────────►│    Elm      │
│   (Server)  │   Channels   │  (Client)   │
└─────────────┘              └─────────────┘
      │                             │
      │                             │
      ▼                             ▼
  Server State                  Client State
```

[TODO: Add detailed split architecture documentation]
