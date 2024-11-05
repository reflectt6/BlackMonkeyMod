local LogPrefix = "[SomersaultCloudAnywhere] "
local Version = "2.1"

local config = require("config")

local gameInstance = nil
local preloadAssetMgr = nil

local cloudEffectDBC = nil
local cloudEffectDBC_RotateLerpSpeedCurve = nil
local cloudEffectDBC_LocationLerpSpeedCurve = nil
local cloudEffectDBC_OffsetCurve = nil
local cloudAkEventStop = nil
local cloudFoliageFadeScaleCurve = nil

local wukong = nil
local cloudMoveConfig = nil

function IsNilOrInvalid(obj)
    return obj == nil or not obj:IsValid()
end

function Log(msg)
    if msg == nil then
        return
    end
    print(LogPrefix .. msg)
end

Log("Starting " .. Version)
Log("KeyNames set to { " .. table.concat(config.keyNames, ", ") .. " }")

function MakeCloudMoveConfig()
    local BGWDataAsset_CloudMoveConfig_Class = StaticFindObject("/Script/b1-Managed.BGWDataAsset_CloudMoveConfig")
    cloudMoveConfig = StaticConstructObject(BGWDataAsset_CloudMoveConfig_Class, gameInstance)

    cloudMoveConfig.CloudSkillCooldownTime = 0
    cloudMoveConfig.CloudSkill_Ride_Walk = 10201
    cloudMoveConfig.CloudSkill_Ride_Run = 10202
    cloudMoveConfig.CloudSkill_Ride_Sprint = 10203
    cloudMoveConfig.CloudSkill_Ride_Fall = 10204
    cloudMoveConfig.CloudSkill_Ride_Fall_MinHeight = 450
    cloudMoveConfig.CloudSkill_GetOff_Walk_Low = 10211
    cloudMoveConfig.CloudSkill_GetOff_Walk_High = 10212
    cloudMoveConfig.CloudSkill_GetOff_Run_Low_Forward = 10213
    cloudMoveConfig.CloudSkill_GetOff_Run_Low_Upward = 10215
    cloudMoveConfig.CloudSkill_GetOff_Run_Low_Downward = 10217
    cloudMoveConfig.CloudSkill_GetOff_Run_High_Forward = 10214
    cloudMoveConfig.CloudSkill_GetOff_Run_High_Upward = 10216
    cloudMoveConfig.CloudSkill_GetOff_Run_High_Downward = 10218
    cloudMoveConfig.CloudSkill_GetOff_Rush_Low_Forward = 10219
    cloudMoveConfig.CloudSkill_GetOff_Rush_Low_Upward = 10221
    cloudMoveConfig.CloudSkill_GetOff_Rush_Low_Downward = 10223
    cloudMoveConfig.CloudSkill_GetOff_Rush_High_Forward = 10220
    cloudMoveConfig.CloudSkill_GetOff_Rush_High_Upward = 10222
    cloudMoveConfig.CloudSkill_GetOff_Rush_High_Downward = 10224
    cloudMoveConfig.HeightLimitThreshold = 2500
    cloudMoveConfig.DisableHeightLimitIfNoInput = true
    cloudMoveConfig.MinimumHeightRestriction = 300
    cloudMoveConfig.MinimumHeightRestrictionThreshold = 1250
    cloudMoveConfig.HorizontalFlightUpAngleRange = 0
    cloudMoveConfig.HorizontalFlightDownAngleRange = -2
    cloudMoveConfig.RushEffectSpeed = 1200
    cloudMoveConfig.RushEffectBuffList = {10296, 10290, 10294}
    cloudMoveConfig.CloudMoveItemId = 5009
    cloudMoveConfig.CloudMoveBuffId = {10299, 10297, 218, 10289}
    cloudMoveConfig.CloudEffectDBC = cloudEffectDBC
    cloudMoveConfig.CloudEffectDBC_RotateLerpSpeedCurve = cloudEffectDBC_RotateLerpSpeedCurve
    cloudMoveConfig.CloudEffectDBC_LocationLerpSpeedCurve = cloudEffectDBC_LocationLerpSpeedCurve
    cloudMoveConfig.CloudEffectDBC_OffsetCurve = cloudEffectDBC_OffsetCurve
    cloudMoveConfig.CloudFoliageFadeScaleCurve = cloudFoliageFadeScaleCurve
    cloudMoveConfig.GroundEffectDistance = 1500
    cloudMoveConfig.GroundEffectInterval = -1
    cloudMoveConfig.GroundEffectSpeed = 1000

    return cloudMoveConfig
