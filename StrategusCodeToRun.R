# -------------------------------------------------------
#                     PLEASE READ
# -------------------------------------------------------
#
# You must call "renv::restore()" and follow the prompts
# to install all of the necessary R libraries to run this
# project. This is a one-time operation that you must do
# before running any code.
#
# !!! PLEASE RESTART R AFTER RUNNING renv::restore() !!!
#
# -------------------------------------------------------
#renv::restore()

# ENVIRONMENT SETTINGS NEEDED FOR RUNNING Strategus ------------
Sys.setenv("_JAVA_OPTIONS"="-Xmx4g") # Sets the Java maximum heap space to 4GB
Sys.setenv("VROOM_THREADS"=1) # Sets the number of threads to 1 to avoid deadlocks on file system

##=========== START OF INPUTS ==========
cdmDatabaseSchema <- "JHM_OMOP.dbo"
workDatabaseSchema <- "JHM_OMOP.Temp"
outputLocation <- file.path(getwd(), "results")
databaseName <- "JHM_OMOP" # Only used as a folder name for results from the study
minCellCount <- 5
cohortTableName <- "rheum_infection"

# Create the connection details for your CDM
# More details on how to do this are found here:
# https://ohdsi.github.io/DatabaseConnector/reference/createConnectionDetails.html
connectionDetails = DatabaseConnector::createConnectionDetails(
  dbms = "sql server",
  server = "esmpmdbpr4.esm.johnshopkins.edu",
  user = "ohdsi_dqd",
  password = "0moPw3b@pi",
  pathToDriver = "C:/Users/bmarti86/DatabaseDrivers"
)


##=========== END OF INPUTS ==========
analysisSpecifications <- ParallelLogger::loadSettingsFromJson(
  fileName = "inst/fullStudyAnalysisSpecification.json"
)

# UNCOMMENT TO RUN COHORT DIAGNOSTICS - IF YOU DO THIS, PLEASE
# COMMENT OUT THE COMMAND ABOVE THAT LOADS THE FULL STUDY
# ANALYSIS SPECIFICATION.
# analysisSpecifications <- ParallelLogger::loadSettingsFromJson(
#   fileName = "inst/cohortDiagnosticsAnalysisSpecification.json"
# )

executionSettings <- Strategus::createCdmExecutionSettings(
  workDatabaseSchema = workDatabaseSchema,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cohortTableNames = CohortGenerator::getCohortTableNames(cohortTable = cohortTableName),
  workFolder = file.path(outputLocation, "results", databaseName, "strategusWork"),
  resultsFolder = file.path(outputLocation, "results", databaseName, "strategusOutput"),
  minCellCount = minCellCount
)

if (!dir.exists(file.path(outputLocation, "results", databaseName))) {
  dir.create(file.path(outputLocation, "results", databaseName), recursive = T)
}
ParallelLogger::saveSettingsToJson(
  object = executionSettings,
  fileName = file.path(outputLocation, "results", databaseName, "executionSettings.json")
)

Strategus::execute(
  analysisSpecifications = analysisSpecifications,
  executionSettings = executionSettings,
  connectionDetails = connectionDetails
)


