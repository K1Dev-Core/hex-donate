Config = {}

Config.DonationPoints = {
    {
        id = "point_1",
        name = "กองทุนพัฒนาโรงม้า",
        maxAmount = 555,
        speechText = {
            "ยินดีต้อนรับสู่ระบบบริจาคกองทุนโรงม้า",
            "การบริจาคของคุณจะช่วยพัฒนาสิ่งอำนวยความสะดวกและฟีเจอร์ใหม่ๆ ให้กับโรงม้า",
            "ขอบคุณสำหรับการสนับสนุนครับ!"
        },
        characterImage = "https://img2.pic.in.th/pic/chare94b2d5f777060b2.png",
        position = vector3(-855.2792, -1371.7983, 43.6162),
        blip = true,
        interactionDistance = 3.0
    },
    {
        id = "point_2",
        name = "กองทุนพัฒนาโรงเรือน",
        maxAmount = 1000,
        speechText = {
            "ยินดีต้อนรับสู่ระบบบริจาคกองทุนโรงเรือน",
            "การบริจาคของคุณจะช่วยพัฒนาสิ่งอำนวยความสะดวกและฟีเจอร์ใหม่ๆ ให้กับโรงเรือน",
            "ขอบคุณสำหรับการสนับสนุนครับ!"
        },
        characterImage = "https://img5.pic.in.th/file/secure-sv1/RedDeadOnline_Artwork_BountyHunter_Character_PNG_Transparent.png",
        position = vector3(-843.7379, -1352.1831, 43.5093),
        blip = true,
        interactionDistance = 3.0
    },
}
Config.DiscordWebhooks = {
    {
        id = "point_1", -- ID ของจุดบริจาค
        donationWebhook = "YOUR_DONATION_WEBHOOK_URL_HERE", -- Webhook URL ของการบริจาค
        goalCompleteWebhook = "YOUR_GOAL_COMPLETE_WEBHOOK_URL_HERE" -- Webhook URL ของการบริจาคครบ
    },
    {
        id = "point_2", 
        donationWebhook = "YOUR_DONATION_WEBHOOK_URL_HERE",
        goalCompleteWebhook = "YOUR_GOAL_COMPLETE_WEBHOOK_URL_HERE"
    }
}

Config.TextUI = {
    enabled = true,
    text = "กด [G] เพื่อบริจาค",
    keyhash = 0x760A9C6F,
    key = "G"
}



Config.Notifications = {
    success = "บริจาคสำเร็จ! ขอบคุณสำหรับการสนับสนุน",
    error = "เกิดข้อผิดพลาดในการบริจาค",
    insufficient = "เงินไม่เพียงพอ",
    invalid = "จำนวนเงินไม่ถูกต้อง"
}

