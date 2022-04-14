###### Read in libraries ######
library(jsonlite)
library(dplyr)
library(tidyr)

###### Set constants ######
base_url <- "https://brapi.workbench.terraref.org/brapi/v1/"
studies <- c("6000000010", "6000000034")
var_ids <- c("6000000196", "6000000007", "6000000354")

###### Table 2: Observations (FieldObs) ######
get_observations <- function(var_id, study_id) {
  pagesize_url <- paste0(base_url, "observationunits", "?studyDbId=", study_id,
                         "&observationVariableDbId=", var_id, "&pageSize=2")
  pagesize_download <- fromJSON(pagesize_url)
  pagesize_count <- pagesize_download$metadata$pagination$totalCount
  var_url <- paste0(base_url, "observationunits", "?", "observationVariableDbId=", 
                    var_id, "&", "studyDbId=", study_id, "&pageSize=", pagesize_count)
  var_json <- fromJSON(var_url)
  var_df <- var_json$result$data %>% 
    unnest(observations) %>% 
    unnest(treatments) %>% 
    select(observationunitDbId, observationVariableName, value, germplasmName, 
           observationTimeStamp, studyDbId, observationUnitName) %>% 
    rename(!!.$observationVariableName[1] := value) %>% 
    select(-observationVariableName, -observationUnitName) %>% 
    mutate(observationTimeStamp = substr(observationTimeStamp, 1, 10))
  return(var_df)
}

var_obs_list <- c()
for(var in var_ids){
  var_obs <- c()
  for(study in studies){
    tryCatch({
      study_var_obs <- get_observations(var, study)
      var_obs <- rbind(study_var_obs, var_obs)
    }, error = function(e) e)
  }
  var_obs_list[[var]] <- var_obs
}
obs_table <- var_obs_list %>% purrr::reduce(full_join, by = c("observationunitDbId", 
                                                         "germplasmName", 
                                                         "studyDbId", 
                                                         "observationTimeStamp")) %>%
  relocate(studyDbId, observationunitDbId, germplasmName, observationTimeStamp)

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
