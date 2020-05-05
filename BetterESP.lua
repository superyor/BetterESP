--- Some References I will need.
local ref = gui.Reference("VISUALS", "Overlay")
local ref1 = gui.Reference("VISUALS", "Overlay", "Friendly")
local ref2 = gui.Reference("VISUALS", "Overlay", "Enemy")
local ref3 = gui.Reference("VISUALS", "Overlay", "Weapon")
local menuref = gui.Reference("MENU")

--- API Localization for faster acess
local getLocal = entities.GetLocalPlayer;
local getRealTime = globals.RealTime;

local dSetColor = draw.Color;
local dRect = draw.OutlinedRect;
local dFilledRect = draw.FilledRect;
local dText = draw.Text;
local dTextShadow = draw.TextShadow;
local dGetTextSize = draw.GetTextSize;
local dSetFont = draw.SetFont;
local dCreateFont = draw.CreateFont;

local setVal = gui.SetValue;
local getVal = gui.GetValue;

--- Rect metaclass
local Rect = {
    p1 = {x=0, y=0},
    p2 = {x=0, y=0},
    width = 0,
    height = 0,
    diagonalSqr = 0,
}

--- Create a new Rect
function Rect:New(x1, y1, x2, y2)
    local newRect = {};
    setmetatable(newRect, self)
    self.__index = self;
    newRect.p1 = {x=x1, y=y1};
    newRect.p2 = {x=x2, y=y2};
    newRect.width = x2-x1;
    newRect.height = y1-y2;
    newRect.diagonalSqr = (newRect.width^2) + (newRect.height^2)
    return newRect;
end

--- Color metaclass
local Color = {r=0, g=0, b=0, a=0};

--- Create a new color
function Color:New(r, g, b, a)
    local newColor = {};
    setmetatable(newColor, self)
    self.__index = self;
    newColor.r = r;
    newColor.g = g;
    newColor.b = b;
    newColor.a = a;
    return newColor;
end

--- Get color inbetween two colors based on percentage from 0-1
function Color:Inbetween(color, percent)

    if percent > 1 then
        percent = 1;
    elseif percent < 0 then
        percent = 0;
    end

    local newColor = Color:New(0, 0, 0, 0);
    newColor.r = self.r-(self.r-color.r)*percent
    newColor.g = self.g-(self.g-color.g)*percent
    newColor.b = self.b-(self.b-color.b)*percent
    newColor.a = self.a-(self.a-color.a)*percent
    return newColor;
end

--- BetterESP object
local BetterESP = {

    metadata = {
        scriptName = GetScriptName();
        version = "2.0 Beta";
        fileLink = "https://raw.githubusercontent.com/superyor/BetterESP/master/BetterESP.lua";
        versionLink = "https://raw.githubusercontent.com/superyor/BetterESP/master/version.txt";
        changelogLink = "https://raw.githubusercontent.com/superyor/BetterESP/master/changelog.txt";
    };

    guiObjects = {
        options = {
            [1] = {}; --- Friendly
            [2] = {}; --- Enemy
        }
    };

    variables = {
        pLocal = nil;

        updater = {
            lastVersionCheck = 0;
            updated = false;
            isOutdated = false;
        };
    };

    flagcolors = {
        Color:New(51, 153, 255, 255),
        Color:New(255, 25, 25, 255),
    };

    font = dCreateFont("Verdana", 12, 500);
};
BetterESP.__index = BetterESP;

