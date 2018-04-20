# CHANGELOG

## v0.1.1

### Bug Fixes

Misc code tidying (e.g. deleting commented code).

To forestall dialyzer warnins, changed `defp update_field` clauses in
`Plymio.Fontais.Error`'s *vekil* to always return `{:ok, any}` or
`{:error, error}`. Also changed `def update` in
`Plymio.Fontais.Error`'s *vekil* to only accept `{:ok, any}` or
`{:error, error}` from calls to `update_field`.

Deleted spurious `true` clauses in `Plymio.Fontais.Workflow`'s *vekil* entries:

1. :defp_update_field_proxy_validate_opzioni
2. :defp_update_field_proxy_normalise_opzioni



## v0.1.0

Support package for the `Plymio` and `Harnais` Package Families.


