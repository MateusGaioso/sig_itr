import 'dart:convert';
import 'dart:io';

import 'package:app_itr/helpers/classes/Municipio.dart';
import 'package:app_itr/stores/login_data_store.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';


class PathReceiver {

  late String fileName;

  PathReceiver(String fileName){
    this.fileName = fileName;
  }

  PathReceiveR(){}

  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();

    return directory!.path;
  }

  Future<File> localFile() async {
    final path = await _localPath;
    return File('$path/$fileName');
  }

  Future<File> writeString(String str) async {
    final file = await localFile();

    // Write the file.
    return file.writeAsString(str);
  }

  Future<String> readFIle() async {
    final file = await  localFile();

    // Write the file.
    return file.readAsString();
  }


}