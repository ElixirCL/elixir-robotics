defmodule Tic80 do
  @led_duty 1000
  @rgb_duty 4000

  @high_speed_timer 0

  @led_r 22
  @led_g 21
  @led_b 23

  @button_1_pin 26
  @button_2_pin 25
  @potentiometer_pin 32

  def start do
    rgb_channels = setup_leds()
    setup_input(rgb_channels)

    LEDC.set_duty(LEDC.high_speed_mode(), 0, @led_duty)
    LEDC.update_duty(LEDC.high_speed_mode(), 0)

    spawn(fn -> button_monitor(@button_1_pin, "Button 1") end)
    spawn(fn -> button_monitor(@button_2_pin, "Button 2") end)
    spawn(fn -> potentiometer_monitor(@potentiometer_pin) end)

    Process.sleep(:infinity)
  end

  defp setup_leds() do
    ledc_hs_timer = [
      {:duty_resolution, 13},
      {:freq_hz, 5000},
      {:speed_mode, LEDC.high_speed_mode()},
      {:timer_num, @high_speed_timer}
    ]

    :ok = LEDC.timer_config(ledc_hs_timer)

    ledc_channel = [
      [
        {:channel, 1},
        {:duty, 0},
        {:gpio_num, @led_r},
        {:speed_mode, LEDC.high_speed_mode()},
        {:hpoint, 0},
        {:timer_sel, @high_speed_timer}
      ],
      [
        {:channel, 2},
        {:duty, 0},
        {:gpio_num, @led_g},
        {:speed_mode, LEDC.high_speed_mode()},
        {:hpoint, 0},
        {:timer_sel, @high_speed_timer}
      ],
      [
        {:channel, 3},
        {:duty, 0},
        {:gpio_num, @led_b},
        {:speed_mode, LEDC.high_speed_mode()},
        {:hpoint, 0},
        {:timer_sel, @high_speed_timer}
      ]
    ]

    Enum.each(ledc_channel, fn channel_config -> :ok = LEDC.channel_config(channel_config) end)
    :ok = LEDC.fade_func_install(0)

    %{
      red: Enum.at(ledc_channel, 0),
      green: Enum.at(ledc_channel, 1),
      blue: Enum.at(ledc_channel, 2)
    }
  end

  defp button_monitor(pin, name) do
    GPIO.set_pin_mode(pin, :input)
    GPIO.set_pin_pull(pin, :up)
    button_loop(pin, name, :released)
  end

  defp button_loop(pin, name, last_state) do
    current_state =
      case GPIO.digital_read(pin) do
        :low -> :pressed
        :high -> :released
      end

    if current_state != last_state do
      :io.format('~s: ~s~n', [name, current_state])
      Process.sleep(50)
      button_loop(pin, name, current_state)
    else
      Process.sleep(100)
      button_loop(pin, name, last_state)
    end
  end

  defp potentiometer_monitor(pin) do
    :ok = :esp_adc.start(pin, bitwidth: :bit_max, atten: :db_12)
    pot_loop(pin, nil, nil)
  end

  defp pot_loop(pin, last_raw, last_mv) do
    case :esp_adc.read(pin, [:raw, :voltage, samples: 48]) do
      {:ok, {raw, mv}} ->
        if last_raw == nil || abs(raw - last_raw) > 50 do
          :io.format('Potentiometer: raw=~p mv=~p~n', [raw, mv])
          Process.sleep(200)
          pot_loop(pin, raw, mv)
        else
          Process.sleep(200)
          pot_loop(pin, last_raw, last_mv)
        end

      error ->
        :io.format('ADC error: ~p~n', [error])
        Process.sleep(500)
        pot_loop(pin, last_raw, last_mv)
    end
  end

  defp setup_input(rgb_channels) do
    uart = :uart.open("UART0", rx: 3, tx: 1, speed: 115_200)
    :io.format('UART0 opened successfully. Sending and receiving on ~p~n', [uart])
    spawn(fn -> loop_read(uart, rgb_channels) end)
  end

  defp loop_read(uart, rgb_channels) do
    data = :uart.read(uart)

    case data do
      '' ->
        Process.sleep(50)

      {:ok, string} ->
        :io.format('Received: ~p~n', [string])

        process_command(string, rgb_channels)
    end

    loop_read(uart, rgb_channels)
  end

  defp process_command(<<"red">>, %{red: red_channel}) do
    apply_duty(red_channel, @rgb_duty)
    Process.sleep(1000)
    apply_duty(red_channel, 0)
  end

  defp process_command(<<"green">>, %{green: green_channel}) do
    apply_duty(green_channel, @rgb_duty)
    Process.sleep(1000)
    apply_duty(green_channel, 0)
  end

  defp process_command(<<"blue">>, %{blue: blue_channel}) do
    apply_duty(blue_channel, @rgb_duty)
    Process.sleep(1000)
    apply_duty(blue_channel, 0)
  end

  defp process_command(_, _), do: :io.format('Invalid input.~n')

  defp apply_duty(channel_config, duty) do
    speed_mode = :proplists.get_value(:speed_mode, channel_config)
    channel = :proplists.get_value(:channel, channel_config)
    :ok = LEDC.set_duty(speed_mode, channel, duty)
    :ok = LEDC.update_duty(speed_mode, channel)
  end
end
