-- RAYFIELD + KEY SYSTEM
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Mecânica BR - PC SAFE",
   LoadingTitle = "Carregando...",
   LoadingSubtitle = "Anti Kick",

   ConfigurationSaving = {Enabled = false},

   KeySystem = true,
   KeySettings = {
      Title = "Sistema de Key",
      Subtitle = "Digite a key",
      Key = {"usuario.2026"}
   }
})

local MainTab = Window:CreateTab("Caixas", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local TeleportTab = Window:CreateTab("Teleporte", 4483362458)

-- PLAYER
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

-- VAR
local caixas = {}
local autoFarm = false
local flySpeed = 800
local noclip = false

local pallet, entrega

-- DETECTAR
for _, v in ipairs(workspace:GetDescendants()) do
    if v:IsA("BasePart") then
        local n = v.Name:lower()
        if not pallet and n:find("pallet") then pallet = v end
        if not entrega and (n:find("delivery") or n:find("entrega")) then entrega = v end
    end
end

-- 🚫 SAFE TP (ANTI-KICK)
local function safeTP(destino)
    while (root.Position - destino.Position).Magnitude > 5 do
        local dir = (destino.Position - root.Position).Unit
        root.CFrame = root.CFrame + dir * 5
        task.wait(0.02)
    end
end

-- PEGAR CAIXAS
local function pegarTudo()
    caixas = {}
    local count = 0

    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local nome = v.Name:lower()
            if nome:find("box") or nome:find("caixa") then
                if (v.Position - root.Position).Magnitude <= 20 then
                    v.Anchored = true
                    v.CanCollide = false
                    table.insert(caixas, v)
                    count += 1
                    if count >= 20 then break end
                end
            end
        end
    end
end

-- SEGURAR CAIXAS
game:GetService("RunService").RenderStepped:Connect(function()
    for i, v in ipairs(caixas) do
        local x = (i % 4) * 2 - 3
        local y = math.floor(i / 4) * 2
        v.CFrame = root.CFrame * CFrame.new(x, y, -3)
    end
end)

-- SOLTAR
local function soltar()
    for _, v in ipairs(caixas) do
        v.Anchored = false
        v.CanCollide = true
    end
    caixas = {}
end

-- AUTO SOLTAR
game:GetService("RunService").Heartbeat:Connect(function()
    if entrega and #caixas > 0 then
        if (root.Position - entrega.Position).Magnitude <= 10 then
            soltar()
        end
    end
end)

-- NOCLIP
game:GetService("RunService").Stepped:Connect(function()
    if noclip then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

-- FLY (PC)
local flying = false
local bv
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function fly()
    bv = Instance.new("BodyVelocity", root)
    bv.MaxForce = Vector3.new(9e9,9e9,9e9)

    RunService.RenderStepped:Connect(function()
        if flying then
            local cam = workspace.CurrentCamera
            local dir = Vector3.zero

            if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end

            if dir.Magnitude > 0 then
                bv.Velocity = dir.Unit * flySpeed
            else
                bv.Velocity = Vector3.zero
            end
        end
    end)
end

-- AUTO FARM (SAFE)
task.spawn(function()
    while true do
        if autoFarm and pallet and entrega then
            noclip = true

            safeTP(pallet.CFrame)
            task.wait(0.5)
            pegarTudo()

            safeTP(entrega.CFrame)
            task.wait(1)
            soltar()
        else
            noclip = false
        end
        task.wait(0.3)
    end
end)

-- 🚀 TELEPORTES SAFE
local function tp(cf) safeTP(cf) end

TeleportTab:CreateButton({Name="Ferro Velho",Callback=function()tp(CFrame.new(-3126,65,-4255))end})
TeleportTab:CreateButton({Name="Auto Peças",Callback=function()tp(CFrame.new(-3330,65,-3409))end})
TeleportTab:CreateButton({Name="Drag Race",Callback=function()tp(CFrame.new(-3859,64,-4896))end})
TeleportTab:CreateButton({Name="Construção Metrópole",Callback=function()tp(CFrame.new(-3645,65,-2509))end})
TeleportTab:CreateButton({Name="Construção Cidade 2",Callback=function()tp(CFrame.new(-25216,65,-5291))end})
TeleportTab:CreateButton({Name="Posto",Callback=function()tp(CFrame.new(-3222,66,-3708))end})
TeleportTab:CreateButton({Name="Concessionária",Callback=function()tp(CFrame.new(-3040,65,-3697))end})
TeleportTab:CreateButton({Name="Secreto",Callback=function()tp(CFrame.new(-25678,32,-5880))end})

-- UI
MainTab:CreateButton({Name="Pegar Caixas",Callback=pegarTudo})
MainTab:CreateButton({Name="Soltar",Callback=soltar})

MainTab:CreateToggle({
   Name="Auto Farm",
   CurrentValue=false,
   Callback=function(v) autoFarm=v end
})

PlayerTab:CreateToggle({
   Name="Fly",
   CurrentValue=false,
   Callback=function(v)
       flying=v
       if v then fly()
       else if bv then bv:Destroy() end end
   end
})

PlayerTab:CreateSlider({
   Name="Speed",
   Range={50,1000},
   Increment=50,
   CurrentValue=800,
   Callback=function(v) flySpeed=v end
})
