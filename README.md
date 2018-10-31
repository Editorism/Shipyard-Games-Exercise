# Shipyard Games Exercise
Coding exercise made based on Shipyard Games' job application exercise

Additions to base project:
- Boxes now jump in random directions
- Score, Countdown timer and Color match sprite added as a SpriteKit OverlayScene
- Game "ends" after countdown (game scene pauses and box spawning stops, finish UI label displayed)

The goal of the game is to destroy as many boxes as possible within 60 seconds by clicking the boxes that match the color indicator in the upper right corner of the UI. The indicator changes color every 5 seconds.

Match = +1 point

Mismatch = -1 point
