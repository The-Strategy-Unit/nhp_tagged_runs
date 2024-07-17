
#' Fetch all Runs with 'run_stage' Metadata
#' @param result_sets A data.frame. A row per run, with columns for each item of
#'     metadata. Probably returned by \link[su.azure]{get_nhp_result_sets}.
#' @return A data.frame.
#' @noRd
prepare_run_stage_runs <- function(result_sets) {

  run_stage_results <- result_sets |>
    dplyr::filter(!is.na(run_stage)) |>
    dplyr::select(dataset, scenario, app_version, run_stage, file) |>
    dplyr::arrange(dataset, run_stage)

  # Generate encrypted bit of the outputs app URL
  run_stage_results$url_file_encrypted <- run_stage_results$file |>
    purrr::map(encrypt_filename) |>
    unlist()

  # Look up trust name from ODS code
  run_stage_results$trust_name <- run_stage_results$dataset |>
    purrr::map(lookup_ods_org_code_name) |>
    unlist()

  run_stage_results |>
    dplyr::mutate(
      url_app_version = stringr::str_replace(app_version, "\\.", "-"),
      url_stub = glue::glue("https://connect.strategyunitwm.nhs.uk/nhp/{url_app_version}/outputs/?"),
      outputs_link = glue::glue("{url_stub}{url_file_encrypted}")
    ) |>
    dplyr::select(
      dataset,
      trust_name,
      tidyselect::everything(),
      -file,
      -tidyselect::starts_with("url_")
    ) |>
    dplyr::mutate(
      dplyr::across(
        c(dataset, trust_name, app_version, run_stage),
        as.factor  # to allow for discrete selections in the datatable
      ),
      outputs_link = glue::glue(
        "<a href='{outputs_link}' target='_blank'>Outputs app</a>"
      )
    ) |> 
    dplyr::rename_with(
      \(col) col |> 
        stringr::str_replace_all("_", " ") |>
        stringr::str_to_sentence()
    ) |> 
    dplyr::rename("Scheme code" = Dataset)
  
}

#' Encrypt a Model Run's Filename
#' @param filename Character. The path on Azure Storage to a .json.gz file that
#'     contains a model run.
#' @param key_b64 Character. A base-64-encoded key used to encrypt `filename`.
#' @details Borrowed from nhp_inputs.
#' @return Character.
#' @noRd
encrypt_filename <- function(
    filename,
    key_b64 = Sys.getenv("NHP_ENCRYPT_KEY")
) {

  key <- openssl::base64_decode(key_b64)

  f <- charToRaw(filename)

  ct <- openssl::aes_cbc_encrypt(f, key, NULL)
  hm <- as.raw(openssl::sha256(ct, key))

  openssl::base64_encode(c(hm, ct)) |>
    # Connect does something weird if it encounters strings of the form /w==,
    # where / can be any special character.
    URLencode(reserved = TRUE)

}

#' Return a Trust Name Given an ODS Code
#' @param org_code Character. Three-character string.
#' @details Borrowed from nhp_inputs.
#' @return Character. The trust name.
#' @noRd
lookup_ods_org_code_name <- function(org_code) {

  req <- httr::GET(
    "https://uat.directory.spineservices.nhs.uk",
    path = c("ORD", "2-0-0", "organisations", org_code)
  )

  content <- httr::content(req)
  name <- content$Organisation$Name %||% "Unknown"
  name |> stringr::str_to_title() |> stringr::str_replace_all("Nhs", "NHS")

}
