# gaia esa API wrapper


[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)



## Installation

You can install the development version of gaia like so:

``` r
devtools::install_github("uskovgs/gaia")
```

## Example

This is a basic example which shows you how to solve a common problem:

## Cone search

``` r
library(gaia)
gaia_cone_search(
  ra = 43.1417,
  dec = 43.1674,
  radius = 40/3600, # 15 arcseconds
  table_name = "gaiadr3.gaia_source",
  cols = c("source_id", "ra", "ra_error", "dec", "dec_error"),
  verbose = TRUE)
#> SELECT TOP 50 source_id, ra, ra_error, dec, dec_error, DISTANCE(
#>     POINT('ICRS',ra, dec),
#>     POINT('ICRS', 43.1417, 43.1674)
#> ) AS dist
#> FROM
#>   gaiadr3.gaia_source
#> WHERE
#>   1 = CONTAINS(
#>   POINT('ICRS', ra, dec),
#>   CIRCLE('ICRS', 43.1417, 43.1674, 0.0111111111111111)
#> )
#> ORDER BY
#>   dist ASC
#> # A tibble: 4 × 6
#>   source_id    ra ra_error   dec dec_error   dist
#>     <int64> <dbl>    <dbl> <dbl>     <dbl>  <dbl>
#> 1      3e17  43.1  0.320    43.2    0.328  0.0101
#> 2      3e17  43.2  0.198    43.2    0.208  0.0102
#> 3      3e17  43.1  1.86     43.2    1.05   0.0108
#> 4      3e17  43.2  0.00955  43.2    0.0109 0.0110
```

## Searching by `source_id` column.

### `source_id` as type character

``` r
sources <- c("337387891762945152", "337384941121847552")
gaia_search_by_id(sources, 
                  cols = c("source_id", "ra", "ra_error", "dec", "dec_error"), 
                  verbose = TRUE)
#> SELECT  source_id, ra, ra_error, dec, dec_error
#> FROM gaiadr3.gaia_source
#> WHERE source_id IN (337387891762945152, 337384941121847552)
#> # A tibble: 2 × 5
#>   source_id    ra ra_error   dec dec_error
#>     <int64> <dbl>    <dbl> <dbl>     <dbl>
#> 1      3e17  43.2  0.00955  43.2    0.0109
#> 2      3e17  43.1  0.320    43.2    0.328
```

### Or using int64

``` r
# source_id column with long type (int64)
sources_int64 <- bit64::as.integer64(sources)
gaia_search_by_id(sources, 
                  cols = c("source_id", "ra", "ra_error", "dec", "dec_error"), 
                  verbose = TRUE)
#> SELECT  source_id, ra, ra_error, dec, dec_error
#> FROM gaiadr3.gaia_source
#> WHERE source_id IN (337387891762945152, 337384941121847552)
#> # A tibble: 2 × 5
#>   source_id    ra ra_error   dec dec_error
#>     <int64> <dbl>    <dbl> <dbl>     <dbl>
#> 1      3e17  43.2  0.00955  43.2    0.0109
#> 2      3e17  43.1  0.320    43.2    0.328
```
