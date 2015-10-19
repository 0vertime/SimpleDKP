-- -----------------------------------------------------------------------------
-- SDKP_Bidding
-- -----------------------------------------------------------------------------
-- Author: Luma
-- Server: Emerald Dream, Feenix
-- -----------------------------------------------------------------------------

-- =============================================================================
-- --------------------------- LOCAL VARIABLES ---------------------------------
-- =============================================================================
local SimpleDKP_bidInProgress   =   false    -- true/false if bid in progress
local SimpleDKP_corePrio        =   false   -- true/false if core prio on bid
local SimpleDKP_highestBidder   =   {}      -- stores data on the highest bidder
local SimpleDKP_UpdateInterval  =   2       -- How often the OnUpdate code will run (in seconds)
local SimpleDKP_TimerCountdown  =   SimpleDKP_biddingTime + 1 -- to fix initial seconds
local SimpleDKP_bidItem         =   ""        -- tracks which item is being bid on

-- =============================================================================
-- START AUCTION
-- =============================================================================
function SimpleDKP_startAuction(itemLink)
    SimpleDKP_corePrio = false

    -- check if item got any priority
    local itemID, itemName = SimpleDKP_ItemInfo(itemLink)
    if SimpleDKP_PrioList[itemID] and SimpleDKP_PrioList[itemID]["prio"] == 4 then
        SimpleDKP_corePrio = true
    end

    -- set variables
    SimpleDKP_highestBidder = {}
    SimpleDKP_bidInProgress = true
    SimpleDKP_bidItem = itemLink
    SimpleDKP_TimerCountdown = SimpleDKP_biddingTime

    SimpleDKP_raidWarning("SimpleDKP: Auction started for "..itemLink..". Minimum bid: !ms "..SimpleDKP_minimumMS.. " or !os "..SimpleDKP_minimumOS)

    -- start timer
    SimpleDKP_Bid_UpdateFrame:Show()
end

-- =============================================================================
-- END AUCTION
-- =============================================================================
function SimpleKDP_endAuction()
    -- stop timer
    SimpleDKP_Bid_UpdateFrame:Hide()

    -- set variables
    SimpleDKP_bidInProgress = false
    SimpleDKP_corePrio = false

    if SimpleDKP_highestBidder["bid"] ~= nil then
        -- we got a winner
        local bidType = SimpleDKP_highestBidder["bidType"]
        if bidType == 1 then bidType = "MS" else bidType = "OS" end
        SimpleDKP_raidWarning("SimpleKDP: "..SimpleDKP_highestBidder["name"].." won "..SimpleDKP_bidItem.." for ("
            ..bidType..") "..SimpleDKP_highestBidder["bid"].." DKP.")
        -- update his DKP
        SimpleDKP_updateDKP("-"..SimpleDKP_highestBidder["bid"], SimpleDKP_highestBidder["name"])

        -- save item & cost
        SimpleDKP_logAuction(SimpleDKP_bidItem, SimpleDKP_highestBidder["name"], SimpleDKP_highestBidder["bid"])

        -- clear variables
        SimpleDKP_highestBidder = {}
    else
        -- no one bid
        SimpleDKP_raidWarning("SimpleDKP: Auction ended for "..SimpleDKP_bidItem.." with no bids.")
        -- clear variables

    end
end

-- =============================================================================
-- EVENT HANDLER
-- =============================================================================
function SimpleDKP_bidEventHandler()
    local playerName = arg2
    local trigger = arg1

    -- checks if its a valid whisper for this addon
    if (SimpleDKP_IsBidChat(playerName, trigger)) and SimpleKDP_raidIndexByName(playerName) ~= nil then
        local cmd, subcmd = SimpleDKP_GetCmd(trigger)
        cmd, subcmd = SimpleDKP_GetCommaCmd(subcmd)

        -- Someone placed a bid
        if SimpleDKP_bidInProgress then 
            if (string.find(string.lower(trigger), "!m")==1) then
                -- MS bidding
                if (cmd=="") then 
                    SimpleDKP_whisperPlayer("SimpleDKP: Use the command \" !ms X \" where X is the value of the bid.",playerName)
                else
                    SimpleDKP_checkBids(cmd, 1, playerName) -- bidType = 1 = MS
                end
            elseif (string.find(string.lower(trigger), "!o")==1) then 
                -- OS bidding
                if (cmd=="") then
                    SimpleDKP_whisperPlayer("SimpleDKP: Use the command \" !os X \" where X is the value of the bid.",playerName)
                else
                    SimpleDKP_checkBids(cmd, 0, playerName) -- bidType = 0 = OS
                end
            end
        else
            SimpleDKP_whisperPlayer("SimpleDKP: There is no bid in progress.",playerName)
        end
    end
