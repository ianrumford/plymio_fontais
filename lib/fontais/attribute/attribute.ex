defmodule Plymio.Fontais.Attribute do
  @moduledoc false

  defmacro __using__(_opts \\ []) do
    quote do
      @plymio_fontais_the_unset_value :plymio_fontais_t3h1e4_u9n8s7e2t7_v1a8l3u8e

      @plymio_fontais_key_vekil :vekil
      @plymio_fontais_key_postwalk :postwalk
      @plymio_fontais_key_prewalk :prewalk
      @plymio_fontais_key_transform :transform
      @plymio_fontais_key_replace_vars :replace_vars

      @plymio_fontais_form_edit_keys [
        @plymio_fontais_key_postwalk,
        @plymio_fontais_key_prewalk,
        @plymio_fontais_key_transform,
        @plymio_fontais_key_replace_vars
      ]

      @plymio_fontais_error_key_message :message
      @plymio_fontais_error_key_value :value
      @plymio_fontais_error_key_reason :reason

      @plymio_fontais_error_key_format_message :format_message
      @plymio_fontais_error_key_format_order :format_order

      @plymio_fontais_error_key_alias_message {@plymio_fontais_error_key_message, [:m, :msg]}
      @plymio_fontais_error_key_alias_value {@plymio_fontais_error_key_value, [:v, :e, :error]}
      @plymio_fontais_error_key_alias_reason {@plymio_fontais_error_key_reason, [:r]}

      @plymio_fontais_error_key_alias_format_message {@plymio_fontais_error_key_format_message,
                                                      []}
      @plymio_fontais_error_key_alias_format_order {@plymio_fontais_error_key_format_order, []}

      @plymio_fontais_error_default_format_order [
        @plymio_fontais_error_key_message,
        @plymio_fontais_error_key_value
      ]

      @plymio_fontais_error_message_opts_invalid "opts invalid"
      @plymio_fontais_error_message_opts_not_derivable "opts not derivable"
      @plymio_fontais_error_message_opzioni_invalid "opzioni invalid"
    end
  end
end
