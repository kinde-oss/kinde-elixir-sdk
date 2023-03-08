defmodule KindeManagementAPI.SDK.Utils do
  @length 32

  defp base64_url_encode(string) do
    string
    |> Base.url_encode64()
    |> String.trim()
    |> String.replace("=", "")
    |> String.replace("+", "-")
    |> String.replace("/", "_")
  end

  @spec random_string(any) :: binary
  def random_string(length \\ @length) do
    :crypto.strong_rand_bytes(length)
    |> Base.encode16()
    |> base64_url_encode()
  end

  @spec generate_challenge :: %{code_challenge: binary, code_verifier: binary, state: binary}
  def generate_challenge do
    state = random_string()
    code_verifier = random_string()
    code_challenge = :crypto.hash(:sha256, code_verifier) |> Base.url_encode64(padding: false)

    %{
      state: state,
      code_verifier: code_verifier,
      code_challenge: code_challenge
    }
  end

  @spec validate_url(binary) :: boolean
  def validate_url(url) do
    Regex.match?(
      ~r/https?:\/\/(?:w{1,3}\.)?[^\s.]+(?:\.[a-z]+)*(?::\d+)?(?![^<]*(?:<\/\w+>|\/?>))/,
      url
    )
  end

  @spec parse_jwt(nil | binary) :: any
  def parse_jwt(nil), do: nil

  def parse_jwt(token) do
    String.split(token, ".")
    |> Enum.at(1)
    |> String.replace("-", "+")
    |> String.replace("_", "/")
    |> Base.decode64!(padding: false)
    |> Jason.decode!()
  end

  @additional_param_keys [:audience, :org_code, :org_name, :is_create_org]

  @spec check_additional_params(map) :: map
  def check_additional_params(params) when params == %{}, do: %{}

  def check_additional_params(params) do
    keys = Map.keys(params)

    for key <- keys do
      if !(key in @additional_param_keys) do
        throw("Please provide correct additional, #{key}")
      end

      if !is_binary(Map.get(params, key)) do
        throw("Please supply a valid #{key}. Expected: string")
      end
    end

    params
  end

  @spec add_additional_params(map, map) :: map
  def add_additional_params(target, additional_params) do
    additional_params
    |> check_additional_params()
    |> Map.merge(target)
  end
end
