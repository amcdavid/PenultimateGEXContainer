context('Create PGEXContainers')

## test_that('Can create empty class', {    
##     expect_is(PGEXContainerProto(), 'PGEXContainerProto')
##     })


test_that('Can guess keys', {
    se <- srcGEO()
    kv <- guess_keys(summarizedExperiment=se, pgex_sample=NULL, geo_soft=NULL, ae_sdrf=NULL)
    expect_equal(kv, colnames(se))
    kv <- guess_keys(summarizedExperiment=se, pgex_sample=colData(se), geo_soft=NULL, ae_sdrf=NULL)
    expect_equal(kv, colnames(se))
    expect_error(kvbad <- guess_keys(summarizedExperiment=se, pgex_sample=DataFrame(row.names=LETTERS[1:10]), geo_soft=NULL, ae_sdrf=NULL), 'Discordant')
    kv <- guess_keys(summarizedExperiment=NULL, pgex_sample=NULL, geo_soft=colData(se), ae_sdrf=colData(se))
    })


test_that('Can create with only summarizedExperiment', {
    se <- srcGEO()
    pgc <- PGEXContainerProto(se)
    expect_is(pgc, 'PGEXContainerProto')
    })
