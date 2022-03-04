###### Read in libraries ######
library(jsonlite)
library(dplyr)
library(tidyr)

###### Set constants ######
base_url <- "https://brapi.workbench.terraref.org/brapi/v1/"
studies <- c("6000000010", "6000000034")
var_ids <- c("6000000196", "6000000012")

###### Table 2: Observations (FieldObs) ######
get_observations <- function(var_id, study_id) {
  var_url <- paste0(base_url, "observationunits", "?", "observationVariableDbId=", 
                    var_id, "&", "studyDbId=", study_id)
  var_json <- fromJSON(var_url)
  var_df <- var_json$result$data %>% 
    unnest(observations) %>% 
    unnest(treatments) %>% 
    select(observationunitDbId, observationVariableName, value, germplasmName, observationTimeStamp, studyDbId, observationUnitName) %>% 
    rename(!!.$observationVariableName[1] := value, 
           !!paste0("time_stamp_", .$observationVariableName[1]) := observationTimeStamp) %>% 
    select(-observationVariableName)
  return(var_df)
}

biomass_obs <- get_observations(var_ids[1], studies[1])
cover_obs <- get_observations(var_ids[2], studies[1])
obs_table <- left_join(biomass_obs, cover_obs, by = c("observationUnitName", 
                                                      "observationunitDbId", 
                                                      "germplasmName", 
                                                      "studyDbId")) %>%
  relocate(studyDbId, observationUnitName, observationunitDbId, germplasmName, 
           starts_with("time_stamp_"))

###### Table 2: Studies (Metadata) ######
studies_url <- paste0(base_url, "studies")
studies_all <- fromJSON(studies_url)
studies_table <- studies_all$result$data %>% 
  filter(studyDbId %in% studies)
studies_table$latitude <- studies_table$location$latitude
studies_table$longitude <- studies_table$location$longitude
studies_table$description <- studies_table$statisticalDesign$description
studies_table <- studies_table %>% 
  select(studyDbId, startDate, endDate, latitude, longitude, description)



###### Table 3: Germplasm (no analog) ######
germplasms_table <- c()
for (study in studies) {
  germplasm_url <- paste0(base_url, "studies/", study[1], "/germplasm")
  germplasm_json <- fromJSON(germplasm_url)
  germplasm_table <- germplasm_json$result$data %>% 
    select(germplasmDbId, germplasmName, genus, species, subtaxa, commonCropName)
  germplasms_table <- bind_rows(germplasm_table, germplasms_table)
}

###### Table 4: Events (Fertilizer) ######
events_table <- c()
for (study in studies) {
  event_url <- paste0(base_url, "events?studyDbId=", study)
  event_json <- fromJSON(event_url)
  event_table <- event_json$result$data %>% 
    unnest(eventParameters) %>% 
    unnest(eventParameters) %>% 
    pivot_wider(names_from = key, values_from = value) %>% 
    unnest(observationUnitDbIds) %>% 
    select(-eventDbId) %>% 
    relocate(observationUnitDbIds, studyDbId)
  events_table <- bind_rows(event_table, events_table)
}

###### Save tables ######
tables <- c("obs_table", "studies_table", "germplasms_table", "events_table")
for (table in tables) {
  file_name <- paste0("csv_data/data/", table, ".csv")
  write.csv(eval(as.symbol(table)), file = file_name, 
            row.names = FALSE)
}
