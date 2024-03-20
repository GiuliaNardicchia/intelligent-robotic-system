# Composite behaviour
## Constraints
The robot should:
- find a light source and go towards it
  - reach the target as fast as possible (max_velocity = 15)
  - once reached it, it should stay close to it (either standing or moving)
- avoid collisions with other objects

The robot is equipped with both light and proximity sensors.

## Problems and possible solutions
- *composite_behaviour.argos* --> in questo file ci sono i cubi di default e un solo robot
  - Possibile soluzione: 
    Per ogni step (10 tick al secondo), vengono innanzitutto letti i valori dei sensori. Si effettua un controllo: se il totale dei sensori di luce supera una certa soglia di luce allora il robot va nello stato di REACHED_TARGET, se il totale dei sensori di prossimità supera una certa soglia di prossimità allora il robot raggiunge lo stato di OBSTACLE_AVOIDANCE, altrimenti rimane nello stato di SEARCHING_TARGET (che è anche quello iniziale).
    - SEARCHING_TARGET:
      - se la somma dei sensori di destra supera quella di sinistra allora gira a sinistra e viceversa, l'obiettivo è quello di avvicinarsi alla luce
    - OBSTACLE_AVOIDANCE:
      - se la somma di destra supera quella di sinistra allora gira a sinistra e viceversa, l'obiettivo in questo caso è quello di allontanarsi dall'oggetto
    - REACHED_TARGET
      - se ha raggiunto la luce si ferma
  - Problema: il robot raggiunge l'obiettivo senza problemi ma ha un andamento a zig-zag
  - Soluzione modificata: nel SEARCHING_TARGET imposto un controllo in più, se la metà frontale dei sensori supera la somma dei sensori dietro ed è pari a zero allora significa che il robot è disposto frontalmente rispetto alla luce e può avanzare dritto

- *composite_behaviour_more_blocks.argos* --> in questo file ho aumentato il numero di blocchi e impostato diverse dimensioni (alti e lunghi)
  - Problema: i blocchi alti ostruiscono la visuale dei sensori di luce e il robot non rileva l'intensità della luce
  - Soluzione modificata: aggiunta del movimento randomico (dopo un tot di step) se non rileva la luce e nella prossimità frontale non sono presenti ostacoli (che nella prima soluzione non serviva)

- *composite_behaviour_more_robots.argos* --> in questo file sono rimasti invariati i blocchi e ho aumentato il numero di robot (quantity = 3), per vedere che funziona anche con oggetti mobili
  - Problema: avevo impostato il fatto che dovessero continuare a girare in prossimità della luce, capitava che i robot si "spostassero" a vicenda dato che si rilevano come ostacoli
  - Soluzione modificata: quando il robot trova la luce si ferma

- *composite_behaviour_more_lights.argos* --> in questo file ho aumentato il numero di luci: ho lasciato quella centrale di intensità 1 e un'altra più spostata vicino al bordo, più bassa in altezza e con intensità inferiore
- Problema1: se l'intensità è troppo bassa, il valore di intensità luminosa rilevata totale non arriva mai a superare LIGHT_TRESHOLD e il robot gira in prossimità, è uno dei comportamenti possibili nella soluzione ma non voluto secondo la logica impostata
- Problema2: nel caso sfortunato i blocchi si dispongano a "V" e dietro c'è la luce, il robot continua a girare su se stesso perchè rileva sempre gli ostacoli, nonostante il movimento random non riesce ad uscire

## Other considerations
- impostare un valore di treshold, trovato con prove empiriche relative ad un ambiente non funziona più se cambiano le condizioni del mondo