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

function ZZCrowAndCountess.TooltipInsertOurText(control, item_link)
    -- Only fire for master writs.
    local item_type, specialized_item_type = GetItemLinkItemType(item_link)
    if     item_type             ~= ITEMTYPE_TREASURE
        or specialized_item_type ~= SPECIALIZED_ITEMTYPE_TREASURE then
        return
    end

                        -- Find treasure type
    local tag_ct = GetItemLinkNumItemTags(item_link)
    for i = 1,tag_ct do
        local tag_desc, tag_category = GetItemLinkItemTagInfo(item_link,i)
        if TAG_CATEGORY_TREASURE_TYPE == tag_category then
            d(tag_desc)
        end
    end

    control:AddLine("Hiya!")
end


-- Postamble -----------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent( ZZCrowAndCountess.name
                              , EVENT_ADD_ON_LOADED
                              , ZZCrowAndCountess.OnAddOnLoaded
                              )
