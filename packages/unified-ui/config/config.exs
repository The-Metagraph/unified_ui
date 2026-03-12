import Config

# Configure your database
# config :unified_ui, UnifiedUi.Repo,
#   username: "postgres",
#   password: "postgres",
#   hostname: "localhost",
#   database: "unified_ui_test",
#   pool: Ecto.Adapters.SQL.Sandbox

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
