-- [[ SIGMA MENU SELECTION & ABSOLUTE COLLISION PIPELINE ]]
local P, W, R = game:GetService("Players").LocalPlayer, game:GetService("Workspace"), game:GetService("ReplicatedStorage")
local VU, TS, HS, CG, RunService = game:GetService("VirtualUser"), game:GetService("TeleportService"), game:GetService("HttpService"), game:GetService("CoreGui"), game:GetService("RunService")

if not game:IsLoaded() then game.Loaded:Wait() end
local C = P.Character or P.CharacterAdded:Wait()
local Rem = R:FindFirstChild("Remotes") or R:FindFirstChild("CommF")

-- Định vị tọa độ hình học Vector cứng chuẩn 100% tại Sea 3 đéo sợ StreamingEnabled
local TargetCoords = {
    BoneIsland = Vector3.new(-9500, 150, 5500), -- Tọa độ khu Haunted Castle farm xương
    DoughKingSpawn = Vector3.new(-25, 20, -11500), -- Vùng đất bánh ngọt spawn Boss
    BoneMobNames = {"Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy"}
}

local CurrentMode = "None" -- Trạng thái lựa chọn thủ công của bạn
local Config = { FlySpeed = 290, StoredFruits = {} }

-- [GUI ENGINE SETUP - SIÊU NHẸ CHỐNG CRASH DELTA X]
if CG:FindFirstChild("SigmaSelectionHub") then CG.SigmaSelectionHub:Destroy() end
local SG = Instance.new("ScreenGui", CG) SG.Name = "SigmaSelectionHub"
local Frame = Instance.new("Frame", SG) Frame.Size = UDim2.new(0, 250, 0, 190) Frame.Position = UDim2.new(0.1, 0, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(12, 12, 12) Frame.BorderSizePixel = 2 Frame.Active = true Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame) Title.Size = UDim2.new(1, 0, 0, 30) Title.Text = "★ SIGMA SELECTION HUB ★"
Title.TextColor3 = Color3.fromRGB(255, 255, 255) Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

local StatusLabel = Instance.new("TextLabel", Frame) StatusLabel.Size = UDim2.new(1, 0, 0, 30) StatusLabel.Position = UDim2.new(0, 0, 0.16, 0)
StatusLabel.Text = "Chế độ: Đang chờ chọn..." StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 200) StatusLabel.BackgroundTransparency = 1

-- Hàm tạo nút bấm nhanh chuẩn cấu trúc phân rã
local function CreateButton(name, text, pos, color)
    local btn = Instance.new("TextButton", Frame)
    btn.Name = name btn.Size = UDim2.new(0.9, 0, 0, 28) btn.Position = pos
    btn.Text = text btn.BackgroundColor3 = color btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    return btn
end

local BtnBone = CreateButton("BtnBone", "Bật Farm Xương (Haunted)", UDim2.new(0.05, 0, 0.35, 0), Color3.fromRGB(30, 80, 30))
local BtnBoss = CreateButton("BtnBoss", "Bật Săn Dough King / Boss", UDim2.new(0.05, 0, 0.53, 0), Color3.fromRGB(120, 20, 20))
local BtnChest = CreateButton("BtnChest", "Bật Auto Nhặt Rương Beli", UDim2.new(0.05, 0, 0.71, 0), Color3.fromRGB(100, 70, 20))
local BtnHop = CreateButton("BtnHop", "Nhảy Server Ping Thấp", UDim2.new(0.05, 0, 0.88, 0), Color3.fromRGB(40, 40, 40))

-- Thiết lập sự kiện tương tác nút bấm gài trạng thái ngầm
BtnBone.MouseButton1Click:Connect(function() CurrentMode = "FarmBone" StatusLabel.Text = "Chế độ: Đang cày Xương..." end)
BtnBoss.MouseButton1Click:Connect(function() CurrentMode = "HuntBoss" StatusLabel.Text = "Chế độ: Săn Dough King..." end)
BtnChest.MouseButton1Click:Connect(function() CurrentMode = "CollectChest" StatusLabel.Text = "Chế độ: Thu thập Rương..." end)

-- [MODULE 1: ANTI-IDLE KICK BYPASS]
P.Idled:Connect(function() VU:Button2Down(Vector2.new(0, 0), W.CurrentCamera.CFrame) task.wait(0.1) VU:Button2Up(Vector2.new(0, 0), W.CurrentCamera.CFrame) end)

-- [MODULE 2: LOW-LEVEL GHOST NOCLIP ENGINE]
RunService.Stepped:Connect(function()
    if C then
        for _, part in ipairs(C:GetChildren()) do
            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
        end
    end
end)

local function ApplyFly(root, targetPos)
    local bv = root:FindFirstChild("SigmaFly") or Instance.new("BodyVelocity", root)
    bv.Name = "SigmaFly" bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
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
            if s.id ~= game.JobId and s.playing < s.maxPlayers then
                pcall(function() TS:TeleportToPlaceInstance(game.PlaceId, s.id, P) end)
                task.wait(1) break
            end
        end
    end
