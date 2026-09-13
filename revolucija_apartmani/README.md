# revolucija_apartmani — instalacija

## Šta je dodano/popravljeno
- **server/server.lua** — kompletna server strana: dodjela apartmana, kreiranje stasha
  (ox_inventory), provjera/dohvat vlasništva, praćenje trenutnog apartmana (za spawn/death/relog),
  pozivanje igrača u apartman.
- **sql/revolucija_apartmani.sql** — tabela u bazi koju server.lua koristi.
- **client/client.lua** — NUI meni za biranje apartmana (`/apartman` komanda), target sistem preko
  `qtarget`, jedan ulaz (definisan u `config/config.lua` kao `Revolucija.Ulaz`).
- **config/config.lua** — 3 apartmana, jedan zajednički ulaz (nema više Grad/Sandy izbor default
  apartmana — pojednostavljeno na tvoj zahtjev).
- **UID se sam dodjeljuje** — server sam prati jedinstveni ID igrača (kolona `id`), ne zavisi ni od
  kakvog vanjskog "core" resursa.

## Instalacija
1. Uvezi `sql/revolucija_apartmani.sql` u bazu.
   - Ako si već ranije uvezao stariju verziju ove tabele, obriši je (`DROP TABLE revolucija_apartmani;`)
     i uvezi ponovo — kolone su se mijenjale.
2. Zamijeni folder resursa na serveru novom verzijom.
3. Provjeri da su ovi resursi pokrenuti PRIJE `revolucija_apartmani` u `server.cfg`:
   `es_extended`, `oxmysql`, `ox_lib`, `qtarget`, `ox_inventory`, `esx_skin`.
4. Restartuj resurs: `ensure revolucija_apartmani`.

## Modeli apartmana
Config sad koristi `default_housing1_k4mb1`, `default_housing3_k4mb1`, `default_housing4_k4mb1`
kao objekte — to su takođe custom "shell" modeli, ne osnovni GTA modeli. Ako ih nemaš instalirane
(poseban stream/prop resurs), dobićeš ili grešku "model ne postoji" u konzoli/notifikaciji, ili
crn ekran ako model postoji ali bez odgovarajućeg osvjetljenja. Vidi prijašnje napomene o
"standardmotel_shell" — isto pravilo važi i za ove nazive.

## Tok korištenja
1. Igrač otkuca `/apartman` → meni sa sva 3 apartmana (učitano iz configa) → "Izaberi".
2. Kod ulaza (`Revolucija.Ulaz`, `qtarget`) igrač bira "Udji u svoj apartman" → apartman se učitava
   (spawn objekta, sef, izlaz).
