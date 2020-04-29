for studyID in 6000000010 6000000034
do
    curl --insecure -o study_$studyID.json https://brapi.workbench.terraref.org/brapi/v1/studies/$studyID
done