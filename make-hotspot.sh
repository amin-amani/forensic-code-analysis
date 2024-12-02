#!/bin/sh
echo "vis.sh script has started..."
ls /home -la
echo " "
read -p "Enter the folder name: " foldername
read -p "start date(1900-01-01): " start_date

read -p "end date(3000-01-01): " end_date

if [ -z "$start_date" ]; then

	    start_date="1900-01-01"

fi

if [ -z "$end_date" ]; then

	    end_date="3000-01-01"

fi


if [ -d "/home/${foldername}" ]; then
	    ls "/home/${foldername}"
    else
	        echo "Folder '/home/${foldername}' does not exist."
fi
git config --global --add safe.directory /home/"${foldername}"
mkdir -p /home/result
cd /home/"${foldername}" && \
git log --pretty=format:'[%h] %an %ad %s' --date=short \
	--numstat --before=2025-09-05 --after=2000-01-01 > /home/result/git_evo.log && \
	cloc ./ --by-file --csv --quiet --report-file=/home/result/maat_lines.csv && \
	maat -l /home/result/git_evo.log -c git -a revisions > /home/result/maat_freqs.csv
	
cd /home/result && \
python3 /app/maat-scripts/transform/csv_as_enclosure_json.py --structure ./maat_lines.csv --weights ./maat_freqs.csv > output.json
cp /home/visualization/* -r /home/result 
