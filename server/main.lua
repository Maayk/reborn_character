-- RebornCore = nil
-- TriggerEvent('RebornCore:GetObject', function(obj) RebornCore = obj end)

RegisterServerEvent('cash-multiplecharacters:server:disconnect')
AddEventHandler('cash-multiplecharacters:server:disconnect', function()
    local src = source

    DropPlayer(src, "Você foi desconectado")
end)

function dump(t, indent, done)
    done = done or {}
    indent = indent or 0

    done[t] = true

    for key, value in pairs(t) do
        print(string.rep("\t", indent))

        if (type(value) == "table" and not done[value]) then
            done[value] = true
            print(key, ":\n")

            dump(value, indent + 2, done)
            done[value] = nil
        else
            print(key, "\t=\t", value, "\n")
        end
    end
end

RegisterServerEvent('cash-multiplecharacters:server:loadUserData')
AddEventHandler('cash-multiplecharacters:server:loadUserData', function(cData)
    local src = source

    if RebornCore.Player.Login(src, cData.citizenid) then
        -- print('passou aqui ?')
        print('^5[reborn_core]^7 '..GetPlayerName(src)..' (RG: '..cData.citizenid..') carregado com sucesso!')
        RebornCore.Commands.Refresh(src)
        loadHouseData()
        
        TriggerClientEvent('apartments:client:setupSpawnUI', src, cData)
        TriggerEvent("Reborn:Servidor:SendLogs", cData.citizenid, "characterloaded", {})
        TriggerEvent("Reborn:Logs:EnviandoLogs", "server-personagens", "Entrando no Personagem", "green", "**".. GetPlayerName(src) .. "** ("..cData.citizenid.." | "..src..") Carregado..",nil,"server-personagens")
        -- print(cData.metadata["vida"])
    end
end)
--xD
RegisterServerEvent('cash-multiplecharacters:server:createCharacter')
AddEventHandler('cash-multiplecharacters:server:createCharacter', function(data)
    local src = source
    local newData = {}
    newData.cid = data.cid
    newData.charinfo = data
    if RebornCore.Player.Login(src, false, newData) then
        print('^5[reborn_core]^7 '..GetPlayerName(src)..' Criando novo Personagem!')
        RebornCore.Commands.Refresh(src)
        loadHouseData()

        TriggerClientEvent("cash-multiplecharacters:client:closeNUI", src)
        TriggerClientEvent('apartments:client:setupSpawnUI', src, newData)
        GiveStarterItems(src)
	end
end)

function GiveStarterItems(source)
    local src = source
    local Player = RebornCore.Functions.GetPlayer(src)

    for k, v in pairs(RebornCore.Shared.StarterItems) do
        local info = {}
        if v.item == "id_card" then
            info.citizenid = Player.PlayerData.citizenid
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.gender = Player.PlayerData.charinfo.gender
            info.nationality = Player.PlayerData.charinfo.nationality
        elseif v.item == "driver_license" then
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.type = "A1-A2-A | AM-B | C1-C-CE"
        end
        Player.Functions.AddItem(v.item, 1, false, info)
    end
end

RegisterServerEvent('cash-multiplecharacters:server:deleteCharacter')
AddEventHandler('cash-multiplecharacters:server:deleteCharacter', function(citizenid)
    local src = source
    RebornCore.Player.DeleteCharacter(src, citizenid)
end)

RebornCore.Functions.CreateCallback("cash-multiplecharacters:server:GetUserCharacters", function(source, cb)
    local license = RebornCore.Functions.GetIdentifier(source, 'license')

    exports['ghmattimysql']:execute('SELECT * FROM players WHERE license=@license', {['@license'] = license}, function(result)
        cb(result)
    end)
end)

RebornCore.Functions.CreateCallback("cash-multiplecharacters:server:GetServerLogs", function(source, cb)
    exports['ghmattimysql']:execute('SELECT * FROM server_logs', function(result)
        cb(result)
    end)
end)

