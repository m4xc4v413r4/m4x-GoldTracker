local name, _ = UnitName("Player");
local realm = GetRealmName("Player");
local faction = UnitFactionGroup("Player");
local _, class = UnitClass("Player");
local dayStart = date("%y%m%d");
local dayCurr = date("%y%m%d");
local monthStart = date("%y%m");
local monthCurr = date("%y%m");
local moneyStart = GetMoney();
local money = GetMoney();
local moneyCurr = GetMoney();
local moneySession = 0;
local moneyToday = 0;
local moneyThisMonth = 0;
local moneyTracker = 0;
local moneyDiff = 0;
local moneyTemp = 0;
local moneyTotal = 0;
local moneyViewToggle = "Gold";
local frameW, frameH = 200, 20;
local tempHidden = {};
local dropData = {};
m4xGoldTrack = {};

local frame = CreateFrame("Button", "m4xMoneyFrame", UIParent);
local text = frame:CreateFontString(nil, "ARTWORK");
local dropdown = CreateFrame("Button", "m4xMoneyDropDown");

dropdown.displayMode = "MENU";

frame:SetPoint("CENTER", UIParent);
frame:SetFrameStrata("HIGH");

text:SetPoint("CENTER", frame);
text:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE");

frame:EnableMouse(true);
frame:SetScript("OnDragStart", frame.StartMoving);
frame:SetScript("OnDragStop", frame.StopMovingOrSizing);

frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("PLAYER_MONEY");
frame:RegisterEvent("PLAYER_TRADE_MONEY");
frame:RegisterEvent("TRADE_MONEY_CHANGED");
frame:RegisterEvent("SEND_MAIL_MONEY_CHANGED");
frame:RegisterEvent("SEND_MAIL_COD_CHANGED");

SLASH_M4XGOLDTRACKER1 = "/mgt";
SlashCmdList["M4XGOLDTRACKER"] = function()
	if frame:IsShown() then
		frame:Hide();
	else
		frame:Show();
	end
end

local function MoneyColor(opt)
	if moneyViewToggle == "Gold" then
		moneyTextColor = {1, 1, 1};
		text:SetText(GetCoinTextureString(abs(moneyCurr)));
	else
		if opt >= 0 then
			moneyTextColor = {0, 1, 0};
		else
			moneyTextColor = {1, 0, 0};
		end
		text:SetText(GetCoinTextureString(abs(moneyDiff)));
	end
end

local function UpdateValues()
	dayCurr = date("%y%m%d");
	monthCurr = date("%y%m");
	moneyCurr = GetMoney();
	moneyDiff = moneyCurr - money;
	moneyTemp = moneySession;
	moneySession = moneyCurr - moneyStart;

	if dayCurr ~= dayStart then
		moneyToday = 0;
		dayStart = dayCurr;
		if monthCurr ~= monthStart then
			moneyThisMonth = 0;
			monthStart = monthCurr;
		end
	end

	if moneyTemp ~= moneySession then
		moneyToday = moneyToday + moneySession - moneyTemp;
		moneyThisMonth = moneyThisMonth + moneySession - moneyTemp;
		moneyTracker = moneyTracker + moneySession - moneyTemp;
	end

	m4xGoldTrack[realm][name]["day"] = dayStart;
	m4xGoldTrack[realm][name]["month"] = monthStart;
	m4xGoldTrack[realm][name]["curr"] = moneyCurr;
	m4xGoldTrack[realm][name]["tracker"] = moneyTracker;
	m4xGoldTrack[realm][name]["today"] = moneyToday;
	m4xGoldTrack[realm][name]["thismonth"] = moneyThisMonth;

	MoneyColor(moneyDiff);

	text:SetTextColor(unpack(moneyTextColor));

	frameW, frameH = text:GetSize();
	frame:SetWidth(frameW+10);
	frame:SetHeight(frameH+8);
end

frame:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		money = GetMoney();
		moneyStart = GetMoney();
		dayStart = date("%y%m%d");
		monthStart = date("%y%m");

		if not m4xGoldTrack[realm] then
			m4xGoldTrack[realm] = {};
		end

		if not m4xGoldTrack[realm][name] then
			m4xGoldTrack[realm][name] = {};
			m4xGoldTrack[realm][name]["faction"] = faction;
			m4xGoldTrack[realm][name]["class"] = class;
			m4xGoldTrack[realm][name]["hideChar"] = 0;
		end

		if m4xGoldTrack[realm][name]["today"] then
			moneyToday = m4xGoldTrack[realm][name]["today"];
			moneyThisMonth = m4xGoldTrack[realm][name]["thismonth"];
			dayStart = m4xGoldTrack[realm][name]["day"];
			monthStart = m4xGoldTrack[realm][name]["month"];
			moneyTracker = m4xGoldTrack[realm][name]["tracker"];
		end

		if m4xGoldTrack[realm][name]["point"] then
			frame:ClearAllPoints();
			
			frame:SetPoint(m4xGoldTrack[realm][name]["point"], nil, m4xGoldTrack[realm][name]["relativePoint"], m4xGoldTrack[realm][name]["xOfs"], m4xGoldTrack[realm][name]["yOfs"]);
		end

		if m4xGoldTrack[realm][name]["font"] then
			text:SetFont("Fonts\\FRIZQT__.TTF", m4xGoldTrack[realm][name]["font"], "OUTLINE");
		end

		frame:UnregisterEvent("PLAYER_ENTERING_WORLD");
	end
	UpdateValues();
