defmodule Plymio.Fontais.Utility do
  @moduledoc false

  use Plymio.Fontais.Attribute

  @type key :: Plymio.Fontais.key()
  @type keys :: Plymio.Fontais.keys()
  @type error :: Plymio.Fontais.error()

  import Plymio.Fontais.Error,
    only: [
      new_error_result: 1
    ]

  @doc false

  @since "0.1.0"

  @spec validate_key(any) :: {:ok, key} | {:error, error}

  def validate_key(key)

  def validate_key(key) when is_atom(key) do
    {:ok, key}
  end

  def validate_key(key) do
    new_error_result(m: "key invalid", v: key)
  end

  @doc false

  @since "0.1.0"

  @spec validate_keys(any) :: {:ok, keys} | {:error, error}

  def validate_keys(keys)

  def validate_keys(keys) when is_list(keys) do
    keys
    |> Enum.reject(&is_atom/1)
    |> case do
      [] ->
        {:ok, keys}

      not_atoms ->
        new_error_result(m: "keys invalid", v: not_atoms)
    end
  end

  def validate_keys(keys) do
    new_error_result(m: "keys invalid", v: keys)
  end

  @doc false

  @since "0.1.0"

  @spec normalise_keys(any) :: {:ok, keys} | {:error, error}

  def normalise_keys(keys) do
    keys
    |> list_wrap_flat_just
    |> validate_keys
  end

  @doc ~S"""
  `list_wrap_flat_just/1` wraps a value (if not already a list), flattens and removes `nils` at the *first / top* level.

  ## Examples

      iex> [{:a, 1}, nil, [{:b1, 12}, nil, {:b2, [nil, 22, nil]}], nil, {:c, 3}] |> list_wrap_flat_just
      [a: 1, b1: 12, b2: [nil, 22, nil], c: 3]

      iex> [[[nil, 42, nil]]] |> list_wrap_flat_just
      [42]

  """

  @spec list_wrap_flat_just(any) :: [any]

  def list_wrap_flat_just(value) do
    value
    |> List.wrap()
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
  end

  @doc ~S"""
  `list_wrap_flat_just_uniq/1` wraps a value (if not already a list), flattens, removes `nils` at
  the *first / top* level, and deletes duplicates (using `Enum.uniq/1`)

  ## Examples

      iex> [{:a, 1}, nil, [{:b1, 12}, nil, {:b2, [nil, 22, nil]}], nil, {:c, 3}, {:a, 1}, {:b1, 12}] |> list_wrap_flat_just_uniq
      [a: 1, b1: 12, b2: [nil, 22, nil], c: 3]

      iex> [nil, [42, [42, 42, nil]], 42] |> list_wrap_flat_just_uniq
      [42]

  """

  @spec list_wrap_flat_just_uniq(any) :: [any]

  def list_wrap_flat_just_uniq(value) do
    value
    |> List.wrap()
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
  end
end
