setMethod('nrow', list(x='EncapsulatedDataFrame'), function(x){
    nrow(x@DF)
})

setMethod('length', list(x='EncapsulatedDataFrame'), function(x){
     ncol(x)
})

## setMethod('showAsCell', list(object='EncapsulatedDataFrame'), function(object){
##     callNextMethod()
##     })


## setMethod('show', list(object='EncapsulatedDataFrame'), function(object){
##     callNextMethod()
##     })
