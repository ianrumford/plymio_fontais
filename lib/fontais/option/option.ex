defmodule Plymio.Fontais.Option do
  @moduledoc ~S"""
  Functions for Managing Keyword Options ("opts")

  See `Plymio.Fontais` for overview and other documentation terms.

  ## Documentation Terms

  ### *key*

  A *key* is an `Atom`.

  ### *key list*

  A *key list* is a list of *key*s.

  ### *key spec*

  A *key spec* is usually a *key list*.

  Alternatively a `Map` with `Atom` keys or a `Keyword` can be given and the (unique) keys will be used.

  ### *key alias dict*

  A *key alias dict* is usually a `Map` with `Atom` keys and values used for canonicalising keys (e.g. as the 2nd argument to `opts_canonical_keys/2`).

  Alternatively a `Keyword` with `Atom` values can be given and will be converted on the fly.

  ### *key dict*

  A *key alias dict* is usually a `Map` with `Atom` keys.

  Alternatively a `Keyword` with `Atom` values can be given and will be converted on the fly.
  """

  use Plymio.Fontais.Attribute

  @type key :: Plymio.Fontais.key()
  @type keys :: Plymio.Fontais.keys()
  @type opts :: Plymio.Fontais.opts()
  @type opzioni :: Plymio.Fontais.opzioni()
  @type error :: Plymio.Fontais.error()
  @type result :: Plymio.Fontais.result()

  @type aliases_tuples :: Plymio.Fontais.aliases_tuples()
  @type aliases_kvs :: Plymio.Fontais.aliases_kvs()
  @type aliases_dict :: Plymio.Fontais.aliases_dict()

  import Plymio.Fontais.Error,
    only: [
      new_error_result: 1,
      new_argument_error_result: 1,
      new_key_error_result: 2,
      new_bad_key_error_result: 2
    ]

  import Plymio.Fontais.Utility,
    only: [
      validate_key: 1
    ]

  import Plymio.Fontais.Option.Utility,
    only: [
      normalise_key_alias_dict: 1,
      normalise_key_list: 1,
      normalise_key_dict: 1
    ]

  @doc ~S"""
  `opts_normalise/` expects a *derivable opts* and returns `{:ok, opts}`.

  Any other argument causes `{:error, error}` to be returned.

  ## Examples

      iex> [] |> opts_normalise
      {:ok, []}

      iex> %{a: 1, b: 2, c: 3} |> opts_normalise
      {:ok, [a: 1, b: 2, c: 3]}

      iex> {:error, error} = %{"a" => 1, :b => 2, :c => 3} |> opts_normalise
      ...> error |> Exception.message
      "bad key \"a\" for: %{:b => 2, :c => 3, \"a\" => 1}"

      iex> {:error, error} = 42 |> opts_normalise
      ...> error |> Exception.message
      "opts not derivable, got: 42"

      iex> [a: nil, b: [:b1], c: [:c1, :c2, :c3]] |> opts_normalise
      {:ok, [a: nil, b: [:b1], c: [:c1, :c2, :c3]]}

  """

  @since "0.1.0"

  @spec opts_normalise(any) :: {:ok, opts} | {:error, error}

  def opts_normalise(value) do
    cond do
      Keyword.keyword?(value) ->
        {:ok, value}

      is_map(value) ->
        value
        |> Map.to_list()
        |> (fn tuples ->
              tuples
              |> Keyword.keyword?()
              |> case do
                true ->
                  {:ok, tuples}

                _ ->
                  tuples
                  |> Keyword.keys()
                  |> Enum.reject(&is_atom/1)
                  |> new_bad_key_error_result(value)
              end
            end).()

      true ->
        new_error_result(m: @plymio_fontais_error_message_opts_not_derivable, v: value)
    end
  end

  @doc ~S"""
  `opts_validate/1` returns `{:ok, opts}` if the argument is an *opts*.

  Any other argument causes `{:error, error}` to be returned.

  ## Examples

      iex> [] |> opts_validate
      {:ok, []}

      iex> %{a: 1, b: 2, c: 3} |> opts_validate
      {:error, %ArgumentError{message: "opts invalid, got: %{a: 1, b: 2, c: 3}"}}

      iex> %{"a" => 1, :b => 2, :c => 3} |> opts_validate
      {:error, %ArgumentError{message: "opts invalid, got: %{:b => 2, :c => 3, \"a\" => 1}"}}

      iex> 42 |> opts_validate
      {:error, %ArgumentError{message: "opts invalid, got: 42"}}

      iex> [a: nil, b: [:b1], c: [:c1, :c2, :c3]] |> opts_validate
      {:ok, [a: nil, b: [:b1], c: [:c1, :c2, :c3]]}

  """

  @since "0.1.0"

  @spec opts_validate(any) :: {:ok, opts} | {:error, error}

  def opts_validate(value) do
    case Keyword.keyword?(value) do
      true -> {:ok, value}
      _ -> new_error_result(m: @plymio_fontais_error_message_opts_invalid, v: value)
    end
  end

  @doc ~S"""
  `opts_merge/` takes one or more *derivable opts*, merges them and returns `{:ok, opts}`.

  Any other argument causes `{:error, error}` to be returned.

  ## Examples

      iex> [] |> opts_merge
      {:ok, []}

      iex> [a: 1, b: 2, c: 3] |> opts_merge
      {:ok, [a: 1, b: 2, c: 3]}

      iex> [[a: 1], [b: 2], [c: 3]] |> opts_merge
      {:ok, [a: 1, b: 2, c: 3]}

      iex> %{a: 1, b: 2, c: 3} |> opts_merge
      {:ok, [a: 1, b: 2, c: 3]}

      iex> [%{a: 1, b: 2, c: 3}, [d: 4]] |> opts_merge
      {:ok, [a: 1, b: 2, c: 3, d: 4]}

      iex> {:error, error} = [[d: 4], %{"a" => 1, :b => 2, :c => 3}] |> opts_merge
      ...> error |> Exception.message
      "bad key \"a\" for: %{:b => 2, :c => 3, \"a\" => 1}"

      iex> {:error, error} = 42 |> opts_merge
      ...> error |> Exception.message
      "opts not derivable, got: 42"

  """

  @since "0.1.0"

  @spec opts_merge(any) :: {:ok, opts} | {:error, error}

  def opts_merge(value) do
    cond do
      Keyword.keyword?(value) ->
        {:ok, value}

      is_map(value) ->
        value |> opts_normalise

      is_list(value) ->
        value
        |> Enum.reduce_while([], fn opts, collated_opts ->
          with {:ok, new_opts} <- opts |> opts_normalise do
            {:cont, collated_opts ++ new_opts}
          else
            {:error, %{__struct__: _}} = result -> {:halt, result}
          end
        end)
        |> case do
          {:error, %{__struct__: _}} = result -> result
          opts -> {:ok, opts}
        end

      true ->
        new_error_result(m: @plymio_fontais_error_message_opts_not_derivable, v: value)
    end
  end

  @doc ~S"""
  `opts_canonical_keys/2` takes a *derivable opts*, together with a *key alias dict*.

  Each key in the `opts` is replaced with its (canonical) value from the dictionary, returning `{:ok, canon_opts}`.

  If there are any unknown keys, `{:error, error}`, where `error` is a `KeyError`, will be returned.

  ## Examples

      iex> [a: 1, b: 2, c: 3] |> opts_canonical_keys(%{a: :x, b: :y, c: :z})
      {:ok, [x: 1, y: 2, z: 3]}

      iex> [a: 1, b: 2, c: 3] |> opts_canonical_keys([a: :x, b: :y, c: :z])
      {:ok, [x: 1, y: 2, z: 3]}

      iex> [a: 11, p: 1, b: 22, q: 2, c: 33, r: 3] |> opts_canonical_keys(%{a: :x, b: :y, c: :z})
      {:error, %KeyError{key: [:p, :q, :r], term: %{a: :x, b: :y, c: :z}}}

      iex> [a: 1, b: 2, c: 3] |> opts_canonical_keys([a_canon: :a, b_canon: [:b], c_canon: [:c, :cc]])
      {:error, %ArgumentError{message: "expected valid key alias dictionary, got: %{a_canon: :a, b_canon: [:b], c_canon: [:c, :cc]}"}}

  """

  @since "0.1.0"

  @spec opts_canonical_keys(any, any) :: {:ok, opts} | {:error, error}

  def opts_canonical_keys(opts, dict)

  def opts_canonical_keys([], _dict) do
    {:ok, []}
  end

  def opts_canonical_keys(opts, dict) do
    with {:ok, opts} <- opts |> opts_normalise,
         {:ok, dict} <- dict |> normalise_key_alias_dict do
      # reject known_keys
      opts
      |> Enum.reject(fn {k, _v} -> Map.has_key?(dict, k) end)
      |> case do
        # no unknown keys
        [] ->
          canon_tuples =
            opts
            |> Enum.map(fn {k, v} -> {Map.get(dict, k), v} end)

          {:ok, canon_tuples}

        unknown_tuples ->
          unknown_tuples |> new_key_error_result(dict)
      end
    else
      {:error, _} = result -> result
    end
  end

  @doc ~S"""
  `opts_maybe_canonical_keys/2` takes a *derivable opts*, together with a *key alias dict*.

  If an *opts* key exists in the dictionary, it is replaced with its (canonical) value. Otherwise the key is unchanged.

  `{:ok, opts}` is returned.

  ## Examples

      iex> [a: 1, b: 2, c: 3] |> opts_maybe_canonical_keys(%{a: :x, b: :y, c: :z})
      {:ok, [x: 1, y: 2, z: 3]}

      iex> [a: 11, p: 1, b: 22, q: 2, c: 33, r: 3]
      ...> |> opts_maybe_canonical_keys(%{a: :x, b: :y, c: :z})
      {:ok, [x: 11, p: 1, y: 22, q: 2, z: 33, r: 3]}

  """

  @since "0.1.0"

  @spec opts_maybe_canonical_keys(any, any) :: {:ok, opts} | {:error, error}

  def opts_maybe_canonical_keys(opts, dict) do
    with {:ok, opts} <- opts |> opts_normalise,
         {:ok, dict} <- dict |> normalise_key_alias_dict do
      opts =
        opts
        |> Enum.map(fn {k, v} -> {Map.get(dict, k, k), v} end)

      {:ok, opts}
    else
      {:error, _} = result -> result
    end
  end

  @doc ~S"""
  `opts_take_canonical_keys/2` takes a *derivable opts*, together with a *key alias dict*.

  It first calls `opts_maybe_canonical_keys/2` to convert all known
  keys to their canonical values, and then takes only the canonical keys returning `{:ok, opts}`.

  ## Examples

      iex> [a: 1, b: 2, c: 3] |> opts_take_canonical_keys(%{a: :x, b: :y, c: :z})
      {:ok, [x: 1, y: 2, z: 3]}

      iex> [a: 11, p: 1, b: 22, q: 2, c: 33, r: 3]
      ...> |> opts_take_canonical_keys(%{a: :x, b: :y, c: :z})
      {:ok, [x: 11, y: 22, z: 33]}

  """

  @since "0.1.0"

  @spec opts_take_canonical_keys(any, any) :: {:ok, opts} | {:error, error}

  def opts_take_canonical_keys(opts, dict) do
    with {:ok, dict} <- dict |> normalise_key_alias_dict,
         {:ok, opts} <- opts |> opts_maybe_canonical_keys(dict) do
      {:ok, opts |> Keyword.take(dict |> Map.values())}
    else
      {:error, _} = result -> result
    end
  end

  @doc ~S"""
  `canonical_keys/2` takes a *key list* and *key alias dict* and replaces each key with its canonical value from the dictionary, returning `{:ok, canonical_keys}`.

  If there are any unknown keys `{:error, error}`, where `error` is a `KeyError`, will be returned.

  ## Examples

      iex> [:a, :b, :c] |> canonical_keys(%{a: :p, b: :q, c: :r})
      {:ok, [:p,:q,:r]}

      iex> [:a, :b, :c] |> canonical_keys(%{a: 1, b: 2, c: 3})
      {:ok, [1,2,3]}

      iex> [:a, :x, :b, :y, :c, :z] |> canonical_keys(%{a: 1, b: 2, c: 3})
      {:error, %KeyError{key: [:x, :y, :z], term: %{a: 1, b: 2, c: 3}}}

  """

  @spec canonical_keys(any, any) :: {:ok, keys} | {:error, error}

  def canonical_keys(keys, dict) do
    with {:ok, keys} <- keys |> normalise_key_list,
         {:ok, dict} <- dict |> normalise_key_dict do
      keys
      |> Enum.reject(fn k -> Map.has_key?(dict, k) end)
      |> case do
        # no unknown keys
        [] ->
          canon_keys = keys |> Enum.map(fn k -> dict |> Map.get(k) end)

          {:ok, canon_keys}

        unknown_keys ->
          unknown_keys |> new_key_error_result(dict)
      end
    else
      {:error, _} = result -> result
    end
  end

  @doc ~S"""
  `canonical_key/2` takes a key together with a *key dict* and replaces the key with its canonical value from the dictionary, returning `{:ok, canonical_key}`.

  If the key is unknown, `{:error, error}`, `error` is a `KeyError`, will be returned.

  ## Examples

      iex> :b |> canonical_key(%{a: :p, b: :q, c: :r})
      {:ok, :q}

      iex> :a |> canonical_key(%{a: 1, b: 2, c: 3})
      {:ok, 1}

      iex> :x |> canonical_key(%{a: 1, b: 2, c: 3})
      {:error, %KeyError{key: :x, term: %{a: 1, b: 2, c: 3}}}

  """

  @spec canonical_key(any, any) :: {:ok, key} | {:error, error}

  def canonical_key(key, dict) do
    with {:ok, key} <- key |> validate_key,
         {:ok, keys} <- [key] |> canonical_keys(dict) do
      {:ok, keys |> hd}
    else
      {:error, %KeyError{} = error} -> {:error, error |> struct!(key: key)}
      {:error, _} = result -> result
    end
  end

  @doc ~S"""
  `opzioni_normalise/1` takes a value tries to normalise it into an *opzioni*, returning `{:ok, opzioni}`.

  Any other argument causes `{:error, error}` to be returned.

  ## Examples

      iex> [] |> opzioni_normalise
      {:ok, []}

      iex> [a: 1, b: 2, c: 3] |> opzioni_normalise
      {:ok, [[a: 1, b: 2, c: 3]]}

      iex> %{a: 1, b: 2, c: 3} |> opzioni_normalise
      {:ok, [[a: 1, b: 2, c: 3]]}

      iex> [ [a: 1, b: 2, c: 3], %{x: 10, y: 11, z: 12}] |> opzioni_normalise
      {:ok, [[a: 1, b: 2, c: 3], [x: 10, y: 11, z: 12]]}

      iex> {:error, error} = %{"a" => 1, :b => 2, :c => 3} |> opzioni_normalise
      ...> error |> Exception.message
      "bad key \"a\" for: %{:b => 2, :c => 3, \"a\" => 1}"

      iex> {:error, error} = 42 |> opzioni_normalise
      ...> error |> Exception.message
      "opzioni invalid, got: 42"

      iex> [a: nil, b: [:b1], c: [:c1, :c2, :c3]] |> opzioni_normalise
      {:ok, [[a: nil, b: [:b1], c: [:c1, :c2, :c3]]]}

  """

  @since "0.1.0"

  @spec opzioni_normalise(any) :: {:ok, opts} | {:error, error}

  def opzioni_normalise(opzioni \\ [])

  def opzioni_normalise([]) do
    {:ok, []}
  end

  def opzioni_normalise(opzioni) do
    cond do
      Keyword.keyword?(opzioni) ->
        {:ok, [opzioni]}

      is_list(opzioni) ->
        opzioni
        |> Enum.reduce_while([], fn
          [], opzioni ->
            {:cont, opzioni}

          item, opzioni ->
            with {:ok, new_opzioni} <- item |> opzioni_normalise do
              {:cont, opzioni ++ new_opzioni}
            else
              {:error, %{__struct__: _}} = result -> {:halt, result}
            end
        end)
        |> case do
          {:error, %{__struct__: _}} = result ->
            result

          opzioni ->
            {:ok, opzioni}
        end

      is_map(opzioni) ->
        with {:ok, opts} <- opzioni |> opts_normalise do
          {:ok, [opts]}
        else
          {:error, %{__exception__: true}} = result -> result
        end

      true ->
        new_error_result(m: @plymio_fontais_error_message_opzioni_invalid, v: opzioni)
    end
  end

  @doc ~S"""
  `opzioni_validate/1` takes a value and validates it is an *opzioni*, returning `{:ok, opzioni}`.

  Any other argument causes `{:error, error}` to be returned.

  ## Examples

      iex> [] |> opzioni_validate
      {:ok, []}

      iex> [[a: 1, b: 2, c: 3]] |> opzioni_validate
      {:ok, [[a: 1, b: 2, c: 3]]}

      iex> {:error, error} = [a: 1, b: 2, c: 3] |> opzioni_validate
      ...> error |> Exception.message
      "opts invalid, got: {:a, 1}"

      iex> {:error, error} = %{a: 1, b: 2, c: 3} |> opzioni_validate
      ...> error |> Exception.message
      "opzioni invalid, got: %{a: 1, b: 2, c: 3}"

      iex> {:error, error} = [[a: 1, b: 2, c: 3], %{x: 10, y: 11, z: 12}] |> opzioni_validate
      ...> error |> Exception.message
      "opts invalid, got: %{x: 10, y: 11, z: 12}"

      iex> {:error, error} = 42 |> opzioni_validate
      ...> error |> Exception.message
      "opzioni invalid, got: 42"

  """

  @since "0.1.0"

  @spec opzioni_validate(any) :: {:ok, opts} | {:error, error}

  def opzioni_validate(opzioni \\ [])

  def opzioni_validate(opzioni) when is_list(opzioni) do
    opzioni
    |> Enum.reduce_while([], fn opts, opzioni ->
      opts
      |> opts_validate
      |> case do
        {:ok, opts} ->
          {:cont, [opts | opzioni]}

        {:error, %{__struct__: _}} = result ->
          {:halt, result}
      end
    end)
    |> case do
      {:error, %{__exception__: true}} = result -> result
      opzioni -> {:ok, opzioni |> Enum.reverse()}
    end
  end

  def opzioni_validate(opzioni) do
    new_argument_error_result("opzioni invalid, got: #{inspect(opzioni)}")
  end

  @doc ~S"""
  `opzioni_merge/` takes one or more *opzioni*, normalises each one and merges them
  to return `{:ok, opzioni}`.

  Empty *opts* are removed.

  Any other argument causes `{:error, error}` to be returned.

  ## Examples

      iex> [] |> opzioni_merge
      {:ok, []}

      iex> [a: 1, b: 2, c: 3] |> opzioni_merge
      {:ok, [[a: 1, b: 2, c: 3]]}

      iex> [[a: 1], [b: 2], [c: 3]] |> opzioni_merge
      {:ok, [[a: 1], [b: 2], [c: 3]]}

      iex> [[[a: 1], [b: 2]], [c: 3], [[d: 4]]] |> opzioni_merge
      {:ok, [[a: 1], [b: 2], [c: 3], [d: 4]]}

      iex> [[a: 1], [], [b: 2], [], [c: 3]] |> opzioni_merge
      {:ok, [[a: 1], [b: 2], [c: 3]]}

      iex> %{a: 1, b: 2, c: 3} |> opzioni_merge
      {:ok, [[a: 1, b: 2, c: 3]]}

      iex> [%{a: 1, b: 2, c: 3}, [d: 4]] |> opzioni_merge
      {:ok, [[a: 1, b: 2, c: 3], [d: 4]]}

      iex> {:error, error} = [[d: 4], %{"a" => 1, :b => 2, :c => 3}] |> opzioni_merge
      ...> error |> Exception.message
      "bad key \"a\" for: %{:b => 2, :c => 3, \"a\" => 1}"

      iex> {:error, error} = 42 |> opzioni_merge
      ...> error |> Exception.message
      "opzioni invalid, got: 42"

  """

  @since "0.1.0"

  @spec opzioni_merge(any) :: {:ok, opzioni} | {:error, error}

  def opzioni_merge(opzioni)

  def opzioni_merge(value) when is_list(value) do
    value
    |> opzioni_normalise
    |> case do
      {:ok, opzioni} ->
        opzioni =
          opzioni
          |> Enum.filter(fn
            [] -> false
            _ -> true
          end)

        {:ok, opzioni}

      _ ->
        value
        |> Enum.reduce_while([], fn opzioni, opzionis ->
          with {:ok, opzioni} <- opzioni |> opzioni_normalise do
            {:cont, [opzioni | opzionis]}
          else
            {:error, %{__struct__: _}} = result -> {:halt, result}
          end
        end)
        |> case do
          {:error, %{__struct__: _}} = result ->
            result

          opzionis ->
            opzioni =
              opzionis
              |> Enum.reverse()
              |> Enum.reduce([], fn v, s -> s ++ v end)
              |> Enum.filter(fn
                [] -> false
                _ -> true
              end)

            {:ok, opzioni}
        end
    end
  end

  def opzioni_merge(value) when is_map(value) do
    value |> Map.to_list() |> opzioni_merge
  end

  def opzioni_merge(opzioni) do
    opzioni |> opzioni_validate
  end

  @doc ~S"""
  `opzioni_flatten/1` takes a value, calls `opzioni_normalise/1` and then merges all the individual *opts* into a single *opts*.

  ## Examples

      iex> [] |> opzioni_flatten
      {:ok, []}

      iex> [a: 1, b: 2, c: 3] |> opzioni_flatten
      {:ok, [a: 1, b: 2, c: 3]}

      iex> [[a: 1], [b: 2], [c: 3]] |> opzioni_flatten
      {:ok, [a: 1, b: 2, c: 3]}

      iex> [[a: 1], [[b: 2], [c: 3]]] |> opzioni_flatten
      {:ok, [a: 1, b: 2, c: 3]}

      iex> %{a: 1, b: 2, c: 3} |> opzioni_flatten
      {:ok, [a: 1, b: 2, c: 3]}

      iex> {:ok, opts} = [[a: 1, b: 2, c: 3], %{x: 10, y: 11, z: 12}] |> opzioni_flatten
      ...> opts |> Enum.sort
      [a: 1, b: 2, c: 3, x: 10, y: 11, z: 12]

      iex> {:error, error} = %{"a" => 1, :b => 2, :c => 3} |> opzioni_flatten
      ...> error |> Exception.message
      "bad key \"a\" for: %{:b => 2, :c => 3, \"a\" => 1}"

      iex> {:error, error} = 42 |> opzioni_flatten
      ...> error |> Exception.message
      "opzioni invalid, got: 42"

      iex> [a: nil, b: [:b1], c: [:c1, :c2, :c3]] |> opzioni_flatten
      {:ok, [a: nil, b: [:b1], c: [:c1, :c2, :c3]]}

  """

  @since "0.1.0"

  @spec opzioni_flatten(any) :: {:ok, opts} | {:error, error}

  def opzioni_flatten(opzioni \\ [])

  def opzioni_flatten([]) do
    {:ok, []}
  end

  def opzioni_flatten(opzioni) do
    opzioni
    |> Keyword.keyword?()
    |> case do
      true ->
        {:ok, opzioni}

      _ ->
        with {:ok, opzioni} <- opzioni |> opzioni_normalise do
          {:ok, opzioni |> Enum.flat_map(& &1)}
        else
          {:error, %{__exception__: true}} = result -> result
        end
    end
  end

  @doc ~S"""
  `opts_get/3` take a *derivable opts*, *key* and default and returns
  the *last* value for the key (or default) as `{:ok, value_or_default}`.

  Note this is different to `Keyword.get/3` that returns the *first* value.

  ## Examples

      iex> [a: 1, b: 2, c: 3] |> opts_get(:a)
      {:ok, 1}

      iex> [a: 11, b: 21, c: 31, a: 12, b: 22, c: 32, a: 13, b: 23, c: 33] |> opts_get(:c)
      {:ok, 33}

      iex> [a: 1, b: 2, c: 3] |> opts_get(:d, 4)
      {:ok, 4}

      iex> {:error, error} = [a: 1, b: 2, c: 3] |> opts_get("a")
      ...> error |> Exception.message
      "key invalid, got: a"

      iex> {:error, error} = 42 |> opts_get(:a)
      ...> error |> Exception.message
      "opts not derivable, got: 42"

      iex> {:error, error} = [{:a, 1}, {:b, 2}, {"c", 3}] |> opts_get(:a)
      ...> error |> Exception.message
      "opts not derivable, got: [{:a, 1}, {:b, 2}, {\"c\", 3}]"

  """

  @since "0.1.0"

  @spec opts_get(any, any, any) :: {:ok, any} | {:error, error}

  def opts_get(opts, key, default \\ nil) do
    with {:ok, opts} <- opts |> opts_normalise,
         {:ok, key} <- key |> validate_key do
      {:ok, opts |> Enum.reverse() |> Keyword.get(key, default)}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  @doc ~S"""
  `opts_get_values/3` take a *derivable opts*, *key* and default and,
  if the derived opts has the *key*, returns the values
  (`Keyword.get_values/21`).

  Otherwise the "listified" (`List.wrap/1`) default is returned.

  ## Examples

      iex> [a: 1, b: 2, c: 3] |> opts_get_values(:a)
      {:ok, [1]}

      iex> [a: 11, b: 21, c: 31, a: 12, b: 22, c: 32, a: 13, b: 23, c: 33] |> opts_get_values(:c)
      {:ok, [31, 32, 33]}

      iex> [a: 1, b: 2, c: 3] |> opts_get_values(:d, 4)
      {:ok, [4]}

      iex> [a: 1, b: 2, c: 3] |> opts_get_values(:d, [41, 42, 43])
      {:ok, [41, 42, 43]}

      iex> {:error, error} = [a: 1, b: 2, c: 3] |> opts_get_values("a")
      ...> error |> Exception.message
      "key invalid, got: a"

      iex> {:error, error} = 42 |> opts_get_values(:a)
      ...> error |> Exception.message
      "opts not derivable, got: 42"

  """

  @since "0.1.0"

  @spec opts_get_values(any, any, any) :: {:ok, list} | {:error, error}

  def opts_get_values(opts, key, default \\ nil) do
    with {:ok, opts} <- opts |> opts_normalise,
         {:ok, key} <- key |> validate_key do
      opts
      |> Keyword.has_key?(key)
      |> case do
        true ->
          {:ok, opts |> Keyword.get_values(key)}

        _ ->
          {:ok, default |> List.wrap()}
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  @doc ~S"""
  `opts_fetch/2` take a *derivable opts* and *key* and and returns
  the *last* value for the key (or default) as `{:ok, value}`.

  Note this is different to `Keyword.fetch/2` that returns the *first* value.

  ## Examples

      iex> [a: 1, b: 2, c: 3] |> opts_fetch(:a)
      {:ok, 1}

      iex> [a: 11, b: 21, c: 31, a: 12, b: 22, c: 32, a: 13, b: 23, c: 33] |> opts_fetch(:c)
      {:ok, 33}

      iex> {:error, error} = [a: 1, b: 2, c: 3] |> opts_fetch(:d)
      ...> error |> Exception.message
      "key :d not found in: [a: 1, b: 2, c: 3]"

      iex> {:error, error} = [a: 1, b: 2, c: 3] |> opts_fetch("a")
      ...> error |> Exception.message
      "key invalid, got: a"

      iex> {:error, error} = 42 |> opts_fetch(:a)
      ...> error |> Exception.message
      "opts not derivable, got: 42"

      iex> {:error, error} = [{:a, 1}, {:b, 2}, {"c", 3}] |> opts_fetch(:a)
      ...> error |> Exception.message
      "opts not derivable, got: [{:a, 1}, {:b, 2}, {\"c\", 3}]"

  """

  @since "0.1.0"

  @spec opts_fetch(any, any) :: {:ok, any} | {:error, error}

  def opts_fetch(opts, key) do
    with {:ok, norm_opts} <- opts |> opts_normalise,
         {:ok, key} <- key |> validate_key do
      norm_opts
      |> Enum.reverse()
      |> Keyword.fetch(key)
      |> case do
        {:ok, _} = result ->
          result

        :error ->
          new_key_error_result(key, opts)
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  @doc ~S"""
  `opts_put/3` take a *derivable opts*, *key* and a value and *appends* the `{key,value}` tuple returnsing `{:ok, opts}`.

  Note this is different to `Keyword.put/2` which prepends the new `{key,value}` tuple and drops all the other for the same key.

  ## Examples

      iex> [a: 11, b: 2, c: 3] |> opts_put(:a, 12)
      {:ok, [a: 11, b: 2, c: 3, a: 12]}

      iex> [a: 1, b: 2, c: 3] |> opts_put(:d, 4)
      {:ok, [a: 1, b: 2, c: 3, d: 4]}

      iex> {:error, error} = [a: 1, b: 2, c: 3] |> opts_put("a", 99)
      ...> error |> Exception.message
      "key invalid, got: a"

      iex> {:error, error} = 42 |> opts_put(:a, nil)
      ...> error |> Exception.message
      "opts not derivable, got: 42"

      iex> {:error, error} = [{:a, 1}, {:b, 2}, {"c", 3}] |> opts_put(:a, nil)
      ...> error |> Exception.message
      "opts not derivable, got: [{:a, 1}, {:b, 2}, {\"c\", 3}]"

  """

  @since "0.1.0"

  @spec opts_put(any, any, any) :: {:ok, any} | {:error, error}

  def opts_put(opts, key, value) do
    with {:ok, opts} <- opts |> opts_normalise,
         {:ok, key} <- key |> validate_key do
      {:ok, opts ++ [{key, value}]}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  @doc ~S"""
  `opts_put_new/3` take a *derivable opts*, *key* and a value.

  If the *key* already exsists in the derived opts, they are returned unchanged as `{:ok, opts}`.

  Otherwise `opts_put/3` is called to *append* the new `{key,value}`, again returning `{:ok, opts}`.

  ## Examples

      iex> [a: 11, b: 2, c: 3] |> opts_put_new(:a, 12)
      {:ok, [a: 11, b: 2, c: 3]}

      iex> [a: 1, b: 2, c: 3] |> opts_put_new(:d, 4)
      {:ok, [a: 1, b: 2, c: 3, d: 4]}

      iex> {:error, error} = [a: 1, b: 2, c: 3] |> opts_put_new("a", 99)
      ...> error |> Exception.message
      "key invalid, got: a"

      iex> {:error, error} = 42 |> opts_put_new(:a)
      ...> error |> Exception.message
      "opts not derivable, got: 42"

      iex> {:error, error} = [{:a, 1}, {:b, 2}, {"c", 3}] |> opts_put_new(:a)
      ...> error |> Exception.message
      "opts not derivable, got: [{:a, 1}, {:b, 2}, {\"c\", 3}]"

  """

  @since "0.1.0"

  @spec opts_put_new(any, any, any) :: {:ok, any} | {:error, error}

  def opts_put_new(opts, key, value \\ nil) do
    with {:ok, opts} <- opts |> opts_normalise,
         {:ok, key} <- key |> validate_key do
      opts
      |> Keyword.has_key?(key)
      |> case do
        true ->
          {:ok, opts}

        _ ->
          opts |> opts_put(key, value)
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  @doc ~S"""
  `opts_drop/3` take a *derivable opts*, *key* and delete *all* occurences of the *key* returning `{ok, opts}`.

  It essentially wraps `Keyword.delete/2`.

  ## Examples

      iex> [a: 1, b: 2, c: 3] |> opts_drop(:a)
      {:ok, [b: 2, c: 3]}

      iex> [a: 11, b: 21, c: 31, a: 12, b: 22, c: 32, a: 13, b: 23, c: 33] |> opts_drop([:a, :c])
      {:ok, [b: 21, b: 22, b: 23]}

      iex> {:error, error} = [a: 1, b: 2, c: 3] |> opts_drop([:b, "a"])
      ...> error |> Exception.message
      "bad key \"a\" for: [:b, \"a\"]"

      iex> {:error, error} = 42 |> opts_drop(:a)
      ...> error |> Exception.message
      "opts not derivable, got: 42"

      iex> {:error, error} = [{:a, 1}, {:b, 2}, {"c", 3}] |> opts_drop(:a)
      ...> error |> Exception.message
      "opts not derivable, got: [{:a, 1}, {:b, 2}, {\"c\", 3}]"

  """

  @since "0.1.0"

  @spec opts_drop(any, any) :: {:ok, opts} | {:error, error}

  def opts_drop(opts, keys) do
    with {:ok, opts} <- opts |> opts_normalise,
         {:ok, keys} <- keys |> normalise_key_list do
      {:ok, opts |> Keyword.drop(keys)}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  @doc ~S"""
  `opts_reduce/3` take a *derivable opts*, realises the derived opts, and calls `Keyword.new/1` to take the *last* `{key, value}` tuple for the same key, returning `{:ok, reduced_opts}`.

  ## Examples

      iex> [a: 1, b: 2, c: 3] |> opts_reduce
      {:ok, [a: 1, b: 2, c: 3]}

      iex> {:ok, opts} = %{a: 1, b: 2, c: 3} |> opts_reduce
      ...> opts |> Enum.sort
      [a: 1, b: 2, c: 3]

      iex> [a: 11, b: 21, c: 31, a: 12, b: 22, c: 32, a: 13, b: 23, c: 33] |> opts_reduce
      {:ok, [a: 13, b: 23, c: 33]}

      iex> {:error, error} = 42 |> opts_reduce
      ...> error |> Exception.message
      "opts not derivable, got: 42"

      iex> {:error, error} = [{:a, 1}, {:b, 2}, {"c", 3}] |> opts_reduce
      ...> error |> Exception.message
      "opts not derivable, got: [{:a, 1}, {:b, 2}, {\"c\", 3}]"

  """

  @since "0.1.0"

  @spec opts_reduce(any) :: {:ok, opts} | {:error, error}

  def opts_reduce(opts \\ [])

  def opts_reduce([]) do
    {:ok, []}
  end

  def opts_reduce(opts) do
    with {:ok, opts} <- opts |> opts_normalise do
      {:ok, opts |> Keyword.new()}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  @doc ~S"""
  `opts_create_aliases_tuples/1` takes an *opts* where the keys are the canonical key names, and their values are zero (nil), one or more aliases for the canonical key.

  A `Keyword` is returned where each key is an alias and its value the canonical key.

  The canonical key also has an entry for itself with the same value.

  ## Examples

      iex> [a: nil, b: [:b1], c: [:c1, :c2, :c3]] |> opts_create_aliases_tuples
      [a: :a, b: :b, b1: :b, c: :c, c1: :c, c2: :c, c3: :c]

  """

  @since "0.1.0"

  @spec opts_create_aliases_tuples(aliases_kvs) :: aliases_tuples

  def opts_create_aliases_tuples(aliases) do
    aliases
    |> Enum.map(fn
      {k, nil} ->
        {k, k}

      {k, a} ->
        [k | a |> List.wrap()]
        |> Enum.uniq()
        |> Enum.map(fn a -> {a, k} end)
    end)
    |> List.flatten()
  end

  @doc ~S"""
  `opts_create_aliases_dict/1` does the same job as `opts_create_aliases_tuples/1` but returns a *key alias dict*.

  ## Examples

      iex> [a: nil, b: [:b1], c: [:c1, :c2, :c3]] |> opts_create_aliases_dict
      %{a: :a, b: :b, b1: :b, c: :c, c1: :c, c2: :c, c3: :c}

  """

  @since "0.1.0"

  @spec opts_create_aliases_dict(aliases_kvs) :: aliases_dict

  def opts_create_aliases_dict(aliases) do
    aliases
    |> opts_create_aliases_tuples
    |> Enum.into(%{})
  end
end
