import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import '../../../model/entity/evento_DTO.dart';
import '../../../utils/jwt_utils.dart';
import '../../components/app_bar_ca.dart';
import 'package:http/http.dart' as http;
import '../routes/routes.dart';

/// Classe che implementa la sezione [CommunityEventsPubblicati]
class CommunityEventsPubblicati extends StatefulWidget {
  @override
  _CommunityEventsState createState() => _CommunityEventsState();
}

/// Creazione dello stato di [CommunityEventsPubblicati],
/// costituito dalla lista degli eventi pubblicati
class _CommunityEventsState extends State<CommunityEventsPubblicati> {
  List<EventoDTO> eventi = [];
  var token = SessionManager().get("token");

  /// Inizializzazione dello stato, con chiamata alla funzione [fetchDataFromServer]
  @override
  void initState() {
    super.initState();
    fetchDataFromServer();
    _checkUserAndNavigate();
  }

  void _checkUserAndNavigate() async {
    String token = await SessionManager().get('token');
    final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/autenticazione/checkUserCA'),
        body: jsonEncode(token),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode != 200) {
      Navigator.pushNamed(context, AppRoutes.home);
    }
  }

  /// Metodo che permette di inviare la richiesta al server per ottenere
  /// la lista di tutti gli [EventoDTO] presenti nel database
  Future<void> fetchDataFromServer() async {
    String user = JWTUtils.getUserFromToken(accessToken: await token);
    Map<String, dynamic> username = {"username": user};
    final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/gestioneEvento/eventiPubblicati'),
        body: json.encode(username));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      if (responseBody.containsKey('eventi')) {
        final List<EventoDTO> data =
            List<Map<String, dynamic>>.from(responseBody['eventi'])
                .map((json) => EventoDTO.fromJson(json))
                .toList();
        setState(() {
          List<EventoDTO> newData = [];
          for (EventoDTO e in data) {
            //if (e.approvato && e.id_ca == idCa) {
            newData.add(e);
            //}
          }
          eventi = newData;
        });
      } else {
        print('Chiave "eventi" non trovata nella risposta.');
      }
    } else {
      print('Errore');
    }
  }

  Future<void> deleteEvento(EventoDTO evento) async {
    final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/gestioneEvento/deleteEvento'),
        body: jsonEncode(evento));
    if (response.statusCode == 200) {
      setState(() {
        eventi.remove(evento);
      });
    } else {
      print("Eliminazione non andata a buon fine");
    }
  }

  /// Build del widget principale della sezione [CommunityEvents],
  /// contenente tutta l'interfaccia grafica
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CaAppBar(
        showBackButton: true,
      ),
      endDrawer: CaAppBar.buildDrawer(context),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Colors.white,
              child: const Text(
                'GESTISCI I TUOI EVENTI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: ListView.builder(
              itemCount: eventi.length,
              itemBuilder: (context, index) {
                final evento = eventi[index];
                return InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.dettaglieventipub,
                      arguments: evento,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [Colors.blue[50]!, Colors.blue[100]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    child: ListTile(
                      visualDensity:
                          const VisualDensity(vertical: 4, horizontal: 4),
                      minVerticalPadding: 50,
                      minLeadingWidth: 80,
                      tileColor: Colors.transparent,
                      leading: CircleAvatar(
                        radius: 35,
                        backgroundImage: AssetImage(evento.immagine),
                      ),
                      title: Text(
                        evento.nomeEvento,
                        style: const TextStyle(
                          fontFamily: 'Genos',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        evento.descrizione.length > 20
                            ? '${evento.descrizione.substring(0, 20)}...'
                            : evento.descrizione,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.black, size: 30),
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, AppRoutes.modificaevento,
                                    arguments: evento);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.black, size: 30),
                              onPressed: () {
                                deleteEvento(evento);
                                Navigator.pushNamed(context, AppRoutes.homeADS);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Evento eliminato',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DetailsEventoPub extends StatefulWidget {
  @override
  _DetailsEventoPub createState() => _DetailsEventoPub();
}

/// Build del widget che viene visualizzato quando viene selezionato un
/// determinato evento dalla sezione [CommunityEvents]
/// Permette di visualizzare i dettagli dell'evento selezionato
class _DetailsEventoPub extends State<DetailsEventoPub> {
  List<EventoDTO> eventi = [];
  var token = SessionManager().get("token");

  /// Inizializzazione dello stato, con chiamata alla funzione [fetchDataFromServer]
  @override
  void initState() {
    _checkUserAndNavigate();
    super.initState();
  }

  void _checkUserAndNavigate() async {
    String token = await SessionManager().get('token');
    final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/autenticazione/checkUserCA'),
        body: jsonEncode(token),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode != 200) {
      Navigator.pushNamed(context, AppRoutes.home);
    }
  }

  Future<void> deleteEvento(EventoDTO evento) async {
    final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/gestioneEvento/deleteEvento'),
        body: jsonEncode(evento));
    if (response.statusCode == 200) {
      setState(() {
        eventi.remove(evento);
      });
    } else {
      print("Eliminazione non andata a buon fine");
    }
  }

  @override
  Widget build(BuildContext context) {
    final EventoDTO evento =
        ModalRoute.of(context)?.settings.arguments as EventoDTO;
    final String data = evento.date.toIso8601String();
    final String dataBuona = data.substring(0, 10);
    return Scaffold(
        appBar: CaAppBar(
          showBackButton: true,
        ),
        endDrawer: CaAppBar.buildDrawer(context),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      fit: BoxFit.cover, image: AssetImage(evento.immagine)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              evento.nomeEvento,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Genos',
                fontSize: 30,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                evento.descrizione,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Contatti',
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'PoppinsMedium',
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        evento.email,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Informazioni',
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'PoppinsMedium',
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        dataBuona,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.black, size: 40),
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, AppRoutes.modificaevento,
                                  arguments: evento);
                            },
                          ),
                          const SizedBox(width: 20),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.black, size: 40),
                            onPressed: () {
                              deleteEvento(evento);
                              Navigator.pushNamed(context, AppRoutes.homeADS);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Evento eliminato',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }
}

