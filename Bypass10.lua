_G.MXP_Runtime = _G.MXP_Runtime or {
    Version = 3,
    BootTime = os.time(),
    State = {
        Lifecycle = "BOOT",
        Initialized = false,
        MatchActive = false,
        CharacterValid = false,
        Authenticated = false
    },
    Character = {
        Current = nil,
        Previous = nil,
        Generation = 0,
        Valid = false
    },
    Timers = {},
    Hooks = {},
    Caches = {},
    Systems = {},
    Errors = {},
    ErrorCounts = {},
    Metrics = {
        TimerCount = 0,
        HookCount = 0,
        SystemCount = 0,
        CacheCount = 0,

        CharacterGeneration = 0
    },
    Config = {
        ErrorBudget = 100,
        MaxCacheEntries = 256,
        DisabledSystems = {}
    }
}

local MXP_Runtime = _G.MXP_Runtime

-- Lifecycle state constants
MXP_Runtime.LifecycleStates = {
    BOOT = "BOOT",
    INITIALIZING = "INITIALIZING",
    READY = "READY",
    AUTH_PENDING = "AUTH_PENDING",
    AUTHENTICATED = "AUTHENTICATED",
    LOBBY = "LOBBY",
    MATCH_START = "MATCH_START",
    MATCH_ACTIVE = "MATCH_ACTIVE",
    CHARACTER_CHANGE = "CHARACTER_CHANGE",
    MATCH_END = "MATCH_END",
    APP_ACTIVE = "APP_ACTIVE",
    APP_BACKGROUND = "APP_BACKGROUND",
    APP_RESUME = "APP_RESUME"
}

-- MXP_SafeCall will be bound after MXP_Runtime:SafeCall is defined below.

-- Timer manager with ownership, scope, idempotency
function MXP_Runtime:RegisterTimer(name, handle, scope, owner)
    if not handle then return false, "no handle" end
    scope = scope or "global"
    owner = owner or "MXP"
    local key = tostring(name)
    local existing = self.Timers[key]
    if existing and existing.Handle == handle then
        return true, "already registered"
    end
    if existing and existing.Handle then
        self:RemoveTimer(key)
    end
    self.Timers[key] = { Name = key, Handle = handle, Scope = scope, Owner = owner, StartedAt = os.time() }
    self.Metrics.TimerCount = (self.Metrics.TimerCount or 0) + 1

    return true
end

function MXP_Runtime:RemoveTimer(name)
    local entry = self.Timers[tostring(name)]
    if not entry then return false end
    local tt = package.loaded["common.time_ticker"] or require("common.time_ticker")
    if tt and type(tt.RemoveTimer) == "function" then
        pcall(function() tt.RemoveTimer(entry.Handle) end)
    end
    self.Timers[tostring(name)] = nil
    self.Metrics.TimerCount = math.max(0, (self.Metrics.TimerCount or 0) - 1)
    return true
end

function MXP_Runtime:RemoveScopeTimers(scope)
    for name, entry in pairs(self.Timers) do
        if entry.Scope == scope then
            self:RemoveTimer(name)
        end
    end
end

function MXP_Runtime:StopAllTimers()
    for name, _ in pairs(self.Timers) do
        self:RemoveTimer(name)
    end
end

function MXP_Runtime:HasTimer(name)
    return self.Timers[tostring(name)] ~= nil
end

function MXP_Runtime:TimerNames()
    local out = {}
    for n in pairs(self.Timers) do table.insert(out, n) end
    return out
end

-- Hook registry with collision detection and original preservation
function MXP_Runtime:RegisterHook(name, targetTable, funcName, wrapper, scope, owner)
    if type(targetTable) ~= "table" then return false, "target not table" end
    scope = scope or "global"
    owner = owner or "MXP"
    local key = tostring(name)
    local orig = targetTable[funcName]
    if type(orig) ~= "function" then return false, "original not function" end
    local reg = self.Hooks[key]
    if reg and reg.Installed then
        if reg.Owner == owner then
            return true, "already owned"
        end
        return false, "collision with " .. tostring(reg.Owner)
    end
    self.Hooks[key] = { Name = key, Target = targetTable, FuncName = funcName, Original = orig, Current = wrapper, Owner = owner, Scope = scope, Installed = true }
    self.Originals = self.Originals or {}
    self.Originals[key] = orig
    targetTable[funcName] = wrapper
    self.Metrics.HookCount = (self.Metrics.HookCount or 0) + 1

    return true
end

function MXP_Runtime:UnregisterHook(name)
    local reg = self.Hooks[tostring(name)]
    if not reg then return false end
    if reg.Target and reg.FuncName and reg.Original then
        reg.Target[reg.FuncName] = reg.Original
    end
    self.Hooks[tostring(name)] = nil
    self.Metrics.HookCount = math.max(0, (self.Metrics.HookCount or 0) - 1)

    return true
end

function MXP_Runtime:RemoveScopeHooks(scope)
    for name, reg in pairs(self.Hooks) do
        if reg.Scope == scope then
            self:UnregisterHook(name)
        end
    end
end

function MXP_Runtime:GetOriginal(name)
    local reg = self.Hooks[tostring(name)]
    return reg and reg.Original or (self.Originals and self.Originals[tostring(name)])
end

-- Cache registry with lifecycle and TTL
function MXP_Runtime:RegisterCache(name, scope)
    scope = scope or "global"
    if self.Caches[name] then
        return self.Caches[name]
    end
    self.Caches[name] = { Name = name, Scope = scope, Data = {}, CreatedAt = os.time(), Generation = 0 }
    self.Metrics.CacheCount = (self.Metrics.CacheCount or 0) + 1

    return self.Caches[name]
end

function MXP_Runtime:GetCache(name)
    return self.Caches[name]
end

function MXP_Runtime:InvalidateCache(name)
    local c = self.Caches[name]
    if c then
        c.Data = {}
        c.Generation = (c.Generation or 0) + 1
        c.InvalidatedAt = os.time()
    end
end

function MXP_Runtime:InvalidateScopeCaches(scope)
    for name, c in pairs(self.Caches) do
        if c.Scope == scope then
            self:InvalidateCache(name)
        end
    end
end

function MXP_Runtime:RemoveScopeCaches(scope)
    local removed = 0
    for name, c in pairs(self.Caches) do
        if c.Scope == scope then
            self.Caches[name] = nil
            removed = removed + 1
        end
    end
    self.Metrics.CacheCount = math.max(0, (self.Metrics.CacheCount or 0) - removed)
end

-- System registry
function MXP_Runtime:SafeCall(systemName, actionName, fn, ...)
  if type(fn) ~= "function" then
    return false, "not a function"
  end
  local key = tostring(systemName) .. "." .. tostring(actionName)
  local sname = tostring(systemName):lower()
  local isCritical = sname == "security" or sname:find("bypass") or sname:find("shield")
  if self.Config.DisabledSystems[key] and not isCritical then
    return false, "disabled by error budget"
  end
  local ok, ret = pcall(fn, ...)
  if not ok then
    self.ErrorCounts[key] = (self.ErrorCounts[key] or 0) + 1
    local budget = isCritical and 1e9 or (self.Config.ErrorBudget or 100)
    if self.ErrorCounts[key] >= budget and not isCritical then
      self.Config.DisabledSystems[key] = true
    end
    return false, ret
  end
  return true, ret
end

_G.MXP_SafeCall = function(systemName, actionName, fn, ...)
  return MXP_Runtime:SafeCall(systemName, actionName, fn, ...)
end

function MXP_Runtime:RegisterSystem(name, startFn, stopFn, scope, deps)
    scope = scope or "global"
    if not self.Systems[name] then
        self.Metrics.SystemCount = (self.Metrics.SystemCount or 0) + 1
    end
    self.Systems[name] = {
        Name = name,
        Scope = scope,
        Started = self.Systems[name] and self.Systems[name].Started or false,
        Disabled = self.Systems[name] and self.Systems[name].Disabled or false,
        Start = startFn,
        Stop = stopFn,
        Dependencies = deps or {}
    }

end

function MXP_Runtime:StartSystem(name)
    local sys = self.Systems[name]
    if not sys then return false, "not registered" end
    if sys.Disabled then return false, "disabled by error budget" end
    if sys.Started then return true, "already started" end
    if sys.Dependencies then
        for _, dep in ipairs(sys.Dependencies) do
            if not self:SystemReady(dep) then
                return false, "dependency not ready: " .. tostring(dep)
            end
        end
    end
    local ok, err = pcall(sys.Start)
    if ok then
        sys.Started = true

        return true
    end

    self:SafeCall(name, "Start", function() error(err) end)
    return false, err or "start failed"
end

function MXP_Runtime:StopSystem(name)
    local sys = self.Systems[name]
    if not sys or not sys.Started then return false end
    self:SafeCall(name, "Stop", sys.Stop)
    sys.Started = false

    return true
end

function MXP_Runtime:SystemReady(name)
    local sys = self.Systems[name]
    return sys ~= nil and sys.Started and not sys.Disabled
end

function MXP_Runtime:StartScope(scope)
    for name, sys in pairs(self.Systems) do
        if sys.Scope == scope then
            self:StartSystem(name)
        end
    end
end

function MXP_Runtime:StopScope(scope)
    for name, sys in pairs(self.Systems) do
        if sys.Scope == scope then
            self:StopSystem(name)
        end
    end
    self:RemoveScopeTimers(scope)
    self:RemoveScopeHooks(scope)
    self:RemoveScopeCaches(scope)
end

-- Character lifecycle
function MXP_Runtime:SetCharacter(character)
    if self.Character.Current == character and self.Character.Valid then
        return false, "same character"
    end
    self.Character.Previous = self.Character.Current
    self.Character.Current = character
    self.Character.Generation = self.Character.Generation + 1
    self.Character.Valid = character ~= nil
    self.State.CharacterValid = self.Character.Valid
    self.Metrics.CharacterGeneration = self.Character.Generation
    self:InvalidateScopeCaches("character")
    self:StopScope("character")
    if character ~= nil then
        self:StartScope("character")
    end

    return true
end

function MXP_Runtime:InvalidateCharacter()
    self.State.CharacterValid = false
    self.Character.Valid = false
    self.Character.Current = nil
    self.Character.Generation = self.Character.Generation + 1
    self.Metrics.CharacterGeneration = self.Character.Generation
    self:InvalidateScopeCaches("character")
    self:StopScope("character")
    -- Remove any per-instance mod tick timer tied to the previous character.
    pcall(function()
        local timerReg = self.Timers and self.Timers["Character.OnTick"]
        if timerReg and timerReg.Handle then
            self:RemoveTimer("Character.OnTick")
        end
    end)
end

-- Match lifecycle state machine
function MXP_Runtime:SetMatchActive(active)
    local prev = self.State.MatchActive
    self.State.MatchActive = active
    if active and not prev then

        self.State.Lifecycle = "MATCH_START"
        self:StartScope("match")
        self.State.Lifecycle = "MATCH_ACTIVE"
        if _G.MXP_ShowStatus then pcall(_G.MXP_ShowStatus) end

    elseif not active and prev then

        self.State.Lifecycle = "MATCH_END"
        if type(_G.MXP_ClearMatchUI) == "function" then
            pcall(_G.MXP_ClearMatchUI)
        end
        self:StopScope("match")
        self:InvalidateScopeCaches("match")
        self:RemoveScopeCaches("match")
        self.State.Lifecycle = "LOBBY"

    end
end

-- ============================================================
-- MXP UI Lifecycle Helpers
-- ============================================================
local function MXP_SafeRemoveFromParent(Widget)
  if not Widget then return false end
  local t = type(Widget)
  if t ~= "userdata" and t ~= "table" then return false end
  if not (slua and slua.isValid and slua.isValid(Widget)) then return false end
  if type(Widget.RemoveFromParent) ~= "function" then return false end
  local ok = pcall(function()
    Widget:RemoveFromParent()
  end)
  return ok
end

-- App resume: repair-oriented
function MXP_Runtime:OnAppResume()
    self.State.Lifecycle = "APP_RESUME"

    -- Re-arm security hooks only if missing; do not reinitialize whole runtime
    if type(_G.MXP_SecurityReArm) == "function" then
        self:SafeCall("Security", "ReArm", _G.MXP_SecurityReArm)
    end
    -- Refresh character reference from GameplayData if available.
    pcall(function()
        local GameplayData = package.loaded["GameLua.GameCore.Data.GameplayData"] or rawget(_G, "GameplayData")
        if GameplayData and GameplayData.GetPlayerCharacter then
            local ch = GameplayData.GetPlayerCharacter()
            if ch and slua and slua.isValid and slua.isValid(ch) then
                self:SetCharacter(ch)
            end
        end
    end)
    -- Ensure combine_class redirect is alive after resume; re-register without
    -- clearing the cached override so the current match keeps working.
    pcall(function()
        local cc = _G.package and _G.package.loaded and _G.package.loaded["combine_class"]
        if type(cc) == "table" and type(cc.AddLuaRequireRedirect) == "function" and type(_G.MXP_CombineRedirect) == "function" then
            cc:AddLuaRequireRedirect(MXP_COMBINE_REDIRECT_PATH, _G.MXP_CombineRedirect)
        end
    end)
    self.State.Lifecycle = self.State.MatchActive and "MATCH_ACTIVE" or "LOBBY"
end

-- MXP Anti-Ban Infrastructure (legacy state bridge)
-- ======================================================================
_G.MXP_LayerState = _G.MXP_LayerState or {
  StateInitialized = false,
  CallbackInstalled = false,
  NetworkInstalled = false,
  DeviceInstalled = false,
  SecurityInstalled = false,
  NativeShieldInstalled = false,
  TelemetryInstalled = false,
  LifecycleInstalled = false,
  IntegrityInstalled = false,
  PakIntegrityInstalled = false,
  NativeAntiDetectInstalled = false,
  PvsShieldInstalled = false,
  HiggsSpoofInstalled = false,
  VehicleLagCompShieldInstalled = false,
  LogCleanupInstalled = false,
  ResourceErrorShieldInstalled = false
}

local function MXP_SetLayerError(name, err)
  _G.MXP_LayerState.Errors = _G.MXP_LayerState.Errors or {}
  table.insert(_G.MXP_LayerState.Errors, { Layer = name, Error = tostring(err), Time = os.time() })
end

local function MXP_ValidateBypassState()
  local ok = true
  local missing = {}
  for layer, state in pairs(_G.MXP_LayerState) do
    if type(state) == "boolean" and state == false then
      ok = false
      table.insert(missing, tostring(layer))
    end
  end
  return ok, missing
end
_G.MXP_LifecycleState = _G.MXP_LifecycleState or "UNINITIALIZED"
if _G.MXP_LifecycleState == "UNINITIALIZED" then
  _G.MXP_LifecycleState = "READY"
end
_G.MXP_HookRegistry = _G.MXP_HookRegistry or {}
_G.MXP_OriginalFunctions = _G.MXP_OriginalFunctions or {}
_G.MXP_LayerErrors = _G.MXP_LayerErrors or {}
_G.MXP_NativeShieldState = _G.MXP_NativeShieldState or { Character = nil, Applied = false }
_G.MXP_TimerHandles = _G.MXP_TimerHandles or {}
-- v9.6 layer re-arm wrapper (fungsi real didefinisikan di bagian bawah file)
local function MXP_InstallBanNotificationShield()
  if _G.MXP_LayerState.BanNotificationShieldInstalled then return end
  local function NukeIncoming(modulePath, funcName)
    if _G.MXP_LogDiag then _G.MXP_LogDiag("protocol: nuke handler: " .. tostring(modulePath) .. "." .. tostring(funcName)) end
    pcall(function()
      local mod = package.loaded[modulePath] or rawget(_G, modulePath)
      if type(mod) ~= "table" then return end
      if type(mod[funcName]) == "function" and not mod["MXP_"..funcName.."Nuked"] then
        mod["MXP_"..funcName.."Raw"] = mod[funcName]
        mod["MXP_"..funcName.."Nuked"] = true
        mod[funcName] = function(...) return true end
      end
    end)
  end
  -- Server-driven kick / ban / cheat warnings.
  local IncomingTargets = {
    {"client.network.Protocol.LoginHandler", "on_kickout"},
    {"client.network.Protocol.LoginHandler", "on_login_failed"},
    {"client.network.Protocol.LoginHandler", "on_notify_game_aas_ban"},
    {"client.network.Protocol.BattleHander", "on_ban_info_notify"},
    {"client.network.Protocol.BattleHander", "on_voice_ban_notify"},
    {"client.network.Protocol.BattleHander", "on_voice_ban_success"},
    {"client.network.Protocol.EmulatorHandler", "on_notify_kick_out_game"},
    {"client.network.Protocol.FairGameHandler", "on_cheat_warn_notify"},
    {"client.network.Protocol.LobbyHandler", "on_sync_player_ban"},
    {"client.network.Protocol.LobbyHandler", "on_dalay_ban_text"},
    {"client.network.Protocol.LobbyHandler", "on_team_change_type_mil_ban_notify"},
    {"client.network.Protocol.GodzillaBanHandler", "on_get_goslar_ban_info_rsp"},
    {"client.network.Protocol.GodzillaBanHandler", "on_goslar_ban_confirm_rsp"},
    {"client.network.Protocol.GodzillaBanHandler", "on_goslar_ban_draw_rsp"},
    {"client.network.Protocol.CrewHandler", "on_get_ban_name_list_rsp"},
    {"client.network.Protocol.ChatHandler", "on_report_info"},
    {"client.network.Protocol.ChatHandler", "on_report_info_mic"},
  }
  for _, t in ipairs(IncomingTargets) do
    NukeIncoming(t[1], t[2])
  end
  -- Neutralize GEMReportSubEvent / GEMReportEvent if exposed on Client.
  pcall(function()
    if type(Client) == "table" then
      for _, name in ipairs({"GEMReportEvent", "GEMReportSubEvent", "AddAttachFileString"}) do
        if type(Client[name]) == "function" and not Client["MXP_"..name.."Nuked"] then
          if _G.MXP_LogDiag then _G.MXP_LogDiag("client.method: nuke report sink: " .. tostring(name)) end
          Client["MXP_"..name.."Raw"] = Client[name]
          Client["MXP_"..name.."Nuked"] = true
          Client[name] = function(...) return true end
        end
      end
    end
  end)
  _G.MXP_LayerState.BanNotificationShieldInstalled = true
end

function MXP_InstallV96Layers()
  local names = {
    "MXP_InstallPacketCallbacks",
    "MXP_InstallEnvironmentSpoof",
    "MXP_InstallDSAnomalyBypass",
    "MXP_InstallDSGlueHia",
    "MXP_InstallReplayStrategy",
    "MXP_InstallTssIoctl",
    "MXP_InstallBanUI",
    "MXP_InstallDeepSubsystemSilence",
    "MXP_InstallCrashReporterStub",
    "MXP_InstallBanAppealTrap",
    "MXP_InstallBanNotificationShield",
    "MXP_HardenHiggsComponent",
    "MXP_NeutralizeTLogSubsystems",
    "MXP_NeutralizeClientBanLogic",
    "MXP_InitializeScannerBlocker",
    "MXP_InitializeLogBlocker",
    "MXP_InitializeReplayTelemetryBlocker",
    "MXP_InstallPakUpdateBlocker",
    "MXP_SpoofManufacturer",
    "MXP_BypassSafetyNetPlayIntegrity",
    "MXP_RandomizeSignature",
    "MXP_SpoofHeartbeat",
    "MXP_NeutralizeNewSymbols46"
  }
  for _, name in ipairs(names) do
    local fn = _G[name]
    if type(fn) == "function" then pcall(fn) end
  end
  local rezero = _G.MXP_PeriodicHiggsReZero
  if type(rezero) == "function" then pcall(rezero) end
  _G.MXP_LayerState.V96LayersInstalled = true
end

function MXP_CheckLateLoadedModules()
  local LateModules = {
    "TssManager", "EmulatorHandler", "ban_login_module",
    "SecurityManager", "client.logic.login.logic_lobby",
    "client.network.Protocol.ClientEntryHandler",
    "client.network.Protocol.LobbyHandler",
    "client.slua.logic.login.login_module",
    "client.logic.ingame",
    "client.logic.anti_cheat",
    "client.common.anti_cheat",
    "client.logic.security",
    "client.common.security"
  }
  local Status = {}
  local anyLoaded = false
  for _, modName in ipairs(LateModules) do
    local loaded = package.loaded[modName] ~= nil
    Status[modName] = loaded and "READY" or "NOT_READY"
    if loaded then
      anyLoaded = true
      pcall(MXP_InstallSecurity)
      pcall(MXP_InstallTelemetry)
      pcall(MXP_InstallDevice)
    end
  end
  -- If any late security module appears, force a full re-arm of all bypass layers.
  if anyLoaded then
    _G.MXP_LayerState = _G.MXP_LayerState or {}
    _G.MXP_LayerState.SecurityInstalled = false
    _G.MXP_LayerState.TelemetryInstalled = false
    _G.MXP_LayerState.DeviceInstalled = false
    _G.MXP_LayerState.NativeShieldInstalled = false
    pcall(MXP_InstallSecurity)
    pcall(MXP_InstallTelemetry)
    pcall(MXP_InstallDevice)
    pcall(MXP_InstallNativeShield)
  end
  -- Re-arm v9.6 layers so late-loaded security modules stay neutralized.
  -- NOTE: load-time bypass already covers v9.6; re-arm only if not installed.
  if not _G.MXP_LayerState or _G.MXP_LayerState.V96LayersInstalled ~= true then
    pcall(MXP_InstallV96Layers)
  end
  if _G.MXP_DebugMode then
    for modName, st in pairs(Status) do
    end
  end

  return Status
end

function MXP_InstallState()
  if _G.MXP_LayerState.StateInstalled then
    return
  end

  -- ----------------------------------------------------------------------
  -- (0) Stable plausible device identity (memory-only, no persistence)
  -- ----------------------------------------------------------------------
  if not _G.MXP_HWIDString then
    local seedSrc = tostring(os.time()) .. tostring(os.clock()*1e7) .. tostring(math.random(1,1e9))
    local state = 7
    for i = 1, #seedSrc do
      state = (state * 31 + seedSrc:byte(i)) % 2147483647
    end
    local chars = "0123456789abcdef"
    local h = ""
    for i = 1, 32 do
      state = (state * 1103515245 + 12345) % 2147483647
      h = h .. chars:sub((state % 16) + 1, (state % 16) + 1)
    end
    _G.MXP_HWIDString = h
  end

  -- ----------------------------------------------------------------------
  -- (0.5) PlayerSafeCallback trust-registry (DS-side only, guard check)
  -- ----------------------------------------------------------------------
  pcall(function()
    if type(_G.PlayerSafeCallback) == "table" then
      local Passes = {
        "CharMoveDistPerSecondLuaIsCharacterStateValid",
        "DistanceToGroundLuaIsCharacterStateValid",
        "MaxCustomMoveModeTimeLuaIsCharacterStateValid",
        "MaxFallingTimeLuaIsCharacterStateValid",
        "MoveDistancePerSecondLuaIsCharacterStateValid",
        "PlayerHeightDiffLuaIsCharacterStateValid",
        "UnderBuildingLuaIsCharacterStateValid",
        "KillFrequencyLimiterIsEnableRunning",
        "KillFrequencyLimiterIsGeneralShooting"
      }
      for _, n in ipairs(Passes) do
        if type(_G.PlayerSafeCallback[n]) ~= "function" then
          _G.PlayerSafeCallback[n] = function() return true end
        end
      end
      local PeerChecks = {
        "LuaIsCharacterStateValid",
        "LuaIsTwoCharacterValidToAccumulateTime",
        "LuaOnGetOnVehicle",
        "IsCheckPass1","IsCheckPass2","IsCheckPass5","IsCheckPass6","IsCheckPass7","IsCheckPass8","IsCheckPass11"
      }
      for _, n in ipairs(PeerChecks) do
        if type(_G.PlayerSafeCallback[n]) ~= "function" then
          _G.PlayerSafeCallback[n] = function() return true end
        end
      end
    end
  end)
  _G.MXP_LayerState.StateInstalled = true

end


