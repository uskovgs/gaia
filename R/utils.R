#' Check table format and table name.
#'
#' @param format output table format
#' @param table_name table name
#'
check_legal <- function(format, table_name) {
  format_list <- c("votable",
                   "votable_plain",
                   "csv",
                   "json",
                   "fits")
  checkmate::assert_choice(format, choices = format_list)

  table_name_list <- c("gaiaedr3.gaia_source",
                       "gaiadr2.gaia_source",
                       "gaiadr1.gaia_source"
                       )
  checkmate::assert_choice(table_name, choices = table_name_list)

}
