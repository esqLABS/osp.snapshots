# Value-object helpers for the `create_*` factories

Small constructors that bundle a value, its unit (where applicable), an
alternative label (where applicable), and any field-specific extras into
a single object. Pass the result straight into the matching
[`create_compound()`](https://esqlabs.github.io/osp.snapshots/reference/create_compound.md),
[`create_individual()`](https://esqlabs.github.io/osp.snapshots/reference/create_individual.md),
or
[`create_observed_data()`](https://esqlabs.github.io/osp.snapshots/reference/create_observed_data.md)
argument, for example `lipophilicity = lipophilicity(2.5)`.

Each helper owns the correct default unit for its field and validates a
supplied unit against that field's `ospsuite` dimension with
[`validate_unit()`](https://esqlabs.github.io/osp.snapshots/reference/validate_unit.md).
The object it returns is meant to be consumed immediately by a factory
(or assigned to the matching writable field of a
[Compound](https://esqlabs.github.io/osp.snapshots/reference/Compound.md)
or
[Individual](https://esqlabs.github.io/osp.snapshots/reference/Individual.md));
it carries the raw values the factory needs and is not intended to be
inspected or mutated directly.

## See also

[`create_compound()`](https://esqlabs.github.io/osp.snapshots/reference/create_compound.md),
[`create_individual()`](https://esqlabs.github.io/osp.snapshots/reference/create_individual.md),
[`create_observed_data()`](https://esqlabs.github.io/osp.snapshots/reference/create_observed_data.md)
