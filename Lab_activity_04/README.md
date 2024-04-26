# Motor schemas architecture

## Task
The task required for this lab activity remains the same as in previous labs.

## Behaviours
Firstly, I defined the primary behaviors I wanted the robot to exhibit:
- ***Phototaxis***: the robot should find a light source and go towards it. 
The foot-bot should reach the target as fast as possible and, once reached it, it should stay close to it (either standing or moving);
- ***Obstacle avoidance***: the robot should avoid collisions with objects (such as walls, boxes and other robots);
- ***Tangential movement***: this behavior involves guiding the robot around an obstacle encountered in its path, enabling it to navigate smoothly without colliding;
- ***Uniform movement***: the robot should go in a given direction;
- ***Random movement***: the robot should also go random if it doesn't detect any light.

## Implementation
### Potential fields
In *[potential_field.lua](potential_field.lua)*, I established corresponding potential fields for each behavior:
- `attractive_field`:
  - If the *distance* to the light source is less than or equal to the threshold distance *D*, the function calculates a length for the attractive force vector.
  The *length* of the force vector is determined by the ratio of the difference between *D* and the actual *distance* to *D*. 
  This ratio is used to scale the attractive force, with the force being stronger when the robot is closer to the light source.
  - The *angle* of the force vector is set to the input angle parameter, indicating the desired direction of movement.
  - This setup ensures that the robot is attracted to the light source and moves towards it.
- `repulsive_field`:
  - The *length* of the force vector is calculated similarly for both the attractive and repulsive forces.
  - The negative sign is applied to the *angle* parameter for the repulsive force to ensure the robot is pushed away from obstacles.
- `tangential_field`:
  - The *length* of the force vector is set to the distance parameter.
  - The *angle* of the force vector is adjusted by adding *π/2* (90 degrees) to the input angle, enabling clockwise rotation.
  This adjustment ensures that the force vector is perpendicular to the obstacle, directing the robot tangentially around it.
- `uniform_field`: 
  - Used for both uniform movement and random movement.
  - The *length* of the force vector is set to the distance parameter, ensuring that the strength of the force remains consistent regardless of distance.
  - The *angle* of the force vector is set to the input angle parameter, indicating the desired direction of movement.

### Environment
The environment, *[test-motor_schemas.argos](test-motor_schemas.argos)*, is set up to test the laboratory.
Light and proximity sensor rays are activated to visually inspect whether the robot perceives stimuli or not.
Initially, I tested the controller with a single robot in the arena, then scaled up to 10 to ensure functionality in the presence of mobile objects.

### Utilities
*[utilities.lua](utilities.lua)* contains utility functions, and in this lab, I specifically utilized `search_highest_value`, which returns the index corresponding to the maximum value among all sensors.

*[performance.lua](performance.lua)* contains a function for computing the Euclidean distance between the robot's position and the target light source.
I employed this information, based on known positions, to establish the distance threshold *D*.

Within *[vector.lua](vector.lua)*, there are several utility functions provided by the Professor.
Primarily, I utilized the function `vector.vec2_polar_sum(v1,v2)` to add vectors (in polar coordinates) pairwise.

### Controller
*[controller-motor_schemas.lua](controller-motor_schemas.lua)* encapsulates the robot's controller logic.

Ho implementato un ***Perceptual Schema*** che usa i seguenti sensori:
- light
- proximity

Vengono definite alcune costanti utilizzate nel codice, come il numero di passi di movimento (`MOVE_STEPS`), 
la velocità massima (`MAX_VELOCITY`), le soglie per la luce (`LIGHT_THRESHOLD`), la prossimità (`PROXIMITY_THRESHOLD`) 
e il rumore (`NOISE_THRESHOLD`), oltre alla lunghezza dell'asse delle ruote (`L`) e alla distanza (`D`).

La funzioni di `init` e `reset` sono equivalenti, viene definita la costante globale `L`, il cui valore è ottenuto con `robot.wheels.axis_length` e `n_steps` viene posto pari a 0.

- In the `destroy` function, there are `log`s of the robot's position, the number of steps, and the calculation of the Euclidean distance to verify performance at the end of the simulation.

Nella funzione di `step`:
- innanzitutto vengono letti i valori dei sensori di luce e di prossimità, e vengono determinati gli indici corrispondenti al valore massimo rilevato per ciascun sensore.
- Dagli indici ottengo: *value* e *angle* per i due sensori e moltiplicando *value* per *D* ottengo la *distance* dalla luce.
- Vengono calcolati i vettori di forza per i comportamenti di attrazione, repulsione e movimento tangenziale utilizzando le funzioni `attractive_field`, `repulsive_field` e `tangential_field`.
- Vengono sommati i vettori risultanti a coppie utilizzando le coordinate polari.
- Ho aggiunto due controlli:
  - if the light is detected and there are no obstacle in the proximity allora al vettore risultato precedente aggiungo un ulteriore vettore per il movimento uniforme.
  Ho usato la funzione `uniform_field` passando come parametri una lunghezza costante e un angolo proporzionale a quello della luce rilevata.
  - if the light is not detected allora al vettore risultato precedente aggiungo un ulteriore vettore per il movimento random.
  Ho usato sempre la funzione `uniform_field` passando come parametri una lunghezza costante e un angolo ottenuto con `robot.random.uniform(-math.pi/5,math.pi/5)`.
- Motor commands expressed as translational and angular velocities are converted into differential actions (wheel velocities) using the `converter_from_rototransational_to_differential` function. 
- Afterwards, they are scaled to the maximum velocity using the `multiplier` function.
- Infine vengono impostate le velocità delle ruote del robot in base ai risultati ottenuti.

## Considerations
- Avendo impostato il movimento tangenziale solo di tipo clockwise, il robot girerà sempre a destra ed è possibile che ritrovandosi un ostacolo messo in una determinata posizione obblighi il robot a tornare indietro.
Ho deciso di non mettere però la possibilità di girare anche a sinistra poiché si incastrava più spesso nei casi in cui gli ostacoli erano posti davanti al target in una forma a cono.
- Personalmente non ho riscontrato il problema del ***Local Minima*** probabilmente perché era presente del rumore nei sensori di luce e di prossimità e forse perché ho aggiunto anche un campo costante uniforme e random in alcune circostanze.
