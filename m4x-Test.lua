m4xGoldTrackDB = {};
local name, _ = UnitName("player");
local realm = GetRealmName();
local moneyStart = GetMoney();
local money = GetMoney();
local moneyDiff = 0;
local moneyFormat = nil;

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

local function UpdateFrame()
	money = GetMoney();
	m4xGoldTrackDB[realm][name] = money;
	if money >= moneyStart then
		text:SetTextColor(0, 1, 0);
	elseif money < moneyStart then
		text:SetTextColor(1, 0, 0);
	end
	moneyDiff = money - moneyStart;
	moneyFormat = GetCoinTextureString(abs(moneyDiff));
	text:SetText(moneyFormat);
end

frame:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		if not m4xGoldTrackDB[realm] then
			m4xGoldTrackDB[realm] = {};
		end
		frame:UnregisterEvent("PLAYER_ENTERING_WORLD");
		moneyStart = GetMoney();
		UpdateFrame();
	else
		UpdateFrame();
	end
end);

frame:SetScript("OnMouseUp", function(self, button)
	if button == "LeftButton" then
		moneyStart = GetMoney();
		UpdateFrame();
	end
end);

frame:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP");
	GameTooltip:SetText("Gold List");
	for iRealm, _ in pairs(m4xGoldTrackDB) do
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(iRealm);
		GameTooltip:AddLine(" ");
		for iName, iMoney in pairs(m4xGoldTrackDB[iRealm]) do
			GameTooltip:AddLine(iName .. ": " .. GetCoinTextureString(iMoney));
		end
	end
	GameTooltip:Show();
end);

frame:SetScript("OnLeave", function(self)
	GameTooltip:Hide();
end);