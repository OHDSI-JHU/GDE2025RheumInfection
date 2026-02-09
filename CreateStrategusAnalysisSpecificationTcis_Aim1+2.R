################################################################################
# INSTRUCTIONS: Make sure you have downloaded your cohorts using 
# DownloadCohorts.R and that those cohorts are stored in the "inst" folder
# of the project. This script is written to use the sample study cohorts
# located in "inst/sampleStudy" so you will need to modify this in the code 
# below. 
# 
# See the Create analysis specifications section
# of the UsingThisTemplate.md for more details.
# 
# More information about Strategus HADES modules can be found at:
# https://ohdsi.github.io/Strategus/reference/index.html#omop-cdm-hades-modules.
# This help page also contains links to the corresponding HADES package that
# further details.
# ##############################################################################
library(dplyr)
library(Strategus)

# Source the CohortAlgebraModule
source("CohortAlgebraModule.R")

########################################################
# Above the line - MODIFY ------------------------------
########################################################

# Get the list of cohorts - NOTE: you should modify this for your
# study to retrieve the cohorts you downloaded as part of
# DownloadCohorts.R
cohortDefinitionSet <- CohortGenerator::getCohortDefinitionSet(
  settingsFileName = "inst/Cohorts.csv",
  jsonFolder = "inst/cohorts",
  sqlFolder = "inst/sql/sql_server"
)


excludedCovariates_JAKi_IVIG = read.csv("inst/excludedCovariates_JAKi_IVIG.csv")
excludedCovariates_JAKi_MMF = read.csv("inst/excludedCovariates_JAKi_MMF.csv")
excludedCovariates_JAKi_RTX = read.csv("inst/excludedCovariates_JAKi_RTX.csv")
excludedCovariates_MMF_IVIG = read.csv("inst/excludedCovariates_MMF_IVIG.csv")
excludedCovariates_RTX_IVIG = read.csv("inst/excludedCovariates_RTX_IVIG.csv")
excludedCovariates_RTX_MMF = read.csv("inst/excludedCovariates_RTX_MMF.csv")
# Add excluded covariates for combo comparisons 
excludedCovariates_Union = read.csv("inst/excludedCovariates_Union.csv")


# =============================================================================
# Single-drug TCIs (singles vs singles only)
# =============================================================================
tcis <- list(
  # ---------------- SLE (1794240) ----------------
  list(targetId = 1794247, comparatorId = 1794245, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_JAKi_RTX$conceptId),
  list(targetId = 1794247, comparatorId = 1794244, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_RTX_MMF$conceptId),
  list(targetId = 1794247, comparatorId = 1794243, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_RTX_IVIG$conceptId),
  list(targetId = 1794245, comparatorId = 1794244, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_JAKi_MMF$conceptId),
  list(targetId = 1794245, comparatorId = 1794243, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_JAKi_IVIG$conceptId),
  list(targetId = 1794244, comparatorId = 1794243, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_MMF_IVIG$conceptId),
  
  # ---------------- Uveitis (1794239) ----------------
  list(targetId = 1794247, comparatorId = 1794245, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_JAKi_RTX$conceptId),
  list(targetId = 1794247, comparatorId = 1794244, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_RTX_MMF$conceptId),
  list(targetId = 1794247, comparatorId = 1794243, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_RTX_IVIG$conceptId),
  list(targetId = 1794245, comparatorId = 1794244, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_JAKi_MMF$conceptId),
  list(targetId = 1794245, comparatorId = 1794243, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_JAKi_IVIG$conceptId),
  list(targetId = 1794244, comparatorId = 1794243, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_MMF_IVIG$conceptId),
  
  # ---------------- SSc (1794241) ----------------
  list(targetId = 1794247, comparatorId = 1794245, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_JAKi_RTX$conceptId),
  list(targetId = 1794247, comparatorId = 1794244, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_RTX_MMF$conceptId),
  list(targetId = 1794247, comparatorId = 1794243, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_RTX_IVIG$conceptId),
  list(targetId = 1794245, comparatorId = 1794244, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_JAKi_MMF$conceptId),
  list(targetId = 1794245, comparatorId = 1794243, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_JAKi_IVIG$conceptId),
  list(targetId = 1794244, comparatorId = 1794243, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_MMF_IVIG$conceptId),
  
  # ---------------- DM (1794242) ----------------
  list(targetId = 1794247, comparatorId = 1794245, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_JAKi_RTX$conceptId),
  list(targetId = 1794247, comparatorId = 1794244, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_RTX_MMF$conceptId),
  list(targetId = 1794247, comparatorId = 1794243, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_RTX_IVIG$conceptId),
  list(targetId = 1794245, comparatorId = 1794244, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_JAKi_MMF$conceptId),
  list(targetId = 1794245, comparatorId = 1794243, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_JAKi_IVIG$conceptId),
  list(targetId = 1794244, comparatorId = 1794243, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_MMF_IVIG$conceptId)
)


