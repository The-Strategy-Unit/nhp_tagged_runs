# Most functions here copied from the private {su.azure} package to avoid GitHub
# PAT headaches when trying to deploy the Rmd to Connect.

get_container <- function(
  tenant = Sys.getenv("AZ_TENANT_ID"),
  app_id = Sys.getenv("AZ_APP_ID"),
  ep_uri = Sys.getenv("AZ_STORAGE_EP"),
  container_name # AZ_STORAGE_CONTAINER_RESULTS or _SUPPORT
) {
  # if the app_id variable is empty, we assume that this is running on an Azure
  # VM, and then we will use Managed Identities for authentication.
  token <- if (app_id != "") {
    AzureAuth::get_azure_token(
      resource = "https://storage.azure.com",
      tenant = tenant,
      app = app_id,
      auth_type = "device_code",
      use_cache = TRUE
    )
  } else {
    AzureAuth::get_managed_token("https://storage.azure.com/")
  }

  ep_uri |>
    AzureStor::blob_endpoint(token = token) |>
    AzureStor::storage_container(container_name)
}

get_table <- function(
  tenant = Sys.getenv("AZ_TENANT_ID"),
  app_id = Sys.getenv("AZ_APP_ID"),
  ep_uri = Sys.getenv("AZ_TABLE_EP")
) {
  # if the app_id variable is empty, we assume that this is running on an Azure VM,
  # and then we will use Managed Identities for authentication.
  token <- if (app_id != "") {
    AzureAuth::get_azure_token(
      resource = "https://storage.azure.com",
      tenant = tenant,
      app = app_id,
      auth_type = "device_code",
      use_cache = TRUE
    )
  } else {
    AzureAuth::get_managed_token("https://storage.azure.com/")
  }

  ep_uri |>
    AzureTableStor::table_endpoint(, token = token) |>
    AzureTableStor::storage_table("taggedruns")
}

get_nhp_result_sets <- function(
  container_results,
  container_support,
  folder = "prod"
) {
  allowed_datasets <- get_nhp_user_allowed_datasets(NULL, container_support)
  allowed <- tibble::tibble(dataset = allowed_datasets)

  container_results |>
    AzureStor::list_blobs(folder, info = "all", recursive = TRUE) |>
    dplyr::filter(!.data[["isdir"]]) |>
    purrr::pluck("name") |>
    purrr::set_names() |>
    purrr::map(
      \(name, ...) AzureStor::get_storage_metadata(container_results, name)
    ) |>
    dplyr::bind_rows(.id = "file") |>
    dplyr::semi_join(allowed, by = dplyr::join_by("dataset")) |>
    dplyr::mutate(dplyr::across("viewable", as.logical))
}

get_report_sites <- function(container_support) {
  raw_json <- AzureStor::storage_download(
    container_support,
    src = "nhp-final-report-sites.json",
    dest = NULL
  )

  raw_json |>
    rawToChar() |>
    jsonlite::fromJSON()
}

get_scheme_lookup <- function(container_support) {
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

get_nhp_user_allowed_datasets <- function(groups = NULL, container_support) {
  raw_json <- AzureStor::storage_download(
    container_support,
    src = "providers.json",
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
