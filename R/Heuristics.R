## Methods to help building/converting columns into pgex formats
cycle_regex <- c('\\b(?=S).*(?=G2)\\b', '\\b(?=G2).*(?=M)\\b', '\\b(?=S).*(?=G2).*(?=M)\\b', '\\bG0\\b', '\\bG1\\b', '\\bS\\b', '\\bG2\\b', '\\bM\\b')
cellcycle <- data.table(cycle_regex=cycle_regex,
                        hoechst_cell_cycle=c((23+58)/2, (80+95)/2, (95+58)/2, 5, 23, 58, 80, 95),
                        idx = seq_along(cycle_regex))

guess_cell_cycle <- function(x){
    ##dx_cycle <- adist(x, cellcycle$cycle_regex, partial=TRUE, ignore.case=TRUE)
    dx_cycle <- cellcycle[,.(xi=seq_along(x), x=x, detected=stringr::str_detect(x, stringr::regex(cycle_regex, ignore_case=TRUE)), hoechst_cell_cycle),key=idx]
    ## FIXME: take first match for each
    setkey(dx_cycle, xi, idx)
    dx_cycle[detected==TRUE][,hoechst_cell_cycle[1],key=list(xi)]
}
