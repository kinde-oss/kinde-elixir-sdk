defmodule KindeSDK.SDK.AuthorizationCode do
  @moduledoc """
  Authorization Code OAuth2 Flow

  This module provides functions for implementing the Authorization Code OAuth2 flow in the Kinde SDK. The Authorization Code flow is commonly used for user authentication, allowing a Kinde application to obtain an access token after the user authorizes the application.

  ## Usage Example

  To initiate an Authorization Code OAuth2 flow, you can call the `login/3` function as follows:

  ```elixir
  conn = KindeSDK.SDK.AuthorizationCode.login(conn, client, additional_params)

  This module simplifies the process of initiating the Authorization Code flow for user authentication in Kinde applications.
  """
  alias KindeSDK.SDK.Utils

  @spec login(
          Plug.Conn.t(),
          %{
            :additional_params => map,
            :authorization_endpoint => any,
            :cache_pid => atom | pid | {atom, any} | {:via, atom, any},
            :client_id => any,
            :redirect_uri => any,
            :scopes => any,
            optional(any) => any
          },
          map
        ) :: Plug.Conn.t()
  def login(conn, client, additional_params \\ %{}) do
    state = Utils.random_string()

    GenServer.cast(client.cache_pid, {:add_kinde_data, {:kinde_oauth_state, state}})

    search_params = %{
      client_id: client.client_id,
      grant_type: :authorization_code,
      redirect_uri: client.redirect_uri,
      response_type: :code,
      scope: client.scopes,
      state: state,
      start_page: :login
    }

    params =
      Utils.add_additional_params(client.additional_params, additional_params)
      |> Map.merge(search_params)
      |> URI.encode_query()

    conn
    |> Plug.Conn.resp(:found, "")
    |> Plug.Conn.put_resp_header("location", "#{client.authorization_endpoint}?#{params}")
  end
end
