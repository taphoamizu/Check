local HttpService = game:GetService(“HttpService”)
local Players = game:GetService(“Players”)
local ReplicatedStorage = game:GetService(“ReplicatedStorage”)
local RunService = game:GetService(“RunService”)

local player = Players.LocalPlayer
local webhookUrl = “https://discord.com/api/webhooks/1224719720612237463/yB3d-J4W_CcDg7YGsPHLCHHREMydZnuNwkh5lvJd7foV_FXmSjHBjAxpCWd8A0DVqtj_”

local fragmentCheckActive = false
local lastFragmentCount = 0

function getFragmentCount()
local success, result = pcall(function()
return ReplicatedStorage.Remotes.CommF_:InvokeServer(“getFragments”)
end)

```
if success and type(result) == "number" then
    return result
end

-- Backup method - check player data
local success2, result2 = pcall(function()
    if player:FindFirstChild("Data") and player.Data:FindFirstChild("Fragments") then
        return player.Data.Fragments.Value
    end
end)

if success2 and type(result2) == "number" then
    return result2
end

return 0
```

end

function sendWebhook(fragments)
local data = {
content = “@everyone”,
embeds = {{
title = “🎉 FRAGMENT MILESTONE REACHED!”,
description = string.format(”**Player:** %s\n**Fragments:** %s\n**Server:** %s\n**Time:** %s”,
player.Name,
string.format(”%,d”, fragments):gsub(”,”, “.”),
game.JobId,
os.date(”%Y-%m-%d %H:%M:%S”)
),
color = 65280, – Green color
thumbnail = {
url = “https://www.roblox.com/headshot-thumbnail/image?userId=” .. player.UserId .. “&width=420&height=420&format=png”
},
footer = {
text = “Fragment Tracker • “ .. game:GetService(“MarketplaceService”):GetProductInfo(game.PlaceId).Name
},
timestamp = os.date(”!%Y-%m-%dT%H:%M:%SZ”)
}}
}

```
local success, response = pcall(function()
    return HttpService:PostAsync(webhookUrl, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
end)

if success then
    print("✅ Webhook sent successfully!")
else
    warn("❌ Failed to send webhook:", response)
end
```

end

function startFragmentCheck()
if fragmentCheckActive then
print(“Fragment checker already running!”)
return
end

```
fragmentCheckActive = true
print("🔍 Fragment checker started - Target: 100,000 fragments")

spawn(function()
    while fragmentCheckActive do
        wait(5) -- Check every 5 seconds
        
        local currentFragments = getFragmentCount()
        
        if currentFragments > 0 and currentFragments ~= lastFragmentCount then
            print(string.format("💎 Current fragments: %s", string.format("%,d", currentFragments):gsub(",", ".")))
            lastFragmentCount = currentFragments
            
            if currentFragments >= 100000 then
                print("🎉 100K FRAGMENTS REACHED!")
                sendWebhook(currentFragments)
                fragmentCheckActive = false
                break
            end
        end
    end
end)
```

end

function stopFragmentCheck()
fragmentCheckActive = false
print(“🛑 Fragment checker stopped”)
end

– Auto start
startFragmentCheck()

– Manual commands
_G.FragmentChecker = {
start = startFragmentCheck,
stop = stopFragmentCheck,
check = function()
local current = getFragmentCount()
print(string.format(“💎 Current fragments: %s”, string.format(”%,d”, current):gsub(”,”, “.”)))
return current
end,
setWebhook = function(url)
webhookUrl = url
print(“✅ Webhook URL updated!”)
end
}