end);

local function CharList(opt)
	for tRealm, _ in pairs(m4xGoldTrack) do
		if (opt == "ttip") and (tempHidden[tRealm]["hiddenCounter"] ~= tempHidden[tRealm]["totalCounter"]) then
			GameTooltip:AddLine(" ");
			GameTooltip:AddLine(tRealm);
		elseif opt == "chars" then
			dropData.isTitle = 1;
			dropData.notCheckable = 1;

			dropData.text = tRealm;
			UIDropDownMenu_AddButton(dropData, 2);

			dropData.isTitle = nil;
			dropData.notCheckable = nil;
			dropData.disabled = nil;
		end

		tempHidden[tRealm] = {};
		tempHidden[tRealm]["hiddenCounter"] = 0;
		tempHidden[tRealm]["totalCounter"] = 0;

		for tName, _ in pairs(m4xGoldTrack[tRealm]) do
			local classColor = RAID_CLASS_COLORS[m4xGoldTrack[tRealm][tName]["class"]];

			if opt == "reset" then
				m4xGoldTrack[tRealm][tName]["tracker"] = 0;
				moneyTracker = 0;
				moneyTotal = 0;
			elseif opt == "chars" then
				dropData.text = tName;
				dropData.func = function() if m4xGoldTrack[tRealm][tName]["hideChar"] == 0 then m4xGoldTrack[tRealm][tName]["hideChar"] = 1; else m4xGoldTrack[tRealm][tName]["hideChar"] = 0; end end
				dropData.checked = m4xGoldTrack[tRealm][tName]["hideChar"] == 1;
				UIDropDownMenu_AddButton(dropData, 2);
			elseif opt == "check" then
				if m4xGoldTrack[tRealm][tName]["hideChar"] == 1 then
					tempHidden[tRealm]["hiddenCounter"] = tempHidden[tRealm]["hiddenCounter"] + 1;
				end
				tempHidden[tRealm]["totalCounter"] = tempHidden[tRealm]["totalCounter"] + 1;
			end

			for tKey, tValue in pairs(m4xGoldTrack[tRealm][tName]) do
				if opt == "ttip" then
					if date("%y%m%d") ~= m4xGoldTrack[tRealm][tName]["day"] and moneyViewToggle == "Today" then
						m4xGoldTrack[tRealm][tName]["today"] = 0;
						m4xGoldTrack[tRealm][tName]["day"] = date("%y%m%d");
					end
					if date("%y%m") ~= m4xGoldTrack[tRealm][tName]["month"] and moneyViewToggle == "Month" then
						m4xGoldTrack[tRealm][tName]["thismonth"] = 0;
						m4xGoldTrack[tRealm][tName]["month"] = date("%y%m");
					end

					if (tKey == "curr" and moneyViewToggle == "Gold") or (tKey == "tracker" and moneyViewToggle == "Tracker") or (tKey == "today" and moneyViewToggle == "Today") or (tKey == "thismonth" and moneyViewToggle == "Month") then
						moneyTotal = moneyTotal + tValue;

						MoneyColor(tValue);

						if m4xGoldTrack[tRealm][tName]["hideChar"] == 0 then
							GameTooltip:AddDoubleLine(tName .. ":", GetCoinTextureString(abs(tValue)), classColor.r, classColor.g, classColor.b , unpack(moneyTextColor));
						end
					end
				end
			end
		end
	end
end

local function OnEnter(self)
	moneyTotal = 0;

	GameTooltip:SetOwner(self, "ANCHOR_TOP");
	GameTooltip:SetText(moneyViewToggle);

	CharList("check");
	CharList("ttip");
	MoneyColor(moneyTotal);

	GameTooltip:AddLine(" ");
	GameTooltip:AddDoubleLine("Total:", GetCoinTextureString(abs(moneyTotal)), 1, 1, 1 , unpack(moneyTextColor));
	GameTooltip:Show();
end

frame:SetScript("OnLeave", function(self)
	GameTooltip:Hide();
end);

