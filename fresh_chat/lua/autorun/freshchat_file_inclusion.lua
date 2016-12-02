
freshChat = {}

local string = string
local table = table
local file = file

if SERVER then
	//resource.AddFile("")
end

AddCSLuaFile("fresh_chat_config.lua")
include("fresh_chat_config.lua")

function freshChat.addCoreFiles()
	local files, folders = file.Find("core/*", "LUA")
		
	for _, afile in pairs(files)do
		local location = "core/" .. afile

		if string.sub( afile, 1, 3 ) == "sh_" then
			if SERVER then AddCSLuaFile(location) end
			include(location)

		elseif string.sub( afile, 1, 3 ) == "cl_" then
			if SERVER then AddCSLuaFile(location) end
			if CLIENT then include(location) end

		elseif string.sub( afile, 1, 3 ) == "sv_" then
			if SERVER then include(location) end

		end
	end
end

freshChat.addCoreFiles()
