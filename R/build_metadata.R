#' function to check and complete metadata.
#' @description this function is usually called by upload or update_metadata, but can also be called to create a suitable metadata (list) object to modify and pass on.
#'
#' @param filename filename of the data file
#' @param name name of the dataset
#' @param tags array of tags.
#' @param projectname name of the project. defaults to the current directory name
#' @param description longer descriptional text of the dataset
#' @param parents an array of hashes that this dataset depends on.
#' @param data any list object to be stored along with the dataset.
#' @param share accessibility of the dataset. either "public", "internal" or "private"
#'
#' @return metadata list object that can be passed to upload or update_metadata etc
#'
#' @export
#
build_metadata <- function(filename = NA,
                           name = NA,
                           tags = c(),
                           projectname = NA,
                           description = NA,
                           parents = c(),
                           data = list(),
                           share = "internal"
                           ) {
  meta <- list()
  meta$generator <- list(
    kind = "diggeR",
    instance = paste(packageVersion("diggeR")),
    ref = NULL
  )
  if( is.na(name) && (! is.na(filename)) ){
    name <- filename
  }
  if( length(name) > 1 ) {
    stop("name must not be a vector")
  }
  if( ! is.character(name) ) {
    stop("name must be character")
  }
  meta$name <- name
  if( ! is.vector(tags) ) {
    tags <- c(tags)
  }
  if( ! is.character(tags) ) {
    stop("tags must be character")
  }
  meta$tags <- tags
  if( is.na(projectname) ){
    if( ! is.na(filename)) {
      projectname <- basename(dirname(filename))
    } else {
      stop("neither file nor projectname given")
    }
  }
  if( length(projectname) > 1 ) {
    stop("projectname must not be a vector")
  }
  if( ! is.character(projectname) ) {
    stop("projectname must be a character")
  }
  meta$projectname <- projectname
  if( is.na(description) ) {
    warning("description is empty. Continuing anyway.")
  } else {
    if( ! is.character(description) ) {
      stop("description must be a character")
    }
    if( length(description) > 1) {
      stop("description must not be a vector")
    }
    meta$description <- description
  }
  if( is.null(share) ) {
    warning("no share given, making dataset internal.")
    share <- "internal"
  }
  if( share != "private" && share != "public" && share != "internal") {
    stop("share can only be \"private\", \"internal\", or \"public\"")
  }
  if( ! is.null(parents) ){
    meta$parents <- sapply(parents, diggeR::resolve_id)
    names(meta$parents) <- NULL
  } else {
    meta$parents <- c()
  }
  meta$share <- share
  meta$data <- data
  return(meta)
}
