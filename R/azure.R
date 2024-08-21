# Most functions here copied from the private {su.azure} package to avoid GitHub
# PAT headaches when trying to deploy the Rmd to Connect.

get_container <- function(
    tenant = Sys.getenv("AZ_TENANT_ID"),
    app_id = Sys.getenv("AZ_APP_ID"),
    ep_uri = Sys.getenv("AZ_STORAGE_EP"),
    container_name  # AZ_STORAGE_CONTAINER_RESULTS or _SUPPORT
) {

  # if the app_id variable is empty, we assume that this is running on an Azure VM,
  # and then we will use Managed Identities for authentication.
  token <- if (app_id != "") {
    AzureAuth::get_azure_token(
      resource = "https://storage.azure.com",
      tenant = tenant,
      app = app_id,
      auth_type = "device_code"
    )
  } else {
    AzureAuth::get_managed_token("https://storage.azure.com/")
  }

  ep_uri |>
    AzureStor::blob_endpoint(token = token) |>
    AzureStor::storage_container(container_name)

}

get_nhp_result_sets <- function(
    container,
    allowed_datasets = get_nhp_user_allowed_datasets(NULL),
    folder = "prod"
) {

  allowed <- tibble::tibble(dataset = allowed_datasets)

  container |>
    AzureStor::list_blobs(folder, info = "all", recursive = TRUE) |>
    dplyr::filter(!.data[["isdir"]]) |>
    purrr::pluck("name") |>
    purrr::set_names() |>
    purrr::map(\(name, ...) AzureStor::get_storage_metadata(container, name)) |>
    dplyr::bind_rows(.id = "file") |>
    dplyr::semi_join(allowed, by = dplyr::join_by("dataset")) |>
    dplyr::mutate(dplyr::across("viewable", as.logical))

}

get_report_sites <- function(container) {

  raw_json <- AzureStor::storage_download(
    container,
    src = , "nhp-final-report-sites.json",
    dest = NULL
  )

  raw_json |>
    rawToChar() |>
    jsonlite::fromJSON()

}

get_scheme_lookup <- function(container, file) {
  AzureStor::storage_read_csv(
    container,
    "nhp-scheme-lookup.csv",
    show_col_types = FALSE
  ) |>
    dplyr::select(
      code = `Trust ODS Code`,
      scheme = `Name of Hospital site`,
      trust = `Name of Trust`
    )
}

get_nhp_user_allowed_datasets <- function(
    groups = NULL,
    container = container_support
) {

  raw_json <- AzureStor::storage_download(
    container,
    src = , "providers.json",
    dest = NULL
  )

  p <- raw_json |>
    rawToChar() |>
    jsonlite::fromJSON(simplifyVector = TRUE)

  if (!(is.null(groups) || any(c("nhp_devs", "nhp_power_users") %in% groups))) {
    a <- groups |>
      stringr::str_subset("^nhp_provider_") |>
      stringr::str_remove("^nhp_provider_")
    p <- intersect(p, a)
  }

  c("synthetic", p)

}
