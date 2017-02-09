## For final, in-memory use
##' An S4 Class to hold gene expression with appropriately labelled cell/feature variables
##' Extends a \link{\code{SummarizedExperiment}}.
##' @slot pgex_version \code{character} giving version string of the package that created the object
##' @importClassesFrom SummarizedExperiment SummarizedExperiment0
##' @import data.table
setClass('PGEXContainer', contains='SummarizedExperiment0', representation=list(pgex_version='character'),prototype=list(pgex_version=as.character(packageVersion('PenultimateGEXContainer'))))

## But maybe these should just be added onto the mcols/colData.  The DataFrame could probably handled nested versions. How to handle idempotency?


## A DataFrame containing related info that will not explode into an unprint-able mess by default
setClass('EncapsulatedDataFrame', representation=list(DF='DataFrame'))
