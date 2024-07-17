create_reactable <- function(dat) {
  DT::datatable(
    dat,
    filter = "top",
    escape = FALSE,
    extensions = "Buttons",
    options = list(
      dom = 'Bfrtip',
      pageLength = 5, 
      buttons = c("copy", "csv"),
      columnDefs = list(list(targets = 6, searchable = FALSE))
    )
  )
}