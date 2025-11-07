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
  app_id = Sys.getenv("AZ_APP_ID"),
  table_ep = Sys.getenv("AZ_TABLE_EP"),
  table_name = Sys.getenv("AZ_TABLE_NAME")
) {
  token <- if (app_id != "") {
    AzureAuth::get_azure_token(
      resource = "https://storage.azure.com",
      tenant = "common",
      app = app_id,
      auth_type = "authorization_code",
      use_cache = TRUE
    )
  } else {
    AzureAuth::get_managed_token("https://storage.azure.com/")
  }

  # Make API call, AzureTableStor functions don't accept tokens
  req <- httr2::request(glue::glue("{table_ep}{table_name}")) |>
    httr2::req_auth_bearer_token(token$credentials$access_token) |>
    httr2::req_headers(
      `x-ms-version` = "2023-11-03",
      Accept = "application/json;odata=nometadata"
    )
  resp <- httr2::req_perform(req)
  entities <- httr2::resp_body_json(resp)

  entities[[1]] |> # response is contained in a list
    purrr::map(tibble::as_tibble) |>
    purrr::list_rbind()
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
