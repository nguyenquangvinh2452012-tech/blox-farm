-- [[ SIGMA DEX-INTEGRATED W-AZURE CUSTOM HUB ]]
local P, W, R = game:GetService("Players").LocalPlayer, game:GetService("Workspace"), game:GetService("ReplicatedStorage")
local VU, TS, HS, CG, RunService = game:GetService("VirtualUser"), game:GetService("TeleportService"), game:GetService("HttpService"), game:GetService("CoreGui"), game:GetService("RunService")

if not game:IsLoaded() then game.Loaded:Wait() end
local C = P.Character or P.CharacterAdded:Wait()
local Rem = R:FindFirstChild("Remotes") or R:FindFirstChild("CommF")

-- Hệ thống nạp tọa độ thực tế trích xuất trực tiếp từ Dex Explorer của bạn
local SigmaConfig = {
    AutoBone = false,
    AutoDoughKing = false,
    AutoChest = false,
    FlySpeed = 295,
    StoredFruits = {},
    Coords = {
        -- Sử dụng chính xác tọa độ Pivot thực tế bạn cung cấp để né kẹt địa hình
        BoneIsland = Vector3.new(-9516.993, 172.017, 6078.465), 
        DoughKingSpawn = Vector3.new(-25, 20, -11500),
        BoneMobNames = {"Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy"}
    }
}

-- [GUI ENGINE SETUP - CLONE GIAO DIỆN W-AZURE CHUẨN ĐÉT]
if CG:FindFirstChild("SigmaAzureHub") then CG.SigmaAzureHub:Destroy() end
local SG = Instance.new("ScreenGui", CG) SG.Name = "SigmaAzureHub"

local MainFrame = Instance.new("Frame", SG)
MainFrame.Size = UDim2.new(0, 380, 0, 240) MainFrame.Position = UDim2.new(0.15, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 27) MainFrame.BorderSizePixel = 0
MainFrame.Active = true MainFrame.Draggable = true

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 30) TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 20) TopBar.BorderSizePixel = 0
local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -10, 1, 0) Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "W-sigma True V2 | discord.gg/w-sigma" Title.TextColor3 = Color3.fromRGB(160, 160, 165)
Title.TextXAlignment = Enum.TextXAlignment.Left Title.BackgroundTransparency = 1

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 110, 1, -30) Sidebar.Position = UDim2.new(0, 0, 0, 30)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 22) Sidebar.BorderSizePixel = 0

local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, -110, 1, -30) Container.Position = UDim2.new(0, 110, 0, 30)
Container.BackgroundColor3 = Color3.fromRGB(30, 30, 32) Container.BorderSizePixel = 0

local MainFarmPage = Instance.new("Frame", Container) MainFarmPage.Size = UDim2.new(1, 0, 1, 0) MainFarmPage.BackgroundTransparency = 1 MainFarmPage.Visible = true
local SubFarmingPage = Instance.new("Frame", Container) SubFarmingPage.Size = UDim2.new(1, 0, 1, 0) SubFarmingPage.BackgroundTransparency = 1 SubFarmingPage.Visible = false

local function SwitchTab(tabName)
    MainFarmPage.Visible = (tabName == "MainFarm")
    SubFarmingPage.Visible = (tabName == "SubFarming")
end

local Tab1 = Instance.new("TextButton", Sidebar)
Tab1.Size = UDim2.new(1, 0, 0, 35) Tab1.Position = UDim2.new(0, 0, 0, 5)
Tab1.Text = "Main Farm" Tab1.TextColor3 = Color3.fromRGB(255, 255, 255) Tab1.BackgroundColor3 = Color3.fromRGB(28, 28, 30) Tab1.BorderSizePixel = 0
Tab1.MouseButton1Click:Connect(function() SwitchTab("MainFarm") end)

local Tab2 = Instance.new("TextButton", Sidebar)
Tab2.Size = UDim2.new(1, 0, 0, 35) Tab2.Position = UDim2.new(0, 0, 0, 42)
Tab2.Text = "Sub Farming" Tab2.TextColor3 = Color3.fromRGB(150, 150, 155) Tab2.BackgroundTransparency = 1
Tab2.MouseButton1Click:Connect(function() SwitchTab("SubFarming") end)

local function AddToggle(parent, text, pos, configKey)
    local toggleFrame = Instance.new("Frame", parent)
    toggleFrame.Size = UDim2.new(0.9, 0, 0, 40) toggleFrame.Position = pos toggleFrame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", toggleFrame)
    label.Size = UDim2.new(0.7, 0, 1, 0) label.Text = text label.TextColor3 = Color3.fromRGB(230, 230, 235)
    label.TextXAlignment = Enum.TextXAlignment.Left label.BackgroundTransparency = 1
    local switch = Instance.new("TextButton", toggleFrame)
    switch.Size = UDim2.new(0, 45, 0, 22) switch.Position = UDim2.new(0.75, 0, 0.2, 0)
    switch.BackgroundColor3 = Color3.fromRGB(50, 50, 55) switch.Text = "" switch.BorderSizePixel = 0
    local indicator = Instance.new("Frame", switch)
    indicator.Size = UDim2.new(0, 18, 0, 18) indicator.Position = UDim2.new(0, 2, 0, 2)
    indicator.BackgroundColor3 = Color3.fromRGB(200, 200, 205) indicator.BorderSizePixel = 0
    
    switch.MouseButton1Click:Connect(function()
        SigmaConfig[configKey] = not SigmaConfig[configKey]
        if SigmaConfig[configKey] then
            switch.BackgroundColor3 = Color3.fromRGB(0, 120, 240)
            indicator.Position = UDim2.new(0, 25, 0, 2)
        else
            switch.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            indicator.Position = UDim2.new(0, 2, 0, 2)
        end
    end)
