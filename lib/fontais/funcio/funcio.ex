defmodule Plymio.Fontais.Funcio do
  @moduledoc false

  # use Plymio.Fontais.Attribute

  @type error :: Plymio.Fontais.error()
  @type fun1_map :: Plymio.Fontais.fun1_map()

  import Plymio.Fontais.Error,
    only: [
      new_error_result: 1
      # new_argument_error_result: 1,
    ]

  import Plymio.Fontais.Utility,
    only: [
      list_wrap_flat_just: 1
    ]

  @doc false

  @since "0.1.0"

  @spec map_collate0_enum(any, any) :: {:ok, list} | {:error, error}

  def map_collate0_enum(enum, fun) when is_function(fun, 1) do
    try do
      enum
      |> Enum.reduce_while([], fn value, values ->
        value
        |> fun.()
        |> case do
          {:error, %{__struct__: _}} = result -> {:halt, result}
          {:ok, value} -> {:cont, [value | values]}
          value -> {:halt, new_error_result(m: "pattern0 result invalid", v: value)}
        end
      end)
      |> case do
        {:error, %{__exception__: true}} = result -> result
        values -> {:ok, values |> Enum.reverse()}
      end
    rescue
      _ ->
        new_error_result(m: "enum invalid", v: enum)
    end
  end

  def map_collate0_enum(_enum, fun) do
    new_error_result(m: "fun/1 invalid", v: fun)
  end

  @doc false

  @since "0.1.0"

  @spec reduce_or_nil_map1_funs(any) :: {:ok, fun1_map} | {:ok, nil} | {:error, error}

  def reduce_or_nil_map1_funs(funs) do
    funs
    |> list_wrap_flat_just
    |> case do
      [] ->
        {:ok, nil}

      [fun] ->
        {:ok, fun}

      funs ->
        fun = fn v -> funs |> Enum.reduce(v, fn f, s -> f.(s) end) end

        {:ok, fun}
    end
  end
end
