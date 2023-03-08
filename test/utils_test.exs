defmodule UtilsTest do
  use ExUnit.Case

  alias KindeManagementAPI.SDK.Utils

  test "random string" do
    str = Utils.random_string(28)
    refute str == ""
  end

  test "generate challenge" do
    challenge = Utils.generate_challenge()

    refute is_nil(challenge[:state])
    refute is_nil(challenge[:code_verifier])
    refute is_nil(challenge[:code_challenge])
  end

  test "valid url" do
    url = "https://test.com"
    assert Utils.validate_url(url)
  end

  test "invalid url" do
    url = "test.c"
    refute Utils.validate_url(url)
  end
end
