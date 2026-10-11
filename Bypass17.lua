

        local lib = {"libanogs.so:bss", "Cb"}
        local path = {0x5D8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 4096, flags = gg.TYPE_BYTE, freeze = true}})
        -- Fix Crash
        
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x184}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- bool bReportFeedBack;

        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x188}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int AutoAimFailedCnt

        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x18C}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int InclusiveBegin

        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x190}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int InclusiveEnd

        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x194}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float SpeedUpValue

        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x198}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int TrackingFailedCnt

        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x19C}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int AreaDamageFailedCnt

        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1A0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int JumpHeightFailedCnt
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1A4}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int JumpFarFailedCnt
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1A8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int VehicleFlyingFailedCnt
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1B8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch CheatStateData2TotalCheatTimes;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1E8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch MoveCheatAntiStrategy3TotalCheatTimes;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x230}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsNoHitDetail;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x258}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsMuzzleRangeCircle;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x280}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsMuzzleRangeUp;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2A8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsHitBoneNameNone;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2D0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsHitBoneHitMissMatch;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2F8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsBulletID;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x320}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsVehicleTimeStampError;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x348}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsWatchTimeStampError;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x370}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int MaxShootPointPassWall
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x374}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int MaxMuzzleHeightTime
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x378}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int MaxLocusFailTime
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x37C}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int MaxBulletVictimClientPassWallTimes
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x380}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int MaxGunPosErrorTimes
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x384}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int MaxAllowVehicleTimeSpeedRawTime
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x388}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int MaxAllowVehicleTimeSpeedConvTime
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x38C}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int MaxAllowVehicleAccTime
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x390}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsBoneInfo;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x3B8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsJumpMaxHeight;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x3E0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsJumpMaxHeight15;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x408}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsJumpMaxHeight2;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x430}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsShootRpgShootTimeVerify;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x458}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsShootLockShootTimeVerify;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x480}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsShootRpgHitNewVerify;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x4A8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsShootTimeConDelta;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x4D0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsServerNoOldShoot;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x4F8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsClientNotConnectShoot;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x520}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsShootRpgShootIntervalVerify;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x560}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsImpactPointAndBulletDisBig;	
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x588}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsShootVerifyInvalid;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x5B0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- bool bOpenDetailDataCollect;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x5B8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsImpactActorPosWithNoHisPos;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x5E0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarJump;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x608}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsShootAngleInVaild;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x630}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsMuzzleAndTailPosInVaild;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x658}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsMuzzleAndImpactPassWall;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x680}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsMuzzleAndTailPassWall;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x6A8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsImpactActorPosOffsetBig;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x6D0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsImpactPointChangeSmall;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x6F8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsImpactBulletPosOffsetBig;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x720}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsTotalImactCharacterNum;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x748}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- AntiCheatDetailData CatchReportAntiCheatDetailData;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x770}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int MaxCatchWeaponAntiDataNLength
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x778}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ClientTimeSpeedAcc;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x7A0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float ClientTimeTotalAcc
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x7A8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float ServerAccumulateErrors
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x7AC}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float ServerAvgErrors
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x7B4}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int ServerCorrectTimes
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x7B8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ServerAccumulateErrorReplay;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x7E0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- BurstVerifySwitch ServerAccumulateErrorBurst;//[,0x80]
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x860}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch DSSpeedOver10FailedCnt;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x888}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch DSSpeedOver15FailedCnt;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x8B0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch DSSpeedOver20FailedCnt;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x8D8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SpeedQuickCheck;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x900}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch BulletDirError;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x928}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchMuzzleLocusError;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x950}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchMuzzleLocusErrorX;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x978}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchMuzzleLocusErrorY;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x9A0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchMuzzleLocusErrorZ;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x9C8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch Gun2ShooterPosError1;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x9F0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchHeadLocusError3;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xA18}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchMuzzleLocusErrorLength;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xA40}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchShootPosHistoryLocusError3;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xA68}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchHitComponentUnvalid;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xA90}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchHitNoRender;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xAB8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchHitOutCollisionBox;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xAE0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch HeadOverShootPos;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xB08}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchMuzzleImpactDirSkipPunish1;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xB30}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchInvalidBulletNumInBarrel;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xB58}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchShooterMovementError2;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xB80}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch GunTailPosError;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xBA8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchMuzzleImpactDirSkipPunish2;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xBD0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchMuzzleImpactDirError1;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xBF8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchMuzzleImpactDirError2;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xC20}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ShooterHead2PosBlock;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xC48}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchShootPosHistoryLocusError2;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xC70}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch Head2GunTailPosError1;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xC98}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchShootDirExcepation1;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xCC0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchShootDirExcepation2;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xCE8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchCamerModeException;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xD10}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchShootPosHistoryLocusError4;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xD38}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchMuzzleImpactDirError3;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xD60}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch CharacterMoveException1;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xD88}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch CharacterMoveException2;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xDB0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch CharacterMoveException3;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xDD8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch CharacterMoveException4;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xE00}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch CharacterMoveException5;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xE28}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch CharacterMoveException6;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xE50}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int ShootVerifyTimes
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xEB0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float VehicleSpeedZDeltaTotal
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xEB4}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int VehicleSpeedZDeltaOver10Times
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xEB8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VehicleSpeedZDeltaOver10TimesWhenNoXY;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xEE0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VehicleVelZCheck1;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xF08}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VehicleVelZCheck2;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xF30}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VehicleMaxSpeedCheck;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xF58}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VehicleHitMuzzleCheck;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xF80}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VehicleHitImpactPointCheck;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xFA8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VehicleHitBlockWall;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xFD0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VehicleSidesway1;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xFF8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VehicleSidesway2;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1028}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarShootInMidAirVehicleExceedThreshold;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1050}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarShootInMidAirVehicleEnemyDistanceTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1078}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarShootInMidAirVehicleEnemyDistanceFurtherTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x10A0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarShootInMidAirVehicleHeightTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x10C8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarShootInMidAirVehicleHeightFurtherTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x10F0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarShootInMidAirPawnExceedThreshold;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1118}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarShootInMidAirPawnEnemyDistanceTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1140}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarShootInMidAirPawnEnemyDistanceFurtherTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1168}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarShootInMidAirPawnHeightTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1190}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarShootInMidAirPawnHeightFurtherTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x11B8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch DSRunning2DSpeedExceededCount;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x11E0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch DSRunning2DSpeedTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1208}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch DSRunning2DSpeedFurtherTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1230}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch DSIgnoreNetworkDying2DSpeedExceededCount;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1258}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch DSDyingMoveSpeedExceedCount;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1280}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch NonGunADSFarShootCount;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x12A8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch NonGunADSFarShootFromClientBulletDataCount;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x12D0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch NonGunADSFarShootFromClientBulletDataEnemyDistanceTrialCount;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x12F8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch NonGunADSFarShootFromClientBulletDataEnemyDistanceFurtherTrialCount;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1320}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ClientUploadFuzzyObjectVerifyFail;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1348}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ClientMoveTimeStampResetFrequencyExceedThreshold;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1370}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ShootBirdNonGunADSExceedThreshold;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1398}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ShootBirdNonGunADSDistanceTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x13C0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ShootBirdNonGunADSDistanceFurtherTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x13E8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarShootInHighTangentMoveSpeedExceedThreshold;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1410}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarShootInHighTangentMoveSpeedEnemyDistanceTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1438}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarShootInHighTangentMoveSpeedEnemyDistanceFurtherTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1460}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarShootInHighTangentMoveSpeedSpeedTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1488}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarShootInHighTangentMoveSpeedSpeedFurtherTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x14B0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireAfterKill;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x14D8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireAfterKillDistanceTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1500}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireAfterKillTimeTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1528}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireAfterKillMaxTime;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1550}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFirePickUpItem;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1578}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFirePickUpItemDistanceTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x15A0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFirePickUpItemTimeTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x15C8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFirePickUpItemMaxTime;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x15F0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireNotKill;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1618}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireNotKillDistanceTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1640}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireNotKillTimeTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1668}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireNotKillMaxTime;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1690}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireOnVehicle;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x16B8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireOnVehicleDistanceTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x16E0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireOnVehicleTimeTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1708}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireOnVehicleMaxTime;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1730}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireSameVehicle;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1758}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireSameVehicleTimeTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1780}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireSameVehicleMaxTime;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x184}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- bool bReportFeedBack;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x188}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int AutoAimFailedCnt
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x18C}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int InclusiveBegin
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x190}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int InclusiveEnd
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x194}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float SpeedUpValue
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x198}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int TrackingFailedCnt
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x19C}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int AreaDamageFailedCnt
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1A0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int JumpHeightFailedCnt
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1A4}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int JumpFarFailedCnt
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1A8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int VehicleFlyingFailedCnt
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1B8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch CheatStateData2TotalCheatTimes;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1E8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch MoveCheatAntiStrategy3TotalCheatTimes;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x230}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsNoHitDetail;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x258}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsMuzzleRangeCircle;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x280}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsMuzzleRangeUp;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2A8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsHitBoneNameNone;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2D0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsHitBoneHitMissMatch;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2F8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsBulletID;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x320}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsVehicleTimeStampError;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x348}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsWatchTimeStampError;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x370}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int MaxShootPointPassWall
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x374}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int MaxMuzzleHeightTime
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x378}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int MaxLocusFailTime
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x37C}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int MaxBulletVictimClientPassWallTimes
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x380}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int MaxGunPosErrorTimes
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x384}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int MaxAllowVehicleTimeSpeedRawTime
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x388}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int MaxAllowVehicleTimeSpeedConvTime
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x38C}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int MaxAllowVehicleAccTime
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x390}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsBoneInfo;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x3B8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsJumpMaxHeight;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x3E0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsJumpMaxHeight15;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x408}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsJumpMaxHeight2;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x430}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsShootRpgShootTimeVerify;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x458}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsShootLockShootTimeVerify;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x480}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsShootRpgHitNewVerify;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x4A8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsShootTimeConDelta;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x4D0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsServerNoOldShoot;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x4F8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsClientNotConnectShoot;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x520}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsShootRpgShootIntervalVerify;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x560}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsImpactPointAndBulletDisBig;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x588}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsShootVerifyInvalid;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x5B0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- bool bOpenDetailDataCollect;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x5B8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsImpactActorPosWithNoHisPos;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x5E0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarJump;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x608}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsShootAngleInVaild;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x630}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsMuzzleAndTailPosInVaild;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x658}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsMuzzleAndImpactPassWall;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x680}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsMuzzleAndTailPassWall;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x6A8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsImpactActorPosOffsetBig;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x6D0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsImpactPointChangeSmall;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x6F8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsImpactBulletPosOffsetBig;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x720}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsTotalImactCharacterNum;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x748}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- AntiCheatDetailData CatchReportAntiCheatDetailData;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x770}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int MaxCatchWeaponAntiDataNLength
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x778}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ClientTimeSpeedAcc;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x7A0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float ClientTimeTotalAcc
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x7A8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float ServerAccumulateErrors
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x7AC}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float ServerAvgErrors
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x7B4}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int ServerCorrectTimes
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x7B8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ServerAccumulateErrorReplay;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x7E0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- BurstVerifySwitch ServerAccumulateErrorBurst;//[,0x80]
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x860}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch DSSpeedOver10FailedCnt;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x888}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch DSSpeedOver15FailedCnt;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x8B0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch DSSpeedOver20FailedCnt;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x8D8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SpeedQuickCheck;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x900}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch BulletDirError;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x928}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchMuzzleLocusError;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x950}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchMuzzleLocusErrorX;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x978}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchMuzzleLocusErrorY;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x9A0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchMuzzleLocusErrorZ;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x9C8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch Gun2ShooterPosError1;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x9F0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchHeadLocusError3;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xA18}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchMuzzleLocusErrorLength;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xA40}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchShootPosHistoryLocusError3;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xA68}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchHitComponentUnvalid;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xA90}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchHitNoRender;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xAB8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchHitOutCollisionBox;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xAE0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch HeadOverShootPos;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xB08}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchMuzzleImpactDirSkipPunish1;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xB30}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchInvalidBulletNumInBarrel;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xB58}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchShooterMovementError2;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xB80}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch GunTailPosError;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xBA8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchMuzzleImpactDirSkipPunish2;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xBD0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchMuzzleImpactDirError1;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xBF8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchMuzzleImpactDirError2;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xC20}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ShooterHead2PosBlock;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xC48}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchShootPosHistoryLocusError2;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xC70}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch Head2GunTailPosError1;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xC98}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchShootDirExcepation1;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xCC0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchShootDirExcepation2;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xCE8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchCamerModeException;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xD10}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchShootPosHistoryLocusError4;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xD38}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SwitchMuzzleImpactDirError3;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xD60}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch CharacterMoveException1;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xD88}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch CharacterMoveException2;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xDB0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch CharacterMoveException3;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xDD8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch CharacterMoveException4;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xE00}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch CharacterMoveException5;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xE28}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch CharacterMoveException6;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xE50}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int ShootVerifyTimes
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xEB0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float VehicleSpeedZDeltaTotal
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xEB4}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int VehicleSpeedZDeltaOver10Times
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xEB8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VehicleSpeedZDeltaOver10TimesWhenNoXY;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xEE0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VehicleVelZCheck1;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xF08}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VehicleVelZCheck2;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xF30}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VehicleMaxSpeedCheck;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xF58}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VehicleHitMuzzleCheck;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xF80}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VehicleHitImpactPointCheck;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xFA8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VehicleHitBlockWall;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xFD0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VehicleSidesway1;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0xFF8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VehicleSidesway2;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1028}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarShootInMidAirVehicleExceedThreshold;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1050}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarShootInMidAirVehicleEnemyDistanceTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1078}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarShootInMidAirVehicleEnemyDistanceFurtherTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x10A0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarShootInMidAirVehicleHeightTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x10C8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarShootInMidAirVehicleHeightFurtherTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x10F0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarShootInMidAirPawnExceedThreshold;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1118}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarShootInMidAirPawnEnemyDistanceTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1140}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarShootInMidAirPawnEnemyDistanceFurtherTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1168}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarShootInMidAirPawnHeightTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1190}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarShootInMidAirPawnHeightFurtherTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x11B8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch DSRunning2DSpeedExceededCount;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x11E0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch DSRunning2DSpeedTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1208}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch DSRunning2DSpeedFurtherTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1230}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch DSIgnoreNetworkDying2DSpeedExceededCount;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1258}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch DSDyingMoveSpeedExceedCount;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1280}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch NonGunADSFarShootCount;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x12A8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch NonGunADSFarShootFromClientBulletDataCount;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x12D0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch NonGunADSFarShootFromClientBulletDataEnemyDistanceTrialCount;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x12F8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch NonGunADSFarShootFromClientBulletDataEnemyDistanceFurtherTrialCount;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1320}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ClientUploadFuzzyObjectVerifyFail;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1348}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ClientMoveTimeStampResetFrequencyExceedThreshold;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1370}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ShootBirdNonGunADSExceedThreshold;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1398}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ShootBirdNonGunADSDistanceTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x13C0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ShootBirdNonGunADSDistanceFurtherTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x13E8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarShootInHighTangentMoveSpeedExceedThreshold;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1410}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarShootInHighTangentMoveSpeedEnemyDistanceTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1438}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarShootInHighTangentMoveSpeedEnemyDistanceFurtherTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1460}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarShootInHighTangentMoveSpeedSpeedTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1488}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch FarShootInHighTangentMoveSpeedSpeedFurtherTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x14B0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireAfterKill;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x14D8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireAfterKillDistanceTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1500}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireAfterKillTimeTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1528}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireAfterKillMaxTime;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1550}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFirePickUpItem;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1578}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFirePickUpItemDistanceTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x15A0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFirePickUpItemTimeTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x15C8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFirePickUpItemMaxTime;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x15F0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireNotKill;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1618}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireNotKillDistanceTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1640}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireNotKillTimeTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1668}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireNotKillMaxTime;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1690}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireOnVehicle;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x16B8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireOnVehicleDistanceTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x16E0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireOnVehicleTimeTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1708}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireOnVehicleMaxTime;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1730}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireSameVehicle;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1758}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireSameVehicleTimeTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1780}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireSameVehicleMaxTime;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x17A8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpUseObjectTogether;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x17D0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpGetOnEnemyVehicleCount;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x17F8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireOneSideHasWeaponOnFoot;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1820}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpNearbyButNoFireOneSideHasWeaponOnFootDistanceTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1848}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch IllegalTeamUpStayOnEnemyVehicle;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1870}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch KillBird;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1898}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ParachuteLandingSecondsExceedThreshold;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x18C0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ParachuteObliqueLandingSecondsExceedThreshold;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1970}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ShootBird;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1998}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch DSFallingSpeedFailCount;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x19C0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch DSFallingHeightFailCount;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x19E8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int PVSInCityKillCount
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x19EC}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int PVSNotInCityKillCount
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x19F0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float PVSInCityKillTotalTime
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x19F4}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float PVSNotInCityKillTotalTime
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x19F8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float PVSInCityKillerTotalMoveDistance
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x19FC}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float PVSNotInCityKillerTotalMoveDistance
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1A00}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int PVSCellHidePercent
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1A04}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int PVSTotalHidePercent
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1A10}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ShooterCapsuleCollided;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1A38}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch JumpReviewHighJumpExceed;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1A60}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch JumpReviewFarJumpExceed;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1A88}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch JumpReviewLowerFarJump;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1AB0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float ActorTimeDilation
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1AB4}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float WalkableFloorAngle
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1AB8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float MaxStepHeight
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1AC0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SmallActorTimeDilationCount;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1AE8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch LargeRotateLockShooting;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1B10}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SmallRotateLockShooting;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1B38}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch OneClipShootCount;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1B60}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ClientWeaponFastReload;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1B88}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch WalkSpeedFailedCnt;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1DE0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch DSCheckClientTimeMoveDistance2D;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1E08}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch DSCheckClientTimeMoveDistance2DTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1E30}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch DSCheckClientTimeMoveDistance2DFurther;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1E58}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch DSCheckClientTimeMoveDistanceZ;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1E80}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch DSCheckClientTimeMoveDistanceZTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1EA8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch DSCheckClientTimeMoveDistanceZFurther;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1ED0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float MaxFallingSustainTime
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1ED8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ReplayMaxFallingSustainTime;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1F00}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float MaxCustomMoveModeSustainTime
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1F08}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ReplayMaxCustomMoveModeSustainTime;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1F30}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float MaxMoveDistance2DPerSecond
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1F34}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float MaxCharMoveDist2DPerSecond
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1F38}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float MaxDistanceToGround
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1F3C}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float MaxSingleShotDamage
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1F40}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ReplayMaxSingleShotDamage;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1F68}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch UndergroundCount;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1F90}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch MoveDistance2DPerSecondAnomaly;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1FB8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch CharMoveDist2DPerSecondAnomaly;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x1FE0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch CharMoveDist2DPerSecondCount;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2008}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch CharMoveAccumDist2D_DS;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2030}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch CharMoveAccumDist3D_DS;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2058}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch CharMoveAccumDist2D_Client;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2080}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch CharMoveAccumDist3D_Client;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x20A8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch CharMoveAccumDist2D_ClientAll;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x20D0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch CharMoveAccumDist3D_ClientAll;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x20F8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch DistanceToGroundAnomaly;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2120}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch SingleShotDamageAnomaly;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2148}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- BurstVerifySwitch DSSpeedOver10BurstCount;//[,0x80]
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x21C8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch BandaCount;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x21F0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- BurstVerifySwitch ParachuteSpeedBurst;//[,0x80]
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2270}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- BurstVerifySwitch ClientTimestampBurst;//[,0x80]
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x22F0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- BurstVerifySwitch ClientTimestampBurstTrial;//[,0x80]
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2370}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch MetroEnterRadiationTime;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2398}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch MetroEnterRadiationTimeTrial;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x23C0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch MetroLeaveBornObstacle;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x243C}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float ParachuteStartTime
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2440}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float ParachuteOpenTime
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2444}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float ParachuteCloseTime
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2448}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float ParachuteStartHight
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x244C}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float ParachuteOpenHight
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2450}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float ParachuteCloseHight
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x24F8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- <enum,uint32> ReportMiscMap;//[,0x50]
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2548}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int PlayerBadPingTimes
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2558}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsPetJumpHeightLimiter;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2580}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsPetMoveSpeedLimiter;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x25A8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsBioVehicleMoveSpeedLimiter;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x25D0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsBioVehicleJumpHeightLimiter;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x25F8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsPterosaurFlyVehicleSpeed;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2620}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsBioVehicleGravityLimiter;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2648}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ServerMoveCacheCountOver;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2670}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ServerMoveCacheCountOver3d;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2698}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ServerMoveBurst;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x26C0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ImpactOtherAfterBurst;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x26E8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float MinImpactOtherInterval
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x26EC}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- bool bImpactOtherAfterBurst;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x26F0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch KillOtherAfterBurst;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2718}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch PickupAfterBurst;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2740}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- bool bOpenPickupWhenBrustCheck;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2744}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float MinBurstToPickupInterval
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2748}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float LastServerBurstMoveTimeForPickup
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x274C}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float MaxPlayerDisSquaredForPickup
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2750}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- bool bGiveupPickupWhenBrust;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2758}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ContinueMoveBurst;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2780}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float MinContinueMoveBurstXY
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2784}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float MaxContinueMoveBurstXY
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2788}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float ContinueMoveBurstTolerant
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x278C}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float LastShortDistMoveBurstTime
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2790}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float ContinueMoveBurstInterval
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2794}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int ContinueMoveBurstCount
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2798}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int RecordContinueMoveBurstCount
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x279C}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- bool bMustStrictContinue;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x27A8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VerifySwitchCameraRotation;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x27D0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VerifySwitchPeekShootThroughWall;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x27F8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VerifySwitchCameraLocation;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2820}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VerifySwitchAutoAimByLockView;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2848}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VerifySwitchControlRotation;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2870}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VerifySwitchRecoilFaildCount;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2898}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VerifySwitchMarcoPolo;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x28C0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VerifySwitchMarcoPolo2;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x28E8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VerifySwitchMarcoPolo3;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2910}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VerifySwitchMeshScaleDiff;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2938}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VerifySwitchOfflineMove;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2960}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VerifySwitchFastAimShootHit;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2988}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VerifySwitchNoRecoilOnWeaponShoot;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x29B0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VerifySwitchLessRecoilOnWeaponShoot;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x29D8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VerifySwitchNoRecoilOnKickBack;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2A00}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VerifySwitchLessRecoilOnKickBack;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2A28}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VerifySwitchDivingBoost;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2A50}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VerifySwitchRecoilCurveFailed;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2A78}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch PlayerQuickProne;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2AA0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch BaseDiffSample;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2AF8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int TrialBaseDiffCount
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2B08}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float BaseDiffRegion
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2B0C}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float BaseDiffVel
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2B10}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float BaseDiffTime
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2B18}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- bool bOpenBaseDiffCheck;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2B28}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- float Werewolf2HumanTime
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2B2C}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int ServerMoveParameterVerifyCount
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2B30}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int ServerMoveParameterVerifyFailedCount
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2B38}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ServerMoveTimeStamp;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2B60}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ServerMoveAccel;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2B88}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ServerMoveClientLoc;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2BB0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ServerMoveCompressedMoveFlags;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2BD8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ServerMoveClientRoll;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2C00}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ServerMoveView;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2C28}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ServerMoveClientMovementBase;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2C50}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ServerMoveClientBaseBoneName;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2C78}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch ServerMoveClientMovementMode;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2CA0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch PlayerInstantHeightDiff;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2CE0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch Player2SecHeightDiff;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2D90}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int StuckGroundPunishType
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2D94}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int StuckTypePunishSet
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2D9C}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- bool bStuckGroundCapsule;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2DA0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int StuckGroundPunishCount
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2DA4}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- int MultiStuckGroundScale
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2DF8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- bool bUploadStuckGroundCount;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2E00}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsTeammateRescue;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2E28}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsTeammateRescueVictim;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2E50}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsTeammateRecall;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2E78}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsTeammateRecallVictim;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2EA0}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsAutoClicker;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2ED8}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- VerifySwitch VsAbnormalShootingRotation;
        local lib = {"libUE4.so:bss", "Cb"}
        local path = {0x56CFF0,0x30,0x4B8,0x2408,0x2F00}
        local addr = S_Pointer(lib, path, true)
        gg.addListItems({{address = addr, value = 0, flags = gg.TYPE_BYTE, freeze = true}}) 
-- Object* DSProperty
	

	
--Tg @RAHMANYVI 