-- [[ ULTIMATE SIGMA REAL-TIME NPC OVERRIDE PIPELINE ]]
local P, W, R = game:GetService("Players").LocalPlayer, game:GetService("Workspace"), game:GetService("ReplicatedStorage")
local VU, TS, HS, CG = game:GetService("VirtualUser"), game:GetService("TeleportService"), game:GetService("HttpService"), game:GetService("CoreGui")

if not game:IsLoaded() then game.Loaded:Wait() end
local C = P.Character or P.CharacterAdded:Wait()
local Rem = R:FindFirstChild("Remotes") or R:FindFirstChild("CommF")

local Sea3Data = {
    MobName = "Chocolate Squad",
    NPCName = "Candy Quest Giver",
    QuestName = "ChocolateQuest1",
    QuestID = 1,
    MobPos = Vector3.new(285, 52, -12350) -- Tọa độ bãi quái
}

local Config = { FlySpeed = 290, MaxPing = 95, BlacklistServers = {}, StoredFruits = {} }

-- [GUI SETUP]
if CG:FindFirstChild("SigmaHub") then CG.SigmaHub:Destroy() end
local SG = Instance.new("ScreenGui", CG) SG.Name = "SigmaHub"
local Frame = Instance.new("Frame", SG) Frame.Size = UDim2.new(0, 240, 0, 140) Frame.Position = UDim2.new(0.1, 0, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(5, 5, 5) Frame.BorderSizePixel = 2 Frame.Active = true Frame.Draggable = true
local Title = Instance.new("TextLabel", Frame) Title.Size = UDim2.new(1, 0, 0, 30) Title.Text = "★ SIGMA REAL FIX ACTIVE ★"
Title.TextColor3 = Color3.fromRGB(255, 255, 255) Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
local StatusLabel = Instance.new("TextLabel", Frame) StatusLabel.Size = UDim2.new(1, 0, 0, 40) StatusLabel.Position = UDim2.new(0, 0, 0.3, 0)
StatusLabel.Text = "Đang quét thực thể NPC..." StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 200) StatusLabel.BackgroundTransparency = 1

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

local function HasActiveQuest()
    local data = P:FindFirstChild("Data")
    if data and data:FindFirstChild("Quest") and data.Quest.Value ~= "" then return true end
    return false
end

-- Tìm kiếm chính xác thực thể NPC Candy Quest Giver đang nằm ở đâu trong Workspace Sea 3
local function FindNPCInstance()
    local npc = W:FindFirstChild("NPCs") and W.NPCs:FindFirstChild(Sea3Data.NPCName) or W:FindFirstChild(Sea3Data.NPCName)
    if npc and npc:FindFirstChild("HumanoidRootPart") then
        return npc
    end
    return nil
end

task.spawn(function()
    while task.wait(0.01) do
        local root = C:FindFirstChild("HumanoidRootPart")
        if root then
            if not Rem then Rem = R:FindFirstChild("Remotes") or R:FindFirstChild("CommF") end
            
            -- [MẮT XÍCH 1: QUET VÀ CƯỚP TRÁI ÁC QUỶ SPARK]
            local targetFruit = nil
            for _, o in ipairs(W:GetChildren()) do
                if o:IsA("Tool") and (string.find(o.Name, "Fruit") or o:FindFirstChild("Handle")) then targetFruit = o break end
            end
            if targetFruit and targetFruit:FindFirstChild("Handle") then
                StatusLabel.Text = "VIP: Phát hiện Fruit! Đang lao tới..."
                if (root.Position - targetFruit.Handle.Position).Magnitude > 12 then
                    ApplyFly(root, targetFruit.Handle.Position)
                else
                    local fly = root:FindFirstChild("SigmaFly") if fly then fly:Destroy() end
                    root.CFrame = targetFruit.Handle.CFrame task.wait(0.2)
                    local held = P:FindFirstChild("Backpack"):FindFirstChild(targetFruit.Name) or C:FindFirstChild(targetFruit.Name)
                    if held and Rem and not Config.StoredFruits[held.Name] then Rem:InvokeServer("StoreFruit", held.Name, C) Config.StoredFruits[held.Name] = true end
                end
            else
                -- [MẮT XÍCH 2: LUỒNG FARM LEVEL THEO THỰC THỂ KHÔNG SỢ KẸT ĐỊA HÌNH]
                local questValue = P:FindFirstChild("Data") and P.Data:FindFirstChild("Quest") and P.Data.Quest.Value or ""
                
                if questValue == "" then
                    -- CHƯA CÓ QUEST -> DỊCH CHUYỂN THẲNG VÀO ĐẦU NPC ĐỂ NHẬN
                    StatusLabel.Text = "Hệ thống: Đang bắt sóng NPC..."
                    local npcInstance = FindNPCInstance()
                    
                    if npcInstance then
                        local npcPos = npcInstance.HumanoidRootPart.Position
                        -- Ép nhân vật khóa CFrame sát rạt NPC để bypass check khoảng cách vật lý
                        local fly = root:FindFirstChild("SigmaFly") if fly then fly:Destroy() end
                        root.CFrame = CFrame.new(npcPos + Vector3.new(0, 2, 0))
                        
                        -- Thực hiện dồn gói tin nhận Quest trực tiếp
                        if Rem then 
                            Rem:InvokeServer("StartQuest", Sea3Data.QuestName, Sea3Data.QuestID) 
                        end
                        task.wait(0.3)
                    else
                        -- Phòng trường hợp StreamingEnabled làm mất tích NPC, script sẽ tự bay về khu vực kẹo ngọt để ép nạp map
                        StatusLabel.Text = "Streaming: Đang bay tìm vùng nhớ Candy..."
                        ApplyFly(root, Vector3.new(215, 55, -12110))
                    end
                else
                    -- ĐÃ CÓ QUEST -> BAY RA BÃI QUÁI DẬP SIÊU TỐC KHÔNG ANIMATION
                    StatusLabel.Text = "Hệ thống: Di chuyển ra bãi Chocolate Squad..."
                    
                    if (root.Position - Sea3Data.MobPos).Magnitude > 45 then
                        ApplyFly(root, Sea3Data.MobPos)
                    else
                        local fly = root:FindFirstChild("SigmaFly") if fly then fly:Destroy() end
                        
                        local targetMob = nil
                        for _, m in ipairs((W:FindFirstChild("Enemies") or W):GetChildren()) do
                            if m:IsA("Model") and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 and m.Name == Sea3Data.MobName then targetMob = m break end
                        end
                        
                        if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                            StatusLabel.Text = "Đấm: " .. Sea3Data.MobName
                            root.CFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 11, 0)
                            if Rem then Rem:InvokeServer("Attack", "Combat", true) Rem:InvokeServer("Attack", "Combat", false) end
                            if C.Humanoid:FindFirstChild("Animator") then for _, t in ipairs(C.Humanoid.Animator:GetPlayingAnimationTracks()) do t:Stop(0) end end
                        else
                            -- Quái chưa hồi thì dọn rương vàng xung quanh kiếm tiền
                            StatusLabel.Text = "Quái chưa hồi! Đang cày rương..."
                            local chest = W:FindFirstChild("Chest1") or W:FindFirstChild("Chest2") or W:FindFirstChild("Chest3")
                            if chest then root.CFrame = chest.CFrame task.wait(0.1) end
                        end
                    end
                end
            end
        end
    end
end)