# =============================================================================
# Combination cohort definitions (created by CohortAlgebraModule at runtime)
# =============================================================================
# These cohorts are created by intersecting pairs of single-drop cohorts.
# They need to be added to cohortDefinitionSet as "synthetic" entries.

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


comboCohorts <- data.frame(
  cohortId = c(1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009, 1010, 1011, 1012, 1013, 1014, 1015, 1016, 1017, 1018),
  cohortName = c(
    "MMF+RTX (Combination)",
    "MMF+IVIG (Combination)",
    "MMF+MTX (Combination)",
    "MMF+AZA (Combination)",
    "MMF+JAKi (Combination)",
    "MTX+IVIG	(Combination)",
    "MTX+MMF (Combination)",
    "MTX+AZA (Combination)",
    "MTX+RTX (Combination)",
    "MTX+JAKi	(Combination)",
    "AZA+IVIG	(Combination)",
    "AZA+MMF (Combination)",
    "AZA+MTX (Combination)",
    "AZA+RTX (Combination)",
    "AZA+JAKi (Combination)",
    "MMF or MTX or AZA + JAKi (Combination)",
    "MMF or MTX or AZA + RTX	(Combination)",
    "MMF or MTX or AZA + IVIG (Combination)"
  ),
  # These are CohortAlgebra combined cohorts - no JSON/SQL definition
  json = NA_character_,
  sql = NA_character_,
  stringsAsFactors = FALSE
)

