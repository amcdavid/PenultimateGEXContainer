# PenultimateGEXContainer
Although there are several good classes for storing gene expression data, in many cases it's not ideal to share serialized versions of these classes.  The package is meant for intermediate storage/exchange of gene expression data, sample and feature covariates.  It will (eventually) support idempotent conversion to/from HDF5, text files and GEO formats.  Emphasis is placed on harmonizing covariates between studies, so a controlled vocabulary will be made available and use encouraged.  It's design case was for single cell gene expression experiments, but is hoped that it will be useful in other contexts.

## How dreadfully banal. Why attempt to define another format?
Good question.  MAGE-TAB is getting pretty creaky.  GEO/SOFT format almost works, but only for sample-level covariates.  It requires some abuse to model cells, and many datasets only offer a link to the processed data now. Both of these are also missing some important (to me) experiment and sample level covariates.

### Alternatives
- Status quo: ad hockery abounds. Text formats with various headers or whatever happened to be uploaded onto GEO.
- [GEO/SOFT format](https://www.ncbi.nlm.nih.gov/geo/info/soft.html#format).  This is pretty close to what we need for sample and platform covariates, but lacks vocab we'd like to have access to.  ArrayExpress has competing format [IDF](https://www.ebi.ac.uk/arrayexpress/help/creating_an_idf.html), [SDRF](https://www.ebi.ac.uk/arrayexpress/help/creating_a_sdrf.html) and imports GEO experiments weekly, so we should just use that, if it's easy to parse
- We want more enumerated types.
- SummarizedExperiment: this maybe could work, but lacks controlled vocab and important/export outside of R, so we'd need to subclass.
- MIAME: A set of reported dimensions and metrics, not an interchange format (though MAGE-Tab...)

## Controlled vocab
Intended to describe:
-  technical aspects of the assay such as platform, chemistry in greater detail than GEO
-  upstream computational aspects, such as aligner, read trimming, deduplication. These two might be scrapable from the Protocol.
-  cellular covariates such as batch, treatment, sort info
-  sample covariates such as organism, tissue, cell line, age, sex.  Many available in GEO.  Use MeSH/EFO where appropriate. Package `ontoCat` can read them. Key:value rather than tabular?
-  feature covariates: Genome/transcriptome, id type (ENTREZGENE, ENSEMBL, ...)
These should be dynamically crowd-sourced with a google docs sheet.  Then validated and incorporated into namespace as data when package is built using data-raw.

### Use of GEO/SOFT
1.  Use GEO/SOFT, IDF/SDRF or  if present, possibly re-writing if incorrect
2.  Make new field, preserving GEO/SOFT

## API:
ReadPGEX -> .txt, .hdf5
WritePGEX -> .txt, .hdf5
GuessPlatform(character; vocab)
GuessSample(character, vocab)
GuessCell(character, vocab)





-------
PenultimateGEXContainer:  We'll reinvent this wheel at least once more.
-------
