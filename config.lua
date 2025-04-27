Config = {}

-- Debug modu (sadece geliştiriciler için)
Config.Debug = false 

-- Dil ayarı ('tr', 'en' vb. locales klasöründeki dosya adı)
Config.Language = 'tr' 


-- Framework ayarı: 'auto', 'esx', 'qbcore' veya 'none'
Config.Framework = 'qbcore'


-- ================== TEMEL AYARLAR ==================

Config.HUD = {
    Visible = true,       -- Başlangıçta HUD açık mı?
    Command = 'togglehud' -- HUD'u açıp kapatmak için komut
}

-- ================== EKRAN AYARLARI ==================

Config.Minimap = {
    HideOutsideVehicle = true -- Araç dışında haritayı gizle, araçta göster
}

-- ================== ARAÇ AYARLARI ==================

Config.Speedometer = {
    Unit = 'kmh',  -- Birim: 'kmh' veya 'mph'
    KmhConversion = 3.6, -- değiştirmeyiniz
    MphConversion = 2.236936, -- değiştirmeyiniz
    MaxSpeed = 250 -- Hız göstergesi için maksimum hız (KM/H veya MPH cinsinden)
}

-- Emniyet Kemeri
Config.Seatbelt = {
    Key = 'B',                 -- Kemeri takma/çıkarma tuşu
    EnableNotifications = true, -- Kemer takılı değilken bildirim gönderilsin mi?
    NotificationInterval = 5000 -- Bildirim gönderme sıklığı (milisaniye)
}

-- Yakıt Sistemi
Config.Fuel = {
    Enabled = true  -- Yakıt göstergesini aktif et
}

-- Yakıt değerini alma fonksiyonu (buradan değiştirilebilir)
Config.GetFuel = function(vehicle)
    -- return GetVehicleFuelLevel(vehicle)
    return exports['cdn-fuel']:GetFuel(vehicle)
end


Config.JobFormat = "%s / %s"  -- İş ve rütbe arası format (örn: "Polis / Şef")

