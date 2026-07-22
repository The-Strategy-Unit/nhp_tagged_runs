tabulate_scenarios <- function(results_table, scheme_lookup) {
  results_table |>
    dplyr::left_join(scheme_lookup, by = dplyr::join_by("dataset" == "code")) |>
    dplyr::mutate(
      scheme = glue::glue("{scheme} ({dataset})"),
      create_datetime = create_datetime |>
        lubridate::as_datetime() |>
        format("%Y-%m-%d %H:%M:%S"),
      url_app_version = stringr::str_replace(app_version, "\\.", "-"),
      url_stub = glue::glue(
        "https://connect.strategyunitwm.nhs.uk/nhp/{url_app_version}/outputs/?"
      ),
      outputs_link = glue::glue("{url_stub}{outputs_app_uri}")
    ) |>
    dplyr::select(
      scheme,
      run_stage,
      scenario,
      create_datetime,
      app_version,
      tidyselect::starts_with("sites_"), # scenario-specific sites
      tidyselect::starts_with("results_"), # results paths
      outputs_link,
      -c(trust, dataset, outputs_app_uri, tidyselect::starts_with("url_"))
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
      .before = "scheme"
    ) |>
    dplyr::arrange(scheme, run_stage) |>
    dplyr::rename_with(
      \(col) {
        col |>
          stringr::str_replace_all("_", " ") |>
          stringr::str_to_sentence() |>
          stringr::str_replace(" aae$", " A&E") |>
          stringr::str_replace(" ip$", " IP") |>
          stringr::str_replace(" op$", " OP")
      }
    )
}

create_datatable_runs <- function(runs_table) {
  runs_table |>
    DT::datatable(
      filter = "top",
      escape = FALSE,
      rownames = FALSE,
      extensions = "Buttons",
      options = list(
        dom = "Bfrtip",
        autoWidth = TRUE,
        scrollX = TRUE,
        columnDefs = list(
          list(searchable = FALSE, targets = 0),
          list(visible = FALSE, targets = 1) # hide in table, see in download
        ),
        pageLength = 6,
        buttons = list(
          list(
            extend = "csv",
            filename = paste0(Sys.Date(), "_nhp-tagged-runs"),
            text = "Download CSV"
          )
        )
      )
    )
}
