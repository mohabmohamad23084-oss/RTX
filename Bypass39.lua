--LuaCodeHub
local BYPASS = {}
_G.LuaCodeHub_BYPASS = BYPASS
local function NOP() return true end
local function RT()  return true end
local function RF()  return false end
local function R0()  return 0 end
local function RE()  return {} end
local function RES() return "" end

local function valid(o)
    if not o then return false end
    if slua and slua.isValid then
        local ok, v = pcall(slua.isValid, o)
        return ok and v
    end
    return o ~= nil
end

local function mute(obj)
    if type(obj) ~= "table" then return end
    for k, v in pairs(obj) do
        if type(v) == "function" and type(k) == "string" and
            (k:find("Report") or k:find("Send") or k:find("Upload") or
             k:find("Verify") or k:find("Check") or k:find("Validate") or
             k:find("Scan") or k:find("Detect") or k:find("Collect") or
             k:find("Flow") or k:find("Heartbeat") or k:find("Record") or
             k:find("Trace") or k:find("Replay") or k:find("Save")) then
            pcall(function() obj[k] = NOP end)
        end
    end
end

local BLOCKED_PACKETS = {
    ["ReportPlayer"]=1,["ReportPlayerBehavior"]=1,["ReportSuspicious"]=1,
    ["ReportCheat"]=1,["ReportHack"]=1,["ReportAim"]=1,["ReportESP"]=1,
    ["ReportSpeed"]=1,["ReportWall"]=1,["ReportTeammate"]=1,["ReportVoice"]=1,
    ["ReportBadWord"]=1,["ReportToxic"]=1,["ReportAFK"]=1,["ReportTeamKill"]=1,
    ["ReportUnsporting"]=1,["ReportFeedback"]=1,["ReportPlayerName"]=1,
    ["ReportBug"]=1,["ReportAutoAim"]=1,["ReportWallHack"]=1,["ReportSpeedHack"]=1,
    ["ReportAimFlow"]=1,["ReportHitFlow"]=1,["ReportAttackFlow"]=1,
    ["ReportSecAttackFlow"]=1,["ReportFireArms"]=1,["ReportVerifyInfoFlow"]=1,
    ["ReportMrpcsFlow"]=1,["ReportSecMrpcsFlow"]=1,["ReportPlayerMoveRoute"]=1,
    ["ReportPlayerPosition"]=1,["ReportVehicleMoveFlow"]=1,
    ["ReportSecTgameMovingFlow"]=1,["ReportParachuteData"]=1,
    ["ReportEquipmentFlow"]=1,["ReportCircleFlow"]=1,["ReportPlayersPing"]=1,
    ["ReportPlayerIP"]=1,["ReportPlayerFramePingRecord"]=1,
    ["ReportDSNetSaturation"]=1,["ReportNetContinuousSaturate"]=1,
    ["ReportDSNetRate"]=1,["ReportTeammatHurt"]=1,["ReportMisKillByTeammate"]=1,
    ["ReportForbitPick"]=1,["report_parachute_data"]=1,
    ["ReportCheatDetection"]=1,["ReportViolation"]=1,["ReportSecurityViolation"]=1,
    ["ReportIntegrityFailure"]=1,["ReportModdedFiles"]=1,["ReportSignatureFail"]=1,
    ["AntiCheatReport"]=1,["CheatDetection"]=1,["ViolationReport"]=1,
    ["SecurityViolation"]=1,["IntegrityCheck"]=1,["SignatureVerify"]=1,
    ["tss_sdk_report"]=1,["tss_sdk_ban"]=1,["tss_sdk_kick"]=1,
    ["on_tss_sdk_anti_data"]=1,["TssSdkReport"]=1,["TssSdkBan"]=1,["TssSdkKick"]=1,
    ["CoronaLabReport"]=1,["CoronaLabData"]=1,["RPC_ClientCoronaLab"]=1,
    ["OperationalStats"]=1,["ReportOperationalStats"]=1,["OperationalStatsReport"]=1,
    ["SwiftHawk"]=1,["ClientSwiftHawk"]=1,["ClientSwiftHawkWithParams"]=1,
    ["SwiftHawkReport"]=1,["SwiftHawkData"]=1,
    ["ClientSecMrpcsFlow"]=1,["MrpcsData"]=1,
    ["BanPlayer"]=1,["KickPlayer"]=1,["on_ban_notice"]=1,["on_kick_notice"]=1,
    ["detect_cheat"]=1,["ban_player"]=1,["kick_player"]=1,
    ["report_player"]=1,["report_cheat"]=1,["report_hack"]=1,["report_esp"]=1,
    ["report_aim_bot"]=1,["report_speed_hack"]=1,["report_wall_hack"]=1,
    ["report_modded_files"]=1,["report_memory_exception"]=1,
    ["report_avatar_exception"]=1,["report_script_exception"]=1,
    ["report_lua_violation"]=1,["report_pak_modified"]=1,
    ["report_signature_fail"]=1,["report_integrity_fail"]=1,
    ["report_unrealnet_exception"]=1,["client_anti_cheat_report"]=1,
    ["report_players_ping"]=1,["report_player_ip"]=1,["report_net_saturate"]=1,
    ["ESPDetection"]=1,["ReportESP"]=1,["WallhackReport"]=1,["RenderAnomaly"]=1,
    ["MarkDetection"]=1,["ScreenMarkReport"]=1,["ClientESPReport"]=1,
    ["ESPUsage"]=1,["VisualAnomaly"]=1,["report_wallhack"]=1,["report_render"]=1,
    ["report_screen_mark"]=1,["report_visual_anomaly"]=1,["esp_detection"]=1,
    ["wallhack_detection"]=1,["render_check"]=1,
}

