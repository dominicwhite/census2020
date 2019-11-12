# Static Data files

### dc_planning_database_subset.csv

The subset of planning database variables was generated from the Block Group Planning Database available on the Census Bureau website: https://www.census.gov/topics/research/guidance/planning-databases.html

The data was first filtered to just rows for just the District of Columbia (FIPS code 11) and then filtered for columns of interest. 

For example, the current version was generated with:

```bash
awk -vFPAT='[^,]*|"[^"]*"' '{ if ($2 == 11) { print } }' pdb2019bgv3_us.csv >> dc_blockgroups.csv

awk -vFPAT='[^,]*|"[^"]*"' '{ print $1 "," $2 "," $3 "," $4 "," $5 "," $6 "," $7 "," $8 "," $9 "," $10 "," $11 "," $12 "," $13 "," $14 "," $15 "," $32 "," $35 "," $38 "," $41 "," $47 "," $50 "," $53 "," $56 "," $59 "," $67 "," $69 "," $91 "," $93 "," $95 "," $97 "," $99 "," $187 "," $188 "," $205 "," $208 "," $211 "," $214 "," $219 "," $220 "," $222 "," $223 "," $225 "," $226 "," $228 "," $229 "," $231 "," $232 "," $234 "," $235 "," $237 "," $238 "," $264 "," $266 "," $268 "," $270 "," $272 }' dc_blockgroups.csv > dc_planning_database_subset.csv
```

### hofstede-6-dimensions-0-100.csv

Contains measurements of Hofstede's 6 Cultural Dimensions for a range of countries.
