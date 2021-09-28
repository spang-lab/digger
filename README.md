# diggeR

A R package for interfacing (searching, downloading, uploading) datatomb.

## Configuration
For persistent configuration, create a file in `XDG_CONFIG_HOME/diggeR/config.yml` like the following
``` yaml
default:
  token: "[your long access token]"
  server: "https://data.spang-lab.de/api/v1"
```

Access tokens are handed out by the auth server, in our case (https://auth.spang-lab.de).

Additional configs other than the "default" can be created and used by setting `R_CONFIG_ACTIVE`, see [the config package](https://cran.r-project.org/web/packages/config/vignettes/introduction.html).

Anonymous usage without a token is possible, but emits warnings upon package load.
For a single session, the token can also be set using `set_token("[your long access token]")`.
The environment variable `ACCESS_TOKEN` overrides (if valid) any set access token in the config.

## Installation
TBD, standard R package

## Usage

### search for data sets
``` R
library(diggeR)
search("dtd.model")
```
returns a data frame containing names, hashes, project names and descriptions.

### download data sets 
``` R
file_name <- download("88b3e7e08b2dfcc486e8")
print(file_name)
```
The filename will be that from the data set. If the file should be stored elsewhere, just be more explicit:
``` R
file_name <- download("88b3e7e08b2dfcc486e8", file="this_dataset.h5")
print(file_name)
```

### metadata

``` R
meta <- metadata("88b3e7e08b2dfcc486e8")
names(meta)
meta$projectname
```

### upload
``` R
hash <- upload("test.h5", tags=c("testtag", "othertag"), description="a long test description.", share="private")
metadata(hash)
```

### delete

``` R
delete(hash)
```
will ask you before actual deletion.

If you want to delete without being asked, pass `quiet = TRUE`.

If data sets that haven't been uploaded via diggeR should also be deleted, then pass `force=TRUE`.
