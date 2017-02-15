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
local moneyDiff = 0;
local moneyTemp = 0;
local moneyFormatDiff = nil;
local moneyFormatCurr = nil;
local moneyTotal = 0;
local moneyViewToggle = "Gold";
local frameW, frameH = 100, 20;
local dropData = {};
m4xGoldTrack = {};

local frame = CreateFrame("Button", "m4xMoneyFrame", UIParent);
local text = frame:CreateFontString(nil, "ARTWORK");
local dropdown = CreateFrame("Button", "m4xDropDown");

dropdown.displayMode = "MENU";

frame:SetPoint("BOTTOM", UIParent, 0, 100);
frame:SetFrameStrata("HIGH");

text:SetPoint("CENTER", frame);
text:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE");

frame:SetMovable(true);
frame:EnableMouse(true);
frame:RegisterForDrag("LeftButton");
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
	end
	if monthCurr ~= monthStart then
		moneyThisMonth = 0;
		monthStart = monthCurr;
	end

	if moneyTemp ~= moneySession then
		moneyToday = moneyToday + moneySession - moneyTemp;
		moneyThisMonth = moneyThisMonth + moneySession - moneyTemp;
	end

	m4xGoldTrack[realm][name]["day"] = dayStart;
	m4xGoldTrack[realm][name]["month"] = monthStart;
	m4xGoldTrack[realm][name]["curr"] = moneyCurr;
	m4xGoldTrack[realm][name]["session"] = moneySession;
	m4xGoldTrack[realm][name]["today"] = moneyToday;
	m4xGoldTrack[realm][name]["thismonth"] = moneyThisMonth;
	moneyFormatDiff = GetCoinTextureString(abs(moneyDiff));
	moneyFormatCurr = GetCoinTextureString(abs(moneyCurr));

	if moneyViewToggle == "Gold" then
		text:SetTextColor(1, 1, 1);
		text:SetText(moneyFormatCurr);
	else
		if moneyDiff >= 0 then
			text:SetTextColor(0, 1, 0);
		else
			text:SetTextColor(1, 0, 0);
		end
		text:SetText(moneyFormatDiff);
	end

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
		end
		frame:UnregisterEvent("PLAYER_ENTERING_WORLD");
	end
	UpdateValues();
end);

local function resetTracker(opt)
	if opt == "tracker" then
		money = GetMoney();
	-- elseif opt == "session" then
	end
	UpdateValues();
end

local function charList(opt)
	for tRealm, _ in pairs(m4xGoldTrack) do
		if opt == "ttip" then
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
		for tName, _ in pairs(m4xGoldTrack[tRealm]) do
			classColor = RAID_CLASS_COLORS[m4xGoldTrack[tRealm][tName]["class"]];
			if opt == "chars" then
				dropData.text = tName;
				dropData.func = function() if m4xGoldTrack[tRealm][tName]["hideChar"] == 0 then m4xGoldTrack[tRealm][tName]["hideChar"] = 1; else m4xGoldTrack[tRealm][tName]["hideChar"] = 0; end end
				dropData.checked = m4xGoldTrack[tRealm][tName]["hideChar"] == 1;
				UIDropDownMenu_AddButton(dropData, 2);
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

					if (tKey == "curr" and moneyViewToggle == "Gold") or (tKey == "session" and moneyViewToggle == "Session") or (tKey == "today" and moneyViewToggle == "Today") or (tKey == "thismonth" and moneyViewToggle == "Month") then
						moneyTotal = moneyTotal + tValue;
						if tKey == "curr" then
							tColor = {1, 1, 1};
						elseif tValue >= 0 then
							tColor = {0, 1, 0};
						else
							tColor = {1, 0, 0};
						end
						if m4xGoldTrack[tRealm][tName]["hideChar"] == 0 then
							GameTooltip:AddDoubleLine(tName .. ":", GetCoinTextureString(abs(tValue)), classColor.r, classColor.g, classColor.b , unpack(tColor));
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
	GameTooltip:SetText(moneyViewToggle, 1, 1, 1);

	charList("ttip");
	
	GameTooltip:AddLine(" ");
	GameTooltip:AddDoubleLine("Total:", GetCoinTextureString(abs(moneyTotal)), 1, 1, 1 , unpack(tColor));
	GameTooltip:Show();
end

frame:SetScript("OnLeave", function(self)
	GameTooltip:Hide();
end);

dropdown.initialize = function(self, dropLevel)
    if not dropLevel then return end
    wipe(dropData);

    if dropLevel == 1 then
        dropData.isTitle = 1;
        dropData.notCheckable = 1;

        dropData.text = "m4x GoldTracker";
        UIDropDownMenu_AddButton(dropData, dropLevel);

		dropData.keepShownOnClick = 1;
        dropData.isTitle = nil;
		dropData.disabled = nil;

        dropData.text = "Lock Tracker";
        UIDropDownMenu_AddButton(dropData, dropLevel);

		dropData.hasArrow = 1;

		dropData.value = "reset";
        dropData.text = "Reset";
        UIDropDownMenu_AddButton(dropData, dropLevel);

		dropData.value = "char";
		dropData.text = "Hide Characters";
		UIDropDownMenu_AddButton(dropData, dropLevel);

		dropData.value = nil;
		dropData.hasArrow = nil;
		dropData.keepShownOnClick = nil;

        dropData.text = "Hide Tracker";
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
			dropData.text = "Tracker";
			dropData.func = function() resetTracker("tracker"); end
			UIDropDownMenu_AddButton(dropData, dropLevel);

			-- dropData.text = "Session";
			-- dropData.func = function() resetTracker("session"); end
			-- UIDropDownMenu_AddButton(dropData, dropLevel);

		elseif UIDROPDOWNMENU_MENU_VALUE == "char" then
			charList("chars");
		end
    end
end

frame:SetScript("OnMouseUp", function(self, button)
	if button == "LeftButton" then
		if moneyViewToggle == "Gold" then
			moneyViewToggle = "Session";
		elseif moneyViewToggle == "Session" then
			moneyViewToggle = "Today";
		elseif moneyViewToggle == "Today" then
			moneyViewToggle = "Month";
		else
			moneyViewToggle = "Gold";
		end
		OnEnter(self);
	end
	if button == "RightButton" then
		ToggleDropDownMenu(1, nil, dropdown, self:GetName(), 0, 0)
	end
	UpdateValues();
end);

frame:SetScript("OnEnter", OnEnter);