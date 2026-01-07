local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/8jds/esp-library/refs/heads/main/library.lua"))()

--// switch
ESP.Settings.Enabled = true

--// box esp
ESP.Settings.ShowBox = true

--// box esp type (Options: "2D", "Corner", "3D")
ESP.Settings.BoxType = "Corner"

--// name esp
ESP.Settings.ShowName = true

--// health bar
ESP.Settings.ShowHealth = true

--// tracers
ESP.Settings.ShowTracer = true

--// distance esp
ESP.Settings.ShowDistance = true

--// head dot
ESP.Settings.ShowHeadDot = true

--// sound esp
ESP.Settings.ShowSoundESP = true

ESP:Init()

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Delete then
        ESP.Settings.Enabled = not ESP.Settings.Enabled
        print("ESP " .. (ESP.Settings.Enabled and "Enabled" or "Disabled"))
    end
end)