local BLOCKED_RPC = {
    "RPC_Server_ReportPlayer","RPC_Server_ReportCheat",
    "RPC_Server_ReportSuspicious","RPC_Server_ReportBehavior",
    "RPC_Server_ReportAim","RPC_Server_ReportESP",
    "RPC_Server_SwiftHawk","RPC_Server_ClientSwiftHawkWithParams",
    "RPC_Server_ClientSecMrpcsFlow",
    "RPC_Server_ReportSimulateCharacterLocation",
    "RPC_Client_ShootVertifyRes","RPC_ClientCoronaLab",
    "RPC_OperationalStats","RPC_Server_Ban","RPC_Server_Kick",
}

local KILL_SUBSYSTEMS = {
    "AFKReportorSubsystem","ClientDataStatistcsSubsystem","AvatarExceptionSubsystem",
    "ShootVerifySubSystemClient","MemoryCheckSubsystem","SpeedCheckSubsystem",
    "WallCheckSubsystem","FileCheckSubsystem","BehaviorScoreSubsystem",
    "CoronaLabSubsystem","PlayerSecurityInfoSubsystem","ClientCircleFlowSubsystem",
    "ModifierExceptionSubsystem","SimulateCharacterSubsystem",
    "ClientReportPlayerSubsystem","DSReportPlayerSubsystem",
    "ClientHawkEyePatrolSubsystem","DSHawkEyePatrolSubsystem",
    "GameReportSubsystem","ReplaySubsystem","SwiftHawkSubsystem",
    "AntiCheatSubsystem","IntegrityCheckSubsystem","SignatureVerifySubsystem",
    "MD5CheckSubsystem","PakVerifySubsystem","OperationalStatsSubsystem",
    "MrpcsFlowSubsystem","CircleFlowSubsystem",
    "ClientESPDetectionSubsystem","ClientAimTrackingSubsystem",
    "ClientRenderCheckSubsystem","ClientMemoryGuardSubsystem",
    "ClientKernelCheckSubsystem","ClientWallhackDetectionSubsystem",
    "ClientAntiCheatSubsystem","ClientSecMrpcsFlowSubsystem",
}

