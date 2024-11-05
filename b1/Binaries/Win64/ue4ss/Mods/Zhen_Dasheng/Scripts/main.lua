
function IsNilOrInvalid(obj)
    return obj == nil or not obj:IsValid()
end

local isPeValueUp = false
local IsInPersicDodge = false
local PersicDodgeCounter = 0

ExecuteWithDelay(10000, function()

    RegisterHook("/Script/b1-Managed.BUS_GSEventCollection:Evt_CastSkillWithAnimMontageMultiCast", function(Context, Montage, PlayTimeRate, MontagePosOffset, StartSectionName, Reason)
        -- print(" --------- > ")
        -- print(Montage:get():GetFullName())
        -- print(" -------------")

        local MontageName = Montage:get():GetFullName()
        if IsInPersicDodge then
            if MontageName:find("ComboA") then
                

                local asset = LoadAsset("/Game/00Main/Animation/Player/Transform/Player_dasheng/Montage/Fashu/AM_dasheng_jxsq_atk_01.AM_dasheng_jxsq_atk_01")

                Montage:set(asset)
                IsInPersicDodge = false
                
                PersicDodgeCounter = 0
                -- Initialize()

                -- local MontageStartSectionName=FName("AM_dasheng_jxsq_atk_01")
                -- StaticFindObject("/Script/b1-Managed.Default__BGUFunctionLibraryCS"):BGUTryCastSpellWithStartSection(wukong,10516,MontageStartSectionName)
                -- MontageName:set()
            end
        end
    end)


    RegisterHook("/Script/b1-Managed.BUS_GSEventCollection:Evt_AddBuffNotify_Multicast_Invoke", function(Context, IsHasBuffBefore, Caster, BuffID, BuffDuration)
        -- print(" --------- >")
        -- print(BuffID:get())
        -- print(" --------- >")
        
        if BuffID:get() == 117 then
            Initialize()

            local BPPlayerController = FindFirstOf("BP_B1PlayerController_C")
            local bpPlayer = BPPlayerController.pawn

            -- print(IsNilOrInvalid(bpPlayer))
            if not IsNilOrInvalid(bpPlayer) then
                BGUFunctionLibraryCS:BGUAddBuff(bpPlayer, bpPlayer, 118, 1, 3000)
                BGUFunctionLibraryCS:BGUAddBuff(bpPlayer, bpPlayer, 119, 1, 3000)
                -- BGUFunctionLibraryCS:BGUAddBuff(bpPlayer, bpPlayer, 120, 1, 3000)
                BGUFunctionLibraryCS:BGUAddBuff(bpPlayer, bpPlayer, 121, 1, 3000)
                BGUFunctionLibraryCS:BGUAddBuff(bpPlayer, bpPlayer, 123, 1, 3000)
                BGUFunctionLibraryCS:BGUAddBuff(bpPlayer, bpPlayer, 1054, 1, 3000)
                BGUFunctionLibraryCS:BGUAddBuff(bpPlayer, bpPlayer, 1055, 1, 3000)
                BGUFunctionLibraryCS:BGUAddBuff(bpPlayer, bpPlayer, 218, 1, 3000)
                BGUFunctionLibraryCS:BGUAddBuff(bpPlayer, bpPlayer, 2093, 1, 3000)
                IsInPersicDodge = true
                PersicDodgeCounter = 0
            end
        elseif BuffID:get() == 1999 then
            isPeValueUp = false
        elseif BuffID:get() == 229 then
            BuffID:set(50005)
        elseif BuffID:get() == 230 then
            BuffID:set(50006)
        end
    end)
end)

LoopAsync(500, function()
    if IsInPersicDodge then
        PersicDodgeCounter = PersicDodgeCounter + 1
        if PersicDodgeCounter > 6 then
            IsInPersicDodge = false
            PersicDodgeCounter = 0
        end
    end
end)

function Initialize()

    if IsNilOrInvalid(BGUFunctionLibraryCS) then
        BGUFunctionLibraryCS = StaticFindObject("/Script/b1-Managed.Default__BGUFunctionLibraryCS")
        if not BGUFunctionLibraryCS:IsValid() then
            BGUFunctionLibraryCS = nil
        end
    end

    if IsNilOrInvalid(UKismetMathLibrary) then
        UKismetMathLibrary = StaticFindObject("/Script/Engine.Default__KismetMathLibrary")
        if not UKismetMathLibrary:IsValid() then
            UKismetMathLibrary = nil
        end
    end
end

RegisterHook("/Script/Engine.PlayerController:ClientRestart", function(Context, pawn)
    local pawnname = pawn:get():GetFullName()
    if pawnname:find("DefaultEmptyPawn_C") then-- trash when start game
        return
    elseif pawnname:find("Unit_Player_Wukong_C") then -- player
        PlayerController = Context:get()
        player=pawn:get()
        
    end
end)

-- RegisterHook("/Script/b1-Managed.BGUCharacterCS:PostInitializeComponentsCS", function(Context)
--     print(" ----------- ")
--     print(Context:get():GetFullName())
--     print(" ----------- ")
-- end)