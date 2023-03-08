defmodule KindeManagementAPI.SDK.Pkce do
  alias KindeManagementAPI.SDK.Utils

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
