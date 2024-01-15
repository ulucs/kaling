# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :kaling,
  ecto_repos: [Kaling.Repo]

# Configures the endpoint
config :kaling, KalingWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: KalingWeb.ErrorHTML, json: KalingWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Kaling.PubSub,
  live_view: [signing_salt: "HBqMs/3u"]

# Having a larger `max_collection` value will result in more memory usage, but less database writes.
# `max_collection` has an upper limit of 65,535/3 ~ 21,000 due to postgres limits. (using COPY would alleviate
# this) Having a larger `max_relay_time` value will result in less database writes, but more memory usage.
# Note that any data not persisted to the database will be lost if the process crashes. Configure the opts
# according to your risk tolerance and database scale.
config :kaling, Kaling.Analytics.Server,
  max_collection: 10,
  max_relay_time: 20

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :kaling, Kaling.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.7",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
