import 'dart:async';

import 'package:app_itr/etc/DBColumnNames.dart';
import 'package:app_itr/helpers/classes/EstradaPoint.dart';
import 'package:app_itr/helpers/classes/ImovelGeoPoint.dart';
import 'package:app_itr/helpers/classes/ImovelRoute.dart';
import 'package:app_itr/helpers/classes/Levantamento.dart';
import 'package:app_itr/helpers/classes/PontePoint.dart';
import 'package:app_itr/helpers/classes/RotaEscolarPoint.dart';
import 'package:app_itr/helpers/classes/imovel.dart';
import 'package:app_itr/helpers/classes/municipio.dart';
import 'package:app_itr/helpers/classes/user.dart';
import 'package:app_itr/helpers/db.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobx/mobx.dart';
import 'package:latlong2/latlong.dart' as LatLng2;

part 'login_data_store.g.dart';

class LoginDataStore = _LoginDataStore with _$LoginDataStore;

abstract class _LoginDataStore with Store {

  _LoginDataStore() {
    autorun((_) {
      print("OLD HEADING: ${oldUserPosition!.heading}");
      print("NEW HEADING: ${userPosition!.heading}");
    });


  }


  @observable
  Municipio m = Municipio();

  @observable
  User u = User();

  @observable
  bool loggedIn = false;

  @observable
  bool municipioSelectorEnabled = false;

  @observable
  double statusBarHeight = 0.0;

  @observable
  int tipo_ponto = 0;

  @observable
  String identificacao = "";

  @observable
  Position? userPosition;

  @observable
  Position? oldUserPosition;

  @observable
  int colorStateValue = 0;

  @observable
  int verticeActualValue = 0;

  @observable
  bool colected = false;

  @observable
  bool allSincronized = true;

  @observable
  bool markers_visible = false;

  @observable
  Imovel imovel = Imovel(false);

  @observable
  String geoJsonFileName = "";

  @observable
  String javaScriptFileName = "";

  @observable
  String pathHtml = "";

  @observable
  bool mapLoading = true;

  @observable
  bool buttonsVisibility = true;

  @observable
  bool buttonIniciarNavegacaoVisibility = false;

  @observable
  String buttonIniciarNavegacaoText = "INICIAR NAVEGAÇÃO";

  @observable
  double navigationHeading  = 0.0;

  ObservableList<ImovelRoute> imovelRouteList = ObservableList<ImovelRoute>();
  ObservableList<LatLng2.LatLng> routeLatLngList = ObservableList<LatLng2.LatLng>();
  ObservableList<Municipio> municipiosList = ObservableList<Municipio>();
  ObservableList<Levantamento> levantamentosList = ObservableList<Levantamento>();
  ObservableList<Levantamento> levantamentosListAsync = ObservableList<Levantamento>();
  ObservableList<EstradaPoint> estradaPointList = ObservableList<EstradaPoint>();
  ObservableList<EstradaPoint> estradaPointListAsync = ObservableList<EstradaPoint>();
  ObservableList<RotaEscolarPoint> rotaEscolarPointList = ObservableList<RotaEscolarPoint>();
  ObservableList<RotaEscolarPoint> rotaEscolarPointListAsync = ObservableList<RotaEscolarPoint>();
  ObservableList<ImovelGeoPoint> imovelGeoPointList = ObservableList<ImovelGeoPoint>();
  ObservableList<ImovelGeoPoint> imovelGeoPointListAsync = ObservableList<ImovelGeoPoint>();
  ObservableList<PontePoint> ponteList = ObservableList<PontePoint>();
  ObservableList<PontePoint> ponteListAsync = ObservableList<PontePoint>();
  ObservableList<Object> ponteImages = ObservableList<Object>();

  @observable
  LatLng2.Path routePath = LatLng2.Path();

  @observable
  ImovelRoute selectedImovelRoute = ImovelRoute();

  @observable
  Levantamento selectedLevantamento = Levantamento();

  @observable
  bool routeDone = false;

  ///OBSERVABLES LEVANTAMENTO

  @observable
  String levantamentoDescricao = "";


  //ESTRADA

  @observable
  String estradaRodovia = "";

  @observable
  String estradaTrecho = "";

  @observable
  String estradaJurisdicao = "";