# =============================================================================
# Combination TCIs (combos vs combos only)
# All pairwise comparisons among the combination cohorts
# NOTE: Combo cohorts don't need indication-based subsetting since they're 
# already intersection cohorts. We only create 3 unique pairs.
# =============================================================================
comboTcis <- list(
    # =============================================================================
    # GROUP 1: Cohorts 1001-1005 MMF Combos
    # =============================================================================
    
    # ---------------- SLE (1794240) ----------------
    list(targetId = 1001, comparatorId = 1002, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1001, comparatorId = 1003, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1001, comparatorId = 1004, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1001, comparatorId = 1005, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1002, comparatorId = 1003, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1002, comparatorId = 1004, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1002, comparatorId = 1005, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1003, comparatorId = 1004, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1003, comparatorId = 1005, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1004, comparatorId = 1005, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    
    # ---------------- Uveitis (1794239) ----------------
    list(targetId = 1001, comparatorId = 1002, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1001, comparatorId = 1003, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1001, comparatorId = 1004, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1001, comparatorId = 1005, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1002, comparatorId = 1003, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1002, comparatorId = 1004, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1002, comparatorId = 1005, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1003, comparatorId = 1004, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1003, comparatorId = 1005, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1004, comparatorId = 1005, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    
    # ---------------- SSc (1794241) ----------------
    list(targetId = 1001, comparatorId = 1002, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1001, comparatorId = 1003, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1001, comparatorId = 1004, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1001, comparatorId = 1005, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1002, comparatorId = 1003, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1002, comparatorId = 1004, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1002, comparatorId = 1005, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1003, comparatorId = 1004, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1003, comparatorId = 1005, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1004, comparatorId = 1005, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    
    # ---------------- DM (1794242) ----------------
    list(targetId = 1001, comparatorId = 1002, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1001, comparatorId = 1003, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1001, comparatorId = 1004, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1001, comparatorId = 1005, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1002, comparatorId = 1003, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1002, comparatorId = 1004, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1002, comparatorId = 1005, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1003, comparatorId = 1004, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1003, comparatorId = 1005, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1004, comparatorId = 1005, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    
    # =============================================================================
    # GROUP 2: Cohorts 1006-1010 MTX Combos
    # =============================================================================
    
    # ---------------- SLE (1794240) ----------------
    list(targetId = 1006, comparatorId = 1007, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1006, comparatorId = 1008, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1006, comparatorId = 1009, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1006, comparatorId = 1010, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1007, comparatorId = 1008, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1007, comparatorId = 1009, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1007, comparatorId = 1010, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1008, comparatorId = 1009, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1008, comparatorId = 1010, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1009, comparatorId = 1010, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    
    # ---------------- Uveitis (1794239) ----------------
    list(targetId = 1006, comparatorId = 1007, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1006, comparatorId = 1008, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1006, comparatorId = 1009, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1006, comparatorId = 1010, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1007, comparatorId = 1008, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1007, comparatorId = 1009, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1007, comparatorId = 1010, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1008, comparatorId = 1009, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1008, comparatorId = 1010, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1009, comparatorId = 1010, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    
    # ---------------- SSc (1794241) ----------------
    list(targetId = 1006, comparatorId = 1007, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1006, comparatorId = 1008, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1006, comparatorId = 1009, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1006, comparatorId = 1010, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1007, comparatorId = 1008, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1007, comparatorId = 1009, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1007, comparatorId = 1010, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1008, comparatorId = 1009, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1008, comparatorId = 1010, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1009, comparatorId = 1010, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    
    # ---------------- DM (1794242) ----------------
    list(targetId = 1006, comparatorId = 1007, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1006, comparatorId = 1008, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1006, comparatorId = 1009, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1006, comparatorId = 1010, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1007, comparatorId = 1008, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1007, comparatorId = 1009, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1007, comparatorId = 1010, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1008, comparatorId = 1009, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1008, comparatorId = 1010, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1009, comparatorId = 1010, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    
    # =============================================================================
    # GROUP 3: Cohorts 1011-1015 AZA Combos
    # =============================================================================
    
    # ---------------- SLE (1794240) ----------------
    list(targetId = 1011, comparatorId = 1012, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1011, comparatorId = 1013, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1011, comparatorId = 1014, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1011, comparatorId = 1015, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1012, comparatorId = 1013, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1012, comparatorId = 1014, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1012, comparatorId = 1015, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1013, comparatorId = 1014, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1013, comparatorId = 1015, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1014, comparatorId = 1015, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    
    # ---------------- Uveitis (1794239) ----------------
    list(targetId = 1011, comparatorId = 1012, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1011, comparatorId = 1013, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1011, comparatorId = 1014, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1011, comparatorId = 1015, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1012, comparatorId = 1013, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1012, comparatorId = 1014, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1012, comparatorId = 1015, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1013, comparatorId = 1014, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1013, comparatorId = 1015, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1014, comparatorId = 1015, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    
    # ---------------- SSc (1794241) ----------------
    list(targetId = 1011, comparatorId = 1012, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1011, comparatorId = 1013, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1011, comparatorId = 1014, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1011, comparatorId = 1015, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1012, comparatorId = 1013, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1012, comparatorId = 1014, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1012, comparatorId = 1015, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1013, comparatorId = 1014, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1013, comparatorId = 1015, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1014, comparatorId = 1015, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    
    # ---------------- DM (1794242) ----------------
    list(targetId = 1011, comparatorId = 1012, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1011, comparatorId = 1013, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1011, comparatorId = 1014, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1011, comparatorId = 1015, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1012, comparatorId = 1013, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1012, comparatorId = 1014, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1012, comparatorId = 1015, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1013, comparatorId = 1014, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1013, comparatorId = 1015, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1014, comparatorId = 1015, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),


    # =============================================================================
    # GROUP 4: Cohorts 1016-1018 (Your New Group Name)
    # =============================================================================
    
    # ---------------- SLE (1794240) ----------------
    list(targetId = 1016, comparatorId = 1017, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1016, comparatorId = 1018, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1017, comparatorId = 1018, indicationId = 1794240, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    
    # ---------------- Uveitis (1794239) ----------------
    list(targetId = 1016, comparatorId = 1017, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1016, comparatorId = 1018, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1017, comparatorId = 1018, indicationId = 1794239, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    
    # ---------------- SSc (1794241) ----------------
    list(targetId = 1016, comparatorId = 1017, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1016, comparatorId = 1018, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1017, comparatorId = 1018, indicationId = 1794241, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    
    # ---------------- DM (1794242) ----------------
    list(targetId = 1016, comparatorId = 1017, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1016, comparatorId = 1018, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId),
    list(targetId = 1017, comparatorId = 1018, indicationId = 1794242, genderConceptIds = c(8507, 8532), minAge = NULL, maxAge = NULL, excludedCovariateConceptIds = excludedCovariates_Union$conceptId)
    )

message(sprintf("Created %d combination TCI comparisons", length(comboTcis)))


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
  cleanWindow = c(
    365, 365, 365, 365,
    365, 365, 365, 9999, 30
  )
)

# Time-at-risks (TARs) for the outcomes of interest in your study
timeAtRisks <- tibble(
  label = c("On treatment", "On treatment"),
  riskWindowStart  = c(1, 1),
  startAnchor = c("cohort start", "cohort start"),
  riskWindowEnd  = c(0, 0),
  endAnchor = c("cohort end", "cohort end")
)
# Try to avoid intent-to-treat TARs for SCCS, or then at least disable calendar time spline:
# Note: SCCS uses 'era start'/'era end' anchors, not 'cohort start'/'cohort end'
sccsTimeAtRisks <- tibble(
  label = c("On treatment", "On treatment"),
  riskWindowStart  = c(1, 1),
  startAnchor = c("era start", "era start"),
  riskWindowEnd  = c(0, 0),
  endAnchor = c("era end", "era end")
)

# If you are not restricting your study to a specific time window, 
# please make these strings empty
studyStartDate <- '19000101' #YYYYMMDD
studyEndDate <- '20251231'   #YYYYMMDD
# Some of the settings require study dates with hyphens
studyStartDateWithHyphens <- gsub("(\\d{4})(\\d{2})(\\d{2})", "\\1-\\2-\\3", studyStartDate)
studyEndDateWithHyphens <- gsub("(\\d{4})(\\d{2})(\\d{2})", "\\1-\\2-\\3", studyEndDate)


# Consider these settings for estimation  ----------------------------------------

useCleanWindowForPriorOutcomeLookback <- FALSE # If FALSE, lookback window is all time prior, i.e., including only first events
psMatchMaxRatio <- 1 # If bigger than 1, the outcome model will be conditioned on the matched set
maxCohortSizeForFitting <- 250000 # Downsampled example study to 10000
maxCohortSize <- maxCohortSizeForFitting
maxCasesPerOutcome <- 1000000 # Downsampled example study to 10000

# Consider these settings for patient-level prediction  ----------------------------------------
plpMaxSampleSize <- 1000000 # Downsampled example study to 20000


# =============================================================================
# CohortAlgebraModule Settings - Cohort Intersection Pairs
# =============================================================================
# Load cohort intersection pairs from the CSV saved by DownloadCohorts.R
# Or define them directly here:

cohortAlgebraPairs <- CohortGenerator::readCsv(
  file = "inst/cohortAlgebraPairs.csv"
)

message(sprintf("Loaded %d cohort intersection pair(s) for CohortAlgebraModule", 
                nrow(cohortAlgebraPairs)))


########################################################
# Below the line - DO NOT MODIFY -----------------------
########################################################

# Don't change below this line (unless you know what you're doing) -------------

# =============================================================================
# Add combination cohorts to cohortDefinitionSet as synthetic entries
# =============================================================================
# These cohorts are created at runtime by CohortAlgebraModule, but we need
# them in cohortDefinitionSet so they can be used by downstream modules.

# Add minimal required columns for combo cohorts
for (i in 1:nrow(comboCohorts)) {
  newRow <- data.frame(
    cohortId = comboCohorts$cohortId[i],
    cohortName = comboCohorts$cohortName[i],
    json = NA_character_,
    sql = NA_character_,
    stringsAsFactors = FALSE
  )
  # Add any other columns that exist in cohortDefinitionSet with NA values
  missingCols <- setdiff(names(cohortDefinitionSet), names(newRow))
  for (col in missingCols) {
    newRow[[col]] <- NA
  }
  # Reorder columns to match
  newRow <- newRow[, names(cohortDefinitionSet)]
  cohortDefinitionSet <- rbind(cohortDefinitionSet, newRow)
}

message(sprintf("Added %d combination cohorts to cohortDefinitionSet (total: %d cohorts)", 
                nrow(comboCohorts), nrow(cohortDefinitionSet)))


# Shared Resources -------------------------------------------------------------

# Get the unique subset criteria from the tcis object (singles only)
# to construct the cohortDefinitionSet's subset definitions
dfUniqueTcis <- data.frame()
for (i in seq_along(tcis)) {
  dfUniqueTcis <- rbind(dfUniqueTcis, data.frame(cohortId = tcis[[i]]$targetId,
                                                 indicationId = paste(tcis[[i]]$indicationId, collapse = ","),
                                                 genderConceptIds = paste(tcis[[i]]$genderConceptIds, collapse = ","),
                                                 minAge = paste(tcis[[i]]$minAge, collapse = ","),
                                                 maxAge = paste(tcis[[i]]$maxAge, collapse = ",")
  ))
  if (!is.null(tcis[[i]]$comparatorId)) {
    dfUniqueTcis <- rbind(dfUniqueTcis, data.frame(cohortId = tcis[[i]]$comparatorId,
                                                   indicationId = paste(tcis[[i]]$indicationId, collapse = ","),
                                                   genderConceptIds = paste(tcis[[i]]$genderConceptIds, collapse = ","),
                                                   minAge = paste(tcis[[i]]$minAge, collapse = ","),
                                                   maxAge = paste(tcis[[i]]$maxAge, collapse = ",")
    ))
  }
}

# Also add combo cohorts to dfUniqueTcis for subsetting
for (i in seq_along(comboTcis)) {
  dfUniqueTcis <- rbind(dfUniqueTcis, data.frame(cohortId = comboTcis[[i]]$targetId,
                                                 indicationId = paste(comboTcis[[i]]$indicationId, collapse = ","),
                                                 genderConceptIds = paste(comboTcis[[i]]$genderConceptIds, collapse = ","),
                                                 minAge = paste(comboTcis[[i]]$minAge, collapse = ","),
                                                 maxAge = paste(comboTcis[[i]]$maxAge, collapse = ",")
  ))
  if (!is.null(comboTcis[[i]]$comparatorId)) {
    dfUniqueTcis <- rbind(dfUniqueTcis, data.frame(cohortId = comboTcis[[i]]$comparatorId,
                                                   indicationId = paste(comboTcis[[i]]$indicationId, collapse = ","),
                                                   genderConceptIds = paste(comboTcis[[i]]$genderConceptIds, collapse = ","),
                                                   minAge = paste(comboTcis[[i]]$minAge, collapse = ","),
                                                   maxAge = paste(comboTcis[[i]]$maxAge, collapse = ",")
    ))
  }
}

dfUniqueTcis <- unique(dfUniqueTcis)
dfUniqueTcis$subsetDefinitionId <- 0 # Adding as a placeholder for loop below
dfUniqueSubsetCriteria <- unique(dfUniqueTcis[,-1])

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
    name = "",
    definitionId = i,
    subsetOperators = subsetOperators
  )
  
  # Only apply subset to cohorts that exist in cohortDefinitionSet AND are not combo cohorts
  # (combo cohorts don't have JSON/SQL definitions so can't be subsetted via CohortGenerator)
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
    # Also create restricted version of indication cohort:
    subsetDef <- CohortGenerator::createCohortSubsetDefinition(
      name = "",
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

negativeControlOutcomeCohortSet <- CohortGenerator::readCsv(
  file = "inst/negativeControlOutcomes.csv"
)

if (any(duplicated(cohortDefinitionSet$cohortId, negativeControlOutcomeCohortSet$cohortId))) {
  stop("*** Error: duplicate cohort IDs found ***")
}


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


# CohortGeneratorModule --------------------------------------------------------

cgModuleSettingsCreator <- CohortGeneratorModule$new()

# Exclude combo cohorts from cohortDefinitionShared - they don't have json/sql definitions
# and are created by CohortAlgebraModule at runtime
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


# CohortDiagnosticsModule Settings ---------------------------------------------
cdModuleSettingsCreator <- CohortDiagnosticsModule$new()

# Exclude combo cohorts AND any cohorts without valid json definitions
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


# CharacterizationModule Settings ---------------------------------------------
cModuleSettingsCreator <- CharacterizationModule$new()

# Include both single and combo cohorts (exclude outcomes)
allCohortIdsExceptOutcomes <- cohortDefinitionSet %>%
  filter(!cohortId %in% outcomes$cohortId) %>%
  pull(cohortId)

# Create outcomeWashoutDays vector matching the length of outcomeIds
# Using the cleanWindow values from the outcomes tibble
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


# CohortIncidenceModule Settings -----------------------------------------------
ciModuleSettingsCreator <- CohortIncidenceModule$new()

# Build the target list based on unique T's / TC's (singles + combos)
irTargetList <- list()
for (i in 1:nrow(dfUniqueTcis)) {
  tci <- dfUniqueTcis[i,]
  
  # Check if this is a combo cohort (no subset needed) or a single cohort (needs subset lookup)
  if (tci$cohortId %in% comboCohorts$cohortId) {
    # Combo cohorts use their ID directly (subsetting happens in CohortAlgebra)
    cohortId <- tci$cohortId
    cohortName <- comboCohorts$cohortName[comboCohorts$cohortId == tci$cohortId]
  } else {
    # Single cohorts - look up the subsetted version
    cohortIdLookup <- cohortDefinitionSet %>% 
      filter(subsetParent == tci$cohortId & subsetDefinitionId == tci$subsetDefinitionId)
    
    if (nrow(cohortIdLookup) == 0) next  # Skip if not found
    
    cohortId <- cohortIdLookup %>% pull(cohortId)
    cohortName <- cohortIdLookup %>% pull(cohortName)
  }
  
  irTargetList[[length(irTargetList)+1]] <- CohortIncidence::createCohortRef(
    id = cohortId,
    name = cohortName
  )
}

# Build the outcome list based on the outcomes specification
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

# Build analyses list based on targets, outcomes, TARs
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


# CohortMethodModule Settings --------------------------------------------------
cmModuleSettingsCreator <- CohortMethodModule$new()

covariateSettings <- FeatureExtraction::createDefaultCovariateSettings(
  addDescendantsToExclude = TRUE
)

# Create outcome list (outcomes of interest + negative controls)
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
# Build TCOs list for SINGLES
# =============================================================================
targetComparatorOutcomesList <- list()
for (i in seq_along(tcis)) {
  tci <- tcis[[i]]
  # Get the subset definition ID that matches the target ID
  currentSubsetDefinitionId <- dfUniqueTcis %>%
    filter(cohortId == tci$targetId &
             indicationId == paste(tci$indicationId, collapse = ",") &
             genderConceptIds == paste(tci$genderConceptIds, collapse = ",") &
             minAge == paste(tci$minAge, collapse = ",") &
             maxAge == paste(tci$maxAge, collapse = ",")) %>%
    pull(subsetDefinitionId)
  targetId <- cohortDefinitionSet %>%
    filter(subsetParent == tci$targetId & subsetDefinitionId == currentSubsetDefinitionId) %>%
    pull(cohortId)
  comparatorId <- cohortDefinitionSet %>% 
    filter(subsetParent == tci$comparatorId & subsetDefinitionId == currentSubsetDefinitionId) %>%
    pull(cohortId)
  targetComparatorOutcomesList[[length(targetComparatorOutcomesList) + 1]] <- CohortMethod::createTargetComparatorOutcomes(
    targetId = targetId,
    comparatorId = comparatorId,
    outcomes = outcomeList,
    excludedCovariateConceptIds = tci$excludedCovariateConceptIds
  )
}

# =============================================================================
# Build TCOs list for COMBOS
# NOTE: Combo cohorts are NOT subsetted by indication (unlike singles), so we
# only need UNIQUE target/comparator pairs. The comboTcis list has the same 
# pairs repeated for each indication, which would cause duplicates.
# =============================================================================
addedComboPairs <- data.frame(targetId = integer(), comparatorId = integer())

for (i in seq_along(comboTcis)) {
  comboTci <- comboTcis[[i]]
  
  # Check if this target/comparator pair has already been added
  alreadyAdded <- any(
    addedComboPairs$targetId == comboTci$targetId & 
    addedComboPairs$comparatorId == comboTci$comparatorId
  )
  
  if (!alreadyAdded) {
    targetComparatorOutcomesList[[length(targetComparatorOutcomesList) + 1]] <- CohortMethod::createTargetComparatorOutcomes(
      targetId = comboTci$targetId,
      comparatorId = comboTci$comparatorId,
      outcomes = outcomeList,
      excludedCovariateConceptIds = comboTci$excludedCovariateConceptIds
    )
    # Track this pair as added
    addedComboPairs <- rbind(addedComboPairs, data.frame(
      targetId = comboTci$targetId,
      comparatorId = comboTci$comparatorId
    ))
  }
}

message(sprintf("Added %d unique combo TCOs (from %d comboTcis with indication variations)", 
                nrow(addedComboPairs), length(comboTcis)))

message(sprintf("Created %d target-comparator-outcome combinations", length(targetComparatorOutcomesList)))

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
  allowReverseMatch = FALSE,
  stratificationColumns = c()
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

# Build CM analyses - one per time-at-risk
cmAnalysisList <- list()
for (i in seq_len(nrow(timeAtRisks))) {
  createStudyPopArgs <- CohortMethod::createCreateStudyPopulationArgs(
    firstExposureOnly = FALSE,
    washoutPeriod = 0,
    removeDuplicateSubjects = "keep first",
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
    createStudyPopArgs = createStudyPopArgs,
    createPsArgs = createPsArgs,
    matchOnPsArgs = matchOnPsArgs,
    computeSharedCovariateBalanceArgs = computeSharedCovariateBalanceArgs,
    computeCovariateBalanceArgs = computeCovariateBalanceArgs,
    fitOutcomeModelArgs = fitOutcomeModelArgs
  )
}

message(sprintf("Created %d CohortMethod analyses", length(cmAnalysisList)))

# Create CM diagnostic thresholds
cmDiagnosticThresholds <- CohortMethod::createCmDiagnosticThresholds(
  mdrrThreshold = Inf,
  easeThreshold = 0.3,
  sdmThreshold = 0.2,
  equipoiseThreshold = 0.15,
  attritionFractionThreshold = NULL,
  generalizabilitySdmThreshold = 1
)

cohortMethodModuleSpecifications <- cmModuleSettingsCreator$createModuleSpecifications(
  cmAnalysisList = cmAnalysisList,
  targetComparatorOutcomesList = targetComparatorOutcomesList,
  analysesToExclude = NULL,
  refitPsForEveryOutcome = FALSE,
  refitPsForEveryStudyPopulation = TRUE,
  cmDiagnosticThresholds = cmDiagnosticThresholds
)


# SelfControlledCaseSeriesModule Settings --------------------------------------
sccsModuleSettingsCreator <- SelfControlledCaseSeriesModule$new()

eoList <- list()

# =============================================================================
# Build SCCS exposures-outcomes for SINGLES
# =============================================================================
uniqueTargetIds <- unique(unlist(lapply(tcis, function(x) { c(x$targetId, x$comparatorId) })))

# Add exposureId column to dfUniqueTcis before the loop
dfUniqueTcis$exposureId <- NA_integer_

for (i in 1:nrow(dfUniqueTcis)) {
  tci <- dfUniqueTcis[i,]
  
  # Skip combo cohorts in this loop (they're handled separately)
  if (tci$cohortId %in% comboCohorts$cohortId) next
  
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

# =============================================================================
# Build SCCS exposures-outcomes for COMBOS
# =============================================================================
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

createStudyPopulationArgs <- SelfControlledCaseSeries::createCreateStudyPopulationArgs(
  firstOutcomeOnly = !useCleanWindowForPriorOutcomeLookback,
  naivePeriod = 365,
  minAge = 18
)

createSccsIntervalDataArgs <- SelfControlledCaseSeries::createCreateSccsIntervalDataArgs(
  eraCovariateSettings = SelfControlledCaseSeries::createEraCovariateSettings(
    includeEraIds = "exposureId",
    endAnchor = "era end",
    stratifyById = FALSE,
    exposureOfInterest = TRUE,
    label = "Main"
  )
)

fitSccsModelArgs <- SelfControlledCaseSeries::createFitSccsModelArgs()

# =============================================================================
# Build SCCS analyses for SINGLES
# =============================================================================
sccsAnalysisList <- list()
analysisToInclude <- data.frame()

for (i in 1:nrow(dfUniqueTcis)) {
  tci <- dfUniqueTcis[i,]
  
  # Skip combo cohorts
  if (tci$cohortId %in% comboCohorts$cohortId) next
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
      fitSccsModelArgs = fitSccsModelArgs
    )
    analysisToInclude <- bind_rows(analysisToInclude, data.frame(
      exposureId = tci$exposureId,
      analysisId = length(sccsAnalysisList)
    ))
  }
}

# =============================================================================
# Build SCCS analyses for COMBOS
# =============================================================================
for (comboCohortId in comboCohorts$cohortId) {
  comboName <- comboCohorts$cohortName[comboCohorts$cohortId == comboCohortId]
  
  for (j in seq_len(nrow(sccsTimeAtRisks))) {
    # Combo cohorts use default demographic settings (no indication-based subsetting 
    # because they're already intersection cohorts)
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
      fitSccsModelArgs = fitSccsModelArgs
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

# Convert R6 → plain list before handing to Strategus
selfControlledModuleSpecifications <- sccsModuleSettingsCreator$createModuleSpecifications(
  sccsAnalysesSpecifications = sccsAnalysesSpecifications$toList()
)


# Create the analysis specifications ------------------------------------------
# NOTE: CohortAlgebra shared resources are included here but the actual
# intersection execution happens in StrategusCodeToRun.R after CohortGenerator

analysisSpecifications <- Strategus::createEmptyAnalysisSpecifications() |>
  Strategus::addSharedResources(cohortDefinitionShared) |> 
  Strategus::addSharedResources(negativeControlsShared) |>
  Strategus::addSharedResources(cohortIntersectionShared) |>  # CohortAlgebra specs
  Strategus::addModuleSpecifications(cohortGeneratorModuleSpecifications) |>
  # NOTE: CohortAlgebraModule is executed separately after Strategus::execute()
  # because it needs the cohorts to be generated first
  #Strategus::addModuleSpecifications(cohortDiagnosticsModuleSpecifications) |>
  Strategus::addModuleSpecifications(characterizationModuleSpecifications) |>
  Strategus::addModuleSpecifications(cohortIncidenceModuleSpecifications) |>
  Strategus::addModuleSpecifications(cohortMethodModuleSpecifications) |>
  Strategus::addModuleSpecifications(selfControlledModuleSpecifications)

ParallelLogger::saveSettingsToJson(
  analysisSpecifications, 
  file.path("inst", "fullStudyAnalysisSpecification.json")
)

# Also save the CohortAlgebra specifications separately for easy access
ParallelLogger::saveSettingsToJson(
  cohortIntersectionSpecifications,
  file.path("inst", "cohortAlgebraSpecifications.json")
)

message("")
message("=== SUMMARY ===")
message(sprintf("Total cohorts in definition set: %d", nrow(cohortDefinitionSet)))
message(sprintf("  - Single-drug cohorts: %d", nrow(cohortDefinitionSet) - nrow(comboCohorts)))
message(sprintf("  - Combination cohorts: %d", nrow(comboCohorts)))
message(sprintf("Single TCIs: %d", length(tcis)))
message(sprintf("Combo TCIs: %d", length(comboTcis)))
message(sprintf("CohortMethod analyses: %d", length(cmAnalysisList)))
message(sprintf("SCCS analyses: %d", length(sccsAnalysisList)))
message("")
message("Analysis specifications saved to inst/fullStudyAnalysisSpecification.json")

message("CohortAlgebra specifications saved to inst/cohortAlgebraSpecifications.json")

