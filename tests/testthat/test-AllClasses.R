context('Class construction')
test_that('Can create empty class', {
    pgex <- PGEXContainer()
    expect_is(pgex, 'PGEXContainer')
    expect_equal(pgex@pgexVersion, as.character(packageVersion('PenultimateGEXContainer')))
    })

test_that('Can create simple class', {
    
    expect_is(PGEXContainer(), 'PGEXContainer')
    })