end

-- =====================================================================
-- HELPER METHOD
-- Returns true if the passed whisper is directed towards bidding
-- =====================================================================
function SimpleDKP_IsBidChat(playerName, trigger)
    if (string.find(string.lower(trigger), "!m") == 1 or
        string.find(string.lower(trigger), "!o") == 1) then
        return true
    end
    return false
end

-- =====================================================================
-- RESET COUNTDOWN
-- =====================================================================
function SimpleDKP_resetCountdown()
    SimpleDKP_TimerCountdown = SimpleDKP_biddingTime
end

-- =============================================================================
-- VALIDATING BIDS
-- =============================================================================
function SimpleDKP_checkBids(bidAmount, bidType, playerName)
    if SimpleDKP_highestBidder["name"] ~= nil and SimpleDKP_highestBidder["name"] == playerName then
        SimpleDKP_whisperPlayer("SimpleDKP: You are the highest bidder.",playerName)
        return
    end

    local rankName, rankIndex = SimpleKDP_grankByName(playerName)
    local currentDKP = SimpleDKP_readOfficerNote(playerName)

    if rankIndex == 0 then
        -- alts are not allowed to bid, only roll (otherwise they would spend main dkp which complicates things)
        SimpleDKP_whisperPlayer("SimpleDKP: Alts are not allowed to spend DKP. Use /roll.",playerName)
        return
    end

    currentDKP = currentDKP + 0

    local num = SimpleDKP_roundUp(bidAmount, SimpleDKP_minimumInterval)
        -- if minimum interval increase > total dkp go all-in
        if num < currentDKP then
             -- dkp remaining
            bidAmount = num
        else
            -- all-in
            if currentDKP > 0 then
                bidAmount = currentDKP
            else
                if bidType == 1 then bidAmount = SimpleDKP_minimumMS else bidAmount = SimpleDKP_minimumOS end
            end
        end

    local postDKP = currentDKP-bidAmount

    if SimpleDKP_corePrio == false and rankIndex == 4 then
        -- downgrade core to raider due to equal prio
        rankIndex = 3
    end

    --SimpleDKP_whisperPlayer("Your rank Index is: "..rankIndex..". This number should be 3 if you are a Raider/core, 2 if you are trial." ,playerName)

    if (SimpleDKP_highestBidder["bid"] == nil) then
        -- accept bid: first bidder
        -- make sure bid is atleast minimum OS/MS
        if bidType == 1 and bidAmount < SimpleDKP_minimumMS or bidType == 1 and postDKP < 0 then
            bidAmount = SimpleDKP_minimumMS
        elseif bidType == 0 and bidAmount < SimpleDKP_minimumOS or bidType == 0 and postDKP < 0 then
            bidAmount = SimpleDKP_minimumOS
        end
        -- update postDKP
        postDKP = currentDKP-bidAmount
        -- accept bid
        SimpleDKP_acceptBid(playerName, bidType, rankIndex, bidAmount, postDKP)
    elseif (SimpleDKP_highestBidder["rankIndex"] < rankIndex) or 
            (SimpleDKP_highestBidder["bidType"] < bidType) then
        -- accept bid: first bidder of this rank OR first MS bid
        -- set bid amount to minimum to avoid overbidding lower ranks or off-specs
        if bidType == 1 then bidAmount = SimpleDKP_minimumMS else bidAmount = SimpleDKP_minimumOS end
        -- update postDKP
        postDKP = currentDKP-bidAmount
        -- accept bid
        SimpleDKP_acceptBid(playerName, bidType, rankIndex, bidAmount, postDKP)
    elseif (postDKP < 0 and SimpleDKP_highestBidder["postDKP"] < 0 ) then
        -- negative bidding
        if bidType == 1 then bidAmount = SimpleDKP_minimumMS else bidamount = SimpleDKP_minimumOS end
        -- update post DKP
        postDKP = currentDKP-bidAmount
        if postDKP > SimpleDKP_highestBidder["postDKP"] then
            -- accept bid
            SimpleDKP_acceptBid(playerName, bidType, rankIndex, bidAmount, postDKP)
        else
            -- decline bid
            SimpleDKP_whisperPlayer("SimpleDKP: Bid declined. You are further into minus than the other bidder.",playerName)
        end
    elseif SimpleDKP_highestBidder["rankIndex"] == rankIndex then
        -- passed rank check
        if SimpleDKP_highestBidder["bidType"] <= bidType then
            -- passed MS > OS check
            if SimpleDKP_highestBidder["bid"] < bidAmount and postDKP >= 0 then
                -- accept bid
                SimpleDKP_acceptBid(playerName, bidType, rankIndex, bidAmount, postDKP)
            elseif postDKP <= 0 then
                -- decline due to not enough DKP to outbid
                SimpleDKP_whisperPlayer("SimpleDKP: Bid declined. You do not have enough DKP to outbid the highest bidder.",playerName)
            else
                -- decline due to too low bid
                SimpleDKP_whisperPlayer("SimpleDKP: Bid declined, too low. Highest bid = "..SimpleDKP_highestBidder["bid"].." DKP.",playerName)
            end
        else
            -- decline due to MS > OS
            SimpleDKP_whisperPlayer("SimpleDKP: Bid declined. Someone are bidding for Main Spec.",playerName)
        end
    else
        -- decline due to higher ranks are bidding
        SimpleDKP_whisperPlayer("SimpleDKP: Bid declined. Higher ranks are bidding with priority.",playerName)
    end
