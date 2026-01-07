local ESP_Library = {}
ESP_Library.__index = ESP_Library

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local cache = {}
local connections = {}

ESP_Library.Settings = {
    Enabled = true,
    TeamCheck = false,
    WallCheck = false,
    MaxDistance = 2000,
    FadeWithDistance = true,
    ShowBox = true,
    BoxType = "2D",
    BoxColor = Color3.fromRGB(255, 255, 255),
    BoxOutlineColor = Color3.fromRGB(0, 0, 0),
    BoxThickness = 1,
    UseTeamColor = false,
    ShowSoundESP = true,
    SoundESPColor = Color3.fromRGB(255, 255, 255),
    SoundESPThickness = 2,
    SoundESPMaxRadius = 50,
    SoundESPDuration = 1.5,
    SoundESPTickDelay = 0.3,
    ShowHeadDot = true,
    HeadDotColor = Color3.fromRGB(255, 255, 255),
    HeadDotSize = 8,
    HeadDotFilled = true,
    HeadDotOutline = true,
    HeadDotOutlineColor = Color3.fromRGB(0, 0, 0),
    HeadDotUseTeamColor = false,
    ShowName = true,
    NameColor = Color3.fromRGB(255, 255, 255),
    NameSize = 13,
    NameOutline = true,
    NameFont = 2,
    ShowDisplayName = false,
    ShowHealth = true,
    HealthBarColor = Color3.fromRGB(0, 255, 0),
    HealthBarLowColor = Color3.fromRGB(255, 0, 0),
    HealthBarPosition = "Left",
    ShowHealthText = true,
    HealthTextColor = Color3.fromRGB(255, 255, 255),
    HealthAnimation = true,
    ShowDistance = true,
    DistanceColor = Color3.fromRGB(255, 255, 255),
    DistanceSize = 12,
    ShowTracer = true,
    TracerColor = Color3.fromRGB(255, 255, 255),
    TracerThickness = 1,
    TracerTransparency = 1,
    TracerPosition = "Bottom",
    TracerUseTeamColor = false,
    ShowFlags = true,
    FlagColor = Color3.fromRGB(255, 100, 100),
    FlagSize = 11,
    ShowLookDirection = false,
    LookDirectionColor = Color3.fromRGB(0, 255, 255),
    LookDirectionLength = 3,
    LookDirectionThickness = 2,
    ShowSkeleton = false,
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    SkeletonThickness = 1,
    SkeletonUseTeamColor = false,
    ShowWeapon = false,
    WeaponColor = Color3.fromRGB(255, 255, 0),
    WeaponSize = 12,
    ShowFOVCircle = false,
    FOVCircleRadius = 100,
    FOVCircleColor = Color3.fromRGB(255, 255, 255),
    FOVCircleThickness = 1,
    FOVCircleFilled = false,
    ShowChams = false,
    ChamsColor = Color3.fromRGB(255, 0, 255),
    ChamsTransparency = 0.3,
    ChamsFillColor = Color3.fromRGB(255, 100, 255),
    ChamsFillTransparency = 0.5,
    ChamsUseTeamColor = false,
    ShowOutOfViewArrows = false,
    ArrowColor = Color3.fromRGB(255, 255, 255),
    ArrowSize = 20,
    ShowOnlyVisible = false,
}

local function createDrawing(class, properties)
    local drawing = Drawing.new(class)
    for property, value in pairs(properties) do
        pcall(function()
            drawing[property] = value
        end)
    end
    return drawing
end

local function getTeamColor(player)
    if player.Team then
        return player.TeamColor.Color
    end
    return Color3.fromRGB(255, 255, 255)
end

local function isPlayerVisible(player)
    local character = player.Character
    if not character then return false end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    
    local ray = Ray.new(
        camera.CFrame.Position,
        (rootPart.Position - camera.CFrame.Position).Unit * 
        (rootPart.Position - camera.CFrame.Position).Magnitude
    )
    
    local hit = Workspace:FindPartOnRayWithIgnoreList(
        ray,
        {localPlayer.Character, character}
    )
    
    return not hit
end

