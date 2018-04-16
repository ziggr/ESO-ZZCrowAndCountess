ZZCrowAndCountess = {}
ZZCrowAndCountess.name                  = "ZZCrowAndCountess"
ZZCrowAndCountess.version               = "3.3.1"
ZZCrowAndCountess.curr_quest_crow       = nil
ZZCrowAndCountess.curr_quest_countess   = nil
ZZCrowAndCountess.quests_scanned        = false


local CROW_TRIBUTES = "Tributes" -- 1 Ct Cosmetics, Grooming Items
local CROW_RESPECT  = "Respect"  -- 1 Cr Dishes and Cookware?, Drinkware, Utensils
local CROW_LEISURE  = "Leisure"  -- 1 Cl Games, Toys. Dolls?
local CROW_GLITTER  = "Glitter"  -- 1  ornate armor
local CROW_MORSELS  = "Morsels"  -- 1  Elemental Essence, Supple Root, Ectoplasm
local CROW_NIBBLES  = "Nibbles"  -- 1  Carapace, Foul Hide, Daedra Husk
local COUNTESS_WINDHELM     = "Windhelm"      -- 12
local COUNTESS_RIFTEN       = "Riften"        -- 1234567
local COUNTESS_DAVONS_WATCH = "Davon's Watch" -- 1
local COUNTESS_STORMHOLD    = "Stormhold"     -- 1
local COUNTESS_MOURNHOLD    = "Mournhold"     -- 1

                    -- All "nil" here are confirmed to NOT be useful for Countess.
                    -- Crow requires more testing                           vv
local TAG_WANTED = {                                                     -- vv
  ["Artwork"                ] = { nil          , nil                   } --    nil
, ["Cosmetics"              ] = { CROW_TRIBUTES, COUNTESS_WINDHELM     } --        tributes
, ["Devices"                ] = { nil          , nil                   } --    nil
, ["Dishes and Cookware"    ] = { CROW_RESPECT , COUNTESS_RIFTEN       } --        respect, riften
, ["Dolls"                  ] = { CROW_LEISURE , COUNTESS_DAVONS_WATCH } --        leisure, davon's
, ["Drinkware"              ] = { CROW_RESPECT , COUNTESS_RIFTEN       } --        respect, riften
, ["Dry Goods"              ] = { nil          , COUNTESS_WINDHELM     } --        windhelm
, ["Fishing Supplies"       ] = { nil          , nil                   } --    nil
, ["Furnishings"            ] = { nil          , nil                   } --    nil
, ["Games"                  ] = { CROW_LEISURE , COUNTESS_DAVONS_WATCH } --        leisure, davon's
, ["Grooming Items"         ] = { CROW_TRIBUTES, nil                   } --        tributes
, ["Lights"                 ] = { nil          , nil                   } -- Ctr nil
, ["Linens"                 ] = { nil          , COUNTESS_WINDHELM     }
, ["Magic Curiosities"      ] = { nil          , nil                   } -- Ctr nil
, ["Maps"                   ] = { nil          , COUNTESS_STORMHOLD    } --        stormhold
, ["Medical Supplies"       ] = { nil          , nil                   } -- Ctr nil
, ["Musical Instruments"    ] = { nil          , nil                   } --    nil
, ["Oddities"               ] = { nil          , COUNTESS_MOURNHOLD    } --         mournhold
, ["Ritual Objects"         ] = { nil          , COUNTESS_MOURNHOLD    } --         mournhold
, ["Scrivener Supplies"     ] = { nil          , COUNTESS_STORMHOLD    } --         stormhold
, ["Smithing Equipment"     ] = { nil          , nil                   } -- Ctr nil
, ["Statues"                ] = { nil          , COUNTESS_DAVONS_WATCH } --         davon's
, ["Tools"                  ] = { nil          , nil                   } -- Ctr nil
, ["Toys"                   ] = { CROW_LEISURE , nil                   }
, ["Trifles and Ornaments"  ] = { nil          , nil                   } --    nil
, ["Utensils"               ] = { CROW_RESPECT , COUNTESS_RIFTEN       } --         respect, riften
, ["Wall Décor"             ] = { nil          , nil                   } --    nil
, ["Wardrobe Accessories"   ] = { nil          , COUNTESS_WINDHELM     } --         windhelm
, ["Writings"               ] = { nil          , COUNTESS_STORMHOLD    } --         stormhold
}
local ITEM_ID_WANTED = {
  [54385] = CROW_MORSELS -- Elemental Essence
, [54388] = CROW_MORSELS -- Supple Root
, [54384] = CROW_MORSELS -- Ectoplasm
, [54382] = CROW_NIBBLES -- Carapace
, [54381] = CROW_NIBBLES -- Foul Hide
, [54383] = CROW_NIBBLES -- Daedra Husk
}

