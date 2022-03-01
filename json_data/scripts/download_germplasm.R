###### Read in libraries ######
library(jsonlite)

###### Specify study IDs ######
studies <- c(6000000010, 6000000034)

###### Download, reformat, and save JSON file for each study ######
base_url <- Sys.getenv("BASEURL")
if(is.null(base_url)){
  base_url <- "https://terraref.org"
}
germplasm_base_url <- paste0(base_url, "/brapi/v1/studies")

#https://brapi.workbench.terraref.org/brapi/v1/studies/$studyID/germplasm


for(study in studies){
  germplasm_url <- paste0(germplasm_base_url, "/", study, "/germplasm")
  germplasm_list <- fromJSON(germplasm_url)
  germplasm_json <- list(studyDbId = as.character(study), data = germplasm_list)
  germplasm_json_final <- list(germplasms = list(germplasm_json))
  write(toJSON(germplasm_json_final, pretty = TRUE, auto_unbox = TRUE),
        file = paste0("germplasm_", study, ".json"))
}
