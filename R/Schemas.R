##' Test for missing mandatory columns/entries in a table according to a schema
##'
##' @param df \code{data.frame} or \code{list}
##' @param schema \code{data.table} schema with fields set according to the google doc
##' @return \code{character} with names of missing fields, or of length 0 if no missing
lacks_mandatory <- function(df, schema){
    sjoin <- schema[Mandatory==TRUE][!data.table(pgex_name=names(df)),pgex_name,on='pgex_name']
    sjoin
}

is_numericlike <- function(x) suppressWarnings(!is.na(as.numeric(as.character(x))))

##' @describeIn lacks_mandatory test for incorrectly-specified columns/entries. Returns a named \code{character} with hints about incorrect entries, if any.
violates_schema <- function(df, schema){
    sjoin <- schema[data.table(pgex_name=names(df)),,on='pgex_name']
    ## did the column check out?
    schema_check <- setNames(rep(FALSE, nrow(sjoin)), sjoin$pgex_name)
    ## error conditions
    schema_value <- setNames(rep(NA_character_, nrow(sjoin)), sjoin$pgex_name)
    for(cn in sjoin$pgex_name){
        type <- sjoin[cn,`Unique Types`,on='pgex_name']
        if(is.na(type)){
            ## entry not in schema
            schema_check[cn] <- TRUE
        } else if(is_numericlike(type)){
            ## enumerated keys
            invalidkey <- na.omit(setdiff(df[[cn]], unlist(schema[cn,key_long,on='pgex_name'])))
            if(!(schema_check[cn] <- length(invalidkey)==0)) schema_value[cn] <- invalidkey[1]
        } else if(type=='key-value'){
            stop("Not implemented")
        }
        else{
            ## try to interpret as a type
            if(!(schema_check[cn] <- inherits(df[[cn]], type))){
                                                                                                                 schema_value[cn] <- class(df[[cn]])[1]
                                                                                                                   }
        }
    }
    schema_value[!schema_check]
}
