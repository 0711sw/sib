# SIB Query API

This document describes how block data is retrieved from a SIB-compatible endpoint.

---

## Overview

A SIB endpoint is an **opaque URL** that returns block data for an entity.
The SIB standard makes no assumptions about URL structure — each implementation defines its own routing and path conventions.

The default response is an **HTML rendering** of the block data. Clients can request structured JSON data via content negotiation.

---

## Content Negotiation

### Response Format

| Accept Header | Response |
|---------------|----------|
| `text/html`, `*/*`, or absent | HTML-rendered view of the block data |
| `application/json` | JSON block data (see [Response Format](#json-response-format)) |

### Language

Language negotiation follows [RFC 7231 §5.3.5](https://www.rfc-editor.org/rfc/rfc7231#section-5.3.5) if supported by the server.
The `Accept-Language` header with quality factors determines which language is used for translated fields.

Example:
```
Accept-Language: de;q=0.9, en;q=0.8
```

---

## Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `blocks` | string | Comma-separated list of block type URNs to include. If empty or absent, all available block types are returned. |

Example:
```
?blocks=urn:sib:product-base-1,urn:sib:product-texts-1
```

Implementations may support additional query parameters.

---

## JSON Response Format

When `Accept: application/json` is set, the response contains:

```json
{
  "blocks": [
    {
      "blockType": "urn:sib:product-base-1",
      "blockVersion": 3,
      "validFrom": "2025-01-15",
      "data": {
        "itemNumber": "AX-1234",
        "productName": "Example Product"
      }
    }
  ]
}
```

### Standard Fields

| Field | Type | Description |
|-------|------|-------------|
| `blocks` | array | List of block results. |
| `blocks[].blockType` | string | URN of the block type (e.g., `urn:sib:product-base-1`). |
| `blocks[].blockVersion` | integer | Minor version of the block data. |
| `blocks[].validFrom` | string | ISO 8601 date (`YYYY-MM-DD`) from which this block version is effective. |
| `blocks[].data` | object | The block payload with all [data transformations](#data-transformations) applied. |

Implementations may include additional fields in the response (e.g., diagnostic information, locale context). Clients should ignore unknown fields.

---

## Data Transformations

Block data undergoes the following transformations before it is included in the response. All transformations are applied **recursively** to nested objects and arrays.

### Translated Fields

Fields marked as `translated: true` in the [schema](SIB_SCHEMA_FORMAT.md#string-field) are stored as a map of language codes to values:

```json
{
  "de": "Beispielprodukt",
  "en": "Example Product",
  "xx": "Example Product"
}
```

On output, the map is resolved to a single string value:

1. Use the value for the **requested language** (from `Accept-Language`).
2. If not available, fall back to the **default language** (`"xx"`).
3. If neither exists, return `null`.

Result:
```json
"Beispielprodukt"
```

### Asset Fields

Fields of type [Asset](SIB_SCHEMA_FORMAT.md#asset-field) are transformed into a structured object with download and preview information.

**For files with preview capability** (jpg, jpeg, png, tif, tiff, webp, pdf, heic, avif):

```json
{
  "filename": "product-photo.jpg",
  "extension": "jpg",
  "url": "<download-url>",
  "smallThumbnail": "<thumbnail-url>",
  "mediumThumbnail": "<thumbnail-url>",
  "largeThumbnail": "<thumbnail-url>",
  "contentSize": 102400,
  "contentSizeString": "100.0 KiB"
}
```

**For all other file types:**

```json
{
  "filename": "datasheet.csv",
  "extension": "csv",
  "url": "<download-url>",
  "contentSize": 2048,
  "contentSizeString": "2.0 KiB"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `filename` | string | Original filename. |
| `extension` | string | File extension (parsed from the last dot in the filename). |
| `url` | string | Download URL. URL format and signing are implementation-specific. |
| `smallThumbnail` | string | Thumbnail URL, approximately 240×240 pixels. Only present for preview-capable files. |
| `mediumThumbnail` | string | Thumbnail URL, approximately 480×480 pixels. Only present for preview-capable files. |
| `largeThumbnail` | string | Thumbnail URL, approximately 1280×720 pixels. Only present for preview-capable files. |
| `contentSize` | integer | File size in bytes. |
| `contentSizeString` | string | Human-readable file size (e.g., `"1.0 KiB"`). |

---

## Extensibility

- Implementations may add additional fields to the response object, to individual blocks, or to asset objects.
- Clients must ignore unknown fields to ensure forward compatibility.
