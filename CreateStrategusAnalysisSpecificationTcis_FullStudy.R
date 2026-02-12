################################################################################
# REVISED: CreateStrategusAnalysisSpecificationTcis_custom.R
# 
# This script properly handles:
# - Single-drug cohorts: subsetted by indication (creating unique IDs per indication)
# - Combo cohorts: NOT subsetted (already intersection cohorts, use base IDs)
# - All pairwise comparisons within each target-comparator group
################################################################################
library(dplyr)
library(Strategus)

# Source the CohortAlgebraModule
source("CohortAlgebraModule.R")

########################################################
# CONFIGURATION SECTION
########################################################

# Get the list of cohorts
cohortDefinitionSet <- CohortGenerator::getCohortDefinitionSet(
  settingsFileName = "inst/Cohorts.csv",
  jsonFolder = "inst/cohorts",
  sqlFolder = "inst/sql/sql_server"
)

# =============================================================================
# EXCLUDED COVARIATES
# =============================================================================
excludedCovariates_JAKi_IVIG = read.csv("inst/excludedCovariates_JAKi_IVIG.csv")
excludedCovariates_JAKi_MMF = read.csv("inst/excludedCovariates_JAKi_MMF.csv")
excludedCovariates_JAKi_RTX = read.csv("inst/excludedCovariates_JAKi_RTX.csv")
excludedCovariates_MMF_IVIG = read.csv("inst/excludedCovariates_MMF_IVIG.csv")
excludedCovariates_RTX_IVIG = read.csv("inst/excludedCovariates_RTX_IVIG.csv")
excludedCovariates_RTX_MMF = read.csv("inst/excludedCovariates_RTX_MMF.csv")
excludedCovariates_Union = read.csv("inst/excludedCovariates_Union.csv")

# =============================================================================
# DEFINE INDICATIONS
# =============================================================================
indications <- data.frame(
  indicationId = c(1794239, 1794240, 1794241, 1794242),
  indicationName = c("Uveitis", "SLE", "SSc", "DM"),
  stringsAsFactors = FALSE
)

# =============================================================================
# DEFINE TARGET-COMPARATOR GROUPS
# =============================================================================

# Group 1: Single drugs (4 drugs, 6 pairwise comparisons)
group1_singles <- data.frame(
  cohortId = c(1794247, 1794245, 1794244, 1794243),
  cohortName = c("rituximab exposures", "JAKi exposures", "MMF exposures", "IVIG exposures"),
  stringsAsFactors = FALSE
)

# Group 2: MMF Combos (5 cohorts, 10 pairwise comparisons)
group2_mmf_combos <- data.frame(
  cohortId = c(1001, 1002, 1003, 1004, 1005),
  cohortName = c("MMF+RTX (Combination)", "MMF+IVIG (Combination)", "MMF+MTX (Combination)", 
                 "MMF+AZA (Combination)", "MMF+JAKi (Combination)"),
  stringsAsFactors = FALSE
)

# Group 3: MTX Combos (5 cohorts, 10 pairwise comparisons)
group3_mtx_combos <- data.frame(
  cohortId = c(1006, 1007, 1008, 1009, 1010),
  cohortName = c("MTX+IVIG (Combination)", "MTX+MMF (Combination)", "MTX+AZA (Combination)",
                 "MTX+RTX (Combination)", "MTX+JAKi (Combination)"),
  stringsAsFactors = FALSE
)

# Group 4: AZA Combos (5 cohorts, 10 pairwise comparisons)
group4_aza_combos <- data.frame(
  cohortId = c(1011, 1012, 1013, 1014, 1015),
  cohortName = c("AZA+IVIG (Combination)", "AZA+MMF (Combination)", "AZA+MTX (Combination)",
                 "AZA+RTX (Combination)", "AZA+JAKi (Combination)"),
  stringsAsFactors = FALSE
)

# Group 5: Pooled Combos (3 cohorts, 3 pairwise comparisons)
group5_pooled_combos <- data.frame(
  cohortId = c(1016, 1017, 1018),
  cohortName = c("MMF or MTX or AZA + JAKi (Combination)", 
                 "MMF or MTX or AZA + RTX (Combination)",
                 "MMF or MTX or AZA + IVIG (Combination)"),
  stringsAsFactors = FALSE
)

# Combine all combo cohorts
comboCohorts <- rbind(group2_mmf_combos, group3_mtx_combos, group4_aza_combos, group5_pooled_combos)
comboCohorts$json <- NA_character_
comboCohorts$sql <- NA_character_

# =============================================================================
# DEFINE OUTCOMES
# =============================================================================
outcomes <- tibble(
  cohortId = c(
    1791985, # pneumocystis pneumonia (Total)
    1792492, # pneumocystis pneumonia (Case1)
    1792493, # pneumocystis pneumonia (Case2)
    1792494, # pneumocystis pneumonia (Case3)
    1791944, # varicella zoster (Sensitive)
    1791945, # varicella zoster (Specific)
    1792481, # varicella zoster (New)
    1792205, # PML
    1793889  # Hospitalized Infection - optimized
  ),
  cleanWindow = c(365, 365, 365, 365, 365, 365, 365, 9999, 30)
)

# =============================================================================
# COHORT ALGEBRA PAIRS (for intersection cohorts)
# =============================================================================
pairs <- list(
  list(sourceIds = c(1794531, 1794532), newId = 1001),
  list(sourceIds = c(1794530, 1794529), newId = 1002),
  list(sourceIds = c(1794395, 1793813), newId = 1003),
  list(sourceIds = c(1795035, 1795036), newId = 1004),
  list(sourceIds = c(1794527, 1794528), newId = 1005),
  list(sourceIds = c(1795370, 1795371), newId = 1006), 
  list(sourceIds = c(1795374, 1795375), newId = 1007),
  list(sourceIds = c(1795378, 1795379), newId = 1008),
  list(sourceIds = c(1795381, 1795382), newId = 1009),
  list(sourceIds = c(1795385, 1795386), newId = 1010),
  list(sourceIds = c(1795372, 1795373), newId = 1011),
  list(sourceIds = c(1795375, 1795376), newId = 1012),
  list(sourceIds = c(1795377, 1795380), newId = 1013),
  list(sourceIds = c(1795383, 1795384), newId = 1014),
  list(sourceIds = c(1795387, 1795388), newId = 1015),
  list(sourceIds = c(1795629, 1795628), newId = 1016),
  list(sourceIds = c(1795626, 1795624), newId = 1017),
  list(sourceIds = c(1795625, 1795627), newId = 1018)
)

