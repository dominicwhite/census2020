import Vue from 'vue';

import { Icon } from 'leaflet';

import 'leaflet/dist/leaflet.css';

delete Icon.Default.prototype._getIconUrl;

Icon.Default.mergeOptions({
  iconRetinaUrl: require('leaflet/dist/images/marker-icon-2x.png'),
  iconUrl: require('leaflet/dist/images/marker-icon.png'),
  shadowUrl: require('leaflet/dist/images/marker-shadow.png'),
});


import App from './App.vue';
import store from './store';


Vue.config.productionTip = false;

new Vue({
  store,
  render: h => h(App),
}).$mount('#app');
