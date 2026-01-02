defmodule TagBoard do
  @behaviour :httpd_api_handler

  @port 8080

  def start() do
    setup_network(:sta)

    httpd_config = [
      # handler para ruta /api
      {[<<"tags">>],
       %{
         handler: :httpd_api_handler,
         handler_config: %{
           module: __MODULE__
         }
       }},
      # handler de archivos para ruta /, expone archivos en directorio /priv 
      {[],
       %{
         handler: :httpd_file_handler,
         handler_config: %{
           app: :tag_board
         }
       }}
    ]

    {:ok, _httpd_pid} = :httpd.start_link(@port, httpd_config)

    :io.format('Servidor web iniciado.~n')

    :io.format('minimum free space: ~p~n', [:erlang.system_info(:esp32_minimum_free_size)])

    :timer.sleep(5000)

    :io.format('minimum free space: ~p~n', [:erlang.system_info(:esp32_minimum_free_size)])

    # TagBoard.Store.clear_all_tags()

    :timer.sleep(:infinity)
  end

  def handle_api_request(:post, [<<"create">>], http_request, _args) do
    :io.format('got request ~p ~n', [http_request])
    {:ok, body_map} = :mjson.decode(http_request.body)

    :io.format('got body ~p~n', [body_map])

    author = body_map[<<"author">>]
    content = body_map[<<"content">>]
    timestamp = body_map[<<"timestamp">>]

    :io.format('got author ~p~n', [author])
    :io.format('got content ~p~n', [content])

    post_content(author, content, timestamp)

    {:close, %{status: "ok"}}
  end

  def handle_api_request(:get, [<<"get">>], http_request, _args) do
    # :io.format('got request ~p ~n', [http_request])

    {:ok, tags} = TagBoard.Store.get_tags()

    # :io.format('got tags: ~p~n', [tags])

    {:close, %{tags: tags}}
  end

  defp post_content(author, content, timestamp) do
    TagBoard.Store.add_tag(author, content, timestamp)

    {:ok, tags} = TagBoard.Store.get_tags()

    :io.format('current tagboard: ~p~n', [tags])
  end

  defp setup_network(:ap) do
    ap_config = [
      ssid: "robot test",
      psk: "passpass",
      ap_started: fn -> :io.format('Punto de acceso iniciado en 192.168.4.1~n') end
    ]

    {:ok, _network_pid} = :network.start(ap: ap_config)

    Process.sleep(4000)
  end

  defp setup_network(:sta) do
    config =
      [
        {:ssid, <<"ssid">>},
        {:psk, <<"password">>},
        {:got_ip, fn ip -> :io.format('Got IP: ~p~n', [ip]) end},
        {:dhcp_hostname, <<"myesp32">>}
      ]

    {:ok, _network_pid} = :network.start(sta: config)

    Process.sleep(4000)
  end
end
