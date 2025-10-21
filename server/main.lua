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

function DonationServer:getWebhookForPoint(pointId, webhookType)
    for _, webhook in pairs(Config.DiscordWebhooks) do
        if webhook.id == pointId then
            if webhookType == "donation" then
                return webhook.donationWebhook
            elseif webhookType == "goal" then
                return webhook.goalCompleteWebhook
            end
        end
    end
    return nil
end

function DonationServer:sendDiscordWebhook(webhookUrl, title, description, color, fields)
    if not webhookUrl or webhookUrl == "YOUR_DONATION_WEBHOOK_URL_HERE" or webhookUrl == "YOUR_GOAL_COMPLETE_WEBHOOK_URL_HERE" then
        return
    end
    
    local embed = {
        {
            ["title"] = title,
            ["description"] = description,
            ["color"] = color,
            ["fields"] = fields,
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }
    
    local payload = {
        ["embeds"] = embed
    }
    
    PerformHttpRequest(webhookUrl, function(err, text, headers) end, 'POST', json.encode(payload), {['Content-Type'] = 'application/json'})
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
    
    local wasGoalReached = (newAmount >= donationPoint.maxAmount)
    
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
    
    local donationWebhook = self:getWebhookForPoint(self.currentDonationPoint, "donation")
    if donationWebhook then
        local fields = {
            {
                ["name"] = "ผู้บริจาค",
                ["value"] = player.name,
                ["inline"] = true
            },
            {
                ["name"] = "จำนวนเงิน",
                ["value"] = "$" .. actualDonation,
                ["inline"] = true
            },
            {
                ["name"] = "ความคืบหน้า",
                ["value"] = newAmount .. "/" .. donationPoint.maxAmount,
                ["inline"] = true
            }
        }
        
        self:sendDiscordWebhook(
            donationWebhook,
            "💰 การบริจาคใหม่",
            "มีผู้บริจาคเงินให้กับ **" .. donationPoint.name .. "**",
            65280,
            fields
        )
    end
    
    if wasGoalReached then
        local goalWebhook = self:getWebhookForPoint(self.currentDonationPoint, "goal")
        if goalWebhook then
            local fields = {
                {
                    ["name"] = "กองทุน",
                    ["value"] = donationPoint.name,
                    ["inline"] = true
                },
                {
                    ["name"] = "จำนวนเงินที่ครบ",
                    ["value"] = "$" .. donationPoint.maxAmount,
                    ["inline"] = true
                },
                {
                    ["name"] = "ผู้บริจาคคนสุดท้าย",
                    ["value"] = player.name,
                    ["inline"] = true
                }
            }
            
            self:sendDiscordWebhook(
                goalWebhook,
                "🎉 เป้าหมายการบริจาคครบแล้ว!",
                "**" .. donationPoint.name .. "** ได้รับการบริจาคครบตามเป้าหมายแล้ว!",
                16776960,
                fields
            )
        end
    end
    
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
