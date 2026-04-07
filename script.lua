-- RAYFIELD + KEY SYSTEM
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Mecânica BR - SEM TRAVAR",
   LoadingTitle = "Carregando...",
   LoadingSubtitle = "Modo Leve",

   ConfigurationSaving = {
      Enabled = false,
   },

   KeySystem = true,
   KeySettings = {
      Title = "Sistema de Key",
      Subtitle = "Digite a key",
      Note = "Key necessária para usar",
      FileName = "MecanicaBR_Key",
      SaveKey = false,
      GrabKeyFromSite = false,
      Key = {"usuario.2026"}
   }
})

local MainTab = Window:CreateTab("Caixas", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)

-- PLAYER
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

-- VARIÁVEIS
local caixas = {}

-- 📦 PEGAR TODAS AS CAIXAS (SEM TRAVAR)
local function pegarTudo()
    caixas = {}

    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and (v.Name:lower():find("box") or v.Name:lower():find("caixa")) then
            
            if (v.Position - root.Position).Magnitude <= 20 then
                v.Anchored = true
                v.CanCollide = false
                table.insert(caixas, v)
            end
        end
    end
end

-- 🔄 SEGURAR CAIXAS NO PLAYER
game:GetService("RunService").RenderStepped:Connect(function()
    for i, v in ipairs(caixas) do
        local x = (i % 4) * 2 - 3
        local y = math.floor(i / 4) * 2
        v.CFrame = root.CFrame * CFrame.new(x, y, -3)
    end
end)

-- 🗑️ SOLTAR
local function soltar()
    for _, v in ipairs(caixas) do
        v.Anchored = false
        v.CanCollide = true
    end
    caixas = {}
end

-- 🔍 DETECTAR ENTREGA
local entrega = nil

for _, v in ipairs(workspace:GetDescendants()) do
    if v:IsA("BasePart") then
        local n = v.Name:lower()
        if n:find("delivery") or n:find("entrega") or n:find("sell") or n:find("drop") then
            entrega = v
            break
        end
    end
end

-- 🧠 AUTO SOLTAR
game:GetService("RunService").Heartbeat:Connect(function()
    if entrega and #caixas > 0 then
        if (root.Position - entrega.Position).Magnitude <= 10 then
            soltar()
            task.wait(1)
        end
    end
end)

-- 🕊️ FLY
local flying = false
local flySpeed = 150
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

-- UI

MainTab:CreateButton({
   Name = "📦 Pegar TODAS (Sem Travar)",
   Callback = pegarTudo
})

MainTab:CreateButton({
   Name = "🗑️ Soltar Caixas",
   Callback = soltar
})

PlayerTab:CreateToggle({
   Name = "🕊️ Fly",
   CurrentValue = false,
   Callback = function(v)
       flying = v
       if v then fly()
       else
           if bv then bv:Destroy() end
       end
   end
})

PlayerTab:CreateSlider({
   Name = "🚀 Fly Speed",
   Range = {50, 600},
   Increment = 10,
   CurrentValue = 150,
   Callback = function(v)
       flySpeed = v
   end
})