function MXP_InstallCallback()
  if _G.MXP_LayerState.CallbackInstalled then
    return
  end

  -------------------------------------------------------------------------
  -- (1) GameplayCallbacks: sanitize punishment state only
  -------------------------------------------------------------------------
  local function MXP_HookGameplayCallbacks()
    if not _G.GameplayCallbacks then return end
    local GameplayCallbacks = _G.GameplayCallbacks
    if GameplayCallbacks.MXP_Hooked then return end
    GameplayCallbacks.MXP_Hooked = true
    local rawOnDSPlayerStateChanged = GameplayCallbacks.OnDSPlayerStateChanged
    local PunishSet = {
      cheatdetected=true, banned=true, imprison=true, imprisonment=true,
      hawkreported=true, hawkreport=true, punished=true, punish=true,
      kicked=true, suspended=true, forbidden=true, restricted=true,
      inspect=true, inspection=true, freezestart=true, freezestop=true,
      freezing=true, frozen=true, highrisk=true, securitypunish=true,
      securityban=true, devicepunish=true, riskcontrol=true,
      antisoftban=true, softban=true, watch=true, watching=true,
      reported=true, violation=true, abnormal=true
    }
    GameplayCallbacks.OnDSPlayerStateChanged = function(UID, State, Arg3, Arg4, Reason)
      if _G.MXP_SAFEMODE_LOGIN ~= true and type(State) == "string" then
        if PunishSet[string.lower(State)] then
          State = "Online"
          Reason = "SafeByMxPCode"
        end
      end
      if rawOnDSPlayerStateChanged then
        local ok, r1, r2, r3, r4, r5 = pcall(rawOnDSPlayerStateChanged, UID, State, Arg3, Arg4, Reason)
        if ok then return r1, r2, r3, r4, r5 end
        MXP_Runtime:SafeCall("GameplayCallbacks", "OnDSPlayerStateChanged", function() error(tostring(r1)) end)
      end
    end
    _G.MXP_HookRegistry["GameplayCallbacks.OnDSPlayerStateChanged"] = { Installed = true, Owner = "MXP", Current = GameplayCallbacks.OnDSPlayerStateChanged, Original = rawOnDSPlayerStateChanged }
    _G.MXP_OriginalFunctions["GameplayCallbacks.OnDSPlayerStateChanged"] = rawOnDSPlayerStateChanged

    local function ReturnTrue() return true end
    if _G.MXP_SAFEMODE_LOGIN ~= true then
      GameplayCallbacks.OnPlayerRPCValidateFailed = ReturnTrue
      GameplayCallbacks.RepListMismatchDetectTrigger = ReturnTrue
      GameplayCallbacks.SendDSHawkEyePatrolLogToLobby = ReturnTrue
      GameplayCallbacks.SendDSErrorLogToLobby = ReturnTrue
    end
    _G.MXP_HookRegistry["GameplayCallbacks.OnPlayerRPCValidateFailed"] = { Installed = true, Owner = "MXP" }
    _G.MXP_HookRegistry["GameplayCallbacks.RepListMismatchDetectTrigger"] = { Installed = true, Owner = "MXP" }
    _G.MXP_HookRegistry["GameplayCallbacks.SendDSHawkEyePatrolLogToLobby"] = { Installed = true, Owner = "MXP" }
    _G.MXP_HookRegistry["GameplayCallbacks.SendDSErrorLogToLobby"] = { Installed = true, Owner = "MXP" }
  end
  MXP_HookGameplayCallbacks()
  -- Re-arm periodically if GameplayCallbacks is loaded late or re-assigned.
  pcall(function()
    local tt = require("common.time_ticker")
    if tt and tt.AddTimerLoop then
      MXP_Runtime:RegisterTimer("Security.ReHookGameplayCallbacks", tt.AddTimerLoop(5.0, function()
        -- If the global callback was replaced by the game, re-install our wrapper.
        if _G.GameplayCallbacks then
          local current = _G.GameplayCallbacks.OnDSPlayerStateChanged
          local reg = MXP_HookRegistry["GameplayCallbacks.OnDSPlayerStateChanged"]
          if reg and current ~= reg.Current then
            MXP_HookGameplayCallbacks()
          end
        end
      end, -1, 5.0), "global", "Security")
    end
  end)
  _G.MXP_LayerState.CallbackInstalled = true

end


function MXP_InstallNetwork()
  if _G.MXP_LayerState.NetworkInstalled then
    return
  end

  -- Global unified blocklist. Merged with Telemetry extras at install time.
  _G.MXP_BlockedLobbyNames = _G.MXP_BlockedLobbyNames or {}
  local BlockedPkg = _G.MXP_BlockedLobbyNames
  local NewTelemetryPkgs = {
    report_shot_check_exception = true,
    log_shooting_miss = true,
    ds_err_report = true,
    ds_ugclua_err_report = true,
    report_unrealnet_exception = true,
    report_hawkeye_inspect = true,
    report_player_replay = true,
    report_anti_cheat_detail = true,
    report_client_behavior = true,
    report_gameguardian_trace = true,
    report_memory_scan = true,
    report_dll_injection = true,
    report_virtual_space = true,
    report_root_state = true,
    report_debug_bridge = true,
    report_abnormal_memory = true,
    report_screenshot = true,
    get_tss_anti_data_req = true,
    get_security_info_req = true,
    get_device_risk_req = true,
    get_behavior_risk_req = true,
    send_device_risk_info = true,
    send_behavior_risk_info = true,
    send_telemetry_batch = true,
    tss_sdk_data_req = true,
    tss_sdk_anti_data_req = true,
    report_security_alert = true,
    report_violation = true,
    client_trace = true,
    client_pak_report = true,
    suspicious_flag_req = true,
    get_ban_id_req = true,
    begin_hawkeye_inspect_req = true,
    ReportHawkeyeBanFlow = true,
    get_goslar_ban_info_req = true,
    goslar_ban_confirm_req = true,
    goslar_ban_draw_req = true,
    cheat_warn_reply = true,
    report_client_timeout_report_req = true,
  }
  for k, v in pairs(NewTelemetryPkgs) do
    BlockedPkg[k] = v
  end

  -------------------------------------------------------------------------
  -- (2) NetUtil.SendPacket selective block (DS channel)
  -------------------------------------------------------------------------
  local function MXP_HookSendPacket()
    if not (NetUtil and type(NetUtil.SendPacket) == "function") then return end
    if NetUtil._IsMxPCodeBypassed and NetUtil.SendPacket == NetUtil._MXP_SendPacketWrapper then return end
    local rawSendPacket = NetUtil._MXP_RawSendPacket or NetUtil.SendPacket
    NetUtil._MXP_RawSendPacket = rawSendPacket
    NetUtil._MXP_SendPacketWrapper = function(PacketName, ...)
      if _G.MXP_LogDiag then _G.MXP_LogDiag("netutil.sendpacket: checking: " .. tostring(PacketName)) end
      if _G.MXP_SAFEMODE_LOGIN == true then
        return rawSendPacket(PacketName, ...)
      end
      if type(PacketName) ~= "string" then
        return rawSendPacket(PacketName, ...)
      end
      if BlockedPkg[PacketName] then
        if _G.MXP_LogDiag then _G.MXP_LogDiag("netutil.sendpacket: blocked: " .. PacketName) end
        -- Return nil instead of true; engine expects nil/handle/object for blocked security paths.
        return nil
      end
      if PacketName == "on_tss_sdk_anti_data" then
        local Args = {...}
        if Args[2] == nil then
          Args[2] = "TSS_SECURE_PAYLOAD_VERIFIED_OK"
          Args[3] = #Args[2]
        end
        if type(Args[5]) == "table" then
          Args[5].ErrorCode = 0
          Args[5].ReportLog = 0
        end
        return rawSendPacket(PacketName, table.unpack(Args))
      end
      return rawSendPacket(PacketName, ...)
    end
    NetUtil.SendPacket = NetUtil._MXP_SendPacketWrapper
    NetUtil._IsMxPCodeBypassed = true
    _G.MXP_HookRegistry["NetUtil.SendPacket"] = { Installed = true, Owner = "MXP", Current = NetUtil.SendPacket, Original = rawSendPacket }
    _G.MXP_OriginalFunctions["NetUtil.SendPacket"] = rawSendPacket
  end
  MXP_HookSendPacket()

  -------------------------------------------------------------------------
  -- (2b) NetUtil.SendPkg lobby normalizer
  -------------------------------------------------------------------------
  local function MXP_HookSendPkg()
    if not (NetUtil and type(NetUtil.SendPkg) == "function") then return end
    if NetUtil._IsMxPCodeSendPkgBypassed and NetUtil.SendPkg == NetUtil._MXP_SendPkgWrapper then return end
    local rawSendPkg = NetUtil._MXP_RawSendPkg or NetUtil.SendPkg
    NetUtil._MXP_RawSendPkg = rawSendPkg
    NetUtil._MXP_SendPkgWrapper = function(MsgName, ...)
      if _G.MXP_LogDiag then _G.MXP_LogDiag("netutil.sendpkg: checking: " .. tostring(MsgName)) end
      if _G.MXP_SAFEMODE_LOGIN == true then
        return rawSendPkg(MsgName, ...)
      end
      if type(MsgName) ~= "string" then
        return rawSendPkg(MsgName, ...)
      end
      if BlockedPkg[MsgName] then
        if _G.MXP_LogDiag then _G.MXP_LogDiag("netutil.sendpkg: blocked: " .. MsgName) end
        -- Return 0 instead of true; engine expects numeric success or nil for blocked lobby send paths.
        return 0
      end
      -- Sanitize hisar device fingerprint supaya tetap terkirim tapi
      -- tidak bawa identitas asli.
      if MsgName == "hisar" then
        local Args = {...}
        if type(Args[3]) == "string" then
          Args[3] = (_G.MXP_HWIDString or "0"):sub(1,32)
        end
        if type(Args[4]) == "string" then
          Args[4] = (_G.MXP_HWIDString or "0"):sub(1,32)
        end
        return rawSendPkg(MsgName, table.unpack(Args))
      end
      return rawSendPkg(MsgName, ...)
    end
    NetUtil.SendPkg = NetUtil._MXP_SendPkgWrapper
    NetUtil._IsMxPCodeSendPkgBypassed = true
    _G.MXP_HookRegistry["NetUtil.SendPkg"] = { Installed = true, Owner = "MXP", Current = NetUtil.SendPkg, Original = rawSendPkg }
    _G.MXP_OriginalFunctions["NetUtil.SendPkg"] = rawSendPkg
  end
  MXP_HookSendPkg()
  local MXP_HookNetManagerSendPkg
  -- Re-arm periodically in case NetUtil table or functions are reassigned.
  pcall(function()
    local tt = require("common.time_ticker")
    if tt and tt.AddTimerLoop then
      MXP_Runtime:RegisterTimer("Security.ReHookNetwork", tt.AddTimerLoop(5.0, function()
        if NetUtil and NetUtil.SendPacket ~= NetUtil._MXP_SendPacketWrapper then
          MXP_HookSendPacket()
        end
        if NetUtil and NetUtil.SendPkg ~= NetUtil._MXP_SendPkgWrapper then
          MXP_HookSendPkg()
        end
        if NetManager and NetManager.SendPkg ~= NetManager._MXP_NMSendPkgWrapper then
          MXP_HookNetManagerSendPkg()
        end
      end, -1, 5.0), "global", "Security")
    end
  end)

  -------------------------------------------------------------------------
  -- (2b.3) NetManager.SendPkg(id, ...) third channel
  -- ----------------------------------------------------------------------
  local function MXP_HookNetManagerSendPkg()
    local NetManager = rawget(_G, "NetManager")
    if not (NetManager and type(NetManager.SendPkg) == "function") then return end
    if NetManager.MXP_SendPkgIdTrapped and NetManager.SendPkg == NetManager._MXP_NMSendPkgWrapper then return end
    local rawNMSendPkg = NetManager._MXP_RawNMSendPkg or NetManager.SendPkg
    NetManager._MXP_RawNMSendPkg = rawNMSendPkg
    local BlockedMsgIds = {
      [242463958] = true,  -- report_simulator_check (emulator detection)
      [446448067] = true,  -- get_ban_id_req
      [1149962314] = true, -- begin_hawkeye_inspect_req
      [1345216445] = true, -- ReportHawkeyeBanFlow
      [1637274787] = true, -- get_goslar_ban_info_req
    }
    local BlockedReqNames = _G.MXP_BlockedLobbyNames or {}
    NetManager._MXP_NMSendPkgWrapper = function(id, ...)
      local idStr = type(id) == "number" and tostring(id) or tostring(id)
      if _G.MXP_LogDiag then _G.MXP_LogDiag("netmanager: checking id: " .. idStr) end
      if _G.MXP_SAFEMODE_LOGIN == true then
        return rawNMSendPkg(id, ...)
      end
      local t = type(id)
      if t == "number" then
        if BlockedMsgIds[id] then
          if _G.MXP_LogDiag then _G.MXP_LogDiag("netmanager: blocked id: " .. idStr) end
          -- Return nil instead of true; engine expects nil/handle/object for blocked security send paths.
          return nil
        end
        local reqName = nil
        pcall(function()
          local NC = require("client.network.comm.NetConfig")
          local info = NC and NC.msgMap and NC.msgMap[id]
          reqName = info and info.req
        end)
        if type(reqName) == "string" and BlockedReqNames[reqName] then
          if _G.MXP_LogDiag then _G.MXP_LogDiag("netmanager: blocked req name: " .. reqName .. " (id " .. idStr .. ")") end
          return nil
        end
      elseif t == "string" and BlockedReqNames[id] then
        if _G.MXP_LogDiag then _G.MXP_LogDiag("netmanager: blocked string id: " .. idStr) end
        return nil
      end
      return rawNMSendPkg(id, ...)
    end
    NetManager.SendPkg = NetManager._MXP_NMSendPkgWrapper
    NetManager.MXP_SendPkgIdTrapped = true
    _G.MXP_HookRegistry["NetManager.SendPkg"] = { Installed = true, Owner = "MXP", Current = NetManager.SendPkg, Original = rawNMSendPkg }
    _G.MXP_OriginalFunctions["NetManager.SendPkg"] = rawNMSendPkg
  end
  MXP_HookNetManagerSendPkg()

  _G.MXP_LayerState.NetworkInstalled = true

end


function MXP_InstallPakUpdateBlocker()
  if _G.MXP_LayerState and _G.MXP_LayerState.PakUpdateBlockerInstalled then
    return
  end
  _G.MXP_LayerState = _G.MXP_LayerState or {}

  -------------------------------------------------------------------------
  -- (16) PAK / update / HTTP blocker v10.2
  -- Goal: stop runtime replacement of Lua/security/anti-cheat PAKs and
  --       block known security HTTP endpoints, while allowing normal
  --       map/audio/character/weapon/vehicle/outfit/skin/UI downloads.
  --
  -- We use an EXPLICIT allow-everything-then-block-security approach.
  -- Only paths/endpoints that explicitly mention security/Lua/TSS/Higgs/
  -- Gokuba/ban/anti-cheat/patch/hotfix/puffer/script payloads are blocked.
  -- Generic words like "update", "clientdata", "data", "version" are NOT
  -- blocked because they appear in normal content downloads.
  -------------------------------------------------------------------------
  local MXP_SecurityPathTokens = {
    "/lua/", "/script/", "/security/", "/tss/", "/anticheat/",
    "/gokuba/", "/higgs/", "/hades/", "/hawk/", "/ban/",
    "/replay/", "/death_replay/", "/puffer/", "/hotfix/",
    "gokuba", "higgsboson", "higgs_boson", "higgboson",
    "anticheat", "anti_cheat", "anti-cheat",
    "tersafe", "tss_sdk", "tssmanager", "tss_manager",
    "securitynotify", "security_notify",
    "banhandler", "ban_handler", "godzillaban",
    "pufferpatch", "puffer_patch",
    ".lua.pak", "_lua.pak", "/lua.pak",
    ".script.pak", "_script.pak", "/script.pak"
  }

  local function MXP_IsSecurityPath(path)
    if type(path) ~= "string" then return false end
    local lower = path:lower()
    for _, token in ipairs(MXP_SecurityPathTokens) do
      if lower:find(token:lower(), 1, true) then return true end
    end
    return false
  end

  local MXP_LoginUrlTokens = {
    "login", "auth", "account", "sdk", "channel", "lobby", "config",
    "serverlist", "version", "gate", "announcement", "notice", "terms",
    "privacy", "user", "player", "init", "startup", "guide"
  }
  local function MXP_IsLoginUrl(path)
    if type(path) ~= "string" then return false end
    local lower = path:lower()
    for _, token in ipairs(MXP_LoginUrlTokens) do
      if lower:find(token, 1, true) then return true end
    end
    return false
  end

  local function MXP_WrapDownload(raw)
    return function(pathOrUrl, ...)
      if _G.MXP_LogDiag then _G.MXP_LogDiag("http.download: checking: " .. tostring(pathOrUrl)) end
      if type(pathOrUrl) ~= "string" then
        return raw(pathOrUrl, ...)
      end
      if MXP_IsLoginUrl(pathOrUrl) then
        return raw(pathOrUrl, ...)
      end
      if MXP_IsSecurityPath(pathOrUrl) then
        if _G.MXP_LogDiag then _G.MXP_LogDiag("http.download: blocked: " .. pathOrUrl) end
        return nil
      end
      return raw(pathOrUrl, ...)
    end
  end

  local function MXP_WrapMethod(raw)
    return function(self, pathOrUrl, ...)
      if _G.MXP_LogDiag then _G.MXP_LogDiag("http.method: checking: " .. tostring(pathOrUrl)) end
      if type(pathOrUrl) ~= "string" then
        return raw(self, pathOrUrl, ...)
      end
      if MXP_IsLoginUrl(pathOrUrl) then
        return raw(self, pathOrUrl, ...)
      end
      if MXP_IsSecurityPath(pathOrUrl) then
        if _G.MXP_LogDiag then _G.MXP_LogDiag("http.method: blocked: " .. pathOrUrl) end
        return nil
      end
      return raw(self, pathOrUrl, ...)
    end
  end

  -- (16.1) Client.DownloadFile / UpdatePak / MountPak helpers
  pcall(function()
    local C = rawget(_G, "Client")
    if type(C) ~= "table" then return end
    local dlNames = {"DownloadFile", "UpdatePak", "DownloadAndMountPak", "MountPak", "UnmountPak", "LoadPak"}
    for _, name in ipairs(dlNames) do
      if type(C[name]) == "function" and not C["MXP_"..name.."Hooked"] then
        if _G.MXP_LogDiag then _G.MXP_LogDiag("client.method: wrapping download method: " .. name) end
        C["MXP_"..name.."Raw"] = C[name]
        C["MXP_"..name.."Hooked"] = true
        C[name] = MXP_WrapDownload(C["MXP_"..name.."Raw"])
      end
    end
  end)

  -- (16.2) PufferDownloader / GCPufferDownloader
  pcall(function()
    local PD = package.loaded["client.slua.logic.download.puffer.logic_puffer_downloader"] or rawget(_G, "PufferDownloader") or rawget(_G, "GCPufferDownloader")
    if type(PD) ~= "table" then return end
    if PD.MXP_PufferBlocked then return end
    PD.MXP_PufferBlocked = true
    for _, name in ipairs({"Download", "DownloadFile", "StartDownload", "RequestDownload", "UpdatePatch", "CheckAndDownload"}) do
      if type(PD[name]) == "function" then
        PD["MXP_"..name.."Raw"] = PD[name]
        PD[name] = MXP_WrapMethod(PD["MXP_"..name.."Raw"])
      end
    end
  end)

  -- (16.3) CDN / generic downloader tables
  pcall(function()
    local function MXP_TrapDownloaderTable(T)
      if type(T) ~= "table" or T.MXP_CDNBlocked then return end
      T.MXP_CDNBlocked = true
      for _, name in ipairs({"Download", "DownloadFile", "StartDownload", "RequestDownload", "Fetch", "Get", "Post", "Update"}) do
        if type(T[name]) == "function" then
          T["MXP_"..name.."Raw"] = T[name]
          T[name] = MXP_WrapMethod(T["MXP_"..name.."Raw"])
        end
      end
    end
    MXP_TrapDownloaderTable(rawget(_G, "CDNDownloader"))
    MXP_TrapDownloaderTable(rawget(_G, "CDNManager"))
    MXP_TrapDownloaderTable(rawget(_G, "DownloadManager"))
    MXP_TrapDownloaderTable(rawget(_G, "PakDownloader"))
    MXP_TrapDownloaderTable(rawget(_G, "PakFileManager"))
    MXP_TrapDownloaderTable(rawget(_G, "PakMountManager"))
  end)

  -- (16.4) HttpManager.Post / Get / Request / Download
  pcall(function()
    local HM = package.loaded["client.slua.logic.http.http_manager"] or rawget(_G, "HttpManager")
    if type(HM) ~= "table" or HM.MXP_HttpBlocked then return end
    HM.MXP_HttpBlocked = true
    for _, name in ipairs({"Post", "Get", "Request", "Download"}) do
      if type(HM[name]) == "function" then
        HM["MXP_"..name.."Raw"] = HM[name]
        HM[name] = MXP_WrapMethod(HM["MXP_"..name.."Raw"])
      end
    end
  end)

  -- (16.5) PakFileManager / PakMount operations
  pcall(function()
    local function MXP_TrapPakMountTable(T)
      if type(T) ~= "table" or T.MXP_PakMountBlocked then return end
      T.MXP_PakMountBlocked = true
      for _, name in ipairs({"MountPak", "UnmountPak", "Mount", "Unmount", "LoadPak", "UnloadPak", "AddPak", "RemovePak"}) do
        if type(T[name]) == "function" then
          T["MXP_"..name.."Raw"] = T[name]
          T[name] = MXP_WrapMethod(T["MXP_"..name.."Raw"])
        end
      end
    end
    MXP_TrapPakMountTable(rawget(_G, "PakFileManager"))
    MXP_TrapPakMountTable(rawget(_G, "PakMountManager"))
    MXP_TrapPakMountTable(rawget(_G, "PakManager"))
  end)

  -- (16.6) Protocol handlers: puffer/hades/posidon update channels
  -- These handlers are part of login/initial handshake; swallowing them hides login options.
  -- v12: single transparent passthrough wrapper per handler. Forward ALL return values
  -- on success; on error return nil. Guarded by one-time keys so re-arm never re-wraps.
  pcall(function()
    local function MXP_ForwardProtocol(raw, ...)
      if _G.MXP_LogDiag then _G.MXP_LogDiag("protocol: forward handler") end
      if type(raw) ~= "function" then return true end
      local rets = {pcall(raw, ...)}
      if not rets[1] then return true end
      local n = table.maxn(rets)
      if n <= 1 then return true end
      return table.unpack(rets, 2, n)
    end
    local function MXP_WrapOnce(tbl, name)
      if type(tbl) ~= "table" then return end
      if type(tbl[name]) ~= "function" then return end
      local key = "MXP_Protocol_" .. name .. "_Wrapped"
      if tbl[key] then return end
      tbl[key] = true
      tbl["MXP_" .. name .. "Raw"] = tbl[name]
      local raw = tbl[name]
      tbl[name] = function(...) return MXP_ForwardProtocol(raw, ...) end
    end
    local LH = package.loaded["client.network.Protocol.LobbyHandler"] or rawget(_G, "LobbyHandler")
    if type(LH) == "table" then
      for _, name in ipairs({"on_puffer_update", "on_on_puffer_update", "on_hades_update_rsp", "send_on_hades_update_rsp", "on_on_hades_update_ntf", "on_posidon_update_ntf"}) do
        MXP_WrapOnce(LH, name)
      end
    end
    local CEH = package.loaded["client.network.Protocol.ClientEntryHandler"] or rawget(_G, "ClientEntryHandler")
    if type(CEH) == "table" then
      MXP_WrapOnce(CEH, "on_send_client_data")
      MXP_WrapOnce(CEH, "on_on_send_client_data")
    end
  end)

  -- (16.7) Re-arm periodically because game may reassign these tables/functions.
  pcall(function()
    local tt = require("common.time_ticker")
    if tt and tt.AddTimerLoop and not _G.MXP_PakUpdateRearmHandle then
      _G.MXP_PakUpdateRearmHandle = tt.AddTimerLoop(5.0, function()
        _G.MXP_LayerState.PakUpdateBlockerInstalled = false
        pcall(MXP_InstallPakUpdateBlocker)
      end, -1, 5.0)
      if MXP_Runtime and MXP_Runtime.RegisterTimer then
        MXP_Runtime:RegisterTimer("Security.PakUpdateBlockerRearm", _G.MXP_PakUpdateRearmHandle, "global", "Security")
      end
    end
  end)

  _G.MXP_LayerState.PakUpdateBlockerInstalled = true
end


