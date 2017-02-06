m4xGoldTrackCurr = {};
m4xGoldTrackDiff = {};
local moneyColor = {1, 0, 0};
local name, _ = UnitName("player");
local realm = GetRealmName();
local moneyStart = GetMoney();
local money = GetMoney();
local moneyDiff = 0;
local moneyFormatDiff = nil;
local moneyFormatCurr = nil;
local moneyViewToggle = 1;

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
	if money >= moneyStart then
		text:SetTextColor(unpack(moneyColor));
	else
		text:SetTextColor(1, 0, 0);
	end
	text:SetText(moneyFormatDiff);
end

local function UpdateValues()
	money = GetMoney();
	moneyDiff = money - moneyStart;
	m4xGoldTrackCurr[realm][name] = money;
	m4xGoldTrackDiff[realm][name] = moneyDiff;
	moneyFormatDiff = GetCoinTextureString(abs(moneyDiff));
	moneyFormatCurr = GetCoinTextureString(abs(money));
	if moneyViewToggle == 1 then
		FrameCurr();
	else
		FrameDiff();
	end
end

frame:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		if not m4xGoldTrackCurr[realm] then
			m4xGoldTrackCurr[realm] = {};
			m4xGoldTrackDiff[realm] = {};
		end
		frame:UnregisterEvent("PLAYER_ENTERING_WORLD");
		moneyStart = GetMoney();
		UpdateValues();
	else
		UpdateValues();
	end
end);

local function OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP");
	if moneyViewToggle == 1 then
		GameTooltip:SetText("Gold Curr");
		for iRealm, _ in pairs(m4xGoldTrackCurr) do
			GameTooltip:AddLine(" ");
			GameTooltip:AddLine(iRealm);
			GameTooltip:AddLine(" ");
			for iName, iMoney in pairs(m4xGoldTrackCurr[iRealm]) do
				GameTooltip:AddDoubleLine(iName .. ":", GetCoinTextureString(iMoney),_ ,_ ,_ ,1 ,1 ,1);
			end
		end
	else
		GameTooltip:SetText("Gold Diff");
		for iRealm, _ in pairs(m4xGoldTrackDiff) do
			GameTooltip:AddLine(" ");
			GameTooltip:AddLine(iRealm);
			GameTooltip:AddLine(" ");
			for iName, iMoney in pairs(m4xGoldTrackDiff[iRealm]) do
				GameTooltip:AddDoubleLine(iName .. ":", GetCoinTextureString(iMoney),_,_,_,0,1,0);
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
		if moneyViewToggle == 1 then
			moneyViewToggle = 2;
			UpdateValues();
		else
			moneyViewToggle = 1;
			UpdateValues();
		end
		OnEnter(self);
	end
	if button == "RightButton" then
		moneyStart = GetMoney();
		UpdateValues();
	end
end);

frame:SetScript("OnEnter", OnEnter);