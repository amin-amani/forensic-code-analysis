# forensic-code-analysis

forensic code analysis based on "Your code as a crime scene"

## build hotspot from your project

copy your project nearby docker-compose.yaml or use git to clone it

```
git clone https://github.com/hibernate/hibernate-orm.git
git checkout $(git rev-list -n 1 --before="2013-09-05" main)

```

run below command to make hotspots. this command should create result folder with json html and some csv files

```
docker-compose run --rm -it make-hotspot
```
input project name in commandline

## navigate hotspots
```
docker-compose up  display-hotspot
```
after using this command open your browser and navigate to this url:
```
http://127.0.0.1:8888/hotspot.html
```



# Generate a Version-Control Log 
```
git log --pretty=format:'[%h] %an %ad %s' --date=short \
--numstat --before=2013-09-05 --after=2012-01-01 > hib_evo.log
```
```
maat -l hib_evo.log -c git -a revisions > maat_freqs.csv
cloc ./ --by-file --csv --quiet --report-file=maat_lines.csv
python3 ../maat-scripts/transform/csv_as_enclosure_json.py --structure ./maat_lines.csv --weights maat_fre
qs.csv > output.csv

```


```
docker-compose run --rm -it make_hotspot 
```
```
 python3 -m http.server 8888
```

