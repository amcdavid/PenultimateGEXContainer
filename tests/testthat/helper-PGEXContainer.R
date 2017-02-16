## library(GEOquery)
## geoexp <- getGEO('GSE42268')
## se <- makeSummarizedExperimentFromExpressionSet(geoexp[[1]])
library(SummarizedExperiment)
se <- readRDS(system.file("tests", "testthat", "GSE42268_SummarizedExperiment.rds",
                          package='PenultimateGEXContainer'))
dats <- split_invariant(colData(se))
colData(se)<- dats$variant
## No batch info available
## Note that we need to be careful to set the right data types.
## No coercion is attempted
batch  <- rep(NA_character_, ncol(se))
## NA by default is logical, which violates schema

## Would be a factor by default
biosample <- as.character(colData(se)$characteristics_ch1)
rna_pg <-  colData(se)$characteristics_ch1.2
ncells_maybe  <- colData(se)$characteristics_ch1.1
ncells <- rep(NA_real_, length(ncells_maybe))
ncells[grepl('single cell', ncells_maybe)] <- 1
ncells[grepl('50 cells', ncells_maybe) ] <- 50
ncells[grepl('12 cells', ncells_maybe)] <- 12
ncells[grepl('10 pg', rna_pg) & grepl('total RNA', ncells_maybe)] <- 1.2
ncells[grepl('1 ug', rna_pg) & grepl('total RNA', ncells_maybe)] <- 120
ncells[grepl('averaged single cell lysis', rna_pg) & grepl('LIMprep', ncells_maybe)] <- 1
cell_cycle_maybe <- colData(se)$characteristics_ch1.3
pgex_sample <- DataFrame(pgex_batch=batch, pgex_biosample=biosample, pgex_ncells=ncells, pgex_filter_study_pass=TRUE)
pgex_experiment <- list(pgex_platform='cell_ina_well', pgex_chemistry='3prime polyA tailing',
                        pgex_has_umi=FALSE, pgex_ercc_version=NA, pgex_molecule='polyA RNA',
                        pgex_is_public=TRUE, pgex_transformation=NA)
proto <- PGEXContainerProto(se, geo_soft=colData(se), pgex_sample=pgex_sample, pgex_experiment=pgex_experiment)
