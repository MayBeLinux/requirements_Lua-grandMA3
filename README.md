# Bibliothèque Lua pour grandMA3
## 📖 Table des matières

1. [Introduction à grandMA3](#introduction-à-grandma3)
2. [Structure du projet](#structure-du-projet)
3. [Analyse des composants principaux](#analyse-des-composants-principaux)
4. [Modules UI (lib_menus/ui/)](#modules-ui-lib_menusui)
5. [Intégration dans l'écosystème grandMA3](#intégration-dans-lécosystème-grandma3)
6. [Installation et compatibilité](#installation-et-compatibilité)
7. [Exemples d'utilisation](#exemples-dutilisation)
8. [Contribution](#contribution)

---

## 🎭 Introduction à grandMA3

### Qu'est-ce que grandMA3 ?

**grandMA3** est la console d'éclairage professionnelle de référence mondiale développée par MA Lighting, utilisée dans les plus grands spectacles, concerts, théâtres et événements internationaux. Elle offre :

- **Contrôle avancé** : Gestion de milliers de projecteurs DMX/RDM
- **Programmation complexe** : Effets, séquences et timecode sophistiqués
- **Extensibilité Lua** : Scripts personnalisés pour automatisation et fonctionnalités avancées
- **Interface professionnelle** : Écrans tactiles, encodeurs et faders physiques
- **Réseau MANet** : Communication multi-consoles et backup en temps réel

### Rôle de Lua dans grandMA3

Le système grandMA3 intègre **Lua 5.3** comme langage de script pour :

- Automatiser des tâches répétitives
- Créer des interfaces utilisateur personnalisées
- Développer des plugins et macros avancés
- Intégrer des systèmes externes (serveurs web, bases de données)
- Étendre les capacités natives de la console

---

## 📁 Structure du projet

```
requirements_Lua-grandMA3/
├── json.lua                    # Bibliothèque JSON (encode/decode)
├── gma3_helpers.lua           # Fonctions utilitaires générales
├── gma3_objects.lua           # Gestion des objets grandMA3
├── gma3_strings.lua           # Manipulation de chaînes
├── gma3_webserver.lua         # Serveur web intégré
├── gma3_debug.lua             # Débogage VSCode
├── gma3internal_fixtures.lua  # Gestion des projecteurs
├── gma3internal_library.lua   # Fonctions internes de bibliothèque
├── mobdebug.lua               # Débogueur Lua
├── vscode-debuggee.lua        # Interface débogage VSCode
├── class.lua                  # Système de classes OOP
├── socket.lua, http.lua, etc. # Bibliothèques réseau LuaSocket
└── lib_menus/
    └── ui/                    # Interfaces utilisateur grandMA3
        ├── bars/              # Barres d'outils (18 fichiers)
        ├── content/           # Contenu des fenêtres (7 fichiers)
        ├── editors/           # Éditeurs divers (55 fichiers)
        ├── fixturesetup/      # Configuration projecteurs (17 fichiers)
        ├── input/             # Contrôles d'entrée (54 fichiers)
        ├── main_overlays/     # Overlays principaux (6 fichiers)
        ├── overlays/          # Overlays généraux (35 fichiers)
        ├── popups/            # Fenêtres popup (76 fichiers)
        ├── setup/             # Configuration système (29 fichiers)
        ├── window_context/    # Contexte de fenêtres (33 fichiers)
        ├── window_other/      # Fenêtres diverses (43 fichiers)
        └── window_sheet/      # Feuilles de données (4 fichiers)
```

**Total : 403+ fichiers Lua** organisés pour le système d'interface grandMA3.

---

## 🔧 Analyse des composants principaux

### 1. **json.lua** - Bibliothèque JSON

**Auteur** : rxi (MIT License)  
**Version** : 0.1.2

#### Fonctionnalités

```lua
local json = require('json')

-- Encodage Lua → JSON
local data = {name = "Fixture 1", dmx = 512, intensity = 75}
local jsonString = json.encode(data)
-- Résultat : '{"name":"Fixture 1","dmx":512,"intensity":75}'

-- Décodage JSON → Lua
local parsed = json.decode(jsonString)
-- Résultat : table Lua avec les données
```

#### Caractéristiques

- ✅ Gestion des types : `string`, `number`, `boolean`, `table`, `nil`
- ✅ Détection de références circulaires
- ✅ Échappement correct des caractères spéciaux
- ✅ Support des tableaux et objets imbriqués
- ⚠️ Ne gère pas les userdata (objets grandMA3 natifs)

#### Utilisation dans grandMA3

Idéal pour :
- Sauvegarder/charger des configurations
- Communiquer avec des APIs externes
- Exporter des données de show
- Configuration de plugins

---

### 2. **gma3_helpers.lua** - Utilitaires grandMA3

Module central contenant des fonctions d'aide pour manipuler le système grandMA3.

#### Fonctions principales

##### 📊 **Débogage et inspection**

```lua
local helpers = require('gma3_helpers')

-- Afficher le contenu d'une variable (tables, objets gma3)
helpers:dump(myObject)

-- Afficher un objet grandMA3 avec toutes ses propriétés
helpers:dumpObj(Root().ShowData.DataPools.Default)

-- Créer un titre formaté
local title = helpers:headline("Configuration", "*", 50)
-- Résultat : "************* Configuration **************"
```

##### 📁 **Gestion de fichiers**

```lua
-- Lister le contenu d'un dossier
local files = helpers:getDirectoryContent("/path/to/folder")
-- Résultat : {{type="file", name="test.lua", fullPath="/path/to/folder/test.lua"}, ...}

-- Copier un fichier
helpers:copyFile("/source/file.xml", "/dest/file.xml")

-- Supprimer le contenu d'un dossier
helpers:deleteFolderContent({
    path = "/temp/folder",
    confirm = true,
    recursive = true
})

-- Obtenir le chemin d'export d'un objet
local exportPath = helpers:getObjectExportPath(mySequence)
```

##### 📋 **Affichage de données**

```lua
-- Afficher une table comme un tableau formaté
local data = {
    {name = "Fixture 1", dmx = 1, intensity = 100},
    {name = "Fixture 2", dmx = 2, intensity = 75}
}
helpers:printTable(data)
-- Affiche un tableau ASCII formaté

-- Afficher une table 2D
helpers:printTable2D(data)
```

##### ⏱️ **Gestion du temps**

```lua
-- Attendre une durée spécifique avec coroutine
helpers:wait(5.0)  -- Attendre 5 secondes

-- Attendre jusqu'à une condition
helpers:waitUntil(function()
    return Root().ShowData.DataPools.Default[1] ~= nil
end, 10.0, 0.5)  -- Timeout 10s, vérifie toutes les 0.5s
```

##### 💾 **Édition interactive**

```lua
-- Éditer une table Lua avec dialogue graphique
local config = {
    intensity = 75,
    color = "red",
    enabled = true
}
local modified = helpers:editLuaTable(config)
-- Ouvre un dialogue interactif pour modifier les valeurs
```

##### 🖥️ **Système**

```lua
-- Exécuter une commande système
helpers:osExecute("mkdir /temp/myFolder")

-- Exécuter et capturer le résultat
local result = helpers:osExecuteWithResult("ls -la")
```

---

### 3. **gma3_objects.lua** - Gestion des objets grandMA3

Module spécialisé pour manipuler les objets natifs de grandMA3 (séquences, presets, macros, etc.).

#### Fonctions de gestion

```lua
local objects = require('gma3_objects')

-- Créer un objet dans un pool
local pool = Root().ShowData.DataPools.Default.Sequences
local newSequence = objects:create(pool, "My Sequence")

-- Supprimer un objet
objects:delete(mySequence)

-- Déplacer un objet à un index spécifique
objects:moveTo(mySequence, 10)

-- Ajouter une ligne à une macro
local macro = Root().ShowData.DataPools.Default.Macros[1]
objects:addMacroLine(macro, {
    Command = "Go+ Sequence 1",
    Wait = "Follow"
})
```

#### Intégration avec l'API grandMA3

Ce module utilise les commandes natives grandMA3 :
- `Cmd()` : Exécuter une commande
- `CmdIndirect()` : Exécuter sans retour
- `ToAddr()` : Obtenir l'adresse d'un objet
- `Store`, `Delete`, `Move` : Commandes de base

---

### 4. **gma3_strings.lua** - Manipulation de chaînes

Utilitaires pour le traitement de chaînes de caractères.

```lua
local strings = require('gma3_strings')

-- Diviser une chaîne par séparateur
local parts = strings:splitStringBySeperator("1.2.3.4", ".")
-- Résultat : {"1", "2", "3", "4"}

-- Utile pour parser des adresses DMX, IPs, etc.
local dmxAddress = "1/512"
local parts = strings:splitStringBySeperator(dmxAddress, "/")
-- parts[1] = "1" (univers), parts[2] = "512" (adresse)
```

---

### 5. **gma3_debug.lua** - Débogage avec VSCode

Permet d'utiliser le débogueur VSCode pour développer des scripts Lua grandMA3.

```lua
local activateDebuggee = require('gma3_debug')

-- Activer le débogueur
local debuggee = activateDebuggee()

-- Le script se connecte automatiquement à VSCode
-- Points d'arrêt, inspection de variables, step-by-step disponibles
```

#### Configuration automatique
- Détecte l'IP du contrôleur via NFS sur Linux
- Configure `vscode-debuggee` et la bibliothèque JSON
- Permet le débogage distant depuis un PC

---

### 6. **Autres modules importants**

#### **gma3_webserver.lua**
Serveur web HTTP intégré pour :
- Contrôler grandMA3 via navigateur web
- Créer des interfaces de contrôle personnalisées
- Intégrer avec des systèmes de gestion de bâtiment

#### **gma3internal_fixtures.lua**
Fonctions internes pour :
- Importer des types de projecteurs
- Créer des fixtures dans le patch
- Gérer les stages et les bibliothèques

#### **LuaSocket (socket.lua, http.lua, etc.)**
Bibliothèques réseau standard pour :
- Requêtes HTTP/HTTPS
- Sockets TCP/UDP
- Communication avec serveurs externes
- FTP, SMTP, etc.

---

## 🖥️ Modules UI (lib_menus/ui/)

Le dossier `lib_menus/ui/` contient **403+ fichiers Lua** qui définissent l'interface utilisateur complète de grandMA3. Chaque fichier correspond à un composant d'interface spécifique.

### Architecture des modules UI

Tous les fichiers UI suivent le même pattern de plugin grandMA3 :

```lua
local pluginName    = select(1,...)  -- Nom du plugin
local componentName = select(2,...)  -- Nom du composant
local signalTable   = select(3,...)  -- Table de signaux/callbacks
local my_handle     = select(4,...)  -- Handle de l'objet UI
```

### Catégories principales

#### 1. **bars/** (18 fichiers) - Barres d'outils contextuelles

Barres d'outils qui apparaissent selon le contexte de travail :

- **color_picker_bar.lua** : Sélection de couleurs (HSB, RGB, CIE)
- **encoder_bar.lua** : Contrôle des encodeurs rotatifs
- **executor_bar.lua** : Gestion des executors (playbacks)
- **patch_bar.lua** : Configuration du patch DMX
- **phaser_bar.lua** : Éditeur d'effets phasers
- **preset_bar.lua** : Gestion des presets
- **sequence_control_bar.lua** : Contrôle des séquences
- **sequence_edit_bar.lua** : Édition des séquences
- **stage_view_bar.lua** : Visualisation 3D de la scène
- **timecode_bar.lua** : Synchronisation timecode

**Exemple d'utilisation** : Quand vous ouvrez un éditeur de séquence, la `sequence_edit_bar.lua` s'active automatiquement pour fournir les outils d'édition.

#### 2. **editors/** (55 fichiers) - Éditeurs spécialisés

Éditeurs pour chaque type d'objet grandMA3 :

- **sequence_editor.lua** : Éditeur de séquences (cues, timing)
- **preset_editor.lua** : Éditeur de presets (couleur, position, beam)
- **macro_editor.lua** : Éditeur de macros
- **phaser_editor.lua** : Éditeur d'effets dynamiques
- **appearance_editor.lua** : Éditeur d'apparence visuelle
- **fixture_edit.lua** : Configuration des projecteurs
- **exec/** : Sous-dossier pour configuration des executors
  - **exec_config_editor.lua** : Configuration générale
  - **executor_editor.lua** : Édition complète
  - **edit_exec_key.lua** : Configuration des touches

#### 3. **fixturesetup/** (17 fichiers) - Configuration des projecteurs

Assistants et outils pour configurer les projecteurs :

- **insert_fixtures_wizard.lua** : **Assistant principal de patch**
  - Wizard interactif pour ajouter des projecteurs
  - Calcul automatique d'adresses DMX
  - Détection de collisions d'ID/adresses
  - Suggestions de noms
  - Interface adaptative (grand écran / RPU)
  
  ```lua
  -- Fonctionnalités clés :
  -- - Validation en temps réel des adresses DMX
  -- - Prévisualisation du patch
  -- - Support des markers
  -- - Gestion des layers et classes
  ```

- **add_fixture_from_library.lua** : Importer depuis la bibliothèque
- **fixture_schedule.lua** : Planification de projecteurs

#### 4. **popups/** (76 fichiers) - Fenêtres popup

Dialogues et popups pour actions spécifiques :

- **popup_add_fixture.lua** : Ajouter des projecteurs
- **popup_store.lua** : Sauvegarder cues/presets
- **popup_copy.lua** : Copier des objets
- **popup_delete.lua** : Supprimer avec confirmation
- **popup_import_export.lua** : Import/export de fichiers
- **popup_assign.lua** : Assigner à des executors
- **popup_oops.lua** : Annuler/restaurer des actions

#### 5. **setup/** (29 fichiers) - Configuration système

Configuration de la console et du réseau :

- **network/mode2.lua** : **Gestion réseau MANet2**
  - Commutation grandMA3 ↔ grandMA2
  - Redémarrage de stations distantes
  - Reboot de consoles
  
  ```lua
  -- Fonctions principales :
  signalTable.Switchgma3Target()  -- Passer en mode gma3
  signalTable.Switchgma2Target()  -- Passer en mode gma2
  signalTable.RestartTarget()     -- Redémarrer
  signalTable.RebootTarget()      -- Reboot complet
  ```

- **user_setup.lua** : Gestion des utilisateurs
- **backup_settings.lua** : Configuration des backups
- **dmx_protocols.lua** : Protocoles DMX/RDM

#### 6. **window_sheet/** (4 fichiers) - Vues en feuille

Feuilles de données (spreadsheet) pour édition en masse :

- **window_fixture_sheet.lua** : Feuille des projecteurs
- **window_dmx_sheet.lua** : Carte DMX
- **window_sequence_sheet.lua** : Feuille des séquences
- **window_content_sheet.lua** : Contenu des objets

#### 7. **window_other/** (43 fichiers) - Fenêtres diverses

Fenêtres fonctionnelles variées :

- **window_command_line.lua** : Ligne de commande
- **window_encoder_bar_content.lua** : Contenu des encodeurs
- **window_layout_view.lua** : Vue de layout
- **window_playbacks.lua** : Vue des playbacks
- **window_rdm.lua** : Configuration RDM
- **window_smart_view.lua** : Vue intelligente
- **window_timecode.lua** : Éditeur timecode

#### 8. **overlays/** (35 fichiers) - Overlays et menus

Overlays qui se superposent à l'interface :

- Menus contextuels
- Sélecteurs rapides
- Palettes de couleurs
- Contrôles temporaires

#### 9. **input/** (54 fichiers) - Contrôles d'entrée

Composants d'entrée réutilisables :

- Champs de texte
- Sliders
- Boutons
- Sélecteurs
- Encodeurs virtuels

---

## 🔄 Intégration dans l'écosystème grandMA3

### Architecture de communication

```
┌─────────────────────────────────────────────────────────┐
│                    Console grandMA3                      │
│  ┌───────────────────────────────────────────────────┐  │
│  │           Interface Utilisateur (UI)              │  │
│  │              (lib_menus/ui/*.lua)                 │  │
│  └─────────────────┬─────────────────────────────────┘  │
│                    │                                     │
│  ┌─────────────────▼─────────────────────────────────┐  │
│  │         Utilitaires & Helpers                     │  │
│  │   (gma3_helpers, gma3_objects, gma3_strings)      │  │
│  └─────────────────┬─────────────────────────────────┘  │
│                    │                                     │
│  ┌─────────────────▼─────────────────────────────────┐  │
│  │          API grandMA3 Native (C++)                │  │
│  │   Cmd(), Root(), DataPools, Fixtures, etc.        │  │
│  └─────────────────┬─────────────────────────────────┘  │
└────────────────────┼─────────────────────────────────────┘
                     │
        ┌────────────┼────────────┐
        │            │            │
   ┌────▼───┐   ┌───▼────┐   ┌──▼─────┐
   │  DMX   │   │ MANet  │   │ Réseau │
   │ (Art-  │   │(Backup)│   │ (HTTP/ │
   │  Net,  │   │        │   │ OSC)   │
   │  sACN) │   │        │   │        │
   └────────┘   └────────┘   └────────┘
```

### Flux de travail typique

1. **Utilisateur** : Interagit avec l'UI (ex: clic sur un bouton)
2. **UI Module** : Déclenche une fonction signal
3. **Helpers** : Traitent les données (formatage, validation)
4. **API Native** : Exécute la commande grandMA3
5. **Moteur** : Met à jour le show (fixtures, séquences, etc.)
6. **Sortie** : DMX/réseau vers les projecteurs

### Exemple concret : Ajouter un projecteur

```lua
-- 1. UI : insert_fixtures_wizard.lua collecte les données
local fixtureData = {
    name = "LED Par 1",
    quantity = 10,
    dmxAddress = 1,
    fixtureID = 1,
    fixtureType = "Generic LED PAR"
}

-- 2. Helpers : Valident les données
local helpers = require('gma3_helpers')
local isValid = helpers:validateDMXAddress(fixtureData.dmxAddress)

-- 3. Objects : Créent les objets
local objects = require('gma3_objects')
-- Utilise l'API native via Cmd()
Cmd(string.format("Patch Fixture %d at %d", 
    fixtureData.fixtureID, 
    fixtureData.dmxAddress))

-- 4. Résultat : Projecteurs créés dans le patch
-- 5. Sortie : DMX envoyé aux adresses configurées
```

---

## 💻 Installation et compatibilité

### Prérequis

- **grandMA3 Software** : Version 1.6+ recommandée
  - Console grandMA3 (full-size, light, compact)
  - grandMA3 onPC (Windows/Mac)
  - grandMA3 onPC command wing

- **Lua** : Version 5.3 (intégrée à grandMA3)
  - Pas d'installation externe nécessaire
  - Interpréteur Lua fourni par MA Lighting

### Installation des bibliothèques

#### Méthode 1 : Importation manuelle

1. **Télécharger** ce repository
2. **Copier** les fichiers `.lua` dans le dossier de plugins grandMA3 :
   - **Windows** : `C:\ProgramData\MALightingTechnology\gma3_library\datapools\plugins\`
   - **macOS** : `/Users/Shared/MALightingTechnology/gma3_library/datapools/plugins/`
   - **Console** : `/gma3/datapools/plugins/`

3. **Charger** depuis la console :
   ```lua
   -- Dans un plugin ou la ligne de commande Lua
   local helpers = require('gma3_helpers')
   local json = require('json')
   ```

#### Méthode 2 : Via showfile

1. **Importer** les fichiers dans un showfile
2. **Menu** : `Backup` → `Import` → Sélectionner les `.lua`
3. Les scripts deviennent disponibles dans le show

### Compatibilité

| Composant | grandMA3 v1.6+ | grandMA2 | Lua standalone |
|-----------|----------------|----------|----------------|
| json.lua | ✅ | ✅ | ✅ |
| gma3_helpers.lua | ✅ | ❌ | ⚠️ (partiel) |
| gma3_objects.lua | ✅ | ❌ | ❌ |
| lib_menus/ui/* | ✅ | ❌ | ❌ |
| LuaSocket | ✅ | ✅ | ✅ |

**Notes** :
- ⚠️ Les modules `gma3_*` nécessitent l'API grandMA3 native
- ⚠️ `lfs` (LuaFileSystem) est inclus dans grandMA3 mais pas en Lua standard
- ✅ `json.lua` est utilisable dans n'importe quel environnement Lua

---

## 📚 Exemples d'utilisation

### Exemple 1 : Créer une séquence automatiquement

```lua
local helpers = require('gma3_helpers')
local objects = require('gma3_objects')

-- Accéder au pool de séquences
local seqPool = Root().ShowData.DataPools.Default.Sequences

-- Créer une nouvelle séquence
local newSeq = objects:create(seqPool, "Auto Sequence 1")

-- Ajouter un cue
Cmd("Store Sequence 1 Cue 1")
Cmd("Label Sequence 1 Cue 1 'Opening'")

-- Configurer le timing
Cmd("Assign Sequence 1 Cue 1 Fade 3")
Cmd("Assign Sequence 1 Cue 1 Delay 0.5")

-- Afficher les propriétés
helpers:dumpObj(newSeq)
```

### Exemple 2 : Exporter la configuration en JSON

```lua
local json = require('json')
local helpers = require('gma3_helpers')

-- Collecter les données du show
local showData = {
    showName = Root().ShowData.ShowFile.name,
    sequences = {},
    fixtures = {}
}

-- Récupérer toutes les séquences
local seqPool = Root().ShowData.DataPools.Default.Sequences
for i = 1, seqPool:Count() do
    local seq = seqPool[i]
    if seq then
        table.insert(showData.sequences, {
            name = seq.name,
            index = seq.index,
            cueCount = seq.Cues:Count()
        })
    end
end

-- Convertir en JSON
local jsonString = json.encode(showData)

-- Sauvegarder dans un fichier
local file = io.open("/path/to/export.json", "w")
file:write(jsonString)
file:close()

Printf("Export réussi : %d séquences exportées", #showData.sequences)
```

### Exemple 3 : Interface web de contrôle

```lua
local webserver = require('gma3_webserver')
local json = require('json')

-- Démarrer le serveur web sur le port 8080
webserver:start(8080)

-- Définir une route pour obtenir l'état
webserver:addRoute("/api/status", function(request)
    local status = {
        online = true,
        activePlaybacks = 5,
        selectedFixtures = Cmd("GetSelectedFixtures")
    }
    return {
        status = 200,
        body = json.encode(status),
        headers = {["Content-Type"] = "application/json"}
    }
end)

-- Route pour déclencher une séquence
webserver:addRoute("/api/go/:seqId", function(request)
    local seqId = request.params.seqId
    Cmd("Go+ Sequence " .. seqId)
    return {
        status = 200,
        body = json.encode({success = true})
    }
end)

Printf("Serveur web démarré : http://console-ip:8080")
```

### Exemple 4 : Assistant de patch personnalisé

```lua
local helpers = require('gma3_helpers')
local objects = require('gma3_objects')

function patchLEDGrid(startX, startY, cols, rows, startDMX)
    local fixtureType = "Generic LED PAR"
    local dmxPerFixture = 4  -- RGBW
    
    local currentDMX = startDMX
    local fixtureID = 1
    
    for row = 1, rows do
        for col = 1, cols do
            -- Calculer la position
            local x = startX + (col - 1) * 2  -- 2m d'espacement
            local y = startY + (row - 1) * 2
            
            -- Patcher le projecteur
            Cmd(string.format("Patch Fixture %d at %d", fixtureID, currentDMX))
            Cmd(string.format("Assign Fixture %d /x=%d /y=%d", fixtureID, x, y))
            Cmd(string.format("Label Fixture %d 'LED_%d_%d'", fixtureID, row, col))
            
            -- Incrémenter
            fixtureID = fixtureID + 1
            currentDMX = currentDMX + dmxPerFixture
            
            -- Pause pour la stabilité
            coroutine.yield()
        end
    end
    
    Printf("Grid patché : %d projecteurs (%dx%d)", fixtureID - 1, cols, rows)
end

-- Utilisation
local coFunc = coroutine.create(function()
    patchLEDGrid(0, 0, 10, 5, 1)  -- Grille 10x5 à partir de DMX 1
end)

-- Exécuter progressivement
coroutine.resume(coFunc)
```

### Exemple 5 : Monitoring et alertes

```lua
local helpers = require('gma3_helpers')
local json = require('json')

-- Fonction de monitoring
function monitorSystem()
    local issues = {}
    
    -- Vérifier les fixtures avec erreurs
    local fixtures = Root().ShowData.LivePatch.Fixtures
    for i = 1, fixtures:Count() do
        local fix = fixtures[i]
        if fix and fix.Status == "Error" then
            table.insert(issues, {
                type = "fixture_error",
                name = fix.name,
                dmx = fix.Address
            })
        end
    end
    
    -- Vérifier l'espace disque
    local diskUsage = helpers:osExecuteWithResult("df -h / | tail -1")
    if diskUsage and string.match(diskUsage, "([0-9]+)%%") then
        local percent = tonumber(string.match(diskUsage, "([0-9]+)%%"))
        if percent > 90 then
            table.insert(issues, {
                type = "disk_space",
                usage = percent
            })
        end
    end
    
    -- Alerter si problèmes
    if #issues > 0 then
        Printf("⚠️ ALERTES SYSTÈME : %d problèmes détectés", #issues)
        helpers:printTable(issues)
    end
    
    return issues
end

-- Lancer le monitoring toutes les 60 secondes
local function startMonitoring()
    while true do
        monitorSystem()
        helpers:wait(60)
    end
end

-- Démarrer en coroutine
coroutine.wrap(startMonitoring)()
```

---

## 🎨 Cas d'usage avancés

### Synchronisation multi-consoles

```lua
-- Console Master envoie l'état via HTTP
local json = require('json')
local http = require('socket.http')

function syncToBackup()
    local state = {
        activeSeq = CurrentSequence(),
        masterLevel = GetMasterFader()
    }
    
    http.request{
        url = "http://backup-console/sync",
        method = "POST",
        headers = {["Content-Type"] = "application/json"},
        source = ltn12.source.string(json.encode(state))
    }
end
```

### Intégration OSC (Open Sound Control)

```lua
local socket = require('socket')
local helpers = require('gma3_helpers')

-- Recevoir des commandes OSC
local udp = socket.udp()
udp:setsockname("*", 8000)

while true do
    local data, ip = udp:receivefrom()
    if data then
        -- Parser le message OSC et exécuter
        local address, value = parseOSC(data)
        Cmd(string.format("Set Fixture %d At %d", address, value))
    end
    helpers:wait(0.01)
end
```

---

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. **Fork** ce repository
2. **Créer** une branche pour votre fonctionnalité (`git checkout -b feature/AmazingFeature`)
3. **Commiter** vos changements (`git commit -m 'Add amazing feature'`)
4. **Pousser** vers la branche (`git push origin feature/AmazingFeature`)
5. **Ouvrir** une Pull Request

### Lignes directrices

- ✅ Documenter les nouvelles fonctions en français
- ✅ Tester sur grandMA3 v1.6+
- ✅ Respecter le style de code existant
- ✅ Ajouter des exemples d'utilisation

---

## 📄 Licence

Ce projet est distribué sous licence **MIT**. Voir le fichier `LICENSE` pour plus de détails.

### Bibliothèques tierces

- **json.lua** : Copyright (c) 2019 rxi - MIT License
- **LuaSocket** : Copyright (c) Diego Nehab - MIT License
- **mobdebug** : Copyright (c) Paul Kulchenko - MIT License
- **vscode-debuggee** : Copyright (c) actboy168 - MIT License

---

## 📞 Support et ressources

### Documentation officielle

- 🌐 [MA Lighting - Site officiel](https://www.malighting.com)
- 📖 [grandMA3 Manual](https://help.malighting.com/grandMA3/)
- 💻 [Lua API Documentation](https://help.malighting.com/grandMA3/Lua/)

### Communauté

- 💬 [Forum MA Lighting](https://forum.malighting.com/)
- 🎓 [MA Lighting Academy](https://www.malighting.com/academy/)
- 🎥 [Tutoriels YouTube](https://www.youtube.com/MALightingTV)

### Contact du développeur

Pour des questions spécifiques à ce repository :
- 📧 Ouvrir une issue sur GitHub
- 💡 Proposer des améliorations via Pull Request

---

![grandMA3 Interface](./images/grandma3-interface-placeholder.png)
*Image : Interface utilisateur grandMA3 avec scripts Lua actifs*

---

**Développé avec ❤️ pour la communauté grandMA3**

*Dernière mise à jour : 2024*
