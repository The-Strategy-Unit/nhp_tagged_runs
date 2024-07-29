create_reactable <- function(dat) {
  DT::datatable(
    dat,
    filter = "top",
    escape = FALSE,
    rownames = FALSE,
    extensions = "Buttons",
    options = list(
      dom = "Bfrtip",
      pageLength = 5,
      columnDefs = list(list(targets = 5, searchable = FALSE)),
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