local function error(msg)
    d("|cff3333ZZCrowAndCountess error: "..msg)
end
-- Quest Scan ----------------------------------------------------------------
-- Look for crow and countess quests

function ZZCrowAndCountess.ScanQuestJournalIf()
    if not ZZCrowAndCountess.quests_scanned then
        ZZCrowAndCountess.ScanQuestJournal()
        ZZCrowAndCountess.quests_scanned = true
    else
        d("ZZCrowAndCountess: skipping quest journal scan. Already done once.")
    end
end

function ZZCrowAndCountess.ScanQuestJournal()
    -- AVOID UNNECESSARY O(n quests) SCANS:
    -- Prefer OnQuestAdded()/OnQuestCompleted() events
    -- for more precise O(1 quest) handling instead of an O(n quests)
    -- scan every time we touch a quest.
    d("ZZCrowAndCountess: scanning quest journal...")

                        -- Start blank unless we see a crow or countess quest.
    local old = { countess = ZZCrowAndCountess.curr_quest_countess
                , crow     = ZZCrowAndCountess.curr_quest_crow
                }
    local found = ZZCrowAndCountess.FindOpenCnCQuests()
    d(found)
    ZZCrowAndCountess.curr_quest_countess = found.countess.quest_type
    ZZCrowAndCountess.curr_quest_crow     = found.crow.quest_type
    if ZZCrowAndCountess.curr_quest_countess ~= old.countess then
        d("ZZCrowAndCountess countess: "..tostring(ZZCrowAndCountess.curr_quest_countess)
            .." (was "..tostring(old.countess)..")")
    end
    if ZZCrowAndCountess.curr_quest_crow ~= old.crow then
        d("ZZCrowAndCountess crow: "..tostring(ZZCrowAndCountess.curr_quest_crow)
            .." (was "..tostring(old.crow)..")")
    end
end

function ZZCrowAndCountess.FindOpenCnCQuests()
    local found = { countess = { quest_index = nil, quest_type = nil }
                  , crow     = { quest_index = nil, quest_type = nil }
                  }
    for quest_index = 1, MAX_JOURNAL_QUESTS do
        local r = ZZCrowAndCountess.ScanQuest(quest_index)
        if r and r.countess then
            found.countess.quest_index = quest_index
            found.countess.quest_type  = r.countess
        elseif r and r.crow then
            found.crow.quest_index = quest_index
            found.crow.quest_type  = r.crow
        end
    end
    return found
end


local COUNTESS_BGTEXT = {
  [COUNTESS_WINDHELM    ] = { "windhelm"    , "cosmetics" }
, [COUNTESS_RIFTEN      ] = { "riften"      , "drinkware" }
, [COUNTESS_DAVONS_WATCH] = { "davon's"     , "games"     }
, [COUNTESS_STORMHOLD   ] = { "stormhold"   , "writings"  }
, [COUNTESS_MOURNHOLD   ] = { "mournhold"   , "oddities"  }
}
local CROW_QUEST_NAMES = {
  [CROW_LEISURE  ] = "A Matter of Leisure"
, [CROW_RESPECT  ] = "A Matter of Respect"
, [CROW_TRIBUTES ] = "A Matter of Tributes"
, [CROW_GLITTER  ] = "Glitter and Gleam"
, [CROW_NIBBLES  ] = "Nibbles and Bits"
, [CROW_MORSELS  ] = "Morsels and Pecks"

}
local COUNTESS_QUEST_NAME = "The Covetous Countess"


local function FindQuestType(quest_name)
    -- return "crow" or "countess" or nil
    if COUNTESS_QUEST_NAME == quest_name then
        return "countess"
    end

    for k,v in pairs(CROW_QUEST_NAMES) do
        if v == quest_name then
            return "crow"
        end
    end
    return nil
end

