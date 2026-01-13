# =============================================================================
# CohortAlgebraModule.R
# A Strategus-compatible module for cohort set operations (intersection, union)
# 
# This module creates new cohorts by computing the temporal intersection of 
# pairs of existing cohorts. For each pair, it finds matching records by 
# subject_id and cohort_start_date, then uses the minimum end date.
#
# Usage:
#   1. Source this file in your CreateStrategusAnalysisSpecification.R
#   2. Define cohort pairs and create shared resources
#   3. Add to analysis specifications after CohortGeneratorModule
#   4. Execute via the provided execute function after Strategus::execute()
# =============================================================================

library(R6)
library(DatabaseConnector)
library(ParallelLogger)

CohortAlgebraModule <- R6::R6Class(

  classname = "CohortAlgebraModule",
  
  public = list(
    #' @field moduleName The name of the module
    moduleName = "CohortAlgebraModule",
    
    #' @field moduleVersion The version of the module
    moduleVersion = "0.1.0",
    
    #' @description Initialize the module
    initialize = function() {
      invisible(self)
    },
    
    #' @description Create cohort intersection specifications
    #' @param cohortPairs Data frame with columns:
    #'   - cohortId1: First cohort ID in the pair
    #'   - cohortId2: Second cohort ID in the pair  
    #'   - newCohortId: The ID for the resulting intersection cohort
    #'   - newCohortName: A descriptive name for the new cohort
    #' @return A CohortIntersectionSpecifications object
    createCohortIntersectionSpecifications = function(cohortPairs) {
      # Validate input
      requiredCols <- c("cohortId1", "cohortId2", "newCohortId", "newCohortName")
      missingCols <- setdiff(requiredCols, names(cohortPairs))
      if (length(missingCols) > 0) {
        stop(sprintf("cohortPairs missing required columns: %s", 
                     paste(missingCols, collapse = ", ")))
      }
      
      # Check for duplicate new cohort IDs
      if (any(duplicated(cohortPairs$newCohortId))) {
        stop("Duplicate newCohortId values found in cohortPairs")
      }
      
      specifications <- list(
        intersections = cohortPairs
      )
      class(specifications) <- c("CohortIntersectionSpecifications", "list")
      return(specifications)
    },
    
    #' @description Create shared resource specifications for cohort intersections
    #' @param cohortIntersectionSpecifications Output from createCohortIntersectionSpecifications()
    #' @return A SharedResources object for use with Strategus
    createCohortIntersectionSharedResourceSpecifications = function(cohortIntersectionSpecifications) {
      if (!inherits(cohortIntersectionSpecifications, "CohortIntersectionSpecifications")) {
        stop("cohortIntersectionSpecifications must be created using createCohortIntersectionSpecifications()")
      }
      
      sharedResource <- list(
        cohortIntersections = cohortIntersectionSpecifications$intersections
      )
      class(sharedResource) <- c("CohortIntersectionSharedResources", "SharedResources")
      return(sharedResource)
    },
    
    #' @description Create module specifications
    #' @return A ModuleSpecifications object for use with Strategus
    createModuleSpecifications = function() {
      specifications <- list(
        module = self$moduleName,
        version = self$moduleVersion,
        settings = list(
          executeIntersections = TRUE
        )
      )
      class(specifications) <- c("CohortAlgebraModuleSpecifications", "ModuleSpecifications")
      return(specifications)
    },
    
    #' @description Execute the cohort intersection operations
    #' @param connectionDetails DatabaseConnector connection details
    #' @param cohortDatabaseSchema Schema where cohort table resides
    #' @param cohortTable Name of the cohort table
    #' @param cohortIntersectionSpecifications Specifications from createCohortIntersectionSpecifications()
    #' @param tempEmulationSchema Schema for temp table emulation (optional)
    execute = function(connectionDetails,
                       cohortDatabaseSchema,
                       cohortTable,
                       cohortIntersectionSpecifications,
                       tempEmulationSchema = getOption("sqlRenderTempEmulationSchema")) {
      
      if (!inherits(cohortIntersectionSpecifications, "CohortIntersectionSpecifications")) {
        stop("cohortIntersectionSpecifications must be created using createCohortIntersectionSpecifications()")
      }
      
      cohortPairs <- cohortIntersectionSpecifications$intersections
      
      if (is.null(cohortPairs) || nrow(cohortPairs) == 0) {
        ParallelLogger::logInfo("No cohort intersections defined, skipping CohortAlgebraModule")
        return(invisible(NULL))
      }
      
      ParallelLogger::logInfo(sprintf(
        "CohortAlgebraModule: Creating %d intersection cohort(s)", 
        nrow(cohortPairs)
      ))
      
      connection <- DatabaseConnector::connect(connectionDetails)
      on.exit(DatabaseConnector::disconnect(connection), add = TRUE)
      
      results <- data.frame(
        newCohortId = integer(),
        newCohortName = character(),
        cohortId1 = integer(),
        cohortId2 = integer(),
        recordCount = integer(),
        personCount = integer(),
        status = character(),
        stringsAsFactors = FALSE
      )
      
      for (i in 1:nrow(cohortPairs)) {
        pair <- cohortPairs[i, ]
        
        tryCatch({
          counts <- private$createIntersectionCohort(
            connection = connection,
            cohortDatabaseSchema = cohortDatabaseSchema,
            cohortTable = cohortTable,
            cohortId1 = pair$cohortId1,
            cohortId2 = pair$cohortId2,
            newCohortId = pair$newCohortId,
            tempEmulationSchema = tempEmulationSchema
          )
          
          ParallelLogger::logInfo(sprintf(
            "  [%d/%d] Created cohort %d '%s' (from %d & %d): %d records, %d persons",
            i, nrow(cohortPairs),
            pair$newCohortId, 
            pair$newCohortName,
            pair$cohortId1,
            pair$cohortId2,
            counts$recordCount,
            counts$personCount
          ))
          
          results <- rbind(results, data.frame(
            newCohortId = pair$newCohortId,
            newCohortName = pair$newCohortName,
            cohortId1 = pair$cohortId1,
            cohortId2 = pair$cohortId2,
            recordCount = counts$recordCount,
            personCount = counts$personCount,
            status = "SUCCESS",
            stringsAsFactors = FALSE
          ))
          
        }, error = function(e) {
          ParallelLogger::logError(sprintf(
            "  [%d/%d] FAILED to create cohort %d '%s': %s",
            i, nrow(cohortPairs),
            pair$newCohortId,
            pair$newCohortName,
            e$message
          ))
          
          results <<- rbind(results, data.frame(
            newCohortId = pair$newCohortId,
            newCohortName = pair$newCohortName,
            cohortId1 = pair$cohortId1,
            cohortId2 = pair$cohortId2,
            recordCount = NA_integer_,
            personCount = NA_integer_,
            status = paste("FAILED:", e$message),
            stringsAsFactors = FALSE
          ))
        })
      }
      
      ParallelLogger::logInfo("CohortAlgebraModule execution complete")
      
      return(invisible(results))
    },
    
    #' @description Get cohort counts for intersection cohorts
    #' @param connectionDetails DatabaseConnector connection details
    #' @param cohortDatabaseSchema Schema where cohort table resides
    #' @param cohortTable Name of the cohort table
    #' @param cohortIds Vector of cohort IDs to count
    #' @return Data frame with cohort counts
    getCohortCounts = function(connectionDetails,
                               cohortDatabaseSchema,
                               cohortTable,
                               cohortIds) {
      connection <- DatabaseConnector::connect(connectionDetails)
      on.exit(DatabaseConnector::disconnect(connection), add = TRUE)
      
      sql <- "
      SELECT 
        cohort_definition_id AS cohort_id,
        COUNT(*) AS record_count,
        COUNT(DISTINCT subject_id) AS person_count
      FROM @cohort_database_schema.@cohort_table
      WHERE cohort_definition_id IN (@cohort_ids)
      GROUP BY cohort_definition_id
      ORDER BY cohort_definition_id;
      "
      
      counts <- DatabaseConnector::renderTranslateQuerySql(
        connection = connection,
        sql = sql,
        cohort_database_schema = cohortDatabaseSchema,
        cohort_table = cohortTable,
        cohort_ids = cohortIds,
        snakeCaseToCamelCase = TRUE
      )
      
      return(counts)
    }
  ),
  
  private = list(
    #' @description Create a single intersection cohort
    createIntersectionCohort = function(connection,
                                         cohortDatabaseSchema,
                                         cohortTable,
                                         cohortId1,
                                         cohortId2,
                                         newCohortId,
                                         tempEmulationSchema = NULL) {
      
      # Step 1: Delete any existing records for the new cohort ID
      deleteSql <- "
      DELETE FROM @cohort_database_schema.@cohort_table 
      WHERE cohort_definition_id = @new_cohort_id;
      "
      
      DatabaseConnector::renderTranslateExecuteSql(
        connection = connection,
        sql = deleteSql,
        cohort_database_schema = cohortDatabaseSchema,
        cohort_table = cohortTable,
        new_cohort_id = newCohortId,
        tempEmulationSchema = tempEmulationSchema,
        progressBar = FALSE,
        reportOverallTime = FALSE
      )
      
      # Step 2: Insert intersection records
      # Join on subject_id and cohort_start_date, take minimum end date
      insertSql <- "
      INSERT INTO @cohort_database_schema.@cohort_table 
        (cohort_definition_id, subject_id, cohort_start_date, cohort_end_date)
      SELECT 
        CAST(@new_cohort_id AS INT) AS cohort_definition_id,
        c1.subject_id,
        c1.cohort_start_date,
        CASE 
          WHEN c1.cohort_end_date <= c2.cohort_end_date THEN c1.cohort_end_date 
          ELSE c2.cohort_end_date 
        END AS cohort_end_date
      FROM @cohort_database_schema.@cohort_table c1
      INNER JOIN @cohort_database_schema.@cohort_table c2
        ON c1.subject_id = c2.subject_id
        AND c1.cohort_start_date = c2.cohort_start_date
      WHERE c1.cohort_definition_id = @cohort_id_1
        AND c2.cohort_definition_id = @cohort_id_2;
      "
      
      DatabaseConnector::renderTranslateExecuteSql(
        connection = connection,
        sql = insertSql,
        cohort_database_schema = cohortDatabaseSchema,
        cohort_table = cohortTable,
        new_cohort_id = newCohortId,
        cohort_id_1 = cohortId1,
        cohort_id_2 = cohortId2,
        tempEmulationSchema = tempEmulationSchema,
        progressBar = FALSE,
        reportOverallTime = FALSE
      )
      
      # Step 3: Get counts for the new cohort
      countSql <- "
      SELECT 
        COUNT(*) AS record_count,
        COUNT(DISTINCT subject_id) AS person_count
      FROM @cohort_database_schema.@cohort_table
      WHERE cohort_definition_id = @new_cohort_id;
      "
      
      counts <- DatabaseConnector::renderTranslateQuerySql(
        connection = connection,
        sql = countSql,
        cohort_database_schema = cohortDatabaseSchema,
        cohort_table = cohortTable,
        new_cohort_id = newCohortId,
        tempEmulationSchema = tempEmulationSchema,
        snakeCaseToCamelCase = TRUE
      )
      
      return(list(
        recordCount = counts$recordCount[1],
        personCount = counts$personCount[1]
      ))
    }
  )
)


