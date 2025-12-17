RegisterCommand('report', function()
    local input = lib.inputDialog('Nahlásit problém', {
        {
            type = 'textarea', 
            label = 'Popis situace', 
            placeholder = 'Detailně popište svůj problém...', 
            required = true, 
            min = Config.MinLength
        },
    })

    if input then
        lib.notify({title = 'Zpracovávám...', description = 'Pořizuji screenshot a odesílám report.', type = 'inform'})

        exports['screencapture']:requestScreenshotUpload(Config.Webhook, "files[]", function(data)
            local resp = json.decode(data)
            local screenshotUrl = nil

            if resp and resp.attachments and resp.attachments[1] then
                screenshotUrl = resp.attachments[1].url
            end

            TriggerServerEvent('jkb_reporty:sendReport', input[1], screenshotUrl)
        end)
    end
end)

RegisterNetEvent('jkb_reporty:openMenu', function(reports)
    local options = {}

    for i, v in ipairs(reports) do
        table.insert(options, {
            title = 'ID: ' .. v.sourceId .. ' | ' .. v.name,
            description = 'Důvod: ' .. v.reason:sub(1, 40) .. '...',
            icon = 'clipboard-list',
            arrow = true,
            onSelect = function()
                OpenReportDetail(v)
            end
        })
    end

    lib.registerContext({
        id = 'jkb_report_main',
        title = 'Aktivní Reporty',
        options = options
    })
    lib.showContext('jkb_report_main')
end)

function OpenReportDetail(data)
    local options = {
        {
            title = 'Informace o hráči',
            description = ('Jméno: %s\nID: %s\nČas: %s'):format(data.name, data.sourceId, data.time),
            icon = 'user'
        },
        {
            title = 'Informace podané k reportu',
            description = data.reason,
            icon = 'comment'
        }
    }

    table.insert(options, {
        title = 'Zobrazit screenshot',
        icon = 'image',
        disabled = not data.screenshot,
        description = not data.screenshot and 'Screenshot není k dispozici',
        onSelect = function()
            if data.screenshot then
                lib.alertDialog({
                    header = 'Screenshot reportu #' .. data.id,
                    content = '![Screenshot](' .. data.screenshot .. ')',
                    centered = true,
                    size = 'xl',
                    labels = {
                        confirm = 'Zavřít'
                    }
                })
            end
        end
    })

    table.insert(options, {
        title = 'Teleport se k hráči',
        icon = 'location-dot',
        onSelect = function()
            TriggerServerEvent('jkb_reporty:teleport', data.sourceId)
        end
    })

    table.insert(options, {
        title = 'Uzavřít report',
        icon = 'trash',
        onSelect = function()
            TriggerServerEvent('jkb_reporty:delete', data.id)
        end
    })

    lib.registerContext({
        id = 'jkb_report_detail',
        title = 'Detail Reportu #' .. data.id,
        menu = 'jkb_report_main',
        options = options
    })
    lib.showContext('jkb_report_detail')
end

RegisterKeyMapping('report', 'Vytvořit Report', 'keyboard', '')