# =============================================================================
# TIME-AT-RISK SETTINGS
# =============================================================================
timeAtRisks <- tibble(
  label = c("On treatment", "On treatment"),
  riskWindowStart  = c(1, 1),
  startAnchor = c("cohort start", "cohort start"),
  riskWindowEnd  = c(0, 0),
  endAnchor = c("cohort end", "cohort end")
)

sccsTimeAtRisks <- tibble(
  label = c("On treatment", "On treatment"),
  riskWindowStart  = c(1, 1),
  startAnchor = c("era start", "era start"),
  riskWindowEnd  = c(0, 0),
  endAnchor = c("era end", "era end")
)

# =============================================================================
# STUDY SETTINGS
# =============================================================================
studyStartDate <- '19000101'
studyEndDate <- '20251231'
studyStartDateWithHyphens <- gsub("(\\d{4})(\\d{2})(\\d{2})", "\\1-\\2-\\3", studyStartDate)
studyEndDateWithHyphens <- gsub("(\\d{4})(\\d{2})(\\d{2})", "\\1-\\2-\\3", studyEndDate)

useCleanWindowForPriorOutcomeLookback <- FALSE
psMatchMaxRatio <- 1
maxCohortSizeForFitting <- 250000
maxCohortSize <- maxCohortSizeForFitting
maxCasesPerOutcome <- 1000000
plpMaxSampleSize <- 1000000

# =============================================================================
# HELPER FUNCTION: Generate all pairwise comparisons
# =============================================================================
generatePairwiseComparisons <- function(cohortIds) {
  pairs <- data.frame(targetId = integer(), comparatorId = integer())
  n <- length(cohortIds)
  for (i in 1:(n-1)) {
    for (j in (i+1):n) {
      pairs <- rbind(pairs, data.frame(
        targetId = cohortIds[i],
        comparatorId = cohortIds[j]
      ))
    }
  }
  return(pairs)
}

# =============================================================================
# HELPER FUNCTION: Get excluded covariates for a target-comparator pair
# =============================================================================
getExcludedCovariates <- function(targetId, comparatorId) {
  # For combo cohorts, use union of all excluded covariates
  if (targetId < 10000 && comparatorId < 10000) {
    return(excludedCovariates_Union$conceptId)
  }
  
  # For single drugs, use specific excluded covariates
  singleIds <- sort(c(targetId, comparatorId))
  
  if (all(singleIds == c(1794243, 1794244))) return(excludedCovariates_MMF_IVIG$conceptId)
  if (all(singleIds == c(1794243, 1794245))) return(excludedCovariates_JAKi_IVIG$conceptId)
  if (all(singleIds == c(1794243, 1794247))) return(excludedCovariates_RTX_IVIG$conceptId)
  if (all(singleIds == c(1794244, 1794245))) return(excludedCovariates_JAKi_MMF$conceptId)
  if (all(singleIds == c(1794244, 1794247))) return(excludedCovariates_RTX_MMF$conceptId)
  if (all(singleIds == c(1794245, 1794247))) return(excludedCovariates_JAKi_RTX$conceptId)
  
  # Default to union
  return(excludedCovariates_Union$conceptId)
}

# =============================================================================
# BUILD SINGLE-DRUG TCIs (Target-Comparator-Indication combinations)
# These require indication-based subsetting
# =============================================================================
message("Building single-drug TCIs...")

singleDrugPairs <- generatePairwiseComparisons(group1_singles$cohortId)
message(sprintf("  Single-drug pairs: %d", nrow(singleDrugPairs)))

tcis <- list()
for (i in 1:nrow(singleDrugPairs)) {
  for (j in 1:nrow(indications)) {
    tcis[[length(tcis) + 1]] <- list(
      targetId = singleDrugPairs$targetId[i],
      comparatorId = singleDrugPairs$comparatorId[i],
      indicationId = indications$indicationId[j],
      genderConceptIds = c(8507, 8532),
      minAge = NULL,
      maxAge = NULL,
      excludedCovariateConceptIds = getExcludedCovariates(
        singleDrugPairs$targetId[i], 
        singleDrugPairs$comparatorId[i]
      )
    )
  }
}
message(sprintf("  Total single-drug TCIs: %d (6 pairs x 4 indications)", length(tcis)))

# =============================================================================
# BUILD COMBO TCIs
# These do NOT require indication subsetting - they use base cohort IDs directly
# =============================================================================
message("Building combo TCIs...")

# Group 2: MMF combos
group2_pairs <- generatePairwiseComparisons(group2_mmf_combos$cohortId)
message(sprintf("  Group 2 (MMF combos) pairs: %d", nrow(group2_pairs)))

# Group 3: MTX combos
group3_pairs <- generatePairwiseComparisons(group3_mtx_combos$cohortId)
message(sprintf("  Group 3 (MTX combos) pairs: %d", nrow(group3_pairs)))

# Group 4: AZA combos
group4_pairs <- generatePairwiseComparisons(group4_aza_combos$cohortId)
message(sprintf("  Group 4 (AZA combos) pairs: %d", nrow(group4_pairs)))

# Group 5: Pooled combos
group5_pairs <- generatePairwiseComparisons(group5_pooled_combos$cohortId)
message(sprintf("  Group 5 (Pooled combos) pairs: %d", nrow(group5_pairs)))

# Combine all combo pairs
allComboPairs <- rbind(group2_pairs, group3_pairs, group4_pairs, group5_pairs)
message(sprintf("  Total combo pairs: %d", nrow(allComboPairs)))