# =============================================================================
# Convenience function for standalone execution
# =============================================================================

#' Execute CohortAlgebra intersection operations
#' 
#' @description A convenience wrapper to execute cohort intersections outside
#'   of the full Strategus pipeline. Useful for testing or post-hoc execution.
#'   
#' @param connectionDetails DatabaseConnector connection details
#' @param cohortDatabaseSchema Schema where cohort table resides
#' @param cohortTable Name of the cohort table
#' @param cohortPairs Data frame with cohortId1, cohortId2, newCohortId, newCohortName
#' @return Data frame with execution results
#' 
#' @examples
#' \dontrun{
#' cohortPairs <- data.frame(
#'   cohortId1 = c(1795035, 1794530, 1794395),
#'   cohortId2 = c(1795036, 1794529, 1793813),
#'   newCohortId = c(1001, 1002, 1003),
#'   newCohortName = c("MMF+AZA (Combination)", 
#'                     "MMF+IVIG (Combination)", 
#'                     "MMF+RTX (Combination)")
#' )
#' 
#' results <- executeCohortAlgebraIntersections(
#'   connectionDetails = connectionDetails,
#'   cohortDatabaseSchema = "my_schema",
#'   cohortTable = "my_cohort_table",
#'   cohortPairs = cohortPairs
#' )
#' }
executeCohortAlgebraIntersections <- function(connectionDetails,
                                               cohortDatabaseSchema,
                                               cohortTable,
                                               cohortPairs) {
  module <- CohortAlgebraModule$new()
  specs <- module$createCohortIntersectionSpecifications(cohortPairs)
  
  results <- module$execute(
    connectionDetails = connectionDetails,
    cohortDatabaseSchema = cohortDatabaseSchema,
    cohortTable = cohortTable,
    cohortIntersectionSpecifications = specs
  )
  
  return(results)
}
