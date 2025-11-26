# 1) Generate base cohorts
CohortGenerator::generateCohortSet(
  connectionDetails      = connectionDetails,
  cdmDatabaseSchema      = cdmDatabaseSchema,
  cohortDatabaseSchema   = cohortDatabaseSchema,
  cohortTableNames       = cohortTableNames,
  cohortDefinitionSet    = cohortDefinitionSet,
  cohortIds              = c(
    1794548, 1794547, 1794546, 1794545,
    1794544, 1794543, 1794542, 1794541,
    1794540, 1794539, 1794538, 1794537,
    1794536, 1794535, 1794534, 1794533,
    1794532, 1794531, 1794530, 1794529,
    1794395, 1793813, 1794528, 1794527
  )
)

connection <- DatabaseConnector::connect(connectionDetails)

# 2) HERE: generate the new overlap cohorts with CohortAlgebra
pairs <- list(
  list(sourceIds = c(1794548, 1794547), newId = 1001),
  list(sourceIds = c(1794546, 1794545), newId = 1002),
  list(sourceIds = c(1794544, 1794543), newId = 1003),
  list(sourceIds = c(1794542, 1794541), newId = 1004),
  list(sourceIds = c(1794540, 1794539), newId = 1005),
  list(sourceIds = c(1794538, 1794537), newId = 1006),
  list(sourceIds = c(1794536, 1794535), newId = 1007),
  list(sourceIds = c(1794534, 1794533), newId = 1008),
  list(sourceIds = c(1794532, 1794531), newId = 1009),
  list(sourceIds = c(1794530, 1794529), newId = 1010),
  list(sourceIds = c(1794395, 1793813), newId = 1011),
  list(sourceIds = c(1794528, 1794527), newId = 1012)
)

for (p in pairs) {
  CohortAlgebra::intersectCohorts(
    connection                  = connection,
    sourceCohortDatabaseSchema  = cohortDatabaseSchema,
    sourceCohortTable           = cohortTableNames$cohortTable,
    targetCohortDatabaseSchema  = cohortDatabaseSchema,
    targetCohortTable           = cohortTableNames$cohortTable,
    cohortIds                   = p$sourceIds,
    newCohortId                 = p$newId,
    purgeConflicts              = TRUE
  )
}
