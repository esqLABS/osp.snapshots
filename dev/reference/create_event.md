# Create a new event

Create an \[Event\] building block from named arguments. This is a thin
factory around \`Event\$new()\` that builds the raw list shape for you.

An \[Event\] is a discrete non-administration perturbation that fires at
a specific simulation time (for example a meal, gallbladder emptying, or
organ removal). PK-Sim creates events by cloning a named template and
overriding parameters, so a template name is required.

## Usage

``` r
create_event(name, template, parameters = NULL)
```

## Arguments

- name:

  Character. Name of the event (required).

- template:

  Character. Event template name passed to the PK-Sim factory
  (required). Determines which event type is created.

- parameters:

  List of \[Parameter\] objects (created with \[create_parameter()\]) or
  raw parameter lists overriding values on the cloned template.

## Value

An \[Event\] object.

## Examples

``` r
# Create a minimal event
event <- create_event(
  name = "Breakfast",
  template = "Meal: Standard (Human)"
)

# Create an event with parameter overrides
event <- create_event(
  name = "Breakfast",
  template = "Meal: Standard (Human)",
  parameters = list(
    create_parameter(name = "Meal energy content", value = 500, unit = "kcal"),
    create_parameter(name = "Meal volume", value = 0.3, unit = "l")
  )
)
```