function ZZCrowAndCountess.ScanQuest(quest_index)
    local qinfo = { GetJournalQuestInfo(quest_index) }
    local r     = { crow = nil, countess = nil }
    if not (qinfo[2] and qinfo[2] ~= "") then return end
                        -- qinfo[1] quest name
                        -- qinfo[2] background text
                        -- qinfo[3] active step text
    local quest_name = qinfo[1]
    if (quest_name == COUNTESS_QUEST_NAME) then
        local all_text_list = ZZCrowAndCountess.AllQuestText(quest_index)
        local all_text = table.concat(all_text_list, "\n"):lower()
        for countess, re_list in pairs(COUNTESS_BGTEXT) do
            for _,re in ipairs(re_list) do
                if string.match(all_text, re:lower()) then
                    r.countess = countess
                end
            end
        end
    end
    for crow_quest, crow_quest_name in pairs(CROW_QUEST_NAMES) do
        if quest_name == crow_quest_name then
            r.crow = crow_quest
        end
    end
    return r
end

function ZZCrowAndCountess.AllQuestText(quest_index)
    local all_text = {}
    local qinfo = { GetJournalQuestInfo(quest_index) }
    table.insert(all_text, tostring(qinfo[1]))
    table.insert(all_text, tostring(qinfo[2]))
    table.insert(all_text, tostring(qinfo[3]))
    local step_ct = GetJournalQuestNumSteps(quest_index)
    for step_index = 1, step_ct do
        local sinfo = { GetJournalQuestStepInfo(quest_index, step_index) }
                        -- sinfo[1] step text
                        -- sinfo[5] condition count
        table.insert(all_text, tostring(sinfo[1]))

        local condition_ct = sinfo[5]
        for condition_index = 1, condition_ct do
            local cinfo = { GetJournalQuestConditionInfo(quest_index
                                        , step_index, condition_index) }
                        -- cinfo[1] condition text
            table.insert(all_text, tostring(cinfo[1]))
        end
    end
    return all_text
end

-- Tooltip Intercept ---------------------------------------------------------

-- Monkey-patch ZOS' ItemTooltip with our own after-overrides. Lets ZOS code
-- create and show the original tooltip, and then we come in and insert our
-- own stuff.
--
-- Based on CraftStore's CS.TooltipHandler().
--
function ZZCrowAndCountess.TooltipInterceptInstall()
    local tt=ItemTooltip.SetBagItem
    ItemTooltip.SetBagItem=function(control,bagId,slotIndex,...)
        tt(control,bagId,slotIndex,...)
        ZZCrowAndCountess.TooltipInsertOurText(control,GetItemLink(bagId,slotIndex))
    end
    local tt=ItemTooltip.SetLootItem
    ItemTooltip.SetLootItem=function(control,lootId,...)
        tt(control,lootId,...)
        ZZCrowAndCountess.TooltipInsertOurText(control,GetLootItemLink(lootId))
    end
    local tt=PopupTooltip.SetLink
    PopupTooltip.SetLink=function(control,link,...)
        tt(control,link,...)
        ZZCrowAndCountess.TooltipInsertOurText(control,link)
    end
    local tt=ItemTooltip.SetTradingHouseItem
    ItemTooltip.SetTradingHouseItem=function(control,tradingHouseIndex,...)
        tt(control,tradingHouseIndex,...)
        local _,_,_,_,_,_,purchase_gold = GetTradingHouseSearchResultItemInfo(tradingHouseIndex)
        ZZCrowAndCountess.TooltipInsertOurText(control
                , GetTradingHouseSearchResultItemLink(tradingHouseIndex))
    end
end

-- Copied from Dolgubon's LibLazyCrafting
function ItemLinkToItemId(item_link)
    return tonumber(string.match(item_link,"|H%d:item:(%d+)"))
end

function ZZCrowAndCountess.IsTreasure(item_link)
                        -- Stolen items, whether laundered or not
                        -- are "treasure".
    local item_type, specialized_item_type = GetItemLinkItemType(item_link)
    return (    item_type             == ITEMTYPE_TREASURE
            and specialized_item_type == SPECIALIZED_ITEMTYPE_TREASURE )
end

