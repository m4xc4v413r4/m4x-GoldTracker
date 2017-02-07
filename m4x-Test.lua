local name, _ = UnitName("Player");
local realm = GetRealmName("Player");
local faction = UnitFactionGroup("Player");
local _, class = UnitClass("Player");
local timeStart = time();
local timeCurr = time();
local moneyStart = GetMoney();
local money = GetMoney();
local moneyCurr = GetMoney();
local moneySession = 0;
local moneyToday = 0;
local moneyDiff = 0;
local moneyTemp = nil;
local moneyFormatDiff = nil;
local moneyFormatCurr = nil;
local moneyViewToggle = "Gold";
m4xGoldTrack = {};

local frame = CreateFrame("Button", "m4xMoneyFrame", UIParent);
local text = frame:CreateFontString(nil, "ARTWORK");

text:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE");
text:SetJustifyH("LEFT");
text:SetPoint("BOTTOM", UIParent, 0, 100);

frame:SetFrameStrata("HIGH");
frame:SetAllPoints(text);

frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("PLAYER_MONEY");
frame:RegisterEvent("PLAYER_TRADE_MONEY");
frame:RegisterEvent("TRADE_MONEY_CHANGED");
frame:RegisterEvent("SEND_MAIL_MONEY_CHANGED");
frame:RegisterEvent("SEND_MAIL_COD_CHANGED");

text:Show();

local function FrameCurr()
	text:SetTextColor(1, 1, 1);
	text:SetText(moneyFormatCurr);
end

local function FrameDiff()
	if moneyDiff >= 0 then
		text:SetTextColor(0, 1, 0);
	else
		text:SetTextColor(1, 0, 0);
	end
	text:SetText(moneyFormatDiff);
end

local function UpdateValues()
	timeCurr = time()
	moneyCurr = GetMoney();
	moneyDiff = moneyCurr - money;
	moneySession = moneyCurr - moneyStart;
	if difftime(timeCurr, timeStart) > 86400 then
		moneyToday = 0;
		timeStart = time();
		m4xGoldTrack[realm][name]["time"] = timeStart;
	end
	if moneyTemp ~= moneySession then
		moneyToday = moneyToday + moneySession - moneyTemp;
	end
	m4xGoldTrack[realm][name]["curr"] = moneyCurr;
	m4xGoldTrack[realm][name]["session"] = moneySession;
	m4xGoldTrack[realm][name]["today"] = moneyToday;
	moneyFormatDiff = GetCoinTextureString(abs(moneyDiff));
	moneyFormatCurr = GetCoinTextureString(abs(moneyCurr));
	if moneyViewToggle == "Gold" then
		FrameCurr();
	else
		FrameDiff();
	end
end

frame:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		if not m4xGoldTrack[realm] then
			m4xGoldTrack[realm] = {};
		end
		if not m4xGoldTrack[realm][name] then
			m4xGoldTrack[realm][name] = {};
			m4xGoldTrack[realm][name]["faction"] = faction;
			m4xGoldTrack[realm][name]["class"] = class;
		end
		if m4xGoldTrack[realm][name]["today"] then
			moneyToday = m4xGoldTrack[realm][name]["today"];
			timeStart = m4xGoldTrack[realm][name]["time"];
		end
		frame:UnregisterEvent("PLAYER_ENTERING_WORLD");
		money = GetMoney();
		moneyStart = GetMoney();
	end
	moneyTemp = moneySession;
	UpdateValues();
end);

local function OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP");
	GameTooltip:SetText(moneyViewToggle);
	for tRealm, _ in pairs(m4xGoldTrack) do
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(tRealm);
		for tName, _ in pairs(m4xGoldTrack[tRealm]) do
			for tKey, tValue in pairs(m4xGoldTrack[tRealm][tName]) do
				classColor = RAID_CLASS_COLORS[m4xGoldTrack[tRealm][tName]["class"]];
				if tKey == "curr" and moneyViewToggle == "Gold" then
					GameTooltip:AddDoubleLine(tName .. ":", GetCoinTextureString(tValue), classColor.r, classColor.g, classColor.b , 1, 1, 1);
				end
				if (tKey == "session" and moneyViewToggle == "Session") or (tKey == "today" and moneyViewToggle == "Today") then
					if tValue >= 0 then
						tColor = {0, 1, 0};
					else
						tColor = {1, 0, 0};
					end
					GameTooltip:AddDoubleLine(tName .. ":", GetCoinTextureString(abs(tValue)), classColor.r, classColor.g, classColor.b , unpack(tColor));
				end
			end
		end
	end
	GameTooltip:Show();
end

frame:SetScript("OnLeave", function(self)
	GameTooltip:Hide();
end);

frame:SetScript("OnMouseUp", function(self, button)
	if button == "LeftButton" then
		if moneyViewToggle == "Gold" then
			moneyViewToggle = "Session";
		elseif moneyViewToggle == "Session" then
			moneyViewToggle = "Today";
		else
			moneyViewToggle = "Gold";
		end
		OnEnter(self);
	end
	if button == "RightButton" then
		money = GetMoney();
	end
	moneyTemp = moneySession;
	UpdateValues();
end);

frame:SetScript("OnEnter", OnEnter);