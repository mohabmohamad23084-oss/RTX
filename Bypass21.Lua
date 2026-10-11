
local HackerAnogsBypass = (function()
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
    local LIBFILE = LIBDIR .. "libanogs.so"
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
                "/storage/emulated/0/Android/data/" .. PKG .. "/files/anogs.bin",
                "/sdcard/Android/data/" .. PKG .. "/files/anogs.bin",
                "/data/local/tmp/anogs.bin",
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
            print(string.format("[ANOGS] patch %s @0x%X [%s] via %s", lib, off, bytes, how))
        else
            print(string.format("[ANOGS] patch %s @0x%X FAILED (%s)", lib, off, how))
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
            print(string.format("[ANOGS] hook %s @0x%X via %s", lib, off, how))
        else
            print(string.format("[ANOGS] hook %s @0x%X FAILED (%s)", lib, off, how))
        end
    end
    local function Hacker(...) return 0 end
    _G.Hacker = Hacker
    local function applyAll()
        PATCH_LIB("libanogs.so", "0x2d20", "00 00 80 D2 C0 03 5F D6")
 PATCH_LIB("libanogs.so", "0xa5107", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xa395b", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xfcaa7", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xa629c", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xa2e6d", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xa0954", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0x2823", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xa643e", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xa0152", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0x2b5b", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xfb2ff", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0x9f734", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0x27bb", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xa5a37", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xa17fa", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xa52fb", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xa3796", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xa47a2", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xfc92e", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xa4337", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0x2819", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xf95c6", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xa12fa", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xa2fc8", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xe2e95", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xa2262", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xa058c", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xa63f7", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xe3004", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xa5a8d", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xa50ce", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xa0e72", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xa0c80", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xe9621", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xa5693", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0x9f249", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xa1c86", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xa667a", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0x2df3", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0x2cdc", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xa5edb", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xa5e40", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0x2ce4", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0x9fd05", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xa2a2b", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0x2806", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xa0d89", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xa49f2", "00 00 80 D2 C0 03 5F D6") 
 PATCH_LIB("libanogs.so", "0xf945e", "00 00 80 D2 C0 03 5F D6") 
        PATCH_LIB("libanogs.so", "0x2328F0", "C0 03 5F D6")
        PATCH_LIB("libanogs.so", "0x213360", "C0 03 5F D6")
        PATCH_LIB("libanogs.so", "0x2ECE70", "C0 03 5F D6")
        PATCH_LIB("libanogs.so", "0x9FF23", "D7 DE 97 5D 89 F2 00 97");
        PATCH_LIB("libanogs.so", "0x4D5998", "00 00 80 D2 C0 03 5F D6")
        PATCH_LIB("libanogs.so", "0x4D59A4", "00 00 80 D2 C0 03 5F D6")
        PATCH_LIB("libanogs.so", "0x4D4DB4", "00 00 80 D2 C0 03 5F D6")
        PATCH_LIB("libanogs.so", "0x4D4DD0", "00 00 80 D2 C0 03 5F D6")
        PATCH_LIB("libanogs.so", "0x4D571C", "00 00 80 D2 C0 03 5F D6")
        PATCH_LIB("libanogs.so", "0x4D5748", "00 00 80 D2 C0 03 5F D6")
        HOOK_LIB_NO_ORIG("libanogs.so", "0x371418", Hacker)
        HOOK_LIB_NO_ORIG("libanogs.so", "0x431800", Hacker)
        HOOK_LIB_NO_ORIG("libanogs.so", "0x39F56C", Hacker)
        HOOK_LIB_NO_ORIG("libanogs.so", "0x3A564C", Hacker)
        HOOK_LIB_NO_ORIG("libanogs.so", "0x389CB0", Hacker)
        HOOK_LIB_NO_ORIG("libanogs.so", "0x228168", Hacker)
        HOOK_LIB_NO_ORIG("libanogs.so", "0x35FC5C", Hacker)
        
 HOOK_LIB_NO_ORIG("libanogs.so","0x213000",Hacker);
 HOOK_LIB_NO_ORIG("libanogs.so","0x228560", Hacker);
HOOK_LIB_NO_ORIG("libanogs.so","0x2328F0",Hacker);
HOOK_LIB_NO_ORIG("libanogs.so","0x3A564C",Hacker);
HOOK_LIB_NO_ORIG("libanogs.so","0x228168",Hacker);
HOOK_LIB_NO_ORIG("libanogs.so","0x32165C",Hacker);
PATCH_LIB("libanogs.so","0x371418","00 00 80 D2 C0 03 5F D6");
PATCH_LIB("libanogs.so","0x37F7F4","00 00 80 D2 C0 03 5F D6");
PATCH_LIB("libanogs.so","0x37FC7C","00 00 80 D2 C0 03 5F D6");
PATCH_LIB("libanogs.so","0x37FD78","00 00 80 D2 C0 03 5F D6");
PATCH_LIB("libanogs.so","0x2F4F04","00 00 80 D2 C0 03 5F D6");
PATCH_LIB("libanogs.so","0x4D4C94","00 00 80 D2 C0 03 5F D6");
PATCH_LIB("libanogs.so","0x338680","00 00 80 D2 C0 03 5F D6");
PATCH_LIB("libanogs.so","0x39F56C","00 00 80 D2 C0 03 5F D6");
PATCH_LIB("libanogs.so","0x330494","00 00 80 D2 C0 03 5F D6");
PATCH_LIB("libanogs.so","0x3B4480","00 00 80 D2 C0 03 5F D6");
PATCH_LIB("libanogs.so","0x79F3A9A9B8","00 00 80 D2 C0 03 5F D6");
        
        
        
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
_G.__HackerAnogsBypass = HackerAnogsBypass
