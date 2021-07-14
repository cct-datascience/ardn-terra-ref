###### Read in libraries ######
library(jsonlite)

###### Specify study IDs ######
studies <- c(6000000010, 6000000034)

###### Download and save JSON file for each endpoint and study ######
base_url <- "https://terraref.org" 

events_base_url <- paste0(base_url, "/brapi/v1/events")
for(study in studies){
  events_url <- paste0(events_base_url, "?studyDbId=", study)
  events_list <- fromJSON(events_url)
  write(toJSON(events_list, pretty = TRUE, auto_unbox = TRUE), 
        file = paste0("raw_brapi_json/events_", study, ".json"))
}

study_base_url <- paste0(base_url, "/brapi/v1/studies")
for(study in studies){
  study_url <- paste0(study_base_url, "/", study)
  study_list <- fromJSON(study_url)
  write(toJSON(study_list, pretty = TRUE, auto_unbox = TRUE),
        file = paste0("raw_brapi_json/study_", study, ".json"))
}

germplasm_base_url <- paste0(base_url, "/brapi/v1/studies")
for(study in studies){
  germplasm_url <- paste0(germplasm_base_url, "/", study, "/germplasm")
  germplasm_list <- fromJSON(germplasm_url)
  write(toJSON(germplasm_list, pretty = TRUE, auto_unbox = TRUE),
        file = paste0("raw_brapi_json/germplasm_", study, ".json"))
}

vars <- c(6000000238, 6000000278, 6000000236, 6000000007, 6000000200,
          6000000196, 6000000193)
obs_base_url <- paste0(base_url, "/brapi/v1/observationunits")
for(study in studies){
  observations_json <- c()
  for(var in vars){
    pagesize_url <- paste0(obs_base_url, "?studyDbId=", study,
                           "&observationVariableDbId=", var, "&pageSize=2")
    pagesize_download <- fromJSON(pagesize_url)
    pagesize_count <- pagesize_download$metadata$pagination$totalCount
    print(pagesize_count)
    if (pagesize_count != 0) {
      observation_url <- paste0(obs_base_url, "?studyDbId=", study,
                                "&observationVariableDbId=", var, "&pageSize=", pagesize_count)
      observation_list <- fromJSON(observation_url)
    }
    observations_json <- append(observations_json, observation_list)
  }
  write(toJSON(observations_json, pretty = TRUE, auto_unbox = TRUE),
        file = paste0("raw_brapi_json/observations_", study, ".json"))
}
