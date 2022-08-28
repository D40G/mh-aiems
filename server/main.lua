--[[ ===================================================== ]]--
--[[            QBCore AI EMS Script by MaDHouSe           ]]--
--[[ ===================================================== ]]--

local QBCore = exports['qb-core']:GetCoreObject()

local function GetPlayerInfo(target)
	local info = {
		source = target.PlayerData.source,
		citizenid = target.PlayerData.citizenid,
		firstname = target.PlayerData.charinfo.firstname,
		lastname = target.PlayerData.charinfo.lastname,
		fullname = target.PlayerData.charinfo.firstname .." "..target.PlayerData.charinfo.lastname,
	}
	return info
end

QBCore.Functions.CreateCallback('mh-aiems:server:CanIPayTheBill', function(source, cb, price)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local canpay = false
	if Player.PlayerData.money["cash"] >= price then
		canpay = true
	else
		if Player.PlayerData.money["bank"] >= price then
			canpay = true
		end
	end
	cb(canpay)
end)

RegisterServerEvent('mh-aiems:server:PayJob', function(price)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	if Player.PlayerData.money["cash"] >= price then
		Player.Functions.RemoveMoney("cash", price)
	else
		Player.Functions.RemoveMoney("bank", price)
	end
end)

QBCore.Commands.Add('callai', Lang:t('command.callinfo'), {{id='name', help='ambulance|mechanic|towtruck'}}, true, function(source, args)
	local src = source
	if args[1] then
		job = tostring(args[1])
		if job == 'ambulance' or job == 'mechanic' or job == 'towtruck' then
			local online = QBCore.Functions.GetDutyCount(job)
			if online >= 1 then
				TriggerClientEvent('QBCore:Notify', id, Lang:t('notify.to_much_ems_online'), "error", 10000)
			else
				TriggerClientEvent('mh-aiems:client:call'..job..'', src)
			end
		end
	end
end, 'user')

QBCore.Functions.CreateCallback('mh-aiems:server:isVehicleOwner', function(source, cb, plate)
    local src = source
	local player = GetPlayerInfo(QBCore.Functions.GetPlayer(src))
    MySQL.Async.fetchAll('SELECT * FROM player_vehicles WHERE plate = ? AND citizenid = ?', {
		plate, player.citizenid
	}, function(result)
		if result[1] ~= nil then
			cb(true)
		else
			cb(false)
		end
	end)
end)

QBCore.Functions.CreateCallback("mh-aiems:server:GetVehicleProperties", function(source, cb, plate)
    local properties = {}
    local result = MySQL.query.await('SELECT mods FROM player_vehicles WHERE plate = ? LIMIT 1', {plate})
    if result[1] ~= nil then
        properties = json.decode(result[1].mods)
    end
    cb(properties)
end)

RegisterServerEvent('mh-aiems:server:SaveBrokenVehicle', function(plate)
	MySQL.Async.fetchAll("SELECT * FROM player_vehicles WHERE state = 0 AND plate = ? LIMIT 1", {plate}, function(rs)
		if type(rs) == 'table' and #rs > 0 and rs[1] then
			target = QBCore.Functions.GetPlayerByCitizenId(rs[1].citizenid)
			MySQL.Async.execute("INSERT INTO broken_player_vehicles (plate, citizenid, vehicle, hash, mods) VALUES (?, ?, ?, ?, ?)", {rs[1].plate, rs[1].citizenid, rs[1].vehicle, rs[1].hash, rs[1].mods})
			MySQL.Async.execute('UPDATE player_vehicles SET state = 4, body = 0, engine = 0 WHERE plate = ?', {plate})
		end
	end)
end)

RegisterServerEvent('mh-aiems:server:FixVehicle', function(plate)
	local src = source
	MySQL.Async.fetchAll("SELECT * FROM player_vehicles WHERE state = 0 AND plate = ? LIMIT 1", {plate}, function(rs)
		if type(rs) == 'table' and #rs > 0 and rs[1] then
			target = QBCore.Functions.GetPlayerByCitizenId(rs[1].citizenid)
			MySQL.Async.execute('UPDATE player_vehicles SET body = 1000.0, engine = 1000.0 WHERE plate = ?', {plate})
			TriggerClientEvent('QBCore:Notify', src, "You fixed this vehicle you get $"..Config.Ped['mechanic'].price, "success")
			TriggerClientEvent('QBCore:Notify', target.citizenid, Lang:t('notify.vehicle_is_restored', {amount = Config.Ped['mechanic'].price}), "success")
		end
	end)
end)

RegisterServerEvent('mh-aiems:server:DeleteBrokenVehicle', function(plate)
	MySQL.Async.execute('DELETE FROM broken_player_vehicles WHERE plate = ? LIMIT 1', {plate})
	MySQL.Async.execute('UPDATE player_vehicles SET state = 0 WHERE plate = ?', {plate})
end)

QBCore.Functions.CreateCallback("mh-aiems:server:GetBrokenVehicles", function(source, cb)
    MySQL.Async.fetchAll('SELECT * FROM player_vehicles WHERE state = ?', {4}, function(result)
		if result[1] ~= nil then
			cb(result)
		else
			cb(nil)
		end
	end)
end)
