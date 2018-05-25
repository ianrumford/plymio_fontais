defmodule Plymio.Fontais.Attribute do
  @moduledoc false

  defmacro __using__(_opts \\ []) do
    quote do
      @plymio_fontais_the_unset_value :plymio_fontais_t3h1e4_u9n8s7e2t7_v1a8l3u8e

      @plymio_fontais_key_dict :dict
      @plymio_fontais_key_vekil :vekil
      @plymio_fontais_key_proxy :proxy

      # form edit keys / actions
      @plymio_fontais_key_forms_edit :forms_edit

      @plymio_fontais_key_postwalk :postwalk
      @plymio_fontais_key_prewalk :prewalk
      @plymio_fontais_key_transform :transform
      @plymio_fontais_key_replace_vars :replace_vars
      @plymio_fontais_key_rename_vars :rename_vars
      @plymio_fontais_key_rename_atoms :rename_atoms
      @plymio_fontais_key_replace_atoms :replace_atoms
      @plymio_fontais_key_rename_funs :rename_funs

      @plymio_fontais_form_edit_keys [
        @plymio_fontais_key_postwalk,
        @plymio_fontais_key_prewalk,
        @plymio_fontais_key_transform,
        @plymio_fontais_key_replace_vars,
        @plymio_fontais_key_rename_vars,
        @plymio_fontais_key_rename_atoms,
        @plymio_fontais_key_replace_atoms,
        @plymio_fontais_key_rename_funs
      ]

      @plymio_fontais_field_protocol_name :protocol_name
      @plymio_fontais_field_protocol_impl :protocol_impl

      @plymio_fontais_field_alias_protocol_name {@plymio_fontais_field_protocol_name, []}
      @plymio_fontais_field_alias_protocol_impl {@plymio_fontais_field_protocol_impl, []}

      @plymio_fontais_error_field_message :message
      @plymio_fontais_error_field_value :value
      @plymio_fontais_error_field_reason :reason

      @plymio_fontais_error_field_message_function :message_function
      @plymio_fontais_error_field_message_config :message_config

      @plymio_fontais_error_field_alias_message {@plymio_fontais_error_field_message, [:m, :msg]}
      @plymio_fontais_error_field_alias_value {@plymio_fontais_error_field_value,
                                               [:v, :e, :error]}
      @plymio_fontais_error_field_alias_reason {@plymio_fontais_error_field_reason, [:r]}

      @plymio_fontais_error_field_alias_message_function {@plymio_fontais_error_field_message_function,
                                                          [:format_message]}
      @plymio_fontais_error_field_alias_message_config {@plymio_fontais_error_field_message_config,
                                                        [:format_order]}

      @plymio_fontais_error_default_message_config [
        @plymio_fontais_error_field_message,
        @plymio_fontais_error_field_value
      ]

      @plymio_fontais_error_message_opts_invalid "opts invalid"
      @plymio_fontais_error_message_opts_not_derivable "opts not derivable"
      @plymio_fontais_error_message_opzioni_invalid "opzioni invalid"
    end
  end
end
