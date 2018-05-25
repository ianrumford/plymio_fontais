defmodule Plymio.Fontais.Funcio do
  @moduledoc false

  require Plymio.Fontais.Option.Macro, as: PFOM
  # use Plymio.Fontais.Attribute

  @type opts :: Plymio.Fontais.opts()
  @type error :: Plymio.Fontais.error()
  @type fun1_map :: Plymio.Fontais.fun1_map()

  import Plymio.Fontais.Error,
    only: [
      new_error_result: 1
    ]

  import Plymio.Fontais.Utility,
    only: [
      list_wrap_flat_just: 1
    ]

  import Plymio.Fontais.Option,
    only: [
      opts_get: 3,
      opts_fetch: 2
    ]

  @doc false

  @since "0.1.0"

  @spec map_collate0_enum(any, any) :: {:ok, list} | {:error, error}

  def map_collate0_enum(enum, fun) when is_function(fun, 1) do
    try do
      enum
      |> Enum.reduce_while(
        [],
        fn value, values ->
          value
          |> fun.()
          |> case do
            {:error, %{__struct__: _}} = result -> {:halt, result}
            {:ok, value} -> {:cont, [value | values]}
            value -> {:halt, new_error_result(m: "pattern0 result invalid", v: value)}
          end
        end
      )
      |> case do
        {:error, %{__exception__: true}} = result -> result
        values -> {:ok, values |> Enum.reverse()}
      end
    rescue
      error -> {:error, error}
    end
  end

  def map_collate0_enum(_enum, fun) do
    new_error_result(m: "fun/1 invalid", v: fun)
  end

  @doc false

  @since "0.1.0"

  @spec map_gather0_enum(any, any) :: {:ok, opts} | {:error, error}

  def map_gather0_enum(enum, fun) when is_function(fun, 1) do
    try do
      enum
      |> Enum.reduce_while(
        {[], []},
        fn element, {oks, errors} ->
          element
          |> fun.()
          |> case do
            {:error, %{__struct__: _} = error} ->
              {:cont, {oks, [{element, error} | errors]}}

            {:ok, value} ->
              {:cont, {[{element, value} | oks], errors}}

            value ->
              with {:error, error} <- new_error_result(m: "pattern0 result invalid", v: value) do
                {:cont, {oks, [{element, error} | errors]}}
              else
                {:error, %{__struct__: _}} = result -> {:halt, result}
              end
          end
        end
      )
      |> case do
        {:error, %{__exception__: true}} = result -> result
        {oks, []} -> {:ok, [ok: oks |> Enum.reverse()]}
        {[], errors} -> {:ok, [error: errors |> Enum.reverse()]}
        {oks, errors} -> {:ok, [ok: oks |> Enum.reverse(), error: errors |> Enum.reverse()]}
      end
    rescue
      error ->
        {:error, error}
    end
  end

  def map_gather0_enum(_enum, fun) do
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

  [
    gather_opts_ok_get: %{key: :ok, default: []},
    gather_opts_error_get: %{key: :error, default: []}
  ]
  |> PFOM.def_custom_opts_get()

  [
    gather_opts_ok_fetch: :ok,
    gather_opts_error_fetch: :error
  ]
  |> PFOM.def_custom_opts_fetch()

  [
    gather_opts_has_ok?: :ok,
    gather_opts_has_error?: :error
  ]
  |> PFOM.def_custom_opts_has_key?()

  def gather_opts_ok_length(opts) do
    with {:ok, ok_tuples} <- opts |> gather_opts_ok_get do
      ok_tuples |> length
    else
      {:error, %{__exception__: true}} -> 0
    end
  end

  def gather_opts_ok_keys_get(opts, default \\ []) do
    with {:ok, ok_tuples} <- opts |> gather_opts_ok_get(default) do
      {:ok, ok_tuples |> Enum.unzip() |> elem(0)}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def gather_opts_ok_values_get(opts, default \\ []) do
    with {:ok, ok_tuples} <- opts |> gather_opts_ok_get(default) do
      {:ok, ok_tuples |> Enum.unzip() |> elem(1)}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def gather_opts_ok_keys_fetch(opts) do
    with {:ok, ok_tuples} <- opts |> gather_opts_ok_fetch do
      {:ok, ok_tuples |> Enum.unzip() |> elem(0)}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def gather_opts_ok_values_fetch(opts) do
    with {:ok, ok_tuples} <- opts |> gather_opts_ok_fetch do
      {:ok, ok_tuples |> Enum.unzip() |> elem(1)}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def gather_opts_error_length(opts) do
    with {:ok, error_tuples} <- opts |> gather_opts_error_get do
      error_tuples |> length
    else
      {:error, %{__exception__: true}} -> 0
    end
  end

  def gather_opts_error_keys_get(opts, default \\ []) do
    with {:ok, error_tuples} <- opts |> gather_opts_error_get(default) do
      {:ok, error_tuples |> Enum.unzip() |> elem(0)}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def gather_opts_error_values_get(opts, default \\ []) do
    with {:ok, error_tuples} <- opts |> gather_opts_error_get(default) do
      {:ok, error_tuples |> Enum.unzip() |> elem(1)}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def gather_opts_error_keys_fetch(opts) do
    with {:ok, error_tuples} <- opts |> gather_opts_error_fetch do
      {:ok, error_tuples |> Enum.unzip() |> elem(0)}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def gather_opts_error_values_fetch(opts) do
    with {:ok, error_tuples} <- opts |> gather_opts_error_fetch do
      {:ok, error_tuples |> Enum.unzip() |> elem(1)}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end
end
