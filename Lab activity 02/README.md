# Composite behaviour
## Constraints
The robot should:
- find a light source and go towards it
  - reach the target as fast as possible (MAX_VELOCITY = 15)
  - once reached it, it should stay close to it (either standing or moving)
- avoid collisions with other objects (such as walls, boxes and other robots).

The robot is equipped with both light and proximity sensors.

## Problems and possible solutions
- *utilities.lua* --> contiene alcune funzioni di utilità: move, search_highest_value, read_half_sensors.

- *composite_behaviour.lua* --> contiene la logica del controller del robot. Ho sviluppato una soluzione al problema usando un approccio di tipo arbitration classico e ho suddiviso il comportamento del robot in quattro stati principali.
  Descrizione:
  - Come prima cosa ho definito le variabili globali che rappresentano i valori di soglia: MOVE_STEPS = 15, MAX_VELOCITY = 15, LIGHT_THRESHOLD = 1.9 e PROXIMITY_THRESHOLD = 0.
  - La funzione di *init* e *reset* sono identiche e stabiliscono un movimento iniziale randomico, n_steps pari a 0 e inizializzano lo stato del robot in `SEARCHING_TARGET`.
  - La funzione di *destroy* l'ho lasciata vuota.
  - La funzione di *step*, che contiene la vera logica del controller, viene eseguita ogni 10 ticks per second. Innanzitutto vengono letti i valori dei sensori di luce e di prossimità: calcolando la somma della metà dei sensori in base all'orientamento stabilito (orizzontale sinistra/destra e in verticale fronte/retro). Si effettuano poi i controlli per verificare in quale stato si trova il robot:
  - se almeno una delle due parti (laterale sinistra o destra) non ha rilevato una luce o se non ha rilevato nessuno oggetto frontalmente allora il robot si trova nello stato di:
    - `RANDOM_WALK`: esegue una camminata random.
  - se la somma totale di tutti i sensori di prossimità supera una certa soglia, il robot si trova nello stato di:
    - `OBSTACLE_AVOIDANCE`: se la somma dei sensori di prossimità di destra supera quella di sinistra allora gira a sinistra e viceversa, l'obiettivo in questo caso è quello di allontanarsi dall'oggetto.
  - se la somma totale di tutti i sensori di luce supera una certa soglia allora si trova nello stato di:
    - `REACHED_TARGET`: ha raggiunto l'obiettivo e quindi si deve fermare.
  - se nessuna delle condizioni precedenti ha successo, allora il robot rimane nello stato di:
    - `SEARCHING_TARGET`: se la somma dei sensori di luce frontali è maggiore rispetto a quelli dietro e non ha rilevato nulla dietro, allora vuol dire che è posizionato di fronte alla luce e si può muovere in avanti andando al massimo della velocità. Altrimenti si effettua un ulteriore controllo per ricalibrare la posizione del robot: se la somma dei sensori di destra supera quella di sinistra allora gira a sinistra e viceversa, l'obiettivo è quello di avvicinarsi alla luce.

Per ciascun file .argos ho impostato un random_seed per avere la possibilità di riprodurre l'esperimento per vedere come cambia il comportamento del robot al variare delle soglie che ho impostato e in seguito ho modificato anche tale valore per vedere come cambia il comportamento al variare dell'ambiente.

- *01_composite_behaviour.argos* --> in questo file ho lasciato i blocchi a forma di cubo e un solo robot
  - Problema: inizialmente non avevo fatto la suddivisione della parte frontale e dietro per i sensori di luce per fare andare dritto il robot e quindi c'era il problema che aveva un andamento a zig-zag anche se raggiungeva l'obiettivo senza difficoltà
  - Soluzione modificata: nel `SEARCHING_TARGET` imposto un controllo in più, se la metà frontale dei sensori supera la somma dei sensori dietro e dietro non rileva nessuna luce allora significa che il robot è disposto frontalmente rispetto alla luce e può avanzare dritto

- *02_composite_behaviour_more_blocks.argos* --> in questo file ho aumentato il numero di blocchi e impostato diverse dimensioni (alti e lunghi)
  - Problema: i blocchi alti ostruivano la visuale dei sensori di luce e il robot non riesce a rilevare l'intensità della luce
  - Soluzione modificata: ho aggiunto il movimento randomico (dopo un tot di step) se non rileva la luce e nella prossimità frontale non sono presenti ostacoli (che nella prima soluzione, con un tipo di ambiente più favorevole e semplice non serviva)

- *03_composite_behaviour_more_robots.argos* --> in questo file sono rimasti invariati i blocchi e ho aumentato il numero di robot (quantity = 3), per vedere coome si comportava con oggetti mobili
  - Problema: avevo impostato il fatto che dovessero continuare a girare in prossimità della luce, capitava che i robot si "spostassero" a vicenda dato che si rilevano come ostacoli
  - Soluzione modificata: quando il robot trova la luce si ferma

- *04_composite_behaviour_more_lights.argos* --> in questo file ho aumentato il numero di luci: ho lasciato quella centrale di intensità 1 e un'altra più spostata vicino al bordo, più bassa in altezza e con intensità inferiore
- Problema1: se l'intensità è troppo bassa, il valore di intensità luminosa rilevata totale non arriva mai a superare LIGHT_TRESHOLD e il robot gira in prossimità, è uno dei comportamenti possibili nella soluzione ma non voluto secondo la logica impostata
- Problema2: nel caso sfortunato i blocchi si dispongano a cono e dietro c'è la luce, il robot continua a girare su se stesso perchè rileva sempre gli ostacoli, a volte nonostante il movimento random non riesce ad uscire

## Other considerations
- impostare un valore di treshold, trovato con prove empiriche relative ad un ambiente non funziona più se cambiano le condizioni del mondo