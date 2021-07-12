//DATABASE
import 'package:app_itr/helpers/classes/ImovelDadosAbertos.dart';

final String appDataTable = "AppDataTable";
final String userTable = "UserTable";
final String municipioTable = "MunicipioTable";
final String estadoTable = "EstadoTable";
final String regiaoAdministrativaTable = "RegiaoAdministrativaTable";
final String loggedUserTable = "LoggedUserTable";
final String geoPointTable = "geoPointTable";
final String routeTable = "routeTable";
final String imovelTable = "imovelTable";
final String levantamentoTable = "levantamentoTable";
final String estradaPointTable = "estradaPointTable";
final String rotaEscolarPointTable = "rotaEscolarPointTable";
final String pontePointTable = "pontePointTable";
final String ponteImageTable = "ponteImageTable";
final String imovelDadosAbertosTable = "imovelDadosAbertosTable";

final String idColumn = 'idColumn';
final String idSistemaColumn = 'idSistemaColumn';
final String idPushMessageColumn = 'idPushMessageColumn';
final String pushMessageColumn = 'pushMessageColumn';
final String isMunicipiosListByUFLoadedColumn = 'isMunicipiosListByUFLoadedColumn';
final String isImoveisListByUFLoadedColumn = 'isImoveisListByUFLoadedColumn';


//IMOVEL
final String idImovelColumn = 'idColumn';
final String listGeoPointsColumn = 'listGeoPointsColumn';

//IMOVELGEOPOINT
final String tipoColumn = 'tipoColumn';
final String descricaoColumn = 'descricaoColumn';
final String latColumn = 'latColumn';
final String lngColumn = 'lngColumn';
final String idSistemaUserColumn = 'idSistemaUserColumn';
final String idSistemaMunicipioColumn = 'idSistemaMunicipioColumn';
final String sincronizadoColumn = 'sincronizadoColumn';

//IMOVELROUTE
final String origem_consultaColumn = 'origem_consultaColumn';
final String nome_imovelColumn = 'nome_imovelColumn';
final String coordenadas_sedeLatColumn = 'coordenadas_sedeLatColumn';
final String coordenadas_sedeLngColumn = 'coordenadas_sedeLngColumn';
final String coordenadas_imovelLatColumn = 'coordenadas_imovelLatColumn';
final String coordenadas_imovelLngColumn = 'coordenadas_imovelLngColumn';
final String idSistemaImovelColumn = 'idSistemaImovelColumn';
final String idSistemaRouteColumn = 'idSistemaRouteColumn';
final String geometryColumn = 'geometryColumn';

//MUNICIPIO
final String nomeMunicipioColumn = 'nomeMunicipioColumn';
final String slugColumn = 'slugColumn';
final String estadoColumn = 'estadoColumn';
final String sigla_ufColumn = 'sigla_ufColumn';
final String cod_ibge_mColumn = 'cod_ibge_mColumn';
final String latitudeColumn = 'latitudeColumn';
final String longitudeColumn = 'longitudeColumn';
final String allDownloadedColumn = 'allDownloadedColumn';

//ESTADO
final String nomeEstadoColumn = 'nomeEstadoColumn';

//REGIÃO ADMINISTRATIVA
final String nomeRegAdmColumn = 'nomeRegAdmColumn';

//USER
final String userColumn = 'userColumn';
final String passColumn = 'passColumn';
final String nameColumn = 'nameColumn';
final String emailColumn = 'emailColumn';
final String cpfColumn = 'cpfColumn';
final String rgColumn = 'rgColumn';
final String telefoneColumn = 'telefoneColumn';
final String imovelColumn = 'imovelColumn';
final String municipiosColumn = 'municipiosColumn';
final String tokenColumn = 'tokenColumn';

//LEVANTAMENTO
final String tipoLevantamentoColumn = 'tipoLevantamentoColumn';
final String statusColumn = 'statusColumn';

//ESTRADA
final String idLevantamentoColumn = 'idLevantamentoColumn';
final String idSistemaLevantamentoColumn = 'idSistemaLevantamentoColumn';
final String estadoConservacaoColumn = 'estadoConservacaoColumn';
final String tipoPavimentacaoColumn = 'tipoPavimentacaoColumn';
final String larguraAproximadaColumn = 'larguraAproximadaColumn';
final String rodoviaColumn = 'rodoviaColumn';
final String trechoColumn = 'trechoColumn';
final String jurisdicaoColumn = 'jurisdicaoColumn';

// PONTE

final String rioRiachoColumn = 'rioRiachoColumn';
final String materialColumn = 'materialColumn';
final String extensaoAproximadaColumn = 'extensaoAproximadaColumn';
final String idPonteColumn = 'idPonteColumn';
final String idSistemaPonteColumn = 'idSistemaPonteColumn';
final String ponteImagePathColumn = 'ponteImagePathColumn';

// DADOS ABERTOS
final String idSistemaBaseConsolidadaColumn = 'idSistemaBaseConsolidadaColumn';
final String nomeImovelColumn = 'nomeImovelColumn';
final String codImovelColumn = 'codImovelColumn';
final String carColumn = 'carColumn';
final String numCertifColumn = 'numCertifColumn';
final String regAdmColumn = 'regAdmColumn';
final String geomMultipolygonColumn = 'geomMultipolygonColumn';
final String geomRotaColumn = 'geomRotaColumn';

