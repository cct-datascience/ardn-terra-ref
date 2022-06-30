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
    mutate(observationTimeStamp = substr(observationTimeStamp, 1, 10), 
           studyDbId = case_when(studyDbId == 6000000034 ~ "TERRAREF-----S4", 
                                 studyDbId == 6000000010 ~ "TERRAREF-----S6"))
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
  relocate(studyDbId, observationunitDbId, germplasmName, observationTimeStamp) %>% 
  mutate_all(list(~replace_na(., "")))

###### Table 2: Studies (Metadata) ######
studies_url <- paste0(base_url, "studies")
studies_all <- fromJSON(studies_url)
studies_table <- studies_all$result$data %>% 
  filter(studyDbId %in% studies)
studies_table$latitude <- studies_table$location$latitude
studies_table$longitude <- studies_table$location$longitude
studies_table$description <- studies_table$statisticalDesign$description
studies_table <- studies_table %>% 
  mutate(studyDbId = case_when(studyDbId == 6000000034 ~ "TERRAREF-----S4", 
                               studyDbId == 6000000010 ~ "TERRAREF-----S6")) %>% 
  select(studyDbId, startDate, endDate, latitude, longitude, description) %>% 
  mutate_all(list(~replace_na(., "")))

###### Table 3: Germplasm (no analog) ######
germplasms_table <- c()
for (study in studies) {
  germplasm_url <- paste0(base_url, "studies/", study[1], "/germplasm")
  germplasm_json <- fromJSON(germplasm_url)
  germplasm_table <- germplasm_json$result$data %>% 
    select(germplasmDbId, germplasmName, commonCropName)
  germplasms_table <- bind_rows(germplasm_table, germplasms_table) %>% 
    mutate_all(list(~replace_na(., "")))
}

###### Table 4: Events (Fertilizer) ######
events_url <- "https://raw.githubusercontent.com/terraref/brapi/master/data/events.json"
events_json <- fromJSON(events_url)

eventParameters_cols <- c("code", "name", "description", "unit", "...1", "value", 
                          "valueDescription", "valuesByDate", "description")
`%!in%` <- Negate(`%in%`)

events_table <- c()
for(i in 1:nrow(events_json)){
  print(i)
  events_table_ind <- events_json %>% 
    slice(i) %>% 
    mutate(eventParameters = na_if(eventParameters, "NULL")) %>% 
    unnest_wider(eventParameters) %>% 
    unnest(any_of(eventParameters_cols)) %>% 
    unpack(cols = c(date))
  events_table_ind$discreteDates[sapply(events_table_ind$discreteDates, is.null)] <- NA
  if("discreteDates" %in% colnames(events_table_ind) & 
     "valuesByDate" %!in% colnames(events_table_ind)){
    events_table_ind <- events_table_ind %>%
      unnest(discreteDates)
  }
  if("valuesByDate" %in% colnames(events_table_ind)){
    events_table_ind <- events_table_ind %>%
      unnest(cols = c(discreteDates, valuesByDate))
  }
  if(class(events_table_ind$discreteDates) == "list"){
    events_table_ind$discreteDates <- unlist(events_table_ind$discreteDates)
  }
  events_table_ind <- events_table_ind %>% 
    unnest(observationUnitDbIds)
  if("value" %in% colnames(events_table_ind)){
    events_table_ind$value <- lapply(events_table_ind$value, as.character)

  }
  if("valueDescription" %in% colnames(events_table_ind)){
    events_table_ind$valueDescription <- lapply(events_table_ind$valueDescription, as.character)
  }
  if("description" %in% colnames(events_table_ind)){
    events_table_ind$description <- lapply(events_table_ind$description, as.character)

  }
  events_table <- bind_rows(events_table_ind, events_table)
}

events_table <- events_table %>%
  mutate(value = as.character(value)) %>% 
  mutate(valueDescription = as.character(valueDescription)) %>% 
  mutate(description = as.character(description)) %>% 
  mutate_all(~na_if(., "NULL")) %>% 
  select(-...16) %>% 
  select(!c(eventDbId, endDate, name, unit, valueDescription, description)) %>% 
  unite("value", c(value, valuesByDate), na.rm = TRUE) %>% 
  mutate(value = replace(value, value == "", NA)) %>% 
  unite(date, c(discreteDates, startDate), na.rm = TRUE) %>% 
  mutate(row = row_number()) %>% 
  pivot_wider(names_from = code, values_from = value) %>% 
  select(-row) %>% 
  mutate(studyDbId = case_when(studyDbId == 6000000034 ~ "TERRAREF-----S4", 
                               studyDbId == 6000000010 ~ "TERRAREF-----S6")) %>% 
  mutate_all(list(~replace_na(., "")))

###### Save tables ######
tables <- c("obs_table", "studies_table", "germplasms_table")
for (table in tables) {
  file_name <- paste0("csv_data/data/", table, ".csv")
  write.csv(eval(as.symbol(table)), file = file_name, 
            row.names = FALSE)
}
readr::write_csv(events_table, "csv_data/data/events_table.csv.gz")
