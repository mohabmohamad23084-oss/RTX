-- ============================================================================
-- SIMON SAFE GUARD - Lua Runtime Protection
-- Developer: SIMON @GNGGD
-- Channel: https://t.me/CCVOPO
-- Version: 1.0.0
--
-- Purpose:
--   Protect this Lua script's own runtime stability and configuration.
--   This module does NOT bypass, disable, hide from, or interfere with
--   anti-cheat, integrity verification, telemetry, screenshots, or game security.
--   It is not an "anti-ban" guarantee.
--
-- Compatible with standard Lua 5.1+ where possible.
-- ============================================================================

local SIMON_GUARD = {
    Name = "SIMON SAFE GUARD",
    Version = "1.0.0",
    Developer = "SIMON @GNGGD",
    Channel = "https://t.me/CCVOPO",

    Enabled = true,
    StartedAt = os and os.time and os.time() or 0,

    Stats = {
        Calls = 0,
        Errors = 0,
        Rejected = 0,
        Checks = 0
    },

    Status = {},
    Config = {
        MaxStringLength = 256,
        MaxTableEntries = 500,
        MaxCallRate = 30,
        LogErrors = true
    }
}

local function safeString(value, limit)
    local ok, result = pcall(tostring, value)
    if not ok then return "<unprintable>" end
    limit = tonumber(limit) or 256
    if #result > limit then
        result = result:sub(1, limit) .. "..."
    end
    return result
end

local function log(level, message)
    if not SIMON_GUARD.Config.LogErrors and level == "ERROR" then
        return
    end

    local line = "[SIMON SAFE GUARD][" .. safeString(level, 16) .. "] "
        .. safeString(message, SIMON_GUARD.Config.MaxStringLength)

    pcall(function()
        if type(_G.LexusNotify) == "function" then
            _G.LexusNotify(line)
        end
    end)

    pcall(function()
        if type(print) == "function" then print(line) end
    end)
end

local function setStatus(name, state, detail)
    SIMON_GUARD.Status[name] = {
        State = state,
        Detail = detail and safeString(detail, 160) or "",
        CheckedAt = os and os.time and os.time() or 0
    }
end

local function countTableEntries(value, maximum)
    if type(value) ~= "table" then return nil, "expected table" end

    local count = 0
    for _ in pairs(value) do
        count = count + 1
        if count > maximum then
            return nil, "table entry limit exceeded"
        end
    end

    return count
end

local function validateConfig(config)
    if type(config) ~= "table" then
        return false, "configuration must be a table"
    end

    local entries, err = countTableEntries(config, 100)
    if not entries then return false, err end

    local numericFields = {
        "MaxStringLength",
        "MaxTableEntries",
        "MaxCallRate"
    }

    for _, key in ipairs(numericFields) do
        local value = config[key]
        if value ~= nil and (type(value) ~= "number" or value < 1) then
            return false, "invalid configuration field: " .. key
        end
    end

    if config.LogErrors ~= nil and type(config.LogErrors) ~= "boolean" then
        return false, "LogErrors must be boolean"
    end

    return true
end

-- Safe protected call. Errors are captured instead of crashing the caller.
function SIMON_GUARD.SafeCall(label, callback, ...)
    if not SIMON_GUARD.Enabled then
        SIMON_GUARD.Stats.Rejected = SIMON_GUARD.Stats.Rejected + 1
        return false, "guard disabled"
    end

    if type(callback) ~= "function" then
        SIMON_GUARD.Stats.Rejected = SIMON_GUARD.Stats.Rejected + 1
        return false, "callback is not a function"
    end

    local args = {...}
    SIMON_GUARD.Stats.Calls = SIMON_GUARD.Stats.Calls + 1

    local results = { pcall(function()
        return callback(unpack(args))
    end) }

    if not results[1] then
        SIMON_GUARD.Stats.Errors = SIMON_GUARD.Stats.Errors + 1
        setStatus(label or "unknown", "ERROR", results[2])
        log("ERROR", (label or "callback") .. ": " .. safeString(results[2], 180))
        return false, results[2]
    end

    setStatus(label or "callback", "OK")
    return true, unpack(results, 2)
end