function BYPASS.HookNetwork()
    pcall(function()
        if NetUtil and NetUtil.SendPacket and not NetUtil.SendPacket.__TX then
            local orig = NetUtil.SendPacket
            NetUtil.SendPacket = function(name, ...)
                if BLOCKED_PACKETS[name] then return nil end
                return orig(name, ...)
            end
            NetUtil.SendPacket.__TX = true
        end
    end)
    pcall(function()
        if _G.SendRPC and not _G.SendRPC.__TX then
            local orig = _G.SendRPC
            _G.SendRPC = function(rpc, ...)
                if not rpc then return orig(rpc, ...) end
                for _, b in ipairs(BLOCKED_RPC) do
                    if rpc == b then return nil end
                end
                local low = string.lower(tostring(rpc))
                if low:find("report") or low:find("ban") or low:find("kick")
                    or low:find("cheat") or low:find("hack") or low:find("violation")
                    or low:find("verify") or low:find("integrity") then
                    return nil
                end
                return orig(rpc, ...)
            end
            _G.SendRPC.__TX = true
        end
    end)
end

function BYPASS.KillHashes()
    pcall(function()
        if slua and slua.getSignature then slua.getSignature = R0 end
        local loader = package.loaded["slua.loader"] or rawget(_G, "slua_loader")
        if loader then
            loader.verifyBytecode = RT
            loader.checkIntegrity = RT
            if loader.disableSignatureCheck then loader.disableSignatureCheck = RT end
        end
        local ser = package.loaded["slua.serialize"]
        if ser then ser.check = RT; ser.verify = RT end
        if jit and jit.attach then jit.attach(function() end, "bc") end
        if _G.slua_verify then _G.slua_verify = RT end
        if _G.check_slua_integrity then _G.check_slua_integrity = RT end

        local KSL = import("KismetSystemLibrary")
        if KSL then
            KSL.ExecuteConsoleCommand(nil, "pak.DisablePakSignatureCheck 1")
            KSL.ExecuteConsoleCommand(nil, "pakchunk.EnableSignatureCheck 0")
            KSL.ExecuteConsoleCommand(nil, "s.VerifyPak 0")
            KSL.ExecuteConsoleCommand(nil, "sig.Check 0")
            KSL.ExecuteConsoleCommand(nil, "security.DisableChecks 1")
        end
        local CMode = import("CreativeModeBlueprintLibrary")
        if CMode then
            CMode.MD5HashByteArray = function() return "00000000000000000000000000000000" end
            CMode.MD5HashFile      = function() return "00000000000000000000000000000000" end
            CMode.GetContentDiffData = function() return true, "OK" end
            CMode.VerifyFileIntegrity = RT
        end
        if _G.MD5Hash then _G.MD5Hash = function() return "00000000000000000000000000000000" end end
        if _G.CRC32   then _G.CRC32   = function() return 0 end end
        if _G.SHA1    then _G.SHA1    = function() return "BYPASS" end end

        local fhc = package.loaded["common.file_hash_checker"]
        if fhc then
            fhc.CheckFileMD5 = RT; fhc.VerifyAll = RT
            fhc.GetHash = function() return "BYPASS" end
        end
        local STExtra = import("STExtraBlueprintFunctionLibrary")
        if STExtra then
            STExtra.CheckMD5 = RT
            STExtra.GetMD5 = function() return "BYPASS" end
            STExtra.VerifyFile = RT
        end
    end)
end

function BYPASS.KillTSS()
    pcall(function()
        local tss = package.loaded["TssSdk"] or _G.TssSdk
        if not tss then return end
        local origRecv = tss.OnRecvData
        tss.OnRecvData = function(data)
            if type(data) == "string" then
                local low = string.lower(data)
                if low:find("report", 1, true) or low:find("exception", 1, true) or
                   low:find("cheat", 1, true) or low:find("violation", 1, true) or
                   low:find("hack", 1, true) or low:find("verify", 1, true) then
                    return
                end
            end
            if origRecv then pcall(origRecv, data) end
        end
        tss.GetFileMD5           = function() return "00000000000000000000000000000000" end
        tss.VerifyFileSignature  = RT
        tss.SendReportInfo       = NOP
        tss.ScanMemory           = RT
        tss.IsEmulator           = RF
        tss.GetTssSdkReportInfo  = RES
        tss.CheckEnvironment     = RT
        tss.VerifyProcess        = RT
        tss.ReportBan            = NOP
        tss.ReportCheat          = NOP
        tss.BanPlayer            = NOP
        tss.KickPlayer           = NOP
    end)
