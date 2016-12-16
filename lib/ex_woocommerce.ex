defmodule ExWoocommerce do
  defstruct url: "", method: "GET", version: "v3",
            consumer_key: "", consumer_secret: "", signature_method: "",
            is_ssl: false, wp_api: false, verify_ssl: true, signature_method: "HMAC-SHA256",
            debug_mode: false, query_string_auth: ""
  
  def client(url, consumer_key, consumer_secret, args \\ %{}) do
    client = %ExWoocommerce{
      url: url,
      consumer_key: consumer_key,
      consumer_secret: consumer_secret,
      is_ssl: String.starts_with?(url, "https://"),
    }
    Map.merge(client, args)
  end

    # Public: GET requests.
  #
  # endpoint - A String naming the request endpoint.
  # query    - A Hash with query params.
  #
  # Returns the request Hash.
  def get(client, endpoint, query \\ nil) do
    do_request(client, "get", add_query_params(endpoint, query))
  end

  # Public: POST requests.
  #
  # endpoint - A String naming the request endpoint.
  # data     - The Hash data for the request.
  #
  # Returns the request Hash.
  def post(client, endpoint, data) do
    do_request(client, "post", endpoint, data)
  end

  def add_query_params(endpoint, data) do
    if is_nil(data) || Enum.count(data) == 0 do
      endpoint
    else
      unless String.contains?(endpoint, "?") do
        endpoint <> "?"
      end
      unless String.ends_with?(endpoint, "?") do
        endpoint <> "&"
      end
      endpoint <> URI.encode(Enum.join(data, "&"))
    end
  end


  def do_request(client, method, endpoint, data \\ %{}) do
    url = get_url(client, endpoint, method)
    headers= [
      "User-Agent": "WooCommerce API Client-Elixir",
      "Content-Type": "application/json;charset=utf-8",
      "Accept": "application/json"
    ]
    options = [ssl: client.verify_ssl]

    # Set basic authentication.
    if client.is_ssl do
      options =
        if client.query_string_auth do
          Map.merge(options, %{
            query: %{
              consumer_key: client.consumer_key,
              consumer_secret: client.consumer_secret
            }}
          )
        else
          Map.merge(options, %{
            basic_auth: %{
              username: client.consumer_key,
              password: client.consumer_secret
            }}
          )
        end
    end

    options = prepare_options(options, data)

    with {:ok, result} <- HTTPoison.request(String.to_atom(method), url, "", headers, options),
         {:ok, body}   <- Poison.decode(result.body) do
         {:ok, body}
    else
      {:error, error} ->
        {:error, error.reason}
    end 
  end

  def get_url(client, endpoint, method) do
    api =
      case client.wp_api do
        true   -> "wp-json"
        false  -> "wc-api"
      end
    url = client.url
    url = add_slash_to_url(url)
    url = "#{url}#{api}/#{client.version}/#{endpoint}"
    
    case client.is_ssl do
      true  -> url
      false -> oauth_url(client, url, method)
    end
  end

  def oauth_url(client, url, method) do
    oauth = ExWoocommerce.Oauth.client(
      url,
      method,
      client.version,
      client.consumer_key,
      client.consumer_secret,
      client.signature_method
    )
    ExWoocommerce.Oauth.get_oauth_url(oauth)
  end

  defp add_slash_to_url(url) do
    unless String.ends_with?(url, "/") do
      "#{url}/"
    else 
      url
    end
  end

  defp prepare_options(options, data) do
    options_keys_count = Map.keys(data) |> Enum.count
    if ( options_keys_count > 0 ) do
        Map.merge(options, %{ body: Poison.encode(data)})
    else 
      options
    end
  end
end
