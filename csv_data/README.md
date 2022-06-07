### Pipeline

| Step                         | Input data                 | Output data              | Processing tool                      |
|------------------------------|----------------------------|--------------------------|--------------------------------------|
| Reformatting raw data        | TERRA REF BrAPI JSONs      | TERRA REF BrAPI csvs     | R script                             |
| Mapping ICASA variables      | TERRA REF BrAPI csvs       | SC2                      | VMapper                              |
| Getting ICASA-compliant data | TERRA REF BrAPI csvs + SC2 | AgMIP csv                | VMapper (AgMIP input package button) |
| Generating model input files | AgMIP csv + DOME + linkage | DSSAT files + ACEB .aceb | QuadUI                               |
| Running model                | DSSAT input file           | DSSAT output files       | Compiled DSSAT                       |

### List of TERRA REF BrAPI csvs & linking keys

1. obs_table
2. studies_table
3. germplasms_table
4. events_table

- obs_table <-> studies_table: studyDbId
- obs_table <-> events_table: observationunitDbId/observationUnitDbIds
- obs_table <-> germplasms_table: germplasmName
