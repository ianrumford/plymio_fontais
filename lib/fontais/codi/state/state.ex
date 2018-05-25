defmodule Plymio.Fontais.Codi.State do
  @moduledoc false

  # note: all the keys are prefixed with 'state_'
  @vekil %{
    state_def_new_doc:
      quote do
        @doc ~S"""
        `new/1` creates a new instance of the module's `struct` and, if the optional
         *opts* were given, calls `update/2` with the instance and the *opts*,
        returning `{:ok, instance}`, else `{:error, error}`.
        """
      end,
    state_def_new_since: nil,
    state_def_new_spec:
      quote do
        @spec new(any) :: {:ok, t} | {:error, error}
      end,
    state_def_new_header:
      quote do
        def new(opts \\ [])
      end,
    state_def_new_clause_arg0_t:
      quote do
        def new(%__MODULE__{} = value) do
          {:ok, value}
        end
      end,
    state_def_new_clause_arg0_l0:
      quote do
        def new([]) do
          {:ok, %__MODULE__{}}
        end
      end,
    state_def_new_clause_arg0_any:
      quote do
        def new(opts) do
          with {:ok, %__MODULE__{} = state} <- new() do
            state |> update(opts)
          else
            {:error, %{__exception__: true}} = result -> result
          end
        end
      end,
    state_def_new: [
      :state_def_new_doc,
      :state_def_new_since,
      :state_def_new_spec,
      :state_def_new_header,
      :state_def_new_clause_arg0_t,
      :state_def_new_clause_arg0_l0,
      :state_def_new_clause_arg0_any
    ],
    state_def_new_doc!:
      quote do
        @doc ~S"""
        `new!/1` calls`new/1` and, if the result is `{:ok, instance}` returns the `instance.
        """
      end,
    state_def_new_since!: nil,
    state_def_new_spec!:
      quote do
        @spec new!(any) :: t | no_return
      end,
    state_def_new_header!:
      quote do
        def new!(opts \\ [])
      end,
    state_def_new_clause_arg0_any!:
      quote do
        def new!(opts) do
          opts
          |> new()
          |> case do
            {:ok, %__MODULE__{} = state} -> state
            {:error, error} -> raise error
          end
        end
      end,
    state_def_new!: [
      :state_def_new_doc!,
      :state_def_new_since!,
      :state_def_new_spec!,
      :state_def_new_header!,
      :state_def_new_clause_arg0_any!
    ],
    state_def_update_doc:
      quote do
        @doc ~S"""
        `update/2` takes an `instance` of the module's `struct` and an optional *opts*.

        The *opts* are normalised by calling the module's `update_canonical_opts/1`
        and then reduced with `update_field/2`:

           opts |> Enum.reduce(instance, fn {k,v}, s -> s |> update_field({k,v}) end)

        `{:ok, instance}` is returned.
        """
      end,
    state_def_update_since: nil,
    state_def_update_spec:
      quote do
        @spec update(t, opts) :: {:ok, t} | {:error, error}
      end,
    state_def_update_header:
      quote do
        def update(t, opts \\ [])
      end,
    state_def_update_clause_arg0_t_arg1_l0:
      quote do
        def update(%__MODULE__{} = state, []) do
          {:ok, state}
        end
      end,
    state_def_update_clause_arg0_t_arg1_any:
      quote do
        def update(%__MODULE__{} = state, opts) do
          with {:ok, opts} <- opts |> update_canonical_opts do
            opts
            |> Enum.reduce_while(state, fn {k, v}, s ->
              s
              |> update_field({k, v})
              |> case do
                {:ok, %__MODULE__{} = s} -> {:cont, s}
                {:error, %{__struct__: _}} = result -> {:halt, result}
              end
            end)
            |> case do
              {:error, %{__exception__: true}} = result -> result
              %__MODULE__{} = value -> {:ok, value}
            end
          else
            {:error, %{__exception__: true}} = result -> result
          end
        end
      end,
    state_def_update: [
      :state_def_update_doc,
      :state_def_update_since,
      :state_def_update_spec,
      :state_def_update_header,
      :state_def_update_clause_arg0_t_arg1_l0,
      :state_def_update_clause_arg0_t_arg1_any
    ],
    state_def_update_doc!:
      quote do
        @doc ~S"""
        `update!/2` calls`update/2` and, if the result is `{:ok, instance}`
        returns the `instance.
        """
      end,
    state_def_update_since!: nil,
    state_def_update_spec!:
      quote do
        @spec update!(t, any) :: t | no_return
      end,
    state_def_update_header!:
      quote do
        def update!(t, opts \\ [])
      end,
    state_def_update_clause_arg0_t_arg1_any!:
      quote do
        def update!(%__MODULE__{} = state, opts) do
          state
          |> update(opts)
          |> case do
            {:ok, %__MODULE__{} = state} -> state
            {:error, error} -> raise error
          end
        end
      end,
    state_def_update!: [
      :state_def_update_doc!,
      :state_def_update_since!,
      :state_def_update_spec!,
      :state_def_update_header!,
      :state_def_update_clause_arg0_t_arg1_any!
    ],
    state_defp_update_field_header:
      quote do
        @spec update_field(t, kv) :: {:ok, t} | {:error, error}
        defp update_field(state, kv)
      end,
    state_defp_update_field_passthru:
      quote do
        defp update_field(%__MODULE__{} = state, {k, v}) do
          {:ok, state |> struct([{k, v}])}
        end
      end,
    state_defp_update_field_unknown:
      quote do
        defp update_field(%__MODULE__{} = state, {k, v}) do
          new_error_result(m: "update field #{inspect(k)} unknown", v: v)
        end
      end,
    state_defp_update_proxy_field_passthru:
      quote do
        defp update_field(%__MODULE__{} = state, {k, v})
             when k == :proxy_field do
          {:ok, state |> struct!([{k, v}])}
        end
      end,
    state_defp_update_proxy_field_unset:
      quote do
        defp update_field(%__MODULE__{} = state, {k, v})
             when k == :proxy_field and Plymio.Fontais.Guard.is_value_unset(v) do
          {:ok, state |> struct!([{k, v}])}
        end
      end,
    state_defp_update_proxy_field_normalise:
      quote do
        defp update_field(%__MODULE__{} = state, {k, v})
             when k == :proxy_field do
          v
          |> Plymio.Fontais.Guard.is_value_unset()
          |> case do
            true ->
              {:ok, state |> struct!([{k, Plymio.Fontais.Guard.the_unset_value()}])}

            _ ->
              with {:ok, v} <- v |> proxy_field_normalise() do
                {:ok, state |> struct!([{k, v}])}
              else
                {:error, %{__exception__: true}} = result -> result
              end
          end
        end
      end,
    state_defp_update_proxy_field_opts_validate:
      quote do
        defp update_field(%__MODULE__{} = state, {k, v})
             when k == :proxy_field do
          cond do
            Plymio.Fontais.Guard.is_value_unset(v) ->
              {:ok, state |> struct!([{k, Plymio.Fontais.Guard.the_unset_value()}])}

            true ->
              with {:ok, opts} <- v |> Plymio.Fontais.Option.validate_opts() do
                opts
                |> Plymio.Fontais.Guard.is_filled_list()
                |> case do
                  true ->
                    {:ok, state |> struct!([{k, opts}])}

                  _ ->
                    {:ok, state |> struct!([{k, Plymio.Fontais.Guard.the_unset_value()}])}
                end
              else
                {:error, %{__exception__: true}} = result -> result
              end
          end
        end
      end,
    state_defp_update_proxy_field_opts_normalise:
      quote do
        defp update_field(%__MODULE__{} = state, {k, v})
             when k == :proxy_field do
          cond do
            Plymio.Fontais.Guard.is_value_unset(v) ->
              {:ok, state |> struct!([{k, Plymio.Fontais.Guard.the_unset_value()}])}

            true ->
              with {:ok, opts} <- v |> Plymio.Fontais.Option.normalise_opts() do
                opts
                |> Plymio.Fontais.Guard.is_filled_list()
                |> case do
                  true ->
                    {:ok, state |> struct!([{k, opts}])}

                  _ ->
                    {:ok, state |> struct!([{k, Plymio.Fontais.Guard.the_unset_value()}])}
                end
              else
                {:error, %{__exception__: true}} = result -> result
              end
          end
        end
      end,
    state_defp_update_proxy_field_opzioni_validate:
      quote do
        defp update_field(%__MODULE__{} = state, {k, v})
             when k == :proxy_field do
          cond do
            Plymio.Fontais.Guard.is_value_unset(v) ->
              {:ok, state |> struct!([{k, Plymio.Fontais.Guard.the_unset_value()}])}

            true ->
              with {:ok, opts} <- v |> Plymio.Fontais.Option.opzioni_validate() do
                opts
                |> Plymio.Fontais.Guard.is_filled_list()
                |> case do
                  true ->
                    {:ok, state |> struct!([{k, opts}])}

                  _ ->
                    {:ok, state |> struct!([{k, Plymio.Fontais.Guard.the_unset_value()}])}
                end
              else
                {:error, %{__exception__: true}} = result -> result
              end
          end
        end
      end,
    state_defp_update_proxy_field_opzioni_normalise:
      quote do
        defp update_field(%__MODULE__{} = state, {k, v})
             when k == :proxy_field do
          cond do
            Plymio.Fontais.Guard.is_value_unset(v) ->
              {:ok, state |> struct!([{k, Plymio.Fontais.Guard.the_unset_value()}])}

            true ->
              with {:ok, opts} <- v |> Plymio.Fontais.Option.opzioni_normalise() do
                opts
                |> Plymio.Fontais.Guard.is_filled_list()
                |> case do
                  true ->
                    {:ok, state |> struct!([{k, opts}])}

                  _ ->
                    {:ok, state |> struct!([{k, Plymio.Fontais.Guard.the_unset_value()}])}
                end
              else
                {:error, %{__exception__: true}} = result -> result
              end
          end
        end
      end,
    state_defp_update_proxy_field_forms_validate:
      quote do
        defp update_field(%__MODULE__{} = state, {k, v})
             when k == :proxy_field do
          cond do
            Plymio.Fontais.Guard.is_value_unset(v) ->
              {:ok, state |> struct!([{k, Plymio.Fontais.Guard.the_unset_value()}])}

            true ->
              with {:ok, forms} <- v |> Plymio.Fontais.Option.forms_validate() do
                forms
                |> Plymio.Fontais.Guard.is_filled_list()
                |> case do
                  true ->
                    {:ok, state |> struct!([{k, forms}])}

                  _ ->
                    {:ok, state |> struct!([{k, Plymio.Fontais.Guard.the_unset_value()}])}
                end
              else
                {:error, %{__exception__: true}} = result -> result
              end
          end
        end
      end,
    state_defp_update_proxy_field_forms_normalise:
      quote do
        defp update_field(%__MODULE__{} = state, {k, v})
             when k == :proxy_field do
          cond do
            Plymio.Fontais.Guard.is_value_unset(v) ->
              {:ok, state |> struct!([{k, Plymio.Fontais.Guard.the_unset_value()}])}

            true ->
              with {:ok, forms} <- v |> Plymio.Fontais.Form.forms_normalise() do
                forms
                |> Plymio.Fontais.Guard.is_filled_list()
                |> case do
                  true ->
                    {:ok, state |> struct!([{k, forms}])}

                  _ ->
                    {:ok, state |> struct!([{k, Plymio.Fontais.Guard.the_unset_value()}])}
                end
              else
                {:error, %{__exception__: true}} = result -> result
              end
          end
        end
      end,
    state_defp_update_proxy_field_keyword:
      quote do
        defp update_field(%__MODULE__{} = state, {k, v})
             when k == :proxy_field do
          cond do
            Plymio.Fontais.Guard.is_value_unset(v) ->
              {:ok, state |> struct!([{k, Plymio.Fontais.Guard.the_unset_value()}])}

            Keyword.keyword?(v) ->
              v
              |> Plymio.Fontais.Guard.is_filled_list()
              |> case do
                true ->
                  {:ok, state |> struct!([{k, v}])}

                _ ->
                  {:ok, state |> struct!([{k, Plymio.Fontais.Guard.the_unset_value()}])}
              end

            true ->
              new_error_result(m: "update keyword field #{inspect(:proxy_field)} invalid", v: v)
          end
        end
      end,
    state_defp_update_proxy_field_list:
      quote do
        defp update_field(%__MODULE__{} = state, {k, v})
             when k == :proxy_field do
          cond do
            Plymio.Fontais.Guard.is_value_unset(v) ->
              {:ok, state |> struct!([{k, Plymio.Fontais.Guard.the_unset_value()}])}

            is_list?(v) ->
              v
              |> Plymio.Fontais.Guard.is_filled_list()
              |> case do
                true ->
                  {:ok, state |> struct!([{k, v}])}

                _ ->
                  {:ok, state |> struct!([{k, Plymio.Fontais.Guard.the_unset_value()}])}
              end

            true ->
              new_error_result(m: "update list field #{inspect(:proxy_field)} invalid", v: v)
          end
        end
      end,
    state_defp_update_proxy_field_normalise_list:
      quote do
        defp update_field(%__MODULE__{} = state, {k, v})
             when k == :proxy_field do
          cond do
            Plymio.Fontais.Guard.is_value_unset(v) ->
              {:ok, state |> struct!([{k, Plymio.Fontais.Guard.the_unset_value()}])}

            true ->
              v
              |> List.wrap()
              |> case do
                x when Plymio.Fontais.Guard.is_filled_list(x) ->
                  {:ok, state |> struct!([{k, x}])}

                _ ->
                  {:ok, state |> struct!([{k, Plymio.Fontais.Guard.the_unset_value()}])}
              end
          end
        end
      end,
    state_defp_update_proxy_field_map:
      quote do
        defp update_field(%__MODULE__{} = state, {k, v})
             when k == :proxy_field do
          cond do
            Plymio.Fontais.Guard.is_value_unset(v) ->
              {:ok, state |> struct!([{k, Plymio.Fontais.Guard.the_unset_value()}])}

            is_map(v) ->
              {:ok, state |> struct!([{k, v}])}

            true ->
              new_error_result(m: "update map field #{inspect(k)} invalid", v: v)
          end
        end
      end,
    state_defp_update_proxy_field_normalise_map:
      quote do
        defp update_field(%__MODULE__{} = state, {k, v})
             when k == :proxy_field do
          cond do
            Plymio.Fontais.Guard.is_value_unset(v) ->
              {:ok, state |> struct!([{k, Plymio.Fontais.Guard.the_unset_value()}])}

            is_map(v) ->
              {:ok, state |> struct!([{k, v}])}

            Keyword.keyword?(v) ->
              {:ok, state |> struct!([{k, v |> Map.new()}])}

            true ->
              new_error_result(m: "update map field #{inspect(k)} invalid", v: v)
          end
        end
      end,
    state_defp_update_proxy_field_atom:
      quote do
        defp update_field(%__MODULE__{} = state, {k, v})
             when k == :proxy_field do
          cond do
            Plymio.Fontais.Guard.is_value_unset(v) ->
              {:ok, state |> struct!([{k, Plymio.Fontais.Guard.the_unset_value()}])}

            is_atom(v) ->
              {:ok, state |> struct!([{k, v}])}

            true ->
              new_error_result(m: "update atom field #{inspect(k)} invalid", v: v)
          end
        end
      end,
    state_defp_update_proxy_field_binary:
      quote do
        defp update_field(%__MODULE__{} = state, {k, v})
             when k == :proxy_field do
          cond do
            Plymio.Fontais.Guard.is_value_unset(v) ->
              {:ok, state |> struct!([{k, Plymio.Fontais.Guard.the_unset_value()}])}

            is_binary(v) ->
              {:ok, state |> struct!([{k, v}])}

            true ->
              new_error_result(m: "update atom field #{inspect(k)} invalid", v: v)
          end
        end
      end,
    state_defp_update_proxy_field_fun:
      quote do
        defp update_field(%__MODULE__{} = state, {k, v})
             when k == :proxy_field do
          cond do
            Plymio.Fontais.Guard.is_value_unset(v) ->
              {:ok, state |> struct!([{k, Plymio.Fontais.Guard.the_unset_value()}])}

            is_function(v, 1) ->
              {:ok, state |> struct!([{k, v}])}

            true ->
              new_error_result(m: "update fun field #{inspect(k)} invalid", v: v)
          end
        end
      end,
    state_defp_update_proxy_field_fun1:
      quote do
        defp update_field(%__MODULE__{} = state, {k, v})
             when k == :proxy_field do
          cond do
            Plymio.Fontais.Guard.is_value_unset(v) ->
              {:ok, state |> struct!([{k, Plymio.Fontais.Guard.the_unset_value()}])}

            is_function(v, 1) ->
              {:ok, state |> struct!([{k, v}])}

            true ->
              new_error_result(m: "update fun/1 field #{inspect(k)} invalid", v: v)
          end
        end
      end,
    state_defp_update_proxy_field_fun2:
      quote do
        defp update_field(%__MODULE__{} = state, {k, v})
             when k == :proxy_field do
          cond do
            Plymio.Fontais.Guard.is_value_unset(v) ->
              {:ok, state |> struct!([{k, Plymio.Fontais.Guard.the_unset_value()}])}

            is_function(v, 2) ->
              {:ok, state |> struct!([{k, v}])}

            true ->
              new_error_result(m: "update fun/1 field #{inspect(k)} invalid", v: v)
          end
        end
      end,
    state_base_package: [
      :state_def_new,
      :state_def_new!,
      :state_def_update,
      :state_def_update!
    ]
  }

  def __vekil__() do
    @vekil
  end
end
