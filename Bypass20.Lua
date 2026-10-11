
local HackerAnortBypass = (function()
    local SH = _G.ScriptHelperClient
    if not SH then
        return { ready = false, reason = 'ScriptHelperClient unavailable' }
    end
    local KNOWN_PKGS = {
        ["com.tencent.ig"]    = "/data/app/~~2U5OPyLPSNrCp3Jhv6O4Xg==/com.tencent.ig-rxZaOzwfUVAPdioMsk4emQ==/lib/arm64/",
        ["com.pubg.krmobile"] = "/data/app/~~uBLiktAOPJCRfbQA01C-3Q==/com.pubg.krmobile-nhvnm6_ClIAV0J93P86daw==/lib/arm64/",
        ["com.pubg.imobile"]  = "/data/app/~~p9qsLKUJYSx0V20AUx9EWg==/com.pubg.imobile-oEDhX_GaHiB7HYo8hWh0Hg==/lib/arm64/",
    }
    local function detectPackage()
        if SH.GetNativePackageTag then
            local ok, p = pcall(SH.GetNativePackageTag)
            if ok and type(p) == "string" and KNOWN_PKGS[p] then return p end
        end
        for p in pairs(KNOWN_PKGS) do return p end
        return "com.tencent.ig"
    end
    local PKG     = detectPackage()
    local LIBDIR  = KNOWN_PKGS[PKG] or ""
    local LIBFILE = LIBDIR .. "libanort.so"
    local APPLIED_PATCH = {}
    local APPLIED_HOOK  = {}
    local BASE_CACHE    = {}
    local function kdup(lib, off) return string.format("%s@0x%X", lib, off) end
    local function getBase(lib)
        if BASE_CACHE[lib] then return BASE_CACHE[lib] end
        local b = 0
        local ok, r = pcall(SH.GetPUBGModuleBaseAddr, lib)
        if ok and type(r) == "number" then b = r
        elseif ok and type(r) == "table" then b = r.base or r.addr or r[1] or 0 end
        if b == 0 then
            local alt = lib:gsub("%.so$", "")
            local ok2, r2 = pcall(SH.GetPUBGModuleBaseAddr, alt)
            if ok2 and type(r2) == "number" then b = r2 end
        end
        BASE_CACHE[lib] = b
        return b
    end
    local function hex2bin(h)
        return (h:gsub("%x%x", function(b) return string.char(tonumber(b, 16)) end))
    end
    local function applyPatch(lib, off, hexbytes)
        local base = getBase(lib)
        local addr = base > 0 and (base + off) or nil
        if SH.ProcessSoPatch and addr then
            local ok = pcall(SH.ProcessSoPatch, addr, hexbytes)
            if ok then return true, "P1" end
        end
        if SH.ProcessSoPatch and addr then
            local ok = pcall(SH.ProcessSoPatch, addr, hex2bin(hexbytes))
            if ok then return true, "P2" end
        end
        if SH.ProcessSoPatch then
            local ok = pcall(SH.ProcessSoPatch, {
                { module = lib, offset = off, addr = addr,
                  bytes = hexbytes, data = hex2bin(hexbytes) }
            })
            if ok then return true, "P3" end
        end
        if SH.WriteFileAtPath and SH.SetUpdatedSoPatchFile and SH.ProcessSoPatch then
            local data = string.format("%s|0x%X|%s", lib, off, hexbytes)
            local paths = {
                "/storage/emulated/0/Android/data/" .. PKG .. "/files/anort.bin",
                "/sdcard/Android/data/" .. PKG .. "/files/anort.bin",
                "/data/local/tmp/anort.bin",
            }
            for _, path in ipairs(paths) do
                local okW = pcall(SH.WriteFileAtPath, path, data)
                if okW then
                    pcall(SH.SetUpdatedSoPatchFile, path)
                    local okP = pcall(SH.ProcessSoPatch)
                    if okP then return true, "P4" end
                end
            end
        end
        return false, "no-path"
    end
    local function installHook(lib, off, handler)
        local base = getBase(lib)
        if _G.__FRAMEWORK_HOOK_LIB_NO_ORIG then
            local ok = pcall(_G.__FRAMEWORK_HOOK_LIB_NO_ORIG, lib, off, handler)
            if ok then return true, "H1" end
        end
        if SH.InstallHook then
            local ok = pcall(SH.InstallHook, lib, off, handler)
            if ok then return true, "H2a" end
        end
        if SH.HookFunction then
            local ok = pcall(SH.HookFunction, lib, off, handler)
            if ok then return true, "H2b" end
        end
        if SH.AddHook then
            local ok = pcall(SH.AddHook, lib, off, handler)
            if ok then return true, "H2c" end
        end
        if SH.AllocVirMem and SH.ProcessSoPatch and base > 0 then
            local slot = pcall(SH.AllocVirMem, 16)
            if slot and type(slot) == "number" and slot > 0 then
                return false, "H3-no-native-bridge"
            end
        end
        return false, "no-hook-api"
    end
    local function PATCH_LIB(lib, offStr, bytes)
        local off = tonumber(offStr)
        if not off then return end
        local k = kdup(lib, off)
        if APPLIED_PATCH[k] then return end
        local ok, how = applyPatch(lib, off, bytes)
        if ok then
            APPLIED_PATCH[k] = true
            print(string.format("[ANORT] patch %s @0x%X [%s] via %s", lib, off, bytes, how))
        else
            print(string.format("[ANORT] patch %s @0x%X FAILED (%s)", lib, off, how))
        end
    end
    local function HOOK_LIB_NO_ORIG(lib, offStr, handler)
        local off = tonumber(offStr)
        if not off then return end
        local k = kdup(lib, off)
        if APPLIED_HOOK[k] then return end
        local ok, how = installHook(lib, off, handler)
        if ok then
            APPLIED_HOOK[k] = true
            print(string.format("[ANORT] hook %s @0x%X via %s", lib, off, how))
        else
            print(string.format("[ANORT] hook %s @0x%X FAILED (%s)", lib, off, how))
        end
    end
    local function Hacker(...) return 0 end
    _G.Hacker = Hacker
    local function applyAll()
     PATCH_LIB("libanort.so", "0x1a0f6c", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libanort.so", "0x1874fb", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libanort.so", "0x18774e", "00 00 80 D2 C0 03 5F D6")
 PATCH_LIB("libanort.so", "0x2728", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanort.so", "0x1c6aec", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanort.so", "0x1ca5e2", "00 00 80 D2 C0 03 5F D6")
  PATCH_LIB("libanort.so", "0x18f046", "00 00 80 D2 C0 03 5F D6")
   PATCH_LIB("libanort.so", "0x1c91fc", "00 00 80 D2 C0 03 5F D6")
    PATCH_LIB("libanort.so", "0x1c463c", "00 00 80 D2 C0 03 5F D6") 
   
  PATCH_LIB("libanort.so", "0xbfd0c", "00 00 80 D2 C0 03 5F D6") 
  PATCH_LIB("libanort.so", "0x8384", "00 00 80 D2 C0 03 5F D6")
   PATCH_LIB("libanort.so", "0xe6b98", "00 00 80 D2 C0 03 5F D6")
    PATCH_LIB("libanort.so", "0x11e39c", "00 00 80 D2 C0 03 5F D6") 
    PATCH_LIB("libanort.so", "0xf158", "00 00 80 D2 C0 03 5F D6")
     PATCH_LIB("libanort.so", "0x1b8267", "00 00 80 D2 C0 03 5F D6") 
     PATCH_LIB("libanort.so", "0x38b28", "00 00 80 D2 C0 03 5F D6")
      PATCH_LIB("libanort.so", "0x1127b8", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0x479b8", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0x19411c", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0xe6ed8", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0x1c27c9", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0x1a0380", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0x187565", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0x26e0", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0x1592a4", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0x1c265a", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0x187d72", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0x103cb0", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0x16395c", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0x2655", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0x67b08", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0x1879a7", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0x18f042", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0x1c81c8", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0xc11b8", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0x1f44", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0x20bf", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0x18f12e", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0x1417c0", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0x760d8", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0xf27d0", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0x18b954", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0xcb274", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0x2605", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0xc919c", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0x9261c", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0x187602", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0x1b83d6", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0x1a39e4", "00 00 80 D2 C0 03 5F D6") 
      PATCH_LIB("libanort.so", "0x82e14", "00 00 80 D2 C0 03 5F D6") 
      
    end
    applyAll()
    return {
        ready            = true,
        pkg              = PKG,
        libfile          = LIBFILE,
        applied_patch    = APPLIED_PATCH,
        applied_hook     = APPLIED_HOOK,
        PATCH_LIB        = PATCH_LIB,
        HOOK_LIB_NO_ORIG = HOOK_LIB_NO_ORIG,
    }
end)()
_G.__HackerAnortBypass = HackerAnortBypass
