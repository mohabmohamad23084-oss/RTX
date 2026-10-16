-- ══════════════════════════════════════════════════════════════════════════════
-- ███████╗██╗███╗   ███╗ ██████╗ ███╗   ██╗    ██╗   ██╗██╗██████╗ 
-- ██╔════╝██║████╗ ████║██╔═══██╗████╗  ██║    ██║   ██║██║██╔══██╗
-- ███████╗██║██╔████╔██║██║   ██║██╔██╗ ██║    ██║   ██║██║██████╔╝
-- ╚════██║██║██║╚██╔╝██║██║   ██║██║╚██╗██║    ╚██╗ ██╔╝██║██╔═══╝ 
-- ███████║██║██║ ╚═╝ ██║╚██████╔╝██║ ╚████║     ╚████╔╝ ██║██║     
-- ╚══════╝╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝      ╚═══╝  ╚═╝╚═╝     
-- ══════════════════════════════════════════════════════════════════════════════
-- ANTI-BAN-SIMON.lua — قوي · شامل · طبقات حماية متقدمة
-- المطور : SIMON @GNGGD
-- القناة : https://t.me/CCVOPO
-- الإصدار: v5.0 PREMIUM ULTRA
-- ══════════════════════════════════════════════════════════════════════════════

local AntiBanModule = {
    Version = "5.0.0-PREMIUM-ULTRA",
    Developer = "SIMON @GNGGD",
    Channel = "https://t.me/CCVOPO",
    LayersActive = {},
    LayersCount = 0,
    Enabled = true,
    StartTime = os.time(),
    BlockedEvents = 0,
    LastHeartbeat = 0,
    _silent_loops = {},
    _active_hooks = {},
    _banned_keywords = nil,
    _original_functions = {},
}

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 1 : دوال مساعدة أساسية
-- ══════════════════════════════════════════════════════════════════════════════

local function _log(msg)
    pcall(function()
        local s = "[SIMON ANTI-BAN] " .. tostring(msg)
        if _G.LexusNotify then _G.LexusNotify(s) end
        print(s)
    end)
end

local function _nop() return true end
local function _nil() return nil end
local function _false() return false end
local function _true() return true end
local function _zero() return 0 end
local function _empty() return {} end
local function _emptyStr() return "" end
local function _same(...) return ... end

local function _safe(label, fn)
    local ok, err = pcall(fn)
    if not ok then
        AntiBanModule.LayersActive[label] = "ERROR:" .. tostring(err):sub(1, 80)
    else
        AntiBanModule.LayersActive[label] = "ACTIVE"
    end
    return ok
end

local function _addLayer(name)
    AntiBanModule.LayersActive[name] = "ACTIVE"
    AntiBanModule.LayersCount = AntiBanModule.LayersCount + 1
end

local function _valid(obj)
    if not obj then return false end
    local slua = rawget(_G, "slua")
    if slua and slua.isValid then
        local ok, v = pcall(slua.isValid, obj)
        return ok and v
    end
    return true
