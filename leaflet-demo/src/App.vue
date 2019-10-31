<template>
  <div id="app">
    <!-- <img alt="Vue logo" src="./assets/logo.png"> -->
    <!-- <HelloWorld msg="Welcome to Your Vue.js App"/> -->
    <LeafletMap/>
  </div>
</template>

<script>
import LeafletMap from './components/LeafletMap.vue';

export default {
  name: 'app',
  components: {
    LeafletMap,
  },
};
</script>

<style lang="less">
html, body {
  margin: 0;
  padding: 0;
}

html, body, #app {
    min-height: 100% !important;
    height: 100%;
}

#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin: 0;
  height: 100%;
}
</style>
