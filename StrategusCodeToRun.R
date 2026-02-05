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

# Source the CohortAlgebraModule
source("CohortAlgebraModule.R")

##=========== START OF INPUTS ==========
cdmDatabaseSchema <- "main"
workDatabaseSchema <- "main"
outputLocation <- file.path(getwd(), "results")
databaseName <- "Eunomia" # Only used as a folder name for results from the study
minCellCount <- 5
cohortTableName <- "sample_study"

# Create the connection details for your CDM
# More details on how to do this are found here:
# https://ohdsi.github.io/DatabaseConnector/reference/createConnectionDetails.html
# connectionDetails <- DatabaseConnector::createConnectionDetails(
#   dbms = Sys.getenv("DBMS_TYPE"),
#   connectionString = Sys.getenv("CONNECTION_STRING"),
#   user = Sys.getenv("DBMS_USERNAME"),
#   password = Sys.getenv("DBMS_PASSWORD")
# )

# For this example we will use the Eunomia sample data 
# set. This library is not installed by default so you
# can install this by running:
#
# install.packages("Eunomia")
connectionDetails <- Eunomia::getEunomiaConnectionDetails()

# You can use this snippet to test your connection
#conn <- DatabaseConnector::connect(connectionDetails)
#DatabaseConnector::disconnect(conn)

##=========== END OF INPUTS ==========


# =============================================================================
# PHASE CONTROL
# =============================================================================
# Set which phases to run. This allows you to run phases separately if needed.
# For a complete run, set all to TRUE.

runPhase1_CohortGeneration <- TRUE
runPhase2_CohortAlgebra <- TRUE
runPhase3_AnalysisModules <- TRUE


# =============================================================================
# SETUP - Create directories and execution settings
# =============================================================================

# Create output directories
if (!dir.exists(file.path(outputLocation, databaseName))) {
  dir.create(file.path(outputLocation, databaseName), recursive = TRUE)
}

# Create base execution settings
executionSettings <- Strategus::createCdmExecutionSettings(
  workDatabaseSchema = workDatabaseSchema,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cohortTableNames = CohortGenerator::getCohortTableNames(cohortTable = cohortTableName),
  workFolder = file.path(outputLocation, databaseName, "strategusWork"),
  resultsFolder = file.path(outputLocation, databaseName, "strategusOutput"),
  minCellCount = minCellCount
)

# Save execution settings
ParallelLogger::saveSettingsToJson(
  object = executionSettings,
  fileName = file.path(outputLocation, databaseName, "executionSettings.json")
)


# =============================================================================
# PHASE 1: Generate Base Cohorts (CohortGeneratorModule only)
# =============================================================================
# This phase generates all the base cohorts from ATLAS definitions,
# including the single-drop cohorts needed for intersection.

if (runPhase1_CohortGeneration) {
  message("")
  message("================================================================")
  message("PHASE 1: Generating Base Cohorts (CohortGeneratorModule)")
  message("================================================================")
  
  # Load the full analysis specifications
  fullAnalysisSpecifications <- ParallelLogger::loadSettingsFromJson(
    fileName = "inst/fullStudyAnalysisSpecification.json"
  )
  
  # Create Phase 1 specifications with only CohortGeneratorModule
  # We need to extract just the CohortGenerator module and shared resources
  phase1Specifications <- Strategus::createEmptyAnalysisSpecifications()
  
  # Add shared resources (cohort definitions, negative controls)
  for (sharedResource in fullAnalysisSpecifications$sharedResources) {
    # Skip CohortAlgebra shared resources for Phase 1
    if (!inherits(sharedResource, "CohortIntersectionSharedResources")) {
      phase1Specifications <- Strategus::addSharedResources(
        phase1Specifications, 
        sharedResource
      )
    }
  }
  
  # Add only CohortGeneratorModule
  for (moduleSpec in fullAnalysisSpecifications$moduleSpecifications) {
    if (moduleSpec$module == "CohortGeneratorModule") {
      phase1Specifications <- Strategus::addModuleSpecifications(
        phase1Specifications,
        moduleSpec
      )
      break
    }
  }
  
  # Execute Phase 1
  Strategus::execute(
    analysisSpecifications = phase1Specifications,
    executionSettings = executionSettings,
    connectionDetails = connectionDetails
  )
  
  message("Phase 1 complete: Base cohorts generated.")
}


# =============================================================================
# PHASE 2: Create Intersection Cohorts (CohortAlgebraModule)
# =============================================================================
# This phase creates the combination cohorts by intersecting pairs of
# single-drop cohorts. Must run after Phase 1.

