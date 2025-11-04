tabulate_scenarios <- function(results_table, scheme_lookup) {
  run_stage_results <- results_table |>
    dplyr::filter(!is.na(run_stage)) |>
    dplyr::select(
      dataset,
      scenario,
      create_datetime,
      app_version,
      run_stage,
      results_file,
      results_dir
    )

  # Generate encrypted bit of the outputs app URL
  run_stage_results$url_file_encrypted <- run_stage_results$results_file |>
    purrr::map(encrypt_filename) |>
    unlist()

  run_stage_results |>
    dplyr::left_join(scheme_lookup, by = dplyr::join_by("dataset" == "code")) |>
    dplyr::mutate(
      scheme = glue::glue("{scheme} ({dataset})"),
      create_datetime = create_datetime |>
        lubridate::as_datetime() |>
        format("%Y-%m-%d %H:%M:%S") |>
        as.character(),
      url_app_version = stringr::str_replace(app_version, "\\.", "-"),
      url_stub = glue::glue(
        "https://connect.strategyunitwm.nhs.uk/nhp/{url_app_version}/outputs/?"
      ),
      outputs_link = glue::glue("{url_stub}{url_file_encrypted}")
    ) |>
    dplyr::select(
      scheme,
      scenario,
      create_datetime,
      app_version,
      run_stage,
      results_file,
      results_dir,
      outputs_link,
      -c(trust, dataset, tidyselect::starts_with("url_"))
    ) |>
    tidyr::replace_na(list(results_dir = "-")) |>
    dplyr::mutate(
      dplyr::across(
        c(scheme, app_version, run_stage),
        as.factor # to allow for discrete selections in the datatable
      )
    ) |>
    dplyr::mutate(
      outputs_app = glue::glue(
        "<a href='{outputs_link}' target='_blank'>Launch</a>"
      ),
      .before = outputs_link
    ) |>
    dplyr::relocate(
      tidyselect::starts_with("outputs_"),
      .after = "run_stage"
    ) |>
    dplyr::arrange(scheme, run_stage) |>
    dplyr::rename_with(
      \(col) {
        col |>
          stringr::str_replace_all("_", " ") |>
          stringr::str_to_sentence()
      }
    )
}

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

tabulate_sites <- function(results_table, scheme_lookup) {
  results_table |>
    dplyr::left_join(scheme_lookup, by = dplyr::join_by("dataset" == "code")) |>
    dplyr::mutate(scheme = glue::glue("{scheme} ({dataset})")) |>
    dplyr::select(scheme, tidyselect::starts_with("sites")) |>
    dplyr::distinct() |>
    tidyr::pivot_longer(
      tidyselect::starts_with("sites"),
      names_to = "activity_type",
      values_to = "sites",
      names_prefix = "sites_",
      names_transform = toupper
    ) |>
    dplyr::mutate(
      activity_type = dplyr::case_match(
        activity_type,
        "AAE" ~ "A&E",
        "IP" ~ "Inpatients",
        "OP" ~ "Outpatients"
      ),
      sites = stringr::str_replace_all(sites, ",", ", ")
    ) |>
    tidyr::replace_na(list(sites = "-")) |>
    dplyr::arrange(scheme) |>
    dplyr::rename_with(
      \(col) {
        col |>
          stringr::str_replace_all("_", " ") |>
          stringr::str_to_sentence()
      }
    )
}
