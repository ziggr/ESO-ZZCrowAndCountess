ZZCrowAndCountess = {}
ZZCrowAndCountess.name                  = "ZZCrowAndCountess"
ZZCrowAndCountess.version               = "3.3.1"
ZZCrowAndCountess.curr_quest_crow       = nil
ZZCrowAndCountess.curr_quest_countess   = nil

local CROW_TRIBUTES = "Tributes" -- Cosmetics, Grooming Items
local CROW_RESPECT  = "Respect"  -- Dishes and Cookware?, Drinkware, Utensils
local CROW_LEISURE  = "Leisure"  -- Games, Toys. Dolls?
local CROW_GLITTER  = "Glitter"  -- ornate armor
local CROW_MORSELS  = "Morsels"  -- Elemental Essence, Supple Root, Ectoplasm
local CROW_NIBBLES  = "Nibbles"  -- Carapace, Foul Hide, Daedra Husk
local COUNTESS_WINDHELM     = "Windhelm"
local COUNTESS_RIFTEN       = "Riften"
local COUNTESS_DAVONS_WATCH = "Davon's Watch"
local COUNTESS_STORMHOLD    = "Stormhold"
local COUNTESS_MOURNHOLD    = "Mournhold"

local TAG_WANTED = {
  ["Artwork"                ] = { nil          , nil                   }
, ["Cosmetics"              ] = { CROW_TRIBUTES, COUNTESS_WINDHELM     }
, ["Devices"                ] = { nil          , nil                   }
, ["Dishes and Cookware"    ] = { CROW_RESPECT , COUNTESS_RIFTEN       }
, ["Dolls"                  ] = { nil          , COUNTESS_DAVONS_WATCH }
, ["Drinkware"              ] = { CROW_RESPECT , COUNTESS_RIFTEN       }
, ["Dry Goods"              ] = { nil          , nil                   }
, ["Fishing Supplies"       ] = { nil          , nil                   }
, ["Furnishings"            ] = { nil          , nil                   }
, ["Games"                  ] = { CROW_LEISURE , COUNTESS_DAVONS_WATCH }
, ["Grooming Items"         ] = { CROW_TRIBUTES, nil                   }
, ["Lights"                 ] = { nil          , nil                   }
, ["Linens"                 ] = { nil          , COUNTESS_WINDHELM     }
, ["Magic Curiosities"      ] = { nil          , nil                   }
, ["Maps"                   ] = { nil          , COUNTESS_STORMHOLD    }
, ["Medical Supplies"       ] = { nil          , nil                   }
, ["Musical Instruments"    ] = { nil          , nil                   }
, ["Oddities"               ] = { nil          , COUNTESS_MORNHOLD     }
, ["Ritual Objects"         ] = { nil          , COUNTESS_MORNHOLD     }
, ["Scrivener Supplies"     ] = { nil          , COUNTESS_STORMHOLD    }
, ["Smithing Equipment"     ] = { nil          , nil                   }
, ["Statues"                ] = { nil          , COUNTESS_DAVONS_WATCH }
, ["Tools"                  ] = { nil          , nil                   }
, ["Toys"                   ] = { CROW_LEISURE , nil                   }
, ["Trifles and Ornaments"  ] = { nil          , nil                   }
, ["Utensils"               ] = { CROW_RESPECT , COUNTESS_RIFTEN       }
, ["Wall Décor"             ] = { nil          , nil                   }
, ["Wardrobe Accessories"   ] = { nil          , COUNTESS_WINDHELM     }
, ["Writings"               ] = { nil          , COUNTESS_STORMHOLD    }
}
local ITEM_ID_WANTED = {
  [54385] = CROW_MORSELS -- Elemental Essence
, [54388] = CROW_MORSELS -- Supple Root
, [54384] = CROW_MORSELS -- Ectoplasm
, [54382] = CROW_NIBBLES -- Carapace
, [54381] = CROW_NIBBLES -- Foul Hide
, [54383] = CROW_NIBBLES -- Daedra Husk
}

-- Init ----------------------------------------------------------------------

function ZZCrowAndCountess.OnAddOnLoaded(event, addonName)
    if addonName ~= ZZCrowAndCountess.name then return end
    if not ZZCrowAndCountess.version then return end
    ZZCrowAndCountess.TooltipInterceptInstall()

    local event_id_list = { EVENT_QUEST_ADDED       -- 0 needs acquire -> 1 or 2
                          , EVENT_CRAFT_COMPLETED   -- 1 needs craft   -> 2
                          , EVENT_QUEST_COMPLETE    -- 2 needs turn in -> 3
                          }
    for _, event_id in ipairs(event_id_list) do
        EVENT_MANAGER:RegisterForEvent( ZZCrowAndCountess.name
                                      , event_id
                                      , function()
                                            ZZCrowAndCountess.ScanQuestJournal()
                                        end
                                      )
    end
    ZZCrowAndCountess.ScanQuestJournal()
end


