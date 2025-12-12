# nhp-tagged-runs

## About

A table of scenario metadata for results files from the New Hospital Programme (NHP) demand model, along with schemes' site selections for those runs. Only includes scenarios that have a 'run stage' label ('final_report_ndg2', etc).

The report is [deployed to Connect](https://connect.strategyunitwm.nhs.uk/nhp/tagged_runs/) (login/permissions required) and updates on schedule.

## Purpose

Note that the app:

* is intended primarily as a lookup tool for the Data Science team
* may not reflect the current up-to-the-moment 'truth'
* is not intended for purposes of governance
* does not avoid the need for schemes and model relationship managers to keep their own records

## Data

Data is stored in a lookup in Azure Table Storage given by the environment variables `AZ_TABLE_NAME` and `AZ_TABLE_EP`.

Developers: search for 'tagging-nhp-model-runs' in the NHP DS area of SharePoint for details on how to update the lookup.

## Update the app manually

The report runs on schedule, so any changes to the underlying data will be integrated on the next rendering.
You may wish to manually refresh the app from Posit Connect if you want your changes to appear more quickly.
To do this, open the app from [the Posit Connect 'Content URL'](https://connect.strategyunitwm.nhs.uk/connect/#/apps/d4f15471-d2ef-45c2-b52f-40822e450d7e) (login/permissions required) and click the 'refresh report' button (circular arrow) in the upper-right of the dev frame.

## Run the report locally

To generate the report on your machine:

1. Create a `.Renviron` file in the project root using `.Renviron.example` as a template.
Ask a member of the Data Science team for the values required by each variable.
2. Knit the `index.Rmd` template to render `index.html`.

During this process, you may be prompted to authorise with Azure through the browser.
See [the Data Science website](https://the-strategy-unit.github.io/data_science/presentations/2024-05-16_store-data-safely/#/authenticating-to-azure-data-storage) for detail on authorisation.

## Deploy

If you make changes to the code in this repo, you can redeploy the report to Posit Connect using the `deploy.R` script.
