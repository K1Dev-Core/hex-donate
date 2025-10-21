local Core = exports.vorp_core:GetCore()

local DonationSystem = {}
DonationSystem.__index = DonationSystem

function DonationSystem:new()
    local instance = {
        isUIOpen = false,
        currentDonationData = nil,
        donationPoints = {},
        blips = {},
        textUI = nil,
        nearbyPoint = nil
    }
    setmetatable(instance, DonationSystem)
    return instance
end

function DonationSystem:initialize()
    self:createBlips()
    self:startInteractionLoop()
    self:registerEvents()

end

function DonationSystem:createBlips()
    for _, point in pairs(Config.DonationPoints) do
        if point.blip then
            local radiusBlip = Citizen.InvokeNative(0x45F13B7E0A15C880, 2033377404, vector3(point.position.x, point.position.y, point.position.z), point.interactionDistance)
        
            self.blips[point.id] = radiusBlip
            self.donationPoints[point.id] = point
        end
       
    end
end

function DonationSystem:startInteractionLoop()
    Citizen.CreateThread(function()
        while true do
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local nearbyPoint = nil
            local closestDistance = math.huge
            
            for _, point in pairs(self.donationPoints) do
                local distance = #(playerCoords - point.position)
                if distance <= point.interactionDistance and distance < closestDistance then
                    closestDistance = distance
                    nearbyPoint = point
                end
               
            end
            
            if nearbyPoint and not self.isUIOpen then
                if not self.textUI then
                    self:showTextUI(nearbyPoint)
                end
                self.nearbyPoint = nearbyPoint
            else
                if self.textUI and not self.isUIOpen then
                    self:hideTextUI()
                end
                if not self.isUIOpen then
                    self.nearbyPoint = nil
                end
            end
            
            Citizen.Wait(500)
        end
    end)
    
    Citizen.CreateThread(function()
        while true do
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            for _, point in pairs(self.donationPoints) do
                local distance = #(playerCoords - point.position)
                if distance <= point.interactionDistance + 30 then
                    if distance <= point.interactionDistance + 30 then
                        Citizen.InvokeNative(0x2A32FAA57B937173,
                        -1795314153,
                        point.position.x,
                        point.position.y + 0.3,
                        point.position.z - 5.0,
                        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                        0.2,
                        0.2,
                        6.0,
                        255, 0, 0,
                        50,
                        false, false, 2, false, nil, nil, false
                    )
                    end
                end
            end
            Citizen.Wait(7)
        end
    end)
   
end

function DonationSystem:showTextUI(point)
    if not Config.TextUI.enabled then return end
    
    self.textUI = true
    SendNUIMessage({
        type = "showTextUI",
        data = {
            text = Config.TextUI.text,
            key = Config.TextUI.key
        }
    })
end

function DonationSystem:hideTextUI()
    if self.textUI then
        SendNUIMessage({
            type = "hideTextUI"
        })
        self.textUI = nil
    end
end

function DonationSystem:registerEvents()
    RegisterNetEvent('hex-donate:openUI', function(data)
        if self.isUIOpen then return end
        
        self.currentDonationData = data
        self.isUIOpen = true
        
        if self.textUI then
            self:hideTextUI()
        end
        PlaySoundFrontend("INFO_HIDE", "HUD_SHOP_SOUNDSET", true,1)
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "openUI",
            data = data
        })
        AnimpostfxPlay("PhotoMode_Bounds")
    end)

    RegisterNetEvent('hex-donate:closeUI', function()
        if not self.isUIOpen then return end
        
        self.isUIOpen = false
        SetNuiFocus(false, false)
        AnimpostfxStop("PhotoMode_Bounds")
        PlaySoundFrontend("INFO_HIDE", "HUD_SHOP_SOUNDSET", true,1)
        SendNUIMessage({
            type = "closeUI"
        })
        
        if self.nearbyPoint then
            self:showTextUI(self.nearbyPoint)
        end
    end)

    RegisterNetEvent('hex-donate:updateProgress', function(data)
        if not self.isUIOpen then return end
        
        SendNUIMessage({
            type = "updateProgress",
            data = data
        })
    end)

    RegisterNetEvent('hex-donate:showNotification', function(message)
        self:showNotification(message)
    end)

    RegisterNUICallback('makeDonation', function(data, cb)
        TriggerServerEvent('hex-donate:makeDonation', tonumber(data.amount))
        PlaySoundFrontend("BET_PROMPT", "HUD_POKER", true, 1)
        cb('ok')
    end)

    RegisterNUICallback('closeDonation', function(data, cb)
        TriggerServerEvent('hex-donate:closeDonation')
        cb('ok')
    end)
end


function DonationSystem:showNotification(message, type)
    type = type or "info"
    SendNUIMessage({
        type = "showNotification",
        data = {
            message = message,
            type = type
        }
    })
end

function DonationSystem:handleInteraction()
    if self.nearbyPoint and not self.isUIOpen then
        TriggerServerEvent('hex-donate:openDonation', self.nearbyPoint.id)
    end
end

function DonationSystem:cleanup()
    for _, blip in pairs(self.blips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    self.blips = {}
    
    if self.textUI then
        self:hideTextUI()
    end
    
    if self.isUIOpen then
        SetNuiFocus(false, false)
        SendNUIMessage({
            type = "closeUI"
        })
    end
end

local donationSystem = DonationSystem:new()
donationSystem:initialize()

Citizen.CreateThread(function()
    print("Donation System by Hex")
    while true do
        if IsControlJustPressed(0, Config.TextUI.keyhash) then
            donationSystem:handleInteraction()
        end
        Citizen.Wait(0)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        donationSystem:cleanup()
    end
end)