saveGEO <- function(){
    library(GEOquery)
    library(SummarizedExperiment)
    geoexp <- getGEO('GSE42268')
    se <- makeSummarizedExperimentFromExpressionSet(geoexp[[1]])
    saveRDS(se, file='GSE42268_SummarizedExperiment.rds')
}

srcGEO <- function(){
    readRDS('GSE42268_SummarizedExperiment.rds')
}
