local Zuggy = LibStub("AceAddon-3.0"):NewAddon("Zuggy", "AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local wholib = LibStub:GetLibrary('LibWho-2.0'):Library()
local ZugsFrame = nil
local zugsframeIsCreated = false
local whoList = {}
local charLocations = {}
local numWhoProcessed = 0


local Tabs = {  {value="items", text="List of Sellers"},
				{value="itembuyers", text="List of Buyers"},
				--{value="chars", text="Saved Chars"},
			 }
local defaultTab = "items"
local itemDetailsButton
--TableStuff
local ScrollingTable = LibStub("ScrollingTable");
local sellertable, buyertable
local colorWhite = { ["r"] = 1.0, ["g"] = 1.0, ["b"] = 1.0, ["a"] = 1.0 }
local colorDarkGreen = { ["r"] = 0.5, ["g"] = 1.0, ["b"] = 0.5, ["a"] = 0.1 }
local colorRed = { ["r"] = 1.1, ["g"] = 0.1, ["b"] = 0.1, ["a"] = 0.1 }
local itemSellColumns = {
	{
		["name"] = "Crafters/Sellers",
		["width"] = 120,
		["align"] = "LEFT",
		["color"] = colorWhite,
		["defaultsort"] = asc, 
		["sortnext"] = 2,
	},
	{
		["name"] = "Location",
		["width"] = 150,
		["align"] = "LEFT",
		["color"] = colorWhite,
		["defaultsort"] = asc, 

		["DoCellUpdate"] = nil,
	},
	{
		["name"] = "Selling Price",
		["width"] = 150,
		["align"] = "LEFT",
		["color"] = colorWhite,
		["defaultsort"] = asc, 
		["sortnext"] = 2,
	},
	
	{
		["name"] = "Tips (Mats required)",
		["width"] = 150,
		["align"] = "LEFT",
		["color"] = colorWhite,
		["defaultsort"] = asc, 
		["sortnext"] = 2,
	},
}

local itemBuyColumns = {
	{
		["name"] = "Buyers",
		["width"] = 120,
		["align"] = "LEFT",
		["color"] = colorWhite,
		["bgcolor"] = colorBlack,
		["defaultsort"] = asc, 
		["sortnext"] = 2,
	},
	{
		["name"] = "Location",
		["width"] = 150,
		["align"] = "LEFT",
		["color"] = colorWhite,
		["bgcolor"] = colorDark,
		["defaultsort"] = asc, 

		["DoCellUpdate"] = nil,
	},
	{
		["name"] = "Buying Price",
		["width"] = 150,
		["align"] = "LEFT",
		["color"] = colorWhite,
		["bgcolor"] = colorBlack,
		["defaultsort"] = asc, 
		["sortnext"] = 2,
	},
	
	{
		["name"] = "Tips (Mats provided by buyer)",
		["width"] = 180,
		["align"] = "LEFT",
		["color"] = colorWhite,
		["bgcolor"] = colorBlack,
		["defaultsort"] = asc, 
		["sortnext"] = 2,
	},
}

local itemSellerListing = {
	{ "Select Item First", "", ""},
}

local itemBuyerListing = {
	{ "Select Item First", "", ""},
}
	
function Zuggy:OnInitialize()
  	SlashCmdList["ZUGS"] = toggleZugsFrame;
	SLASH_ZUGS1 = "/zugs";
	SLASH_ZUGS2 = "/zugslist";
	SLASH_ZUGS3 = "/zug";
	SLASH_ZUGS4 = "/zuggy";

	
end

function userWho(user)
	wholib:Who(user, { queue = wholib.WHOLIB_QUEUE_USER, })
end

function DrawTab1(container) -- function that draws the widgets for the first tab
	local desc = AceGUI:Create("Label")
	if ZugsSellers then
		desc:SetText("Select an item to see who wants to sell/craft it!")
	else
		desc:SetText("You have no items in your list. Visit www.zugslist.com to add your wanted items.")
	end
	desc:SetFullWidth(true)
	container:AddChild(desc)
	
	local itemSellerMenu =  AceGUI:Create("Dropdown")
	itemSellerMenu:SetLabel("Item Wishlist")
	itemSellerMenu:SetText("Select An Item")
	itemSellerMenu:SetWidth(250)
	itemSellerMenu:SetList({})
	if ZugsSellers then
		for k,v in pairs(ZugsSellers) do
			itemSellerMenu:AddItem(k, v.name)
		end

		itemSellerMenu:SetCallback("OnValueChanged", function(widget, event, key) 
													itemDetailsButton:SetCallback("OnClick", function() viewItemDeets(key) end)
													itemDetailsButton:SetDisabled(false)												
													populateItemListing(key, "seller"); 
												end)
		container:AddChild(itemSellerMenu)

		if (not sellertable) then
			sellertable = ScrollingTable:CreateST(itemSellColumns,19,nil,nil,container.frame)
			sellertable.frame:SetPoint("BOTTOMLEFT",20,20)
			sellertable.frame:SetPoint("TOP", container.frame, 0, -120)
			sellertable.frame:SetPoint("RIGHT", container.frame, -20,0)
			
		end
		sellertable:SetData(itemSellerListing, 1)
		sellertable:Show()

		itemDetailsButton = AceGUI:Create("Button")
		itemDetailsButton:SetText("View Item Details")
		itemDetailsButton:SetWidth(140)
		itemDetailsButton:SetDisabled(1)
		container:AddChild(itemDetailsButton)
	end
	--AceGUI:RegisterAsWidget(sellertable)
  --container:AddChild(sellertable)

end


function DrawTab2(container)
	local desc = AceGUI:Create("Label")
	if ZugsBuyers then
		desc:SetText("Select an item to see who wants to buys it!")
	else
		desc:SetText("You have no items in your list. Visit www.zugslist.com to add your wanted items.")
	end
	desc:SetFullWidth(true)
	container:AddChild(desc)
	
	local itemBuyerMenu =  AceGUI:Create("Dropdown")
	itemBuyerMenu:SetLabel("Item List")
	itemBuyerMenu:SetText("Select An Item")
	itemBuyerMenu:SetWidth(250)
	itemBuyerMenu:SetList({})
	if ZugsBuyers then
		for k,v in pairs(ZugsBuyers) do
			itemBuyerMenu:AddItem(k, v.name)
		end
	

		itemBuyerMenu:SetCallback("OnValueChanged", function(widget, event, key) 
													itemDetailsButton:SetCallback("OnClick", function() viewItemDeets_buyer(key) end)
													itemDetailsButton:SetDisabled(false)												
													populateItemListing(key, "buyer"); 
												end)
		container:AddChild(itemBuyerMenu)

		if (not buyertable) then
			buyertable = ScrollingTable:CreateST(itemBuyColumns,19,nil,nil,container.frame)
			buyertable.frame:SetPoint("BOTTOMLEFT",20,20)
			buyertable.frame:SetPoint("TOP", container.frame, 0, -120)
			buyertable.frame:SetPoint("RIGHT", container.frame, -20,0)
			
		end
		buyertable:SetData(itemBuyerListing, 1)
		buyertable:Show()

		itemDetailsButton = AceGUI:Create("Button")
		itemDetailsButton:SetText("View Item Details")
		itemDetailsButton:SetWidth(140)
		itemDetailsButton:SetDisabled(1)
		container:AddChild(itemDetailsButton)
	end
	--AceGUI:RegisterAsWidget(buyertable)
  --container:AddChild(buyertable)

end

function viewItemDeets(item) 
	ItemRefTooltip:SetOwner(ZugsFrame.frame, "ANCHOR_Preserve")
	ItemRefTooltip:SetHyperlink(ZugsSellers[item].link)
	ShowUIPanel(ItemRefTooltip)
end

function viewItemDeets_buyer(item) 
	ItemRefTooltip:SetOwner(ZugsFrame.frame, "ANCHOR_Preserve")
	ItemRefTooltip:SetHyperlink(ZugsBuyers[item].link)
	ShowUIPanel(ItemRefTooltip)
end

function DrawTab3(container) -- function that draws the widgets for the second tab
  local desc = AceGUI:Create("Label")
  desc:SetText("Browse through the chars you saved so you can use their services")
  desc:SetFullWidth(true)
  container:AddChild(desc)
  
  local button = AceGUI:Create("Button")
  button:SetText("testing")
  button:SetWidth(200)
  container:AddChild(button)
end

function SelectGroup(container, event, group) -- Callback function for OnGroupSelected
	container:ReleaseChildren()
	if sellertable then
		sellertable:Hide()
	end
	if buyertable then
		buyertable:Hide()
	end
	if group == Tabs[1].value then
		DrawTab1(container)
	elseif group == Tabs[2].value then
		DrawTab2(container)
	end
end


function createZugsFrame()
 
 	zugsframeIsCreated = true
	ZugsFrame = AceGUI:Create("Frame")
	ZugsFrame:SetTitle("Zugslist")
	ZugsFrame:SetStatusText("Zugslist UI for www.zugslist.com (in limited preview)")
--ZugsFrame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end) Fixes toggling bug by commenting out
	ZugsFrame:SetLayout("Fill")
	ZugsFrame:SetWidth(700)
	ZugsFrame:SetHeight(500)
	
	-- Create the TabGroup
	interface =  AceGUI:Create("TabGroup")
	interface:SetLayout("Flow")
	-- Setup which tabs to show
	interface:SetTabs(Tabs)
	-- Register callback
	interface:SetCallback("OnGroupSelected", SelectGroup)
	-- Set initial Tab (this will fire the OnGroupSelected callback)
	interface:SelectTab(defaultTab)

	-- add to the frame container
	ZugsFrame:AddChild(interface)


