defmodule ExWoocommerce.OauthTest do
  use ExUnit.Case, async: false

  @url "http://localhost:8080"
  @method "get"
  @version "v3"
  @key "ck_010730bd8e7bd8cc5b737e15ce20124126f3d97b"
  @secret "cs_d4c27238255ad7824359e91f0c7c20172fda1183"

  test "it creates client struct" do
    client = ExWoocommerce.Oauth.client(@url, @method, @version, @key, @secret)
    test_struct = %ExWoocommerce.Oauth{url: "http://localhost:8080", version: "v3", consumer_key: "ck_010730bd8e7bd8cc5b737e15ce20124126f3d97b", consumer_secret: "cs_d4c27238255ad7824359e91f0c7c20172fda1183", method: "GET", signature_method: "HMAC-SHA256"}
    assert test_struct == client
  end

  test "it creates generates oauth_url" do
    client = ExWoocommerce.Oauth.client(@url <> "/orders", @method, @version, @key, @secret)
    url = ExWoocommerce.Oauth.get_oauth_url(client)
    test_url = "http://localhost:8080/orders?oauth_consumer_key=ck_010730bd8e7bd8cc5b737e15ce20124126f3d97b&oauth_nonce=28CC2209B234D9183848F1C6A8FF13E0311057B9&oauth_signature=1F3F6FD0228B63FBF4E7DF7C00807DA26CFF190C7E074FFE203215F8940AECDE&oauth_signature_method=HMAC-SHA256&oauth_timestamp=#{DateTime.utc_now() |> DateTime.to_unix()}"
    assert test_url == url
  end

  test "it creates api client" do
    client = ExWoocommerce.client(@url <> "/orders", @key, @secret)
    test_struct = %ExWoocommerce{consumer_key: "ck_010730bd8e7bd8cc5b737e15ce20124126f3d97b",
       consumer_secret: "cs_d4c27238255ad7824359e91f0c7c20172fda1183",
       debug_mode: false, is_ssl: false, method: "GET", query_string_auth: "",
       signature_method: "HMAC-SHA256", url: "http://localhost:8080/orders",
       verify_ssl: true, version: "v3", wp_api: false}
    assert test_struct == client
  end

  test "it creates api client and make get request" do
    client = ExWoocommerce.client(@url, @key, @secret)
    res = ExWoocommerce.get(client, "products")
    IO.inspect res
  end
end
