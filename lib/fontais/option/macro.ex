defmodule Plymio.Fontais.Option.Macro do
  @moduledoc ~S"""
  Macros for Custom Option ("opts") Accessors and Mutators.

  See `Plymio.Fontais` for overview and documentation terms.

  These macros define custom versions of a small set of functions from `Plymio.Fontais.Option` such as `Plymio.Fontais.Option.opts_get/3`

  The customisation hardcode ("curries") arguments such as the `key` and `default`.
  """

  use Plymio.Fontais.Attribute

  defmacro def_custom_opts_get(opts \\ []) do
    quote bind_quoted: [opts: opts] do
      for {fun_name, fun_spec} <- opts do
        fun_spec =
          fun_spec
          |> case do
            x when is_atom(x) -> %{key: x}
            x when is_map(x) -> x
          end

        fun_key = fun_spec |> Map.fetch!(:key)
        fun_default = fun_spec |> Map.get(:default)

        def unquote(fun_name)(opts, default \\ unquote(fun_default))

        def unquote(fun_name)(opts, default) do
          opts_get(opts, unquote(fun_key), default)
        end
      end
    end
  end

  defmacro def_custom_opts_get_values(opts \\ []) do
    quote bind_quoted: [opts: opts] do
      for {fun_name, fun_spec} <- opts do
        fun_spec =
          fun_spec
          |> case do
            x when is_atom(x) -> %{key: x}
            x when is_map(x) -> x
          end

        fun_key = fun_spec |> Map.fetch!(:key)
        fun_default = fun_spec |> Map.get(:default)

        def unquote(fun_name)(opts, default \\ unquote(fun_default))

        def unquote(fun_name)(opts, default) do
          opts_get_values(opts, unquote(fun_key), default)
        end
      end
    end
  end

  defmacro def_custom_opts_fetch(opts \\ []) do
    quote bind_quoted: [opts: opts] do
      for {fun_name, fun_key} <- opts do
        def unquote(fun_name)(opts) do
          opts_fetch(opts, unquote(fun_key))
        end
      end
    end
  end

  defmacro def_custom_opts_put(opts \\ []) do
    quote bind_quoted: [opts: opts] do
      for {fun_name, fun_key} <- opts do
        def unquote(fun_name)(opts, value) do
          opts_put(opts, unquote(fun_key), value)
        end
      end
    end
  end

  defmacro def_custom_opts_put_value(opts \\ []) do
    quote bind_quoted: [opts: opts] do
      for {fun_name, fun_spec} <- opts do
        fun_key = fun_spec |> Map.fetch!(:key)
        fun_value = fun_spec |> Map.fetch!(:value)

        def unquote(fun_name)(opts) do
          opts_put(opts, unquote(fun_key), unquote(fun_value))
        end
      end
    end
  end

  defmacro def_custom_opts_delete(opts \\ []) do
    quote bind_quoted: [opts: opts] do
      for {fun_name, fun_key} <- opts do
        def unquote(fun_name)(opts) do
          opts_delete(opts, unquote(fun_key), value)
        end
      end
    end
  end

  defmacro def_custom_opts_drop(opts \\ []) do
    quote bind_quoted: [opts: opts] do
      for {fun_name, fun_key} <- opts do
        fun_key =
          fun_key
          |> List.wrap()
          |> Enum.uniq()

        def unquote(fun_name)(opts) do
          opts_drop(opts, unquote(fun_key))
        end
      end
    end
  end

  defmacro def_custom_opts_has_key?(opts \\ []) do
    quote bind_quoted: [opts: opts] do
      for {fun_name, fun_key} <- opts do
        def unquote(fun_name)(opts) do
          opts
          |> Keyword.keyword?()
          |> case do
            true -> opts |> Keyword.has_key?(unquote(fun_key))
            _ -> false
          end
        end
      end
    end
  end
end
