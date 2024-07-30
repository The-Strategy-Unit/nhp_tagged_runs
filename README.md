# nhp-tagged-runs

## About

Generate a simple interactive table for exploring tagged NHP model runs.

This is intended primarily as a tool for the Data Science team.
It may not reflect the current up-to-the-moment 'truth'.
It is not intended for purposes of governance. 
Schemes and model-relationship managers must keep their own records.

## Run locally

To run locally, first create a `.Renviron` file in the root using `.Renviron.sample` as a template.
Ask a member of the Data Science team for the values required by each variable.

Then knit the `nhp-tagged-runs.Rmd` template, which fetches the latest model-run metadata from Azure, wrangles it into a table in `index.Rmd` and outputs `index.html`.
You'll be prompted to authorise with Azure through the browser. 
See [the Data Science website](https://the-strategy-unit.github.io/data_science/presentations/2024-05-16_store-data-safely/#/authenticating-to-azure-data-storage) for detail on authorisation.