  @observable
  String estradaEstadoDeConservacao = "";

  @observable
  String estradaTipoDePavimentacao = "";

  @observable
  String estradaLarguraAproximada = "";

  @observable
  bool  estradaStart = false;

  @observable
  String estradaPointTimer = '0';

  @observable
  LatLng lastEstradaPoint = new LatLng(0.0, 0.0);

  @observable
  String buttonIniciarCapturaEstradaText = "INICIAR CAPTURA DA ESTRADA";

  //ROTA ESCOLAR

  @observable
  String rotaEscolarRodovia = "";

  @observable
  String rotaEscolarTrecho = "";

  @observable
  String rotaEscolarJurisdicao = "";

  @observable
  String rotaEscolarEstadoDeConservacao = "";

  @observable
  String rotaEscolarTipoDePavimentacao = "";

  @observable
  String rotaEscolarLarguraAproximada = "";

  @observable
  bool  rotaEscolarStart = false;

  @observable
  String rotaEscolarPointTimer = '0';

  @observable
  LatLng lastRotaEscolarPoint = new LatLng(0.0, 0.0);

  @observable
  String buttonIniciarCapturaRotaEscolarText = "INICIAR CAPTURA DA ROTA ESCOLAR";

  //IMOVEL GEO POINT

  @observable
  String imovelGeoPointDescricao = "";

  @observable
  String imovelGeoPointTipo = "";

  @observable
  bool  imovelGeoPointStart = false;

  @observable
  String buttonIniciarCapturaImovelText = "INICIAR CAPTURA DO PONTO";

  //PONTE

  @observable
  String ponteDescricao = "";

  @observable
  String ponteEstadoConservacao = "";

  @observable
  String ponteMaterial = "";

  @observable
  String ponteExtensaoAproximada = "";

  @observable
  String ponteRioRiacho = "";

  @observable
  bool  ponteStart = false;

  @observable
  String buttonIniciarCapturaPonteText = "INICIAR CAPTURA DA PONTE";

  @observable
  PontePoint? selectedPontePoint;

  @observable
  PonteImage? selectedPonteImage;

  /// ACTIONS

  @action
  void setMunicipio(Municipio municipio) {
    m = municipio;
  }

  @action
  void setUser(User user) {
    u = user;
  }

  @action
  void login() {
    loggedIn = true;
  }

  @action
  void logout() {
    setUser(User());
    setMunicipio(Municipio());
    setImovel(Imovel(false));
    loggedIn = false;
  }

  @action
  void setStatusBarHeight(double d) {
    statusBarHeight = d;
  }

  @action
  void setTipo(int value) => tipo_ponto = value;

  @action
  void setIdent(String value) => identificacao = value;

  @action
  void setUserPosition(Position position) {
    if (userPosition == null) {
      userPosition = position;
      oldUserPosition = userPosition;

    } else {
      oldUserPosition = userPosition;
      userPosition = position;
    }

  }

  @action
  void setColorStateValue(int value) {
    colorStateValue = value;
  }

  @action
  void setVerticeActualValue(int value){
    verticeActualValue = value;
  }

  @action
  void setCollected(bool value) => colected = value;

  @action
  void setAllSincronized(bool value) => allSincronized = value;

  @action
  void toggleMarkers() {
    markers_visible = !markers_visible;
  }

  @action
  void setMarkersVisibility(bool value){
    markers_visible = value;
  }

  @action
  void setImovel(Imovel im){
    imovel = im;
  }

  @action
  void setGeoJsonFileName(String f){
    geoJsonFileName = f;
  }

  @action
  void setJavaScriptFileName(String f){
    javaScriptFileName = f;
  }

  @action
  void setPathHtml(String s){
    pathHtml = s;
  }

  @action
  void setMapLoading(bool b){
    mapLoading = b;
  }

  @action
  void setButtonsVisibility(bool b){
    buttonsVisibility = b;
  }

  @action
  void setButtonIniciarNavegacaoVisibility(bool b){
    buttonIniciarNavegacaoVisibility = b;
  }

  @action
  void setButtonIniciarNavegacaoText(String T){
    buttonIniciarNavegacaoText = T;
  }

  @action
  void setNavigationHeading(double d){
    navigationHeading = d;
  }


