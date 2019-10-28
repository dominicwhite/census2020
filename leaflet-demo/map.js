
var map = L.map('map').setView([38.9145, -77.045992], 12);
L.geoJson(dcPolygons).addTo(map);