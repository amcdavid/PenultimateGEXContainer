## To allow empty slots (better than making up zero-length objects?)
#setClass('EMPTY', representation(x='NULL'))
#setClassUnion('DataFrameOrNULL', members=c('DataFrame', 'NULL'))
setClassUnion('MIAMEOrNULL', members=c('MIAME', 'NULL'))

.PGEXExperimentMetaValidity <- function(object){
    ## Check if all fields obey schema
    return(TRUE)
}
setClass('PGEXExperimentMeta', contains='list', validity=.PGEXExperimentMetaValidity)

.isNonEmptyDF <- function(object) nrow(object)>0

.PGEXProtoValidity <- function(object){
    if(.isNonEmptyDF(object@geo) && ncol(object) != nrow(object@geo)) return(paste0("`@geo` has ", nrow(geo), " rows and object has ", ncol(object), " columns."))
    if(.isNonEmptyDF(object@ae) && ncol(object) != nrow(object@ae)) return(paste0("`@ae` has ", nrow(ae), " rows and object has ", ncol(object), " columns."))
    return(TRUE)
}

##' An S4 Class to hold gene expression with appropriately labelled cell/feature variables
##' Extends a \link{\code{SummarizedExperiment}}.
##' @slot pgex_version \code{character} giving version string of the package that created the object
##' @slot geo optional \code{DataFrame} containing GEO/SOFT fields
##' @slot ae optional \code{DataFrame} containing ArrayExpress srdf fields
##' @importClassesFrom Biobase MIAME
##' @import S4Vectors SummarizedExperiment
setClass('PGEXContainerProto',
         contains='SummarizedExperiment',
         representation=list(pgex_version='character', geo='DataFrame', ae='DataFrame', MIAMEed='MIAMEOrNULL',
                             pgex_experiment='PGEXExperimentMeta'),
         prototype=list(pgex_version=as.character(packageVersion('PenultimateGEXContainer'))),
         validity=.PGEXProtoValidity)

format_schema_err <- function(src, x){
    paste0(src, " doesn't follow schema: ", lapply(names(x), function(y) paste0(y, ' ("',  x[y], '") ')))
}

format_missing_err <- function(src, x){
    paste0(src, " is missing: ", x)
}


.PGEXValidity <- function(object){
    if(length(lacking <- lacks_mandatory(colData(object),  sample_schema))>0) return(format_missing_err("colData(object)", lacking))
    if(length(violates <- violates_schema(colData(object),  sample_schema))>0) return(format_schema_err("colData(object)", violates))
    if(length(lacking <- lacks_mandatory(object@pgex_experiment,  experiment_schema))>0) return(format_missing_err("object@pgex_experiment", lacking))
    if(length(violates <- violates_schema(object@pgex_experiment,  experiment_schema))>0) return(format_schema_err("object@pgex_experiment", violates))
    return(TRUE)
}

setClass("PGEXContainer", contains='PGEXContainerProto', validity=.PGEXValidity)

## How to handle idempotency when we write these out?


