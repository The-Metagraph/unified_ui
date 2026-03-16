import Config

app = Mix.Project.config()[:app]

namespace =
  app
  |> Atom.to_string()
  |> String.trim_leading("unified_example_")
  |> Macro.camelize()
  |> then(&Module.concat([UnifiedExamples, &1]))

endpoint = Module.concat(namespace, Endpoint)
pubsub_server = Module.concat(namespace, PubSub)

config :phoenix, :json_library, Jason

config app, endpoint,
  url: [host: "127.0.0.1"],
  http: [ip: {127, 0, 0, 1}, port: String.to_integer(System.get_env("PORT") || "4000")],
  server: false,
  secret_key_base: String.duplicate("0123456789abcdef", 4),
  live_view: [signing_salt: "unifiedexamples"],
  pubsub_server: pubsub_server,
  check_origin: false,
  debug_errors: true,
  code_reloader: false
