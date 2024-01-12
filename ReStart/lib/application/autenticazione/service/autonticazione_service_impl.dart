import '../../../model/dao/autenticazione/autenticazione_DAO.dart';
import '../../../model/dao/autenticazione/autenticazione_DAO_impl.dart';
import '../../../model/dao/autenticazione/utente/utente_DAO.dart';
import '../../../model/dao/autenticazione/utente/utente_DAO_impl.dart';
import '../../../model/entity/ads_DTO.dart';
import '../../../model/entity/ca_DTO.dart';
import '../../../model/entity/utente_DTO.dart';
import 'autenticazione_service.dart';

class AutenticazioneServiceImpl implements AutenticazioneService {
  final AutenticazioneDAO _autenticazioneDAO;
  final UtenteDAO _utenteDAO;

  AutenticazioneServiceImpl()
      : _autenticazioneDAO = AutenticazioneDAOImpl(),
        _utenteDAO = UtenteDAOImpl();

  @override
  Future<dynamic> login(String user, String psw) async {
    print("service: "+user);print(psw);
    dynamic utente = await _autenticazioneDAO.findByUsername(user);
    print(utente);
    if (utente == null) {
      return null;
    } else {
      if (utente is AdsDTO) {
        AdsDTO utenteAds = utente;
        if (utenteAds.password == psw) {
          return utenteAds;
        }
      }
      if (utente is UtenteDTO) {
        UtenteDTO utenteU = utente;
        if (utenteU.password == psw) {
          return utenteU;
        }
      } else {
        CaDTO utenteCa = utente;
        if (utenteCa.password == psw) {
          return utenteCa;
        }
      }
    }
  }

  @override
  Future<UtenteDTO?> visualizzaUtente(String username) {
    final UtenteDAO utenteDAO = UtenteDAOImpl();
    return utenteDAO.findByUsername(username);
  }

  @override
  Future<List<UtenteDTO>> listaUtenti() {
    return _utenteDAO.findAll();
  }

  @override
  Future<bool> deleteUtente(String username) {
    final UtenteDAO utenteDAO = UtenteDAOImpl();
    return utenteDAO.removeByUsername(username);
  }

  @override
  Future<bool> modifyUtente(UtenteDTO u) {
    return _utenteDAO.update(u);
  }
}
