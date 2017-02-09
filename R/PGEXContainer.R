##' Construct a PGEX Container Prototype
##'
##' A \code{PGEXContainerPrototype} is a \code{PGEXContainer} that has not had its fields validated for consistency and validity.
##' This allows step-wise construction.
##' @return object of class \code{PGEXContainerPrototype}
##' @import data.table
##' @examples
##' library(GEOquery)
##' geoexp <- getGEO('GSE42268')
##' se <- lapply(geoexp, makeSummarizedExperimentFromExpressionSet)
##' geoDF <- pData(geoexp[[1]])
##' batch  <- rep(1, ncol(se[[1]]))
##' biosample <- colData(se[[1]])$characteristics_ch1
##' rna_pg <-  colData(se[[1]])$characteristics_ch1.2
##' ncells_maybe  <- colData(se[[1]])$characteristics_ch1.1
##' ncells <- rep(NA_numeric_, length(ncells_maybe))
##' ncells[ncells_maybe %like% 'single cell'] <- 1
##' ncells[ncells_maybe %like% '50 cells'] <- 50
##' ncells[ncells_maybe %like% '12 cells'] <- 12
##' cell_cycle_maybe <- colData(se[[1]])$characteristics_ch1.3
##' cell_cycle <- colData(se[[1]])$characteristics_ch1.3
##' pgex_sample <- DataFrame(batch=rep(1, ncol(se[[1]])), biosample=rep(1, ncol(se[[1]])), hoechst_cell_cycle
##' cont <- PGEXContainerPrototype(se[[1]], geoSoft=colData(se[[1]]))
PGEXContainerPrototype <- function(summarizedExperiment, pgex_experiment=DataFrame(), pgex_sample, geo_soft=NULL, ae_idf=NULL, ae_sdrf=NULL, cdata, fdata, exprs){
    ## Combine geo_soft, ae_sdrf, cdata into big table and set metadata to describe provenance of columns
    cd <- .DataFrame(summarizedExperiment, pgex_sample, cdata, exprs)
    if(!missing(ae_idf)){
        cd <- cbind(cd, ae_idf)
        cd <- cbind(cd, guessAeCovariates(ae_idf))
    }
    if(!missing(geo_soft)){
        cd <- cbind(cd, geo_soft)
        cd <- cbind(cd, guessGeoCovariates(geo_soft))
    }
    if(!missing(summarizedExperiment)){
        #if(! (missing(exprs) && missing(cdata) && missing(fdata))) stop("Cannot provided both `summarizedExperiment` and `exprs` or `cdata` or `fdata`.")
    }
    
     new('PGEXContainer', summarizedExperiment)
}

guessAeCovariates <- guessGeoCovariates <- function(x) NULL


## Make a DataFrame preferentially from the arguments in order listed
.DataFrame <- function(summarizedExperiment, pgex_sample, cdata, exprs){
    if(!missing(summarizedExperiment)){
        return(summarizedExperiment)
    } else if(!missing(pgex_sample)){
        return(DataFrame(pgex_sample))
    } else if(!missing(cdata)){
        return(DataFrame(cdata))
    } else if(!missing(exprs)){
        return(DataFrame(row.names=colnames(exprs)))
    } 
}

## Make a DataFrame with no columns but correct number/name of rows, preferentially from the arguments in order listed
.DataFrameRow <- function(summarizedExperiment, pgex_sample, geo_soft, ae_sdrf, cdata, exprs){
    if(!missing(summarizedExperiment)){
        return(DataFrame(row.names=colnames(summarizedExperiment)))
    } else if(!missing(pgex_sample)){
        return(DataFrame(row.names=row.names(pgex_sample)))
    } else if(!missing(geo_soft)){
        return(DataFrame(row.names=row.names(geo_soft)))
    } else if(!missing(ae_sdrf)){
        return(DataFrame(row.names=row.names(ae_sdrf)))
    } else if(!missing(cdata)){
        return(DataFrame(row.names=row.names(cdata)))
    } else if(!missing(exprs)){
        return(DataFrame(row.names=colnames(exprs)))
    } 
}
