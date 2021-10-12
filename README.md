# diggeR

A simple R package for interfacing (searching, downloading, uploading) [datatomb](https://gitlab.spang-lab.de/containers/datatomb/).

Coverage of the datatomb API is (intentionally) not complete. E.g., admin commands should not be possible via this interface. Pull requests or feedback on other missing functionality are greatly appreciated.

A more feature-complete datatomb frontend available on the command line is [glacier](https://gitlab.spang-lab.de/jsimeth/glacier) (besides curl 😉). glacier includes functionality to track the "ancestry" of datasets. That means datasets typically have parents and children (This information is discarded when using diggeR).

## Configuration

For persistent configuration, create a file in `XDG_CONFIG_HOME/diggeR/config.yml` like the following

``` yaml
default:
  token: "[your long access token]"
  server: "https://data.spang-lab.de/api/v1"
```

If `XDG_CONFIG_HOME` is not set, the following algorithm is used to determine the location of `diggeR/config.yml`:

```R
xdg_home <- Sys.getenv("XDG_CONFIG_HOME")
if( xdg_home == '' ) {
    homedir <- Sys.getenv("HOME")
      if( homedir == '' ) {
            # fall-back to current directory
                homedir <- getwd()
                  }
                    xdg_home <- paste0(homedir, "/", ".config")
}
```

Access tokens are handed out by the auth server, in our case <https://auth.spang-lab.de>.

Additional configs other than the "default" can be created and used by setting `R_CONFIG_ACTIVE`, see [the config package](https://cran.r-project.org/web/packages/config/vignettes/introduction.html).

Anonymous usage without a token is possible, but emits warnings upon package load.
For a single session, the token can also be set using `set_token("[your long access token]")`.
The environment variable `ACCESS_TOKEN` overrides (if valid) any set access token in the config.

## Installation

1. Clone this repo
2. Start an `R` session from the repository root folder
3. Run following code snippet from within `R`
   ```R
      install.packages("devtools")
         devtools::install()
            ```

## Interactive usage

### search for data sets

``` R
library(diggeR)
search("dtd.model")
```
returns a data frame with search results containing names, hashes, project names and descriptions.

More fine-grained search is possible using the keywords, e.g.,
``` R
library(diggeR)
search(tags=c("dtd.model", "macro"), author="mschoen")
```
See the docstring `?diggeR::search` for details.

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

### update_metadata

It is possible to alter metadata on the server. E.g., if a dataset should be made public, the following can be done:
``` R
meta <- metadata(hash)
meta$share <- "public"
update_metadata(hash, meta)
```

### delete

``` R
delete(hash)
```
will ask you before actual deletion.

If you want to delete without being asked, pass `quiet = TRUE`.

If data sets that haven't been uploaded via diggeR should also be deleted, then pass `force=TRUE`.

## Usage in scripts and best practices

### ensure file integrity and improve reproducibility
To tie your commits to a dataset that should be used in your scripts, you can
``` R
ensure("file.h5", "abb5c806601182d92a68e62889fba2e7d145dc3f8f485d28a693c8e3db975cae")
```
(note that here, the full hash is necessary). This will check, if `file.h5` exists and has the correct checksum. If it does not exist, then it downloads it from datatomb. If it has a wrong hash, the function errors, except `replace=TRUE` is set (then the corrupt file is overwritten by the remote file).

To verify that an existing file has the correct check sum, you can instead call `check("file.h5", "abb5c806601182d92a68e62889fba2e7d145dc3f8f485d28a693c8e3db975cae")`.

Integrating these functions in your script will make the input to your script more predictable and excludes potential overwriting of files and alike. It will also make your scripts easily runnable via a remote machine without copying the necessary input files alongside.

### automatic dependency resolution
When using the metadata field `parents`, it is possible to resolve dependencies automatically. Combining wrong input files is one of the most frequent source of errors and depending on just one file and pulling the appropriate information automatically leads to more consistent results.

Example: I have a script that takes some kind of learnt model and applies it to some other dataset. Now, I want to know, on what dataset the model has been learnt (or need that file for some reason), so I can do something like the following:

``` R
modelhash <- "abcdef123456789"
modelmeta <- diggeR::metadata(modelhash)
trainingdatahash <- modelmeta$parents[1]
diggeR::ensure("model.h5", modelhash)
diggeR::ensure("trainingdata.h5", trainingdatahash)
```

This requires to store the parents in the datasets when uploading to datatomb. Glacier does this automatically, in diggeR, one would have to set parents explicitly at the time of uploading.

If named dependencies are needed, similar information can also be stored in the more generic `data` field.

