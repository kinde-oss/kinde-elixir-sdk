defmodule KindeManagementAPI.SDK.AuthorizationCode do
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