# Create comboTcis - note: we add indication info but it's NOT used for subsetting
# This is just for consistency with the data structure
comboTcis <- list()
for (i in 1:nrow(allComboPairs)) {
  # Add one entry per indication (for SCCS and other modules that might use it)
  for (j in 1:nrow(indications)) {
    comboTcis[[length(comboTcis) + 1]] <- list(
      targetId = allComboPairs$targetId[i],
      comparatorId = allComboPairs$comparatorId[i],
      indicationId = indications$indicationId[j],
      genderConceptIds = c(8507, 8532),
      minAge = NULL,
      maxAge = NULL,
      excludedCovariateConceptIds = excludedCovariates_Union$conceptId
    )
  }
}
message(sprintf("  Total combo TCIs (with indication variants): %d", length(comboTcis)))

########################################################
# COHORT DEFINITION SET SETUP
########################################################

# Add combo cohorts to cohortDefinitionSet
for (i in 1:nrow(comboCohorts)) {
  newRow <- data.frame(
    cohortId = comboCohorts$cohortId[i],
    cohortName = comboCohorts$cohortName[i],
    json = NA_character_,
    sql = NA_character_,
    stringsAsFactors = FALSE
  )
  missingCols <- setdiff(names(cohortDefinitionSet), names(newRow))
  for (col in missingCols) {
    newRow[[col]] <- NA
  }
  newRow <- newRow[, names(cohortDefinitionSet)]
  cohortDefinitionSet <- rbind(cohortDefinitionSet, newRow)
}

message(sprintf("Added %d combination cohorts to cohortDefinitionSet (total: %d cohorts)", 
                nrow(comboCohorts), nrow(cohortDefinitionSet)))

# =============================================================================
# CREATE SUBSET DEFINITIONS FOR SINGLE-DRUG COHORTS ONLY
# =============================================================================
message("Creating subset definitions for single-drug cohorts...")

# Build unique TCI criteria for SINGLES ONLY (not combos)
dfUniqueTcis <- data.frame()
for (i in seq_along(tcis)) {
  dfUniqueTcis <- rbind(dfUniqueTcis, data.frame(
    cohortId = tcis[[i]]$targetId,
    indicationId = paste(tcis[[i]]$indicationId, collapse = ","),
    genderConceptIds = paste(tcis[[i]]$genderConceptIds, collapse = ","),
    minAge = paste(tcis[[i]]$minAge, collapse = ","),
    maxAge = paste(tcis[[i]]$maxAge, collapse = ",")
  ))
  if (!is.null(tcis[[i]]$comparatorId)) {
    dfUniqueTcis <- rbind(dfUniqueTcis, data.frame(
      cohortId = tcis[[i]]$comparatorId,
      indicationId = paste(tcis[[i]]$indicationId, collapse = ","),
      genderConceptIds = paste(tcis[[i]]$genderConceptIds, collapse = ","),
      minAge = paste(tcis[[i]]$minAge, collapse = ","),
      maxAge = paste(tcis[[i]]$maxAge, collapse = ",")
    ))
  }
}

dfUniqueTcis <- unique(dfUniqueTcis)
dfUniqueTcis$subsetDefinitionId <- 0
dfUniqueSubsetCriteria <- unique(dfUniqueTcis[,-1])

message(sprintf("  Unique subset criteria: %d", nrow(dfUniqueSubsetCriteria)))

for (i in 1:nrow(dfUniqueSubsetCriteria)) {
  uniqueSubsetCriteria <- dfUniqueSubsetCriteria[i,]
  dfCurrentTcis <- dfUniqueTcis[dfUniqueTcis$indicationId == uniqueSubsetCriteria$indicationId &
                                  dfUniqueTcis$genderConceptIds == uniqueSubsetCriteria$genderConceptIds &
                                  dfUniqueTcis$minAge == uniqueSubsetCriteria$minAge & 
                                  dfUniqueTcis$maxAge == uniqueSubsetCriteria$maxAge,]
  targetCohortIdsForSubsetCriteria <- as.integer(dfCurrentTcis[, "cohortId"])
  dfUniqueTcis[dfUniqueTcis$indicationId == dfCurrentTcis$indicationId &
                 dfUniqueTcis$genderConceptIds == dfCurrentTcis$genderConceptIds &
                 dfUniqueTcis$minAge == dfCurrentTcis$minAge & 
                 dfUniqueTcis$maxAge == dfCurrentTcis$maxAge,]$subsetDefinitionId <- i
  
  subsetOperators <- list()
  if (uniqueSubsetCriteria$indicationId != "") {
    subsetOperators[[length(subsetOperators) + 1]] <- CohortGenerator::createCohortSubset(
      cohortIds = uniqueSubsetCriteria$indicationId,
      negate = FALSE,
      cohortCombinationOperator = "all",
      windows = list(
        CohortGenerator::createSubsetCohortWindow(
          startDay = -99999, 
          endDay = 0, 
          targetAnchor = "cohortStart",
          subsetAnchor = "cohortStart"
        ),
        CohortGenerator::createSubsetCohortWindow(
          startDay = 0, 
          endDay = 99999, 
          targetAnchor = "cohortStart",
          subsetAnchor = "cohortEnd"
        )
      )
    )
  }
  subsetOperators[[length(subsetOperators) + 1]] <- CohortGenerator::createLimitSubset(
    priorTime = 365,
    followUpTime = 1
  )
  if (uniqueSubsetCriteria$genderConceptIds != "" ||
      uniqueSubsetCriteria$minAge != "" ||
      uniqueSubsetCriteria$maxAge != "") {
    subsetOperators[[length(subsetOperators) + 1]] <- CohortGenerator::createDemographicSubset(
      ageMin = if(uniqueSubsetCriteria$minAge == "") 0 else as.integer(uniqueSubsetCriteria$minAge),
      ageMax = if(uniqueSubsetCriteria$maxAge == "") 99999 else as.integer(uniqueSubsetCriteria$maxAge),
      gender = if(uniqueSubsetCriteria$genderConceptIds == "") NULL else as.integer(strsplit(uniqueSubsetCriteria$genderConceptIds, ",")[[1]])
    )
  }
  if (studyStartDate != "" || studyEndDate != "") {
    subsetOperators[[length(subsetOperators) + 1]] <- CohortGenerator::createLimitSubset(
      calendarStartDate = if (studyStartDate == "") NULL else as.Date(studyStartDate, "%Y%m%d"),
      calendarEndDate = if (studyEndDate == "") NULL else as.Date(studyEndDate, "%Y%m%d")
    )
  }
  subsetDef <- CohortGenerator::createCohortSubsetDefinition(
    name = "Subset",
    definitionId = i,
    subsetOperators = subsetOperators
  )
  
  # ONLY apply subset to SINGLE-DRUG cohorts (NOT combo cohorts)
  existingCohortIds <- targetCohortIdsForSubsetCriteria[
    targetCohortIdsForSubsetCriteria %in% cohortDefinitionSet$cohortId &
      !targetCohortIdsForSubsetCriteria %in% comboCohorts$cohortId
  ]
  
  if (length(existingCohortIds) > 0) {
    cohortDefinitionSet <- cohortDefinitionSet %>%
      CohortGenerator::addCohortSubsetDefinition(
        cohortSubsetDefintion = subsetDef,
        targetCohortIds = existingCohortIds
      )
  }
  
  if (uniqueSubsetCriteria$indicationId != "") {
    subsetDef <- CohortGenerator::createCohortSubsetDefinition(
      name = "Subset",
      definitionId = i + 100,
      subsetOperators = subsetOperators[2:length(subsetOperators)]
    )
    cohortDefinitionSet <- cohortDefinitionSet %>%
      CohortGenerator::addCohortSubsetDefinition(
        cohortSubsetDefintion = subsetDef,
        targetCohortIds = as.integer(uniqueSubsetCriteria$indicationId)
      )
  }  
}

