local Core = exports.vorp_core:GetCore()

local DonationServer = {}
DonationServer.__index = DonationServer

function DonationServer:new()
    local instance = {
        donationData = {},
        currentDonationPoint = nil
    }
    setmetatable(instance, DonationServer)
    return instance
end

function DonationServer:readJSONData(filename)
    local json_string = LoadResourceFile(GetCurrentResourceName(), filename)
    if json_string then
        return json.decode(json_string) or {}
    end
    return {}
end

function DonationServer:writeJSONData(filename, data)
    SaveResourceFile(GetCurrentResourceName(), filename, json.encode(data), -1)
end

function DonationServer:getPlayerFromId(src)
    local user = Core.getUser(src)
    if not user then return false end
    local character = user.getUsedCharacter
    return {
        source = src,
        identifier = character.identifier,
        name = (character.firstname or "กำลังสร้างตัวละคร..").."  "..(character.lastname or " "),
        job = character.job,
        jobGrade = character.jobGrade,
        jobLabel = character.jobLabel,
        money = character.money,
        group = character.group,
        gold = character.gold
    }
end

function DonationServer:deductPlayerMoney(src, amount)
    local user = Core.getUser(src)
    if not user then return false end
    
    local character = user.getUsedCharacter
    if not character then return false end
    
    local currentMoney = character.money
    if currentMoney < amount then
        return false
    end
    
    character.removeCurrency(0, amount)
    return true
end

function DonationServer:openDonation(src, pointId)
    local player = self:getPlayerFromId(src)
    if not player then return end
    
    local donationPoint = nil
    for _, point in pairs(Config.DonationPoints) do
        if point.id == pointId then
            donationPoint = point
            break
        end
    end
    
    if not donationPoint then return end
    
    self.currentDonationPoint = pointId
    self.donationData = self:readJSONData('donation_data.json')
    
    if not self.donationData[pointId] then
        self.donationData[pointId] = {
            currentAmount = 0,
            donations = {},
            topDonators = {}
        }
    end
    
    local data = {
        pointName = donationPoint.name,
        maxAmount = donationPoint.maxAmount,
        currentAmount = self.donationData[pointId].currentAmount,
        speechText = donationPoint.speechText,
        characterImage = donationPoint.characterImage,
        recentDonations = self.donationData[pointId].donations,
        topDonators = self.donationData[pointId].topDonators
    }
    
    TriggerClientEvent('hex-donate:openUI', src, data)
end

function DonationServer:makeDonation(src, amount)
    local player = self:getPlayerFromId(src)
    if not player then return end
    
    if not self.currentDonationPoint then return end
    
    local donationPoint = nil
    for _, point in pairs(Config.DonationPoints) do
        if point.id == self.currentDonationPoint then
            donationPoint = point
            break
        end
    end
    
    if not donationPoint then return end
    
    if amount <= 0 or amount > player.money then
        TriggerClientEvent('hex-donate:showNotification', src, Config.Notifications.invalid)
        return
    end
    
    if self.donationData[self.currentDonationPoint].currentAmount >= donationPoint.maxAmount then
        TriggerClientEvent('hex-donate:showNotification', src, "กองทุนนี้เต็มแล้ว")
        return
    end
    
    local newAmount = math.min(self.donationData[self.currentDonationPoint].currentAmount + amount, donationPoint.maxAmount)
    local actualDonation = newAmount - self.donationData[self.currentDonationPoint].currentAmount
    
    local success = self:deductPlayerMoney(src, actualDonation)
    if not success then
        TriggerClientEvent('hex-donate:showNotification', src, Config.Notifications.insufficient)
        return
    end
    
    self.donationData[self.currentDonationPoint].currentAmount = newAmount
    
    local donationRecord = {
        playerName = player.name,
        amount = actualDonation,
        timestamp = os.time()
    }
    
    table.insert(self.donationData[self.currentDonationPoint].donations, 1, donationRecord)
    
    if #self.donationData[self.currentDonationPoint].donations > 10 then
        table.remove(self.donationData[self.currentDonationPoint].donations, #self.donationData[self.currentDonationPoint].donations)
    end
    
    local found = false
    for i, donator in pairs(self.donationData[self.currentDonationPoint].topDonators) do
        if donator.playerName == player.name then
            donator.totalAmount = donator.totalAmount + actualDonation
            found = true
            break
        end
    end
    
    if not found then
        table.insert(self.donationData[self.currentDonationPoint].topDonators, {
            playerName = player.name,
            totalAmount = actualDonation
        })
    end
    
    table.sort(self.donationData[self.currentDonationPoint].topDonators, function(a, b)
        return a.totalAmount > b.totalAmount
    end)
    
    if #self.donationData[self.currentDonationPoint].topDonators > 5 then
        table.remove(self.donationData[self.currentDonationPoint].topDonators, #self.donationData[self.currentDonationPoint].topDonators)
    end
    
    self:writeJSONData('donation_data.json', self.donationData)
    
    TriggerClientEvent('hex-donate:updateProgress', src, {
        currentAmount = newAmount,
        maxAmount = donationPoint.maxAmount,
        recentDonations = self.donationData[self.currentDonationPoint].donations,
        topDonators = self.donationData[self.currentDonationPoint].topDonators
    })
    
    TriggerClientEvent('hex-donate:showNotification', src, Config.Notifications.success)
end

function DonationServer:closeDonation(src)
    self.currentDonationPoint = nil
    TriggerClientEvent('hex-donate:closeUI', src)
end

function DonationServer:registerEvents()
    RegisterNetEvent('hex-donate:openDonation', function(pointId)
        self:openDonation(source, pointId)
    end)

    RegisterNetEvent('hex-donate:makeDonation', function(amount)
        self:makeDonation(source, amount)
    end)

    RegisterNetEvent('hex-donate:closeDonation', function()
        self:closeDonation(source)
    end)
end

local donationServer = DonationServer:new()
donationServer:registerEvents()