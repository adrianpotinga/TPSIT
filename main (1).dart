import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

// Widget principale dell'app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp fornisce lo stile di base (tema Material Design)
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // Nasconde la scritta "debug"
      home: Mastermind(), // Imposta la schermata principale
    );
  }
}

// Widget con stato che rappresenta il gioco
class Mastermind extends StatefulWidget {
  const Mastermind({super.key});

  @override
  State<Mastermind> createState() => _MastermindState();
}

// Classe che contiene la logica del gioco
class _MastermindState extends State<Mastermind> {
  // Lista dei colori disponibili nel gioco
  final List<Color> colori = [Colors.red, Colors.orange, Colors.green];

  // Lista per memorizzare la sequenza segreta da indovinare
  List<Color> segreto = [];

  // Lista per memorizzare i colori scelti dal giocatore
  List<Color> scelta = List.filled(4, Colors.grey);

  // Messaggio mostrato all'utente (vittoria, errore, ecc.)
  String messaggio = '';

  // Numero di tentativi effettuati dal giocatore
  int tentativi = 0;

  @override
  void initState() {
    super.initState();
    // Quando l'app parte, genero subito la sequenza segreta
    generaSegreto();
  }

  // Funzione per generare una sequenza segreta casuale di 4 colori
  void generaSegreto() {
    final random = Random();
    segreto = List.generate(4, (_) => colori[random.nextInt(colori.length)]);
  }

  // Funzione per cambiare il colore di un rettangolo quando l'utente lo tocca
  void cambiaColore(int i) {
    setState(() {
      // Se il rettangolo è ancora grigio, parte dal primo colore
      if (scelta[i] == Colors.grey) {
        scelta[i] = colori[0];
      } else {
        // Altrimenti passa al colore successivo ciclicamente
        int pos = colori.indexOf(scelta[i]);
        scelta[i] = colori[(pos + 1) % colori.length];
      }
    });
  }

  // Funzione principale del gioco: verifica se la sequenza scelta è corretta
  void verifica() {
    // Controllo se il giocatore ha scelto tutti i colori
    if (scelta.contains(Colors.grey)) {
      setState(() => messaggio = 'Scegli tutti i colori!');
      return;
    }

    setState(() {
      // Incremento il numero di tentativi
      tentativi++;

      // Conteggio dei colori nella posizione giusta
      int giusti = 0;
      for (int i = 0; i < 4; i++) {
        if (scelta[i] == segreto[i]) giusti++;
      }

      // Caso 1: il giocatore ha indovinato tutta la sequenza
      if (giusti == 4) {
        messaggio = 'Hai vinto in $tentativi tentativi!';
        mostraSequenzaSegreta();
      }
      // Caso 2: ha esaurito i 10 tentativi
      else if (tentativi >= 10) {
        messaggio = 'Hai perso! Tentativi finiti.';
        mostraSequenzaSegreta();
      }
      // Caso 3: ha indovinato solo alcuni colori
      else {
        messaggio = 'Hai indovinato $giusti su 4!';
      }

      // Dopo ogni verifica, resetto la scelta (tutti grigi)
      scelta = List.filled(4, Colors.grey);
    });
  }

  // Mostra un popup (AlertDialog) con la sequenza segreta alla fine del gioco
  void mostraSequenzaSegreta() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sequenza segreta'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: segreto
              .map((c) => Container(
                    margin: const EdgeInsets.all(5),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(8), // Rettangolo arrotondato
                    ),
                  ))
              .toList(),
        ),
        actions: [
          // Pulsante per iniziare una nuova partita
          TextButton(
            child: const Text('Nuova partita'),
            onPressed: () {
              Navigator.pop(context);
              reset();
            },
          )
        ],
      ),
    );
  }

  // Funzione per resettare il gioco
  void reset() {
    setState(() {
      tentativi = 0; 
      messaggio = ''; 
      scelta = List.filled(4, Colors.grey);
      generaSegreto(); 
    });
  }

  // Widget che disegna un singolo rettangolo arrotondato cliccabile
  Widget rettangolo(Color c, VoidCallback onTap) => GestureDetector(
        onTap: onTap, 
        child: Container(
          width: 60,
          height: 60,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(15), 
            border: Border.all(color: Colors.black54),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    // Costruisce l'interfaccia grafica principale
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mastermind'), // Titolo in alto
        backgroundColor: Color.fromARGB(255, 99, 24, 1), // Colore della barra
        actions: [
          // Icona di refresh per ricominciare la partita
          IconButton(icon: const Icon(Icons.refresh), onPressed: reset)
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Titolo principale
            const Text(
              'Indovina la sequenza!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Riga con i 4 rettangoli cliccabili
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (i) => rettangolo(scelta[i], () => cambiaColore(i)),
              ),
            ),

            const SizedBox(height: 20),

            // Bottone per verificare la sequenza
            ElevatedButton(
              onPressed: verifica,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 90, 21, 0),
              ),
              child: const Text('Verifica'),
            ),

            const SizedBox(height: 20),

            // Mostra il numero di tentativi effettuati
            Text('Tentativi: $tentativi / 10',
                style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 10),

            // Mostra i messaggi di stato (vittoria, errore, ecc.)
            Text(
              messaggio,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}