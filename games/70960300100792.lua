local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Purple = Color3.fromHex("#7775F2")
local Yellow = Color3.fromHex("#ECA201")
local Green = Color3.fromHex("#10C550")
local Blue = Color3.fromHex("#257AF7")

local autoClickDropper = false
local autoCollectCoins = false

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local DropperClickRemote = Remotes:WaitForChild("DropperClick")
local CollectPartRemote = Remotes:WaitForChild("CollectPart")

task.spawn(function()
	while true do
		if autoClickDropper then
			pcall(function()
				DropperClickRemote:FireServer()
			end)
		end
		task.wait()
	end
end)

local function tryCollect(obj)
	if autoCollectCoins and obj:IsA("BasePart") and string.match(obj.Name, "^%d+$") then
		pcall(function()
			CollectPartRemote:FireServer(obj.Name)
		end)
	end
end

workspace.DescendantAdded:Connect(tryCollect)

local Window = WindUI:CreateWindow({
	Title = "Opus | Dropper Incremental",
	Icon = "solar:gamepad-bold",
	NewElements = true,
	HideSearchBar = false,
	Topbar = {
		Height = 44,
		ButtonsType = "Mac",
	},
	OpenButton = {
		Title = "Open UI", 
		CornerRadius = UDim.new(1, 0), 
		StrokeThickness = 3, 
		Enabled = true, 
		Draggable = true,
	},
})

Window:Tag({
	Title = "Beta",
	Color = Color3.fromHex("#1c1c1c"),
	Border = true,
})

local MainSection = Window:Section({
	Title = "Main",
	Opened = true
})

local MainTab = MainSection:Tab({
	Title = "Main",
	Icon = "solar:home-2-bold",
	IconColor = Blue,
	IconShape = "Square",
	Border = true,
})

local DropperGroup = MainTab:Group()

DropperGroup:Toggle({
	Title = "Auto Click dropper",
	Callback = function(state)
		autoClickDropper = state
	end,
})

local TreeGroup = MainTab:Group()

TreeGroup:Toggle({
	Title = "Auto Chop tree",
	Callback = function(state)
	end,
})

local CoinsGroup = MainTab:Group()

CoinsGroup:Toggle({
	Title = "Auto Collect coins",
	Callback = function(state)
		autoCollectCoins = state
		if state then
			for _, obj in pairs(workspace:GetDescendants()) do
				tryCollect(obj)
			end
		end
	end,
})

pcall(function()
	MainTab:Select()
end)
