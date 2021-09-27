# diggeR

A R package for interfacing (searching, downloading, uploading) datatomb.

## Configuration
For persistent configuration, create a file in `XDG_CONFIG_HOME/digger/config.yml` like the following
``` yaml
default:
  token: "[your long access token]"
  server: "https://data.spang-lab.de/api/v1"
```

Access tokens are handed out by the auth server, in our case (https://auth.spang-lab.de).

Additional configs other than the "default" can be created and used by setting `R_CONFIG_ACTIVE`, see [the config package](https://cran.r-project.org/web/packages/config/vignettes/introduction.html).

Anonymous usage without a token is possible, but emits warnings upon package load.

