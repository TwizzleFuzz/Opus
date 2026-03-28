local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
	Title = "Game not supported!",
	Icon = "solar:danger-triangle-bold",
	NewElements = true,
	HideSearchBar = true,
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
	Title = "Supported Games",
	Opened = true
})

local SupportedTab = MainSection:Tab({
	Title = "Game supported",
	Icon = "solar:gamepad-bold",
	IconColor = Color3.fromHex("#10C550"),
	IconShape = "Square",
	Border = true,
})

local GamesGroup = SupportedTab:Group()

GamesGroup:Button({
	Title = "Dropper Incremental",
	Desc = "ID: 70960300100792",
	Callback = function()
		Window:Destroy()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/TwizzleFuzz/Opus/main/games/70960300100792.lua"))()
	end,
})

pcall(function()
	SupportedTab:Select()
end)

WindUI:Notify({
	Title = "Opus Hub",
	Content = "Этот плейс пока не поддерживается. Выберите скрипт из списка!",
	Duration = 5,
})