end

function BYPASS.KillLogs()
    pcall(function()
        local SMTD = import("ScreenshotMTDer")
        if SMTD then
            SMTD.MTDePicture = RES
            SMTD.ReMTDePicture = RES
            SMTD.HasCaptured = RT
            SMTD.TakeScreenshot = NOP
        end
        local TLog = package.loaded["TLog"] or _G.TLog
        if TLog then
            TLog.Info, TLog.Warning, TLog.Error, TLog.Debug = NOP,NOP,NOP,NOP
            TLog.Report, TLog.Send, TLog.Flush = NOP,NOP,NOP
        end
        local CS = package.loaded["CrashSight"] or _G.CrashSight
        if CS then
            CS.ReportException = NOP; CS.SetCustomData = NOP; CS.Log = NOP
            CS.SendCrash = NOP; CS.ReportUserException = NOP
        end
        local GR = package.loaded["GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils"]
        if GR then
            GR.BugglyPostExceptionFull = RF
            GR.CheckCanBugglyPostException = RF
            GR.ReplayReportData = NOP; GR.ReportGameException = NOP; GR.PostException = NOP
        end
        local CTR = package.loaded["client.slua.logic.report.ClientToolsReport"]
        if CTR then
            CTR.SendReport = NOP; CTR.SendException = NOP; CTR.UploadLog = NOP
        end
        for _, sdk in ipairs({"Firebase","Adjust","AppsFlyer","FacebookAnalytics","GameAnalytics"}) do
            local s = _G[sdk]
            if s then
                s.logEvent = NOP; s.trackEvent = NOP
                s.setEnabled = RF; s.sendEvent = NOP; s.report = NOP
            end
        end
    end)
end

function BYPASS.KillSkinReports()
    pcall(function()
        local PT = package.loaded["client.slua.logic.download.report.puffer_tlog"]
        if PT then
            PT.ReportEvent = NOP; PT.ReportDownloadResult = NOP
            PT.ReportODPTDError = NOP; PT.ReportSkinError = NOP
        end
        local AV = package.loaded["AvatarUtils"]
        if AV then
            AV.CheckIsWeaponInBlackList = RF
            AV.IsValidAvatar = RT
            AV.CheckAvatarIntegrity = RT
            AV.ReportInvalidAvatar = NOP
        end
        local EQ = package.loaded["client.slua.logic.report.EquipmentExceptionReport"]
        if EQ then EQ.Report = NOP; EQ.SendException = NOP end
    end)
end

function BYPASS.KillSubsystems()
    pcall(function()
        local mgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if not mgr then return end
        for _, name in ipairs(KILL_SUBSYSTEMS) do
            local sub = mgr:Get(name)
            if sub then
                mute(sub)
                for _, tm in ipairs({"timer","heartbeatTimer","reportTimer","ReportPingDelayTimer"}) do
                    if sub[tm] then pcall(function() sub:RemoveGameTimer(sub[tm]) end) end
                end
                sub.bBanned = false
                sub.bKicked = false
                sub.bSuspended = false
                sub.BanCount = 0
                sub.WarningCount = 0
                sub.SuspicionScore = 0
            end
        end
    end)
    pcall(function()
        local AX = package.loaded["GameLua.Mod.Library.GamePlay.Avatar.Exception.AvatarExceptionPlayerInst"]
        if AX then
            AX.CheckAvatarException = NOP; AX.CheckAvatarExceptionOnce = NOP
            AX.ReportAvatarException = NOP
            AX.CheckSlotMeshVisible = RF; AX.CheckPawnVisible = RF
            AX.CheckCanBugglyPostException = RF
        end
    end)
    pcall(function()
        local RR = package.loaded["client.slua.logic.replay.logic_report_replay"]
        if RR then
            RR.ReportReplay = NOP; RR.SendReportReq = NOP; RR.UploadReplay = NOP
        end
    end)
end