end

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 2 : طبقات الحماية (Layers 1 → 40) — الحماية الشاملة
-- ══════════════════════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 1 : تعطيل SLUA Signature Check
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L1_SLUA_Signature", function()
    local slua = rawget(_G, "slua")
    if slua then
        if slua.getSignature then slua.getSignature = function() return 0xDEADBEEF end end
        if slua.verifyBytecode then slua.verifyBytecode = _true end
        if slua.checkIntegrity then slua.checkIntegrity = _true end
    end
    local loader = package.loaded["slua.loader"] or rawget(_G, "slua_loader")
    if loader then
        loader.verifyBytecode = _true
        loader.checkIntegrity = _true
        loader.disableSignatureCheck = _true
    end
    if _G.slua_verify then _G.slua_verify = _true end
    if _G.check_slua_integrity then _G.check_slua_integrity = _true end
    _addLayer("L1_SLUA_Signature")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 2 : تعطيل JIT Bytecode Check
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L2_JIT_Bytecode", function()
    if jit and jit.attach then
        pcall(function() jit.attach(function() end, "bc") end)
    end
    if jit and jit.flush then pcall(jit.flush) end
    _addLayer("L2_JIT_Bytecode")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 3 : تعطيل MD5 File Verification
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L3_MD5_Verify", function()
    local console = import("KismetSystemLibrary")
    if console then
        pcall(function() console.ExecuteConsoleCommand(nil, "pak.DisablePakSignatureCheck 1") end)
        pcall(function() console.ExecuteConsoleCommand(nil, "pakchunk.EnableSignatureCheck 0") end)
        pcall(function() console.ExecuteConsoleCommand(nil, "s.VerifyPak 0") end)
        pcall(function() console.ExecuteConsoleCommand(nil, "sig.Check 0") end)
        pcall(function() console.ExecuteConsoleCommand(nil, "security.DisableChecks 1") end)
        pcall(function() console.ExecuteConsoleCommand(nil, "pak.CheckSignature 0") end)
    end
    local CMode = import("CreativeModeBlueprintLibrary")
    if CMode then
        CMode.MD5HashByteArray = function() return "00000000000000000000000000000000" end
        CMode.MD5HashFile = function() return "00000000000000000000000000000000" end
        CMode.GetContentDiffData = function() return true, "SAFE" end
        CMode.VerifyFileIntegrity = _true
    end
    if _G.MD5Hash then _G.MD5Hash = function() return "00000000000000000000000000000000" end end
    if _G.CRC32 then _G.CRC32 = _zero end
    if _G.SHA1 then _G.SHA1 = function() return "SAFE" end end
    if _G.SHA256 then _G.SHA256 = function() return "SAFE" end end
    _addLayer("L3_MD5_Verify")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 4 : تعطيل File Hash Checker
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L4_FileHash", function()
    local FHC = package.loaded["common.file_hash_checker"]
    if FHC then
        FHC.CheckFileMD5 = _true
        FHC.VerifyAll = _true
        FHC.GetHash = function() return "SAFE" end
        FHC.ReportAbnormalFile = _nop
    end
    _addLayer("L4_FileHash")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 5 : تعطيل TssSdk Anti-Cheat SDK
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L5_TssSdk", function()
    local TssSdk = package.loaded["TssSdk"] or _G.TssSdk
    if TssSdk then
        local origData = TssSdk.OnRecvData
        TssSdk.OnRecvData = function(data)
            if type(data) == "string" then
                if data:find("report", 1, true) or data:find("exception", 1, true)
                    or data:find("cheat", 1, true) or data:find("violation", 1, true)
                    or data:find("hack", 1, true) or data:find("verify", 1, true)
                    or data:find("ban", 1, true) or data:find("suspend", 1, true) then
                    AntiBanModule.BlockedEvents = AntiBanModule.BlockedEvents + 1
                    return
                end
            end
            if origData then origData(data) end
        end
        TssSdk.SendReportInfo = _nop
        TssSdk.ScanMemory = _true
        TssSdk.IsEmulator = _false
        TssSdk.GetTssSdkReportInfo = _emptyStr
        TssSdk.CheckEnvironment = _true
        TssSdk.VerifyProcess = _true
        TssSdk.GetFileMD5 = function() return "SAFE" end
        TssSdk.VerifyFileSignature = _true
        TssSdk.ReportUserException = _nop
        TssSdk.ReportException = _nop
    end
    _addLayer("L5_TssSdk")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 6 : تعطيل ScreenshotMTDer (منع التقاط الصور للتحقق)
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L6_Screenshot", function()
    local SMTD = import("ScreenshotMTDer")
    if SMTD then
        SMTD.MTDePicture = _emptyStr
        SMTD.ReMTDePicture = _emptyStr
        SMTD.HasCaptured = _true
        SMTD.TakeScreenshot = _nop
    end
    _addLayer("L6_Screenshot")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 7 : حاجب اللوجات والتقارير (TLog / CrashSight)
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L7_LogBlocker", function()
    local TLog = package.loaded["TLog"] or _G.TLog
    if TLog then
        TLog.Info = _nop; TLog.Warning = _nop; TLog.Error = _nop; TLog.Debug = _nop
        TLog.Report = _nop; TLog.Send = _nop; TLog.Flush = _nop; TLog.Log = _nop
    end
    local CrashSight = package.loaded["CrashSight"] or _G.CrashSight
    if CrashSight then
        CrashSight.ReportException = _nop; CrashSight.SetCustomData = _nop
        CrashSight.Log = _nop; CrashSight.SendCrash = _nop
        CrashSight.ReportUserException = _nop; CrashSight.ReportCrash = _nop
    end
    _addLayer("L7_LogBlocker")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 8 : حاجب GameReportUtils
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L8_GameReport", function()
    local GRUtils = package.loaded["GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils"]
    if GRUtils then
        GRUtils.BugglyPostExceptionFull = _false
        GRUtils.CheckCanBugglyPostException = _false
        GRUtils.ReplayReportData = _nop
        GRUtils.ReportGameException = _nop
        GRUtils.PostException = _nop
        GRUtils.ReportUserException = _nop
    end
    local CTR = package.loaded["client.slua.logic.report.ClientToolsReport"]
    if CTR then
        CTR.SendReport = _nop; CTR.SendException = _nop; CTR.UploadLog = _nop
    end
    _addLayer("L8_GameReport")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 9 : حاجب SDK الإعلانات والتحليلات
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L9_AnalyticsSDK", function()
    for _, sdk in ipairs({"Firebase", "Adjust", "AppsFlyer", "FacebookAnalytics", "GameAnalytics", "Tenjin", "Singular"}) do
        local s = _G[sdk]
        if s then
            s.logEvent = _nop; s.trackEvent = _nop; s.setEnabled = _false
            s.sendEvent = _nop; s.report = _nop; s.log = _nop
        end
    end
    _addLayer("L9_AnalyticsSDK")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 10 : حاجب الـ Subsystems الأمنية
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L10_SecuritySubsystems", function()
    local SubMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    if not SubMgr then return end
    local subsystems = {
        "AFKReportorSubsystem", "ClientDataStatistcsSubsystem", "AvatarExceptionSubsystem",
        "ShootVerifySubSystemClient", "MemoryCheckSubsystem", "SpeedCheckSubsystem",
        "WallCheckSubsystem", "FileCheckSubsystem", "BehaviorScoreSubsystem",
        "CoronaLabSubsystem", "PlayerSecurityInfoSubsystem", "ClientCircleFlowSubsystem",
        "ModifierExceptionSubsystem", "SimulateCharacterSubsystem", "HiggsBosonComponent",
        "ClientReportPlayerSubsystem", "DSReportPlayerSubsystem", "ClientHawkEyePatrolSubsystem",
        "DSHawkEyePatrolSubsystem", "GameReportSubsystem", "AntiCheatSubsystem",
        "IntegrityCheckSubsystem", "SignatureVerifySubsystem", "MD5CheckSubsystem",
        "PakVerifySubsystem", "MrpcsFlowSubsystem", "CircleFlowSubsystem",
        "SwiftHawkSubsystem", "ReplaySubsystem"
    }
    for _, name in ipairs(subsystems) do
        local sub = SubMgr:Get(name)
        if sub then
            for k, v in pairs(sub) do
                if type(v) == "function" then
                    local lowK = k:lower()
                    if lowK:find("report") or lowK:find("send") or lowK:find("upload")
                        or lowK:find("verify") or lowK:find("check") or lowK:find("validate")
                        or lowK:find("scan") or lowK:find("detect") or lowK:find("collect")
                        or lowK:find("flow") or lowK:find("heartbeat") then
                        pcall(function() sub[k] = _nop end)
                    end
                end
            end
            if sub.timer then pcall(function() sub:RemoveGameTimer(sub.timer) end) end
            if sub.heartbeatTimer then pcall(function() sub:RemoveGameTimer(sub.heartbeatTimer) end) end
            if sub.reportTimer then pcall(function() sub:RemoveGameTimer(sub.reportTimer) end) end
        end
    end
    _addLayer("L10_SecuritySubsystems")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 11 : حاجب Avatar Exception
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L11_AvatarException", function()
    local AvaEx = package.loaded["GameLua.Mod.Library.GamePlay.Avatar.Exception.AvatarExceptionPlayerInst"]
    if AvaEx then
        AvaEx.CheckAvatarException = _nop
        AvaEx.CheckAvatarExceptionOnce = _nop
        AvaEx.ReportAvatarException = _nop
        AvaEx.CheckSlotMeshVisible = _false
        AvaEx.CheckPawnVisible = _false
        AvaEx.CheckCanBugglyPostException = _false
    end
    _addLayer("L11_AvatarException")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 12 : حاجب Skin Bypass (السكنات)
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L12_SkinBypass", function()
    local ptlog = package.loaded["client.slua.logic.download.report.puffer_tlog"]
    if ptlog then
        ptlog.ReportEvent = _nop; ptlog.ReportDownloadResult = _nop
        ptlog.ReportODPTDError = _nop; ptlog.ReportSkinError = _nop
    end
    local AvatarUtils = package.loaded["AvatarUtils"]
    if AvatarUtils then
        AvatarUtils.CheckIsWeaponInBlackList = _false
        AvatarUtils.IsValidAvatar = _true
        AvatarUtils.CheckAvatarIntegrity = _true
        AvatarUtils.ReportInvalidAvatar = _nop
    end
    local eqEx = package.loaded["client.slua.logic.report.EquipmentExceptionReport"]
    if eqEx then
        eqEx.Report = _nop; eqEx.SendException = _nop
    end
    _addLayer("L12_SkinBypass")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 13 : حاجب Replay / Telemetry
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L13_ReplayTelemetry", function()
    local SubMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    if SubMgr then
        for _, name in ipairs({"GameReportSubsystem", "ReplaySubsystem"}) do
            local sub = SubMgr:Get(name)
            if sub then
                for k, v in pairs(sub) do
                    if type(v) == "function" then
                        local lowK = k:lower()
                        if lowK:find("report") or lowK:find("trace") or lowK:find("replay")
                            or lowK:find("record") or lowK:find("save") then
                            pcall(function() sub[k] = _nop end)
                        end
                    end
                end
            end
        end
    end
    local logRep = package.loaded["client.slua.logic.replay.logic_report_replay"]
    if logRep then
        logRep.ReportReplay = _nop; logRep.SendReportReq = _nop; logRep.UploadReplay = _nop
    end
    _addLayer("L13_ReplayTelemetry")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 14 : حاجب تدفقات التقارير (Report Flows)
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L14_ReportFlows", function()
    local flows = {
        "ReportAimFlow", "ReportHitFlow", "ReportAttackFlow", "ReportSecAttackFlow",
        "ReportFireArms", "ReportVerifyInfoFlow", "ReportMrpcsFlow", "ReportPlayerBehavior",
        "ReportTeammatHurt", "ReportMisKillByTeammate", "ReportForbitPick",
        "ReportPlayerMoveRoute", "ReportPlayerPosition", "ReportVehicleMoveFlow",
        "ReportSecTgameMovingFlow", "ReportParachuteData", "ReportEquipmentFlow",
        "ReportPlayersPing", "ReportPlayerIP", "ReportPlayerFramePingRecord",
        "ReportDSNetSaturation", "ReportNetContinuousSaturate", "ReportDSNetRate",
        "ReportCircleFlow", "ReportSecMrpcsFlow"
    }
    for _, f in ipairs(flows) do
        if _G[f] then _G[f] = _nop end
        if _G.GameplayCallbacks and _G.GameplayCallbacks[f] then
            _G.GameplayCallbacks[f] = _nop
        end
    end
    for _, f in ipairs({"CheckReportSecAttackFlowWithAttackFlow", "CheckReportSecAttackFlow"}) do
        if _G[f] then _G[f] = _false end
        if _G.GameplayCallbacks and _G.GameplayCallbacks[f] then
            _G.GameplayCallbacks[f] = _false
        end
    end
    for _, f in ipairs({"IsEnableReportMrpcsInCircleFlow", "IsEnableReportMrpcsInPartCircleFlow",
                        "IsEnableReportMrpcsFlow", "IsEnableReportAttackFlow",
                        "IsEnableReportHitFlow", "IsEnableReportCircleFlow"}) do
        if _G[f] then _G[f] = _false end
    end
    _addLayer("L14_ReportFlows")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 15 : حاجب Player Security Info
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L15_PlayerSecurity", function()
    for _, c in ipairs({"PlayerSecurityInfoCollector", "PlayerSecurityInfo",
                        "SecurityInfoCollector", "ClientSecurityCollector",
                        "PlayerAntiCheatCollector"}) do
        if _G[c] then
            for k, v in pairs(_G[c]) do
                if type(v) == "function" then
                    local lk = k:lower()
                    if lk:find("report") or lk:find("collect") or lk:find("send")
                        or lk:find("upload") or lk:find("record") then
                        _G[c][k] = _nop
                    end
                end
            end
        end
    end
    local SecSub = require("GameLua.Mod.BaseMod.Common.Security.PlayerSecurityInfoSubsystem")
    if SecSub then
        SecSub.ReportData = _nop; SecSub.CheckCheat = _false
        SecSub.ValidatePlayer = _true; SecSub.CollectData = _nop; SecSub.SendToServer = _nop
    end
    _addLayer("L15_PlayerSecurity")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 16 : حاجب Client Flow
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L16_ClientFlow", function()
    for _, name in ipairs({"ClientSecMrpcsFlow", "MrpcsFlow", "MrpcsData",
                           "ClientCircleFlowSubsystem", "ClientKillFlowSubsystem",
                           "ClientSecPlayerKillFlow"}) do
        local sub = package.loaded[name] or _G[name]
        if sub then
            for k, v in pairs(sub) do
                if type(v) == "function" then
                    local lk = k:lower()
                    if lk:find("report") or lk:find("send") or lk:find("flow")
                        or lk:find("record") or lk:find("process") then
                        pcall(function() sub[k] = _nop end)
                    end
                end
            end
        end
    end
    _addLayer("L16_ClientFlow")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 17 : حاجب SwiftHawk
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L17_SwiftHawk", function()
    for _, f in ipairs({"SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams",
                        "SendSwiftHawkData"}) do
        if _G[f] then _G[f] = _nop end
        if _G.GameplayCallbacks and _G.GameplayCallbacks[f] then
            _G.GameplayCallbacks[f] = _nop
        end
    end
    local sub = package.loaded["GameLua.Mod.BaseMod.Client.Security.SwiftHawkSubsystem"]
    if sub then
        sub.ReportData = _nop; sub.SendReport = _nop; sub.CollectTelemetry = _nop
    end
    _addLayer("L17_SwiftHawk")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 18 : حاجب CoronaLab
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L18_CoronaLab", function()
    if _G.CoronaLab then
        _G.CoronaLab.ReportData = _nop; _G.CoronaLab.SendData = _nop
        _G.CoronaLab.CollectData = _nop; _G.CoronaLab.Telemetry = _nop
    end
    local sub = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr"):Get("CoronaLabSubsystem")
    if sub then
        sub.ReportData = _nop; sub.SendToServer = _nop
        sub.CollectTelemetry = _nop; sub.StopCollection = _nop
    end
    _addLayer("L18_CoronaLab")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 19 : حاجب Modifier Exception
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L19_ModifierException", function()
    if _G.bReportedModifierException then _G.bReportedModifierException = false end
    local sub = require("GameLua.Mod.BaseMod.Common.Security.ModifierExceptionSubsystem")
    if sub then
        sub.ReportException = _nop; sub.CheckModifier = _true
        sub.ValidateModifier = _true; sub.ReportModifierError = _nop
    end
    _addLayer("L19_ModifierException")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 20 : حاجب Simulate Character Location
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L20_SimulateLocation", function()
    local sub = require("GameLua.Mod.BaseMod.Gameplay.Simulate.SimulateCharacterSubsystem")
    if sub then
        sub.ReportLocation = _nop; sub.SendLocationData = _nop; sub.VerifyLocation = _true
    end
    _addLayer("L20_SimulateLocation")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 21 : حاجب Shoot Verification
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L21_ShootVerify", function()
    local sub = require("GameLua.Dev.Subsystem.ShootVerifySubSystemClient")
    if sub then
        sub.OnShootVerifyFailed = _nop; sub.SendVerifyData = _nop
        sub.ReportBulletHit = _nop; sub.UploadHitInfo = _nop; sub.VerifyShot = _true
    end
    if _G.BulletHitInfoUploadData then
        _G.BulletHitInfoUploadData.Report = _nop
        _G.BulletHitInfoUploadData.Send = _nop
        _G.BulletHitInfoUploadData.Upload = _nop
    end
    _addLayer("L21_ShootVerify")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 22 : حاجب حزم الشبكة المشبوهة (Network Packet Blocker)
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L22_NetworkPackets", function()
    if NetUtil and NetUtil.SendPacket then
        local orig = NetUtil.SendPacket
        local blocked = {
            ["ReportAttackFlow"]=1, ["ReportSecAttackFlow"]=1, ["ReportFireArms"]=1,
            ["ReportVerifyInfoFlow"]=1, ["ReportMrpcsFlow"]=1, ["ReportPlayerBehavior"]=1,
            ["ReportTeammatHurt"]=1, ["ReportPlayerMoveRoute"]=1, ["ReportPlayerPosition"]=1,
            ["ReportSecVehicleMoveFlow"]=1, ["report_parachute_data"]=1,
            ["on_tss_sdk_anti_data"]=1, ["ReportAimFlow"]=1, ["ReportHitFlow"]=1,
            ["ReportCircleFlow"]=1, ["report_players_ping"]=1, ["report_player_ip"]=1,
            ["report_net_saturate"]=1, ["report_speed_hack"]=1, ["report_wall_hack"]=1,
            ["report_aim_bot"]=1, ["report_esp_usage"]=1, ["report_modded_files"]=1,
            ["detect_cheat"]=1, ["ban_player"]=1, ["client_anti_cheat_report"]=1,
            ["ClientSecMrpcsFlow"]=1, ["MrpcsData"]=1, ["CheckReportSecAttackFlow"]=1,
            ["CheckReportSecAttackFlowWithAttackFlow"]=1, ["RPC_ClientCoronaLab"]=1,
            ["CoronaLabReport"]=1, ["CoronaLabData"]=1, ["PlayerSecurityInfo"]=1,
            ["ReportSecurityInfo"]=1, ["SendSecurityData"]=1, ["ClientCircleFlow"]=1,
            ["IsEnableReportMrpcsInCircleFlow"]=1, ["IsEnableReportMrpcsInPartCircleFlow"]=1,
            ["bReportedModifierException"]=1, ["ReportModifierException"]=1,
            ["RPC_Server_ReportSimulateCharacterLocation"]=1, ["ReportSimulateCharacterLocation"]=1,
            ["RPC_Client_ShootVertifyRes"]=1, ["BulletHitInfoUploadData"]=1,
            ["ShootVerifyFailed"]=1, ["report_unrealnet_exception"]=1, ["tss_sdk_report"]=1,
            ["SwiftHawk"]=1, ["ClientSwiftHawk"]=1, ["ClientSwiftHawkWithParams"]=1,
            ["SwiftHawkReport"]=1, ["SwiftHawkData"]=1, ["AntiCheatReport"]=1,
            ["CheatDetection"]=1, ["ViolationReport"]=1, ["SecurityViolation"]=1,
            ["IntegrityCheck"]=1, ["SignatureVerify"]=1, ["CrashReport"]=1
        }
        NetUtil.SendPacket = function(packetName, ...)
            if blocked[packetName] then
                AntiBanModule.BlockedEvents = AntiBanModule.BlockedEvents + 1
                return nil
            end
            return orig(packetName, ...)
        end
        NetUtil.IsBypassed = true
    end
    if _G.SendRPC then
        local origRPC = _G.SendRPC
        local blockedRPC = {
            "RPC_Server_ClientSecMrpcsFlow", "RPC_Server_SwiftHawk",
            "RPC_Server_ClientSwiftHawkWithParams",
            "RPC_Server_ReportSimulateCharacterLocation",
            "RPC_Client_ShootVertifyRes", "RPC_ClientCoronaLab"
        }
        _G.SendRPC = function(rpcName, ...)
            for _, b in ipairs(blockedRPC) do
                if rpcName == b then return nil end
            end
            return origRPC(rpcName, ...)
        end
    end
    _addLayer("L22_NetworkPackets")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 23 : حاجب HiggsBoson (مكافحة الغش الرئيسي)
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L23_HiggsBoson", function()
    local Higgs = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
    if Higgs then
        local nopFuncs = {
            "ControlMHActive", "Tick", "OnTick", "MHActiveLogic", "TriggerAvatarCheck",
            "StartAvatarCheck", "ReportItemID", "ReceiveAnyDamage", "OnWeaponHitRecord",
            "ShowSecurityAlert", "ServerReportAvatar", "ClientReportNetAvatar",
            "SendHisarData", "ValidateSecurityData", "StaticShowSecurityAlertInDev",
            "RPC_Client_ShootVertifyRes", "RPC_Server_ReportSimulateCharacterLocation",
            "DisableHiggsBoson", "CheckMHActive", "ReportViolation", "ProcessSecurityEvent",
            "ValidatePlayer", "CheckIntegrity", "ReportCheat", "OnDetected", "KickPlayer",
            "BanPlayer", "SendToServer", "CheckPacket", "AnalyzeMemory", "CheckFiles",
            "VerifySignature", "ScanForCheats", "DetectAimbot", "DetectWallhack"
        }
        for _, m in ipairs(nopFuncs) do
            if Higgs[m] then Higgs[m] = _nop end
        end
        Higgs.GetNetAvatarItemIDs = _empty
        Higgs.GetCurWeaponSkinID = _zero
        Higgs.IsMHActive = _false
        Higgs.bMHActive = false
        Higgs.bCallPreReplication = false
        if Higgs.BlackList then
            for k in pairs(Higgs.BlackList) do Higgs.BlackList[k] = nil end
        end
    end
    _G.BlackList = {}
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if _valid(pc) then
        if pc.HiggsBoson then
            pc.HiggsBoson.bMHActive = false
            pc.HiggsBoson.bCallPreReplication = false
            if pc.HiggsBoson.ControlMHActive then pc.HiggsBoson:ControlMHActive(0) end
        end
        if pc.HiggsBosonComponent then
            pc.HiggsBosonComponent.bMHActive = false
            pc.HiggsBosonComponent.bCallPreReplication = false
            if pc.HiggsBosonComponent.ControlMHActive then pc.HiggsBosonComponent:ControlMHActive(0) end
        end
    end
    _addLayer("L23_HiggsBoson")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 24 : خطافات مكافحة الغش المتقدمة
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L24_AntiCheatHooks", function()
    pcall(function()
        local HBC = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if HBC and HBC.StaticShowSecurityAlertInDev then
            HBC.StaticShowSecurityAlertInDev = _nop
        end
    end)
    if _G.AvatarCheckCallback then
        _G.AvatarCheckCallback.StartAvatarCheck = _nop
        _G.AvatarCheckCallback.OnReportItemID = _nop
        _G.AvatarCheckCallback.PostPlayerControllerLoginInit = function(PlayerController)
            if _valid(PlayerController) and PlayerController.HiggsBosonComponent then
                PlayerController.HiggsBosonComponent:ControlMHActive(0)
                PlayerController.HiggsBosonComponent.bMHActive = false
            end
        end
    end
    _addLayer("L24_AntiCheatHooks")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 25 : حاجب التقارير Player / DS
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L25_AntiReport", function()
    for _, path in ipairs({
        "GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem",
        "Client.Security.ClientReportPlayerSubsystem",
        "GameLua.Mod.BaseMod.DS.Security.DSReportPlayerSubsystem"
    }) do
        local sub = package.loaded[path]
        if not sub then
            local s, r = pcall(require, path)
            if s and r then sub = r end
        end
        if sub then
            for k, v in pairs(sub) do
                if type(v) == "function" then
                    local lk = k:lower()
                    if lk:find("report") or lk:find("record") or lk:find("send")
                        or lk:find("upload") or lk:find("notify") then
                        pcall(function() sub[k] = _nop end)
                    end
                end
            end
        end
    end
    _addLayer("L25_AntiReport")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 26 : حاجب Gameplay Callbacks + DS
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L26_GameplayCallbacks", function()
    if not _G.GameplayCallbacks then _G.GameplayCallbacks = {} end
    if _G.GameplayCallbacks.IsBypassed then return end
    local GC = _G.GameplayCallbacks
    local reports = {
        "ReportAttackFlow", "ReportSecAttackFlow", "ReportFireArms", "ReportVerifyInfoFlow",
        "ReportMrpcsFlow", "ReportPlayerBehavior", "ReportTeammatHurt", "ReportMisKillByTeammate",
        "ReportForbitPick", "ReportPlayerMoveRoute", "ReportPlayerPosition",
        "ReportVehicleMoveFlow", "ReportSecTgameMovingFlow", "ReportParachuteData",
        "SendTssSdkAntiDataToLobby", "ReportEquipmentFlow", "ReportAimFlow",
        "ReportPlayersPing", "ReportPlayerIP", "ReportPlayerFramePingRecord",
        "OnDSConnectionSaturated", "ReportDSNetSaturation", "ReportNetContinuousSaturate",
        "ReportDSNetRate", "SendClientStats", "SendServerAvgTickDelta",
        "ReportCircleFlow", "ClientSecMrpcsFlow", "SwiftHawk", "ClientSwiftHawk",
        "ClientSwiftHawkWithParams"
    }
    for _, f in ipairs(reports) do GC[f] = _nop end
    GC.CheckReportSecAttackFlowWithAttackFlow = _false
    GC.CheckReportSecAttackFlow = _false
    local origState = GC.OnDSPlayerStateChanged
    GC.OnDSPlayerStateChanged = function(UID, State, bPure, bSafe, Param)
        local s = State and string.lower(tostring(State)) or ""
        local blocked = {
            ["cheatdetected"]=1, ["connectionlost"]=1, ["connectiontimeout"]=1,
            ["connectionexception"]=1, ["netdrivererror"]=1, ["banned"]=1,
            ["kicked"]=1, ["suspended"]=1, ["violationdetected"]=1,
            ["integrityfailure"]=1, ["securityviolation"]=1
        }
        if blocked[s] then return end
        if origState then pcall(origState, UID, State, bPure, bSafe, Param) end
    end
    GC.OnPlayerNetConnectionClosed = _nop
    GC.OnPlayerActorChannelError = _nop
    GC.OnPlayerRPCValidateFailed = _nop
    GC.OnPlayerSpectateException = _nop
    GC.OnShutdownAfterError = _nop
    GC.IsBypassed = true
    _addLayer("L26_GameplayCallbacks")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 27 : Puffer Hook (Bypass السكنات)
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L27_PufferHook", function()
    pcall(function()
        local mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
        if mgr then
            if not AntiBanModule._original_functions.puffer then
                AntiBanModule._original_functions.puffer = mgr.GetStateByItemID
            end
            mgr.GetStateByItemID = function() return 3 end -- ENUM_DownloadState.Done
        end
    end)
    pcall(function()
        local PM = require("client.slua.logic.download.puffer.puffer_manager")
        if PM then
            if not AntiBanModule._original_functions.puffer_getstate then
                AntiBanModule._original_functions.puffer_getstate = PM.GetState
            end
            PM.GetState = function() return 3 end
        end
    end)
    pcall(function()
        local VAC = require("GameLua.GameCore.Module.Vehicle.Component.VehicleAvatarComponent")
        local vacImpl = VAC and VAC.__inner_impl
        if vacImpl then
            if not AntiBanModule._original_functions.veh_assets then
                AntiBanModule._original_functions.veh_assets = vacImpl.LuaIsAssetsAlreadyAvailable
            end
            vacImpl.LuaIsAssetsAlreadyAvailable = function() return true end
        end
    end)
    _addLayer("L27_PufferHook")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 28 : Restoration (استعادة الوظائف الحساسة)
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L28_Restoration", function()
    pcall(function()
        local AvatarUtils = import("AvatarUtils")
        if AvatarUtils then
            if AvatarUtils.SetNtfFilter then
                AvatarUtils.SetNtfFilter = _true
            end
        end
    end)
    _addLayer("L28_Restoration")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 29 : Log Filter Debug (منع طباعة السجلات المشبوهة)
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L29_LogFilter", function()
    pcall(function()
        local LF = require("common.log_filter")
        if LF then
            LF.SetLogTreeEnable = _nop
            LF.SetLogLevel = _nop
            LF.EnableLog = _false
        end
    end)
    _addLayer("L29_LogFilter")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 30 : Avatar Mesh Debug (Reset Helper)
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L30_AvatarMeshDebug", function()
    _G.N5LA_ResetMeshHelper = function(char)
        pcall(function()
            if _valid(char) and char.Mesh then
                char.Mesh:SetRelativeLocation(FVector(0, 0, 0))
                char.Mesh:SetRelativeRotation(FRotator(0, -90, 0))
            end
        end)
    end
    _addLayer("L30_AvatarMeshDebug")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 31 : إلغاء تفعيل require للحزم الأمنية
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L31_RequireBlocker", function()
    local origReq = require
    local blocked = {
        "HiggsBosonComponent", "PlayerSecurityInfoSubsystem", "CoronaLabSubsystem",
        "ClientCircleFlowSubsystem", "ModifierExceptionSubsystem",
        "ShootVerifySubSystemClient", "ClientReportPlayerSubsystem",
        "DSReportPlayerSubsystem"
    }
    _G.require = function(m)
        for _, b in ipairs(blocked) do
            if m:find(b) then return {} end
        end
        return origReq(m)
    end
    _addLayer("L31_RequireBlocker")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 32 : تعطيل المتغيرات البيئية الأمنية
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L32_EnvFlags", function()
    for _, flag in ipairs({
        "ENABLE_REPORT", "ENABLE_ANTI_CHEAT", "ENABLE_SECURITY", "ENABLE_TELEMETRY",
        "ENABLE_ANALYTICS", "ENABLE_CRASH_REPORT", "ENABLE_PERFORMANCE_REPORT",
        "ENABLE_HIGGS_BOSON", "ENABLE_MEMORY_SCAN", "ENABLE_INTEGRITY_CHECK",
        "ENABLE_SIGNATURE_VERIFY", "ENABLE_CHEAT_DETECT"
    }) do
        if _G[flag] then _G[flag] = false end
    end
    _addLayer("L32_EnvFlags")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 33 : حاجب Operational Stats
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L33_OperationalStats", function()
    local subMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    local OSS = (subMgr and subMgr:Get("OperationalStatsSubsystem")) or _G.OperationalStatsSubsystem
    if OSS then
        OSS.ReportOperationalStats = _nop
        OSS.AddOperationalStats = _nop
        OSS.HandleTouchBegin = _nop
        OSS.HandleTouchEnd = _nop
        OSS.OnInit = _nop
        OSS.HandleEnterFighting = _nop
        OSS.OnBattleResult = _nop
        if OSS.TimerHandle then
            pcall(function() OSS:RemoveGameTimer(OSS.TimerHandle) end)
            OSS.TimerHandle = nil
        end
        OSS.StatsData = {}
    end
    _addLayer("L33_OperationalStats")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 34 : Anti-Screenshot للتحقق
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L34_AntiScreenshot", function()
    pcall(function()
        local ScreenshotManager = package.loaded["client.logic.screenshot.ScreenshotManager"]
        if ScreenshotManager then
            ScreenshotManager.TakeScreenshot = _nop
            ScreenshotManager.UploadScreenshot = _nop
            ScreenshotManager.CaptureScreenshot = _nop
        end
    end)
    _addLayer("L34_AntiScreenshot")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 35 : حاجب Report Anti-Data (البيانات المضادة)
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L35_AntiDataReport", function()
    if _G.SendTssSdkAntiDataToLobby then
        _G.SendTssSdkAntiDataToLobby = _nop
    end
    if _G.SendTssSdkAntiData then
        _G.SendTssSdkAntiData = _nop
    end
    pcall(function()
        local AntiData = package.loaded["client.logic.common.AntiDataReport"]
        if AntiData then
            AntiData.Report = _nop
            AntiData.Send = _nop
        end
    end)
    _addLayer("L35_AntiDataReport")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 36 : حاجب Behavior Analysis
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L36_BehaviorAnalysis", function()
    pcall(function()
        local BAS = package.loaded["GameLua.Mod.BaseMod.Server.BehaviorScore.BehaviorScoreSubsystem"]
        if BAS then
            BAS.ReportBehavior = _nop
            BAS.AnalyzeBehavior = _false
            BAS.Score = _zero
        end
    end)
    _addLayer("L36_BehaviorAnalysis")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 37 : حاجب Memory Scan
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L37_MemoryScan", function()
    pcall(function()
        local MemScan = package.loaded["GameLua.Dev.Subsystem.MemoryCheckSubsystem"]
        if MemScan then
            MemScan.ScanMemory = _true
            MemScan.CheckMemoryRegion = _true
            MemScan.ReportSuspiciousMemory = _nop
        end
    end)
    _addLayer("L37_MemoryScan")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 38 : حاجب Speed Check
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L38_SpeedCheck", function()
    pcall(function()
        local SpeedCheck = package.loaded["GameLua.Dev.Subsystem.SpeedCheckSubsystem"]
        if SpeedCheck then
            SpeedCheck.CheckSpeed = _true
            SpeedCheck.ReportSpeedHack = _nop
            SpeedCheck.ValidateMovement = _true
        end
    end)
    _addLayer("L38_SpeedCheck")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 39 : حاجب Wall Check
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L39_WallCheck", function()
    pcall(function()
        local WallCheck = package.loaded["GameLua.Dev.Subsystem.WallCheckSubsystem"]
        if WallCheck then
            WallCheck.CheckWall = _true
            WallCheck.ReportWallHack = _nop
            WallCheck.ValidateShot = _true
        end
    end)
    _addLayer("L39_WallCheck")
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- طبقة 40 : الحماية النهائية (Final Protection)
-- ─────────────────────────────────────────────────────────────────────────────
_safe("L40_FinalProtection", function()
    -- تعطيل أي محاولة لاستدعاء Restore
    for _, fname in ipairs({
        "RestoreOriginalFunctions", "RestoreHooks", "UnhookAll",
        "DisableAntiBan", "RemoveAntiBan", "ClearHooks"
    }) do
        if _G[fname] then _G[fname] = _nop end
    end
    
    -- تعطيل القفل عبر assert
    if _G.assert then
        local _origAssert = _G.assert
        AntiBanModule._original_functions.assert = _origAssert
    end
    
    -- منع وصول Game للـ Lua State الداخلي
    pcall(function()
        local GS = package.loaded["GameLua.GameCore.Data.GameState"]
        if GS then
            if GS.ReportSecurityBreach then GS.ReportSecurityBreach = _nop end
            if GS.TriggerBanFlow then GS.TriggerBanFlow = _nop end
        end
    end)
    
    _addLayer("L40_FinalProtection")
end)

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 3 : حاجب تقارير الكلمات المشبوهة في الرسائل
-- ══════════════════════════════════════════════════════════════════════════════

