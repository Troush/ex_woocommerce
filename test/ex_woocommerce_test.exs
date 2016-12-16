defmodule ExWoocommerce.OauthTest do
  use ExUnit.Case, async: false

  @url "http://localhost:8080"
  @key "ck_010730bd8e7bd8cc5b737e15ce20124126f3d97b"
  @secret "cs_d4c27238255ad7824359e91f0c7c20172fda1183"

  test "it creates api client" do
    client = ExWoocommerce.client(@url, @key, @secret)
    test_struct = %ExWoocommerce{consumer_key: "ck_010730bd8e7bd8cc5b737e15ce20124126f3d97b",
       consumer_secret: "cs_d4c27238255ad7824359e91f0c7c20172fda1183",
       debug_mode: false, is_ssl: false, method: "GET", query_string_auth: "",
       signature_method: "HMAC-SHA256", url: "http://localhost:8080",
       verify_ssl: true, version: "v3", wp_api: false}
    assert test_struct == client
  end

  test "it creates api client and make get request" do
    client = ExWoocommerce.client(@url, @key, @secret)
    res = ExWoocommerce.get(client, "products")
    IO.inspect res
  end
end