if (runPhase2_CohortAlgebra) {
  message("")
  message("================================================================")
  message("PHASE 2: Creating Intersection Cohorts (CohortAlgebraModule)")
  message("================================================================")
  
  # Load CohortAlgebra specifications from CSV (more reliable than JSON)
  cohortAlgebraCsvFile <- "inst/cohortAlgebraPairs.csv"
  cohortAlgebraSpecsFile <- "inst/cohortAlgebraSpecifications.json"
  
  # Prefer CSV if it exists, otherwise try JSON
  if (file.exists(cohortAlgebraCsvFile)) {
    message(sprintf("Loading cohort pairs from: %s", cohortAlgebraCsvFile))
    cohortPairs <- CohortGenerator::readCsv(file = cohortAlgebraCsvFile)
    message(sprintf("Loaded %d cohort pairs", nrow(cohortPairs)))
    print(cohortPairs)
    
  } else if (file.exists(cohortAlgebraSpecsFile)) {
    message(sprintf("Loading cohort pairs from: %s", cohortAlgebraSpecsFile))
    # Load the specifications from JSON
    loadedSpecs <- ParallelLogger::loadSettingsFromJson(fileName = cohortAlgebraSpecsFile)
    
    # Convert the intersections list back to a data frame
    if (is.list(loadedSpecs$intersections) && !is.data.frame(loadedSpecs$intersections)) {
      # JSON converts data frames to lists of lists - convert back
      cohortPairs <- do.call(rbind, lapply(loadedSpecs$intersections, as.data.frame))
    } else {
      cohortPairs <- as.data.frame(loadedSpecs$intersections)
    }
    message(sprintf("Loaded %d cohort pairs", nrow(cohortPairs)))
    print(cohortPairs)
    
  } else {
    stop(sprintf("Neither %s nor %s found. Cannot create intersection cohorts.", 
                 cohortAlgebraCsvFile, cohortAlgebraSpecsFile))
  }
  
  # Validate the cohort pairs
  requiredCols <- c("cohortId1", "cohortId2", "newCohortId", "newCohortName")
  missingCols <- setdiff(requiredCols, names(cohortPairs))
  if (length(missingCols) > 0) {
    stop(sprintf("Cohort pairs missing required columns: %s", paste(missingCols, collapse = ", ")))
  }
  
  # Create the module
  caModule <- CohortAlgebraModule$new()
  
  # Create properly structured specifications
  cohortIntersectionSpecifications <- caModule$createCohortIntersectionSpecifications(
    cohortPairs = cohortPairs
  )
  
  message("Executing CohortAlgebraModule...")
  
  # Execute the module
  intersectionResults <- caModule$execute(
    connectionDetails = connectionDetails,
    cohortDatabaseSchema = workDatabaseSchema,
    cohortTable = cohortTableName,
    cohortIntersectionSpecifications = cohortIntersectionSpecifications
  )
  
  # Check if we got results
  if (is.null(intersectionResults)) {
    message("WARNING: CohortAlgebraModule returned NULL. Check if cohort pairs were processed.")
    message("Creating empty results data frame...")
    intersectionResults <- data.frame(
      newCohortId = cohortPairs$newCohortId,
      newCohortName = cohortPairs$newCohortName,
      cohortId1 = cohortPairs$cohortId1,
      cohortId2 = cohortPairs$cohortId2,
      recordCount = NA_integer_,
      personCount = NA_integer_,
      status = "UNKNOWN",
      stringsAsFactors = FALSE
    )
  }
  
  # Save the results
  resultsFile <- file.path(outputLocation, databaseName, "cohortAlgebraResults.csv")
  write.csv(intersectionResults, resultsFile, row.names = FALSE)
  message(sprintf("CohortAlgebra results saved to: %s", resultsFile))
  
  # Print summary
  message("")
  message("Phase 2 Summary - Intersection Cohorts Created:")
  message("------------------------------------------------")
  successCount <- sum(intersectionResults$status == "SUCCESS")
  failCount <- sum(intersectionResults$status != "SUCCESS")
  message(sprintf("  Successful: %d", successCount))
  message(sprintf("  Failed: %d", failCount))
  
  if (successCount > 0) {
    message("")
    for (i in 1:nrow(intersectionResults)) {
      if (intersectionResults$status[i] == "SUCCESS") {
        message(sprintf("  - Cohort %d (%s): %d records, %d persons",
                        intersectionResults$newCohortId[i],
                        intersectionResults$newCohortName[i],
                        intersectionResults$recordCount[i],
                        intersectionResults$personCount[i]))
      }
    }
  }
  
  if (failCount > 0) {
    message("")
    message("Failed intersections:")
    for (i in 1:nrow(intersectionResults)) {
      if (intersectionResults$status[i] != "SUCCESS") {
        message(sprintf("  - Cohort %d (%s): %s",
                        intersectionResults$newCohortId[i],
                        intersectionResults$newCohortName[i],
                        intersectionResults$status[i]))
      }
    }
  }
  
  message("")
  message("Phase 2 complete: Intersection cohorts created.")
}