function BYPASS.KillHiggs()
    pcall(function()
        local HBC = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if HBC then
            local methods = {
                "ControlMHActive","Tick","OnTick","MHActiveLogic","TriggerAvatarCheck",
                "StartAvatarCheck","ReportItemID","ReceiveAnyDamage","OnWeaponHitRecord",
                "ShowSecurityAlert","ServerReportAvatar","ClientReportNetAvatar",
                "SendHisarData","ValidateSecurityData","StaticShowSecurityAlertInDev",
                "DisableHiggsBoson","CheckMHActive","ReportViolation",
                "ProcessSecurityEvent","ValidatePlayer","CheckIntegrity"
            }
            for _, m in ipairs(methods) do
                if HBC[m] then HBC[m] = NOP end
            end
            HBC.GetNetAvatarItemIDs = RE
            HBC.GetCurWeaponSkinID  = R0
            HBC.IsMHActive          = RF
            HBC.bMHActive           = false
            HBC.bCallPreReplication = false
            if HBC.BlackList then
                for k in pairs(HBC.BlackList) do HBC.BlackList[k] = nil end
            end
        end
        _G.BlackList = {}

        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if valid(pc) then
            if pc.HiggsBoson then
                pc.HiggsBoson.bMHActive = false
                pc.HiggsBoson.bCallPreReplication = false
                if pc.HiggsBoson.ControlMHActive then
                    pcall(function() pc.HiggsBoson:ControlMHActive(0) end)
                end
            end
            if pc.HiggsBosonComponent then
                pc.HiggsBosonComponent.bMHActive = false
                pc.HiggsBosonComponent.bCallPreReplication = false
                pcall(function() pc.HiggsBosonComponent:ControlMHActive(0) end)
            end
        end

        if _G.AvatarCheckCallback then
            _G.AvatarCheckCallback.StartAvatarCheck = NOP
            _G.AvatarCheckCallback.OnReportItemID = NOP
            _G.AvatarCheckCallback.PostPlayerControllerLoginInit = function(pc2)
                if valid(pc2) then
                    if pc2.HiggsBosonComponent then
                        pcall(function() pc2.HiggsBosonComponent:ControlMHActive(0) end)
                        pc2.HiggsBosonComponent.bMHActive = false
                    end
                    if pc2.HiggsBoson then
                        pcall(function() pc2.HiggsBoson:ControlMHActive(0) end)
                        pc2.HiggsBoson.bMHActive = false
                    end
                end
            end
        end
    end)
end

local FLOW_CALLBACKS = {
    "ReportAttackFlow","ReportSecAttackFlow","ReportFireArms",
    "ReportVerifyInfoFlow","ReportMrpcsFlow","ReportPlayerBehavior",
    "ReportTeammatHurt","ReportMisKillByTeammate","ReportForbitPick",
    "ReportPlayerMoveRoute","ReportPlayerPosition","ReportVehicleMoveFlow",
    "ReportSecTgameMovingFlow","ReportParachuteData","ReportEquipmentFlow",
    "ReportAimFlow","ReportHitFlow","ReportCircleFlow","ReportPlayersPing",
    "ReportPlayerIP","ReportPlayerFramePingRecord","ReportDSNetSaturation",
    "ReportNetContinuousSaturate","ReportDSNetRate","SendTssSdkAntiDataToLobby",
    "SendClientStats","SendServerAvgTickDelta","ClientSecMrpcsFlow",
    "SwiftHawk","ClientSwiftHawk","ClientSwiftHawkWithParams",
    "ReportESP","ReportWallhack","ReportRenderAnomaly","CheckESP",
    "CheckWallhack","CheckRender","OnESPDetected","OnWallhackDetected",
    "OnRenderAnomaly","ValidateScreenMark","CheckScreenMark","ReportScreenMark",
    "BanPlayer","BanUser","ReportBan","SendBanReport","DetectBan","CheckBan",
    "ValidateBan","ProcessBan","BanKick","KickPlayer","ForceLogout",
    "DisconnectPlayer","ReportSuspicious","ReportCheat","ReportHack",
    "OnCheatDetected","OnHackDetected","OnViolationDetected","AntiCheatReport",
    "CheatDetection","ViolationReport","SecurityViolation","IntegrityCheck",
    "SignatureVerify","TssSdkReport","TssSdkBan","TssSdkKick",
}

