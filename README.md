# get-tagged-nhp-runs

## About

Generate a simple interactive table for exploring tagged NHP model runs.

This is intended primarily as a tool for the Data Science team.
It may not reflect the current up-to-the-moment 'truth'.
It is not intended for purposes of governance. 
Schemes and model-relationship managers must keep their own records.

## Metadata

Each row of the table represents a model run that we've tagged with the 'run_stage' metadata key in Azure Storage.
This metadata is used to identify model runs considered as an 'initial', 'intermediate' (in development) or 'final' (used to produce final reports).
The run_stage suffixes 'ndg1' and 'ndg2' indicate whether the run used non-demographic growth (NDG) variant 1 or 2.
Click in the 'Outputs link' column to open the NHP Outputs app pre-loaded with the selected run.

## Run locally

To run locally, first create a `.Renviron` file in the root using `.Renviron.sample` as a template.
Ask a member of the Data Science team for the values required by each variable.

Then execute the `generate-table.R` script, which fetches the latest model-run metadata from Azure, wrangles it into a table in `index.Rmd` and outputs `index.html`.
You'll be prompted to authorise with Azure through the browser. 
See [the Data Science website](https://the-strategy-unit.github.io/data_science/presentations/2024-05-16_store-data-safely/#/authenticating-to-azure-data-storage) for detail on authorisation.
