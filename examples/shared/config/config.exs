import Config

# Runtime configuration for unified examples
#
# The runtime determines which UI package renders the IUR (Intermediate Unified Representation).
# Options:
#   - :live_ui (default) - Browser-based rendering via LiveView
#   - :desktop_ui - Native desktop rendering via SDL3
#
# Override priority (highest to lowest):
#   1. CLI flag: mix examples.launch DIRECTORY --runtime desktop_ui
#   2. Environment variable: UNIFIED_RUNTIME=desktop_ui
#   3. Config file: config :unified_examples_shared, :runtime, :desktop_ui
#   4. Default: :live_ui

config :unified_examples_shared, :runtime, :live_ui
