defmodule Plymio.Fontais.Option.Utility do
  @moduledoc false

  import Plymio.Fontais.Error,
    only: [
      new_error_result: 1,
      new_bad_key_error_result: 2
    ]

  import Plymio.Fontais.Utility,
    only: [
      list_wrap_flat_just: 1
    ]

  @type opts :: Plymio.Fontais.opts()
  @type error :: Plymio.Fontais.error()
  @type result :: Plymio.Fontais.result()

  @type key :: Plymio.Fontais.key()
  @type keys :: Plymio.Fontais.keys()

  @type alias_key :: Plymio.Fontais.alias_key()
  @type alias_keys :: Plymio.Fontais.alias_keys()
  @type alias_value :: Plymio.Fontais.alias_value()

  @type aliases_kvs :: Plymio.Fontais.aliases_kvs()
  @type aliases_tuples :: Plymio.Fontais.aliases_tuples()
  @type aliases_dict :: Plymio.Fontais.aliases_dict()

  @type dict :: Plymio.Fontais.dict()

  @doc false

  @since "0.1.0"

  @spec normalise_key_spec(any) :: {:ok, keys} | {:error, error}

  def normalise_key_spec(value)

  def normalise_key_spec(value) when is_list(value) do
    cond do
      Keyword.keyword?(value) ->
        {:ok, value |> Keyword.keys() |> Enum.uniq()}

      true ->
        value
        |> Enum.reject(&is_atom/1)
        |> case do
          [] -> {:ok, value |> Enum.uniq()}
          not_atom_keys -> {:error, %KeyError{key: not_atom_keys, term: value}}
        end
    end
  end

  def normalise_key_spec(value) when is_map(value) do
    value |> Map.keys() |> normalise_key_spec
  end

  def normalise_key_spec(value) do
    new_error_result(m: "expected enum", v: value)
  end

  @since "0.1.0"

  @spec validate_key_list(any) :: {:ok, keys} | {:error, error}

  defp validate_key_list(keys)

  defp validate_key_list(keys) when is_list(keys) do
    keys
    |> Enum.reject(&is_atom/1)
    |> case do
      [] -> {:ok, keys}
      not_atoms -> not_atoms |> new_bad_key_error_result(keys)
    end
  end

  @doc false

  @since "0.1.0"

  def normalise_key_list(keys) do
    keys |> list_wrap_flat_just |> validate_key_list
  end

  @since "0.1.0"

  @spec validate_key_alias_dict(any) :: {:ok, aliases_dict} | {:error, error}

  defp validate_key_alias_dict(dict)

  defp validate_key_alias_dict(dict) when is_map(dict) do
    with true <- dict |> Map.keys() |> Enum.all?(&is_atom/1),
         true <- dict |> Map.values() |> Enum.all?(&is_atom/1) do
      {:ok, dict}
    else
      false -> new_error_result(m: "expected valid key alias dictionary", v: dict)
    end
  end

  @doc false

  @since "0.1.0"

  @spec normalise_key_alias_dict(any) :: {:ok, aliases_dict} | {:error, error}

  def normalise_key_alias_dict(dict)

  def normalise_key_alias_dict(dict) when is_map(dict) do
    dict |> validate_key_alias_dict
  end

  def normalise_key_alias_dict(dict) when is_list(dict) do
    cond do
      Keyword.keyword?(dict) ->
        dict |> Enum.into(%{}) |> validate_key_alias_dict

      true ->
        new_error_result(m: "expected valid alias dictionary", v: dict)
    end
  end

  def normalise_key_alias_dict(dict) do
    new_error_result(m: "expected valid alias dictionary", v: dict)
  end

  @doc false

  @since "0.1.0"

  @spec validate_key_dict(any) :: {:ok, aliases_dict} | {:error, error}

  defp validate_key_dict(dict)

  defp validate_key_dict(dict) when is_map(dict) do
    with true <- dict |> Map.keys() |> Enum.all?(&is_atom/1) do
      {:ok, dict}
    else
      false -> new_error_result(m: "expected valid key dictionary", v: dict)
    end
  end

  @doc false

  @since "0.1.0"

  @spec normalise_key_dict(any) :: {:ok, aliases_dict} | {:error, error}

  def normalise_key_dict(dict)

  def normalise_key_dict(dict) when is_map(dict) do
    dict |> validate_key_dict
  end

  def normalise_key_dict(dict) when is_list(dict) do
    cond do
      Keyword.keyword?(dict) ->
        dict |> Enum.into(%{})

      true ->
        new_error_result(m: "expected valid key dictionary", v: dict)
    end
  end

  def normalise_key_dict(dict) do
    new_error_result(m: "expected valid key dictionary", v: dict)
  end
end
