defmodule ClientTestHelper do
  alias KindeClientSDK
  alias KindeSDK.SDK.Utils

  @redirect_url Application.compile_env(:kinde_sdk, :redirect_url) |> String.replace("\"", "")
  @pkce_callback_url Application.compile_env(:kinde_sdk, :pkce_callback_url)
                     |> String.replace("\"", "")
  @frontend_client_id Application.compile_env(:kinde_sdk, :frontend_client_id)
                      |> String.replace("\"", "")
  @client_id Application.compile_env(:kinde_sdk, :backend_client_id) |> String.replace("\"", "")
  @client_secret Application.compile_env(:kinde_sdk, :client_secret) |> String.replace("\"", "")
  @logout_redirect_url Application.compile_env(:kinde_sdk, :logout_redirect_url)
                       |> String.replace("\"", "")
  @valid_domain Application.compile_env(:kinde_sdk, :domain) |> String.replace("\"", "")
  @invalid_domain "test.c"

  def initialize_valid_client(conn, grant_type) do
    KindeClientSDK.init(
      conn,
      @valid_domain,
      @redirect_url,
      @client_id,
      @client_secret,
      grant_type,
      @logout_redirect_url
    )
  end

  def initialize_invalid_client(conn, grant_type) do
    KindeClientSDK.init(
      conn,
      @invalid_domain,
      @redirect_url,
      @client_id,
      @client_secret,
      grant_type,
      @logout_redirect_url
    )
  end

  def initialize_invalid_redirect_uri(conn, grant_type) do
    KindeClientSDK.init(
      conn,
      @valid_domain,
      "",
      @client_id,
      @client_secret,
      grant_type,
      @logout_redirect_url
    )
  end

  def initialize_valid_client_add_params(conn, grant_type, additional_params) do
    KindeClientSDK.init(
      conn,
      @valid_domain,
      @redirect_url,
      @client_id,
      @client_secret,
      grant_type,
      @logout_redirect_url,
      "openid profile email offline",
      additional_params
    )
  end

  def init_valid_pkce_client(conn, grant_type) do
    KindeClientSDK.init(
      conn,
      @valid_domain,
      @pkce_callback_url,
      @frontend_client_id,
      @client_secret,
      grant_type,
      @logout_redirect_url
    )
  end

  def mock_token(conn, pid) do
    token = %{
      "id_token" =>
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJLaW5kZSBFbGl4aXIgVGVzdCIsImlhdCI6MTY4MDYwODY3NSwiZXhwIjoxNzEyMTQ0Njc1LCJhdWQiOiJ3d3cuZXhhbXBsZS5jb20iLCJzdWIiOiJ0ZXN0QGtpbmRlLmNvbSIsImdpdmVuX25hbWUiOiJKb2huIiwiZmFtaWx5X25hbWUiOiJEb2UiLCJlbWFpbCI6InVzZXJAa2luZGUuY29tIiwib3JnX2NvZGUiOiI3NjU1NDYifQ.7oLWhK6MhMdOWhExd7XTKUH-FvcfUBtBZQjvyKWmSyE",
      "access_token" => nil,
      "expires_in" => 99987
    }

    expires_in = if is_nil(token["expires_in"]), do: 0, else: token["expires_in"]

    GenServer.cast(pid, {:add_kinde_data, {:kinde_login_time_stamp, DateTime.utc_now()}})
    GenServer.cast(pid, {:add_kinde_data, {:kinde_access_token, token["access_token"]}})
    GenServer.cast(pid, {:add_kinde_data, {:kinde_id_token, token["id_token"]}})
    GenServer.cast(pid, {:add_kinde_data, {:kinde_expires_in, expires_in}})

    payload = Utils.parse_jwt(token["id_token"])

    if !is_nil(payload) do
      user = %{
        id: payload["sub"],
        given_name: payload["given_name"],
        family_name: payload["family_name"],
        email: payload["email"]
      }

      GenServer.cast(pid, {:add_kinde_data, {:kinde_user, user}})
    else
      GenServer.cast(pid, {:add_kinde_data, {:kinde_user, nil}})
    end

    conn
  end

  def mock_feature_flags(conn, pid) do
    token = %{
      "access_token" =>
        "eyJhbGciOiJSUzI1NiIsImtpZCI6IjdhOmYzOjZiOmE3OjVjOjI1OmE3OmY4OmMzOjA1OjYzOmNiOjRiOmYwOjMzOjhiIiwidHlwIjoiSldUIn0.eyJhdWQiOltdLCJhenAiOiIyZTQxZTllNzk4MDA0MTc3YjFiNDRhYTFlMWFkM2Q2MiIsImV4cCI6MTY4NDM5NjYzMCwiZmVhdHVyZV9mbGFncyI6eyJjb3VudGVyIjp7InQiOiJpIiwidiI6NTV9LCJpc19kYXJrX21vZGUiOnsidCI6ImIiLCJ2IjpmYWxzZX0sInRoZW1lIjp7InQiOiJzIiwidiI6ImdyYXlzY2FsZSJ9fSwiaWF0IjoxNjg0Mzk2NTY5LCJpc3MiOiJodHRwczovL2VsaXhpcnNkazIua2luZGUuY29tIiwianRpIjoiYzljOTM0YTctOGRmOC00OWFjLWFkZDctODRiNDMwODg3YWYyIiwib3JnX2NvZGUiOiJvcmdfOWRjMzNmMWQ2NDQiLCJwZXJtaXNzaW9ucyI6W10sInNjcCI6WyJvcGVuaWQiLCJwcm9maWxlIiwiZW1haWwiLCJvZmZsaW5lIl0sInN1YiI6ImtwOmEzNjgzMTJlM2Q4ODRlMTU4YmU0NzVjNjAyNWJiYmFkIn0.vM0s0KKp8Y_KcXgBtuIWlskcyiSyhBRBNV-7hOWUarUr9wu61P1L-pjYswdRj_0HKH7ZxaOydSl1Mq-6tf7R8uWryR-kLVVFRpCvCDP7y3CLsGkBlLsnxazwWuBmja0619oBTqjba7QAVE3rxlIuUYdNLjJrXbo0V0OAwErzlB8gGEJ5s2opvpWKtKjO027SNDEGSHbWJ3SGvMRYtZSRA9ku3Tcso3eqLH2cFT7tS0aYRWyPqvZe3k_st4T0qoRXGYgQI_XMTgw26ar2yvXp7Shvl3ib6oUndOr_ZQ5yT3orvvl8wyadgct3X-i8c379pn8kTvZ3kTN2r-jYLQVAEQ"
    }

    GenServer.cast(pid, {:add_kinde_data, {:kinde_access_token, token["access_token"]}})

    conn
  end

  def mock_picture_url(conn, pid) do
    token = %{
      "id_token" =>
        "eyJhbGciOiJSUzI1NiIsImtpZCI6IjdhOmYzOjZiOmE3OjVjOjI1OmE3OmY4OmMzOjA1OjYzOmNiOjRiOmYwOjMzOjhiIiwidHlwIjoiSldUIn0.eyJhdF9oYXNoIjoiXzBBV1kteF9SZnd1NHduMVdhMV9NQSIsImF1ZCI6WyJodHRwczovL2VsaXhpcnNkazIua2luZGUuY29tIiwiMmU0MWU5ZTc5ODAwNDE3N2IxYjQ0YWExZTFhZDNkNjIiXSwiYXV0aF90aW1lIjoxNjg1NDYyNjU0LCJhenAiOiIyZTQxZTllNzk4MDA0MTc3YjFiNDRhYTFlMWFkM2Q2MiIsImVtYWlsIjoiYWhtZWQuaXNtYWlsQGludm96b25lLmNvbSIsImV4cCI6MTY4NTQ2MjcxNCwiZmFtaWx5X25hbWUiOiJBaG1lZCBJc21haWwiLCJnaXZlbl9uYW1lIjoiTXVoYW1tYWQiLCJpYXQiOjE2ODU0NjI2NTQsImlzcyI6Imh0dHBzOi8vZWxpeGlyc2RrMi5raW5kZS5jb20iLCJqdGkiOiI3N2MxMjUxYi1hYmY0LTRjNTctOGUxOS1mYzQ2NDc4OTVjNzYiLCJuYW1lIjoiTXVoYW1tYWQgQWhtZWQgSXNtYWlsIiwib3JnX2NvZGVzIjpbIm9yZ185ZGMzM2YxZDY0NCJdLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUFjSFR0ZndiOHlHOHhpOFozM0xVQ1htbngtNDBuRXlQVjYxTkFsVHJEc2Q9czk2LWMiLCJzdWIiOiJrcDphMzY4MzEyZTNkODg0ZTE1OGJlNDc1YzYwMjViYmJhZCIsInVwZGF0ZWRfYXQiOjEuNjg1NDYyNjUzZSswOX0.mPc9D4xXppJLe_JqPODzBzZxULYkgVEG8uUAWSRw0GFOj8zq3rpCiaYClubL_l2mlojgFEWJnwvX1Jjei2jjKDjZ4WfwAYywIDnodgZ2F4AUSvjY1bR7jT6ZqjSvYU6_AsvF3Dp2VSmY5R0xudxQrC1tm68jFLBrrD8RMcbJg_BJ8hRWEMHbg58BBBOdsuOuI1wiqIozlQWHe74B2RaZNuNCHjfQ81e71IYU8z9ibbDF6-xxyhMKGnDH1-b3mlW34i4RO7dTVrXSjz9L0wubTD2ECTMCQ8ym9UUtO6-Sq3wZZl_ztudaRTdiwBiDeJGHgvR9AStmfVhf6iFmrLUTUw"
    }

    payload = Utils.parse_jwt(token["id_token"])

    if !is_nil(payload) do
      user = %{
        id: payload["sub"],
        given_name: payload["given_name"],
        family_name: payload["family_name"],
        email: payload["email"],
        picture: payload["picture"]
      }

      GenServer.cast(pid, {:add_kinde_data, {:kinde_user, user}})
    else
      GenServer.cast(pid, {:add_kinde_data, {:kinde_user, nil}})
    end

    conn
  end

  def mock_pkce_token(conn, pid) do
    token = %{
      "access_token" =>
        "eyJhbGciOiJSUzI1NiIsImtpZCI6IjdhOmYzOjZiOmE3OjVjOjI1OmE3OmY4OmMzOjA1OjYzOmNiOjRiOmYwOjMzOjhiIiwidHlwIjoiSldUIn0.eyJhdWQiOltdLCJhenAiOiIyZTQxZTllNzk4MDA0MTc3YjFiNDRhYTFlMWFkM2Q2MiIsImV4cCI6MTY4NTUyMjg0MiwiZmVhdHVyZV9mbGFncyI6eyJjb3VudGVyIjp7InQiOiJpIiwidiI6NTV9LCJpc19kYXJrX21vZGUiOnsidCI6ImIiLCJ2IjpmYWxzZX0sInRoZW1lIjp7InQiOiJzIiwidiI6ImdyYXlzY2FsZSJ9fSwiaWF0IjoxNjg1NTIyNzgyLCJpc3MiOiJodHRwczovL2VsaXhpcnNkazIua2luZGUuY29tIiwianRpIjoiMzFmNzBlMzQtODRlYy00ODE5LWI0ZTEtMWJlYWNlMWQwOTVjIiwib3JnX2NvZGUiOiJvcmdfOWRjMzNmMWQ2NDQiLCJwZXJtaXNzaW9ucyI6W10sInNjcCI6WyJvcGVuaWQiLCJwcm9maWxlIiwiZW1haWwiLCJvZmZsaW5lIl0sInN1YiI6ImtwOmEzNjgzMTJlM2Q4ODRlMTU4YmU0NzVjNjAyNWJiYmFkIn0.vDZ7LnzlYhYKrJhpk3eb_435A4ecyiEtR3S2D0TTDMKZx6JP-i8jKfimwzjCQmd6L7KRohJjj8ClNK2pdykEu-HRKiPZLOzni74tNMzIrjaQwvrmz4qEf2OEUE3IrLmHgZ2phIqJmqBN8albfdivm2RYesRt68TKakkqs-I8vU9eyAffRQH7UkKmzmAbhC69N4Y3auJefNFtqRlbUZ0-gAyBCeBLErFmgcoWyTpUWnKPlps7hCQNqA-q3JkXnsKX-WPFNm5LIF2qUjCAjMJLAKQW6Xc66LfsTWiuwMSF_NlUSK56tfv9089QGV_dZ7EODAzDM2P8hxnxvpEv6WSRbw",
      "expires_in" => 59,
      "id_token" =>
        "eyJhbGciOiJSUzI1NiIsImtpZCI6IjdhOmYzOjZiOmE3OjVjOjI1OmE3OmY4OmMzOjA1OjYzOmNiOjRiOmYwOjMzOjhiIiwidHlwIjoiSldUIn0.eyJhdF9oYXNoIjoidTQtLVJEMjAyWTM5c0lURXN1SENNdyIsImF1ZCI6WyJodHRwczovL2VsaXhpcnNkazIua2luZGUuY29tIiwiMmU0MWU5ZTc5ODAwNDE3N2IxYjQ0YWExZTFhZDNkNjIiXSwiYXV0aF90aW1lIjoxNjg1NTIyNzgyLCJhenAiOiIyZTQxZTllNzk4MDA0MTc3YjFiNDRhYTFlMWFkM2Q2MiIsImVtYWlsIjoiYWhtZWQuaXNtYWlsQGludm96b25lLmNvbSIsImV4cCI6MTY4NTUyMjg0MiwiZmFtaWx5X25hbWUiOiJBaG1lZCBJc21haWwiLCJnaXZlbl9uYW1lIjoiTXVoYW1tYWQiLCJpYXQiOjE2ODU1MjI3ODIsImlzcyI6Imh0dHBzOi8vZWxpeGlyc2RrMi5raW5kZS5jb20iLCJqdGkiOiI2MDI4OGRkYi1jMjRiLTRmODYtYjUwZS01ZWZiNDAzOGMxMjciLCJuYW1lIjoiTXVoYW1tYWQgQWhtZWQgSXNtYWlsIiwib3JnX2NvZGVzIjpbIm9yZ185ZGMzM2YxZDY0NCJdLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUFjSFR0ZndiOHlHOHhpOFozM0xVQ1htbngtNDBuRXlQVjYxTkFsVHJEc2Q9czk2LWMiLCJzdWIiOiJrcDphMzY4MzEyZTNkODg0ZTE1OGJlNDc1YzYwMjViYmJhZCIsInVwZGF0ZWRfYXQiOjEuNjg1NTIyNzIxZSswOX0.B6FUOesnmnWa1IUM8e36zPMPLu-9lINmtUqoapte2gnd1_0BDVfXJVcfaKu7ekykc76LdF8l8_SOYGzh54xkJuMffIP6l2I5yEi35pXXuS10gP1AO6alCgFwUnBfNVP2jX1Np4IDPocxUojJxcOd_NGxaEOogaVnqWZobfkZdb1hNkUg-FYMYQYVtmnLj5sVCouTdLCyqKT_HlKfWgYxcWauoDzIcHnE1io8JGRNmPu-Nf_o8Czm10pgXVZNdVVLNpzRhAVmSieZZNDZi5iVGEwghcFLroujpvHDJESfiIFnbGbR50jTleSjoVZJjgvJN3JCt0m_CQqKcCXPoqrAPw",
      "refresh_token" =>
        "h-GHFrU_9dRPBJxEIkJjYQBoy-pI0y52fuiFbfGndX4.auX9g-Pp02sM1YBn-nkmCWrynGSy_AvY7RmipN5uUwI",
      "scope" => "openid profile email offline",
      "token_type" => "bearer"
    }

    GenServer.cast(pid, {:add_kinde_data, {:kinde_access_token, token["access_token"]}})
    GenServer.cast(pid, {:add_kinde_data, {:kinde_id_token, token["id_token"]}})
    GenServer.cast(pid, {:add_kinde_data, {:kinde_expires_in, token["expires_in"]}})
    GenServer.cast(pid, {:add_kinde_data, {:kinde_refresh_token, token["refresh_token"]}})

    conn
  end

  def mock_result_for_refresh_token(conn, pid) do
    token = %{
      "access_token" =>
        "eyJhbGciOiJSUzI1NiIsImtpZCI6IjdhOmYzOjZiOmE3OjVjOjI1OmE3OmY4OmMzOjA1OjYzOmNiOjRiOmYwOjMzOjhiIiwidHlwIjoiSldUIn0.eyJhdWQiOltdLCJhenAiOiIyZTQxZTllNzk4MDA0MTc3YjFiNDRhYTFlMWFkM2Q2MiIsImV4cCI6MTY4NTUyNjY4MywiZmVhdHVyZV9mbGFncyI6eyJjb3VudGVyIjp7InQiOiJpIiwidiI6NTV9LCJpc19kYXJrX21vZGUiOnsidCI6ImIiLCJ2IjpmYWxzZX0sInRoZW1lIjp7InQiOiJzIiwidiI6ImdyYXlzY2FsZSJ9fSwiaWF0IjoxNjg1NTI2NjIyLCJpc3MiOiJodHRwczovL2VsaXhpcnNkazIua2luZGUuY29tIiwianRpIjoiOGQyMTgxYjgtNjcxZC00ZTdmLWFkNDgtYTIxYmJhNjlhM2ZhIiwib3JnX2NvZGUiOiJvcmdfOWRjMzNmMWQ2NDQiLCJwZXJtaXNzaW9ucyI6W10sInNjcCI6WyJvcGVuaWQiLCJwcm9maWxlIiwiZW1haWwiLCJvZmZsaW5lIl0sInN1YiI6ImtwOmEzNjgzMTJlM2Q4ODRlMTU4YmU0NzVjNjAyNWJiYmFkIn0.jarRvDXeeX26J_hdxDjhGgUgbOJYXIOgk48EQg4zstISGGP4Dev2b91vM4cQAW2X8RSnXeVcJJ7u1_6Yz19sw14aPrJlvuDcVpuADiPFE4phkAvRXTPvr2iJpC0OVz6ZHqKBsMciu3bCi61uojyAKvjD6pn7rYiHWmxoFeZnmPxLK1cGBrMfBzX0MXXykMMF78NEpthempjhuM3kMPlyao7H1LCO4Os6mKPDzAliyv4t5T465wLIC_xTr1Kdp456eLU-FyJLD2bWWtKOzMSf2pOXt99UNtrJl7Pcyi7C7t1Z_iyPvLhU6YnPGe4UICKcuVYC3--TbZfGkg5kr2JKNw",
      "expires_in" => 60,
      "id_token" =>
        "eyJhbGciOiJSUzI1NiIsImtpZCI6IjdhOmYzOjZiOmE3OjVjOjI1OmE3OmY4OmMzOjA1OjYzOmNiOjRiOmYwOjMzOjhiIiwidHlwIjoiSldUIn0.eyJhdF9oYXNoIjoiQVpGSHdSbkpyN1dZWm1mRXJpd3ZBZyIsImF1ZCI6WyJodHRwczovL2VsaXhpcnNkazIua2luZGUuY29tIiwiMmU0MWU5ZTc5ODAwNDE3N2IxYjQ0YWExZTFhZDNkNjIiXSwiYXV0aF90aW1lIjoxNjg1NTI2NjIyLCJhenAiOiIyZTQxZTllNzk4MDA0MTc3YjFiNDRhYTFlMWFkM2Q2MiIsImVtYWlsIjoiYWhtZWQuaXNtYWlsQGludm96b25lLmNvbSIsImV4cCI6MTY4NTUyNjY4MiwiZmFtaWx5X25hbWUiOiJBaG1lZCBJc21haWwiLCJnaXZlbl9uYW1lIjoiTXVoYW1tYWQiLCJpYXQiOjE2ODU1MjY2MjIsImlzcyI6Imh0dHBzOi8vZWxpeGlyc2RrMi5raW5kZS5jb20iLCJqdGkiOiIyZjVmZmY3NC1jYjU3LTRlNWQtOWU2My0zZDVjZTMxNDE4YzYiLCJuYW1lIjoiTXVoYW1tYWQgQWhtZWQgSXNtYWlsIiwib3JnX2NvZGVzIjpbIm9yZ185ZGMzM2YxZDY0NCJdLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUFjSFR0ZndiOHlHOHhpOFozM0xVQ1htbngtNDBuRXlQVjYxTkFsVHJEc2Q9czk2LWMiLCJzdWIiOiJrcDphMzY4MzEyZTNkODg0ZTE1OGJlNDc1YzYwMjViYmJhZCIsInVwZGF0ZWRfYXQiOjEuNjg1NTIyNzIxZSswOX0.pQzIPfbGbS8pxU55aHdqIMSsg8S8lTQ7cCPnrjnIIAIwtuG22MxxFjryMzX0zcW8HK2zmBuKTvrgx6-dI34wPT2uDyvvP3vpXS76h5Yz4-06Bn4y11DfnOGEk1CNxhv-8a2F9khCSWrM8Pi9WOBd3R1QHY4neDdYK-SF_tJ2yoouFTDOe8XzYynt7UBesBqzWzibpoDIymU_l0BMkz-abdRhtdgctbu6R42GVEEedH3uvQuIXwfyUOwfXpdAl5QuA0Hp6hWogFkrCGQTDF6k8kNimZmDXTTyDoAcqy7ubQrXDcq6O5wHLz5kLJ3UxPuOztlrmghSTR1h3UZAFJXEVw",
      "refresh_token" =>
        "TrpKSDbbvSjIlg204MItcvDZXNEXzhh_TifwLvscb1s.xpgl4r4GQatmaKn-GFa9tm152Oyf8U4a0c2kagFFEr0",
      "scope" => "openid profile email offline",
      "token_type" => "bearer"
    }

    GenServer.cast(pid, {:add_kinde_data, {:kinde_access_token, token["access_token"]}})
    GenServer.cast(pid, {:add_kinde_data, {:kinde_id_token, token["id_token"]}})
    GenServer.cast(pid, {:add_kinde_data, {:kinde_expires_in, token["expires_in"]}})
    GenServer.cast(pid, {:add_kinde_data, {:kinde_refresh_token, token["refresh_token"]}})

    conn
  end
end
