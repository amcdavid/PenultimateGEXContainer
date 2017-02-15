library(googlesheets)
library(stringr)
library(data.table)
sht <- gs_key('1i4DMDxNhKCvrtKJJ3HJN5SjKRcaQbHz0eCA3wsqJHg0')
overall_gs <- as.data.table(gs_read(sht, 'overall'))
overall_gs[,pgex_name:= str_c('pgex_', Column)]
overall <- overall_gs[,.(key_long=str_split(Keys, ';')),key=list(pgex_name, `Unique Types`, Keys, Values, Description, Mandatory)]
write.csv(overall_gs, "data-raw/experiment_schema.csv")
experiment_schema <- overall

sht <- gs_key('1vP7-qQkPJ_gmBsouVFWKSTByNN617L8XxX6Uw2FNefc')
overall_gs <- as.data.table(gs_read(sht, 'overall'))
overall_gs[,pgex_name:= str_c('pgex_', Column)]
overall <- overall_gs[,.(key_long=str_split(Keys, ';')),key=list(pgex_name, `Unique Types`, Keys, Values, Description, Mandatory)]
write.csv(overall_gs, "data-raw/sample_schema.csv")
sample_schema <- overall

devtools::use_data(experiment_schema, sample_schema, overwrite = TRUE, internal=TRUE)