--- BetterESP Functions
function BetterESP:createMenu()

    --- Autoupdater GUI Objects
    self.guiObjects.updatergroup = gui.Groupbox(ref, "BetterESP | Updater", 16, 16, 300-8, 600)
    self.guiObjects.updaterText = gui.Text(self.guiObjects.updatergroup, "You shouldn't be able to see this...")
    self.guiObjects.updaterButton = gui.Button(self.guiObjects.updatergroup, "Update", function()
        if self.variables.updater.isOutdated then
            local nScript = http.Get(self.metadata.fileLink)
            local oScript = file.Open(self.metadata.scriptName, "w");
            oScript:Write(nScript);
            oScript:Close()
            self.variables.updater.updated = true;
            self.guiObjects.updaterText:SetText("Please reload the lua.");
        end
    end)
    self.guiObjects.updaterButton:SetWidth(300-32-8)

    self.guiObjects.changelogGroup = gui.Groupbox(ref, "BetterESP | Changelog", 16+8+300, 16, 300-8, 600)
    self.guiObjects.changelogText = gui.Text(self.guiObjects.changelogGroup, "You shouldn't be able to see this...")

    --- Main GUI Objects
    self.guiObjects.group = gui.Groupbox(ref, "BetterESP | v" .. self.metadata.version, 16, 128+13+16, 400, 600)
    self.guiObjects.targetSelector = gui.Combobox(self.guiObjects.group, "targetselector", "Target", "Enemy", "Friendly")

    self.guiObjects.drawOptions = gui.Multibox(self.guiObjects.group, "Draw Options")
    self.guiObjects.outlined = gui.Checkbox(self.guiObjects.drawOptions, "drawoptions.outlined", "Draw Outlined", false)
    self.guiObjects.lowercase = gui.Checkbox(self.guiObjects.drawOptions, "drawoptions.lowercase", "Force Lowercase", false)

    for i=1, 2 do
        p = i==1 and "friendly" or "enemy"
        self.guiObjects.options[i].name = gui.Checkbox(self.guiObjects.group, p .. ".name", "Enable Name", false)
        self.guiObjects.options[i].box = gui.Checkbox(self.guiObjects.group, p .. ".box", "Enable Box", false)
        self.guiObjects.options[i].weapon = gui.Checkbox(self.guiObjects.group, p .. ".weapon", "Enable Weapon", false)
        self.guiObjects.options[i].health = gui.Checkbox(self.guiObjects.group, p .. ".health", "Enable Healthbar", false)
        self.guiObjects.options[i].healthlines = gui.Checkbox(self.guiObjects.group, p .. ".healthlines", "Healthbar lines", false)
        self.guiObjects.options[i].healthcolor = gui.ColorPicker(self.guiObjects.options[i].health, p .. "health.color", "Color", 25, 255, 25, 255)
        self.guiObjects.options[i].flagsMulti = gui.Multibox(self.guiObjects.group, "Flags");
        self.guiObjects.options[i].flagArmor = gui.Checkbox(self.guiObjects.options[i].flagsMulti , p .. ".flagarmor", "Armor", false)
        self.guiObjects.options[i].flagScoped = gui.Checkbox(self.guiObjects.options[i].flagsMulti , p .. ".flagscoped", "Scoped", false)
    end
end

function BetterESP:checkUpdates()

    if self.variables.updater.updated == false then

        local time = getRealTime()

        if self.variables.updater.lastVersionCheck < time-300 then

            local onlineVersion = http.Get(self.metadata.versionLink);

            if self.metadata.version ~= onlineVersion then
                self.guiObjects.updaterText:SetText("A new update is available. Newest version: " .. onlineVersion);
                self.variables.updater.isOutdated = true;
            else
                self.guiObjects.updaterText:SetText("Your client is up to date.");
            end

            local changelogContent = http.Get(self.metadata.changelogLink)
            self.guiObjects.changelogText:SetText(changelogContent);

            self.variables.updater.lastVersionCheck = time;
        end

    end
end

function BetterESP:handleUI()

    local target = self.guiObjects.targetSelector:GetValue()+1

    for i=1, 2 do
        self.guiObjects.options[i].name:SetInvisible(i==target)
        self.guiObjects.options[i].box:SetInvisible(i==target)
        self.guiObjects.options[i].weapon:SetInvisible(i==target)
        self.guiObjects.options[i].health:SetInvisible(i==target)
        self.guiObjects.options[i].healthlines:SetInvisible(i==target)
        self.guiObjects.options[i].flagsMulti:SetInvisible(i==target)
    end
end

function BetterESP:drawBox(rect, color)
    if self.guiObjects.outlined:GetValue() then
        dSetColor(0, 0, 0, 255);
        dRect(rect.p1.x+1, rect.p1.y+1, rect.p2.x-1, rect.p2.y-1)
        dRect(rect.p1.x-1, rect.p1.y-1, rect.p2.x+1, rect.p2.y+1)
        dSetColor(color.r, color.g, color.b, color.a);
        dRect(rect.p1.x, rect.p1.y, rect.p2.x, rect.p2.y)
    else
        dSetColor(color.r, color.g, color.b, color.a);
        dRect(rect.p1.x, rect.p1.y, rect.p2.x, rect.p2.y)
    end
end

function BetterESP:drawName(rect, color, name)

    if self.guiObjects.lowercase:GetValue() then
        name = name:lower()
    end

    local w, h = dGetTextSize(name);
    dSetColor(color.r, color.g, color.b, color.a);

    if self.guiObjects.outlined:GetValue() then
        dTextShadow((rect.p1.x+(rect.width/2))-(w/2), (rect.p1.y-(h/2)-9), name)
    else
        dText((rect.p1.x+(rect.width/2))-(w/2), (rect.p1.y-(h/2)-9), name)
    end
end