-- Validate a value before it is used by the script.
function SIMON_GUARD.Validate(value, expectedType, label)
    SIMON_GUARD.Stats.Checks = SIMON_GUARD.Stats.Checks + 1

    if type(value) ~= expectedType then
        setStatus(label or "value", "REJECTED", "expected " .. expectedType)
        SIMON_GUARD.Stats.Rejected = SIMON_GUARD.Stats.Rejected + 1
        return false
    end

    if expectedType == "string"
        and #value > SIMON_GUARD.Config.MaxStringLength then
        setStatus(label or "value", "REJECTED", "string too long")
        SIMON_GUARD.Stats.Rejected = SIMON_GUARD.Stats.Rejected + 1
        return false
    end

    if expectedType == "table" then
        local count = countTableEntries(value, SIMON_GUARD.Config.MaxTableEntries)
        if not count then
            setStatus(label or "value", "REJECTED", "table too large")
            SIMON_GUARD.Stats.Rejected = SIMON_GUARD.Stats.Rejected + 1
            return false
        end
    end

    setStatus(label or "value", "OK")
    return true
end

-- A simple per-key call limiter to prevent accidental runaway loops.
local rateState = {}

function SIMON_GUARD.AllowCall(key, interval)
    key = safeString(key or "default", 80)
    interval = tonumber(interval) or 1

    local now = os and os.clock and os.clock() or 0
    local previous = rateState[key]

    if previous and now > 0 and (now - previous) < interval then
        SIMON_GUARD.Stats.Rejected = SIMON_GUARD.Stats.Rejected + 1
        return false
    end

    rateState[key] = now
    return true
end

-- Check that this module's public API still contains the expected functions.
-- This is a runtime consistency check, not cryptographic tamper protection.
local expectedFunctions = {
    "SafeCall",
    "Validate",
    "AllowCall",
    "HealthCheck",
    "GetReport",
    "SetConfig"
}

function SIMON_GUARD.HealthCheck()
    local passed = true

    for _, name in ipairs(expectedFunctions) do
        if type(SIMON_GUARD[name]) ~= "function" then
            passed = false
            setStatus("API_" .. name, "ERROR", "missing or replaced function")
        else
            setStatus("API_" .. name, "OK")
        end
    end

    local configOK, configError = validateConfig(SIMON_GUARD.Config)
    if not configOK then
        passed = false
        setStatus("CONFIG", "ERROR", configError)
    else
        setStatus("CONFIG", "OK")
    end

    SIMON_GUARD.Stats.Checks = SIMON_GUARD.Stats.Checks + 1
    return passed
end

function SIMON_GUARD.SetConfig(newConfig)
    local ok, err = validateConfig(newConfig)
    if not ok then
        log("WARN", "Configuration rejected: " .. safeString(err, 120))
        return false, err
    end

    local merged = {}
    for key, value in pairs(SIMON_GUARD.Config) do
        merged[key] = value
    end
    for key, value in pairs(newConfig) do
        merged[key] = value
    end

    SIMON_GUARD.Config = merged
    setStatus("CONFIG", "OK")
    return true
end

function SIMON_GUARD.GetReport()
    local report = {
        Name = SIMON_GUARD.Name,
        Version = SIMON_GUARD.Version,
        Developer = SIMON_GUARD.Developer,
        Channel = SIMON_GUARD.Channel,
        Enabled = SIMON_GUARD.Enabled,
        Stats = {},
        Status = {}
    }

    for key, value in pairs(SIMON_GUARD.Stats) do
        report.Stats[key] = value
    end

    for key, value in pairs(SIMON_GUARD.Status) do
        report.Status[key] = {
            State = value.State,
            Detail = value.Detail,
            CheckedAt = value.CheckedAt
        }
    end

    return report
end

-- Optional helper for safely running a sequence of independent checks.
function SIMON_GUARD.RunChecks(checks)
    if type(checks) ~= "table" then
        return false, "checks must be a table"
    end

    local allPassed = true
    for name, callback in pairs(checks) do
        local ok = SIMON_GUARD.SafeCall(name, callback)
        if not ok then allPassed = false end
    end

    return allPassed
end

-- Safe shutdown for this module only. It does not alter game/security systems.
function SIMON_GUARD.Shutdown()
    SIMON_GUARD.Enabled = false
    setStatus("MODULE", "STOPPED")
    log("INFO", "SIMON SAFE GUARD stopped safely")
    return true
end

-- Startup self-test.
local startupOK = SIMON_GUARD.HealthCheck()
if startupOK then
    setStatus("MODULE", "READY")
    log("INFO", "SIMON SAFE GUARD v" .. SIMON_GUARD.Version .. " loaded")
else
    setStatus("MODULE", "DEGRADED", "startup self-test failed")
    log("WARN", "Startup self-test reported an issue")
end

return SIMON_GUARD
