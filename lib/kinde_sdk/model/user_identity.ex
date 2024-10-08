# NOTE: This file is auto generated by OpenAPI Generator 6.3.0 (https://openapi-generator.tech).
# Do not edit this file manually.

defmodule KindeSDK.Model.UserIdentity do
  @moduledoc false

  @derive [Poison.Encoder]
  defstruct [
    :type,
    :result
  ]

  @type t :: %__MODULE__{
          :type => String.t() | nil,
          :result => KindeSDK.Model.UserIdentityResult.t() | nil
        }
end

defimpl Poison.Decoder, for: KindeSDK.Model.UserIdentity do
  import KindeSDK.Deserializer

  def decode(value, options) do
    value
    |> deserialize(:result, :struct, KindeSDK.Model.UserIdentityResult, options)
  end
end
