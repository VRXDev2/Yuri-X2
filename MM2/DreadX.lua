---@diagnostic disable: undefined-global
local Library = loadstring(game:HttpGet(("https://raw.githubusercontent.com/VRXDev2/DreadX/main/UILib.lua"), true))()

setfpscap(900)

local colors = {
    SchemeColor = Color3.fromRGB(109, 65, 170),
    Background = Color3.fromRGB(82, 45, 135),
    Header = Color3.fromRGB(68, 32, 117),
    TextColor = Color3.fromRGB(255, 255, 255),
    ElementColor = Color3.fromRGB(70, 38, 114)
}

local Window = Library.CreateLib("DreadX | Murder Mystery 2", colors)

local Workspace = game:GetService('Workspace')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local Client = Players.LocalPlayer
local RunService = game:GetService('RunService')
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local Teams = game:GetService("Teams")
local ScriptContext = game:GetService("ScriptContext")
local CoreGui = game:GetService("CoreGui")
local Camera = Workspace.CurrentCamera
local Mouse = Client:GetMouse()
local Terrain = Workspace.Terrain
local VirtualUser = game:GetService("VirtualUser")

local Murderer, Sheriff = nil, nil

local Character = Client.Character
local Humanoid = Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid")
local RootPart = Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart")

function GetMurderer()
    for i,v in pairs(Players:GetChildren()) do 
        if v.Backpack:FindFirstChild("Knife") or v.Character:FindFirstChild("Knife") and v.Name == "Tool" then
            return v.Name
        end
    end
    return nil
end

function GetSheriff()
    for i,v in pairs(Players:GetChildren()) do 
        if v.Backpack:FindFirstChild("Gun") or v.Character:FindFirstChild("Gun") and v.Name == "Tool" then
            return v.Name
        end
        return nil
    end
end





local Main_Tab = Window:NewTab("Main")
local Main_Character = Main_Tab:NewSection("Character")

Main_Character:NewSlider("WalkSpeed", "Changes your walkspeed", 150, 16, function(s)
    Humanoid.WalkSpeed = s
end)

Main_Character:NewSlider("JumpPower", "Changes your jumppower", 150, 50, function(s)
    Humanoid.JumpPower = s
end)

local Main_Teleport = Main_Tab:NewSection("Teleport")

Main_Teleport:NewToggle("ClickTP (CTRL + Click)", "Toggles ClickTP", function(state)
    getgenv().ClickTP = state;
end)

Mouse.Button1Down:connect(function()
    if not game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftControl) then return end;
    if not Mouse.Target then return end;
    if not getgenv().ClickTP then return end;
    Character:MoveTo(Mouse.Hit.p);
end)

local Autofarm_Tab = Window:NewTab("Autofarm")
local Autofarm_Section = Autofarm_Tab:NewSection("Autofarm")

Autofarm_Section:NewDropdown("Autofarm Target", "Choose the autofarm target", {"Coin", "XP"}, function(currentOption)
    getgenv().AutofarmTarget = currentOption
end)


Autofarm_Section:NewToggle("Toggle", "Toggles autofarm", function(state)
    getgenv().Autofarm = state

    if not getgenv().AutofarmTarget then return end
    if getgenv().AutofarmTarget == "Coin" then
        while getgenv().Autofarm do
            task.wait()
            local CoinContainer = Workspace:FindFirstChild("CoinContainer", true)
            if CoinContainer and Client.PlayerGui.MainGUI.Game.CashBag.Visible == true then
                local coin = CoinContainer:FindFirstChild("Coin_Server")
                if coin then
                    repeat
                        RootPart.CFrame = CFrame.new(coin.Position + Vector3.new(0, 3.5, 0)) * CFrame.Angles(0, 0, math.rad(180))
                        RunService.Stepped:Wait(0.1)
                        if not getgenv().Autofarm then break end
                    until not coin:IsDescendantOf(Workspace) or coin.Name ~= "Coin_Server" or Client.PlayerGui.MainGUI.Game.CashBag.Full.Visible
                    task.wait(1.1)
                end
            else
                task.wait(1.5)
            end
        end
    else
        while getgenv().Autofarm do
            wait()
            if Client.PlayerGui.MainGUI.Game.CashBag.Visible == true then
                RootPart.CFrame = CFrame.new(-121.12338256836, 138.27394104004, 38.946128845215)
            end
        end
    end

end)


local ESP_Tab = Window:NewTab("ESP")
local ESP_PlayerESP = ESP_Tab:NewSection("PlayerESP")

local folder = Instance.new("Folder",CoreGui)
folder.Name = "ESP Holder"
	
local function AddBillboard(player)
    local billboard = Instance.new("BillboardGui",folder)
    billboard.Name = player.Name
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.fromOffset(200,50)
    billboard.ExtentsOffset = Vector3.new(0,3,0)
    billboard.Enabled = false

    local textLabel = Instance.new("TextLabel",billboard)
    textLabel.TextSize = 20
    textLabel.Text = player.Name
    textLabel.Font = Enum.Font.Arial
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.fromScale(1,1)

    if getgenv().AllEsp then
        billboard.Enabled = true
    end
    repeat
        wait()
        pcall(function()
            billboard.Adornee = player.Character.Head
            if player.Character:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife") then
                textLabel.TextColor3 = Color3.new(1,0,0)
                if not billboard.Enabled and getgenv().MurderEsp then
                    billboard.Enabled = true
                end
            elseif player.Character:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun") then
                textLabel.TextColor3 = Color3.new(0,0,1)
                if not billboard.Enabled and getgenv().SheriffEsp then
                    billboard.Enabled = true
                end
            else
                textLabel.TextColor3 = Color3.new(0,1,0)
            end
        end)
    until not player.Parent
end

for _,player in pairs(Players:GetPlayers()) do
    if player ~= Client then
        coroutine.wrap(AddBillboard)(player)
    end
end
Players.PlayerAdded:Connect(AddBillboard)

Players.PlayerRemoving:Connect(function(player)
    folder[player.Name]:Destroy()
end)




-- Keybinds

local Keybinds_Tab = Window:NewTab("Keybinds")
local Keybinds_Section = Keybinds_Tab:NewSection("Keybinds")


Keybinds_Section:NewKeybind("Toggle GUI", "Toggles the GUI on and off", Enum.KeyCode.Delete, function()
	Library:ToggleUI()
end)


-- About

local About_Tab = Window:NewTab("About")
local About_Section = About_Tab:NewSection("About")
local About_Authors = About_Section:NewLabel("Authors: VRX#0001, HuskyPoe#5284")
local About_Version = About_Section:NewLabel("Version: 0.0.1")

About_Section:NewButton("Official Discord Server (It will be in your clipboard)", "Link to our official Discord server.", function()
    setclipboard('https://discord.gg/5bjTbbr85k')
end)