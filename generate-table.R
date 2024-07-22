source("r/wrangle.R")

azure_result_sets <- su.azure::get_nhp_result_sets()
tagged_runs <- prepare_run_stage_runs(azure_result_sets)

rmarkdown::render(
  input = "nhp-tagged-runs.Rmd",
  output_file = "nhp-tagged-runs.html",
  params = list(tagged_runs = tagged_runs)
)
