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

###


* `raw_brapi_data`: directly from terraref endpoints
* `json_data/` slightly modified using scripts in `json_data/scripts`
* `azmet`: contains daily weather data

### 

### Convert to ACE-B

#### Install QuadUI

~~Download QuadUI from https://github.com/agmip/quadui/releases~~

Download most recent version of QuadUI from https://github.com/MengZhang/quadui/releases

#### Run QuadUI

```psl
set PATH=C:\Program Files (x86)\Java\jre1.8.0_301\bin;%PATH%
cd C:\Users\David\Downloads\QuadUI_v1.3.9-beta22
.\QUADUI.BAT
```

command line (to get help)

```psl
java -help quadui-1.3.9-beta22.jar

java quadui-1.3.9-beta22.jar  -cli -help

java -jar quadui-1.3.9-beta22.jar  -cli -DJ -f dome_filename.csv
```

#### Load files


## TODO

* API
    * [ ] finish events.json
    * [ ] review schema and terms _w/ ICASA folk_
    * update BrAPI events.py to use above
* Running DSSAT 
    * configure DOME file for s4 and s6
    * see if we have irrigation rates somewhere (like from the PEG project)
    * update mappings
        * study --> EXNAME
        * treatment --> TRT_NAME
        * planting date --> PDATE
        * yield --> CWAH
        * harvest date --> HADAT
    * generate DSSAT inputs
    * cultivars: convert date to GDD to phenology phase
    * weather file
    * soil file