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
    def_error_complete: [
      :def_error_redtape,
      :def_error_defexception,
      :def_error_types,
      :def_new,
      :def_new!,
      :def_update,
      :def_update!,
      :defp_update_field_header,
      :defp_update_field_error_message,
      :defp_update_field_error_fields,
      :def_error_new_error,
      :def_error_exception,
      :def_error_message_header,
      :def_error_message_clause_user_transform,
      :def_error_message_clause_default,
      :def_error_message_format_message
    ],
    def_error_defexception:
      quote do
        @plymio_fontais_error_struct_kvs_aliases [
          @plymio_fontais_error_key_alias_message,
          @plymio_fontais_error_key_alias_reason,
          @plymio_fontais_error_key_alias_value,
          @plymio_fontais_error_key_alias_format_message,
          @plymio_fontais_error_key_alias_format_order
        ]

        @plymio_fontais_error_struct_dict_aliases @plymio_fontais_error_struct_kvs_aliases
                                                  |> Plymio.Fontais.Option.opts_create_aliases_dict()

        @plymio_fontais_error_defstruct @plymio_fontais_error_struct_kvs_aliases
                                        |> Enum.map(fn {k, _v} ->
                                          {k, @plymio_fontais_the_unset_value}
                                        end)
                                        |> Keyword.put(
                                          @plymio_fontais_error_key_format_order,
                                          @plymio_fontais_error_default_format_order
                                        )
                                        |> Keyword.new()

        def update_canonical_opts(opts, dict \\ @plymio_fontais_error_struct_dict_aliases) do
          opts |> Plymio.Fontais.Option.opts_canonical_keys(dict)
        end

        defexception @plymio_fontais_error_defstruct
      end,
    def_error_redtape:
      quote do
        use Plymio.Fontais.Attribute
      end,
    def_error_types: [
      quote do
        @type t :: %__MODULE__{}
      end,
      :def_minimal_types
    ],
    defp_update_field_error_message:
      quote do
        defp update_field(%__MODULE__{} = state, {k, v})
             when k in [@plymio_fontais_error_key_message] do
          cond do
            is_binary(v) ->
              state |> Map.put(k, v)

            is_atom(v) ->
              state |> Map.put(k, v |> to_string)

            true ->
              {:error, %ArgumentError{message: "expected valid #{inspect(k)}; got #{inspect(v)}"}}
          end
        end
      end,
    defp_update_field_error_fields:
      quote do
        defp update_field(%__MODULE__{} = state, {k, v})
             when k in [
                    @plymio_fontais_error_key_value,
                    @plymio_fontais_error_key_reason,
                    @plymio_fontais_error_key_format_message,
                    @plymio_fontais_error_key_format_order
                  ] do
          state |> struct!([{k, v}])
        end
      end,
    def_error_exception:
      quote do
        def exception(value)

        def exception(%__MODULE__{} = state) do
          state
        end

        def exception(value) do
          value |> new!
        end
      end,
    def_error_message_header:
      quote do
        @spec message(t) :: String.t()
        def message(error)
      end,
    def_error_message_clause_user_transform:
      quote do
        def message(
              %__MODULE__{@plymio_fontais_error_key_format_message => format_message} = state
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
    def_error_message_clause_default:
      quote do
        def message(%__MODULE__{} = state) do
          state
          |> format_error_message
        end
      end,
    def_error_message_format_message:
      quote do
        def format_error_message(
              %__MODULE__{
                @plymio_fontais_error_key_format_order => format_order
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
    def_error_new_error:
      quote do
        def new_result(opts \\ []) do
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

        defdelegate new_error_result(opts), to: __MODULE__, as: :new_result
      end
  }

  def __vekil__() do
    @vekil
  end
end
