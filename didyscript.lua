-- [[ SIGMA SEA 3 STREAMING BYPASS DEFINITIVE PIPELINE ]]
local P, W, R = game:GetService("Players").LocalPlayer, game:GetService("Workspace"), game:GetService("ReplicatedStorage")
local VU, TS, HS, CG = game:GetService("VirtualUser"), game:GetService("TeleportService"), game:GetService("HttpService"), game:GetService("CoreGui")

if not game:IsLoaded() then game.Loaded:Wait() end
local C = P.Character or P.CharacterAdded:Wait()
local Rem = R:FindFirstChild("Remotes") or R:FindFirstChild("CommF")

-- Tọa độ Vector3 chuẩn xác 100% của NPC và Quái tại Đảo Chocolate (Sea 3)
local Sea3Data = {
    MobName = "Chocolate Squad",
    NPCName = "Candy Quest Giver",
    QuestName = "ChocolateQuest1",
    QuestID = 1,
    NPCPos = Vector3.new(215.1, 48.2, -12110.5), -- Tọa độ chuẩn NPC Kẹo Ngọt
    MobPos = Vector3.new(285.3, 52.1, -12350.2)   -- Tọa độ trung tâm bãi Chocolate Squad
}

local Config = { FlySpeed = 290, MaxPing = 95, BlacklistServers = {}, StoredFruits = {} }

-- [GUI SETUP]
if CG:FindFirstChild("SigmaHub") then CG.SigmaHub:Destroy() end
local SG = Instance.new("ScreenGui", CG) SG.Name = "SigmaHub"
local Frame = Instance.new("Frame", SG) Frame.Size = UDim2.new(0, 240, 0, 140) Frame.Position = UDim2.new(0.1, 0, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10) Frame.BorderSizePixel = 2 Frame.Active = true Frame.Draggable = true
local Title = Instance.new("TextLabel", Frame) Title.Size = UDim2.new(1, 0, 0, 30) Title.Text = "★ SIGMA PROOF ACTIVE ★"
Title.TextColor3 = Color3.fromRGB(255, 255, 255) Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
local StatusLabel = Instance.new("TextLabel", Frame) StatusLabel.Size = UDim2.new(1, 0, 0, 40) StatusLabel.Position = UDim2.new(0, 0, 0.3, 0)
StatusLabel.Text = "Đang phá xích Streaming..." StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150) StatusLabel.BackgroundTransparency = 1

P.Idled:Connect(function() VU:Button2Down(Vector2.new(0, 0), W.CurrentCamera.CFrame) task.wait(0.1) VU:Button2Up(Vector2.new(0, 0), W.CurrentCamera.CFrame) end)

local function ApplyFly(root, targetPos)
    local bv = root:FindFirstChild("SigmaFly")
    if not bv then
        bv = Instance.new("BodyVelocity") bv.Name = "SigmaFly"
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9) bv.Parent = root
    end
    local dir = (targetPos - root.Position)
    bv.Velocity = dir.Magnitude > 12 and dir.Unit * Config.FlySpeed or Vector3.new(0,0,0)
end

local function ExecuteServerHop()
    StatusLabel.Text = "Trạng thái: Đang nhảy Server..."
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

local function HasActiveQuest()
    local data = P:FindFirstChild("Data")
    if data and data:FindFirstChild("Quest") and data.Quest.Value ~= "" then return true end
    return false
end

-- Ép Client Roblox nạp dữ liệu vùng địa hình tránh lỗi đứng im (Streaming Bypass)
local function ForceStreamArea(pos)
    if P.RequestStreamAroundAsync then
        pcall(function() P:RequestStreamAroundAsync(pos) end)
    end
end

