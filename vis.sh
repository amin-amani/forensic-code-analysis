#!/bin/sh
echo "vis.sh script has started..."
ls -la
echo " "
read -p "Enter the folder name: " foldername
if [ -d "${foldername}" ]; then
	    ls "${foldername}"
    else
	        echo "Folder '${foldername}' does not exist."
fi
git config --global --add safe.directory /home/"${foldername}"
mkdir -p /home/result
cd /home/"${foldername}" && \
git log --pretty=format:'[%h] %an %ad %s' --date=short \
	--numstat --before=2013-09-05 --after=2012-01-01 > /home/result/hib_evo.log


