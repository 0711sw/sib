# Standard Information Block (SIB) Schema Format

This document describes the YAML-based schema format for **Standard
Information Blocks (SIBs)**.\
The format allows defining reusable blocks of structured JSON data with
strict typing, validation rules, and metadata.

------------------------------------------------------------------------

## Overview

A **Block Descriptor** defines:

-   **Metadata** about the block (name, version, state, description,
    documentation URL).
-   **Fields** that make up the block (typed, validated, optionally
    nested).

Each descriptor is written in **YAML**.

------------------------------------------------------------------------

## Block Descriptor

``` yaml
name: urn:sib:product:logistics-1
version: 1
description: "Logistics information for product delivery"
state: Active
fields:
  trackingNumber:
    type: String
    description: "Unique tracking ID"
    pattern: "^[A-Z0-9]{10,20}$"
  weight:
    type: Number
    minValue: "0"
  attachments:
    type: List
    contents:
      type: Asset
      acceptedFileExtensions: ["jpg", "png", "pdf"]
```

### Properties

  ------------------------------------------------------------------------------------------
  Field                Type        Required   Description
  -------------------- ----------- ---------- ----------------------------------------------
  `name`               `string`    ✅         Must match pattern
                                              `urn:namespace:name-MajorVersion` (e.g.,
                                              `urn:sib:product:logistics-1`).

  `version`            `integer`   ✅         The version number of the descriptor.

  `description`        `string`    ❌         A short explanation of the descriptor's
                                              purpose.

  `state`              `enum`      ✅         One of: `Experimental`, `Active`,
                                              `Deprecated`.

  `fields`             `object`    ✅         The set of fields making up the descriptor.
  ------------------------------------------------------------------------------------------

------------------------------------------------------------------------

## Field Types

Fields are defined with a `type` discriminator.\
Supported types:

-   **String**
-   **Number**
-   **List**
-   **Asset**
-   **Date**
-   **DateTime**
-   **Boolean**
-   **Object**

### Common Field Properties

  ------------------------------------------------------------------------------
  Property        Type       Required   Description
  --------------- ---------- ---------- ----------------------------------------
  `optional`      `bool`     ❌         If `true`, the field may be omitted.

  `description`   `string`   ❌         Explanation of the field's
                                        meaning/purpose.
  ------------------------------------------------------------------------------

------------------------------------------------------------------------

### String Field

``` yaml
type: String
choices: ["Draft", "Shipped", "Delivered"]
pattern: "^[A-Za-z]+$"
minLength: 3
maxLength: 20
translated: true
```

  --------------------------------------------------------------------------------
  Property       Type         Required   Description
  -------------- ------------ ---------- -----------------------------------------
  `choices`      `[string]`   ❌         Enumerated allowed values.

  `pattern`      `string`     ❌         Regular expression for value validation.

  `minLength`    `integer`    ❌         Minimum allowed length.

  `maxLength`    `integer`    ❌         Maximum allowed length.

  `translated`   `bool`       ❌         Indicates if field values can be
                                         localized.
  --------------------------------------------------------------------------------

------------------------------------------------------------------------

### Number Field

``` yaml
type: Number
minValue: "0.0"
maxValue: "100.0"
```

  ---------------------------------------------------------------------------
  Property     Type       Required   Description
  ------------ ---------- ---------- ----------------------------------------
  `minValue`   `string`   ❌         Minimum allowed numeric value.

  `maxValue`   `string`   ❌         Maximum allowed numeric value.
  ---------------------------------------------------------------------------

> Values are strings to support decimal precision.

------------------------------------------------------------------------

### List Field

``` yaml
type: List
minOccur: 1
maxOccur: 10
contents:
  type: String
```

  ----------------------------------------------------------------------------------
  Property     Type          Required   Description
  ------------ ------------- ---------- --------------------------------------------
  `contents`   `FieldType`   ✅         The type of items in the list.

  `minOccur`   `integer`     ❌         Minimum number of elements.

  `maxOccur`   `integer`     ❌         Maximum number of elements.
  ----------------------------------------------------------------------------------

------------------------------------------------------------------------

### Asset Field

``` yaml
type: Asset
acceptedFileExtensions: ["jpg", "png", "tar.gz"]
```

  ------------------------------------------------------------------------------------------
  Property                   Type         Required   Description
  -------------------------- ------------ ---------- ---------------------------------------
  `acceptedFileExtensions`   `[string]`   ❌         List of valid lowercase file
                                                     extensions.

  ------------------------------------------------------------------------------------------

------------------------------------------------------------------------

### Date & DateTime Fields

``` yaml
type: Date
```

``` yaml
type: DateTime
```

-   No additional properties.
-   Values must be valid ISO-8601 dates or datetimes.

------------------------------------------------------------------------

### Boolean Field

``` yaml
type: Boolean
```

-   Represents a true/false flag.
-   No additional properties.

------------------------------------------------------------------------

### Object Field

``` yaml
type: Object
fields:
  street:
    type: String
  zip:
    type: String
```

  --------------------------------------------------------------------------
  Property   Type                   Required   Description
  ---------- ---------------------- ---------- -----------------------------
  `fields`   `map[string, Field]`   ✅         Nested fields of the object.

  --------------------------------------------------------------------------

------------------------------------------------------------------------

## Validation Rules

The following rules are enforced:

1.  **Block Descriptor**
    -   `name` must follow pattern: `urn:namespace:name-MajorVersion`.
    -   Missing `description` → **Hint**.
2.  **Strings**
    -   Invalid regex in `pattern` → **Error**.
    -   `minLength` must not exceed `maxLength`.
3.  **Numbers**
    -   `minValue` and `maxValue` must be valid decimals.
    -   `minValue` ≤ `maxValue`.
4.  **Lists**
    -   `minOccur` ≤ `maxOccur`.
5.  **Assets**
    -   Each extension must be lowercase and start with a character and
        then either more characters or dots. Examples: `zip`, `tar.gz`.

------------------------------------------------------------------------

### Severity Levels

-   `Hint` -- Suggestions for completeness (e.g., missing description).
-   `Warning` -- Potentially problematic but not invalid.
-   `Error` -- Schema is invalid and rejected.
