##' Construct a PGEX Container Prototype
##'
##' A \code{PGEXContainerProto} is a \code{PGEXContainer} that has not had its fields validated for consistency and validity.
##' This allows step-wise construction.
##' @return object of class \code{PGEXContainerProto}
##' @import data.table
##' @examples
##' \dontrun{
##' library(GEOquery)
##' geoexp <- getGEO('GSE42268')
##' se <- makeSummarizedExperimentFromExpressionSet(geoexp[[1]])
##' }
##' library(SummarizedExperiment)
##' se <- readRDS(system.file("tests", "testthat", "GSE42268_SummarizedExperiment.rds",
##' package='PenultimateGEXContainer'))
##' batch  <- rep(1, ncol(se))
##' biosample <- colData(se)$characteristics_ch1
##' rna_pg <-  colData(se)$characteristics_ch1.2
##' ncells_maybe  <- colData(se)$characteristics_ch1.1
##' ncells <- rep(NA_real_, length(ncells_maybe))
##' ncells[grepl('single cell', ncells_maybe)] <- 1
##' ncells[grepl('50 cells', ncells_maybe) ] <- 50
##' ncells[grepl('12 cells', ncells_maybe)] <- 12
##' cell_cycle_maybe <- colData(se)$characteristics_ch1.3
##' pgex_sample <- DataFrame(batch=batch, biosample=biosample, ncells=ncells, )
##' cont <- PGEXContainerProto(se, geoSoft=colData(se))
PGEXContainerProto <- function(summarizedExperiment=NULL, pgex_experiment=NULL, pgex_sample=NULL, geo_soft=NULL, ae_idf=NULL, ae_sdrf=NULL, fdata=NULL, exprs=NULL){
    kv <- guess_keys(summarizedExperiment, pgex_sample, geo_soft, ae_sdrf)
    ## Want tables with common keys or keyed by row order
    ## guess keys/number of samples.
    cd <- .DataFrame(summarizedExperiment, pgex_sample, cdata, exprs)
    if(!is.null(summarizedExperiment)){
        #if(! (is.null(exprs) && is.null(cdata) && is.null(fdata))) stop("Cannot provided both `summarizedExperiment` and `exprs` or `cdata` or `fdata`.")
    }
    if(is.null(geo_soft)) geo_soft <- DataFrame()
    if(is.null(ae_sdrf)) ae_sdrf <- DataFrame()
    if(is.null(pgex_experiment)) pgex_experiment <- new('PGEXExperimentMeta')

    MIAMEed <- NULL
    if(any(hasMIAME <- sapply(metadata(summarizedExperiment), inherits, 'MIAME'))){
        MIAMEed <- metadata(summarizedExperiment)[[which(hasMIAME)]]
    }
    
    new('PGEXContainerProto', summarizedExperiment, geo=geo_soft, ae=ae_sdrf, MIAMEed=MIAMEed, pgex_experiment=pgex_experiment)
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
is_invariant <- function(x) length(unique(x))==1

prepData <- function(df){
    invariantCols <- sapply(df, is_invariant)
    list(df=df[,!invariantCols,drop=FALSE], constants=df[1,invariantCols,drop=TRUE])
}

## Make a DataFrame preferentially from the arguments in order listed
.DataFrame <- function(summarizedExperiment, pgex_sample, cdata, exprs){
    if(!missing(summarizedExperiment)){
        return(colData(summarizedExperiment))
    } else if(!missing(pgex_sample)){
        return(as(pgex_sample, 'DataFrame'))
    } else if(!missing(cdata)){
        return(as(cdata, 'Data.Frame'))
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
