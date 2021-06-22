import 'dart:io';

import 'package:app_itr/etc/ThemeCTRM.dart';
import 'package:app_itr/etc/custom_icons_icons.dart';
import 'package:app_itr/helpers/classes/PontePoint.dart';
import 'package:app_itr/helpers/classes/RotaEscolarPoint.dart';
import 'package:app_itr/helpers/db.dart';
import 'package:app_itr/stores/login_data_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class PonteCameraPickerPage extends StatefulWidget {
  PonteCameraPickerPage({Key? key}) : super(key: key);

  @override
  _PonteCameraPickerPage createState() {
    return _PonteCameraPickerPage();
  }
}

class _PonteCameraPickerPage extends State<PonteCameraPickerPage> with SingleTickerProviderStateMixin {
  late LoginDataStore _loginDataStore;
  late AnimationController _animationController;
  late Animation _animation;
  FocusNode _focusNode = FocusNode();
  String estadoDeConservacaoValue = "otimo";
  String materialValue = "alvenaria";
  DBHelper _helper = new DBHelper();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this, duration: kThemeAnimationDuration, value: 1);
    _animation = Tween(begin: 300.0, end: 50.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    _loginDataStore.removePonteBlankImages();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loginDataStore = Provider.of<LoginDataStore>(context);
  }

  Future<void> _salvarImagens() async {


    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "Deseja salvar todas as imagens da ponte?",
            style: FontsStyleCTRM.primaryFont20Dark,
          ),
          content: Text(""),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: ElevatedButton(
                child: Text(
                  "NÃO",
                  style: FontsStyleCTRM.primaryFontWhite,
                ),
                style: ElevatedButton.styleFrom(primary: ColorsCTRM.primaryColorComplementary),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: ElevatedButton(
                child: Text(
                  "SIM",
                  style: FontsStyleCTRM.primaryFontWhite,
                ),
                style: ElevatedButton.styleFrom(primary: ColorsCTRM.primaryColor),
                onPressed: () {
                  _loginDataStore.ponteImages.forEach((element) {
                    if (element is PonteImage) {
                      if(element.id == null){
                        _helper.savePonteImage(element);
                      }
                    }
                  });
                  Navigator.of(context).pop();
                  _pop();
                },
              ),
            ),
            // define os botões na base do dialogo
          ],
        );
      },
    );

  }

  _pop(){
    Navigator.pop(context, "save-${_loginDataStore.selectedLevantamento.tipoLevantamento}-image");
  }

  void _removeFocus() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Capturar Imagens da Ponte",
            style: FontsStyleCTRM.primaryFontWhite,
          ),
        ),
        body: GestureDetector(
          onTap: _removeFocus,
          child: Padding(
            padding: EdgeInsets.only(right: 1.0, left: 1.0, bottom: 1.0, top: 1.0),
            child: Container(
              color: ColorsCTRM.primaryColorDarkAlpha66,
              child: Container(
                color: ColorsCTRM.primaryColorDarkAlpha66,
                child: ListView(
                  children: [
                    Observer(
                      builder: (_) {
                        return GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                          children: List.generate(_loginDataStore.ponteImages.length, (index) {
                            if (_loginDataStore.ponteImages[index] is PonteImage) {
                              PonteImage image = _loginDataStore.ponteImages[index] as PonteImage;
                              return Card(
                                clipBehavior: Clip.antiAlias,
                                child: Stack(
                                  children: <Widget>[
                                    GestureDetector(
                                      child: Image.file(
                                        image.imageFile!,
                                        width: 300,
                                        height: 300,
                                        fit: BoxFit.cover,
                                      ),
                                      onTap: (){
                                        _showFullImage(image);
                                      },
                                    ),
                                    Positioned(
                                      right: 5,
                                      top: 5,
                                      child: InkWell(
                                        child: Icon(
                                          Icons.remove_circle,
                                          size: 25,
                                          color: Colors.red,
                                        ),
                                        onTap: (){
                                          _loginDataStore.setSelectedPonteImage(image);
                                          _deletePonteImage();}
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return Card(
                                child: IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    _onAddImageClick(index);
                                  },
                                ),
                              );
                            }
                          }),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(right: 10, bottom: 10),
          child: SizedBox(
              height: 50,
              child: ElevatedButton(
                  child: Text(
                    "SALVAR IMAGENS",
                    style: FontsStyleCTRM.primaryFontWhite,
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: ColorsCTRM.primaryColor,
                    elevation: 6,
                    shadowColor: ColorsCTRM.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  ),
                  onPressed: _salvarImagens)),
        ),
      ),
    );
  }

  Future _onAddImageClick(int index) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "SELECIONE O TIPO DE CAPTURA",
            style: FontsStyleCTRM.primaryFont20Dark,
          ),
          content: Container(
            decoration: BoxDecoration(
              color: ColorsCTRM.primaryColorAlphaAA,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(16.0),
                bottomLeft: Radius.circular(16.0),
                topLeft: Radius.circular(16.0),
                bottomRight: Radius.circular(16.0),
              ),
            ),
            height: 100,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _capturePhotoWithCamera,
                        child: Container(
                          height: 70,
                          child: Center(
                            child: SvgPicture.asset(camera, height: 60),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _capturePhotoWithGallery,
                        child: Container(
                          decoration: BoxDecoration(
                            color: ColorsCTRM.primaryColorDarkAlpha66,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(16.0),
                            ),
                          ),
                          height: 70,
                          child: Center(
                            child: SvgPicture.asset(gallery, height: 45),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _capturePhotoWithCamera,
                        child: Container(
                            height: 30,
                            child: Column(
                              children: [
                                Center(child: Text("CAPTURAR", style: FontsStyleCTRM.primaryFontMiniWhite)),
                                Center(child: Text("IMAGEM", style: FontsStyleCTRM.primaryFontMiniWhite)),
                              ],
                            )),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _capturePhotoWithGallery,
                        child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              color: ColorsCTRM.primaryColorDarkAlpha66,
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(16.0),
                              ),
                            ),
                            child: Column(
                              children: [
                                Center(child: Text("SELECIONAR", style: FontsStyleCTRM.primaryFontMiniWhite)),
                                Center(child: Text("DA GALERIA", style: FontsStyleCTRM.primaryFontMiniWhite)),
                              ],
                            )),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          actions: <Widget>[
            // define os botões na base do dialogo
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: ElevatedButton(
                child: Text(
                  "VOLTAR",
                  style: FontsStyleCTRM.primaryFontWhite,
                ),
                style: ElevatedButton.styleFrom(primary: ColorsCTRM.primaryColor),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void getFileImage(PickedFile? file) async {
//    var dir = await path_provider.getTemporaryDirectory();

    PonteImage ponteImage = new PonteImage();
    ponteImage.sincronizado = 0;
    ponteImage.idPonte = _loginDataStore.selectedPontePoint!.id;
    ponteImage.imageFile = File(file!.path);
    ponteImage.imagePath = file.path;

    _loginDataStore.addPonteImagesList(ponteImage);
    _loginDataStore.addPonteImageLastPosition();
  }

  _capturePhotoWithCamera() async {
    Navigator.of(context).pop();
    await ImagePicker.platform.pickImage(source: ImageSource.camera, maxHeight: 1920, maxWidth: 1080).then((value) {
      print("VALUE -> $value");
      if (value != null) {
        _loginDataStore.removePonteBlankImages();
        getFileImage(value);
      }
    });
  }

  _capturePhotoWithGallery() async {}

  _deletePonteImage(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "Deseja excluir essa imagem?",
            style: FontsStyleCTRM.primaryFont20Dark,
          ),
          content: Text(""),
          actions: <Widget>[
            // define os botões na base do dialogo
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: ElevatedButton(
                child: Text(
                  "NÃO",
                  style: FontsStyleCTRM.primaryFontWhite,
                ),
                style: ElevatedButton.styleFrom(primary: ColorsCTRM.primaryColorComplementary),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: ElevatedButton(
                child: Text(
                  "SIM",
                  style: FontsStyleCTRM.primaryFontWhite,
                ),
                style: ElevatedButton.styleFrom(primary: ColorsCTRM.primaryColor),
                onPressed: () {
                  _helper.deleteImagePonte(_loginDataStore);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  _showFullImage(PonteImage image){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Image.file(
            image.imageFile!,
            fit: BoxFit.contain,
          ),
          actions: <Widget>[
            // define os botões na base do dialogo
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: ElevatedButton(
                child: Text(
                  "FECHAR",
                  style: FontsStyleCTRM.primaryFontWhite,
                ),
                style: ElevatedButton.styleFrom(primary: ColorsCTRM.primaryColor),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _onBackPressed() async {
    BuildContext dialogContext;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "Deseja voltar para o mapa sem salvar as imagens?",
            style: FontsStyleCTRM.primaryFont20Dark,
          ),
          content: Text(""),
          actions: <Widget>[
            // define os botões na base do dialogo
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: ElevatedButton(
                child: Text(
                  "NÃO",
                  style: FontsStyleCTRM.primaryFontWhite,
                ),
                style: ElevatedButton.styleFrom(primary: ColorsCTRM.primaryColorComplementary),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: ElevatedButton(
                child: Text(
                  "SIM",
                  style: FontsStyleCTRM.primaryFontWhite,
                ),
                style: ElevatedButton.styleFrom(primary: ColorsCTRM.primaryColor),
                onPressed: () {
                  Navigator.pop(context);
                  _pop();
                },
              ),
            ),
          ],
        );
      },
    );


    throw true;
  }


}
