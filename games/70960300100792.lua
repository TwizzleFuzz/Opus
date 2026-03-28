local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Purple = Color3.fromHex("#7775F2")
local Yellow = Color3.fromHex("#ECA201")
local Green = Color3.fromHex("#10C550")
local Blue = Color3.fromHex("#257AF7")

local Window = WindUI:CreateWindow({
	Title = "Roblox Script",
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
		print("Auto Click dropper state:", state)
	end,
})

local TreeGroup = MainTab:Group()

TreeGroup:Toggle({
	Title = "Auto Chop tree",
	Callback = function(state)
		print("Auto Chop tree state:", state)
	end,
})

local CoinsGroup = MainTab:Group()

CoinsGroup:Toggle({
	Title = "Auto Collect coins",
	Callback = function(state)
		print("Auto Collect coins state:", state)
	end,
})

pcall(function()
	MainTab:Select()
end)

WindUI:Notify({
	Title = "iOS UI Loaded",
	Content = "Main UI in iOS style has been loaded!",
	Duration = 5,
})