  @action
  void addMunicipioList(Municipio m){
    municipiosList.add(m);
  }

  @action
  void clearMunicipioList(){
    municipiosList.clear();
  }


  /// ACTIONS ROUTING

  @action
  void setRoutPath(LatLng2.Path p){
    routePath = p;
  }

  @action
  void addImovelRoute(ImovelRoute i){
    imovelRouteList.add(i);
  }

  @action
  void clearImovelRoute(){
    imovelRouteList.clear();
  }


  @action
  void addLatLngRoute(LatLng2.LatLng l){
    routeLatLngList.add(l);
  }

  @action
  void clearLatLngRoute(){
    routeLatLngList.clear();
  }


  @action
  void setSelectedImovelRoute(ImovelRoute i){
    selectedImovelRoute = i;
  }

  @action
  void setSelectedLevantamento(Levantamento l){
    selectedLevantamento = l;
  }

  @action
  void setRouteDone(bool b){
    routeDone = b;
  }

  @action
  void clearButtons(){
    buttonIniciarNavegacaoVisibility = false;
    buttonIniciarNavegacaoText = "INICIAR NAVEGAÇÃO";
    buttonIniciarCapturaImovelText = "INICIAR CAPTURA DO PONTO";
    buttonIniciarCapturaEstradaText = "INICIAR CAPTURA DA ESTRADA";
    buttonIniciarCapturaRotaEscolarText =  "INICIAR CAPTURA DA ROTA ESCOLAR";
    estradaStart = false;
    rotaEscolarStart = false;
    imovelGeoPointStart = false;
  }

  /// ACTIONS LEVANTAMENTOS

  @action
  void setLevantamentoDescricao(String d){
    levantamentoDescricao = d;
  }

  @action
  void addLevantamentosList(Levantamento l){
    levantamentosList.add(l);
  }

  @action
  void clearLevantamentosList(){
    levantamentosList.clear();
  }


  @action
  void addLevantamentosAsyncList(Levantamento l){
    levantamentosListAsync.add(l);
  }

  @action
  void clearLevantamentosAsyncList(){
    levantamentosListAsync.clear();
  }

  // ESTRADA

  @action
  void setEstradaRodovia(String d){
    estradaRodovia = d;
  }

  @action
  void setEstradaTrecho(String d){
    estradaTrecho = d;
  }

  @action
  void setEstradaJurisdicao(String d){
    estradaJurisdicao = d;
  }

  @action
  void setEstradaConservacao(String d){
    estradaEstadoDeConservacao = d;
  }

  @action
  void setEstradaPavimentacao(String d){
    estradaTipoDePavimentacao = d;
  }

  @action
  void setEstradaLargura(String d){
    estradaLarguraAproximada = d;
  }

  @action
  void setEstradaStart(bool b){
    estradaStart = b;
  }

  @action
  void setEstradaPointTimer(String s){
    estradaPointTimer = s;
  }

  @action
  void setLastEstradaPoint(LatLng l){
    lastEstradaPoint = l;
  }

  @action
  void setButtonIniciarCapturaEstrada(String T){
    buttonIniciarCapturaEstradaText = T;
  }

  @action
  void clearEstradaData(){
    estradaEstadoDeConservacao = "otimo";
    estradaTipoDePavimentacao = "asfalto";
    estradaLarguraAproximada = "";
    estradaRodovia = "";
    estradaTrecho = "";
    estradaJurisdicao = "municipal";
  }


  @action
  void addEstradaPointList(EstradaPoint e){
    estradaPointList.add(e);
  }

  @action
  void clearEstradaPointList(){
    estradaPointList.clear();
  }


  @action
  void addEstradaPointAsyncList(EstradaPoint e){
    estradaPointListAsync.add(e);
  }

  @action
  void clearEstradaPointAsyncList(){
    estradaPointListAsync.clear();
  }

  // ROTA ESCOLAR

  @action
  void setRotaEscolarRodovia(String d){
    rotaEscolarRodovia = d;
  }

  @action
  void setRotaEscolarTrecho(String d){
    rotaEscolarTrecho = d;
  }

  @action
  void setRotaEscolarJurisdicao(String d){
    rotaEscolarJurisdicao = d;
  }