RebornCore.Functions.CreateCallback("Reborn:Setup:Persoangens", function(source, cb)
    local license = RebornCore.Functions.GetIdentifier(source, 'license')
    -- local license = RebornCore.Functions.GetIdentifier(source, 'license')
    local plyChars = {}
    
    exports['ghmattimysql']:execute('SELECT * FROM players WHERE license = @license', {['@license'] = license}, function(result)
        for i = 1, (#result), 1 do
            result[i].charinfo = json.decode(result[i].charinfo)
            result[i].money = json.decode(result[i].money)
            result[i].job = json.decode(result[i].job)
            result[i].metadata = json.decode(result[i].metadata)

            table.insert(plyChars, result[i])
        end
        cb(plyChars)
    end)

    -- exports['ghmattimysql']:execute('SELECT * FROM players WHERE steam = @steam', {['@steam'] = steamId}, function(result)
    --     for i = 1, (#result), 1 do
    --         result[i].charinfo = json.decode(result[i].charinfo)
    --         result[i].money = json.decode(result[i].money)
    --         result[i].job = json.decode(result[i].job)
    --         result[i].metadata = json.decode(result[i].metadata)
    --         --aqui
    --         table.insert(plyChars, result[i])
    --     end
    --     cb(plyChars)
    -- end)
end)

RebornCore.Functions.CreateCallback("reborn:check:vip:type", function(source, cb)
    local license = RebornCore.Functions.GetIdentifier(source, 'license')

    exports['ghmattimysql']:execute('SELECT * FROM whitelist WHERE license = @license', {['@license'] = license}, function(result)
        if result[1] ~= nil then
            -- print('[server] tipo de vip: '..result[1].tipoconta)
            TriggerEvent("Reborn:Logs:EnviandoLogs", "server-personagens", "Loadando Conta", "green", "Nome: ".. GetPlayerName(source) .. " - Tipo de conta: "..result[1].tipoconta,nil,"server-personagens")
            cb(result[1].tipoconta)
        end
    end)
end)

-- xD
-- RebornCore.Commands.Add("char", "Give the character menu to the player", {{name="id", help="Player ID"}}, false, function(source, args)
--     TriggerClientEvent('cash-multiplecharacters:client:chooseChar', source)
-- end, "admin")

RebornCore.Commands.Add("closeNUI", "Give an item to a player", {{name="id", help="Player ID"},{name="item", help="Name of the item (no label)"}, {name="amount", help="Number of items"}}, false, function(source, args)
    TriggerClientEvent('cash-multiplecharacters:client:closeNUI', source)
end)

RebornCore.Functions.CreateCallback("cash-multiplecharacters:server:getSkin", function(source, cb, cid)
    local src = source

    RebornCore.Functions.ExecuteSql(false, "SELECT * FROM `playerskins` WHERE `citizenid` = '"..cid.."' AND `active` = 1", function(result)
        if result[1] ~= nil then
            cb(result[1].model, result[1].skin)
        else
            cb(nil)
        end
    end)
end)

function loadHouseData()
    local HouseGarages = {}
    local Houses = {}
    local result = exports.ghmattimysql:executeSync('SELECT * FROM houselocations')
	-- RebornCore.Functions.ExecuteSql(false, "SELECT * FROM `houselocations`", function(result)   Linha antiga antes da atualização
		if result[1] ~= nil then
			for k, v in pairs(result) do
				local owned = false
				if tonumber(v.owned) == 1 then
					owned = true
				end
				local garage = v.garage ~= nil and json.decode(v.garage) or {}
				Houses[v.name] = {
					coords = json.decode(v.coords),
					owned = v.owned,
					price = v.price,
					locked = true,
					adress = v.label, 
					tier = v.tier,
					garage = garage,
					decorations = {},
				}
				HouseGarages[v.name] = {
					label = v.label,
					takeVehicle = garage,
				}
			end
		end
		TriggerClientEvent("cash-garagesystem:client:houseGarageConfig", -1, HouseGarages)
		TriggerClientEvent("cash-playerhousing:client:setHouseConfig", -1, Houses)
end