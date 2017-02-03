local moneyStart = GetMoney();
local money = GetMoney();
print("Start: " .. moneyStart, money);
local moneyDiff = 0;
local moneyFormat = nil;
local name, _ = UnitName("player");
local realm = GetRealmName();
m4xGoldTrackDB = {};
m4xGoldTrackDB[realm] = {};

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
	if money >= moneyStart then
		text:SetTextColor(0, 1, 0);
	elseif money < moneyStart then
		text:SetTextColor(1, 0, 0);
	end
	m4xGoldTrackDB[realm][name] = money;
	print("Update: " .. moneyStart, money);
	moneyDiff = money - moneyStart;
	moneyFormat = GetCoinTextureString(abs(moneyDiff));
	print("Update: " .. moneyStart, money);
	text:SetText(moneyFormat);
end

frame:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		frame:UnregisterEvent("PLAYER_ENTERING_WORLD");
		print("If: " .. moneyStart, money);
		moneyStart = GetMoney();
		money = GetMoney();
		print("If: " .. moneyStart, money);
		UpdateFrame();
	else
		print("Event: " .. moneyStart, money);
		money = GetMoney();
		print("Event: " .. moneyStart, money);
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