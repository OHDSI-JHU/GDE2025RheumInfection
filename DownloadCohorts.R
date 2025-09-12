################################################################################
# INSTRUCTIONS: This script assumes you have cohorts you would like to use in an
# ATLAS instance. Please note you will need to update the baseUrl to match
# the settings for your enviroment. You will also want to change the 
# CohortGenerator::saveCohortDefinitionSet() function call arguments to identify
# a folder to store your cohorts. This code will store the cohorts in 
# "inst/sampleStudy" as part of the template for reference. You should store
# your settings in the root of the "inst" folder and consider removing the 
# "inst/sampleStudy" resources when you are ready to release your study.
# 
# See the Download cohorts section
# of the UsingThisTemplate.md for more details.
# ##############################################################################

library(dplyr)
baseUrl <- "https://atlas-demo.ohdsi.org/WebAPI"
# Use this if your WebAPI instance has security enables
# ROhdsiWebApi::authorizeWebApi(
#   baseUrl = baseUrl,
#   authMethod = "windows"
# )
# ---- inputs ---------------------------------------------------------------
baseUrl  <- Sys.getenv("WEBAPI")   # <- or set a literal URL

# ---- export from WebAPI ---------------------------------------------------
cohortDefinitionSet <- ROhdsiWebApi::exportCohortDefinitionSet(
  baseUrl       = baseUrl,
  cohortIds     = c(
    1791985, # pneumocystis pneumonia (Total)
    1792492, # pneumocystis pneumonia (Case1)
    1792493, # pneumocystis pneumonia (Case2)
    1792494, # pneumocystis pneumonia (Case3)
    1791944, # varicella zoster (Sensitive)
    1791945, # varicella zoster (Specific)
    1792481, # varicella zoster (New)
    1792205, # PML
    1793889, # Hospitalized Infection
    1794247, # rituximab exposures
    1794245, # JAKi exposures
    1794244, # MMF exposures
    1794243, # IVIG exposures
    1794239, # Uveitis
    1794240, # SLE
    1794241, # SSc
    1794242  # DM
  ),
  generateStats = TRUE
)

# ---- rename cohorts to match your preferred labels ------------------------
name_map <- list(
  `1791985` = "pneumocystis pneumonia (Total)",
  `1792492` = "pneumocystis pneumonia (Case1)",
  `1792493` = "pneumocystis pneumonia (Case2)",
  `1792494` = "pneumocystis pneumonia (Case3)",
  `1791944` = "varicella zoster (Sensitive)",
  `1791945` = "varicella zoster (Specific)",
  `1792481` = "varicella zoster (New)",
  `1792205` = "PML",
  '1793889' = "Hospitalized Infection",
  `1794247` = "rituximab exposures",
  `1794245` = "JAKi exposures",
  `1794244` = "MMF exposures",
  `1794243` = "IVIG exposures",
  `1794239` = "Uveitis",
  `1794240` = "SLE",
  `1794241` = "SSc",
  `1794242` = "DM"
)

cohortDefinitionSet$atlasId <- cohortDefinitionSet$cohortId  # keep original ATLAS IDs
for (i in seq_len(nrow(cohortDefinitionSet))) {
  atlas_id <- as.character(cohortDefinitionSet$atlasId[i])
  if (atlas_id %in% names(name_map)) {
    cohortDefinitionSet$cohortName[i] <- name_map[[atlas_id]]
  }
}

# ---- re-number cohorts sequentially (1..N) --------------------------------
cohortDefinitionSet$cohortId <- seq_len(nrow(cohortDefinitionSet))

# ---- save cohort definition set -------------------------------------------
CohortGenerator::saveCohortDefinitionSet(
  cohortDefinitionSet = cohortDefinitionSet,
  settingsFileName    = "inst/sampleStudy/Cohorts.csv",
  jsonFolder          = "inst/sampleStudy/cohorts",
  sqlFolder           = "inst/sampleStudy/sql/sql_server"
)


# Download and save the negative control outcomes
library(purrr)

# List of concept IDs you provided
conceptIds <- c(
  439935,443585,199192,4088290,4092879,75911,137951,73241,45757682,81878,
  4216219,133655,134765,73560,434327,81378,432303,4201390,434675,134438,
  78619,76786,436077,377910,4115402,45757370,433111,433527,4170770,437448,
  4092896,374801,259995,4096540,439788,40481632,4168318,433577,4231770,
  4012570,4012934,374375,4344500,40481897,139099,444132,4265896,432593,
  434203,438329,4027782,433997,4051630,258540,432798,4103703,439795,
  4209423,377572,40480893,136368,438130,4299094,4091513,437092,433951,
  4202045,439790,81634,380706,141932,4019836,36713918,443172,81151,72748,
  432436,378427,437264,433244,436876,440612,4201387,45757285,140641,4115367,440193
)

# Fetch concept details for each conceptId
negativeControlOutcomeCohortSet <- map_dfr(seq_along(conceptIds), function(i) {
  cid <- conceptIds[i]
  df <- ROhdsiWebApi::getConcepts(
    conceptIds = cid,
    baseUrl = baseUrl
  )
  df %>%
    rename(outcomeConceptId = conceptId,
           cohortName = conceptName) %>%
    mutate(cohortId = i + 100) %>%
    select(cohortId, cohortName, outcomeConceptId)
})

# Save to CSV
CohortGenerator::writeCsv(
  x = negativeControlOutcomeCohortSet,
  file = "inst/sampleStudy/negativeControlOutcomes.csv",
  warnOnFileNameCaseMismatch = FALSE
)
