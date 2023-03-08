defmodule KindeManagementAPI.SDK.ClientCredentials do
  alias KindeManagementAPI.SDK.Utils
  use Tesla
  alias HTTPoison

  @spec login(
          any,
          %{
            :additional_params => map,
            :cache_pid => atom | pid | {atom, any} | {:via, atom, any},
            :client_id => any,
            :client_secret => any,
            :scopes => any,
            :token_endpoint => binary,
            optional(any) => any
          },
          map
        ) :: any
  def login(conn, client, additional_params \\ %{}) do
    form_data = %{
      client_id: client.client_id,
      client_secret: client.client_secret,
      grant_type: :client_credentials,
      scope: client.scopes
    }

    params =
      Utils.add_additional_params(client.additional_params, additional_params)
      |> Map.merge(form_data)
      |> Map.to_list()

    body = {:form, params}
    {:ok, response} = HTTPoison.post(client.token_endpoint, body)

    contents = Jason.decode!(response.body)

    GenServer.cast(
      client.cache_pid,
      {:add_kinde_data, {:kinde_access_token, contents["access_token"]}}
    )

    expires_in = if is_nil(contents["expires_in"]), do: 0, else: contents["expires_in"]

    GenServer.cast(
      client.cache_pid,
      {:add_kinde_data, {:kinde_expires_in, expires_in}}
    )

    GenServer.cast(
      client.cache_pid,
      {:add_kinde_data, {:kinde_login_time_stamp, DateTime.utc_now()}}
    )

    GenServer.cast(client.cache_pid, {:add_kinde_data, {:kinde_token, contents}})

    conn
  end
end