end

-- load instance only if it's nil or invalid. loading order is find first then load default if default path is given
function LoadInstance(current, className, defaultPath)
    if current ~= nil and current:IsValid() then
        return current
    end

    Log("loading " .. className)

    local instance = FindFirstOf(className)
    if defaultPath ~= nil and IsNilOrInvalid(instance) then
        Log("Finding default")
        instance = StaticFindObject(defaultPath)
    end

    if IsNilOrInvalid(instance) then
        Log("failed to load " .. className)
    end

    return instance
end

function SetVars()
    gameInstance = LoadInstance(gameInstance, "BGW_GameInstance_B1")
    preloadAssetMgr = LoadInstance(preloadAssetMgr, "BGW_PreloadAssetMgr")

    if not preloadAssetMgr._CloudMoveConfig:IsValid() then
        Log("setting _CloudMoveConfig")
        cloudMoveConfig = MakeCloudMoveConfig()
        preloadAssetMgr._CloudMoveConfig = cloudMoveConfig
    end
end

function LoadCloudAssets()
    if IsNilOrInvalid(cloudEffectDBC) then
        Log("loading cloudEffectDBC")
        cloudEffectDBC = LoadAsset(
            "/Game/00Main/VFX/Characters/sunwukong/DBC/Cloud/DBC_wukong_cloud_interactive.DBC_wukong_cloud_interactive")
    end

    if IsNilOrInvalid(cloudEffectDBC_RotateLerpSpeedCurve) then
        Log("loading cloudEffectDBC_RotateLerpSpeedCurve")
        cloudEffectDBC_RotateLerpSpeedCurve = LoadAsset(
            "/Game/00Main/Design/Curve/CloudMove/CloudMoveCurve_EffectRotationLerpSpeed.CloudMoveCurve_EffectRotationLerpSpeed")
    end

    if IsNilOrInvalid(cloudEffectDBC_LocationLerpSpeedCurve) then
        Log("loading cloudEffectDBC_LocationLerpSpeedCurve")
        cloudEffectDBC_LocationLerpSpeedCurve = LoadAsset(
            "/Game/00Main/Design/Curve/CloudMove/CloudMoveCurve_EffectLocationLerpSpeed.CloudMoveCurve_EffectLocationLerpSpeed")
    end

    if IsNilOrInvalid(cloudEffectDBC_OffsetCurve) then
        Log("loading cloudEffectDBC_OffsetCurve")
        cloudEffectDBC_OffsetCurve = LoadAsset(
            "/Game/00Main/Design/Curve/CloudMove/CloudMoveCurve_EffectOffset.CloudMoveCurve_EffectOffset")
    end

    if IsNilOrInvalid(cloudFoliageFadeScaleCurve) then
        Log("loading cloudFoliageFadeScaleCurve")
        cloudFoliageFadeScaleCurve = LoadAsset(
            "/Game/00Main/Design/Curve/FoliageFade/FadeCurve_wukong_cloud.FadeCurve_wukong_cloud")
    end
end

RegisterHook("/Script/Engine.PlayerController:ClientRestart", function(self, newPawn)
    LoadCloudAssets()
    SetVars()

    newPawn = newPawn:get()
    if not IsNilOrInvalid(newPawn) then
        if string.find(newPawn:GetFullName(), "Unit_Player_Wukong_C") then
            Log("setting wukong")
            wukong = newPawn
        end
    end
end)

function SetBPVars(ModActor)
    if IsNilOrInvalid(ModActor) then
        ModActor = FindFirstOf("/Game/Mods/SomersaultCloudAnywhere/ModActor.ModActor_C")
    end
    if IsNilOrInvalid(ModActor) then
        Log("Error: unable to set bp variables due to not finding ModActor")
        return
    end

    ModActor.keyNames = config.keyNames

    if IsNilOrInvalid(wukong) then
        Log("finding wukong")
        wukong = FindFirstOf("Unit_Player_Wukong_C")
    end
    ModActor.wukong = wukong
end

RegisterCustomEvent("SomersaultCloudAnywhereSetVariables", function(ModActor)
    SetBPVars(ModActor:get())
end)
