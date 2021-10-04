#' internal function to check and complete metadata.
#' @param filename filename of the data file
#' @param ... metadata fields
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
  meta$share <- share
  meta$data <- data
  return(meta)
}
