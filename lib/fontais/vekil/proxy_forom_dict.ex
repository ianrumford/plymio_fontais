defmodule Plymio.Fontais.Vekil.ProxyForomDict do
  # a vekil dictionary where the proxies are atoms and the forom quoted forms
  # i.e. the dictionary used by Plymio.Vekil.Form
  # has functions that mirror the Plymio.Fontais.Vekil protocol but does *not*
  # implement the protocol

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

  import Plymio.Fontais.Form,
    only: [
      forms_normalise: 1,
      forms_edit: 2
    ]

  import Plymio.Fontais.Funcio,
    only: [
      map_collate0_enum: 2,
      map_gather0_enum: 2
    ]

  @doc false

  @since "0.1.0"

  defdelegate normalise_proxies(proxies), to: Plymio.Fontais.Utility, as: :normalise_keys

  @doc false

  @since "0.1.0"

  defdelegate validate_proxy(proxy), to: Plymio.Fontais.Utility, as: :validate_key

  @doc false

  @since "0.1.0"

  defdelegate validate_proxies(proxies), to: Plymio.Fontais.Utility, as: :validate_keys

  @since "0.1.0"

  @spec normalise_proxy_forom_dict(any) :: {:ok, map} | {:error, error}

  defp normalise_proxy_forom_dict(vekil)

  defp normalise_proxy_forom_dict(vekil) do
    cond do
      is_map(vekil) -> vekil
      Keyword.keyword?(vekil) -> vekil |> Enum.into(%{})
      true -> vekil
    end
    |> validate_proxy_forom_dict
  end

  @since "0.1.0"

  @spec validate_proxy_forom_dict(any) :: {:ok, map} | {:error, error}

  def validate_proxy_forom_dict(vekil)

  def validate_proxy_forom_dict(vekil) when is_map(vekil) do
    with {:ok, _} <- vekil |> Map.keys() |> validate_proxies do
      {:ok, vekil}
    else
      {:error, %{__exception__: true} = error} ->
        new_error_result(m: "vekil invalid", v: error)
    end
  end

  def validate_proxy_forom_dict(vekil) do
    new_error_result(m: "vekil invalid", v: vekil)
  end

  @doc false

  @spec validate_proxy_forom_dict!(any) :: map | no_return

  def validate_proxy_forom_dict!(value) do
    with {:ok, dict} <- value |> validate_proxy_forom_dict do
      dict
    else
      {:error, error} -> raise error
    end
  end

  @since "0.1.0"

  @spec transform_proxy_forom_dict(any) :: {:ok, map} | {:error, error}

  def transform_proxy_forom_dict(vekil, opts \\ [])

  def transform_proxy_forom_dict(vekil, []) do
    vekil |> validate_proxy_forom_dict
  end

  def transform_proxy_forom_dict(vekil, opts) do
    with {:ok, vekil} <- vekil |> validate_proxy_forom_dict,
         {:ok, opts} <- opts |> opts_validate do
      opts
      |> Enum.reduce_while(vekil, fn
        {:transform_k = _verb, fun}, vekil when is_function(fun, 1) ->
          {:cont, vekil |> Enum.map(fn {k, v} -> {k |> fun.(), v} end)}

        {:transform_v = _verb, fun}, vekil when is_function(fun, 1) ->
          {:cont, vekil |> Enum.map(fn {k, v} -> {k, v |> fun.()} end)}

        {:transform_kv = _verb, fun}, vekil when is_function(fun, 1) ->
          {:cont, vekil |> Enum.map(fn kv -> kv |> fun.() end)}

        x, _vekil ->
          {:halt, new_error_result(m: "vekil transform invalid", v: x)}
      end)
      |> case do
        {:error, %{__struct__: _}} = result -> result
        vekil -> vekil |> normalise_proxy_forom_dict
      end
    else
      {:error, %{__struct__: _}} = result -> result
    end
  end

  @doc false

  @since "0.1.0"

  @spec create_proxy_forom_dict(any) :: {:ok, map} | {:error, error}

  def create_proxy_forom_dict(value) do
    cond do
      Keyword.keyword?(value) -> [value]
      true -> value |> List.wrap()
    end
    |> map_collate0_enum(fn
      v when is_atom(v) ->
        {:ok, apply(v, :__vekil__, [])}

      v ->
        {:ok, v}
    end)
    |> case do
      {:error, %{__struct__: _}} = result ->
        result

      {:ok, dicts} ->
        dicts
        |> map_collate0_enum(fn
          %{__struct__: _} = v ->
            v
            |> Map.get(@plymio_fontais_key_dict)
            |> case do
              x when is_map(x) ->
                {:ok, x}

              x ->
                new_error_result(m: "struct dict invalid", v: x)
            end

          v when is_map(v) ->
            {:ok, v}

          v when is_list(v) ->
            case v |> Keyword.keyword?() do
              true ->
                {:ok, v |> Enum.into(%{})}

              _ ->
                new_error_result(m: "proxy forom dict invalid", v: v)
            end

          v ->
            new_error_result(m: "proxy forom dict", v: v)
        end)
    end
    |> case do
      {:error, %{__struct__: _}} = result ->
        result

      {:ok, dicts} ->
        dicts
        |> Enum.reduce(%{}, fn m, s -> Map.merge(s, m) end)
        |> validate_proxy_forom_dict
    end
  end

  @doc false

  @spec create_proxy_forom_dict!(any) :: map | no_return

  def create_proxy_forom_dict!(value) do
    with {:ok, dict} <- value |> create_proxy_forom_dict do
      dict
    else
      {:error, error} -> raise error
    end
  end

  defp reduce_gather_opts(gather_opts) do
    with {:ok, gather_opts} <- gather_opts |> Plymio.Fontais.Option.opts_validate() do
      gather_opts
      |> Plymio.Fontais.Funcio.gather_opts_error_get()
      |> case do
        {:ok, []} ->
          gather_opts |> Plymio.Fontais.Funcio.gather_opts_ok_get()

        {:ok, error_tuples} ->
          error_tuples
          |> case do
            [{_proxy, error}] -> {:error, error}
            tuples -> new_error_result(m: "proxies invalid", v: tuples |> Keyword.keys())
          end
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  @since "0.1.0"

  defp resolve_forom_in_proxy_forom_dict(proxy_forom_dict, forom, seen_proxies)

  defp resolve_forom_in_proxy_forom_dict(_proxy_forom_dict, nil, _seen_proxies) do
    {:ok, nil}
  end

  # must be a proxy
  defp resolve_forom_in_proxy_forom_dict(proxy_forom_dict, forom, seen_proxies)
       when is_atom(forom) do
    proxy_forom_dict |> resolve_proxy_in_proxy_forom_dict(forom, seen_proxies)
  end

  defp resolve_forom_in_proxy_forom_dict(proxy_forom_dict, forom, seen_proxies)
       when is_list(forom) do
    forom
    |> map_collate0_enum(fn value ->
      proxy_forom_dict |> resolve_forom_in_proxy_forom_dict(value, seen_proxies)
    end)
  end

  # must be a proxy
  defp resolve_forom_in_proxy_forom_dict(_proxy_forom_dict, forom, _seen_proxies) do
    {:ok, forom}
  end

  @since "0.2.0"

  defp resolve_proxy_in_proxy_forom_dict(proxy_forom_dict, proxy, seen_proxies)

  defp resolve_proxy_in_proxy_forom_dict(proxy_forom_dict, proxy, seen_proxies)
       when is_map(proxy_forom_dict) and is_atom(proxy) do
    seen_proxies
    |> Map.has_key?(proxy)
    |> case do
      true ->
        new_error_result(m: "proxy seen before", v: proxy)

      _ ->
        proxy_forom_dict
        |> Map.fetch(proxy)
        |> case do
          {:ok, forom} ->
            # mark seen
            seen_proxies = seen_proxies |> Map.put(proxy, nil)

            with {:ok, form} <-
                   proxy_forom_dict |> resolve_forom_in_proxy_forom_dict(forom, seen_proxies) do
              {:ok, form}
            else
              {:error, %{__exception__: true}} = result -> result
            end

          _ ->
            new_error_result(m: "proxy invalid", v: proxy)
        end
    end
  end

  @doc false

  @since "0.2.0"

  @spec resolve_proxies(any, any) :: {:ok, forms} | {:error, error}

  def resolve_proxies(proxy_forom_dict, proxies) do
    with {:ok, proxy_forom_dict} <- proxy_forom_dict |> validate_proxy_forom_dict,
         true <- true do
      proxies
      |> List.wrap()
      |> map_gather0_enum(fn
        proxy when is_atom(proxy) ->
          proxy_forom_dict |> resolve_proxy_in_proxy_forom_dict(proxy, %{})

        value ->
          # must be a form
          {:ok, value}
      end)
      |> case do
        {:error, %{__struct__: _}} = result ->
          result

        {:ok, gather_opts} ->
          gather_opts
          |> reduce_gather_opts
          |> case do
            {:error, %{__struct__: _}} = result ->
              result

            {:ok, ok_tuples} ->
              {:ok, ok_tuples}
          end
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  @doc false

  @since "0.1.0"

  @spec produce_proxies(any, any) :: {:ok, forms} | {:error, error}

  def produce_proxies(proxies, opts \\ [])

  def produce_proxies(proxies, opts) when is_list(opts) do
    with {:ok, opts} <- opts |> opts_validate,
         {:ok, vekil} <- opts |> opts_fetch(@plymio_fontais_key_dict),
         {:ok, tuples} <- vekil |> resolve_proxies(proxies),
         forms <- tuples |> Keyword.values(),
         {:ok, forms} <- forms |> forms_normalise,
         {:ok, _forms} = result <-
           forms
           |> forms_edit(opts |> Keyword.get(@plymio_fontais_key_forms_edit, [])) do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  @doc false

  @since "0.1.0"

  defmacro reify_proxies(proxies, opts \\ []) do
    quote bind_quoted: [proxies: proxies, opts: opts] do
      with {:ok, forms} <- proxies |> Plymio.Fontais.Vekil.ProxyForomDict.produce_proxies(opts) do
        forms
        |> Code.eval_quoted([], __ENV__)
      else
        {:error, %{__exception__: true} = error} -> raise error
      end
    end
  end
end
