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
    <l-control id="voi-selector" position="bottomleft" style="margin-bottom: 25%;">
      <select v-model="voi">
        <option value="pct_ENG_VW_SPAN_ACS_13_17">% Spanish language households</option>
        <option value="pct_ENG_VW_INDOEURO_ACS_13_17">% Indo-European language households</option>
        <option value="pct_ENG_VW_API_ACS_13_17">% Asian/Pacific language households</option>
        <option value="pct_ENG_VW_OTHER_ACS_13_17">% Other (non-English) language housholds</option>
        <!-- <option value="pct_Hispanic_ACS_13_17">% Hispanic</option> -->
      </select>
    </l-control>
    <l-choropleth-layer 
      :data="blockGroupData" 
      title-key="GIDBG_name" 
      id-key="GIDBG" 
      :value="value" 
      :extra-values="extraValues" 
      geojson-id-key="GEOID" 
      :geojson="geojson" 
      :color-scale="colorScale"
      :key="voi" 
      >
      <!-- Note: key in l-chloropleth-layer is needed for reactive update to change in value -->
      <template slot-scope="props">
        <l-info-control 
          :item="props.currentItem"
          :unit="props.unit"
          title="Block Group"
          placeholder="Hover over a block group"
          position="topright">
        </l-info-control>
        <l-reference-chart 
          id="voi-color-reference"
          :title="value.metric" 
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
import { LMap, LControl, LControlAttribution, LTileLayer } from 'vue2-leaflet';
import { InfoControl, ReferenceChart, ChoroplethLayer } from 'vue-choropleth';

export default {
  name: 'LeafletMap',
  components: {
    LMap,
    LControl,
    LControlAttribution,
    LTileLayer,
    'l-info-control': InfoControl, 
    'l-reference-chart': ReferenceChart, 
    'l-choropleth-layer': ChoroplethLayer,
  },
  computed: {
    value(){
      return {
          key: this.voi,
          metric: this.displayVariables[this.voi]
      }
    },
    extraValues() {
      let ev = [];
      for (let variable in this.displayVariables){
        if (variable !== this.voi) {
          ev.push({
            key: variable,
            metric: this.displayVariables[variable]
          })
        }
      }
      return ev;
      // [{
      //   key: "pct_Hispanic_ACS_13_17",
      //   metric: "% Hispanic (2017 ACS)"
      // }]
    } 
  },
  data() {
    return {
      url: 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/rastertiles/voyager/{z}/{x}/{y}.png',
      map: false,
      zoom: 12,
      bounds: [],
      center: [38.9145, -77.045992],
      mapOptions: {
          attributionControl: false
      },

      blockGroupData: [],
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
      voi: "pct_ENG_VW_SPAN_ACS_13_17",
      displayVariables: {
        pct_ENG_VW_SPAN_ACS_13_17: "% Spanish language households",
        pct_ENG_VW_INDOEURO_ACS_13_17: "% Indo-European language households",
        pct_ENG_VW_API_ACS_13_17: "% Asian/Pacific language households",
        pct_ENG_VW_OTHER_ACS_13_17: "% Other (non-English) language housholds",
        // pct_Hispanic_ACS_13_17: "% Hispanic"
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
    },
    clickHandler() {

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
        this.blockGroupData = data;
      });
    this.$nextTick(() => {
      this.map = this.$refs.map.mapObject;
    });
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="less">
// voi-selector {
//   margin-bottom: 100px;
// }
</style>
