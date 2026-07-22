get_table <- function(
  auth_token = azkit::get_auth_token(),
  table_ep = Sys.getenv("AZ_TABLE_EP"),
  runs_table_name = Sys.getenv("AZ_TABLE_NAME"),
  filter_entities = "run_stage ne ''", # i.e. run_stage must have a value
  select_properties = c(
    "dataset",
    "scenario",
    "create_datetime",
    "run_stage",
    "app_version",
    "sites_aae",
    "sites_ip",
    "sites_op",
    "outputs_app_uri"
  )
) {
  azkit::read_azure_table(
    table_name = runs_table_name,
    table_endpoint = table_ep,
    token = auth_token,
    filter = filter_entities,
    select = paste(select_properties, collapse = ",")
  )
}

get_scheme_lookup <- function(path = "reference/nhp-scheme-lookup.csv") {
  readr::read_csv(path, col_types = "c") |>
    dplyr::select(
      code = `Trust ODS Code`,
      scheme = `Name of Hospital site`,
      trust = `Name of Trust`
    ) |>
    # Reduce St Marys, Charing Cross, Hammersmith (all RYJ) to Imperial
    dplyr::mutate(scheme = dplyr::if_else(code == "RYJ", "Imperial", scheme)) |>
    dplyr::distinct(code, scheme, trust) |>
    dplyr::arrange(code)
}
