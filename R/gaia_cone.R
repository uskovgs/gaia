#' Make gaia query
#'
#' @param output_format output table format
#' @param adql ADQL string
#'
#' @return A `response()` object.
#' @export
#'
gaia_query_sync <- function(output_format, adql) {

  query = list(
    REQUEST = "doQuery",
    LANG    = "ADQL",
    FORMAT  = output_format,
    QUERY   = adql
  )

  httr::GET(
    url = "https://gea.esac.esa.int/tap-server/tap/sync",
    query = query
  )
}

#' Gaia cone search
#'
#' @param ra RA
#' @param dec DEC
#' @param table_name gaia table name (default = "gaiadr3.gaia_source")
#' @param row_limit number of the most nearest sources (default = 50). Set to *-1* for unlimited
#' @param verbose show ADQL query? (default = FALSE)
#' @param cols vector of column names (default = NULL)
#' @param radius circle radius in degrees
#'
#' @return A data frame
#' @export
#'
#' @examples
#' \dontrun{
#' gaia_cone_search(
#' ra = 95.1669125,
#' dec = 26.725528,
#' radius = 15/3600, # 15 arcseconds
#' table_name = "gaiadr3.gaia_source",
#' cols = c("source_id", "ra", "ra_error", "dec", "dec_error"),
#' verbose = TRUE)
#' }
gaia_cone_search <- function(ra, dec, radius,
                             row_limit = 50L,
                             table_name = "gaiadr3.gaia_source",
                             cols = NULL,
                             verbose = FALSE) {

  # gaia cone search work only for one point
  check_params(ra, dec, radius, row_limit)
  check_table(table_name)

  if(is.null(cols)) {
    cols <- "*"
  } else {
    check_colnames(cols, table_name)
    cols <- paste(cols, collapse = ", ")
  }

  row_limit <- ifelse(row_limit == -1, "", glue::glue("TOP {row_limit}"))

  adql <- glue::glue("
  SELECT {row_limit} {cols}, DISTANCE(
      POINT('ICRS',ra, dec),
      POINT('ICRS', {ra}, {dec})
  ) AS dist
  FROM
    {table_name}
  WHERE
    1 = CONTAINS(
    POINT('ICRS', ra, dec),
    CIRCLE('ICRS', {ra}, {dec}, {radius})
  )
  ORDER BY
    dist ASC
  ")

  if(verbose)
    print(adql)

  resp <- gaia_query_sync("json", adql) %>%
    read_json_response()

  return(resp)
}


#' Search gaia source by source_id
#'
#' @param id vector of source_id (bit64::integer64, character)
#' @param table_name gaia table name (default = "gaiadr3.gaia_source")
#' @param cols vector of column names (default = NULL)
#' @param verbose show ADQL query? (default = FALSE)
#'
#' @return A data frame
#' @export
#'
#' @examples
#' \dontrun{
#' sources <- c("3432266562766594688", "3432266562764508032")
#' sources_int64 <- bit64::as.integer64(sources)
#' gaia_search_by_id(sources, verbose = TRUE)
#' gaia_search_by_id(sources_int64, cols = c("source_id", "ra", "ra_error", "dec", "dec_error"))
#'}
gaia_search_by_id <- function(id,
                              table_name = "gaiadr3.gaia_source",
                              cols = NULL,
                              verbose = FALSE) {
  # checkmate::assert_int(id)
  checkmate::assert_multi_class(id, c("integer64", "character"))

  if(is.null(cols)) {
    cols <- "*"
  } else {
    check_colnames(cols, table_name)
    cols <- paste(cols, collapse = ", ")
  }

  ids <- id %>%
    paste(collapse = ", ") %>%
    paste0("(", ., ")")

  adql <- glue::glue("
  SELECT  {cols}
  FROM {table_name}
  WHERE source_id IN {ids}
  ")
#
#   adql <- glue::glue("
#   SELECT  {cols}
#   FROM {table_name}
#   WHERE source_id = {id}
#   ")

  if(verbose)
    print(adql)

  resp <- gaia_query_sync("json", adql)

  resp %>%
    read_json_response()

}



