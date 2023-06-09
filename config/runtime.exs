import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.
import Envar
Envar.load(".env")

config :kinde_sdk, base_url: Envar.get("KINDE_BASE_URL")
config :kinde_sdk, domain: Envar.get("KINDE_DOMAIN")
config :kinde_sdk, redirect_url: Envar.get("KINDE_REDIRECT_URL")
config :kinde_sdk, backend_client_id: Envar.get("KINDE_BACKEND_CLIENT_ID")
config :kinde_sdk, client_secret: Envar.get("KINDE_CLIENT_SECRET")
config :kinde_sdk, logout_redirect_url: Envar.get("KINDE_LOGOUT_REDIRECT_URL")
config :kinde_sdk, pkce_callback_url: Envar.get("KINDE_PKCE_REDIRECT_URL")
config :kinde_sdk, pkce_logout_url: Envar.get("KINDE_PKCE_LOGOUT_URL")
config :kinde_sdk, frontend_client_id: Envar.get("KINDE_FRONTEND_CLIENT_ID")

if base_url = System.get_env("KINDE_SDK_BASE_URI") do
  config :kinde_sdk, base_url: base_url
end
