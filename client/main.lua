--[[ ===================================================== ]]--
--[[        QBCore 3 in 1 AI EMS Script by MaDHouSe        ]]--
--[[ ===================================================== ]]--

local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local IsActive = false
local IsSpawning = true
local hasCalled = false
local playerVeh = nil
local job = nil
local jobVeh = nil
local jobPed = nil
local jobBlip = nil

local function CallAnimation()
    CreateThread(function()
	RequestAnimDict("random@arrests")
	TaskPlayAnim(PlayerPedId(), "random@arrests", "generic_radio_enter", 1.5, 2.0, -1, 50, 2.0, 0, 0, 0 )
	Wait(6000)
	ClearPedTasks(PlayerPedId())
    end)
end

local function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(5)
    end
end

local function PlayJobAnimation()
    SetVehicleUndriveable(playerVeh, true)
    SetVehicleDoorOpen(playerVeh, 4, false, false)
    TaskTurnPedToFaceCoord(jobPed, GetEntityCoords(playerVeh), -1)
    TaskStartScenarioInPlace(jobPed, Config.Ped[job].animation, 0, false)
end

local function DoVehicleDamage(vehicle, body, engine)
    local engine = engine + 0.0
    local body = body + 0.0
    if body < 100 then body = 100 end
    if engine < 100 then engine = 100 end
    if body < 900.0 then
	SmashVehicleWindow(vehicle, 0)
	SmashVehicleWindow(vehicle, 1)
	SmashVehicleWindow(vehicle, 2)
	SmashVehicleWindow(vehicle, 3)
	SmashVehicleWindow(vehicle, 4)
	SmashVehicleWindow(vehicle, 5)
	SmashVehicleWindow(vehicle, 6)
	SmashVehicleWindow(vehicle, 7)
    end
    if body < 800.0 then
	SetVehicleDoorBroken(vehicle, 0, true)
	SetVehicleDoorBroken(vehicle, 1, true)
	SetVehicleDoorBroken(vehicle, 2, true)
	SetVehicleDoorBroken(vehicle, 3, true)
	SetVehicleDoorBroken(vehicle, 4, true)
	SetVehicleDoorBroken(vehicle, 5, true)
	SetVehicleDoorBroken(vehicle, 6, true)
    end
    if engine < 700.0 then
	SetVehicleTyreBurst(vehicle, 1, false, 990.0)
	SetVehicleTyreBurst(vehicle, 2, false, 990.0)
	SetVehicleTyreBurst(vehicle, 3, false, 990.0)
	SetVehicleTyreBurst(vehicle, 4, false, 990.0)
    end
    if engine < 500.0 then
	SetVehicleTyreBurst(vehicle, 0, false, 990.0)
	SetVehicleTyreBurst(vehicle, 5, false, 990.0)
	SetVehicleTyreBurst(vehicle, 6, false, 990.0)
	SetVehicleTyreBurst(vehicle, 7, false, 990.0)
    end
    SetVehicleEngineHealth(vehicle, engine)
    SetVehicleBodyHealth(vehicle, body)
end

local function SetFuel(vehicle, fuel)
    if type(fuel) == 'number' and fuel >= 0 and fuel <= 100 then
        SetVehicleFuelLevel(vehicle, fuel + 0.0)
        DecorSetFloat(vehicle, "_FUEL_LEVEL", GetVehicleFuelLevel(vehicle))
    end
end

local function LeaveTarget()
    PlayAmbientSpeech1(jobPed, "THANKS", "SPEECH_PARAMS_FORCE_NORMAL")
    TaskVehicleDriveWander(jobPed, jobVeh, 17.0, Config.Ped[job].drivingStyle)
    SetEntityAsNoLongerNeeded(jobVeh)
    SetPedAsNoLongerNeeded(jobPed)
    RemoveBlip(jobBlip)
    PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData.job.name ~= "mechanic" then
	TriggerServerEvent('mh-aiems:server:PayJob', Config.Ped[job].price)
	if job == "towtruck" then
	    if playerVeh ~= nil then
		tmpVeh = playerVeh
		QBCore.Functions.Notify(Lang:t('notify.vehicle_is_teken', {amount = Config.Ped[job].price}), "success")
		TriggerServerEvent('mh-aiems:server:SaveBrokenVehicle', QBCore.Functions.GetPlate(playerVeh))
		Citizen.Wait(25000)
		if DoesEntityExist(tmpVeh) then
		    DeleteEntity(tmpVeh)
		end
		tmpVeh = nil
	    end
	elseif job == "mechanic" then
	    QBCore.Functions.Notify(Lang:t('notify.vehicle_is_restored', {amount = Config.Ped[job].price}), "success")
	elseif job == "ambulance" then
	    QBCore.Functions.Notify(Lang:t('notify.you_were_cared', {amount = Config.Ped[job].price}), "success")
	end
    end
    if PlayerData.job.name == "mechanic" then
	if job == "towtruck" then
	    if playerVeh ~= nil then
		tmpVeh = playerVeh
		TriggerServerEvent('mh-aiems:server:SaveBrokenVehicle', QBCore.Functions.GetPlate(playerVeh))
		Citizen.Wait(25000)
		if DoesEntityExist(tmpVeh) then
		    DeleteEntity(tmpVeh)
		end
		tmpVeh = nil
	    end
	end
    end
    -- reset
    IsActive = false
    IsSpawning = true
    hasCalled = false
    playerVeh = nil
    job = nil
    jobVeh = nil
    jobPed = nil
    jobBlip = nil
