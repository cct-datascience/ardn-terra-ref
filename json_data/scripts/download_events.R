###### Read in libraries ######
library(jsonlite)

###### Specify study IDs ######
studies <- c(6000000010, 6000000034)

###### Download, reformat, and save JSON file for each study ######
base_url <- Sys.getenv("BASEURL")
if(is.null(base_url)){
  base_url <- "https://terraref.org" 
}

events_base_url <- paste0(base_url, "/brapi/v1/events")

for(study in studies){
  events_url <- paste0(events_base_url, "?studyDbId=", study)
  events_list <- fromJSON(events_url)
  events_json <- list(studyDbId = as.character(study), data = events_list)
  events_json_final <- list(events = list(events_json))
  write(toJSON(events_json_final, pretty = TRUE, auto_unbox = TRUE),
        file = paste0("events_", study, ".json"))
}
