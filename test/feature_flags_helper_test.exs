defmodule FeatureFlagsHelperTest do
  use ExUnit.Case
  alias KindeSdk.Sdk.FeatureFlagsHelper

  @feature_flags %{
    "counter" => %{"t" => "i", "v" => 55},
    "is_dark_mode" => %{"t" => "b", "v" => true},
    "theme" => %{"t" => "s", "v" => "grayscale"}
  }

  describe "get_flag/2 action" do
    test "returns detailed map for any certain code" do
      assert FeatureFlagsHelper.get_flag(@feature_flags, "theme") == %{
               "code" => "theme",
               "is_default" => false,
               "type" => "string",
               "value" => "grayscale"
             }
    end

    test "returns error-message when unknown-code is passed" do
      assert FeatureFlagsHelper.get_flag(@feature_flags, "unknown_flag_code") ==
               "This flag does not exist, and no default value provided"

      assert FeatureFlagsHelper.get_flag(@feature_flags, "another_invalid_code") ==
               "This flag does not exist, and no default value provided"
    end
  end

  describe "get_flag/3 action" do
    test "returns detailed map for any certain code, despite of any default-value provided" do
      assert FeatureFlagsHelper.get_flag(@feature_flags, "theme", "pink") == %{
               "code" => "theme",
               "is_default" => false,
               "type" => "string",
               "value" => "grayscale"
             }
    end

    test "returns customized-map for any certain code (which doesn't exists), but default-value provided" do
      assert FeatureFlagsHelper.get_flag(@feature_flags, "unknown_flag_code", "pink") == %{
               "code" => "unknown_flag_code",
               "is_default" => true,
               "value" => "pink"
             }
    end
  end

  describe "get_flag/4 action" do
    test "returns detailed map for any certain code, when flag-type matches the type of code" do
      assert FeatureFlagsHelper.get_flag(@feature_flags, "theme", "pink", "s") == %{
               "code" => "theme",
               "is_default" => false,
               "type" => "string",
               "value" => "grayscale"
             }
    end

    test "returns error-message when types are mis-matched" do
      assert FeatureFlagsHelper.get_flag(@feature_flags, "theme", "pink", "i") ==
               "The flag type was provided as integer, but it is string"

      assert FeatureFlagsHelper.get_flag(@feature_flags, "counter", 34, "s") ==
               "The flag type was provided as string, but it is integer"
    end
  end

  describe "get_boolean_flag/2 action" do
    test "returns true/false, when boolean-flag is fetched" do
      assert FeatureFlagsHelper.get_boolean_flag(@feature_flags, "is_dark_mode") == true
    end

    test "returns error-message, if you try to fetch non-boolean flag from it" do
      assert FeatureFlagsHelper.get_boolean_flag(@feature_flags, "theme") ==
               "Error - Flag theme is of type string not boolean"
    end

    test "returns error-message, if flag is invalid, and doesn't exists" do
      assert FeatureFlagsHelper.get_boolean_flag(@feature_flags, "unknown_flag") ==
               "Error - flag does not exist and no default provided"
    end
  end

  describe "get_boolean_flag/3 action" do
    test "returns true/false, when boolean-flag is fetched, despite of what default-value is being passed" do
      assert FeatureFlagsHelper.get_boolean_flag(@feature_flags, "is_dark_mode", false) == true
    end

    test "returns default-value, when unknown-flag is passed" do
      assert FeatureFlagsHelper.get_boolean_flag(@feature_flags, "unknown_flag", false) == false
    end
  end

  describe "get_string_flag/2 action" do
    test "returns string-value, when string-flag is fetched" do
      assert FeatureFlagsHelper.get_string_flag(@feature_flags, "theme") == "grayscale"
    end

    test "returns error-message, if you try to fetch non-string flag from it" do
      assert FeatureFlagsHelper.get_string_flag(@feature_flags, "is_dark_mode") ==
               "Error - Flag is_dark_mode is of type boolean not string"
    end

    test "returns error-message, if flag is invalid, nor doesn't exists" do
      assert FeatureFlagsHelper.get_string_flag(@feature_flags, "unknown_flag") ==
               "Error - flag does not exist and no default provided"
    end
  end

  describe "get_string_flag/3 action" do
    test "returns string-value, when string-flag is fetched, despite of what default-value is being passed" do
      assert FeatureFlagsHelper.get_string_flag(@feature_flags, "theme", "pink") == "grayscale"
    end

    test "returns default-value, when unknown-flag is passed" do
      assert FeatureFlagsHelper.get_string_flag(@feature_flags, "unknown_flag", "pink") == "pink"
    end
  end

  describe "get_integer_flag/2 action" do
    test "returns integer-value, when integer-flag is fetched" do
      assert FeatureFlagsHelper.get_integer_flag(@feature_flags, "counter") == 55
    end

    test "returns error-message, if you try to fetch non-integer flag from it" do
      assert FeatureFlagsHelper.get_integer_flag(@feature_flags, "is_dark_mode") ==
               "Error - Flag is_dark_mode is of type boolean not integer"
    end

    test "returns error-message, if flag is invalid + doesn't exists" do
      assert FeatureFlagsHelper.get_integer_flag(@feature_flags, "unknown_flag") ==
               "Error - flag does not exist and no default provided"
    end
  end

  describe "get_integer_flag/3 action" do
    test "returns integer-value, when integer-flag is fetched, despite of what default-value is being passed" do
      assert FeatureFlagsHelper.get_integer_flag(@feature_flags, "counter", 99) == 55
    end

    test "returns default-value, when unknown-flag is passed" do
      assert FeatureFlagsHelper.get_integer_flag(@feature_flags, "unknown_flag", 99) == 99
    end
  end
end
