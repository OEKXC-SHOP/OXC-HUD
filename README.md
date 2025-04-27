
## Özellikler Ön izleme

- Ön İzleme(https://youtu.be/L3ZaBf6uJqQ)



# OXC-HUD

Bu Hud, FiveM sunucuları için geliştirilmiş bir huddur

## Özellikler

- Hız göstergesi (KM/H veya MPH)
- Yakıt göstergesi
- Emniyet kemeri durumu ve uyarısı
- Sağlık, zırh, açlık, susuzluk ve dayanıklılık göstergeleri
- Oyuncu bilgileri (ID, Oyuncu Sayısı)
- Sunucu bilgileri (Saat, Hava Durumu)
- Para (Nakit, Banka)
- İş bilgileri
- Konum ve sokak adı göstergesi
- Minimalist ve modern arayüz
- Çoklu dil desteği (TR, EN, DE, FR, ES, PT)
- ESX ve QBCore framework desteği (Otomatik algılama)
- `ox_lib` bağımlılığı

## Kurulum

1.  **Bağımlılıkları Kurun:**
    *   [ox_lib](https://github.com/overextended/ox_lib) kütüphanesinin sunucunuzda kurulu olduğundan emin olun.
2.  **İndirin:**
    *   Bu depoyu indirin veya klonlayın.
3.  **Sunucuya Ekleyin:**
    *   İndirdiğiniz `oxc-hud` klasörünü sunucunuzun `resources` klasörüne taşıyın.
4.  **Yapılandırın:**
    *   `config.lua` dosyasını açarak istediğiniz ayarları (dil, framework, HUD görünürlüğü vb.) yapın. Özellikle `Config.Framework` ayarını sunucunuza (`esx`, `qbcore` veya `none`) göre ayarlayın veya `auto` bırakın.
    *   Eğer özel bir yakıt scripti kullanıyorsanız (`cdn-fuel` gibi), `Config.GetFuel` fonksiyonunu `config.lua` içinde buna göre düzenleyin.
5.  **Başlatın:**
    *   `server.cfg` dosyanıza `ensure oxc-hud` satırını ekleyin.

## Kullanım

- Varsayılan olarak HUD görünür durumdadır.
- `/togglehud` komutu ile HUD'u açıp kapatabilirsiniz (komut `config.lua` içinden değiştirilebilir).
- Emniyet kemerini takıp çıkarmak için varsayılan tuş `B'dir (`config.lua` içinden değiştirilebilir).

## Katkıda Bulunma

OEKXC         -   Yapımcı

Lasparagas    --  Tester
RAZONWT       --  Tester


## Lisans

Bu proje Apache-2.0 Lisansı altında lisanslanmıştır. Detaylar için `LICENSE` dosyasına bakınız. 
