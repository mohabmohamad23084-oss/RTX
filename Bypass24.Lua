
local HackerRoosterNNBypass = (function()
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
    local FILE = DIR .. "RoosterNN.so"
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
                "/storage/emulated/0/Android/data/" .. PKG .. "/files/RoosterNN.bin",
                "/sdcard/Android/data/" .. PKG .. "/files/RoosterNN.bin",
                "/data/local/tmp/RoosterNN.bin",
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
            print(string.format("[RoosterNN] patch %s @0x%X [%s] via %s", , off, bytes, how))
        else
            print(string.format("[RoosterNN] patch %s @0x%X FAILED (%s)", , off, how))
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
            print(string.format("[RoosterNN] hook %s @0x%X via %s", , off, how))
        else
            print(string.format("[RoosterNN] hook %s @0x%X FAILED (%s)", , off, how))
        end
    end
    local function Hacker(...) return 0 end
    _G.Hacker = Hacker
    local function applyAll()    
PATCH_("RoosterNN.so", "0x171e6", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x19574", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x1e44a3", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x10fec", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x17fd3", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x1e0825", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x1e59e9", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x1e4ed0", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x1e0886", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x10eaf", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x19b1a", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x1e45dd", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x17e75", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x1980b", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x1e3ff4", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x1e5b17", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x1e7cac", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x16a24", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x1e7c99", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x168e9", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x1e08be", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x1e4a93", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x1e818a", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x1e59d2", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x1e6c58", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x1e4da1", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x1e81a5", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x1e64c2", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x17e1a", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x1e7c8b", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x165b7", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x11038", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x19b21", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x1e4ab9", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x1e71be", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x1e085d", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x16ab2", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x16a3d", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x163b6", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x1e5734", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x1e4cad", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x15658", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x10e85", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x1e648a", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x1955d", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x1e2d69", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x1e2e50", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x17e01", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x16a98", "00 00 80 D2 C0 03 5F D6") 
PATCH_("RoosterNN.so", "0x1e8197", "00 00 80 D2 C0 03 5F D6") 

      

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
_G.__HackerRoosterNNBypass = HackerRoosterNNBypass
