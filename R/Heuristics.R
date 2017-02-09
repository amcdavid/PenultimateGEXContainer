## Methods to help building/converting columns into pgex formats
cellcycle <- data.table(cycle=c('G0', 'G1', 'S', 'G2', 'M', 'S/G2', 'G2/M', 'S/G2/M'),
                       hoechst_cell_cycle=c(5, 23, 58, 80, 95, (23+58)/2, (80+95)/2, (95+58)/2))
