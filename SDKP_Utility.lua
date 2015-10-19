-- -----------------------------------------------------------------------------
-- SDKP_Utility
-- -----------------------------------------------------------------------------
-- Author: Luma
-- Server: Emerald Dream, Feenix
-- -----------------------------------------------------------------------------

-- =============================================================================
-- DKP FIXER
-- =============================================================================
function SimpleDKP_fixDKP()
    -- sets everyones dKP to zero
    --[[
    local i = 1
    while GetGuildRosterInfo(i) ~= nil do
        local name, rank = GetGuildRosterInfo(i)
        if rank ~= "Social" or rank ~= "Alt" or rank ~= "Officer Alts" then
            SimpleDKP_writeOfficerNote(0, name)
        end
        i = i+1
    end
    --]]

    -- up to date 23.07.14
    local setDKP = {
        [1] = {"Ilydur", 495},
        [2] = {"Litlefeather", 255},
        [3] = {"Riccoh", 0},
        [4] = {"Thygeuner", 245},
        [5] = {"Cloudly", 225},
        [6] = {"Footchapuk", 245},
        [7] = {"Jugreh", 355},
        [8] = {"Narin", 150},
        [9] = {"Scylla", 335},
        [10] = {"Adobi", 365},
        [11] = {"Arondra", 500},
        [12] = {"Buscha", 250},
        [13] = {"Cibee", 695},
        [14] = {"Doflol", 280},
        [15] = {"Fluktare", 315},
        [16] = {"Panulo", 670},
        [17] = {"Ramabbalah", 260},
        [18] = {"Eranor", 515},
        [19] = {"Geraldine", 350},
        [20] = {"Hammertimezz", 150},
        [21] = {"Hodorianos", 150},
        [22] = {"Takith", 515},
        [23] = {"Uzgrannor", 310},
        [24] = {"Zeraton", 575},
        [25] = {"Holygurl", 0},
        [26] = {"Graye", 265},
        [27] = {"Karabaja", 720},
        [28] = {"Kiona", 695},
        [29] = {"Malachim", 405},
        [30] = {"Thalenys", 640},
        [31] = {"Tomsonsvk", 225},
        [32] = {"Apux", 400},
        [33] = {"Baddi", 650},
        [34] = {"Crnjalol", 270},
        [35] = {"Evilgold", 600},
        [36] = {"Korupted", 250},
        [37] = {"Revushka", 160},
        [38] = {"Rolig", 290},
        [39] = {"Femdom", 50},
        [40] = {"Hyac", 470},
        [41] = {"Jotunmorkr", 535},
        [42] = {"Malago", 160},
        [43] = {"Moondragons", 25},
        [44] = {"Pikkuhousut", 735},
        [45] = {"Raveni", 400},
        [46] = {"Trafalgarr", 310},
        [47] = {"Funbags", 770},
        [48] = {"Hjuke", 555},
        [49] = {"Klone", 775},
        [50] = {"Luma", 745},
        [51] = {"Oldwarf", 240},
        [52] = {"Pepsimaax", 365},
        [53] = {"Shirotaro", 620},
        [54] = {"Torva", 325},
        [55] = {"Tsaza", 630},
        [56] = {"Lynn", 115},
        [57] = {"Gilberto", 580},
    }

    for i=1, table.getn(setDKP) do
        local name = setDKP[i][1]
        local dkpAmount = setDKP[i][2]
        SimpleDKP_print(name)
        SimpleDKP_writeOfficerNote(dkpAmount, name)
    end

    SimpleDKP_print("SimpleDKP: Updated everyones DKP to match values given in file (copied from website).")
end


-- =============================================================================
-- PRINT MSG TO CHAT FRAME
-- =============================================================================
function SimpleDKP_print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(msg)
end

-- =============================================================================
-- SEND MSG TO RAID CHAT
-- =============================================================================
function SimpleDKP_raidChat(msg)
    SendChatMessage(msg, "RAID")
end

-- =============================================================================
-- SEND MSG TO RAID WARNING
-- =============================================================================
function SimpleDKP_raidWarning(msg)
    SendChatMessage(msg, "RAID_WARNING")
end

