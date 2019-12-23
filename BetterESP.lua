---
--- Title: BetterESP™
--- Author: superyu'#7167
--- Description: Better ESP for aimware, purpose of this is to make people not get eye cancer using the cheat.
---

--- Auto updater Variables
local SCRIPT_FILE_NAME = GetScriptName();
local SCRIPT_FILE_ADDR = "https://raw.githubusercontent.com/superyor/betteresp/master/betteresp.lua";
local VERSION_FILE_ADDR = "https://raw.githubusercontent.com/superyor/betteresp/master/version.txt"; --- in case of update i need to update this. (Note by superyu'#7167 "so i don't forget it.")
local VERSION_NUMBER = "1.0.0"; --- This too
local version_check_done = false;
local update_downloaded = false;
local update_available = false;

--- Auto Updater GUI Stuff
local betteresp_autoupdater_wnd = gui.Window("rbot__betteresp_autoupdater_wnd", "Auto Updater for BetterESP™ | v" .. VERSION_NUMBER, 0, 0, 400, 180)
local betteresp_autoupdater_grp = gui.Groupbox(betteresp_autoupdater_wnd, "", 15, 15, 370, 100)
local betteresp_autoupdater_text = gui.Text(betteresp_autoupdater_grp, "")
local betteresp_autoupdater_wnd_active = 1;
local betteresp_autoupdater_wnd_closed = false;
local betteresp_autoupdater_button = gui.Button(betteresp_autoupdater_grp, "Close", function() betteresp_autoupdater_wnd_active = 0 betteresp_autoupdater_wnd_closed = true end)

--- Main GUI Stuff
local suyu_esp_wnd_active = gui.Checkbox(gui.Reference("SETTINGS", "Miscellaneous"), "suyu_esp_wnd_active", "Show BetterESP™", 0)
local suyu_esp_wnd = gui.Window("suyu_enemy_wnd", "BetterESP™ | v" .. VERSION_NUMBER, 50, 50, 445, 775)

--- Main GUI Groups
--- Left
local mainSettings_grp = gui.Groupbox(suyu_esp_wnd, "Main", 15, 15, 200, 185)
local suyu_esp_fontMain_grp = gui.Groupbox(suyu_esp_wnd, "Main", 15, 215, 200, 150)
local suyu_esp_fontName_grp = gui.Groupbox(suyu_esp_wnd, "Name", 15, 265+115, 200, 100)
local suyu_esp_fontWeapon_grp = gui.Groupbox(suyu_esp_wnd, "Weapon", 15, 265+115+115, 200, 100)
local suyu_esp_fontFlags_grp = gui.Groupbox(suyu_esp_wnd, "Flags", 15, 265+115+115+115, 200, 100)

--- Right
local enemySettings_grp = gui.Groupbox(suyu_esp_wnd, "Enemy", 230, 15, 200, 200 )
local teamSettings_grp = gui.Groupbox(suyu_esp_wnd, "Team", 230, 230, 200, 200 )
local weaponSettings_grp = gui.Groupbox(suyu_esp_wnd, "Weapons", 230, 460-15, 200, 125 )
local nadeSettings_grp = gui.Groupbox(suyu_esp_wnd, "Nades", 230, 690-30-50-25, 200, 125 )

--- Main GUI Controllers
--- Drawing GUI Stuff
local espSettings = gui.Multibox(mainSettings_grp, "ESP Settings")
local Master = gui.Checkbox(espSettings, "suyu_esp_active", "Enabled", 0)
local precision = gui.Checkbox(espSettings, "suyu_esp_precision", "Precision", 0)
local rounded = gui.Checkbox(espSettings, "suyu_esp_rounded", "Rounded", 0)
local boxOutline = gui.Checkbox(espSettings, "suyu_esp_boxoutline", "Box Outline", 0)
local textShadow = gui.Checkbox(espSettings, "suyu_esp_textShadow", "Text Shadow", 0)
local textLower = gui.Checkbox(espSettings, "suyu_esp_textLower", "Force lowercase", 0)

local FilterMulti = gui.Multibox(mainSettings_grp, "ESP Filters" )
local enemyMaster = gui.Checkbox(FilterMulti, "suyu_esp_enemy_enable", "Enemies", 0)
local teamMaster = gui.Checkbox(FilterMulti, "suyu_esp_team_enable", "Teammates", 0)
local weaponsMaster = gui.Checkbox(FilterMulti, "suyu_esp_weapons_enable", "Weapons", 0)
local nadesMaster = gui.Checkbox(FilterMulti, "suyu_esp_nades_enable", "Nades", 0)
local barsBlueValue = gui.Slider(mainSettings_grp, "suyu_esp_bars_bluevalue", "Bars Blue value", 0, 0, 255)

local enemyBox = gui.Checkbox(enemySettings_grp, "suyu_esp_enemy_box", "Box", 0)
local enemyName = gui.Checkbox(enemySettings_grp, "suyu_esp_enemy_name", "Name", 0)
local enemyWeapon = gui.Checkbox(enemySettings_grp, "suyu_esp_enemy_weapon", "Weapon", 0)
local enemyHealth = gui.Combobox(enemySettings_grp, "suyu_esp_enemy_health", "Health", "Off", "Bar", "Number", "Both", "Number Bottom")
local enemyFlagMulti = gui.Multibox(enemySettings_grp, "Flags" )
local enemyArmorFlag = gui.Checkbox(enemyFlagMulti, "suyu_esp_enemy_flag_armor", "Armor", 0)
local enemyZoomFlag = gui.Checkbox(enemyFlagMulti, "suyu_esp_enemy_flag_zoom", "Zoom", 0)
local enemyFakeduckFlag = gui.Checkbox(enemyFlagMulti, "suyu_esp_enemy_flag_fakeduck", "Fakeduck", 0)
local enemyDesyncFlag = gui.Checkbox(enemyFlagMulti, "suyu_esp_enemy_flag_desync", "Desync", 0)

local teamBox = gui.Checkbox(teamSettings_grp, "suyu_esp_team_box", "Box", 0)
local teamName = gui.Checkbox(teamSettings_grp, "suyu_esp_team_name", "Name", 0)
local teamWeapon = gui.Checkbox(teamSettings_grp, "suyu_esp_team_weapon", "Weapon", 0)
local teamHealth = gui.Combobox(teamSettings_grp, "suyu_esp_team_health", "Health", "Off", "Bar", "Number", "Both")
local teamFlagMulti = gui.Multibox(teamSettings_grp, "Flags" )
local teamArmorFlag = gui.Checkbox(teamFlagMulti, "suyu_esp_team_flag_armor", "Armor", 0)
local teamZoomFlag = gui.Checkbox(teamFlagMulti, "suyu_esp_team_flag_zoom", "Zoom", 0)
local teamFakeduckFlag = gui.Checkbox(teamFlagMulti, "suyu_esp_team_flag_fakeduck", "Fakeduck", 0)

local weaponsBox = gui.Checkbox(weaponSettings_grp, "suyu_esp_weapons_box", "Box", 0)
local weaponsName = gui.Checkbox(weaponSettings_grp, "suyu_esp_weapons_name", "Name", 0)
local weaponsAmmo = gui.Combobox(weaponSettings_grp, "suyu_esp_weapons_health", "Ammo", "Off", "Bar", "Number", "Both")

local nadesBox = gui.Checkbox(nadeSettings_grp, "suyu_esp__nades_box", "Box", 0)
local nadesName = gui.Checkbox(nadeSettings_grp, "suyu_esp_nades_name", "Name", 0)
local nadesTimer = gui.Combobox(nadeSettings_grp, "suyu_esp_nades_timer", "Timer", "Off", "Bar", "Number", "Both")

--- Font Window GUI Stuff
local fontNameMain = gui.Editbox(suyu_esp_fontMain_grp, "suyu_font_type_main", "Verdana")
local fontSizeMain = gui.Slider(suyu_esp_fontMain_grp, "suyu_font_size_main", "Size", 11, 5, 20 )
local fontWeightMain = gui.Slider(suyu_esp_fontMain_grp, "suyu_font_weight_main", "Weight", 600, 1, 1000)

local fontNameName = gui.Editbox(suyu_esp_fontName_grp, "suyu_font_type_name", "Verdana")
local fontSizeName = gui.Slider(suyu_esp_fontName_grp, "suyu_font_size_name", "Size Name", 12, 5, 20 )

local fontNameWeapon = gui.Editbox(suyu_esp_fontWeapon_grp, "suyu_font_type_weapon", "Verdana")
local fontSizeWeapon = gui.Slider(suyu_esp_fontWeapon_grp, "suyu_font_size_weapon", "Size Weapon", 11, 5, 20 )

local fontNameFlags = gui.Editbox(suyu_esp_fontFlags_grp, "suyu_font_type_flags", "Verdana")
local fontSizeFlags = gui.Slider(suyu_esp_fontFlags_grp, "suyu_font_size_flags", "Size Flags", 9, 5, 20 )

--- Listeners
client.AllowListener("round_start")
client.AllowListener("inferno_startburn")
client.AllowListener("inferno_expire")
client.AllowListener("inferno_extinguish")
client.AllowListener("smokegrenade_detonate")
client.AllowListener("smokegrenade_expired")

--- Variables
local menuPressed = 1
local drawBox = draw.OutlinedRect
local drawFilledBox = draw.FilledRect
local pLocal = entities.GetLocalPlayer()
local storedTick = 0
local lastTick = 0;

--- Tables
local max_ammo = {
    7, 30, 20, 20, 0, 0, 30, 30, 10, 25, 20, 0, 35, 100, 0, 30, 30, 18, 50, 0, 0, 0, 30, 25, 7, 64, 5, 150, 7, 18, 0, 13, 30, 30, 8, 13, 0, 20, 30, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 25, 12, 0, 12, 8
}
local crouched_ticks = {}
local Molotovs = {}
local Smokes = {}
local isDesyncing = {};
local lastSimtime = {};
local desyncCooldown = {};

--- Helpers
local function toBits(num)
    local t = { }
    while num > 0 do
        local rest = math.fmod(num,2)
        t[#t+1] = rest
        num = (num-rest) / 2
    end
 
    return t
end

local function isNade(pEntity)

    local class = pEntity:GetClass()

    if class == "CSmokeGrenade" or class == "CIncendiaryGrenade" or class =="CMolotovGrenade" or class == "CHEGrenade" 
        or class == "CDecoyGrenade" or class == "CSmokeGrenadeProjectile" or class == "CBaseCSGrenadeProjectile" then

        return true;
    else
        return false;
    end
end

local function round(num, numDecimalPlaces)
        return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

local function drawText(x, y, text)

    if textLower:GetValue() then
        text = string.lower(text)
    else
        text = string.upper(text)
    end

    if textShadow:GetValue() then
        draw.TextShadow( x, y, text)
    else
        draw.Text(x, y, text)
    end

end

local function TIME_TO_TICKS(time)
    local TICK_INTERVAL	= globals.TickInterval()
    return round((0.5 + (time) / TICK_INTERVAL), 0);
end

local function getFont(fontName, size, weight)
    return draw.CreateFont(fontName, round(size, 0), round(weight,0))
end

local function isFakeducking(pEntity)
    local index = pEntity:GetIndex()
    local m_flDuckAmount = pEntity:GetProp("m_flDuckAmount")
    local m_flDuckSpeed = pEntity:GetProp("m_flDuckSpeed")
    local m_fFlags = pEntity:GetProp("m_fFlags")

    if crouched_ticks[index] == nil then
        crouched_ticks[index] = 0
    end

    if m_flDuckSpeed ~= nil and m_flDuckAmount ~= nil then
        if m_flDuckSpeed == 8 and m_flDuckAmount <= 0.9 and m_flDuckAmount > 0.01 and toBits(m_fFlags)[1] == 1 then
            if storedTick ~= globals.TickCount() then
                crouched_ticks[index] = crouched_ticks[index] + 1
                storedTick = globals.TickCount()
            end

            if crouched_ticks[index] >= 5 then
                return true
            end
        else
            crouched_ticks[index] = 0
        end
    end
    return false;
end

local function drawBar(x1, y1, x2, y2, value, maxValue, type, bottom)

    if value > maxValue then value = maxValue end

    local h = y2 - y1
    local w = x2 - x1
    local valuePercentageH = h - ((h * value) / maxValue)
    local valuePercentageW = w - ((w * value) / maxValue)
    local valueString
    local textWidth, textHeight

    if bottom then
        valueString = value .. " / " .. maxValue
        textWidth, textHeight = draw.GetTextSize(valueString)
    else
        textWidth, textHeight = draw.GetTextSize(value)
    end

    local colorMultiplier = 255 / maxValue
    local blue = round(barsBlueValue:GetValue(), 0)

    if bottom then
        if type == 1 then
            draw.Color(25, 25, 25, 155)
            drawFilledBox( x1, y2+5, x2, y2+10)
            if value > 0 then
                draw.Color(255 - (value * colorMultiplier), (value * colorMultiplier), blue, 255)
                drawFilledBox( x1, y2 + 6, x2 - valuePercentageW, y2 + 9)
            end
            draw.Color(255, 255, 255, 255)
        elseif type == 2 then
            drawText(x1 + (w / 2) - (textWidth/2) , y2 + 2 , valueString)
        elseif type == 3 then
            draw.Color(0, 0, 0, 155)
            drawFilledBox( x1, y2+5, x2, y2+10)
            if value > 0 then
            draw.Color(255 - (value * colorMultiplier), (value * colorMultiplier), blue, 255)
            drawFilledBox( x1, y2 + 6, x2 - valuePercentageW, y2 + 9)
            end
            draw.Color(255, 255, 255, 255)
            drawText(x1 + (w / 2) - (textWidth/2),  y2 + textHeight, valueString)
        end
    else
        if type == 1 then
            draw.Color(0, 0, 0, 155)
            drawFilledBox( x1-8, y1+1, x1-3, y2-1 )
            draw.Color(255 - (value * colorMultiplier), (value * colorMultiplier), blue, 255)
            drawFilledBox( x1-7, y1 + valuePercentageH+2, x1-4, y2-2)
            draw.Color(255, 255, 255, 255)
        elseif type == 2 then
            drawText(x1 - textWidth - 3 , y1 + (h/2) - (textHeight/2) , value)
        elseif type == 3 then
            draw.Color(0, 0, 0, 155)
            drawFilledBox( x1-8, y1+1, x1-3, y2-1 )
            if value > 0 then
            draw.Color(255 - (value * colorMultiplier), (value * colorMultiplier), blue, 255)
            drawFilledBox( x1-7, y1 + valuePercentageH+2, x1-4, y2-2)
            end
            draw.Color(255, 255, 255, 255)
            if value ~= maxValue then
                drawText(x1-(textWidth/2)-6, y1 + valuePercentageH - (textHeight/2) , value)
            end
        elseif type == 4 then
            if enemyWeapon:GetValue() then
                drawText(x2 - (w/2) - (textWidth/2) , y2 + fontSizeWeapon:GetValue() , value)
            else
                drawText(x2 - (w/2) - (textWidth/2) , y2 , value)
            end
        end
    end
end


local function drawESPEntity(pEntity, x1, y1, x2, y2, masterEnabled, boxEnabled, nameEnabled, weaponEnabled, healthType, armorEnabled, zoomEnabled, fakeduckEnabled, desyncEnabled)

    if masterEnabled then
        draw.SetFont(getFont(fontNameMain:GetValue(), fontSizeMain:GetValue(), fontWeightMain:GetValue()))
        draw.Color(255, 255, 255, 255)

        --- Box
        if boxEnabled then
            if boxOutline:GetValue() then
                draw.Color(25, 25, 25, 200)
                drawBox(x1+1, y1+1, x2-1, y2-1)
                drawBox(x1-1, y1-1, x2+1, y2+1)
            end

            draw.Color(255, 244, 255, 255)
            drawBox(x1, y1, x2, y2)
        end

        --- Name
        if nameEnabled then
            draw.SetFont(getFont(fontNameName:GetValue(), fontSizeName:GetValue(), fontWeightMain:GetValue()))
            local nameWidth, nameHeight = draw.GetTextSize(pEntity:GetName())
            drawText(x1 + ((x2 - x1)/2)-(nameWidth/2), y1-nameHeight-2, pEntity:GetName())
        end

        --- Weapon
        if weaponEnabled then
            draw.SetFont(getFont(fontNameWeapon:GetValue(), fontSizeWeapon:GetValue(), fontWeightMain:GetValue()))

            local weapon = pEntity:GetPropEntity("m_hActiveWeapon")

            if weapon == nil then
                return
            end

            local weapon_name = weapon:GetClass()

            if weapon_name == "CDEagle" and weapon:GetWeaponID() == 64 then
                weapon_name = "r8"
            else
                weapon_name = weapon_name:gsub("CWeapon", "")
                weapon_name = weapon_name:gsub("CKnife", "knife")

            end

            weapon_name = weapon_name:lower()

            if (weapon_name:sub(1, 1) == "c") then
                weapon_name = weapon_name:sub(2)
            end

            weapon_name:match( "^%s*(.-)%s*$" )

            local nameWidth, nameHeight = draw.GetTextSize(weapon_name)
            drawText(x1 + ((x2 - x1)/2) - (nameWidth/2), y2+2, weapon_name)
        end

        --- Health
        if healthType > 0 then
            draw.SetFont(getFont(fontNameMain:GetValue(), fontSizeMain:GetValue(), fontWeightMain:GetValue()))
            drawBar(x1, y1, x2, y2, pEntity:GetHealth(), 100, healthType, false)
        end

        --- Flags
        draw.SetFont(getFont(fontNameFlags:GetValue(), fontSizeFlags:GetValue(), fontWeightMain:GetValue()))
       
        local flagHK = ""
        local flagZoom = ""
        local flagDesync = ""
        local flagFakeduck = ""

        if (pEntity:GetPropInt("m_bHasHelmet") == 1) then
            flagHK = flagHK .. "H"
        end

        if (pEntity:GetPropInt("m_ArmorValue") ~= 0) then
            flagHK = flagHK .. "K"
        end

        if (pEntity:GetProp("m_bIsScoped") == 1) then
            flagZoom =  "ZOOM"
        end

        if isDesyncing[pEntity:GetIndex()] then
            flagDesync = "DESYNC"
        end

        if isFakeducking(pEntity) then
            flagFakeduck = "FAKEDUCK"
        end

        local useless1, flagHeight = draw.GetTextSize("Sample Test")
        flagHeight = flagHeight
        local nextFlagHeight = y1-4;

        if armorEnabled and flagHK ~= "" then
            draw.Color(255, 255, 255, 255)
            drawText(x2+2, nextFlagHeight+2, flagHK)
            nextFlagHeight = nextFlagHeight + flagHeight
        end

        if zoomEnabled and flagZoom ~= "" then
            draw.Color(51, 153, 255, 255)
            drawText(x2+2, nextFlagHeight+2, flagZoom)
            nextFlagHeight = nextFlagHeight + flagHeight
        end

        if desyncEnabled and flagDesync ~= "" then
            draw.Color(255, 25, 25, 255)
            drawText(x2+2, nextFlagHeight+2, flagDesync)
            nextFlagHeight = nextFlagHeight + flagHeight
        end


        if fakeduckEnabled and flagFakeduck ~= "" then
            draw.Color(255, 153, 51, 255)
            drawText(x2+2, nextFlagHeight+2, flagFakeduck)
        end
    end
end

local function drawESPOther(pEntity, x1, y1, x2, y2, masterEnabled, boxEnabled, nameEnabled, barType, isWeapon, nadeTimer, nadeTimerMax)

    if masterEnabled then

        draw.SetFont(getFont(fontNameMain:GetValue(), fontSizeMain:GetValue(), fontWeightMain:GetValue()))
        draw.Color(255, 255, 255, 255)

        --- Box
        if boxEnabled then
            if boxOutline:GetValue() then
                draw.Color(25, 25, 25, 200)
                drawBox(x1+1, y1+1, x2-1, y2-1)
                drawBox(x1-1, y1-1, x2+1, y2+1)
            end

            draw.Color(255, 244, 255, 255)
            drawBox(x1, y1, x2, y2)
        end

        --- Name
        if nameEnabled then
            draw.SetFont(getFont(fontNameName:GetValue(), fontSizeName:GetValue(), fontWeightMain:GetValue()))
            local name = pEntity:GetName()
            name:lower()
            local nameWidth, nameHeight = draw.GetTextSize(name)
            drawText(x1 + ((x2 - x1)/2)-(nameWidth/2), y1-(nameHeight)-2, name)
        end

        --- Ammo/Timer
        if barType then
            draw.SetFont(getFont(fontNameMain:GetValue(), fontSizeMain:GetValue(), fontWeightMain:GetValue()))
            if isWeapon then

                local ent = entities.FindByClass("CBaseCombatWeapon")
                local count = 0
                local clipMax
                for i = 1, #ent, 1 do
                    if ent[i]:GetIndex() == pEntity:GetIndex() then
                        if ent[i]:GetPropInt("m_iClip1") >= 0 then
                            count = count + 1
                            clipMax = max_ammo[ent[i]:GetWeaponID()]
                        end
                    end
                end

                if clipMax then

                    if clipMax == 0 then
                        clipMax = 1
                    end

                    drawBar(x1, y1, x2, y2, pEntity:GetPropInt("m_iClip1"), clipMax, barType, true)
                end
            end
        end
    end
end


--- Handlers
local function handleMenu()

    if input.IsButtonPressed(gui.GetValue("msc_menutoggle")) then
        menuPressed = menuPressed == 0 and 1 or 0;
        if not betteresp_autoupdater_wnd_closed then
            betteresp_autoupdater_wnd_active = betteresp_autoupdater_wnd_active == 0 and 1 or 0
        end
    end

    if (suyu_esp_wnd_active:GetValue()) then
        suyu_esp_wnd:SetActive(menuPressed);
    else
        suyu_esp_wnd:SetActive(0);
    end
end

local function handleDrawTypes()

    if rounded:GetValue() then
        drawBox = draw.RoundedRect
        drawFilledBox = draw.RoundedRectFill
    else
        drawBox = draw.OutlinedRect
        drawFilledBox = draw.FilledRect
    end
end

local function handleVars()
    gui.SetValue("esp_enemy_box_precise", precision:GetValue())
    gui.SetValue("esp_team_box_precise", precision:GetValue())
    gui.SetValue("esp_filter_enemy", enemyMaster:GetValue())
    gui.SetValue("esp_filter_team", teamMaster:GetValue())
    gui.SetValue("esp_filter_weapon", weaponsMaster:GetValue())
    gui.SetValue("esp_filter_grenades", nadesMaster:GetValue())
end

local function handleEntityList()

    if not pLocal then
        return
    end

    if enemyDesyncFlag:GetValue() then
        for pEntityIndex, pEntity in pairs(entities.FindByClass("CCSPlayer")) do
            if pEntity:GetTeamNumber() ~= pLocal:GetTeamNumber() and pEntity:IsPlayer() and pEntity:IsAlive() then
                if globals.TickCount() > lastTick then
                    if lastSimtime[pEntityIndex] ~= nil then
                        if pEntity:GetProp("m_flSimulationTime") == lastSimtime[pEntityIndex] then
                            isDesyncing[pEntityIndex] = true;
                            desyncCooldown[pEntityIndex] = globals.TickCount();
                        else
                            if desyncCooldown[pEntityIndex] ~= nil then
                                if desyncCooldown[pEntityIndex] < globals.TickCount() - 128 then
                                    isDesyncing[pEntityIndex] = false;
                                end
                            else
                                isDesyncing[pEntityIndex] = false;
                            end
                        end
                    end
                    lastSimtime[pEntityIndex] = pEntity:GetProp("m_flSimulationTime")
                end
            end
        end
        lastTick = globals.TickCount();
    end
end

--- Auto updater by ShadyRetard/Shady#0001
local function handleUpdates()

    betteresp_autoupdater_wnd:SetActive(betteresp_autoupdater_wnd_active)

    if (update_available and not update_downloaded) then
        betteresp_autoupdater_text:SetText("Update is getting downloaded.")

        if (gui.GetValue("lua_allow_cfg") == false) then
            draw.Color(255, 0, 0, 255);
        else
            local new_version_content = http.Get(SCRIPT_FILE_ADDR);
            local old_script = file.Open(SCRIPT_FILE_NAME, "w");
            old_script:Write(new_version_content);
            old_script:Close();
            update_available = false;
            update_downloaded = true;
        end
    end

    if (update_downloaded) then
        draw.Color(255, 0, 0, 255);
        betteresp_autoupdater_text:SetText("Update available, please reload the script.")
        return;
    end

    if (not version_check_done) then
        if (gui.GetValue("lua_allow_http") == false) then
            draw.Color(255, 0, 0, 255);
            betteresp_autoupdater_text:SetText("Please allow internet connections for scripts.")
            return;
        end

        if (gui.GetValue("lua_allow_cfg") == false) then
            betteresp_autoupdater_text:SetText("Please allow Config editing for scripts.")
            return;
        end

        version_check_done = true;
        local version = http.Get(VERSION_FILE_ADDR);
        if (version ~= VERSION_NUMBER) then
            update_available = true;
        end

        betteresp_autoupdater_text:SetText("Your client is up to date.")

    end
end

--- Hooks
local function drawESPHook(builder)
    if not pLocal then
        return
    end

    local pEntity = builder:GetEntity()

    if Master:GetValue() then

        local x1, y1, x2, y2 = builder:GetRect()

        if pEntity:GetIndex() ~= pLocal:GetIndex() and pEntity:GetTeamNumber() ~= pLocal:GetTeamNumber() and pEntity:IsPlayer() then
            drawESPEntity(pEntity, x1, y1, x2, y2, enemyMaster:GetValue(), enemyBox:GetValue(), enemyName:GetValue(), enemyWeapon:GetValue() ,enemyHealth:GetValue(), enemyArmorFlag:GetValue(), enemyZoomFlag:GetValue(), enemyFakeduckFlag:GetValue(), enemyDesyncFlag:GetValue())

        elseif pEntity:GetIndex() ~= pLocal:GetIndex() and pEntity:GetTeamNumber() == pLocal:GetTeamNumber() and pEntity:IsPlayer() then
            drawESPEntity(pEntity, x1, y1, x2, y2, teamMaster:GetValue(), teamBox:GetValue(), teamName:GetValue(), teamWeapon:GetValue(), teamHealth:GetValue(), teamArmorFlag:GetValue(), teamZoomFlag:GetValue(), teamFakeduckFlag:GetValue())

        elseif pEntity:GetIndex() ~= pLocal:GetIndex() and isNade(pEntity) then
            if nadesBox:GetValue() then
                y1 = y1-((x2-x1)/3.5)
                y2 = y2+((x2-x1)/3.5)
            end
            drawESPOther(pEntity, x1, y1, x2, y2, nadesMaster:GetValue(), nadesBox:GetValue(), nadesName:GetValue(), nadesTimer:GetValue())
        elseif pEntity:GetIndex() ~= pLocal:GetIndex() then
            if weaponsBox:GetValue() then
                y1 = y1-((x2-x1)/3.5)
                y2 = y2+((x2-x1)/3.5)
            end
            drawESPOther(pEntity, x1, y1, x2, y2, weaponsMaster:GetValue(), weaponsBox:GetValue(), weaponsName:GetValue(), weaponsAmmo:GetValue(), true)
        end
    end
end

local function drawHook()

    pLocal = entities.GetLocalPlayer()

    handleMenu()
    handleDrawTypes()
    handleVars()
    handleEntityList()

    if nadesMaster:GetValue() then 
        draw.SetFont(getFont(fontNameName:GetValue(), fontSizeName:GetValue(), fontWeightMain:GetValue())) --- Set the created font for drawing.

        for k, v in pairs(Molotovs) do
            local w2sX, w2sY = client.WorldToScreen(v[1][1], v[1][2], v[1][3])
            if w2sX and w2sY then
                draw.Color(255, 255, 255, 255)
                local x1 = w2sX-20
                local x2 = w2sX+20
                local y1 = w2sY-1
                local y2 = w2sY+1
                if nadesName:GetValue() then
                    local name = "Molotov"
                    name:lower()
                    local nameWidth, nameHeight = draw.GetTextSize(name)
                    drawText(x1 + ((x2 - x1)/2)-(nameWidth/2), y1-(nameHeight)+4, name)
                end

                if nadesTimer:GetValue() > 0 then
                    drawBar(x1, y1, x2, y2, round(globals.CurTime()-v[2], 1), 7, nadesTimer:GetValue(), true)
                end
            end
        end

        for k, v in pairs(Smokes) do
            local w2sX, w2sY = client.WorldToScreen(v[1][1], v[1][2], v[1][3])
            if w2sX and w2sY then
                draw.Color(255, 255, 255, 255)
                local x1 = w2sX-20
                local x2 = w2sX+20
                local y1 = w2sY-9
                local y2 = w2sY+9
 
                if nadesTimer:GetValue() > 0 then
                    drawBar(x1, y1, x2, y2, round(globals.CurTime()-v[2], 1), 18, nadesTimer:GetValue(), true)
                end
            end
        end
    end
end

local function eventHook(event)

    if event:GetName() == "round_start" then
        Molotovs = {}
        Smokes = {}
    end

    if event:GetName() == "inferno_startburn" then
        local x, y, z = event:GetFloat("x"), event:GetFloat("y"), event:GetFloat("z")
        table.insert(Molotovs, {{x,y,z},globals.CurTime()})
    end

    if event:GetName() == "inferno_expire" then
        table.remove(Molotovs, 1)
    end

    if event:GetName() == "inferno_extinguish" then
        table.remove(Molotovs, 1)
    end

    if event:GetName() == "smokegrenade_detonate" then
        local x, y, z = event:GetFloat("x"), event:GetFloat("y"), event:GetFloat("z")
        table.insert(Smokes, {{x,y,z},globals.CurTime()})
    end

    if event:GetName() == "smokegrenade_expired" then
        table.remove(Smokes, 1)
    end
end

--- Callbacks
callbacks.Register("Draw", drawHook)
callbacks.Register("DrawESP", drawESPHook)
callbacks.Register("FireGameEvent", eventHook)
