# Load DataSet from OSP snapshot observed data

Creates a DataSet object (from ospsuite package) from observed data in
an OSP snapshot. This function converts snapshot observed data format to
the standardized DataSet format used throughout the OSP ecosystem.

## Usage

``` r
loadDataSetFromSnapshot(observedDataStructure)
```

## Arguments

- observedDataStructure:

  Raw observed data structure from a snapshot JSON

## Value

A DataSet object from the ospsuite package

## Details

This function follows the same pattern as other DataSet loading
functions in ospsuite: - \`ospsuite::loadDataSetFromPKML()\` -
\`ospsuite::loadDataSetFromExcel()\` -
\`osp.snapshots::loadDataSetFromSnapshot()\` (this function)

## Migration Plan

This function is designed for eventual migration to the ospsuite
package. When migrated, the usage pattern will be:

“\`r \# Future usage (when moved to ospsuite): dataset \<-
ospsuite::loadDataSetFromSnapshot(observedDataStructure)

\# Current usage: dataset \<-
osp.snapshots::loadDataSetFromSnapshot(observedDataStructure)

\# Migration steps: \# 1. Copy this function to ospsuite package \# 2.
Update osp.snapshots to import from ospsuite \# 3. Eventually remove
from osp.snapshots “\`