-- =============================================================================
-- SEND MSG TO PLAYER VIA WHISPER
-- =============================================================================
function SimpleDKP_whisperPlayer(msg, toPlayer)
    SendChatMessage(msg, "WHISPER", nil, toPlayer)
end

-- =============================================================================
-- ROUNDING
-- =============================================================================
function SimpleDKP_RoundUp(num, next)
    num = num / next
    num = math.floor(num + 0.8)
    num = num * next
    return num
end

-- =============================================================================
-- HELPER METHODS
-- Gets the command part of whispers starting with !bid
-- =============================================================================
function SimpleDKP_GetCmd(msg)
    if msg then
        local a,b,c=strfind(msg, "(%S+)") -- contiguous string of non-space characters
        if a then
            return c, strsub(msg, b+2)
        else    
            return ""
        end
    end
end

function SimpleDKP_GetCommaCmd(msg)
    if msg then
        local a = strfind(msg, ",")
        if a then
            local first = strtrim(strsub(msg,0, a-1))
            local second = strtrim(strsub(msg,a+1))
            return first, second
        else    
            return msg
        end
    end
end

-- =============================================================================
-- FIND PLAYERS GUILD INDEX
-- =============================================================================
function SimpleKDP_guildIndexByName(playerName)
    local i = 1
    while GetGuildRosterInfo(i) ~= nil do
        if GetGuildRosterInfo(i) == playerName then
            return i
        end
        i = i+1
    end
    return nil
end

-- =============================================================================
-- FIND PLAYERS RAID INDEX
-- =============================================================================
function SimpleKDP_raidIndexByName(playerName)
    for i=0, GetNumRaidMembers() do 
        if GetUnitName("raid"..i) == playerName then
            return i
        end
    end
    return nil
end

-- =============================================================================
-- FIND PLAYER GUILD RANK
-- =============================================================================
function SimpleKDP_grankByName(playerName)
    local index = SimpleKDP_guildIndexByName(playerName)

    local name, rankName, rankIndex = GetGuildRosterInfo(index)

    -- fixing priorities as some ranks should be conisdered the same rank
    -- using rankIndex to differentiate between ranks priorites

    if (rankName == "God" or rankName == "Officer" or rankName == "Class Lead" or rankName == "Sergeant" or rankName == "Core Raider") then 
        rankIndex = 4
    elseif (rankName == "Raider") then
        rankIndex = 3
    elseif (rankName == "Trial") then
        rankIndex = 2
    elseif (rankName == "Social") then
        rankIndex = 1
    elseif (rankName == "Officer Alts" or rankName == "Alt") then
        rankIndex = 0
    else
        rankIndex = -1
    end

    return rankName, rankIndex
end

-- =============================================================================
-- FIND PLAYER CLASS
-- =============================================================================
function SimpleKDP_playerClass(playerName)
    local index = SimpleKDP_guildIndexByName(playerName)

    local name, rank, rankIndex, level, playerClass = GetGuildRosterInfo(index)

    SimpleDKP_print(playerClass)

    return playerClass
end

-- =============================================================================
-- ROUNDING BIDS
-- =============================================================================
function SimpleDKP_roundUp(num, next)
    num = num / next
    num = math.floor(num + 0.8)
    num = num * next
    --ChatFrame1:AddMessage(num)
    return num
end

-- =============================================================================
-- UPDATE DKP
-- =============================================================================
function SimpleDKP_updateDKP(addDKP, playerName)
    -- use negative value to subtract DKP
    local currentDKP = SimpleDKP_readOfficerNote(playerName)
    local _, somerthing, mainName = strfind(currentDKP, "(%a+)")
    if mainName ~= nil then
        -- alt character, reward the main
        currentDKP = SimpleDKP_readOfficerNote(mainName)
        local newDKP = (addDKP) + (currentDKP)
        SimpleDKP_writeOfficerNote(newDKP, mainName)
    else
        -- main character
        --SimpleDKP_print("MAIN OR NO MAIN NAME FOUND: "..playerName)
        local newDKP = (addDKP) + (currentDKP)
        SimpleDKP_writeOfficerNote(newDKP, playerName)
    end
end

