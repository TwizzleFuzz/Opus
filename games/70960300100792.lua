local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Purple = Color3.fromHex("#7775F2")
local Yellow = Color3.fromHex("#ECA201")
local Green = Color3.fromHex("#10C550")
local Blue = Color3.fromHex("#257AF7")

local autoCash = false
local autoBronze = false
local autoCollectCoins = false
local autoAttack = false
local autoChopTree = false
local isRunning = true

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local DropperClickRemote = Remotes:WaitForChild("DropperClick")
local BronzeDropperClickRemote = Remotes:WaitForChild("BronzeDropperClick")
local CollectPartRemote = Remotes:WaitForChild("CollectPart")
local MobAttackMltRemote = Remotes:WaitForChild("MobAttackMlt")
local TreeHitRemote = Remotes:WaitForChild("TreeHit")

task.spawn(function()
	while isRunning do
		if autoCash then
			pcall(function()
				DropperClickRemote:FireServer()
			end)
		end
		if autoBronze then
			pcall(function()
				BronzeDropperClickRemote:FireServer()
			end)
		end
		if autoAttack then
			pcall(function()
				MobAttackMltRemote:FireServer()
			end)
		end
		if autoChopTree then
			pcall(function()
				TreeHitRemote:FireServer()
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
	Folder = "Opus/Dropper Incremental",
	Icon = "solar:gamepad-bold",
	NewElements = true,
	HideSearchBar = false,
	Size = UDim2.fromOffset(650, 450),
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

MainTab:Section({
	Title = "Droppers"
})

local DropperGroup = MainTab:Group()

DropperGroup:Toggle({
	Title = "Auto Cash",
	Callback = function(state)
		autoCash = state
	end,
})

DropperGroup:Toggle({
	Title = "Auto Bronze",
	Callback = function(state)
		autoBronze = state
	end,
})

MainTab:Section({
	Title = "Farming"
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

local TreeGroup = MainTab:Group()

TreeGroup:Toggle({
	Title = "Auto Chop tree",
	Callback = function(state)
		autoChopTree = state
	end,
})

local AttackGroup = MainTab:Group()

AttackGroup:Toggle({
	Title = "Auto Attack",
	Callback = function(state)
		autoAttack = state
	end,
})

if type(Window.Destroy) == "function" then
	local oldDestroy = Window.Destroy
	Window.Destroy = function(self, ...)
		isRunning = false
		autoCash = false
		autoBronze = false
		autoCollectCoins = false
		autoAttack = false
		autoChopTree = false
		return oldDestroy(self, ...)
	end
end

pcall(function()
	MainTab:Select()
end)
