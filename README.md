#  Mastermind

**Sviluppatore**: Potinga Adrian  
**Linguaggio**: Dart & Flutter


##  Descrizione del Progetto

Mastermind è un gioco di logica classico in cui il giocatore deve indovinare una sequenza segreta di 4 colori in massimo 10 tentativi.

### Come si Gioca

1. Tocca i 4 rettangoli grigi per cambiare colore (rosso, giallo, arancione)
2. Premi "Verifica" per controllare la combinazione
3. Leggi il feedback: quanti colori hai indovinato nella posizione giusta
4. Hai 10 tentativi per indovinare tutta la sequenza
5. Quando vinci o perdi, appare un popup con la sequenza segreta
6. Usa il bottone ↻ in alto per ricominciare


##  Scelte di Sviluppo

### StatefulWidget e setState()

Ho usato `StatefulWidget` perché il gioco deve aggiornare l'interfaccia quando:
- Cambio i colori dei cerchi
- Verifico la risposta
- Mostro i messaggi e i tentativi

`setState()` permette di ridisegnare solo le parti dell'interfaccia che cambiano, mantenendo l'app fluida.

### Liste per Organizzare i Dati

Tre liste gestiscono i colori del gioco:
- `colori`: i 3 colori disponibili (rosso, giallo, arancione)
- `segreto`: la sequenza da indovinare (generata casualmente)
- `scelta`: i colori selezionati dal giocatore

Usare liste indicizzate (0-3) rende facile accedere a ogni posizione e confrontare le sequenze.

### Ciclo dei Colori

Per il cambio ciclico dei colori uso l'operatore modulo:
```dart
scelta[i] = colori[(pos + 1) % colori.length];
```

Quando arrivo all'ultimo colore (arancione) e aggiungo 1, il modulo mi riporta al primo (rosso), creando un ciclo infinito.

### Generazione Casuale con List.generate()

Per creare la sequenza segreta uso:
```dart
segreto = List.generate(4, (_) => colori[random.nextInt(colori.length)]);
```

`List.generate()` crea una lista di 4 elementi, ognuno estratto casualmente. Questo garantisce che ogni partita sia diversa.

### Conteggio dei Colori Giusti

Confronto posizione per posizione le due liste:
```dart
for (int i = 0; i < 4; i++) {
  if (scelta[i] == segreto[i]) giusti++;
}
```

Questo metodo è semplice e diretto: conta solo i colori nella posizione esatta.

### Limite di 10 Tentativi

Ho aggiunto un contatore `tentativi` che si incrementa a ogni verifica:
```dart
if (tentativi >= 10) {
  messaggio = 'Hai perso! Tentativi finiti.';
}
```

Questo rende il gioco più sfidante e aggiunge una componente strategica.

### AlertDialog per la Sequenza Segreta

Uso `showDialog()` per mostrare un popup a fine partita:
```dart
showDialog(
  context: context,
  builder: (_) => AlertDialog(...)
);
```

Il popup blocca l'interazione e obbliga il giocatore a vedere la soluzione prima di ricominciare.

### Widget Riutilizzabile per i rettangolo

Ho creato una funzione che restituisce un widget cerchio:
```dart
Widget rettangolo(Color c, VoidCallback onTap)
```

Questo evita di ripetere 4 volte lo stesso codice e rende il programma più pulito.
