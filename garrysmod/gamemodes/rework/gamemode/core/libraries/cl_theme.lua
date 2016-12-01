--[[ 
	Rework © 2016 TeslaCloud Studios
	Do not share, re-distribute or sell.
--]]

library.New("theme", _G);
theme.activeTheme = theme.activeTheme or nil;

local stored = theme.stored or {};
theme.stored = stored;

local cache = theme.cache or {};
theme.cache = cache;

function theme.GetStored()
	return stored;
end;

function theme.SetPanel(key, value)
	cache["menu_"..key] = value;
end;

function theme.GetPanel(key, fallback)
	return cache["menu_"..key] or fallback;
end;

function theme.CreatePanel(panelID, parent, fallback)
	local menu = theme.GetPanel(panelID, fallback);

	if (menu and hook.Run("ShouldThemeCreatePanel", panelID, menu) != false) then
		return vgui.Create(menu, parent);
	end;
end;

function theme.Hook(id, ...)
	if (typeof(id) == "string" and theme.activeTheme and theme.activeTheme[id]) then
		local result = {pcall(theme.activeTheme[id], theme.activeTheme, ...)};
		local success = result[1];
		table.remove(result, 1);

		if (!success) then
			ErrorNoHalt("[Rework] Theme hook '"..id.."' has failed to run!\n"..result[1].."\n");
		else
			return unpack(result);
		end;
	end;
end;

theme.Call = theme.Hook;

// A function to override theme's methods.
function theme.Override(themeID, id, callback)
	local themeTable = theme.FindTheme(themeID);

	if (themeTable and hook.Run("ShouldThemeOverride", id, themeTable) != false) then
		themeTable[id:MakeID()] = callback;
	end;
end;

function theme.GetActiveTheme()
	return (theme.activeTheme and theme.activeTheme.m_UniqueID);
end;

function theme.OverrideActive(id, callback)
	if (theme.activeTheme) then
		theme.Override(theme.GetActiveTheme(), id, callback);
	end;
end;

function theme.SetSound(key, value)
	cache["sound_"..key] = value;
end;

function theme.GetSound(key, fallback)
	return cache["sound_"..key] or fallback;
end;

function theme.SetColor(key, value)
	cache["color_"..key] = value;
end;

function theme.GetColor(key, fallback)
	return cache["color_"..key] or fallback;
end;

function theme.SetMaterial(key, value)
	cache["material_"..key] = value;
end;

function theme.GetMaterial(key, fallback)
	return cache["material_"..key] or fallback;
end;

function theme.FindTheme(id)
	return stored[id:MakeID()];
end;

function theme.RemoveTheme(id)
	if (theme.FindTheme(id)) then
		stored[id] = nil;
	end;
end;

function theme.RegisterTheme(obj)
	if (obj.parent and stored[obj.parent:MakeID()]) then
		local newObj = table.Copy(stored[obj.parent:MakeID()]);
		table.Merge(newObj, obj);
		obj = newObj;
	end;

	stored[obj.m_UniqueID] = obj;
end;

function theme.LoadTheme(theme)
	local themeTable = theme.FindTheme(theme);

	if (themeTable) then
		if (hook.Run("ShouldThemeLoad", themeTable) == false) then
			return;
		end;

		theme.activeTheme = themeTable;

		if (theme.activeTheme.OnLoaded) then
			theme.activeTheme:OnLoaded();

			hook.Run("OnThemeLoaded", theme.activeTheme);
		end;
	end;
end;

function theme.UnloadTheme()
	if (hook.Run("ShouldThemeUnload", theme.activeTheme) == false) then
		return;
	end;

	if (theme.activeTheme.OnUnloaded) then
		theme.activeTheme:OnUnloaded();

		hook.Run("OnThemeUnloaded", theme.activeTheme);
	end;

	theme.activeTheme = nil;
end;

local themeHooks = {};

function themeHooks:InitPostEntity()
	theme.LoadTheme("Factory");
end;

plugin.AddHooks("rwThemeHooks", themeHooks);