--
--

local lfs = require("lfs")

local licomiter = "licomiter"
local version   = "0.1.0"

function usage()
	print("usage: "..licomiter.." <dir/path>")
end

local args = {...}
if (#args-1 < 0) then
	usage()
	os.exit(1)
end

print("starting operation on "..args[1])
local current_dir = args[1]
for entry in lfs.dir(current_dir) do
		-- Skip current and parent directory references
		if entry ~= "." and entry ~= ".." then
				local path = current_dir .. "/" .. entry
				local attr = lfs.attributes(path)

				if attr then
						local mode = attr.mode
						-- print("- " .. entry .. " (" .. mode .. ")")

						-- Check specifically for .git folder
						if entry == ".git" and mode == "directory" then
								-- print("  >>> .git folder found at: " .. path)
								git_found = true
						end
				end
		end
end

if not git_found then
		print("\nNo .git folder found in '"..current_dir.."' directory.")
end

local success, err = lfs.chdir(current_dir)

if success then
		print("Changed directory to: " .. lfs.currentdir())

		local code = os.execute("git add .")

		if code == 0 then
				print("Successfully staged all files.")
		else
				print("git add failed with exit code:", code)
		end

		code = os.execute("git commit -m \"no op...\"")

		if code == 0 then
				print("Successfully commited all files.")
		else
				print("git add failed with exit code:", code)
		end

  code = os.execute("git push origin master")

		if code == 0 then
				print("Successfully pushed all code.")
		else
				print("git add failed with exit code:", code)
		end

else
		print("Failed to change directory:", err)
end