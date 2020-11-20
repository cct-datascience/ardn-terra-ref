###### Read in libraries ######
library(jsonlite)

###### Specify study IDs ######
studies <- c(6000000010, 6000000034)

###### Download, reformat, and save JSON file for each study ######
study_base_url <- "https://brapi.workbench.terraref.org/brapi/v1/studies"

for(study in studies){
  study_url <- paste0(study_base_url, "/", study)
  study_list <- fromJSON(study_url)
  study_json <- list(studyDbId = as.character(study), data = study_list)
  study_json_final <- list(studies = list(study_json))
  write(toJSON(study_json_final, pretty = TRUE, auto_unbox = TRUE), 
        file = paste0("study_", study, ".json"))
}
