#!/bin/sh
echo "vis.sh script has started..."
ls /home -la
echo " "
read -p "Enter the folder name: " foldername
git config --global --add safe.directory /home/"${foldername}"
end_date=$(cd /home/${foldername} &&  git log --reverse --format=%cd --date=short | head -n 1)

# Get the last commit date

start_date=$(cd /home/${foldername} && git log -1 --format=%cd --date=short)

read -p "start date(${start_date}): " start_date
#current_date=$(date '+%Y-%m-%d')

read -p "end date(${end_date}): " end_date

if [ -z "$start_date" ]; then

	    start_date=$start_date

fi

if [ -z "$end_date" ]; then

	    end_date=$end_date

fi

echo "Using Start date: $start_date"

echo "Using End date: $end_date"

# Validate the date formats before running git log

if ! date -d "$start_date" "+%Y-%m-%d" >/dev/null 2>&1; then

     echo "Start date is invalid: $start_date"
     exit 1

fi

if ! date -d "$end_date" "+%Y-%m-%d" >/dev/null 2>&1; then
    echo "End date is invalid: $end_date"
    exit 1

fi

if [ -d "/home/${foldername}" ]; then
	    ls "/home/${foldername}"
    else
	        echo "Folder '/home/${foldername}' does not exist."
fi


#git config --global --add safe.directory /home/"${foldername}"
mkdir -p /home/result
cd /home/"${foldername}" && \
	git log --pretty=format:'[%h] %an %ad %s' --date=short \
		--numstat --before=$end_date --after=$start_date > /home/result/git_evo.log && \
			cloc ./ --by-file --csv --quiet --report-file=/home/result/maat_lines.csv && \
				maat -l /home/result/git_evo.log -c git -a revisions > /home/result/maat_freqs.csv
	
cd /home/result && \
	python3 /app/maat-scripts/transform/csv_as_enclosure_json.py --structure ./maat_lines.csv --weights ./maat_freqs.csv > output.json
cp /home/visualization/* -r /home/result 
