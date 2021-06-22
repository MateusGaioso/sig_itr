import 'package:app_itr/etc/DBColumnNames.dart';
import '../db.dart';


class User {
  int? id;
  late int idSistema;
  late String user;
  late String pass;
  late String nome;
  late String email;
  late  String cpf;
  late String rg;
  late String telefone;
  late String imovel;
  late String municipios;
  late String token;

  User();

  User.fromMap(Map map) {
    id = map[idColumn];
    idSistema = map[idSistemaColumn];
    user = map[userColumn];
    pass = map[passColumn];
    nome = map[nameColumn];
    email = map[emailColumn];
    cpf = map[cpfColumn];
    rg = map[rgColumn];
    telefone = map[telefoneColumn];
    imovel = map[imovelColumn];
    municipios = map[municipiosColumn];
    token = map[tokenColumn];
  }

  Map<String, Object?> toMap() {
    Map<String, Object?> map = {
      idSistemaColumn: idSistema,
      userColumn: user,
      passColumn: pass,
      nameColumn: nome,
      emailColumn: email,
      cpfColumn: cpf,
      rgColumn: rg,
      telefoneColumn: telefone,
      imovelColumn: imovel,
      municipiosColumn: municipios,
      tokenColumn: token,
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "User(id: $id, idSistema: $idSistema, user: $user, pass: $pass, nome: $nome, email: $email, cpf:"
        " $cpf, rg: $rg, telefone: $telefone, imovel: $imovel, municipios: $municipios, token: $token)";
  }
}

class LoggedUser{
  int? id;
  late int idSistema;

  LoggedUser();

  LoggedUser.fromMap(Map map) {
    id = map[idColumn];
    idSistema = map[idSistemaColumn];
  }

  Map<String, Object?> toMap() {
    Map<String, dynamic> map = {
      idSistemaColumn: idSistema,
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "LoggedUser(id: $id, idSistema: $idSistema)";

  }
}

