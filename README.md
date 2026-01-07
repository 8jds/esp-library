# ESP Library

not the most feature-rich library, but it will be, updating it every week (almost)

## Features

- **multiple box esp types**: 2D, Corner, and 3D
- **head dot esp**: just a dot in player head
- **sound esp**: ripples showing player movement
- **health bar**: health bar that simple
- **tracers**: lines that points players
- **name esp**: display player names
- **distance display**: show distance
- **player flags**: status indicators (SITTING, JUMPING, etc.)
- **look direction**: indicates wheres the player facing
- **team check**: filter by team
- **wall check**: hide players behind walls

## use

```lua
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/8jds/esp-library/refs/heads/main/library.lua"))()
```

## example

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

## configuration

all settings can be customized through `ESP.Settings`. See [example.lua](example.lua)

### Box Types

- **2D**: standart 2d box
- **Corner**: corner box
- **3D**: 3d box

## thats all
