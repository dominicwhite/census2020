<template>
  <l-map 
    ref="map"
    :center="center" 
    :zoom="zoom"
    style="height: 500px;" 
    :options="mapOptions"
    >
    <l-control-attribution
      position="bottomright"
      prefix='Built by: 
      <a href="https://www.datakind.org/chapters/datakind-dc" target="_blank">DataKind DC</a> 
      &amp; 
      <a href="https://www.motivf.com/" target="_blank">Motivf</a> 
      | 
      Map tiles by Carto, under CC BY 3.0. 
      Data by OpenStreetMap, under ODbL.'
      >
        
      </l-control-attribution>
    <l-choropleth-layer 
      :data="pyDepartmentsData" 
      title-key="GIDBG_name" 
      id-key="GIDBG" 
      :value="value" 
      :extra-values="extraValues" 
      geojson-id-key="GEOID" 
      :geojson="geojson" 
      :color-scale="colorScale">
      <template slot-scope="props">
        <l-info-control 
          :item="props.currentItem"
          :unit="props.unit"
          title="Block Group"
          placeholder="Hover over a block group"
          position="topright">
        </l-info-control>
        <l-reference-chart 
          title="% Hispanic" 
          :color-scale="colorScale" 
          :min="props.min" 
          :max="props.max" position="bottomleft">
        </l-reference-chart>
      </template>
    </l-choropleth-layer>
    <l-tile-layer :url="url">
    </l-tile-layer>
  </l-map>
</template>

<script>
import { LMap, LControlAttribution, LTileLayer } from 'vue2-leaflet';
import { InfoControl, ReferenceChart, ChoroplethLayer } from 'vue-choropleth';

export default {
  name: 'LeafletMap',
  components: {
    LMap,
    LControlAttribution,
    LTileLayer,
    'l-info-control': InfoControl, 
    'l-reference-chart': ReferenceChart, 
    'l-choropleth-layer': ChoroplethLayer,
  },
  data() {
    return {
      url: 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/rastertiles/voyager/{z}/{x}/{y}.png',
      map: false,
      zoom: 12,
      bounds: [],

      center: [38.9145, -77.045992],
      pyDepartmentsData: [],
      geojson: {type:"FeatureCollection", features:[]},
      colorScale: [
        "313695", 
        "4575b4", 
        "74add1", 
        "abd9e9", 
        "e0f3f8", 
        "fee090", 
        "fdae61", 
        "f46d43", 
        "d73027", 
        "a50026"
        ],
      value: {
          key: "pct_Hispanic_CEN_2010",
          metric: "% Hispanic (2010 census)"
      },
      extraValues: [{
          key: "pct_Hispanic_ACS_13_17",
          metric: "% Hispanic (2017 ACS)"
      }],
      mapOptions: {
          attributionControl: false
      }
    };
  },
  methods: {
    zoomUpdated (zoom) {
      this.zoom = zoom;
    },
    centerUpdated (center) {
      this.center = center;
    },
    boundsUpdated (bounds) {
      this.bounds = bounds;
    }
  },
  mounted() {
    const boundaries = fetch('data/dc_polygons.json')
      .then(response => response.json())
      .then(data => {
        this.geojson = data;
      });
    const stats = fetch('data/dc_data.json')
      .then(response => response.json())
      .then(data => {
        this.pyDepartmentsData = data;
      });
    this.$nextTick(() => {
      this.map = this.$refs.map.mapObject;
    });
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="less">

</style>
