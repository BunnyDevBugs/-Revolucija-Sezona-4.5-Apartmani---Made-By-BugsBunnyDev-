local Objekt, Target = nil, {}

local function OtvoriMenuApartmana()
    ESX.TriggerServerCallback("revolucija_apartmani>server>DajApartman", function(Tip)
        if Tip then
            return ESX.ShowNotification("Već imaš izabran apartman!", "error")
        end

        local Lista = {}
        for Ime, Podatci in pairs(Revolucija.Apartmani) do
            Lista[#Lista + 1] = { ime = Ime, slika = Podatci.Slika }
        end
        
        SetNuiFocus(true, true)
        return SendNUIMessage({ Apartmani = Lista })
    end, LocalPlayer.state.UID)
end

RegisterNUICallback("Odabir", function(Podatak, Callback)
    SetNuiFocus(false, false)
    --
    TriggerEvent("revolucija_apartmani>client>Biranje", Podatak)
    --
    return Callback({})
end)

RegisterCommand("apartman", function()
    return OtvoriMenuApartmana()
end, false)

RegisterNetEvent("revolucija_apartmani>client>Biranje", function(Tip)
    Tip = Tip or "Apartman 1"
    --
    if not Revolucija.Apartmani[Tip] then return end
    --
    TriggerServerEvent("revolucija_apartmani>server>PostaviApartman", Tip)
    --
    return TriggerServerEvent("revolucija_apartmani>server>NapraviStash", LocalPlayer.state.UID)
end)

local function Obrisi()
    if Objekt then
        DeleteEntity(Objekt)
        --
        Objekt = nil
    end
    --
    if Target.Sef then
        exports['qtarget']:RemoveZone(Target.Sef)
        --
        Target.Sef = nil
    end
    --
    if Target.Izlaz then
        exports['qtarget']:RemoveZone(Target.Izlaz)
        --
        Target.Izlaz = nil
    end
end

local function UcitajApartman(Tip, RoutingBucket, Registracija)
    if not Tip or not RoutingBucket then return end
    --
    if not Revolucija.Apartmani[Tip] then return end
    --
    TriggerServerEvent("revolucija_apartmani>server>UpdateUApt", Tip)
    --
    DoScreenFadeOut(337)
    --
    Citizen.Wait(337)
    --
    local Hash = GetHashKey(Revolucija.Apartmani[Tip].Objekt)
    --
    if not IsModelInCdimage(Hash) then
        print("^1[revolucija_apartmani]^0 Model '" .. Revolucija.Apartmani[Tip].Objekt .. "' ne postoji (los naziv ili nedostaje resurs sa modelom).")
        --
        return ESX.ShowNotification("Greska: model apartmana ne postoji. Vidi konzolu.", "error")
    end
    --
    if IsModelInCdimage(Hash) then
        FreezeEntityPosition(PlayerPedId(), true)
        --
        RequestModel(Hash)
        --
        while not HasModelLoaded(Hash) do Citizen.Wait(0) end
        --
        Obrisi()
        --
        Objekt = CreateObject(Hash, Revolucija.Koordinate, false, true, false)
        --
        SetModelAsNoLongerNeeded(Hash)
        --
        while not DoesEntityExist(Objekt) do Citizen.Wait(0) end
        --
        SetEntityInvincible(Objekt, true)
        --
        FreezeEntityPosition(Objekt, true)
        --
        Target.Sef = "revolucija_apartman_sef_" .. RoutingBucket
        --
        exports['qtarget']:AddCircleZone(Target.Sef, Revolucija.Apartmani[Tip].Sef, 1.0,
        {
            name = Target.Sef,
            debugPoly = false,
            useZ = true
        },
        {
            options =
            {
                {
                    type = "client",
                    icon = "fa-solid fa-vault",
                    label = "Otvori Sef",
                    distance = 2.0,
                    action = function(entity)
                        return exports.ox_inventory:openInventory("stash", "Apartman" .. RoutingBucket)
                    end
                }
            },
            distance = 2.0
        })
        --
        Target.Izlaz = "revolucija_apartman_izlaz_" .. RoutingBucket
        --
        exports['qtarget']:AddCircleZone(Target.Izlaz, Revolucija.Apartmani[Tip].Izlaz.Koordinate, 1.0,
        {
            name = Target.Izlaz,
            debugPoly = false,
            useZ = true
        },
        {
            options =
            {
                {
                    type = "client",
                    icon = "fa-solid fa-door-closed",
                    label = "Izadji iz apartmana",
                    distance = 2.0,
                    action = function(entity)
                        DoScreenFadeOut(337)
                        --
                        Citizen.Wait(337)
                        --
                        local Ulaz = Revolucija.Ulaz
                        --
                        SetEntityCoords(PlayerPedId(), vector3(Ulaz.Koordinate.x, Ulaz.Koordinate.y, Ulaz.Koordinate.z - 1))
                        --
                        SetEntityHeading(PlayerPedId(), Ulaz.Heading)
                        --
                        Obrisi()
                        --
                        TriggerServerEvent("revolucija_apartmani>server>RoutingBucket", 0)
                        --
                        LocalPlayer.state:set("Apartman", 0, true)
                        --
                        ESX.ShowNotification("Izasao/la si iz apartmana ~y~" .. RoutingBucket .. "~s~.", "success")
                        --
                        TriggerServerEvent("revolucija_apartmani>server>UpdateUApt", nil)
                        --
                        return DoScreenFadeIn(337)
                    end
                },
                {
                    type = "client",
                    icon = "fa-solid fa-user-group",
                    label = "Pozovi igraca u apartman",
                    distance = 2.0,
                    canInteract = function(entity)
                        if RoutingBucket == LocalPlayer.state.UID then return true else return false end
                    end,
                    action = function(entity)
                        ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "Pozivanje",
                        {
                            title = "Pozovi igraca u apartman"
                        }, function(Podatci, Menu)
                            local targetID = tonumber(Podatci.value)
                            if not targetID then 
                                return ESX.ShowNotification("Moras upisati važeći ID igrača!") 
                            end
                            --
                            TriggerServerEvent("revolucija_apartmani>server>PozoviUApartman", targetID, Tip, RoutingBucket)
                            --
                            ESX.UI.Menu.Close('dialog', GetCurrentResourceName(), "Pozivanje")
                            SetNuiFocus(false, false)
                        end, function(Podatci, Menu)
                            ESX.UI.Menu.Close('dialog', GetCurrentResourceName(), "Pozivanje")
                            SetNuiFocus(false, false)
                        end)
                    end
                }
            },
            distance = 2.0
        })
        --
        TriggerServerEvent("revolucija_apartmani>server>RoutingBucket", RoutingBucket)
        --
        if Registracija then
            RequestCollisionAtCoord(Revolucija.Apartmani[Tip].Spawn.Koordinate)
            --
            SetEntityCoords(PlayerPedId(), Revolucija.Apartmani[Tip].Spawn.Koordinate)
            --
            SetEntityHeading(PlayerPedId(), Revolucija.Apartmani[Tip].Spawn.Heading)
            --
            while not HasCollisionLoadedAroundEntity(PlayerPedId()) do Citizen.Wait(0) end
        else
            RequestCollisionAtCoord(vector3(Revolucija.Apartmani[Tip].Izlaz.Koordinate.x, Revolucija.Apartmani[Tip].Izlaz.Koordinate.y, Revolucija.Apartmani[Tip].Izlaz.Koordinate.z - 1))
            --
            SetEntityCoords(PlayerPedId(), vector3(Revolucija.Apartmani[Tip].Izlaz.Koordinate.x, Revolucija.Apartmani[Tip].Izlaz.Koordinate.y, Revolucija.Apartmani[Tip].Izlaz.Koordinate.z - 1))
            --
            SetEntityHeading(PlayerPedId(), Revolucija.Apartmani[Tip].Izlaz.Heading)
            --
            while not HasCollisionLoadedAroundEntity(PlayerPedId()) do Citizen.Wait(0) end
        end
        --
        LocalPlayer.state:set("Apartman", RoutingBucket, true)
        --
        FreezeEntityPosition(PlayerPedId(), false)
        --
        DoScreenFadeIn(337)
        --
        return SetModelAsNoLongerNeeded(Hash)
    end