task.spawn(function()
    while task.wait(0.01) do
        local root = C:FindFirstChild("HumanoidRootPart")
        if root then
            if not Rem then Rem = R:FindFirstChild("Remotes") or R:FindFirstChild("CommF") end
            
            -- Quét tìm Trái ác quỷ tự do trên map (Ưu tiên tuyệt đối)
            local targetFruit = nil
            for _, o in ipairs(W:GetChildren()) do
                if o:IsA("Tool") and (string.find(o.Name, "Fruit") or o:FindFirstChild("Handle")) then targetFruit = o break end
            end
            
            if targetFruit and targetFruit:FindFirstChild("Handle") then
                StatusLabel.Text = "VIP: Phát hiện Fruit! Đang bay tới..."
                ForceStreamArea(targetFruit.Handle.Position)
                if (root.Position - targetFruit.Handle.Position).Magnitude > 12 then
                    ApplyFly(root, targetFruit.Handle.Position)
                else
                    local fly = root:FindFirstChild("SigmaFly") if fly then fly:Destroy() end
                    root.CFrame = targetFruit.Handle.CFrame task.wait(0.2)
                    local held = P:FindFirstChild("Backpack"):FindFirstChild(targetFruit.Name) or C:FindFirstChild(targetFruit.Name)
                    if held and Rem and not Config.StoredFruits[held.Name] then 
                        Rem:InvokeServer("StoreFruit", held.Name, C) 
                        Config.StoredFruits[held.Name] = true 
                    end
                end
            else
                -- LUỒNG CHÍNH: FARM LEVEL THEO TOẠ ĐỘ HARDCODED BYPASS STREAMING
                local questValue = P:FindFirstChild("Data") and P.Data:FindFirstChild("Quest") and P.Data.Quest.Value or ""
                
                if questValue == "" then
                    -- BƯỚC 1: NHẬN NHIỆM VỤ
                    StatusLabel.Text = "Hệ thống: Tiến về NPC nhận Quest..."
                    ForceStreamArea(Sea3Data.NPCPos)
                    
                    if (root.Position - Sea3Data.NPCPos).Magnitude > 12 then
                        ApplyFly(root, Sea3Data.NPCPos)
                    else
                        local fly = root:FindFirstChild("SigmaFly") if fly then fly:Destroy() end
                        root.CFrame = CFrame.new(Sea3Data.NPCPos) task.wait(0.3)
                        if Rem then Rem:InvokeServer("StartQuest", Sea3Data.QuestName, Sea3Data.QuestID) end
                    end
                else
                    -- BƯỚC 2: RA BÃI QUÁI ĐẤM SIÊU TỐC
                    StatusLabel.Text = "Hệ thống: Bay ra bãi Chocolate Squad..."
                    ForceStreamArea(Sea3Data.MobPos)
                    
                    if (root.Position - Sea3Data.MobPos).Magnitude > 45 then
                        ApplyFly(root, Sea3Data.MobPos)
                    else
                        local fly = root:FindFirstChild("SigmaFly") if fly then fly:Destroy() end
                        
                        -- Tìm kiếm thực thể quái đã được ép nạp vào map
                        local targetMob = nil
                        for _, m in ipairs((W:FindFirstChild("Enemies") or W):GetChildren()) do
                            if m:IsA("Model") and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 and m.Name == Sea3Data.MobName then targetMob = m break end
                        end
                        
                        if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                            StatusLabel.Text = "Đấm: " .. Sea3Data.MobName
                            root.CFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 11, 0)
                            if Rem then 
                                Rem:InvokeServer("Attack", "Combat", true) 
                                Rem:InvokeServer("Attack", "Combat", false) 
                            end
                            if C.Humanoid:FindFirstChild("Animator") then 
                                for _, t in ipairs(C.Humanoid.Animator:GetPlayingAnimationTracks()) do t:Stop(0) end 
                            end
                        else
                            -- Nếu đã tới bãi mà không thấy quái do server trống -> Đi nhặt rương vàng chữa cháy kiếm Beli
                            StatusLabel.Text = "Quái chưa hồi! Đang quét rương..."
                            local chest = W:FindFirstChild("Chest1") or W:FindFirstChild("Chest2") or W:FindFirstChild("Chest3")
                            if chest then
                                root.CFrame = chest.CFrame task.wait(0.1)
                            else
                                StatusLabel.Text = "Hết mục tiêu! Đang nhảy Server..."
                                task.wait(1) ExecuteServerHop()
                            end
                        end
                    end
                end
            end
        end
    end
end)
