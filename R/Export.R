setAs('PGEXContainer', 'list', function(from){
    list(exprs=assay(from), cdata=colData(from), fdata=rowData(from), expdata=pgex_experiment(from), geo_data = from@geo, ae_data=from@ae, meta=metadata(from))
})

##' Convert to a list
##'
##' @param x \code{PGEXContainer}
##' @return list with components
##' @export
pgex_to_list <- function(x){
    as(x, 'list')
}
