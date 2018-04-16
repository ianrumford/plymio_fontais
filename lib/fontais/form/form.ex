defmodule Plymio.Fontais.Form do
  @moduledoc ~S"""
  Functions for Quoted Forms (Asts)

  See `Plymio.Fontais` for overview and documentation terms.
  """

  use Plymio.Fontais.Attribute

  @type form :: Plymio.Fontais.form()
  @type forms :: Plymio.Fontais.forms()
  @type error :: Plymio.Fontais.error()

  import Plymio.Fontais.Error,
    only: [
      new_error_result: 1
    ]

  import Plymio.Fontais.Option,
    only: [
      opts_get_values: 3,
      opts_validate: 1
    ]

  import Plymio.Fontais.Utility,
    only: [
      list_wrap_flat_just: 1
    ]

  import Plymio.Fontais.Funcio,
    only: [
      reduce_or_nil_map1_funs: 1,
      map_collate0_enum: 2
    ]

  @doc ~S"""
  `form_validate/1` calls `Macro.validate/1` on the argument (the expected *form*)
  and if the result is `:ok` returns {:ok, form}, else `{:error, error}`.

  ## Examples

      iex> 1 |> form_validate
      {:ok, 1}

      iex> nil |> form_validate # nil is a valid ast
      {:ok, nil}

      iex> [:x, :y] |> form_validate
      {:ok, [:x, :y]}

      iex> form = {:x, :y} # this 2tuple is a valid form without escaping
      ...> form |> form_validate
      {:ok, {:x, :y}}

      iex> {:error, error} = {:x, :y, :z} |> form_validate
      ...> error |> Exception.message
      "form invalid, got: {:x, :y, :z}"

      iex> {:error, error} = %{a: 1, b: 2, c: 3} |> form_validate # map not a valid form
      ...> error |> Exception.message
      "form invalid, got: %{a: 1, b: 2, c: 3}"

      iex> form = %{a: 1, b: 2, c: 3} |> Macro.escape # escaped map is a valid form
      ...> form |> form_validate
      {:ok,  %{a: 1, b: 2, c: 3} |> Macro.escape}

  """

  @since "0.1.0"

  @spec form_validate(any) :: {:ok, form} | {:error, error}

  def form_validate(form)

  def form_validate(form) do
    case form |> Macro.validate() do
      :ok -> {:ok, form}
      {:error, _remainder} -> new_error_result(m: "form invalid", v: form)
    end
  end

  @doc ~S"""

  `forms_validate/1` validates the *forms* using `form_validate/1` on each *form*, returning `{:ok, forms}` if all are valid, else `{:error, error}`.

  ## Examples

      iex> [1, 2, 3] |> forms_validate
      {:ok, [1, 2, 3]}

      iex> [1, {2, 2}, :three] |> forms_validate
      {:ok, [1, {2, 2}, :three]}

      iex> {:error, error} = [1, {2, 2, 2}, %{c: 3}] |> forms_validate
      ...> error |> Exception.message
      "forms invalid, got invalid indices: [1, 2]"

  """

  @since "0.1.0"

  @spec forms_validate(any) :: {:ok, forms} | {:error, error}

  def forms_validate(forms)

  def forms_validate(forms) when is_list(forms) do
    forms
    |> Stream.with_index()
    |> Enum.reduce([], fn {form, index}, invalid_indices ->
      case form |> form_validate do
        {:ok, _} -> invalid_indices
        {:error, _} -> [index | invalid_indices]
      end
    end)
    |> case do
      # no invalid forms
      [] ->
        {:ok, forms}

      invalid_indices ->
        new_error_result(
          m: "forms invalid, got invalid indices: #{inspect(Enum.reverse(invalid_indices))}"
        )
    end
  end

  def forms_validate(forms) do
    new_error_result(m: "forms invalid", v: forms)
  end

  @doc ~S"""
  `forms_reduce/1` takes a zero, one or more *form*, normalises them, and reduces the *forms* to a single
  *form* using `Kernel.SpecialForms.unquote_splicing/1`.

  If the reduction suceeds, `{:ok, reduced_form}` is returned, else `{:error, error}`.

  An empty list reduces to `{:ok, nil}`.

  ## Examples

      iex> {:ok, reduced_form} = quote(do: a = x + y) |> forms_reduce
      ...> reduced_form |> Macro.to_string
      "a = x + y"

      iex> {:ok, reduced_form} = [
      ...>  quote(do: a = x + y),
      ...>  quote(do: a * c)
      ...> ] |> forms_reduce
      ...> reduced_form |> Macro.to_string
      "(\n  a = x + y\n  a * c\n)"

      iex> {:ok, form} = nil |> forms_reduce
      ...> form |> Macro.to_string
      "nil"

      iex> {:ok, form} = [
      ...>  quote(do: a = x + y),
      ...>  nil,
      ...>  [
      ...>   quote(do: b = a / c),
      ...>   nil,
      ...>   quote(do: d = b * b),
      ...>  ],
      ...>  quote(do: e = a + d),
      ...> ] |> forms_reduce
      ...> form |> Macro.to_string
      "(\n  a = x + y\n  b = a / c\n  d = b * b\n  e = a + d\n)"

  """

  @since "0.1.0"

  @spec forms_reduce(any) :: {:ok, form} | {:error, error}

  def forms_reduce(asts \\ [])

  def forms_reduce([]), do: {:ok, nil}

  def forms_reduce(forms) do
    with {:ok, forms} <- forms |> forms_normalise do
      forms
      |> case do
        x when is_nil(x) ->
          {:ok, nil}

        forms ->
          forms
          |> length
          |> case do
            0 ->
              {:ok, nil}

            1 ->
              {:ok, forms |> List.first()}

            _ ->
              form =
                quote do
                  (unquote_splicing(forms))
                end

              {:ok, form}
          end
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  @doc ~S"""
  `forms_normalise/1` takes zero, one or more *form* and normalises them to a *forms* returning `{:ok, forms}`.

  The list is first flattened and any `nils` removed before splicing.

  ## Examples

      iex> {:ok, forms} = quote(do: a = x + y) |> forms_normalise
      ...> forms |> hd |> Macro.to_string
      "a = x + y"

      iex> {:ok, forms} = [
      ...>  quote(do: a = x + y),
      ...>  quote(do: a * c)
      ...> ] |> forms_normalise
      ...> forms |> Macro.to_string
      "[a = x + y, a * c]"

      iex> nil |> forms_normalise
      {:ok, []}

      iex> {:ok, form} = [
      ...>  quote(do: a = x + y),
      ...>  nil,
      ...>  [
      ...>   quote(do: b = a / c),
      ...>   nil,
      ...>   quote(do: d = b * b),
      ...>  ],
      ...>  quote(do: e = a + d),
      ...> ] |> forms_normalise
      ...> form |> Macro.to_string
      "[a = x + y, b = a / c, d = b * b, e = a + d]"

  """

  @since "0.1.0"

  @spec forms_normalise(any) :: {:ok, forms} | {:error, error}

  def forms_normalise(forms \\ [])

  def forms_normalise(forms) do
    forms
    |> list_wrap_flat_just
    |> forms_validate
    |> case do
      # {:ok, []} -> {:ok, nil}
      {:ok, _} = result ->
        result

      {:error, %{__struct__: _}} = result ->
        result
    end
  end

  @doc ~S"""
  `opts_forms_normalise/2` takes an *opts*, a *key* and an optional default, gets all the *key*'s values, or uses the default if none, and calls `forms_normalise/1` on the values returning `{:ok, forms}`.

  ## Examples

      iex> opts = [form: quote(do: a = x + y) , form: quote(do: b = p * q)]
      ...> {:ok, forms} = opts |> opts_forms_normalise(:form)
      ...> forms |> Enum.map(&Macro.to_string/1)
      ["a = x + y", "b = p * q"]

      iex> {:ok, forms} = [
      ...>  form1: quote(do: a = x + y),
      ...>  form2: quote(do: b = p * q),
      ...>  form1: quote(do: c = j - k),
      ...> ] |> opts_forms_normalise(:form1)
      ...> forms |> Enum.map(&Macro.to_string/1)
      ["a = x + y", "c = j - k"]

      iex> opts = []
      ...> {:ok, forms} = opts |> opts_forms_normalise(:form)
      ...> forms |> Enum.map(&Macro.to_string/1)
      []

      iex> opts = []
      ...> {:ok, forms} = opts |> opts_forms_normalise(:form, quote(do: a = x + y))
      ...> forms |> Enum.map(&Macro.to_string/1)
      ["a = x + y"]

      iex> {:ok, forms} = [
      ...>  form: quote(do: a = x + y),
      ...>  form: nil,
      ...>  form: [
      ...>   quote(do: b = a / c),
      ...>   nil,
      ...>   quote(do: d = b * b),
      ...>  ],
      ...>  form: quote(do: e = a + d),
      ...> ] |> opts_forms_normalise(:form)
      ...> forms |> Enum.map(&Macro.to_string/1)
      ["a = x + y", "b = a / c", "d = b * b", "e = a + d"]

  """

  @since "0.1.0"

  @spec opts_forms_normalise(any, any, any) :: {:ok, forms} | {:error, error}

  def opts_forms_normalise(opts, form_key, default \\ nil)

  def opts_forms_normalise(opts, key, default) do
    with {:ok, forms} <- opts |> opts_get_values(key, default),
         {:ok, _forms} = result <- forms |> forms_normalise do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  @doc ~S"""
  `opts_forms_reduce/2` takes an *opts* and a *key*, gets all the *key*'s values and calls `forms_reduce/1` on the values returning `{:ok, forms}`.

  ## Examples

      iex> opts = [form: quote(do: a = x + y) , form: quote(do: b = p * q)]
      ...> {:ok, form} = opts |> opts_forms_reduce(:form)
      ...> form |> Macro.to_string
      "(\n  a = x + y\n  b = p * q\n)"

      iex> {:ok, form} = [
      ...>  form1: quote(do: a = x + y),
      ...>  form2: quote(do: b = p * q),
      ...>  form1: quote(do: c = j - k),
      ...> ] |> opts_forms_reduce(:form1)
      ...> form |> Macro.to_string
      "(\n  a = x + y\n  c = j - k\n)"

      iex> opts = []
      ...> opts |> opts_forms_reduce(:form)
      {:ok, nil}

      iex> opts = []
      ...> {:ok, form} = opts |> opts_forms_reduce(:form, quote(do: a = x + y))
      ...> form |> Macro.to_string
      "a = x + y"

      iex> {:ok, form} = [
      ...>  form1: quote(do: a = x + y),
      ...>  form2: nil,
      ...>  form3: [
      ...>   quote(do: b = a / c),
      ...>   nil,
      ...>   quote(do: d = b * b),
      ...>  ],
      ...>  form4: quote(do: e = a + d),
      ...> ] |> opts_forms_reduce(:form3)
      ...> form |> Macro.to_string
      "(\n  b = a / c\n  d = b * b\n)"

  """

  @since "0.1.0"

  @spec opts_forms_reduce(any, any, any) :: {:ok, forms} | {:error, error}

  def opts_forms_reduce(opts, form_key, default \\ nil)

  def opts_forms_reduce(opts, key, default) do
    with {:ok, forms} <- opts |> opts_get_values(key, default),
         {:ok, _forms} = result <- forms |> forms_reduce do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  defp forms_edit_normalise_var_dict(dict)

  defp forms_edit_normalise_var_dict(dict) do
    cond do
      Keyword.keyword?(dict) ->
        {:ok, dict |> Map.new()}

      is_map(dict) ->
        dict
        |> Map.keys()
        |> Enum.all?(&is_atom/1)
        |> case do
          true ->
            {:ok, dict}

          _ ->
            new_error_result(m: "forms_edit var dict invalid", v: dict)
        end

      true ->
        new_error_result(m: "forms_edit var dict invalid", v: dict)
    end
  end

  defp forms_edit_reduce_edit(kv)

  defp forms_edit_reduce_edit({k, v})
       when k == @plymio_fontais_key_transform do
    v |> reduce_or_nil_map1_funs
  end

  defp forms_edit_reduce_edit({k, v})
       when k == @plymio_fontais_key_postwalk do
    with {:ok, fun} <- v |> reduce_or_nil_map1_funs do
      fun
      |> case do
        x when is_nil(x) ->
          {:ok, nil}

        _ ->
          {:ok, fn form -> form |> Macro.postwalk(fun) end}
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  defp forms_edit_reduce_edit({k, v})
       when k == @plymio_fontais_key_prewalk do
    with {:ok, fun} <- v |> reduce_or_nil_map1_funs do
      fun
      |> case do
        x when is_nil(x) ->
          {:ok, nil}

        _ ->
          {:ok, fn form -> form |> Macro.prewalk(fun) end}
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  defp forms_edit_reduce_edit({k, v})
       when k == @plymio_fontais_key_replace_vars do
    with {:ok, var_dict} <- v |> forms_edit_normalise_var_dict do
      fun_postwalk = fn snippet ->
        snippet
        |> case do
          {form, _, module} when is_atom(form) and is_atom(module) ->
            var_dict
            |> Map.has_key?(form)
            |> case do
              true ->
                v = var_dict |> Map.get(form)

                case v |> Macro.validate() do
                  :ok -> v
                  _ -> v |> Macro.escape()
                end

              # no replacement
              _ ->
                snippet
            end

          # passthru
          x ->
            x
        end
      end

      {@plymio_fontais_key_postwalk, fun_postwalk}
      |> forms_edit_reduce_edit
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  defp forms_edit_reduce_edit(_kv) do
    {:ok, nil}
  end

  defp forms_edit_reduce_opts(opts)

  defp forms_edit_reduce_opts(opts) do
    with {:ok, opts} <- opts |> opts_validate do
      opts
      |> map_collate0_enum(&forms_edit_reduce_edit/1)
      |> case do
        {:error, %{__struct__: _}} = result ->
          result

        {:ok, edits} ->
          edits
          |> reduce_or_nil_map1_funs
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  # not documented at this time
  @doc false

  @since "0.1.0"

  @spec forms_edit(any, any) :: {:ok, forms} | {:error, error}

  def forms_edit(forms, opts)

  def forms_edit(forms, opts) do
    with {:ok, edit_fun} <- opts |> forms_edit_reduce_opts,
         {:ok, forms} <- forms |> forms_normalise do
      edit_fun
      |> case do
        x when is_nil(x) ->
          {:ok, forms}

        _ ->
          forms = forms |> Enum.map(edit_fun)

          {:ok, forms}
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end
end
