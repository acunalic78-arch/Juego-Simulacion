AeroClash Complete - Proyecto Godot 4
====================================

Escena principal:
res://Scenes/MainMenu.tscn

Modos:
- Historia 1 jugador
- Score Battle 2 jugadores
- PvP Arena 1 vs 1
- Cooperativo
- Desempate automático

Controles:
P1: WASD + SPACE, bomba Q / Gamepad 1
P2: Flechas + ENTER, bomba SHIFT / Gamepad 2

Sistema implementado:
- Score separado
- Vidas separadas
- HUD completo
- Enemigos aleatorios con probabilidades
- Dificultad por niveles
- Jefe final
- Disparos enemigos aleatorios
- Items aleatorios
- Records TOP 5 guardados en user://aeroclash_records.json

Para cambiar gráficos:
Los objetos se dibujan con ColorRect en código. Puedes reemplazar cada ColorRect por Sprite2D en:
Scripts/Entities/PlayerShip.gd
Scripts/Entities/EnemyShip.gd
Scripts/Entities/BossShip.gd
Scripts/Entities/PowerItem.gd
Scripts/Entities/PlayerBullet.gd
Scripts/Entities/EnemyBullet.gd


Actualización PvP Arena:
- En PvP los enemigos aparecen dentro de la zona central.
- 40% salen desde arriba hacia abajo, 40% salen desde abajo hacia arriba y 20% cruzan por el centro.
- Los items aparecen aleatoriamente en el centro para que ambos jugadores compitan por ellos.
