-- -----------------------------------------------------------------------------
-- SDKP_Whispers
-- -----------------------------------------------------------------------------
-- Author: Luma
-- Server: Emerald Dream, Feenix
-- -----------------------------------------------------------------------------

-- A reference to the original chat frame event hook as we will replace it
local SimpleDKP_ChatFrame_OnEvent_Original = nil

-- =============================================================================
-- WHISPER HOOK
-- =============================================================================
function SimpleDKP_Register_WhisperHook()
    if (ChatFrame_OnEvent ~= SimpleDKP_ChatFrame_OnEvent_Hook) then
        SimpleDKP_ChatFrame_OnEvent_Original = ChatFrame_OnEvent
        ChatFrame_OnEvent = SimpleDKP_ChatFrame_OnEvent_Hook
    end
end

-- =============================================================================
-- EVENT HANDLER
-- =============================================================================
function SimpleDKP_WhisperDKP_Event()
    local playerName = arg2
    local trigger = arg1

    -- checks if its a valid whisper for this addon
    if (SimpleDKP_IsSimpleDKPWhisper(playerName, trigger)) then
        -- they want to know their dkp
        if(string.find(string.lower(trigger), "!dkp")==1) then
            local currentDKP = SimpleDKP_readOfficerNote(playerName)
            SimpleDKP_whisperPlayer("SimpleDKP: You have "..currentDKP.." DKP.",playerName)
        end
    end
end

-- =============================================================================
-- EVENT HOOK TO FILTER WHISPERS
-- =============================================================================
function SimpleDKP_ChatFrame_OnEvent_Hook()
    if (arg1 and arg2) then
        -- incoming whisper
        if (event == "CHAT_MSG_WHISPER") then
            if (SimpleDKP_IsSimpleDKPWhisper(arg2, arg1)) then
                -- don't display whisper
                return
            end
        end
        -- outgoing whisper
        if (event == "CHAT_MSG_WHISPER_INFORM") then
            if (string.find(arg1, "^SimpleDKP: ")) then
                -- don't display whispers sent by addon
                return
			elseif (string.find(arg1, "^ShimpleDKP: ")) then
				-- don't display whispers sent by addon
				return
            end
        end
    end
    SimpleDKP_ChatFrame_OnEvent_Original(event, arg1, name)
end

-- -----------------------------------------------------------------------------
-- HELPER METHOD
-- Returns true if the passed whispers is directed towards SimpleDKP
-- -----------------------------------------------------------------------------
function SimpleDKP_IsSimpleDKPWhisper(name, trigger)
    -- if it has "SimpleDKP" in it, its an outgoing message. Ignore it.

    if (string.find(string.lower(trigger), "SimpleDKP: ")) then
        return false
	elseif (string.find(string.lower(trigger), "ShimpleDKP: ")) then
		return false
    end
    if (string.find(string.lower(trigger), "!dkp")==1 or 
        string.find(string.lower(trigger), "!m")==1 or
        string.find(string.lower(trigger), "!o")==1) then
        return true
    end
    return false
end