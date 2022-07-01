## Harmonizing and modeling BrAPI TERRA REF data

This repository contains code, data, and intermediate files for harmonizing [BrAPI TERRA REF data]() into the ARDN format and running it through the DSSAT model. This data modeling pipeline is outlined below. 

Learn more about this project at the ARDN website here: https://agmip.github.io/ARDN/

### Pipeline

| **Step**                        | **Input data**                                    | **Output data**                                                                                                                                                                                                 | **Output data location**                    | **Processing tool**                                                                                                                                                                                         |
|---------------------------------|---------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1. Reformatting raw data        | TERRA REF JSONs from BrAPI                        | [TERRA REF BrAPI csvs](https://github.com/cct-datascience/ardn-terra-ref/tree/master/csv_data/data)                                                                                                             | `csv_data` folder                           | [R script](https://github.com/cct-datascience/ardn-terra-ref/blob/master/csv_data/scripts/download_and_convert.R)                                                                                           |
| 2. Mapping ICASA variables      | TERRA REF BrAPI csvs                              | [SC2](https://github.com/cct-datascience/ardn-terra-ref/tree/master/dssat_files/sc2.json)                                                                                                                       | `dssat_files` folder                        | [VMapper](https://vmapper.herokuapp.com/tools/vmapper#)                                                                                                                                                     |
| 3. Getting ICASA-compliant data | TERRA REF BrAPI csvs + SC2                        | [AgMIP zip](https://github.com/cct-datascience/ardn-terra-ref/tree/master/dssat_files/AgMIP_Input.zip)                                                                                                          | `dssat_files` folder                        | VMapper (AgMIP input package button)                                                                                                                                                                        |
| 4. Get model-specific files     |                                                   | [DOME + linkage files](https://github.com/cct-datascience/ardn-terra-ref/tree/master/dssat_files/DOME)                                                                                                          | `dssat_files/DOME`  folder                  | Hand-written based on [DOME template](https://github.com/agmip/json-translation-samples/blob/master/Maize_Machakos/raw/Field_Overlay-Machakos-MAZ.xlsx) & [linkage info](https://agmip.github.io/DOME.html) |
| 5. Generating model input files | AgMIP zip + DOME + linkage                        | [DSSAT files](https://github.com/cct-datascience/ardn-terra-ref/tree/master/dssat_files/dssat_input) + [ACEB .aceb](https://github.com/cct-datascience/ardn-terra-ref/tree/master/dssat_files/AgMIP_Input.aceb) | `dssat_files/dssat_input` and `dssat_files` | [Data Factory](http://vmapper-test.herokuapp.com/tools/data_factory#)                                                                                                                                       |
| 6. Running model                | DSSAT input files + cultivar, weather, soil files | DSSAT output files                                                                                                                                                                                              | `dssat_files/dssat_input` folder            | Compiled DSSAT                                                                                                                                                                                              |

#### Diagram mapping pipeline steps

![](README_images/ARDN_workflows.jpg)

### Repository file structure

- `csv_data/`
  - `scripts/download_and_convert.R`: script downloads raw BrAPI TERRA REF JSON data from 4 endpoints (observationunits, studies, germplasm, and events) and converts to required csv format
  - `data/`: contains converted csv data files
    - `studies_table.csv`
    - `obs_table.csv`
    - `germplasms_table.csv`
    - `events_table.csv.gz`
  - `mvp/`: (obsolete) contains older versions of converted BrAPI TERRA REF JSON files
- `dssat_files/`
  - `sc2.json`: sidecar file that maps csv files with [AgMIP ICASA variables](https://docs.google.com/spreadsheets/u/0/d/1MYx1ukUsCAM1pcixbVQSu49NU-LfXg-Dtt-ncLBzGAM/pub?output=html)
  - `AgMIP_Input.zip`: resulting csv file from apply sidecar to data csv files
  - `DOME/`
    - `Field_Overlay_s4.csv`: DSSAT-specific DOME file that contributes additional required inputs to run model
    - `LINKAGE_s4_v2.csv`: DDSAT-specific linkage file that enables DOME file to be used
  - `AgMIP_Input.aceb`: ACEB-format file
  - `dssat_input.zip`
  - `dssat_input/`: generated from above zip file; contains DSSAT-specific input files and model run output files; many files, only including ones that are used
    - `DSSBatch.v48`
    - `TERRAR01.SGX`
    - `Summary.OUT`
- `raw_brapi_json/`: (obsolete) contains R script for converting raw TERRA REF JSON files into format needed by collaborator, and resulting .json files
- `json_data/scripts`: (obsolete) contains R scripts for converting raw TERRA REF JSON files into format needed by collaborator

### Keys for TERRA REF BrAPI csvs

1. obs_table
2. studies_table
3. germplasms_table
4. events_table

- obs_table <-> studies_table: studyDbId
- obs_table <-> events_table: observationunitDbId/observationUnitDbIds
- obs_table <-> germplasms_table: germplasmName

![](README_images/ARDN_tables_relational_diagram.jpg)
