# Hex Donate System

**👨‍💻 Created by K1Dev Team**  
[Join our Discord](https://discord.gg/vWcYNgAv8S) for support & updates!

ระบบบริจาคเงินกองทุนสำหรับ RedM VORP

## 🚀 การติดตั้ง

### 1. ดาวน์โหลดไฟล์
```
📁 resources/hex-donate/
├── 📄 fxmanifest.lua
├── 📄 config.lua
├── 📄 client/main.lua
├── 📄 server/main.lua
└── 📁 html/
    ├── 📄 index.html
    ├── 📄 script.js
    ├── 📄 style.css
    └── 📁 images/
        └── 📄 char.png
```

### 2. วางไฟล์ใน Server
วางโฟลเดอร์ `hex-donate` ในโฟลเดอร์ `resources` ของเซิร์ฟเวอร์

### 3. เพิ่มใน server.cfg
```
ensure hex-donate
```


## ⚙️ การตั้งค่า


```lua
Config.DonationPoints = {
    {
        id = "point_1",                    -- ID ของจุดบริจาค
        name = "กองทุนพัฒนาโรงม้า",         -- ชื่อกองทุน
        maxAmount = 555,                   -- จำนวนเงินเป้าหมาย
        speechText = {                     -- ข้อความตัวละคร
            "ยินดีต้อนรับสู่ระบบบริจาคกองทุนโรงม้า",
            "การบริจาคของคุณจะช่วยพัฒนาสิ่งอำนวยความสะดวกและฟีเจอร์ใหม่ๆ ให้กับโรงม้า",
            "ขอบคุณสำหรับการสนับสนุนครับ!"
        },
        characterImage = "https://img2.pic.in.th/pic/chare94b2d5f777060b2.png",  -- รูปตัวละคร
        position = vector3(-855.2792, -1371.7983, 43.6162),  -- ตำแหน่งในเกม
        blip = true,                       -- แสดงบนแผนที่
        interactionDistance = 3.0          -- ระยะการโต้ตอบ
    }
}
```

