-- RebornCore = nil

local charPed = nil

-- Citizen.CreateThread(function() 
--     while true do
--         Citizen.Wait(10)
--         if RebornCore == nil then
--             TriggerEvent("RebornCore:GetObject", function(obj) RebornCore = obj end)    
--             Citizen.Wait(200)
--         end
--     end
-- end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
        if NetworkIsSessionStarted() then
            TriggerEvent('cash-multiplecharacters:client:chooseChar')
            FreezeEntityPosition(PlayerPedId(), true)
            SetEntityInvincible(PlayerPedId(), true)
			return
		end
	end
end)

--- CODE

local choosingCharacter = false
local cam = nil

function openCharMenu(bool)
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        action = "openUI",
        toggle = bool,
    })
    choosingCharacter = bool
    skyCam(bool)
    RebornCore.Functions.TriggerCallback("reborn:check:vip:type", function(result)
        SendNUIMessage({
            vipstatus = result
        })
    end)
end

RegisterNUICallback('closeUI', function()
    openCharMenu(false)
end)

RegisterNUICallback('disconnectButton', function()
    TriggerServerEvent('cash-multiplecharacters:server:disconnect')
end)

RegisterNUICallback('selectCharacter', function(data)
    local cData = data.cData
    DoScreenFadeOut(20)
    TriggerServerEvent('cash-multiplecharacters:server:loadUserData', cData)
    openCharMenu(false)
end)

RegisterNetEvent('cash-multiplecharacters:client:closeNUI')
AddEventHandler('cash-multiplecharacters:client:closeNUI', function()
    openCharMenu(false)
end)

RegisterNetEvent('cash-multiplecharacters:client:chooseChar')
AddEventHandler('cash-multiplecharacters:client:chooseChar', function()
    skyCam(true)
    Citizen.Wait(5000)
    SendNUIMessage({
        loading = true,
    })
    RebornCore.Functions.TriggerCallback("reborn:check:vip:type", function(result)
        SendNUIMessage({
            action = "atualizavip",
            vipstatus = result
        })
    end)
    -- openCharMenu(true)
end)

function selectChar()
    openCharMenu(true)
end

RegisterNUICallback('cDataPed', function(data)
    local cData = data.cData
	if cData ~= nil then
        --[[
        RebornCore.Functions.TriggerCallback('cash-multiplecharacters:server:getSkin', function(model, data)
            FreezeEntityPosition(PlayerPedId(), true)
            SetEntityInvincible(PlayerPedId(), true)
            if model ~= nil then
                model = model ~= nil and tonumber(model) or false

                if not IsModelInCdimage(model) or not IsModelValid(model) then setDefault() return end
            
                Citizen.CreateThread(function()
                    RequestModel(model)
                    
                    while not HasModelLoaded(model) do
                        Citizen.Wait(0)
                    end
                    --charPed = CreatePed(3, model, 306.25, -991.09, -99.99, 89.5, false, true)
                    
                    data = json.decode(data)
            
                    TriggerEvent('cash-clothes:client:loadPlayerClothing', data, charPed)
                end)
            else
                charPed = CreatePed(4, GetHashKey("mp_m_freemode_01"), 306.25, -991.09, -99.99, 89.5, false, true)
            end
        end, cData.citizenid)
        ]]
        return
    else
        return
    end

    Citizen.Wait(100)
    
    -- SetEntityHeading(PlayerPedId(), 89.5)
    -- FreezeEntityPosition(PlayerPedId(), false)
    -- SetEntityInvincible(PlayerPedId(), true)
    -- PlaceObjectOnGroundProperly(PlayerPedId())
    -- SetBlockingOfNonTemporaryEvents(PlayerPedId(), true)
end)

RegisterNUICallback('setupCharacters', function()
    RebornCore.Functions.TriggerCallback("Reborn:Setup:Persoangens", function(result)
        SendNUIMessage({
            action = "setupCharacters",
            characters = result
        })
        SetNuiFocus(true,true)
        SetTimecycleModifier('default')
    end)
    RebornCore.Functions.TriggerCallback("reborn:check:vip:type", function(result)
        -- print('[client] tipo de vip: '..result)
        SendNUIMessage({
            action = "atualizavip",
            vipstatus = result
        })
    end)
end)

RegisterNUICallback('CharacterFocus', function()
    SetNuiFocus(true, true)
end)


RegisterNUICallback('checarVipConta', function()
    RebornCore.Functions.TriggerCallback("reborn:check:vip:type", function(result)
        -- print('[client] tipo de vip: '..result)
        SendNUIMessage({
            vipstatus = result
        })
    end)
end)

RegisterNUICallback('createNewCharacter', function(data)
    local cData = data
    DoScreenFadeOut(150)
    if cData.gender == "man" then
        cData.gender = 0
        TriggerEvent('novopersonagem:gender:set', 0)
    elseif cData.gender == "vrouw" then
        cData.gender = 1
        TriggerEvent('novopersonagem:gender:set', 1)
    end
    TriggerServerEvent('cash-multiplecharacters:server:createCharacter', cData)
    TriggerServerEvent('cash-multiplecharacters:server:GiveStarterItems')
    Citizen.Wait(500)
end)

RegisterNUICallback('removeCharacter', function(data)
    TriggerServerEvent('cash-multiplecharacters:server:deleteCharacter', data.citizenid)
end)

function skyCam(bool)
    if bool then
        DoScreenFadeIn(10)
        SetTimecycleModifier('hud_def_blur')
        SetTimecycleModifierStrength(1.0)
        FreezeEntityPosition(GetPlayerPed(-1), false)
        cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 696.28, 1062.98, 348.62, -2.00, 0.00, 350.50, 85.00, false, 0)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 1, true, true)
    else
        SetTimecycleModifier('default')
        SetCamActive(cam, false)
        DestroyCam(cam, true)
        RenderScriptCams(false, false, 1, true, true)
        FreezeEntityPosition(GetPlayerPed(-1), false)
    end
end