message(sprintf("  Created %d subset definitions", nrow(dfUniqueSubsetCriteria)))

# Load negative controls
negativeControlOutcomeCohortSet <- CohortGenerator::readCsv(
  file = "inst/negativeControlOutcomes.csv"
)

if (any(duplicated(cohortDefinitionSet$cohortId, negativeControlOutcomeCohortSet$cohortId))) {
  stop("*** Error: duplicate cohort IDs found ***")
}

# Load cohort algebra pairs
cohortAlgebraPairs <- CohortGenerator::readCsv(
  file = "inst/cohortAlgebraPairs.csv"
)

# =============================================================================
# CohortAlgebraModule Specifications
# =============================================================================
caModule <- CohortAlgebraModule$new()

cohortIntersectionSpecifications <- caModule$createCohortIntersectionSpecifications(
  cohortPairs = cohortAlgebraPairs
)

cohortIntersectionShared <- caModule$createCohortIntersectionSharedResourceSpecifications(
  cohortIntersectionSpecifications = cohortIntersectionSpecifications
)

cohortAlgebraModuleSpecifications <- caModule$createModuleSpecifications()

message("CohortAlgebraModule specifications created successfully")

# =============================================================================
# CohortGeneratorModule
# =============================================================================
cgModuleSettingsCreator <- CohortGeneratorModule$new()

cohortDefinitionSetForGenerator <- cohortDefinitionSet %>%
  filter(!cohortId %in% comboCohorts$cohortId)

message(sprintf("Cohorts for CohortGenerator: %d (excluding %d combo cohorts)",
                nrow(cohortDefinitionSetForGenerator), nrow(comboCohorts)))

cohortDefinitionShared <- cgModuleSettingsCreator$createCohortSharedResourceSpecifications(cohortDefinitionSetForGenerator)
negativeControlsShared <- cgModuleSettingsCreator$createNegativeControlOutcomeCohortSharedResourceSpecifications(
  negativeControlOutcomeCohortSet = negativeControlOutcomeCohortSet,
  occurrenceType = 'all',
  detectOnDescendants = TRUE
)
cohortGeneratorModuleSpecifications <- cgModuleSettingsCreator$createModuleSpecifications(
  generateStats = TRUE
)

# =============================================================================
# CohortDiagnosticsModule
# =============================================================================
cdModuleSettingsCreator <- CohortDiagnosticsModule$new()

cohortIdsForDiagnostics <- cohortDefinitionSet %>%
  filter(!cohortId %in% comboCohorts$cohortId) %>%
  filter(!is.na(json) & json != "") %>%
  pull(cohortId)

message(sprintf("Cohorts for CohortDiagnostics: %d", length(cohortIdsForDiagnostics)))

cohortDiagnosticsModuleSpecifications <- cdModuleSettingsCreator$createModuleSpecifications(
  cohortIds = cohortIdsForDiagnostics,
  runInclusionStatistics = TRUE,
  runIncludedSourceConcepts = TRUE,
  runOrphanConcepts = TRUE,
  runTimeSeries = FALSE,
  runVisitContext = TRUE,
  runBreakdownIndexEvents = TRUE,
  runIncidenceRate = TRUE,
  runCohortRelationship = TRUE,
  runTemporalCohortCharacterization = TRUE,
  minCharacterizationMean = 0.01
)

# =============================================================================
# CharacterizationModule
# =============================================================================
cModuleSettingsCreator <- CharacterizationModule$new()

allCohortIdsExceptOutcomes <- cohortDefinitionSet %>%
  filter(!cohortId %in% outcomes$cohortId) %>%
  pull(cohortId)

outcomeWashoutDays <- outcomes$cleanWindow