function MXP_InstallSecurity()
  if _G.MXP_LayerState.SecurityInstalled then
    return
  end

  -- ----------------------------------------------------------------------
  -- (3) Native verify-fail sinks: stop punish-counter increments
  -- ----------------------------------------------------------------------
  pcall(function()
    local LagCompensationComponent = import("LagCompensationComponent")
    if LagCompensationComponent then
      if LagCompensationComponent.RecordShootVerifyStatType then
        LagCompensationComponent.RecordShootVerifyStatType = function() end
      end
      if LagCompensationComponent.RecordShootVerifyFailed then
        LagCompensationComponent.RecordShootVerifyFailed = function() end
      end
    end
    local LagCompensationSubSystem = package.loaded["GameLua.Mod.BaseMod.DS.Weapon.LagCompensationSubSystem"]
    if not LagCompensationSubSystem then
      LagCompensationSubSystem = rawget(_G, "LagCompensationSubSystem")
    end
    if LagCompensationSubSystem then
      local raw = LagCompensationSubSystem.HandleShootVertifyLagcomBegin
      LagCompensationSubSystem.HandleShootVertifyLagcomBegin = function(self, a, b, uCharacter, uController)
        pcall(function()
          if raw then raw(self, a, b, uCharacter, uController) end
          local PC = slua.isValid(uCharacter) and uCharacter:GetController()
          if slua.isValid(PC) and PC.AntiCheatManagerComp then
            local am = PC.AntiCheatManagerComp
            if am.SwitchHitComponentUnvalid then
              local s = am.SwitchHitComponentUnvalid
              s.bShouldPunish = false
              s.PunishThresHold = 1e9
              am.SwitchHitComponentUnvalid = s
            end
            if am.SwitchHitOutCollisionBox then
              local s2 = am.SwitchHitOutCollisionBox
              s2.bShouldPunish = false
              s2.PunishThresHold = 1e9
              am.SwitchHitOutCollisionBox = s2
            end
          end
        end)
      end
    end
  end)

  -- (3a) Lua-side LuaShootVertifyInfo sanitizer: clear evidence fields
  pcall(function()
    local function SanitizeVertifyInfo(VertifyInfo)
      if type(VertifyInfo) == "userdata" and slua.isValid and slua.isValid(VertifyInfo) then
        pcall(function() VertifyInfo.VertifyRes = "Non" end)
        pcall(function() VertifyInfo.RecordSequenceIndex = 0 end)
        pcall(function() VertifyInfo.WeaponThroughWall = false end)
        pcall(function() VertifyInfo.BlockTime = 0 end)
        pcall(function() VertifyInfo.BlockActor = nil end)
        pcall(function() VertifyInfo.BlockComp = nil end)
      end
    end
    local CharacterBaseCls = rawget(_G, "CharacterBase")
    if type(CharacterBaseCls) == "table" and not CharacterBaseCls.MXP_VertifyInfoSanitized then
      CharacterBaseCls.MXP_VertifyInfoSanitized = true
      local rawShoot = CharacterBaseCls.Do_VerifyShoot
      if type(rawShoot) == "function" then
        CharacterBaseCls.Do_VerifyShoot = function(self, a, b, c, VertifyInfo, ...)
          SanitizeVertifyInfo(VertifyInfo)
          return rawShoot(self, a, b, c, VertifyInfo, ...)
        end
      end
      local rawHit = CharacterBaseCls.ServerHandleBulletHitData
      if type(rawHit) == "function" then
        CharacterBaseCls.ServerHandleBulletHitData = function(self, VertifyInfo, ...)
          SanitizeVertifyInfo(VertifyInfo)
          return rawHit(self, VertifyInfo, ...)
        end
      end
    end
  end)

  -- ----------------------------------------------------------------------
  -- (3b) Shoot-verify RPC + LagComp net-data suppression
  -- ----------------------------------------------------------------------
  pcall(function()
    if _G.MXP_ShootVerifyPatchDone then return end
    _G.MXP_ShootVerifyPatchDone = true
    local LagCompensationSubSystem = package.loaded["GameLua.Mod.BaseMod.DS.Weapon.LagCompensationSubSystem"]
    if not LagCompensationSubSystem then
      LagCompensationSubSystem = rawget(_G, "LagCompensationSubSystem")
    end
    if type(LagCompensationSubSystem) == "table" then
      LagCompensationSubSystem.AddShootNetWorkData = function() end
      local rawHandle = LagCompensationSubSystem.HandleShootNetWorkData
      LagCompensationSubSystem.HandleShootNetWorkData = function(self, _, __, ShooterUid, VertifyRes, PingDifType, IsShootCorner, IsAI)
        if rawHandle then
          local ok, r1, r2, r3, r4, r5 = pcall(rawHandle, self, _, __, ShooterUid, VertifyRes, PingDifType, IsShootCorner, IsAI)
          if ok then return r1, r2, r3, r4, r5 end
          MXP_Runtime:SafeCall("LagCompensation", "HandleShootNetWorkData", function() error(tostring(r1)) end)
        end
      end
      LagCompensationSubSystem.NetWorkMap = nil
      if not LagCompensationSubSystem.MXP_NetWorkDataTimerGuarded then
        LagCompensationSubSystem.MXP_NetWorkDataTimerGuarded = true
        LagCompensationSubSystem.ConditionCreateNetWorkDataTimer = function() end
        LagCompensationSubSystem.ConditionSendShootNetWorkData = function(self)
          self.NetWorkMap = nil
        end
      end
    end
    local function MXP_HookCharacterBaseDevCheck()
      local CharacterBaseCls = rawget(_G, "CharacterBase")
      if type(CharacterBaseCls) == "table" and type(CharacterBaseCls.DevelopmentClientCheck) == "function"
         and not CharacterBaseCls.MXP_DevCheckHooked then
        CharacterBaseCls.MXP_DevCheckHooked = true
        CharacterBaseCls.DevelopmentClientCheck = function(self) end
      end
    end
    MXP_HookCharacterBaseDevCheck()
    _G.MXP_HookCharacterBaseDevCheck = MXP_HookCharacterBaseDevCheck
    local PlayerAntiCheatManager = import("PlayerAntiCheatManager")
    if PlayerAntiCheatManager and type(PlayerAntiCheatManager.PushWeaponAntiData) == "function" then
      PlayerAntiCheatManager.PushWeaponAntiData = function() end
    end
  end)

  -- ----------------------------------------------------------------------
  -- (4) ServerPlayerDataMgr scrub (ban/suspicious flags)
  -- ----------------------------------------------------------------------
  pcall(function()
    local ServerPlayerDataMgr = package.loaded["Server.Data.ServerPlayerDataMgr"] or rawget(_G, "ServerPlayerDataMgr")
    if ServerPlayerDataMgr and ServerPlayerDataMgr.GetPlayerInfo then
      local rawGetPlayerInfo = ServerPlayerDataMgr.GetPlayerInfo
      ServerPlayerDataMgr.GetPlayerInfo = function(UID)
        local PlayerInfo = rawGetPlayerInfo(UID)
        if type(PlayerInfo) == "table" then
          local Scrubbed = {}
          for k, v in pairs(PlayerInfo) do Scrubbed[k] = v end
          Scrubbed.suspicious_flag = 0
          Scrubbed.avatar_err_report = false
          Scrubbed.ban = nil
          Scrubbed.imprison = nil
          if type(Scrubbed.ext_attr) == "table" then
            Scrubbed.ext_attr[2] = 0
          end
          PlayerInfo = Scrubbed
        end
        return PlayerInfo
      end
    end
  end)

  -- ----------------------------------------------------------------------
  -- (5) Security subsystem output silence (surgical)
  -- ----------------------------------------------------------------------
  pcall(function()
    local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    if SubsystemMgr then
      local SubsystemNames = {
        "DSHawkEyePatrolSubsystem", "ClientHawkEyePatrolSubsystem",
        "ShootVerifySubSystemClient", "WeaponRecordSubSystem",
        "AvatarExceptionSubsystem", "FileCheckSubsystem",
        "SpeedCheckSubsystem", "WallCheckSubsystem",
        "ClientReportPlayerSubsystem", "DSReportPlayerSubsystem",
        "DSSecurityNotifySystem", "DSSecurityTLogSubsystem",
        "DSBanLogic", "KillFrequencyLimiter",
        "DSIllegalTeamUpSystem", "SecurityNotifyPCFeature",
        "DSPVSSubsystem", "DSGlueHiaSystem", "ClientGlueHiaSystem",
        "DSMaliciousTeammateDetectionSubsystem", "DSQuickReportMaliciousTeammate",
        "ClientQuickReportMaliciousTeammate", "NearbyButNoFireSystem",
        "GetOnEnemyVehicleSystem", "UseObjectTogetherSystem",
        "ClientInGameCreditLogic", "DSCreditTLogSubsystem"
      }
      for _, SubsystemName in ipairs(SubsystemNames) do
        local Subsystem = SubsystemMgr:Get(SubsystemName)
        if Subsystem then
          for FuncName, FuncValue in pairs(Subsystem) do
            if type(FuncValue) == "function" then
              if string.find(FuncName, "Report") or string.find(FuncName, "Send") or string.find(FuncName, "Check") or string.find(FuncName, "Retrieve") then
                Subsystem[FuncName] = function() return {} end
              end
            end
          end
        end
      end
    end
  end)

  -- Direct no-ops for known high-risk standalone security modules.
  pcall(function()
    local KillFrequencyLimiter = package.loaded["GameLua.Mod.BaseMod.DS.Security.KillFrequencyLimiter"] or rawget(_G, "KillFrequencyLimiter")
    if type(KillFrequencyLimiter) == "table" and not KillFrequencyLimiter.MXP_Neutralized then
      KillFrequencyLimiter.MXP_Neutralized = true
      for k, v in pairs(KillFrequencyLimiter) do
        if type(v) == "function" then
          pcall(function() KillFrequencyLimiter[k] = function() return true end end)
        end
      end
    end
  end)
  -- ReplayRecordManager neutralization consolidated into MXP_InstallDeepSubsystemSilence.
  -- SecurityNotifyPCFeature neutralization consolidated into MXP_InstallDeepSubsystemSilence.

  -- ----------------------------------------------------------------------
  -- (6) TSS / device identity getters
  -- ----------------------------------------------------------------------
  pcall(function()
    local function MXP_HookTssGetUserTag()
      local T = rawget(_G, "Tss") or rawget(_G, "TssManager")
      if not T then return false end
      if T.MXP_GetUserTagHooked then return true end
      local Raw = rawget(T, "GetUserTag4Lua")
      if type(Raw) ~= "function" then return false end
      if not rawget(T, "MXP_RawGetUserTag4Lua") then
        T.MXP_RawGetUserTag4Lua = Raw
      end
      -- return plausible stable safe tag instead of nil
      pcall(function() T.GetUserTag4Lua = function() return "0" end end)
      T.MXP_GetUserTagHooked = true
      pcall(function() T.SendSkdData = function() end end)
      pcall(function() T.OnRecvData = function() end end)
      pcall(function() T.GetSDKAntiData = function() return "" end end)
      pcall(function() T.SetUserTag = function() end end)
      if type(rawget(T, "EigenArrayObfuscationVerify")) == "function" and not T.MXP_EigenHooked then
        T.MXP_EigenHooked = true
        pcall(function() T.EigenArrayObfuscationVerify = function() return 0 end end)
      end

      return true
    end
    if not MXP_HookTssGetUserTag() then
      pcall(function()
        local tt = require("common.time_ticker")
        if tt and tt.AddTimerLoop then
          MXP_Runtime:RegisterTimer("Security.HookTssGetUserTag", tt.AddTimerLoop(2.0, function() MXP_HookTssGetUserTag() end, 30, 2.0), "global", "Security")
        end
      end)
    end
  end)
  pcall(function()
    local function MXP_HookTssGetDeviceFeature()
      local T = rawget(_G, "Tss") or rawget(_G, "TssManager")
      if not T then return false end
      if T.MXP_GetDeviceFeatureHooked then return true end
      if type(rawget(T, "GetDeviceFeature")) ~= "function" then return false end
      pcall(function() T.GetDeviceFeature = function() return 0 end end)
      T.MXP_GetDeviceFeatureHooked = true
      return true
    end
    if not MXP_HookTssGetDeviceFeature() then
      pcall(function()
        local tt = require("common.time_ticker")
        if tt and tt.AddTimerLoop then
          MXP_Runtime:RegisterTimer("Security.HookTssGetDeviceFeature", tt.AddTimerLoop(2.0, function() MXP_HookTssGetDeviceFeature() end, 30, 2.0), "global", "Security")
        end
      end)
    end
  end)

  -- ----------------------------------------------------------------------
  -- (7) Gokuba / HiggsBoson / SecurityNotifyPCFeature
  -- ----------------------------------------------------------------------
  -- SecurityNotifyPCFeature now handled above with full table neutralization.
  -- GokubaLogic neutralization consolidated into MXP_TrapGokuba below.
  -- Higgs neutralization consolidated into MXP_InstallHiggsSpoof; do not duplicate here.
  pcall(function()
    local CSDB = package.loaded["client.slua.umg.crew.crew_safety_detection_base"]
    if type(CSDB) == "table" and not CSDB.MXP_Neutralized then
      CSDB.MXP_Neutralized = true
      if type(CSDB.PerformCheckWithObfuscation) == "function" then
        CSDB.PerformCheckWithObfuscation = function() return 0 end
      end
      if type(CSDB.PerformCheck) == "function" then
        CSDB.PerformCheck = function() return 0 end
      end
    end
  end)
  pcall(function()
    local Skip = package.loaded["GameLua.Mod.BaseMod.Common.Security.HiggsBosonSkipRules"] or rawget(_G, "HiggsBosonSkipRules")
    if type(Skip) == "table" and not Skip.MXP_Neutralized then
      Skip.MXP_Neutralized = true
      for k, v in pairs(Skip) do
        if type(v) == "function" then
          pcall(function() Skip[k] = function() return true end end)
        end
      end
    end
  end)

  -- ----------------------------------------------------------------------
  -- (7.5) Exact TSS/TssManager neutralization with re-arm on assignment
  -- ----------------------------------------------------------------------
  local function MXP_NeutralizeTssExact(T)
    if type(T) ~= "table" then return false end
    if T.MXP_NeutralizeTssExactDone and T.MXP_NeutralizeTssExactVersion == 2 then return true end
    T.MXP_NeutralizeTssExactDone = true
    T.MXP_NeutralizeTssExactVersion = 2
    local function Kill(name, ret)
      if type(rawget(T, name)) == "function" and not T["MXP_Exact_"..name.."Killed"] then
        T["MXP_Exact_"..name.."Killed"] = true
        pcall(function() T[name] = function(...) return ret end end)
      end
    end
    local function KillAll(names, ret)
      for _, name in ipairs(names) do Kill(name, ret) end
    end
    KillAll({"GetUserTag4Lua","GetSDKAntiData","GetDeviceFeature","GetUserTag"}, "0")
    KillAll({"SendSkdData","OnRecvData","SetUserTag","InvokeSDKIoctl","ioctl","Ioctl",
             "init","Init","initEx","InitEx","initAsync","InitAsync","setUserInfo","SetUserInfo",
             "report","Report","sendData","SendData","sendAntiData","SendAntiData","setInfo","SetInfo",
             "heartbeat","Heartbeat","setToken","SetToken","setOpenId","SetOpenId",
             "onResume","OnResume","onPause","OnPause","onForeground","OnForeground",
             "onBackground","OnBackground","onTssEvent","OnTssEvent","sendDataAsync","SendDataAsync"}, 0)
    if type(rawget(T, "EigenArrayObfuscationVerify")) == "function" and not T.MXP_EigenExactHooked then
      T.MXP_EigenExactHooked = true
      pcall(function() T.EigenArrayObfuscationVerify = function() return 0 end end)
    end
    if type(T.SetUserInfoAsync) == "function" and not T.MXP_SetUserInfoAsyncHooked then
      T.MXP_SetUserInfoAsyncHooked = true
      pcall(function() T.SetUserInfoAsync = function() end end)
    end
    if type(T.GetTssAntiData) == "function" and not T.MXP_GetTssAntiDataHooked then
      T.MXP_GetTssAntiDataHooked = true
      pcall(function() T.GetTssAntiData = function() return "" end end)
    end
    -- Wipe any cached state tables that may carry flags.
    for _, key in ipairs({"UserTag","DeviceFeature","SDKAntiData","AntiData","TssData","LastData"}) do
      pcall(function() rawset(T, key, nil) end)
    end
    return true
  end
  local function MXP_ReArmTssOnAssignment()
    local tssGlobals = {"Tss","TssManager","TssSDK"}
    for _, gname in ipairs(tssGlobals) do
      local T = rawget(_G, gname)
      if type(T) == "table" then
        if not T.MXP_NeutralizeTssExactDone or T.MXP_NeutralizeTssExactVersion ~= 2 then
          MXP_NeutralizeTssExact(T)
        end
      end
    end
  end
  MXP_ReArmTssOnAssignment()
  pcall(function()
    local tt = require("common.time_ticker")
    if tt and tt.AddTimerLoop then
      MXP_Runtime:RegisterTimer("Security.NeutralizeTssExact", tt.AddTimerLoop(2.0, MXP_ReArmTssOnAssignment, -1, 2.0), "global", "Security")
    end
  end)

  -- ----------------------------------------------------------------------
  -- (7.6) Trap GokubaLogic late load with retry timer
  -- ----------------------------------------------------------------------
  local function MXP_TrapGokuba()
    local GokubaLogic = package.loaded["GameLua.Mod.BaseMod.Client.Security.Gokuba"] or rawget(_G, "GokubaLogic")
    if type(GokubaLogic) ~= "table" then return false end
    if GokubaLogic.MXP_TrapGokubaDone then return true end
    GokubaLogic.MXP_TrapGokubaDone = true
    local kill = {"ForwardFeature","InitGokubaLogic","OnControllerBeginPlay","Update","LateUpdate",
                  "Tick","OnBeginPlay","OnEndPlay","CollectFeature","SendFeature","ReportFeature",
                  "OnCrowUpdate","OnCrowUpdateNtf","OnCrowUpdateNtf2","OnCrowUpdateNtf3",
                  "OnCrowUpdateNtf4","OnCrowUpdateNtf5"}
    for _, name in ipairs(kill) do
      if type(GokubaLogic[name]) == "function" then
        pcall(function() GokubaLogic[name] = function() end end)
      end
    end
    if type(GokubaLogic.ClientRPC) == "table" then
      for k, v in pairs(GokubaLogic.ClientRPC) do
        if type(v) == "function" then
          pcall(function() GokubaLogic.ClientRPC[k] = function() end end)
        end
      end
    end
    return true
  end
  if not MXP_TrapGokuba() then
    pcall(function()
      local tt = require("common.time_ticker")
      if tt and tt.AddTimerLoop then
        MXP_Runtime:RegisterTimer("Security.TrapGokuba", tt.AddTimerLoop(2.0, function() if MXP_TrapGokuba() then return end end, 60, 2.0), "global", "Security")
      end
    end)
  end

  -- ----------------------------------------------------------------------
  -- (8) slua / loader integrity stubs
  -- ----------------------------------------------------------------------
  -- NEVER forge signature values; it corrupts engine crypto during login.
  -- Only neutralize verification functions below.
  local slua_loader = package.loaded["slua.loader"] or rawget(_G, "slua_loader")
  if slua_loader then
    slua_loader.verifyBytecode = function() return true end
    slua_loader.checkIntegrity = function() return true end
    if slua_loader.disableSignatureCheck then
      slua_loader.disableSignatureCheck = function() return true end
    end
  end
  _G.MXP_LayerState.SecurityInstalled = true

end


local function MXP_ShieldLagComp(uCharacter)
    if not (slua and slua.isValid and type(uCharacter) == "userdata" and slua.isValid(uCharacter)) then return end
    local LagCompensationComponent = uCharacter.LagCompensationComponent
    if not (LagCompensationComponent and slua.isValid(LagCompensationComponent)) then return end
    pcall(function()
      LagCompensationComponent.TolerateHitDataDelayTime = 1.2
      LagCompensationComponent.TolerateHitDataDelayTimeShootCorner = 0.2
      LagCompensationComponent.TolerateShootRange = 999999
      LagCompensationComponent.TolerateMuzzleDistanceSqured = 999999
      LagCompensationComponent.TolerateMuzzleDistanceVehicleSqured = 999999
      LagCompensationComponent.TolerateShootPointDistanceSqured = 989999
      LagCompensationComponent.TolerateShootPointDistanceVehicleSqured = 989999
      LagCompensationComponent.TolerateBulletImpactOffsetDistSqured = 999999
      LagCompensationComponent.TolerateBulletDirOffsetSquared = 999999
      LagCompensationComponent.TolerateBulletDirCheckDistance = 999999
      LagCompensationComponent.TolerateFlyDis = 999999
      LagCompensationComponent.TolerateCharacterDis = 999999
      LagCompensationComponent.TolerateVehicleDis = 999999
      LagCompensationComponent.TolerateMaxVictmPosDis = 999999
      LagCompensationComponent.TolerateOwnerAndBulletDist = 999999
      LagCompensationComponent.TolerateNetDelay = 999999
      LagCompensationComponent.MaxTolerateCharacterDis = 999999
      LagCompensationComponent.MaxTolerateVehicleDis = 999999
      LagCompensationComponent.MaxGunPosLength = 999999
      LagCompensationComponent.MaxGunPosZHeight = 999999
      LagCompensationComponent.MaxCharacterSpeed = 999999
      LagCompensationComponent.MaxVehicleSpeed = 999999
    end)
    local VerifySwitchNames = {
      "bVerifyBlock", "bVerifyGunPos", "bVerifyClientMuzzle", "bVerifyShootRange",
      "bVerifyShootDir", "bVerifyMuzzleImpactDir", "bVerifyShootPosInHistory",
      "bVerifyMuzzleLocus", "bVerifyShootPoint", "bVerifyBulletImpactOffset",
      "bVerifyClientHitAndBullet", "bVerifyCharacterImpactOffset",
      "bVerifyInParachuteShootPoint", "bVerifyShooterHead2PosIsBlock",
      "bVerifyClientHitCheck"
    }
    for _, VerifyName in ipairs(VerifySwitchNames) do
      pcall(function() LagCompensationComponent[VerifyName] = false end)
    end
  end


local function MXP_ShieldMoveAntiCheat(uCharacter)
    if not (slua and slua.isValid and type(uCharacter) == "userdata" and slua.isValid(uCharacter)) then return end
    local MoveAntiCheatComponent = uCharacter.MoveAntiCheatComponent
    if not (MoveAntiCheatComponent and slua.isValid(MoveAntiCheatComponent)) then return end
    pcall(function() MoveAntiCheatComponent.bUseMoveAntiCheatCheck = false end)
    pcall(function() MoveAntiCheatComponent.IsOpenRTPunish = false end)
    pcall(function() MoveAntiCheatComponent.MaxTotalMoveCheatTimes = 0 end)
    pcall(function() MoveAntiCheatComponent.MaxTotalPassWallTimes = 0 end)
    pcall(function() MoveAntiCheatComponent.TolerateDistanceFractor = 999.0 end)
    pcall(function() MoveAntiCheatComponent.MaxJumpHeight = 999999 end)
    pcall(function() MoveAntiCheatComponent.JumpHeightTolerance = 999999 end)
    if type(slua.IndexReference) == "function" then
      pcall(function()
        local Strategy = slua.IndexReference(MoveAntiCheatComponent, "MoveCheatAntiStrategy3")
        if type(Strategy) ~= "table" then return end
        Strategy.bIsOpen = 0
        Strategy.bIgnoreCheck = 1
        Strategy.MaxAllowCheatMoveTimes = 0
        Strategy.MaxContinuousCheatMoveTimes = 0
        Strategy.MaxMoveSpeedValue = 0
        Strategy.MaxClientSpeed = 0
      end)
    end
  end


