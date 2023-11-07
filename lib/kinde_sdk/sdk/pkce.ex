defmodule KindeSDK.SDK.Pkce do
  alias KindeSDK.SDK.Utils

  @moduledoc """
  PKCE (Proof Key for Code Exchange) OAuth2 Login Flow

  This module provides functions for implementing the PKCE OAuth2 login flow
  in the Kinde SDK. PKCE is a security extension for OAuth2 to protect against
  code interception and misuse. This module facilitates the login process and the
  generation of PKCE code challenges.

  ## Usage Example

  To initiate a PKCE OAuth2 login flow, you can call the `login/4` function as follows:

  ```elixir
  conn = KindeSDK.SDK.Pkce.login(conn, client, start_page, additional_params)

  This module is designed to simplify the login process while enhancing security in Kinde applications.
  """
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
          any,
          map
        ) :: Plug.Conn.t()
  def login(conn, client, start_page, additional_params) do
    GenServer.cast(client.cache_pid, {:add_kinde_data, {:kinde_oauth_code_verifier, nil}})
    challenge = Utils.generate_challenge()

    GenServer.cast(client.cache_pid, {:add_kinde_data, {:kinde_oauth_state, challenge.state}})

    search_params = %{
      redirect_uri: client.redirect_uri,
      client_id: client.client_id,
      response_type: :code,
      scope: client.scopes,
      code_challenge: challenge.code_challenge,
      code_verifier: challenge.code_verifier,
      code_challenge_method: "S256",
      state: challenge.state,
      start_page: start_page
    }

    params =
      Utils.add_additional_params(client.additional_params, additional_params)
      |> Map.merge(search_params)
      |> URI.encode_query()

    GenServer.cast(
      client.cache_pid,
      {:add_kinde_data, {:kinde_oauth_code_verifier, challenge.code_verifier}}
    )

    conn
    |> Plug.Conn.resp(:found, "")
    |> Plug.Conn.put_resp_header("location", "#{client.authorization_endpoint}?#{params}")
  end
end