-- Return crow_list and countess_list of quest types that
-- require the given item_link
function ZZCrowAndCountess.ItemLinkToCrowAndCountess(item_link)
    local r = { crow_list     = {}
              , countess_list = {}
          }
                        -- Daedra Husk and such
    local item_id = ItemLinkToItemId(item_link)
    local crow = ITEM_ID_WANTED[item_id]
    if crow then
        table.insert(r.crow_list, crow)
        return r
    end

    if not ZZCrowAndCountess.IsTreasure(item_link) then return r end

                        -- Find item tags such as "Utensils" or "Dry Goods"
    local tag_ct = GetItemLinkNumItemTags(item_link)
    for i = 1,tag_ct do
        local tag_desc, tag_category = GetItemLinkItemTagInfo(item_link,i)
        if TAG_CATEGORY_TREASURE_TYPE == tag_category then
            local cc = TAG_WANTED[tag_desc]
            if not cc then
                d("Unknown tag: "..tostring(tag_desc))
            else
                if cc[1] then table.insert(r.crow_list, cc[1]) end
                if cc[2] then
                    table.insert(r.countess_list, cc[2])
                end
            end
        end
    end
    r.crow_list     = ZZCrowAndCountess.StripDuplicates(r.crow_list    )
    r.countess_list = ZZCrowAndCountess.StripDuplicates(r.countess_list)
    return r
end

function ZZCrowAndCountess.IsCurrent(crow_or_countess_list)
    if not crow_or_countess_list then
        return false
    end
    for _,c in ipairs(crow_or_countess_list) do
        if    c == ZZCrowAndCountess.curr_quest_crow
           or c == ZZCrowAndCountess.curr_quest_countess then
           return true
       end
   end
   return false
end

function ZZCrowAndCountess.StripDuplicates(list)
    local set = {}
    local dupe_seen = false
    for _,v in ipairs(list) do
        set[v] = 1 + (set[v] or 0)
        if 2 <= set[v] then
            dupe_seen = true
        end
    end
    if not dupe_seen then return list end
    local new_list = {}
    for k,_ in pairs(set) do
        table.insert(new_list, k)
    end
    return new_list
end

local COLOR_NEED_CURRENT  = "|c66FF66"
local COLOR_NEED_SOMEDAY  = "|cFFFFFF"
local COLOR_UNINTERESTING = "|c999999"

function ZZCrowAndCountess.TooltipInsertOurText(control, item_link)
    local r = ZZCrowAndCountess.ItemLinkToCrowAndCountess(item_link)
    local lines = {}

    if 0 < #r.crow_list then
        local color = COLOR_NEED_SOMEDAY
        if ZZCrowAndCountess.IsCurrent(r.crow_list) then
            color = COLOR_NEED_CURRENT
        end
        local s = color.."Crow: "..table.concat(r.crow_list, ", ").."|r"
        table.insert(lines, s)
    end
    if 0 < #r.countess_list then
        local color = COLOR_NEED_SOMEDAY
        if ZZCrowAndCountess.IsCurrent(r.countess_list) then
            color = COLOR_NEED_CURRENT
        end
        local s = color.."Countess: "..table.concat(r.countess_list, ", ").."|r"
        table.insert(lines, s)
    end
    local is_treasure = ZZCrowAndCountess.IsTreasure(item_link)
    if is_treasure and 0 == #r.crow_list and 0 == #r.countess_list then
        table.insert(lines, COLOR_UNINTERESTING.."not needed for crow or countess|r")
    end
    if 0 < #lines then
        control:AddLine(table.concat(lines, "\n"))
    end
end

-- How many of whatever do we still need to collect or steal?
function ZZCrowAndCountess.GetCountessNeedCt(quest_index)
    local jqi = { GetJournalQuestInfo(quest_index) }
    if jqi[6] then return 0 end -- is_completed   not sure if this ever goes true
    local step_ct = GetJournalQuestNumSteps(quest_index)
    for step_index = 1, step_ct do
        local sinfo = { GetJournalQuestStepInfo(quest_index, step_index) }
        -- 1 stepText "The contract requests that I steal drinkware, utensils, and dishes, launder those items to remove all traces of the original owners, and deliver them to the client, but any clean goods should do."
        -- 2 visibility nil
        -- 3 stepType 1
        -- 4 trackerOverrideText ""
        -- 5 numConditions 1
        local condition_ct = sinfo[5]
        for condition_index = 1, condition_ct do
            local cinfo = { GetJournalQuestConditionInfo(quest_index
                                        , step_index, condition_index) }
            -- 1 conditionText  "Collect "Clean" Drinkware, Utensils, and Dishes: 0/3
            -- 2 current 0
            -- 3 number 3
            -- 4 isFailCondition false
            -- 5 isComplete false
            -- 6 isCreditShared false
            -- 7 isVisible true
            if string.find(cinfo[1], "Collect") or string.find(cinfo[1], "Steal") then
                local have_ct     = cinfo[2]
                local required_ct = cinfo[3]
                if required_ct <= have_ct then return 0 end
                return required_ct - have_ct
            end
        end
    end
    return 0
