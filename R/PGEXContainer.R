##' Construct a PGEX Container Prototype
##'
##' A \code{PGEXContainerProto} is a \code{PGEXContainer} that has not had its fields validated for consistency and validity.
##' This allows step-wise construction.
##' @return object of class \code{PGEXContainerProto}
##' @export
##' @example tests/testthat/helper-PGEXContainer.R
##' @param summarizedExperiment \code{SummarizedExperiment}, currently mandatory
##' @param pgex_experiment mandatory experiment data
##' @param pgex_sample optional experiment data to populate \code{colData(summarizedExperiment)}
##' @param geo_soft optional GEO data
##' @param ae_idf optional ArrayExpress
##' @param ae_sdrf optional ArrayExpress
##' @param fdata feature data (ignored)
##' @param exprs expression data (ignored)
##' @rdname PGEXContainerProto-fun
PGEXContainerProto <- function(summarizedExperiment=NULL, pgex_experiment=NULL, pgex_sample=NULL, geo_soft=NULL, ae_idf=NULL, ae_sdrf=NULL, fdata=NULL, exprs=NULL){
    kv <- guess_keys(summarizedExperiment, pgex_sample, geo_soft, ae_sdrf)
    ## Want tables with common keys or keyed by row order
    ## guess keys/number of samples.
    if(!is.null(summarizedExperiment)){
        #if(! (is.null(exprs) && is.null(cdata) && is.null(fdata))) stop("Cannot provided both `summarizedExperiment` and `exprs` or `cdata` or `fdata`.")
    }
    if(is.null(geo_soft)) geo_soft <- DataFrame()
    if(is.null(ae_sdrf)) ae_sdrf <- DataFrame()
    if(is.null(pgex_experiment)){
        pgex_experiment <- new('PGEXExperimentMeta')
    } else{
        pgex_experiment <- as(pgex_experiment, "PGEXExperimentMeta")
    }

    ## strip structed metadata
    MIAMEed <- NULL
    if(length(whichMIAME <- which_MIAME(metadata(summarizedExperiment)))>0){
        MIAMEed <- metadata(summarizedExperiment)[[whichMIAME]]
        metadata(summarizedExperiment)[[whichMIAME]] <- NULL
    }

    if(!is.null(pgex_sample)){
        colData(summarizedExperiment) <- cbind_unique(pgex_sample, colData(summarizedExperiment))
    }
    new('PGEXContainerProto', summarizedExperiment, geo=geo_soft, ae=ae_sdrf, MIAMEed=MIAMEed, pgex_experiment=pgex_experiment)
}

##' @describeIn PGEXContainerProto-fun Promote an object to a full-fledged (validity checked) PGEXContainer
##' @examples
##' PGEX_promote(proto)
##' @export
##' @param obj \code{PGEXContainerProto}
PGEX_promote <- function(obj){
    obj <- as(obj, 'PGEXContainer')
    validObject(obj)
    obj
}

# cbind, removing duplicated columns
cbind_unique <- function(...){
    maybe <- cbind(...)
    dups <- duplicated(t(as.matrix(maybe)))
    maybe[,!dups,drop=FALSE]
}

which_MIAME <- function(x){
    if(length(x)==0) return(integer(0))
    emptyMIAME <- MIAME()
    which(sapply(x, function(y) inherits(y, 'MIAME') && !all.equal(y, emptyMIAME)))
}



eval_or_NAnull <- function(x, FUN){
    if(!is.function(FUN)) FUN <- eval(FUN)
    if(is.null(x) || is.null(FUN(x))) NA else FUN(x)
}

dimnames_or_name <- function(x, FUN){
    if(is.null(x)) return(NA)
    if(FUN==quote(nrow)){
        namefun <- rownames
    } else if(FUN==quote(ncol)){
        namefun <- colnames
    }
    if(is.null(namefun(x))) return(NA)
    return(namefun(x))
        }

guess_keys <- function(summarizedExperiment, pgex_sample, geo_soft, ae_sdrf){
    axis <- c(summarizedExperiment=quote(ncol), pgex_sample=quote(nrow), geo_soft=quote(nrow), ae_sdrf=quote(nrow)) #do we use rows or columns to find keys?
    ## get number of rows/columns following traits in axis
    nkeylist <- sapply(names(axis), function(x) eval_or_NAnull(get(x), axis[[x]]))
    if(length(nkey <- unique(na.omit(nkeylist)))>1) stop('Discordant number of entries between ', paste(names(axis)[nkeylist %in% nkey], collapse=', '), '.')
    keynames <- lapply(names(axis)[which(nkeylist==nkey)], function(x) dimnames_or_name(get(x), axis[[x]]))
    return(keynames[[1]]) #take the first non-empty name
}

guessAeCovariates <- guessGeoCovariates <- function(x) NULL
is_variant <- function(x) length(unique(x))>1

##' Separate variant and invariant columns
##'
##' Pull off columns from a \code{data.frame} that are constant
##' @param df \code{data.frame}
##' @return \code{list} with entries \code{data.frame} \code{variant} and named list \code{constants}
##' @export
split_invariant <- function(df){
    variantCols <- sapply(df, is_variant)
    list(variant=df[,variantCols,drop=FALSE], constants=df[1,!variantCols,drop=TRUE])
}

## Make a DataFrame preferentially from the arguments in order listed
.DataFrame <- function(summarizedExperiment, pgex_sample, cdata, exprs){
    if(!missing(summarizedExperiment)){
        return(colData(summarizedExperiment))
    } else if(!missing(pgex_sample)){
        return(as(pgex_sample, 'DataFrame'))
    } else if(!missing(cdata)){
        return(as(cdata, 'DataFrame'))
    } else if(!missing(exprs)){
        return(DataFrame(row.names=colnames(exprs)))
    } 
}


setMethod('[', list(x='PGEXContainerProto', i='ANY', j='ANY', drop='ANY'), function(x, i, j, ..., drop=TRUE){
    ans <- callNextMethod()
    ans@geo <- x@geo[i,j,,drop=drop]
    ans@ae <- x@ae[i,j,,drop=drop]
    ans
})

setMethod('pgex_experiment', list(x="PGEXContainerProto"), function(x){
    x@pgex_experiment
})

setReplaceMethod('pgex_experiment', list(x="PGEXContainerProto", value='PGEXExperimentMeta'), function(x, value){
    x@pgex_experiment <- value
    x
})
