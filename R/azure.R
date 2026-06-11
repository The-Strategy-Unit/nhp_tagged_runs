get_table <- function(
  auth_token = azkit::get_auth_token(),
  table_ep = Sys.getenv("AZ_TABLE_EP"),
  table_name = Sys.getenv("AZ_TABLE_NAME"),
  filter_entities = "run_stage eq 'final_report_ndg2'",
  select_properties = c(
    "scenario",
    "create_datetime",
    "run_stage",
    "app_version",
    "sites_aae",
    "sites_ip",
    "sites_op"
  )
) {
  azkit::read_azure_table(
    table_name = "modelruns",
    token = auth_token,
    filter = filter_entities,
    select = paste(select_properties, collapse = ",")
  )
}

get_scheme_lookup <- function(
  container_support = azkit::get_container(Sys.getenv("AZ_CONTAINER_SUPPORT"))
) {
  AzureStor::storage_read_csv(
    container_support,
    "nhp-scheme-lookup.csv",
    show_col_types = FALSE
  ) |>
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
