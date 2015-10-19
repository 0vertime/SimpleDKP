-- -----------------------------------------------------------------------------
-- SimpleDKP
-- -----------------------------------------------------------------------------
-- Author: Luma
-- Server: Emerald Dream, Feenix
-- -----------------------------------------------------------------------------
-- HOW THIS ADDON IS ORGANIZED:
-- The addon is grouped into series of files which holds code for certain
-- functions.
--
-- SimpleDKP            Code to handle start / registering events and event
--                      handlers. This is the main entry point of the addon and
--                      directs events to the functionality in the other files.
--
-- SDKP_Whispers        Implementations of the Whisper DKP feature.
--
-- SDKP_Utility         Utility and helper methods. For example, methods
--                      to find out a users guild or print something to the
--                      screen.
--
-- SDKP_ItemList        Config file for priorities on items. 
--
--
-- SDKP_Bidding         Implementations of bidding and determining winner of
--                      the given auction.
--
-- SDKP_Announcements   Config file for all announcements the addon uses.
--
-- -----------------------------------------------------------------------------

local version = "v3.4"

-- =============================================================================
-- -------------------------------- CONFIG -------------------------------------
-- ----  The below values can be changed to alter the behavior of the addon ----
-- =============================================================================
SimpleDKP_minimumMS         =   25  -- minimum cost on MS items
SimpleDKP_minimumOS         =   15  -- minimum cost on OS items
SimpleDKP_minimumInterval   =   5   -- minimum bid interval
SimpleDKP_biddingTime       =   10  -- total time (seconds * 2) to bid on items

-- =============================================================================
-- EVENT: CHAT_MSG_WHISPER
-- =============================================================================
function SimpleDKP_CHAT_MSG_WHISPER()
    SimpleDKP_WhisperDKP_Event()
    SimpleDKP_bidEventHandler()
end

-- =============================================================================
-- EVENT: ADDON_LOADED
-- =============================================================================
function SimpleDKP_ADDON_LOADED()

    -- Checks if LootTable is loaded from saved vars.
    if (SimpleDKP_LootTable == nil) then
        SimpleDKP_LootTable = {}
    end

    -- unregister event to avoid trying to trigger again
    SimpleDKP:UnregisterEvent("ADDON_LOADED")

    -- place a hook on the chat frame so we can filter out whispers
    SimpleDKP_Register_WhisperHook()

    -- inform the user that the addon is loaded properly
    SimpleDKP_print("|cff83ABDD- SimpleDKP "..version.." Loaded.")
end

-- =============================================================================
-- EVENT HANDLER
-- =============================================================================
function SimpleDKP_OnEvent()
    if (event=="CHAT_MSG_WHISPER") then
        SimpleDKP_CHAT_MSG_WHISPER()
    elseif (event=="ADDON_LOADED" and arg1=="_SimpleDKP") then
        SimpleDKP_ADDON_LOADED()
    end
end

-- =============================================================================
-- INITILIZATION
-- =============================================================================

-- create a frame to interaction with game events
SimpleDKP = CreateFrame("Frame")

-- register events
SimpleDKP:RegisterEvent("ADDON_LOADED")
SimpleDKP:RegisterEvent("CHAT_MSG_WHISPER")

-- redirect events
SimpleDKP:SetScript("OnEvent", SimpleDKP_OnEvent)


-- =====================================================================
-- HELP COMMANDS
-- =====================================================================
SLASH_SIMPLEDKP1 = "/sdkp"
function SlashCmdList.SIMPLEDKP(msg, editbox)
   SimpleDKP_print("|cff83ABDDSimpleDKP Slash Commands")
   SimpleDKP_print("|cff83ABDD /start [itemLink]                   - starts an auction")
   SimpleDKP_print("|cff83ABDD /attendance                        - awards attendance DKP")
   SimpleDKP_print("|cff83ABDD /award dkpAmount playerName   - award (-)DKP to player")
   SimpleDKP_print("|cff83ABDD /alt altName mainName            - connects alts to mains")
end

-- =====================================================================
-- TEMP: Starting bids command
-- =====================================================================
SLASH_SIMPLEDKP_BID1 = "/start"
function SlashCmdList.SIMPLEDKP_BID(msg, editbox)
    if msg == "" or msg == "help" or GetNumRaidMembers() == 0 then
        SimpleDKP_print("|cff83ABDDSimpleDKP: /start <itemLink> to start a bid")
    else
        SimpleDKP_startAuction(msg)
    end
end

-- =====================================================================
-- TEMP: Award DKP individually
-- =====================================================================
SLASH_SIMPLEDKP_AWARD1 = "/award"
function SlashCmdList.SIMPLEDKP_AWARD(msg, editbox)
    local _, something, dkpAmount = strfind(msg, "([%-]%d+) ")
    local _, something, playerName = strfind(msg, " (%a+)")
    if dkpAmount == nil then
        -- not a negative value
        _, something, dkpAmount = strfind(msg, "(%d+) ")
    end

    if dkpAmount == nil or playerName == nil then
        SimpleDKP_print("|cff83ABDDSimpleDKP: /award dkpAmount playerName")
    else
        SimpleDKP_updateDKP(dkpAmount, playerName)
        SimpleDKP_print("|cff83ABDDSimpleDKP: Awarded "..dkpAmount.." DKP to "..playerName..".")
    end
end

-- =====================================================================
-- TEMP: Award Attendance DKP
-- =====================================================================
SLASH_SIMPLEDKP_ATTENDANCE1 = "/attendance"
function SlashCmdList.SIMPLEDKP_ATTENDANCE(msg, editbox)
    SimpleDKP_rewardAttendanceDKP()
end

-- =====================================================================
-- TEMP: Set alt character
-- =====================================================================
SLASH_SIMPLEDKP_ALT1 = "/alt"
function SlashCmdList.SIMPLEDKP_ALT(msg, editbox)
    local _, something, mainName = strfind(msg, "(%w+) ")
    local _, something, altName = strfind(msg, " (%w+)")

    if mainName == nil or altName == nil then
        SimpleDKP_print("|cff83ABDDSimpleDKP: /alt mainName altName")
    else
        SimpleDKP_writeOfficerNote(mainName, altName)
        SimpleDKP_print("|cff83ABDDSimpleDKP: "..altName.." (alt) is now connected to "..mainName.." (main).")
    end
end
--]]