end
BtnHop.MouseButton1Click:Connect(ExecuteServerHop)

task.spawn(function()
    while task.wait(0.01) do
        local root = C:FindFirstChild("HumanoidRootPart")
        if root then
            if not C or not C:Parent() then C = P.Character or P.CharacterAdded:Wait() end
            if not Rem then Rem = R:FindFirstChild("Remotes") or R:FindFirstChild("CommF") end
            
            -- ƯU TIÊN TOÁN HỌC TUYỆT ĐỐI: THẤY FRUIT TỰ ĐỘNG BAY HỐT ĐÉO CẦN BIẾT ĐANG CHỌN CHẾ ĐỘ GÌ
            local targetFruit = nil
            for _, o in ipairs(W:GetChildren()) do if o:IsA("Tool") and (string.find(o.Name, "Fruit") or o:FindFirstChild("Handle")) then targetFruit = o break end end
            if targetFruit and targetFruit:FindFirstChild("Handle") then
                StatusLabel.Text = "VIP: Phát hiện Fruit! Đang hốt..."
                if (root.Position - targetFruit.Handle.Position).Magnitude > 12 then ApplyFly(root, targetFruit.Handle.Position)
                else
                    local fly = root:FindFirstChild("SigmaFly") if fly then fly:Destroy() end
                    root.CFrame = targetFruit.Handle.CFrame task.wait(0.2)
                    local held = P:FindFirstChild("Backpack"):FindFirstChild(targetFruit.Name) or C:FindFirstChild(targetFruit.Name)
                    if held and Rem and not Config.StoredFruits[held.Name] then Rem:InvokeServer("StoreFruit", held.Name, C) Config.StoredFruits[held.Name] = true end
                end
            else
                -- CHẠY THEO CHẾ ĐỘ THỦ CÔNG MÀ BẠN CHỌN TRÊN MENU (BYPASS LỖI LỎ TỰ ĐỘNG KHÔNG LÀM GÌ)
                if CurrentMode == "FarmBone" then
                    if (root.Position - TargetCoords.BoneIsland).Magnitude > 150 then
                        ApplyFly(root, TargetCoords.BoneIsland)
                    else
                        local fly = root:FindFirstChild("SigmaFly") if fly then fly:Destroy() end
                        local targetMob = nil
                        for _, m in ipairs((W:FindFirstChild("Enemies") or W):GetChildren()) do
                            if m:IsA("Model") and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 and table.find(TargetCoords.BoneMobNames, m.Name) then targetMob = m break end
                        end
                        if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                            root.CFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 11, 0)
                            if Rem then Rem:InvokeServer("Attack", "Combat", true) Rem:InvokeServer("Attack", "Combat", false) end
                            if C.Humanoid:FindFirstChild("Animator") then for _, t in ipairs(C.Humanoid.Animator:GetPlayingAnimationTracks()) do t:Stop(0) end end
                        end
                    end
                    
                elseif CurrentMode == "HuntBoss" then
                    local enemies = W:FindFirstChild("Enemies") or W
                    local targetBoss = enemies:FindFirstChild("Dough King") or enemies:FindFirstChild("Cake Prince")
                    if targetBoss and targetBoss:FindFirstChild("HumanoidRootPart") and targetBoss.Humanoid.Health > 0 then
                        local fly = root:FindFirstChild("SigmaFly") if fly then fly:Destroy() end
                        root.CFrame = targetBoss.HumanoidRootPart.CFrame * CFrame.new(0, 11, 0)
                        if Rem then Rem:InvokeServer("Attack", "Combat", true) Rem:InvokeServer("Attack", "Combat", false) end
                        if C.Humanoid:FindFirstChild("Animator") then for _, t in ipairs(C.Humanoid.Animator:GetPlayingAnimationTracks()) do t:Stop(0) end end
                    else
                        StatusLabel.Text = "Boss chưa spawn! Đang bay rình rập..."
                        if (root.Position - TargetCoords.DoughKingSpawn).Magnitude > 50 then ApplyFly(root, TargetCoords.DoughKingSpawn) end
                    end
                    
                elseif CurrentMode == "CollectChest" then
                    local chest = W:FindFirstChild("Chest1") or W:FindFirstChild("Chest2") or W:FindFirstChild("Chest3")
                    if chest then
                        if (root.Position - chest.Position).Magnitude > 10 then ApplyFly(root, chest.Position)
                        else local fly = root:FindFirstChild("SigmaFly") if fly then fly:Destroy() end root.CFrame = chest.CFrame task.wait(0.1) end
                    else
                        StatusLabel.Text = "Hết rương! Đang chờ hồi..."
                        local fly = root:FindFirstChild("SigmaFly") if fly then fly:Destroy() end
                    end
                end
            end
        end
    end
end)
