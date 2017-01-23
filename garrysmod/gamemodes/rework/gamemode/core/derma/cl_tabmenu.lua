--[[ 
	Rework © 2016-2017 TeslaCloud Studios
	Do not share or re-distribute before 
	the framework is publicly released.
--]]

local PANEL = {}
PANEL.menuItems = {};
PANEL.buttons = {};
PANEL.activePanel = nil;

function PANEL:Init()
	self:SetPos(0, 0);
	self:SetSize(ScrW(), ScrH());

	local curX, curY = hook.Run("AdjustMenuItemPositions");
	curX = curX or 42;
	curY = curY or 200;

	self.closeButton = vgui.Create("reButton", self);
	self.closeButton:SetFont("rw_menuitem_large");
	self.closeButton:SetText("CLOSE");
	self.closeButton:SetPos(curX + 16, curY);
	self.closeButton:SetSize(164, 38);
	self.closeButton:SetDrawBackground(false);
	self.closeButton:SetTextAutoposition(false);
	self.closeButton.DoClick = function(btn)
		self:SetVisible(false);
		self:Remove();
	end;

	curY = curY + 42;

	hook.Run("AddTabMenuItems", self);

	for k, v in pairs(self.menuItems) do
		local button = vgui.Create("reButton", self);
		button:SetDrawBackground(false);
		button:SetPos(curX - 20, curY);
		button:SetSize(200, 30);
		button:SetText(v.title);
		button:SetIcon(v.icon);
		button:SetFont(v.font or "rw_menuitem");

		button.DoClick = function(btn)
			if (v.override) then
				v.override(self, btn);
				return;
			end;

			if (v.panel) then
				if (IsValid(self.activePanel)) then
					self.activePanel:SetVisible(false);
					self.activePanel:Remove();
				end;

				self.activePanel = vgui.Create(v.panel, self);
				hook.Run("OnMenuPanelOpen", self, self.activePanel);
			end;

			if (v.callback) then
				v.callback(self, button);
			end;
		end;

		curY = curY + 32;

		self.buttons[k] = button;
	end;

	self.lerpStart = CurTime();
end;

function PANEL:AddMenuItem(id, data)
	data.title = data.title or "error";
	data.icon = data.icon or false;

	self.menuItems[id] = data;
end;

function PANEL:CloseMenu()
	self:SetVisible(false);
	self:Remove();
end;

function PANEL:OnMousePressed()
	if (IsValid(self.activePanel)) then
		self.activePanel:SetVisible(false);
		self.activePanel:Remove();
	end;
end;

function PANEL:Paint(w, h)
	if (!theme.Hook("PaintTabMenu", self, w, h)) then
		Derma_DrawBackgroundBlur(self, self.lerpStart);
		local fraction = (CurTime() - self.lerpStart) / 0.15;
		draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, Lerp(fraction, 0, 150)));
	end;
end;

vgui.Register("reTabMenu", PANEL, "EditablePanel");