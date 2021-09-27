dt_baseurl = "https://data.spang-lab.de/api/v1/"
dt_access_token = Sys.getenv("ACCESS_TOKEN")

dt_get <- function(...) {
    httr::GET(..., httr::add_headers(Authorization = dt_access_token))
}

dt_get_meta <- function(hash) {
    # GET /meta/<hash>
    # returns all metadata of <hash> as json object.
}

dt_search <- function(search_string, silent = FALSE) {
    # returns a list of hashes. query may be any key-value pair combining
    # any: free text search in all fields
    # name: user-provided (possibly non-unique) name of the dataset.
    # author: datasets authored by some specific user
    # tag: dataset has tag attached
    # description: free text search in description field
    # after: created after some time point (unix time)
    # before: created before some time point (unix time)
    # lastAccessBefore: last access before some time point (unix time). Only available for admins and mainly used to identify deletion candidates
    # child=<hash>: returns all parents of hash
    # hash=<hash>: returns itself (can be used to check for existance of a hash)
    # commit: commit or id that can be used to identify a commit.
    # project: project id
    # Several conditions are AND-connected.
    # Example: GET /meta/search?name=my_dataset&author=my_user will return all datasets named "my_dataset" and were created by "my_user".
    response <- httr::GET(
        url = paste0(dt_baseurl, "meta/search?any=", search_string),
        httr::add_headers(Authorization = dt_access_token)
    )
    hashes <- unlist(strsplit(httr::content(response), split = ","))
    clean_hashes <- if (setequal(hashes, "[]")) {
        character()
    } else {
        gsub("[[:punct:]]", "", hashes)
    }
    info_frame <- data.frame(
        "names" = rep(NA, length(clean_hashes)),
        "hash" = clean_hashes,
        "description" = rep(NA, length(clean_hashes))
    )
    n <- length(clean_hashes)
    for (i in seq_along(clean_hashes)) {
        if (!silent) cat(glue::glue("\r{i}/{n}"))
        hash <- clean_hashes[i]
        meta <- httr::GET(
            url = paste0(dt_baseurl, "meta/", hash),
            httr::add_headers(Authorization = dt_access_token)
        )
        meta.readable <- rjson::fromJSON(httr::content(meta))
        info_frame$names[i] <- meta.readable$name
        info_frame$description[i] <- meta.readable$description
    }
    # TODO: sending 1 search request to fetch n hashes and then n requests to
    # fetch n names and descriptions is slow (because it requires n + 1 HTTP
    # requests). Check if it is possible to send 1 search request to query hash,
    # name and description directly. I.e. above for loop should be removed.
    if (!silent) cat("\n")
    return(info_frame)
}

df_download <- function(hash) {
    response <- GET(
        url = paste0(dt_baseurl, hash),
        httr::add_headers(Authorization = dt_access_token)
    )
    the.data <- httr::content(response, "raw")
    meta <- GET(
        url = paste0(dt_baseurl, "meta/", hash),
        httr::add_headers(Authorization = dt_access_token)
    )
    the.meta <- rjson::fromJSON(httr::content(meta))
    writeBin(
        object = the.data,
        con = paste0(data$path.to.data, the.meta$name)
    )
}