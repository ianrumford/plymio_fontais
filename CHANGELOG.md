# CHANGELOG

## v0.2.0

### Bug Fixes

Deleted erroneous `Enum.reverse/1` in
`Plymio.Vekil.Utility.create_form_vekil/1` before merging vekils - last
wins!.

### Internal Changes

Changed names of some `Plymio.Fontais.Error` related module attributes
and `defexception` fields to be more descriptive and for better
integration with `Harnais.Error`.

The `Plymio.Fontais.Workflow` module has been broken out into more
focused *proxy* families.

The first cut of a standard style and naming convention
for the *proxies* in a *vekil* has been adopted.

`Plymio.Fontais.Vekil` has been renamed to
`Plymio.Fontais.Vekil.ProxyForomDict` to more correctly describe its
function. This module supports the (new) `Plymio.Vekil` package.

Added gather opts functions to `Plymio.Fontais.Funcio`

Added `def_custom_opts_has_key?/1` macro to `Plymio.Fontais.Option.Macro`

`Plymio.Fontais.Form.forms_edit/2` is now documented.

## v0.1.0

Support package for the `Plymio` and `Harnais` Package Families.


