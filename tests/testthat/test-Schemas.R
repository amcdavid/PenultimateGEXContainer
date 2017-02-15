context("Schema validity testing")

## Mock schema
schema <- data.table(pgex_name=c('pgex_arrayexpress_accession', 'pgex_chemistry', 'pgex_ercc_version'),
                     'Unique Types'=c('character', '6', '1'),
                     Mandatory=c(FALSE, TRUE, TRUE),
                     key_long=list(NA, c('10X genomics V2','SMARTer V1'), 'ERCC RNA Spike-In Mix 1'))

## Mock experimentdata
testerbadvalue <- testerbad <- list('pgex_chemistry'='SMARTer V1', 'foo'=3, 'pgex_arrayexpress_accession'='bar')
testergood <- c(testerbad, list('pgex_ercc_version'='ERCC RNA Spike-In Mix 1'))
testerbadkey <- c(testerbad, list('pgex_ercc_version'='batman'))
testerbadvalue$pgex_arrayexpress_accession <- 999
                     
test_that("Has mandatory fields", {
    expect_equal(lacks_mandatory(testerbadvalue, schema), 'pgex_ercc_version')
    expect_equal(length(lacks_mandatory(testerbadkey, schema)), 0)
})

test_that("Schema verifies", {
    expect_equal(length(violates_schema(testergood, schema)), 0)
    expect_equivalent(violates_schema(testerbadkey, schema), 'batman')
    expect_equivalent(violates_schema(testerbadvalue, schema), 'numeric')
})