function BYPASS.KillGameplayCallbacks()
    pcall(function()
        if not _G.GameplayCallbacks then _G.GameplayCallbacks = {} end
        local GC = _G.GameplayCallbacks
        for _, f in ipairs(FLOW_CALLBACKS) do
            GC[f] = NOP
            if _G[f] then _G[f] = NOP end
        end
        GC.CheckReportSecAttackFlowWithAttackFlow = RF
        GC.CheckReportSecAttackFlow = RF
        if _G.CheckReportSecAttackFlowWithAttackFlow then _G.CheckReportSecAttackFlowWithAttackFlow = RF end
        if _G.CheckReportSecAttackFlow then _G.CheckReportSecAttackFlow = RF end
        for _, f in ipairs({"IsEnableReportMrpcsInCircleFlow","IsEnableReportMrpcsInPartCircleFlow",
                            "IsEnableReportMrpcsFlow","IsEnableReportAttackFlow",
                            "IsEnableReportHitFlow","IsEnableReportCircleFlow"}) do
            if _G[f] then _G[f] = RF end
        end
        _G.ShowBanNotice     = NOP
        _G.ShowKickNotice    = NOP
        _G.ProcessBanNotice  = NOP
        _G.HandleBanNotice   = NOP
        _G.ShowBanUI         = NOP
        _G.ShowKickUI        = NOP

        local orig = GC.OnDSPlayerStateChanged
        GC.OnDSPlayerStateChanged = function(uid, state, bPure, bSafe, param)
            local s = state and string.lower(tostring(state)) or ""
            local danger = {
                ["cheatdetected"]=1,["connectionlost"]=1,["connectiontimeout"]=1,
                ["connectionexception"]=1,["netdrivererror"]=1,["banned"]=1,
                ["kicked"]=1,["suspended"]=1,["violationdetected"]=1,
                ["integrityfailure"]=1,["securityviolation"]=1,["reportdetected"]=1
            }
            if danger[s] then return end
            if orig then pcall(orig, uid, state, bPure, bSafe, param) end
        end
        GC.OnPlayerNetConnectionClosed = NOP
        GC.OnPlayerActorChannelError   = NOP
        GC.OnPlayerRPCValidateFailed   = NOP
        GC.OnPlayerSpectateException   = NOP
        GC.OnShutdownAfterError        = NOP
    end)
end

function BYPASS.KillBanUI()
    pcall(function()
        local banUI = {
            "client.slua.umg.BanNoticeUI",
            "client.slua.umg.KickNoticeUI",
            "GameLua.Mod.BaseMod.Client.UI.BanUI",
        }
        for _, path in ipairs(banUI) do
            local mod = package.loaded[path]
            if not mod then
                local ok, loaded = pcall(require, path)
                if ok and loaded then mod = loaded end
            end
            if mod and type(mod) == "table" then
                for k, v in pairs(mod) do
                    if type(v) == "function" and type(k) == "string" and k:find("Show") then
                        pcall(function() mod[k] = NOP end)
                    end
                end
            end
        end
    end)
end

function BYPASS.KillEnvFlags()
    pcall(function()
        for _, flag in ipairs({
            "ENABLE_REPORT","ENABLE_ANTI_CHEAT","ENABLE_SECURITY",
            "ENABLE_TELEMETRY","ENABLE_ANALYTICS","ENABLE_CRASH_REPORT",
            "ENABLE_PERFORMANCE_REPORT"
        }) do
            if _G[flag] then _G[flag] = false end
        end
    end)
end

