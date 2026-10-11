--SIMON

local Security = {
    VERSION = "6.0.0",
    ENABLED = true,
    LOG     = {},
    EVENTS  = {},
    VIOLATIONS = 0,
    STARTED_AT = os.time(),
    METRICS = {
        validations=0, failures=0, rateLimited=0, sanitized=0,
        safeCalls=0, blocked=0, allowed=0, banned=0,
        tokens=0, sessions=0, nonces=0, hashes=0,
        signs=0, encrypts=0, decrypts=0, alarms=0,
        jsonEncodes=0, jsonDecodes=0, sends=0, blocks=0,
        fwRules=0, fwInspected=0
    }
}

-- =====================================================================
-- §0  أدوات أساسية
-- =====================================================================

local type_        = type
local tostring_    = tostring
local tonumber_    = tonumber
local pairs_       = pairs
local ipairs_      = ipairs
local next_        = next
local pcall_       = pcall
local xpcall_      = xpcall
local select_      = select
local setmetatable_= setmetatable
local getmetatable_= getmetatable
local rawget_      = rawget
local rawset_      = rawset
local error_       = error
local require_     = require

local os_time      = os.time
local os_clock     = os.clock
local os_date      = os.date

local math_floor   = math.floor
local math_max     = math.max
local math_min     = math.min
local math_abs     = math.abs
local math_random  = math.random
local math_huge    = math.huge

local str_format   = string.format
local str_byte     = string.byte
local str_char     = string.char
local str_sub      = string.sub
local str_lower    = string.lower
local str_upper    = string.upper
local str_find     = string.find
local str_match    = string.match
local str_gmatch   = string.gmatch
local str_gsub     = string.gsub
local str_rep      = string.rep
local str_reverse  = string.reverse

local tbl_insert   = table.insert
local tbl_remove   = table.remove
local tbl_concat   = table.concat
local tbl_sort     = table.sort

local function now() return os_time() end
local function safe_tostring(v)
    local ok, s = pcall_(tostring_, v)
    if ok then return s end
    return "<unprintable>"
end

-- =====================================================================
-- §1  بوابة التدقيق (Audit)
-- =====================================================================

Security.MAX_LOG = 50000
Security.LOG_LEVELS = { debug=1, info=2, warn=3, error=4, critical=5 }
Security.MIN_LEVEL = 1

function Security.Log(event, detail, level)
    level = level or "info"
    if (Security.LOG_LEVELS[level] or 2) < Security.MIN_LEVEL then return end
    local entry = {
        event  = safe_tostring(event),
        detail = safe_tostring(detail or ""),
        level  = level,
        time   = now()
    }
    tbl_insert(Security.LOG, entry)
    if #Security.LOG > Security.MAX_LOG then tbl_remove(Security.LOG, 1) end
    return entry
end

function Security.Fail(reason, level)
    Security.VIOLATIONS = Security.VIOLATIONS + 1
    Security.METRICS.failures = Security.METRICS.failures + 1
    Security.Log("VIOLATION", reason, level or "warn")
    return false
end

