###### Read in libraries ######
library(jsonlite)

###### Specify study and variable IDs ######
studies <- c(6000000010, 6000000034)
vars <- c(6000000238, 6000000278, 6000000236, 6000000007, 6000000200,
          6000000196, 6000000193)

###### Download JSON file for each study/variable combo ######
base_url <- Sys.getenv("BASEURL")
if(is.null(base_url)){
  base_url <- "https://terraref.org"
}

obs_base_url <- paste0(base_url, "/brapi/v1/observationunits")


for(study in studies){
  observations_json <- list()
  for(var in vars){
    pagesize_url <- paste0(obs_base_url, "?studyDbId=", study,
                           "&observationVariableDbId=", var, "&pageSize=2")
    pagesize_download <- fromJSON(pagesize_url)
    pagesize_count <- pagesize_download$metadata$pagination$totalCount
    if (pagesize_count != 0) {
      observation_url <- paste0(obs_base_url, "?studyDbId=", study,
                         "&observationVariableDbId=", var, "&pageSize=", pagesize_count)
      observation_list <- fromJSON(observation_url)
      observation_json <- list(studyDbId = as.character(study),
                               observationVariableDbId = as.character(var),
                               data = observation_list)
    }
    observations_json <- append(observations_json, list(observation_json))
    observations_json_final <- list(observed = observations_json)
  }
  write(toJSON(observations_json_final, auto_unbox = TRUE),
        file = paste0("observations_", study, ".json"))
}