function BetterESP:drawWeaponName(rect, color, weapon)

    local weaponName = "";

    if weapon ~= nil then
        weaponName = weapon:GetClass()

        if weaponName == "CDeagle" and weapon:GetWeaponID() == 64 then
            weaponName = "R8"
        else
            weaponName = weaponName:gsub("CWeapon", "")
            weaponName = weaponName:gsub("CKnife", "Knife")
        end

        if (weaponName:sub(1, 1) == "C") then
            weaponName = weaponName:sub(2)
        end
    else
        weaponName = "Unknown Weapon"
    end

    if self.guiObjects.lowercase:GetValue() then
        weaponName = weaponName:lower()
    end

    local w, h = dGetTextSize(weaponName);
    dSetColor(color.r, color.g, color.b, color.a);

    if self.guiObjects.outlined:GetValue() then
        dTextShadow((rect.p1.x+(rect.width/2))-(w/2), (rect.p2.y+(h/2))-2, weaponName)
    else
        dText((rect.p1.x+(rect.width/2))-(w/2), (rect.p2.y+(h/2))-2, weaponName)
    end
end

function BetterESP:drawBarLeft(rect, color, percentage, lines)

    local offset = 0;

    if self.guiObjects.outlined:GetValue() then
        offset = 1;
    end

    dSetColor(0, 0, 0, 255)
    dRect(rect.p1.x-6-offset, rect.p1.y-offset, rect.p1.x-2-offset, rect.p2.y+offset)

    dSetColor(25, 25, 25, 255/1.33)
    dFilledRect(rect.p1.x-5-offset, (rect.p1.y-offset+1), rect.p1.x-3-offset, rect.p2.y+offset-1)

    local value = (rect.p2.y+offset-1)-(rect.p1.y-offset+1) - ((((rect.p2.y+offset-1)-(rect.p1.y-offset+1))*percentage) / 100);

    dSetColor(color.r, color.g, color.b, color.a)
    dFilledRect(rect.p1.x-5-offset, (rect.p1.y-offset+1)+value, rect.p1.x-3-offset, rect.p2.y+offset-1)

    dSetColor(255, 255, 255, 255)

    if percentage ~= 100 then

        local hpString = tostring(percentage);
        local w, h = dGetTextSize(hpString);

        if self.guiObjects.outlined:GetValue() then
            dTextShadow(rect.p1.x-8-w-offset, (rect.p1.y-offset+1)+value-(h/2), hpString)
        else
            dText(rect.p1.x-8-w-offset, (rect.p1.y-offset+1)+value-(h/2), hpString)
        end
    end

    if lines then
        dSetColor(0, 0, 0, 255)
        for i=0.1, 0.9, 0.1 do
            local h = (rect.p2.y+offset)-(rect.p1.y-offset) - (((rect.p2.y+offset)-(rect.p1.y-offset))*i);
            dFilledRect(rect.p1.x-6-offset, (rect.p1.y-offset) + h, rect.p1.x-2-offset, (rect.p1.y-offset) + h+1)
        end
    end
end

