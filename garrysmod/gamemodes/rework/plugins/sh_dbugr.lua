function PLUGIN:Initialize()
	for hookName, hooks in pairs(plugin.GetCache()) do
		for k, v in ipairs(hooks) do
			local name = "N/A";
			local func = v[1];

			if (v[2] and v[2].GetName) then
				name = v[2]:GetName();
			elseif (v.id) then
				name = v.id;
			end;

			hooks[k][1] = DBugR.Util.Func.AttachProfiler(func, function(time) 
				DBugR.Profilers.Hook:AddPerformanceData(name..":"..hookName, time, func);
			end);
		end;
	end;

	DBugR.Print("Rework plugin hooks detoured!");
end;