# =============================================================================
# PHASE 3: Run Analysis Modules
# =============================================================================
# This phase runs all the analysis modules (Characterization, CohortIncidence,
# CohortMethod, SCCS, etc.) now that both base and intersection cohorts exist.

if (runPhase3_AnalysisModules) {
  message("")
  message("================================================================")
  message("PHASE 3: Running Analysis Modules")
  message("================================================================")
  
  # Load the full analysis specifications
  fullAnalysisSpecifications <- ParallelLogger::loadSettingsFromJson(
    fileName = "inst/fullStudyAnalysisSpecification.json"
  )
  
  # Create Phase 3 specifications with all modules EXCEPT CohortGeneratorModule
  # (since cohorts are already generated in Phase 1 & 2)
  phase3Specifications <- Strategus::createEmptyAnalysisSpecifications()
  
  # Add all shared resources
  for (sharedResource in fullAnalysisSpecifications$sharedResources) {
    phase3Specifications <- Strategus::addSharedResources(
      phase3Specifications, 
      sharedResource
    )
  }
  
  # Add all modules EXCEPT CohortGeneratorModule
  # Add ONLY CohortMethodModule
  modulesAdded <- c()
  for (moduleSpec in fullAnalysisSpecifications$moduleSpecifications) {
    if (moduleSpec$module == "CohortMethodModule") {
      phase3Specifications <- Strategus::addModuleSpecifications(
        phase3Specifications,
        moduleSpec
      )
      modulesAdded <- c(modulesAdded, moduleSpec$module)
    }
  }
  
  if (length(modulesAdded) == 0) {
    message("No analysis modules found in specifications. Skipping Phase 3.")
  } else {
    message(sprintf("Running modules: %s", paste(modulesAdded, collapse = ", ")))
    
    # Execute Phase 3
    Strategus::execute(
      analysisSpecifications = phase3Specifications,
      executionSettings = executionSettings,
      connectionDetails = connectionDetails
    )
    
    message("Phase 3 complete: Analysis modules finished.")
  }
}


# =============================================================================
# COMPLETION SUMMARY
# =============================================================================
message("")
message("================================================================")
message("ALL PHASES COMPLETE")
message("================================================================")
message("")
message(sprintf("Results location: %s", file.path(outputLocation, databaseName)))
message("")
message("Phase Summary:")
if (runPhase1_CohortGeneration) message("  Phase 1 (CohortGenerator): COMPLETED")
if (runPhase2_CohortAlgebra) message("  Phase 2 (CohortAlgebra): COMPLETED")
if (runPhase3_AnalysisModules) message("  Phase 3 (Analysis Modules): COMPLETED")
message("")


# =============================================================================
# OPTIONAL: Verify cohort counts
# =============================================================================
# Uncomment this section to verify all cohort counts after execution

# message("Verifying cohort counts...")
# 
# connection <- DatabaseConnector::connect(connectionDetails)
# 
# sql <- "
# SELECT 
#   cohort_definition_id AS cohort_id,
#   COUNT(*) AS record_count,
#   COUNT(DISTINCT subject_id) AS person_count
# FROM @cohort_schema.@cohort_table
# GROUP BY cohort_definition_id
# ORDER BY cohort_definition_id;
# "
# 
# counts <- DatabaseConnector::renderTranslateQuerySql(
#   connection = connection,
#   sql = sql,
#   cohort_schema = workDatabaseSchema,
#   cohort_table = cohortTableName,
#   snakeCaseToCamelCase = TRUE
# )
# 
# DatabaseConnector::disconnect(connection)
# 
# print(counts)
# 
# # Check specifically for intersection cohorts
# intersectionCohortIds <- c(1001, 1002, 1003)
# intersectionCounts <- counts[counts$cohortId %in% intersectionCohortIds, ]
# message("")
# message("Intersection cohort counts:")
# print(intersectionCounts)