#' delete a data set remotely on datatomb
#'
#' @description Allows to delete remote files stored on datatomb.
#' If not explicitly deactivated, the user has to confirm the deletion before the request is sent.
#' By default, this function also only deletes datasets that were uploaded via diggeR to reduce
#' destructive interference with other tools like glacier.
#'
#' @param hash hash to delete
#' @param quiet if set to TRUE, don't ask before deletion
#' @param force if set to TRUE, allow deletion of datasets that were not uploaded using diggeR
#'
#' @export
delete <- function(hash, quiet = FALSE, force = FALSE) {
  if( ! quiet || ! force ) {
    meta <- metadata(hash)
    if( ! quiet ) {
      yn <- readline(prompt = paste0(
                      "Do you really want to remotely (= ON THE SERVER) delete the data set with hash \"",
                      hash, "\" (name: \"", meta$name, "\") [Ny]"))
      if( yn != "y" && yn != "Y" && yn != "j" && yn != "J" ) {
        stop("deletion aborted upon request")
      }
    }
    if( ! force ) {
      if( meta$generator$kind != "diggeR" ){
        stop("dataset was not uploaded by diggeR and thus can have dependent data sets. Won't delete this dataset (set force to TRUE if you know what you are doing.)")
      }
    }
  }
  hash <- resolve_hash(hash)
  response <- DELETE(
      url = paste0(pkg.env$dt_config[["server"]], "/", hash),
      httr::add_headers(Authorization = diggeR:::get_token())
  )
  if( response$status_code != 200 ) {
    stop(paste0("deletion failed: ", httr::content(response)$error))
  }
}
