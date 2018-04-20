defmodule Plymio.Fontais.Workflow do
  @moduledoc false

  use Plymio.Fontais.Attribute

  import Plymio.Fontais.Error,
    only: [
      new_error_result: 1
    ]

  @vekil %{
    doc_false:
      quote do
        @doc false
      end,
    def_minimal_types:
      quote do
        @type kv :: Plymio.Fontais.kv()
        @type opts :: Plymio.Fontais.opts()
        @type error :: Plymio.Fontais.error()
        @type result :: Plymio.Fontais.result()
      end,
    def_new:
      quote do
        @spec new(any) :: {:ok, t} | {:error, error}

        def new(opts \\ [])

        def new(%__MODULE__{} = value) do
          {:ok, value}
        end

        def new([]) do
          {:ok, %__MODULE__{}}
        end

        def new(opts) do
          with {:ok, %__MODULE__{} = state} <- new() do
            state |> update(opts)
          else
            {:error, %{__exception__: true}} = result -> result
          end
        end
      end,
    def_new!:
      quote do
        @spec new!(opts) :: t | no_return

        def new!(opts \\ []) do
          opts
          |> new()
          |> case do
            {:ok, %__MODULE__{} = state} -> state
            {:error, error} -> raise error
          end
        end
      end,
    def_update:
      quote do
        @spec update(t, opts) :: {:ok, t} | {:error, error}

        def update(t, opts \\ [])

        def update(%__MODULE__{} = state, []) do
          {:ok, state}
        end

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
    def_update!:
      quote do
        @spec update!(t, opts) :: t | no_return

        def update!(state, opts \\ [])

        def update!(%__MODULE__{} = state, []) do
          state
        end

        def update!(%__MODULE__{} = state, opts) when is_list(opts) do
          state
          |> update(opts)
          |> case do
            {:ok, %__MODULE__{} = state} -> state
            {:error, error} -> raise error
          end
        end
      end,
    defp_update_field_header:
      quote do
        @spec update_field(t, kv) :: {:ok, t} | {:error, error}
        defp update_field(state, kv)
      end,
    defp_update_field_passthru:
      quote do
        defp update_field(%__MODULE__{} = state, {k, v}) do
          {:ok, state |> struct([{k, v}])}
        end
      end,
    defp_update_field_unknown:
      quote do
        defp update_field(%__MODULE__{} = state, {k, v}) do
          new_error_result(m: "struct field #{inspect(k)} unknown", v: v)
        end
      end,
    defp_update_field_proxy_passthru:
      quote do
        defp update_field(%__MODULE__{} = state, {k, v})
             when k == :proxy_field do
          v
          |> Plymio.Fontais.Guard.is_value_unset()
          |> case do
            true ->
              {:ok, state |> struct!([{k, Plymio.Fontais.Guard.the_unset_value()}])}

            _ ->
              {:ok, state |> struct!([{k, v}])}
          end
        end
      end,
    defp_update_field_proxy_normalise:
      quote do
        defp update_field(%__MODULE__{} = state, {k, v})
             when k == :proxy_field do
          v
          |> Plymio.Fontais.Guard.is_value_unset()
          |> case do
            true ->
              {:ok, state |> struct!([{k, Plymio.Fontais.Guard.the_unset_value()}])}

            _ ->
              with {:ok, v} <- v |> proxy_field_normalise do
                {:ok, state |> struct!([{k, v}])}
              else
                {:error, %{__exception__: true}} = result -> result
              end
          end
        end
      end,
    defp_update_field_proxy_validate_opts:
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

            true ->
              new_error_result(m: "update keyword field #{inspect(:proxy_field)} invalid", v: v)
          end
        end
      end,
    defp_update_field_proxy_normalise_opts:
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

            true ->
              new_error_result(m: "update keyword field #{inspect(:proxy_field)} invalid", v: v)
          end
        end
      end,
    defp_update_field_proxy_validate_opzioni:
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
    defp_update_field_proxy_normalise_opzioni:
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
    defp_update_field_proxy_keyword:
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
    defp_update_field_proxy_list:
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
    defp_update_field_proxy_normalise_list:
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
    defp_update_field_proxy_map:
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
    defp_update_field_proxy_normalise_map:
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
    defp_update_field_proxy_atom:
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
    defp_update_field_proxy_binary:
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
    defp_update_field_proxy_fun:
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
    defp_update_field_proxy_fun1:
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
    defp_update_field_proxy_fun2:
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
    def_update_stage_field:
      quote do
        def update_stage_field(state, updates \\ [])

        def update_stage_field(%PRODUCESTAGESTRUCT{} = state, []) do
          {:ok, state}
        end

        def update_stage_field(%PRODUCESTAGESTRUCT{} = state, updates)
            when is_list(updates) do
          state |> PRODUCESTAGESTRUCT.update(updates)
        end
      end,

    # "PRODUCE=(T,O0) | (T,O)"
    def_produce:
      quote do
        def produce(new_opts_or_t, update_opts \\ [])

        def produce(%__MODULE__{} = state, []) do
          with {:ok, {_value, %__MODULE__{}}} = result <- state |> express do
            result
          else
            {:error, %{__exception__: true}} = result -> result
          end
        end

        def produce(%__MODULE__{} = state, update_opts) do
          with {:ok, %__MODULE_{} = state} <- state |> update(update_opts),
               {:ok, {_value, %__MODULE__{}}} = result <- state |> produce do
            result
          else
            {:error, %{__exception__: true}} = result -> result
          end
        end

        def produce(new_opts, update_opts) do
          with {:ok, new_opts} <- new_opts |> Plymio.Fontais.Option.opts_normalise(),
               {:ok, update_opts} <- update_opts |> Plymio.Fontais.Option.opts_normalise(),
               {:ok, %__MODULE__{} = state} <- (new_opts ++ update_opts) |> new,
               {:ok, {_, %__MODULE__{}}} = result <- state |> produce do
            result
          else
            {:error, %{__exception__: true}} = result -> result
          end
        end
      end,
    def_produce_stages:
      quote do
        @spec produce_stages(t, any) :: {:ok, t} | {:error, error}

        def produce_stages(state, stages \\ nil)

        def produce_stages(%PRODUCESTAGESTRUCT{} = state, stages)
            when is_list(stages) do
          stages
          |> Plymio.Funcio.Enum.Reduce.reduce1_enum({[], state}, fn {stage, fun_stage},
                                                                    {product, state} ->
            with {:ok, {stage_product, %PRODUCESTAGESTRUCT{} = state}} <- state |> fun_stage.() do
              cond do
                Keyword.keyword?(stage_product) ->
                  {:ok, {product ++ stage_product, state}}

                true ->
                  new_error_result(m: "stage #{inspect(stage)} product invalid", v: stage_product)
              end
            else
              {:error, %{__struct__: _}} = result -> result
            end
          end)
          |> case do
            {:error, %{__struct__: _}} = result -> result
            {:ok, {_, %PRODUCESTAGESTRUCT{}}} = result -> result
          end
        end

        def produce_stages(%PRODUCESTAGESTRUCT{:produce_stage_field => stages} = state, nil) do
          state |> produce_stages(stages)
        end
      end,
    def_produce_stage_field_header:
      quote do
        require Plymio.Fontais.Guard
        def produce_stage(state)
      end,
    def_produce_stage_field_unset_worker:
      quote do
        def produce_stage(%PRODUCESTAGESTRUCT{:produce_stage_field => field} = state)
            when Plymio.Fontais.Guard.is_value_unset_or_nil(field) do
          state |> produce_stage_field_unset_worker
        end
      end,

    # "SP=(T{F:{UNSET,NIL})"
    def_produce_stage_field_unset_empty:
      quote do
        def produce_stage(%PRODUCESTAGESTRUCT{:produce_stage_field => field} = state)
            when Plymio.Fontais.Guard.is_value_unset_or_nil(field) do
          {:ok, {[], state}}
        end
      end,

    # "SP=(T{F:SET})"
    def_produce_stage_field_set_worker_update:
      quote do
        def produce_stage(%PRODUCESTAGESTRUCT{:produce_stage_field => field} = state)
            when Plymio.Fontais.Guard.is_value_set(field) do
          with {:ok, {product, %PRODUCESTAGESTRUCT{} = state}} <- state |> produce_stage_worker,
               {:ok, %PRODUCESTAGESTRUCT{} = state} <- state |> produce_stage_update(product) do
            {:ok, {product, state}}
          else
            {:error, %{__exception__: true}} = result -> result
          end
        end
      end,
    def_produce_stage_field: [
      :def_update_stage_field,
      :def_produce_stage_field_header,
      :def_produce_stage_field_unset_empty,
      :def_produce_stage_field_set_worker_update
    ],

    # "SP=(T{F:L},Is=NIL)=>PSW(T,Is)=>{[{F,Is}],T}"
    def_produce_stage_field_items:
      quote do
        require Plymio.Fontais.Guard

        def produce_stage(state, items \\ nil)

        def produce_stage(%PRODUCESTAGESTRUCT{} = state, items) when is_list(items) do
          state
          |> produce_stage_worker(items)
          |> case do
            {:error, %{__struct__: _}} = result ->
              result

            {:ok, {items, %PRODUCESTAGESTRUCT{} = state}} ->
              product = [{:produce_stage_field, items}]

              with {:ok, %PRODUCESTAGESTRUCT{} = state} <-
                     state
                     |> PRODUCESTAGESTRUCT.update(product) do
                {:ok, {product, state}}
              else
                {:error, %{__exception__: true}} = result -> result
              end
          end
        end

        def produce_stage(%PRODUCESTAGESTRUCT{:produce_stage_field => items} = state, nil)
            when is_list(items) do
          state
          |> produce_stage(items)
        end

        def produce_stage(%PRODUCESTAGESTRUCT{:produce_stage_field => items} = state, nil)
            when Plymio.Fontais.Guard.is_value_unset_or_nil(items) do
          {:ok, {[], state}}
        end
      end,

    # "SPW=(T,Is=L)=>MCCP0E(T,I->{OZI})=>{OZI,T}"
    def_produce_stage_worker_t_is_mccp0e_ozi_t:
      quote do
        def produce_stage_worker(state, items \\ [])

        def produce_stage_worker(%PRODUCESTAGESTRUCT{} = state, []) do
          {:ok, {[], state}}
        end

        def produce_stage_worker(%PRODUCESTAGESTRUCT{} = state, items)
            when is_list(items) do
          fun = fn item ->
            with {:ok, {opzioni, %PRODUCESTAGESTRUCT{}}} <-
                   state
                   |> produce_stage_worker_item(item),
                 true <- true do
              {:ok, opzioni}
            else
              {:error, %{__exception__: true}} = result -> result
            end
          end

          with {:ok, opzioni} <-
                 items
                 |> Plymio.Funcio.Enum.Map.Collate.map_concurrent_collate0_opzioni_enum(fun) do
            {:ok, {opzioni, state}}
          else
            {:error, %{__exception__: true}} = result -> result
          end
        end
      end,

    # "SPW=(T,Is=L)=>MCP0E(T,I->{OZI})=>{OZI,T}"
    def_produce_stage_worker_t_is_mcp0e_ozi_t:
      quote do
        def produce_stage_worker(state, items \\ [])

        def produce_stage_worker(%PRODUCESTAGESTRUCT{} = state, []) do
          {:ok, {[], state}}
        end

        def produce_stage_worker(%PRODUCESTAGESTRUCT{} = state, items)
            when is_list(items) do
          fun = fn item ->
            with {:ok, {opzioni, %PRODUCESTAGESTRUCT{}}} <-
                   state
                   |> produce_stage_worker_item(item),
                 true <- true do
              {:ok, opzioni}
            else
              {:error, %{__exception__: true}} = result -> result
            end
          end

          with {:ok, opzioni} <-
                 items
                 |> Plymio.Funcio.Enum.Map.Collate.map_collate0_opzioni_enum(fun) do
            {:ok, {opzioni, state}}
          else
            {:error, %{__exception__: true}} = result -> result
          end
        end
      end,

    # "SPW=(T,Is=L)=>R0E(T,I->{Is,T})=>{OZI,T}"
    def_produce_stage_worker_t_is_rp0e_ozi_t:
      quote do
        def produce_stage_worker(%PRODUCESTAGESTRUCT{} = state, items)
            when is_list(items) do
          items
          |> Enum.reduce_while({[], state}, fn item, {items, state} ->
            with {:ok, {item, %PRODUCESTAGESTRUCT{} = state}} <-
                   state
                   |> produce_stage_worker_item(item) do
              {:cont, {[item | items], state}}
            else
              {:error, %{__struct__: _}} = result -> {:halt, result}
            end
          end)
          |> case do
            {:error, %{__struct__: _}} = result ->
              result

            {items, %PRODUCESTAGESTRUCT{} = state} ->
              items = items |> Enum.reverse()

              with {:ok, opzioni} <- items |> Plymio.Fontais.Option.opzioni_merge() do
                {:ok, {opzioni, state}}
              else
                {:error, %{__exception__: true}} = result -> result
              end
          end
        end
      end
  }

  def __vekil__() do
    @vekil
  end
end
