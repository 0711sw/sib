# Standard Information Block (SIB) Schema Format

This document describes the YAML-based schema format for **Standard Information Blocks (SIBs)**.
The format allows defining reusable blocks of structured JSON data with strict typing, validation rules, and metadata.

---

## Overview

A **Block Descriptor** defines:

- **Metadata** about the block (name, version, state, description, documentation URL).
- **Fields** that make up the block (typed, validated, optionally nested).

Each descriptor is written in **YAML**.

---

## Block Descriptor

```yaml
name: urn:sib:product-base-1
version: 1
description: "Contains elemental base data for a product."
state: Active
fields:
  itemNumber:
    type: String
    description: "Unique item identifier"
  weight:
    type: Number
    minValue: "0"
  mainImage:
    type: Asset
    optional: true
    acceptedFileExtensions: ["jpg", "png", "pdf"]
```

### Properties

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | `string` | Yes | Unique identifier in URN format (e.g., `urn:sib:product-base-1`). The trailing number is the **major version**. |
| `version` | `integer` | Yes | The **minor version** of the descriptor. Incremented for backwards-compatible changes (e.g., adding optional fields, removing fields, adjusting patterns). |
| `description` | `string` | No | A short explanation of the descriptor's purpose. |
| `state` | `enum` | Yes | One of: `Experimental`, `Active`, `Deprecated`. |
| `fields` | `object` | Yes | The set of fields making up the descriptor. |

### Versioning

SIB descriptors use a two-level versioning scheme:

- **Major version** — encoded in the URN name (e.g., `urn:sib:product-logistics-1`). A new major version creates a new block and is used for breaking changes that are not backwards-compatible.
- **Minor version** — the `version` field (integer). Incremented for backwards-compatible changes such as adding optional fields, removing optional fields, or relaxing validation patterns.

A descriptor at `urn:sib:product-logistics-1` with `version: 2` represents major version 1, minor version 2.

---

## Field Types

Fields are defined with a `type` discriminator.
Supported types:

- **String**
- **Number**
- **List**
- **Asset**
- **Date**
- **Boolean**
- **Object**

### Common Field Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `optional` | `bool` | No | If `true`, the field may be omitted. Default: `false`. |
| `deprecated` | `bool` | No | If `true`, the field is deprecated. Deprecated fields **must** be `optional: true`. Providing a value for a deprecated field produces a warning. Default: `false`. |
| `description` | `string` | No | Explanation of the field's meaning/purpose. |

---

### String Field

```yaml
type: String
choices: ["Draft", "Shipped", "Delivered"]
minLength: 3
maxLength: 20
translated: true
softFail: true
```

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `choices` | `[string]` | No | Enumerated allowed values. |
| `pattern` | `string` | No | Regular expression for value validation. |
| `validationMessage` | `string` | No | Custom error message shown when `pattern` or `choices` validation fails. |
| `minLength` | `integer` | No | Minimum allowed length. |
| `maxLength` | `integer` | No | Maximum allowed length. |
| `translated` | `bool` | No | If `true`, field values can be a localized map (e.g., `{"en": "Hello", "de": "Hallo"}`). |
| `softFail` | `bool` | No | If `true`, validation failures produce warnings instead of errors. |
| `acceptUntrimmed` | `bool` | No | If `true`, leading/trailing whitespace is accepted. Default: `false`. |

---

### Number Field

```yaml
type: Number
minValue: "0.0"
maxValue: "100.0"
minScale: 2
maxScale: 3
softFail: true
```

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `minValue` | `string` | No | Minimum allowed numeric value. |
| `maxValue` | `string` | No | Maximum allowed numeric value. |
| `minScale` | `integer` | No | Minimum decimal places. Values with fewer decimals are padded with zeros. |
| `maxScale` | `integer` | No | Maximum decimal places. Values with more decimals produce an error. |
| `softFail` | `bool` | No | If `true`, validation failures produce warnings instead of errors. |

Values for `minValue` and `maxValue` are strings to support arbitrary decimal precision.

---

### List Field

```yaml
type: List
minOccur: 1
maxOccur: 10
contents:
  type: String
```

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `contents` | `FieldType` | Yes | The type of items in the list. |
| `minOccur` | `integer` | No | Minimum number of elements. |
| `maxOccur` | `integer` | No | Maximum number of elements. |

---

### Asset Field

```yaml
type: Asset
acceptedFileExtensions: ["jpg", "png", "tar.gz"]
```

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `acceptedFileExtensions` | `[string]` | No | List of valid lowercase file extensions. |

---

### Date Field

```yaml
type: Date
```

- No additional properties.
- Values must be valid ISO-8601 dates in the format `YYYY-MM-DD`.

---

### Boolean Field

```yaml
type: Boolean
```

- Represents a true/false flag.
- No additional properties.

---

### Object Field

```yaml
type: Object
fields:
  street:
    type: String
  zip:
    type: String
```

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `fields` | `map[string, Field]` | Yes | Nested fields of the object. |

---

## Severity Levels

Validation produces messages at different severity levels:

- **Hint** — Suggestions for completeness (e.g., missing description).
- **Warning** — Potentially problematic but not invalid. Used when `softFail: true`.
- **Error** — Data is invalid and rejected.

---

## Validation Rules

The following rules are enforced when validating data against a schema:

### Strings

- Value not in `choices` produces an error (or warning if `softFail: true`).
- Value doesn't match `pattern` produces an error (or warning if `softFail: true`).
- Leading/trailing whitespace produces an error (or warning if `softFail: true`), unless `acceptUntrimmed: true`.
- Value shorter than `minLength` or longer than `maxLength` produces an error (or warning if `softFail: true`).

### Numbers

- Value below `minValue` or above `maxValue` produces an error (or warning if `softFail: true`).
- Too many decimal places (exceeds `maxScale`) produces an error (or warning if `softFail: true`).
- Values with fewer decimal places than `minScale` are automatically padded with zeros.

### Lists

- Fewer items than `minOccur` or more items than `maxOccur` produces an error.

### Assets

- File extension not in `acceptedFileExtensions` produces an error.
- Each extension must be lowercase (e.g., `jpg`, `tar.gz`).
