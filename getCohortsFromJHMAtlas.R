
## Get cookies and assign the bearer token to a variable "token"
token <- ""

## Authorize WebApi
baseUrl <- "https://atlas-de-id.pm.jh.edu/WebAPI"
setAuthHeader(baseUrl, authHeader = token)
getCdmSources(baseUrl)

## Get cohort definitions via WebAPI
cohortIds <- c(###,###)
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