end

-- Bank Fetch ----------------------------------------------------------------

function ZZCrowAndCountess.OnOpenBank()
                        -- Waste as few CPU cycles as possible if we don't
                        -- have a current crow or countess quest. Don't
                        -- make my FPS stutter every time I talk to Tythis.
    ZZCrowAndCountess.ScanQuestJournalIf()
    if not (   ZZCrowAndCountess.curr_quest_crow
            or ZZCrowAndCountess.curr_quest_countess) then
        return
    end

                        -- O(n) scan quest journal
                        -- Find open crow and countess quests. We'll need
                        -- the quest journal_index so that we can find
                        -- steps and conditions and such.
    local found = ZZCrowAndCountess.FindOpenCnCQuests()
    d("ZZCrowAndCountess: quest_index crow:"..tostring(found.crow.quest_index)
        .. " countess:"..tostring(found.countess.quest_index))

    zo_callLater(function() ZZCrowAndCountess.BankWithdrawal(found) end, 100)
end

function ZZCrowAndCountess.BankWithdrawal(open_quests)
                        -- Async callback chain to calculate and withdraw
                        -- one stack of items from the bank.
    local need_ct = ZZCrowAndCountess.GetCountessNeedCt(
                                    open_quests.countess.quest_index)
    d(string.format("ZZCrowAndCountess: countess needs %d more items.",need_ct))
    if 0 < need_ct then
        local c = ZZCrowAndCountess.FindOneBankStackCountess(
                                           open_quests.countess.quest_type
                                         , open_quests.countess.quest_index )
        if c and 0 < c.ct then
            local move_ct   = math.min(c.ct, need_ct)
            local is_moved  = ZZCrowAndCountess.WithdrawFromBank(
                                          c.bag_id
                                        , c.slot_id
                                        , move_ct )
            if (not is_moved) or (move_ct <= 0) then
                error(" could not move "..tostring(move_ct).." "..tostring(c.item_link)
                    .. " from bag:"..tostring(c.bag_id).." slot:"..tostring(c.slot_id))
                return
            end
            if need_ct <= move_ct then
                d("ZZCrowAndCountess: done withdrawing.")
                return
            end
                        -- Still need more. Loop back and try some more
            zo_callLater(function() ZZCrowAndCountess.BankWithdrawal(open_quests) end, 100)
            return
        else
                        -- Countess needs stuff, but nothing found in bank,
                        -- so give up on countess and fall through to crow.
            d("ZZCrowAndCountess: countess needs:"..tostring(need_ct)
               .." found:"..tostring(c.ct))
        end
    end

    d("ZZCrowAndCountess: nothing to do for countess, checking crow... (someday)")

                        -- Nothing to do for countess? Check crow work.
                        -- ###
end

local function MinBankSlotCandidate(a,b)
    if a and a.ct <= b.ct then
        return a
    else
        return b
    end
end

function ZZCrowAndCountess.FindOneBankStackCountess(
                  countess_quest_type
                , countess_quest_index)
                        -- O(n) bank scan to return the smallest bank stack
                        -- that satisfies the given countess quest.
    local min_candidate = nil
    for _,bag_id in ipairs({BAG_BANK, BAG_SUBSCRIBER_BANK}) do
        local slot_ct = GetBagSize(bag_id)
        for slot_id = 1,slot_ct do
            local item_link = GetItemLink(bag_id, slot_id, LINK_STYLE_DEFAULT)

                        -- Countess
            local r = ZZCrowAndCountess.ItemLinkToCrowAndCountess(item_link)
            for _,c in ipairs(r.countess_list) do
                if c == countess_quest_type then
                        -- Possible winning slot.
                    local ci = { ['bag_id']  = bag_id
                               , ['slot_id'] = slot_id
                               , ['ct']      = GetSlotStackSize(bag_id, slot_id)
                               , ['item_link'] = GetItemLink(bag_id, slot_id)
                               }
                    min_candidate = MinBankSlotCandidate(min_candidate, ci)
-- d("Found: bag_id:"..tostring(bag_id)
--         .." slot_id:"..tostring(slot_id)
--         .." ct:"..tostring(ci.ct)
--         .." "..GetItemName(bag_id, slot_id)
--         .."    min:"..min_candidate.item_link)
                end
            end
        end
    end
    return min_candidate
