# Combat Name HUD

Version 1.0.0  
By Daft Fox

Combat Name HUD is a customizable combat name overlay that adds readable HUD labels for bosses during boss fights and temporary labels for regular enemies when they are hit. It enhances combat readability and identity without disrupting the game's natural flow.

The mod is configured through Mod Config Menu and includes animated previews so you can fine-tune visuals directly in-game.

## Requirements

- The Binding of Isaac: Repentance  
- Mod Config Menu (Pure/Impure)

## Optional

- REPENTOGON is supported and recommended for more accurate champion detection and modded entity names  
- Safe fallback behavior is used when REPENTOGON features are unavailable

## Main Features

- Boss name HUD during boss fights  
- Temporary enemy name HUD on damage  
- Separate configuration for bosses and enemies  
- Position modes: fixed, above entity, below entity  
- Adjustable scale, offsets, alpha, line spacing, and display time  
- Optional Boss/Enemy prefixes and text outline  
- Preset colors, custom RGB, Rainbow mode, and HP-based coloring  
- Boss intro animations, active effects, and death effects  
- Champion styling with optional descriptors  
- Hit feedback (flash and scale punch) and reactive shake  
- Full Mod Config Menu integration with live previews  
- Stable preview names with optional randomization  
- Compatible with current Mod Config Menu versions and forks  

## Configuration Overview

- **Info**: animated showcase of labels  
- **General**: shared settings (outline, previews, hit feedback, champions, reset/randomize)  
- **Boss**: visibility, position, grouping, colors, intro, effects, shake  
- **Enemy**: visibility, position, colors, effects, shake, display duration  

## Effects

### Active Effects
Disabled, Pulse, Bob, Pulse + Bob, Wiggle, Nervous, Drift, Breathing, Wave, Letter wave, Flicker, Magnet pull, Glitch, Heavy, Orbit, Toxic drift  

### Boss Intro Effects
Disabled, Fade + slide, Fade in, Pop in, Drop in, Rise in, Glitch in, Stomp in  

### Death Effects
Disabled, Fade out, Float up, Shrink, Explode, Slide left, Pop, Drop down, Dissolve, Slash cut, Drop + squash, Ring burst, Phase out, Split ghost, Implode, Toxic fade, Coin spark, Necro fade, Coin flip  

## Notes

- Champion styling is visual only  
- Enemy death effects only play on actual death  
- Expired labels do not trigger death animations  
- Boss labels can group repeated bosses for clarity  
- Multi-boss fights are handled with grouping and overflow `...`  
- In fixed mode, boss labels persist through hidden, burrowed, or invulnerable phases  