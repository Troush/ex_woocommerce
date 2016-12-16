defmodule ExWoocommerce.OauthTest do
  use ExUnit.Case, async: false

  @url "http://localhost:8080"
  @key "ck_5a3d4fbcf8fd4bbb9b32f93aca8c0e1384a50c9f"
  @secret "cs_04ef3b1cdcb4724dd2a79b8a5b167bef846faf67"

  test "it creates api client" do
    client = ExWoocommerce.client(@url, @key, @secret)
    test_struct = %ExWoocommerce{consumer_key: "ck_5a3d4fbcf8fd4bbb9b32f93aca8c0e1384a50c9f",
       consumer_secret: "cs_04ef3b1cdcb4724dd2a79b8a5b167bef846faf67",
       debug_mode: false, is_ssl: false, method: "GET", query_string_auth: "",
       signature_method: "HMAC-SHA256", url: "http://localhost:8080",
       verify_ssl: true, version: "v3", wp_api: false}
    assert test_struct == client
  end

  test "it creates api client and make get request" do
    client = ExWoocommerce.client(@url, @key, @secret)
    {status, _products} = ExWoocommerce.get(client, "products")
    assert :ok == status
  end
end
