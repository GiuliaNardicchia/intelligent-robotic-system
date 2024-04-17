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

Vengono definite alcune costanti utilizzate nel codice, come il numero di passi di movimento (`MOVE_STEPS`), la velocità massima (`MAX_VELOCITY`), le soglie per la luce (`LIGHT_THRESHOLD`), la prossimità (`PROXIMITY_THRESHOLD`) e il rumore (`NOISE_THRESHOLD`), oltre alla lunghezza dell'asse delle ruote (`L`) e alla distanza (`D`).

To convert motor commands that are expressed in the form of translational and angular
velocities into differential actions (wheel velocities) I used the formulas expressed in the function `converter_from_rototransational_to_differential` e `multiplier`, utilizzate per la conversione tra movimento roto-traslazionale e differenziale, nonché per moltiplicare le velocità delle ruote.

Nella funzione di step:
- innanzitutto ottengo l'indice corrispondente al maggior valore riscontrato sia nei sensori di luce sia nei sensori di prossimità usando la funzione di utilità `search_highest_value`. 
Ottengo poi il valore di lenght e di angle corrispondenti all'indice e passo i valori alle funzioni `attractive_field` e `repulsive_field` per ottenere i vettori risultanti. Allo stesso modo con `tangential_field`. 
E ho sommato i vettori a coppie due a due con le coordinate polari. 
A questo punto ho applicato una conversione da movimento roto-traslazionale a differenziale e ho ottenuto la velocità delle ruote sinistra e destra e applicando un moltiplicatore li ho passati come input al robot (attuatori). 
Ho implementato un Perceptual Schema per un sensore, ricavo il sensore che percepisce il maggior valore 
