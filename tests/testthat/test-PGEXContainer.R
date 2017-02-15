context('Create PGEXContainers')

saveGEO <- function(){
    library(GEOquery)
    library(SummarizedExperiment)
    geoexp <- getGEO('GSE42268')
    se <- makeSummarizedExperimentFromExpressionSet(geoexp[[1]])
    saveRDS(se, file='GSE42268_SummarizedExperiment.rds')
}

srcGEO <- function(){
readRDS(system.file("tests", "testthat", "GSE42268_SummarizedExperiment.rds",
                          package='PenultimateGEXContainer'))
}


test_that('Can guess keys', {
    se <- srcGEO()
    kv <- guess_keys(summarizedExperiment=se, pgex_sample=NULL, geo_soft=NULL, ae_sdrf=NULL)
    expect_equal(kv, colnames(se))
    kv <- guess_keys(summarizedExperiment=se, pgex_sample=colData(se), geo_soft=NULL, ae_sdrf=NULL)
    expect_equal(kv, colnames(se))
    expect_error(kvbad <- guess_keys(summarizedExperiment=se, pgex_sample=DataFrame(row.names=LETTERS[1:10]), geo_soft=NULL, ae_sdrf=NULL), 'Discordant')
    kv <- guess_keys(summarizedExperiment=NULL, pgex_sample=NULL, geo_soft=colData(se), ae_sdrf=colData(se))
    })

test_that("Can find non-empty MIAME", {
    
})

test_that("cbind_unique preserves non-identical columns", {
    d1 <- data.frame(A=1:5, B=6:10)
    d2 <- data.frame(D=c('6', '7', '8', '9', '10'))
    d3 <- data.frame(D=c(6:9, NA))
    expect_equal(cbind_unique(d1, d2), cbind(d1, d2))
    expect_equal(cbind_unique(d1, d3), cbind(d1, d3))
})

test_that("cbind_unique removes duplicate columns", {
    d1 <- data.frame(A=1:5, B=6:10)
    d2 <- data.frame(C=c('6', '7', '8', '9', '10'), A=1:5)
    d3 <- data.frame(C=c('6', '7', '8', '9', '10'), D=1:5)
    expect_equal(cbind_unique(d1, d2), cbind(d1, d3)[,-4])
    expect_equal(cbind_unique(d1, d2), cbind(d1, d2)[,-4])
})


test_that('Can create with only summarizedExperiment', {
    se <- srcGEO()
   
    pgc <- PGEXContainerProto(se)
    expect_is(pgc, 'PGEXContainerProto')
    })

test_that('Can create full container', {
    pgex <- PGEX_promote(proto)
    expect_is(pgex, 'PGEXContainer')
    expdata <- pgex_experiment(proto)
    pgex_experiment(proto)$pgex_platform <- 'batman'
    pgex_experiment(proto)$pgex_chemistry <- 'squirrel'
    expect_error(PGEX_promote(proto), 'platform.*batman')
    expect_error(PGEX_promote(proto), 'chemistry.*squirrel')
    pgex_experiment(proto) <- expdata
    colData(proto)$pgex_batch <- NULL
    expect_error(PGEX_promote(proto), 'batch')
})
