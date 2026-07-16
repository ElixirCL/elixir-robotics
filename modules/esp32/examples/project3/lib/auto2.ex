defmodule Auto2 do
  @in1 13
  @in2 14
  @in3 27
  @in4 26
  @wifi_timeout_ms 20_000
  @wifi_max_retries 5
  @listen_port 80
  @recv_timeout_ms 2_000
  @max_request_bytes 2048
  @wifi_ssid "mauricio"
  @wifi_psk "mauricapo123"
  @ap_ssid "Auto2"
  @ap_psk "auto2control"
  @ap_timeout_ms 15_000

  def start do
    IO.puts("--- Auto2 boot ---")
    setup_motors()

    case connect_wifi_with_retries(@wifi_max_retries) do
      {:ok, ip} ->
        IO.puts("WiFi connected. IP: #{format_ip(ip)}")
        start_server(@listen_port)

      {:error, reason} ->
        IO.puts("WiFi failed: #{inspect(reason)}")

        case start_ap_and_wait() do
          {:ok, ap_ip} ->
            IO.puts("AP started. Control via http://#{ap_ip}/")
            start_server(@listen_port)

          {:error, ap_reason} ->
            IO.puts("AP fallback failed: #{inspect(ap_reason)}")
            idle_loop()
        end
    end
  end

  defp connect_wifi_with_retries(0), do: {:error, :wifi_connect_timeout}

  defp connect_wifi_with_retries(attempts_left) do
    attempt = @wifi_max_retries - attempts_left + 1
    IO.puts("Connecting WiFi (attempt #{attempt}/#{@wifi_max_retries})...")

    case build_sta_config() do
      {:ok, sta_config} ->
        connect_with_sta_config(sta_config, attempts_left)

      {:error, reason} ->
        IO.puts("WiFi config error: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp connect_with_sta_config(sta_config, attempts_left) do
    case wait_for_sta_safe(sta_config, @wifi_timeout_ms) do
      {:ok, {ip, _mask, _gw}} ->
        {:ok, ip}

      {:error, reason} ->
        IO.puts("WiFi attempt failed: #{inspect(reason)}")
        log_sta_rssi()
        safe_network_stop()
        :timer.sleep(1_500)
        connect_wifi_with_retries(attempts_left - 1)
    end
  end

  defp wait_for_sta_safe(sta_config, timeout_ms) do
    try do
      :network.wait_for_sta(sta_config, timeout_ms)
    catch
      :exit, reason -> {:error, {:network_exit, reason}}
      kind, reason -> {:error, {kind, reason}}
    end
  end

  defp log_sta_rssi do
    try do
      case :network.sta_rssi() do
        {:ok, rssi} -> IO.puts("STA RSSI: #{rssi} dB")
        {:error, reason} -> IO.puts("STA RSSI error: #{inspect(reason)}")
      end
    catch
      :exit, _ -> :ok
      _, _ -> :ok
    end
  end

  defp build_sta_config do
    cond do
      @wifi_ssid == "" ->
        {:error, :missing_ssid}

      @wifi_psk == "" ->
        {:error, :missing_psk}

      true ->
        {:ok, [{:ssid, @wifi_ssid}, {:psk, @wifi_psk}]}
    end
  end

  defp setup_motors do
    :gpio.set_pin_mode(@in1, :output)
    :gpio.set_pin_mode(@in2, :output)
    :gpio.set_pin_mode(@in3, :output)
    :gpio.set_pin_mode(@in4, :output)
    stop()
  end

  def forward do
    :gpio.digital_write(@in1, :high)
    :gpio.digital_write(@in2, :low)
    :gpio.digital_write(@in3, :high)
    :gpio.digital_write(@in4, :low)
  end

  def backward do
    :gpio.digital_write(@in1, :low)
    :gpio.digital_write(@in2, :high)
    :gpio.digital_write(@in3, :low)
    :gpio.digital_write(@in4, :high)
  end

  def left do
    :gpio.digital_write(@in1, :low)
    :gpio.digital_write(@in2, :high)
    :gpio.digital_write(@in3, :high)
    :gpio.digital_write(@in4, :low)
  end

  def right do
    :gpio.digital_write(@in1, :high)
    :gpio.digital_write(@in2, :low)
    :gpio.digital_write(@in3, :low)
    :gpio.digital_write(@in4, :high)
  end

  def stop do
    :gpio.digital_write(@in1, :low)
    :gpio.digital_write(@in2, :low)
    :gpio.digital_write(@in3, :low)
    :gpio.digital_write(@in4, :low)
  end

  defp start_server(port) do
    {:ok, listen_socket} =
      :gen_tcp.listen(port, [:binary, active: false, reuseaddr: true, backlog: 8])

    IO.puts("HTTP server ready on port #{port}")
    accept_loop(listen_socket)
  end

  defp accept_loop(listen_socket) do
    case :gen_tcp.accept(listen_socket) do
      {:ok, socket} ->
        spawn(fn -> handle_client(socket) end)
        accept_loop(listen_socket)

      {:error, reason} ->
        IO.puts("Accept error: #{inspect(reason)}")
        :timer.sleep(250)
        accept_loop(listen_socket)
    end
  end

  defp handle_client(socket) do
    case :gen_tcp.recv(socket, 0, @recv_timeout_ms) do
      {:ok, data} ->
        request = truncate_request(data)
        process_request(socket, request)

      {:error, reason} ->
        IO.puts("Client recv error: #{inspect(reason)}")
    end

    :gen_tcp.close(socket)
  end

  defp process_request(socket, request) do
    first_line = first_request_line(request)

    cond do
      starts_with_bin?(first_line, "GET /cmd?") ->
        handle_command_request(socket, first_line)

      starts_with_bin?(first_line, "GET / ") or starts_with_bin?(first_line, "GET /HTTP") ->
        send_html(socket)

      true ->
        send_not_found(socket)
    end
  end

  defp handle_command_request(socket, request_line) do
    motion =
      cond do
        contains_bin?(request_line, "move=forward") -> "forward"
        contains_bin?(request_line, "move=backward") -> "backward"
        contains_bin?(request_line, "move=left") -> "left"
        contains_bin?(request_line, "move=right") -> "right"
        contains_bin?(request_line, "move=stop") -> "stop"
        true -> nil
      end

    case motion do
      "forward" ->
        forward()
        send_json(socket, motion)

      "backward" ->
        backward()
        send_json(socket, motion)

      "left" ->
        left()
        send_json(socket, motion)

      "right" ->
        right()
        send_json(socket, motion)

      "stop" ->
        stop()
        send_json(socket, motion)

      nil ->
        send_bad_request(socket, "invalid_move")
    end
  end

  defp send_json(socket, motion) do
    :gen_tcp.send(socket, [
      "HTTP/1.1 200 OK\r\n",
      "Content-Type: application/json\r\n",
      "Connection: close\r\n\r\n",
      "{\"motion\":\"",
      motion,
      "\"}"
    ])
  end

  defp send_html(socket) do
    :gen_tcp.send(socket, [
      "HTTP/1.1 200 OK\r\n",
      "Content-Type: text/html\r\n",
      "Connection: close\r\n\r\n",
      Auto2.Page.html()
    ])
  end

  defp send_bad_request(socket, reason) do
    :gen_tcp.send(socket, [
      "HTTP/1.1 400 Bad Request\r\n",
      "Content-Type: application/json\r\n",
      "Connection: close\r\n\r\n",
      "{\"error\":\"",
      reason,
      "\"}"
    ])
  end

  defp send_not_found(socket) do
    :gen_tcp.send(socket, [
      "HTTP/1.1 404 Not Found\r\n",
      "Content-Type: application/json\r\n",
      "Connection: close\r\n\r\n",
      "{\"error\":\"not_found\"}"
    ])
  end

  defp truncate_request(data) when is_binary(data) do
    if byte_size(data) > @max_request_bytes do
      <<head::binary-size(@max_request_bytes), _rest::binary>> = data
      head
    else
      data
    end
  end

  defp first_request_line(request) when is_binary(request) do
    take_until_crlf(request, <<>>)
  end

  defp take_until_crlf(<<"\r\n", _rest::binary>>, acc), do: acc

  defp take_until_crlf(<<byte, rest::binary>>, acc),
    do: take_until_crlf(rest, <<acc::binary, byte>>)

  defp take_until_crlf(<<>>, acc), do: acc

  defp starts_with_bin?(bin, prefix) when is_binary(bin) and is_binary(prefix) do
    prefix_size = byte_size(prefix)

    case bin do
      <<candidate::binary-size(prefix_size), _rest::binary>> -> candidate == prefix
      _ -> false
    end
  end

  defp contains_bin?(_bin, <<>>), do: true
  defp contains_bin?(<<>>, _fragment), do: false

  defp contains_bin?(bin, fragment) when is_binary(bin) and is_binary(fragment) do
    if starts_with_bin?(bin, fragment) do
      true
    else
      <<_byte, rest::binary>> = bin
      contains_bin?(rest, fragment)
    end
  end

  defp safe_network_stop do
    case :network.stop() do
      :ok -> :ok
      {:error, _} -> :ok
      _ -> :ok
    end
  end

  defp start_ap_and_wait do
    ap_config = build_ap_config()

    case wait_for_ap_safe(ap_config, @ap_timeout_ms) do
      :ok -> {:ok, "192.168.4.1"}
      {:error, reason} -> {:error, reason}
      other -> {:error, {:unexpected, other}}
    end
  end

  defp wait_for_ap_safe(ap_config, timeout_ms) do
    try do
      :network.wait_for_ap(ap_config, timeout_ms)
    catch
      :exit, reason -> {:error, {:network_exit, reason}}
      kind, reason -> {:error, {kind, reason}}
    end
  end

  defp build_ap_config do
    cond do
      @ap_ssid == "" -> [{:ssid, "Auto2"}]
      @ap_psk == "" -> [{:ssid, @ap_ssid}]
      true -> [{:ssid, @ap_ssid}, {:psk, @ap_psk}]
    end
  end

  defp idle_loop do
    :timer.sleep(5_000)
    idle_loop()
  end

  defp format_ip({a, b, c, d}), do: "#{a}.#{b}.#{c}.#{d}"
  defp format_ip(ip), do: inspect(ip)
end

defmodule Auto2.Page do
  def html do
    """
    <!DOCTYPE html><html><body style="text-align:center; background:#111; color:#fff;">
    <h1>Auto2 Controller</h1>
    <p>Use this page from any phone in the same WiFi network.</p>
    <button onclick="fetch('/cmd?move=forward')" style="height:100px; width:100px;">Forward</button><br>
    <button onclick="fetch('/cmd?move=left')" style="height:100px; width:100px;">Left</button>
    <button onclick="fetch('/cmd?move=stop')" style="height:100px; width:100px; background:red;">Stop</button>
    <button onclick="fetch('/cmd?move=right')" style="height:100px; width:100px;">Right</button><br>
    <button onclick="fetch('/cmd?move=backward')" style="height:100px; width:100px;">Backward</button>
    </body></html>
    """
  end
end
