
check_table <- function(table_name) {
  table_name_list <- c("gaiaedr3.gaia_source",
                       "gaiadr3.gaia_source",
                       "gaiadr2.gaia_source",
                       "gaiadr1.gaia_source"
  )
  checkmate::assert_choice(table_name, choices = table_name_list)
}


check_format <- function(format) {
  format_list <- c("votable",
                   "votable_plain",
                   "csv",
                   "json",
                   "fits")
  checkmate::assert_choice(format, choices = format_list)
}

check_params <- function(ra, dec, r_arcmin, row_limit) {
  checkmate::assert_number(ra)
  checkmate::assert_number(dec)
  checkmate::assert_number(r_arcmin)
  checkmate::assert_int(row_limit)
}

check_colnames <- function(cols, table_name) {

  checkmate::assert_character(cols)

  if(table_name == "gaiaedr3.gaia_source")
    all_cols <- cols_availvable[["cols_edr3"]]
  if(table_name == "gaiadr3.gaia_source")
    all_cols <- cols_availvable[["cols_dr3"]]
  if(table_name == "gaiadr2.gaia_source")
    all_cols <- cols_availvable[["cols_dr1"]]
  if(table_name == "gaiadr1.gaia_source")
    all_cols <- cols_availvable[["cols_dr1"]]

  checkmate::assert_subset(cols, all_cols)
}


read_json_response <- function(resp) {

  cont <- resp %>%
    httr::content(as='text', encoding = "UTF-8") %>%
    jsonlite::fromJSON(simplifyDataFrame = TRUE,
                       bigint_as_char = TRUE)

  meta <- cont$metadata

  # cont$data is matrix
  data <- as.data.frame(cont$data)
  checkmate::assert_data_frame(data, min.rows = 1)

  colnames(data) <- meta$name

  convert_type_functions <- list(
    "long" = bit64::as.integer64,
    "char" = as.character,
    "double" = as.double,
    "float" = as.double,
    "int" = as.integer,
    "short" = as.integer,
    "boolean" = as.logical
  )
  col_types_functions <- convert_type_functions[meta$datatype]

  data1 <- purrr::map2_dfr(data, col_types_functions, ~.y(.x))

  return(data1)
}

