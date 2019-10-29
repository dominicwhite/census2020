console.log(dcStats);

var map = L.map('map', {
    atttribution: "Leaflet | DataKindDC"
}).setView([38.9145, -77.045992], 12);

L.tileLayer('https://cartodb-basemaps-{s}.global.ssl.fastly.net/rastertiles/voyager/{z}/{x}/{y}.png', {
	attribution: 'DataKind DC',
	maxZoom: 18
}).addTo(map);

function getColor(d) {
	return d > 90 ? '#a50026' :
	       d > 80 ? '#d73027' :
	       d > 70 ? '#f46d43' :
	       d > 60 ? '#fdae61' :
	       d > 50 ? '#fee090' :
	       d > 40 ? '#e0f3f8' :
	       d > 30 ? '#abd9e9' :
	       d > 20 ? '#74add1' :
	       d > 10 ? '#4575b4' :
	                '#313695';
}

function style(feature) {
    console.log(feature);
	return {
		fillColor: getColor(dcStats[feature.properties.GEOID]["pct_Hispanic_ACS_13_17"]),
		weight: 2,
		opacity: 1,
		color: 'white',
		dashArray: '3',
		fillOpacity: 0.7
	};
}

L.geoJson(dcPolygons, {style: style}).addTo(map);