end

local function SpawnVehicle()
    IsSpawning = false
    local vehhash = GetHashKey(Config.Ped[job].vehicle)
    local loc = GetEntityCoords(PlayerPedId())
    RequestModel(vehhash)
    while not HasModelLoaded(vehhash) do Wait(1) end
    RequestModel(Config.Ped[job].pedModel)
    while not HasModelLoaded(Config.Ped[job].pedModel) do Wait(1) end
    local spawnRadius = Config.Ped[job].spawnRadius
    local found, spawnPos, spawnHeading = GetClosestVehicleNodeWithHeading(loc.x + math.random(-spawnRadius, spawnRadius), loc.y + math.random(-spawnRadius, spawnRadius), loc.z, 0, 3, 0)
    if not DoesEntityExist(vehhash) then
	jobVeh = CreateVehicle(vehhash, spawnPos, vehicleHeading, true, true)
	SetEntityHeading(jobVeh, vehicleHeading)
	ClearAreaOfVehicles(GetEntityCoords(jobVeh), 10000, false, false, false, false, false)
        SetVehicleOnGroundProperly(jobVeh)
	SetVehicleNumberPlateText(jobVeh, "AI-EMS")
	SetEntityAsMissionEntity(jobVeh, true, true)
	SetVehicleEngineOn(jobVeh, true, true, false)
        jobPed = CreatePedInsideVehicle(jobVeh, 26, GetHashKey(Config.Ped[job].pedModel), -1, true, false)
        jobBlip = AddBlipForEntity(jobVeh)
        SetBlipFlashes(jobBlip, true)
        SetBlipColour(jobBlip, 5)
	SetVehicleLights(jobVeh, 2)
	if job == "ambulance" then SetVehicleSiren(jobVeh, true) end
	PlaySoundFrontend(-1, "Text_Arrive_Tone", "Phone_SoundSet_Default", 1)
	Wait(2000)
	TaskVehicleDriveToCoord(jobPed, jobVeh, loc.x, loc.y, loc.z, 20.0, 0, GetEntityModel(jobVeh), Config.Ped[job].drivingStyle, 2.0)
	IsActive = true
    end
end

local function CheckIfICanPayTheBill()
    PlayerData = QBCore.Functions.GetPlayerData()
    if not hasCalled then
	hasCalled = true
	if PlayerData.job.name == "mechanic" then
	    if PlayerData.job.onduty then
		if job == "towtruck" then	
		    CallAnimation()
		    Wait(6000)
		    SpawnVehicle()
		end
	    else
		QBCore.Functions.Notify(Lang:t('notify.off_duty'), "error")
	    end
	elseif PlayerData.job.name ~= "mechanic" then
	    if job == "mechanic" or job == "towtruck" then
		QBCore.Functions.TriggerCallback('mh-aiems:server:isVehicleOwner', function(owned)
		    if owned then
			CallAnimation()
			QBCore.Functions.TriggerCallback('mh-aiems:server:CanIPayTheBill', function(canipay)
			    if canipay and IsSpawning then
				SpawnVehicle()
			    end
			end, Config.Ped[job].price)
		     else
			QBCore.Functions.Notify(Lang:t('notify.not_the_owner'), "error")
		     end
                end, QBCore.Functions.GetPlate(playerVeh))
	    elseif job == "ambulance" then
		CallAnimation()
		Wait(6000)
		QBCore.Functions.TriggerCallback('mh-aiems:server:CanIPayTheBill', function(canipay)
		    if canipay and IsSpawning then
			SpawnVehicle()
		    end
		end, Config.Ped[job].price)
	    end
	end
    end
end

