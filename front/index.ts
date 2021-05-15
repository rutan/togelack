import $ from 'jquery';
import * as Vue from 'vue';
import * as VueDnd from 'vue-dnd';
import { createEditApp } from './legacy/EditApp';

(() => {
  const global = (window as any);

  // setup jquery-ujs
  global.jQuery = global.$ = $;
  require('jquery-ujs');

  Vue.use(VueDnd);
  global.createEditApp = createEditApp;
})();