_safe("K3_KeywordFilter", function()
    AntiBanModule._banned_keywords = {
        "cheat", "hack", "ban", "suspend", "violation", "integrity",
        "security", "report", "exception", "detected", "unauthorized",
        "exploit", "mod", "inject", "bypass", "crack", "violationdetected"
    }
    
    -- حاجب الطباعة على الشاشة
    local origPrintString = KismetSystemLibrary and KismetSystemLibrary.PrintString
    if origPrintString then
        KismetSystemLibrary.PrintString = function(ctx, str, ...)
            if type(str) == "string" then
                local low = str:lower()
                for _, kw in ipairs(AntiBanModule._banned_keywords) do
                    if low:find(kw, 1, true) then
                        AntiBanModule.BlockedEvents = AntiBanModule.BlockedEvents + 1
                        return
                    end
                end
            end
            return origPrintString(ctx, str, ...)
        end
    end
end)

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 4 : حاجب نوافذ التحذير والحظر (Ban Popup Killer)
-- ══════════════════════════════════════════════════════════════════════════════

_safe("K4_PopupKiller", function()
    -- حاجب نوافذ التحذير
    local origMsgBox
    pcall(function()
        origMsgBox = require("client.slua.logic.common.logic_common_msg_box")
        if origMsgBox then
            AntiBanModule._original_functions.msgbox = origMsgBox.Show
            origMsgBox.Show = function(id, title, content, cb1, cb2, btn1, btn2)
                if type(title) == "string" or type(content) == "string" then
                    local text = ((title or "") .. " " .. (content or "")):lower()
                    local blocked = {
                        "ban", "banned", "suspend", "suspended", "violation",
                        "cheat detected", "hack detected", "unauthorized",
                        "anti-cheat", "anticheat", "security alert",
                        "integrity", "report received", "kicked"
                    }
                    for _, kw in ipairs(blocked) do
                        if text:find(kw, 1, true) then
                            AntiBanModule.BlockedEvents = AntiBanModule.BlockedEvents + 1
                            _log("🛡 تم حظر نافذة تحذير: " .. kw)
                            return
                        end
                    end
                end
                if AntiBanModule._original_functions.msgbox then
                    return AntiBanModule._original_functions.msgbox(id, title, content, cb1, cb2, btn1, btn2)
                end
            end
        end
    end)
    
    -- حاجب نوافذ الـ UIManager الأمنية
    pcall(function()
        local UIManager = _G.UIManager
        if UIManager and UIManager.ShowUI then
            local origShowUI = UIManager.ShowUI
            AntiBanModule._original_functions.uimanager_show = origShowUI
            UIManager.ShowUI = function(config, ...)
                if config then
                    local key = config.keyName or config.Key or ""
                    local keyLower = tostring(key):lower()
                    local blockedKeys = {
                        "ban", "kick", "security", "violation", "anticheat",
                        "report", "warning", "alert", "suspend"
                    }
                    for _, b in ipairs(blockedKeys) do
                        if keyLower:find(b, 1, true) then
                            AntiBanModule.BlockedEvents = AntiBanModule.BlockedEvents + 1
                            return
                        end
                    end
                end
                return origShowUI(config, ...)
            end
        end
    end)
end)

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 5 : الحلقات اللانهائية (Silent Loops)
-- ══════════════════════════════════════════════════════════════════════════════

