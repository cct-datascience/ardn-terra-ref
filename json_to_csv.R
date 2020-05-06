library(jsonlite)
library(dplyr)

base_url <- "https://brapi.workbench.terraref.org/brapi/v1/"

# Isolate one season
seasons_url <- paste0(base_url, 
                      "seasons")
seasons <- fromJSON(seasons_url)
season_ids <- seasons$result$data %>% 
  filter(season == "MAC Season 4" | season == "MAC Season 6") %>% 
  select(season, seasonDbId)
season_id <- season_ids$seasonDbId[1]

# Isolate one study from that season
studies <- fromJSON("https://brapi.workbench.terraref.org/brapi/v1/studies")
study <- studies$result$data %>% 
  filter(purrr::map_lgl(seasons, ~ all(season_id %in% .x))) %>% 
  slice(1)

# Variable 1: location
c(study$location$latitude, study$location$longitude)

# Variable 3: planting date
study$startDate

# Variable 4: harvest date
study$endDate

species_url <- paste0(base_url, "studies/", study$studyDbId, "/germplasm")
species <- fromJSON(species_url)

# Variable 2: species
paste(unique(species$result$data$genus), unique(species$result$data$species))

# biomass values for one plot
plot_ex <- "MAC%20Field%20Scanner%20Season%204%20Range%2013%20Column%2011"

dry_biomass_id <- 6000000196
dry_biomass_url <- paste0(base_url, "observationunits", "?", 
                           "observationVariableDbId=", dry_biomass_id, "&", 
                           "observationUnitDbId=", plot_ex)
dry_biomass_json <- fromJSON(dry_biomass_url)
dry_biomass_observations <- dry_biomass_json$result$data$observations[[1]] %>% 
  distinct(observationDbId, .keep_all = TRUE)
dry_biomass_df <- data.frame(latitude = study$location$latitude, 
                             longitude = study$location$longitude, 
                             startDate = study$startDate, 
                             endDate = study$endDate, 
                             species = paste(unique(species$result$data$genus), unique(species$result$data$species)), 
                             aboveground_dry_biomass = dry_biomass_observations$value)

# Variable 5: yield
dry_biomass_observations$value

# Save data as CSV
write.csv(dry_biomass_df, file = "ardn_mvp.csv")