function BYPASS.Sweep()
    local needles = {
        "verify","integrity","signature","filecheck","file_check",
        "hashcheck","hash_check","tss","security","report"
    }
    local seen = {}
    pcall(function()
        local function watch(m)
            if type(m) ~= "table" or seen[m] then return end
            seen[m] = true
            mute(m)
        end
        for key, mod in pairs(package.loaded) do
            if type(key) == "string" then
                local low = string.lower(key)
                for _, n in ipairs(needles) do
                    if string.find(low, n, 1, true) then watch(mod) break end
                end
            end
        end
        for key, mod in pairs(_G) do
            if type(key) == "string" then
                local low = string.lower(key)
                for _, n in ipairs(needles) do
                    if string.find(low, n, 1, true) then watch(mod) break end
                end
            end
        end
    end)
end

function BYPASS.AntiForensics()
    pcall(function()
        if debug and debug.getinfo then
            local orig = debug.getinfo
            debug.getinfo = function(level, what)
                local info = orig(level, what)
                if info and info.source then
                    local src = info.source
                    if string.find(src, "BRPlayerCharacterBase", 1, true)
                        or string.find(src, "AegisShell", 1, true)
                        or string.find(src, "TOXIC", 1, true) then
                        info.source = "ProtectedSource"
                        info.short_src = "ProtectedSource"
                    end
                end
                return info
            end
        end
        if debug then
            if debug.sethook   then debug.sethook   = function() end end
            if debug.getlocal  then debug.getlocal  = function() end end
            if debug.setupvalue then debug.setupvalue = function() end end
        end
        if string and string.dump then
            string.dump = function() return "" end
        end
    end)
end

function BYPASS.Hum()
    _G.TX_HB   = math.random(15, 45)
    _G.TX_JIT  = math.random(-12, 18)
    _G.TX_KD   = 0.9 + math.random() * 1.9
    _G.TX_HD   = 9 + math.random() * 22
end

function BYPASS.ApplyAll()
    BYPASS.HookNetwork()
    BYPASS.KillHashes()
    BYPASS.KillTSS()
    BYPASS.KillLogs()
    BYPASS.KillSkinReports()
    BYPASS.KillSubsystems()
    BYPASS.KillHiggs()
    BYPASS.KillGameplayCallbacks()
    BYPASS.KillBanUI()
    BYPASS.KillEnvFlags()
    BYPASS.Sweep()
    BYPASS.AntiForensics()
    BYPASS.Hum()
end

_G.LicenseValid = true
_G.ModsEnabled  = true
_G.CompleteBypassStarted = true

pcall(function()
    BYPASS.ApplyAll()
end)

pcall(function()
    local ticker = require("common.time_ticker")
    if not ticker then return end

    local function loop()
        pcall(function()
            if NetUtil and NetUtil.SendPacket and not NetUtil.SendPacket.__TX then
                BYPASS.HookNetwork()
            end
            if _G.SendRPC and not _G.SendRPC.__TX then
                BYPASS.HookNetwork()
            end
            local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
            if valid(pc) then
                if pc.HiggsBoson then
                    pc.HiggsBoson.bMHActive = false
                    pc.HiggsBoson.bCallPreReplication = false
                end
                if pc.HiggsBosonComponent then
                    pc.HiggsBosonComponent.bMHActive = false
                    pc.HiggsBosonComponent.bCallPreReplication = false
                end
            end
            BYPASS.KillSubsystems()
            BYPASS.KillGameplayCallbacks()
        end)
    end

    if ticker.AddTimerOnce then ticker.AddTimerOnce(3.0, loop) end
    if ticker.AddTimerLoop then ticker.AddTimerLoop(0, loop, -1, 5.0) end
end)

pcall(function()
    if EventSystem and EventSystem.registEvent then
        if EVENTTYPE_LOBBY and EVENTID_ENTER_GAME_BEGIN then
            EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_ENTER_GAME_BEGIN, function()
                pcall(BYPASS.ApplyAll)
            end)
        end
    end
end)

_G.StartBypass_Complete  = BYPASS.ApplyAll
_G.LuaCodeHub_BYPASS_Apply    = BYPASS.ApplyAll
_G.LuaCodeHub_BYPASS_Status   = function()
    return {
        network = NetUtil and NetUtil.SendPacket and NetUtil.SendPacket.__TX == true or false,
        rpc     = _G.SendRPC and _G.SendRPC.__TX == true or false,
        started = _G.CompleteBypassStarted == true,
    }
end

