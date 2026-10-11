

-- MERIT SYSTEM BY  @TRNDRAVIX / ONE & ONLY DRAVIX 
-- JOIN FOR MORE -- @CODE_LEAK
-- ANYONE WANNA?? BUY PAID LUA FILES DM HERE -- @TRNDRAVIX
-- CONTACT EMAIL -- danger@62v.net / trndravix@gmail.com 
-- DONT DM HOW TO USE IF YOU ARE A DEVELOPER THEN YOU CAN USE IT EASILY
-- ═══════════════════════════════════════════════════════════════════
-- MERIT BYPASS SYSTEM - TrnDravix
-- Only fixes Merit/Credit
-- ═══════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════
-- FEATURE TOGGLE -- YOU NEED FIX MATH MAKING ISSUES YOUR SELF ❤️
-- ═══════════════════════════════════════════════════════════════════
_G.TrnDravix_Features = _G.TrnDravix_Features or {}

local meritExists = false
for _, f in ipairs(_G.TrnDravix_Features) do
    if f.id == "MERIT_BYPASS" then
        meritExists = true
        break
    end
end

if not meritExists then
    table.insert(_G.TrnDravix_Features, {
        id = "MERIT_BYPASS",
        name = "Merit Bypass (Fake Credit)",
        val = 1,
        type = "toggle"
    })
end

function _G.TrnDravix_GetVal(id)
    for _, f in ipairs(_G.TrnDravix_Features or {}) do
        if f.id == id then return f.val end
    end
    return 0
end-- JOIN FOR MORE -- @CODE_LEAK
-- ANYONE WANNA?? BUY PAID LUA FILES DM HERE -- @TRNDRAVIX
-- CONTACT EMAIL -- danger@62v.net / trndravix@gmail.com 
-- DONT DM HOW TO USE IF YOU ARE A DEVELOPER THEN YOU CAN USE IT EASILY

-- ═══════════════════════════════════════════════════════════════════
-- CORE MERIT BYPASS FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════
local MERIT_TIMER = nil
local MATCH_HOOKED = false
local CHECK_BLOCKED = false
-- JOIN FOR MORE -- @CODE_LEAK
-- ANYONE WANNA?? BUY PAID LUA FILES DM HERE -- @TRNDRAVIX
-- CONTACT EMAIL -- danger@62v.net / trndravix@gmail.com 
-- DONT DM HOW TO USE IF YOU ARE A DEVELOPER THEN YOU CAN USE IT EASILY
-- ═══════════════════════════════════════════════════════════════════
-- 1. FORCE MERIT = 100 EVERYWHERE
-- ═══════════════════════════════════════════════════════════════════
local function ForceMeritFull()
    pcall(function()
        -- DataMgr
        if DataMgr then
            if DataMgr.roleData then
                DataMgr.roleData.credit = 100
                DataMgr.roleData.merit = 100
                DataMgr.roleData.rating = 100
                DataMgr.roleData.score = 100
            end
            DataMgr.credit = 100
            DataMgr.merit = 100
        end
        -- JOIN FOR MORE -- @CODE_LEAK
-- ANYONE WANNA?? BUY PAID LUA FILES DM HERE -- @TRNDRAVIX
-- CONTACT EMAIL -- danger@62v.net / trndravix@gmail.com 
-- DONT DM HOW TO USE IF YOU ARE A DEVELOPER THEN YOU CAN USE IT EASILY
        -- LobbySystem
        if LobbySystem then
            if LobbySystem.roleData then
                LobbySystem.roleData.credit = 100
                LobbySystem.roleData.merit = 100
            end
        end
        
        -- PlayerState
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then
            local ps = pc.PlayerState
            if slua.isValid(ps) then
                ps.credit = 100
                ps.merit = 100
                ps.rating = 100
                if ps.SetMerit then ps:SetMerit(100) end
                if ps.SetCredit then ps:SetCredit(100) end
            end
        end
        -- JOIN FOR MORE -- @CODE_LEAK
-- ANYONE WANNA?? BUY PAID LUA FILES DM HERE -- @TRNDRAVIX
-- CONTACT EMAIL -- danger@62v.net / trndravix@gmail.com 
-- DONT DM HOW TO USE IF YOU ARE A DEVELOPER THEN YOU CAN USE IT EASILY
        -- GameplayData
        local GameplayData = require("GameLua.GameCore.Data.GameplayData")
        if GameplayData then
            local ps = GameplayData.GetPlayerState()
            if slua.isValid(ps) then
                ps.credit = 100
                ps.merit = 100
            end
        end
        
        -- Force UI Refresh
        EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_CREDIT, 100)
        EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ROLE_CREDIT, 100)
        
        print("[TrnDravix] Credit forced to 100 everywhere!")
    end)
