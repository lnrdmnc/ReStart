import 'dart:convert';
import 'package:restart_all_in_one/application/gestioneEvento/service/evento_service_impl.dart';
import 'package:restart_all_in_one/model/entity/evento_DTO.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart' as shelf_router;

class GestioneEventoController {
  late final EventoServiceImpl _service;
  late final shelf_router.Router _router;

  GestioneEventoController() {
    _service = EventoServiceImpl();
    _router = shelf_router.Router();

    _router.post('/visualizzaEventi', _visualizzaEventi);
    _router.post('/addEvento', _addEvento);
    //_router.post('/dettagliEvento', _dettagliEvento);

    _router.all('/ignored|.*>', _notFound);
  }

  shelf_router.Router get router => _router;

  Future<Response> _visualizzaEventi(Request request) async {
    try {
      final List<EventoDTO> listaEventi = await _service.communityEvents();
      final responseBody = jsonEncode({'eventi': listaEventi});
      return Response.ok(responseBody,
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(
          body: 'Errore durante la visualizzazione dei corsi: $e');
    }
  }
  Future<Response> _addEvento(Request request) async {
    try {
      final String requestBody = await request.readAsString();
      final Map<String, dynamic> params = jsonDecode(requestBody);
      final int id_ca = params['id_ca'] ?? '';
      final String nomeEvento = params['nome'] ?? '';
      final String descrizione = params['descrizione'] ?? '';
      final DateTime date = params['data'] ?? '';
      final bool approvato = params['approvato'] ?? '';
      final String email = params['email'] ?? '';
      final String sito = params['sito'] ?? '';
      final String immagine = params['immagine'] ?? '';
      final String via = params['via'] ?? '';
      final String citta = params['citta'] ?? '';
      final String provincia = params['provincia'] ?? '';

      EventoDTO evento = EventoDTO(
          id_ca: id_ca,
          nomeEvento: nomeEvento,
          descrizione: descrizione,
          date: date,
          approvato: approvato,
          email: email,
          sito: sito,
          immagine: immagine,
          via: via,
          citta: citta,
          provincia: provincia);

      if (await _service.addEvento(evento)) {
        final responseBody = jsonEncode({'result': "Inserimento effettuato."});
        return Response.ok(responseBody,
            headers: {'Content-Type': 'application/json'});
      } else {
        final responseBody =
        jsonEncode({'result': 'Inserimento non effettuato'});
        return Response.badRequest(
            body: responseBody, headers: {'Content-Type': 'application/json'});
      }
    } catch (e) {
      // Gestione degli errori durante la chiamata al servizio
      return Response.internalServerError(
          body: 'Errore durante l\'inserimento del corso di formazione: $e');
    }
  }

  //Commentato perchÃ¨ penso sia sbagliata
  // Future<Response> _dettagliEvento(Request request, int id) async {
  //   try {
  //     final EventoDTO? evento = await _service.detailsEvento(id);
  //     final responseBody = jsonEncode({'evento': evento});
  //         return Response.ok(responseBody,
  //             headers: {'Content-Type': 'application/json'});
  //   } catch (e) {
  //         return Response.internalServerError(
  //             body: 'Errore durante la visualizzazione dei corsi: $e');
  //   }
  // }

  Future<Response> _notFound(Request request) async {
    return Response.notFound('Endpoint non trovato',
        headers: {'Content-Type': 'text/plain'});
  }
}

// Funzione per il parsing dei dati di form
Map<String, dynamic> parseFormBody(String body) {
  final Map<String, dynamic> formData = {};
  final List<String> pairs = body.split("&");
  for (final String pair in pairs) {
    final List<String> keyValue = pair.split("=");
    if (keyValue.length == 2) {
      final String key = Uri.decodeQueryComponent(keyValue[0]);
      final String value = Uri.decodeQueryComponent(keyValue[1]);
      formData[key] = value;
    }
  }
  return formData;
}