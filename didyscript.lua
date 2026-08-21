-- [[ SIGMA ALL-IN-ONE INFINITE PIPELINE ]]
local P, W, R = game:GetService("Players").LocalPlayer, game:GetService("Workspace"), game:GetService("ReplicatedStorage")
local VU, TS, HS = game:GetService("VirtualUser"), game:GetService("TeleportService"), game:GetService("HttpService")
local C = P.Character or P.CharacterAdded:Wait()
local Rem = R:FindFirstChild("Remotes") or R:FindFirstChild("CommF")

-- Cấu hình hệ thống nén dữ liệu ngầm
local Config = {
    FlySpeed = 280,
    MaxPing = 90,
    BlacklistServers = {},
    StoredFruits = {},
    Islands = {
        {N="Bandits", M=1, X=10, V=Vector3.new(100,20,100)},
        {N="Monkeys", M=10, X=30, V=Vector3.new(1200,30,-500)}
    }
}

-- [MODULE 1: ANTI-IDLE KICK BYPASS]
P.Idled:Connect(function()
    VU:Button2Down(Vector2.new(0, 0), W.CurrentCamera.CFrame)
    task.wait(0.1)
    VU:Button2Up(Vector2.new(0, 0), W.CurrentCamera.CFrame)
end)

-- [MODULE 2: LINEAR VELOCITY FLY]
local function ApplyFly(root, targetPos)
    local bv = root:FindFirstChild("SigmaFly")
    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.Name = "SigmaFly"
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Parent = root
    end
    local dir = (targetPos - root.Position)
    bv.Velocity = dir.Magnitude > 15 and dir.Unit * Config.FlySpeed or Vector3.new(0,0,0)
end

-- [MODULE 3: SMART SERVER HOPPER VIA API]
local function ExecuteServerHop()
    local success, result = pcall(function()
        return HS:JSONDecode(game:HttpGet("https://roblox.com" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=50"))
    end)
    if success and result and result.data then
        for _, s in ipairs(result.data) do
            if s.id ~= game.JobId and s.playing < s.maxPlayers and not Config.BlacklistServers[s.id] then
                if s.ping and s.ping <= Config.MaxPing then
                    Config.BlacklistServers[s.id] = true
                    pcall(function() TS:TeleportToPlaceInstance(game.PlaceId, s.id, P) end)
                    task.wait(1)
                end
            end
        end
    end
end

-- [MODULE 4: SCANNER TARGETS & VIP FRUITS]
local function CheckServerStatus()
    for _, m in ipairs((W:FindFirstChild("Enemies") or W):GetChildren()) do
        if m:IsA("Model") and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 then
            if table.find({"Dough King", "Rip Indra", "Cake Prince", "Darkbeard"}, m.Name) then return true, m, "Boss" end
        end
    end
    for _, o in ipairs(W:GetChildren()) do
        if o:IsA("Tool") and (string.find(o.Name, "Fruit") or o:FindFirstChild("Handle")) then return true, o, "Fruit" end
    end
    return false, nil, nil
end

-- [MAIN REPLICATION PIPELINE EXECUTION]
task.spawn(function()
    task.wait(3) -- Đợi server ổn định gói tin
    while task.wait(0.01) do
        local root = C:FindFirstChild("HumanoidRootPart")
        if root then
            local hasTarget, obj, mode = CheckServerStatus()
            
            if hasTarget then
                if mode == "Fruit" and obj:FindFirstChild("Handle") then
                    if (root.Position - obj.Handle.Position).Magnitude > 12 then
                        ApplyFly(root, obj.Handle.Position)
                    else
                        if root:FindFirstChild("SigmaFly") then root.SigmaFly:Destroy() end
                        root.CFrame = obj.Handle.CFrame
                        task.wait(0.2)
                        local held = P:FindFirstChild("Backpack"):FindFirstChild(obj.Name) or C:FindFirstChild(obj.Name)
                        if held and Rem and not Config.StoredFruits[held.Name] then
                            Rem:InvokeServer("StoreFruit", held.Name, C)
                            Config.StoredFruits[held.Name] = true
                        end
                    end
                elseif mode == "Boss" and obj:FindFirstChild("HumanoidRootPart") then
                    root.CFrame = obj.HumanoidRootPart.CFrame * CFrame.new(0, 11, 0)
                    if Rem then Rem:InvokeServer("Attack", "Combat", true) Rem:InvokeServer("Attack", "Combat", false) end
                    if C.Humanoid:FindFirstChild("Animator") then
                        for _, t in ipairs(C.Humanoid.Animator:GetPlayingAnimationTracks()) do t:Stop(0) end
                    end
                end
            else
                -- Vòng lặp Farm Level khi Server trống mục tiêu VIP
                local lvl = P:FindFirstChild("Data") and P.Data:FindFirstChild("Level") and P.Data.Level.Value or 1
                local active = Config.Islands[1]
                for _, i in ipairs(Config.Islands) do if lvl >= i.M and lvl <= i.X then active = i break end end
                
                if (root.Position - active.V).Magnitude > 50 then
                    ApplyFly(root, active.V)
                else
                    if root:FindFirstChild("SigmaFly") then root.SigmaFly:Destroy() end
                    local targetMob = nil
                    for _, m in ipairs((W:FindFirstChild("Enemies") or W):GetChildren()) do
                        if m:IsA("Model") and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 and m.Name == active.N then targetMob = m break end
                    end
                    
                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        root.CFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 11, 0)
                        if Rem then Rem:InvokeServer("Attack", "Combat", true) Rem:InvokeServer("Attack", "Combat", false) end
                        if C.Humanoid:FindFirstChild("Animator") then
                            for _, t in ipairs(C.Humanoid.Animator:GetPlayingAnimationTracks()) do t:Stop(0) end
                        end
                    else
                        -- Không có quái để farm và đéo có Boss/Fruit -> Kích hoạt Server Hop tức thì
                        ExecuteServerHop()
                    end
                end
            end
        end
    end
end)
