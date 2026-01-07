local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/8jds/esp-library/refs/heads/main/library.lua"))()

ESP.Settings.Enabled = true

ESP.Settings.ShowBox = true
ESP.Settings.BoxType = "Corner"
ESP.Settings.BoxColor = Color3.fromRGB(255, 255, 255)
ESP.Settings.BoxOutlineColor = Color3.fromRGB(255, 255, 255)
ESP.Settings.BoxThickness = 1
ESP.Settings.UseTeamColor = false

ESP.Settings.ShowName = true
ESP.Settings.NameColor = Color3.fromRGB(255, 255, 255)
ESP.Settings.NameSize = 13
ESP.Settings.ShowDisplayName = false

ESP.Settings.ShowHealth = true
ESP.Settings.HealthBarPosition = "Left"
ESP.Settings.HealthBarColor = Color3.fromRGB(0, 255, 0)
ESP.Settings.HealthBarLowColor = Color3.fromRGB(0, 255, 0)
ESP.Settings.ShowHealthText = true
ESP.Settings.HealthAnimation = true

ESP.Settings.ShowTracer = true
ESP.Settings.TracerColor = Color3.fromRGB(255, 255, 255)
ESP.Settings.TracerThickness = 1
ESP.Settings.TracerPosition = "Bottom"
ESP.Settings.TracerUseTeamColor = false

ESP.Settings.ShowDistance = true
ESP.Settings.DistanceColor = Color3.fromRGB(255, 255, 255)
ESP.Settings.DistanceSize = 12
ESP.Settings.MaxDistance = 2000

ESP.Settings.ShowHeadDot = true
ESP.Settings.HeadDotColor = Color3.fromRGB(255, 255, 255)
ESP.Settings.HeadDotSize = 8
ESP.Settings.HeadDotFilled = false
ESP.Settings.HeadDotOutline = false
ESP.Settings.HeadDotOutlineColor = Color3.fromRGB(0, 0, 0)
ESP.Settings.HeadDotUseTeamColor = false

ESP.Settings.ShowSoundESP = true
ESP.Settings.SoundESPColor = Color3.fromRGB(255, 255, 255)
ESP.Settings.SoundESPThickness = 2
ESP.Settings.SoundESPMaxRadius = 50
ESP.Settings.SoundESPDuration = 1.5
ESP.Settings.SoundESPTickDelay = 0.3

ESP.Settings.ShowFlags = false -- beta
ESP.Settings.FlagColor = Color3.fromRGB(255, 100, 100)
ESP.Settings.FlagSize = 11

ESP.Settings.ShowLookDirection = false
ESP.Settings.LookDirectionColor = Color3.fromRGB(0, 255, 255)
ESP.Settings.LookDirectionLength = 3
ESP.Settings.LookDirectionThickness = 2

ESP.Settings.TeamCheck = false
ESP.Settings.WallCheck = false
ESP.Settings.FadeWithDistance = false -- beta

ESP:Init()

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Delete then
        ESP.Settings.Enabled = not ESP.Settings.Enabled
        print("ESP " .. (ESP.Settings.Enabled and "Enabled" or "Disabled"))
    end
end)
