library(googlesheets)
library(stringr)
library(data.table)
sht <- gs_key('1i4DMDxNhKCvrtKJJ3HJN5SjKRcaQbHz0eCA3wsqJHg0')
overall_gs <- as.data.table(gs_read(sht, 'overall'))
overall_gs[,pgex_name:= str_c('pgex_', Column)]
overall <- overall_gs[,.(key_long=str_split(Keys, ';')),key=list(pgex_name, `Unique Types`, Keys, Values, Description)]
write.csv(overall_gs, "data-raw/pgex_experiment.csv")
pgex_experiment <- overall
devtools::use_data(pgex_experiment, overwrite = TRUE)
