# |  (C) 2008-2025 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of MAgPIE and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  MAgPIE License Exception, version 1.0 (see LICENSE file).
# |  Contact: magpie@pik-potsdam.de

##########################################################
#### MAgPIE output generation ####
##########################################################

library(gms)
source("scripts/start_functions.R")

version   <- "v1"

### Scenario 1: SSP1 ─────────────────────────────────────────────────────────
source("config/default.cfg")
cfg <- setScenario(cfg, c("SSP2", "NDC", "AR-natveg", "nocc_hist"))
cfg$gms$c56_mute_ghgprices_until <- "y2030"
scenario_config <- read.csv2("./scenario_config_magpie_UPTAKE.csv")

# Select the scenario
scenario <- "SSP2-PkBudg650"

# Find the column
row_index <- which(scenario_config[,"title"] == scenario)

# Update cfg$gms with settings from the selected scenario
for(i in 1:ncol(scenario_config)) {
  param <- names(scenario_config)[i]
  if(grepl("^cfg_mag", param)) {
    param_name <- sub("^cfg_mag.gms.", "", param)
    value <- scenario_config[row_index, i]
    if(!is.na(value) && value != "") {
      cfg$gms[[param_name]] <- value
    }
  }
}
# cfg <- setScenario(cfg,"noAR",scenario_config="./scenario_config_mUPTAKE.csv")

# OPEN-PROM soft-coupling via env-vars. If OPENPROM_COUPLING_MIF is set, wire
# the MAgPIE coupling channels (c56_pollutant_prices, c60_2ndgen_biodem) to the
# mif produced by postprom/R/couplePromWithMagpie.R::couplePromToMagpie().
openprom_mif      <- Sys.getenv("OPENPROM_COUPLING_MIF",      unset = "")
openprom_scenario <- Sys.getenv("OPENPROM_COUPLING_SCENARIO", unset = "SSP2-PkBudg650")
openprom_ghg      <- Sys.getenv("OPENPROM_COUPLING_GHG",      unset = "on")
openprom_bio      <- Sys.getenv("OPENPROM_COUPLING_BIOENERGY", unset = "on")
if (nzchar(openprom_mif)) {
  message(sprintf("[openprom-coupling] using mif: %s (scenario=%s, ghg=%s, bio=%s)",
                  openprom_mif, openprom_scenario, openprom_ghg, openprom_bio))
  if (tolower(openprom_ghg) == "on") {
    cfg$path_to_report_ghgprices  <- openprom_mif
    cfg$gms$c56_pollutant_prices  <- "coupling"
  }
  if (tolower(openprom_bio) == "on") {
    cfg$path_to_report_bioenergy  <- openprom_mif
    cfg$gms$c60_2ndgen_biodem     <- "coupling"
  }
}

cfg$title <- "noAR"
start_run(cfg = cfg, codeCheck = FALSE)