-- Quest Scan ----------------------------------------------------------------
-- Look for crow and countess quests
function ZZCrowAndCountess.ScanQuestJournal()
    local crow     = nil -- CROW_TRIBUTES
    local countess = nil -- COUNTESS_RIFTEN

    for quest_index = 1, MAX_JOURNAL_QUESTS do
        local r = ZZCrowAndCountess.ScanQuest(quest_index)
        if r and r.countess then
            ZZCrowAndCountess.curr_quest_countess = r.countess
            d("Learned countess="..tostring(ZZCrowAndCountess.curr_quest_countess))
        end
        if r and r.crow then
            ZZCrowAndCountess.curr_quest_crow = r.crow
            d("Learned crow="..tostring(ZZCrowAndCountess.curr_quest_crow))
        end
    end
end


COUNTESS_BGTEXT = {
  [COUNTESS_WINDHELM    ] = { "cosmetics", "windhelm" }
, [COUNTESS_RIFTEN      ] = { "XXX" }
, [COUNTESS_DAVONS_WATCH] = { "XXX" }
, [COUNTESS_STORMHOLD   ] = { "XXX" }
, [COUNTESS_MOURNHOLD   ] = { "XXX" }
}
function ZZCrowAndCountess.ScanQuest(quest_index)
    local qinfo = { GetJournalQuestInfo(quest_index) }
    local r     = { crow = nil, countess = nil }
    if not (qinfo[2] and qinfo[2] ~= "") then return end

    -- qinfo[1] quest name
    -- qinfo[2] background text
    -- qinfo[3] active step text
    d("name: "..tostring(qinfo[1]))
    d("bg text: "..tostring(qinfo[2]))
    d("active step: "..tostring(qinfo[3]))

    local quest_name = qinfo[1]
    if (quest_name == "The Covetous Countess") then
        local all_text_list = ZZCrowAndCountess.AllQuestText(quest_index)
        local all_text = table.concat(all_text_list, "\n"):lower()
        d("all_text:"..all_text)
        for countess, re_list in pairs(COUNTESS_BGTEXT) do
            for _,re in ipairs(re_list) do
                if string.match(all_text, re:lower()) then
                    d("current countess:"..countess)
                    r.countess = countess
                    return r
                else
                    d("re nomatch: "..re)
                end
            end
        end
    else
        d("Quest name not covetous:'"..tostring(quest_name).."'")
    end

    return r
end

            -- -- if match...
            -- -- ### FAKEY CODE
            -- ZZCrowAndCountess.curr_quest_crow     = CROW_TRIBUTES
            -- ZZCrowAndCountess.curr_quest_countess = COUNTESS_RIFTEN


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
            -- d(tag_desc)
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
    return r
end

function ZZCrowAndCountess.IsCurrent(crow_or_countess_list)
    d("curr crow    : "..tostring(ZZCrowAndCountess.curr_quest_crow))
    d("curr countess: "..tostring(ZZCrowAndCountess.curr_quest_countess))
    if not crow_or_countess_list then
        d("no")
        return false
    end
    for _,c in ipairs(crow_or_countess_list) do
        if    c == ZZCrowAndCountess.curr_quest_crow
           or c == ZZCrowAndCountess.curr_quest_countess then
           d("curr true: "..tostring(c))
           return true
       else
            d("curr false: "..tostring(c))
       end
   end
   return false
end

local COLOR_NEED_CURRENT  = "|c66FF66"
local COLOR_NEED_SOMEDAY  = "|cFFFFFF"
local COLOR_UNINTERESTING = "|c999999"

function ZZCrowAndCountess.TooltipInsertOurText(control, item_link)
    local r = ZZCrowAndCountess.ItemLinkToCrowAndCountess(item_link)

    if 0 < #r.crow_list then
        local color = COLOR_NEED_SOMEDAY
        if ZZCrowAndCountess.IsCurrent(r.crow_list) then
            color = COLOR_NEED_CURRENT
        end
        local s = color.."Crow: "..table.concat(r.crow_list, ", ").."|r"
        control:AddLine(s)
    end
    if 0 < #r.countess_list then
        local color = COLOR_NEED_SOMEDAY
        if ZZCrowAndCountess.IsCurrent(r.countess_list) then
            color = COLOR_NEED_CURRENT
        end
        local s = color.."Countess: "..table.concat(r.countess_list, ", ").."|r"
        control:AddLine(s)
    end
    local is_treasure = ZZCrowAndCountess.IsTreasure(item_link)
    if is_treasure and 0 == #r.crow_list and 0 == #r.countess_list then
        control:AddLine(COLOR_UNINTERESTING.."not needed for crow or countess|r")
    end
end


-- Postamble -----------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent( ZZCrowAndCountess.name
                              , EVENT_ADD_ON_LOADED
                              , ZZCrowAndCountess.OnAddOnLoaded
                              )

SLASH_COMMANDS["/zzcrow"] = ZZCrowAndCountess.ScanQuestJournal
