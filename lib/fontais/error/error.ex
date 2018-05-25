defmodule Plymio.Fontais.Error do
  @moduledoc false

  import Plymio.Fontais.Error.Utility,
    only: [
      update_canonical_opts: 1
    ]

  import Plymio.Fontais.Error.Format,
    only: [
      format_error_message_opts: 1
    ]

  def new_argument_error(opts \\ [])

  def new_argument_error(message) when is_binary(message) do
    {:ok, %ArgumentError{message: message}}
  end

  def new_argument_error(opts) do
    with {:ok, opts} <- opts |> update_canonical_opts do
      opts
      |> format_error_message_opts
      |> case do
        {:error, %{__struct__: _}} = result -> result
        {:ok, message} -> {:ok, %ArgumentError{message: message}}
      end
    else
      {:error, %{__exception__: true}} ->
        {:error,
         %ArgumentError{message: "new_argument_error argument invalid, got: #{inspect(opts)}"}}
    end
  end

  @doc false
  def new_argument_error_result(opts \\ []) do
    with {:ok, error} <- opts |> new_argument_error do
      {:error, error}
    else
      {:error, %{__exception__: true}} ->
        {:error,
         %ArgumentError{message: "new_argument_error argument invalid, got: #{inspect(opts)}"}}
    end
  end

  def new_runtime_error(opts \\ [])

  def new_runtime_error(message) when is_binary(message) do
    {:ok, %RuntimeError{message: message}}
  end

  def new_runtime_error(opts) do
    with {:ok, opts} <- opts |> update_canonical_opts do
      opts
      |> format_error_message_opts
      |> case do
        {:error, %{__struct__: _}} = result -> result
        {:ok, message} -> {:ok, %RuntimeError{message: message}}
      end
    else
      {:error, %{__exception__: true}} ->
        {:error,
         %ArgumentError{message: "new_runtime_error runtime invalid, got: #{inspect(opts)}"}}
    end
  end

  @doc false
  def new_runtime_error_result(opts \\ []) do
    with {:ok, error} <- opts |> new_runtime_error do
      {:error, error}
    else
      {:error, %{__exception__: true}} ->
        {:error,
         %ArgumentError{message: "new_runtime_error runtime invalid, got: #{inspect(opts)}"}}
    end
  end

  def new_key_error(values, term) do
    cond do
      Keyword.keyword?(values) -> values |> Keyword.keys()
      is_list(values) -> values
      true -> [values]
    end
    |> Enum.uniq()
    |> case do
      [key] -> %KeyError{key: key, term: term}
      keys -> %KeyError{key: keys, term: term}
    end
  end

  @doc false
  def new_key_error_result(values, term) do
    {:error, new_key_error(values, term)}
  end

  @doc false
  def new_bad_key_error(keys, term) do
    keys =
      cond do
        Keyword.keyword?(keys) -> keys |> Keyword.keys()
        is_list(keys) -> keys
        true -> [keys]
      end
      |> Enum.uniq()

    %BadKeyError{key: keys, term: term}
  end

  @doc false
  def new_bad_key_error_result(keys, term) do
    {:error, new_bad_key_error(keys, term)}
  end

  @doc false
  def new_error_result(opts \\ []) do
    opts |> new_argument_error_result
  end

  @vekil %{
    defexception_package: [
      :defexception_redtape,
      :defexception_defexception,
      :defexception_types,
      :state_base_package,
      :defexception_defp_update_field,
      :defexception_new_error_package,
      :defexception_def_exception,
      :defexception_message_package
    ],
    defexception_defexception:
      quote do
        @plymio_fontais_error_struct_kvs_aliases [
          @plymio_fontais_error_field_alias_message,
          @plymio_fontais_error_field_alias_reason,
          @plymio_fontais_error_field_alias_value,
          @plymio_fontais_error_field_alias_message_function,
          @plymio_fontais_error_field_alias_message_config
        ]

        @plymio_fontais_error_struct_dict_aliases @plymio_fontais_error_struct_kvs_aliases
                                                  |> Plymio.Fontais.Option.opts_create_aliases_dict()

        @plymio_fontais_error_defstruct @plymio_fontais_error_struct_kvs_aliases
                                        |> Enum.map(fn {k, _v} ->
                                          {k, @plymio_fontais_the_unset_value}
                                        end)
                                        |> Keyword.put(
                                          @plymio_fontais_error_field_message_config,
                                          @plymio_fontais_error_default_message_config
                                        )
                                        |> Keyword.new()

        def update_canonical_opts(opts, dict \\ @plymio_fontais_error_struct_dict_aliases) do
          opts |> Plymio.Fontais.Option.opts_canonical_keys(dict)
        end

        defexception @plymio_fontais_error_defstruct
      end,
    defexception_redtape:
      quote do
        use Plymio.Fontais.Attribute
      end,
    defexception_types: [
      quote do
        @type t :: %__MODULE__{}
      end,
      :def_minimal_types
    ],
    defexception_defp_update_field: [
      :state_defp_update_field_header,
      :defexception_defp_update_field_message,
      :defexception_defp_update_field_rest
    ],
    defexception_defp_update_field_message:
      quote do
        defp update_field(%__MODULE__{} = state, {k, v})
             when k in [@plymio_fontais_error_field_message] do
          cond do
            is_binary(v) ->
              {:ok, state |> Map.put(k, v)}

            is_atom(v) ->
              {:ok, state |> Map.put(k, v |> to_string)}

            true ->
              {:error, %ArgumentError{message: "expected valid #{inspect(k)}; got #{inspect(v)}"}}
          end
        end
      end,
    defexception_defp_update_field_rest:
      quote do
        defp update_field(%__MODULE__{} = state, {k, v})
             when k in [
                    @plymio_fontais_error_field_value,
                    @plymio_fontais_error_field_reason,
                    @plymio_fontais_error_field_message_function,
                    @plymio_fontais_error_field_message_config
                  ] do
          {:ok, state |> struct!([{k, v}])}
        end
      end,
    defexception_def_exception:
      quote do
        def exception(value)

        def exception(%__MODULE__{} = state) do
          state
        end

        def exception(value) do
          value |> new!
        end
      end,
    defexception_def_message_doc: nil,
    defexception_def_message_since: nil,
    defexception_def_message_spec:
      quote do
      end,
    defexception_def_message_header:
      quote do
        def message(error)
      end,
    defexception_def_message_clause_user_transform:
      quote do
        def message(
              %__MODULE__{@plymio_fontais_error_field_message_function => format_message} = state
            )
            when is_function(format_message) do
          state
          |> format_message.()
          |> case do
            {:error, %{__struct__: _} = error} -> raise error
            {:ok, message} -> message |> Plymio.Fontais.Error.Format.format_error_message_value()
            message -> message |> Plymio.Fontais.Error.Format.format_error_message_value()
          end
          |> case do
            {:ok, message} -> message
          end
        end
      end,
    defexception_def_message_clause_default:
      quote do
        def message(%__MODULE__{} = state) do
          state
          |> format_error_message
        end
      end,
    defexception_def_message: [
      :defexception_def_message_doc,
      :defexception_def_message_since,
      :defexception_def_message_spec,
      :defexception_def_message_header,
      :defexception_def_message_clause_user_transform,
      :defexception_def_message_clause_default
    ],
    defexception_message_package: [
      :defexception_def_message,
      :defexception_def_format_error_message
    ],
    defexception_def_format_error_message_doc: nil,
    defexception_def_format_error_message_since: nil,
    defexception_def_format_error_message_spec:
      quote do
        @spec format_error_message(t) :: String.t()
      end,
    defexception_def_format_error_message_header:
      quote do
        def format_error_message(error)
      end,
    defexception_def_format_error_message_clause_default:
      quote do
        def format_error_message(
              %__MODULE__{
                @plymio_fontais_error_field_message_config => format_order
              } = state
            ) do
          format_order
          |> List.wrap()
          |> Enum.map(fn k -> {k, state |> Map.get(k)} end)
          |> Plymio.Fontais.Error.Format.format_error_message_opts()
          |> case do
            {:ok, message} -> message
            {:error, %{__struct__: _} = error} -> raise error
          end
        end
      end,
    defexception_def_format_error_message: [
      :defexception_def_format_error_message_doc,
      :defexception_def_format_error_message_since,
      :defexception_def_format_error_message_spec,
      :defexception_def_format_error_message_header,
      :defexception_def_format_error_message_clause_default
    ],
    defexception_new_error_package: [
      :defexception_def_new_result,
      :defexception_def_new_error_result_defdelegate_new_result
    ],
    defexception_def_new_result_doc: nil,
    defexception_def_new_result_since: nil,
    defexception_def_new_result_spec:
      quote do
        @spec new_result(opts) :: {:error, t} | no_return
      end,
    defexception_def_new_result_header:
      quote do
        def new_result(opts \\ [])
      end,
    defexception_def_new_result_clause_arg0_list:
      quote do
        def new_result(opts) when is_list(opts) do
          opts
          |> new
          |> case do
            {:ok, %__MODULE__{} = state} ->
              {:error, state}

            {:error, error} ->
              case error |> Exception.exception?() do
                true -> raise error
              end
          end
        end
      end,
    defexception_def_new_result: [
      :defexception_def_new_result_doc,
      :defexception_def_new_result_since,
      :defexception_def_new_result_spec,
      :defexception_def_new_result_header,
      :defexception_def_new_result_clause_arg0_list
    ],
    defexception_def_new_error_result_defdelegate_new_result:
      quote do
        defdelegate new_error_result(opts), to: __MODULE__, as: :new_result
      end
  }

  def __vekil__() do
    @vekil
  end
end
