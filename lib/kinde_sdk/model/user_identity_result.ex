# NOTE: This file is auto generated by OpenAPI Generator 6.3.0 (https://openapi-generator.tech).
# Do not edit this file manually.

defmodule KindeSDK.Model.UserIdentityResult do
  @moduledoc """
  The result of the user creation operation
  """

  @derive [Poison.Encoder]
  defstruct [
    :created,
    :identity_id
  ]

  @type t :: %__MODULE__{
          :created => boolean() | nil,
          :identity_id => integer() | nil
        }
end

defimpl Poison.Decoder, for: KindeSDK.Model.UserIdentityResult do
  def decode(value, _options) do
    value
  end
end