  @action
  void setRotaEscolarConservacao(String d){
    rotaEscolarEstadoDeConservacao = d;
  }

  @action
  void setRotaEscolarPavimentacao(String d){
    rotaEscolarTipoDePavimentacao = d;
  }

  @action
  void setRotaEscolarLargura(String d){
    rotaEscolarLarguraAproximada = d;
  }

  @action
  void setRotaEscolarStart(bool b){
    rotaEscolarStart = b;
  }

  @action
  void setRotaEscolarPointTimer(String s){
    rotaEscolarPointTimer = s;
  }

  @action
  void setLastRotaEscolarPoint(LatLng l){
    lastRotaEscolarPoint = l;
  }

  @action
  void setButtonIniciarCapturaRotaEscolar(String T){
    buttonIniciarCapturaRotaEscolarText = T;
  }

  @action
  void clearRotaEscolarData(){
    rotaEscolarEstadoDeConservacao = "otimo";
    rotaEscolarTipoDePavimentacao = "asfalto";
    rotaEscolarLarguraAproximada = "";
    rotaEscolarRodovia = "";
    rotaEscolarTrecho = "";
    rotaEscolarJurisdicao = "municipal";

  }


  @action
  void addRotaEscolarPointList(RotaEscolarPoint r){
    rotaEscolarPointList.add(r);
  }

  @action
  void clearRotaEscolarPointList(){
    rotaEscolarPointList.clear();
  }


  @action
  void addRotaEscolarPointAsyncList(RotaEscolarPoint r){
    rotaEscolarPointListAsync.add(r);
  }

  @action
  void clearRotaEscolarPointAsyncList(){
    rotaEscolarPointListAsync.clear();
  }

  //GEO POINTS

  @action
  void setImovelStart(bool b){
    imovelGeoPointStart = b;
  }

  @action
  void setImovelDescricao(String s){
    imovelGeoPointDescricao = s;
  }

  @action
  void setImovelTipo(String s){
    imovelGeoPointTipo = s;
  }

  @action
  void setButtonIniciarCapturaImovel(String T){
    buttonIniciarCapturaImovelText = T;
  }

  @action
  void clearImovelGeoPointsData(){
    imovelGeoPointTipo = "sede";
    imovelGeoPointDescricao = "";
  }

  @action
  void addImovelGeoPointList(ImovelGeoPoint i){
    imovelGeoPointList.add(i);
  }

  @action
  void clearImovelGeoPointList(){
    imovelGeoPointList.clear();
  }


  @action
  void addImovelGeoPointAsyncList(ImovelGeoPoint i){
    imovelGeoPointListAsync.add(i);
  }

  @action
  void clearImovelGeoPointAsyncList(){
    imovelGeoPointListAsync.clear();
  }

  //PONTE

  @action
  void setPonteStart(bool b){
    ponteStart = b;
  }

  @action
  void setButtonIniciarCapturaPonte(String T){
    buttonIniciarCapturaPonteText = T;
  }

  @action
  void setPonteDescricao(String s){
    ponteDescricao = s;
  }

  @action
  void setPonteEstadoConservacao(String s){
    ponteEstadoConservacao = s;
  }

  @action
  void setPonteMaterial(String s){
    ponteMaterial = s;
  }

  @action
  void setPonteExtensaoAproximada(String s){
    ponteExtensaoAproximada = s;
  }

  @action
  void setPonteRioRiacho(String s){
    ponteRioRiacho = s;
  }

  @action
  void addPonteList(PontePoint p){
    ponteList.add(p);
  }

  @action
  void clearPonteList(){
    ponteList.clear();
  }


  @action
  void addPonteAsyncList(PontePoint p){
    ponteListAsync.add(p);
  }

  @action
  void clearPonteAsyncList() {
    ponteListAsync.clear();
  }

  @action
  void addPonteImagesList(Object o){
    ponteImages.add(o);
  }

  @action
  void addPonteImageLastPosition(){
    ponteImages.add("add image");
  }

  @action
  void removePonteBlankImages(){
    ponteImages.removeWhere((element) => element is String);
  }

  @action
  void clearPonteImages(){
    ponteImages.clear();
  }

  @action
  void setSelectedPonte(PontePoint p) {
    selectedPontePoint = p;
  }

