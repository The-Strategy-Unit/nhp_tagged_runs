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
        columnDefs = list(
          list(width = "100px", targets = 0),
          list(width = "100px", targets = 1),
          list(width = "100px", targets = 2),
          list(width = "75px",  targets = 3),
          list(width = "100px", targets = 4),
          list(width = "75px",  targets = 5),
          list(searchable = FALSE, targets = 6),
          list(searchable = FALSE, targets = 6),
          list(visible = FALSE, targets = 7)  # hide in table, see in download
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

create_datatable_sites <- function(sites_table) {
  sites_table |>
    DT::datatable(
      filter = "top",
      rownames = FALSE,
      extensions = "Buttons",
      options = list(
        dom = "Bfrtip",
        autoWidth = TRUE,
        pageLength = 6,
        buttons = list(
          list(
            extend = "csv",
            filename = paste0(Sys.Date(), "_nhp-sites"),
            text = "Download CSV"
          )
        )
      )
    )
}
