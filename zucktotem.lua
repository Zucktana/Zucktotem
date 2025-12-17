-- ZuckTotem for Turtle WoW
print("zucktana is easily distracted and sometimes forgets about her totems so I made thi.... Oh look a squirrel!")

local TOTEM_DATA = {
    ["Searing Totem"]   = { dur = 30, icon = "Interface\\Icons\\Spell_Fire_SearingTotem", next = "Searing" },
    ["Magma Totem"]     = { dur = 20, icon = "Interface\\Icons\\Spell_Fire_SelfDestruct", next = "Fire Nova" },
    ["Fire Nova Totem"] = { dur = 5,  icon = "Interface\\Icons\\Spell_Fire_SealOfFire",   next = "Magma" },
    ["Mana Tide Totem"] = { dur = 12, icon = "Interface\\Icons\\Spell_Frost_SummonWaterElemental" },
}

-- 1. Main UI Box
local f = CreateFrame("Frame", "ZuckTotemUI", UIParent)
f:SetWidth(80); f:SetHeight(80)
f:SetPoint("TOP", 0, -50)
f:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"})

local icon = f:CreateTexture(nil, "ARTWORK")
icon:SetWidth(50); icon:SetHeight(50)
icon:SetPoint("CENTER", 0, 10)
icon:SetTexture("Interface\\Icons\\Spell_Fire_SearingTotem")

local timerText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
timerText:SetPoint("BOTTOM", f, "BOTTOM", 0, 8)
timerText:SetText("READY")

local statusText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
statusText:SetPoint("TOP", f, "BOTTOM", 0, -2)
statusText:SetText("")

-- 2. THE BIG ALERT TEXT (SAFE VERSION)
local bigAlert = f:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
bigAlert:SetPoint("BOTTOM", f, "TOP", 0, 100) -- Places it high in the center of the screen
bigAlert:SetText("")

-- 3. Small Ankh Box
local a = CreateFrame("Frame", "ZuckAnkh", f)
a:SetWidth(30); a:SetHeight(30)
a:SetPoint("RIGHT", f, "LEFT", -5, 0)
a:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"})
local aIcon = a:CreateTexture(nil, "ARTWORK")
aIcon:SetAllPoints()
aIcon:SetTexture("Interface\\Icons\\Spell_Nature_Reincarnation")

local endTime, fearEndTime, ankhReadyTime = 0, 0, 0
local currentNext = ""
local inCombat = false

-- 4. Update Loop
f:SetScript("OnUpdate", function()
    local now = GetTime()
    local fRem = fearEndTime - now
    local rem = endTime - now
    local active = rem > 0 or fRem > 0
    
    -- Combat Fading
    if inCombat or active then f:SetAlpha(1.0) else f:SetAlpha(0.2) end

    -- Ankh transparency
    if now >= ankhReadyTime then a:SetAlpha(1.0) else a:SetAlpha(0.2) end

    -- DISPLAY PRIORITY
    if fRem > 0 then
        icon:SetTexture("Interface\\Icons\\Spell_Nature_TremorTotem")
        timerText:SetText(string.format("%.1f", fRem))
        timerText:SetTextColor(1, 0, 0)
        
        -- SHOW BIG ALERT
        bigAlert:SetText("FEAR INCOMING!")
        bigAlert:SetTextColor(1, 0, 0)
        
        if fRem < 0.8 then statusText:SetText("DROP NOW!") else statusText:SetText("FEAR!") end
    elseif rem > 0 then
        bigAlert:SetText("") -- Hide Big Alert
        timerText:SetText(string.format("%.1f", rem))
        timerText:SetTextColor(1, 1, 1)
        statusText:SetText("ACTIVE")
    else
        bigAlert:SetText("") -- Hide Big Alert
        timerText:SetText("READY")
        timerText:SetTextColor(0, 1, 0)
        statusText:SetText("NEXT: "..currentNext)
    end
end)

-- 5. Event Listener
f:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF")
f:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("CHAT_MSG_COMBAT_PLAYER_MISSES")

f:SetScript("OnEvent", function()
    if event == "PLAYER_REGEN_DISABLED" then
        inCombat = true
    elseif event == "PLAYER_REGEN_ENABLED" then
        inCombat = false
    elseif event == "CHAT_MSG_SPELL_SELF_BUFF" then
        for name, data in pairs(TOTEM_DATA) do
            if arg1 and string.find(arg1, "You cast " .. name) then
                icon:SetTexture(data.icon)
                endTime = GetTime() + data.dur
                currentNext = data.next or ""
            end
        end
    elseif arg1 and string.find(arg1, "begins to cast") then
        if string.find(arg1, "Fear") or string.find(arg1, "Panic") or string.find(arg1, "Bellowing Roar") then
            fearEndTime = GetTime() + 2.0
        end
    elseif arg1 and string.find(arg1, "You use Reincarnation") then
        ankhReadyTime = GetTime() + 1800
    end
end)

-- 6. Test Command
SLASH_ZUCKTEST1 = "/zucktest"
SlashCmdList["ZUCKTEST"] = function()
    DEFAULT_CHAT_FRAME:AddMessage("ZuckTotem: Simulating Fear (2s)...")
    fearEndTime = GetTime() + 2
end
