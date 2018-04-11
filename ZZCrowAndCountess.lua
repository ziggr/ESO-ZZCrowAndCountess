ZZCrowAndCountess = {}
ZZCrowAndCountess.name            = "ZZCrowAndCountess"
ZZCrowAndCountess.version         = "3.3.1"


-- Init ----------------------------------------------------------------------

function ZZCrowAndCountess.OnAddOnLoaded(event, addonName)
    if addonName ~= ZZCrowAndCountess.name then return end
    if not ZZCrowAndCountess.version then return end
    ZZCrowAndCountess.TooltipInterceptInstall()
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

local TAG_WANTED = {
  ["Artwork"                ] = {  nil      ,  nil              }
, ["Cosmetics"              ] = { "Tributes", "Windhelm"        }
, ["Devices"                ] = {  nil      ,  nil              }
, ["Dishes and Cookware"    ] = {  nil      , "Riften"          }
, ["Dolls"                  ] = {  nil      , "Davon's Watch"   }
, ["Drinkware"              ] = { "Respect" , "Riften"          }
, ["Dry Goods"              ] = {  nil      ,  nil              }
, ["Fishing Supplies"       ] = {  nil      ,  nil              }
, ["Furnishings"            ] = {  nil      ,  nil              }
, ["Games"                  ] = { "Leisure" , "Davon's Watch"   }
, ["Grooming Items"         ] = { "Tributes",  ni               }
, ["Lights"                 ] = {  nil      ,  nil              }
, ["Linens"                 ] = {  nil      , "Windhelm"        }
, ["Magic Curiosities"      ] = {  nil      ,  nil              }
, ["Maps"                   ] = {  nil      , "Stormhold"       }
, ["Medical Supplies"       ] = {  nil      ,  nil              }
, ["Musical Instruments"    ] = {  nil      ,  nil              }
, ["Oddities"               ] = {  nil      , "Mournhold"       }
, ["Ritual Objects"         ] = {  nil      , "Mournhold"       }
, ["Scrivener Supplies"     ] = {  nil      , "Stormhold"       }
, ["Smithing Equipment"     ] = {  nil      ,  nil              }
, ["Statues"                ] = {  nil      , "Davon's Watch"   }
, ["Tools"                  ] = {  nil      ,  nil              }
, ["Toys"                   ] = { "Leisure" , nil               }
, ["Trifles and Ornaments"  ] = {  nil      ,  nil              }
, ["Utensils"               ] = { "Respect" , "Riften"          }
, ["Wall Décor"             ] = {  nil      ,  nil              }
, ["Wardrobe Accessories"   ] = {  nil      , "Windhelm"        }
, ["Writings"               ] = {  nil      , "Stormhold"       }
}

function ZZCrowAndCountess.TooltipInsertOurText(control, item_link)
    -- Only fire for master writs.
    local item_type, specialized_item_type = GetItemLinkItemType(item_link)
    if     item_type             ~= ITEMTYPE_TREASURE
        or specialized_item_type ~= SPECIALIZED_ITEMTYPE_TREASURE then
        return
    end

                        -- Find treasure type
    local tag_ct = GetItemLinkNumItemTags(item_link)
    local crow_list = {}
    local countess_list = {}

    for i = 1,tag_ct do
        local tag_desc, tag_category = GetItemLinkItemTagInfo(item_link,i)
        if TAG_CATEGORY_TREASURE_TYPE == tag_category then
            d(tag_desc)
            local cc = TAG_WANTED[tag_desc]
            if not cc then
                d("Unknown tag: "..tostring(tag_desc))
            else
                if cc[1] then table.insert(crow_list, cc[1]) end
                if cc[2] then table.insert(countess_list, cc[2]) end
            end
        end
    end
    if 0 < #crow_list then
        control:AddLine("Crow: "..table.concat(crow_list, ", "))
    end
    if 0 < #countess_list then
        control:AddLine("Countess: "..table.concat(countess_list, ", "))
    end
    if 0 == #crow_list and 0 == #countess_list then
        control:AddLine("|c999999not needed for crow or countess|r")
    end
end


-- Postamble -----------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent( ZZCrowAndCountess.name
                              , EVENT_ADD_ON_LOADED
                              , ZZCrowAndCountess.OnAddOnLoaded
                              )