end

-- This only works ONCE. After that, the slots move around out from under us,
-- but from our thread, we still see the old slot_id and can't see the movement.
-- We're gonna have to async zo_calllater() this. Ugh.

function ZZCrowAndCountess.WithdrawFromBank(bag_id, slot_id, ct)
    local item_link        = GetItemLink(bag_id, slot_id)
    local backpack_slot_id = FindFirstEmptySlotInBag(BAG_BACKPACK)
d("w/d bag_id:"..tostring(bag_id).." slot_id:"..tostring(slot_id)
    .." ct:"..tostring(ct)
    .." to backback_slot_id:"..tostring(backpack_slot_id))
    if not backpack_slot_id then return false end

    if IsProtectedFunction("RequestMoveItem") then
        CallSecureProtected( "RequestMoveItem"
                           , bag_id
                           , slot_id
                           , BAG_BACKPACK
                           , backpack_slot_id
                           , ct
                           )
    else
        RequestMoveItem( bag_id
                       , slot_id
                       , BAG_BACKPACK
                       , backpack_slot_id
                       , ct
                       )
    end
    d("ZZCrowAndCountess: fetched from bank "..tostring(ct).."x "..item_link)
    return true
end


-- Quest added/completed -----------------------------------------------------

function ZZCrowAndCountess.OnQuestAdded(what, journal_index, quest_name, objective_name)
    d("ZZCrowAndCountess.OnQuestAdded() quest_name:"..tostring(quest_name)
      .." objective_name:"..tostring(objective_name))

    local quest_type = FindQuestType(quest_name)
    if quest_type == "countess" then
        local r = ZZCrowAndCountess.ScanQuest(journal_index)
        ZZCrowAndCountess.curr_quest_countess = r.countess
        d("ZZCrowAndCountess: countess "..tostring(ZZCrowAndCountess.curr_quest_countess))
    elseif quest_type == "crow" then
        local r = ZZCrowAndCountess.ScanQuest(journal_index)
        ZZCrowAndCountess.curr_quest_crow = r.crow
        d("ZZCrowAndCountess: crow "..tostring(ZZCrowAndCountess.curr_quest_crow))
    end
end

function ZZCrowAndCountess.OnQuestComplete( event
                                          , quest_name
                                          , level
                                          , previous_experience
                                          , current_experience
                                          , champion_points
                                          , quest_type
                                          , instance_display_type )
    -- d("ZZCrowAndCountess: quest complete quest_name:"..tostring(quest_name))
    local quest_type = FindQuestType(quest_name)
    if quest_type == "countess" then
        ZZCrowAndCountess.curr_quest_countess = nil
        d("ZZCrowAndCountess: countess "..tostring(ZZCrowAndCountess.curr_quest_countess))
    elseif quest_type == "crow" then
        ZZCrowAndCountess.curr_quest_crow = nil
        d("ZZCrowAndCountess: crow "..tostring(ZZCrowAndCountess.curr_quest_crow))
    end
end


-- Init ----------------------------------------------------------------------

function ZZCrowAndCountess.OnAddOnLoaded(event, addonName)
    if addonName ~= ZZCrowAndCountess.name then return end
    if not ZZCrowAndCountess.version then return end
    ZZCrowAndCountess.TooltipInterceptInstall()

    EVENT_MANAGER:RegisterForEvent( ZZCrowAndCountess.name
                                  , EVENT_QUEST_ADDED
                                  , ZZCrowAndCountess.OnQuestAdded
                                  )
    EVENT_MANAGER:RegisterForEvent( ZZCrowAndCountess.name
                                  , EVENT_QUEST_COMPLETE
                                  , ZZCrowAndCountess.OnQuestComplete
                                  )
    EVENT_MANAGER:RegisterForEvent( ZZCrowAndCountess.name
                                  , EVENT_OPEN_BANK
                                  , ZZCrowAndCountess.OnOpenBank
                                  )
    ZZCrowAndCountess.ScanQuestJournal()
end

-- Postamble -----------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent( ZZCrowAndCountess.name
                              , EVENT_ADD_ON_LOADED
                              , ZZCrowAndCountess.OnAddOnLoaded
                              )


SLASH_COMMANDS["/zzcrow"] = ZZCrowAndCountess.ScanQuestJournal
