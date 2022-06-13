#' Gaia cone query
#'
#' @param ra
#' @param dec
#' @param radius
#' @param table_name
#' @param output_format
#' @param row_limit
#' @param verbose
#'
gaia_cone_query <- function(ra, dec,
                            r_arcmin,
                            table_name,
                            output_format,
                            row_limit,
                            verbose = FALSE
                      ) {

  checkmate::assert_number(ra)
  checkmate::assert_number(dec)
  checkmate::assert_number(r_arcmin)
  checkmate::assert_int(row_limit)

  # output_format <- "csv"

  check_legal(output_format, table_name)

  radius <- r_arcmin / 60
  row_limit <- ifelse(row_limit == -1, "", glue::glue("TOP {row_limit}"))

  adql <- glue::glue("
  SELECT
    {row_limit}
    *,
    DISTANCE(
      POINT('ICRS',ra,dec),
      POINT('ICRS', {ra}, {dec})
    ) AS dist
  FROM
    {table_name}
  WHERE
    1 = CONTAINS(
    POINT('ICRS',ra,dec),
    CIRCLE('ICRS',{ra}, {dec}, {radius})
  )
  ORDER BY
    dist ASC
  ")



  query = list(
    REQUEST = "doQuery",
    LANG    = "ADQL",
    FORMAT  = output_format,
    QUERY   = adql
  )

  if(verbose) {
    print(adql)
    resp <- httr::GET(
      url = "https://gea.esac.esa.int/tap-server/tap/sync",
      query = query,
      httr::verbose()
    )
  } else {
    resp <- httr::GET(
      url = "https://gea.esac.esa.int/tap-server/tap/sync",
      query = query
    )
  }


  resp
}

#' Gaia cone search
#'
#' @param ra
#' @param dec
#' @param r_arcmin
#' @param table_name
#' @param output_format
#' @param row_limit
#' @param verbose
#'
#' @return
#' @export
#'
#' @examples
gaia_cone <- function(ra, dec, r_arcmin,
                      table_name = "gaiadr2.gaia_source",
                      row_limit = 50L,
                      verbose = FALSE) {

  resp <- gaia_cone_query(ra = ra,
                          dec = dec,
                          r_arcmin = r_arcmin,
                          table_name = table_name,
                          output_format = "json",
                          row_limit = row_limit,
                          verbose = verbose)
  cont <- resp %>%
    httr::content(as='text', encoding = "UTF-8") %>%
    jsonlite::fromJSON(simplifyDataFrame = TRUE,
                       bigint_as_char = TRUE)

  meta <- cont$metadata

  data <-  as.data.frame(cont$data)
  colnames(data) <- meta$name

  int64_cols <- which(meta$datatype == "long")
  data[int64_cols] <- lapply(data[int64_cols], bit64::as.integer64)


  return(data)
}



