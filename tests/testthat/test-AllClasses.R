context('Class construction')
test_that('Can create empty class', {
    pgex <- new("PGEXContainerProto")
    expect_is(pgex, 'PGEXContainerProto')
    expect_equal(pgex@pgex_version, as.character(packageVersion('PenultimateGEXContainer')))
    })

