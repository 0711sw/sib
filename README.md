# Standard Information Blocks

The **Standard Information Blocks (SIB)** system defines reusable blocks
that describe the data stored in digital product passports.\
These definitions enable interoperability, allowing blocks to be
exchanged between systems of different providers.

## Schema

The structure of descriptors is defined here:
[Schema](SIB_SCHEMA_FORMAT.md)

## Query API

How block data is retrieved from a SIB-compatible endpoint:
[Query API](QUERY.md)

## Blocks

-   [urn:sib:links-1](links.yml)\
    Describes links between entities.

-   [urn:sib:product-base-1](product-base.yml)\
    Contains basic elemental data for a product.

-   [urn:sib:product-documents-1](product-documents.yml)\
    Provides various documents for a product.

-   [urn:sib:product-features-1](product-features.yml)\
    Contains technical features for a product as specified by
    classification systems like eCl@ss or ETIM.

-   [urn:sib:product-images-1](product-images.yml)\
    Provides various images for a product.

-   [urn:sib:product-logistics-1](product-logistics.yml)\
    Provides information about transportation and storage of a product.

-   [urn:sib:product-regulations-1](product-regulations.yml)\
    Contains regulatory information such as WEEE, REACH, and CLP
    compliance.

-   [urn:sib:product-relations-1](product-relations.yml)\
    Contains relations to other products such as spare parts or
    successors.

-   [urn:sib:product-texts-1](product-texts.yml)\
    Contains longer descriptive texts about the product and its
    characteristics.

-   [urn:sib:product-brand-1](product-brand.yml)\
    Contains information about the brand or manufacturer of a product.

-   [urn:sib:product-attributes-1](product-attributes.yml)\
    Contains a list of custom product attributes, typically for
    rendering purposes and not for further processing.

-   [urn:sib:item-base-1](item-base.yml)\
    Provides information for an actual physical item.

### Experimental

-   [urn:sib:product-faq-1](product-faq.yml)\
    Provides frequently asked questions (FAQ) and answers for a product.

-   [urn:sib:product-lca-1](product-lca.yml)\
    Life Cycle Assessment (LCA) data according to EN 15804.

-   [urn:sib:product-maintenance-1](product-maintenance.yml)\
    Contains maintenance and replacement information for a product.

## Development
Use `./test.sh` to check your descriptors locally.

## Deployment
Descriptors are automatically checked when a Pull Request is created. Once this PR is merged
to main, all descriptors are deployed to *d01.durablox.net* and *t01.durablox.net*.
