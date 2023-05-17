# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :kinde_sdk, base_url: System.get_env("KINDE_BASE_URL")
config :kinde_sdk, domain: System.get_env("KINDE_DOMAIN")
config :kinde_sdk, redirect_url: System.get_env("KINDE_REDIRECT_URL")
config :kinde_sdk, backend_client_id: System.get_env("KINDE_BACKEND_CLIENT_ID")
config :kinde_sdk, client_secret: System.get_env("KINDE_CLIENT_SECRET")
config :kinde_sdk, logout_redirect_url: System.get_env("KINDE_LOGOUT_REDIRECT_URL")
config :kinde_sdk, pkce_callback_url: System.get_env("KINDE_PKCE_REDIRECT_URL")
config :kinde_sdk, pkce_logout_url: System.get_env("KINDE_PKCE_LOGOUT_URL")
config :kinde_sdk, frontend_client_id: System.get_env("KINDE_FRONTEND_CLIENT_ID")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
#
# import_config "#{config_env()}.exs"
