###### Read in libraries ######
library(jsonlite)

###### Specify study and variable IDs ######
studies <- c(6000000010, 6000000034)
vars <- c(6000000238, 6000000278, 6000000236, 6000000007, 6000000200, 
          6000000196, 6000000193)

###### Download JSON file for each study/variable combo ######
obs_base_url <- "https://brapi.workbench.terraref.org/brapi/v1/observationunits"

for(study in studies){
  for(var in vars){
    pagesize_url <- paste0(obs_base_url, "?studyDbId=", study, 
                           "&observationVariableDbId=", var, "&pageSize=2")
    pagesize_download <- fromJSON(pagesize_url)
    pagesize_count <- pagesize_download$metadata$pagination$totalCount
    if (pagesize_count != 0) {
      full_url <- paste0(obs_base_url, "?studyDbId=", study,
                         "&observationVariableDbId=", var, "&pageSize=", pagesize_count)
      full_download <- fromJSON(full_url)
      write(toJSON(full_download), file = paste0(paste("observations", study, var, sep = "_"), ".json"))
    }
  }
}