function Security.Dump()
    local out = {}
    for i = 1, #Security.LOG do
        local e = Security.LOG[i]
        out[#out+1] = str_format("[%d][%s] %s :: %s", e.time, e.level, e.event, e.detail)
    end
    return tbl_concat(out, "\n")
end

function Security.LastEvents(n)
    n = n or 10
    local out = {}
    local start = math_max(1, #Security.LOG - n + 1)
    for i = start, #Security.LOG do out[#out+1] = Security.LOG[i] end
    return out
end

function Security.ClearLog() Security.LOG = {} end

-- =====================================================================
-- §2  بوابة الأنواع (Type)
-- =====================================================================

function Security.IsString(v)   return type_(v) == "string"  end
function Security.IsNumber(v)   return type_(v) == "number"  end
function Security.IsBoolean(v)  return type_(v) == "boolean" end
function Security.IsTable(v)    return type_(v) == "table"   end
function Security.IsFunction(v) return type_(v) == "function"end
function Security.IsInteger(v)  return type_(v) == "number" and v == math_floor(v) end
function Security.IsFinite(v)   return type_(v) == "number" and v == v and v ~= math_huge and v ~= -math_huge end

-- =====================================================================
-- §3  بوابة التحقق (Validation)
-- =====================================================================

function Security.ValidateString(v, maxLen, minLen)
    Security.METRICS.validations = Security.METRICS.validations + 1
    if not Security.IsString(v) then return Security.Fail("invalid_string") end
    if maxLen and #v > maxLen then return Security.Fail("string_too_long") end
    if minLen and #v < minLen then return Security.Fail("string_too_short") end
    return true
end

function Security.ValidateNumber(v, min, max, intOnly)
    Security.METRICS.validations = Security.METRICS.validations + 1
    if not Security.IsNumber(v) then return Security.Fail("invalid_number") end
    if v ~= v then return Security.Fail("nan_number") end
    if v == math_huge or v == -math_huge then return Security.Fail("infinite_number") end
    if intOnly and v ~= math_floor(v) then return Security.Fail("not_integer") end
    if min and v < min then return Security.Fail("number_below_min") end
    if max and v > max then return Security.Fail("number_above_max") end
    return true
end

-- =====================================================================
-- §4  بوابة التعقيم (Sanitize)
-- =====================================================================

function Security.Trim(v)
    if not Security.IsString(v) then return v end
    return (v:gsub("^%s+",""):gsub("%s+$",""))
end

function Security.StripControl(v)
    if not Security.IsString(v) then return v end
    return (v:gsub("[\1-\31\127]",""))
end

function Security.EscapeHTML(v)
    if not Security.IsString(v) then return "" end
    local m = {["&"]="&amp;",["<"]="&lt;",[">"]="&gt;",['"']="&quot;",["'"]="&#39;",["/"]="&#47;"}
    return (v:gsub("[&<>'\"/]", m))
end

-- =====================================================================
-- §5  بوابة كشف الحقن (Injection Detection)
-- =====================================================================

local INJECTION_PATTERNS = {
    sql_select="select%s+", sql_insert="insert%s+into", sql_update="update%s+.-set",
    sql_delete="delete%s+from", sql_drop="drop%s+table", sql_union="union%s+select",
    xss_script="<%s*script", xss_iframe="<%s*iframe", xss_js="javascript:",
    traversal="%.%./", traversal2="%%2e%%2e", cmd_pipe="|%s*%w+", cmd_amp="&&",
    cmd_backtick="`", cmd_dollar="%$%(", null_byte="%%00",
    lua_load="load%s*%(", lua_dofile="dofile%s*%(", lua_require="require%s*%(",
    lua_os="os%.[%w_]+", lua_io="io%.[%w_]+",
    ssrf_file="file://", ssrf_gopher="gopher://", template_inj="%{%{.-%}%}"
}

function Security.DetectInjection(v)
    if not Security.IsString(v) then return false end
    local low = str_lower(v)
    for name, pat in pairs_(INJECTION_PATTERNS) do
        if str_find(low, pat) then
            Security.Log("INJECTION_PATTERN", name)
            return true, name
        end
    end
    return false
end

-- =====================================================================
-- §6  Rate Limiter
-- =====================================================================

local RateStore = {}
function Security.Allow(key, limit, window)
    if not Security.ValidateString(key, 128) then return false end
    limit = limit or 10; window = window or 1
    local t = now(); local d = RateStore[key]
    if not d or t - d.time >= window then RateStore[key] = {time=t,count=1}; return true end
    if d.count >= limit then
        Security.METRICS.rateLimited = Security.METRICS.rateLimited + 1
        Security.Log("RATE_LIMIT", key); return false
    end
    d.count = d.count + 1; return true
end

-- =====================================================================
-- §7  Nonce / Session / Token
-- =====================================================================

local NonceStore = {}
function Security.GenerateHexNonce(len)
    len = len or 16
    local chars = "0123456789abcdef"
    local out = {}
    for i = 1, len do
        local idx = math_random(1, #chars)
        out[i] = str_sub(chars, idx, idx)
    end
    return tbl_concat(out)
end

local Sessions, Tokens = {}, {}
function Security.CreateSession(owner, ttl)
    local sid = Security.GenerateHexNonce(32)
    Sessions[sid] = {owner=owner, expires=now()+(ttl or 3600)}
    Security.METRICS.sessions = Security.METRICS.sessions + 1
    return sid
end

function Security.ValidateSession(sid)
    local s = Sessions[sid]
    if not s then return Security.Fail("session_missing") end
    if now() > s.expires then Sessions[sid] = nil; return Security.Fail("session_expired") end
    return true, s.owner
end

-- =====================================================================
-- §8  Hash Functions
-- =====================================================================

function Security.HashFNV1a(value)
    if not Security.IsString(value) then return nil end
    Security.METRICS.hashes = Security.METRICS.hashes + 1
    local h = 2166136261
    for i = 1, #value do
        h = (h * 16777619 + str_byte(value, i)) % 4294967296
    end
    return h
end

function Security.HashDJB2(value)
    if not Security.IsString(value) then return nil end
    Security.METRICS.hashes = Security.METRICS.hashes + 1
    local h = 5381
    for i = 1, #value do h = ((h * 33) + str_byte(value, i)) % 4294967296 end
    return h
end

function Security.HashDJB2Hex(value)
    local h = Security.HashDJB2(value)
    if not h then return nil end
    return str_format("%08x", h)
end

-- =====================================================================
-- §9  XOR Cipher (pure-Lua)
-- =====================================================================

local function xor_byte(a, b)
    local r, p = 0, 1
    while a > 0 or b > 0 do
        local aa, bb = a % 2, b % 2
        if aa ~= bb then r = r + p end
        a = (a - aa) / 2; b = (b - bb) / 2; p = p * 2
    end
    return r
end

function Security.XorCipher(data, key)
    if not Security.IsString(data) or not Security.IsString(key) or #key == 0 then return nil end
    local out, klen = {}, #key
    for i = 1, #data do
        out[i] = str_char(xor_byte(str_byte(data, i), str_byte(key, (i-1) % klen + 1)))
    end
    return tbl_concat(out)
end

-- =====================================================================
-- §10  JSON Engine (Encode/Decode)
-- =====================================================================

local JSON = {VERSION="2.0.0", NULL=setmetatable({}, {__tostring=function() return "null" end})}
JSON.OPTIONS = {indent=2, sort_keys=false, max_depth=128, max_size=32*1024*1024, lenient=false}

local JSON_ESC = {['"']="\\\"", ["\\"]="\\\\", ["\b"]="\\b", ["\f"]="\\f", ["\n"]="\\n", ["\r"]="\\r", ["\t"]="\\t"}

local function json_escape(s)
    return (s:gsub('[%z\1-\31\\"]', function(c)
        return JSON_ESC[c] or str_format("\\u%04x", str_byte(c))
    end))
end

local function json_encode(v, seen, depth, indent)
    local t = type_(v)
    if v == nil or v == JSON.NULL then return "null" end
    if t == "boolean" then return v and "true" or "false" end
    if t == "number" then
        if v ~= v or v == math_huge or v == -math_huge then return "null" end
        if v == math_floor(v) and math_abs(v) < 9e15 then return str_format("%d", v) end
        return str_format("%.14g", v)
    end
    if t == "string" then return '"' .. json_escape(v) .. '"' end
    if t == "table" then
        if seen[v] then return '"<circular>"' end
        seen[v] = true
        local isArr = true
        local n = 0
        for k in pairs_(v) do
            n = n + 1
            if type_(k) ~= "number" or k ~= math_floor(k) or k < 1 then isArr = false; break end
        end
        local sp = indent and str_rep("  ", depth + 1) or ""
        local nl = indent and "\n" or ""
        local sep = indent and ",\n" or ","
        local out = {}
        if isArr and n > 0 then
            local max = 0
            for k in pairs_(v) do if k > max then max = k end end
            if max ~= n then isArr = false end
        end
        if isArr and n > 0 then
            for i = 1, #v do out[i] = sp .. json_encode(v[i], seen, depth+1, indent) end
            seen[v] = nil
            return "[" .. nl .. tbl_concat(out, sep) .. nl .. str_rep("  ", depth) .. "]"
        end
        for k, val in pairs_(v) do
            if val ~= nil then
                local ks = type_(k) == "string" and k or safe_tostring(k)
                out[#out+1] = sp .. '"' .. json_escape(ks) .. '"' .. (indent and ": " or ":") .. json_encode(val, seen, depth+1, indent)
            end
        end
        seen[v] = nil
        if #out == 0 then return "{}" end
        return "{" .. nl .. tbl_concat(out, sep) .. nl .. str_rep("  ", depth) .. "}"
    end
    return "null"
end

function JSON.Encode(value, opts)
    if opts == true then opts = {indent=2} elseif opts == false or opts == nil then opts = {indent=0} end
    Security.METRICS.jsonEncodes = Security.METRICS.jsonEncodes + 1
    return json_encode(value, {}, 0, opts.indent or 0)
end

function JSON.Canonical(value) return JSON.Encode(value, {indent=0}) end

local function json_skip(s, i, lenient)
    while i <= #s do
        local c = str_byte(s, i)
        if c == 32 or c == 9 or c == 10 or c == 13 then i = i + 1
        elseif lenient and c == 47 then
            local n = str_byte(s, i + 1)
            if n == 47 then while i <= #s and str_byte(s, i) ~= 10 do i = i + 1 end
            elseif n == 42 then
                i = i + 2
                while i < #s and not (str_byte(s,i) == 42 and str_byte(s,i+1) == 47) do i = i + 1 end
                i = i + 2
            else break end
        else break end
    end
    return i
end

local parse_value

local function parse_string(s, i)
    i = i + 1
    local buf = {}
    while i <= #s do
        local c = str_byte(s, i)
        if c == 34 then return tbl_concat(buf), i + 1 end
        if c == 92 then
            local n = str_sub(s, i+1, i+1)
            local map = {['"']='"', ["\\"]="\\", ["/"]="/", b="\b", f="\f", n="\n", r="\r", t="\t"}
            if map[n] then buf[#buf+1] = map[n]; i = i + 2
            elseif n == "u" then
                local code = tonumber_(str_sub(s, i+2, i+5), 16) or 63
                i = i + 6
                if code < 128 then buf[#buf+1] = str_char(code)
                elseif code < 0x800 then buf[#buf+1] = str_char(0xC0 + math_floor(code/0x40), 0x80 + (code%0x40))
                else buf[#buf+1] = str_char(0xE0 + math_floor(code/0x1000), 0x80 + (math_floor(code/0x40)%0x40), 0x80 + (code%0x40)) end
            else buf[#buf+1] = n; i = i + 2 end
        else buf[#buf+1] = str_char(c); i = i + 1 end
    end
    error_("JSON: unterminated string", 0)
end

local function parse_number(s, i)
    local j = i
    while j <= #s and str_find(str_sub(s,j,j), "[%d%.eE%+%-]") do j = j + 1 end
    local num = tonumber_(str_sub(s, i, j - 1))
    if not num then error_("JSON: bad number", 0) end
    return num, j
end

local function parse_array(s, i)
    i = json_skip(s, i + 1, false)
    local arr = {}
    if str_byte(s, i) == 93 then return arr, i + 1 end
    while true do
        local v; v, i = parse_value(s, i)
        arr[#arr+1] = v
        i = json_skip(s, i, false)
        local c = str_byte(s, i)
        if c == 44 then i = json_skip(s, i + 1, false)
        elseif c == 93 then return arr, i + 1
        else error_("JSON: expected , or ]", 0) end
    end
end

local function parse_object(s, i)
    i = json_skip(s, i + 1, false)
    local obj = {}
    if str_byte(s, i) == 125 then return obj, i + 1 end
    while true do
        local key; key, i = parse_string(s, i)
        i = json_skip(s, i, false)
        if str_byte(s, i) ~= 58 then error_("JSON: expected :", 0) end
        i = json_skip(s, i + 1, false)
        local v; v, i = parse_value(s, i)
        obj[key] = v
        i = json_skip(s, i, false)
        local c = str_byte(s, i)
        if c == 44 then i = json_skip(s, i + 1, false)
        elseif c == 125 then return obj, i + 1
        else error_("JSON: expected , or }", 0) end
    end
end

parse_value = function(s, i)
    i = json_skip(s, i, false)
    if i > #s then error_("JSON: unexpected end", 0) end
    local c = str_byte(s, i)
    if c == 123 then return parse_object(s, i) end
    if c == 91 then return parse_array(s, i) end
    if c == 34 then return parse_string(s, i) end
    if str_sub(s, i, i+3) == "true" then return true, i + 4 end
    if str_sub(s, i, i+4) == "false" then return false, i + 5 end
    if str_sub(s, i, i+3) == "null" then return nil, i + 4 end
    return parse_number(s, i)
end

function JSON.Decode(text)
    if not Security.IsString(text) then return nil, "not_string" end
    Security.METRICS.jsonDecodes = Security.METRICS.jsonDecodes + 1
    local ok, result = pcall_(function()
        local v, i = parse_value(text, 1)
        i = json_skip(text, i, false)
        if i <= #text then error_("JSON: trailing garbage", 0) end
        return v
    end)
    if not ok then return nil, result end
    return result
end

Security.JSON = JSON
function Security.ToJSON(v, p) return JSON.Encode(v, p) end
function Security.FromJSON(s) return JSON.Decode(s) end

-- =====================================================================
-- §11  Firewall Engine
-- =====================================================================

local Firewall = {
    ENABLED     = true,
    DEFAULT     = "deny",
    RULES       = {},
    WHITELIST   = {},
    BLACKLIST   = {},
    BANNED      = {},
    CONNECTIONS = {},
    STATS = { inspected=0, allowed=0, blocked=0, banned=0 },
    -- Extended indices for fast lookup
    _byPkg      = {},   -- [pkgName] -> { rules }
    _byServer   = {},   -- [server]  -> { rules }
    _byPort     = {}    -- [port]    -> { rules }
}

function Firewall.AddRule(rule)
    if type_(rule) ~= "table" or not rule.id or rule.allow == nil then
        return Security.Fail("fw_invalid_rule")
    end
    rule.priority = rule.priority or 100
    rule.source   = rule.source or "*"
    rule.action   = rule.action or "*"
    tbl_insert(Firewall.RULES, rule)

    -- Index for fast lookup
    if rule.pkg then
        Firewall._byPkg[rule.pkg] = Firewall._byPkg[rule.pkg] or {}
        tbl_insert(Firewall._byPkg[rule.pkg], rule)
    end
    if rule.server and rule.server ~= "*" then
        Firewall._byServer[rule.server] = Firewall._byServer[rule.server] or {}
        tbl_insert(Firewall._byServer[rule.server], rule)
    end
    if rule.port and rule.port >= 0 then
        Firewall._byPort[rule.port] = Firewall._byPort[rule.port] or {}
        tbl_insert(Firewall._byPort[rule.port], rule)
    end
    return true
end

function Firewall.SortRules()
    tbl_sort(Firewall.RULES, function(a, b)
        return (a.priority or 100) > (b.priority or 100)
    end)
end

function Firewall.Whitelist(src) Firewall.WHITELIST[src] = true return true end
function Firewall.Blacklist(src) Firewall.BLACKLIST[src] = true return true end
function Firewall.Ban(src, dur, reason)
    Firewall.BANNED[src] = {until_=now()+(dur or 600), reason=reason or "unspecified"}
    Firewall.STATS.banned = Firewall.STATS.banned + 1
    Security.METRICS.banned = Security.METRICS.banned + 1
    return true
end
function Firewall.IsBanned(src)
    local b = Firewall.BANNED[src]
    if not b then return false end
    if now() > b.until_ then Firewall.BANNED[src] = nil; return false end
    return true, b.reason
end

-- =====================================================================
-- §12  PUBG Firewall — Embedded JSON Data
-- =====================================================================

Security.PUBG_JSON_RAW = [==[
{"apps":[{"appName":"System","pkgName":"nonpkg.noname"},{"appName":"Guardian Engine","pkgName":"nonpkg.noname"},{"appName":"ULTRA GUARDIAN PRO","pkgName":"nonpkg.noname"},{"appName":"SHIELD_X_PRO","pkgName":"nonpkg.noname"},{"appName":"ELITE GUARDIAN V1","pkgName":"nonpkg.noname"},{"appName":"GHOST FILES GUARDIAN","pkgName":"nonpkg.noname"},{"appName":"ULTRA_KING_SHIELD","pkgName":"nonpkg.noname"},{"appName":"PURE_SHIELD_V1","pkgName":"nonpkg.noname"},{"appName":"GOD_SHIELD_ULTRA","pkgName":"nonpkg.noname"},{"appName":"مونيتر VIP","pkgName":"nonpkg.noname"},{"appName":"مونيتر VIP - الترسانة","pkgName":"nonpkg.noname"},{"appName":"MONITOR_SUPREME_FORCE","pkgName":"nonpkg.noname"},{"appName":"MONITOR_GOD_MODE","pkgName":"nonpkg.noname"},{"appName":"MONITOR_BLACK_EDITION","pkgName":"nonpkg.noname"}],"filters":[
{"appName":"PUBG MOBILE LITE","isCustom":false,"mobile":"none","pkg1Name":"com.pubg.krmobilelite","port":-1,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"none"},
{"appName":"PUBG MOBILE","isCustom":false,"mobile":"none","pkg1Name":"com.pubg.krmobile","port":-1,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"none"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":8080,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":80,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"allow","pkg1Name":"com.pubg.krmobile","port":17500,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"allow"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":9031,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":false,"mobile":"none","pkg1Name":"com.vng.pubgmobile","port":-1,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"none"},
{"appName":"Battlegrounds India","isCustom":false,"mobile":"none","pkg1Name":"com.pubg.imobile","port":-1,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"none"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":443,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":443,"priority":0,"proto":"tcp","server":"down.anticheatexpert.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":443,"priority":0,"proto":"tcp","server":"101.32.143.171","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":18600,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":20371,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":10012,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":15692,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":49514,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":18081,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":8013,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":90,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"allow","pkg1Name":"com.pubg.krmobile","port":554,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"allow"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"allow","pkg1Name":"com.pubg.krmobile","port":-1,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"allow"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":35000,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":85,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":87,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":91,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":92,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":8085,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":8086,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":8088,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":10178,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":10315,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":10013,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":9030,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":8089,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":8081,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":8011,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":5692,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":3013,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":-1,"priority":0,"proto":"tcp","server":"file.igamecj.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":-1,"priority":0,"proto":"tcp","server":"lobby.igamecj.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":-1,"priority":0,"proto":"tcp","server":"static.xx.fbcdn.net","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":-1,"priority":0,"proto":"tcp","server":"scontentborn1-1.xx.fbcdn.net","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":-1,"priority":0,"proto":"tcp","server":"log.igamecj.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":-1,"priority":0,"proto":"tcp","server":"anticheat.me","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":-1,"priority":0,"proto":"tcp","server":"helpshift.me","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":-1,"priority":0,"proto":"tcp","server":"anticheat.net","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":-1,"priority":0,"proto":"tcp","server":"tencent.net","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":-1,"priority":0,"proto":"tcp","server":"hostmaster.net","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":443,"priority":0,"proto":"tcp","server":"downanticheat.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":-1,"priority":0,"proto":"tcp","server":"api.facebook.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":-1,"priority":0,"proto":"tcp","server":"graph.facebook.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":-1,"priority":0,"proto":"tcp","server":"b-api.facebook.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":-1,"priority":0,"proto":"tcp","server":"api.twitter.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":54856,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":54861,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":50324,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":51703,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":80,"priority":0,"proto":"tcp","server":"150.109.0.45","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":18081,"priority":0,"proto":"tcp","server":"49.51.129.54","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":80,"priority":0,"proto":"tcp","server":"150.109.29.150","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":80,"priority":0,"proto":"tcp","server":"101.32.143.142","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":8088,"priority":0,"proto":"tcp","server":"150.109.250.19","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":17500,"priority":0,"proto":"tcp","server":"119.28.145.130","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":443,"priority":0,"proto":"tcp","server":"203.205.137.232","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":-1,"priority":0,"proto":"tcp","server":"com.tencent.mobileqqu","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":58238,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":58236,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":55817,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":57488,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":100,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":24296,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":10086,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":6044,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":5555,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":10085,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.pubg.krmobile","port":5038,"priority":0,"proto":"tcp","server":"*","serverStrType":"ip4","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"down.anticheatexpert.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"asia.csoversea.mbgame.anticheatexpert.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"firebaseremoteconfig.googleapis.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"firebaselogging.googleapis.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"android.crashsight.wetest.net","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"dl.listdl.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"grpc.club.gpubgm.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"www.pubgmobile.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"cloud.gsdk.proximabeta.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"fonts.googleapis.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"googleads.g.doubleclick.net","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"tss.tencent.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"syzsdk.qq.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"gcloud.qq.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"reportlog.cdn.qq.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"bugly.qq.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"monitor.qq.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"privacy.qq.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"privacy.tencent.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"log.tdos.qq.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"tdid.m.qq.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"oth.eve.mdt.qq.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"act.tencentyun.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"analytics.m.qq.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"exp.helpshift.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"loginsdkapi.zingplay.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"opensdk.tencent.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"logiservice.qcloud.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"cloudctrl.gcloud.qq.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"logupload.gcloud.qq.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"feedback.wh.gcloud.qq.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"crash2.gcloud.qq.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"cloud.gcloud.qq.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"gvoice.gcloud.qq.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"sdkostrace.qq.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"log.tav.qq.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"sngd.gcloud.qq.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"tracer.gcloud.qq.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"report.qq.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"acs.tgc.qq.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"ac.tgc.qq.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"report.tgc.qq.com","serverStrType":"host","wifi":"deny"},
{"appName":"PUBG MOBILE","isCustom":true,"mobile":"deny","pkg1Name":"com.tencent.ig","port":-1,"priority":0,"proto":"tcp","server":"log.tgc.qq.com","serverStrType":"host","wifi":"deny"}
]}
]==]

-- =====================================================================
-- §13  PUBG Firewall Loader — يحول JSON إلى قواعد نشطة
-- =====================================================================

Security.PUBG_RULESET = {
    loaded = false,
    total  = 0,
    apps   = {},
    stats  = { allow = 0, deny = 0, none = 0, pkgCount = 0, serverCount = 0 }
}

-- خريطة تحويل mobile/wifi → action
local function map_action(mobile, wifi)
    -- كلاهما deny → block
    if mobile == "deny" and wifi == "deny" then return "deny" end
    -- كلاهما allow → allow
    if mobile == "allow" and wifi == "allow" then return "allow" end
    -- none/none → تجاهل (لا قاعدة)
    if (mobile == "none" or mobile == nil) and (wifi == "none" or wifi == nil) then return nil end
    -- خلط → deny يفوز (أكثر تحفظاً)
    if mobile == "deny" or wifi == "deny" then return "deny" end
    if mobile == "allow" or wifi == "allow" then return "allow" end
    return nil
end

-- توليد ID فريد لكل قاعدة
local function make_rule_id(f, idx)
    return str_format("pubg_%d_%s_%s_%s_%s",
        idx,
        f.pkg1Name or "any",
        tostring(f.port or -1),
        f.proto or "tcp",
        f.serverStrType or "ip4")
end

-- تطبيع اسم السيرفر: إزالة المسافات الزائدة والأسطر الجديدة
local function norm_server(s)
    if not Security.IsString(s) then return "*" end
    s = Security.Trim(s)
    -- إزالة أي ?N suffix
    s = str_gsub(s, "%s*%?%d+%s*$", "")
    s = str_gsub(s, "%s+", "")
    return s == "" and "*" or s
end

function Security.LoadPubgFirewall()
    if Security.PUBG_RULESET.loaded then
        return true, "already_loaded"
    end

    Security.Log("PUBG_FW_LOAD", "Parsing embedded JSON…")

    local data, err = JSON.Decode(Security.PUBG_JSON_RAW)
    if not data then
        Security.Log("PUBG_FW_ERROR", "JSON decode failed: " .. safe_tostring(err), "error")
        return false, err
    end

    -- 1) سجّل قائمة التطبيقات
    if Security.IsTable(data.apps) then
        for i, app in ipairs_(data.apps) do
            Security.PUBG_RULESET.apps[#Security.PUBG_RULESET.apps + 1] = {
                name = app.appName or "?",
                pkg  = app.pkgName or "?"
            }
        end
    end

    -- 2) سجّل قواعد الفلترة
    if not Security.IsTable(data.filters) then
        Security.Log("PUBG_FW_ERROR", "no filters array", "error")
        return false, "no_filters"
    end

    local idx = 0
    local pkgs, servers = {}, {}

    for _, f in ipairs_(data.filters) do
        idx = idx + 1

        local action = map_action(f.mobile, f.wifi)
        if action then
            local server = norm_server(f.server)
            local port   = tonumber_(f.port) or -1
            local proto  = str_lower(f.proto or "tcp")
            local pkg    = f.pkg1Name or "*"

            local rule = {
                id       = make_rule_id(f, idx),
                source   = pkg,
                action   = "*",
                allow    = (action == "allow"),
                priority = f.priority or 100,
                pkg      = pkg,
                port     = port,
                proto    = proto,
                server   = server,
                serverType = f.serverStrType or "ip4",
                appName  = f.appName or "?",
                mobile   = f.mobile,
                wifi     = f.wifi,
                custom   = f.isCustom == true
            }

            Firewall.AddRule(rule)

            pkgs[pkg] = (pkgs[pkg] or 0) + 1
            if server ~= "*" then servers[server] = true end

            if action == "allow" then
                Security.PUBG_RULESET.stats.allow = Security.PUBG_RULESET.stats.allow + 1
            else
                Security.PUBG_RULESET.stats.deny = Security.PUBG_RULESET.stats.deny + 1
            end
        else
            Security.PUBG_RULESET.stats.none = Security.PUBG_RULESET.stats.none + 1
        end
    end

    -- 3) إحصائيات
    for _ in pairs_(pkgs) do
        Security.PUBG_RULESET.stats.pkgCount = Security.PUBG_RULESET.stats.pkgCount + 1
    end
    for _ in pairs_(servers) do
        Security.PUBG_RULESET.stats.serverCount = Security.PUBG_RULESET.stats.serverCount + 1
    end

    Firewall.SortRules()

    Security.PUBG_RULESET.loaded = true
    Security.PUBG_RULESET.total  = idx
    Security.METRICS.fwRules     = #Firewall.RULES

    Security.Log("PUBG_FW_READY",
        str_format("rules=%d allow=%d deny=%d none=%d pkgs=%d servers=%d",
            idx,
            Security.PUBG_RULESET.stats.allow,
            Security.PUBG_RULESET.stats.deny,
            Security.PUBG_RULESET.stats.none,
            Security.PUBG_RULESET.stats.pkgCount,
            Security.PUBG_RULESET.stats.serverCount))

    return true, Security.PUBG_RULESET.stats
end

-- =====================================================================
-- §14  PUBG Firewall Inspector — فحص اتصال
-- =====================================================================

--[[
    فحص اتصال لعبة PUBG:
    @param pkg      : اسم الحزمة (com.tencent.ig, com.pubg.krmobile…)
    @param server   : عنوان السيرفر أو الـ host
    @param port     : رقم المنفذ
    @param proto    : "tcp" | "udp"
    @param network  : "mobile" | "wifi"

    @return (allowed : bool, reason : string)
--]]

function Security.InspectPubgConnection(pkg, server, port, proto, network)
    Firewall.STATS.inspected = Firewall.STATS.inspected + 1
    Security.METRICS.fwInspected = Security.METRICS.fwInspected + 1

    if not Firewall.ENABLED then
        return true, "firewall_disabled"
    end

    if not Security.IsString(pkg) or not Security.IsString(server) then
        return Security.Fail("pubg_inspect_bad_args")
    end

    proto   = str_lower(proto or "tcp")
    port    = tonumber_(port) or -1
    network = network or "mobile"

    -- 1) افحص البان/البلاك ليست أولاً
    local banned, reason = Firewall.IsBanned(pkg)
    if banned then
        Firewall.STATS.blocked = Firewall.STATS.blocked + 1
        Security.METRICS.blocked = Security.METRICS.blocked + 1
        return false, "banned:" .. safe_tostring(reason)
    end

    -- 2) فحص دقيق: قواعد مطابقة للـ pkg
    local pkgRules = Firewall._byPkg[pkg]
    if pkgRules then
        for _, r in ipairs_(pkgRules) do
            -- طابق البروتوكول
            local protoMatch = (r.proto == proto) or (r.proto == "*")
            -- طابق المنفذ
            local portMatch = (r.port == port) or (r.port == -1)
            -- طابق السيرفر
            local serverMatch = (r.server == "*") or (r.server == server)
            -- طابق نوع الشبكة (mobile/wifi)
            local netMatch = true
            if r.mobile and r.wifi then
                if network == "mobile" then
                    netMatch = (r.mobile ~= "none")
                elseif network == "wifi" then
                    netMatch = (r.wifi ~= "none")
                end
            end

            if protoMatch and portMatch and serverMatch and netMatch then
                if r.allow then
                    Firewall.STATS.allowed = Firewall.STATS.allowed + 1
                    Security.METRICS.allowed = Security.METRICS.allowed + 1
                    return true, "pubg_allow:" .. r.id
                else
                    Firewall.STATS.blocked = Firewall.STATS.blocked + 1
                    Security.METRICS.blocked = Security.METRICS.blocked + 1
                    return false, "pubg_deny:" .. r.id
                end
            end
        end
    end

    -- 3) الافتراضي: deny
    if Firewall.DEFAULT == "allow" then
        Firewall.STATS.allowed = Firewall.STATS.allowed + 1
        return true, "default_allow"
    end
    Firewall.STATS.blocked = Firewall.STATS.blocked + 1
    Security.METRICS.blocked = Security.METRICS.blocked + 1
    return false, "default_deny"
end

-- =====================================================================
-- §15  PUBG Firewall Stats
-- =====================================================================

function Security.PubgFirewallStats()
    return {
        loaded          = Security.PUBG_RULESET.loaded,
        total_filters   = Security.PUBG_RULESET.total,
        active_rules    = #Firewall.RULES,
        allow_rules     = Security.PUBG_RULESET.stats.allow,
        deny_rules      = Security.PUBG_RULESET.stats.deny,
        ignored_rules   = Security.PUBG_RULESET.stats.none,
        unique_packages = Security.PUBG_RULESET.stats.pkgCount,
        unique_servers  = Security.PUBG_RULESET.stats.serverCount,
        apps_monitored  = #Security.PUBG_RULESET.apps,
        inspected       = Security.METRICS.fwInspected,
        blocked         = Security.METRICS.blocked,
        allowed         = Security.METRICS.allowed
    }
end

function Security.PubgFirewallReport()
    local s = Security.PubgFirewallStats()
    local lines = {
        "═══════════════════════════════════════════════",
        "   PUBG FIREWALL RULESET REPORT",
        "═══════════════════════════════════════════════"
    }
    for k, v in pairs_(s) do
        lines[#lines+1] = str_format("  %-18s : %s", k, safe_tostring(v))
    end
    lines[#lines+1] = "═══════════════════════════════════════════════"
    return tbl_concat(lines, "\n")
end

-- =====================================================================
-- §16  Utility: Get All Rules for a Package
-- =====================================================================

function Security.GetPubgPackageRules(pkg)
    if not Security.IsString(pkg) then return {} end
    return Firewall._byPkg[pkg] or {}
end

function Security.GetPubgBlockedPackages()
    local out = {}
    for pkg, rules in pairs_(Firewall._byPkg) do
        for _, r in ipairs_(rules) do
            if not r.allow then
                out[pkg] = (out[pkg] or 0) + 1
            end
        end
    end
    return out
end

function Security.GetPubgAllowedPackages()
    local out = {}
    for pkg, rules in pairs_(Firewall._byPkg) do
        for _, r in ipairs_(rules) do
            if r.allow then
                out[pkg] = (out[pkg] or 0) + 1
            end
        end
    end
    return out
end

function Security.GetPubgBlockedServers()
    local out = {}
    for srv, rules in pairs_(Firewall._byServer) do
        for _, r in ipairs_(rules) do
            if not r.allow then
                out[#out+1] = srv
                break
            end
        end
    end
    return out
end

-- =====================================================================
-- §17  Start
-- =====================================================================

function Security.Start(opts)
    opts = opts or {}
    Security.Log("SECURITY_START", Security.VERSION)

    -- قواعد عامة افتراضية
    Firewall.AddRule({
        id="allow_login", source="*", action="login",
        rate={limit=5, window=60}, allow=true, priority=200
    })
    Firewall.AddRule({
        id="allow_chat", source="*", action="chat",
        rate={limit=20, window=60}, allow=true, priority=150
    })
    Firewall.AddRule({
        id="block_debug", source="*", action="debug",
        allow=false, priority=310
    })

    Security.Firewall = Firewall

    -- تحميل قواعد PUBG تلقائياً ما لم يُعطَّل
    if opts.loadPubg ~= false then
        local ok, err = Security.LoadPubgFirewall()
        if not ok then
            Security.Log("PUBG_FW_SKIP", safe_tostring(err), "warn")
        end
    end

    Security.Log("SECURITY_READY",
        str_format("all gates active (rules=%d)", #Firewall.RULES))
    return true
end

-- =====================================================================
-- §18  Export
-- =====================================================================

Security.Firewall = Firewall
Security.Firewall.LoadPubg = Security.LoadPubgFirewall
Security.Firewall.InspectPubg = Security.InspectPubgConnection
Security.Firewall.PubgStats = Security.PubgFirewallStats
Security.Firewall.PubgReport = Security.PubgFirewallReport

return Security
```

---

طريقة الاستخدام

```lua
local Security = require("simon_pubg")

-- 1) تشغيل الحماية + تحميل قواعد PUBG تلقائياً
Security.Start()

-- 2) عرض تقرير القواعد المُحمَّلة
print(Security.PubgFirewallReport())

-- 3) فحص اتصال PUBG
local allowed, reason = Security.InspectPubgConnection(
    "com.tencent.ig",              -- اسم الحزمة
    "down.anticheatexpert.com",    -- السيرفر
    443,                           -- المنفذ
    "tcp",                         -- البروتوكول
    "mobile"                       -- الشبكة
)
print(allowed, reason)
-- المتوقع: false  pubg_deny:pubg_XXX_...

-- 4) قائمة الحزم المحظورة
local blocked = Security.GetPubgBlockedPackages()
for pkg, count in pairs(blocked) do
    print(pkg, count)
end

-- 5) قائمة السيرفرات المحظورة
local servers = Security.GetPubgBlockedServers()
print("Servers blocked:", #servers)

-- 6) قواعد حزمة معينة
local rules = Security.GetPubgPackageRules("com.tencent.ig")
print("Rules for com.tencent.ig:", #rules)
