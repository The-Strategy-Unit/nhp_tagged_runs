# nhp-tagged-runs

## About

A report with two simple interactive tables:

1. Selected metadata for NHP model results files that are tagged with a run stage ('final_report_ndg2', etc).
2. Each scheme's preferred sites for output ('final') reports, split by activity type.

The report is [deployed to Connect](https://connect.strategyunitwm.nhs.uk/connect/#/apps/9f04f47e-61c4-4f76-8e39-648839f09c5a/output/39) (requires login) and updates on schedule.

## Purpose

Note that the app:

* is intended primarily as a lookup tool for the Data Science team
* may not reflect the current up-to-the-moment 'truth'
* is not intended for purposes of governance
* does not avoid the need for schemes and model relationship managers to keep their own records

## Data

The data underpinning the app is in two forms:

1. Scenario metadata is collected from the results files on Azure, in the container given by `AZ_STORAGE_CONTAINER_RESULTS`.
2. Preferred-sites data is held in a json file on Azure, in the container given by `AZ_STORAGE_CONTAINER_SUPPORT`.

See the [separate guidance](https://csucloudservices.sharepoint.com/:w:/r/sites/HEUandSUProjects/_layouts/15/Doc.aspx?sourcedoc=%7BE9BF237E-BA81-4F7E-90B1-2CA3A003F5A1%7D&file=2024-08-24_tagging-nhp-model-runs.docx&action=default&mobileredirect=true) for how to update this data.

## Update the app manually

The report runs on schedule, so any changes to the underlying data will be integrated on the next rendering.
You may wish to manually refresh the app from Posit Connect if you want your changes to appear more quickly.
To do this, open the app from the Posit Connect 'Content' page and click the 'refresh report' button (circular arrow) in the upper-right of the dev frame. 

## Run the report locally

To generate the report on your machine:

1. Create a `.Renviron` file in the project root using `.Renviron.sample` as a template.
Ask a member of the Data Science team for the values required by each variable.
2. Knit the `nhp-tagged-runs.Rmd` template to render `nhp-tagged-runs.html`.

During this process, you'll be prompted to authorise with Azure through the browser. 
See [the Data Science website](https://the-strategy-unit.github.io/data_science/presentations/2024-05-16_store-data-safely/#/authenticating-to-azure-data-storage) for detail on authorisation.
