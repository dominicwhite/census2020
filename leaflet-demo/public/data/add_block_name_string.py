import json

with open("leaflet-demo/public/data/dc_data.json", "r") as dcjson:
    j = json.load(dcjson)

print(j[0])

for bg in j:
    bg["GIDBG_name"] = str(bg["GIDBG"])

print(j[0])

with open("leaflet-demo/public/data/dc_data.json", "w") as dcjson:
    json.dump(j, dcjson)