characterizationModuleSpecifications <- cModuleSettingsCreator$createModuleSpecifications(
  targetIds = allCohortIdsExceptOutcomes,
  outcomeIds = outcomes$cohortId,
  outcomeWashoutDays = outcomeWashoutDays,
  minPriorObservation = 365,
  dechallengeStopInterval = 30,
  dechallengeEvaluationWindow = 30,
  riskWindowStart = timeAtRisks$riskWindowStart,
  startAnchor = timeAtRisks$startAnchor,
  riskWindowEnd = timeAtRisks$riskWindowEnd,
  endAnchor = timeAtRisks$endAnchor,
  minCharacterizationMean = 0.01
)

# =============================================================================
# CohortIncidenceModule
# =============================================================================
ciModuleSettingsCreator <- CohortIncidenceModule$new()

# Build target list for singles (using subsetted IDs) + combos (using base IDs)
irTargetList <- list()

# Add subsetted single-drug cohorts
for (i in 1:nrow(dfUniqueTcis)) {
  tci <- dfUniqueTcis[i,]
  
  cohortIdLookup <- cohortDefinitionSet %>% 
    filter(subsetParent == tci$cohortId & subsetDefinitionId == tci$subsetDefinitionId)
  
  if (nrow(cohortIdLookup) == 0) next
  
  cohortId <- cohortIdLookup %>% pull(cohortId)
  cohortName <- cohortIdLookup %>% pull(cohortName)
  
  irTargetList[[length(irTargetList)+1]] <- CohortIncidence::createCohortRef(
    id = cohortId,
    name = cohortName
  )
}

# Add combo cohorts (base IDs, no subsetting)
for (i in 1:nrow(comboCohorts)) {
  irTargetList[[length(irTargetList)+1]] <- CohortIncidence::createCohortRef(
    id = comboCohorts$cohortId[i],
    name = comboCohorts$cohortName[i]
  )
}

# Build outcome list
irOutcomeList <- list()
for (i in seq_len(nrow(outcomes))) {
  irOutcomeList[[length(irOutcomeList)+1]] <- CohortIncidence::createOutcomeDef(
    id = i,
    name = cohortDefinitionSet %>% filter(cohortId == outcomes$cohortId[i]) %>% pull(cohortName),
    cohortId = outcomes$cohortId[i],
    cleanWindow = outcomes$cleanWindow[i]
  )
}

# Build TARs
irTimeAtRiskList <- list()
for (i in seq_len(nrow(timeAtRisks))) {
  irTimeAtRiskList[[length(irTimeAtRiskList)+1]] <- CohortIncidence::createTimeAtRiskDef(
    id = i,
    startWith = if (timeAtRisks$startAnchor[i] == "cohort start") "start" else "end",
    startOffset = timeAtRisks$riskWindowStart[i],
    endWith = if (timeAtRisks$endAnchor[i] == "cohort start") "start" else "end",
    endOffset = timeAtRisks$riskWindowEnd[i]
  )
}

# Build analyses
irAnalysisList <- list()
analysisId <- 0
for (targetDef in irTargetList) {
  for (outcomeDef in irOutcomeList) {
    for (tarDef in irTimeAtRiskList) {
      analysisId <- analysisId + 1
      irAnalysisList[[length(irAnalysisList)+1]] <- CohortIncidence::createIncidenceAnalysis(
        targets = targetDef$id,
        outcomes = outcomeDef$id,
        tars = tarDef$id
      )
    }
  }
}

irDesign <- CohortIncidence::createIncidenceDesign(
  targetDefs = irTargetList,
  outcomeDefs = irOutcomeList,
  tars = irTimeAtRiskList,
  analysisList = irAnalysisList,
  studyWindow = if (studyStartDate == "" && studyEndDate == "") NULL 
  else CohortIncidence::createDateRange(
    startDate = studyStartDateWithHyphens,
    endDate = studyEndDateWithHyphens
  )
)

cohortIncidenceModuleSpecifications <- ciModuleSettingsCreator$createModuleSpecifications(
  irDesign = irDesign$toList()
)

# =============================================================================
# CohortMethodModule
# =============================================================================
message("Building CohortMethod specifications...")

cmModuleSettingsCreator <- CohortMethodModule$new()

covariateSettings <- FeatureExtraction::createDefaultCovariateSettings(
  addDescendantsToExclude = TRUE
)

# Create outcome list
outcomeList <- append(
  lapply(seq_len(nrow(outcomes)), function(i) {
    if (useCleanWindowForPriorOutcomeLookback)
      priorOutcomeLookback <- outcomes$cleanWindow[i]
    else
      priorOutcomeLookback <- 99999
    CohortMethod::createOutcome(
      outcomeId = outcomes$cohortId[i],
      outcomeOfInterest = TRUE,
      trueEffectSize = NA,
      priorOutcomeLookback = priorOutcomeLookback
    )
  }),
  lapply(negativeControlOutcomeCohortSet$cohortId, function(i) {
    CohortMethod::createOutcome(
      outcomeId = i,
      outcomeOfInterest = FALSE,
      trueEffectSize = 1
    )
  })
)

# =============================================================================
# BUILD TCOs FOR COHORT METHOD
# =============================================================================
targetComparatorOutcomesList <- list()

# -----------------------------------------------------------------------------
# SINGLES: Use subsetted cohort IDs (indication-specific)
# -----------------------------------------------------------------------------
message("  Building single-drug TCOs...")
for (i in seq_along(tcis)) {
  tci <- tcis[[i]]
  
  # Find the subset definition ID for this indication
  currentSubsetDefinitionId <- dfUniqueTcis %>%
    filter(cohortId == tci$targetId &
             indicationId == paste(tci$indicationId, collapse = ",") &
             genderConceptIds == paste(tci$genderConceptIds, collapse = ",") &
             minAge == paste(tci$minAge, collapse = ",") &
             maxAge == paste(tci$maxAge, collapse = ",")) %>%
    pull(subsetDefinitionId)
  
  if (length(currentSubsetDefinitionId) == 0) {
    warning(sprintf("No subset definition found for TCI %d", i))
    next
  }
  
  # Look up the subsetted target and comparator IDs
  targetIdLookup <- cohortDefinitionSet %>%
    filter(subsetParent == tci$targetId & subsetDefinitionId == currentSubsetDefinitionId)
  
  comparatorIdLookup <- cohortDefinitionSet %>% 
    filter(subsetParent == tci$comparatorId & subsetDefinitionId == currentSubsetDefinitionId)
  
  if (nrow(targetIdLookup) == 0 || nrow(comparatorIdLookup) == 0) {
    warning(sprintf("Could not find subsetted cohorts for TCI %d", i))
    next
  }
  
  targetId <- targetIdLookup %>% pull(cohortId)
  comparatorId <- comparatorIdLookup %>% pull(cohortId)
  
  targetComparatorOutcomesList[[length(targetComparatorOutcomesList) + 1]] <- CohortMethod::createTargetComparatorOutcomes(
    targetId = targetId,
    comparatorId = comparatorId,
    outcomes = outcomeList,
    excludedCovariateConceptIds = tci$excludedCovariateConceptIds
  )
}
message(sprintf("    Added %d single-drug TCOs", length(targetComparatorOutcomesList)))