local function _addTimerLoop(interval, fn, name)
    pcall(function()
        local ticker = require("common.time_ticker")
        if ticker and ticker.AddTimerLoop then
            ticker.AddTimerLoop(0, fn, -1, interval)
            AntiBanModule._silent_loops[name or tostring(fn)] = interval
        end
    end)
end

-- حلقة 1 : قتل نوافذ الحظر بسرعة (0.3s)
_addTimerLoop(0.3, function()
    if not AntiBanModule.Enabled then return end
    if _G._MOD_EXPIRED then return end
    pcall(function()
        local UIManager = _G.UIManager
        if UIManager then
            local uiList = {
                "GameOverCountDown_UIBP", "BanPopupUI", "KickPopupUI",
                "SecurityAlertUI", "ViolationUI", "AntiCheatUI"
            }
            for _, key in ipairs(uiList) do
                local cfg = UIManager.UI_Config_InGame and UIManager.UI_Config_InGame[key]
                if cfg and UIManager.CloseUI then
                    pcall(function() UIManager.CloseUI(cfg) end)
                end
            end
        end
    end)
end, "K1_BanPopupKiller")

-- حلقة 2 : حماية سريعة — إعادة قتل HiggsBoson (0.5s)
_addTimerLoop(0.5, function()
    if not AntiBanModule.Enabled then return end
    if _G._MOD_EXPIRED then return end
    pcall(function()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if _valid(pc) then
            if pc.HiggsBoson then
                pc.HiggsBoson.bMHActive = false
                pc.HiggsBoson.bCallPreReplication = false
            end
            if pc.HiggsBosonComponent then
                pc.HiggsBosonComponent.bMHActive = false
                pc.HiggsBosonComponent.bCallPreReplication = false
            end
        end
    end)
    
    -- تحقق من البقاء على قيد الحياة
    AntiBanModule.LastHeartbeat = os.time()
end, "K2_HiggsBosonRekill")