-- AI Doctor Start
local function RequestDoctor()
    PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData.metadata['isdead'] or PlayerData.metadata['inlaststand'] then
	CheckIfICanPayTheBill()
    else
	QBCore.Functions.Notify(Lang:t('notify.only_when_badly_injured'), "error")
    end
end

local function DoctorNPC()
    RequestAnimDict("mini@cpr@char_a@cpr_str")
    while not HasAnimDictLoaded("mini@cpr@char_a@cpr_str") do
	Citizen.Wait(1000)
    end
    TaskPlayAnim(jobPed, "mini@cpr@char_a@cpr_str", Config.Ped[job].animation, 1.0, 1.0, -1, 9, 1.0, 0, 0, 0)
    QBCore.Functions.Progressbar("revive_doc", Lang:t('notify.job_is_helping', {job = Config.Ped[job].job}), Config.Ped[job].workTime, false, false, {
        disableMovement = false,
	disableCarMovement = false,
	disableMouse = false,
	disableCombat = true,
    }, {}, {}, {}, function() -- Done
	ClearPedTasks(jobPed)
	Citizen.Wait(500)
        TriggerEvent("hospital:client:Revive")
	StopScreenEffect('DeathFailOut')
	Citizen.Wait(5000)
	LeaveTarget()
	IsSpawning = true
    end)
end
-- AI Doctor End

-- AI Mechanic Start
local function RequestMechanic()
    CheckIfICanPayTheBill()
end

local function MechanicNPC()
    PlayJobAnimation(Config.Ped[job].job)
    QBCore.Functions.Progressbar("mechanic", Lang:t('notify.job_is_helping', {job = Config.Ped[job].job}), Config.Ped[job].workTime, false, false, {
	disableMovement = false,
	disableCarMovement = false,
	disableMouse = false,
	disableCombat = true,
    }, {}, {}, {}, function() -- Done
	ClearPedTasks(jobPed)
	SetVehicleDoorShut(playerVeh, 4, false, false)
	Citizen.Wait(1000)
	SetVehicleFixed(playerVeh)
	SetVehicleEngineHealth(playerVeh, 1000.0)
	SetVehicleBodyHealth(playerVeh, 1000.0)
	SetVehicleOnGroundProperly(playerVeh)
	SetVehicleUndriveable(playerVeh, false)
	Citizen.Wait(5000)
	LeaveTarget()
	IsSpawning = true
    end)
end
-- AI Mechanic End

-- AI Towtruck Start
local function RequestTowtruck()
    CheckIfICanPayTheBill()
end

local function TowtruckNPC()
    PlayJobAnimation(Config.Ped[job].job)
    QBCore.Functions.Progressbar("towtruck", Lang:t('notify.job_is_helping', {job = Config.Ped[job].job}), Config.Ped[job].workTime, false, false, {
	disableMovement = false,
	disableCarMovement = false,
	disableMouse = false,
	disableCombat = true,
    }, {}, {}, {}, function() -- Done
	ClearPedTasks(jobPed)
	SetVehicleDoorShut(playerVeh, 4, false, false)
	AttachEntityToEntity(playerVeh, jobVeh, 20, Config.Ped[job].offset.x, Config.Ped[job].offset.y, Config.Ped['towtruck'].offset.z, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
	Citizen.Wait(5000)
	SetVehicleDoorsShut(jobVeh, false)
	TaskVehicleDriveWander(jobPed, jobVeh, 17.0, Config.Ped[job].drivingStyle)
	SetEntityAsNoLongerNeeded(playerVeh)
	SetEntityAsNoLongerNeeded(jobVeh)
	SetPedAsNoLongerNeeded(jobPed)
	SetVehicleUndriveable(playerVeh, false)
	LeaveTarget()
	IsSpawning = true
    end)
end
-- AI Towtruck End

-- Mechanic Job Start
local function TakeOutVehicle(data)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    local tmpLocation = vector3(coords.x, coords.y, coords.z)
    if tmpLocation then
        if not QBCore.Functions.SpawnClear(tmpLocation, 5.0) then
            QBCore.Functions.Notify(Lang:t('notify.area_is_obstructed'), 'error', 5000)
            return
        else
            QBCore.Functions.SpawnVehicle(data.vehicle, function(veh)
                QBCore.Functions.TriggerCallback("mh-aiems:server:GetVehicleProperties", function(properties)
                    QBCore.Functions.SetVehicleProperties(veh, properties)
                    SetVehicleNumberPlateText(veh, data.plate)
                    SetEntityHeading(veh, heading)
                    SetVehRadioStation(veh,'OFF')
                    SetVehicleDirtLevel(veh, 0)
                    SetVehicleDoorsLocked(veh, 0)
                    SetEntityAsMissionEntity(veh, true, true)
		    TaskWarpPedIntoVehicle(playerPed, veh, -1)
                    DoVehicleDamage(veh, data.body, data.engine)
                    SetFuel(veh, data.fuel)
                    TriggerServerEvent(Config.KeyScriptTrigger, data.plate)
		    TriggerServerEvent('mh-aiems:server:DeleteBrokenVehicle', data.plate)
                    exports['qb-menu']:closeMenu()
                end, data.plate)
            end, tmpLocation, true)
        end
    end
end

local function CheckPlayers(vehicle)
    for i = -1, 5,1 do
	if GetPedInVehicleSeat(vehicle, i) ~= 0 then
            local seat = GetPedInVehicleSeat(vehicle, i)
            TaskLeaveVehicle(seat, vehicle, 0)
            SetVehicleDoorsLocked(vehicle)
        end
    end
end

local function StoreCar()
    local veh = GetVehiclePedIsIn(PlayerPedId())
    local plate = QBCore.Functions.GetPlate(veh)
    SetVehicleEngineOn(veh, false, false, true)
    CheckPlayers(veh)
    Wait(1500)
    RequestAnimSet("anim@mp_player_intmenu@key_fob@")
    TaskPlayAnim(PlayerPedId(), 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3.0, 3.0, -1, 49, 0, false, false)
    Wait(500)
    ClearPedTasks(PlayerPedId())
    SetVehicleLights(veh, 2)
    Wait(150)
    SetVehicleLights(veh, 0)
    Wait(150)
    SetVehicleLights(veh, 2)
    Wait(150)
    SetVehicleLights(veh, 0)
    TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, "lock", 0.3)
    Wait(1000)
    TriggerServerEvent('mh-aiems:server:SaveBrokenVehicle', plate)
    QBCore.Functions.DeleteVehicle(veh)
    DeleteVehicle(veh)
