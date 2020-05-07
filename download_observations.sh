for studyID in 6000000010 6000000034
do
    curl --insecure -o observations_$studyID.json https://brapi.workbench.terraref.org/brapi/v1/observationunits?studyDbId=$studyID&observationVariableDbId=6000000196
done