defmodule Plymio.Fontais.Guard do
  @moduledoc ~S"""
  Guards (`Kernel.defguard/1`).

  See `Plymio.Fontais` for overview and documentation terms.

  Since the guards are macros, the module must be required (`Kernel.SpecialForms.require/2`) or imported (`Kernel.SpeicalForms.import/2`) first.
  """

  use Plymio.Fontais.Attribute

  @doc ~S"""
  `the_unset_value/0` returns a unique, randomish `Atom`.

  The actual value does not matter; it is intended to be used
  e.g. as the default value for a `struct` field.

  *The Unset Value* is used by `is_value_set/1` and `is_value_unset/1`.

  The value is also available at compile time as
  `@plymio_fontais_the_unset_value` after:

      use Plymio.Fontais.Attribute

  ## Examples

      iex> is_atom(the_unset_value())
      true

  """

  @since "0.1.0"

  @spec the_unset_value() :: atom

  def the_unset_value() do
    @plymio_fontais_the_unset_value
  end

  @doc ~S"""
  `is_value_unset/1` is a guard (`Kernel.defguard/1`) that tests whether its argument is the same as *the unset value*, returning `true` if so, otherwise `false`.

  ## Examples

      iex> 42 |> is_value_unset
      false

      iex> :this_is_set |> is_value_unset
      false

      iex> value = the_unset_value()
      ...> value |> is_value_unset
      true

  """

  @since "0.1.0"

  defguard is_value_unset(value) when value == @plymio_fontais_the_unset_value

  @doc ~S"""
  `is_value_set/1` is a guard (`Kernel.defguard/1`) that tests whether its argument is **not** the same as *the unset value*, returning `true` if so, otherwise `false`.

  ## Examples

      iex> 42 |> is_value_set
      true

      iex> :this_is_set |> is_value_set
      true

      iex> value = the_unset_value()
      ...> value |> is_value_set
      false

  """

  @since "0.1.0"

  defguard is_value_set(value) when value != @plymio_fontais_the_unset_value

  @doc ~S"""
  `is_value_unset_or_nil/1`  is a guard (`Kernel.defguard/1`) that tests whether its argument is *the unset value* or `nil`, returning `true` if so, otherwise `false`.

  ## Examples

      iex> 42 |> is_value_unset_or_nil
      false

      iex> :this_is_set |> is_value_unset_or_nil
      false

      iex> value = the_unset_value()
      ...> value |> is_value_unset_or_nil
      true

      iex> nil |> is_value_unset_or_nil
      true

  """

  @since "0.1.0"

  defguard is_value_unset_or_nil(value) when is_nil(value) or is_value_unset(value)

  @doc ~S"""
  `is_filled_list/1` tests whether its argument is a `List` and has at least one entry, returning `true` if so, otherwise `false`.

  ## Examples

      iex> [1,2,3] |> is_filled_list
      true

      iex> [] |> is_filled_list
      false

      iex> fun = fn
      ...>   v when is_filled_list(v) -> true
      ...>   _ -> false
      ...> end
      ...> true = [1,2,3] |> fun.()
      ...> false = [] |> fun.()
      ...> false = 42 |> fun.()
      ...> false = :not_a_list |> fun.()
      false

  """

  @since "0.1.0"

  defguard is_filled_list(value) when is_list(value) and length(value) > 0

  @doc ~S"""
  `is_empty_list/1` tests whether its argument is a `List` and is empty, returning `true` if so, otherwise `false`.

  ## Examples

      iex> [1,2,3] |> is_empty_list
      false

      iex> [] |> is_empty_list
      true

      iex> fun = fn
      ...>   v when is_empty_list(v) -> true
      ...>   _ -> false
      ...> end
      ...> false = [1,2,3] |> fun.()
      ...> true = [] |> fun.()
      ...> false = 42 |> fun.()
      ...> false = :not_a_list |> fun.()
      false

  """

  @since "0.1.0"

  defguard is_empty_list(value) when is_list(value) and length(value) == 0

  @doc ~S"""
  `is_positive_integer/1` tests whether its argument is an `Integer` and `>= 0`, returning `true` if so, otherwise `false`.

  ## Examples

      iex> 42 |> is_positive_integer
      true

      iex> 0 |> is_positive_integer
      true

      iex> -1 |> is_positive_integer
      false

      iex> fun = fn
      ...>   v when is_positive_integer(v) -> true
      ...>   _ -> false
      ...> end
      ...> false = [1,2,3] |> fun.()
      ...> false = [] |> fun.()
      ...> true = 42 |> fun.()
      ...> false = :not_an_integer |> fun.()
      false

  """

  @since "0.1.0"

  defguard is_positive_integer(value) when is_integer(value) and value >= 0

  @doc ~S"""
  `is_negative_integer/1` tests whether its argument is an `Integer` and `< 0`, returning `true` if so, otherwise `false`.

  ## Examples

      iex> 42 |> is_negative_integer
      false

      iex> 0 |> is_negative_integer
      false

      iex> -1 |> is_negative_integer
      true

      iex> fun = fn
      ...>   v when is_negative_integer(v) -> true
      ...>   _ -> false
      ...> end
      ...> false = [1,2,3] |> fun.()
      ...> true = -1 |> fun.()
      ...> false = 42 |> fun.()
      ...> false = :not_an_integer |> fun.()
      false

  """

  @since "0.1.0"

  defguard is_negative_integer(value) when is_integer(value) and value < 0
end