end

RegisterNetEvent('mh-aiems:client:takeOutVehicle', function(data)
    if not IsPedInAnyVehicle(PlayerPedId()) then
        TakeOutVehicle(data)
    else
        QBCore.Functions.Notify(Lang:t('notify.is_in_vehicle'), "error")
    end
end)

RegisterNetEvent('mh-aiems:client:storeVehicle', function(data)
    StoreCar()
end)

RegisterNetEvent('mh-aiems:client:FixVehicle', function(data)
    PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData.job.name == "mechanic" then
	if IsPedInAnyVehicle(PlayerPedId()) then
	    local tmpVeh = GetVehiclePedIsIn(PlayerPedId())
	    loadAnimDict("mp_car_bomb")
    	    TaskPlayAnim(PlayerPedId(), "mp_car_bomb", "car_bomb_mechanic" ,3.0, 3.0, -1, 16, 0, false, false, false)
	    QBCore.Functions.Progressbar("repair_advanced", "Repair Vehicle", Config.Ped['mechanic'].workTime, false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	    }, {}, {}, function() -- Done
		ClearPedTasks(PlayerPedId())
		Citizen.Wait(5000)
		SetVehicleFixed(tmpVeh)
		SetVehicleEngineHealth(tmpVeh, 1000.0)
		SetVehicleBodyHealth(tmpVeh, 1000.0)
		SetVehicleOnGroundProperly(tmpVeh)
		SetVehicleUndriveable(tmpVeh, false)
		TriggerServerEvent('mh-aiems:server:FixVehicle', QBCore.Functions.GetPlate(tmpVeh))
	    end)
	end
    else
	QBCore.Functions.Notify(Lang:t('notify.not_a_mechanic'), "error")
    end
end)