# -----------------------------------------------------------------------------
# COMBOS: Use base cohort IDs directly (NO indication subsetting)
# Only add unique target/comparator pairs
# -----------------------------------------------------------------------------
message("  Building combo TCOs...")
comboTCOCount <- 0

for (i in 1:nrow(allComboPairs)) {
  targetComparatorOutcomesList[[length(targetComparatorOutcomesList) + 1]] <- CohortMethod::createTargetComparatorOutcomes(
    targetId = allComboPairs$targetId[i],
    comparatorId = allComboPairs$comparatorId[i],
    outcomes = outcomeList,
    excludedCovariateConceptIds = excludedCovariates_Union$conceptId
  )
  comboTCOCount <- comboTCOCount + 1
}
message(sprintf("    Added %d combo TCOs", comboTCOCount))

message(sprintf("  Total TCOs: %d", length(targetComparatorOutcomesList)))

# CohortMethod analysis settings
getDbCohortMethodDataArgs <- CohortMethod::createGetDbCohortMethodDataArgs(
  restrictToCommonPeriod = TRUE,
  studyStartDate = studyStartDate,
  studyEndDate = studyEndDate,
  maxCohortSize = 0,
  covariateSettings = covariateSettings
)

createPsArgs <- CohortMethod::createCreatePsArgs(
  maxCohortSizeForFitting = maxCohortSizeForFitting,
  errorOnHighCorrelation = TRUE,
  stopOnError = FALSE,
  estimator = "att",
  prior = Cyclops::createPrior(
    priorType = "laplace", 
    exclude = c(0), 
    useCrossValidation = TRUE
  ),
  control = Cyclops::createControl(
    noiseLevel = "silent", 
    cvType = "auto", 
    seed = 1, 
    resetCoefficients = TRUE, 
    tolerance = 2e-07, 
    cvRepetitions = 1, 
    startingVariance = 0.01
  )
)

matchOnPsArgs <- CohortMethod::createMatchOnPsArgs(
  maxRatio = psMatchMaxRatio,
  caliper = 0.2,
  caliperScale = "standardized logit",
  allowReverseMatch = FALSE
)

computeSharedCovariateBalanceArgs <- CohortMethod::createComputeCovariateBalanceArgs(
  maxCohortSize = maxCohortSize,
  covariateFilter = NULL
)

computeCovariateBalanceArgs <- CohortMethod::createComputeCovariateBalanceArgs(
  maxCohortSize = maxCohortSize,
  covariateFilter = FeatureExtraction::getDefaultTable1Specifications()
)

fitOutcomeModelArgs <- CohortMethod::createFitOutcomeModelArgs(
  modelType = "cox",
  stratified = psMatchMaxRatio != 1,
  useCovariates = FALSE,
  inversePtWeighting = FALSE,
  prior = Cyclops::createPrior(
    priorType = "laplace", 
    useCrossValidation = TRUE
  ),
  control = Cyclops::createControl(
    cvType = "auto", 
    seed = 1, 
    resetCoefficients = TRUE,
    startingVariance = 0.01, 
    tolerance = 2e-07, 
    cvRepetitions = 1, 
    noiseLevel = "quiet"
  )
)

# Build CM analyses
cmAnalysisList <- list()
for (i in seq_len(nrow(timeAtRisks))) {
  createStudyPopArgs <- CohortMethod::createCreateStudyPopulationArgs(
    censorAtNewRiskWindow = TRUE,
    removeSubjectsWithPriorOutcome = TRUE,
    priorOutcomeLookback = 99999,
    riskWindowStart = timeAtRisks$riskWindowStart[[i]],
    startAnchor = timeAtRisks$startAnchor[[i]],
    riskWindowEnd = timeAtRisks$riskWindowEnd[[i]],
    endAnchor = timeAtRisks$endAnchor[[i]],
    minDaysAtRisk = 1,
    maxDaysAtRisk = 99999
  )
  cmAnalysisList[[i]] <- CohortMethod::createCmAnalysis(
    analysisId = i,
    description = sprintf("Cohort method, %s", timeAtRisks$label[i]),
    getDbCohortMethodDataArgs = getDbCohortMethodDataArgs,
    createStudyPopulationArgs = createStudyPopArgs,
    createPsArgs = createPsArgs,
    matchOnPsArgs = matchOnPsArgs,
    computeSharedCovariateBalanceArgs = computeSharedCovariateBalanceArgs,
    computeCovariateBalanceArgs = computeCovariateBalanceArgs,
    fitOutcomeModelArgs = fitOutcomeModelArgs
  )
}

message(sprintf("Created %d CohortMethod analyses", length(cmAnalysisList)))

cmDiagnosticThresholds <- CohortMethod::createCmDiagnosticThresholds(
  mdrrThreshold = Inf,
  easeThreshold = 0.3,
  sdmThreshold = 0.2,
  equipoiseThreshold = 0.15,
  generalizabilitySdmThreshold = 1
)


