defmodule Plymio.Fontais.Vekil do
  @moduledoc false

  use Plymio.Fontais.Attribute

  @type form :: Plymio.Fontais.form()
  @type forms :: Plymio.Fontais.forms()
  @type error :: Plymio.Fontais.error()

  import Plymio.Fontais.Error,
    only: [
      new_error_result: 1
    ]

  import Plymio.Fontais.Option,
    only: [
      opts_validate: 1,
      opts_fetch: 2
    ]

  import Plymio.Fontais.Utility,
    only: [
      validate_keys: 1
    ]

  import Plymio.Fontais.Form,
    only: [
      forms_validate: 1,
      forms_normalise: 1,
      forms_edit: 2
    ]

  import Plymio.Fontais.Funcio,
    only: [
      map_collate0_enum: 2
    ]

  @since "0.1.0"

  @spec normalise_vekil(any) :: {:ok, map} | {:error, error}

  def normalise_vekil(vekil)

  def normalise_vekil(vekil) do
    cond do
      is_map(vekil) -> vekil
      Keyword.keyword?(vekil) -> vekil |> Enum.into(%{})
      true -> vekil
    end
    |> validate_vekil
  end

  @since "0.1.0"

  @spec validate_vekil(any) :: {:ok, map} | {:error, error}

  def validate_vekil(vekil)

  def validate_vekil(vekil) when is_map(vekil) do
    with {:ok, _} <- vekil |> Map.keys() |> validate_keys,
         {:ok, _} <- vekil |> Map.values() |> forms_validate do
      {:ok, vekil}
    else
      {:error, %{__exception__: true} = error} ->
        new_error_result(m: "vekil invalid", v: error)
    end
  end

  def validate_vekil(vekil) do
    new_error_result(m: "vekil invalid", v: vekil)
  end

  @doc false

  @since "0.1.0"

  @spec create_vekil(any) :: {:ok, map} | {:error, error}

  def create_vekil(value) do
    value
    |> List.wrap()
    |> map_collate0_enum(fn
      v when is_atom(v) ->
        {:ok, apply(v, :__vekil__, [])}

      v when is_map(v) ->
        {:ok, v}

      v when is_list(v) ->
        case v |> Keyword.keyword?() do
          true ->
            {:ok, v |> Enum.into(%{})}

          _ ->
            new_error_result(m: "vekil invalid", v: v)
        end

      v ->
        new_error_result(m: "vekil invalid", v: v)
    end)
    |> case do
      {:error, %{__struct__: _}} = result ->
        result

      {:ok, dicts} ->
        dicts
        |> Enum.reverse()
        |> Enum.reduce(fn m, s -> Map.merge(s, m) end)
        |> validate_vekil
    end
  end

  @doc false

  @spec create_vekil!(any) :: map | no_return

  def create_vekil!(value) do
    with {:ok, dict} <- value |> create_vekil do
      dict
    else
      {:error, error} -> raise error
    end
  end

  @since "0.1.0"

  @spec fetch_proxies(any, any) :: {:ok, forms} | {:error, error}

  defp fetch_proxies(proxies, vekil)

  defp fetch_proxies(proxies, vekil) when is_map(vekil) do
    proxies
    |> List.wrap()
    |> map_collate0_enum(fn
      {_, _, _} = ast ->
        {:ok, ast}

      proxy ->
        vekil
        |> Map.fetch(proxy)
        |> case do
          {:ok, form} ->
            form
            |> case do
              {_, _, _} = ast -> {:ok, ast}
              _ -> form |> fetch_proxies(vekil)
            end

          _ ->
            new_error_result(m: "proxy invalid", v: proxy)
        end
    end)
    |> case do
      {:error, %{__struct__: _}} = result -> result
      {:ok, forms} -> forms |> forms_normalise
    end
  end

  @doc false

  @since "0.1.0"

  @spec produce_proxies(any, any) :: {:ok, forms} | {:error, error}

  def produce_proxies(proxies, opts \\ [])

  def produce_proxies(proxies, opts) when is_list(opts) do
    with {:ok, opts} <- opts |> opts_validate,
         {:ok, vekil} <- opts |> opts_fetch(@plymio_fontais_key_vekil),
         {:ok, forms} <- proxies |> fetch_proxies(vekil),
         {:ok, _forms} = result <-
           forms
           |> forms_edit(opts |> Keyword.take(@plymio_fontais_form_edit_keys)),
         true <- true do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  @doc false

  @since "0.1.0"

  defmacro reify_proxies(proxies, opts \\ []) do
    quote bind_quoted: [proxies: proxies, opts: opts] do
      with {:ok, forms} <- proxies |> Plymio.Fontais.Vekil.produce_proxies(opts) do
        forms
        |> Code.eval_quoted([], __ENV__)
      else
        {:error, %{__exception__: true} = error} -> raise error
      end
    end
  end
end