local function MXP_ShieldWeaponAntiCheat(uCharacter)
    if not (slua and slua.isValid and type(uCharacter) == "userdata" and slua.isValid(uCharacter)) then return end
    local ok_wm, WeaponManager = pcall(function() return uCharacter:GetWeaponManager() end)
    if not (ok_wm and WeaponManager and slua.isValid(WeaponManager)) then return end
    local Weapons = nil
    pcall(function()
      if type(WeaponManager.GetAllInventoryWeaponList) == "function" then
        Weapons = WeaponManager:GetAllInventoryWeaponList(false)
      end
    end)
    local function DisarmWeapon(Weapon)
      if not (Weapon and slua.isValid(Weapon)) then return end
      local AC = nil
      pcall(function() AC = Weapon.AntiCheatComp end)
      if not (AC and slua.isValid(AC)) then return end
      pcall(function() AC.ShootRateCheckTag = false end)
      pcall(function() AC.bVerifyTimeLineSync = false end)
      pcall(function() AC.bVerifyStartFireTime = false end)
      pcall(function() AC.ShootRateCheckInterval = 0 end)
      pcall(function() AC.ShootRateCheckMulCoff = 0 end)
      pcall(function() AC.ShootTimeMuzzleDistThres = 999999 end)
      pcall(function() AC.ShootTimeMuzzleZThres = 999999 end)
      pcall(function() AC.ShootTimeConnectionDeltaThres = 999999 end)
      pcall(function() AC.MaxShootPassTimeDeltaBetweenSysAndLevel = 999999 end)
      pcall(function() AC.TimeLineCheckDnBorder = -999999 end)
      pcall(function() AC.TimeLineCheckUpBorder = 999999 end)
    end
    if Weapons then
      local Count = 0
      pcall(function() Count = #Weapons end)
      if Count > 0 then
        for i = 1, Count do pcall(DisarmWeapon, Weapons[i]) end
      else
        for _, Weapon in pairs(Weapons) do pcall(DisarmWeapon, Weapon) end
      end
    end
    pcall(function() DisarmWeapon(uCharacter:GetCurrentWeapon()) end)
    pcall(function() DisarmWeapon(WeaponManager.CurrentWeaponReplicated) end)
  end


local function MXP_ShieldAntiCheatManager(uCharacter, bDeep)
    if not (slua and slua.isValid and type(uCharacter) == "userdata" and slua.isValid(uCharacter)) then return end
    local PC = nil
    pcall(function() PC = uCharacter:GetController() end)
    if not (PC and slua.isValid(PC)) then return end
    local AC = nil
    pcall(function() AC = PC.AntiCheatManagerComp end)
    if not (AC and slua.isValid(AC)) then return end
    local VerifySwitchFields = {
      "SwitchHitComponentUnvalid", "SwitchHitOutCollisionBox",
      "SwitchHitNoRender", "SwitchInvalidBulletNumInBarrel",
      "SwitchMuzzleImpactDirError1", "SwitchMuzzleImpactDirError2",
      "SwitchMuzzleImpactDirError3", "SwitchMuzzleLocusError",
      "SwitchShootDirExcepation1", "SwitchShootDirExcepation2",
      "SwitchShooterMovementError2", "ClientWeaponFastReload",
      "ContinueMoveBurst", "ServerMoveBurst", "ServerMoveAccel",
      "ServerAccumulateErrorBurst", "ClientTimestampBurst",
      "ClientUploadFuzzyObjectVerifyFail"
    }
    for _, FieldName in ipairs(VerifySwitchFields) do
      pcall(function()
        local Ref = slua.IndexReference(AC, FieldName)
        if type(Ref) == "table" then
          Ref.PunishThresHold = 999999
          Ref.bShouldPunish = false
          Ref.VerifyFailedCnt = 0
        end
      end)
    end
    pcall(function()
      -- Direct scalar counters are not FVerifySwitch structs; reset separately.
      local ScalarCounters = {
        "AutoAimFailedCnt", "TrackingFailedCnt", "AreaDamageFailedCnt",
        "ShootVerifyTimes", "bReportFeedBack", "bOpenDetailDataCollect"
      }
      for _, FieldName in ipairs(ScalarCounters) do
        pcall(function()
          local t = type(AC[FieldName])
          if t == "number" then AC[FieldName] = 0 end
          if t == "boolean" then AC[FieldName] = false end
        end)
      end
    end)
    pcall(function()
      -- Deep scan: flatten all named switch/tolerance structures and clear counters.
      if not bDeep then return end
      local KeyWords = { "Switch", "Verify", "Punish", "Threshold", "ThresHold", "FailedCnt", "CheatCnt", "Abnormal" }
      for k, _ in pairs(AC) do
        if type(k) == "string" then
          for _, kw in ipairs(KeyWords) do
            if k:find(kw, 1, true) then
              pcall(function()
                local Ref = slua.IndexReference(AC, k)
                if type(Ref) == "table" then
                  if Ref.bShouldPunish ~= nil then Ref.bShouldPunish = false end
                  if Ref.PunishThresHold ~= nil then Ref.PunishThresHold = 999999 end
                  if Ref.VerifyFailedCnt ~= nil then Ref.VerifyFailedCnt = 0 end
                elseif type(Ref) == "boolean" then
                  AC[k] = false
                elseif type(Ref) == "number" and Ref > 0 then
                  AC[k] = 0
                end
              end)
              break
            end
          end
        end
      end
    end)
    pcall(function()
      if type(AC.ReportAntiCheatDetailData) == "function" then
        AC.ReportAntiCheatDetailData = function() end
      end
    end)
  end


function MXP_InstallNativeShield()
  if _G.MXP_LayerState.NativeShieldInstalled then
    return
  end

  -- ----------------------------------------------------------------------
  -- (9) Native shields: run ONCE per local character, not on timer storm
  -- ----------------------------------------------------------------------
  
  
  
  
  _G.MXP_NativeShields = {
    LagComp = MXP_ShieldLagComp,
    MoveAntiCheat = MXP_ShieldMoveAntiCheat,
    WeaponAntiCheat = MXP_ShieldWeaponAntiCheat,
    AntiCheatManager = MXP_ShieldAntiCheatManager
  }
  _G.MXP_LayerState.NativeShieldInstalled = true

end


function MXP_InstallDevice()
  if _G.MXP_LayerState.DeviceInstalled then
    return
  end

  -- ----------------------------------------------------------------------
  -- (10) Emulator / device fingerprint normalizer
  -- ----------------------------------------------------------------------
  pcall(function()
    -- Per-device plausible identity: deterministic but variable per HWID seed.
    local function MakePlausibleDeviceID(seed)
      local hex = "0123456789abcdef"
      local out = {}
      local s = seed % 0xFFFFFFFF
      for i = 1, 16 do
        s = (s * 0x9E3779B9 + i) % 0xFFFFFFFF
        local b = s % 16
        out[i] = hex:sub(b + 1, b + 1)
      end
      return table.concat(out)
    end
    local function MakePlausibleMAC(seed)
      local hex = "0123456789ABCDEF"
      local out = {}
      local s = seed % 0xFFFFFFFF
      for i = 1, 6 do
        s = (s * 0x9E3779B9 + i) % 0xFFFFFFFF
        local b = s % 256
        out[i] = hex:sub(math.floor(b / 16) + 1, math.floor(b / 16) + 1) .. hex:sub(b % 16 + 1, b % 16 + 1)
      end
      return table.concat(out, ":")
    end
    local function MakePlausibleIMEI(seed)
      local digits = "0123456789"
      local out = {}
      local s = seed % 0xFFFFFFFF
      for i = 1, 15 do
        s = (s * 0x9E3779B9 + i) % 0xFFFFFFFF
        local b = s % 10
        out[i] = digits:sub(b + 1, b + 1)
      end
      return table.concat(out)
    end
    local hwidSeed = tonumber(tostring(_G.MXP_HWIDString or ""):sub(-8), 16) or 0
    _G.MXP_PhoneDeviceID = _G.MXP_PhoneDeviceID or MakePlausibleDeviceID(hwidSeed)
    _G.MXP_PhoneMAC = _G.MXP_PhoneMAC or MakePlausibleMAC(hwidSeed)
    _G.MXP_PhoneIMEI = _G.MXP_PhoneIMEI or MakePlausibleIMEI(hwidSeed)
    _G.MXP_AndroidID = _G.MXP_AndroidID or _G.MXP_PhoneDeviceID
    _G.MXP_SerialNumber = _G.MXP_SerialNumber or _G.MXP_PhoneDeviceID
    _G.MXP_OAID = _G.MXP_OAID or _G.MXP_HWIDString or "0"
    _G.MXP_SubscriberId = _G.MXP_SubscriberId or _G.MXP_PhoneIMEI
    _G.MXP_SimSerialNumber = _G.MXP_SimSerialNumber or _G.MXP_PhoneIMEI
    if Client and type(Client.GetEmulatorName) == "function" and not Client.MXP_EmulatorNameHooked then
      Client.MXP_EmulatorNameHooked = true
      Client.GetEmulatorName = function() return "NoEmulator" end
    end
    if Client and type(Client.IsEmulator) == "function" and not Client.MXP_IsEmulatorHooked then
      Client.MXP_IsEmulatorHooked = true
      Client.IsEmulator = function() return false end
    end
    if Client and type(Client.IsDeviceRooted) == "function" and not Client.MXP_RootedHooked then
      Client.MXP_RootedHooked = true
      Client.IsDeviceRooted = function() return false end
    end
    if Client and type(Client.GetPhoneDeviceID) == "function" and not Client.MXP_DeviceIDHooked then
      Client.MXP_DeviceIDHooked = true
      Client.GetPhoneDeviceID = function()
        return _G.MXP_PhoneDeviceID or "0000000000000000"
      end
    end
    if Client and type(Client.GetAndroidID) == "function" and not Client.MXP_AndroidIDHooked then
      Client.MXP_AndroidIDHooked = true
      Client.GetAndroidID = function()
        return _G.MXP_AndroidID or "0000000000000000"
      end
    end
    if Client and type(Client.GetMacAddress) == "function" and not Client.MXP_MacHooked then
      Client.MXP_MacHooked = true
      Client.GetMacAddress = function()
        return _G.MXP_PhoneMAC or "02:00:00:00:00:00"
      end
    end
    if Client and type(Client.GetIMEI) == "function" and not Client.MXP_IMEIHooked then
      Client.MXP_IMEIHooked = true
      Client.GetIMEI = function()
        return _G.MXP_PhoneIMEI or "000000000000000"
      end
    end
    if Client and type(Client.GetOAID) == "function" and not Client.MXP_OAIDHooked then
      Client.MXP_OAIDHooked = true
      Client.GetOAID = function()
        return _G.MXP_OAID or "0"
      end
    end
    if Client and type(Client.GetSerialNumber) == "function" and not Client.MXP_SerialHooked then
      Client.MXP_SerialHooked = true
      Client.GetSerialNumber = function()
        return _G.MXP_SerialNumber or "0000000000000000"
      end
    end
    local esc = package.loaded["client.logic.login.emulator_scanner"] or rawget(_G, "emulator_scanner")
    if type(esc) == "table" and type(esc.find_emulator) == "function" and not esc.MXP_Hooked then
      esc.MXP_Hooked = true
      esc.find_emulator = function() return false, "NoEmulator" end
    end
    local function MXP_TrapEmulatorReport()
      local EH = package.loaded["client.network.Protocol.EmulatorHandler"] or rawget(_G, "EmulatorHandler")
      if type(EH) == "table" and type(EH.send_report_simulator_check) == "function" and not EH.MXP_ReportTrapped then
        EH.MXP_ReportTrapped = true
        EH.send_report_simulator_check = function() end
      end
    end
    if not MXP_TrapEmulatorReport() then
      pcall(function()
        local tt = require("common.time_ticker")
        if tt and tt.AddTimerLoop then
          MXP_Runtime:RegisterTimer("Security.TrapEmulatorReport", tt.AddTimerLoop(2.0, function() MXP_TrapEmulatorReport() end, 30, 2.0), "global", "Security")
        end
      end)
    end
  end)
  _G.MXP_LayerState.DeviceInstalled = true

end


function MXP_InstallTelemetry()
  if _G.MXP_LayerState.TelemetryInstalled then
    return
  end

  -- ----------------------------------------------------------------------
  -- (11) APM / GEM report filter for gokuba/tss/eigeninfo
  -- ----------------------------------------------------------------------
  pcall(function()
    local gru = package.loaded["client.logic.store.gem_report_utils"] or rawget(_G, "gem_report_utils")
    if gru and type(gru.ReportEventImmediate) == "function" and not gru.MXP_GokubaSinked then
      gru.MXP_GokubaSinked = true
      local rawReport = gru.ReportEventImmediate
      gru.ReportEventImmediate = function(eventName, subEventName, ...)
        if type(eventName) == "string" then
          local lower = eventName:lower()
          if lower:find("gokuba") or lower:find("tss") or lower:find("eigeninfo") then
            return
          end
        end
        return rawReport(eventName, subEventName, ...)
      end
    end
    if Client and type(Client.GEMReportSubEvent) == "function" and not Client.MXP_GEMReportTrapped then
      Client.MXP_GEMReportTrapped = true
      local rawGEM = Client.GEMReportSubEvent
      Client.GEMReportSubEvent = function(hud, eventName, subEvent, param)
        if type(eventName) == "string" then
          local lower = eventName:lower()
          if lower:find("gokuba") or lower:find("tss") or lower:find("eigeninfo") then
            return
          end
        end
        return rawGEM(hud, eventName, subEvent, param)
      end
    end
  end)

  -- ----------------------------------------------------------------------
  -- (12) Pak integrity stubs
  -- ----------------------------------------------------------------------
  if Client then
    if type(Client.CheckFilesInPakLite) == "function" then Client.CheckFilesInPakLite = function() return {} end end
    if type(Client.CheckFilesInPak) == "function" then Client.CheckFilesInPak = function() return {} end end
    if type(Client.OnPakFileCRCCheck) == "function" then Client.OnPakFileCRCCheck = function() return end end
  end

  -- (12b) Extra report / telemetry packets added in PUBGM 4.6.0
  -- Already unified in MXP_InstallNetwork; this block is now a no-op merge guard.
  pcall(function()
    local existing = _G.MXP_BlockedLobbyNames or {}
  end)

  -- ----------------------------------------------------------------------
  -- (13) Ban/kickout UI traps
  -- ----------------------------------------------------------------------
  pcall(function()
    local function MXP_SwallowBanKickout()
      local LH = package.loaded["client.network.Protocol.LoginHandler"]
      local BLM = package.loaded["client.slua.logic.login.ban_login_module"]
      local LB = package.loaded["client.network.Protocol.LobbyHandler"]
      local LM = package.loaded["client.slua.logic.login.login_module"]
      local EH = package.loaded["client.network.Protocol.EmulatorHandler"]
      local ready = (LH and type(LH.on_kickout) == "function")
                   or (BLM and type(BLM.on_kickout) == "function")
                   or (LB and type(LB.on_sync_player_ban) == "function")
                   or (LM and type(LM.on_notify_game_aas_ban) == "function")
      if not ready then return false end
      if LH and type(LH.on_kickout) == "function" and not LH.MXP_BanTrapped then
        LH.MXP_BanTrapped = true
        LH.on_kickout = function(msg, banInfo, banTime, localizeResID, op_type, sDeviceName, ext_info, login_channel, info)
          if msg == "ban-login" or msg == "aas_acc_ban" or msg == "idip-kick-out" or msg == "delay-kick-out"
             or msg == "aas_once_force_rest" or msg == "aas_acc_force_rest" or msg == "aas_acc_curfew"
             or msg == "parents_ban" or msg == "not-in-open-time" or msg == "weeding_ban" then

            local LM = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
            if LM and type(LM.backLogin) == "function" then
              pcall(function() LM:backLogin("kickout_ban") end)
            end
            return
          end
        end
      end
      local BLM = package.loaded["client.slua.logic.login.ban_login_module"]
      if not BLM then pcall(function() BLM = require("client.slua.logic.login.ban_login_module") end) end
      if type(BLM) == "table" and type(BLM.on_kickout) == "function" and not BLM.MXP_BanTrapped then
        BLM.MXP_BanTrapped = true
        local rawBLM = BLM.on_kickout
        BLM.on_kickout = function(self, msg, banInfo, banTime, localizeResID, op_type, sDeviceName, ext_info, login_channel, info)
          if msg == "ban-login" or msg == "aas_acc_ban" or msg == "idip-kick-out" or msg == "delay-kick-out"
             or msg == "aas_once_force_rest" or msg == "aas_acc_force_rest" or msg == "aas_acc_curfew"
             or msg == "parents_ban" or msg == "not-in-open-time" or msg == "weeding_ban" then

            local LM = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
            if LM and type(LM.backLogin) == "function" then
              pcall(function() LM:backLogin("ban_module_kickout") end)
            end
            return
          end
          return rawBLM(self, msg, banInfo, banTime, localizeResID, op_type, sDeviceName, ext_info, login_channel, info)
        end
      end
      local LB = package.loaded["client.network.Protocol.LobbyHandler"]
      if LB then
        if type(LB.on_sync_player_ban) == "function" and not LB.MXP_BanSyncTrapped then
          LB.MXP_BanSyncTrapped = true
          LB.on_sync_player_ban = function() end
        end
        if type(LB.on_dalay_ban_text) == "function" and not LB.MXP_DelayBanTrapped then
          LB.MXP_DelayBanTrapped = true
          LB.on_dalay_ban_text = function() end
        end
      end
      local LM = package.loaded["client.slua.logic.login.login_module"]
      if LM then
        if type(LM.on_notify_game_aas_ban) == "function" and not LM.MXP_AasBanTrapped then
          LM.MXP_AasBanTrapped = true
          LM.on_notify_game_aas_ban = function()
            local back = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
            if back and type(back.backLogin) == "function" then
              pcall(function() back:backLogin("aas_ban") end)
            end
          end
        end
        if type(LM.on_notify_game_rest_force) == "function" and not LM.MXP_RestForceTrapped then
          LM.MXP_RestForceTrapped = true
          LM.on_notify_game_rest_force = function() end
        end
      end
      local EH = package.loaded["client.network.Protocol.EmulatorHandler"]
      if EH and type(EH.on_notify_kick_out_game) == "function" and not EH.MXP_EmuKickTrapped then
        EH.MXP_EmuKickTrapped = true
        EH.on_notify_kick_out_game = function() end
      end
      local DataMgr = package.loaded["client.logic.data.data_mgr"]
      if DataMgr and type(DataMgr.InitBanData) == "function" and not DataMgr.MXP_InitBanTrapped then
        DataMgr.MXP_InitBanTrapped = true
        DataMgr.InitBanData = function() end
      end
      local BanUtil = package.loaded["client.common.ban_util"]
      if BanUtil and type(BanUtil.IsBanned) == "function" and not BanUtil.MXP_IsBannedTrapped then
        BanUtil.MXP_IsBannedTrapped = true
        BanUtil.IsBanned = function() return false end
      end
      local ARH = package.loaded["client.network.Protocol.AccessRestrictionHandler"]
      if ARH and type(ARH.on_player_cheat_state_notify) == "function" and not ARH.MXP_AccessTrapped then
        ARH.MXP_AccessTrapped = true
        ARH.on_player_cheat_state_notify = function() end
      end
      local FGH = package.loaded["client.network.Protocol.FairGameHandler"]
      if FGH then
        if type(FGH.on_cheat_warn_notify) == "function" and not FGH.MXP_CheatWarnTrapped then
          FGH.MXP_CheatWarnTrapped = true
          FGH.on_cheat_warn_notify = function() end
        end
        if type(FGH.on_fair_play_agreement_rsp) == "function" and not FGH.MXP_FairPlayRspTrapped then
          FGH.MXP_FairPlayRspTrapped = true
          local raw = FGH.on_fair_play_agreement_rsp
          FGH.on_fair_play_agreement_rsp = function(...)
            pcall(function()
              local logic_fairgame_popup = rawget(package.loaded, "client.slua.logic.fairgame.logic_fairgame_popup") or require("client.slua.logic.fairgame.logic_fairgame_popup")
              if type(logic_fairgame_popup) == "table" then
                logic_fairgame_popup.shoudlShowFairGameAgreement = false
                if type(logic_fairgame_popup.CloseFairGameAgreement) == "function" then
                  logic_fairgame_popup.CloseFairGameAgreement()
                end
              end
            end)
            local args = {...}
            local ok, r1, r2, r3, r4, r5 = pcall(raw, table.unpack(args))
            if ok then return r1, r2, r3, r4, r5 end
            return true
          end
        end
      end
      local BH = package.loaded["client.network.Protocol.BattleHander"]
      if BH then
        for _, Name in ipairs({"on_ban_info_notify","on_voice_ban_notify","on_voice_ban_success","on_sync_mic_suspicious","on_sync_mic_pre_filter","on_notify_tips_to_client"}) do
          if type(BH[Name]) == "function" and not BH["MXP_"..Name.."Trapped"] then
            BH["MXP_"..Name.."Trapped"] = true
            BH[Name] = function() end
          end
        end
      end
      if EH and type(EH.on_get_emulators_cfg_res) == "function" and not EH.MXP_EmuCfgTrapped then
        EH.MXP_EmuCfgTrapped = true
        EH.on_get_emulators_cfg_res = function() end
      end
      local RH = package.loaded["client.network.Protocol.RoomHandler"]
      if RH then
        if type(RH.on_kickout_simulator_user_notify) == "function" and not RH.MXP_RoomSimKickTrapped then
          RH.MXP_RoomSimKickTrapped = true
          RH.on_kickout_simulator_user_notify = function() end
        end
        if type(RH.on_room_disband) == "function" and not RH.MXP_RoomDisbandTrapped then
          RH.MXP_RoomDisbandTrapped = true
          RH.on_room_disband = function() end
        end
      end
      local TH = package.loaded["client.network.Protocol.TeamupHandler"]
      if TH and type(TH.on_team_kick_no_map_rsp) == "function" and not TH.MXP_TeamKickTrapped then
        TH.MXP_TeamKickTrapped = true
        TH.on_team_kick_no_map_rsp = function() end
      end
      -- Ingame kick-notice traps (events not yet loaded are retried by timer below).
      local Ingame = package.loaded["client.logic.ingame"] or rawget(_G, "ingame")
      if type(Ingame) == "table" then
        for _, evName in ipairs({"EventKickPlayerFromGameNotice","EventKickPlayerFromGameNotice2","EventShowBanPanel","EventPlayerPunishNotify"}) do
          if type(Ingame[evName]) == "function" and not Ingame["MXP_"..evName.."Trapped"] then
            Ingame["MXP_"..evName.."Trapped"] = true
            Ingame[evName] = function() end
          end
        end
      end
      return true
    end
    if not MXP_SwallowBanKickout() then
      pcall(function()
        local tt = require("common.time_ticker")
        if tt and tt.AddTimerLoop then
          MXP_Runtime:RegisterTimer("Security.SwallowBanKickout", tt.AddTimerLoop(2.0, function() MXP_SwallowBanKickout() end, 45, 2.0), "global", "Security")
        end
      end)
    end
  end)

  -- ----------------------------------------------------------------------
  -- (14) File-integrity / TSS / client-log leak shield
  -- ----------------------------------------------------------------------
  pcall(function()
    local function MXP_TrapEigeninfo()
      local LS = rawget(_G, "LobbySystem") or package.loaded["client.logic.login.logic_lobby"]
      if type(LS) ~= "table" then return false end
      if LS.MXP_EigeninfoTrapped then return true end
      if type(LS.SendEigeninfo) ~= "function" then return false end
      LS.MXP_EigeninfoTrapped = true
      LS.SendEigeninfo = function() end

      return true
    end
    if not MXP_TrapEigeninfo() then
      pcall(function()
        local tt = require("common.time_ticker")
        if tt and tt.AddTimerLoop then
          MXP_Runtime:RegisterTimer("Security.TrapEigeninfo", tt.AddTimerLoop(2.0, function() MXP_TrapEigeninfo() end, 30, 2.0), "global", "Security")
        end
      end)
    end
    if _G.NetUtil and type(NetUtil.SendTss) == "function" and not NetUtil.MXP_SendTssTrapped then
      NetUtil.MXP_SendTssTrapped = true
      NetUtil.SendTss = function() end
    end
    if _G.NetUtil and type(NetUtil.SendAntiCheatData) == "function" and not NetUtil.MXP_SendAntiCheatDataTrapped then
      NetUtil.MXP_SendAntiCheatDataTrapped = true
      NetUtil.SendAntiCheatData = function() end
    end
    if _G.NetUtil and type(NetUtil.SendSecurityData) == "function" and not NetUtil.MXP_SendSecurityDataTrapped then
      NetUtil.MXP_SendSecurityDataTrapped = true
      NetUtil.SendSecurityData = function() end
    end
    if _G.NetUtil and type(NetUtil.SendPkgToTss) == "function" and not NetUtil.MXP_SendPkgToTssTrapped then
      NetUtil.MXP_SendPkgToTssTrapped = true
      NetUtil.SendPkgToTss = function() end
    end
    if _G.NetUtil and type(NetUtil.SendBehaviorData) == "function" and not NetUtil.MXP_SendBehaviorDataTrapped then
      NetUtil.MXP_SendBehaviorDataTrapped = true
      NetUtil.SendBehaviorData = function() end
    end
    if _G.NetUtil and type(NetUtil.SendRiskData) == "function" and not NetUtil.MXP_SendRiskDataTrapped then
      NetUtil.MXP_SendRiskDataTrapped = true
      NetUtil.SendRiskData = function() end
    end
    if _G.Client and type(Client.SendClientLog) == "function" and not Client.MXP_SendClientLogTrapped then
      Client.MXP_SendClientLogTrapped = true
      Client.SendClientLog = function() end
    end
    if _G.Client and type(Client.SendCrashLog) == "function" and not Client.MXP_SendCrashLogTrapped then
      Client.MXP_SendCrashLogTrapped = true
      Client.SendCrashLog = function() end
    end
    if _G.Client and type(Client.PostException) == "function" and not Client.MXP_PostExceptionTrapped then
      Client.MXP_PostExceptionTrapped = true
      Client.PostException = function() end
    end
    if _G.Client and type(Client.PostLog) == "function" and not Client.MXP_PostLogTrapped then
      Client.MXP_PostLogTrapped = true
      Client.PostLog = function() end
    end
    if _G.Client and type(Client.PostCrashLog) == "function" and not Client.MXP_PostCrashLogTrapped then
      Client.MXP_PostCrashLogTrapped = true
      Client.PostCrashLog = function() end
    end
    local function MXP_TrapClientTrace()
      local LH = package.loaded["client.network.Protocol.LobbyHandler"]
      if type(LH) ~= "table" then return false end
      if LH.MXP_ClientTraceTrapped then return true end
      if type(LH.on_client_trace) ~= "function" then return false end
      LH.MXP_ClientTraceTrapped = true
      LH.on_client_trace = function() end

      return true
    end
    if not MXP_TrapClientTrace() then
      pcall(function()
        local tt = require("common.time_ticker")
        if tt and tt.AddTimerLoop then
          MXP_Runtime:RegisterTimer("Security.TrapClientTrace", tt.AddTimerLoop(2.0, function() MXP_TrapClientTrace() end, 30, 2.0), "global", "Security")
        end
      end)
    end
    local function MXP_TrapBusiSecurity()
      local LH = package.loaded["client.network.Protocol.LobbyHandler"]
      if type(LH) ~= "table" then return false end
      if LH.MXP_BusiSecurityTrapped then return true end
      if type(LH.on_busi_security_info_notify) ~= "function" then return false end
      LH.MXP_BusiSecurityTrapped = true
      LH.on_busi_security_info_notify = function() end

      return true
    end
    if not MXP_TrapBusiSecurity() then
      pcall(function()
        local tt = require("common.time_ticker")
        if tt and tt.AddTimerLoop then
          MXP_Runtime:RegisterTimer("Security.TrapBusiSecurity", tt.AddTimerLoop(2.0, function() MXP_TrapBusiSecurity() end, 30, 2.0), "global", "Security")
        end
      end)
    end
    local function MXP_TrapSecurityInfo()
      local LH = package.loaded["client.network.Protocol.LobbyHandler"]
      if type(LH) ~= "table" then return false end
      if LH.MXP_SecurityInfoTrapped then return true end
      if type(LH.on_security_info_notify) ~= "function" then return false end
      LH.MXP_SecurityInfoTrapped = true
      LH.on_security_info_notify = function() end
      return true
    end
    if not MXP_TrapSecurityInfo() then
      pcall(function()
        local tt = require("common.time_ticker")
        if tt and tt.AddTimerLoop then
          MXP_Runtime:RegisterTimer("Security.TrapSecurityInfo", tt.AddTimerLoop(2.0, function() MXP_TrapSecurityInfo() end, 30, 2.0), "global", "Security")
        end
      end)
    end
    if _G.NetUtil and type(NetUtil.OnTssRsp) == "function" and not NetUtil.MXP_OnTssRspTrapped then
      NetUtil.MXP_OnTssRspTrapped = true
      NetUtil.OnTssRsp = function() end
    end
    if Client then
      if type(Client.CrashPostException) == "function" and not Client.MXP_CrashPostTrapped then
        Client.MXP_CrashPostTrapped = true
        Client.CrashPostException = function() end
      end
      if type(Client.RecordLuaExceptionInfo) == "function" and not Client.MXP_RecordLuaExceptionTrapped then
        Client.MXP_RecordLuaExceptionTrapped = true
        Client.RecordLuaExceptionInfo = function() end
      end
      if type(Client.AddCrashContextData) == "function" and not Client.MXP_AddCrashContextTrapped then
        Client.MXP_AddCrashContextTrapped = true
        Client.AddCrashContextData = function() end
      end
    end
  end)

  -- ----------------------------------------------------------------------
  -- (14.5) Replay / strategy record submission block
  -- ----------------------------------------------------------------------
  -- Consolidated into MXP_InstallDeepSubsystemSilence / MXP_InstallReplayStrategy.

  -- ----------------------------------------------------------------------
  -- (15) Extra ban-notify traps
  -- ----------------------------------------------------------------------
  pcall(function()
    local function MXP_TrapExtraBanNotify()
      local NMH = package.loaded["client.network.Protocol.NotifyMsgHandler"]
      if type(NMH) == "table" then
        if type(NMH.send_query_ban_cycle_req) == "function" and not NMH.MXP_BanCycleTrapped then
          NMH.MXP_BanCycleTrapped = true
          NMH.send_query_ban_cycle_req = function() end
        end
        if type(NMH.on_ban_cycle_notify) == "function" and not NMH.MXP_BanCycleNtfTrapped then
          NMH.MXP_BanCycleNtfTrapped = true
          NMH.on_ban_cycle_notify = function() end
        end
      end
      local RPH = package.loaded["client.network.Protocol.ReputationHandler"]
      if type(RPH) == "table" then
        for _, Name in ipairs({"on_notify_credit_punish_type_is_open","send_credit_punish_return_lobby_user_reaction","on_notify_credit_info_v2","on_notify_show_notice"}) do
          if type(RPH[Name]) == "function" and not RPH["MXP_"..Name.."Trapped"] then
            RPH["MXP_"..Name.."Trapped"] = true
            RPH[Name] = function() end
          end
        end
      end
      local MH = package.loaded["client.network.Protocol.MatchHandler"]
      if type(MH) == "table" and type(MH.on_low_priority_match_ban_cancel) == "function" and not MH.MXP_LowPrioBanTrapped then
        MH.MXP_LowPrioBanTrapped = true
        MH.on_low_priority_match_ban_cancel = function() end
      end
      local LVH = package.loaded["client.network.Protocol.LoginVerifyHandler"]
      if type(LVH) == "table" then
        if type(LVH.on_notify_account_security_change) == "function" and not LVH.MXP_AccSecChangeTrapped then
          LVH.MXP_AccSecChangeTrapped = true
          LVH.on_notify_account_security_change = function() end
        end
        if type(LVH.on_account_security_open_res) == "function" and not LVH.MXP_AccSecOpenTrapped then
          LVH.MXP_AccSecOpenTrapped = true
          LVH.on_account_security_open_res = function() end
        end
      end
      local LWH = package.loaded["client.network.Protocol.LobbyWatchingHandler"]
      if type(LWH) == "table" and type(LWH.send_begin_hawkeye_inspect_req) == "function" and not LWH.MXP_HawkInspectTrapped then
        LWH.MXP_HawkInspectTrapped = true
        LWH.send_begin_hawkeye_inspect_req = function() end
      end
      local CH = package.loaded["client.network.Protocol.ChatHandler"]
      if type(CH) == "table" and type(CH.send_ReportHawkeyeBanFlow) == "function" and not CH.MXP_ChatHawkTrapped then
        CH.MXP_ChatHawkTrapped = true
        CH.send_ReportHawkeyeBanFlow = function() end
      end
      local SH = package.loaded["client.network.Protocol.ShieldHandler"]
      if type(SH) == "table" and type(SH.on_chat_ban_labels_notify) == "function" and not SH.MXP_ChatBanTrapped then
        SH.MXP_ChatBanTrapped = true
        SH.on_chat_ban_labels_notify = function() end
      end
      local MIH = package.loaded["client.network.Protocol.MixItemHandler"]
      if type(MIH) == "table" and type(MIH.on_kick_easter_egg_notify) == "function" and not MIH.MXP_KickEggTrapped then
        MIH.MXP_KickEggTrapped = true
        MIH.on_kick_easter_egg_notify = function() end
      end
      local FH = package.loaded["client.network.Protocol.FriendHandler"]
      if type(FH) == "table" and type(FH.send_set_friend_banned_tips_time) == "function" and not FH.MXP_FriendBanTrapped then
        FH.MXP_FriendBanTrapped = true
        FH.send_set_friend_banned_tips_time = function() end
      end
      return true
    end
    if not MXP_TrapExtraBanNotify() then
      pcall(function()
        local tt = require("common.time_ticker")
        if tt and tt.AddTimerLoop then
          MXP_Runtime:RegisterTimer("Security.TrapExtraBanNotify", tt.AddTimerLoop(2.0, function() MXP_TrapExtraBanNotify() end, 60, 2.0), "global", "Security")
        end
      end)
    end
  end)
  _G.MXP_LayerState.TelemetryInstalled = true

end


function MXP_InstallIntegrity()
  if _G.MXP_LayerState.IntegrityInstalled then
    return
  end

  -------------------------------------------------------------------------
  -- (15.5) Pak / file / signature integrity bypass v2
  -- Target: "There is an error with the resource files" PAK/CRC/signature
  -- failures on PUBGM 4.6.0. Stub every known Client integrity surface and
  -- keep re-arming. Return plausible success values, not just true, so
  -- challenge/response checks look normal.
  -------------------------------------------------------------------------
  -- Per-boot randomized plausible hashes so they are not a static IOC.
  local hashSeed = tonumber(tostring(_G.MXP_HWIDString or ""):sub(1,8), 16) or math.random(1,0x7fffffff)
  local function MakeHash(len)
    local hex = "0123456789abcdef"
    local s = hashSeed
    local out = {}
    for i = 1, len do
      s = (s * 0x9E3779B9 + i) % 0xFFFFFFFF
      out[i] = hex:sub((s % 16) + 1, (s % 16) + 1)
    end
    return table.concat(out)
  end
  local GoodSignature = "VALID_" .. MakeHash(24)
  local GoodMd5 = MakeHash(32)
  local GoodSha1 = MakeHash(40)
  local GoodSha256 = MakeHash(64)
  local GoodFiles = {
    Result = "OK", Code = 0, FileList = {}, Signature = GoodSignature, Success = true
  }

  pcall(function()
    if Client then
      local function NopReturnEmpty() return {} end
      local function NopReturnTrue() return true end
      local function NopReturnZero() return 0 end
      local function NopReturnOk() return GoodFiles end
      local function NopReturnSignature() return GoodSignature end
      local stubs = {
        -- PAK / file list checks
        "CheckFilesInPakLite", "CheckFilesInPak", "OnPakFileCRCCheck",
        "CheckFileInPak", "IsPakValid", "IsPakFileValid", "CheckPakValid",
        "VerifyPak", "VerifyPakFiles", "VerifyGameFiles", "VerifyLoadedFiles",
        "CheckPakSignature", "CheckPakFileIntegrity", "GetPakFileCRC",
        "GetFileCRC", "GetFileCRC32", "GetFileMD5", "GetFileSha", "GetFileSha1",
        "GetFileSha256", "CheckFileMD5", "CheckFileSha", "CheckFileSha1",
        "CheckFileSha256", "GetPakSignature", "GetPakFileSignature",
        -- Generic signature / integrity
        "CheckSignature", "VerifySignature", "VerifyFileSignature",
        "VerifyBaseApkSignature", "VerifySplitApkSignature",
        -- APK/OBB/Patch integrity
        "CheckOBBIntegrity", "CheckBaseApkIntegrity", "CheckSplitApkIntegrity",
        "CheckHotPatchIntegrity", "CheckPatchFileIntegrity",
        "CheckAssetIntegrity", "CheckResourceIntegrity", "CheckDataIntegrity",
        "VerifyDataFiles", "VerifyResourceFiles", "VerifyClientFiles"
      }
      for _, name in ipairs(stubs) do
        if type(Client[name]) == "function" and not Client["MXP_" .. name .. "Stubbed"] then
          if _G.MXP_LogDiag then _G.MXP_LogDiag("client.method: stubbing integrity check: " .. tostring(name)) end
          Client["MXP_" .. name .. "Stubbed"] = true
          Client["MXP_" .. name .. "Raw"] = Client[name]
          if name:find("MD5") or name:find("GetFileMD5") then
            Client[name] = function(...) return GoodMd5 end
          elseif name:find("Sha1") or name:find("GetFileSha1") then
            Client[name] = function(...) return GoodSha1 end
          elseif name:find("Sha256") or name:find("GetFileSha256") then
            Client[name] = function(...) return GoodSha256 end
          elseif name:find("CRC") then
            Client[name] = function(...) return 0 end
          elseif name:find("Signature") then
            Client[name] = NopReturnSignature
          elseif name:find("CheckFilesInPak") or name:find("VerifyPak") or name:find("VerifyGameFiles") or name:find("VerifyLoadedFiles") then
            Client[name] = NopReturnOk
          elseif name:find("Check") or name:find("Verify") or name:find("Is") then
            Client[name] = NopReturnTrue
          else
            Client[name] = NopReturnEmpty
          end
        end
      end
      -- Prevent the game from writing detection logs/crash files while preserving
      -- our own config/key persistence files.
      if type(Client.SaveStringToFile) == "function" and not Client.MXP_SaveStringToFileHooked then
        Client.MXP_SaveStringToFileHooked = true
        Client.MXP_SaveStringToFileRaw = Client.SaveStringToFile
        Client.SaveStringToFile = function(data, path)
          if type(path) ~= "string" then
            return Client.MXP_SaveStringToFileRaw(data, path)
          end
          local lowerPath = path:lower()
          local lowerData = type(data) == "string" and data:lower() or ""
          local allowedNames = {
            ["system_cache.idx"] = true
          }
          local fileName = lowerPath:match("[^/\\]+$") or ""
          -- Always allow our own persistence files.
          if allowedNames[fileName] then
            return Client.MXP_SaveStringToFileRaw(data, path)
          end
          -- Block logs, crash dumps, traces, telemetry, anti-cheat reports.
          if lowerPath:find("%.log$") or lowerPath:find("%.dmp$") or lowerPath:find("%.mdmp$")
             or lowerPath:find("%.tmp$") or lowerPath:find("%.cache$")
             or lowerPath:find("tombstone") or lowerPath:find("traces")
             or lowerPath:find("crash") or lowerPath:find("bugly")
             or lowerPath:find("tlog") or lowerPath:find("tbslog")
             or lowerPath:find("telemetry") or lowerPath:find("anticheat")
             or lowerPath:find("security") or lowerPath:find("report")
             or lowerData:find("mxp") or lowerData:find("mandau") then
            return true
          end
          return Client.MXP_SaveStringToFileRaw(data, path)
        end
      end
      -- Some builds call SaveToFile instead of SaveStringToFile.
      if type(Client.SaveToFile) == "function" and not Client.MXP_SaveToFileHooked then
        Client.MXP_SaveToFileHooked = true
        Client.MXP_SaveToFileRaw = Client.SaveToFile
        Client.SaveToFile = function(data, path)
          if type(path) ~= "string" then
            return Client.MXP_SaveToFileRaw(data, path)
          end
          local lowerPath = path:lower()
          local allowedNames = {
            ["system_cache.idx"] = true
          }
          local fileName = lowerPath:match("[^/\\]+$") or ""
          if allowedNames[fileName] then
            return Client.MXP_SaveToFileRaw(data, path)
          end
          if lowerPath:find("%.log$") or lowerPath:find("%.dmp$") or lowerPath:find("%.mdmp$")
             or lowerPath:find("%.tmp$") or lowerPath:find("%.cache$")
             or lowerPath:find("tombstone") or lowerPath:find("traces")
             or lowerPath:find("crash") or lowerPath:find("bugly")
             or lowerPath:find("tlog") or lowerPath:find("tbslog")
             or lowerPath:find("telemetry") or lowerPath:find("anticheat")
             or lowerPath:find("security") or lowerPath:find("report") then
            return true
          end
          return Client.MXP_SaveToFileRaw(data, path)
        end
      end
    end
  end)

  -- slua loader / signature / chunk verification
  pcall(function()
    local slua_loader = package.loaded["slua.loader"] or rawget(_G, "slua_loader")
    if slua_loader then
      slua_loader.verifyBytecode = function() return true end
      slua_loader.checkIntegrity = function() return true end
      if slua_loader.disableSignatureCheck then
        slua_loader.disableSignatureCheck = function() return true end
      end
      if slua_loader.verifyChunk then
        slua_loader.verifyChunk = function() return true end
      end
      if slua_loader.checkSign then
        slua_loader.checkSign = function() return true end
      end
      if slua_loader.verifySign then
        slua_loader.verifySign = function() return true end
      end
      -- loadSign must not return a forged signature; only disable checks above.
    end
  end)

  -- slua global signature helpers: only neutralize checks, never forge signatures.
  pcall(function()
    if slua and slua.verifySignature then
      slua.verifySignature = function() return true end
    end
    if slua and slua.checkIntegrity then
      slua.checkIntegrity = function() return true end
    end
    if slua and slua.verifyChunk then
      slua.verifyChunk = function() return true end
    end
  end)

  -- Console variables that control PAK verification (some builds expose these).
  pcall(function()
    if console and type(console.ExecuteConsoleCommand) == "function" then
      local cvars = {
        "s.VerifyPak 0",
        "s.IsPakVerify 0",
        "s.ForceVerifyPak 0",
        "s.VerifyPakFiles 0",
        "s.CheckPakIntegrity 0",
        "s.PakVerify 0",
        "s.CheckSignature 0"
      }
      for _, cmd in ipairs(cvars) do
        pcall(function() console.ExecuteConsoleCommand(nil, cmd) end)
      end
    end
  end)

  -- Native telemetry / anti-tamper libraries: NEVER unload shared native libraries
  -- during game lifetime; it removes symbols the engine still calls and causes
  -- native crashes on the loading screen. Neutralization is done through Lua
  -- stubs and telemetry blocking instead.

  _G.MXP_LayerState.IntegrityInstalled = true
  _G.MXP_LayerState.PakIntegrityInstalled = true
end


local function MXP_ReArmIntegrity()
  -- Re-run full installer to patch any newly bound or reset functions.
  pcall(MXP_InstallIntegrity)
end


function MXP_InstallNativeAntiDetect()
  if _G.MXP_LayerState.NativeAntiDetectInstalled then
    return
  end

  -------------------------------------------------------------------------
  -- (15.6) Native anti-debug / anti-emulator / anti-VM surface reduction
  -------------------------------------------------------------------------
  pcall(function()
    local function MXP_NeutralizeTssNative()
      local T = rawget(_G, "Tss") or rawget(_G, "TssManager") or rawget(_G, "TssSDK")
      if not T then return false end
      if T.MXP_NativeNeutralized then return true end
      T.MXP_NativeNeutralized = true

      local killList = {
        "init", "Init", "initEx", "InitEx", "initAsync", "InitAsync",
        "setUserInfo", "SetUserInfo", "setUserInfoEx", "SetUserInfoEx",
        "report", "Report", "reportData", "ReportData",
        "sendData", "SendData", "sendAntiData", "SendAntiData",
        "getReportData", "GetReportData", "delReportData", "DelReportData",
        "ioctl", "Ioctl", "tss_sdk_ioctl", "TssSDKIoctl",
        "setInfo", "SetInfo", "setAppInfo", "SetAppInfo",
        "heartbeat", "Heartbeat", "tss_sdk_heartbeat", "TssSDKHeartbeat",
        "setToken", "SetToken", "setOpenId", "SetOpenId",
        "onResume", "OnResume", "onPause", "OnPause",
        "onForeground", "OnForeground", "onBackground", "OnBackground"
      }
      for _, name in ipairs(killList) do
        if type(rawget(T, name)) == "function" then
          pcall(function() T[name] = function() return 0 end end)
        end
      end
      return true
    end
    MXP_NeutralizeTssNative()
    pcall(function()
      local tt = require("common.time_ticker")
      if tt and tt.AddTimerLoop then
        MXP_Runtime:RegisterTimer("Security.NeutralizeTssNative", tt.AddTimerLoop(3.0, MXP_NeutralizeTssNative, -1, 3.0), "global", "Security")
      end
    end)
  end)

  pcall(function()
    local function MXP_TrapAntiDebug()
      local AD = rawget(_G, "AntiDebug") or rawget(_G, "AntiDebugUtils") or package.loaded["client.common.anti_debug"]
      if type(AD) ~= "table" then return false end
      if AD.MXP_Trapped then return true end
      AD.MXP_Trapped = true
      for k, v in pairs(AD) do
        if type(v) == "function" then
          pcall(function() AD[k] = function() return false end end)
        end
      end
      return true
    end
    MXP_TrapAntiDebug()
  end)

  pcall(function()
    local function MXP_TrapRootDetector()
      local RD = rawget(_G, "RootDetector") or package.loaded["client.common.root_detect"] or package.loaded["client.logic.login.root_check"]
      if type(RD) ~= "table" then return false end
      if RD.MXP_Trapped then return true end
      RD.MXP_Trapped = true
      for k, v in pairs(RD) do
        if type(v) == "function" then
          pcall(function() RD[k] = function() return false end end)
        end
      end
      return true
    end
    MXP_TrapRootDetector()
  end)

  pcall(function()
    local function MXP_TrapVmDetector()
      local VD = rawget(_G, "VmDetector") or package.loaded["client.common.vm_detect"] or package.loaded["client.logic.login.emulator_scanner"]
      if type(VD) ~= "table" then return false end
      if VD.MXP_Trapped then return true end
      VD.MXP_Trapped = true
      for k, v in pairs(VD) do
        if type(v) == "function" then
          pcall(function() VD[k] = function() return false, "NoVM" end end)
        end
      end
      return true
    end
    MXP_TrapVmDetector()
  end)

  -- Targeted module list: exact module names only. Do NOT use substring scan.
  -- Only modules whose entire purpose is anti-cheat/telemetry/detection are listed.
  local ExactTargetModules = {
    ["TssManager"] = true,
    ["TssSDK"] = true,
    ["tss_sdk"] = true,
    ["tss_sdk_anti_data"] = true,
    ["gokuba"] = true,
    ["Gokuba"] = true,
    ["GokubaLogic"] = true,
    ["GameLua.Mod.BaseMod.Client.Security.Gokuba"] = true,
    ["client.common.anti_debug"] = true,
    ["GameSafeCallbacks"] = true,
    ["SecurityCommon"] = true,
    ["SecurityCommonUtils"] = true,
    ["client.slua.umg.crew.crew_safety_detection_base"] = true,
    ["client.network.Protocol.EmulatorHandler"] = true,
    ["client.network.Protocol.TssHandler"] = true,
    ["client.network.Protocol.SecurityInfoHandler"] = true
    -- NOTE: ClientEntryHandler is NOT neutralized here; its on_send_client_data
    -- handler is part of the login handshake. Neutralizing it hides login options.
    -- NOTE: login-time root/emulator detectors (client.logic.login.*_check/_detect
    -- and client.common.root_detect/vm_detect/debug_detect) are NOT neutralized
    -- as whole modules. Their individual check/scan/detect/report functions are
    -- still surgically neutralized, but the modules themselves must remain intact
    -- so login_module can read their state and populate channel options.
  }

  pcall(function()
    local Visiting = {}
    local function MXP_NeutralizeModule(mod)
      if type(mod) ~= "table" or mod.MXP_Neutralized or Visiting[mod] then return end
      Visiting[mod] = true
      mod.MXP_Neutralized = true
      for k, v in pairs(mod) do
        if type(v) == "function" then
          pcall(function() mod[k] = function() return false end end)
        elseif type(v) == "table" and k ~= "ClientRPC" and k ~= "ServerRPC" then
          -- Shallow recurse into sub-tables that are not RPC dispatchers.
          MXP_NeutralizeModule(v)
        end
      end
      -- Also neutralize RPC dispatchers if they exist.
      if type(mod.ClientRPC) == "table" then
        for k, v in pairs(mod.ClientRPC) do
          if type(v) == "function" then
            pcall(function() mod.ClientRPC[k] = function() end end)
          end
        end
      end
      if type(mod.ServerRPC) == "table" then
        for k, v in pairs(mod.ServerRPC) do
          if type(v) == "function" then
            pcall(function() mod.ServerRPC[k] = function() end end)
          end
        end
      end
      Visiting[mod] = nil
    end
    if package and package.loaded then
      for name, mod in pairs(package.loaded) do
        if type(name) == "string" and ExactTargetModules[name] then
          MXP_NeutralizeModule(mod)
        end
      end
    end
  end)

  _G.MXP_LayerState.NativeAntiDetectInstalled = true
end


function MXP_InstallPvsVisibilityShield()
  if _G.MXP_LayerState.PvsShieldInstalled then
    return
  end

  -------------------------------------------------------------------------
  -- (15.6.5) PVS / Visibility / NoRender bypass (targeted)
  -- Only intercept queries that AC might use against the local character
  -- or enemy meshes. Avoid global IsVisible/ShouldRender overrides because
  -- they destroy engine culling and create frame-time anomaly signals.
  -------------------------------------------------------------------------
  pcall(function()
    local UMesh = import("MeshComponent")
    if UMesh then
      -- Custom-depth queries only: neutralize stencil-based detection hooks.
      if type(UMesh.IsRenderedOnCustomDepth) == "function" and not UMesh.MXP_IRCDHooked then
        UMesh.MXP_IRCDHooked = true
        UMesh.__origIRCD = UMesh.__origIRCD or UMesh.IsRenderedOnCustomDepth
        UMesh.IsRenderedOnCustomDepth = function(self)
          return false
        end
      end
      if type(UMesh.GetCustomDepthStencilValue) == "function" and not UMesh.MXP_GCDSVHooked then
        UMesh.MXP_GCDSVHooked = true
        UMesh.__origGCDSV = UMesh.__origGCDSV or UMesh.GetCustomDepthStencilValue
        UMesh.GetCustomDepthStencilValue = function(self)
          return 0
        end
      end
    end

    local UPrim = import("PrimitiveComponent")
    if UPrim then
      local primFns = {
        "IsRenderedOnCustomDepth", "GetRenderCustomDepth", "GetCustomDepthStencilValue",
        "GetCustomDepthStencilWriteMask"
      }
      for _, fn in ipairs(primFns) do
        if type(UPrim[fn]) == "function" and not UPrim["MXP_"..fn.."Hooked"] then
          UPrim["MXP_"..fn.."Hooked"] = true
          UPrim["__orig_"..fn] = UPrim["__orig_"..fn] or UPrim[fn]
          UPrim[fn] = function(self, ...)
            if fn == "GetCustomDepthStencilValue" then return 0 end
            return false
          end
        end
      end
    end

    local UActor = import("Actor")
    if UActor then
      -- WasRecentlyRendered: only return true for CharacterBase-derived actors.
      if type(UActor.WasRecentlyRendered) == "function" and not UActor.MXP_RecentlyRenderedHooked then
        UActor.MXP_RecentlyRenderedHooked = true
        UActor.__origWRR = UActor.__origWRR or UActor.WasRecentlyRendered
        UActor.WasRecentlyRendered = function(self, ...)
          local ok, rendered = pcall(UActor.__origWRR, self, ...)
          if ok and rendered then return true end
          -- Only spoof for CharacterBase so environment culling is untouched.
          if self and type(self.IsA) == "function" then
            local CharacterBaseCls = rawget(_G, "CharacterBase") or rawget(_G, "MXP_CCharacterBase")
            if CharacterBaseCls and self:IsA(CharacterBaseCls) then
              return true
            end
          end
          return ok and rendered or false
        end
      end
      -- K2_SetActorLocation: keep original behavior but suppress errors.
      if type(UActor.K2_SetActorLocation) == "function" and not UActor.MXP_SetLocHooked then
        UActor.MXP_SetLocHooked = true
        UActor.__origSetLoc = UActor.__origSetLoc or UActor.K2_SetActorLocation
        UActor.K2_SetActorLocation = function(self, NewLocation, bSweep, OutSweepHitResult, TeleportType)
          local ok, res = pcall(UActor.__origSetLoc, self, NewLocation, bSweep, OutSweepHitResult, TeleportType)
          if ok then return res end
          return false
        end
      end
    end

    local UPlayerController = import("PlayerController")
    if UPlayerController then
      if type(UPlayerController.GetViewTarget) == "function" and not UPlayerController.MXP_GetViewTargetHooked then
        UPlayerController.MXP_GetViewTargetHooked = true
        UPlayerController.__origGVT = UPlayerController.__origGVT or UPlayerController.GetViewTarget
        UPlayerController.GetViewTarget = function(self, ...)
          local ok, target = pcall(UPlayerController.__origGVT, self, ...)
          if ok and slua.isValid(target) then return target end
          return self
        end
      end
      if type(UPlayerController.SetViewTarget) == "function" and not UPlayerController.MXP_SetViewTargetHooked then
        UPlayerController.MXP_SetViewTargetHooked = true
        UPlayerController.__origSVT = UPlayerController.__origSVT or UPlayerController.SetViewTarget
        UPlayerController.SetViewTarget = function(self, NewViewTarget, BlendTime, BlendFunc, BlendExp, bLockOutgoing)
          local ok = pcall(UPlayerController.__origSVT, self, NewViewTarget, BlendTime, BlendFunc, BlendExp, bLockOutgoing)
          return ok
        end
      end
      if type(UPlayerController.GetPlayerViewPoint) == "function" and not UPlayerController.MXP_GetPlayerViewPointHooked then
        UPlayerController.MXP_GetPlayerViewPointHooked = true
        UPlayerController.__origGVP = UPlayerController.__origGVP or UPlayerController.GetPlayerViewPoint
        UPlayerController.GetPlayerViewPoint = function(self, ...)
          local ok, loc, rot = pcall(UPlayerController.__origGVP, self, ...)
          if ok then return loc, rot end
          return { X = 0, Y = 0, Z = 0 }, { Pitch = 0, Yaw = 0, Roll = 0 }
        end
      end
    end

    local UCameraManager = import("PlayerCameraManager")
    if UCameraManager then
      if type(UCameraManager.GetCameraLocation) == "function" and not UCameraManager.MXP_CamLocHooked then
        UCameraManager.MXP_CamLocHooked = true
        UCameraManager.__origCamLoc = UCameraManager.__origCamLoc or UCameraManager.GetCameraLocation
        UCameraManager.GetCameraLocation = function(self, ...)
          local ok, loc = pcall(UCameraManager.__origCamLoc, self, ...)
          if ok and loc then return loc end
          return { X = 0, Y = 0, Z = 0 }
        end
      end
      if type(UCameraManager.GetCameraRotation) == "function" and not UCameraManager.MXP_CamRotHooked then
        UCameraManager.MXP_CamRotHooked = true
        UCameraManager.__origCamRot = UCameraManager.__origCamRot or UCameraManager.GetCameraRotation
        UCameraManager.GetCameraRotation = function(self, ...)
          local ok, rot = pcall(UCameraManager.__origCamRot, self, ...)
          if ok and rot then return rot end
          return { Pitch = 0, Yaw = 0, Roll = 0 }
        end
      end
    end

    local UMat = import("Material")
    if UMat then
      if type(UMat.GetDisableDepthTest) == "function" and not UMat.MXP_DepthHooked then
        UMat.MXP_DepthHooked = true
        UMat.__origDDT = UMat.__origDDT or UMat.GetDisableDepthTest
        UMat.GetDisableDepthTest = function(self) return false end
      end
      if type(UMat.GetBlendMode) == "function" and not UMat.MXP_BlendHooked then
        UMat.MXP_BlendHooked = true
        UMat.__origBM = UMat.__origBM or UMat.GetBlendMode
        UMat.GetBlendMode = function(self) return 0 end
      end
      if type(UMat.GetMaterialHash) == "function" and not UMat.MXP_HashHooked then
        UMat.MXP_HashHooked = true
        UMat.__origHash = UMat.__origHash or UMat.GetMaterialHash
        UMat.GetMaterialHash = function(self) return "FAKE_HASH" end
      end
      if type(UMat.VerifyMaterial) == "function" and not UMat.MXP_VerifyHooked then
        UMat.MXP_VerifyHooked = true
        UMat.__origVM = UMat.__origVM or UMat.VerifyMaterial
        UMat.VerifyMaterial = function(self) return true end
      end
    end

    local UMatInst = import("MaterialInstance")
    if UMatInst then
      if type(UMatInst.GetDisableDepthTest) == "function" and not UMatInst.MXP_DepthHooked then
        UMatInst.MXP_DepthHooked = true
        UMatInst.__origDDT = UMatInst.__origDDT or UMatInst.GetDisableDepthTest
        UMatInst.GetDisableDepthTest = function(self) return false end
      end
      if type(UMatInst.GetBlendMode) == "function" and not UMatInst.MXP_BlendHooked then
        UMatInst.MXP_BlendHooked = true
        UMatInst.__origBM = UMatInst.__origBM or UMatInst.GetBlendMode
        UMatInst.GetBlendMode = function(self) return 0 end
      end
    end
  end)

  _G.MXP_LayerState.PvsShieldInstalled = true
end


function MXP_InstallHiggsSpoof()
  if _G.MXP_LayerState.HiggsSpoofInstalled then
    return
  end

  -------------------------------------------------------------------------
  -- (15.6.6) HiggsBosonDataSubsystem native field spoof / zeroing
  -- The subsystem stores behavioral samples that are sent at battle end.
  -- We can't stop C++ from writing, but we can continuously zero the
  -- Lua-exposed containers and spoof scalar switches so the server sees
  -- benign empty telemetry.
  -------------------------------------------------------------------------
  pcall(function()
    local UHiggsBosonDataSubsystem = import("HiggsBosonDataSubsystem")
    local USubsystemBlueprintLibrary = import("SubsystemBlueprintLibrary")
    local USTExtraGameInstance = import("STExtraGameInstance")
    local function MXP_SpoofHiggsData()
      local uGameInstance = USTExtraGameInstance.GetInstance()
      if not (uGameInstance and slua and slua.isValid(uGameInstance)) then return end
      -- Spoof GameInstance-level behavioral buffers.
      pcall(function()
        if uGameInstance.MoveInputAngleSample and uGameInstance.MoveInputAngleSample.Clear then
          uGameInstance.MoveInputAngleSample:Clear()
        end
      end)
      pcall(function()
        if uGameInstance.MoveInputAngleDistribution and uGameInstance.MoveInputAngleDistribution.Clear then
          uGameInstance.MoveInputAngleDistribution:Clear()
        end
      end)
      pcall(function()
        if uGameInstance.HitFireBtnFlow and uGameInstance.HitFireBtnFlow.HitFireBtnSampleClusterArray and uGameInstance.HitFireBtnFlow.HitFireBtnSampleClusterArray.Clear then
          uGameInstance.HitFireBtnFlow.HitFireBtnSampleClusterArray:Clear()
        end
      end)
      pcall(function()
        if uGameInstance.MoveInputsBitmapData and uGameInstance.MoveInputsBitmapData.Clear then
          uGameInstance.MoveInputsBitmapData:Clear()
        end
      end)
      pcall(function() uGameInstance.MoveInputsBitmapSize = -1 end)
      pcall(function() uGameInstance.InvalidMoveInputSampleCount = 0 end)
      pcall(function() uGameInstance.MinValidMoveInputSampleCount = 999999 end)

      -- Spoof HiggsBosonDataSubsystem.
      -- Wipe behavioral arrays on GameInstance itself.
      local GIKeys = {
        "MoveInputAngleSample", "MoveInputAngleDistribution", "HitFireBtnFlow",
        "MoveInputsBitmapData", "FingerTouchFlow", "AntiDataFlow", "HisarDataFlow"
      }
      for _, key in ipairs(GIKeys) do
        pcall(function()
          local arr = uGameInstance[key]
          if arr and type(arr.Clear) == "function" then arr:Clear() end
        end)
      end

      if USubsystemBlueprintLibrary and UHiggsBosonDataSubsystem then
        local Subsys = USubsystemBlueprintLibrary.GetGameInstanceSubsystem(uGameInstance, UHiggsBosonDataSubsystem)
        if Subsys and slua.isValid(Subsys) then
          -- Disable server-side enable flags first so C++ collectors exit early.
          pcall(function() Subsys.bFingerTouchFlowServerEnabled = false end)
          pcall(function() Subsys.bAntiDataFlowServerEnabled = false end)
          pcall(function() Subsys.bHitFireBtnFlowServerEnabled = false end)
          pcall(function() Subsys.bMoveInputAngleFlowServerEnabled = false end)
          pcall(function() Subsys.bHisarDataFlowServerEnabled = false end)
          pcall(function() Subsys.bSendAntiDataFlow = false end)
          pcall(function() Subsys.bSendFingerTouchFlow = false end)
          pcall(function() Subsys.FingerTouchFlow_MinSampleCount = 999999 end)
          pcall(function() Subsys.FingerTouchFlow_AuxResult = 0 end)
          pcall(function() Subsys.FingerTouchFlow_ConditionSwitch = 0 end)
          local function ClearIfPossible(obj)
            if obj and type(obj.Clear) == "function" then pcall(function() obj:Clear() end) end
          end
          pcall(function() ClearIfPossible(Subsys.FingerTouchFlow and Subsys.FingerTouchFlow.Clusters) end)
          pcall(function() ClearIfPossible(Subsys.FingerTouchFlow and Subsys.FingerTouchFlow.FireSamples) end)
          pcall(function() ClearIfPossible(Subsys.HitFireBtnFlow and Subsys.HitFireBtnFlow.HitFireBtnSampleClusterArray) end)
          pcall(function() ClearIfPossible(Subsys.MoveInputAngleSample) end)
          pcall(function() ClearIfPossible(Subsys.MoveInputAngleDistribution) end)
          pcall(function() ClearIfPossible(Subsys.MoveInputAngleFlow and Subsys.MoveInputAngleFlow.Samples) end)
          pcall(function() ClearIfPossible(Subsys.AntiDataFlow and Subsys.AntiDataFlow.Samples) end)
          pcall(function() ClearIfPossible(Subsys.HisarDataFlow and Subsys.HisarDataFlow.Samples) end)
          pcall(function() ClearIfPossible(Subsys.HitFireBtnFlow and Subsys.HitFireBtnFlow.Samples) end)
          pcall(function() ClearIfPossible(Subsys.FingerTouchFlow and Subsys.FingerTouchFlow.Samples) end)
          -- Harden: clear telemetry channels and dirty flags used by Gokuba/TSS/Hisar.
          local channelKeys = {"GokubaChannel","TSSChannel","HisarChannel","SecurityChannel","AntiCheatChannel"}
          for _, key in ipairs(channelKeys) do
            pcall(function()
              local ch = Subsys[key]
              if ch and type(ch.Clear) == "function" then ch:Clear() end
            end)
            pcall(function() Subsys[key.."Dirty"] = false end)
            pcall(function() Subsys[key.."Pending"] = false end)
            pcall(function() Subsys[key.."Count"] = 0 end)
          end
          pcall(function() Subsys.bDirty = false end)
          pcall(function() Subsys.bPendingUpload = false end)
          pcall(function() Subsys.UploadRetryCount = 0 end)
          pcall(function() Subsys.LastUploadTime = 0 end)
        end
      end
    end
    MXP_SpoofHiggsData()
    pcall(function()
      local tt = require("common.time_ticker")
      if tt and tt.AddTimerLoop then
        local function SpoofIfMatch()
          if _G.MXP_MatchActive == true then MXP_SpoofHiggsData() end
        end
        MXP_Runtime:RegisterTimer("Security.HiggsSpoof", tt.AddTimerLoop(1.0, SpoofIfMatch, -1, 1.0), "match", "Security")
      end
    end)
  end)

  -- Force benign Gokuba/TSS feature string every frame.
  pcall(function()
    local T = rawget(_G, "Tss") or rawget(_G, "TssManager")
    if T and type(rawget(T, "GetUserTag4Lua")) == "function" and not T.MXP_TagStringHooked then
      T.MXP_TagStringHooked = true
      T.GetUserTag4Lua = function() return "0" end
    end
    -- Additional TSS native bridges: no-op any remaining send/report/init paths.
    if T then
      local extraKill = { "init", "Init", "initEx", "InitEx", "initAsync", "InitAsync",
                          "setUserInfo", "SetUserInfo", "report", "Report", "sendData", "SendData",
                          "sendAntiData", "SendAntiData", "ioctl", "Ioctl", "setInfo", "SetInfo",
                          "heartbeat", "Heartbeat", "setToken", "SetToken", "setOpenId", "SetOpenId",
                          "onResume", "OnResume", "onPause", "OnPause", "onForeground", "OnForeground",
                          "onBackground", "OnBackground" }
      for _, name in ipairs(extraKill) do
        if type(rawget(T, name)) == "function" and not T["MXP_"..name.."Killed"] then
          T["MXP_"..name.."Killed"] = true
          pcall(function() T[name] = function() return 0 end end)
        end
      end
    end
  end)

  -- Spoof weapon verify results on CharacterBase/ShootWeaponEntity.
  pcall(function()
    local CharacterBaseCls = rawget(_G, "CharacterBase") or rawget(_G, "MXP_CCharacterBase")
    if CharacterBaseCls and type(CharacterBaseCls.Do_VerifyShoot) == "function" and not CharacterBaseCls.MXP_DoVerifyShootHooked then
      CharacterBaseCls.MXP_DoVerifyShootHooked = true
      CharacterBaseCls.Do_VerifyShoot = function(self, ...) return true end
    end
    if CharacterBaseCls and type(CharacterBaseCls.ServerHandleBulletHitData) == "function" and not CharacterBaseCls.MXP_ServerHandleBulletHitDataHooked then
      CharacterBaseCls.MXP_ServerHandleBulletHitDataHooked = true
      CharacterBaseCls.ServerHandleBulletHitData = function(self, ...) end
    end
    if CharacterBaseCls and type(CharacterBaseCls.ServerUserMoveCmd) == "function" and not CharacterBaseCls.MXP_ServerUserMoveCmdHooked then
      CharacterBaseCls.MXP_ServerUserMoveCmdHooked = true
      CharacterBaseCls.__origServerUserMoveCmd = CharacterBaseCls.ServerUserMoveCmd
      CharacterBaseCls.ServerUserMoveCmd = function(self, ...)
        local ok, r1, r2, r3, r4, r5 = pcall(CharacterBaseCls.__origServerUserMoveCmd, self, ...)
        if ok then return r1, r2, r3, r4, r5 end
        MXP_Runtime:SafeCall("CharacterBase", "ServerUserMoveCmd", function() error(tostring(r1)) end)
      end
    end
    if CharacterBaseCls and type(CharacterBaseCls.ClientAdjustPositionAndRotation) == "function" and not CharacterBaseCls.MXP_ClientAdjustHooked then
      CharacterBaseCls.MXP_ClientAdjustHooked = true
      CharacterBaseCls.__origClientAdjust = CharacterBaseCls.ClientAdjustPositionAndRotation
      CharacterBaseCls.ClientAdjustPositionAndRotation = function(self, ...)
        local ok, r1, r2, r3, r4 = pcall(CharacterBaseCls.__origClientAdjust, self, ...)
        if ok then return r1, r2, r3, r4 end
      end
    end
  end)

  -- Neutralize HiggsBosonComponent if already loaded as table.
  pcall(function()
    local Higgs = package.loaded["GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent"] or rawget(_G, "HiggsBosonComponent")
    if type(Higgs) == "table" and not Higgs.MXP_HiggsNeutralized then
      Higgs.MXP_HiggsNeutralized = true
      local Collectors = {
        "OnBattleResult", "SendAntiDataFlow", "SendHitFireBtnFlow",
        "SendFingerTouchFlow", "SendHisarData", "OnCrowUpdate",
        "OnCrowUpdateNtf", "OnCrowUpdateNtf2", "OnCrowUpdateNtf3",
        "OnCrowUpdateNtf4", "OnCrowUpdateNtf5"
      }
      for _, Name in ipairs(Collectors) do
        if type(Higgs[Name]) == "function" then
          Higgs[Name] = function() end
        end
      end
    end
  end)
  -- Retry HiggsBosonComponent neutralization if it loads late.
  pcall(function()
    local function MXP_NeutralizeHiggsComponent()
      local Higgs = package.loaded["GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent"] or rawget(_G, "HiggsBosonComponent")
      if type(Higgs) ~= "table" or Higgs.MXP_HiggsNeutralized then return true end
      Higgs.MXP_HiggsNeutralized = true
      local Collectors = {
        "OnBattleResult", "SendAntiDataFlow", "SendHitFireBtnFlow",
        "SendFingerTouchFlow", "SendHisarData", "OnCrowUpdate",
        "OnCrowUpdateNtf", "OnCrowUpdateNtf2", "OnCrowUpdateNtf3",
        "OnCrowUpdateNtf4", "OnCrowUpdateNtf5"
      }
      for _, Name in ipairs(Collectors) do
        if type(Higgs[Name]) == "function" then
          Higgs[Name] = function() end
        end
      end
      return true
    end
    if not MXP_NeutralizeHiggsComponent() then
      local tt = require("common.time_ticker")
      if tt and tt.AddTimerLoop then
        MXP_Runtime:RegisterTimer("Security.NeutralizeHiggsComponent", tt.AddTimerLoop(2.0, function() if MXP_NeutralizeHiggsComponent() then return end end, 30, 2.0), "global", "Security")
      end
    end
  end)

  -- Also zero Hisar data fingerprint fields on GameInstance.
  pcall(function()
    local USTExtraGameInstance = import("STExtraGameInstance")
    local uGameInstance = USTExtraGameInstance.GetInstance()
    if uGameInstance and uGameInstance.HisarData and type(uGameInstance.HisarData) == "userdata" then
      pcall(function() uGameInstance.HisarData.DeviceId = (_G.MXP_HWIDString or "0"):sub(1,32) end)
      pcall(function()
        if uGameInstance.HisarData.AppInstallData then
          uGameInstance.HisarData.AppInstallData.FirstInstallTime = 0
          uGameInstance.HisarData.AppInstallData.GuidStr = (_G.MXP_HWIDString or "0"):sub(1,32)
        end
      end)
    end
  end)

  _G.MXP_LayerState.HiggsSpoofInstalled = true
end


function MXP_InstallVehicleLagCompShield()
  if _G.MXP_LayerState.VehicleLagCompShieldInstalled then
    return
  end

  -------------------------------------------------------------------------
  -- (15.6.7) VehicleLagCompensationComponent hardening
  -------------------------------------------------------------------------
  pcall(function()
    local VehicleLagCompensationComponent = import("VehicleLagCompensationComponent")
    if not VehicleLagCompensationComponent then return end
    local fields = {
      "TolerateHitDataDelayTime", "TolerateHitDataDelayTimeShootCorner", "TolerateShootRange",
      "TolerateMuzzleDistanceSqured", "TolerateShootPointDistanceSqured",
      "TolerateBulletImpactOffsetDistSqured", "TolerateBulletDirOffsetSquared",
      "TolerateFlyDis", "TolerateVehicleDis", "TolerateNetDelay",
      "MaxTolerateVehicleDis", "MaxGunPosLength", "MaxVehicleSpeed"
    }
    local mt = getmetatable(VehicleLagCompensationComponent)
    if mt and mt.__index then
      for _, f in ipairs(fields) do
        pcall(function()
          local setter = "Set" .. f
          if type(mt.__index[setter]) == "function" then
            mt.__index[setter] = function() end
          end
        end)
      end
    end
  end)

  _G.MXP_LayerState.VehicleLagCompShieldInstalled = true
end


function MXP_InstallLogCleanup()
  if _G.MXP_LayerState.LogCleanupInstalled then
    return
  end

  -------------------------------------------------------------------------
  -- (15.7) Remove logs / traces that can leak mod fingerprint
  -------------------------------------------------------------------------
  pcall(function()
    local function MXP_ClearLogs()
      if not Client or not Client.GetGamePackageName then return end
      local pkg = Client.GetGamePackageName() or "com.pubg.krmobile"
      -- Only delete specific log/crash/trace files and known temp caches.
      -- Do NOT delete whole Saved/Paks, Saved/Config, Saved/GameSave directories
      -- because they contain legitimate game data and mod config.
      local roots = {
        "/storage/emulated/0/Android/data/" .. pkg .. "/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Logs",
        "/storage/emulated/0/Android/data/" .. pkg .. "/cache/logs",
        "/storage/emulated/0/Android/data/" .. pkg .. "/files/tbslog",
        "/storage/emulated/0/Android/data/" .. pkg .. "/files/ProgramBinaryCache"
      }
      -- Always protect mod config and any file inside Saved/Paks/Config/GameSave.
      local alwaysProtectedPrefixes = {
        "/storage/emulated/0/Android/data/" .. pkg .. "/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks",
        "/storage/emulated/0/Android/data/" .. pkg .. "/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Config",
        "/storage/emulated/0/Android/data/" .. pkg .. "/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/GameSave"
      }
      -- Protected files: only files this mod actually reads/writes itself.
      local protectedNames = {
        ["game_runtime_key.bin"] = true,
        ["saved_config.lua"] = true,
        ["saved_config"] = true
      }
      local dangerousSuffixes = {
        ".log", ".tmp", ".cache", ".dmp", ".mdmp",
        "_crash.dmp", "_crash.log", "tombstone", "tombstones",
        "crash", "crashes", "anr", "traces", "stacktrace",
        "bugly", "buglylog", "tlog", "tbslog"
      }
      local dangerousNames = {
        "ShadowTrackerExtra.log",
        "runtime.log",
        "runtime.log",
        "UE4Minidump.dmp",
        "PUBGMOBILE.log",
        "output_log.txt",
        "output.log",
        "debug.log",
        "errors.log",
        "game.log",
        "log.txt",
        "latest.log"
      }
      local function IsPathProtected(path)
        if not path then return false end
        for _, prefix in ipairs(alwaysProtectedPrefixes) do
          if path:sub(1, #prefix) == prefix then return true end
        end
        return false
      end
      -- File-level cleanup only. Never delete whole directories.
      for _, path in ipairs(roots) do
        pcall(function()
          if IsPathProtected(path) then return end
          if Client.DeleteFile then
            for _, name in ipairs(dangerousNames) do
              if not protectedNames[name] then
                Client.DeleteFile(path .. "/" .. name)
              end
            end
          end
        end)
      end
      -- Global temp log files. Still file-level only.
      local globalFileTargets = {
        "/storage/emulated/0/Android/data/" .. pkg .. "/cache/logs/ShadowTrackerExtra.log",
        "/storage/emulated/0/Android/data/" .. pkg .. "/cache/logs/output_log.txt",
        "/storage/emulated/0/Android/data/" .. pkg .. "/cache/logs/debug.log",
        "/data/data/" .. pkg .. "/cache/logs/ShadowTrackerExtra.log",
        "/data/data/" .. pkg .. "/files/tombstones/tombstone_00",
        "/data/data/" .. pkg .. "/files/anr/traces.txt",
        "/data/data/" .. pkg .. "/files/logs/ShadowTrackerExtra.log",
        "/data/data/" .. pkg .. "/files/bugly/BuglyLog.txt",
        "/data/data/" .. pkg .. "/files/tlog/tlog.log",
        "/data/data/" .. pkg .. "/files/tbslog/tbslog.log"
      }
      for _, filePath in ipairs(globalFileTargets) do
        pcall(function()
          if IsPathProtected(filePath) then return end
          if Client.DeleteFile then Client.DeleteFile(filePath) end
        end)
      end
      -- Wipe stack traces from C++ crash reporter if Lua-exposed.
      if Client and type(Client.CrashPostException) == "function" and not Client.MXP_CrashPostTrapped2 then
        Client.MXP_CrashPostTrapped2 = true
        Client.CrashPostException = function() end
      end
    end
    MXP_ClearLogs()
    pcall(function()
      local tt = require("common.time_ticker")
      if tt and tt.AddTimerLoop then
        MXP_Runtime:RegisterTimer("Security.LogCleanup", tt.AddTimerLoop(60.0, MXP_ClearLogs, -1, 60.0), "global", "Security")
      end
    end)
    -- Redirect log sinks so new traces never reach disk.
    pcall(function()
      if Client then
        local noOp = function() end
        local sinks = {"OpenLogFile","WriteLog","FlushLog","AppendLog","LogToFile","SaveLog"}
        for _, name in ipairs(sinks) do
          if type(Client[name]) == "function" and not Client["MXP_"..name.."Redirected"] then
            if _G.MXP_LogDiag then _G.MXP_LogDiag("client.method: redirecting log sink: " .. tostring(name)) end
            Client["MXP_"..name.."Redirected"] = true
            Client[name] = noOp
          end
        end
      end
      if type(slua) == "table" and type(slua.log) == "function" and not slua.MXP_LogRedirected then
        slua.MXP_LogRedirected = true
        slua.log = function() end
      end
      -- Do not override _G.print or _G.io here to avoid breaking engine boot/debug output.
    end)
  end)

  _G.MXP_LayerState.LogCleanupInstalled = true
end


function MXP_InstallResourceErrorShield()
  if _G.MXP_LayerState.ResourceErrorShieldInstalled then
    return
  end

  -------------------------------------------------------------------------
  -- (15.8) "There is an error with the resource files" popup bypass
  -- Targets: Hades/Posidon PAK CRC checks, PufferDownloader corruption,
  --          file-modification monitor, forced quit/restart, resource-error
  --          CommonMsgBoxMgr popups.
  -------------------------------------------------------------------------

  -- Suppress resource-error / forced-update popups.
  pcall(function()
    local ok, logic_common_msg_box = pcall(require, "client.slua.logic.common.logic_common_msg_box")
    if not ok or type(logic_common_msg_box) ~= "table" then
      logic_common_msg_box = rawget(_G, "CommonMsgBoxMgr") or rawget(_G, "logic_common_msg_box")
    end
    if type(logic_common_msg_box) ~= "table" then return end
    if logic_common_msg_box.MXP_ResourceErrorHooked then return end
    logic_common_msg_box.MXP_ResourceErrorHooked = true
    logic_common_msg_box.MXP_ShowRaw = logic_common_msg_box.Show

    local badKeywords = {
      "resource files", "restart the game", "update the client",
      "resource", "pak", "integrity", "verify", "corrupted"
    }

    local function IsBadTitleOrMsg(title, msg)
      if title == 301137 or msg == 25147 then return true end
      local t = type(title) == "string" and title:lower() or ""
      local m = type(msg) == "string" and msg:lower() or ""
      for _, kw in ipairs(badKeywords) do
        if t:find(kw, 1, true) or m:find(kw, 1, true) then return true end
      end
      return false
    end

    logic_common_msg_box.Show = function(style, title, msg, cbOk, cbCancel, btnOk, btnCancel, ...)
      if IsBadTitleOrMsg(title, msg) then
        --
        if type(cbOk) == "function" then pcall(cbOk) end
        return nil
      end
      if logic_common_msg_box.MXP_ShowRaw then
        return logic_common_msg_box.MXP_ShowRaw(style, title, msg, cbOk, cbCancel, btnOk, btnCancel, ...)
      end
    end
  end)

  -- Block forced exit paths.
  pcall(function()
    local GS = package.loaded["client.common.game_status"] or rawget(_G, "GameStatus")
    if type(GS) == "table" and type(GS.QuitGame) == "function" and not GS.MXP_QuitGameHooked then
      GS.MXP_QuitGameHooked = true
      GS.MXP_QuitGameRaw = GS.QuitGame
      GS.QuitGame = function(...)
        return true
      end
    end
    if type(Client) == "table" and type(Client.RestartGame) == "function" and not Client.MXP_RestartGameHooked then
      Client.MXP_RestartGameHooked = true
      Client.MXP_RestartGameRaw = Client.RestartGame
      Client.RestartGame = function(...)
        return true
      end
    end
  end)



  -- Neutralize PufferDownloader local corruption check.
  pcall(function()
    local PD = package.loaded["client.slua.logic.download.puffer.logic_puffer_downloader"] or rawget(_G, "PufferDownloader")
    if type(PD) == "table" and type(PD.CheckCorrupted) == "function" and not PD.MXP_CheckCorruptedHooked then
      PD.MXP_CheckCorruptedHooked = true
      PD.MXP_CheckCorruptedRaw = PD.CheckCorrupted
      PD.CheckCorrupted = function(...)
        return true
      end
    end
  end)

  -- Neutralize login_module file-modification monitor.
  pcall(function()
    local LM = package.loaded["client.slua.logic.login.login_module"] or rawget(_G, "login_module")
    if type(LM) == "table" then
      if type(LM.PakMonitorStart) == "function" and not LM.MXP_PakMonitorStartHooked then
        LM.MXP_PakMonitorStartHooked = true
        LM.MXP_PakMonitorStartRaw = LM.PakMonitorStart
        LM.PakMonitorStart = function(...)
          return true
        end
      end
      if type(rawget(LM, "ModifiedDelegate")) ~= "nil" then
        LM.ModifiedDelegate = nil
      end
    end
  end)

  -- Stub Client.StartMonitorFileModified and delegate broadcast.
  pcall(function()
    if type(Client) == "table" and type(Client.StartMonitorFileModified) == "function" and not Client.MXP_StartMonitorFileModifiedHooked then
      Client.MXP_StartMonitorFileModifiedHooked = true
      Client.MXP_StartMonitorFileModifiedRaw = Client.StartMonitorFileModified
      Client.StartMonitorFileModified = function(...)
        return true
      end
    end
    local GFE = rawget(_G, "slua_GameFrontendHUD")
    if type(GFE) == "table" and type(GFE.OnFileModifiedDelegate) == "table" and not GFE.MXP_FileModifiedDelegateHooked then
      GFE.MXP_FileModifiedDelegateHooked = true
      GFE.MXP_FileModifiedDelegateRaw = GFE.OnFileModifiedDelegate
      local noop = function() end
      GFE.OnFileModifiedDelegate = { Add = function() return {} end, Remove = noop, Broadcast = noop, Clear = noop }
    end
  end)

  -- Force-disable remote config switches that enable file-modified protect / CRC guards.
  -- NOTE: do NOT touch OpenEncryptionManager / BypassAllZeroPak / UseFilenameHideKeyword;
  -- those are needed for normal PAK/network setup and login.
  pcall(function()
    local HDR = package.loaded["client.slua.logic.HDmpveRemote.HDmpveRemote"] or rawget(_G, "HDmpveRemote")
    if type(HDR) == "table" and type(HDR.HDmpveRemoteConfigGetInt) == "function" and not HDR.MXP_HDmpveRemoteConfigGetIntHooked then
      HDR.MXP_HDmpveRemoteConfigGetIntHooked = true
      HDR.MXP_HDmpveRemoteConfigGetIntRaw = HDR.HDmpveRemoteConfigGetInt
      local killKeys = {
        EnableFileModifiedProtectMode = 0,
        FileCRCGuardCheckInterval = 99999999,
        TableGuardCheckInterval = 99999999
      }
      HDR.HDmpveRemoteConfigGetInt = function(key, default)
        if killKeys[key] ~= nil then
          return killKeys[key]
        end
        return HDR.MXP_HDmpveRemoteConfigGetIntRaw(key, default)
      end
    end
  end)

  -- Stub destructive ScriptHelperClient methods if already imported.
  -- NOTE: do NOT stub FullPathFileExist / GetBlockCRC globally; they are used
  -- by legitimate login/asset paths. The hades/posidon handlers are swallowed
  -- above, so these destructive actions are already unreachable.
  pcall(function()
    local SHC = rawget(_G, "ScriptHelperClient") or (import and pcall(import, "ScriptHelperClient") and nil)
    if type(SHC) ~= "table" then return end
    local noops = {"UnmountPakFile", "DeleteFile", "OnPakFileCRCCheck"}
    for _, name in ipairs(noops) do
      if type(SHC[name]) == "function" and not SHC["MXP_"..name.."Hooked"] then
        if _G.MXP_LogDiag then _G.MXP_LogDiag("client.method: stubbing script helper: " .. tostring(name)) end
        SHC["MXP_"..name.."Hooked"] = true
        SHC[name] = function(...) return true end
      end
    end
  end)

  -- Hook GameInstance:ExecuteCMD to drop CRC/verify/table-guard commands only.
  -- NOTE: allow r.OpenEncryptionManager / r.BypassAllZeroPak / r.UseFilenameHideKeyword
  -- so PAK/network setup stays compatible with the server.
  pcall(function()
    local USTExtraGameInstance = import("STExtraGameInstance")
    if not USTExtraGameInstance then return end
    local function HookExecuteCMD(target)
      if type(target) ~= "table" then return end
      if target.MXP_ExecuteCMDHooked then return end
      local raw = target.ExecuteCMD
      if type(raw) ~= "function" then return end
      target.MXP_ExecuteCMDHooked = true
      target.MXP_ExecuteCMDRaw = raw
      target.ExecuteCMD = function(self, cmd)
        if type(cmd) ~= "string" then return raw(self, cmd) end
        local lower = cmd:lower()
        local blockedPrefixes = {
          "pak.filecrcguardcheckinterval", "higgs.tableguardcheckinterval",
          "s.verifypak", "s.ispakverify", "s.forceverifypak", "s.verifypakfiles",
          "s.checkpakintegrity", "s.pakverify", "s.checksignature",
          "r.verifyresource", "r.checkpak", "r.pakverify", "r.signatureverify"
        }
        -- Allow r.OpenEncryptionManager, r.BypassAllZeroPak, r.UseFilenameHideKeyword for normal PAK/network setup.
        for _, p in ipairs(blockedPrefixes) do
          if lower:find(p, 1, true) then
            pcall(function() if _G.print then _G.print("[MXP] blocked ExecuteCMD: " .. cmd) end end)
            return true
          end
        end
        return raw(self, cmd)
      end
    end
    HookExecuteCMD(USTExtraGameInstance)
    pcall(function()
      local gi = USTExtraGameInstance.GetInstance()
      if gi then HookExecuteCMD(gi) end
    end)
    pcall(function()
      local tt = require("common.time_ticker")
      if tt and tt.AddTimerLoop then
        MXP_Runtime:RegisterTimer("Security.ExecuteCMDHook", tt.AddTimerLoop(5.0, function()
          pcall(function()
            local gi = USTExtraGameInstance.GetInstance()
            if gi then HookExecuteCMD(gi) end
          end)
        end, -1, 5.0), "match", "Security")
      end
    end)
  end)

  _G.MXP_LayerState.ResourceErrorShieldInstalled = true
end


function MXP_ReArmResourceErrorShield()
  _G.MXP_LayerState.ResourceErrorShieldInstalled = false
  pcall(MXP_InstallResourceErrorShield)
end


function MXP_InstallLifecycle()
  if _G.MXP_LayerState.LifecycleInstalled then
    return
  end

  -------------------------------------------------------------------------
  -- (16) Deferred native-shield application: once per character change
  -------------------------------------------------------------------------
  pcall(function()
    local GameplayData = package.loaded["GameLua.GameCore.Data.GameplayData"] or rawget(_G, "GameplayData")
    if GameplayData and GameplayData.GetPlayerCharacter then
      local tt_ok, time_ticker = pcall(require, "common.time_ticker")
      if tt_ok and time_ticker and time_ticker.AddTimerLoop then
        local LastCharacter = nil
        local function ApplyNativeShields()
          if _G.MXP_MatchActive ~= true then return end
          local uCharacter = GameplayData.GetPlayerCharacter()
          if not (type(uCharacter) == "userdata" and slua and slua.isValid and slua.isValid(uCharacter)) then
            return
          end
          if LastCharacter == uCharacter then return end
          LastCharacter = uCharacter
          MXP_ShieldLagComp(uCharacter)
          MXP_ShieldMoveAntiCheat(uCharacter)
          MXP_ShieldWeaponAntiCheat(uCharacter)
          -- First run shallow scan; deep scan once per character.
          MXP_ShieldAntiCheatManager(uCharacter, true)
        end
        ApplyNativeShields()
        MXP_Runtime:RegisterTimer("Security.NativeShield", time_ticker.AddTimerLoop(1.0, ApplyNativeShields, -1, 1.0), "global", "Security")
        -- Re-arm integrity stubs periodically because anti-tamper may re-bind them.
        pcall(function()
          MXP_ReArmIntegrity()
          MXP_Runtime:RegisterTimer("Security.ReArmIntegrity", time_ticker.AddTimerLoop(10.0, MXP_ReArmIntegrity, -1, 10.0), "global", "Security")
        end)
        pcall(function()
          MXP_ReArmResourceErrorShield()
          MXP_Runtime:RegisterTimer("Security.ReArmResourceErrorShield", time_ticker.AddTimerLoop(10.0, MXP_ReArmResourceErrorShield, -1, 10.0), "global", "Security")
        end)
        -- Periodic deep re-arm of AntiCheatManagerComp while match active.
        local DeepTick = 0
        MXP_Runtime:RegisterTimer("Security.DeepACManager", time_ticker.AddTimerLoop(5.0, function()
          if _G.MXP_MatchActive ~= true then return end
          local ch = GameplayData.GetPlayerCharacter()
          if ch and slua and slua.isValid(ch) then
            DeepTick = DeepTick + 1
            MXP_ShieldAntiCheatManager(ch, (DeepTick % 6) == 1)
          end
        end, -1, 5.0), "match", "Security")
        MXP_Runtime:RegisterTimer("Security.LateModuleCheck", time_ticker.AddTimerLoop(5.0, function() if _G.MXP_MatchActive == true then pcall(MXP_CheckLateLoadedModules) end end, -1, 5.0), "match", "Security")
        local function MXP_ReArmShootVerifyRPC()
          if _G.MXP_MatchActive ~= true then return end
          local ch = nil
          pcall(function() ch = GameplayData.GetPlayerCharacter() end)
          if not (ch and slua and slua.isValid(ch)) then return end
          if _G._MXP_RPCChar == ch then return end
          _G._MXP_RPCChar = ch
          pcall(function()
            if type(ch.RPC_Server_ShootVertifyFailAlarm) == "function" then
              ch.RPC_Server_ShootVertifyFailAlarm = function() end
            end
          end)
          pcall(function()
            if type(ch.RPC_Server_SynShootMissData) == "function" then
              ch.RPC_Server_SynShootMissData = function() end
            end
          end)
        end
        pcall(MXP_ReArmShootVerifyRPC)
        MXP_Runtime:RegisterTimer("Security.ReArmShootVerifyRPC", time_ticker.AddTimerLoop(2.0, MXP_ReArmShootVerifyRPC, -1, 2.0), "global", "Security")
      end
    end
  end)

  -- ----------------------------------------------------------------------
  -- (17) Minimal telemetry normalizer / debug traceback sanitizer
  -- ----------------------------------------------------------------------
  pcall(function()
    if debug then
      local rawtrace = debug.traceback
      debug.traceback = function(msg, level)
        local s = rawtrace(msg, level)
        if type(s) == "string" then
          s = s:gsub("CharacterBase%.lua", "EngineModule.lua")
          s = s:gsub("[Mm]andau[Xx]p", "")
          s = s:gsub("MXP_", "")
                    s = s:gsub("AddOutfit", "")
          s = s:gsub("client_entry_selfcontained", "client_entry")
          s = s:gsub("MXP_CharacterBase", "EngineModule")
        end
        return s
      end
    end
    _G.MXP_Humanizer = _G.MXP_Humanizer or {
      LastAimTime = 0, AimJitterSeed = 0, ReactionDelay = 0,
      TargetSwitchTime = 0, LastTarget = nil, SwitchCount = 0,
      JitterAmplitude = 0.02, MaxAimDeltaPerTick = 999.0,
      PerceptualSkipChance = 0.0, ReactionDelayBase = 0.0,
      ReactionDelayMax = 0.0, FireHoldMin = 0.04, FireHoldMax = 0.22,
      AimSmoothFactor = 0.18, AimErrorBudget = 0.025,
      BurstPatternIndex = 0, MaxBurstRounds = 3,
      LastFireTime = 0, FireJitter = 0.0,
      TraceNoiseEnabled = true,
      _TraceCache = {}, _TraceTTL = 1.5
    }
    if not _G.MXP_Humanizer_RNGSeeded then
      pcall(function() math.randomseed(os.time() + os.clock() * 1000000) end)
      _G.MXP_Humanizer_RNGSeeded = true
    end
    function MXP_Humanizer_Update()
      local H = _G.MXP_Humanizer
      if not H then return end
      H.ReactionDelay = 0
      H.PerceptualSkipChance = 0
      H.MaxAimDeltaPerTick = 999.0
      H.JitterAmplitude = 0.02 + (math.random() * 0.02 - 0.01)
      H.JitterAmplitude = math.max(0.01, math.min(0.05, H.JitterAmplitude))
      H.AimErrorBudget = 0.015 + (math.random() * 0.02)
      H.FireJitter = math.random() * 0.05 - 0.025
    end
    -- Helpers for feature modules; keep aim/shot patterns within human bounds.
    function _G.MXP_Humanizer_SmoothAim(from, to, dt)
      local H = _G.MXP_Humanizer
      if not H or not from or not to then return to end
      local speed = math.max(0.05, math.min(0.95, H.AimSmoothFactor + math.random() * 0.08))
      local jitter = H.AimErrorBudget or 0.02
      local result = {}
      for k, v in pairs(to) do
        local base = from[k] or v
        if type(base) == "number" and type(v) == "number" then
          local dir = v - base
          local step = dir * speed * (dt and dt * 60 or 1.0)
          local noise = (math.random() * 2 - 1) * jitter * math.abs(dir)
          result[k] = base + step + noise
        else
          result[k] = v
        end
      end
      return result
    end
    function _G.MXP_Humanizer_ShouldSkipAim()
      local H = _G.MXP_Humanizer
      if not H then return false end
      return math.random() < (H.PerceptualSkipChance or 0)
    end
    function _G.MXP_Humanizer_NextFireDelay(baseDelay)
      local H = _G.MXP_Humanizer
      if not H then return baseDelay end
      local jitter = H.FireJitter or 0
      local hold = H.FireHoldMin + math.random() * (H.FireHoldMax - H.FireHoldMin)
      return math.max(0.001, (baseDelay or 0) + jitter + hold)
    end
    function _G.MXP_Humanizer_ApplyTraceNoise(hitPos)
      local H = _G.MXP_Humanizer
      if not H or not H.TraceNoiseEnabled or not hitPos then return hitPos end
      local amp = H.JitterAmplitude or 0.02
      local cache = H._TraceCache
      local now = os.clock()
      local key = string.format("%.1f_%.1f_%.1f", hitPos.X or 0, hitPos.Y or 0, hitPos.Z or 0)
      local cached = cache[key]
      if cached and (now - cached.t) < (H._TraceTTL or 1.5) then
        return cached.v
      end
      local noisy = {}
      for k, v in pairs(hitPos) do
        if type(v) == "number" then noisy[k] = v + (math.random() * 2 - 1) * amp end
      end
      cache[key] = { v = noisy, t = now }
      return noisy
    end
  end)
  _G.MXP_LayerState.LifecycleInstalled = true

end


local function MXPCODE_BypassAntiCheat()
  -- ======================================================================
  -- MXP Anti-Ban Orchestrator v8 (refactored per task-antiban.md)
  -- ======================================================================
  _G.MXP_LifecycleState = "INITIALIZING"
  local layers = {
    {"State", MXP_InstallState},
    {"Callback", MXP_InstallCallback},
    {"Network", MXP_InstallNetwork},
    {"Security", MXP_InstallSecurity},
    {"NativeShield", MXP_InstallNativeShield},
    {"Device", MXP_InstallDevice},
    {"Telemetry", MXP_InstallTelemetry},
    {"Integrity", MXP_InstallIntegrity},
    {"NativeAntiDetect", MXP_InstallNativeAntiDetect},
    {"PvsVisibilityShield", MXP_InstallPvsVisibilityShield},
    {"HiggsSpoof", MXP_InstallHiggsSpoof},
    {"VehicleLagCompShield", MXP_InstallVehicleLagCompShield},
    {"LogCleanup", MXP_InstallLogCleanup},
    {"ResourceErrorShield", MXP_InstallResourceErrorShield},
    {"V96Layers", MXP_InstallV96Layers},
    {"Lifecycle", MXP_InstallLifecycle}
  }
  local installed = {}
  local failed = {}
  for _, entry in ipairs(layers) do
    local name, fn = entry[1], entry[2]
    local ok, err = pcall(fn)
    if ok then
      installed[#installed + 1] = name
    else
      failed[#failed + 1] = name
      MXP_SetLayerError(name, err)
    end
  end
  if _G.MXP_MatchActive == true then
    _G.MXP_LifecycleState = "MATCH_ACTIVE"
  else
    _G.MXP_LifecycleState = "READY"
  end
  if _G.MXPMODNotify then
    pcall(function()
      local status
      if #failed == 0 then
        status = "Bypass OK v9.6"
      else
        status = "Bypass FAIL " .. tostring(#failed)
      end
      _G.MXPMODNotify(status)
    end)
  end
end


do
    local MXP_pcall = pcall
    local MXP_type = type
    local MXP_tostring = tostring
    local MXP_pairs = pairs
    local MXP_ipairs = ipairs
    local MXP_rawset = rawset
    local MXP_rawget = rawget
    local MXP_setmetatable = setmetatable
    local MXP_getmetatable = getmetatable

    local MXP_EB_Log = function() end

    -- Global safe-mode check: when true, interceptors must passthrough.
    local function MXP_EB_IsSafeMode()
        return _G.MXP_SAFEMODE_LOGIN == true
    end

    -- Stable fake device state (avoid random; deterministic per boot).
    -- Stable plausible device state. Values are deterministic per boot but
    -- shaped like real device identifiers so login SDK / channel detection
    -- does not reject them.
    local MXP_EB_Device = {
        Model = "SM-G998B",
        Manufacturer = "samsung",
        Brand = "samsung",
        DeviceName = "p3s",
        Product = "p3sxxx",
        Board = "exynos2100",
        Hardware = "exynos2100",
        Serial = "R3CR10ABCDEF1234",
        IMEI = "354601080123456",
        AndroidId = "a1b2c3d4e5f67890",
        MAC = "A4:DA:32:12:34:56",
        IDFV = "A1B2C3D4-E5F6-7890-1234-567890ABCDEF",
        IsEmulator = false,
        IsSimulator = false
    }

    local MXP_EB_Noop = function() end
    local MXP_EB_NoopTrue = function(...) return true end
    local MXP_EB_NoopZero = function(...) return 0 end
    local MXP_EB_NoopEmpty = function(...) return "" end
    local MXP_EB_NoopTable = function(...) return {} end
    local MXP_EB_NoopValid = function(...) return "VALID", 0 end
    local MXP_EB_NoopIntegrity = function(...) return "MEets_DEVICE_INTEGRITY", 0 end

    -- Exact or strongly-anchored security module signatures only.
    -- Do NOT use loose substrings like "ban" / "detect" / "crash" / "replay" / "security"
    -- because they match many legitimate UI/gameplay modules.
    --
    -- v11: whitelist login/lobby/account/auth/sdk/channel modules so the login UI
    -- can initialize. Emulator/security modules that load during login are now
    -- neutralized at function-level (IsEmulator/CheckEmulator/Scan/Detect/Report/Verify)
    -- instead of replaced with an empty stub.
    local MXP_EB_DenyPatterns = {
        -- exact lower-case substrings that only appear in security paths
        "/anticheat", ".anticheat", "_anticheat_",
        "/tss", ".tss.", "_tss_", "tersafe",
        "/gokuba", ".gokuba", "_gokuba_",
        "/higgs", ".higgs", "_higgs_",
        "/hades", ".hades", "_hades_",
        "/hawk", ".hawk", "_hawk_",
        "_ban_logic", "banhandler", "godzillaban",
        "anticheat_clienttrace", "clienttrace_anticheat", "security_clienttrace",
        "fight_tlog", "anticheat_tlog", "security_tlog",
        "dsmonitor", "ds_security", "dsban", "dsmalicious", "dsdynamic",
        "shootverify", "shoot_verify",
        "securitynotify",
        "eigeninfo",
        "fairgame",
        "send_client_data",
        "on_hades_update",
        "puffer_update",
        "allowapkcollect",
        "dsdynamicdispatched"
    }

    -- Modules required during login that must NOT be stubbed.
    local MXP_EB_LoginWhitelist = {
        "login", "lobby", "account", "auth", "sdk", "channel"
    }

    -- True ban modules can still be fully stubbed even if they contain whitelisted words.
    local MXP_EB_BanModuleForceDeny = {
        "ban_login_module", "banhandler", "godzillaban", "ban_logic", "banlogic"
    }

    -- Function-level neutralization targets for emulator/security modules loaded during login.
    local MXP_EB_SecurityFunctionNames = {
        "isemulator", "checkemulator", "checksimulator", "emulatorcheck", "emulator_check",
        "scan", "scanemulator", "scan_device", "scandevice",
        "detect", "detectemulator", "detectroot", "detectrootstate", "detect_debug", "detectdebug",
        "report", "reportemulator", "reportstatus", "reportdevice", "reportresult",
        "verify", "verifydevice", "verifyintegrity", "verifyenvironment", "verifyemulator",
        "check", "checkdevice", "checkintegrity", "checkenvironment", "checkroot", "checkdebug",
        "getdevicestate", "getemulatorstate", "getsecuritystatus", "getriskstatus",
        "isdevicecompromised", "isrooted", "isjailbroken", "isvirtual", "issimulator",
        "collect", "collectdevice", "collectdata", "senddata"
    }

    local function MXP_EB_IsBanModuleForceDeny(name)
        local low = MXP_tostring(name):lower()
        for _, pat in MXP_ipairs(MXP_EB_BanModuleForceDeny) do
            if low:find(pat, 1, true) then return true end
        end
        return false
    end

    local function MXP_EB_IsLoginWhitelisted(name)
        local low = MXP_tostring(name):lower()
        for _, pat in MXP_ipairs(MXP_EB_LoginWhitelist) do
            if low:find(pat, 1, true) then return true end
        end
        return false
    end

    local function MXP_EB_IsSecurityModule(name)
        -- True ban modules always blocked regardless of whitelist words.
        if MXP_EB_IsBanModuleForceDeny(name) then return true end
        -- If the module is needed for login/auth, do not block it.
        if MXP_EB_IsLoginWhitelisted(name) then return false end
        local low = MXP_tostring(name):lower()
        for _, pat in MXP_ipairs(MXP_EB_DenyPatterns) do
            if low:find(pat, 1, true) then
                return true
            end
        end
        -- extra whole-segment matches
        local segs = {"anticheat/security", "security_anticheat", "tss_security", "security_tss",
                      "/safetynet", "/playintegrity",
                      "anticheat_telemetry", "telemetry_anticheat", "tss_telemetry", "telemetry_tss",
                      "anticheat_anomaly", "anomaly_anticheat", "tss_anomaly", "anomaly_tss",
                      "anticheat_exception", "exception_anticheat", "tss_exception", "exception_tss",
                      "anticheat_crash", "crash_anticheat", "tss_crash", "crash_tss"}
        for _, seg in MXP_ipairs(segs) do
            if low:find(seg, 1, true) then return true end
        end
        return false
    end

    local function MXP_EB_NeutralizeTable(mod)
        if MXP_type(mod) ~= "table" then return end
        for k, v in MXP_pairs(mod) do
            if MXP_type(v) == "function" then
                MXP_pcall(function() mod[k] = MXP_EB_Noop end)
            end
        end
    end

    -- Surgical function-level neutralization for emulator/security modules.
    -- Preserves non-security functions so login/lobby/account modules continue working.
    local function MXP_EB_SurgicallyNeutralize(mod)
        if MXP_type(mod) ~= "table" then return end
        local Visiting = {}
        local function Walk(tbl)
            if MXP_type(tbl) ~= "table" or Visiting[tbl] then return end
            Visiting[tbl] = true
            for k, v in MXP_pairs(tbl) do
                if MXP_type(v) == "function" then
                    local lowk = MXP_tostring(k):lower()
                    local matched = false
                    for _, pat in MXP_ipairs(MXP_EB_SecurityFunctionNames) do
                        if lowk:find(pat, 1, true) then
                            matched = true
                            break
                        end
                    end
                    if matched then
                        MXP_pcall(function() tbl[k] = MXP_EB_Noop end)
                    end
                elseif MXP_type(v) == "table" then
                    Walk(v)
                end
            end
            Visiting[tbl] = nil
        end
        Walk(mod)
    end

    -- Intercept require() but ONLY for known security module signatures.
    local MXP_EB_RawRequire = _G.require
    if MXP_type(MXP_EB_RawRequire) == "function" then
        local function MXP_EB_Require(name, ...)
            if _G.MXP_LogDiag then _G.MXP_LogDiag("require: checking module: " .. MXP_tostring(name)) end
            local ok, mod = MXP_pcall(MXP_EB_RawRequire, name, ...)
            if not ok or mod == nil then
                if _G.MXP_LogDiag then _G.MXP_LogDiag("require: load failed: " .. MXP_tostring(name)) end
                return mod
            end
            if MXP_EB_IsSafeMode() then
                return mod
            end
            if MXP_EB_IsSecurityModule(name) then
                if _G.MXP_LogDiag then _G.MXP_LogDiag("require: denied security module: " .. MXP_tostring(name)) end
                -- Login-related security modules: keep module untouched.
                -- Surgical neutralization of check/verify/detect/report/collect functions
                -- inside login/auth/lobby modules has been observed to break login UI option
                -- discovery. Only hard ban modules are fully stubbed.
                if MXP_EB_IsLoginWhitelisted(name) and not MXP_EB_IsBanModuleForceDeny(name) then
                    return mod
                end
                -- Hard security / ban modules: replace with empty stub.
                local stub = {}
                MXP_EB_NeutralizeTable(mod)
                MXP_EB_NeutralizeTable(stub)
                if package and package.loaded then
                    MXP_pcall(function() package.loaded[name] = stub end)
                end
                return stub
            end
            return mod
        end
        _G.require = MXP_EB_Require
    end


    -- Stub crash/exception/log sinks on Client when available.
    local function MXP_EB_StubClientSecurity()
        local Client = MXP_rawget(_G, "Client")
        if MXP_type(Client) ~= "table" then return end
        local safe = MXP_EB_IsSafeMode()
        local sinks = {
            "PostException", "SendCrashLog", "PostLog", "PostCrashLog", "NativePostException",
            "NativePostLog", "ReportCrash", "UploadCrash", "SubmitCrash", "SendTombstone",
            "SendANR", "SendTrace", "ReportLuaError", "ReportException", "PostTombstone",
            "CrashPostException", "RecordLuaExceptionInfo", "AddCrashContextData",
            "ReportCheatInfo", "ReportPlayerCheat", "SendAntiData", "TssSdkCmd",
            "GEMReportEvent", "GEMReportSubEvent"
        }
        for _, n in MXP_ipairs(sinks) do
            if MXP_type(Client[n]) == "function" then
                if safe then
                    MXP_pcall(function()
                        local raw = Client[n]
                        Client[n] = function(...) MXP_EB_Log("SAFEMODE: " .. n .. " passthrough") return raw(...) end
                    end)
                else
                    MXP_pcall(function() Client[n] = MXP_EB_Noop end)
                end
            end
        end
        if safe then
            MXP_pcall(function()
                local raw = Client.AddAttachFileString
                if MXP_type(raw) == "function" then
                    Client.AddAttachFileString = function(...) MXP_EB_Log("SAFEMODE: AddAttachFileString passthrough") return raw(...) end
                end
            end)
        else
            MXP_pcall(function() Client.AddAttachFileString = MXP_EB_NoopTrue end)
        end
    end
    MXP_EB_StubClientSecurity()

    -- Sanitize debug.traceback so stack traces cannot leak mod frames.
    local MXP_EB_RawTraceback = debug and debug.traceback
    if MXP_type(MXP_EB_RawTraceback) == "function" then
        debug.traceback = function(msg, level)
            local ok, tb = MXP_pcall(MXP_EB_RawTraceback, msg, level)
            if not ok or MXP_type(tb) ~= "string" then
                return MXP_tostring(msg or "")
            end
            local out = tb:gsub("MXP_[^%s:]+", "MXP_X")
            out = out:gsub("client_entry_selfcontained", "client_entry")
            out = out:gsub("MandauXp", "M_X")
            return out
        end
    end

    -- Hook ExecuteCMD to drop CRC/verify/dump commands.
    local function MXP_EB_HookExecuteCMD()
        local blocked = {
            ["t.MaxFPS"] = false,
            ["r.FrameRateLimit"] = false,
            ["ke." ] = true,
            ["anticheat"] = true,
            ["verify"] = true,
            ["crc"] = true,
            ["dump"] = true,
            ["guard"] = true,
            ["checksum"] = true,
            ["integrity"] = true,
            ["tss"] = true,
            ["slua.check"] = true,
            ["slua.guard"] = true,
            ["lua.guard"] = true,
            ["gscript"] = true
        }
        local function ShouldBlock(cmd)
            local c = MXP_tostring(cmd):lower()
            for k, v in MXP_pairs(blocked) do
                if c:find(k, 1, true) then return v end
            end
            return false
        end
        local GameInstance = MXP_rawget(_G, "GameInstance") or MXP_rawget(_G, "UE4")
        if MXP_type(GameInstance) == "table" and MXP_type(GameInstance.ExecuteCMD) == "function" and not GameInstance.MXP_EB_ExecuteCMDHooked then
            local raw = GameInstance.ExecuteCMD
            GameInstance.MXP_EB_ExecuteCMDHooked = true
            GameInstance.MXP_EB_ExecuteCMDRaw = raw
            GameInstance.ExecuteCMD = function(self, cmd, ...)
                if MXP_EB_IsSafeMode() then
                    return MXP_pcall(raw, self, cmd, ...)
                end
                if ShouldBlock(cmd) then
                    return false
                end
                return MXP_pcall(raw, self, cmd, ...)
            end
        end
    end
    MXP_EB_HookExecuteCMD()

    -- Spoof device environment getters. Only override existing functions; never create new fields.
    local function MXP_EB_SpoofDevice()
        local Client = MXP_rawget(_G, "Client")
        if MXP_type(Client) ~= "table" then return end
        if MXP_EB_IsSafeMode() then return end
        local getters = {
            GetDeviceModel = MXP_EB_Device.Model,
            GetDeviceManufacturer = MXP_EB_Device.Manufacturer,
            GetDeviceBrand = MXP_EB_Device.Brand,
            GetDeviceName = MXP_EB_Device.DeviceName,
            GetProductName = MXP_EB_Device.Product,
            GetBoard = MXP_EB_Device.Board,
            GetHardware = MXP_EB_Device.Hardware,
            GetSerialNumber = MXP_EB_Device.Serial,
            GetIMEI = MXP_EB_Device.IMEI,
            GetAndroidId = MXP_EB_Device.AndroidId,
            GetMacAddress = MXP_EB_Device.MAC,
            GetIDFV = MXP_EB_Device.IDFV,
            IsEmulator = MXP_EB_Device.IsEmulator,
            IsSimulator = MXP_EB_Device.IsSimulator
        }
        for name, val in MXP_pairs(getters) do
            if MXP_type(Client[name]) == "function" then
                if _G.MXP_LogDiag then _G.MXP_LogDiag("client.method: spoofing device getter: " .. MXP_tostring(name)) end
                MXP_pcall(function()
                    Client[name] = function() return val end
                end)
            end
        end
    end
    MXP_EB_SpoofDevice()

    -- Re-arm hook via timer loop when engine globals appear later.
    local function MXP_EB_PeriodicRearm()
        MXP_pcall(MXP_EB_StubClientSecurity)
        MXP_pcall(MXP_EB_SpoofDevice)
        MXP_pcall(MXP_EB_HookExecuteCMD)
    end
    local ticker
    MXP_pcall(function() ticker = _G.require("common.time_ticker") end)
    if MXP_type(ticker) == "table" and MXP_type(ticker.AddTimerLoop) == "function" then
        if not _G.MXP_EB_RearmHandle then
            _G.MXP_EB_RearmHandle = ticker.AddTimerLoop(5.0, MXP_EB_PeriodicRearm)
        end
    end

    -- ======================================================================
    -- MXP Security Module Denylist + Require Interceptor Integration v11
    -- ======================================================================
    function MXP_BuildSecurityModuleDenylist()
        return {
            -- exact lower-case substrings inside module paths
            "/anticheat", ".anticheat", "_anticheat_",
            "/tss", ".tss.", "_tss_", "tersafe",
            "/gokuba", ".gokuba", "_gokuba_",
            "/higgs", ".higgs", "_higgs_",
            "/hades", ".hades", "_hades_",
            "/hawk", ".hawk", "_hawk_",
            "_ban_logic", "banhandler", "godzillaban",
            "anticheat_clienttrace", "clienttrace_anticheat", "security_clienttrace",
            "fight_tlog", "anticheat_tlog", "security_tlog",
            "dsmonitor", "ds_security", "dsban", "dsmalicious", "dsdynamic",
            "shootverify", "shoot_verify",
            "securitynotify",
            "eigeninfo",
            "fairgame",
            "send_client_data",
            "on_hades_update",
            "puffer_update",
            "allowapkcollect",
            "dsdynamicdispatched"
        }
    end

    -- Modules required during login that must NOT be stubbed.
    local MXP_LoginWhitelist = {
        "login", "lobby", "account", "auth", "sdk", "channel"
    }

    -- True ban modules can still be fully stubbed even if they contain whitelisted words.
    local MXP_BanModuleForceDeny = {
        "ban_login_module", "banhandler", "godzillaban", "ban_logic", "banlogic"
    }

    -- Function-level neutralization targets for emulator/security modules loaded during login.
    local MXP_SecurityFunctionNames = {
        "isemulator", "checkemulator", "checksimulator", "emulatorcheck", "emulator_check",
        "scan", "scanemulator", "scan_device", "scandevice",
        "detect", "detectemulator", "detectroot", "detectrootstate", "detect_debug", "detectdebug",
        "report", "reportemulator", "reportstatus", "reportdevice", "reportresult",
        "verify", "verifydevice", "verifyintegrity", "verifyenvironment", "verifyemulator",
        "check", "checkdevice", "checkintegrity", "checkenvironment", "checkroot", "checkdebug",
        "getdevicestate", "getemulatorstate", "getsecuritystatus", "getriskstatus",
        "isdevicecompromised", "isrooted", "isjailbroken", "isvirtual", "issimulator",
        "collect", "collectdevice", "collectdata", "senddata"
    }

    local function MXP_IsBanModuleForceDeny(name)
        local low = MXP_tostring(name):lower()
        for _, pat in MXP_ipairs(MXP_BanModuleForceDeny) do
            if low:find(pat, 1, true) then return true end
        end
        return false
    end

    local function MXP_IsLoginWhitelisted(name)
        local low = MXP_tostring(name):lower()
        for _, pat in MXP_ipairs(MXP_LoginWhitelist) do
            if low:find(pat, 1, true) then return true end
        end
        return false
    end

    function MXP_NeutralizeModule(M)
        if MXP_type(M) ~= "table" or M.MXP_Neutralized then return M end
        M.MXP_Neutralized = true
        local Visiting = {}
        local function Walk(tbl)
            if MXP_type(tbl) ~= "table" or Visiting[tbl] then return end
            Visiting[tbl] = true
            for k, v in MXP_pairs(tbl) do
                if MXP_type(v) == "function" then
                    MXP_pcall(function() tbl[k] = MXP_EB_Noop end)
                elseif MXP_type(v) == "table" then
                    Walk(v)
                end
            end
            Visiting[tbl] = nil
        end
        Walk(M)
        return M
    end

    -- Surgical function-level neutralization for emulator/security modules.
    local function MXP_SurgicallyNeutralize(mod)
        if MXP_type(mod) ~= "table" then return end
        local Visiting = {}
        local function Walk(tbl)
            if MXP_type(tbl) ~= "table" or Visiting[tbl] then return end
            Visiting[tbl] = true
            for k, v in MXP_pairs(tbl) do
                if MXP_type(v) == "function" then
                    local lowk = MXP_tostring(k):lower()
                    local matched = false
                    for _, pat in MXP_ipairs(MXP_SecurityFunctionNames) do
                        if lowk:find(pat, 1, true) then
                            matched = true
                            break
                        end
                    end
                    if matched then
                        MXP_pcall(function() tbl[k] = MXP_EB_Noop end)
                    end
                elseif MXP_type(v) == "table" then
                    Walk(v)
                end
            end
            Visiting[tbl] = nil
        end
        Walk(mod)
    end

    function MXP_InstallRequireInterceptor()
        if _G.MXP_RequireInterceptorInstalled then return end
        _G.MXP_RequireInterceptorInstalled = true

        local DenyPatterns = MXP_BuildSecurityModuleDenylist()
        local function IsSecurityModule(name)
            if MXP_IsBanModuleForceDeny(name) then return true end
            if MXP_IsLoginWhitelisted(name) then return false end
            local low = MXP_tostring(name):lower()
            for _, pat in MXP_ipairs(DenyPatterns) do
                if low:find(pat, 1, true) then
                    return true
                end
            end
            local segs = {"anticheat/security", "security_anticheat", "tss_security", "security_tss",
                          "/safetynet", "/playintegrity",
                          "anticheat_telemetry", "telemetry_anticheat", "tss_telemetry", "telemetry_tss",
                          "anticheat_anomaly", "anomaly_anticheat", "tss_anomaly", "anomaly_tss",
                          "anticheat_exception", "exception_anticheat", "tss_exception", "exception_tss",
                          "anticheat_crash", "crash_anticheat", "tss_crash", "crash_tss"}
            for _, seg in MXP_ipairs(segs) do
                if low:find(seg, 1, true) then return true end
            end
            return false
        end

        local RawRequire = _G.require
        if MXP_type(RawRequire) ~= "function" then return end

        local function InterceptedRequire(name, ...)
            if _G.MXP_LogDiag then _G.MXP_LogDiag("require2: checking module: " .. MXP_tostring(name)) end
            local ok, mod = MXP_pcall(RawRequire, name, ...)
            if not ok then
                if _G.MXP_LogDiag then _G.MXP_LogDiag("require2: load failed: " .. MXP_tostring(name)) end
                return mod
            end
            if _G.MXP_SAFEMODE_LOGIN == true then
                return mod
            end
            if mod ~= nil and IsSecurityModule(name) then
                if _G.MXP_LogDiag then _G.MXP_LogDiag("require2: denied security module: " .. MXP_tostring(name)) end
                -- Login-related security modules: keep module untouched.
                -- Surgical neutralization inside login/auth/lobby modules breaks login UI.
                if MXP_IsLoginWhitelisted(name) and not MXP_IsBanModuleForceDeny(name) then
                    return mod
                end
                local sanitized = MXP_NeutralizeModule(mod)
                if package and package.loaded then
                    MXP_pcall(function() package.loaded[name] = sanitized end)
                end
                return sanitized
            end
            return mod
        end

        _G.require = InterceptedRequire
    end

    MXP_InstallRequireInterceptor()
    -- ======================================================================
    -- END MXP Security Module Denylist + Require Interceptor Integration v12
    -- ======================================================================

    _G.MXP_EB_Installed = true
end


-- Legacy global aliases
_G.MXP_RegisterTimer = function(name, handle, scope, owner)
    return MXP_Runtime:RegisterTimer(name, handle, scope, owner)
end
_G.MXP_RemoveTimer = function(name)
    return MXP_Runtime:RemoveTimer(name)
end
_G.MXP_RemoveAllTimers = function()
    return MXP_Runtime:StopAllTimers()
end
_G.MXP_HasTimer = function(name)
    return MXP_Runtime:HasTimer(name)
end

-- Initialize match-state global used by Higgs spoof / lifecycle hooks.
_G.MXP_MatchActive = false

-- Run bypass immediately on load so early security modules are intercepted.
pcall(MXPCODE_BypassAntiCheat)

-- ======================================================================
-- CharacterBase combine_class redirect
-- ======================================================================
local MXP_COMBINE_REDIRECT_PATH = "GameLua.GameCore.Framework.CharacterBase"
local MXP_CHARACTERBASE_RESULT = nil
local MXP_CHARACTERBASE_FUNC = nil

local function MXP_Log(msg)
    -- no-op
end

local function MXP_CompileModOnce()
    if MXP_CHARACTERBASE_FUNC ~= nil then return MXP_CHARACTERBASE_FUNC end
    local env = _ENV or _G
    local fn, err = load(MXP_CHARACTERBASE_SOURCE, "@MXP_CharacterBase.lua", "t", env)
    if not fn then
        MXP_Log("MXP mod compile failed: " .. tostring(err))
        return nil
    end
    MXP_CHARACTERBASE_FUNC = fn
    return fn
end

local function MXP_ExecuteMod()
    if MXP_CHARACTERBASE_RESULT ~= nil then return MXP_CHARACTERBASE_RESULT end
    local fn = MXP_CompileModOnce()
    if not fn then return nil end
    local ok, res = pcall(fn)
    if not ok then
        MXP_Log("MXP CharacterBase execution failed: " .. tostring(res))
        return nil
    end
    MXP_CHARACTERBASE_RESULT = res
    if _G.package and _G.package.loaded then
        _G.package.loaded[MXP_COMBINE_REDIRECT_PATH] = res
    end
    return res
end

local function MXP_CombineRedirect(Path, OriginRequire)
    if Path == MXP_COMBINE_REDIRECT_PATH then
        local res = MXP_ExecuteMod()
        if res ~= nil then
            return res
        end
        MXP_Log("MXP CharacterBase failed, falling back to original")
    end
    return OriginRequire(Path)
end
_G.MXP_CombineRedirect = MXP_CombineRedirect

local rawRequire = _G.require
local function mxpRequire(name, ...)
    local mod = rawRequire(name, ...)
    if name == "combine_class" then
        local cc = mod
        if type(cc) == "table" and type(cc.AddLuaRequireRedirect) == "function" and not cc.MXP_CombineRedirectHooked then
            cc.MXP_CombineRedirectHooked = true
            local ok2, err = pcall(cc.AddLuaRequireRedirect, MXP_COMBINE_REDIRECT_PATH, MXP_CombineRedirect)
            if ok2 then
                MXP_Log("combine_class redirect registered")
            else
                MXP_Log("combine_class redirect failed: " .. tostring(err))
            end
            if type(cc.HookLuaRequire) == "function" and not cc.MXP_HookLuaRequireHooked then
                cc.MXP_HookLuaRequireHooked = true
                local rawHook = cc.HookLuaRequire
                cc.HookLuaRequire = function(isHook, ...)
                    local results = { pcall(rawHook, isHook, ...) }
                    if not results[1] then return end
                    if isHook then
                        pcall(cc.AddLuaRequireRedirect, MXP_COMBINE_REDIRECT_PATH, MXP_CombineRedirect)
                    end
                    local n = #results
                    if n <= 1 then return end
                    return table.unpack(results, 2, n)
                end
            end
        end
    end
    return mod
end
_G.require = mxpRequire

-- Embedded CharacterBase mod source (was external MXP_CharacterBase.lua)