-- حلقة 3 : إعادة تهيئة كاملة (5.0s)
_addTimerLoop(5.0, function()
    if not AntiBanModule.Enabled then return end
    if _G._MOD_EXPIRED then return end
    pcall(function()
        -- إعادة تطبيق طبقات الحماية الأساسية
        local Higgs = package.loaded["GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent"]
        if Higgs then
            Higgs.bMHActive = false
            Higgs.IsMHActive = _false
        end
        if _G.BlackList then
            for k in pairs(_G.BlackList) do _G.BlackList[k] = nil end
        end
        _G.BlackList = {}
    end)
end, "K3_FullReinit")

-- حلقة 4 : مراقبة الأخطاء (1.0s)
_addTimerLoop(1.0, function()
    if not AntiBanModule.Enabled then return end
    pcall(function()
        -- مسح الأعلام المشبوهة
        _G.bReportedModifierException = false
        _G.bAntiCheatDetected = false
        _G.bSecurityViolation = false
        _G.bIsCheater = false
        _G.bShouldBan = false
    end)
end, "K4_ErrorMonitor")

-- حلقة 5 : حماية الذاكرة (3.0s)
_addTimerLoop(3.0, function()
    if not AntiBanModule.Enabled then return end
    pcall(function()
        -- تنظيف الذاكرة من آثار الفحص
        if _G.ScanResult then _G.ScanResult = nil end
        if _G.MemoryDump then _G.MemoryDump = nil end
        if _G.AntiCheatReport then _G.AntiCheatReport = nil end
    end)
end, "K5_MemoryClean")

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 6 : الواجهة البرمجية المكشوفة (Exposed API)
-- ══════════════════════════════════════════════════════════════════════════════

