#!/bin/bash
PWD=$(pwd)
CONFIG_FILE="${PWD}/.config"



source $CONFIG_FILE

base_datetime=$(date $date_format)
path_devices="${PWD}/$folder_devices/${base_datetime}"
path_backups="${PWD}/${folder_backups}"
header="date${delimeter}mission${delimeter}device_type${delimeter}device_status${delimeter}hash"


# Checks if should stop simulation
if [[ -f "${PWD}/sim_step.log" ]]
then 
    source "${PWD}/sim_step.log"
    ((sim_step+=1))
    echo "sim_step=${sim_step}" > "${PWD}/sim_step.log"
    if [[ $sim_step > $max_simulations ]] 
    then
        echo -e "\n... Reach maximum simulation steps. Ending simulation ..." 
        rm "${PWD}/sim_step.log" > /dev/null
        exit 0
    fi 
else 
    echo "sim_step=1" > "${PWD}/sim_step.log"
    echo -e "... Starting simulation ...\n"
fi
    

mkdir -p $path_devices > /dev/null
mkdir -p $path_backups > /dev/null

echo -e "\n... Requesting mission devices information ..."

file_num=$((RANDOM % (max_files - min_files + 1) + min_files))

echo "... Receiving data uptades from ${file_num} devices ..."

for i in $(seq 1 $file_num)
do 
    mission=${missions[$((RANDOM % ${#missions[@]}))]}
    
    if [[ "${mission}" == "UNKN" ]]
    then
        status="unknown"
        device="unknown"
        hash="unknown"
    else
        status=${statuses[$((RANDOM % ${#statuses[@]}))]}
        device=${devices[$((RANDOM % ${#devices[@]}))]}
        hash=$(echo "${base_datetime}${mission}${device}${status}${RANDOM}" | base64)
    fi 
    
    file_name="${path_devices}/APL${mission}-0000$i.log"
    file_content="${base_datetime}${delimeter}${mission}${delimeter}${device}${delimeter}${status}${delimeter}${hash}"

    echo -e $header > $file_name
    echo -e $file_content >> $file_name


done

echo "... Data received. Generating reports ..."

cd $path_devices

consolidated_report="APLSTATS-CONSOLIDATED-${base_datetime}.log"
event_analysis_report="APLSTATS-EVENTANALYSIS-${base_datetime}.log"
disconnections_report="APLSTATS-DISCONNECTIONS-${base_datetime}.log"
failures_report="APLSTATS-FAILURES-${base_datetime}.log"
percents_report="APLSTATS-PERCENTS-${base_datetime}.log"

csvstack $(ls) > $consolidated_report

csvsql --delimiter=$'\t' --query "
SELECT
    mission
    ,device_type
    ,device_status
    ,COUNT(*) AS num_events
FROM 
    events
GROUP BY 
    mission
    ,device_type
    ,device_status
" ${consolidated_report} --tables events > $event_analysis_report

csvsql --delimiter=$'\t' --query "
WITH DisconnectionEvents AS (
SELECT
    mission
    ,device_type
    ,COUNT(*) AS desc_events
FROM 
    events
WHERE
    device_status='unknown'
GROUP BY 
    mission
    ,device_type
)
SELECT
    d1.mission
    ,d1.device_type
    ,d1.desc_events
FROM
    DisconnectionEvents d1
WHERE 
    d1.desc_events=(SELECT MAX(d2.desc_events) FROM DisconnectionEvents d2 WHERE d1.mission=d2.mission);

" ${consolidated_report} --tables events > $disconnections_report

csvsql --delimiter=$'\t' --query "
SELECT
    mission
    ,COUNT(*) AS num_killed_devices
FROM 
    events
WHERE 
    device_status='killed'
GROUP BY
    mission
" ${consolidated_report} --tables events > $failures_report

csvsql --delimiter=$'\t' --query "
SELECT
    mission
    ,device_type
    ,ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM events),2)  AS percent_of_total_events
FROM 
    events
GROUP BY
    mission
    ,device_type
" ${consolidated_report} --tables events > $percents_report

cd $(pwd)/..
mv $path_devices $path_backups > /dev/null
cd ..

echo "... Reports generated and saved to back up. Refer to folder ${base_datetime} in ${path_backups} ..."

sleep $exec_rate

bash "${PWD}/Apolo-11.sh"