end

RegisterNetEvent("revolucija_apartmani>client>PozoviUApartman", function(Tip, RoutingBucket)
    if not Tip or not RoutingBucket then return end
    --
    return UcitajApartman(Tip, RoutingBucket, false)
end)

RegisterNetEvent("revolucija_apartmani>client>Provjera", function(Tip)
    if not Tip then return end
    --
    ESX.TriggerServerCallback("esx_skin:getPlayerSkin", function(Skin)
        if Skin then
            ESX.TriggerServerCallback("revolucija_apartmani>server>ProvjeriApartman", function(Apartman)
                if not Apartman then return end
                --
                TriggerEvent("esx_skin>client>Apartmani", Skin)
                --
                if Apartman ~= 0 then
                    ESX.TriggerServerCallback("revolucija_apartmani>server>DajApartman", function(Tip)
                        if not Tip then return end
                        --
                        return UcitajApartman(Tip, Apartman, false)
                    end, Apartman)
                end
            end)
        else
            UcitajApartman(Tip, LocalPlayer.state.UID, true)
            --
            return TriggerEvent("esx_skin>client>Apartmani", false)
        end
    end)
end)

local function UlazOpcije()
    return
    {
        {
            type = "client",
            icon = "fa-solid fa-door-open",
            label = "Udji u svoj apartman",
            distance = 5,
            canInteract = function(entity)
                if not LocalPlayer.state.Carry and not LocalPlayer.state.Mrtav then return true end
            end,
            action = function(entity)
                if not LocalPlayer.state.UID then
                    print("^1[revolucija_apartmani]^0 LocalPlayer.state.UID nije postavljen - provjeri svoj core resurs.")
                    --
                    return ESX.ShowNotification("Greska: UID nije postavljen. Vidi server konzolu.", "error")
                end
                --
                ESX.TriggerServerCallback("revolucija_apartmani>server>DajApartman", function(Tip)
                    if not Tip then
                        return ESX.ShowNotification("Nemas apartman. Otvori meni komandom ~y~/apartman~s~ da ga izaberes.", "error")
                    end
                    --
                    UcitajApartman(Tip, LocalPlayer.state.UID, false)
                    --
                    return ESX.ShowNotification("Usao/la si u apartman ~y~" .. LocalPlayer.state.UID .. "~s~.", "success")
                end, LocalPlayer.state.UID)
            end
        }
    }
