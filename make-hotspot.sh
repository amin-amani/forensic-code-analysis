#!/bin/sh
echo "vis.sh script has started..."
ls /home -la
echo " "
read -p "Enter the folder name: " foldername
git config --global --add safe.directory /home/"${foldername}"

firs_commit_date=$(cd /home/${foldername} &&  git log --reverse --format=%cd --date=short | head -n 1)

# Get the last commit date

last_commit_date=$(cd /home/${foldername} && git log -1 --format=%cd --date=short)

read -p "first commit date($firs_commit_date): " first_commit_date_input
#current_date=$(date '+%Y-%m-%d')

read -p "laste_commit_date(${last_commit_date}): " last_commit_date_input

if [ -z "$first_commit_date_input" ]; then

	first_commit_date_input=$firs_commit_date
fi

if [ -z "$last_commit_date_input" ]; then

	    last_commit_date_input=$last_commit_date

fi

echo "start from: $first_commit_date_input"

echo "to : $last_commit_date_input"

# Validate the date formats before running git log

if ! date -d "$firs_commit_date_input" "+%Y-%m-%d" >/dev/null 2>&1; then

     echo "Start date is invalid: $first_commit_date_input"
     exit 1

fi

if ! date -d "$last_commit_date_input" "+%Y-%m-%d" >/dev/null 2>&1; then
    echo "End date is invalid: $last_commit_date_input"
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
	git --no-pager log --pretty=format:'[%h] %an %ad %s' --date=short \
		--numstat --before=$last_commit_date_input --after=$first_commit_date_input > /home/result/git_evo.log && \
			cloc ./ --by-file --csv --quiet --report-file=/home/result/maat_lines.csv && \
			java -jar /usr/bin/maat -l /home/result/git_evo.log -c git -a revisions > /home/result/maat_freqs.csv
	
cd /home/result && \
	python3 /maat-scripts/transform/csv_as_enclosure_json.py --structure ./maat_lines.csv --weights ./maat_freqs.csv > output.json
cp /home/visualization/* -r /home/result 
