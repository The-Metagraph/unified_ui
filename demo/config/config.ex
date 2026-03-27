import Config

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11"

# Configure Tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  default: [
    :default,
    :text,
    :heading,
    :body
  ]