-- !!! TEMP FUNCTION !!!
-- rewards attending players with DKP
function SimpleDKP_rewardAttendanceDKP()
    SetGuildRosterShowOffline(false)

    local playersAwarded = {}

    --local debugCount = 0

    for i=1, GetNumGuildMembers() do
        local name, rank = GetGuildRosterInfo(i)
        local dkpAward = 50
        if rank ~= "Social" then
            -- not rewarding socials with DKP
            if rank == "Alt" or rank == "Officer Alts" then
                -- get main name
                local _, somerthing, mainName = strfind(SimpleDKP_readOfficerNote(name), "(%a+)")
                if mainName ~= nil and playersAwarded[mainName] == nil then
                    SimpleDKP_updateDKP(dkpAward, mainName)
                    playersAwarded[mainName] = true

                    --SimpleDKP_print("DEBUG: ALT "..name.." REWARDING "..mainName)
                    --debugCount = debugCount + 1
                end
            else
                -- this is a main
                if playersAwarded[name] == nil then
                    playersAwarded[name] = true
                    SimpleDKP_updateDKP(dkpAward, name)

                    --SimpleDKP_print("DEBUG: REWARDING "..name)
                    --debugCount = debugCount + 1
                end
            end
        end
    end

    --SimpleDKP_print("DEBUG: awarded "..debugCount.." players with DKP.")

    SimpleDKP_print("SimpleDKP: 50 DKP awarded to all attending players.")
    SimpleDKP_raidWarning("SimpleDKP: 50 DKP awarded to all attending players.")
end

-- =============================================================================
-- LOG AUCTION
-- =============================================================================
function SimpleDKP_logAuction(itemLink, winner, dkpCost)
    -- saves winner, item and itemCost to saved vars
    local dateToday = date("%Y-%m-%d")
    local timeToday = date("%H:%M:%S")
    local itemID, itemName = SimpleDKP_ItemInfo(itemLink)

    if SimpleDKP_LootTable[dateToday] == nil then
        SimpleDKP_LootTable[dateToday] = {}
    end
    
    SimpleDKP_LootTable[dateToday][timeToday] = {
        ["item"] = itemName,
        ["itemID"] = itemID,
        ["dkp"] = dkpCost,
        ["player"] = winner,
    }

    SimpleDKP_print("SimpleDKP: Updated log file with item ("..itemName..") to "..winner.." for "..dkpCost.." DKP.")
end

-- =============================================================================
-- WRITE TO OFFICER NOTE
-- aka: write DKP
-- =============================================================================
function SimpleDKP_writeOfficerNote(dkp, playerName)
    local index = SimpleKDP_guildIndexByName(playerName)
    local name, rank, rankIndex, level, playerClass, playerLocation, publicNote, officerNote = GetGuildRosterInfo(index)
    local _, something, restOfNote = strfind(officerNote, "](.+)")
    
    if restOfNote == nil then restOfNote = "" end
    note = "[DKP:"..dkp.."]"..restOfNote
    GuildRosterSetOfficerNote(index, note)
end

-- =============================================================================
-- READ FROM OFFICER NOTE
-- aka: read DKP
-- =============================================================================
function SimpleDKP_readOfficerNote(playerName)
    local index = SimpleKDP_guildIndexByName(playerName)
    local name, rank, rankIndex, level, playerClass, playerLocation, publicNote, officerNote = GetGuildRosterInfo(index)

    -- making sure DKP is returned as a number
    local _, something, currentDKP = strfind(officerNote, "DKP:(%w+)")

    if currentDKP == nil then
        -- checks if player has a negative DKP amount
        _, something, currentDKP = strfind(officerNote, "DKP:([%-]%d+)")
        if currentDKP == nil then
            -- no DKP found,  set DKP to zero
            currentDKP = 0
            SimpleDKP_writeOfficerNote(currentDKP, playerName)
        end
    end

    return currentDKP
end

-- =====================================================================
-- EXTRACT itemName AND itemID FROM ITEM LINK
-- =====================================================================
function SimpleDKP_ItemInfo(itemLink)
    local _, something, itemName = strfind(itemLink, "|h(.+)|h") -- itemName
    local _, something, itemID = strfind(itemLink, "item:(%d+)") -- item ID

    return itemID, itemName
end