rsconnect::deployDoc(
  server = "connect.strategyunitwm.nhs.uk",
  appId = 112,
  doc = "index.Rmd",
  appName = "nhp_tagged_runs",
  appTitle = "NHP: scenario run-stage table",
  envVars = c(
    "AZ_CONTAINER_SUPPORT",
    "AZ_STORAGE_EP",
    "AZ_TABLE_EP",
    "AZ_TABLE_NAME",
    "NHP_ENCRYPT_KEY"
  ),
  lint = FALSE,
  forceUpdate = TRUE
)
