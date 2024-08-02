create_reactable <- function(dat) {
  DT::datatable(
    dat,
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
        list(width = "100px", targets = 3),
        list(width = "75px",  targets = 4),
        list(width = "75px",  targets = 5),
        list(searchable = FALSE, targets = 5),  # no need to search link column
        list(visible = FALSE, targets = 6)  # hide in table, see in download
      ),
      pageLength = 5,
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