# First create the combined specification object
cmAnalysesSpecifications <- CohortMethod::createCmAnalysesSpecifications(
  cmAnalysisList = cmAnalysisList,
  targetComparatorOutcomesList = targetComparatorOutcomesList
)

# Then pass it as a single argument
cohortMethodModuleSpecifications <- cmModuleSettingsCreator$createModuleSpecifications(
  cmAnalysesSpecifications = cmAnalysesSpecifications$toList()
)

# =============================================================================
# SelfControlledCaseSeriesModule
# =============================================================================
message("Building SCCS specifications...")

sccsModuleSettingsCreator <- SelfControlledCaseSeriesModule$new()

eoList <- list()

# Build exposure-outcomes for SINGLES (using subsetted IDs)
dfUniqueTcis$exposureId <- NA_integer_

for (i in 1:nrow(dfUniqueTcis)) {
  tci <- dfUniqueTcis[i,]
  
  cohortIdLookup <- cohortDefinitionSet %>% 
    filter(subsetParent == tci$cohortId & subsetDefinitionId == tci$subsetDefinitionId)
  
  if (nrow(cohortIdLookup) == 0) next
  
  cohortId <- cohortIdLookup %>% pull(cohortId)
  dfUniqueTcis$exposureId[i] <- cohortId
  
  for (outcomeId in outcomes$cohortId) {
    eoList[[length(eoList) + 1]] <- SelfControlledCaseSeries::createExposuresOutcome(
      exposures = list(
        SelfControlledCaseSeries::createExposure(
          exposureId = cohortId,
          exposureIdRef = "exposureId"
        )
      ),
      outcomeId = outcomeId
    )
  }
}

# Build exposure-outcomes for COMBOS (using base IDs)
for (comboCohortId in comboCohorts$cohortId) {
  for (outcomeId in outcomes$cohortId) {
    eoList[[length(eoList) + 1]] <- SelfControlledCaseSeries::createExposuresOutcome(
      exposures = list(
        SelfControlledCaseSeries::createExposure(
          exposureId = comboCohortId,
          exposureIdRef = "exposureId"
        )
      ),
      outcomeId = outcomeId
    )
  }
}

message(sprintf("Created %d SCCS exposure-outcome combinations", length(eoList)))

getDbSccsDataArgs <- SelfControlledCaseSeries::createGetDbSccsDataArgs(
  studyStartDate = studyStartDate,
  studyEndDate = studyEndDate,
  deleteCovariatesSmallCount = 0,
  maxCasesPerOutcome = maxCasesPerOutcome
)

# Build SCCS analyses for SINGLES
sccsAnalysisList <- list()
analysisToInclude <- data.frame()

for (i in 1:nrow(dfUniqueTcis)) {
  tci <- dfUniqueTcis[i,]
  
  if (is.na(tci$exposureId) || is.null(tci$exposureId)) next
  
  for (j in seq_len(nrow(sccsTimeAtRisks))) {
    createStudyPopulationArgs <- SelfControlledCaseSeries::createCreateStudyPopulationArgs(
      firstOutcomeOnly = !useCleanWindowForPriorOutcomeLookback,
      naivePeriod = 365,
      minAge = if(tci$minAge == "") 18 else as.integer(tci$minAge),
      maxAge = if(tci$maxAge == "") NULL else as.integer(tci$maxAge),
      genderConceptIds = if(tci$genderConceptIds == "") NULL else as.integer(strsplit(tci$genderConceptIds, ",")[[1]])
    )
    createSccsIntervalDataArgs <- SelfControlledCaseSeries::createCreateSccsIntervalDataArgs(
      eraCovariateSettings = SelfControlledCaseSeries::createEraCovariateSettings(
        includeEraIds = "exposureId",
        startAnchor = sccsTimeAtRisks$startAnchor[j],
        start = sccsTimeAtRisks$riskWindowStart[j],
        endAnchor = sccsTimeAtRisks$endAnchor[j],
        end = sccsTimeAtRisks$riskWindowEnd[j],
        stratifyById = FALSE,
        exposureOfInterest = TRUE,
        label = "Main"
      )
    )
    
    exposureName <- cohortDefinitionSet %>% 
      filter(cohortId == tci$exposureId) %>% 
      pull(cohortName)
    
    description <- sprintf("%s", exposureName)
    if (!is.na(tci$indicationId) && tci$indicationId != "") {
      indicationName <- cohortDefinitionSet %>%
        filter(cohortId == as.integer(tci$indicationId)) %>%
        pull(cohortName)
      description <- sprintf("%s, having %s", description, indicationName)
    }
    if (tci$genderConceptIds == "8507") {
      description <- sprintf("%s, male", description)
    } else if (tci$genderConceptIds == "8532") {
      description <- sprintf("%s, female", description)
    }
    if (tci$minAge != "" || tci$maxAge != "") {
      description <- sprintf("%s, age %s-%s", description,
                             if(tci$minAge == "") "" else tci$minAge,
                             if(tci$maxAge == "") "" else tci$maxAge)
    }
    description <- sprintf("%s, %s", description, sccsTimeAtRisks$label[j])
    
    sccsAnalysisList[[length(sccsAnalysisList) + 1]] <- SelfControlledCaseSeries::createSccsAnalysis(
      analysisId = length(sccsAnalysisList) + 1,
      description = description,
      getDbSccsDataArgs = getDbSccsDataArgs,
      createStudyPopulationArgs = createStudyPopulationArgs,
      createIntervalDataArgs = createSccsIntervalDataArgs,
      fitSccsModelArgs = SelfControlledCaseSeries::createFitSccsModelArgs()
    )
    analysisToInclude <- bind_rows(analysisToInclude, data.frame(
      exposureId = tci$exposureId,
      analysisId = length(sccsAnalysisList)
    ))
  }
}

