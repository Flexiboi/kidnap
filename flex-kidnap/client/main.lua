local KidnapZones = {}
local Peds, PedTargets = {}, {}
local KidnapMode, KidnapFollowMode, InScene, IsKidnapping, IsKidnappedSurrender = false, false, false, false, false
local CurrentGuardPed, KidnappedPed, CurrentVan = nil, nil, nil

function RegisterPed(coords, model, scenario)
    local current = type(model) == 'number' and model or joaat(model)
    RequestModel(current)
    while not HasModelLoaded(current) do Wait(0) end
    Peds[#Peds+1] = CreatePed(0, current, coords.x, coords.y, coords.z - 1, coords.w, true, true)
    if scenario then
        TaskStartScenarioInPlace(Peds[#Peds], scenario, 0, true)
    end
    FreezeEntityPosition(Peds[#Peds], true)
    SetEntityInvincible(Peds[#Peds], true)
    SetBlockingOfNonTemporaryEvents(Peds[#Peds], true)
    return Peds[#Peds]
end

CreateThread(function()
    for k, v in pairs(C_Config.KidnapZones) do
        KidnapZones[k] = PolyZone:Create(v, {
            name = "KidnapZones_"..k,
            useZ = true,
            debugPoly = C_Config.Debug
        })
        KidnapZones[k]:onPlayerInOut(function(isPointInside)
            if isPointInside then
                exports.ox_target:addGlobalPed({
                    {
                        name = Lang:t('target.kidnap'),
                        icon = 'fas fa-shopping-basket',
                        label = Lang:t('target.kidnap'),
                        onSelect = function(data)
                            local ped = PlayerPedId()
                            local coords = GetEntityCoords(ped)
                            CurrentVan = GetClosestVehicle(coords.x, coords.y, coords.z, 10.0, joaat('burrito'), 70)
                            if not IsEntityAPed(data.entity) then return end
                            KidnappedPed = data.entity
                            if DoesEntityExist(CurrentVan) and KidnappedPed and CurrentGuardPed then
                                InScene = true
                                ClearPedTasks(CurrentGuardPed)
                                ClearPedTasks(KidnappedPed)
                                local targetPosition, targetRotation = GetEntityCoords(CurrentVan), GetEntityRotation(CurrentVan)
                                local KidnapScene = NetworkCreateSynchronisedScene(targetPosition, targetRotation, 2, false, false, 1065353216, 0, 1.0)
                                local AnimDic = 'random@kidnap_girl'
                                NetworkAddPedToSynchronisedScene(ped, KidnapScene, AnimDic, "ig_1_guy1_drag_into_van", 1.5, -4.0, 1, 16, 1148846080, 0)
                                NetworkAddPedToSynchronisedScene(CurrentGuardPed, KidnapScene, AnimDic, "ig_1_guy2_drag_into_van", 1.5, -4.0, 1, 16, 1148846080, 0)
                                NetworkAddPedToSynchronisedScene(KidnappedPed, KidnapScene, AnimDic, "ig_1_girl_drag_into_van", 1.5, -4.0, 1, 16, 1148846080, 0)
                                NetworkAddEntityToSynchronisedScene(CurrentVan, KidnapScene, AnimDic, "drag_into_van_burr", 1.0, 1.0, 1)
            
                                NetworkStartSynchronisedScene(KidnapScene)
                                Wait(GetAnimDuration(AnimDic, "drag_into_van_burr")*750)
                                TaskWarpPedIntoVehicle(ped, CurrentVan, -1)
                                TaskWarpPedIntoVehicle(CurrentGuardPed, CurrentVan, 0)
                                TaskWarpPedIntoVehicle(KidnappedPed, CurrentVan, 1)
                                InScene = false
                                IsKidnapping = true
                                local Aiming = true
                                local CurrentKidnapCoords = GetEntityCoords(KidnappedPed)
                                DisablePlayerFiring(ped, true)
                                CreateThread(function()
                                    while Aiming do
                                        Wait(1000)
                                        local ped = PlayerPedId()
                                        local coords = GetEntityCoords(ped)
                                        local hasWeapon, currentWeapon = GetCurrentPedWeapon(ped, true)
                                        local IsAiming, targetPed = GetEntityPlayerIsFreeAimingAt(PlayerId())
                                        if IsPedInAnyVehicle(KidnappedPed, false) then
                                            if IsAiming and hasWeapon and currentWeapon and GetSelectedPedWeapon(ped) ~= `WEAPON_UNARMED` then
                                                if DoesEntityExist(targetPed) and targetPed == KidnappedPed then
                                                    if #(coords - CurrentKidnapCoords) > 100 and #(GetEntityCoords(KidnappedPed).xyz - GetEntityCoords(CurrentVan).xyz) < 5 then
                                                        TaskLeaveVehicle(KidnappedPed, GetVehiclePedIsIn(KidnappedPed, 0), 0)
                                                        Wait(3000)
                                                        ClearPedTasks(KidnappedPed)
                                                        SetPedFleeAttributes(KidnappedPed, 0, 0)
                                                        SetBlockingOfNonTemporaryEvents(KidnappedPed, true)
                                                        KidnapFollowMode = true
                                                        CreateThread(function()
                                                            while KidnapFollowMode do
                                                                if not IsPedInAnyVehicle(KidnappedPed, false) then
                                                                    if IsPedInAnyVehicle(ped, false) or GetVehiclePedIsTryingToEnter(ped) then
                                                                        local veh = GetVehiclePedIsIn(ped, 0)
                                                                        local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(veh)
                                                                        TaskEnterVehicle(KidnappedPed, veh, -1, freeSeat, 1.0, 0)
                                                                    end
                                                                end
                                                                if not IsPedInAnyVehicle(player, false) then
                                                                    TaskGoToEntity(KidnappedPed, ped, -1, 1.0, 10.0, 1073741824.0, 0)
                                                                end
                                                                Wait(1000)
                                                            end
                                                        end)
                                                    end
                                               
                                                end
                                            end
                                        else
                                            if IsAiming and hasWeapon and currentWeapon and GetSelectedPedWeapon(ped) ~= `WEAPON_UNARMED` then
                                                if #(GetEntityCoords(KidnappedPed).xyz - GetEntityCoords(CurrentVan).xyz) > 5 then
                                                    if not IsEntityPlayingAnim(KidnappedPed, 'random@arrests@busted', 'idle_a', 3) and not IsPedInAnyVehicle(KidnappedPed, false) then
                                                        if hasWeapon and currentWeapon and GetSelectedPedWeapon(ped) ~= `WEAPON_UNARMED` then
                                                            IsKidnappedSurrender = true
                                                            KidnapFollowMode = false
                                                            SetPedFleeAttributes(KidnappedPed, 0, 0)
                                                            ClearPedTasks(KidnappedPed)
                                                            FreezeEntityPosition(KidnappedPed, true)
                                                            Wait(1000)
                                                            lib.playAnim(KidnappedPed, 'random@arrests@busted', 'idle_a', 1.0, 1.0, -1, 1, 0, false, false, false)
                                                            CreateThread(function()
                                                                while IsKidnappedSurrender do 
                                                                    Wait(1000)
                                                                    if GetEntityHealth(KidnappedPed) < 10 then
                                                                        SetEntityAsMissionEntity(KidnappedPed, true, true)
                                                                        SetPedFleeAttributes(CurrentGuardPed, 1, true)
                                                                        TaskReactAndFleePed(CurrentGuardPed, KidnappedPed)
                                                                        KidnapMode, KidnapFollowMode, InScene, IsKidnapping, IsKidnappedSurrender = false, false, false, false, false
                                                                        CurrentGuardPed, KidnappedPed, CurrentVan = nil, nil, nil
                                                                        DisablePlayerFiring(ped, false)
                                                                    end
                                                                end
                                                            end)
                                                        else
                                                            print('need weapon')
                                                        end
                                                    else
                                                        GiveWeaponToPed(CurrentGuardPed, GetHashKey("WEAPON_SNSPISTOL"), 100, false, true)
                                                        SetCurrentPedWeapon(CurrentGuardPed, GetHashKey("WEAPON_SNSPISTOL"), true)
                                                        Wait(1000)
                                                        SetPedCombatAttributes(CurrentGuardPed, 46, true) -- Make sure NPC engages in combat
                                                        SetPedCombatAbility(CurrentGuardPed, 100) -- High combat skill
                                                        SetPedCombatRange(CurrentGuardPed, 2) -- Medium range attack
                                                        SetPedAlertness(CurrentGuardPed, 3) -- High alert
                                                        SetPedAccuracy(CurrentGuardPed, 75) -- Decent aim
                                                        Wait(1000)
                                                        local hasWeapon, currentWeapon = GetCurrentPedWeapon(CurrentGuardPed, true)
                                                        if hasWeapon and currentWeapon and GetSelectedPedWeapon(CurrentGuardPed) ~= `WEAPON_UNARMED` then
                                                            Citizen.CreateThread(function()
                                                                while GetEntityHealth(KidnappedPed) > 0 and DoesEntityExist(CurrentGuardPed) and DoesEntityExist(KidnappedPed) and not IsPedDeadOrDying(KidnappedPed, true) do
                                                                    TaskShootAtEntity(CurrentGuardPed, KidnappedPed, 200, "FIRING_PATTERN_FULL_AUTO")
                                                                    Wait(200)
                                                                end
                                                            end)
                                                        else
                                                            print('need weapon')
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end)
                            end
                        end,
                        canInteract = function(entity, coords, distance)
                            return KidnapMode and CurrentGuardPed and not IsKidnapping and (entity ~= CurrentGuardPed)
                        end,
                        distance = 5.0
                    },
                })
            else
                exports.ox_target:removeGlobalPed(Lang:t('target.kidnap'))
            end
        end)
    end

    for k, v in pairs(C_Config.Peds) do
        local ped = RegisterPed(v, C_Config.Models[math.random(1, #C_Config.Models)], C_Config.Scenarios[math.random(1, #C_Config.Scenarios)])
        PedTargets[#PedTargets + 1] = exports.ox_target:addLocalEntity(ped, {
            {
                name = Lang:t('target.recruit')..k,
                icon = 'fas fa-shopping-basket',
                label = Lang:t('target.recruit'),
                onSelect = function()
                    FreezeEntityPosition(ped, false)
                    KidnapMode = true
                    CurrentGuardPed = ped
                    local player = PlayerPedId()
                    SetPedKeepTask(ped, true)
                    CreateThread(function()
                        while KidnapMode do
                            if not InScene then
                                if not IsPedInAnyVehicle(ped, false) then
                                    if IsPedInAnyVehicle(player, false) or GetVehiclePedIsTryingToEnter(player) then
                                        local veh = GetVehiclePedIsIn(player, 0)
                                        local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(veh)
                                        TaskEnterVehicle(ped, veh, -1, freeSeat, 1.0, 0)
                                    end
                                end
                                if not IsPedInAnyVehicle(player, false) then
                                    TaskGoToEntity(ped, player, -1, 1.0, 10.0, 1073741824.0, 0)
                                end
                            end
                            Wait(1000)
                        end
                    end)
                end,
                canInteract = function(entity, coords, distance)
                    return not KidnapMode
                end,
                distance = 2
            },
        })
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for k, v in pairs(PedTargets) do
            exports.ox_target:removeLocalEntity(v)
        end
        if KidnappedPed then
            exports.ox_target:removeLocalEntity(KidnappedPed)
        end
        exports.ox_target:removeGlobalPed(Lang:t('target.kidnap'))
        for k, v in pairs(Peds) do
            if DoesEntityExist(v) then 
                DeleteEntity(v) 
            end
        end
    end
end)