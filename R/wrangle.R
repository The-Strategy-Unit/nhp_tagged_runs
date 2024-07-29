
#' Fetch all Runs with 'run_stage' Metadata
#' @param result_sets A data.frame. A row per run, with columns for each item of
#'     metadata. Probably returned by \link[su.azure]{get_nhp_result_sets}.
#' @param trust_lookup_file Character. A path to a file containing a lookup from
#'    ODS codes to trust names to hospital sites.
#' @return A data.frame.
#' @noRd
prepare_run_stage_runs <- function(
    result_sets,
    trust_lookup_file = "data/nhp-trust-code-lookup.csv"
) {

  run_stage_results <- result_sets |>
    dplyr::filter(!is.na(run_stage)) |>
    dplyr::select(dataset, scenario, app_version, run_stage, file)

  # Generate encrypted bit of the outputs app URL
  run_stage_results$url_file_encrypted <- run_stage_results$file |>
    purrr::map(encrypt_filename) |>
    unlist()

  trust_lookup <- readr::read_csv(
    trust_lookup_file,
    col_select = c("Name of Hospital site", "Trust ODS Code"),
    show_col_types = FALSE
  ) |>
    dplyr::select(
      dataset = "Trust ODS Code",
      hospital_site = "Name of Hospital site"
    )

  run_stage_results |>
    dplyr::left_join(trust_lookup, by = "dataset") |>
    dplyr::mutate(
      url_app_version = stringr::str_replace(app_version, "\\.", "-"),
      url_stub = glue::glue("https://connect.strategyunitwm.nhs.uk/nhp/{url_app_version}/outputs/?"),
      outputs_link = glue::glue("{url_stub}{url_file_encrypted}")
    ) |>
    dplyr::select(
      dataset,
      hospital_site,
      tidyselect::everything(),
      -file,
      -tidyselect::starts_with("url_")
    ) |>
    dplyr::mutate(
      dplyr::across(
        c(dataset, hospital_site, app_version, run_stage),
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
    dplyr::rename("Scheme code" = Dataset) |>
    dplyr::arrange("Hospital site")

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
