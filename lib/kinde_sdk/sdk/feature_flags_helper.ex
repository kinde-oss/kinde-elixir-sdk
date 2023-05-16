defmodule KindeSdk.Sdk.FeatureFlagsHelper do
  @moduledoc """
    Helper module created for the feature-flags object

    ### Usage

    Can be used to leverage the get_claim method, and make the feature-flag object more readible, for example:

    feature_flags = %{
                      "counter" => %{"t" => "i", "v" => 55},
                      "is_dark_mode" => %{"t" => "b", "v" => true},
                      "theme" => %{"t" => "s", "v" => "grayscale"}
                    }
    FeatureFlagsHelper.get_flag(feature_flags, "theme") will return

    %{
      "code" => "theme",
      "is_default" => false,
      "type" => "string",
      "value" => "grayscale"
    }

  """

  @doc """
    Returns more readible version of any feature-flag

    ### Returns

    feature-flag map such as

    %{
      "code" => "theme",
      "is_default" => false,
      "type" => "string",
      "value" => "grayscale"
    }
  """
  @spec get_flag(map(), String.t()) :: map() | String.t()
  def get_flag(feature_flags, code) do
    case feature_flags[code] do
      nil ->
        "This flag does not exist, and no default value provided"

      %{"t" => flag_type, "v" => value} ->
        %{
          "code" => code,
          "type" => get_type(flag_type),
          "value" => value,
          "is_default" => false
        }
    end
  end

  @spec get_flag(map(), String.t(), any()) :: map() | String.t()
  def get_flag(feature_flags, code, default_value) do
    case feature_flags[code] do
      nil ->
        %{
          "code" => code,
          "value" => default_value,
          "is_default" => true
        }

      _ ->
        get_flag(feature_flags, code)
    end
  end

  @spec get_flag(map(), String.t(), any(), String.t()) :: map() | String.t()
  def get_flag(feature_flags, code, default_value, flag_type) do
    case feature_flags[code] do
      %{"t" => actual_type} when actual_type != flag_type ->
        "The flag type was provided as #{get_type(flag_type)}, but it is #{get_type(actual_type)}"

      _ ->
        get_flag(feature_flags, code, default_value)
    end
  end

  @doc """
    Returns a boolean flag from feature-flags object

    ### Returns

    true, false or error-messages
  """

  @spec get_boolean_flag(map(), String.t()) :: boolean() | String.t()
  def get_boolean_flag(feature_flags, code) do
    case feature_flags[code] do
      %{"t" => "b", "v" => value} ->
        value

      %{"t" => type} ->
        "Error - Flag #{code} is of type #{get_type(type)} not boolean"

      _ ->
        "Error - flag does not exist and no default provided"
    end
  end

  @spec get_boolean_flag(map(), String.t(), boolean()) :: boolean() | String.t()
  def get_boolean_flag(feature_flags, code, default_value) do
    case feature_flags[code] do
      nil ->
        default_value

      %{"t" => "b", "v" => value} ->
        value

      %{"t" => type, "v" => _} ->
        "Error - Flag #{code} is of type #{get_type(type)} not boolean"
    end
  end

  @doc """
    Returns a string flag from feature-flags object

    ### Returns

    corresponding values from object or error-messages
  """
  @spec get_string_flag(map(), String.t()) :: String.t()
  def get_string_flag(feature_flags, code) do
    case feature_flags[code] do
      %{"t" => "s", "v" => value} ->
        value

      %{"t" => type} ->
        "Error - Flag #{code} is of type #{get_type(type)} not string"

      _ ->
        "Error - flag does not exist and no default provided"
    end
  end

  @spec get_string_flag(map(), String.t(), String.t()) :: String.t()
  def get_string_flag(feature_flags, code, default_value) do
    case feature_flags[code] do
      nil ->
        default_value

      %{"t" => "s", "v" => value} ->
        value

      %{"t" => type, "v" => _} ->
        "Error - Flag #{code} is of type #{get_type(type)} not string"
    end
  end

  @doc """
    Returns a integer flag from feature-flags object

    ### Returns

    corresponding values from object or error-messages
  """

  @spec get_integer_flag(map(), String.t()) :: integer() | String.t()
  def get_integer_flag(feature_flags, code) do
    case feature_flags[code] do
      %{"t" => "i", "v" => value} ->
        value

      %{"t" => type} ->
        "Error - Flag #{code} is of type #{get_type(type)} not integer"

      _ ->
        "Error - flag does not exist and no default provided"
    end
  end

  @spec get_integer_flag(map(), String.t(), integer()) :: integer() | String.t()
  def get_integer_flag(feature_flags, code, default_value) do
    case feature_flags[code] do
      nil ->
        default_value

      %{"t" => "i", "v" => value} ->
        value

      %{"t" => type, "v" => _} ->
        "Error - Flag #{code} is of type #{get_type(type)} not integer"
    end
  end

  defp get_type(flag) when is_map(flag) do
    type = flag["t"]

    case type do
      "i" ->
        "integer"

      "s" ->
        "string"

      "b" ->
        "boolean"

      _ ->
        "undefined"
    end
  end

  defp get_type(flag) do
    case flag do
      "i" ->
        "integer"

      "s" ->
        "string"

      "b" ->
        "boolean"

      _ ->
        "undefined"
    end
  end
end
