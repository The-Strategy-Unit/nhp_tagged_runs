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