local function getPlayerFlags(player)
    local flags = {}
    
    if player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            if humanoid.Sit then table.insert(flags, "SITTING") end
            if humanoid.Jump then table.insert(flags, "JUMPING") end
            if humanoid.PlatformStand then table.insert(flags, "RAGDOLL") end
            if humanoid.Health <= 0 then table.insert(flags, "DEAD") end
        end
    end
    
    return flags
end

function ESP_Library:CreateESP(player)
    if cache[player] then return end
    
    local esp = {
        boxOutline = createDrawing("Square", {
            Color = ESP_Library.Settings.BoxOutlineColor,
            Thickness = 3,
            Filled = false,
            Transparency = 0,
            Visible = false
        }),
        box = createDrawing("Square", {
            Color = ESP_Library.Settings.BoxColor,
            Thickness = ESP_Library.Settings.BoxThickness,
            Filled = false,
            Transparency = 0,
            Visible = false
        }),
        name = createDrawing("Text", {
            Color = ESP_Library.Settings.NameColor,
            Outline = ESP_Library.Settings.NameOutline,
            Center = true,
            Size = ESP_Library.Settings.NameSize,
            Font = ESP_Library.Settings.NameFont,
            Transparency = 1,
            Visible = false
        }),
        healthOutline = createDrawing("Line", {
            Thickness = 4,
            Color = ESP_Library.Settings.BoxOutlineColor,
            Transparency = 1,
            Visible = false
        }),
        health = createDrawing("Line", {
            Thickness = 2,
            Color = ESP_Library.Settings.HealthBarColor,
            Transparency = 1,
            Visible = false
        }),
        healthText = createDrawing("Text", {
            Color = ESP_Library.Settings.HealthTextColor,
            Size = 11,
            Center = true,
            Outline = true,
            Font = 2,
            Transparency = 1,
            Visible = false
        }),
        distance = createDrawing("Text", {
            Color = ESP_Library.Settings.DistanceColor,
            Size = ESP_Library.Settings.DistanceSize,
            Outline = true,
            Center = true,
            Font = 2,
            Transparency = 1,
            Visible = false
        }),
        tracer = createDrawing("Line", {
            Thickness = ESP_Library.Settings.TracerThickness,
            Color = ESP_Library.Settings.TracerColor,
            Transparency = ESP_Library.Settings.TracerTransparency,
            Visible = false
        }),
        flags = createDrawing("Text", {
            Color = ESP_Library.Settings.FlagColor,
            Size = ESP_Library.Settings.FlagSize,
            Outline = true,
            Center = false,
            Font = 2,
            Transparency = 1,
            Visible = false
        }),
        lookLine = createDrawing("Line", {
            Thickness = ESP_Library.Settings.LookDirectionThickness,
            Color = ESP_Library.Settings.LookDirectionColor,
            Transparency = 1,
            Visible = false
        }),
        arrow = createDrawing("Triangle", {
            Color = ESP_Library.Settings.ArrowColor,
            Filled = true,
            Transparency = 1,
            Visible = false
        }),
        headDotOutline = createDrawing("Circle", {
            Color = ESP_Library.Settings.HeadDotOutlineColor,
            Thickness = 3,
            NumSides = 32,
            Radius = ESP_Library.Settings.HeadDotSize + 1,
            Filled = false,
            Transparency = 1,
            Visible = false
        }),
        headDot = createDrawing("Circle", {
            Color = ESP_Library.Settings.HeadDotColor,
            Thickness = 2,
            NumSides = 32,
            Radius = ESP_Library.Settings.HeadDotSize,
            Filled = ESP_Library.Settings.HeadDotFilled,
            Transparency = 1,
            Visible = false
        }),
        boxLines = {},
        box3DLines = {},
        chams = {},
        animatedHealth = 100,
        soundRipples = {},
        lastPosition = nil,
        lastMoveTime = 0,
    }
    
    cache[player] = esp
end

