local Games = {
  [70960300100792] = "https://raw.githubusercontent.com/TwizzleFuzz/Opus/main/games/70960300100792.lua", 
}
local URL = Games[game.PlaceId] or Games[game.GameId]
if URL then
  loadstring(game:HttpGet(URL))()
else
  loadstring(game:HttpGet("https://raw.githubusercontent.com/TwizzleFuzz/Opus/main/games/Notsupported.lua"))()
end
