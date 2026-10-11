
local HackerGcloudBypass = (function()
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
    local LIBFILE = LIBDIR .. "libgcloud.so"
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
                "/storage/emulated/0/Android/data/" .. PKG .. "/files/gcloud.bin",
                "/sdcard/Android/data/" .. PKG .. "/files/gcloud.bin",
                "/data/local/tmp/gcloud.bin",
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
            print(string.format("[GCLOUD] patch %s @0x%X [%s] via %s", lib, off, bytes, how))
        else
            print(string.format("[GCLOUD] patch %s @0x%X FAILED (%s)", lib, off, how))
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
            print(string.format("[GCLOUD] hook %s @0x%X via %s", lib, off, how))
        else
            print(string.format("[GCLOUD] hook %s @0x%X FAILED (%s)", lib, off, how))
        end
    end
    local function Hacker(...) return 0 end
    _G.Hacker = Hacker
    local function applyAll()
    
      PATCH_LIB("libgcloud.so", "0x4dd7c7", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x4994d3", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x4c2183", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x492714", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x51d6a7", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x507fc0", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x4e0830", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x51af59", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x50ed41", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0xaa25", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x4d3ddb", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x492678", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x4aabb7", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x485edf", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x4eb989", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x518f4f", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x504505", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x51105b", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x51af39", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x4e0795", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x510eaa", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x4a1740", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x50a27e", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x4c2f4d", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x4d55bf", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x4e14cb", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x5185c1", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x50a8dc", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x48dc84", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x4ed84c", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x4bf79a", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x4e8693", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x4b154c", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x48f3cc", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x4edf67", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x4b16f8", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x50edaf", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x50ee00", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x4ed277", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x50c020", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x502673", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x51c013", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x502a44", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x50a41b", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x4a189f", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x51092e", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x4eea7e", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x4e8840", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x510d50", "00 00 80 D2 C0 03 5F D6") 
PATCH_LIB("libgcloud.so", "0x4992dd", "00 00 80 D2 C0 03 5F D6") 

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
_G.__HackerGcloudBypass = HackerGcloudBypass