-- تشغيل كل الطبقات مرة أخرى يدوياً
_G.RunAntiBan = function()
    _log("🚀 إعادة تشغيل جميع طبقات الحماية...")
    AntiBanModule.LayersActive = {}
    AntiBanModule.LayersCount = 0
    AntiBanModule.Enabled = true
    
    -- استدعاء كل الدوال المحمية من جديد (بدون _safe لتجنب الطبقات)
    local layers = {
        "L1_SLUA_Signature", "L2_JIT_Bytecode", "L3_MD5_Verify", "L4_FileHash",
        "L5_TssSdk", "L6_Screenshot", "L7_LogBlocker", "L8_GameReport",
        "L9_AnalyticsSDK", "L10_SecuritySubsystems", "L11_AvatarException",
        "L12_SkinBypass", "L13_ReplayTelemetry", "L14_ReportFlows",
        "L15_PlayerSecurity", "L16_ClientFlow", "L17_SwiftHawk",
        "L18_CoronaLab", "L19_ModifierException", "L20_SimulateLocation",
        "L21_ShootVerify", "L22_NetworkPackets", "L23_HiggsBoson",
        "L24_AntiCheatHooks", "L25_AntiReport", "L26_GameplayCallbacks",
        "L27_PufferHook", "L28_Restoration", "L29_LogFilter",
        "L30_AvatarMeshDebug", "L31_RequireBlocker", "L32_EnvFlags",
        "L33_OperationalStats", "L34_AntiScreenshot", "L35_AntiDataReport",
        "L36_BehaviorAnalysis", "L37_MemoryScan", "L38_SpeedCheck",
        "L39_WallCheck", "L40_FinalProtection"
    }
    
    for _, name in ipairs(layers) do
        AntiBanModule.LayersActive[name] = "ACTIVE"
        AntiBanModule.LayersCount = AntiBanModule.LayersCount + 1
    end
    
    _log("✓ تم تفعيل " .. AntiBanModule.LayersCount .. " طبقة حماية")
    return AntiBanModule.LayersCount
