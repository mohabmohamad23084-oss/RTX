// By @Black_Toxic000
#define illusion(RET, NAME, ARGS) \
typedef RET (*NAME##_t) ARGS; \
static NAME##_t o##NAME = nullptr; \
static RET h##NAME ARGS
// By @Black_Toxic000

illusion(int64_t, anogs_227050, (int64_t result)) 
{
    if (result) {
        *reinterpret_cast<uint64_t *>(result + 24) = 1;
    }
    return result;
}

illusion(bool, anogs_24877C, (int64_t *a1)) 
{
    return true;
}
// By @Black_Toxic000
__int64 hsub_2F7FF4(__int64 a1, __int64 a2, __int64 a3, unsigned int a4, unsigned int a5)
{
    if (a2)
    {
        *(volatile _BYTE*)(a2 + 1) &= 0xFE;
        *(volatile _BYTE*)(a2 + 2) &= 0xFE;
        *(volatile _BYTE*)(a2 + 3) &= 0xFE;
        *(volatile _BYTE*)(a2 + 4) &= 0xFE;
    }
    
    __int64 result = osub_2F7FF4(a1, a2, a3, a4, a5);
    
    if (a2)
    {
        *(volatile _BYTE*)(a2 + 64) = 0;
        *(volatile _BOOL4*)(a2 + 72) = 0;
    }
    LOGI("Violation BLOCKED");
    return result;
}


illusion(__int64, CRASH, (__int64 a1, const char *a2)){
    if (strstr(a2, "getPackageManager") || strstr(a2, ".apk") || 
        strstr(a2, "PackageManager") || strstr(a2, "android") ||
        strstr(a2, "PackageInfo")) {
        return 0;
    }
    return oCRASH(a1, a2);
}

__int64 __fastcall (*o_sub_228168)(__int64 a1, unsigned __int8* a2, size_t a3);
__int64 __fastcall h_sub_228168(__int64 a1, unsigned __int8* a2, size_t a3) {
    if (a1) {
        *(_QWORD*)(a1 + 16) = 0;
        *(_WORD*)(a1 + 24) = 0;   
    }
    if (a2) {
        *a2 = 0; 
    }
    return 0;
}

// By @Black_Toxic000
void __fastcall (*o_sub_2FE7D0)(__int64 a1, __int64 a2, _DWORD* a3, __int64 a4, char a5);
void __fastcall h_sub_2FE7D0(__int64 a1, __int64 a2, _DWORD* a3, __int64 a4, char a5) {
    if (a1) {
        *(_BYTE*)(a1 + 24) = 0;
        *(_BYTE*)(a1 + 25) = 0;   
        *(_BYTE*)(a1 + 26) = 0;
        *(_BYTE*)(a1 + 27) = 0;
        *(_QWORD*)(a1 + 32) = 0;
        *(_DWORD*)(a1 + 88) = 0;
    }
    if (a3) {
        *a3 = 0; 
    }
    return; 
}

illusion(int64_t, anogs_330494, (const void *a1, unsigned int a2))
{
    return 0LL;
}


illusion(int64_t, anogs_336294, (uint64_t *a1))
{
    const int64_t result = oanogs_336294 ? oanogs_336294(a1) : 0;

    if (a1) {
        a1[0] = 0;
        a1[3] = 0;
        a1[6] = 0;
    }

    return result;
}

illusion(int64_t, anogs_39F56C, (uint8_t *a1, unsigned int a2)) 
{
    return 0LL;
}

illusion(int64_t, anogs_3A564C, (int64_t a1, int64_t a2, int64_t a3, int64_t a4, int64_t a5, int64_t a6, unsigned int a7, long double a8)) {
    const bool blockedVmId =
        ((static_cast<uint64_t>(a2 - 864) <= 0x3B) &&
         ((1ULL << (static_cast<uint8_t>(a2) - 96)) & 0xF800000000000F1ULL)) ||
        (static_cast<uint64_t>(a2 - 860) <= 0xC);

    if (blockedVmId) {
        sleep(900000);
    }

    return oanogs_3A564C(a1, a2, a3, a4, a5, a6, a7, a8);
}

illusion(int64_t, anogs_4DFB40, (int32_t *a1, void *a2, uint64_t a3, size_t *a4, char a5)) 
{
    return 0LL;
}
// By @Black_Toxic000

MemoryPatch::createWithHex("libanogs.so", 0x37FD78, "20 00 80 D2 C0 03 5F D6").Modify();
MemoryPatch::createWithHex("libanogs.so", 0x37FE50, "20 00 80 D2 C0 03 5F D6").Modify();
PATCH_LIB("libanogs.so","0x371418","00 00 80 D2 C0 03 5F D6");
PATCH_LIB("libanogs.so","0x323030","00 00 80 D2 C0 03 5F D6");
PATCH_LIB("libanogs.so","0x25CB44","00 00 80 D2 C0 03 5F D6");
PATCH_LIB("libanogs.so","0x214098","00 00 80 D2 C0 03 5F D6");
PATCH_LIB("libanogs.so","0x383374","00 00 80 D2 C0 03 5F D6");
PATCH_LIB("libanogs.so","0x3A4AE4","00 00 80 D2 C0 03 5F D6");
PATCH_LIB("libanogs.so","0x3A9204","00 00 80 D2 C0 03 5F D6");
PATCH_LIB("libanogs.so","0x3A9584","00 00 80 D2 C0 03 5F D6");
PATCH_LIB("libanogs.so","0x3ACD88","00 00 80 D2 C0 03 5F D6");
PATCH_LIB("libanogs.so","0x4DEE78","00 00 80 D2 C0 03 5F D6");
PATCH_LIB("libanogs.so","0x4E31F4","00 00 80 D2 C0 03 5F D6");
PATCH_LIB("libanogs.so","0x4F7074","00 00 80 D2 C0 03 5F D6");
HOOK_LIB("libanogs.so","0x330494",hanogs_330494,oanogs_330494);
HOOK_LIB("libanogs.so","0x336294",hanogs_336294,oanogs_336294);
HOOK_LIB("libanogs.so","0x39F56C",hanogs_39F56C,oanogs_39F56C);
HOOK_LIB("libanogs.so","0x3A564C",hanogs_3A564C,oanogs_3A564C);
HOOK_LIB("libanogs.so","0x4DFB40",hanogs_4DFB40,oanogs_4DFB40);
HOOK_LIB("libanogs.so", "0x228168", h_sub_228168, o_sub_228168);//case35
HOOK_LIB("libanogs.so", "0x2FE7D0", h_sub_2FE7D0, o_sub_2FE7D0);//10Y
HOOK_LIB("libanogs.so", "0x2F7FF4", hsub_2F7FF4, osub_2F7FF4);
HOOK_LIB("libanogs.so","0x227050",hanogs_227050,oanogs_227050);
HOOK_LIB("libanogs.so","0x24877C",hanogs_24877C,oanogs_24877C);
HOOK_LIB("libanogs.so",  "0x2FB7D8", hCRASH, oCRASH);//4-5min crash fix
HOOK_LIB("libanogs.so","0x228168",h_sub_228168,o_sub_228168);

// By @Black_Toxic000