end
-- JOIN FOR MORE -- @CODE_LEAK
-- ANYONE WANNA?? BUY PAID LUA FILES DM HERE -- @TRNDRAVIX
-- CONTACT EMAIL -- danger@62v.net / trndravix@gmail.com 
-- DONT DM HOW TO USE IF YOU ARE A DEVELOPER THEN YOU CAN USE IT EASILY
-- ═══════════════════════════════════════════════════════════════════
-- 2. BLOCK MERIT CHECKS IN GAME SYSTEMS
-- ═══════════════════════════════════════════════════════════════════
local function BlockMeritCheck()
    pcall(function()
        if not CHECK_BLOCKED then
            -- MatchSystem CanMatchInBan
            if MatchSystem and MatchSystem.CanMatchInBan then
                local oldFunc = MatchSystem.CanMatchInBan
                MatchSystem.CanMatchInBan = function(modeId)
                    if _G.TrnDravix_GetVal("MERIT_BYPASS") == 1 then
                        print("[TrnDravix] Match ban check blocked!")
                        return true
                    end
                    return oldFunc(modeId)
                end
            end
            -- JOIN FOR MORE -- @CODE_LEAK
-- ANYONE WANNA?? BUY PAID LUA FILES DM HERE -- @TRNDRAVIX
-- CONTACT EMAIL -- danger@62v.net / trndravix@gmail.com 
-- DONT DM HOW TO USE IF YOU ARE A DEVELOPER THEN YOU CAN USE IT EASILY
            -- LobbySystem credit check
            if LobbySystem and LobbySystem.CheckCredit then
                local oldFunc = LobbySystem.CheckCredit
                LobbySystem.CheckCredit = function()
                    if _G.TrnDravix_GetVal("MERIT_BYPASS") == 1 then
                        print("[TrnDravix] Credit check blocked!")
                        return true
                    end
                    return oldFunc()
                end
            end
            
            CHECK_BLOCKED = true
            print("[TrnDravix] Merit checks blocked!")
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════
-- 3. HOOK MATCH REQUEST - SEND FAKE CREDIT TO SERVER
-- ═══════════════════════════════════════════════════════════════════
local function HookMatchHandler()
    pcall(function()
        if not MATCH_HOOKED and MatchHandler and MatchHandler.send_on_match_req then
            local oldFunc = MatchHandler.send_on_match_req
            MatchHandler.send_on_match_req = function(modeId, isFill, dataList, deviceInfo, enterFrom, token, extraInfo)
                if _G.TrnDravix_GetVal("MERIT_BYPASS") == 1 then
                    extraInfo = extraInfo or {}
                    extraInfo.team_rating = 100
                    extraInfo.credit = 100
                    extraInfo.fake_merit = 100
                    extraInfo.merit = 100
                    extraInfo.bypass_credit = true
                    print("[TrnDravix] Fake credit sent to server!")
                end
                return oldFunc(modeId, isFill, dataList, deviceInfo, enterFrom, token, extraInfo)
            end
            MATCH_HOOKED = true
            print("[TrnDravix] MatchHandler hooked!")
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════
-- 4. HOBBY ERROR HANDLER - IGNORE CREDIT ERRORS
-- ═══════════════════════════════════════════════════════════════════
local function HookErrorHandler()
    pcall(function()
        if LobbySystem and LobbySystem.HandleMatchErrorCode then
            local oldFunc = LobbySystem.HandleMatchErrorCode
            LobbySystem.HandleMatchErrorCode = function(msg, waitTime, reason, surplustime, resParams, extInfo)
                if msg == "credit_is_too_low" or msg == "low_priority_match_banned" then
                    print("[TrnDravix] Error ignored: " .. tostring(msg))
                    return
                end
                return oldFunc(msg, waitTime, reason, surplustime, resParams, extInfo)
            end
            print("[TrnDravix] Error handler hooked!")
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════
-- 5. APPLY ALL BYPASSES
-- ═══════════════════════════════════════════════════════════════════
local function ApplyMeritBypass()
    if _G.TrnDravix_GetVal("MERIT_BYPASS") ~= 1 then
        return
    end
    
    pcall(function()
        ForceMeritFull()
        BlockMeritCheck()
        HookMatchHandler()
        HookErrorHandler()
    end)
end
-- JOIN FOR MORE -- @CODE_LEAK
-- ANYONE WANNA?? BUY PAID LUA FILES DM HERE -- @TRNDRAVIX
-- CONTACT EMAIL -- danger@62v.net / trndravix@gmail.com 
-- DONT DM HOW TO USE IF YOU ARE A DEVELOPER THEN YOU CAN USE IT EASILY
-- ═══════════════════════════════════════════════════════════════════
-- 6. START TIMER - RE-APPLY EVERY 1 SECOND
-- ═══════════════════════════════════════════════════════════════════
local function StartMeritBypass()
    if MERIT_TIMER then
        pcall(function()
            if _G.Game then _G.Game:RemoveGameTimer(MERIT_TIMER) end
        end)
        MERIT_TIMER = nil
    end
    
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(pc) and pc.AddGameTimer then
        ApplyMeritBypass()
        MERIT_TIMER = pc:AddGameTimer(1.0, true, function()
            if _G.TrnDravix_GetVal("MERIT_BYPASS") == 1 then
                ApplyMeritBypass()
            end
        end)
        print("[TrnDravix] Merit Bypass started! (re-apply every 1s)")
        return true
    end
    return false
end

StartMeritBypass()

-- ═══════════════════════════════════════════════════════════════════
-- 7. TOGGLE FUNCTION
-- ═══════════════════════════════════════════════════════════════════
_G.ToggleMeritBypass = function()
    for _, f in ipairs(_G.TrnDravix_Features or {}) do
        if f.id == "MERIT_BYPASS" then
            f.val = (f.val == 1 and 0 or 1)
            print("[TrnDravix] Merit Bypass toggled to: " .. tostring(f.val == 1))
            if f.val == 1 then
                ApplyMeritBypass()
            end
            break
        end
    end
end
-- JOIN FOR MORE -- @CODE_LEAK
-- ANYONE WANNA?? BUY PAID LUA FILES DM HERE -- @TRNDRAVIX
-- CONTACT EMAIL -- danger@62v.net / trndravix@gmail.com 
-- DONT DM HOW TO USE IF YOU ARE A DEVELOPER THEN YOU CAN USE IT EASILY
print("========================================")
print("[TrnDravix] MERIT BYPASS LOADED!")
print("[TrnDravix] Toggle: _G.ToggleMeritBypass()")
print("[TrnDravix] Status: " .. tostring(_G.TrnDravix_GetVal("MERIT_BYPASS") == 1 and "ON" or "OFF"))
print("========================================")