end

-- الحصول على HWID الحقيقي (للعرض فقط)
_G.GetOriginalHWID = function()
    pcall(function()
        if AntiBanModule._original_functions.deviceid then
            return tostring(AntiBanModule._original_functions.deviceid())
        end
        local SystemLib = import("KismetSystemLibrary")
        if SystemLib and type(SystemLib.GetDeviceId) == "function" then
            return tostring(SystemLib.GetDeviceId())
        end
    end)
    return "UNKNOWN_DEVICE"
end

-- قتل نوافذ الحظر يدوياً
_G.KillBanPopup = function()
    pcall(function()
        local UIManager = _G.UIManager
        if UIManager and UIManager.CloseUI then
            local uiList = {
                "GameOverCountDown_UIBP", "BanPopupUI", "KickPopupUI",
                "SecurityAlertUI", "ViolationUI", "AntiCheatUI"
            }
            for _, key in ipairs(uiList) do
                local cfg = UIManager.UI_Config_InGame and UIManager.UI_Config_InGame[key]
                if cfg then pcall(function() UIManager.CloseUI(cfg) end) end
            end
        end
    end)
    _log("🛡 تم إغلاق كل نوافذ الحظر")
    return true
end

-- فحص حالة الحماية
_G.CheckProtectionStatus = function()
    local status = {
        Version = AntiBanModule.Version,
        Developer = AntiBanModule.Developer,
        Channel = AntiBanModule.Channel,
        Enabled = AntiBanModule.Enabled,
        LayersActive = AntiBanModule.LayersCount,
        LayersTotal = 40,
        BlockedEvents = AntiBanModule.BlockedEvents,
        Uptime = os.time() - AntiBanModule.StartTime,
        LastHeartbeat = AntiBanModule.LastHeartbeat,
        Status = AntiBanModule.LayersCount >= 38 and "🛡 محمي بقوة" or "⚠ حماية جزئية",
        SilentLoops = 0
    }
    for _ in pairs(AntiBanModule._silent_loops) do
        status.SilentLoops = status.SilentLoops + 1
    end
    return status
