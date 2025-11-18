# ExpressionProfile class for OSP snapshot expression profiles

An R6 class that represents an expression profile in an OSP snapshot.
This class provides methods to access different properties of an
expression profile and display a summary of its information.

## Public fields

- `data`:

  The raw data of the expression profile

## Active bindings

- `type`:

  The type of the expression profile

- `species`:

  The species of the expression profile

- `molecule`:

  The molecule name of the expression profile

- `category`:

  The category of the expression profile

- `localization`:

  The localization of the expression profile

- `transportType`:

  The transport type of the expression profile

- `ontogeny`:

  The ontogeny information of the expression profile

- `parameters`:

  The parameters of the expression profile

- `id`:

  The unique identifier of the expression profile

## Methods

### Public methods

- [`ExpressionProfile$new()`](#method-ExpressionProfile-new)

- [`ExpressionProfile$print()`](#method-ExpressionProfile-print)

- [`ExpressionProfile$to_df()`](#method-ExpressionProfile-to_df)

- [`ExpressionProfile$clone()`](#method-ExpressionProfile-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new ExpressionProfile object

#### Usage

    ExpressionProfile$new(data)

#### Arguments

- `data`:

  Raw expression profile data from a snapshot

#### Returns

A new ExpressionProfile object

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print a summary of the expression profile

#### Usage

    ExpressionProfile$print(...)

#### Arguments

- `...`:

  Additional arguments passed to print methods

#### Returns

Invisibly returns the object

------------------------------------------------------------------------

### Method `to_df()`

Convert the expression profile to data frames for easier manipulation

#### Usage

    ExpressionProfile$to_df()

#### Returns

A list with basic information and parameters as tibbles

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    ExpressionProfile$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