function ESP_Library:UpdateESP()
    if not ESP_Library.Settings.Enabled then
        for _, esp in pairs(cache) do
            for _, drawing in pairs(esp) do
                if type(drawing) == "userdata" and drawing.Visible ~= nil then
                    drawing.Visible = false
                end
            end
        end
        return
    end
    
    for player, esp in pairs(cache) do
        if not player or player == localPlayer then continue end
        
        local character = player.Character
        local shouldShow = true
        
        if ESP_Library.Settings.TeamCheck and player.Team == localPlayer.Team then
            shouldShow = false
        end
        
        if ESP_Library.Settings.WallCheck and not isPlayerVisible(player) then
            shouldShow = false
        end
        
        if character and shouldShow then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local head = character:FindFirstChild("Head")
            local humanoid = character:FindFirstChild("Humanoid")
            
            if rootPart and head and humanoid then
                local distance = (camera.CFrame.Position - rootPart.Position).Magnitude
                
                if distance > ESP_Library.Settings.MaxDistance then
                    shouldShow = false
                end
                
                local position, onScreen = camera:WorldToViewportPoint(rootPart.Position)
                
                if onScreen and shouldShow then
                    local headPos = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local legPos = camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
                    
                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height / 2
                    
                    local boxSize = Vector2.new(width, height)
                    local boxPos = Vector2.new(position.X - width / 2, position.Y - height / 2)
                    
                    local transparency = 1
                    if ESP_Library.Settings.FadeWithDistance then
                        transparency = math.clamp(1 - (distance / ESP_Library.Settings.MaxDistance), 0.3, 1)
                    end
                    
                    local teamColor = ESP_Library.Settings.BoxColor
                    if ESP_Library.Settings.BoxType == "Corner" or ESP_Library.Settings.BoxType == "3D" then
                        teamColor = Color3.fromRGB(255, 255, 255)
                    elseif ESP_Library.Settings.UseTeamColor then
                        teamColor = getTeamColor(player)
                    end
                    
                    if ESP_Library.Settings.ShowBox then
                        if ESP_Library.Settings.BoxType == "2D" then
                            for _, line in ipairs(esp.boxLines) do
                                line.Visible = false
                            end
                            for _, line in ipairs(esp.box3DLines) do
                                line.Visible = false
                            end
                            
                            esp.boxOutline.Size = boxSize
                            esp.boxOutline.Position = boxPos
                            esp.boxOutline.Visible = true
                            
                            esp.box.Size = boxSize
                            esp.box.Position = boxPos
                            esp.box.Color = teamColor
                            esp.box.Transparency = transparency
                            esp.box.Visible = true
                            
                        elseif ESP_Library.Settings.BoxType == "Corner" then
                            esp.box.Visible = false
                            esp.boxOutline.Visible = false
                            for _, line in ipairs(esp.box3DLines) do
                                line.Visible = false
                            end
                            
                            local lineW = width / 4
                            local lineH = height / 5
                            
                            if #esp.boxLines == 0 then
                                for i = 1, 16 do
                                    local line = createDrawing("Line", {
                                        Thickness = ESP_Library.Settings.BoxThickness,
                                        Color = teamColor,
                                        Transparency = transparency
                                    })
                                    table.insert(esp.boxLines, line)
                                end
                            end
                            
                            esp.boxLines[1].From = boxPos
                            esp.boxLines[1].To = Vector2.new(boxPos.X + lineW, boxPos.Y)
                            esp.boxLines[2].From = boxPos
                            esp.boxLines[2].To = Vector2.new(boxPos.X, boxPos.Y + lineH)
                            
                            esp.boxLines[3].From = Vector2.new(boxPos.X + boxSize.X, boxPos.Y)
                            esp.boxLines[3].To = Vector2.new(boxPos.X + boxSize.X - lineW, boxPos.Y)
                            esp.boxLines[4].From = Vector2.new(boxPos.X + boxSize.X, boxPos.Y)
                            esp.boxLines[4].To = Vector2.new(boxPos.X + boxSize.X, boxPos.Y + lineH)
                            
                            esp.boxLines[5].From = Vector2.new(boxPos.X, boxPos.Y + boxSize.Y)
                            esp.boxLines[5].To = Vector2.new(boxPos.X + lineW, boxPos.Y + boxSize.Y)
                            esp.boxLines[6].From = Vector2.new(boxPos.X, boxPos.Y + boxSize.Y)
                            esp.boxLines[6].To = Vector2.new(boxPos.X, boxPos.Y + boxSize.Y - lineH)
                            
                            esp.boxLines[7].From = Vector2.new(boxPos.X + boxSize.X, boxPos.Y + boxSize.Y)
                            esp.boxLines[7].To = Vector2.new(boxPos.X + boxSize.X - lineW, boxPos.Y + boxSize.Y)
                            esp.boxLines[8].From = Vector2.new(boxPos.X + boxSize.X, boxPos.Y + boxSize.Y)
                            esp.boxLines[8].To = Vector2.new(boxPos.X + boxSize.X, boxPos.Y + boxSize.Y - lineH)
                            
                            for i = 9, 16 do
                                esp.boxLines[i].Thickness = 3
                                esp.boxLines[i].Color = ESP_Library.Settings.BoxOutlineColor
                                esp.boxLines[i].Transparency = transparency
                                esp.boxLines[i].From = esp.boxLines[i - 8].From
                                esp.boxLines[i].To = esp.boxLines[i - 8].To
                            end
                            
                            for i = 1, 8 do
                                esp.boxLines[i].Color = teamColor
                                esp.boxLines[i].Transparency = transparency
                                esp.boxLines[i].Visible = true
                            end
                            for i = 9, 16 do
                                esp.boxLines[i].Visible = true
                            end
                            
                        elseif ESP_Library.Settings.BoxType == "3D" then
                            esp.box.Visible = false
                            esp.boxOutline.Visible = false
                            for _, line in ipairs(esp.boxLines) do
                                line.Visible = false
                            end
                            
                            if #esp.box3DLines == 0 then
                                for i = 1, 24 do
                                    local line = createDrawing("Line", {
                                        Thickness = ESP_Library.Settings.BoxThickness,
                                        Color = teamColor,
                                        Transparency = transparency
                                    })
                                    table.insert(esp.box3DLines, line)
                                end
                            end
                            
                            local size = Vector3.new(2, 5, 2)
                            local cf = rootPart.CFrame
                            
                            local corners = {
                                cf * CFrame.new(-size.X/2, -size.Y/2, -size.Z/2),
                                cf * CFrame.new(size.X/2, -size.Y/2, -size.Z/2),
                                cf * CFrame.new(-size.X/2, -size.Y/2, size.Z/2),
                                cf * CFrame.new(size.X/2, -size.Y/2, size.Z/2),
                                cf * CFrame.new(-size.X/2, size.Y/2, -size.Z/2),
                                cf * CFrame.new(size.X/2, size.Y/2, -size.Z/2),
                                cf * CFrame.new(-size.X/2, size.Y/2, size.Z/2),
                                cf * CFrame.new(size.X/2, size.Y/2, size.Z/2),
                            }
                            
                            local screenCorners = {}
                            local allVisible = true
                            for _, corner in ipairs(corners) do
                                local screenPos, visible = camera:WorldToViewportPoint(corner.Position)
                                table.insert(screenCorners, Vector2.new(screenPos.X, screenPos.Y))
                                if not visible or screenPos.Z < 0 then
                                    allVisible = false
                                end
                            end
                            
                            if allVisible then
                                local edges = {
                                    {1, 2}, {3, 4}, {5, 6}, {7, 8},
                                    {1, 3}, {2, 4}, {5, 7}, {6, 8},
                                    {1, 5}, {2, 6}, {3, 7}, {4, 8},
                                }
                                
                                for i = 1, 12 do
                                    local edge = edges[i]
                                    local line = esp.box3DLines[i + 12]
                                    line.From = screenCorners[edge[1]]
                                    line.To = screenCorners[edge[2]]
                                    line.Color = ESP_Library.Settings.BoxOutlineColor
                                    line.Thickness = 3
                                    line.Transparency = transparency
                                    line.Visible = true
                                end
                                
                                for i = 1, 12 do
                                    local edge = edges[i]
                                    local line = esp.box3DLines[i]
                                    line.From = screenCorners[edge[1]]
                                    line.To = screenCorners[edge[2]]
                                    line.Color = teamColor
                                    line.Thickness = ESP_Library.Settings.BoxThickness
                                    line.Transparency = transparency
                                    line.Visible = true
                                end
                            else
                                for _, line in ipairs(esp.box3DLines) do
                                    line.Visible = false
                                end
                            end
                        end
                    else
                        esp.box.Visible = false
                        esp.boxOutline.Visible = false
                        for _, line in ipairs(esp.boxLines) do
                            line.Visible = false
                        end
                        for _, line in ipairs(esp.box3DLines) do
                            line.Visible = false
                        end
                    end
                    
                    if ESP_Library.Settings.ShowName then
                        local displayName = ESP_Library.Settings.ShowDisplayName and player.DisplayName or player.Name
                        esp.name.Text = displayName
                        esp.name.Position = Vector2.new(boxPos.X + boxSize.X / 2, boxPos.Y - 18)
                        esp.name.Color = ESP_Library.Settings.UseTeamColor and teamColor or ESP_Library.Settings.NameColor
                        esp.name.Transparency = transparency
                        esp.name.Visible = true
                    else
                        esp.name.Visible = false
                    end
                    
                    if ESP_Library.Settings.ShowHeadDot then
                        local headPosition, headOnScreen = camera:WorldToViewportPoint(head.Position)
                        
                        if headOnScreen and headPosition.Z > 0 then
                            local dotColor = ESP_Library.Settings.HeadDotUseTeamColor and getTeamColor(player) or ESP_Library.Settings.HeadDotColor
                            
                            if ESP_Library.Settings.HeadDotOutline then
                                esp.headDotOutline.Position = Vector2.new(headPosition.X, headPosition.Y)
                                esp.headDotOutline.Radius = ESP_Library.Settings.HeadDotSize + 1
                                esp.headDotOutline.Transparency = transparency
                                esp.headDotOutline.Visible = true
                            else
                                esp.headDotOutline.Visible = false
                            end
                            
                            esp.headDot.Position = Vector2.new(headPosition.X, headPosition.Y)
                            esp.headDot.Radius = ESP_Library.Settings.HeadDotSize
                            esp.headDot.Color = dotColor
                            esp.headDot.Filled = ESP_Library.Settings.HeadDotFilled
                            esp.headDot.Transparency = transparency
                            esp.headDot.Visible = true
                        else
                            esp.headDot.Visible = false
                            esp.headDotOutline.Visible = false
                        end
                    else
                        esp.headDot.Visible = false
                        esp.headDotOutline.Visible = false
                    end
                    
                    if ESP_Library.Settings.ShowHealth then
                        local healthPercent = humanoid.Health / humanoid.MaxHealth
                        
                        if ESP_Library.Settings.HealthAnimation then
                            esp.animatedHealth = esp.animatedHealth + (humanoid.Health - esp.animatedHealth) * 0.1
                        else
                            esp.animatedHealth = humanoid.Health
                        end
                        
                        local animHealthPercent = esp.animatedHealth / humanoid.MaxHealth
                        local healthColor = ESP_Library.Settings.HealthBarLowColor:Lerp(
                            ESP_Library.Settings.HealthBarColor,
                            healthPercent
                        )
                        
                        local healthBarLength = boxSize.Y * animHealthPercent
                        
                        if ESP_Library.Settings.HealthBarPosition == "Left" then
                            esp.healthOutline.From = Vector2.new(boxPos.X - 6, boxPos.Y + boxSize.Y)
                            esp.healthOutline.To = Vector2.new(boxPos.X - 6, boxPos.Y)
                            
                            esp.health.From = Vector2.new(boxPos.X - 5, boxPos.Y + boxSize.Y)
                            esp.health.To = Vector2.new(boxPos.X - 5, boxPos.Y + boxSize.Y - healthBarLength)
                            esp.health.Color = healthColor
                            
                            if ESP_Library.Settings.ShowHealthText then
                                esp.healthText.Position = Vector2.new(boxPos.X - 5, boxPos.Y + boxSize.Y / 2)
                                esp.healthText.Text = tostring(math.floor(humanoid.Health))
                                esp.healthText.Visible = true
                            end
                        elseif ESP_Library.Settings.HealthBarPosition == "Right" then
                            esp.healthOutline.From = Vector2.new(boxPos.X + boxSize.X + 6, boxPos.Y + boxSize.Y)
                            esp.healthOutline.To = Vector2.new(boxPos.X + boxSize.X + 6, boxPos.Y)
                            
                            esp.health.From = Vector2.new(boxPos.X + boxSize.X + 5, boxPos.Y + boxSize.Y)
                            esp.health.To = Vector2.new(boxPos.X + boxSize.X + 5, boxPos.Y + boxSize.Y - healthBarLength)
                            esp.health.Color = healthColor
                            
                            if ESP_Library.Settings.ShowHealthText then
                                esp.healthText.Position = Vector2.new(boxPos.X + boxSize.X + 5, boxPos.Y + boxSize.Y / 2)
                                esp.healthText.Text = tostring(math.floor(humanoid.Health))
                                esp.healthText.Visible = true
                            end
                        end
                        
                        esp.healthOutline.Transparency = transparency
                        esp.health.Transparency = transparency
                        esp.healthOutline.Visible = true
                        esp.health.Visible = true
                    else
                        esp.healthOutline.Visible = false
                        esp.health.Visible = false
                        esp.healthText.Visible = false
                    end
                    
                    if ESP_Library.Settings.ShowDistance then
                        esp.distance.Text = string.format("%.1f studs", distance)
                        esp.distance.Position = Vector2.new(boxPos.X + boxSize.X / 2, boxPos.Y + boxSize.Y + 5)
                        esp.distance.Transparency = transparency
                        esp.distance.Visible = true
                    else
                        esp.distance.Visible = false
                    end
                    
                    if ESP_Library.Settings.ShowFlags then
                        local flags = getPlayerFlags(player)
                        if #flags > 0 then
                            esp.flags.Text = table.concat(flags, "\n")
                            esp.flags.Position = Vector2.new(boxPos.X + boxSize.X + 5, boxPos.Y)
                            esp.flags.Transparency = transparency
                            esp.flags.Visible = true
                        else
                            esp.flags.Visible = false
                        end
                    else
                        esp.flags.Visible = false
                    end
                    
                    if ESP_Library.Settings.ShowTracer then
                        local tracerY
                        if ESP_Library.Settings.TracerPosition == "Top" then
                            tracerY = 0
                        elseif ESP_Library.Settings.TracerPosition == "Middle" then
                            tracerY = camera.ViewportSize.Y / 2
                        else
                            tracerY = camera.ViewportSize.Y
                        end
                        
                        esp.tracer.From = Vector2.new(camera.ViewportSize.X / 2, tracerY)
                        esp.tracer.To = Vector2.new(position.X, position.Y)
                        esp.tracer.Color = ESP_Library.Settings.TracerUseTeamColor and teamColor or ESP_Library.Settings.TracerColor
                        esp.tracer.Transparency = transparency
                        esp.tracer.Visible = true
                    else
                        esp.tracer.Visible = false
                    end
                    
                    if ESP_Library.Settings.ShowLookDirection then
                        local lookVector = rootPart.CFrame.LookVector * ESP_Library.Settings.LookDirectionLength
                        local lookPos = camera:WorldToViewportPoint(rootPart.Position + lookVector)
                        
                        esp.lookLine.From = Vector2.new(position.X, position.Y)
                        esp.lookLine.To = Vector2.new(lookPos.X, lookPos.Y)
                        esp.lookLine.Color = ESP_Library.Settings.LookDirectionColor
                        esp.lookLine.Transparency = transparency
                        esp.lookLine.Visible = true
                    else
                        esp.lookLine.Visible = false
                    end
                    
                    if ESP_Library.Settings.ShowSoundESP then
                        local currentTime = tick()
                        local currentPos = rootPart.Position
                        
                        if esp.lastPosition then
                            local moved = (currentPos - esp.lastPosition).Magnitude > 0.5
                            
                            if moved and (currentTime - esp.lastMoveTime) >= ESP_Library.Settings.SoundESPTickDelay then
                                local ripple = {
                                    circle = createDrawing("Circle", {
                                        Color = ESP_Library.Settings.SoundESPColor,
                                        Thickness = ESP_Library.Settings.SoundESPThickness,
                                        NumSides = 64,
                                        Radius = 0,
                                        Filled = false,
                                        Transparency = 1,
                                        Visible = false
                                    }),
                                    startTime = currentTime,
                                    position = currentPos
                                }
                                table.insert(esp.soundRipples, ripple)
                                esp.lastMoveTime = currentTime
                            end
                        end
                        
                        esp.lastPosition = currentPos
                        
                        local i = 1
                        while i <= #esp.soundRipples do
                            local ripple = esp.soundRipples[i]
                            local elapsed = currentTime - ripple.startTime
                            
                            if elapsed >= ESP_Library.Settings.SoundESPDuration then
                                pcall(function() ripple.circle:Remove() end)
                                table.remove(esp.soundRipples, i)
                            else
                                local progress = elapsed / ESP_Library.Settings.SoundESPDuration
                                local footPos = camera:WorldToViewportPoint(ripple.position - Vector3.new(0, 3, 0))
                                
                                if footPos.Z > 0 then
                                    ripple.circle.Position = Vector2.new(footPos.X, footPos.Y)
                                    ripple.circle.Radius = ESP_Library.Settings.SoundESPMaxRadius * progress
                                    ripple.circle.Transparency = 1 - progress
                                    ripple.circle.Visible = true
                                else
                                    ripple.circle.Visible = false
                                end
                                
                                i = i + 1
                            end
                        end
                    else
                        for _, ripple in ipairs(esp.soundRipples) do
                            ripple.circle.Visible = false
                        end
                    end
                    
                else
                    for _, drawing in pairs(esp) do
                        if type(drawing) == "userdata" and drawing.Visible ~= nil then
                            drawing.Visible = false
                        end
                    end
                    for _, line in ipairs(esp.boxLines) do
                        line.Visible = false
                    end
                    for _, line in ipairs(esp.box3DLines) do
                        line.Visible = false
                    end
                    for _, ripple in ipairs(esp.soundRipples) do
                        ripple.circle.Visible = false
                    end
                end
            end
        else
            for _, drawing in pairs(esp) do
                if type(drawing) == "userdata" and drawing.Visible ~= nil then
                    drawing.Visible = false
                end
            end
            for _, line in ipairs(esp.boxLines) do
                line.Visible = false
            end
            for _, line in ipairs(esp.box3DLines) do
                line.Visible = false
            end
            for _, ripple in ipairs(esp.soundRipples) do
                ripple.circle.Visible = false
            end
        end
    end
