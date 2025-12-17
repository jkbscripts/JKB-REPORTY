local activeReports = {}

local function sendDiscordLog(data)
    local hiddenIP = "||" .. data.ip .. "||" 
    local brandingLogo = "https://cdn.discordapp.com/attachments/1450410466839892018/1450473027736440883/DB07C26C-D4EB-4671-828E-719AF741DE35.png?ex=69435286&is=69420106&hm=01bafcc10d6b5c977d1c2d37c266efb446e9972bfbf5737d51ee81583178d525&"
    
    local embed = {
        {
            ["color"] = 16711680,
            ["title"] = "📩 Nový Report #" .. data.id,
            ["description"] = string.format(
                "**Hráč:** %s\n**Server ID:** %s\n**IP:** %s\n**Zpráva:** %s\n\n**Screenshot:** %s",
                data.name, data.sourceId, hiddenIP, data.reason, data.screenshot or "Není k dispozici"
            ),
            ["image"] = { ["url"] = data.screenshot },
            ["footer"] = { 
                ["text"] = "JKB Scripts - REPORT LOG | " .. data.time,
                ["icon_url"] = brandingLogo
            },
        }
    }

    PerformHttpRequest(Config.Webhook, function(err, text, headers) end, 'POST', json.encode({
        username = "JKB Scripts - REPORT LOG",
        avatar_url = brandingLogo,
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

RegisterServerEvent('jkb_reporty:sendReport', function(reason, screenshotUrl)
    local src = source
    local playerName = GetPlayerName(src)
    local playerIP = GetPlayerEndpoint(src) or "Neznámá"
    local reportId = #activeReports + 1
    local time = os.date('%H:%M:%S')

    local data = {
        id = reportId,
        sourceId = src,
        name = playerName,
        ip = playerIP,
        reason = reason,
        screenshot = screenshotUrl,
        time = time
    }

    table.insert(activeReports, data)
    sendDiscordLog(data)

    TriggerClientEvent('ox_lib:notify', src, {title = 'Report odeslán', description = 'Admini byli informováni.', type = 'success'})
end)

RegisterCommand('reporty', function(source)
    local src = source
    if #activeReports == 0 then
        TriggerClientEvent('ox_lib:notify', src, {title = 'Žádné reporty', type = 'inform'})
    else
        TriggerClientEvent('jkb_reporty:openMenu', src, activeReports)
    end
end)

RegisterServerEvent('jkb_reporty:teleport', function(targetId)
    local src = source
    local targetPed = GetPlayerPed(targetId)
    if targetPed and targetPed ~= 0 then
        local coords = GetEntityCoords(targetPed)
        SetEntityCoords(GetPlayerPed(src), coords.x, coords.y, coords.z)
    else
        TriggerClientEvent('ox_lib:notify', src, {title = 'Hráč není online', type = 'error'})
    end
end)

RegisterServerEvent('jkb_reporty:delete', function(id)
    local src = source
    for i, v in ipairs(activeReports) do
        if v.id == id then
            table.remove(activeReports, i)
            break
        end
    end
    TriggerClientEvent('ox_lib:notify', src, {title = 'Report uzavřen', type = 'success'})
    TriggerClientEvent('jkb_reporty:openMenu', src, activeReports)
end)