function BetterESP:drawFlags(rect, pEntity, callId)

    local flags = {};

    if self.guiObjects.options[callId].flagArmor:GetValue() then
        if pEntity:GetPropInt("m_ArmorValue") ~= 0 then
            flags[#flags+1] = "K"
        end

        if pEntity:GetPropInt("m_bHasHelmet") == 1 then
            flags[#flags] = "H" .. flags[#flags]
        end
    end

    if self.guiObjects.options[callId].flagScoped:GetValue() then
        if pEntity:GetPropBool("m_bIsScoped") then
            flags[#flags+1] = "SC"
        end
    end

    local sampleTextWidth, sampleTextHeight = dGetTextSize("Test");
    local posX = rect.p1.x+rect.width+2;
    local posY = rect.p1.y-sampleTextHeight-3;

    if self.guiObjects.outlined:GetValue() then
        posY = posY-1;
    end

    for k=1, #flags do
        local flagString = flags[k];

        if self.guiObjects.lowercase:GetValue() then
            flagString = flagString:lower()
        end

        dSetColor(self.flagcolors[k].r, self.flagcolors[k].g, self.flagcolors[k].b, self.flagcolors[k].a)

        if self.guiObjects.outlined:GetValue() then
            dTextShadow(posX, posY+(k*(sampleTextHeight+2)), flagString)
        else
            dText(posX, posY+(k*(sampleTextHeight+2)), flagString)
        end
    end
end

function BetterESP:doESPPlayers(pEntity, rect)

    if self.variables.pLocal ~= nil then

        if pEntity:IsPlayer() and pEntity:IsAlive() then

            if pEntity:GetTeamNumber() ~= self.variables.pLocal:GetTeamNumber() then

                dSetFont(self.font);

                if self.guiObjects.options[2].name:GetValue() then
                    self:drawName(rect, Color:New(255, 255, 255, 255), pEntity:GetName())
                end

                if self.guiObjects.options[2].weapon:GetValue() then
                    self:drawWeaponName(rect, Color:New(255, 255, 255, 255), pEntity:GetPropEntity("m_hActiveWeapon"))
                end

                if self.guiObjects.options[2].health:GetValue() then
                    local hp = pEntity:GetHealth()
                    local c1 = Color:New(255, 25, 25, 255);
                    local c2 = {}
                    c2.r, c2.g, c2.b, c2.a = self.guiObjects.options[2].healthcolor:GetValue()
                    local col = c1:Inbetween(Color:New(c2.r, c2.g, c2.b, c2.a), hp/100);
                    self:drawBarLeft(rect, col, hp, self.guiObjects.options[2].healthlines:GetValue());
                end

                if self.guiObjects.options[2].flagArmor:GetValue() or self.guiObjects.options[2].flagScoped:GetValue() then
                    self:drawFlags(rect, pEntity, 2)
                end

                if self.guiObjects.options[2].box:GetValue() then
                    self:drawBox(rect, Color:New(255, 255, 255, 255))
                end

            elseif pEntity:GetTeamNumber() == self.variables.pLocal:GetTeamNumber() and pEntity:GetIndex() ~= self.variables.pLocal:GetIndex() then

                dSetFont(self.font);

                if self.guiObjects.options[1].name:GetValue() then
                    self:drawName(rect, Color:New(255, 255, 255, 255), pEntity:GetName())
                end

                if self.guiObjects.options[1].weapon:GetValue() then
                    self:drawWeaponName(rect, Color:New(255, 255, 255, 255), pEntity:GetPropEntity("m_hActiveWeapon"))
                end

                if self.guiObjects.options[1].health:GetValue() then
                    local hp = pEntity:GetHealth()
                    local c1 = Color:New(255, 25, 25, 255);
                    local c2 = {}
                    c2.r, c2.g, c2.b, c2.a = self.guiObjects.options[1].healthcolor:GetValue()
                    local col = c1:Inbetween(Color:New(c2.r, c2.g, c2.b, c2.a), hp/100);
                    self:drawBarLeft(rect, col, hp, self.guiObjects.options[1].healthlines:GetValue());
                end

                if self.guiObjects.options[1].box:GetValue() then
                    self:drawBox(rect, Color:New(255, 255, 255, 255))
                end
            end
        end
    end
end

--- Callback Functions
function BetterESP:hkLoad() -- ok not really callback function but idc
    ref1:SetInvisible(true)
    ref2:SetInvisible(true)
    ref3:SetPosY(128+13+16)

    --- The commented out ones are not working for whatever reason
    for i=1, 2 do
        p = i==1 and "friendly" or "enemy"
        --setVal("esp.overlay." .. p .. ".box", 0)
        setVal("esp.overlay." .. p .. ".precision", 0)
        --setVal("esp.overlay." .. p .. ".name", 0)
        setVal("esp.overlay." .. p .. ".skeleton", 0)
        setVal("esp.overlay." .. p .. ".glow", 0)
        setVal("esp.overlay." .. p .. ".health.healthbar", 0)
        setVal("esp.overlay." .. p .. ".health.healthnum", 0)
        setVal("esp.overlay." .. p .. ".armorbar", 0)
        setVal("esp.overlay." .. p .. ".armornum", 0)
        --setVal("esp.overlay." .. p .. ".weapon", 0)
        setVal("esp.overlay." .. p .. ".defusing", 0)
        setVal("esp.overlay." .. p .. ".planting", 0)
        setVal("esp.overlay." .. p .. ".scoped", 0)
        setVal("esp.overlay." .. p .. ".reloading", 0)
        setVal("esp.overlay." .. p .. ".flashed", 0)
        setVal("esp.overlay." .. p .. ".hasdefuser", 0)
        setVal("esp.overlay." .. p .. ".hasc4", 0)
        setVal("esp.overlay." .. p .. ".money", 0)
    end

    self:createMenu();
    self:checkUpdates()
end

function BetterESP:hkUnload()
    ref1:SetInvisible(false)
    ref2:SetInvisible(false)
    ref3:SetPosY(16)
end

function BetterESP:hkDraw()
    self.variables.pLocal = getLocal()

    if menuref:IsActive() then
        self:handleUI()
    end
end

function BetterESP:hkDrawESP(espBuilder)
    local pEntity = espBuilder:GetEntity()

    if pEntity ~= nil then
        local x1, y1, x2, y2 = espBuilder:GetRect();
        local rect = Rect:New(x1, y1, x2, y2);
        BetterESP:doESPPlayers(pEntity, rect);
    end
end

--- Some function calls
BetterESP:hkLoad();

--- Callbacks
callbacks.Register("Draw", function() BetterESP:hkDraw() end)
callbacks.Register("DrawESP", function(espBuilder) BetterESP:hkDrawESP(espBuilder) end)
callbacks.Register("Unload", function() BetterESP:hkUnload() end)