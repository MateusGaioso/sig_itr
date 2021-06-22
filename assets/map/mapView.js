var mymap = L.map('mapid').setView([-20.4577, -54.58737], 18);
var gstreets = L.tileLayer('https://mt0.google.com/vt/lyrs=m&hl=en&x={x}&y={y}&z={z}', {maxZoom: 20, attribution: 'google'});
gstreets.addTo(mymap);
var imoveis = L.geoJson([], {});
$.getJSON('127.0.0.1/data/user/0/com.multisig.app.app_itr/app_flutter/campo-grande-MS.json', function (data) {
	imoveis.addData(data);
	mymap.fitBounds(imoveis.getBounds());
});
imoveis.addTo(mymap);
mymap.panTo(new L.LatLng(-20.4577, -54.58737));