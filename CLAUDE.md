# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Standard Information Blocks (SIB) is a data-definition repository containing YAML descriptors that define reusable blocks for digital product passports. These blocks enable interoperability between systems of different providers.

## Commands

### Local Validation
```bash
./test.sh
```
Validates all `.yml` files against `https://t01.durablox.net/descriptor/check/v1`. Requires `curl` and `jq`.

### Deployment
Automatic via GitHub Actions:
- PRs trigger validation checks
- Merges to `main` deploy to both `t01.durablox.net` (test) and `d01.durablox.net` (production)

## Architecture

### Block Descriptors
All YAML files in the root directory are block descriptors. Each defines:
- **Metadata**: name (URN), version, state, description
- **Fields**: typed data fields with validation rules

### Versioning
SIB uses a two-level versioning scheme:
- **Major version** - encoded in the URN name (e.g., `urn:sib:product-logistics-1`). New major version = new block, for breaking changes.
- **Minor version** - the `version` field (integer). Incremented for backwards-compatible changes (adding/removing optional fields, relaxing patterns).

### URN Naming Pattern
```
urn:sib:<name>-<major-version>
```
Examples: `urn:sib:product-base-1`, `urn:sib:links-1`

### Block States
- `Active` - Production-ready
- `Experimental` - Under development
- `Deprecated` - No longer recommended

### Field Types
- **String**: with optional `choices`, `pattern`, `minLength`, `maxLength`, `translated`
- **Number**: with `minValue`/`maxValue` (stored as strings for precision)
- **List**: with `contents`, `minOccur`, `maxOccur`
- **Asset**: binary files with `acceptedFileExtensions` (lowercase)
- **Date/DateTime**: ISO-8601 format
- **Boolean**: true/false
- **Object**: nested fields

### Common Field Properties
- `optional: true` - field can be omitted
- `translated: true` - field supports localization
- `softFail: true` - validation failures are warnings, not errors

## Schema Documentation

See [SIB_SCHEMA_FORMAT.md](SIB_SCHEMA_FORMAT.md) for complete schema specification.

## Key Blocks

- `product-base.yml` - Core product data (item number, model, GTIN)
- `product-regulations.yml` - Regulatory compliance (WEEE, REACH, CLP, ERP)
- `product-logistics.yml` - Transportation/storage info
- `links.yml` - Cross-references between entities
- `item-base.yml` - Physical item data (serial numbers)
