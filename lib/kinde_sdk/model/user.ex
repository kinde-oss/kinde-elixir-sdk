# NOTE: This file is auto generated by OpenAPI Generator 6.3.0 (https://openapi-generator.tech).
# Do not edit this file manually.

defmodule KindeSDK.Model.User do
  @moduledoc false

  @derive [Poison.Encoder]
  defstruct [
    :id,
    :email,
    :last_name,
    :first_name,
    :is_suspended
  ]

  @type t :: %__MODULE__{
          :id => integer() | nil,
          :email => String.t() | nil,
          :last_name => String.t() | nil,
          :first_name => String.t() | nil,
          :is_suspended => boolean() | nil
        }
end

defimpl Poison.Decoder, for: KindeSDK.Model.User do
  def decode(value, _options) do
    value
  end
end
