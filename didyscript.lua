-- [[ SIGMA SEA 3 MAX-LEVEL INFINITE PIPELINE ]]
local P, W, R = game:GetService("Players").LocalPlayer, game:GetService("Workspace"), game:GetService("ReplicatedStorage")
local VU, TS, HS, CG = game:GetService("VirtualUser"), game:GetService("TeleportService"), game:GetService("HttpService"), game:GetService("CoreGui")
local C = P.Character or P.CharacterAdded:Wait()
local Rem = R:FindFirstChild("Remotes") or R:FindFirstChild("CommF")

local Config = {
    FlySpeed = 280, MaxPing = 90, BlacklistServers = {}, StoredFruits = {},
    -- Nạp dữ liệu bãi farm tối thượng Sea 3: Quái Chocolate Squad, cấp từ 2300 đến max level 2800
    Islands = {
        {N="Chocolate Squad", M=2300, X=2800, V=Vector3.new(280, 50, -12000), NPC="Candy Quest Giver", QName="ChocolateQuest1", QID=1}
    }
}

-- [GUI SETUP]
if CG:FindFirstChild("SigmaHub") then CG.SigmaHub:Destroy() end
local SG = Instance.new("ScreenGui", CG) SG.Name = "SigmaHub"
local Frame = Instance.new("Frame", SG) Frame.Size = UDim2.new(0, 240, 0, 140) Frame.Position = UDim2.new(0.1, 0, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15) Frame.BorderSizePixel = 2 Frame.Active = true Frame.Draggable = true
local Title = Instance.new("TextLabel", Frame) Title.Size = UDim2.new(1, 0, 0, 30) Title.Text = "★ SIGMA SEA 3 FARM ★"
Title.TextColor3 = Color3.fromRGB(255, 255, 255) Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
local StatusLabel = Instance.new("TextLabel", Frame) StatusLabel.Size = UDim2.new(1, 0, 0, 40) StatusLabel.Position = UDim2.new(0, 0, 0.3, 0)
StatusLabel.Text = "Khởi tạo luồng..." StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100) StatusLabel.BackgroundTransparency = 1
local HopBtn = Instance.new("TextButton", Frame) HopBtn.Size = UDim2.new(0.9, 0, 0, 30) HopBtn.Position = UDim2.new(0.05, 0, 0.7, 0)
HopBtn.Text = "Bấm Để Nhảy Server Ngay" HopBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0) HopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

P.Idled:Connect(function() VU:Button2Down(Vector2.new(0, 0), W.CurrentCamera.CFrame) task.wait(0.1) VU:Button2Up(Vector2.new(0, 0), W.CurrentCamera.CFrame) end)

local function ApplyFly(root, targetPos)
    local bv = root:FindFirstChild("SigmaFly") or Instance.new("BodyVelocity")
    bv.Name = "SigmaFly" bv.MaxForce = Vector3.new(9e9, 9e9, 9e9) bv.Parent = root
    local dir = (targetPos - root.Position)
    bv.Velocity = dir.Magnitude > 15 and dir.Unit * Config.FlySpeed or Vector3.new(0,0,0)
end

local function ForceAcceptQuest(npcName, questName, questId)
    local npc = W:FindFirstChild("NPCs") and W.NPCs:FindFirstChild(npcName) or W:FindFirstChild(npcName)
    if npc and Rem then Rem:InvokeServer("StartQuest", questName, questId) end
end

local function HasActiveQuest()
    local data = P:FindFirstChild("Data")
    if data and data:FindFirstChild("Quest") and data.Quest.Value ~= "" then return true end
    return false
end

local function ExecuteServerHop()
    StatusLabel.Text = "Trạng thái: Đang quét tìm server..."
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
HopBtn.MouseButton1Click:Connect(ExecuteServerHop)

local function CheckVIPStatus()
    for _, m in ipairs((W:FindFirstChild("Enemies") or W):GetChildren()) do
        if m:IsA("Model") and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 and table.find({"Dough King", "Rip Indra", "Cake Prince", "Darkbeard"}, m.Name) then return true, m, "Boss" end
    end
    for _, o in ipairs(W:GetChildren()) do
        if o:IsA("Tool") and (string.find(o.Name, "Fruit") or o:FindFirstChild("Handle")) then return true, o, "Fruit" end
    end
    return false, nil, nil