local function LockTracker()
	if not frame:IsMovable() then
		frame:SetMovable(true);
		frame:RegisterForDrag("LeftButton");
	else
		frame:SetMovable(false);
		frame:RegisterForDrag();
		m4xGoldTrack[realm][name]["point"], _, m4xGoldTrack[realm][name]["relativePoint"], m4xGoldTrack[realm][name]["xOfs"], m4xGoldTrack[realm][name]["yOfs"] = frame:GetPoint();
	end
end

local function ChooseFont()
	local _, fSize, _ = text:GetFont()
	local fSizeInt = math.floor(fSize+0.5);
	for i = fSizeInt - 3, fSizeInt + 3 do
		if i > 0 then
			if i == fSizeInt then
				dropData.disabled = 1;
			else
				dropData.disabled = nil;
			end
			dropData.text = i;
			dropData.func = function() text:SetFont("Fonts\\FRIZQT__.TTF", i, "OUTLINE"); m4xGoldTrack[realm][name]["font"] = i end
			UIDropDownMenu_AddButton(dropData, 2);
		end
	end
end

local function ResetDisplay()
	frame:ClearAllPoints();

	frame:SetPoint("CENTER", UIParent);
	m4xGoldTrack[realm][name]["point"] = nil;

	text:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE");
	m4xGoldTrack[realm][name]["font"] = 15;
end

dropdown.initialize = function(self, dropLevel)
	if not dropLevel then return end
	wipe(dropData);

	if dropLevel == 1 then
		dropData.isTitle = 1;
		dropData.notCheckable = 1;

		dropData.text = "m4x GoldTracker";
		UIDropDownMenu_AddButton(dropData, dropLevel);

		dropData.isTitle = nil;
		dropData.disabled = nil;
		dropData.notCheckable = nil;

		dropData.text = "Lock Display";
		dropData.func = function() LockTracker(); end
		dropData.checked = not frame:IsMovable();
		UIDropDownMenu_AddButton(dropData, dropLevel);

		dropData.keepShownOnClick = 1;
		dropData.hasArrow = 1;
		dropData.notCheckable = 1;

		dropData.value = "reset";
		dropData.text = "Reset";
		UIDropDownMenu_AddButton(dropData, dropLevel);

		dropData.value = "char";
		dropData.text = "Hide Characters";
		UIDropDownMenu_AddButton(dropData, dropLevel);

		dropData.value = "font";
		dropData.text = "Font Size";
		UIDropDownMenu_AddButton(dropData, dropLevel);

		dropData.value = nil;
		dropData.hasArrow = nil;
		dropData.keepShownOnClick = nil;

		dropData.text = "Hide Display";
		dropData.func = function() frame:Hide(); end
		UIDropDownMenu_AddButton(dropData, dropLevel);

		dropData.text = CLOSE;
		dropData.func = function() CloseDropDownMenus(); end
		dropData.checked = nil;
		UIDropDownMenu_AddButton(dropData, dropLevel);

	elseif dropLevel == 2 then
		dropData.keepShownOnClick = 1;
		dropData.notCheckable = 1;

		if UIDROPDOWNMENU_MENU_VALUE == "reset" then
			dropData.text = "Display";
			dropData.func = function() money = GetMoney(); UpdateValues(); end
			UIDropDownMenu_AddButton(dropData, dropLevel);

			dropData.text = "Tracker";
			dropData.func = function() CharList("reset"); UpdateValues(); end
			UIDropDownMenu_AddButton(dropData, dropLevel);

			dropData.disabled = 1;
			
			dropData.text = "";
			UIDropDownMenu_AddButton(dropData, dropLevel)

			dropData.disabled = nil;
			dropData.keepShownOnClick = nil;

			dropData.text = "|cffff0000Position/Size|r";
			dropData.func = function() ResetDisplay(); end
			UIDropDownMenu_AddButton(dropData, dropLevel);

		elseif UIDROPDOWNMENU_MENU_VALUE == "char" then
			CharList("chars");
		
		elseif UIDROPDOWNMENU_MENU_VALUE == "font" then
			dropData.keepShownOnClick = nil;
			ChooseFont();
		end
	end
end

frame:SetScript("OnMouseUp", function(self, button)
	if button == "LeftButton" then
		if moneyViewToggle == "Gold" then
			moneyViewToggle = "Tracker";
		elseif moneyViewToggle == "Tracker" then
			moneyViewToggle = "Today";
		elseif moneyViewToggle == "Today" then
			moneyViewToggle = "Month";
		else
			moneyViewToggle = "Gold";
		end
		UpdateValues();
		OnEnter(self);
	elseif button == "RightButton" then
		ToggleDropDownMenu(1, nil, dropdown, self:GetName(), 0, 0)
	end
end);

frame:SetScript("OnEnter", OnEnter);