# ESP Library

A powerful and feature-rich ESP (Extra Sensory Perception) library for Roblox with multiple visualization modes and customization options.

## Features

- **Multiple Box Modes**: 2D, Corner, and 3D box ESP
- **Head Dot ESP**: Circular markers on player heads
- **Sound ESP**: Animated ripples showing player movement
- **Health Bars**: Animated health bars with color transitions
- **Tracers**: Lines pointing to players
- **Name Tags**: Display player names
- **Distance Display**: Show distance in studs
- **Player Flags**: Status indicators (SITTING, JUMPING, etc.)
- **Look Direction**: Visual indicator of where players are facing
- **Team Check**: Filter by team
- **Wall Check**: Hide players behind walls
- **Distance Fading**: ESP fades based on distance

## Installation

```lua
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/linemaster2/esp-library/main/library.lua"))()
```

## Quick Start

```lua
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/linemaster2/esp-library/main/library.lua"))()

-- Enable ESP
ESP.Settings.Enabled = true
ESP.Settings.ShowBox = true
ESP.Settings.BoxType = "Corner" -- Options: "2D", "Corner", "3D"
ESP.Settings.ShowName = true
ESP.Settings.ShowHealth = true
ESP.Settings.ShowTracer = true

-- Initialize
ESP:Init()
```

## Controls

- **DELETE Key**: Toggle ESP on/off

## Configuration

All settings can be customized through `ESP.Settings`. See [example.lua](example.lua) for a complete list of available options.

### Box Types

- **2D**: Standard rectangular box
- **Corner**: Corner brackets (white by default)
- **3D**: Full 3D bounding box (white by default)

### Key Settings

```lua
ESP.Settings.Enabled = true              -- Master toggle
ESP.Settings.ShowBox = true              -- Show boxes
ESP.Settings.BoxType = "Corner"          -- Box style
ESP.Settings.ShowName = true             -- Show names
ESP.Settings.ShowHealth = true           -- Show health bars
ESP.Settings.ShowTracer = true           -- Show tracers
ESP.Settings.ShowDistance = true         -- Show distance
ESP.Settings.ShowHeadDot = true          -- Show head dots
ESP.Settings.ShowSoundESP = true         -- Show movement ripples
ESP.Settings.TeamCheck = false           -- Only show enemies
ESP.Settings.MaxDistance = 2000          -- Maximum render distance
```

## Advanced Features

### Sound ESP
Displays animated white circles at players' feet when they move, creating a sonar-like effect.

### Head Dot
Places a circular marker directly on each player's head for quick identification.

### Health Animation
Smooth health bar transitions with color gradients from red (low) to green (full).

## License

MIT License - Feel free to use and modify as needed.