end

task.spawn(function()
    while task.wait(0.01) do
        local root = C:FindFirstChild("HumanoidRootPart")
        if root then
            local hasVIP, obj, mode = CheckVIPStatus()
            if hasVIP then
                if mode == "Fruit" and obj:FindFirstChild("Handle") then
                    StatusLabel.Text = "Ưu tiên: Bay cướp Trái Ác Quỷ!"
                    ApplyFly(root, obj.Handle.Position)
                    if (root.Position - obj.Handle.Position).Magnitude <= 12 then
                        if root:FindFirstChild("SigmaFly") then root.SigmaFly:Destroy() end
                        root.CFrame = obj.Handle.CFrame task.wait(0.2)
                        local held = P:FindFirstChild("Backpack"):FindFirstChild(obj.Name) or C:FindFirstChild(obj.Name)
                        if held and Rem and not Config.StoredFruits[held.Name] then Rem:InvokeServer("StoreFruit", held.Name, C) Config.StoredFruits[held.Name] = true end
                    end
                elseif mode == "Boss" and obj:FindFirstChild("HumanoidRootPart") then
                    StatusLabel.Text = "Săn Boss: " .. obj.Name
                    root.CFrame = obj.HumanoidRootPart.CFrame * CFrame.new(0, 11, 0)
                    if Rem then Rem:InvokeServer("Attack", "Combat", true) Rem:InvokeServer("Attack", "Combat", false) end
                    if C.Humanoid:FindFirstChild("Animator") then for _, t in ipairs(C.Humanoid.Animator:GetPlayingAnimationTracks()) do t:Stop(0) end end
                end
            else
                local lvl = P:FindFirstChild("Data") and P.Data:FindFirstChild("Level") and P.Data.Level.Value or 1
                local active = Config.Islands
                for _, i in ipairs(Config.Islands) do if lvl >= i.M and lvl <= i.X then active = i break end end
                
                if not HasActiveQuest() then
                    StatusLabel.Text = "Nhận Quest: " .. active.N
                    local npcObj = W:FindFirstChild("NPCs") and W.NPCs:FindFirstChild(active.NPC) or W:FindFirstChild(active.NPC)
                    local npcPos = npcObj and npcObj:FindFirstChild("HumanoidRootPart") and npcObj.HumanoidRootPart.Position or active.V
                    if (root.Position - npcPos).Magnitude > 15 then
                        ApplyFly(root, npcPos)
                    else
                        if root:FindFirstChild("SigmaFly") then root.SigmaFly:Destroy() end
                        root.CFrame = CFrame.new(npcPos) task.wait(0.2)
                        ForceAcceptQuest(active.NPC, active.QName, active.QID)
                    end
                else
                    if (root.Position - active.V).Magnitude > 50 then
                        StatusLabel.Text = "Bay ra bãi: " .. active.N
                        ApplyFly(root, active.V)
                    else
                        if root:FindFirstChild("SigmaFly") then root.SigmaFly:Destroy() end
                        local targetMob = nil
                        for _, m in ipairs((W:FindFirstChild("Enemies") or W):GetChildren()) do
                            if m:IsA("Model") and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 and m.Name == active.N then targetMob = m break end
                        end
                        if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                            StatusLabel.Text = "Đấm: " .. active.N .. " (Max Speed)"
                            root.CFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 11, 0)
                            if Rem then Rem:InvokeServer("Attack", "Combat", true) Rem:InvokeServer("Attack", "Combat", false) end
                            if C.Humanoid:FindFirstChild("Animator") then for _, t in ipairs(C.Humanoid.Animator:GetPlayingAnimationTracks()) do t:Stop(0) end end
                        else
                            StatusLabel.Text = "Hết quái! Tự động Hop sau 3s..."
                            task.wait(3) ExecuteServerHop()
                        end
                    end
                end
            end
        end
    end
end)
