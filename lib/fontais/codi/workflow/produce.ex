defmodule Plymio.Fontais.Codi.Workflow.Produce do
  @moduledoc false

  @vekil %{
    workflow_def_produce_doc: :doc_false,
    workflow_def_produce_since: nil,
    workflow_def_produce_spec:
      quote do
        @spec produce(any, any) :: {:ok, {any, t}} | {:error, error}
      end,
    workflow_def_produce_header:
      quote do
        def produce(new_opts_or_t, update_opts \\ [])
      end,
    workflow_def_produce_clause_t_l0:
      quote do
        def produce(%__MODULE__{} = state, []) do
          with {:ok, {_value, %__MODULE__{}}} = result <- state |> express do
            result
          else
            {:error, %{__exception__: true}} = result -> result
          end
        end
      end,
    workflow_def_produce_clause_t_any:
      quote do
        def produce(%__MODULE__{} = state, update_opts) do
          with {:ok, %__MODULE_{} = state} <- state |> update(update_opts),
               {:ok, {_value, %__MODULE__{}}} = result <- state |> produce do
            result
          else
            {:error, %{__exception__: true}} = result -> result
          end
        end
      end,
    workflow_def_produce_clause_any_any:
      quote do
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
    workflow_def_produce: [
      :workflow_def_produce_doc,
      :workflow_def_produce_since,
      :workflow_def_produce_spec,
      :workflow_def_produce_header,
      :workflow_def_produce_clause_t_l0,
      :workflow_def_produce_clause_t_any,
      :workflow_def_produce_clause_any_any
    ],
    workflow_def_produce_stages:
      quote do
        @spec produce_stages(t, any) :: {:ok, {any, t}} | {:error, error}

        def produce_stages(state, stages \\ nil)

        def produce_stages(%PRODUCESTAGESTRUCT{} = state, stages)
            when is_list(stages) do
          stages
          |> Plymio.Funcio.Enum.Reduce.reduce1_enum(
            {[], state},
            fn {stage, fun_stage}, {product, state} ->
              with {:ok, {stage_product, %PRODUCESTAGESTRUCT{} = state}} <- state |> fun_stage.() do
                cond do
                  Keyword.keyword?(stage_product) ->
                    {:ok, {product ++ stage_product, state}}

                  true ->
                    new_error_result(
                      m: "stage #{inspect(stage)} product invalid",
                      v: stage_product
                    )
                end
              else
                {:error, %{__struct__: _}} = result -> result
              end
            end
          )
          |> case do
            {:error, %{__struct__: _}} = result -> result
            {:ok, {_, %PRODUCESTAGESTRUCT{}}} = result -> result
          end
        end

        def produce_stages(%PRODUCESTAGESTRUCT{:produce_stage_field => stages} = state, nil) do
          state |> produce_stages(stages)
        end
      end,
    workflow_def_produce_stage_field_header:
      quote do
        require Plymio.Fontais.Guard
        def produce_stage(state)
      end,
    workflow_def_produce_stage_field_unset_worker:
      quote do
        def produce_stage(%PRODUCESTAGESTRUCT{:produce_stage_field => field} = state)
            when Plymio.Fontais.Guard.is_value_unset_or_nil(field) do
          state |> produce_stage_field_unset_worker
        end
      end,

    # "SP=(T{F:{UNSET,NIL})"
    workflow_def_produce_stage_field_unset_empty:
      quote do
        def produce_stage(%PRODUCESTAGESTRUCT{:produce_stage_field => field} = state)
            when Plymio.Fontais.Guard.is_value_unset_or_nil(field) do
          {:ok, {[], state}}
        end
      end,

    # "SP=(T{F:SET})"
    workflow_def_produce_stage_field_set_worker_update:
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
    workflow_def_produce_stage_field: [
      :workflow_def_produce_stage_field_header,
      :workflow_def_produce_stage_field_unset_empty,
      :workflow_def_produce_stage_field_set_worker_update
    ],

    # "SP=(T{F:L},Is=NIL)=>PSW(T,Is)=>{[{F,Is}],T}"
    workflow_def_produce_stage_field_items:
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
                     state |> PRODUCESTAGESTRUCT.update(product) do
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
    workflow_def_produce_stage_worker_t_is_mccp0e_ozi_t:
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
                   |> produce_stage_worker_item(item) do
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
    workflow_def_produce_stage_worker_t_is_mcp0e_ozi_t:
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
                   |> produce_stage_worker_item(item) do
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
    workflow_def_produce_stage_worker_t_is_rp0e_ozi_t:
      quote do
        def produce_stage_worker(%PRODUCESTAGESTRUCT{} = state, items)
            when is_list(items) do
          items
          |> Enum.reduce_while(
            {[], state},
            fn item, {items, state} ->
              with {:ok, {item, %PRODUCESTAGESTRUCT{} = state}} <-
                     state
                     |> produce_stage_worker_item(item) do
                {:cont, {[item | items], state}}
              else
                {:error, %{__struct__: _}} = result -> {:halt, result}
              end
            end
          )
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