end

function toggleZugsFrame()
	if (not zugsframeIsCreated) then
		createZugsFrame()
	elseif ZugsFrame:IsVisible() then
		ZugsFrame:Hide()
	else
		ZugsFrame:Show()

	end
end

function Zuggy:OnEnable()
	generateWhoList()
	initCharLocations()
	for i, v in ipairs(whoList) do
		wholib:Who(v, { callback = 'UserDataReturned', queue = wholib.WHOLIB_QUEUE_QUIET,})
	end
end

-- callback function
function wholib:UserDataReturned(query, results, complete)
	numWhoProcessed = numWhoProcessed + 1
	local foundChar = false
	if results[1] then
		for i,res in ipairs(results) do
			if in_table(res.Name,whoList) then
				foundChar = true
				charLocations[res.Name] = res.Zone
			end
		end
	end
	if (not foundChar) and in_table(query,whoList) then
		charLocations[query] = "Offline"
	end
	if sellertable then	
		sellertable:SortData()
		sellertable:Refresh()
	end

	if buyertable then
		buyertable:SortData()
		buyertable:Refresh()
	end

	-- When done with whoqueue run through it again and again to keep up to date.
	if numWhoProcessed == #whoList then
		numWhoProcessed = 0
		for i, v in ipairs(whoList) do
			wholib:Who(v, { callback = 'UserDataReturned', queue = wholib.WHOLIB_QUEUE_QUIET,})
		end
	end