end

-- =============================================================================
-- ACCEPTING BIDS
-- =============================================================================
function SimpleDKP_acceptBid(playerName, bidType, rankIndex, bidAmount, postDKP)
    SimpleDKP_highestBidder = {
        ["name"]        = playerName,
        ["bidType"]     = bidType,
        ["rankIndex"]   = rankIndex,
        ["bid"]         = bidAmount,
        ["postDKP"]     = postDKP,
    }

    if postDKP <= 0 then
        -- allin 
        SimpleDKP_whisperPlayer("SimpleDKP: Bid accepted for "..bidAmount.." DKP. You are all-in.",playerName)
    else 
        -- dkp leftover
        SimpleDKP_whisperPlayer("SimpleDKP: Bid accepted for "..bidAmount.." DKP.",playerName)
    end

    if bidType == 1 then bidType = "MS" else bidType = "OS" end
    SimpleDKP_raidChat("SimpleDKP: Highest bid ("..bidType..") = "..bidAmount.." DKP.")
    SimpleDKP_resetCountdown()
end

-- =============================================================================
-- COUNTDOWN UPDATER
-- Timer to track bidding time and ending of auctions.
-- =============================================================================
function SimpleDKP_OnUpdate(self, elapsed)
local time = GetTime()

    if (this.TimeSinceLastUpdate < time) then

        -- decrement the countdown
        SimpleDKP_TimerCountdown = SimpleDKP_TimerCountdown - 1

        if (SimpleDKP_TimerCountdown == 5) then
            if (SimpleDKP_highestBidder["bid"] == nil) then
                -- no bidder
                SimpleDKP_raidWarning("SimpleDKP: 5 seconds left to bid. No bids.")
            else
                -- announce highest bidder
                local bidType = SimpleDKP_highestBidder["bidType"]
                if bidType == 1 then bidType = "MS" else bidType = "OS" end
                SimpleDKP_raidWarning("SimpleDKP: 5 seconds left to bid. Highest bid ("..bidType..") = "..SimpleDKP_highestBidder["bid"].." DKP.")
                SimpleDKP_whisperPlayer("SimpleDKP: You are the highest bidder.", SimpleDKP_highestBidder["name"])
            end
        elseif (SimpleDKP_TimerCountdown == 3 or SimpleDKP_TimerCountdown == 2 or SimpleDKP_TimerCountdown == 1) then
            -- announce near end
            SimpleDKP_raidChat(SimpleDKP_TimerCountdown.." seconds left to bid.")
        elseif (SimpleDKP_TimerCountdown <= 0) then
            -- end bid
            SimpleKDP_endAuction()
        end 

        this.TimeSinceLastUpdate = time + SimpleDKP_UpdateInterval
    end
end

SimpleDKP_Bid_UpdateFrame = CreateFrame("Frame")
SimpleDKP_Bid_UpdateFrame.TimeSinceLastUpdate = 0
SimpleDKP_Bid_UpdateFrame:SetScript("OnUpdate", SimpleDKP_OnUpdate)
SimpleDKP_Bid_UpdateFrame:Hide()