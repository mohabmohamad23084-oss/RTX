_G.BlackList = {}
_G.BypassInstalled = false

-- ANTICHEAT BYPASS
local function InstallAntiCheatBypass()
    if _G.BypassInstalled then return end
    pcall(function()
        local a = require("GameLua.Mod.Library.GamePlay.Avatar.AvatarExceptionReport")
        if a and a.__inner_impl then
            a.__inner_impl.OnRecordAvatarException = function() end
            a.__inner_impl.OnPreBattleResult = function() end
        end
local BlockedPkgs = {
    on_crow_update_ntf = true,
    on_crow_update_ntf2 = true,
    on_crow_update_ntf3 = true,
    hisar = true,
    battle_client_sync_allstar_auth_check_result_req = true
}

local BlockedPrefixes = {
    "report_client_net_",
    "report_unrealnet_",
    "report_dh_calc_key"
}

local function ShouldBlockPkg(pkgName)
    if not pkgName then return false end
    if BlockedPkgs[pkgName] then return true end
    for _, prefix in ipairs(BlockedPrefixes) do
        if pkgName:sub(1, #prefix) == prefix then
            return true
        end
    end
    return false
end

if NetUtil and NetUtil.SendPkg then
    local orig_SendPkg = NetUtil.SendPkg
    NetUtil.SendPkg = function(pkgName, ...)
        if ShouldBlockPkg(pkgName) then return end
        return orig_SendPkg(pkgName, ...)
    end
end

local function HookTss()
    if not _G.Tss then return end
    if Tss.SendEigeninfoData then
        Tss.SendEigeninfoData = function() return 0 end
    end
    if Tss.GetUserTag4Lua then
        Tss.GetUserTag4Lua = function() return "" end
    end
    if Tss.SaveSendEigeninfoCode then
        local orig_SaveSendEigeninfoCode = Tss.SaveSendEigeninfoCode
        Tss.SaveSendEigeninfoCode = function(code)
            return orig_SaveSendEigeninfoCode(0)
        end
    end
end

HookTss()

pcall(function()
    if LobbySystem and LobbySystem.SendEigeninfo then
        LobbySystem.SendEigeninfo = function(a, b)
            HookTss()
            if Tss and Tss.SaveSendEigeninfoCode then
                pcall(Tss.SaveSendEigeninfoCode, 0)
            end
        end
    end
end)

pcall(function()
    local Gokuba = require("GameLua.Mod.BaseMod.Client.Security.Gokuba")
    if Gokuba then
        Gokuba.ForwardFeature = function() return {0, 0, 0, 0, 0} end
    end
end)

pcall(function()
    local HiggsBosonComponent = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
    if HiggsBosonComponent then
        HiggsBosonComponent.SendAntiDataFlow = function() end
        HiggsBosonComponent.SendHitFireBtnFlow = function() end
        HiggsBosonComponent.SendHisarData = function() end
        HiggsBosonComponent.OnLogin = function() end
        HiggsBosonComponent.OnBattleResult = function() end
        if HiggsBosonComponent.ShowABCD then
            HiggsBosonComponent.ShowABCD = function() end
        end
        HiggsBosonComponent.SkipAlertServer()
    end
end)

pcall(function()
    local ClientToolsReport = require("client.slua.logic.report.ClientToolsReport")
    if ClientToolsReport and ClientToolsReport.SendReport then
        local orig_SendReport = ClientToolsReport.SendReport
        ClientToolsReport.SendReport = function(a, b, c, ...)
            if c and type(c) == "string" then
                local lower_c = string.lower(c)
                if lower_c:find("anticheat") or lower_c:find("cheat") or lower_c:find("security") or lower_c:find("eigen") or lower_c:find("tss") or lower_c:find("gokuba") then
                    return
                end
            end
            return orig_SendReport(a, b, c, ...)
        end
    end
end)

pcall(function()
    local gem_report_utils = require("client.logic.store.gem_report_utils")
    if gem_report_utils and gem_report_utils.ReportEventImmediate then
        local orig_ReportEventImmediate = gem_report_utils.ReportEventImmediate
        gem_report_utils.ReportEventImmediate = function(a, b, ...)
            local str_a = tostring(a or "")
            local str_b = tostring(b or "")
            if str_a:find("Gokuba") or str_a:find("gokuba") or str_b:find("Tss") or str_b:find("tss") or str_b:find("Eigen") or str_b:find("eigen") or str_a:find("Mini_Pak") then
                return
            end
            return orig_ReportEventImmediate(a, b, ...)
        end
    end
end)

pcall(function()
    local GameReportUtils = require("GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils")
    if GameReportUtils and GameReportUtils.ReportException then
        local orig_ReportException = GameReportUtils.ReportException
        GameReportUtils.ReportException = function(a, ...)
            if a and type(a) == "string" then
                local lower_a = string.lower(a)
                if lower_a:find("anticheat") or lower_a:find("cheat") or lower_a:find("security") or lower_a:find("strategy") then
                    return
                end
            end
            return orig_ReportException(a, ...)
        end
    end
end)

pcall(function()
    EventSystem:registEvent(EVENTTYPE_INGAME, EVENTID_INGAME_CONTROLLER_BEGINPLAY, function()
        pcall(function()
            local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
            if pc then
                pc.bShouldReportAntiCheat = false
            end
        end)
    end)
end)

pcall(function()
    local ClientGlueHiaSystem = require("GameLua.Mod.BaseMod.Client.Security.ClientGlueHiaSystem")
    if ClientGlueHiaSystem then
        ClientGlueHiaSystem.LuaFunc1 = function() return true end
        ClientGlueHiaSystem.LuaFunc4 = function() return false end
        ClientGlueHiaSystem.LuaFunc5 = function() return false end
        ClientGlueHiaSystem.LuaFunc6 = function() return false end
        ClientGlueHiaSystem.LuaFunc7 = function() return false end
        ClientGlueHiaSystem.LuaFunc8 = function() return false end
    end
end)

pcall(function()
    local logic_mini_pak_gem = require("client.slua.logic.download.report.logic_mini_pak_gem")
    if logic_mini_pak_gem then
        logic_mini_pak_gem.StartReport = function() end
        logic_mini_pak_gem.ReportGemLog = function() end
        logic_mini_pak_gem.SetCurDownloadSize = function() end
    end
end)

        local h = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if h and h.__inner_impl then
            h.__inner_impl.SendAntiDataFlow = function() end
            h.__inner_impl.SendHitFireBtnFlow = function() end
        end
        
        local cr = require("GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem")
        if cr and cr.__inner_impl then
            cr.__inner_impl._OnSyncFatalDamage = function() end
            cr.__inner_impl._OnPlayerKilledOtherPlayer = function() end
        end
        
        if UnrealNet and UnrealNet.FilterNetworkException then
            local of = UnrealNet.FilterNetworkException
            UnrealNet.FilterNetworkException = function(t, m)
                if m and (string.find(m, "CheatDetected") or string.find(m, "IdipBan")) then return false end
                return of(t, m)
            end
        end
        
        
        
        if not _G.GameplayCallbacks then
    _G.GameplayCallbacks = {}
end

function _G.InitializeAntiReport()
    print('[AntiReport] Initializing System...')
    pcall(function()
        local reportPaths = { "GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem", "Client.Security.ClientReportPlayerSubsystem" }
        local ClientReportPlayerSubsystem = nil
        for _, path in ipairs(reportPaths) do
            if package.loaded[path] then ClientReportPlayerSubsystem = package.loaded[path] break end
            local success, loadedReportSubsystem = pcall(require, path)
            if success and loadedReportSubsystem then ClientReportPlayerSubsystem = loadedReportSubsystem break end
        end
        if ClientReportPlayerSubsystem then
            ClientReportPlayerSubsystem.OnInit = function(self) return end
            ClientReportPlayerSubsystem._OnPlayerKilledOtherPlayer = function() return end
            ClientReportPlayerSubsystem._RecordFatalDamager = function() return end
            ClientReportPlayerSubsystem._OnDeathReplayDataWhenFatalDamaged = function() return end
            ClientReportPlayerSubsystem._RecordMurdererFromDeathReplayData = function() return end
            ClientReportPlayerSubsystem._RecordTeammatePlayerInfo = function() return end
            ClientReportPlayerSubsystem._OnBattleResult = function() return end
            ClientReportPlayerSubsystem._OnShowQuickReportMutualExclusiveUI = function() return end
            ClientReportPlayerSubsystem.GetFatalDamagerMap = function() return {} end
            ClientReportPlayerSubsystem.GetCachedTeammateName2InfoMap = function() return {} end
            ClientReportPlayerSubsystem.GetTeammateName2InfoMapDuringBattle = function() return {} end
            ClientReportPlayerSubsystem.GetCurrentNotInTeamHistoricalTeammateMap = function() return {} end
            ClientReportPlayerSubsystem.GetInTeamIndexFromHistoricalTeammateInfo = function() return -1 end
        end
    end)

    pcall(function()
        local reportPaths = { "GameLua.Mod.BaseMod.DS.Security.DSReportPlayerSubsystem", "GameLua.Mod.BaseMod.Client.Security.DSReportPlayerSubsystem" }
        local DSReportPlayerSubsystem = nil
        for _, path in ipairs(reportPaths) do
            if package.loaded[path] then DSReportPlayerSubsystem = package.loaded[path] break end
            local success, loadedReportSubsystem = pcall(require, path)
            if success and loadedReportSubsystem then DSReportPlayerSubsystem = loadedReportSubsystem break end
        end
        if DSReportPlayerSubsystem then
            DSReportPlayerSubsystem.OnInit = function(self) return end
            DSReportPlayerSubsystem._OnNearDeathOrRescued = function() return end
            DSReportPlayerSubsystem._OnCharacterDied = function() return end
            DSReportPlayerSubsystem._OnTeammateDamage = function() return end
            DSReportPlayerSubsystem._OnPlayerSettlementStart = function() return end
            DSReportPlayerSubsystem._AddKnockDownerToBattleResult = function() return end
            DSReportPlayerSubsystem._AddKillerToBattleResult = function() return end
            DSReportPlayerSubsystem._AddTeammateMurderToBattleResult = function() return end
            DSReportPlayerSubsystem._AddFatalDamagerMapToBattleResult = function() return end
            DSReportPlayerSubsystem._AddMLKillerUIDToBattleResult = function() return end
            DSReportPlayerSubsystem._SaveHistoricalTeammateInfo = function() return end
            DSReportPlayerSubsystem._RecordFatalDamager = function() return end
            DSReportPlayerSubsystem._RecordTeammateMurderer = function() return end
        end
    end)

    pcall(function()
        local ReportPlayerUtils = require("GameLua.Mod.BaseMod.Common.Security.ReportPlayerUtils")
        if ReportPlayerUtils then
            ReportPlayerUtils.RecordFatalDamager = function() return end
            ReportPlayerUtils.IsUsingHistoricalTeammateInfo = function() return false end
            ReportPlayerUtils.IsCharacterDeliverAI = function() return false end
        end
    end)

    pcall(function()
        local SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils")
        if SecurityCommonUtils then
            SecurityCommonUtils.ExtractPlayerBasicInfo = function() return {} end
            SecurityCommonUtils.LogIf = function() return false end
        end
    end)

    pcall(function()
        local ClientQuickReportMaliciousTeammate = require("GameLua.Mod.BaseMod.Client.Security.ClientQuickReportMaliciousTeammate")
        if ClientQuickReportMaliciousTeammate then
            ClientQuickReportMaliciousTeammate.OnShowMutualExclusiveUI = function() return end
            ClientQuickReportMaliciousTeammate.OnHideMutualExclusiveUI = function() return end
        end
    end)

    pcall(function()
        local LogicReportReplay = package.loaded["client.slua.logic.replay.logic_report_replay"]
        if LogicReportReplay then
            LogicReportReplay.ReportReplay = function() end
            LogicReportReplay.SendReportReq = function() end
        end

        local LogicHomeReport = package.loaded["client.slua.logic.home.logic_home_report"]
        if LogicHomeReport then
            LogicHomeReport.ShowInGameReportUI = function() end
            LogicHomeReport.SendReport = function() end
        end
    end)

    print('[AntiReport] System Fully Active!')
end

function _G.DisableHiggsBoson()
    local localPlayerController = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if not localPlayerController or not slua.isValid(localPlayerController) then return end
    if localPlayerController.HiggsBoson then
        localPlayerController.HiggsBoson.bMHActive = false
        localPlayerController.HiggsBoson.bCallPreReplication = false
    end
    if localPlayerController.HiggsBosonComponent then
        localPlayerController.HiggsBosonComponent.bMHActive = false
        localPlayerController.HiggsBosonComponent:ControlMHActive(0)
    end
end

function _G.InitializeAntiCheatHooks()
    print('[AntiCheat] Initializing bypass system...')
    pcall(function()
        local HiggsBosonComponent = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if HiggsBosonComponent and HiggsBosonComponent.StaticShowSecurityAlertInDev then
            HiggsBosonComponent.StaticShowSecurityAlertInDev = function() end
        end
    end)

    if _G.AvatarCheckCallback then
        _G.AvatarCheckCallback.StartAvatarCheck = function(HiggsBosonComponent) end
        _G.AvatarCheckCallback.OnReportItemID = function(HiggsBosonComponent) end
        _G.AvatarCheckCallback.PostPlayerControllerLoginInit = function(localPlayerController)
            if slua.isValid(localPlayerController) and localPlayerController.HiggsBosonComponent then
                localPlayerController.HiggsBosonComponent:ControlMHActive(0)
                localPlayerController.HiggsBosonComponent.bMHActive = false
            end
        end
    end

    pcall(function()
        local HiggsBosonComponentModule = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if HiggsBosonComponentModule and HiggsBosonComponentModule.BlackList then
            for k in pairs(HiggsBosonComponentModule.BlackList) do HiggsBosonComponentModule.BlackList[k] = nil end
        end
    end)

    _G.BlackList = {}

    pcall(function()
        _G.GlobalPlayerCoronaData = _G.GlobalPlayerCoronaData or {}
        _G.GlobalPlayerCheatTimes = _G.GlobalPlayerCheatTimes or {}
        local mt = getmetatable(_G.GlobalPlayerCoronaData) or {}
        mt.__newindex = function(t, k, v) end
        setmetatable(_G.GlobalPlayerCoronaData, mt)
    end)

    pcall(function()
        if _G.GameSafeCallbacks and _G.GameSafeCallbacks.RecordStrategyTimestampInReplay then
            _G.GameSafeCallbacks.RecordStrategyTimestampInReplay = function(...) end
            _G.GameSafeCallbacks.DoAttackFlowStrategy = function() end
            _G.GameSafeCallbacks.GetScriptReportContent = function() return "" end
        end
    end)

    pcall(function()
        local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
        if STExtraBlueprintFunctionLibrary then
            STExtraBlueprintFunctionLibrary.IsDevelopment = function() return false end
        end
    end)
    print('[AntiCheat] Bypass system activated!')
end

function _G.InitializeGameplayBypass()
    pcall(function()
        if not _G.GameplayCallbacks or _G.GameplayCallbacks.IsBypassed then return end
        
        local GC = _G.GameplayCallbacks
        print('[GameplayBypass] Hooking GameplayCallbacks...')
        
        local OriginalOnDSPlayerStateChanged = GC.OnDSPlayerStateChanged
        GC.OnDSPlayerStateChanged = function(UID, InPlayerState, bPureWatcher, bIsSafeExit, ParamReason)
            if InPlayerState and string.lower(tostring(InPlayerState)) == "cheatdetected" then return end
            if OriginalOnDSPlayerStateChanged then return OriginalOnDSPlayerStateChanged(UID, InPlayerState, bPureWatcher, bIsSafeExit, ParamReason) end
        end

        local function EmptyFunc() return end
        local function EmptyTableFunc() return {} end
        local function EmptyNilFunc() return nil end
        
        GC.ReportAttackFlow = EmptyFunc
        GC.ReportSecAttackFlow = EmptyFunc
        GC.ReportHurtFlow = EmptyFunc
        GC.ReportFireArms = EmptyFunc
        GC.ReportVerifyInfoFlow = EmptyFunc
        GC.ReportMrpcsFlow = EmptyFunc
        GC.ReportPlayerBehavior = EmptyFunc
        GC.ReportTeammatHurt = EmptyFunc
        GC.ReportMisKillByTeammate = EmptyFunc
        GC.ReportForbitPick = EmptyFunc
        GC.ReportPlayerMoveRoute = EmptyFunc
        GC.ReportPlayerPosition = EmptyFunc
        GC.ReportVehicleMoveFlow = EmptyFunc
        GC.ReportSecTgameMovingFlow = EmptyFunc
        GC.ReportParachuteData = EmptyFunc
        GC.SendTssSdkAntiDataToLobby = EmptyFunc
        GC.SendDSErrorLogToLobby = EmptyFunc
        GC.SendDSErrorLogToLobbyOnece = EmptyFunc
        GC.SendDSHawkEyePatrolLogToLobby = EmptyFunc
        GC.ReportEquipmentFlow = EmptyFunc
        GC.ReportAimFlow = EmptyFunc
        GC.GetWeaponReport = EmptyTableFunc
        GC.GetOneWeaponReport = EmptyTableFunc
        GC.ReportHeavyWeaponBoxSpawnFlow = EmptyFunc
        GC.ReportHeavyWeaponBoxActivationFlow = EmptyFunc
        GC.ReportHeavyWeaponBoxOpenPlayerFlow = EmptyFunc
        GC.ReportHeavyWeaponBoxItemFlow = EmptyFunc
        GC.ReportPlayersPing = EmptyFunc
        GC.ReportPlayerIP = EmptyFunc
        GC.ReportPlayerFramePingRecord = EmptyFunc
        GC.OnDSConnectionSaturated = EmptyFunc
        GC.ReportDSNetSaturation = EmptyFunc
        GC.ReportNetContinuousSaturate = EmptyFunc
        GC.ReportDSNetRate = EmptyFunc
        GC.SendClientStats = EmptyFunc
        GC.SendServerAvgTickDelta = EmptyFunc
        GC.ReportCircleFlow = EmptyFunc
        GC.ReportDSCircleFlow = EmptyFunc
        GC.ReportJumpFlow = EmptyFunc
        GC.ReportAIStrategyInfo = EmptyFunc
        GC.SendAIDeliveryInfo = EmptyFunc
        GC.ReportDailyTaskInfo = EmptyFunc
        GC.ReportMatchRoomData = EmptyFunc
        GC.SendPlayerSpectatingLog = EmptyFunc
        GC.ReportIDCardProduceFlow = EmptyFunc
        GC.ReportIDCardPickUpFlow = EmptyFunc
        GC.ReportIDCardDestroyFlow = EmptyFunc
        GC.ReportRevivalFlow = EmptyFunc
        GC.ReportGameSetting = EmptyFunc
        GC.ReportGameSettingNew = EmptyFunc
        GC.ReportAntsVoiceTeamCreate = EmptyFunc
        GC.ReportAntsVoiceTeamQuit = EmptyFunc
        GC.ReportCommonInfo = EmptyFunc
        GC.ReportLightweightStat = EmptyFunc
        GC.SendSecTLog = EmptyFunc
        GC.SendDataMiningTLog = EmptyFunc
        GC.SendActivityTLog = EmptyFunc
        GC.GetGeneralTLogData = EmptyNilFunc
        
        GC.IsBypassed = true
    end)

    pcall(function()
        if NetUtil and NetUtil.SendPacket and not NetUtil.IsBypassed then
            local OriginalSendPacket = NetUtil.SendPacket
            local blockedPacketsMap = {
                ["ReportAttackFlow"]=1, ["ReportSecAttackFlow"]=1, ["ReportHurtFlow"]=1,
                ["ReportFireArms"]=1, ["ReportVerifyInfoFlow"]=1, ["ReportMrpcsFlow"]=1,
                ["ReportPlayerBehavior"]=1, ["ReportTeammatHurt"]=1, ["ReportTeammateKillConfirmFlow"]=1,
                ["ReportForbiddenPickupFlow"]=1, ["ReportPlayerMoveRoute"]=1, ["ReportPlayerPosition"]=1,
                ["ReportSecVehicleMoveFlow"]=1, ["ReportSecTgameMovingFlow"]=1, ["report_parachute_data"]=1,
                ["report_character_all_drag"]=1, ["report_parachute_all_drag"]=1, ["report_vehicle_move_drag"]=1,
                ["on_tss_sdk_anti_data"]=1, ["report_unrealnet_exception"]=1, ["ReportPlayerEquipmentInfo"]=1,
                ["ReportAimFlow"]=1, ["ReportHitFlow"]=1, ["log_shooting_miss"]=1, ["report_heavy_weapon_box_activation_flow"]=1,
                ["report_heavy_weapon_box_item_flow"]=1, ["ReportCircleFlow"]=1, ["report_ds_player_circle_flow"]=1,
                ["ReportJumpFlow"]=1, ["ReportGameStartFlow"]=1, ["ReportGameEndFlow"]=1, ["report_players_ping"]=1,
                ["report_player_ip"]=1, ["report_player_frame_ping_record"]=1, ["report_net_saturate"]=1,
                ["report_ds_netsaturate"]=1, ["report_ds_net_continuous_saturate"]=1, ["report_ds_netrate"]=1,
                ["report_unrealnet_clientstats"]=1, ["report_serverstat_avgtickdelta"]=1, ["report_all_players_address"]=1,
                ["report_ai_strategyinfo"]=1, ["ReportAIActionFlow"]=1, ["ReportGenerateMonsterFlow"]=1,
                ["report_ds_match_room_data"]=1, ["SendSpectatingLog"]=1, ["ReportIDCardProduceFlow"]=1,
                ["ReportIDCardPickUpFlow"]=1, ["ReportIDCardDestroyFlow"]=1, ["ReportRevivalFlow"]=1,
                ["ReportGameSetting"]=1, ["ReportGameSettingNew"]=1, ["ReportAntsVoiceTeamCreate"]=1,
                ["ReportAntsVoiceTeamQuit"]=1, ["report_common_info"]=1, ["report_common_battle_info"]=1,
                ["report_client_scan_result"]=1, ["tss_sdk_report"]=1, ["report_memory_exception"]=1,
                ["report_avatar_exception"]=1, ["report_ui_state"]=1, ["report_hit_reg_fail"]=1,
                ["report_character_state"]=1, ["report_vehicle_exception"]=1, ["report_camera_exception"]=1,
                ["ReportPlayerControllerStateChanged"]=1, ["ReportAvatarFlow"]=1,
                ["send_ugc_report_uni_mod_expose_req"]=1, 
                ["send_ugc_report_uni_mod_interactive_req"]=1,
            }
            
            NetUtil.SendPacket = function(packetName, ...)
                if blockedPacketsMap[packetName] then return end
                return OriginalSendPacket(packetName, ...)
            end
            NetUtil.IsBypassed = true
        end
    end)
end

function _G.InitializeConnectionGuard()
    pcall(function()
        if _G.ConnectionGuardInitialized or not _G.GameplayCallbacks then return end
        print('[ConnectionGuard] Initializing Shield...')
        
        local GC = _G.GameplayCallbacks
        local OriginalOnDSPlayerStateChanged = GC.OnDSPlayerStateChanged

        GC.OnDSPlayerStateChanged = function(UID, InPlayerState, bPureWatcher, bIsSafeExit, ParamReason)
            local stateNameLower = InPlayerState and string.lower(tostring(InPlayerState)) or ""
            local blockedStatesMap = {
                ["cheatdetected"] = true, ["connectionlost"] = true,
                ["connectiontimeout"] = true, ["connectionexception"] = true,
                ["netdrivererror"] = true
            }
            if blockedStatesMap[stateNameLower] then return end
            if OriginalOnDSPlayerStateChanged then
                pcall(OriginalOnDSPlayerStateChanged, UID, InPlayerState, bPureWatcher, bIsSafeExit, ParamReason)
            end
        end

        GC.OnPlayerNetConnectionClosed = function(GameID, UID, Reason, ErrorMessage) end
        GC.OnPlayerActorChannelError = function(GameID, UID, Reason, ErrorMessage) end
        GC.OnPlayerRPCValidateFailed = function(GameID, UID, Reason, ErrorMessage) end
        GC.OnPlayerSpectateException = function(GameID, UID, Reason, ErrorMessage) end
        GC.OnShutdownAfterError = function(GameID) end

        _G.ConnectionGuardInitialized = true
        print('[ConnectionGuard] Active & Protecting!')
    end)
end

function _G.InitializeLogBlocker()
    print('[LogBlocker] Initializing Ultimate Log/Crash Blocker...')
    pcall(function()
        local TLog = package.loaded["TLog"] or _G.TLog
        if TLog then
            TLog.Info = function() end; TLog.Warning = function() end
            TLog.Error = function() end; TLog.Debug = function() end; TLog.Report = function() end
        end

        local CrashSight = package.loaded["CrashSight"] or _G.CrashSight
        if CrashSight then
            CrashSight.ReportException = function() end
            CrashSight.SetCustomData = function() end; CrashSight.Log = function() end
        end
        
        local ClientToolsReport = package.loaded["client.slua.logic.report.ClientToolsReport"]
        if ClientToolsReport then
            ClientToolsReport.SendReport = function() end; ClientToolsReport.SendException = function() end
        end

        local TLogReportUtils = package.loaded["client.slua.config.tlog.tlog_report_utils"]
        if TLogReportUtils then
            TLogReportUtils.ReportTLogEvent = function() end
        end

        local UGCNewTLogReport = package.loaded["client.slua.logic.ugc.UGCNewTLogReport"] or package.loaded["client.slua.data.BasicData.BasicDataTLogReport"]
        if UGCNewTLogReport then
            UGCNewTLogReport.SendExposeReq = function() end
            UGCNewTLogReport.SendInteractionReq = function() end
            UGCNewTLogReport.TLogReport = function() end
        end
        
        local LogicUGCTLog = package.loaded["client.slua.logic.ugc.logic_ugc_tlog"]
        if LogicUGCTLog then
            LogicUGCTLog.SendModTLog = function() end
            LogicUGCTLog.ReportStay = function() end
        end

        local ClientTLogUtil = package.loaded["GameLua.Mod.BaseMod.Client.ClientTLog.ClientTLogUtil"]
        if ClientTLogUtil then
            ClientTLogUtil.ReportGeneralCountByBRPhase = function() end
            ClientTLogUtil.ReportCommonTLogDataByBRPhase = function() end
        end

        local GameplayDataRef = require("GameLua.GameCore.Data.GameplayData")
        if GameplayDataRef then
            local playerController = GameplayDataRef.GetPlayerControllerSafety and GameplayDataRef.GetPlayerControllerSafety() or GameplayDataRef.GetPlayerController()
            if slua.isValid(playerController) and playerController.ReportCrashKitFeature then
                playerController.ReportCrashKitFeature.ReportCharacterAttachedOnVehicleException = function() end
            end
        end

        local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        local GameReportSubsystem = SubsystemMgr and SubsystemMgr:Get("GameReportSubsystem")
        if GameReportSubsystem then
            GameReportSubsystem.CheckCanBugglyPostException = function() return false end
            GameReportSubsystem.BugglyPostExceptionFull = function() return false end
        end
    end)
    print('[LogBlocker] Log/Crash/UGC Telemetry Systems Silenced!')
end

function _G.InitializeScannerBlocker()
    print('[ScannerBlocker] Initializing Scanner Blocker...')
    pcall(function()
        local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        
        if SubsystemMgr then
            local AFKReportorSubsystem = SubsystemMgr:Get("AFKReportorSubsystem")
            if AFKReportorSubsystem then 
                AFKReportorSubsystem.PlayerHaveAction = function() end; AFKReportorSubsystem.ReportAFK = function() end
            end

            local AvatarExceptionSubsystem = SubsystemMgr:Get("AvatarExceptionSubsystem")
            if AvatarExceptionSubsystem then
                AvatarExceptionSubsystem.ReportException = function() end
                AvatarExceptionSubsystem.BindPlayerCharacter = function() end
                AvatarExceptionSubsystem.CheckAvatarValid = function() return true end
            end
            
            local ShootVerifySubSystemClient = SubsystemMgr:Get("ShootVerifySubSystemClient")
            if ShootVerifySubSystemClient then
                ShootVerifySubSystemClient.ReportVerifyFail = function() end
                ShootVerifySubSystemClient.OnVerifyFailed = function() end
            end
        end

        local AvatarCheckerModule = package.loaded["blacklist.slua.logic.lobby_gm.AvatarCheckerModule"]
        if AvatarCheckerModule then
            AvatarCheckerModule.CheckAvatar = function() return true end
            AvatarCheckerModule.ReportException = function() end
        end

        local LogicMemoryWarning = package.loaded["client.slua.logic.memory_warning.logic_memory_warning"]
        if LogicMemoryWarning then
            LogicMemoryWarning.OnMemoryWarning = function() end
            LogicMemoryWarning.ReportMemoryWarning = function() end
        end

        local TssSdk = package.loaded["TssSdk"] or _G.TssSdk
        if TssSdk then
            TssSdk.OnRecvData = function() end; TssSdk.SendReportInfo = function() end
            TssSdk.ScanMemory = function() return true end
        end
    end)
    print('[ScannerBlocker] Scanners and Exception Detectors Bypassed!')
end

function _G.InitializeReplayTelemetryBlocker()
    print('[ReplayBlocker] Initializing Replay Telemetry Blocker...')
    pcall(function()
        local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        
        local RescueBtnReplayTraceSubsystem = SubsystemMgr and SubsystemMgr:Get("RescueBtnReplayTraceSubsystem")
        if RescueBtnReplayTraceSubsystem then
            RescueBtnReplayTraceSubsystem.ReportTrace = function() end; RescueBtnReplayTraceSubsystem.StartTickMonitor = function() end
            RescueBtnReplayTraceSubsystem.TickMonitorCheck = function() end; RescueBtnReplayTraceSubsystem.ReportTickMonitorHeartbeat = function() end
        end

        local GameReportUtils = package.loaded["GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils"]
        if GameReportUtils then
            GameReportUtils.ReplayReportData = function() end
            GameReportUtils.ReportGameException = function() end
        end

        local GameReportSubsystem = SubsystemMgr and SubsystemMgr:Get("GameReportSubsystem")
        if GameReportSubsystem then
            GameReportSubsystem.ReplayReportData = function() return false end
            if GameReportSubsystem.Reporter then
                GameReportSubsystem.Reporter.ReportIntArrayData = function() end
                GameReportSubsystem.Reporter.ReportUInt8ArrayData = function() end
                GameReportSubsystem.Reporter.ReportFloatArrayData = function() end
            end
        end
    end)
    print('[ReplayBlocker] Replay Evidence Collection Stopped!')
end

-- Initialize all bypasses immediately
local function InitializeAllBlockers()
    pcall(function()
        print('[BYPASS_MODULE] ACTIVATING ALL BYPASSES - FIRST PRIORITY!')
        if _G.InitializeAntiReport then _G.InitializeAntiReport() end
        if _G.InitializeAntiCheatHooks then _G.InitializeAntiCheatHooks() end
        if _G.InitializeGameplayBypass then _G.InitializeGameplayBypass() end
        if _G.InitializeConnectionGuard then _G.InitializeConnectionGuard() end
        if _G.DisableHiggsBoson then _G.DisableHiggsBoson() end
        if _G.InitializeLogBlocker then _G.InitializeLogBlocker() end
        if _G.InitializeScannerBlocker then _G.InitializeScannerBlocker() end
        if _G.InitializeReplayTelemetryBlocker then _G.InitializeReplayTelemetryBlocker() end
        print('[BYPASS_MODULE] ALL BYPASSES ACTIVATED SUCCESSFULLY!')
    end)
end

        
        
        if NetUtil and NetUtil.SendPkg and not NetUtil._bp then
            local old = NetUtil.SendPkg
            local blocked = {
                ["on_crow_update_ntf"]=1, ["hisar"]=1, ["ReportAttackFlow"]=1,
                ["ReportHurtFlow"]=1, ["ReportFireArms"]=1, ["ReportPlayerBehavior"]=1,
                ["report_tss_sdk_anti_data"]=1,
            }
            NetUtil.SendPkg = function(n, ...)
                if blocked[n] then return end
                return old(n, ...)
            end
            NetUtil._bp = true
        end
        
        _G.BypassInstalled = true
    end)
end

-- SECURITY & ANTICHEAT BYPASS HANDLING
function _G.InitializeAntiReport()
    pcall(function()
        local paths = {
            "GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem",
            "Client.Security.ClientReportPlayerSubsystem"
        }
        
        local ClientReport = nil
        for _, path in ipairs(paths) do
            if package.loaded[path] then ClientReport = package.loaded[path] break end
            local status, lib = pcall(require, path)
            if status and lib then ClientReport = lib break end
        end

        if ClientReport then
            ClientReport.OnInit = function(self) return end
            ClientReport._OnPlayerKilledOtherPlayer = function() return end
            ClientReport._RecordFatalDamager = function() return end
            ClientReport._OnDeathReplayDataWhenFatalDamaged = function() return end
            ClientReport._RecordMurdererFromDeathReplayData = function() return end
            ClientReport._RecordTeammatePlayerInfo = function() return end
            ClientReport._OnBattleResult = function() return end
            ClientReport._OnShowQuickReportMutualExclusiveUI = function() return end
            ClientReport.GetFatalDamagerMap = function() return {} end
            ClientReport.GetCachedTeammateName2InfoMap = function() return {} end
            ClientReport.GetTeammateName2InfoMapDuringBattle = function() return {} end
            ClientReport.GetCurrentNotInTeamHistoricalTeammateMap = function() return {} end
            ClientReport.GetInTeamIndexFromHistoricalTeammateInfo = function() return -1 end
        end
    end)

    pcall(function()
        local paths = {
            "GameLua.Mod.BaseMod.DS.Security.DSReportPlayerSubsystem",
            "GameLua.Mod.BaseMod.Client.Security.DSReportPlayerSubsystem"
        }
        
        local DSReport = nil
        for _, path in ipairs(paths) do
            if package.loaded[path] then DSReport = package.loaded[path] break end
            local status, lib = pcall(require, path)
            if status and lib then DSReport = lib break end
        end

        if DSReport then
            DSReport.OnInit = function(self) return end
            DSReport._OnNearDeathOrRescued = function() return end
            DSReport._OnCharacterDied = function() return end
            DSReport._OnTeammateDamage = function() return end
            DSReport._OnPlayerSettlementStart = function() return end
            DSReport._AddKnockDownerToBattleResult = function() return end
            DSReport._AddKillerToBattleResult = function() return end
            DSReport._AddTeammateMurderToBattleResult = function() return end
            DSReport._AddFatalDamagerMapToBattleResult = function() return end
            DSReport._AddMLKillerUIDToBattleResult = function() return end
            DSReport._SaveHistoricalTeammateInfo = function() return end
            DSReport._RecordFatalDamager = function() return end
            DSReport._RecordTeammateMurderer = function() return end
        end
    end)

    pcall(function()
        local ReportPlayerUtils = require("GameLua.Mod.BaseMod.Common.Security.ReportPlayerUtils")
        if ReportPlayerUtils then
            ReportPlayerUtils.RecordFatalDamager = function() return end
            ReportPlayerUtils.IsUsingHistoricalTeammateInfo = function() return false end
            ReportPlayerUtils.IsCharacterDeliverAI = function() return false end
        end
    end)

    pcall(function()
        local SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils")
        if SecurityCommonUtils then
            SecurityCommonUtils.ExtractPlayerBasicInfo = function() return {} end
            SecurityCommonUtils.LogIf = function() return false end
        end
    end)

    pcall(function()
        local HiggsBosonComponent = Waitrequire("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if HiggsBosonComponent then
            HiggsBosonComponent.StaticShowSecurityAlertInDev = function() return end
        end
    end)

    pcall(function()
        local QuickReport = require("GameLua.Mod.BaseMod.Client.Security.ClientQuickReportMaliciousTeammate")
        if QuickReport then
            QuickReport.OnShowMutualExclusiveUI = function() return end
            QuickReport.OnHideMutualExclusiveUI = function() return end
        end
    end)
end

function _G.DisableHiggsBoson()
    local PlayerController = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if not PlayerController or not slua.isValid(PlayerController) then return end
    
    if PlayerController.HiggsBoson then
        PlayerController.HiggsBoson.bMHActive = false
        PlayerController.HiggsBoson.bCallPreReplication = false
    end
    
    if PlayerController.HiggsBosonComponent then
        PlayerController.HiggsBosonComponent.bMHActive = false
    end
end

pcall(function()
    local HiggsBosonComponent = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
    if HiggsBosonComponent and HiggsBosonComponent.StaticShowSecurityAlertInDev then
        HiggsBosonComponent.StaticShowSecurityAlertInDev = function() end
    end
end)

if _G.AvatarCheckCallback then
    _G.AvatarCheckCallback.StartAvatarCheck = function(HiggsBosonComponent) end
    
    _G.AvatarCheckCallback.OnReportItemID = function(HiggsBosonComponent)
        if slua.isValid(HiggsBosonComponent) and HiggsBosonComponent.FFItemIDMap then
            local DetectedItems = {}
            for ItemID, _ in pairs(HiggsBosonComponent.FFItemIDMap) do
                table.insert(DetectedItems, ItemID)
            end
            
            if #DetectedItems > 0 then
                pcall(function()
                    local path = "/sdcard/Download/detected_items.txt"
                    local file = io.open(path, 'w+')
                    if file then
                        file:write('Detected Items:\n')
                        for _, id in ipairs(DetectedItems) do
                            file:write(tostring(id) .. '\n')
                        end
                        file:close()
                    end
                end)
            end
        end
    end
    
    _G.AvatarCheckCallback.PostPlayerControllerLoginInit = function(PlayerController)
        if slua.isValid(PlayerController) and PlayerController.HiggsBosonComponent then
            PlayerController.HiggsBosonComponent:ControlMHActive(0)
            PlayerController.HiggsBosonComponent.bMHActive = false
        end
    end
end

pcall(function()
    local SecurityModule = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
    if SecurityModule and SecurityModule.BlackList then
        for k in pairs(SecurityModule.BlackList) do
            SecurityModule.BlackList[k] = nil
        end
    end
end)

pcall(function()
    _G.GlobalPlayerCoronaData = _G.GlobalPlayerCoronaData or {}
    _G.GlobalPlayerCheatTimes = _G.GlobalPlayerCheatTimes or {}
    local mt = getmetatable(_G.GlobalPlayerCoronaData) or {}
    mt.__newindex = function(t, k, v) end
    setmetatable(_G.GlobalPlayerCoronaData, mt)
end)

pcall(function()
    if _G.GameSafeCallbacks and _G.GameSafeCallbacks.RecordStrategyTimestampInReplay then
        _G.GameSafeCallbacks.RecordStrategyTimestampInReplay = function(...) end
    end
end)

pcall(function()
    local USTExtraBlueLogFunctionLibrary = import("STExtraBlueLogFunctionLibrary")
    if USTExtraBlueLogFunctionLibrary then
        USTExtraBlueLogFunctionLibrary.IsDevelopment = function() return false end
    end
end)

pcall(function()
    local logic_imsdk_deeplink_login = require('client.logic.login.logic_imsdk_deeplink_login')
    if logic_imsdk_deeplink_login then
        local originalLoginViaSystemWebview = logic_imsdk_deeplink_login.LoginViaSystemWebview
        if originalLoginViaSystemWebview then
            logic_imsdk_deeplink_login.LoginViaSystemWebview = function(self, loginType)
                if loginType == 42 then return false end
                return originalLoginViaSystemWebview(self, loginType)
            end
        end
    end
end)


-- GAMEPLAY TRAFFIC & CONNECTION GUARD BYPASS
function _G.InitializeGameplayBypass()
    pcall(function()
        if not _G.GameplayCallbacks then return end
        if _G.GameplayCallbacks.IsBypassed then return end
        
        local GC = _G.GameplayCallbacks
        local original_OnDSPlayerStateChanged = GC.OnDSPlayerStateChanged
        GC.OnDSPlayerStateChanged = function(UID, InPlayerState, bPureWatcher, bIsSafeExit, ParamReason)
            if InPlayerState and string.lower(tostring(InPlayerState)) == "cheatdetected" then return end
            if original_OnDSPlayerStateChanged then
                return original_OnDSPlayerStateChanged(UID, InPlayerState, bPureWatcher, bIsSafeExit, ParamReason)
            end
        end

        local function BlockFunc() return end
        local function BlockRetEmpty() return {} end
        local function BlockRetNil() return nil end
        
        GC.ReportAttackFlow = BlockFunc
        GC.ReportSecAttackFlow = BlockFunc
        GC.ReportHurtFlow = BlockFunc
        GC.ReportFireArms = BlockFunc
        GC.ReportVerifyInfoFlow = BlockFunc
        GC.ReportMrpcsFlow = BlockFunc
        GC.ReportPlayerBehavior = BlockFunc
        GC.ReportTeammatHurt = BlockFunc
        GC.ReportMisKillByTeammate = BlockFunc
        GC.ReportForbitPick = BlockFunc
        GC.ReportPlayerMoveRoute = BlockFunc
        GC.ReportPlayerPosition = BlockFunc
        GC.ReportVehicleMoveFlow = BlockFunc
        GC.ReportSecTgameMovingFlow = BlockFunc
        GC.ReportParachuteData = BlockFunc
        GC.SendTssSdkAntiDataToLobby = function(GameID, Uid, Data, DataLen, NetworkStatus) return end
        GC.SendDSErrorLogToLobby = BlockFunc
        GC.SendDSErrorLogToLobbyOnece = BlockFunc
        GC.SendDSHawkEyePatrolLogToLobby = BlockFunc
        GC.ReportEquipmentFlow = BlockFunc
        GC.ReportAimFlow = BlockFunc
        GC.GetWeaponReport = BlockRetEmpty
        GC.GetOneWeaponReport = BlockRetEmpty
        GC.ReportHeavyWeaponBoxSpawnFlow = BlockFunc
        GC.ReportHeavyWeaponBoxActivationFlow = BlockFunc
        GC.ReportHeavyWeaponBoxOpenPlayerFlow = BlockFunc
        GC.ReportHeavyWeaponBoxItemFlow = BlockFunc
        GC.ReportPlayersPing = BlockFunc
        GC.ReportPlayerIP = BlockFunc
        GC.ReportPlayerFramePingRecord = BlockFunc
        GC.OnDSConnectionSaturated = BlockFunc
        GC.ReportDSNetSaturation = BlockFunc
        GC.ReportNetContinuousSaturate = BlockFunc
        GC.ReportDSNetRate = BlockFunc
        GC.SendClientStats = BlockFunc
        GC.SendServerAvgTickDelta = BlockFunc
        GC.ReportCircleFlow = BlockFunc
        GC.ReportDSCircleFlow = BlockFunc
        GC.ReportJumpFlow = BlockFunc
        GC.ReportAIStrategyInfo = BlockFunc
        GC.SendAIDeliveryInfo = BlockFunc
        GC.ReportDailyTaskInfo = BlockFunc
        GC.ReportMatchRoomData = BlockFunc
        GC.SendPlayerSpectatingLog = BlockFunc
        GC.ReportIDCardProduceFlow = BlockFunc
        GC.ReportIDCardPickUpFlow = BlockFunc
        GC.ReportIDCardDestroyFlow = BlockFunc
        GC.ReportRevivalFlow = BlockFunc
        GC.ReportGameSetting = BlockFunc
        GC.ReportGameSettingNew = BlockFunc
        GC.ReportAntsVoiceTeamCreate = BlockFunc
        GC.ReportAntsVoiceTeamQuit = BlockFunc
        GC.ReportCommonInfo = BlockFunc
        GC.ReportLightweightStat = BlockFunc
        GC.SendSecTLog = BlockFunc
        GC.SendDataMiningTLog = BlockFunc
        GC.SendActivityTLog = BlockFunc
        GC.GetGeneralTLogData = BlockRetNil

        GC.IsBypassed = true
    end)

    pcall(function()
        if NetUtil and NetUtil.SendPacket and not NetUtil.IsBypassed then
            local original_SendPacket = NetUtil.SendPacket
            local BlockedPackets = {
                ["ReportAttackFlow"]=1, ["ReportSecAttackFlow"]=1, ["ReportHurtFlow"]=1,
                ["ReportFireArms"]=1, ["ReportVerifyInfoFlow"]=1, ["ReportMrpcsFlow"]=1,
                ["ReportPlayerBehavior"]=1, ["ReportTeammatHurt"]=1, ["ReportTeammateKillConfirmFlow"]=1,
                ["ReportForbiddenPickupFlow"]=1, ["ReportPlayerMoveRoute"]=1, ["ReportPlayerPosition"]=1,
                ["ReportSecVehicleMoveFlow"]=1, ["ReportSecTgameMovingFlow"]=1, ["report_parachute_data"]=1,
                ["report_character_all_drag"]=1, ["report_parachute_all_drag"]=1, ["report_vehicle_move_drag"]=1,
                ["on_tss_sdk_anti_data"]=1, ["report_unrealnet_exception"]=1, ["ReportPlayerEquipmentInfo"]=1,
                ["ReportAimFlow"]=1, ["ReportHitFlow"]=1, ["log_shooting_miss"]=1, ["report_heavy_weapon_box_activation_flow"]=1,
                ["report_heavy_weapon_box_item_flow"]=1, ["ReportCircleFlow"]=1, ["report_ds_player_circle_flow"]=1,
                ["ReportJumpFlow"]=1, ["ReportGameStartFlow"]=1, ["ReportGameEndFlow"]=1, ["report_players_ping"]=1,
                ["report_player_ip"]=1, ["report_player_frame_ping_record"]=1, ["report_net_saturate"]=1,
                ["report_ds_netsaturate"]=1, ["report_ds_net_continuous_saturate"]=1, ["report_ds_netrate"]=1,
                ["report_unrealnet_clientstats"]=1, ["report_serverstat_avgtickdelta"]=1, ["report_all_players_address"]=1,
                ["report_ai_strategyinfo"]=1, ["ReportAIActionFlow"]=1, ["ReportGenerateMonsterFlow"]=1,
                ["report_ds_match_room_data"]=1, ["SendSpectatingLog"]=1, ["ReportIDCardProduceFlow"]=1,
                ["ReportIDCardPickUpFlow"]=1, ["ReportIDCardDestroyFlow"]=1, ["ReportRevivalFlow"]=1,
                ["ReportGameSetting"]=1, ["ReportGameSettingNew"]=1, ["ReportAntsVoiceTeamCreate"]=1,
                ["ReportAntsVoiceTeamQuit"]=1, ["report_common_info"]=1, ["report_common_battle_info"]=1
            }
            
            NetUtil.SendPacket = function(packetName, ...)
                if BlockedPackets[packetName] then return end
                return original_SendPacket(packetName, ...)
            end
            NetUtil.IsBypassed = true
        end
    end)
    
    pcall(function()
        if _G.GameSafeCallbacks and not _G.GameSafeCallbacks.IsBypassed then
             _G.GameSafeCallbacks.DoAttackFlowStrategy = function() end
             _G.GameSafeCallbacks.GetScriptReportContent = function() return "" end
             _G.GameSafeCallbacks.RecordStrategyTimestampInReplay = function() end
             _G.GameSafeCallbacks.IsBypassed = true
        end
    end)
end

_G.ConnectionGuardInitialized = false

function _G.InitializeConnectionGuard()
    pcall(function()
        if _G.ConnectionGuardInitialized then return end
        if not _G.GameplayCallbacks then return end
        
        local GC = _G.GameplayCallbacks
        local original_OnDSPlayerStateChanged = GC.OnDSPlayerStateChanged

        GC.OnDSPlayerStateChanged = function(UID, InPlayerState, bPureWatcher, bIsSafeExit, ParamReason)
            local sState = InPlayerState and string.lower(tostring(InPlayerState)) or ""
            local BadStates = {
                ["cheatdetected"] = true,
                ["connectionlost"] = true,
                ["connectiontimeout"] = true,
                ["connectionexception"] = true,
                ["netdrivererror"] = true
            }
            if BadStates[sState] then return end
            if original_OnDSPlayerStateChanged then
                pcall(original_OnDSPlayerStateChanged, UID, InPlayerState, bPureWatcher, bIsSafeExit, ParamReason)
            end
        end

        GC.OnPlayerNetConnectionClosed = function(GameID, UID, Reason, ErrorMessage) end
        GC.OnPlayerActorChannelError = function(GameID, UID, Reason, ErrorMessage) end
        GC.OnPlayerRPCValidateFailed = function(GameID, UID, Reason, ErrorMessage) end
        GC.OnPlayerSpectateException = function(GameID, UID, Reason, ErrorMessage) end
        GC.OnShutdownAfterError = function(GameID) end

        _G.ConnectionGuardInitialized = true
    end)
end

-- TIMER TICKERS & LOOPS EXECUTIONS
local function AntiCheatHandler()
    if _G.DisableHiggsBoson then pcall(_G.DisableHiggsBoson) end
end

local TXtime_ticker = require('common.time_ticker')
_G.Mytimer_ticker = TXtime_ticker

-- Execute Initialization
InstallAntiCheatBypass()
_G.InitializeAntiReport()
_G.InitializeGameplayBypass()
_G.InitializeConnectionGuard()
pcall(_G.DisableHiggsBoson)

if _G.Mytimer_ticker then
    pcall(function()
        _G.Mytimer_ticker.AddTimerLoop(3, AntiCheatHandler, -1, 1)
    end)
end

-- VERSION UTILITY BYPASS & ANTI-ERROR
pcall(function()
    local original_require = _G.require
    _G.require = function(modname)
        local status, result = pcall(original_require, modname)
        
        if status and result then
            if string.find(modname, "version_up_module") or string.find(modname, "login_module") then
                if type(result) == "table" or type(result) == "userdata" then
                    result.GetTssVersion = function(self)
                        local secureVersion = _G.global_patch_tss or _G.global_package_tss or "4.6.0.21125_Patch"
                        return secureVersion
                    end
                    
                    if result.IsInLoginForceUpdateProgress then
                        result.IsInLoginForceUpdateProgress = function(self) 
                            return false 
                        end
                    end
                end
            end
        end
        return result
    end
    end) 
    
    pcall(function()
    if OperationalStatsSubsystem then
        OperationalStatsSubsystem.ReportOperationalStats = nop
        OperationalStatsSubsystem.AddOperationalStats = nop
        OperationalStatsSubsystem.HandleTouchBegin = nop
        OperationalStatsSubsystem.HandleTouchEnd = nop
        OperationalStatsSubsystem.OnInit = nop
        OperationalStatsSubsystem.HandleEnterFighting = nop
        OperationalStatsSubsystem.OnBattleResult = nop
        if OperationalStatsSubsystem.TimerHandle then
            pcall(function() OperationalStatsSubsystem:RemoveGameTimer(OperationalStatsSubsystem.TimerHandle) end)
            OperationalStatsSubsystem.TimerHandle = nil
        end
        OperationalStatsSubsystem.StatsData = {}
        print("[BYPASS]  OperationalStatsSubsystem blocked!")
    end
end)
    
local GC = _G.GameplayCallbacks or _G.GC
        if GC then
            GC.SendTssSdkAntiDataToLobby = empty_func
            GC.SendDSErrorLogToLobby = empty_func
            GC.SendDSHawkEyePatrolLogToLobby = empty_func
            GC.SendSecTLog = empty_func
            GC.SendDataMiningTLog = empty_func
            GC.SendActivityTLog = empty_func
            local orig_OnDSPlayerStateChanged = GC.OnDSPlayerStateChanged
            GC.OnDSPlayerStateChanged = function(a, b, c, ...)
                if string.lower(tostring(c)) == "cheatdetected" then return end
                if orig_OnDSPlayerStateChanged then
                    pcall(orig_OnDSPlayerStateChanged, a, b, c, ...)
                end
            end
        end
        
        if _G.BasicDataTLogReport then
            _G.BasicDataTLogReport.OnSendBatchReqMsg = empty_func
            _G.BasicDataTLogReport.OnImmediateReqMsg = empty_func
            _G.BasicDataTLogReport.send_report_event_duration_log = empty_func
            _G.BasicDataTLogReport.SendTlog = empty_func
        end
        
        if _G.TApmHelper then
            _G.TApmHelper.postEvent = empty_func
        end
        
        if _G.ServerDataMgr and _G.ServerDataMgr.DeletablePlayerResultKey then
            local key = _G.ServerDataMgr.DeletablePlayerResultKey
            key.SuspiciousHitCount = true
            key.EspTotalSimTraceCnt = true
            key.EspTotalImeFocusCnt = true
            key.ClientGravityAnomalyCount = true
        end
        
        local HiggsBosonComponent = package.loaded["GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent"] or require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if HiggsBosonComponent then
            HiggsBosonComponent.ControlMHActive = empty_func
            HiggsBosonComponent.TriggerAvatarCheck = empty_func
            HiggsBosonComponent.StartAvatarCheck = empty_func
            HiggsBosonComponent.GetNetAvatarItemIDs = ret_empty_table
            HiggsBosonComponent.GetCurWeaponSkinID = ret_zero
            HiggsBosonComponent.SendHisarData = empty_func
            HiggsBosonComponent.OnLogin = empty_func
            HiggsBosonComponent.ValidateSecurityData = ret_true
        end
        
        if _G.DisableHiggsBoson then
            _G.DisableHiggsBoson = empty_func
        end
        
        local ClientGlueHiaSystem = package.loaded["GameLua.Mod.BaseMod.Client.Security.ClientGlueHiaSystem"] or require("GameLua.Mod.BaseMod.Client.Security.ClientGlueHiaSystem")
        if ClientGlueHiaSystem then
            ClientGlueHiaSystem.CheckHitIntegrity = ret_true
            ClientGlueHiaSystem.InitSession = empty_func
            ClientGlueHiaSystem.OnBattleEnd = empty_func
        end
        if _G.ClientGlueHiaSystem then
            _G.ClientGlueHiaSystem.CheckHitIntegrity = ret_true
        end
        
        local SecurityCommonUtils = package.loaded["GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils"] or require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils")
        if SecurityCommonUtils and SecurityCommonUtils.EStrategyTypeInReplay then
            SecurityCommonUtils.EStrategyTypeInReplay.EspTotalSimTraceCnt = 0
            SecurityCommonUtils.EStrategyTypeInReplay.EspTotalImeFocusCnt = 0
            SecurityCommonUtils.EStrategyTypeInReplay.ClientGravityAnomalyCount = 0
            SecurityCommonUtils.EStrategyTypeInReplay.FlyingErrorCnt = 0
        end
        
        local SecurityNotifyPCFeature = package.loaded["GameLua.Mod.BaseMod.Common.Security.SecurityNotifyPCFeature"] or require("GameLua.Mod.BaseMod.Common.Security.SecurityNotifyPCFeature")
        if SecurityNotifyPCFeature then
            SecurityNotifyPCFeature.ClientRPC_SyncBanID = empty_func
            SecurityNotifyPCFeature.ClientRPC_StrongTips = empty_func
            SecurityNotifyPCFeature.ClientRPC_NormalTips = empty_func
            SecurityNotifyPCFeature.Notify = empty_func
        end
        
        local ClientReportPlayerSubsystem = package.loaded["GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem"] or require("GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem")
        if ClientReportPlayerSubsystem then
            ClientReportPlayerSubsystem.OnInit = empty_func
            ClientReportPlayerSubsystem._OnPlayerKilledOtherPlayer = empty_func
            ClientReportPlayerSubsystem._RecordFatalDamager = empty_func
            ClientReportPlayerSubsystem.SendPacket = empty_func
            ClientReportPlayerSubsystem.ReportSuspiciousPlayer = empty_func
            ClientReportPlayerSubsystem.SubmitReport = empty_func
        end
        
        local SubsystemMgr = package.loaded["GameLua.GameCore.Module.Subsystem.SubsystemMgr"] or require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubsystemMgr then
            local hawkEye = SubsystemMgr:Get("DSHawkEyePatrolSubsystem")
            if hawkEye then
                hawkEye.MarkSuspiciousPlayer = empty_func
            end
        end
        
        local ReportPlayerUtils = package.loaded["GameLua.Mod.BaseMod.Common.Security.ReportPlayerUtils"] or require("GameLua.Mod.BaseMod.Common.Security.ReportPlayerUtils")
        if ReportPlayerUtils then
            ReportPlayerUtils.GetBotType = ret_zero
            ReportPlayerUtils.IsCharacterDeliverAI = ret_false
        end
        
        if _G.AvatarExceptionPlayerInst then
            _G.AvatarExceptionPlayerInst.ReportAvatarException = empty_func
        end
        
        local ClientBanLogic = package.loaded["client.slua.logic.ban.ClientBanLogic"] or require("client.slua.logic.ban.ClientBanLogic")
        if ClientBanLogic then
            ClientBanLogic.OnSyncBanInfo = empty_func
            ClientBanLogic.OnVoiceBanNotify = empty_func
        end
        
        local logic_tt_ban = package.loaded["client.slua.logic.login.logic_tt_ban"] or require("client.slua.logic.login.logic_tt_ban")
        if logic_tt_ban then
            logic_tt_ban.GetCarrierInfo = function() return '[{"mcc":"000"}]' end
            logic_tt_ban.CheckIfCanCreateRole = ret_true
        end
        
        local DataLayerSubsystem = package.loaded["GameLua.Mod.BaseMod.Common.Subsystem.DataLayerSubsystem"] or require("GameLua.Mod.BaseMod.Common.Subsystem.DataLayerSubsystem")
        if DataLayerSubsystem then
            local orig_OnSpectatorReplayChanged = DataLayerSubsystem.OnSpectatorReplayChanged
            DataLayerSubsystem.OnSpectatorReplayChanged = function(a)
                _G.IsBeingWatched = true
                if orig_OnSpectatorReplayChanged then
                    orig_OnSpectatorReplayChanged(a)
                end
            end
        end
        
        local DSActiveSubsystem = package.loaded["GameLua.Mod.PlanBT.Gameplay.Subsystem.DSActiveSubsystem"] or require("GameLua.Mod.PlanBT.Gameplay.Subsystem.DSActiveSubsystem")
        if DSActiveSubsystem then
            DSActiveSubsystem.DelayKickOutPlayer = empty_func
            DSActiveSubsystem.ActiveKickNotify = empty_func
        end
        
        local CreativeDevDebugSubsystem = package.loaded["GameLua.Mod.CreativeBase.Gameplay.Subsystem.CreativeDevDebugSubsystem"] or require("GameLua.Mod.CreativeBase.Gameplay.Subsystem.CreativeDevDebugSubsystem")
        if CreativeDevDebugSubsystem then
            CreativeDevDebugSubsystem.IsDebugPanelEnalbedCli = ret_true
        end
        
        local DSAITLogSubsystem = package.loaded["GameLua.Mod.BaseMod.DS.Security.DSAITLogSubsystem"] or require("GameLua.Mod.BaseMod.DS.Security.DSAITLogSubsystem")
        if DSAITLogSubsystem then
            DSAITLogSubsystem._UpdateTTKRecords = empty_func
            DSAITLogSubsystem._UpdateOperatingFrequency = empty_func
        end
        
        local DSFightTLogSubsystem = package.loaded["GameLua.Mod.BaseMod.DS.Security.DSFightTLogSubsystem"] or require("GameLua.Mod.BaseMod.DS.Security.DSFightTLogSubsystem")
        if DSFightTLogSubsystem then
            DSFightTLogSubsystem.GetSimpleFightData = ret_empty_table
        end
        
        local DSSecurityTLogSubsystem = package.loaded["GameLua.Mod.BaseMod.DS.Security.DSSecurityTLogSubsystem"] or require("GameLua.Mod.BaseMod.DS.Security.DSSecurityTLogSubsystem")
        if DSSecurityTLogSubsystem then
            DSSecurityTLogSubsystem._OnReportServerJumpFlow = empty_func
        end
        
        local DSCommonTLogSubsystem = package.loaded["GameLua.Mod.BaseMod.DS.Security.DSCommonTLogSubsystem"] or require("GameLua.Mod.BaseMod.DS.Security.DSCommonTLogSubsystem")
        if DSCommonTLogSubsystem then
            DSCommonTLogSubsystem.HandleKillTlog = empty_func
        end
        
        local DSReportPlayerSubsystem = package.loaded["GameLua.Mod.BaseMod.DS.Security.DSReportPlayerSubsystem"] or require("GameLua.Mod.BaseMod.DS.Security.DSReportPlayerSubsystem")
        if DSReportPlayerSubsystem then
            DSReportPlayerSubsystem._AddEnemyMapToBattleResult = empty_func
        end
        
        if _G.ClientReplayDataReporter then
            _G.ClientReplayDataReporter.ReportIntArrayData = empty_func
            _G.ClientReplayDataReporter.ReportFloatArrayData = empty_func
        end
        
        local HighlightMomentSubsystem_DSChecker = package.loaded["GameLua.Mod.BaseMod.DS.Security.HighlightMomentSubsystem_DSChecker"] or require("GameLua.Mod.BaseMod.DS.Security.HighlightMomentSubsystem_DSChecker")
        if HighlightMomentSubsystem_DSChecker then
            HighlightMomentSubsystem_DSChecker.CheckFuncUpgradedWeaponKill = empty_func
        end
        
        local ICTLogSubsystem = package.loaded["GameLua.Mod.BaseMod.DS.Security.ICTLogSubsystem"] or require("GameLua.Mod.BaseMod.DS.Security.ICTLogSubsystem")
        if ICTLogSubsystem then
            ICTLogSubsystem.SendICExceptionTLog = empty_func
        end
        
        local InspectionSystemReportClientLogicSubsystem = package.loaded["GameLua.Mod.BaseMod.Client.Security.InspectionSystemReportClientLogicSubsystem"] or require("GameLua.Mod.BaseMod.Client.Security.InspectionSystemReportClientLogicSubsystem")
        if InspectionSystemReportClientLogicSubsystem then
            InspectionSystemReportClientLogicSubsystem.AskForInspector = empty_func
            InspectionSystemReportClientLogicSubsystem.ReportEnemy = empty_func
            InspectionSystemReportClientLogicSubsystem.KickOutOneTeam = empty_func
        end
        
        local InspectionSystemReportDSLogicSubsystem = package.loaded["GameLua.Mod.BaseMod.DS.Security.InspectionSystemReportDSLogicSubsystem"] or require("GameLua.Mod.BaseMod.DS.Security.InspectionSystemReportDSLogicSubsystem")
        if InspectionSystemReportDSLogicSubsystem then
            InspectionSystemReportDSLogicSubsystem.ServerKickOutOneTeamByPlayerImplementation = empty_func
            InspectionSystemReportDSLogicSubsystem.AddReportedCount = empty_func
        end
        
        local SpectateAndReplaySubsystem = package.loaded["GameLua.Mod.BaseMod.Common.Subsystem.SpectateAndReplaySubsystem"] or require("GameLua.Mod.BaseMod.Common.Subsystem.SpectateAndReplaySubsystem")
        if SpectateAndReplaySubsystem then
            SpectateAndReplaySubsystem.RequestGotoSpectatingImp = empty_func
            SpectateAndReplaySubsystem.RequestGotoSpectating = empty_func
        end
        
        local ClientHawkEyePatrolSubsystem = package.loaded["GameLua.Mod.BaseMod.Client.Security.ClientHawkEyePatrolSubsystem"] or require("GameLua.Mod.BaseMod.Client.Security.ClientHawkEyePatrolSubsystem")
        if ClientHawkEyePatrolSubsystem then
            ClientHawkEyePatrolSubsystem._OnHawkSync = empty_func
            ClientHawkEyePatrolSubsystem._OnHawkReportSuccess = empty_func
            ClientHawkEyePatrolSubsystem._StartExitGameTimer = empty_func
        end
        
        local BehaviorScoreSubsystem = package.loaded["GameLua.Mod.Escape.Gameplay.Subsystem.BehaviorScoreSubsystem"] or require("GameLua.Mod.Escape.Gameplay.Subsystem.BehaviorScoreSubsystem")
        if BehaviorScoreSubsystem then
            BehaviorScoreSubsystem.OnHandleBehaviorScore = empty_func
            BehaviorScoreSubsystem.AIPerceptionScore = empty_func
        end
        
        local ClientDataStatistcsSubsystem = package.loaded["GameLua.Mod.BaseMod.Client.Security.ClientDataStatistcsSubsystem"] or require("GameLua.Mod.BaseMod.Client.Security.ClientDataStatistcsSubsystem")
        if ClientDataStatistcsSubsystem then
            ClientDataStatistcsSubsystem.StartToCheck = empty_func
        end
        
        local AIReplaySubsystem = package.loaded["GameLua.ExtraModule.MLAI.Client.AIReplaySubsystem"] or require("GameLua.ExtraModule.MLAI.Client.AIReplaySubsystem")
        if AIReplaySubsystem then
            AIReplaySubsystem.ReportAllPlayerInfo = empty_func
            if AIReplaySubsystem.uCompletePlayBack then
                AIReplaySubsystem.uCompletePlayBack.AddRecordMLAIInfo = empty_func
            end
        end
        
        local AITrackingLogSubsystem = package.loaded["GameLua.Mod.BaseMod.GamePlay.AI.AITrackingLogSubsystem"] or require("GameLua.Mod.BaseMod.GamePlay.AI.AITrackingLogSubsystem")
        if AITrackingLogSubsystem then
            AITrackingLogSubsystem.RealLogoutTimer = empty_func
            AITrackingLogSubsystem.LogQueue = {}
        end
        
        local AFKReportorSubsystem = package.loaded["GameLua.Mod.BaseMod.DS.Security.AFKReportorSubsystem"] or require("GameLua.Mod.BaseMod.DS.Security.AFKReportorSubsystem")
        if AFKReportorSubsystem then
            AFKReportorSubsystem.HandleEnterFighting = empty_func
            AFKReportorSubsystem.InitializePlayerInputInfo = empty_func
        end
        
        local TDMAFKReportorSubsystem = package.loaded["GameLua.Mod.TDM.Gameplay.Subsystem.TDMAFKReportorSubsystem"] or require("GameLua.Mod.TDM.Gameplay.Subsystem.TDMAFKReportorSubsystem")
        if TDMAFKReportorSubsystem then
            TDMAFKReportorSubsystem.SendAFKTips = empty_func
            TDMAFKReportorSubsystem.OnHandleLostConnection = empty_func
        end
        
        local TLogSubsystem = package.loaded["GameLua.Mod.Borderland.Gameplay.Subsystem.TLogSubsystem"] or require("GameLua.Mod.Borderland.Gameplay.Subsystem.TLogSubsystem")
        if TLogSubsystem then
            TLogSubsystem.OnInit = empty_func
        end
        
        if _G.TLogSubsystem then
            _G.TLogSubsystem.OnInit = empty_func
        end
    end)
end
HookSubsystems()

local function ABC(msg)
    pcall(function()
        local success, loc_util = pcall(require, "common.loc_util")
        if success and loc_util and loc_util.ShowNotice then
            loc_util.ShowNotice("通知: " .. tostring(msg))
        end
        local success2, InGameTipsTools = pcall(require, "GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
        if success2 and InGameTipsTools and InGameTipsTools.BattleNormalTips then
            InGameTipsTools.BattleNormalTips("通知: " .. tostring(msg), 2, 3)
        end
    end)
end
