library(S4Vectors)
score <- c(1L, 3L, NA)
counts <- c(10L, 2L, NA)
row.names <- c("one", "two", "three")
df <- DataFrame(score, counts, row.names = row.names) #with row names

dfe1 <- new('EncapsulatedDataFrame', DF=df)
dfe2 <- new('EncapsulatedDataFrame', DF=DataFrame(df, nums=1:3))
DataFrame(dfe1, dfe2)