RegisterNetEvent('mh-aiems:client:getBrokenVehicles', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData.job.name == "mechanic" and PlayerData.job.onduty then
	QBCore.Functions.TriggerCallback("mh-aiems:server:GetBrokenVehicles", function(vehicles)
	    local categoryMenu = {
		{
		    header = Lang:t('menu.header_menu'),
		    isMenuHeader = true
		}
	    }
	    if vehicles ~= nil then
		for k, vehicle in pairs(vehicles) do
		    local enginePercent = QBCore.Shared.Round(vehicle.engine / 10, 0)
		    local bodyPercent = QBCore.Shared.Round(vehicle.body / 10, 0)
		    local currentFuel = vehicle.fuel
		    categoryMenu[#categoryMenu + 1] = {
			header = vehicle.vehicle,
			txt = Lang:t('vehicle.plate', {plate = vehicle.plate})..Lang:t('vehicle.fuel',{fuel = currentFuel})..Lang:t('vehicle.engine',{engine = enginePercent})..Lang:t('vehicle.body',{ body = bodyPercent}),
			params = {
			    event = 'mh-aiems:client:takeOutVehicle',
			    args = {
				vehicle = vehicle.vehicle,
				plate = vehicle.plate,
				fuel = vehicle.fuel,
				body = vehicle.body,
				engine = vehicle.engine,
			    }
			},
		    }
		end
	    end
	    if IsPedInAnyVehicle(PlayerPedId()) then
		categoryMenu[#categoryMenu + 1] = {
		    header = Lang:t('menu.store'),
		    params = {
			event = 'mh-aiems:client:storeVehicle',
			args = {}
		    },
		}
	    end
	    categoryMenu[#categoryMenu + 1] = {
		header = Lang:t('menu.close_menu'),
		params = {event = ''}
	    }
	    exports['qb-menu']:openMenu(categoryMenu)
	end)
    else
	QBCore.Functions.Notify(Lang:t('notify.not_a_mechanic'), "error")
    end
end)
-- Mechanic Job End

RegisterNetEvent("mh-aiems:client:callambulance", function(source)
    if not jobVeh then
	job = "ambulance"
	RequestDoctor()
    else
	QBCore.Functions.Notify(Lang:t('notify.services_is_use'), "error")
    end
end)

RegisterNetEvent("mh-aiems:client:callmechanic", function(source)
    if not jobVeh then
	playerVeh, _ = QBCore.Functions.GetClosestVehicle(GetEntityCoords(PlayerPedId()))
	local engine = GetVehicleEngineHealth(playerVeh)
	job = "mechanic"
	SetVehicleUndriveable(playerVeh, true)
	if engine > Config.MinDamageToUseTowTruck then
	    RequestMechanic()
	    QBCore.Functions.Notify(Lang:t('notify.vehicle_can_drive'), "success")
	else
	    job = "towtruck"
	    RequestTowtruck()
	    QBCore.Functions.Notify(Lang:t('notify.vehicle_unable_to_drive'), "success")
	end
    else
	QBCore.Functions.Notify(Lang:t('notify.services_is_use'), "error")
    end
end)

RegisterNetEvent("mh-aiems:client:calltowtruck", function(source)
    if not jobVeh then
	playerVeh, _ = QBCore.Functions.GetClosestVehicle(GetEntityCoords(PlayerPedId()))
	--local engine = GetVehicleEngineHealth(playerVeh)
	job = "towtruck"
	SetVehicleUndriveable(playerVeh, true)
	--if engine <= Config.MinDamageToUseTowTruck then
	    RequestTowtruck()
	    QBCore.Functions.Notify(Lang:t('notify.vehicle_unable_to_drive'), "success")
	--else
	--	job = "mechanic"
	--	RequestMechanic()
	--	QBCore.Functions.Notify(Lang:t('notify.vehicle_can_drive'), "success")
	--end
    else
	QBCore.Functions.Notify(Lang:t('notify.services_is_use'), "error")
    end
end)

Citizen.CreateThread(function()
    while true do
      Citizen.Wait(100)
        if IsActive then
            local loc = GetEntityCoords(GetPlayerPed(-1))
	    local ld = GetEntityCoords(jobPed)
	    local lc = GetEntityCoords(jobVeh)
            local dist = #(vector3(loc.x, loc.y, loc.z) - vector3(lc.x, lc.y, lc.z))
	    local dist1 = #(vector3(loc.x, loc.y, loc.z) - vector3(ld.x, ld.y, ld.z))
            if dist <= 15 then
		if IsActive then
		    if job == "mechanic" or job == "towtruck" then
			local engine = GetWorldPositionOfEntityBone(playerVeh, GetEntityBoneIndexByName(playerVeh, Config.Ped[job].bone))
			TaskGoToCoordAnyMeans(jobPed, engine, 2.0, 0, 0, Config.Ped[job].walkStyle, 0xbf800000)
			dist1 = #(vector3(engine.x, engine.y, engine.z) - vector3(ld.x, ld.y, ld.z))
		    end
		    if job == "ambulance" then
			SetVehicleSiren(jobVeh, false)
			TaskGoToCoordAnyMeans(jobPed, loc, 1.0, 0, 0, Config.Ped[job].walkStyle, 0xbf800000)
		    end
		end
		if dist1 <= 2.5 then
		    if job == "ambulance" then
			DoctorNPC()
		    elseif job == "mechanic" then
			MechanicNPC()
		    elseif job == "towtruck" then
		        TowtruckNPC()
		    end
		    IsActive = false
		    ClearPedTasksImmediately(jobPed)
		end
            end
	end
    end
end)
