
## Get cookies and assign the bearer token to a variable "token"
token <- ""

## Authorize WebApi
baseUrl <- "https://atlas-demo.ohdsi.org/WebAPI"
setAuthHeader(baseUrl, authHeader = token)
getCdmSources(baseUrl)

## Get cohort definitions via WebAPI
cohortIds <- c(1794207,1794206,1794205,1794204,1794203,1794199,1794067,1794065,1794063,1794062,1794201,1794200,1794061,1794064,1794066,1794056,1794053,1794059,1794054,1794055)
cohortDefinitionSet <- ROhdsiWebApi::exportCohortDefinitionSet(
  baseUrl = baseUrl,
  cohortIds = cohortIds,
  generateStats = TRUE
)

## Generate "inst" folder components
cohorts <- subset(cohortDefinitionSet, select = -c(sql, json))

write.csv(cohorts, file = here::here("cohorts.csv"))

write(cohortDefinitionSet$json[1], file = here::here("json/###.json"))
write(cohortDefinitionSet$json[2], file = here::here("json/###.json"))


write(cohortDefinitionSet$sql[1], file = here::here("sql/sql_server/###.sql"))
write(cohortDefinitionSet$sql[2], file = here::here("sql/sql_server/###.sql"))




