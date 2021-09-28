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

Access tokens are handed out by the auth server, in our case https://auth.spang-lab.de.

Additional configs other than the "default" can be created and used by setting `R_CONFIG_ACTIVE`, see [the config package](https://cran.r-project.org/web/packages/config/vignettes/introduction.html).

Anonymous usage without a token is possible, but emits warnings upon package load.
For a single session, the token can also be set using `set_token("[your long access token]")`.
The environment variable `ACCESS_TOKEN` overrides (if valid) any set access token in the config.

## Installation
TBD, standard R package

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

### delete

``` R
delete(hash)
```
will ask you before actual deletion.

If you want to delete without being asked, pass `quiet = TRUE`.

If data sets that haven't been uploaded via diggeR should also be deleted, then pass `force=TRUE`.


## Usage in scripts
To tie your commits to a dataset that should be used in your scripts, you can
``` R
ensure("file.h5", "abb5c806601182d92a68e62889fba2e7d145dc3f8f485d28a693c8e3db975cae")
```
(note that here, the full hash is necessary). This will check, if `file.h5` exists and has the correct checksum. If it does not exist, then it downloads it from datatomb. If it has a wrong hash, the function errors, except `replace=TRUE` is set (then the corrupt file is overwritten by the remote file).

To verify that an existing file has the correct check sum, you can instead call `check("file.h5", "abb5c806601182d92a68e62889fba2e7d145dc3f8f485d28a693c8e3db975cae")`.

Integrating these functions in your script will make the input to your script more predictable and excludes potential overwriting of files and alike. It will also make your scripts easily runnable via a remote machine without copying the necessary input files alongside.