end

AddToggle(MainFarmPage, "Auto Farm Bones\n(Tọa độ chuẩn Dex)", UDim2.new(0.05, 0, 0.05, 0), "AutoBone")
AddToggle(SubFarmingPage, "Raid Fruit Hop\n(Săn Dough King & Boss)", UDim2.new(0.05, 0, 0.05, 0), "AutoDoughKing")
AddToggle(SubFarmingPage, "Auto Collect Chest\n(Tự động gom rương tiền)", UDim2.new(0.05, 0, 0.25, 0), "AutoChest")

-- [MODULE 1: ANTI-IDLE KICK & LOW-LEVEL GHOST NOCLIP]
P.Idled:Connect(function() VU:Button2Down(Vector2.new(0, 0), W.CurrentCamera.CFrame) task.wait(0.1) VU:Button2Up(Vector2.new(0, 0), W.CurrentCamera.CFrame) end)

RunService.Stepped:Connect(function()
    if C and (SigmaConfig.AutoBone or SigmaConfig.AutoDoughKing or SigmaConfig.AutoChest) then
        for _, part in ipairs(C:GetChildren()) do
            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
        end
    end
end)

local function ApplyFly(root, targetPos)
    local bv = root:FindFirstChild("SigmaFly") or Instance.new("BodyVelocity", root)
    bv.Name = "SigmaFly" bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    local dir = (targetPos - root.Position)
    bv.Velocity = dir.Magnitude > 10 and dir.Unit * SigmaConfig.FlySpeed or Vector3.new(0,0,0)
end

task.spawn(function()
    while task.wait(0.01) do
        local root = C:FindFirstChild("HumanoidRootPart")
        if root then
            if not C or not C:Parent() then C = P.Character or P.CharacterAdded:Wait() end
            if not Rem then Rem = R:FindFirstChild("Remotes") or R:FindFirstChild("CommF") end
            
            -- QUÉT VÀ CƯỚP TRÁI ÁC QUỶ ƯU TIÊN CAO NHẤT
            local targetFruit = nil
            for _, o in ipairs(W:GetChildren()) do if o:IsA("Tool") and (string.find(o.Name, "Fruit") or o:FindFirstChild("Handle")) then targetFruit = o break end end
            if targetFruit and targetFruit:FindFirstChild("Handle") then
                if (root.Position - targetFruit.Handle.Position).Magnitude > 12 then ApplyFly(root, targetFruit.Handle.Position)
                else
                    local fly = root:FindFirstChild("SigmaFly") if fly then fly:Destroy() end
                    root.CFrame = targetFruit.Handle.CFrame task.wait(0.2)
                    local held = P:FindFirstChild("Backpack"):FindFirstChild(targetFruit.Name) or C:FindFirstChild(targetFruit.Name)
                    if held and Rem and not SigmaConfig.StoredFruits[held.Name] then Rem:InvokeServer("StoreFruit", held.Name, C) SigmaConfig.StoredFruits[held.Name] = true end
                end
            else
                -- CHẠY THEO TOGGLE CHỨC NĂNG CỨNG
                if SigmaConfig.AutoBone then
                    -- Kiểm tra khoảng cách hình học tới tọa độ lấy từ Dex
                    if (root.Position - SigmaConfig.Coords.BoneIsland).Magnitude > 150 then 
                        ApplyFly(root, SigmaConfig.Coords.BoneIsland)
                    else
                        local fly = root:FindFirstChild("SigmaFly") if fly then fly:Destroy() end
                        local targetMob = nil
                        for _, m in ipairs((W:FindFirstChild("Enemies") or W):GetChildren()) do
                            if m:IsA("Model") and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 and table.find(SigmaConfig.Coords.BoneMobNames, m.Name) then targetMob = m break end
                        end
                        if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                            root.CFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 11, 0)
                            if Rem then Rem:InvokeServer("Attack", "Combat", true) Rem:InvokeServer("Attack", "Combat", false) end
                            if C.Humanoid:FindFirstChild("Animator") then for _, t in ipairs(C.Humanoid.Animator:GetPlayingAnimationTracks()) do t:Stop(0) end end
                        end
                    end
                    
                elseif SigmaConfig.AutoDoughKing then
                    local enemies = W:FindFirstChild("Enemies") or W
                    local targetBoss = enemies:FindFirstChild("Dough King") or enemies:FindFirstChild("Cake Prince")
                    if targetBoss and targetBoss:FindFirstChild("HumanoidRootPart") and targetBoss.Humanoid.Health > 0 then
                        local fly = root:FindFirstChild("SigmaFly") if fly then fly:Destroy() end
                        root.CFrame = targetBoss.HumanoidRootPart.CFrame * CFrame.new(0, 11, 0)
                        if Rem then Rem:InvokeServer("Attack", "Combat", true) Rem:InvokeServer("Attack", "Combat", false) end
                        if C.Humanoid:FindFirstChild("Animator") then for _, t in ipairs(C.Humanoid.Animator:GetPlayingAnimationTracks()) do t:Stop(0) end end
                    else
                        if (root.Position - SigmaConfig.Coords.DoughKingSpawn).Magnitude > 50 then ApplyFly(root, SigmaConfig.Coords.DoughKingSpawn) end
                    end
                    
                elseif SigmaConfig.AutoChest then