  @action
  void setSelectedPonteImage(PonteImage p) {
    selectedPonteImage = p;
  }

  @action
  void clearPonteData(){
    ponteDescricao = "";
    ponteEstadoConservacao = "otimo";
    ponteExtensaoAproximada = "";
    ponteRioRiacho = "";
    ponteMaterial = "alvenaria";
  }



  @action
  void fullDataClear(){
    rotaEscolarPointList.clear();
    rotaEscolarPointListAsync.clear();
    estradaPointList.clear();
    estradaPointListAsync.clear();
    imovelGeoPointListAsync.clear();
    imovelGeoPointList.clear();
    ponteList.clear();
    ponteListAsync.clear();
    ponteImages.clear();
    selectedPontePoint = null;
    selectedPonteImage = null;
    selectedLevantamento = Levantamento();
    selectedImovelRoute = ImovelRoute();
    clearButtons();
    clearPonteData();
    clearEstradaData();
    clearRotaEscolarData();
    clearImovelGeoPointsData();
  }

  /// COMPUTED

  @computed
  bool get isColected => colected;

  @computed
  bool get isCidadeValid {
    if (m.idSistema != 0 && m.idSistema != null) {
      return true;
    } else {
      return false;
    }
  }

  @computed
  int get tipoSelected => tipo_ponto;


  @computed
  bool get isIdentValid => identificacao.length >=  2 && identificacao.length <= 30;


  @computed
  bool get isColorFinished => colorStateValue == 2;



  @computed
  bool get isTipoVertice => tipo_ponto == 0;

  void resetValues(){
    colorStateValue = 0;
    verticeActualValue = 0;
    tipo_ponto = 0;
    identificacao = "";
  }

  @computed
  bool get isAllSincronized => allSincronized;

  @computed
  bool get isMarkerVisible => markers_visible;

  @computed
  bool get isImovelUsing => imovel.isUsing();

  @computed
  bool get isMapLoading => mapLoading;

  @computed
  bool get isButtonsVisible => buttonsVisibility;

  @computed
  bool get isButtonIniciarNavegacaoVisible => buttonIniciarNavegacaoVisibility;

  @computed
  bool get isNavigationStarted => buttonIniciarNavegacaoText == "PARAR NAVEGAÇÃO";

  @computed
  bool get isNavigationStartedWithoutCompass => buttonIniciarNavegacaoText == "PARAR NAVEGAÇÃO 2";

  @computed
  bool get hasSelectedRoute => selectedImovelRoute.id != null;

  @computed
  bool get isRouteDone => routeDone;

  @computed
  bool get isLevantamentoFormValid => levantamentoDescricao.length > 1;

  @computed
  bool get isLevantamentoSincronizado => selectedLevantamento.sincronizado == 1;

  @computed
  bool get isEstradaFormValid => estradaRodovia.length > 1 && estradaTrecho.length > 1 && estradaLarguraAproximada.length > 0;

  @computed
  bool get isEstradaStarted => estradaStart;

  @computed
  bool get isEstradaCaptureStarted => buttonIniciarCapturaEstradaText == "PAUSAR CAPTURA DA ESTRADA";

  @computed
  bool get isRotaEscolarFormValid => rotaEscolarRodovia.length > 1 && rotaEscolarTrecho.length > 1 &&rotaEscolarLarguraAproximada.length > 0;

  @computed
  bool get isRotaEscolarStarted => rotaEscolarStart;

  @computed
  bool get isRotaEscolarCaptureStarted => buttonIniciarCapturaRotaEscolarText == "PAUSAR CAPTURA DA ROTA ESCOLAR";

  @computed
  bool get isGeoPointFormValid => imovelGeoPointDescricao.length > 1;

  @computed
  bool get isImovelStarted => imovelGeoPointStart;

  @computed
  bool get isImovelCaptureStarted => buttonIniciarCapturaImovelText == "PAUSAR CAPTURA DO PONTO";

  @computed
  bool get isPonteFormValid => ponteDescricao.length > 1 && ponteExtensaoAproximada.length > 0 && ponteRioRiacho.length > 0 ;

  @computed
  bool get isPonteStarted => ponteStart;

  @computed
  bool get isPonteCaptureStarted => buttonIniciarCapturaPonteText == "PAUSAR CAPTURA DA PONTE";


}