
local HackerTDataMasterBypass = (function()
    local SH = _G.ScriptHelperClient
    if not SH then
        return { ready = false, reason = 'ScriptHelperClient unavailable' }
    end
    local KNOWN_PKGS = {
        ["com.tencent.ig"]    = "/data/app/~~2U5OPyLPSNrCp3Jhv6O4Xg==/com.tencent.ig-rxZaOzwfUVAPdioMsk4emQ==//arm64/",
        ["com.pubg.krmobile"] = "/data/app/~~uBLiktAOPJCRfbQA01C-3Q==/com.pubg.krmobile-nhvnm6_ClIAV0J93P86daw==//arm64/",
        ["com.pubg.imobile"]  = "/data/app/~~p9qsLKUJYSx0V20AUx9EWg==/com.pubg.imobile-oEDhX_GaHiB7HYo8hWh0Hg==//arm64/",
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
    local DIR  = KNOWN_PKGS[PKG] or ""
    local FILE = DIR .. "TDataMaster.so"
    local APPLIED_PATCH = {}
    local APPLIED_HOOK  = {}
    local BASE_CACHE    = {}
    local function kdup(, off) return string.format("%s@0x%X", , off) end
    local function getBase()
        if BASE_CACHE[] then return BASE_CACHE[] end
        local b = 0
        local ok, r = pcall(SH.GetPUBGModuleBaseAddr, )
        if ok and type(r) == "number" then b = r
        elseif ok and type(r) == "table" then b = r.base or r.addr or r[1] or 0 end
        if b == 0 then
            local alt = :gsub("%.so$", "")
            local ok2, r2 = pcall(SH.GetPUBGModuleBaseAddr, alt)
            if ok2 and type(r2) == "number" then b = r2 end
        end
        BASE_CACHE[] = b
        return b
    end
    local function hex2bin(h)
        return (h:gsub("%x%x", function(b) return string.char(tonumber(b, 16)) end))
    end
    local function applyPatch(, off, hexbytes)
        local base = getBase()
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
                { module = , offset = off, addr = addr,
                  bytes = hexbytes, data = hex2bin(hexbytes) }
            })
            if ok then return true, "P3" end
        end
        if SH.WriteFileAtPath and SH.SetUpdatedSoPatchFile and SH.ProcessSoPatch then
            local data = string.format("%s|0x%X|%s", , off, hexbytes)
            local paths = {
                "/storage/emulated/0/Android/data/" .. PKG .. "/files/TDataMaster.bin",
                "/sdcard/Android/data/" .. PKG .. "/files/TDataMaster.bin",
                "/data/local/tmp/TDataMaster.bin",
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
    local function installHook(, off, handler)
        local base = getBase()
        if _G.__FRAMEWORK_HOOK__NO_ORIG then
            local ok = pcall(_G.__FRAMEWORK_HOOK__NO_ORIG, , off, handler)
            if ok then return true, "H1" end
        end
        if SH.InstallHook then
            local ok = pcall(SH.InstallHook, , off, handler)
            if ok then return true, "H2a" end
        end
        if SH.HookFunction then
            local ok = pcall(SH.HookFunction, , off, handler)
            if ok then return true, "H2b" end
        end
        if SH.AddHook then
            local ok = pcall(SH.AddHook, , off, handler)
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
    local function PATCH_(, offStr, bytes)
        local off = tonumber(offStr)
        if not off then return end
        local k = kdup(, off)
        if APPLIED_PATCH[k] then return end
        local ok, how = applyPatch(, off, bytes)
        if ok then
            APPLIED_PATCH[k] = true
            print(string.format("[TDataMaster] patch %s @0x%X [%s] via %s", , off, bytes, how))
        else
            print(string.format("[TDataMaster] patch %s @0x%X FAILED (%s)", , off, how))
        end
    end
    local function HOOK__NO_ORIG(, offStr, handler)
        local off = tonumber(offStr)
        if not off then return end
        local k = kdup(, off)
        if APPLIED_HOOK[k] then return end
        local ok, how = installHook(, off, handler)
        if ok then
            APPLIED_HOOK[k] = true
            print(string.format("[TDataMaster] hook %s @0x%X via %s", , off, how))
        else
            print(string.format("[TDataMaster] hook %s @0x%X FAILED (%s)", , off, how))
        end
    end
    local function Hacker(...) return 0 end
    _G.Hacker = Hacker
    local function applyAll()    
PATCH_("TDataMaster.so", "0x306137", "00 00 80 D2 C0 03 5F D6")
PATCH_("TDataMaster.so", "0x3161aa", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x30a018", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x2fccc3", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x30b452", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x3011f3", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x307f98", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x2fcc83", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x2dd972", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x2ecb0d", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x314a93", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x2fcc63", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x3166af", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x2fd227", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x312391", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x2eceec", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x2d8c03", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x2eb2c1", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x2e95e0", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x2d9741", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x2d9562", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x31d722", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x307c13", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x307d44", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x30b482", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x2ebc31", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x306a56", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x306b70", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x306ba8", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x2dd961", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x316aa3", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x2f8231", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x30d813", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x30a392", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x30b947", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x2d857b", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x2d900b", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x314a5b", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x30482c", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x2eb7d9", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x2fcba8", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x3063c2", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x3143fa", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x306d93", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x2fceb6", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x306f10", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x2f7c08", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x3169d0", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x307ed7", "00 00 80 D2 C0 03 5F D6") 
PATCH_("TDataMaster.so", "0x31674c", "00 00 80 D2 C0 03 5F D6") 


      

    end
    applyAll()
    return {
        ready            = true,
        pkg              = PKG,
        file          = FILE,
        applied_patch    = APPLIED_PATCH,
        applied_hook     = APPLIED_HOOK,
        PATCH_        = PATCH_,
        HOOK__NO_ORIG = HOOK__NO_ORIG,
    }
end)()
_G.__HackerTDataMasterBypass = HackerTDataMasterBypass
