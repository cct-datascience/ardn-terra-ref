## Code to query data from TERRA REF from BrAPI for the ARDN Project 

Learn more about ARDN https://agmip.github.io/ARDN/

To run in R console:

If developing the API on your computer, make sure to set the base_url. By 
default it will point to [terraref.org](https://terraref.org)

```R
#Sys.setenv(BASEURL='https://terraref.org')
Sys.setenv(BASEURL='http://localhost:5000')
source('download_studies.R')
source('download_germplasm.R')
source('download_observations.R')
```