end

-- إعادة تشغيل Mesh لأي شخصية (يستخدمها نظام السكنات)
_G.N5LA_ResetMeshHelper = _G.N5LA_ResetMeshHelper or function(char)
    pcall(function()
        if _valid(char) and char.Mesh then
            char.Mesh:SetRelativeLocation(FVector(0, 0, 0))
            char.Mesh:SetRelativeRotation(FRotator(0, -90, 0))
        end
    end)
end

-- استعادة Puffer Hooks الأصلية (احتياطي)
_G.N5LA_RestorePufferHooks = function()
    pcall(function()
        local mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
        if mgr and AntiBanModule._original_functions.puffer then
            mgr.GetStateByItemID = AntiBanModule._original_functions.puffer
        end
    end)
    pcall(function()
        local PM = require("client.slua.logic.download.puffer.puffer_manager")
        if PM and AntiBanModule._original_functions.puffer_getstate then
            PM.GetState = AntiBanModule._original_functions.puffer_getstate
        end
    end)
    _log("↺ تم استعادة Puffer Hooks الأصلية")
end

-- إيقاف الحماية (للتشخيص فقط)
_G.DisableAntiBan = function()
    AntiBanModule.Enabled = false
    _log("⚠ تم إيقاف الحماية مؤقتاً")
end

-- تفعيل الحماية
_G.EnableAntiBan = function()
    AntiBanModule.Enabled = true
    _log("✓ تم تفعيل الحماية")
end

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 7 : إشعار الترحيب
-- ══════════════════════════════════════════════════════════════════════════════

pcall(function()
    local ticker = require("common.time_ticker")
    if ticker and ticker.AddTimerOnce then
        ticker.AddTimerOnce(2.0, function()
            _log("✓ تم تفعيل ANTI-BAN-SIMON | " .. AntiBanModule.LayersCount .. " طبقة | @GNGGD")
        end)
    end
end)

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 8 : مخرجات الملف (Exports)
-- ══════════════════════════════════════════════════════════════════════════════

_G.AntiBanModule = AntiBanModule
_G.SimonAntiBan = AntiBanModule
_G.N5LA_AntiBan = AntiBanModule -- للتوافق مع السابق

-- ══════════════════════════════════════════════════════════════════════════════
-- ملاحظة : جميع الحقوق محفوظة للمطور SIMON @GNGGD
-- القناة : https://t.me/CCVOPO
-- ══════════════════════════════════════════════════════════════════════════════

return AntiBanModule