end

Target.Ulaz = "revolucija_apartman_ulaz"

exports['qtarget']:AddCircleZone(Target.Ulaz, Revolucija.Ulaz.Koordinate, 2.0,
{
    name = Target.Ulaz,
    debugPoly = false,
    useZ = true
},
{
    options = UlazOpcije(),
    distance = 5
})

AddEventHandler("onResourceStop", function(ImeResourcea)
    if ImeResourcea == GetCurrentResourceName() then
        Obrisi()
        --
        if Target.Ulaz then
            exports['qtarget']:RemoveZone(Target.Ulaz)
            --
            Target.Ulaz = nil
        end
    end
end)

AddEventHandler("esx:onPlayerSpawn", function()
    Wait(1000)
    ESX.TriggerServerCallback("revolucija_apartmani>server>DohvatiUApt", function(tip)
        if tip then
            DoScreenFadeOut(337)
            --
            Citizen.Wait(337)
            --
            local Ulaz = Revolucija.Ulaz
            --
            SetEntityCoords(PlayerPedId(), vector3(Ulaz.Koordinate.x, Ulaz.Koordinate.y, Ulaz.Koordinate.z - 1))
            --
            SetEntityHeading(PlayerPedId(), Ulaz.Heading)
            --
            Obrisi()
            --
            TriggerServerEvent("revolucija_apartmani>server>RoutingBucket", 0)
            --
            LocalPlayer.state:set("Apartman", 0, true)
            --
            TriggerServerEvent("revolucija_apartmani>server>UpdateUApt", nil)
            --
            DoScreenFadeIn(337)
        end
    end)
end)

AddEventHandler("esx:onPlayerDeath", function()
    ESX.TriggerServerCallback("revolucija_apartmani>server>DohvatiUApt", function(tip)
        if tip then
            DoScreenFadeOut(337)
            --
            Citizen.Wait(337)
            --
            local Ulaz = Revolucija.Ulaz
            --
            SetEntityCoords(PlayerPedId(), vector3(Ulaz.Koordinate.x, Ulaz.Koordinate.y, Ulaz.Koordinate.z - 1))
            --
            SetEntityHeading(PlayerPedId(), Ulaz.Heading)
            --
            Obrisi()
            --
            TriggerServerEvent("revolucija_apartmani>server>RoutingBucket", 0)
            --
            LocalPlayer.state:set("Apartman", 0, true)
            --
            TriggerServerEvent("revolucija_apartmani>server>UpdateUApt", nil)
            --
            DoScreenFadeIn(337)
        end
    end)
end)