end

function ESP_Library:RemoveESP(player)
    local esp = cache[player]
    if not esp then return end
    
    if esp.soundRipples then
        for _, ripple in ipairs(esp.soundRipples) do
            pcall(function() ripple.circle:Remove() end)
        end
    end
    
    for _, drawing in pairs(esp) do
        if type(drawing) == "userdata" then
            pcall(function() drawing:Remove() end)
        elseif type(drawing) == "table" then
            for _, subDrawing in pairs(drawing) do
                if type(subDrawing) == "userdata" then
                    pcall(function() subDrawing:Remove() end)
                elseif type(subDrawing) == "table" and subDrawing.circle then
                    pcall(function() subDrawing.circle:Remove() end)
                end
            end
        end
    end
    
    cache[player] = nil
end

function ESP_Library:Init()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            self:CreateESP(player)
        end
    end
    
    connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
        if player ~= localPlayer then
            self:CreateESP(player)
        end
    end)
    
    connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
        self:RemoveESP(player)
    end)
    
    connections.RenderStepped = RunService.RenderStepped:Connect(function()
        self:UpdateESP()
    end)
end

function ESP_Library:Destroy()
    for _, connection in pairs(connections) do
        connection:Disconnect()
    end
    
    for player, _ in pairs(cache) do
        self:RemoveESP(player)
    end
end

return ESP_Library
