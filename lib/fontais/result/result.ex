defmodule Plymio.Fontais.Result do
  @moduledoc ~S"""
  Functions for Result Patterns: `{:ok, any}` or `{:error, error}`

  See `Plymio.Fontais` for overview and documentation terms.
  """

  require Plymio.Fontais.Guard

  @type opts :: Plymio.Fontais.opts()
  @type error :: Plymio.Fontais.error()
  @type result :: Plymio.Fontais.result()
  @type results :: Plymio.Fontais.results()

  import Plymio.Fontais.Error,
    only: [
      new_error_result: 1,
      new_runtime_error_result: 1,
      new_argument_error_result: 1
    ]

  import Plymio.Fontais.Guard,
    only: [
      is_value_unset_or_nil: 1
    ]

  @doc ~S"""
  `normalise0_result/1` takes an argument an enforces *pattern 0*.

  If the argument is `{:ok, value}` or `{:error, error}`, it is passed through unchanged.

  If the argument is anything else, it is converted into `{:error, error}`.

  ## Examples

      iex> {:ok, 42} |> normalise0_result
      {:ok, 42}

      iex> {:error, error} = {:error, %ArgumentError{message: "value is 42"}} |> normalise0_result
      ...> error |> Exception.message
      "value is 42"

      iex> {:error, error} = 42 |> normalise0_result
      ...> error |> Exception.message
      "pattern0 result invalid, got: 42"

  """

  @since "0.1.0"

  @spec normalise0_result(any) :: {:ok, any} | {:error, error}

  def normalise0_result(result)

  def normalise0_result({:ok, _} = result) do
    result
  end

  def normalise0_result({:error, %{__struct__: _}} = result) do
    result
  end

  def normalise0_result(x) do
    new_argument_error_result(m: "pattern0 result invalid", v: x)
  end

  @doc ~S"""
  `normalise1_result/1` takes an argument an enforces *pattern 1*.

  If the argument is `{:ok, value}` or `{:error, error}`, it is passed through unchanged.

  An other `value` is converted into `{:ok, value}`.

  ## Examples

      iex> {:ok, 42} |> normalise1_result
      {:ok, 42}

      iex> {:error, error} = {:error, %ArgumentError{message: "value is 42"}} |> normalise1_result
      ...> error |> Exception.message
      "value is 42"

      iex> 42 |> normalise1_result
      {:ok, 42}

  """

  @since "0.1.0"

  @spec normalise1_result(any) :: {:ok, any} | {:error, error}

  def normalise1_result(result)

  def normalise1_result({:ok, _} = result) do
    result
  end

  def normalise1_result({:error, %{__struct__: _}} = result) do
    result
  end

  def normalise1_result(value) do
    {:ok, value}
  end

  @doc ~S"""
  `normalise2_result/1` takes an argument an applies *pattern 2*.

  Its works like `normalise1_result/1` **except** if the `value` is
  `nil` or *the unset value* (see `Plymio.Fontais.Guard.the_unset_value/0`),
  it is passed through unchanged.

  ## Examples

      iex> {:ok, 42} |> normalise2_result
      {:ok, 42}

      iex> {:error, error} = {:error, %ArgumentError{message: "value is 42"}} |> normalise2_result
      ...> error |> Exception.message
      "value is 42"

      iex> 42 |> normalise2_result
      {:ok, 42}

      iex> nil |> normalise2_result
      nil

      iex> value1 = Plymio.Fontais.Guard.the_unset_value
      ...> value2 = value1
      ...> value3 = value1 |> normalise2_result
      ...> value3 == value2
      true

  """

  @since "0.1.0"

  @spec normalise2_result(any) :: atom | {:ok, any} | {:error, error}

  def normalise2_result(result)

  def normalise2_result({:ok, _} = result) do
    result
  end

  def normalise2_result({:error, %{__struct__: _}} = result) do
    result
  end

  def normalise2_result(value) when is_value_unset_or_nil(value) do
    value
  end

  def normalise2_result(value) do
    {:ok, value}
  end

  @doc ~S"""
  `normalise0_results/1` takes an *enum* and applies *pattern 0* to each element, returning `{:ok, enum}` where `enum` will be a `Stream`.

  ## Examples

      iex> {:ok, enum} = [
      ...>   {:ok, 42},
      ...>   {:error, %BadMapError{term: :not_a_map}},
      ...>   "HelloWorld"
      ...> ] |> normalise0_results
      ...> enum |> Enum.to_list
      [{:ok, 42}, {:error, %BadMapError{term: :not_a_map}},
       {:error, %ArgumentError{message: "pattern0 result invalid, got: HelloWorld"}}]

  """

  @since "0.1.0"

  @spec normalise0_results(any) :: {:ok, results} | {:error, error}

  def normalise0_results(results)

  def normalise0_results(results) when is_list(results) do
    {:ok, results |> Stream.map(&normalise0_result/1)}
  end

  def normalise0_results(results) do
    new_error_result(m: "results invalid", v: results)
  end

  @doc ~S"""
  `normalise1_results/1` takes an *enum* and applies *pattern 1* to each element, returning `{:ok, enum}` where `enum` will be a `Stream`.

  ## Examples

      iex> {:ok, enum} = [
      ...>   {:ok, 42},
      ...>   {:error, %BadMapError{term: :not_a_map}},
      ...>   "HelloWorld"
      ...> ] |> normalise1_results
      ...> enum |> Enum.to_list
      [{:ok, 42}, {:error, %BadMapError{term: :not_a_map}}, {:ok, "HelloWorld"}]

  """

  @since "0.1.0"

  @spec normalise1_results(any) :: {:ok, results} | {:error, error}

  def normalise1_results(results)

  def normalise1_results(results) when is_list(results) do
    {:ok, results |> Stream.map(&normalise1_result/1)}
  end

  def normalise1_results(results) do
    new_error_result(m: "results invalid", v: results)
  end

  @doc ~S"""
  `normalise2_results/1` takes an *enum* and applies *pattern 2* to each element, returning `{:ok, enum}` where `enum` will be a `Stream`.

  ## Examples

      iex> unset_value = Plymio.Fontais.Guard.the_unset_value()
      ...> {:ok, enum} = [
      ...>   nil,
      ...>   {:ok, 42},
      ...>   {:error, %BadMapError{term: :not_a_map}},
      ...>   unset_value,
      ...>   "HelloWorld"
      ...> ] |> normalise2_results
      ...> results = enum |> Enum.to_list
      ...> nil = results |> Enum.at(0)
      ...> {:error, %BadMapError{term: :not_a_map}} = results |> Enum.at(2)
      ...> ^unset_value = results |> Enum.at(3)
      ...> results |> Enum.at(3) |> Plymio.Fontais.Guard.is_value_unset
      true

  """

  @since "0.1.0"

  @spec normalise2_results(any) :: {:ok, results} | {:error, error}

  def normalise2_results(results)

  def normalise2_results(results) when is_list(results) do
    {:ok, results |> Stream.map(&normalise2_result/1)}
  end

  def normalise2_results(results) do
    new_error_result(m: "results invalid", v: results)
  end

  @doc ~S"""
  `validate_results/1` takes an *enum* and confirms each value is a *result*, returning `{:ok, enum}`.

  ## Examples

      iex> {:ok, enum} = [
      ...>   {:ok, 42},
      ...>   {:error, %BadMapError{term: :not_a_map}},
      ...> ] |> validate_results
      ...> enum |> Enum.to_list
      [{:ok, 42}, {:error, %BadMapError{term: :not_a_map}}]

      iex> {:error, error} = [
      ...>   {:ok, 42},
      ...>   {:error, %BadMapError{term: :not_a_map}},
      ...>   "HelloWorld"
      ...> ] |> validate_results
      ...> error |> Exception.message
      "result invalid, got: \"HelloWorld\""

      iex> {:error, error} = [
      ...>   {:ok, 42},
      ...>   {:error, %BadMapError{term: :not_a_map}},
      ...>   "HelloWorld", :not_a_result
      ...> ] |> validate_results
      ...> error |> Exception.message
      "results invalid, got: [\"HelloWorld\", :not_a_result]"

  """

  @since "0.1.0"

  @spec validate_results(any) :: result

  def validate_results(results) do
    results
    |> Enum.reject(fn
      {:ok, _} -> true
      {:error, error} -> error |> Exception.exception?()
      _ -> false
    end)
    |> case do
      [] ->
        {:ok, results}

      not_results ->
        not_results
        |> length
        |> case do
          1 ->
            new_runtime_error_result("result invalid, got: #{inspect(hd(not_results))}")

          _ ->
            new_runtime_error_result("results invalid, got: #{inspect(not_results)}")
        end
    end
  end

  @doc false

  def realise_results(results)

  def realise_results(results) when is_list(results) do
    results |> validate_results
  end

  def realise_results(results) do
    try do
      results |> Enum.to_list() |> validate_results
    rescue
      error ->
        {:error, error}
    end
  end

  @doc false

  @since "0.1.0"

  def result_strip_ok_or_raise_error(result)

  def result_strip_ok_or_raise_error({:ok, value}) do
    value
  end

  def result_strip_ok_or_raise_error({:error, error}) do
    raise error
  end

  def result_strip_ok_or_raise_error(result) do
    new_error_result(m: "result invalid", v: result)
    |> result_strip_ok_or_raise_error
  end

  @doc false

  @since "0.1.0"

  def result_strip_ok_or_passthru(result)

  def result_strip_ok_or_passthru({:ok, value}) do
    value
  end

  def result_strip_ok_or_passthru(value) do
    value
  end
end
