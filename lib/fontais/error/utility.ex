defmodule Plymio.Fontais.Error.Utility do
  @moduledoc false

  use Plymio.Fontais.Attribute

  # error copy to pre-empt dependency on Plymio.Fontais.Option

  @doc false

  def opts_normalise(value) do
    cond do
      Keyword.keyword?(value) ->
        {:ok, value}

      is_map(value) ->
        opts = value |> Map.to_list()

        opts
        |> Keyword.keyword?()
        |> case do
          true ->
            {:ok, opts}

          _ ->
            {:error,
             %ArgumentError{
               message:
                 "#{@plymio_fontais_error_message_opts_not_derivable}, got: #{inspect(value)}"
             }}
        end

      true ->
        {:error,
         %ArgumentError{
           message: "#{@plymio_fontais_error_message_opts_not_derivable}, got: #{inspect(value)}"
         }}
    end
  end

  def update_canonical_opts(opts \\ []) do
    with {:ok, opts} <- opts |> opts_normalise do
      # no aliases so hardcoded
      opts =
        opts
        |> Enum.map(fn
          {k, v}
          when k in [
                 :m,
                 :msg
               ] ->
            {@plymio_fontais_error_key_message, v}

          {k, v}
          when k in [
                 :v,
                 :e,
                 :error
               ] ->
            {@plymio_fontais_error_key_value, v}

          {k, v}
          when k in [
                 :r
               ] ->
            {@plymio_fontais_error_key_reason, v}

          # passthru
          x ->
            x
        end)

      {:ok, opts}
    else
      {:error, %{__struct__: _}} = result -> result
    end
  end

  @doc false

  def validate_error(error)

  def validate_error(%{:__struct__ => _} = error) do
    error
    |> Exception.exception?()
    |> case do
      true ->
        {:ok, error}

      _ ->
        {:error, %ArgumentError{message: "error invalid, got: #{inspect(error)}"}}
    end
  end

  def validate_error(error) do
    {:error, %ArgumentError{message: "error invalid, got: #{inspect(error)}"}}
  end

  @doc false

  def validate_errors(errors)

  def validate_errors(errors) when is_list(errors) do
    errors
    |> Enum.reduce_while([], fn error, not_errors ->
      with {:ok, _} <- error |> validate_error do
        {:cont, not_errors}
      else
        _ -> {:halt, [error | not_errors]}
      end
    end)
    |> case do
      # all errors?
      [] ->
        {:ok, errors}

      not_errors ->
        {:error,
         %ArgumentError{message: "errors invalid, got: #{inspect(Enum.reverse(not_errors))}"}}
    end
  end

  def validate_errors(errors) do
    {:error, %ArgumentError{message: "errors invalid, got: #{inspect(errors)}"}}
  end

  @doc false

  def reduce_errors_default_function(errors)

  def reduce_errors_default_function(errors) do
    with {:ok, errors} <- errors |> List.wrap() |> validate_errors do
      errors
      |> length
      |> case do
        0 ->
          {:error, %ArgumentError{message: "errorss invalid, got: none"}}

        1 ->
          {:ok, errors |> hd}

        _ ->
          errors_text =
            errors
            |> Enum.map(&Exception.message/1)
            |> Enum.join("; ")

          {:ok, %RuntimeError{message: "multiple errors, got: #{errors_text}"}}
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end
end
