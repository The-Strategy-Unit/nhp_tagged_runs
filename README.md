# nhp-tagged-runs

## About

A report with two simple interactive tables:

1. Selected metadata for NHP model results files that are tagged with a run stage ('final_report_ndg2', etc).
2. Each scheme's preferred sites for output ('final') reports, split by activity type.

The report is [deployed to Connect](https://connect.strategyunitwm.nhs.uk/nhp/tagged_runs/) (login/permissions required) and updates on schedule.

## Purpose

Note that the app:

* is intended primarily as a lookup tool for the Data Science team
* may not reflect the current up-to-the-moment 'truth'
* is not intended for purposes of governance
* does not avoid the need for schemes and model relationship managers to keep their own records

## Data

The data underpinning the app is in two forms:

1. Scenario metadata for tagged runs is collected from the relevant lookup table in Azure Table Storage.
2. Preferred-sites data is held in a json file on Azure, in the container given by `AZ_STORAGE_CONTAINER_SUPPORT`.

Developers: search for 'tagging-nhp-model-runs' in the NHP DS area of SharePoint for details on how to update the lookup.

## Update the app manually

The report runs on schedule, so any changes to the underlying data will be integrated on the next rendering.
You may wish to manually refresh the app from Posit Connect if you want your changes to appear more quickly.
To do this, open the app from the Posit Connect 'Content' page and click the 'refresh report' button (circular arrow) in the upper-right of the dev frame.

## Run the report locally

To generate the report on your machine:

1. Create a `.Renviron` file in the project root using `.Renviron.sample` as a template.
Ask a member of the Data Science team for the values required by each variable.
2. Knit the `nhp-tagged-runs.Rmd` template to render `nhp-tagged-runs.html`.

During this process, you may be prompted to authorise with Azure through the browser.
See [the Data Science website](https://the-strategy-unit.github.io/data_science/presentations/2024-05-16_store-data-safely/#/authenticating-to-azure-data-storage) for detail on authorisation.

## Deploy

If you make changes to the code in this repo, you can redeploy the report to Posit Connect using the `deploy.R` script.
