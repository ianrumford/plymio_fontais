defmodule Plymio.Fontais.Error.Format do
  @moduledoc false

  use Plymio.Fontais.Attribute

  import Plymio.Fontais.Guard,
    only: [
      is_value_set: 1
    ]

  import Plymio.Fontais.Error.Utility,
    only: [
      opts_normalise: 1
    ]

  def format_error_message_merge_values(values, joiner \\ ", ")

  def format_error_message_merge_values(values, sep)
      when is_binary(sep) do
    message =
      values
      |> List.wrap()
      |> Stream.reject(&is_nil/1)
      |> Enum.join(sep)

    {:ok, message}
  end

  def format_error_message_merge_values(values, joiner)
      when is_function(joiner) do
    values
    |> List.wrap()
    |> Stream.reject(&is_nil/1)
    |> joiner.()
    |> format_error_message_binary
  end

  def format_error_message_binary(value) when is_binary(value) do
    {:ok, value |> String.replace("\n", "") |> String.trim(" ")}
  end

  def format_error_message_value(value)

  def format_error_message_value(value) when is_binary(value) do
    value |> format_error_message_binary
  end

  def format_error_message_value(%Macro.Env{} = value) do
    value
    |> Macro.Env.stacktrace()
    |> Exception.format_stacktrace()
    |> format_error_message_binary
  end

  def format_error_message_value(values) when is_list(values) do
    texts =
      values
      |> Enum.map(fn
        # stop small integers being treated as chars
        value when is_integer(value) ->
          value |> to_string

        value ->
          value |> inspect
      end)
      |> Enum.join(", ")

    text = "[#{texts}]"

    {:ok, text}
  end

  def format_error_message_value(value) do
    cond do
      Exception.exception?(value) ->
        value |> Exception.message()

      # just a regular value
      true ->
        value |> inspect
    end
    |> format_error_message_binary
  end

  def format_error_message_no_prefix_kv({_k, v}) do
    v |> format_error_message_value
  end

  def format_error_message_prefix_kv({k, v}) do
    with {:ok, v_msg} <- v |> format_error_message_value do
      {:ok, "#{to_string(k)}=#{v_msg}"}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def format_error_message_opts(opts) do
    with {:ok, opts} <- opts |> opts_normalise do
      opts
      |> Stream.filter(fn {_k, v} -> is_value_set(v) end)
      |> Enum.reduce_while([], fn
        {@plymio_fontais_error_field_value, v}, texts ->
          with {:ok, text} <- v |> format_error_message_value do
            texts
            |> case do
              # no prior texts
              [] ->
                {:cont, [text]}

              # prior texts - add the "got: "
              texts ->
                {:cont, ["got: #{text}" | texts]}
            end
          else
            {:error, %{__struct__: _}} = result -> {:halt, result}
          end

        {k, v}, texts when k in [@plymio_fontais_error_field_message] ->
          with {:ok, text} <- {k, v} |> format_error_message_no_prefix_kv do
            {:cont, [text | texts]}
          else
            {:error, %{__struct__: _}} = result -> {:halt, result}
          end

        {k, v}, texts ->
          with {:ok, text} <- {k, v} |> format_error_message_prefix_kv do
            {:cont, [text | texts]}
          else
            {:error, %{__struct__: _}} = result -> {:halt, result}
          end
      end)
      |> case do
        {:error, %{__exception__: true}} = result ->
          result

        texts ->
          texts |> Enum.reverse() |> format_error_message_merge_values
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end
end
