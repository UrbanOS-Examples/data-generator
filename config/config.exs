# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :data_generator, DataGeneratorWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "yQ0MRsL2W5819zTqNxL8r4rqxXbT2Xk1JBpkzG/hRo4Mu5eL9POJxLeUZ9CtV+EG",
  render_errors: [view: DataGeneratorWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: DataGenerator.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$date $time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :smart_city_registry,
  redis: [
    host: System.get_env("REDIS_HOST") || "localhost"
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
