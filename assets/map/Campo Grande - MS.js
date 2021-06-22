var mymap = L.map('mapid').setView([-20.4526332, -54.5886463], 18);
var gstreets = L.tileLayer('https://mt0.google.com/vt/lyrs=m&hl=en&x={x}&y={y}&z={z}', {maxZoom: 20, attribution: 'google'});
gstreets.addTo(mymap);
var imoveis = L.geoJson(geoJsonFeature, {onEachFeature: function (feature, layer) {
	layer.bindPopup(feature.properties.nome_area);
	layer.bindTooltip(feature.properties.nome_area,
   {permanent: true, direction:"center"}
  );
}});
imoveis.addTo(mymap);mymap.panTo(new L.LatLng(-20.4526332, -54.5886463)); var group = L.featureGroup();