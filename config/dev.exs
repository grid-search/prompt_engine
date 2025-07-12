import Config

# Configure assets for development environment
config :esbuild,
  version: "0.25.5",
  default: [
    args: ~w(js/app.js --bundle --minify --outdir=priv/static/assets),
    cd: "assets",
    env: %{"NODE_PATH" => "node_modules"}
  ]

config :tailwind,
  version: "4.1.11",
  prompt_engine_web: [
    cd: "assets",
    input: "css/app.css",
    output: "priv/static/assets/app.css",
    config: "tailwind.config.js"
  ]
