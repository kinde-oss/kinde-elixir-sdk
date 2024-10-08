# NOTE: This file is auto generated by OpenAPI Generator 6.3.0 (https://openapi-generator.tech).
# Do not edit this file manually.

defmodule KindeSDK.Model.CreateUserRequest do
  @moduledoc false

  @derive [Poison.Encoder]
  defstruct [
    :profile,
    :identities
  ]

  @type t :: %__MODULE__{
          :profile => KindeSDK.Model.CreateUserRequestProfile.t() | nil,
          :identities => [KindeSDK.Model.CreateUserRequestIdentitiesInner.t()] | nil
        }
end

defimpl Poison.Decoder, for: KindeSDK.Model.CreateUserRequest do
  import KindeSDK.Deserializer

  def decode(value, options) do
    value
    |> deserialize(:profile, :struct, KindeSDK.Model.CreateUserRequestProfile, options)
    |> deserialize(:identities, :list, KindeSDK.Model.CreateUserRequestIdentitiesInner, options)
  end
end
