defmodule Plymio.Fontais do
  @moduledoc ~S"""
  `Plymio.Fontais` is a foundation / support package for the `Plymio` and `Harnais` package families.

  ## Documentation Terms

  In the documentation these terms, usually in *italics*, are used to mean the same thing (e.g. *opts*).

  ### *opts* and *opzioni*

  *opts* is a `Keyword` list. An *opzioni* is a list of *opts*.

  ### *form* and *forms*

  A *form* is an quoted form (ast). A *forms* is a list of zero, one or more *form*s.

  ### *result* and *results*

  A result is either `{:ok, any}` or `{:error, error}` where `error` is an `Exception`.

  A *results* is an enumerable of *result* e.g. a `List` or `Stream`.

  ## Standard Processing and Result Patterns

  Many functions return either `{:ok, value}` or `{:error, error}`
  where `error` will be an `Exception`.

  Peer bang functions return either the `value` or raises the `error`.

  There are three common function *patterns*:

  ### *pattern 0*

  A *pattern 0* function always returns either `{:ok, any}` or
  `{:error, error}`.

  If the function's processing (e.g. after calling other functions)
  does not produce either `{:ok, value}` or `{:error,
  error}`, a new `{:error, error}` will be created and returned.

  A *pattern 0* function is *pessimistic* i.e it assumes the `value` is invalid, and
  an error has occured.

  ### *pattern 1*

  A *pattern 1* function always returns either `{:ok, any}` or
  `{:error, error}`.

  If the function's processing (e.g. after calling other functions)
  produces a `value` that is neither `{:ok, any}` nor `{:error,
  error}`, the `value` is converted into `{:ok, value}` and returned.

  A *pattern 1* function is *optimistic* i.e it assumes the
  `value` is valid.

  ### *pattern 2*

  A *pattern 2* function always returns either `{:ok, any}`, `{:error,
  error}`, `nil` or *the unset value*.

  See below for an explanation of *the unset value*.

  A *pattern 2* function works like *pattern 1* other than if
  the `value` is `nil` or *the unset value* (see below), it is
  returned unchanged.

  ## The Unset Value

  In many situations it is useful to know whether a var has been set
  explicity but its value can be validly `nil`.

  For example the default default value for a `struct` field is
  `nil`. But there is no way to determine whether the field has been
  set to `nil` or has never been set at all.

  *The Unset Value* is an arbitrary, randomish atom that can be used
   where `nil` can not e.g. as the default value for a field in a
   `struct`.

   See `Plymio.Fontais.Guard.the_unset_value/0`.

  """

  require Plymio.Fontais.Guard
  use Plymio.Fontais.Attribute

  @type form :: Macro.t()
  @type forms :: [form]

  @type key :: atom
  @type keys :: key | [key]

  @type alias_key :: key
  @type alias_keys :: keys
  @type alias_value :: nil | alias_keys

  @type aliases_kvs :: [{alias_key, alias_value}]

  @type aliases_tuples :: [{alias_key, alias_key}]
  @type aliases_dict :: %{optional(alias_key) => alias_key}

  @type kv :: {any, any}
  @type product :: [kv]
  @type opts :: Keyword.t()
  @type opzioni :: [opts]
  @type error :: struct
  @type result :: {:ok, any} | {:error, error}
  @type results :: [result]

  @type dict :: %{optional(alias_key) => any}

  @type fun1_map :: (any -> any)

  @doc "Delegated to `Plymio.Fontais.Guard.the_unset_value/0`"
  @since "0.1.0"
  @spec the_unset_value() :: atom
  defdelegate the_unset_value(), to: Plymio.Fontais.Guard

  @doc "Delegated to `Plymio.Fontais.Guard.is_value_set/1`"
  @since "0.1.0"
  @spec is_value_set(any) :: boolean
  defdelegate is_value_set(value), to: Plymio.Fontais.Guard

  @doc "Delegated to `Plymio.Fontais.Guard.is_value_unset/1`"
  @since "0.1.0"
  @spec is_value_unset(any) :: boolean
  defdelegate is_value_unset(value), to: Plymio.Fontais.Guard

  @doc "Delegated to `Plymio.Fontais.Guard.is_value_unset_or_nil/1`"
  @since "0.1.0"
  @spec is_value_unset_or_nil(any) :: boolean
  defdelegate is_value_unset_or_nil(value), to: Plymio.Fontais.Guard
end