# Build SCCS analyses for COMBOS
for (comboCohortId in comboCohorts$cohortId) {
  comboName <- comboCohorts$cohortName[comboCohorts$cohortId == comboCohortId]
  
  for (j in seq_len(nrow(sccsTimeAtRisks))) {
    createStudyPopulationArgs <- SelfControlledCaseSeries::createCreateStudyPopulationArgs(
      firstOutcomeOnly = !useCleanWindowForPriorOutcomeLookback,
      naivePeriod = 365,
      minAge = 18
    )
    createSccsIntervalDataArgs <- SelfControlledCaseSeries::createCreateSccsIntervalDataArgs(
      eraCovariateSettings = SelfControlledCaseSeries::createEraCovariateSettings(
        includeEraIds = "exposureId",
        startAnchor = sccsTimeAtRisks$startAnchor[j],
        start = sccsTimeAtRisks$riskWindowStart[j],
        endAnchor = sccsTimeAtRisks$endAnchor[j],
        end = sccsTimeAtRisks$riskWindowEnd[j],
        stratifyById = FALSE,
        exposureOfInterest = TRUE,
        label = "Main"
      )
    )
    
    description <- sprintf("%s, %s", comboName, sccsTimeAtRisks$label[j])
    
    sccsAnalysisList[[length(sccsAnalysisList) + 1]] <- SelfControlledCaseSeries::createSccsAnalysis(
      analysisId = length(sccsAnalysisList) + 1,
      description = description,
      getDbSccsDataArgs = getDbSccsDataArgs,
      createStudyPopulationArgs = createStudyPopulationArgs,
      createIntervalDataArgs = createSccsIntervalDataArgs,
      fitSccsModelArgs = SelfControlledCaseSeries::createFitSccsModelArgs()
    )
    analysisToInclude <- bind_rows(analysisToInclude, data.frame(
      exposureId = comboCohortId,
      analysisId = length(sccsAnalysisList)
    ))
  }
}

message(sprintf("Created %d SCCS analyses", length(sccsAnalysisList)))

analysesToExclude <- expand.grid(
  exposureId = unique(analysisToInclude$exposureId),
  analysisId = unique(analysisToInclude$analysisId)
) %>%
  anti_join(analysisToInclude, by = join_by(exposureId, analysisId))

sccsAnalysesSpecifications <- SelfControlledCaseSeries::createSccsAnalysesSpecifications(
  sccsAnalysisList = sccsAnalysisList,
  exposuresOutcomeList = eoList,
  combineDataFetchAcrossOutcomes = FALSE,
  sccsDiagnosticThresholds = SelfControlledCaseSeries::createSccsDiagnosticThresholds(
    mdrrThreshold = 1000000000,
    easeThreshold = 0.25,
    timeTrendMaxRatio = 1.1,
    rareOutcomeMaxPrevalence = 0.1
  )
)

selfControlledModuleSpecifications <- sccsModuleSettingsCreator$createModuleSpecifications(
  sccsAnalysesSpecifications = sccsAnalysesSpecifications$toList()
)

# =============================================================================
# CREATE FINAL ANALYSIS SPECIFICATIONS
# =============================================================================
analysisSpecifications <- Strategus::createEmptyAnalysisSpecifications() |>
  Strategus::addSharedResources(cohortDefinitionShared) |> 
  Strategus::addSharedResources(negativeControlsShared) |>
  Strategus::addSharedResources(cohortIntersectionShared) |>
  Strategus::addModuleSpecifications(cohortGeneratorModuleSpecifications) |>
  Strategus::addModuleSpecifications(characterizationModuleSpecifications) |>
  Strategus::addModuleSpecifications(cohortIncidenceModuleSpecifications) |>
  Strategus::addModuleSpecifications(cohortMethodModuleSpecifications) |>
  Strategus::addModuleSpecifications(selfControlledModuleSpecifications) |>
  Strategus::addModuleSpecifications(cohortDiagnosticsModuleSpecifications)

ParallelLogger::saveSettingsToJson(
  analysisSpecifications, 
  file.path("inst", "fullStudyAnalysisSpecification.json")
)
# Also save the CohortAlgebra specifications separately for easy access
ParallelLogger::saveSettingsToJson(
  cohortIntersectionSpecifications,
  file.path("inst", "cohortAlgebraSpecifications.json")
)

# =============================================================================
# SUMMARY
# =============================================================================
message("")
message("=============================================================================")
message("=== SUMMARY ===")
message("=============================================================================")
message(sprintf("Total cohorts in definition set: %d", nrow(cohortDefinitionSet)))
message(sprintf("  - Single-drug cohorts (base): %d", nrow(group1_singles)))
message(sprintf("  - Combination cohorts: %d", nrow(comboCohorts)))
message("")
message("Target-Comparator Groups:")
message(sprintf("  - Group 1 (Singles): %d cohorts, %d pairs x 4 indications = %d TCIs", 
                nrow(group1_singles), nrow(singleDrugPairs), length(tcis)))
message(sprintf("  - Group 2 (MMF combos): %d cohorts, %d pairs", 
                nrow(group2_mmf_combos), nrow(group2_pairs)))
message(sprintf("  - Group 3 (MTX combos): %d cohorts, %d pairs", 
                nrow(group3_mtx_combos), nrow(group3_pairs)))
message(sprintf("  - Group 4 (AZA combos): %d cohorts, %d pairs", 
                nrow(group4_aza_combos), nrow(group4_pairs)))
message(sprintf("  - Group 5 (Pooled combos): %d cohorts, %d pairs", 
                nrow(group5_pooled_combos), nrow(group5_pairs)))
message("")
message(sprintf("CohortMethod TCOs: %d", length(targetComparatorOutcomesList)))
message(sprintf("  - Single-drug TCOs: %d (6 pairs x 4 indications)", length(tcis)))
message(sprintf("  - Combo TCOs: %d (%d unique pairs)", comboTCOCount, nrow(allComboPairs)))
message("")
message(sprintf("SCCS analyses: %d", length(sccsAnalysisList)))
message("")
message("Analysis specifications saved to inst/fullStudyAnalysisSpecification.json")
message("CohortAlgebra specifications saved to inst/cohortAlgebraSpecifications.json")
message("=============================================================================")
