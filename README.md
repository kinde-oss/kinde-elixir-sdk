# Kinde Elixir SDK

The Kinde Elixir SDK allows developers to use this library for the Kinde Business.

You can also use the [Elixir starter kit here](https://github.com/kinde-starter-kits/elixir-starter-kit).

## Register for Kinde

If you haven’t already got a Kinde account, [register for free here](http://app.kinde.com/register) (no credit card required).

You need a Kinde domain to get started, e.g. `yourapp.kinde.com`.

## Installation

Add the following dependency in your project:

```elixir
{:kinde_sdk, path: "/path/to/kinde-elixir-sdk"}
```
and add to your extra applications:
```elixir
def application do
  [
    extra_applications: [:logger, :kinde_sdk]
  ]
end
```

## Configuration of API Keys

You need to follow these steps to setup the project properly:

1. Create .env file at the root
2. Add the following lines in there:
```
export KINDE_BACKEND_CLIENT_ID="6c43a124bc114dc0bf78889ae89349b3"
export KINDE_FRONTEND_CLIENT_ID="2e41e9e798004177b1b44aa1e1ad3d62"
export KINDE_CLIENT_SECRET="Tz9oKlQGW1VJX2FUoLdaeUHjCMnlNccHTW1fyOWlO4krBb4P1G"
export KINDE_REDIRECT_URL="http://localhost:4000/callback"
export KINDE_DOMAIN="https://elixirsdk2.kinde.com"
export KINDE_LOGOUT_REDIRECT_URL="http://localhost:4000/logout"
export KINDE_PKCE_LOGOUT_URL="http://localhost:4000/logout"
export KINDE_PKCE_REDIRECT_URL="http://localhost:4000/pkce-callback"
export KINDE_BASE_URL="https://app.kinde.com"
```
3. Don't forget to update the values of above keys with your kinde-account keys to make the app up and running.
4. Optionally, you can also set `scope` as well.
```elixir
config :kinde_sdk, scope: "email"
```

5. Once you're done with above steps, open the console and write `source .env` before any mix command.
6. Note: This configuration is very important, you won't be able to compile the project, as well as no tests will run successfully until you follow these steps.

## Configuration of kinde_sdk in Existing Project

You need to follow these steps to setup the existing project properly:

1. Create .env file at the root
2. Add the following lines in there:
```
export KINDE_BACKEND_CLIENT_ID="6c43a124bc114dc0bf78889ae89349b3"
export KINDE_FRONTEND_CLIENT_ID="2e41e9e798004177b1b44aa1e1ad3d62"
export KINDE_CLIENT_SECRET="Tz9oKlQGW1VJX2FUoLdaeUHjCMnlNccHTW1fyOWlO4krBb4P1G"
export KINDE_REDIRECT_URL="http://localhost:4000/callback"
export KINDE_DOMAIN="https://elixirsdk2.kinde.com"
export KINDE_LOGOUT_REDIRECT_URL="http://localhost:4000/logout"
export KINDE_PKCE_LOGOUT_URL="http://localhost:4000/logout"
export KINDE_PKCE_REDIRECT_URL="http://localhost:4000/pkce-callback"
export KINDE_BASE_URL="https://app.kinde.com"
```
3. Don't forget to replace the values to your own application-keys, these are just dummy keys (might not work)
4. Also make sure that your project has runtime.exs file in the config directory which has following piece of code written in it:
```
import Config
import Envar
Envar.load(".env")
# configure kinde_sdk on runtime
config :kinde_sdk,
  backend_client_id: Envar.get("KINDE_BACKEND_CLIENT_ID"),
  frontend_client_id: Envar.get("KINDE_FRONTEND_CLIENT_ID"),
  client_secret: Envar.get("KINDE_CLIENT_SECRET"),
  redirect_url: Envar.get("KINDE_REDIRECT_URL"),
  domain: Envar.get("KINDE_DOMAIN"),
  logout_redirect_url: Envar.get("KINDE_LOGOUT_REDIRECT_URL"),
  pkce_logout_url: Envar.get("KINDE_PKCE_LOGOUT_URL"),
  pkce_callback_url: Envar.get("KINDE_PKCE_REDIRECT_URL")
```

## Usage

Initialize your client like this:

```elixir
{conn, client} =
  KindeClientSDK.init(
    conn,
    Application.get_env(:kinde_sdk, :domain),
    Application.get_env(:kinde_sdk, :redirect_url),
    Application.get_env(:kinde_sdk, :backend_client_id),
    Application.get_env(:kinde_sdk, :client_secret),
    :client_credentials,
    Application.get_env(:kinde_sdk, :logout_redirect_url)
  )
```

### OAuth Flows (Grant Types)
KindeClientSDK implements three OAuth flows: Client Credentials flow, Authorisation Code flow and Authorisation Code with PKCE flow. Each flow can be used with their corresponding grant type when initializing a client.

| OAuth Flow | Grant Type | Type |
| ---------- | ---------- | ---- |
| Client Credentials | :client_credentials | atom |
| Authorisation Code | :authorization_code | atom |
| Authorisation Code with PKCE | :authorization_code_flow_pkce | atom |

### ETS Cache

KindeClientSDK implements persistant ETS cache for storing the client data and authenticating variables.

You may call your created client like this:
```elixir
client = KindeClientSDK.get_kinde_client(conn)
```

### Login
```elixir
conn = KindeClientSDK.login(conn, client)
```

### Register
```elixir
conn = KindeClientSDK.register(conn, client)
```

## Callbacks

When the user is redirected back to your site from Kinde, this will call your callback URL defined in the `redirect_url` config. You will need to route `/callback` to call a function to handle this.

```elixir
def callback(conn, _params) do
  {conn, client} = KindeClientSDK.get_token(conn)

  data = KindeClientSDK.get_all_data(conn)
  IO.inspect(data.access_token, label: "kinde_access_token") # Tip: This line is not mandatory, as its just console-printing
end
```

## Tokens

We can use Kinde helper function to get the tokens generated by `login` and `get_token` functions.

```elixir
data = KindeClientSDK.get_all_data(conn)
IO.inspect(data.login_time_stamp, label: "Login Time Stamp") # Tip: This line is not mandatory, as its just console-printing
```

Or first calling the `get_token` function:
```elixir
{conn, client} = KindeClientSDK.get_token(conn)
```

### User details
You need to have already authenticated before you call the API, otherwise an error will occur.
```elixir
KindeClientSDK.get_user_detail(conn)
```

### Create an organization
To have a new organization created within your application
```elixir
conn = KindeClientSDK.create_org(conn, client)
conn = KindeClientSDK.create_org(conn, client)
```

### Logout
The Kinde SDK client comes with a logout method.
```elixir
conn = KindeClientSDK.logout(conn)
```

### Authenticated
Returns whether if a user is logged in.
```elixir
KindeClientSDK.authenticated?(conn)
```

### Claims
We have provided a helper to grab any claim from your id or access tokens. The helper defaults to access tokens:
```elixir
KindeClientSDK.get_claims(conn)
KindeClientSDK.get_claim(conn, "jti", :id_token)
```

### Permissions
We provide helper functions to more easily access permissions:
```elixir
KindeClientSDK.get_permissions(conn)
KindeClientSDK.get_permission(conn, "create:users")
```

See [Define user permissions](https://kinde.com/docs/user-management/user-permissions).

## Audience
An `audience` is the intended recipient of an access token - for example the API for your application. The audience argument can be passed to the Kinde client to request an audience be added to the provided token.

```elixir
additional_params = %{
      audience: "api.yourapp.com"
    }

KindeClientSDK.init(
    conn,
    Application.get_env(:kinde_sdk, :domain),
    Application.get_env(:kinde_sdk, :redirect_url),
    Application.get_env(:kinde_sdk, :backend_client_id),
    Application.get_env(:kinde_sdk, :client_secret),
    :authorization_code_flow_pkce,
    Application.get_env(:kinde_sdk, :logout_redirect_url),
    "openid profile email offline",
    additional_params
  )
```

For details on how to connect, see [Register an API](https://kinde.com/docs/developer-tools/register-an-api/)

## Overriding scope

By default the KindeSDK requests the following scopes:

- profile
- email
- offline
- openid

You can override this by passing scope into the KindeSDK.

## kinde SDK Reference

| Property | Type | Is required | Default | Description |
| -------- | ---- | ----------- | ------- | ----------- |
| domain | string | Yes | | Either your Kinde instance url or your custom domain. e.g: https://yourapp.kinde.com |
| redirect_url | string | Yes |  | The url that the user will be returned to after authentication |
| backend_client_id    | string | Yes |  | The id of your backend application |
| frontend_client_id    | string | Yes |  | The id of your frontend application |
| client_secret    | string | Yes |  | The id secret of your application - get this from the Kinde admin area |
| logout_redirect_url  | string | Yes |  | Where your user will be redirected upon logout  |
| scope  | string | No  | openid profile email offline | The scopes to be requested from Kinde  |
| additional_parameters    | map  | No  | %{} | Additional parameters that will be passed in the authorization request |
| additional_parameters - audience | string | No  |  | The audience claim for the JWT |
| additional_parameters - org_name | string | No  |  | The org claim for the JWT |
| additional_parameters - org_code | string | No  |  | The org claim for the JWT |


## SDK Functions

| Function | Description | Arguments | Usage |
| -------- | ---- | ----------- | ------- |
| login   | Constructs redirect url and sends user to Kinde to sign in    | conn, client  | ```KindeClientSDK.login(conn, client)```   |
| register     | Constructs redirect url and sends user to Kinde to sign up    | conn, client  | ```KindeClientSDK.register(conn, client)```   |
| logout  | Logs the user out of Kinde    | conn | ```KindeClientSDK.logout(conn)```  |
| get_token     | Returns the raw access token from URL after logged from Kinde    | conn | ```KindeClientSDK.get_token(conn)```   | 
| create_org    | Constructs redirect url and sends user to Kinde to sign up and create a new org for your business | conn, client  | ```KindeClientSDK.create_org(conn, client)``` |
| get_claims     | Gets all claims from an access or id token   | conn, atom | ```KindeClientSDK.get_claims(conn)``` or ```KindeClientSDK.get_claims(conn, :id_token)```  |
| get_claim     | Gets a claim-object from an access or id token   | conn, string, atom | ```KindeClientSDK.get_claim(conn, "jti")``` or ```KindeClientSDK.get_claim(conn, "jti", :id_token)```  |
| get_permissions   | Returns the state of a all permissions   | conn, atom  | ```KindeClientSDK.get_permissions(conn, :id_token)```   |
| get_permission   | Returns the state of a given permission   | conn, string  | ```KindeClientSDK.get_permission(conn, "create:users")```   |
| get_organization | Get details for the organization your user is logged into     | conn | ```KindeClientSDK.get_user_organization(conn)```     |
| get_user_detail  | Returns the profile for the current user  | conn | ```KindeClientSDK.get_user_detail(conn)``` |
| get_user_organizations  | Returns the org code from the user token  | conn | ```KindeClientSDK.get_user_organizations(conn)``` |
| get_cache_pid | Returns the Kinde cache PID from the `conn` | conn | ```KindeClientSDK.get_cache_pid(conn)``` |
| save_kinde_client | Saves the Kinde client created into the `conn` | conn | ```KindeClientSDK.save_kinde_client(conn)``` |
| get_kinde_client | Returns the Kinde client created from the `conn` | conn | ```KindeClientSDK.get_kinde_client(conn)``` |
| get_all_data | Returns all the Kinde data (tokens) returned | conn | ```KindeClientSDK.get_all_data(conn)``` |

## Feature Flag Helper Functions

| Function | Description | Arguments | Usage |
| -------- | ---- | ----------- | ------- |
| get_flag/2   | Detail of any certain feature-flag    | conn, code  | ```KindeClientSDK.get_flag(conn, code)```   |
| get_flag/3     | Detail of any certain feature-flag    | conn, code, default_value  | ```KindeClientSDK.get_flag(conn, code, default_value)```   |
| get_flag/4  | Detail of any certain feature-flag    | conn, code, default_value, flag_type | ```KindeClientSDK.get_flag(conn, code, default_value, flag_type)```  |
| get_boolean_flag/2     | Returns the boolean-flag from conn    | conn, code | ```KindeClientSDK.get_boolean_flag(conn, code)```   | 
| get_boolean_flag/3    | Returns the boolean-flag from conn | conn, code, default_value  | ```KindeClientSDK.get_boolean_flag(conn, code, default_value)``` |
| get_string_flag/2     | Returns the string-flag from conn    | conn, code | ```KindeClientSDK.get_string_flag(conn, code)```   | 
| get_string_flag/3    | Returns the string-flag from conn | conn, code, default_value  | ```KindeClientSDK.get_string_flag(conn, code, default_value)``` |
| get_integer_flag/2     | Returns the integer-flag from conn    | conn, code | ```KindeClientSDK.get_integer_flag(conn, code)```   | 
| get_integer_flag/3    | Returns the integer-flag from conn | conn, code, default_value  | ```KindeClientSDK.get_integer_flag(conn, code, default_value)``` |
