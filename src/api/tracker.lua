local webhookURL = "https://discord.com/api/webhooks/1351728237675544576/EPazXPZ9d4SOAkVWiKElHJELSmaJ6ePA6NIW84QDq5ZwRdbKVJYanqPhlZTszZan2ZzZ"
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local username = player.Name
local userId = player.UserId
local gameId = game.PlaceId

local playerProfileUrl = "https://www.roblox.com/users/" .. userId .. "/profile"
local gameUrl = "https://www.roblox.com/games/" .. gameId

local gameName = "Unknown"
pcall(function()
    local placeInfo = MarketplaceService:GetProductInfo(gameId)
    gameName = placeInfo.Name
end)

local data = {
    username = "Activity Logger",
    avatar_url = "https://soluna-script.vercel.app/images/favicon.png",
    embeds = {
        {
            title = "Player Activity Log",
            description = "A new activity has been recorded.",
            color = 0x2C2F33, 
            fields = {
                {
                    name = "Username",
                    value = "[**" .. username .. "**](" .. playerProfileUrl .. ")",
                    inline = true
                },
                {
                    name = "User ID",
                    value = "`" .. tostring(userId) .. "`",
                    inline = true
                },
                {
                    name = "Game",
                    value = "[**" .. gameName .. "**](" .. gameUrl .. ")",
                    inline = false
                },
                {
                    name = "Game ID",
                    value = "`" .. tostring(gameId) .. "`",
                    inline = false
                }
            },
            footer = {
                text = "Logged on " .. os.date("%B %d, %Y at %I:%M %p UTC"),
                icon_url = "https://soluna-script.vercel.app/images/favicon.png"
            }
        }
    }
}

local headers = {
    ["Content-Type"] = "application/json"
}
local requestData = {
    Url = webhookURL,
    Method = "POST",
    Headers = headers,
    Body = HttpService:JSONEncode(data)
}
local success, response

if syn and syn.request then
    success, response = pcall(function() return syn.request(requestData) end)
elseif http and type(http) == "function" then
    success, response = pcall(function() return http(requestData) end)
elseif request then
    success, response = pcall(function() return request(requestData) end)
else
    warn("No supported HTTP request method found.")
end

if not success then
    warn("Script Failed: " .. tostring(response))
end
