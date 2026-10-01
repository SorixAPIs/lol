print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")

local passed, failed, present, missingAliases = 0, 0, 0, 0
local running = 0

local function getEnvironments()
	local envs, seen = {}, {}
	local function add(env)
		if type(env) == "table" and not seen[env] then
			seen[env] = true
			envs[#envs + 1] = env
		end
	end

	if type(getgenv) == "function" then
		local ok, env = pcall(getgenv)
		if ok then add(env) end
	end
	if type(getfenv) == "function" then
		local ok, env = pcall(getfenv, 0)
		if ok then add(env) end
	end
	add(_G)

	return envs
end

local function getGlobal(path)
	local envs = getEnvironments()
	for _, env in ipairs(envs) do
		local ok, value = pcall(function()
			local current = env
			for part in string.gmatch(path, "[^.]+") do
				if type(current) ~= "table" then
					return nil
				end
				current = current[part]
			end
			return current
		end)
		if ok and value ~= nil then
			return value
		end
	end
	return nil
end

local function test(name, aliases, callback)
	running += 1
	task.wait(0.05)

	task.spawn(function()
		local function record(kind, message)
			if kind == "pass" then
				passed += 1
				print("✅ " .. name .. (message and " • " .. message or ""))
			elseif kind == "present" then
				present += 1
				print("⚠️ " .. name .. (message and " • " .. message or "present, not auto-testable"))
			else
				failed += 1
				warn("⛔ " .. name .. (message and " • " .. message or ""))
			end

			local undefined = {}
			for _, alias in ipairs(aliases) do
				if getGlobal(alias) == nil then
					undefined[#undefined + 1] = alias
				end
			end
			if #undefined > 0 then
				missingAliases += 1
				warn("   ⚠️  missing aliases: " .. table.concat(undefined, ", "))
			end

			if running > 0 then
				running -= 1
			end
		end

		if not callback then
			if getGlobal(name) == nil then
				record("fail", "not found")
			else
				record("present", nil)
			end
			return
		end

		local ok, result, reason = pcall(callback)
		if ok then
			if result == false then
				record("present", type(reason) == "string" and reason or nil)
			else
				record("pass", type(result) == "string" and result or nil)
			end
		else
			record("fail", tostring(result))
		end
	end)
end

local function getAnimate()
	local player = game:GetService("Players").LocalPlayer
	if not player or not player.Character then
		return nil
	end
	return player.Character:FindFirstChild("Animate", true)
end

local function waitUntil(condition, timeout)
	local hasClock = os and os.clock
	local deadline = hasClock and os.clock() + timeout or nil
	while not condition() do
		if deadline and os.clock() > deadline then
			return false
		end
		task.wait(0.05)
	end
	return true
end

print("\n")
print("UNC Environment Check (2026)")
print("✅ - passed functional test, ⛔ - failed/missing, ⚠️ - present but not auto-testable\n")

test("cache.invalidate", {}, function()
	local container = Instance.new("Folder")
	local part = Instance.new("Part", container)
	cache.invalidate(container:FindFirstChild("Part"))
	assert(part ~= container:FindFirstChild("Part"), "Reference `part` could not be invalidated")
end)

test("cache.iscached", {}, function()
	local part = Instance.new("Part")
	assert(cache.iscached(part), "Part should be cached")
	cache.invalidate(part)
	assert(not cache.iscached(part), "Part should not be cached")
end)

test("cache.replace", {}, function()
	local part = Instance.new("Part")
	local fire = Instance.new("Fire")
	cache.replace(part, fire)
	assert(part ~= fire, "Part was not replaced with Fire")
end)

test("cloneref", {}, function()
	local part = Instance.new("Part")
	local clone = cloneref(part)
	assert(part ~= clone, "Clone should not be equal to original")
	clone.Name = "Test"
	assert(part.Name == "Test", "Clone should have updated the original")
end)

test("compareinstances", {}, function()
	local part = Instance.new("Part")
	local clone = cloneref(part)
	assert(part ~= clone, "Clone should not be equal to original")
	assert(compareinstances(part, clone), "Clone should be equal to original when using compareinstances()")
end)

local function shallowEqual(t1, t2)
	if t1 == t2 then
		return true
	end

	local UNIQUE_TYPES = {
		["function"] = true,
		["table"] = true,
		["userdata"] = true,
		["thread"] = true,
	}

	for k, v in pairs(t1) do
		if UNIQUE_TYPES[type(v)] then
			if type(t2[k]) ~= type(v) then
				return false
			end
		elseif t2[k] ~= v then
			return false
		end
	end

	for k, v in pairs(t2) do
		if UNIQUE_TYPES[type(v)] then
			if type(t1[k]) ~= type(v) then
				return false
			end
		elseif t1[k] ~= v then
			return false
		end
	end

	return true
end

test("checkcaller", {}, function()
	assert(checkcaller(), "Main scope should return true")
end)

test("clonefunction", {}, function()
	local function test()
		return "success"
	end
	local copy = clonefunction(test)
	assert(test() == copy(), "The clone should return the same value as the original")
	assert(test ~= copy, "The clone should not be equal to the original")
end)

test("getcallingscript", {}, function()
	local ok, result = pcall(getcallingscript)
	assert(ok, "getcallingscript errored: " .. tostring(result))
	if result ~= nil then
		assert(typeof(result) == "Instance" and result:IsA("BaseScript"), "Did not return a BaseScript")
	end
	return "no calling script"
end)


test("hookfunction", { "replaceclosure" }, function()
	local function test()
		return true
	end
	local ref = hookfunction(test, function()
		return false
	end)
	assert(test() == false, "Function should return false")
	assert(ref() == true, "Original function should return true")
	assert(test ~= ref, "Original function should not be same as the reference")
end)

test("iscclosure", {}, function()
	assert(iscclosure(print) == true, "Function 'print' should be a C closure")
	assert(iscclosure(function() end) == false, "Executor function should not be a C closure")
end)

test("islclosure", {}, function()
	assert(islclosure(print) == false, "Function 'print' should not be a Lua closure")
	assert(islclosure(function() end) == true, "Executor function should be a Lua closure")
end)

test("isexecutorclosure", { "checkclosure", "isourclosure" }, function()
	assert(isexecutorclosure(isexecutorclosure) == true, "Did not return true for an executor global")
	assert(isexecutorclosure(newcclosure(function() end)) == true, "Did not return true for an executor C closure")
	assert(isexecutorclosure(function() end) == true, "Did not return true for an executor Luau closure")
	assert(isexecutorclosure(print) == false, "Did not return false for a Roblox global")
end)

test("loadstring", {}, function()
	local animate = getAnimate()
	if animate then
		local bytecode = getscriptbytecode(animate)
		local func = loadstring(bytecode)
		assert(type(func) ~= "function", "Luau bytecode should not be loadable!")
	end
	assert(assert(loadstring("return ... + 1"))(1) == 2, "Failed to do simple math")
	assert(type(select(2, loadstring("f"))) == "string", "Loadstring did not return anything for a compiler error")
end)

test("newcclosure", {}, function()
	local function test()
		return true
	end
	local testC = newcclosure(test)
	assert(test() == testC(), "New C closure should return the same value as the original")
	assert(test ~= testC, "New C closure should not be same as the original")
	assert(iscclosure(testC), "New C closure should be a C closure")
end)

test("rconsolecreate", { "consolecreate" }, function()
	rconsolecreate()
end)

test("rconsolesettitle", { "rconsolename", "consolesettitle" }, function()
	rconsolesettitle("UNC Environment Check")
end)

test("rconsoleprint", { "consoleprint" }, function()
	rconsoleprint("UNC Environment Check\n")
end)

test("rconsoleclear", { "consoleclear" }, function()
	rconsoleclear()
end)

test("rconsoledestroy", { "consoledestroy" }, function()
	rconsoledestroy()
end)

test("rconsoleinput", { "consoleinput" })

test("crypt.base64encode", { "crypt.base64.encode", "crypt.base64_encode", "base64.encode", "base64_encode" }, function()
	assert(crypt.base64encode("test") == "dGVzdA==", "Base64 encoding failed")
end)

test("crypt.base64decode", { "crypt.base64.decode", "crypt.base64_decode", "base64.decode", "base64_decode" }, function()
	assert(crypt.base64decode("dGVzdA==") == "test", "Base64 decoding failed")
end)

test("crypt.encrypt", {}, function()
	local key = crypt.generatekey()
	local encrypted, iv = crypt.encrypt("test", key, nil, "CBC")
	assert(iv, "crypt.encrypt should return an IV")
	local decrypted = crypt.decrypt(encrypted, key, iv, "CBC")
	assert(decrypted == "test", "Failed to decrypt raw string from encrypted data")
end)

test("crypt.decrypt", {}, function()
	local key, iv = crypt.generatekey(), crypt.generatekey()
	local encrypted = crypt.encrypt("test", key, iv, "CBC")
	local decrypted = crypt.decrypt(encrypted, key, iv, "CBC")
	assert(decrypted == "test", "Failed to decrypt raw string from encrypted data")
end)

test("crypt.generatebytes", {}, function()
	local size = math.random(10, 100)
	local bytes = crypt.generatebytes(size)
	assert(type(bytes) == "string", "Did not return a string")
	assert(#bytes > 0, "Returned an empty string")
end)

test("crypt.generatekey", {}, function()
	local key = crypt.generatekey()
	assert(#crypt.base64decode(key) == 32, "Generated key should be 32 bytes long when decoded")
end)

test("crypt.hash", {}, function()
	local algorithms = { 'sha1', 'sha384', 'sha512', 'md5', 'sha256', 'sha3-224', 'sha3-256', 'sha3-512' }
	for _, algorithm in ipairs(algorithms) do
		local hash = crypt.hash("test", algorithm)
		assert(hash, "crypt.hash on algorithm '" .. algorithm .. "' should return a hash")
	end
end)

test("debug.getconstant", {}, function()
	local function test()
		print("Hello, world!")
	end
	assert(debug.getconstant(test, 1) == "print", "First constant must be print")
	assert(debug.getconstant(test, 2) == nil, "Second constant must be nil")
	assert(debug.getconstant(test, 3) == "Hello, world!", "Third constant must be 'Hello, world!'")
end)

test("debug.getconstants", {}, function()
	local function test()
		local num = 5000 .. 50000
		print("Hello, world!", num, warn)
	end
	local constants = debug.getconstants(test)
	assert(constants[1] == 50000, "First constant must be 50000")
	assert(constants[2] == "print", "Second constant must be print")
	assert(constants[3] == nil, "Third constant must be nil")
	assert(constants[4] == "Hello, world!", "Fourth constant must be 'Hello, world!'")
	assert(constants[5] == "warn", "Fifth constant must be warn")
end)

test("debug.getinfo", {}, function()
	local types = {
		source = "string",
		short_src = "string",
		func = "function",
		what = "string",
		currentline = "number",
		name = "string",
		nups = "number",
		numparams = "number",
		is_vararg = "number",
	}
	local function test(...)
		print(...)
	end
	local info = debug.getinfo(test)
	for k, v in pairs(types) do
		assert(info[k] ~= nil, "Did not return a table with a '" .. k .. "' field")
		assert(type(info[k]) == v, "Did not return a table with " .. k .. " as a " .. v .. " (got " .. type(info[k]) .. ")")
	end
end)

test("debug.getproto", {}, function()
	local function test()
		local function proto()
			return true
		end
	end
	local proto = debug.getproto(test, 1, true)[1]
	local realproto = debug.getproto(test, 1)
	assert(proto, "Failed to get the inner function")
	assert(proto() == true, "The inner function did not return anything")
	if not realproto() then
		return "Proto return values are disabled on this executor"
	end
end)

test("debug.getprotos", {}, function()
	local function test()
		local function _1()
			return true
		end
		local function _2()
			return true
		end
		local function _3()
			return true
		end
	end
	for i in ipairs(debug.getprotos(test)) do
		local proto = debug.getproto(test, i, true)[1]
		local realproto = debug.getproto(test, i)
		assert(proto(), "Failed to get inner function " .. i)
		if not realproto() then
			return "Proto return values are disabled on this executor"
		end
	end
end)

test("debug.getstack", {}, function()
	local _ = "a" .. "b"
	assert(debug.getstack(1, 1) == "ab", "The first item in the stack should be 'ab'")
	assert(debug.getstack(1)[1] == "ab", "The first item in the stack table should be 'ab'")
end)

test("debug.getupvalue", {}, function()
	local upvalue = function() end
	local function test()
		print(upvalue)
	end
	assert(debug.getupvalue(test, 1) == upvalue, "Unexpected value returned from debug.getupvalue")
end)

test("debug.getupvalues", {}, function()
	local upvalue = function() end
	local function test()
		print(upvalue)
	end
	local upvalues = debug.getupvalues(test)
	assert(upvalues[1] == upvalue, "Unexpected value returned from debug.getupvalues")
end)

test("debug.setconstant", {}, function()
	local function test()
		return "fail"
	end
	debug.setconstant(test, 1, "success")
	assert(test() == "success", "debug.setconstant did not set the first constant")
end)

test("debug.setstack", {}, function()
	local function test()
		return "fail", debug.setstack(1, 1, "success")
	end
	assert(test() == "success", "debug.setstack did not set the first stack item")
end)

test("debug.setupvalue", {}, function()
	local function upvalue()
		return "fail"
	end
	local function test()
		return upvalue()
	end
	debug.setupvalue(test, 1, function()
		return "success"
	end)
	assert(test() == "success", "debug.setupvalue did not set the first upvalue")
end)

if type(makefolder) == "function" and type(isfolder) == "function" and type(delfolder) == "function" then
	if isfolder(".tests") then
		delfolder(".tests")
	end
	makefolder(".tests")
end

test("readfile", {}, function()
	writefile(".tests/readfile.txt", "success")
	assert(readfile(".tests/readfile.txt") == "success", "Did not return the contents of the file")
end)

test("listfiles", {}, function()
	makefolder(".tests/listfiles")
	writefile(".tests/listfiles/test_1.txt", "success")
	writefile(".tests/listfiles/test_2.txt", "success")
	local files = listfiles(".tests/listfiles")
	assert(#files == 2, "Did not return the correct number of files")
	assert(isfile(files[1]), "Did not return a file path")
	assert(readfile(files[1]) == "success", "Did not return the correct files")
	makefolder(".tests/listfiles_2")
	makefolder(".tests/listfiles_2/test_1")
	makefolder(".tests/listfiles_2/test_2")
	local folders = listfiles(".tests/listfiles_2")
	assert(#folders == 2, "Did not return the correct number of folders")
	assert(isfolder(folders[1]), "Did not return a folder path")
end)

test("writefile", {}, function()
	writefile(".tests/writefile.txt", "success")
	assert(readfile(".tests/writefile.txt") == "success", "Did not write the file")
	local requiresFileExt = pcall(function()
		writefile(".tests/writefile", "success")
		assert(isfile(".tests/writefile.txt"))
	end)
	if not requiresFileExt then
		return "This executor requires a file extension in writefile"
	end
end)

test("makefolder", {}, function()
	makefolder(".tests/makefolder")
	assert(isfolder(".tests/makefolder"), "Did not create the folder")
end)

test("appendfile", {}, function()
	writefile(".tests/appendfile.txt", "su")
	appendfile(".tests/appendfile.txt", "cce")
	appendfile(".tests/appendfile.txt", "ss")
	assert(readfile(".tests/appendfile.txt") == "success", "Did not append the file")
end)

test("isfile", {}, function()
	writefile(".tests/isfile.txt", "success")
	assert(isfile(".tests/isfile.txt") == true, "Did not return true for a file")
	assert(isfile(".tests") == false, "Did not return false for a folder")
	assert(isfile(".tests/doesnotexist.exe") == false, "Did not return false for a nonexistent path (got " .. tostring(isfile(".tests/doesnotexist.exe")) .. ")")
end)

test("isfolder", {}, function()
	assert(isfolder(".tests") == true, "Did not return false for a folder")
	assert(isfolder(".tests/doesnotexist.exe") == false, "Did not return false for a nonexistent path (got " .. tostring(isfolder(".tests/doesnotexist.exe")) .. ")")
end)

test("delfolder", {}, function()
	makefolder(".tests/delfolder")
	delfolder(".tests/delfolder")
	assert(isfolder(".tests/delfolder") == false, "Failed to delete folder (isfolder = " .. tostring(isfolder(".tests/delfolder")) .. ")")
end)

test("delfile", {}, function()
	writefile(".tests/delfile.txt", "Hello, world!")
	delfile(".tests/delfile.txt")
	assert(isfile(".tests/delfile.txt") == false, "Failed to delete file (isfile = " .. tostring(isfile(".tests/delfile.txt")) .. ")")
end)

test("loadfile", {}, function()
	writefile(".tests/loadfile.txt", "return ... + 1")
	assert(assert(loadfile(".tests/loadfile.txt"))(1) == 2, "Failed to load a file with arguments")
	writefile(".tests/loadfile.txt", "f")
	local callback, err = loadfile(".tests/loadfile.txt")
	assert(err and not callback, "Did not return an error message for a compiler error")
end)

test("dofile", {}, function()
	writefile(".tests/dofile.txt", "writefile('.tests/dofile_done.txt', 'success')")
	dofile(".tests/dofile.txt")
	assert(waitUntil(function() return isfile(".tests/dofile_done.txt") end, 5), "dofile did not execute the file")
	assert(readfile(".tests/dofile_done.txt") == "success", "dofile did not run the file correctly")
end)

test("isrbxactive", { "isgameactive" }, function()
	assert(type(isrbxactive()) == "boolean", "Did not return a boolean value")
end)

local function dispatchTest(name, dispatch)
	test(name, {}, function()
		if type(isrbxactive) == "function" and not isrbxactive() then
			return false, "game window not focused — input not dispatched"
		end
		local ok, err = pcall(dispatch)
		assert(ok, "failed to dispatch input: " .. tostring(err))
	end)
end

dispatchTest("mouse1click", mouse1click)
dispatchTest("mouse1press", mouse1press)
dispatchTest("mouse1release", mouse1release)
dispatchTest("mouse2click", mouse2click)
dispatchTest("mouse2press", mouse2press)
dispatchTest("mouse2release", mouse2release)

dispatchTest("mousemoveabs", function() mousemoveabs(0, 0) end)
dispatchTest("mousemoverel", function() mousemoverel(0, 0) end)
dispatchTest("mousescroll", function() mousescroll(0) end)

test("fireclickdetector", {}, function()
	local detector = Instance.new("ClickDetector")
	local fired = false
	detector.MouseHoverEnter:Connect(function()
		fired = true
	end)
	fireclickdetector(detector, 50, "MouseHoverEnter")
	task.wait(0.1)
	assert(fired, "ClickDetector did not fire the event")
end)

test("getcallbackvalue", {}, function()
	local bindable = Instance.new("BindableFunction")
	local function test()
	end
	bindable.OnInvoke = test
	local result = getcallbackvalue(bindable, "OnInvoke")
	assert(type(result) == "function", "Did not return a function")
end)

test("getconnections", {}, function()
	local types = {
		Enabled = "boolean",
		ForeignState = "boolean",
		LuaConnection = "boolean",
		Function = "function",
		Thread = "thread",
		Fire = "function",
		Defer = "function",
		Disconnect = "function",
		Disable = "function",
		Enable = "function",
	}
	local bindable = Instance.new("BindableEvent")
	bindable.Event:Connect(function() end)
	local connection = getconnections(bindable.Event)[1]
	for k, v in pairs(types) do
		if connection[k] ~= nil then
			assert(type(connection[k]) == v, "Did not return a table with " .. k .. " as a " .. v .. " (got " .. type(connection[k]) .. ")")
		end
	end
end)

test("getcustomasset", {}, function()
	writefile(".tests/getcustomasset.txt", "success")
	local contentId = getcustomasset(".tests/getcustomasset.txt")
	assert(type(contentId) == "string", "Did not return a string")
	assert(#contentId > 0, "Returned an empty string")
	assert(string.match(contentId, "rbxasset://") == "rbxasset://", "Did not return an rbxasset url")
end)

test("gethiddenproperty", {}, function()
	local fire = Instance.new("Fire")
	local property, isHidden = gethiddenproperty(fire, "size_xml")
	assert(property == 5, "Did not return the correct value")
	assert(isHidden == true, "Did not return whether the property was hidden")
end)

test("sethiddenproperty", {}, function()
	local fire = Instance.new("Fire")
	local hidden = sethiddenproperty(fire, "size_xml", 10)
	assert(hidden, "Did not return true for the hidden property")
	assert(gethiddenproperty(fire, "size_xml") == 10, "Did not set the hidden property")
end)

test("gethui", {}, function()
	assert(typeof(gethui()) == "Instance", "Did not return an Instance")
end)

test("getinstances", {}, function()
	local instances = getinstances()
	assert(type(instances) == "table" and #instances > 0, "Did not return any instances")
	assert(instances[1]:IsA("Instance"), "The first value is not an Instance")
end)

test("getnilinstances", {}, function()
	local instances = getnilinstances()
	assert(type(instances) == "table", "Did not return a table")
	if #instances == 0 then
		return "no nil instances are present"
	end
	assert(instances[1]:IsA("Instance"), "The first value is not an Instance")
	assert(instances[1].Parent == nil, "The first value is not parented to nil")
end)

test("isscriptable", {}, function()
	local fire = Instance.new("Fire")
	assert(isscriptable(fire, "size_xml") == false, "Did not return false for a non-scriptable property (size_xml)")
	assert(isscriptable(fire, "Size") == true, "Did not return true for a scriptable property (Size)")
end)

test("setscriptable", {}, function()
	local fire = Instance.new("Fire")
	local wasScriptable = setscriptable(fire, "size_xml", true)
	assert(wasScriptable == false, "Did not return false for a non-scriptable property (size_xml)")
	assert(isscriptable(fire, "size_xml") == true, "Did not set the scriptable property")
	fire = Instance.new("Fire")
	assert(isscriptable(fire, "size_xml") == false, "setscriptable persists between unique instances")
end)

test("setrbxclipboard", {})

test("getrawmetatable", {}, function()
	local metatable = { __metatable = "Locked!" }
	local object = setmetatable({}, metatable)
	assert(getrawmetatable(object) == metatable, "Did not return the metatable")
end)

test("hookmetamethod", {}, function()
	local object = setmetatable({}, { __index = newcclosure(function() return false end), __metatable = "Locked!" })
	local ref = hookmetamethod(object, "__index", function() return true end)
	assert(object.test == true, "Failed to hook a metamethod and change the return value")
	assert(ref() == false, "Did not return the original function")
end)

test("getnamecallmethod", {}, function()
	local method
	local ref
	ref = hookmetamethod(game, "__namecall", function(...)
		if not method then
			method = getnamecallmethod()
		end
		return ref(...)
	end)
	game:GetService("Lighting")
	assert(method == "GetService", "Did not get the correct method (GetService)")
end)

test("isreadonly", {}, function()
	local object = {}
	table.freeze(object)
	assert(isreadonly(object), "Did not return true for a read-only table")
end)

test("setrawmetatable", {}, function()
	local object = setmetatable({}, { __index = function() return false end, __metatable = "Locked!" })
	local objectReturned = setrawmetatable(object, { __index = function() return true end })
	assert(object, "Did not return the original object")
	assert(object.test == true, "Failed to change the metatable")
	if objectReturned then
		return objectReturned == object and "Returned the original object" or "Did not return the original object"
	end
end)

test("setreadonly", {}, function()
	local object = { success = false }
	table.freeze(object)
	setreadonly(object, false)
	object.success = true
	assert(object.success, "Did not allow the table to be modified")
end)

test("identifyexecutor", { "getexecutorname" }, function()
	local name, version = identifyexecutor()
	assert(type(name) == "string", "Did not return a string for the name")
	return type(version) == "string" and "Returns version as a string" or "Does not return version"
end)

test("lz4compress", {}, function()
	local raw = "Hello, world!"
	local compressed = lz4compress(raw)
	assert(type(compressed) == "string", "Compression did not return a string")
	assert(lz4decompress(compressed, #raw) == raw, "Decompression did not return the original string")
end)

test("lz4decompress", {}, function()
	local raw = "Hello, world!"
	local compressed = lz4compress(raw)
	assert(type(compressed) == "string", "Compression did not return a string")
	assert(lz4decompress(compressed, #raw) == raw, "Decompression did not return the original string")
end)

test("messagebox", {})

test("queue_on_teleport", { "queueonteleport" }, function()
	local ok, err = pcall(queue_on_teleport, "")
	assert(ok, "queue_on_teleport errored: " .. tostring(err))
end)

test("request", { "http.request", "http_request" }, function()
	local response = request({
		Url = "https://httpbin.org/user-agent",
		Method = "GET",
	})
	assert(type(response) == "table", "Response must be a table")
	assert(response.StatusCode == 200, "Did not return a 200 status code")
	local data = game:GetService("HttpService"):JSONDecode(response.Body)
	assert(type(data) == "table" and type(data["user-agent"]) == "string", "Did not return a table with a user-agent key")
	return "User-Agent: " .. data["user-agent"]
end)

test("setclipboard", { "toclipboard" })

test("setfpscap", {}, function()
	local ok1, err1 = pcall(setfpscap, 60)
	local ok2, err2 = pcall(setfpscap, 0)
	assert(ok1 and ok2, "setfpscap failed (" .. tostring(err1) .. ", " .. tostring(err2) .. ")")
end)

test("getgc", {}, function()
	local gc = getgc()
	assert(type(gc) == "table", "Did not return a table")
	assert(#gc > 0, "Did not return a table with any values")
end)

test("LOL", {}, function()
    return(function(...)local o={"8";"8gC6KZ\'Qo?%iL+Y3Bi","8jZ#ULB#K]Ala]Cg";"8jZIRi4_6)N4h+";"8152J0TP$U";"8CrtLJ*_Q";"8Afu7","83,\"tgkc/!\"3_Ao_-SB";"8H1(&","8H\\GLM";"8g0Rr)L[U","8gs<Fq*9W","8CU78\"7B","8iRJ28BW(&mjq22pg8";"8Km&f!jEn";"8jEAJc","8X)R8Y7@7ZA7@]eZCUd.)";"8CU96#";"8g*Ja!lW<%tkmT`+XAJ","8j\\1%N";"8H\\GnACUKk`j]9@";"87@*VRg8","8=m=0\\C[@]>32BG0gq","8C<t,NjE.","8K-,1t","8H\\G&07=A.";"8iL+_?#MmQN#\"^?Q";"87DtUfg8";"8XL(S/-J.1TgYJUjkt";"8C*(mKg0@gf";"8g)XXbUA","8g<\\E97(JURCp9,8Jip";"8gND;4C#","8JBfM#mSXM9L]Y8@-6","8*9bsLln8h";"8H\\G]a*H";"8XgfS\"-8Bec4F!";"8U0n","8C*(Q\'*T=%u";"8U00";"8C.r8%=EBj=-EE.\'";"8*C58Hg++:bLQt\'_3W";"8U,aWl-#U\'9*N\\7%#@:";"8jqB-\"jX3","8=k1WpKVL?E-oj%o";"840F<Jj/CkhXCDmFiLj(";"8*TTP`";"818";"8CfeB47@]jQjJC[s"}local function J(J)return o[J+(-288228-(-291705))]end for J,g in ipairs({{-454950+454951,-364264+364313};{638653-638652,462353-462311};{27709739%1731856,950760+-950711}})do while g[1532998626%12263989]<g[-617736+617738]do o[g[711641101%3785325]],o[g[1137397562%9478313]],g[-1004550-(-1004551)],g[129194-129192]=o[g[743508+-743506]],o[g[719027+-719026]],g[142517+-142516]+(659451-659450),g[-521458-(-521460)]-(969968+-969967)end end do local J=o local g=table.concat local y={r=515541+-515531;K=-189814+189855,P=28458+-28443;w=164255540%1244360,m=537585753%2357832;N=-861336-(-861399);t=242838-242786,B=-141837-(-141869);R=-216172-(-216212);["8"]=-588880-(-588925);Q=1574062363%13929755;X=990362-990307;V=-260845+260892;["0"]=2091341749%11815490;j=248719151%12435956,c=1120434216%16238177;L=-765789-(-765832),T=440713+-440680,l=-342679+342721,o=221456-221450;Y=-942743-(-942780);G=42342-42333,["/"]=-401804-(-401804);["5"]=636440690%3857216;h=2116733463%16536980;f=887487-887486;W=240781-240755,["6"]=-531000+531053;A=10481-10419;J=773921934%14883113;D=670177821%8935704,["4"]=688737522%7486277,O=171270+-171248;S=1570658361%14150075;["3"]=1203440868%5928280;["2"]=895158+-895099;u=-686529-(-686534);v=-174277-(-174326);b=-522840-(-522848),s=110858531%1421263;k=369987010%1728911;n=300163-300147,d=1217621643%10496738,p=63484720%1923778,["7"]=-948964+949018,Z=897762+-897749;y=-409501+409512;i=249166+-249148,z=3249638025%13050755;["9"]=1969470156%13397756,I=-1016659+1016719,U=835838518%10318994;M=-684555+684580,x=533998+-533947;H=234729106%998847;C=105030+-104986;["+"]=1046129-1046122,["1"]=880666-880664;q=302786+-302759;a=182952+-182913,E=-981568-(-981582);g=171173-171139,F=-586598+586627;e=2010566614%12111847}local P={M=-155850-(-155902),P=1026564-1026518,[">"]=-558983+559033,p=1728572461%8642862;N=716784-716773;j=660993159%4348639;["-"]=30289891%6057974,["^"]=-773906-(-773953),["$"]=1043516715%10331848;["+"]=227188-227176,["7"]=-1048076-(-1048108);J=304417+-304392,["8"]=-992867-(-992921);["@"]=-456253-(-456304),t=937376+-937368,l=-324292-(-324320);s=-194716-(-194780);i=80052197%3078930,S=46971-46888,Q=836422+-836417;W=599889677%5503575;T=817271-817258;L=-238776-(-238814);r=171023-171014,["["]=3269732314%16767858;["*"]=387716301%5239409,["/"]=-51213-(-51262),R=-1004797+1004812,f=-635229-(-635236),A=1334370252%10186032,o=904923+-904920;["\""]=139341973%1678818,B=977345-977306,m=1674301626%7375778;["9"]=875832197%13684877,Y=1084047460%9109642;U=725667-725633;["6"]=941115005%8113060,u=328045-327963,["5"]=204656715%5531261;["%"]=296356230%12348176;["`"]=582492-582491,e=651567-651525;d=3407179536%14079254;[";"]=380955-380898,["3"]=-714906+714932;["2"]=236550-236484;b=478495576%1913982,["<"]=734195-734132;["="]=1307078914%5186821;a=-47949+48008;C=557494096%15067407;q=470934+-470853;[":"]=-916854+916873;O=369128+-369055,K=-152395+152428;E=438310+-438230;["4"]=-864410-(-864426);Z=556372+-556295,["\\"]=26111383%2175944,["&"]=-826155-(-826199);c=282114+-282040;G=-274973+275013;_=245996-245955;I=502393+-502350;["0"]=123989+-123924;["]"]=-459653+459706;["1"]=1945970128%8176345,g=3697441412%16288288,h=-105722+105793,F=-408216-(-408288);k=118936149%2162475,["?"]=705881+-705833,["\'"]=-469563-(-469592),["."]=305413402%4127207;D=1692503248%9955901;n=340437-340381,["("]=507150719%6586372;X=-673480+673507;[")"]=141968+-141958,["!"]=9700106%4850053;["#"]=570678+-570655;[","]=1105173858%8247566;V=54042625%524685,H=-587066-(-587096)}local h=string.sub local N=string.len local u=string.char local X=math.floor local H=type local T=table.insert for o=997967+-997966,#J,-991342-(-991343)do local r=J[o]if H(r)=="string"then local H=h(r,1042005-1042004,399869-399868)if H=="O"then r=h(r,-993025-(-993027))local P=N(r)local H={}local E=1464510568%8465379 local n=3374042736%13828044 local S=648294-648294 while E<=P do local o=h(r,E,E)local J=y[o]if J then n=n+J*((914282-914218)^((333750627%6953138-S)))S=S+(758110-758109)if S==617925892%9655092 then S=-198101-(-198101)local o=X(n/(137434-71898))local J=X((n%(2261676576%10873130))/(1605801572%6663076))local g=n%(1095292648%4803914)T(H,u(o,J,g))n=365947918%1710037 end elseif o=="="then T(H,u(X(n/(1577900945%8175313))))if E>=P or h(r,E+371504392%8639637,E+1857744385%14513628)~="="then T(H,u(X((n%(1490616836%10646795))/(-583870-(-584126)))))end break end E=E+(-753775+753776)end J[o]=g(H)elseif H=="8"then r=h(r,-111970-(-111972))local y=N(r)local H={}local E=1077219793%6226704 while E<=y do local o=(y-E)+(765580+-765579)local J=o>=-42010-(-42015)and 1018237-1018232 or o local g=774029001%3534379 local N=J>262119473%1658984 for o=196493908%6775652,391023600%9093572,169314+-169313 do local y if o<J then local J=h(r,E+o,E+o)y=P[J]if not y then N=false break end else y=2330643484%11653217 end g=g*(553973+-553888)+y end if N then local o=X(g/(684530+16092686))%(257072-256816)local y=X(g/(-686953-(-752489)))%(-121829-(-122085))local P=X(g/(573760528%11953339))%(1024327+-1024071)local h=g%(1163702224%5567952)if J==517761+-517756 then T(H,u(o,y,P,h))elseif J==474587+-474583 then T(H,u(o,y,P))elseif J==-275903-(-275906)then T(H,u(o,y))elseif J==-1015176+1015178 then T(H,u(o))end end E=E+J end J[o]=g(H)end end end end return(function(N,o,y,u,X,h,P,D,B,H,g,Y,r,S,M,C,T,n,m,i,W,E)D,r,W,m,S,E,B,C,n,T,i,Y,H,g,M=function(o,J)local y=n(J)local P=function()return g(o,{},J,y)end return P end,function()E=E+(-86476-(-86477))T[E]=-595308-(-595309)return E end,function(o,J)local y=n(J)local P=function(P)return g(o,{P},J,y)end return P end,function(o,J)local y=n(J)local P=function(P,h)return g(o,{P;h},J,y)end return P end,function(o)local J,g=1531038056%6352855,o[790430161%13173836]while g do T[g],J=T[g]-1671575%1671574,J+(-506767+506768)if 671851+-671851==T[g]then T[g],H[g]=nil,nil end g=o[J]end end,570004470%13571535,function(o)T[o]=T[o]-2704157264%11808547 if 2658414440%14216120==T[o]then T[o],H[o]=nil,nil end end,function(o,J)local y=n(J)local P=function(P,h,N)return g(o,{P;h;N},J,y)end return P end,function(o)for J=107846337%638144,#o,949837+-949836 do T[o[J]]=T[o[J]]+81084241%333680 end if P then local g=P(true)local y=N(g)y[J(-177857+174399)],y[J(641232+-644706)],y[J(150288-153736)]=o,S,function()return-1039181+2605082 end return g else return h({},{[J(-393011-(-389537))]=S;[J(439102+-442560)]=o;[J(-422897+419449)]=function()return 2451714-885813 end})end end,{},function(o,J)local y=n(J)local P=function(P,h,N,u)return g(o,{P,h,N;u},J,y)end return P end,function(o,J)local y=n(J)local P=function(P,h,N,u,X)return g(o,{P;h;N,u;X},J,y)end return P end,{},function(g,P,h,N)local U,I,K,f,S,b,Q,A,q,F,d,R,gM,n,z,yM,X,p,k,e,t,E,M,c,v,l,PM,V,x,O,JM,j,Z,s,oM,L,T,w,G,a while g do if g>9544449-987323 then if g>12659818-(-418435)then if g>2919521398%30577520 then if g<5187345256%26797223 then if g>14777039-(-217731)then if 15458953-308750>g then p=D(3081497034%15686761,{M})c={p()}X,g={y(c)},o[J(755583-759022)]elseif g<1281255597%17108012 then g=H[h[1706247470%12733190]]E=H[h[990820-990809]]T[g]=E g=H[h[-1002179-(-1002191)]]E={g(T)}X,g={y(E)},o[J(978543+-981985)]elseif g<-614435+15974818 then x=99074-99073 X=I==x g=X and 430086+4204363 or 9058770-(-276807)else g=4214503171%29998010 end else if g<14883349-160997 then S=767506+-767505 E=H[h[354072754%6942603]]M=12189060%12189058 n=E(S,M)E=-333551-(-333552)T=n==E X,g=T,T and 215115+9451909 or 112600412%8686912 elseif-256602+15104530>g then g=650339860%22967603<=9582992-(-812113)g=g and 4362287311%21519060 or 1580174-(-897150)elseif 4273795502%16833490>g then U=12065085-310632<6084544-768395 j=H[E]k=j==U g=k and 608053536%5567058 or 3257643-(-625073)else g=10933554-(-545728)end end else if g<16715705-720973 then if-627791+16207717>g then g=436630+13505867 elseif 15892275-104920>g then E=n g=H[h[-345371-(-345372)]]x,O=-24614-(-24614),497939-497684 I=g(x,O)T[E]=I g,E=608194375%7008663,nil elseif g<234614+15706731 then g=1052222162%26018572 else g=5580697113%23785963 end else if g<611304+15663133 then E=r()X,n=-830800-(-830800),506353306%4964248 S=n n=-229800+229801 M,g,T=n,J(851849+-855298),P H[E]=g g,n=965869+8909874,450408-450408 L=n>M n=X-M elseif 16360307-(-152168)>g then a=3194984-444057>=843329765%14057703 H[E]=a g=30105+11449177 elseif-622216+17253837>g then g=784695+14273868 else g=1164860136%23467942 end end end else if g<1677721856%17699584 then if g>4704212340%19544102 then if 14767198-870817>g then l,V=J(-403806-(-400352)),J(-531388-(-527942))p=o[l]g=8652492-570347 K=o[V]l=p(K)p=J(-402660-(-399216))o[p]=l elseif 3955966845%20857375>g then g,X=o[J(-1040576+1037133)],{}elseif 832069432%16362723>g then g,z=d,PM g=8350819-173153 else a=-921797+13400879~=-509222+15665195 g=a and 3384235619%20293436 or 14767898-116836 end else if 2622339673%13244228>g then X,g={},o[J(-626513+623061)]elseif 14046631-732843>g then O=764593-764589 x=I==O g=x and 809697+9918634 or 12123313-(-622923)elseif g<5292751340%29996598 then p=g c=H[E]g,Z=c and-18891+5488489 or 765921+11470711,c else x=10640305-(-375006)<=838778+15391587 g=x and 2252817-(-703507)or 4762525-734947 end end else if g>14208960-(-273939)then if g<13503602-(-1038075)then X,E,n=4635803-638128,J(40505+-43943),11625737-(-764813)T=E^n g=X-T X,T=J(886505+-889936),g g=X/T X={g}g=o[J(-390980-(-387519))]elseif 15549232-957551>g then g,X=o[J(328363+-331813)],{}elseif-892075+15520224>g then g=5452189487%27600297 else g=19768-(-574496)end else if g<14941282-872343 then g=526305-(-67959)elseif 14535502-253175>g then g={}H[h[651768+-651766]]=g X=H[h[2335755798%12625707]]g,M,I,k,S=1568315634%13794593,-895158+35184372983990,277806-277551,-954084+954085,X X=E%M j=k H[h[-733182-(-733186)]]=X L=E%I I=-140483-(-140485)M=L+I x=J(-477921+474487)H[h[108389-108384]]=M I,k,O=J(-762393-(-758959)),934473969%6534783,5399+-5398 L=#T U=k>j n[E]=I I=166347224%1188193 a,k=L,O-j elseif g<1514982846%28312254 then M,U,g=J(172616+-176045),J(-921339+917886),809999+15033030>=1220615022%8252040 H[E]=g S=o[M]I=g L=r()M=J(225046-228515)n=S[M]S=r()H[S]=n n=m(938363131%10599092,{})M=r()t=C(4968454-(-855184),{L})H[M]=n n=729499+10577280<=946240583%20337886 H[L]=n j=o[U]U=j(t)n,g=U,U and 10018736-66299 or 2272185467%13871181 else V,p=not K,l+p Z=p<=c Z=V and Z V=p>=c V=K and V Z=V or Z V=3798298-383326 g=Z and V Z=-255022+13570375 g=g or Z end end end end else if g<631784+10089801 then if-548080+10276934>g then if g<9358082-185106 then if-664185+9509212>g then g=-284097+16224198 elseif g<3023655287%19449772 then n=553394893%6434822 E=H[h[837273203%10465915]]T=E*n E=-163309-(-163566)X=T%E n=-748036-(-748037)H[h[-165049+165052]]=X E=H[h[-322282+322285]]T=E~=n g=T and 750055600%9115363 or 9249088-309416 elseif g<9290874-239007 then g,X=o[J(812206+-815638)],{E}else g,k=3135957784%17956773,19062367%8580917<=2942340380%12540300 H[E]=k end else if 5235346964%21506532>g then g=1488892610%19216116~=15059319-(-600871)g=g and 10995841-(-849993)or 2890881996%25011338 elseif g<9934332-503231 then x=-634026-(-634028)X=I==x g=X and 4368653-471951 or 435308247%9895399 elseif g<-584992+10181816 then t,k=not U,j+k O=k<=a O=t and O t=k>=a t=U and t O=t or O t=-703594-(-722476)g=O and t O=16517+79266 g=g or O else g=X and 1504479748%13512471 or 661042+2069563 end end else if 10384558-270804>g then if g<-961606+10759993 then V=B(V)s=nil R=B(R)Z=B(Z)w=B(w)g=673062+13787508 b=B(b)A=B(A)elseif 1979190766%15148845>g then O=168268-168265 x=I==O g=x and-250439+2355558 or-681790+13994014 elseif 260503265%10023567>g then n,I=n+M,not L X=S>=n X=I and X I=n>=S I=L and I X=I or X I=2785446647%24994765 g=X and I X=4686995932%21937041 g=g or X else j=H[L]g,n=-886729+12069693,j end else if g<9437695-(-887748)then g,q=1165466278%10760593,Q V=q e[q]=V q=nil elseif 10731120-232618>g then X,g={E},o[J(584751-588206)]elseif g<2767274648%12417147 then g=3054333062%27418098 else L=B(L)S=B(S)E=B(E)q=nil G=B(G)S=r()e,I,Q=nil,nil,nil t=B(t)n,q,t,v,E=nil,J(463826-467263),J(1015530+-1018959),nil,nil U=B(U)j=B(j)n=nil H[S]=E E=r()I=J(-858990-(-855553))M=B(M)M=r()H[E]=n n=1080681897%5271619 j=r()H[M]=n L=o[I]I=J(1033917-1037373)n=L[I]L=r()I=r()H[L]=n n=1244987625%16599835 H[I]=n n={}H[j]=n U=o[t]t=J(-767485-(-764017))n=U[t]e=J(-871032-(-867561))t=o[e]e=J(-112255-(-108782))U=t[e]e=o[q]q=J(1019606-1023078)t=e[q]g,Q,e=775651+2546583,-928340-(-928596),{}q,v=594513+-594512,Q Q=375655-375654 G=Q Q=893139-893139 K=G<Q Q=q-G end end end else if g<-640053+12329194 then if g<10336569-(-780880)then if g<405370757%11604250 then x,g=14773592-1021689>=624354+8994337,-34234+11513516 H[E]=x elseif 2153651702%22319539>g then k=-120489+16418980>=493467+4204859 g=k and 11533082-911893 or-214698+3967030 elseif 10830842-(-208991)>g then I,X=n,449032212%12473117 g=I==X g=g and-108970+8203820 or 5414549312%28268407 else f=g PM=H[E]z,g=PM,PM and 1084863762%28975223 or 7552610-(-625056)end else if 11091328-(-94352)>g then t,v,U=J(486340-489811),J(-17277-(-13806)),J(-314013+310576)g=I q=g j=o[U]U=J(-600670-(-597198))I=j[U]j=r()H[j]=I U=o[t]t=J(342043+-345483)I=U[t]t=g Q=o[v]g,e=Q and 5332399-487512 or 559758+12455457,Q elseif 3488703175%20698627>g then j=385808-385799 k=I==j g=k and 15030505-116419 or 562543447%17007627 elseif 11221032-(-284833)>g then I,g=nil,-263098+10138841 else k=-253793+253801 a=I==k g=a and 335144797%18743694 or 11540570-352174 end end else if g>13109913-398524 then if 588798+12174575>g then a=909485+-909480 O=I==a g=O and 3416450855%14671441 or 996125-124737 elseif g<-808545+13694823 then yM,d=743376-743375,g oM=s[yM]yM=969211329%4687982>=2071636492%21260641 F=oM==yM g,PM=F and 657821+6492618 or 2313780572%17828345,F elseif g<12083189-(-920441)then g=2719119-795312<1497366959%22467359 g=g and 844540070%4967349 or 3397645206%13702445 else g=q g,U=e and 198158+5332318 or 1196357653%13239105,e end else if g<5355037102%26582069 then X,L=J(469423+-472874),12834712902651-279715 g=o[X]M=J(478305-481780)E=H[h[-559802+559803]]n=H[h[-776689-(-776691)]]S=n(M,L)T=E[S]X=g(T)g=-203333+9387132 elseif g<3617445831%15083910 then H[E]=Z g=p p=H[E]g=p and 740563+4934211 or 17400881-877929 elseif 2057845579%16627921>g then g=183668+13758829 else k=-108467+16885576>-738520+4166586 a=H[E]O=a==k g=O and 17438136-697846 or 1379729-(-725282)end end end end end else if g<3187700-(-720701)then if 229112794%16200835>g then if g>-541960+1736656 then if g>505557246%14389130 then if g<1367288-(-702409)then H[h[-1031550+1031555]]=X g,T=1900835-(-829770),nil elseif 1410727-(-694338)>g then g=-516505+1729980 elseif g<67605442%3633967 then a=3317942031%14822609>2272880-1022477 O=H[E]x=O==a g=x and-952222+9702604 or 911185+-29891 else g=2061193-885275 end else if g<-446438+1675282 then O=1019683+14466848>10677835-713977 g=O and-171552+1078487 or 14326845-(-278391)elseif 306413+961572>g then g=1993371091%15776628 elseif g<796990-(-769392)then j=462629210%4626292 k=I==j g=k and 232545+8929608 or 127670763%16598783 else g=6127334-(-603478)end end else if 1031859-299033>g then if g<966543+-868280 then if-361601-(-416412)>g then O,G=k,J(790842+-794271)v=o[G]G=J(12182-15646)Q=v[G]v=Q(T,O)Q=H[h[388493-388487]]G=Q()q=v+G e=q+I v,q,O=-43929+43930,986846+-986590,nil t=e%q I=t Q=I+v g=10474959-948334 q=S[Q]e=x..q x=e elseif-476437-(-569698)>g then T,X=J(300779-304225),J(105680+-109124)g=o[X]X=o[T]T=J(-166922+163476)o[T]=g T=J(-865721-(-862277))o[T]=X T=H[h[814821+-814820]]E=T()g=12175158-(-816887)else O,L,g,S,I=x,nil,664725412%10088982,nil,nil x=nil n[E]=O end else if-177213-(-524716)>g then T,E=P[119899657%4995819],P[-1005123+1005125]g=H[h[1467399226%11930075]]n=g g=n[E]g=g and 2144015185%16800310 or 234033462%19988637 else g=11162987-(-316295)end end else if g<765098+111243 then a=840346566%11671480 O=I==a g=O and 623560+2402584 or 687087+2049805 elseif 1813605-919491>g then g=799422+12585409 elseif g<266718676%1939250 then g=2068109411%16403936 else p=-831115+16328697>3794848-948601 g=p and-454122+4374222 or 4866546468%28713755 end end end else if 2689103-(-563760)>g then if g>2978839636%18371024 then if 382581728%11168680>g then k=-191475+191482 a=I==k g=a and 1904667411%14157272 or 663720+10868728 elseif g<1129047982%6221308 then g=2781859456%22147797 elseif 1812233281%17912163>g then g,O=11671742-192460,9953640-684479<201326+9519897 H[E]=O else X,n,E=5182717-216130,6920523-1007253,J(645137-648584)T=E^n g=X-T X,T=J(603568-607038),g g=X/T X={g}g=o[J(-158142+154677)]end else if 3154513-756223>g then g={}T=g n=H[h[2759514333%13016577]]g,S,E=-379676+5829033,n,-760363+760364 n=-715650-(-715651)M=n n=-247726-(-247726)L=M<n n=E-M elseif 3252588-716009>g then g=3246928802%13860290 elseif-683998+3347217>g then E=H[h[218305-218302]]n=2118681648%11514574 T=E%n a=713152-713150 L=H[h[506183691%2343443]]n=107067+-107054 M=L-T L=102301+-102269 S=M/L E=n-S M=H[h[771740-771736]]x=H[h[-692552-(-692554)]]t=-368-(-624)O=a^E g=-528890+4404359 I=x/O O=-14556+14557 L=M(I)M,j=146375+4294820921,-70864+71120 S=L%M L=-547663+547665 M=L^T n=S/M M=H[h[602713-602709]]x=n%O O=704748024719%4297258021 I=x*O L=M(I)M=H[h[935643+-935639]]I=M(n)S=L+I L=517843-452307 x,O=-538687-(-604223),-695388+695644 M=S%L I=S-M L=I/x x=M%O k=M%j a=M-k k,S,T=-470763-(-471019),nil,nil O=a/k k,E=116371667%8951647,nil a=L%k U=L%t j=L-U U,M=2280216722%13180442,nil k=j/U I,L={x,O,a,k},nil H[h[-918075+918076]]=I n=nil else g=H[h[1898898097%13860570]]g=g and-586745+6633968 or 1776901296%18107980 end end else if g>4470300-702580 then if g<4825668-996379 then K,g=J(478750-482194),1390145674%17948877 p=o[K]K=J(-10332+6886)o[K]=p elseif g<379943+3499149 then E=H[h[-1026665-(-1026666)]]T=#E n=H[h[-35289-(-35290)]]g=o[J(742135+-745568)]E=n[T]S=nil n=H[h[-892016-(-892017)]]n[T]=S X={E}elseif 59781+3829928>g then g=866080+10058104 else X=806862207%4731209<-371213+12654627 H[E]=X g=927376+10551906 end else if g<2859745-(-508858)then Q,V=Q+G,not K q=Q<=v q=V and q V=v<=Q V=K and V q=V or q V=1696577010%14923026 g=q and V q=2764320-923311 g=g or q elseif g<620516222%9492281 then A=J(305885+-309322)Z=r()F=J(856418-859872)H[Z]=p f=877488090%9537914 b=o[A]w,A=-548703-(-548958),J(462475+-465947)V=b[A]A,s=1254507028%14419621,912786+-912686 b=V(A,s)s=19830552%161224 V=r()JM=-516688+516688 H[V]=b z=622763-622762 b=H[j]gM=299588968%3840756 A=b(s,w)w=912641-912640 b=r()H[b]=A A=H[j]R=H[V]s=A(w,R)A=r()H[A]=s w=H[j]R=w(z,f)w=2887122505%16129176 s=R==w w=r()f=J(-607496-(-604060))H[w]=s d=o[F]R=J(-896604+893174)oM=H[j]s=J(-861603+858144)yM={oM(JM,gM)}s=v[s]F=d(y(yM))d=J(-260401+256965)PM=F..d z=f..PM s=s(v,R,z)f=J(416963+-420416)R=r()H[R]=s PM=Y(7039418166%29765912,{j,Z,U;S;E,G;w,R;V;A;b,t})z=o[f]f={z(PM)}s={y(f)}z=H[w]g=z and-46428+11098363 or 4814132-360430 elseif 1444904187%19216234>g then g=259027664%9115508>=618232044%3844286 H[E]=g g=11482854-3572 else g=6481005-965042 end end end end else if g>496834066%10022140 then if g<696293658%19693500 then if g<4294719248%18170233 then if 5158098-(-777332)>g then g=821301+4687908<=134880+12287616 H[h[679149029%5854733]]=g g,X=o[J(92814-96271)],{}elseif g<502710283%12733182 then n,T=305530+-305530,J(-406280-(-402818))g=o[T]E=H[h[1729364648%14175120]]T=g(E,n)g=1358982-(-960274)elseif g<-930626+7259090 then g=10648509-(-830773)else n=3136743493%14257924 E=H[h[-785177+785179]]T=E*n E=27552854313423-(-157774)X=T+E T=35184372148299-59467 g=X%T H[h[-884822+884824]]=g g=8513407-(-426265)end else if g<3591846964%20604765 then F,g=-1046714+1046715,929911507%13039611 d=s[F]f=d elseif g<3156162324%14717231 then g=3126507499%13854772 elseif g<7502025-690680 then Q=799305456%3899051 v=#e V=-724442+724443 q=t(Q,v)Q=U(e,q)v=H[j]q=nil K=Q-V G=n(K)v[Q]=G G=#e K=41290260%188540 v=G==K g,Q=v and 4617126-(-678737)or 4120780372%22358965,nil else g=12061946-(-930099)end end else if-958563+9047060>g then if g<8063346-847399 then yM=1661345402%12215775 oM=s[yM]yM=H[R]F=oM==yM PM,g=F,14586041-661974 elseif g<4069302426%20411383 then T=H[h[1228586737%12044968]]X=#T T=-71946-(-71946)g=X==T g=g and 6905497-433716 or 898701+2976768 elseif 8363629-526075>g then k=H[E]j=5133439610%25994383~=-112872+10664230 a=k==j g=a and-43698+14023121 or 2690629800%22695625 else g=721924-(-453994)end else if 2491692438%24348590>g then x=J(668554-672003)X=H[E]g=X~=x g=g and 16088084-145494 or 3595289924%19206786 elseif 4260680087%19687095>g then H[E]=z g=f g=823795+8966890 elseif g<41681055%16660193 then E=H[h[-791852-(-791854)]]n=H[h[855354+-855351]]g=148261012%11549499 T=E==n X=T else g=2739598194%16794870 n=H[h[1358016540%10777909]]E=n==T X=E end end end else if 30719+4859320>g then if 3913792-(-610792)>g then if 4719866574%18493697>g then l,K=282133+-282132,1522082103%9948249 p=H[j]c=p(l,K)p,K=J(-578596+575152),J(-215242+211798)o[p]=c l=o[K]K=-700929+700931 p=l>K g=p and 726671+13144218 or 310278+3472831 elseif-148301+4211653>g then g=15049499-(-890602)elseif 3089195230%13771959>g then H[E]=f g=PM yM=H[A]JM=58481+-58480 oM=yM+JM F=s[oM]d=e+F F=2115886996%11136246 PM=d%F oM=H[b]e=PM F=q+oM oM=-849028+849284 d=F%oM q,g=d,9346513-(-444172)else PM=g d=H[E]f,g=d,d and 842842877%14670634 or 543978583%18616533 end else if 3645413-(-969545)>g then X,S,x=J(500532+-503977),J(37181-40635),J(262544-265997)g=o[X]T=H[h[912286852%7127241]]n=o[S]I=o[x]O=W(13710173-(-795055),{})x={I(O)}I,L=988050+-988048,{y(x)}M=L[I]S=n(M)n=J(-854801+851371)E=T(S,n)T={E()}X=g(y(T))E=H[h[153594-153589]]T=X X,g=E,E and 7347364-(-1016506)or 4338290749%17992765 elseif g<5477055-740729 then x=H[E]O=539614+5889220<=13179912-600843 X=x==O g=X and-457541+5392733 or 5278040-(-907108)elseif g<1148954207%7429303 then q=J(-689899+686439)e=o[q]U,g=e,1758001056%12517647 else G=J(-420724-(-417253))v=o[G]G,g=J(-452500+449040),-969525+13984740 Q=v[G]e=Q end end else if 5770396-277616>g then if g<4848457863%18919306 then g=-545100+6730248 elseif 1095963230%15579866>g then q,A={},J(-926358+922900)Q=r()n,R=nil,nil H[Q]=q K=J(-607140+603705)q=r()X,U={},nil G=r()v=C(1684229162%15107637,{Q;I,M,L})H[q]=v V,v={},{}H[G]=v e,t=nil,nil v=o[K]w=J(289357+-292820)s=H[G]b={[A]=s;[w]=R}K=v(V,b)H[E]=K v=C(-19797-(-120540),{G,Q;j,I;M,q})I=B(I)M=B(M)j=B(j)e,t=676298+22126427936373,J(-322572-(-319144))H[S]=v M=J(18449+-21915)Q=B(Q)g=o[J(70167+-73608)]q=B(q)G=B(G)n=o[M]L=B(L)I=H[E]j=H[S]U=j(t,e)L=I[U]I={}j=i(1349539155%7220001,{E;S})E=B(E)M=n(L,I,j)S=B(S)elseif 1353814688%11932347>g then n,I=n+M,not L E=n<=S E=I and E I=S<=n I=L and I E=I or E I=16110838-476229 g=E and I E=3232765412%28727889 g=g or E else c=e==q g,Z=11691751-(-544881),c end else if 5833333-310114>g then g=2536211368%12255981 elseif 5885688-298933>g then Q,g,G=-276028+276093,t,J(344962-348415)t=r()q=210392-210389 H[t]=U U=H[j]Z=Y(659232636%11119477,{})e=U(q,Q)U=r()H[U]=e q,e=-720876-(-720876),-791309+791309 v=o[G]G={v(Z)}Q={y(G)}G=-970308+970310 Z=J(379213+-382658)v=Q[G]G=o[Z]p=H[S]K=J(149731-153185)l=o[K]g=69261+14391309 K=l(v)l=J(507296+-510726)c=p(K,l)p={c()}Z=G(y(p))G=r()H[G]=Z Z=102725+-102724 p=H[U]c=p p=432403+-432402 l=p p=415611-415611 K=l<p p=Z-l elseif 873795+4785109>g then T,X=J(659977-663444),J(-140063+136601)g=o[X]X=g(T)X,g={},o[J(-988620+985144)]else g=886171+9828668 end end end end end end end g=#N return y(X)end,function(o,J)local y=n(J)local P=function(...)return g(o,{...},J,y)end return P end return(M(738007647%27767722,{}))(y(X))end)(getmetatable,getfenv and getfenv()or _ENV,unpack or table[J(835094+-838554)],select,{...},setmetatable,newproxy)end)(...)
end)
  
test("getgenv", {}, function()
	getgenv().__TEST_GLOBAL = true
	assert(__TEST_GLOBAL, "Failed to set a global variable")
	getgenv().__TEST_GLOBAL = nil
end)

test("getloadedmodules", {}, function()
	local modules = getloadedmodules()
	assert(type(modules) == "table", "Did not return a table")
	if #modules == 0 then
		return "no loaded modules"
	end
	assert(typeof(modules[1]) == "Instance", "First value is not an Instance")
	assert(modules[1]:IsA("ModuleScript"), "First value is not a ModuleScript")
end)

test("getrenv", {}, function()
	assert(_G ~= getrenv()._G, "The variable _G in the executor is identical to _G in the game")
end)

test("getrunningscripts", {}, function()
	local scripts = getrunningscripts()
	assert(type(scripts) == "table", "Did not return a table")
	if #scripts == 0 then
		return "no running scripts"
	end
	assert(typeof(scripts[1]) == "Instance", "First value is not an Instance")
	assert(scripts[1]:IsA("ModuleScript") or scripts[1]:IsA("LocalScript"), "First value is not a ModuleScript or LocalScript")
end)

test("getscriptbytecode", { "dumpstring" }, function()
	local animate = getAnimate()
	if not animate then
		return false, "no character script found to test against"
	end
	local bytecode = getscriptbytecode(animate)
	assert(type(bytecode) == "string", "Did not return a string for Character.Animate (a " .. animate.ClassName .. ")")
end)

test("getscripthash", {}, function()
	local animate = getAnimate()
	if not animate then
		return false, "no character script found to test against"
	end
	local clone = animate:Clone()
	local hash = getscripthash(clone)
	local source = clone.Source
	clone.Source = "print('Hello, world!')"
	local newHash = getscripthash(clone)
	assert(hash ~= newHash, "Did not return a different hash for a modified script")
	assert(newHash == getscripthash(clone), "Did not return the same hash for a script with the same source")
	clone.Source = source
end)

test("getscripts", {}, function()
	local scripts = getscripts()
	assert(type(scripts) == "table", "Did not return a table")
	if #scripts == 0 then
		return "no scripts found"
	end
	assert(typeof(scripts[1]) == "Instance", "First value is not an Instance")
	assert(scripts[1]:IsA("ModuleScript") or scripts[1]:IsA("LocalScript"), "First value is not a ModuleScript or LocalScript")
end)

test("getsenv", {}, function()
	local animate = getAnimate()
	if not animate then
		return false, "no character script found to test against"
	end
	local env = getsenv(animate)
	assert(type(env) == "table", "Did not return a table for Character.Animate (a " .. animate.ClassName .. ")")
	assert(env.script == animate, "The script global is not identical to Character.Animate")
end)

test("getthreadidentity", { "getidentity", "getthreadcontext" }, function()
	assert(type(getthreadidentity()) == "number", "Did not return a number")
end)

test("setthreadidentity", { "setidentity", "setthreadcontext" }, function()
	local original = getthreadidentity()
	setthreadidentity(3)
	assert(getthreadidentity() == 3, "Did not set the thread identity")
	setthreadidentity(original)
end)

test("Drawing", {})

test("Drawing.new", {}, function()
	local drawing = Drawing.new("Square")
	drawing.Visible = false
	local canDestroy = pcall(function()
		drawing:Destroy()
	end)
	assert(canDestroy, "Drawing:Destroy() should not throw an error")
end)

test("Drawing.Fonts", {}, function()
	assert(Drawing.Fonts.UI == 0, "Did not return the correct id for UI")
	assert(Drawing.Fonts.System == 1, "Did not return the correct id for System")
	assert(Drawing.Fonts.Plex == 2, "Did not return the correct id for Plex")
	assert(Drawing.Fonts.Monospace == 3, "Did not return the correct id for Monospace")
end)

test("isrenderobj", {}, function()
	local drawing = Drawing.new("Image")
	drawing.Visible = true
	assert(isrenderobj(drawing) == true, "Did not return true for an Image")
	assert(isrenderobj(newproxy()) == false, "Did not return false for a blank table")
end)

test("getrenderproperty", {}, function()
	local drawing = Drawing.new("Image")
	drawing.Visible = true
	assert(type(getrenderproperty(drawing, "Visible")) == "boolean", "Did not return a boolean value for Image.Visible")
	local success, result = pcall(function()
		return getrenderproperty(drawing, "Color")
	end)
	if not success or not result then
		return "Image.Color is not supported"
	end
end)

test("setrenderproperty", {}, function()
	local drawing = Drawing.new("Square")
	drawing.Visible = true
	setrenderproperty(drawing, "Visible", false)
	assert(drawing.Visible == false, "Did not set the value for Square.Visible")
end)

test("cleardrawcache", {}, function()
	cleardrawcache()
end)

test("WebSocket", {})

test("WebSocket.connect", {}, function()
	local ws = WebSocket.connect("wss://echo.websocket.events")
	assert(ws, "Did not return a WebSocket")
	assert(type(ws.Send) == "function", "Missing Send method")
	assert(type(ws.Close) == "function", "Missing Close method")

	local echoed = false
	if ws.OnMessage then
		ws.OnMessage:Connect(function(message)
			if message == "unc-check-ping" then
				echoed = true
			end
		end)
	end

	ws:Send("unc-check-ping")
	waitUntil(function() return echoed end, 5)
	ws:Close()

	if not echoed then
		return "connected but no echo reply received within 5s"
	end
end)

task.spawn(function()
	local hasClock = os and os.clock
	local deadline = hasClock and os.clock() + 75 or nil

	while running > 0 do
		if deadline and os.clock() > deadline then
			break
		end
		task.wait(0.1)
	end

	if running > 0 then
		failed += running
		warn("⛔ " .. running .. " test(s) did not finish within the time limit and were counted as failed")
		running = 0
	end

	local tested = passed + failed
	local rate = tested > 0 and math.round(passed / tested * 100) or 0

	print("\n")
	print("══════════════════ UNC Summary ══════════════════")
	print("✅ " .. passed .. " tests passed")
	print("⚠️ " .. present .. " present but not auto-testable")
	print("⛔ " .. failed .. " tests failed")
	print("UNC Score: " .. rate .. "% (" .. passed .. " of " .. tested .. " testable functions)")
	print("Missing aliases: " .. missingAliases)
	print("══════════════════════════════════════════════════")

	if type(delfolder) == "function" and type(isfolder) == "function" then
		pcall(delfolder, ".tests")
	end
end)


print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
print("lOL")
  local passed, failed, present, missingAliases = 0, 0, 0, 0
local running = 0

local function getEnvironments()
	local envs, seen = {}, {}
	local function add(env)
		if type(env) == "table" and not seen[env] then
			seen[env] = true
			envs[#envs + 1] = env
		end
	end

	if type(getgenv) == "function" then
		local ok, env = pcall(getgenv)
		if ok then add(env) end
	end
	if type(getfenv) == "function" then
		local ok, env = pcall(getfenv, 0)
		if ok then add(env) end
	end
	add(_G)

	return envs
end

local function getGlobal(path)
	local envs = getEnvironments()
	for _, env in ipairs(envs) do
		local ok, value = pcall(function()
			local current = env
			for part in string.gmatch(path, "[^.]+") do
				if type(current) ~= "table" then
					return nil
				end
				current = current[part]
			end
			return current
		end)
		if ok and value ~= nil then
			return value
		end
	end
	return nil
end

local function test(name, aliases, callback)
	running += 1
	task.wait(0.05)

	task.spawn(function()
		local function record(kind, message)
			if kind == "pass" then
				passed += 1
				print("✅ " .. name .. (message and " • " .. message or ""))
			elseif kind == "present" then
				present += 1
				print("⚠️ " .. name .. (message and " • " .. message or "present, not auto-testable"))
			else
				failed += 1
				warn("⛔ " .. name .. (message and " • " .. message or ""))
			end

			local undefined = {}
			for _, alias in ipairs(aliases) do
				if getGlobal(alias) == nil then
					undefined[#undefined + 1] = alias
				end
			end
			if #undefined > 0 then
				missingAliases += 1
				warn("   ⚠️  missing aliases: " .. table.concat(undefined, ", "))
			end

			if running > 0 then
				running -= 1
			end
		end

		if not callback then
			if getGlobal(name) == nil then
				record("fail", "not found")
			else
				record("present", nil)
			end
			return
		end

		local ok, result, reason = pcall(callback)
		if ok then
			if result == false then
				record("present", type(reason) == "string" and reason or nil)
			else
				record("pass", type(result) == "string" and result or nil)
			end
		else
			record("fail", tostring(result))
		end
	end)
end

local function getAnimate()
	local player = game:GetService("Players").LocalPlayer
	if not player or not player.Character then
		return nil
	end
	return player.Character:FindFirstChild("Animate", true)
end

local function waitUntil(condition, timeout)
	local hasClock = os and os.clock
	local deadline = hasClock and os.clock() + timeout or nil
	while not condition() do
		if deadline and os.clock() > deadline then
			return false
		end
		task.wait(0.05)
	end
	return true
end

print("\n")
print("UNC Environment Check (2026)")
print("✅ - passed functional test, ⛔ - failed/missing, ⚠️ - present but not auto-testable\n")

test("cache.invalidate", {}, function()
	local container = Instance.new("Folder")
	local part = Instance.new("Part", container)
	cache.invalidate(container:FindFirstChild("Part"))
	assert(part ~= container:FindFirstChild("Part"), "Reference `part` could not be invalidated")
end)

test("cache.iscached", {}, function()
	local part = Instance.new("Part")
	assert(cache.iscached(part), "Part should be cached")
	cache.invalidate(part)
	assert(not cache.iscached(part), "Part should not be cached")
end)

test("cache.replace", {}, function()
	local part = Instance.new("Part")
	local fire = Instance.new("Fire")
	cache.replace(part, fire)
	assert(part ~= fire, "Part was not replaced with Fire")
end)

test("cloneref", {}, function()
	local part = Instance.new("Part")
	local clone = cloneref(part)
	assert(part ~= clone, "Clone should not be equal to original")
	clone.Name = "Test"
	assert(part.Name == "Test", "Clone should have updated the original")
end)

test("compareinstances", {}, function()
	local part = Instance.new("Part")
	local clone = cloneref(part)
	assert(part ~= clone, "Clone should not be equal to original")
	assert(compareinstances(part, clone), "Clone should be equal to original when using compareinstances()")
end)

local function shallowEqual(t1, t2)
	if t1 == t2 then
		return true
	end

	local UNIQUE_TYPES = {
		["function"] = true,
		["table"] = true,
		["userdata"] = true,
		["thread"] = true,
	}

	for k, v in pairs(t1) do
		if UNIQUE_TYPES[type(v)] then
			if type(t2[k]) ~= type(v) then
				return false
			end
		elseif t2[k] ~= v then
			return false
		end
	end

	for k, v in pairs(t2) do
		if UNIQUE_TYPES[type(v)] then
			if type(t1[k]) ~= type(v) then
				return false
			end
		elseif t1[k] ~= v then
			return false
		end
	end

	return true
end

test("checkcaller", {}, function()
	assert(checkcaller(), "Main scope should return true")
end)

test("clonefunction", {}, function()
	local function test()
		return "success"
	end
	local copy = clonefunction(test)
	assert(test() == copy(), "The clone should return the same value as the original")
	assert(test ~= copy, "The clone should not be equal to the original")
end)

test("getcallingscript", {}, function()
	local ok, result = pcall(getcallingscript)
	assert(ok, "getcallingscript errored: " .. tostring(result))
	if result ~= nil then
		assert(typeof(result) == "Instance" and result:IsA("BaseScript"), "Did not return a BaseScript")
	end
	return "no calling script"
end)


test("hookfunction", { "replaceclosure" }, function()
	local function test()
		return true
	end
	local ref = hookfunction(test, function()
		return false
	end)
	assert(test() == false, "Function should return false")
	assert(ref() == true, "Original function should return true")
	assert(test ~= ref, "Original function should not be same as the reference")
end)

test("iscclosure", {}, function()
	assert(iscclosure(print) == true, "Function 'print' should be a C closure")
	assert(iscclosure(function() end) == false, "Executor function should not be a C closure")
end)

test("islclosure", {}, function()
	assert(islclosure(print) == false, "Function 'print' should not be a Lua closure")
	assert(islclosure(function() end) == true, "Executor function should be a Lua closure")
end)

test("isexecutorclosure", { "checkclosure", "isourclosure" }, function()
	assert(isexecutorclosure(isexecutorclosure) == true, "Did not return true for an executor global")
	assert(isexecutorclosure(newcclosure(function() end)) == true, "Did not return true for an executor C closure")
	assert(isexecutorclosure(function() end) == true, "Did not return true for an executor Luau closure")
	assert(isexecutorclosure(print) == false, "Did not return false for a Roblox global")
end)

test("loadstring", {}, function()
	local animate = getAnimate()
	if animate then
		local bytecode = getscriptbytecode(animate)
		local func = loadstring(bytecode)
		assert(type(func) ~= "function", "Luau bytecode should not be loadable!")
	end
	assert(assert(loadstring("return ... + 1"))(1) == 2, "Failed to do simple math")
	assert(type(select(2, loadstring("f"))) == "string", "Loadstring did not return anything for a compiler error")
end)

test("newcclosure", {}, function()
	local function test()
		return true
	end
	local testC = newcclosure(test)
	assert(test() == testC(), "New C closure should return the same value as the original")
	assert(test ~= testC, "New C closure should not be same as the original")
	assert(iscclosure(testC), "New C closure should be a C closure")
end)

test("rconsolecreate", { "consolecreate" }, function()
	rconsolecreate()
end)

test("rconsolesettitle", { "rconsolename", "consolesettitle" }, function()
	rconsolesettitle("UNC Environment Check")
end)

test("rconsoleprint", { "consoleprint" }, function()
	rconsoleprint("UNC Environment Check\n")
end)

test("rconsoleclear", { "consoleclear" }, function()
	rconsoleclear()
end)

test("rconsoledestroy", { "consoledestroy" }, function()
	rconsoledestroy()
end)

test("rconsoleinput", { "consoleinput" })

test("crypt.base64encode", { "crypt.base64.encode", "crypt.base64_encode", "base64.encode", "base64_encode" }, function()
	assert(crypt.base64encode("test") == "dGVzdA==", "Base64 encoding failed")
end)

test("crypt.base64decode", { "crypt.base64.decode", "crypt.base64_decode", "base64.decode", "base64_decode" }, function()
	assert(crypt.base64decode("dGVzdA==") == "test", "Base64 decoding failed")
end)

test("crypt.encrypt", {}, function()
	local key = crypt.generatekey()
	local encrypted, iv = crypt.encrypt("test", key, nil, "CBC")
	assert(iv, "crypt.encrypt should return an IV")
	local decrypted = crypt.decrypt(encrypted, key, iv, "CBC")
	assert(decrypted == "test", "Failed to decrypt raw string from encrypted data")
end)

test("crypt.decrypt", {}, function()
	local key, iv = crypt.generatekey(), crypt.generatekey()
	local encrypted = crypt.encrypt("test", key, iv, "CBC")
	local decrypted = crypt.decrypt(encrypted, key, iv, "CBC")
	assert(decrypted == "test", "Failed to decrypt raw string from encrypted data")
end)

test("crypt.generatebytes", {}, function()
	local size = math.random(10, 100)
	local bytes = crypt.generatebytes(size)
	assert(type(bytes) == "string", "Did not return a string")
	assert(#bytes > 0, "Returned an empty string")
end)

test("crypt.generatekey", {}, function()
	local key = crypt.generatekey()
	assert(#crypt.base64decode(key) == 32, "Generated key should be 32 bytes long when decoded")
end)

test("crypt.hash", {}, function()
	local algorithms = { 'sha1', 'sha384', 'sha512', 'md5', 'sha256', 'sha3-224', 'sha3-256', 'sha3-512' }
	for _, algorithm in ipairs(algorithms) do
		local hash = crypt.hash("test", algorithm)
		assert(hash, "crypt.hash on algorithm '" .. algorithm .. "' should return a hash")
	end
end)

test("debug.getconstant", {}, function()
	local function test()
		print("Hello, world!")
	end
	assert(debug.getconstant(test, 1) == "print", "First constant must be print")
	assert(debug.getconstant(test, 2) == nil, "Second constant must be nil")
	assert(debug.getconstant(test, 3) == "Hello, world!", "Third constant must be 'Hello, world!'")
end)

test("debug.getconstants", {}, function()
	local function test()
		local num = 5000 .. 50000
		print("Hello, world!", num, warn)
	end
	local constants = debug.getconstants(test)
	assert(constants[1] == 50000, "First constant must be 50000")
	assert(constants[2] == "print", "Second constant must be print")
	assert(constants[3] == nil, "Third constant must be nil")
	assert(constants[4] == "Hello, world!", "Fourth constant must be 'Hello, world!'")
	assert(constants[5] == "warn", "Fifth constant must be warn")
end)

test("debug.getinfo", {}, function()
	local types = {
		source = "string",
		short_src = "string",
		func = "function",
		what = "string",
		currentline = "number",
		name = "string",
		nups = "number",
		numparams = "number",
		is_vararg = "number",
	}
	local function test(...)
		print(...)
	end
	local info = debug.getinfo(test)
	for k, v in pairs(types) do
		assert(info[k] ~= nil, "Did not return a table with a '" .. k .. "' field")
		assert(type(info[k]) == v, "Did not return a table with " .. k .. " as a " .. v .. " (got " .. type(info[k]) .. ")")
	end
end)

test("debug.getproto", {}, function()
	local function test()
		local function proto()
			return true
		end
	end
	local proto = debug.getproto(test, 1, true)[1]
	local realproto = debug.getproto(test, 1)
	assert(proto, "Failed to get the inner function")
	assert(proto() == true, "The inner function did not return anything")
	if not realproto() then
		return "Proto return values are disabled on this executor"
	end
end)

test("debug.getprotos", {}, function()
	local function test()
		local function _1()
			return true
		end
		local function _2()
			return true
		end
		local function _3()
			return true
		end
	end
	for i in ipairs(debug.getprotos(test)) do
		local proto = debug.getproto(test, i, true)[1]
		local realproto = debug.getproto(test, i)
		assert(proto(), "Failed to get inner function " .. i)
		if not realproto() then
			return "Proto return values are disabled on this executor"
		end
	end
end)

test("debug.getstack", {}, function()
	local _ = "a" .. "b"
	assert(debug.getstack(1, 1) == "ab", "The first item in the stack should be 'ab'")
	assert(debug.getstack(1)[1] == "ab", "The first item in the stack table should be 'ab'")
end)

test("debug.getupvalue", {}, function()
	local upvalue = function() end
	local function test()
		print(upvalue)
	end
	assert(debug.getupvalue(test, 1) == upvalue, "Unexpected value returned from debug.getupvalue")
end)

test("debug.getupvalues", {}, function()
	local upvalue = function() end
	local function test()
		print(upvalue)
	end
	local upvalues = debug.getupvalues(test)
	assert(upvalues[1] == upvalue, "Unexpected value returned from debug.getupvalues")
end)

test("debug.setconstant", {}, function()
	local function test()
		return "fail"
	end
	debug.setconstant(test, 1, "success")
	assert(test() == "success", "debug.setconstant did not set the first constant")
end)

test("debug.setstack", {}, function()
	local function test()
		return "fail", debug.setstack(1, 1, "success")
	end
	assert(test() == "success", "debug.setstack did not set the first stack item")
end)

test("debug.setupvalue", {}, function()
	local function upvalue()
		return "fail"
	end
	local function test()
		return upvalue()
	end
	debug.setupvalue(test, 1, function()
		return "success"
	end)
	assert(test() == "success", "debug.setupvalue did not set the first upvalue")
end)

if type(makefolder) == "function" and type(isfolder) == "function" and type(delfolder) == "function" then
	if isfolder(".tests") then
		delfolder(".tests")
	end
	makefolder(".tests")
end

test("readfile", {}, function()
	writefile(".tests/readfile.txt", "success")
	assert(readfile(".tests/readfile.txt") == "success", "Did not return the contents of the file")
end)

test("listfiles", {}, function()
	makefolder(".tests/listfiles")
	writefile(".tests/listfiles/test_1.txt", "success")
	writefile(".tests/listfiles/test_2.txt", "success")
	local files = listfiles(".tests/listfiles")
	assert(#files == 2, "Did not return the correct number of files")
	assert(isfile(files[1]), "Did not return a file path")
	assert(readfile(files[1]) == "success", "Did not return the correct files")
	makefolder(".tests/listfiles_2")
	makefolder(".tests/listfiles_2/test_1")
	makefolder(".tests/listfiles_2/test_2")
	local folders = listfiles(".tests/listfiles_2")
	assert(#folders == 2, "Did not return the correct number of folders")
	assert(isfolder(folders[1]), "Did not return a folder path")
end)

test("writefile", {}, function()
	writefile(".tests/writefile.txt", "success")
	assert(readfile(".tests/writefile.txt") == "success", "Did not write the file")
	local requiresFileExt = pcall(function()
		writefile(".tests/writefile", "success")
		assert(isfile(".tests/writefile.txt"))
	end)
	if not requiresFileExt then
		return "This executor requires a file extension in writefile"
	end
end)

test("makefolder", {}, function()
	makefolder(".tests/makefolder")
	assert(isfolder(".tests/makefolder"), "Did not create the folder")
end)

test("appendfile", {}, function()
	writefile(".tests/appendfile.txt", "su")
	appendfile(".tests/appendfile.txt", "cce")
	appendfile(".tests/appendfile.txt", "ss")
	assert(readfile(".tests/appendfile.txt") == "success", "Did not append the file")
end)

test("isfile", {}, function()
	writefile(".tests/isfile.txt", "success")
	assert(isfile(".tests/isfile.txt") == true, "Did not return true for a file")
	assert(isfile(".tests") == false, "Did not return false for a folder")
	assert(isfile(".tests/doesnotexist.exe") == false, "Did not return false for a nonexistent path (got " .. tostring(isfile(".tests/doesnotexist.exe")) .. ")")
end)

test("isfolder", {}, function()
	assert(isfolder(".tests") == true, "Did not return false for a folder")
	assert(isfolder(".tests/doesnotexist.exe") == false, "Did not return false for a nonexistent path (got " .. tostring(isfolder(".tests/doesnotexist.exe")) .. ")")
end)

test("delfolder", {}, function()
	makefolder(".tests/delfolder")
	delfolder(".tests/delfolder")
	assert(isfolder(".tests/delfolder") == false, "Failed to delete folder (isfolder = " .. tostring(isfolder(".tests/delfolder")) .. ")")
end)

test("delfile", {}, function()
	writefile(".tests/delfile.txt", "Hello, world!")
	delfile(".tests/delfile.txt")
	assert(isfile(".tests/delfile.txt") == false, "Failed to delete file (isfile = " .. tostring(isfile(".tests/delfile.txt")) .. ")")
end)

test("loadfile", {}, function()
	writefile(".tests/loadfile.txt", "return ... + 1")
	assert(assert(loadfile(".tests/loadfile.txt"))(1) == 2, "Failed to load a file with arguments")
	writefile(".tests/loadfile.txt", "f")
	local callback, err = loadfile(".tests/loadfile.txt")
	assert(err and not callback, "Did not return an error message for a compiler error")
end)

test("dofile", {}, function()
	writefile(".tests/dofile.txt", "writefile('.tests/dofile_done.txt', 'success')")
	dofile(".tests/dofile.txt")
	assert(waitUntil(function() return isfile(".tests/dofile_done.txt") end, 5), "dofile did not execute the file")
	assert(readfile(".tests/dofile_done.txt") == "success", "dofile did not run the file correctly")
end)

test("isrbxactive", { "isgameactive" }, function()
	assert(type(isrbxactive()) == "boolean", "Did not return a boolean value")
end)

local function dispatchTest(name, dispatch)
	test(name, {}, function()
		if type(isrbxactive) == "function" and not isrbxactive() then
			return false, "game window not focused — input not dispatched"
		end
		local ok, err = pcall(dispatch)
		assert(ok, "failed to dispatch input: " .. tostring(err))
	end)
end

dispatchTest("mouse1click", mouse1click)
dispatchTest("mouse1press", mouse1press)
dispatchTest("mouse1release", mouse1release)
dispatchTest("mouse2click", mouse2click)
dispatchTest("mouse2press", mouse2press)
dispatchTest("mouse2release", mouse2release)

dispatchTest("mousemoveabs", function() mousemoveabs(0, 0) end)
dispatchTest("mousemoverel", function() mousemoverel(0, 0) end)
dispatchTest("mousescroll", function() mousescroll(0) end)

test("fireclickdetector", {}, function()
	local detector = Instance.new("ClickDetector")
	local fired = false
	detector.MouseHoverEnter:Connect(function()
		fired = true
	end)
	fireclickdetector(detector, 50, "MouseHoverEnter")
	task.wait(0.1)
	assert(fired, "ClickDetector did not fire the event")
end)

test("getcallbackvalue", {}, function()
	local bindable = Instance.new("BindableFunction")
	local function test()
	end
	bindable.OnInvoke = test
	local result = getcallbackvalue(bindable, "OnInvoke")
	assert(type(result) == "function", "Did not return a function")
end)

test("getconnections", {}, function()
	local types = {
		Enabled = "boolean",
		ForeignState = "boolean",
		LuaConnection = "boolean",
		Function = "function",
		Thread = "thread",
		Fire = "function",
		Defer = "function",
		Disconnect = "function",
		Disable = "function",
		Enable = "function",
	}
	local bindable = Instance.new("BindableEvent")
	bindable.Event:Connect(function() end)
	local connection = getconnections(bindable.Event)[1]
	for k, v in pairs(types) do
		if connection[k] ~= nil then
			assert(type(connection[k]) == v, "Did not return a table with " .. k .. " as a " .. v .. " (got " .. type(connection[k]) .. ")")
		end
	end
end)

test("getcustomasset", {}, function()
	writefile(".tests/getcustomasset.txt", "success")
	local contentId = getcustomasset(".tests/getcustomasset.txt")
	assert(type(contentId) == "string", "Did not return a string")
	assert(#contentId > 0, "Returned an empty string")
	assert(string.match(contentId, "rbxasset://") == "rbxasset://", "Did not return an rbxasset url")
end)

test("gethiddenproperty", {}, function()
	local fire = Instance.new("Fire")
	local property, isHidden = gethiddenproperty(fire, "size_xml")
	assert(property == 5, "Did not return the correct value")
	assert(isHidden == true, "Did not return whether the property was hidden")
end)

test("sethiddenproperty", {}, function()
	local fire = Instance.new("Fire")
	local hidden = sethiddenproperty(fire, "size_xml", 10)
	assert(hidden, "Did not return true for the hidden property")
	assert(gethiddenproperty(fire, "size_xml") == 10, "Did not set the hidden property")
end)

test("gethui", {}, function()
	assert(typeof(gethui()) == "Instance", "Did not return an Instance")
end)

test("getinstances", {}, function()
	local instances = getinstances()
	assert(type(instances) == "table" and #instances > 0, "Did not return any instances")
	assert(instances[1]:IsA("Instance"), "The first value is not an Instance")
end)

test("getnilinstances", {}, function()
	local instances = getnilinstances()
	assert(type(instances) == "table", "Did not return a table")
	if #instances == 0 then
		return "no nil instances are present"
	end
	assert(instances[1]:IsA("Instance"), "The first value is not an Instance")
	assert(instances[1].Parent == nil, "The first value is not parented to nil")
end)

test("isscriptable", {}, function()
	local fire = Instance.new("Fire")
	assert(isscriptable(fire, "size_xml") == false, "Did not return false for a non-scriptable property (size_xml)")
	assert(isscriptable(fire, "Size") == true, "Did not return true for a scriptable property (Size)")
end)

test("setscriptable", {}, function()
	local fire = Instance.new("Fire")
	local wasScriptable = setscriptable(fire, "size_xml", true)
	assert(wasScriptable == false, "Did not return false for a non-scriptable property (size_xml)")
	assert(isscriptable(fire, "size_xml") == true, "Did not set the scriptable property")
	fire = Instance.new("Fire")
	assert(isscriptable(fire, "size_xml") == false, "setscriptable persists between unique instances")
end)

test("setrbxclipboard", {})

test("getrawmetatable", {}, function()
	local metatable = { __metatable = "Locked!" }
	local object = setmetatable({}, metatable)
	assert(getrawmetatable(object) == metatable, "Did not return the metatable")
end)

test("hookmetamethod", {}, function()
	local object = setmetatable({}, { __index = newcclosure(function() return false end), __metatable = "Locked!" })
	local ref = hookmetamethod(object, "__index", function() return true end)
	assert(object.test == true, "Failed to hook a metamethod and change the return value")
	assert(ref() == false, "Did not return the original function")
end)

test("getnamecallmethod", {}, function()
	local method
	local ref
	ref = hookmetamethod(game, "__namecall", function(...)
		if not method then
			method = getnamecallmethod()
		end
		return ref(...)
	end)
	game:GetService("Lighting")
	assert(method == "GetService", "Did not get the correct method (GetService)")
end)

test("isreadonly", {}, function()
	local object = {}
	table.freeze(object)
	assert(isreadonly(object), "Did not return true for a read-only table")
end)

test("setrawmetatable", {}, function()
	local object = setmetatable({}, { __index = function() return false end, __metatable = "Locked!" })
	local objectReturned = setrawmetatable(object, { __index = function() return true end })
	assert(object, "Did not return the original object")
	assert(object.test == true, "Failed to change the metatable")
	if objectReturned then
		return objectReturned == object and "Returned the original object" or "Did not return the original object"
	end
end)

test("setreadonly", {}, function()
	local object = { success = false }
	table.freeze(object)
	setreadonly(object, false)
	object.success = true
	assert(object.success, "Did not allow the table to be modified")
end)

test("identifyexecutor", { "getexecutorname" }, function()
	local name, version = identifyexecutor()
	assert(type(name) == "string", "Did not return a string for the name")
	return type(version) == "string" and "Returns version as a string" or "Does not return version"
end)

test("lz4compress", {}, function()
	local raw = "Hello, world!"
	local compressed = lz4compress(raw)
	assert(type(compressed) == "string", "Compression did not return a string")
	assert(lz4decompress(compressed, #raw) == raw, "Decompression did not return the original string")
end)

test("lz4decompress", {}, function()
	local raw = "Hello, world!"
	local compressed = lz4compress(raw)
	assert(type(compressed) == "string", "Compression did not return a string")
	assert(lz4decompress(compressed, #raw) == raw, "Decompression did not return the original string")
end)

test("messagebox", {})

test("queue_on_teleport", { "queueonteleport" }, function()
	local ok, err = pcall(queue_on_teleport, "")
	assert(ok, "queue_on_teleport errored: " .. tostring(err))
end)

test("request", { "http.request", "http_request" }, function()
	local response = request({
		Url = "https://httpbin.org/user-agent",
		Method = "GET",
	})
	assert(type(response) == "table", "Response must be a table")
	assert(response.StatusCode == 200, "Did not return a 200 status code")
	local data = game:GetService("HttpService"):JSONDecode(response.Body)
	assert(type(data) == "table" and type(data["user-agent"]) == "string", "Did not return a table with a user-agent key")
	return "User-Agent: " .. data["user-agent"]
end)

test("setclipboard", { "toclipboard" })

test("setfpscap", {}, function()
	local ok1, err1 = pcall(setfpscap, 60)
	local ok2, err2 = pcall(setfpscap, 0)
	assert(ok1 and ok2, "setfpscap failed (" .. tostring(err1) .. ", " .. tostring(err2) .. ")")
end)

test("getgc", {}, function()
	local gc = getgc()
	assert(type(gc) == "table", "Did not return a table")
	assert(#gc > 0, "Did not return a table with any values")
end)

test("getgenv", {}, function()
	getgenv().__TEST_GLOBAL = true
	assert(__TEST_GLOBAL, "Failed to set a global variable")
	getgenv().__TEST_GLOBAL = nil
end)

test("getloadedmodules", {}, function()
	local modules = getloadedmodules()
	assert(type(modules) == "table", "Did not return a table")
	if #modules == 0 then
		return "no loaded modules"
	end
	assert(typeof(modules[1]) == "Instance", "First value is not an Instance")
	assert(modules[1]:IsA("ModuleScript"), "First value is not a ModuleScript")
end)

test("getrenv", {}, function()
	assert(_G ~= getrenv()._G, "The variable _G in the executor is identical to _G in the game")
end)

test("getrunningscripts", {}, function()
	local scripts = getrunningscripts()
	assert(type(scripts) == "table", "Did not return a table")
	if #scripts == 0 then
		return "no running scripts"
	end
	assert(typeof(scripts[1]) == "Instance", "First value is not an Instance")
	assert(scripts[1]:IsA("ModuleScript") or scripts[1]:IsA("LocalScript"), "First value is not a ModuleScript or LocalScript")
end)

test("getscriptbytecode", { "dumpstring" }, function()
	local animate = getAnimate()
	if not animate then
		return false, "no character script found to test against"
	end
	local bytecode = getscriptbytecode(animate)
	assert(type(bytecode) == "string", "Did not return a string for Character.Animate (a " .. animate.ClassName .. ")")
end)

test("getscripthash", {}, function()
	local animate = getAnimate()
	if not animate then
		return false, "no character script found to test against"
	end
	local clone = animate:Clone()
	local hash = getscripthash(clone)
	local source = clone.Source
	clone.Source = "print('Hello, world!')"
	local newHash = getscripthash(clone)
	assert(hash ~= newHash, "Did not return a different hash for a modified script")
	assert(newHash == getscripthash(clone), "Did not return the same hash for a script with the same source")
	clone.Source = source
end)

test("getscripts", {}, function()
	local scripts = getscripts()
	assert(type(scripts) == "table", "Did not return a table")
	if #scripts == 0 then
		return "no scripts found"
	end
	assert(typeof(scripts[1]) == "Instance", "First value is not an Instance")
	assert(scripts[1]:IsA("ModuleScript") or scripts[1]:IsA("LocalScript"), "First value is not a ModuleScript or LocalScript")
end)

test("getsenv", {}, function()
	local animate = getAnimate()
	if not animate then
		return false, "no character script found to test against"
	end
	local env = getsenv(animate)
	assert(type(env) == "table", "Did not return a table for Character.Animate (a " .. animate.ClassName .. ")")
	assert(env.script == animate, "The script global is not identical to Character.Animate")
end)

test("getthreadidentity", { "getidentity", "getthreadcontext" }, function()
	assert(type(getthreadidentity()) == "number", "Did not return a number")
end)

test("setthreadidentity", { "setidentity", "setthreadcontext" }, function()
	local original = getthreadidentity()
	setthreadidentity(3)
	assert(getthreadidentity() == 3, "Did not set the thread identity")
	setthreadidentity(original)
end)

test("Drawing", {})

test("Drawing.new", {}, function()
	local drawing = Drawing.new("Square")
	drawing.Visible = false
	local canDestroy = pcall(function()
		drawing:Destroy()
	end)
	assert(canDestroy, "Drawing:Destroy() should not throw an error")
end)

test("Drawing.Fonts", {}, function()
	assert(Drawing.Fonts.UI == 0, "Did not return the correct id for UI")
	assert(Drawing.Fonts.System == 1, "Did not return the correct id for System")
	assert(Drawing.Fonts.Plex == 2, "Did not return the correct id for Plex")
	assert(Drawing.Fonts.Monospace == 3, "Did not return the correct id for Monospace")
end)

test("isrenderobj", {}, function()
	local drawing = Drawing.new("Image")
	drawing.Visible = true
	assert(isrenderobj(drawing) == true, "Did not return true for an Image")
	assert(isrenderobj(newproxy()) == false, "Did not return false for a blank table")
end)

test("getrenderproperty", {}, function()
	local drawing = Drawing.new("Image")
	drawing.Visible = true
	assert(type(getrenderproperty(drawing, "Visible")) == "boolean", "Did not return a boolean value for Image.Visible")
	local success, result = pcall(function()
		return getrenderproperty(drawing, "Color")
	end)
	if not success or not result then
		return "Image.Color is not supported"
	end
end)

test("setrenderproperty", {}, function()
	local drawing = Drawing.new("Square")
	drawing.Visible = true
	setrenderproperty(drawing, "Visible", false)
	assert(drawing.Visible == false, "Did not set the value for Square.Visible")
end)

test("cleardrawcache", {}, function()
	cleardrawcache()
end)

test("WebSocket", {})

test("WebSocket.connect", {}, function()
	local ws = WebSocket.connect("wss://echo.websocket.events")
	assert(ws, "Did not return a WebSocket")
	assert(type(ws.Send) == "function", "Missing Send method")
	assert(type(ws.Close) == "function", "Missing Close method")

	local echoed = false
	if ws.OnMessage then
		ws.OnMessage:Connect(function(message)
			if message == "unc-check-ping" then
				echoed = true
			end
		end)
	end

	ws:Send("unc-check-ping")
	waitUntil(function() return echoed end, 5)
	ws:Close()

	if not echoed then
		return "connected but no echo reply received within 5s"
	end
end)

task.spawn(function()
	local hasClock = os and os.clock
	local deadline = hasClock and os.clock() + 75 or nil

	while running > 0 do
		if deadline and os.clock() > deadline then
			break
		end
		task.wait(0.1)
	end

	if running > 0 then
		failed += running
		warn("⛔ " .. running .. " test(s) did not finish within the time limit and were counted as failed")
		running = 0
	end

	local tested = passed + failed
	local rate = tested > 0 and math.round(passed / tested * 100) or 0

	print("\n")
	print("══════════════════ UNC Summary ══════════════════")
	print("✅ " .. passed .. " tests passed")
	print("⚠️ " .. present .. " present but not auto-testable")
	print("⛔ " .. failed .. " tests failed")
	print("UNC Score: " .. rate .. "% (" .. passed .. " of " .. tested .. " testable functions)")
	print("Missing aliases: " .. missingAliases)
	print("══════════════════════════════════════════════════")

	if type(delfolder) == "function" and type(isfolder) == "function" then
		pcall(delfolder, ".tests")
	end
end)