end

function Zuggy:OnDisable()
    -- Called when the addon is disabled
end

-- Populate the table requested with buyers/sellers (and their info) of an item 
function populateItemListing(itemID, st)

	local data = {}
	local lst, scrolltable
	if st == "seller" then
		lst = ZugsSellers[itemID].sellers
		scrolltable = sellertable
	else
		lst = ZugsBuyers[itemID].buyers
		scrolltable = buyertable
	end
	
	if lst then
		for char,v in pairs(lst) do
			local price = v.price
			local tips = v.tips
			if type(price) == 'table' then
				price = price[1] .. " Gold, " .. price[2] .. " Sil, " .. price[3] .. " Cop"
			end
			
			if type(tips) == 'table' then
				tips = tips[1] .. " Gold, " .. tips[2] .. " Sil, " .. tips[3] .. " Cop"
			end
			row = {char, charLocations[char], price, tips}

			table.insert(data,row)
		end
	end
	
	scrolltable:SetData(data, 1)
	scrolltable:SortData()
end

function initCharLocations()
	if whoList then
		for i, char in ipairs(whoList) do
			charLocations[char] = "Pending"
		end
	end
end

function generateWhoList()
	if ZugsSellers then
		for item,v in pairs(ZugsSellers) do
			for char, char_val in pairs(v.sellers) do
				table.insert(whoList, char)
			end
		end
	end
	if ZugsBuyers then
		for item,v in pairs(ZugsBuyers) do
			for char, char_val in pairs(v.buyers) do
				table.insert(whoList, char)
			end
		end
	end
	whoList = table_unique(whoList)

end


-- Remove duplicates from a table array (does NOT work on key-value tables!)
function table_unique(tt)
  local newtable
  newtable = {}
  for ii,xx in ipairs(tt) do
    if(table_count(newtable, xx) == 0) then
      newtable[#newtable+1] = xx
    end
  end
  return newtable
end

-- Count the number of times a value occurs in a table 
function table_count(tt, item)
  local count
  count = 0
  for ii,xx in pairs(tt) do
    if item == xx then count = count + 1 end
  end
  return count
end

function in_table ( e, t )
	for _,v in pairs(t) do
		if (v==e) then return true end
	end
	return false
end

function table.copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

