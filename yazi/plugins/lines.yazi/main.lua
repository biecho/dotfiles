--- @since 26.5.6
--- Show a line count next to every file in the listing.
---
--- Counting lines means reading file contents, which is too slow to do on the
--- synchronous render thread. So, like the built-in `git` plugin, this counts
--- lines in an async *fetcher* (off the render thread), caches the result in
--- plugin state, and a `Linemode` child just displays the cached value. The
--- count therefore pops in shortly after a directory loads, rather than
--- blocking the UI.
---
--- Safety rails: directories are skipped, files larger than SIZE_CAP are
--- skipped (cheap to bound worst-case I/O), and files containing a NUL byte
--- are treated as binary and show nothing.

local SIZE_CAP = 1024 * 1024 -- 1 MiB; larger files are not counted
local READ_CHUNK = 64 * 1024

-- Persist counts in plugin state, keyed by the file's url string. Runs on the
-- main thread (ya.sync), so it can trigger a repaint once new counts land.
local set = ya.sync(function(st, counts)
	st.counts = st.counts or {}
	for path, n in pairs(counts) do
		st.counts[path] = n
	end
	ui.render()
end)

-- Count '\n' occurrences, plus one for a final line with no trailing newline.
-- Returns nil for unreadable or binary (NUL-containing) files.
local function count_lines(path)
	local f = io.open(path, "rb")
	if not f then
		return nil
	end

	local count, last = 0, "\n"
	while true do
		local chunk = f:read(READ_CHUNK)
		if not chunk then
			break
		end
		if chunk:find("\0", 1, true) then
			f:close()
			return nil -- binary file
		end
		local _, nl = chunk:gsub("\n", "")
		count = count + nl
		last = chunk:sub(-1)
	end
	f:close()

	if last ~= "\n" then
		count = count + 1 -- last line is not newline-terminated
	end
	return count
end

local function setup(st, opts)
	st.counts = st.counts or {}
	opts = opts or {}
	local order = opts.order or 2000 -- placed after the built-in size linemode

	Linemode:children_add(function(self)
		local n = st.counts[tostring(self._file.url)]
		if not n then
			return ""
		end
		return ui.Line { " ", ui.Span(string.format("%dL", n)):style(ui.Style():fg("cyan")) }
	end, order)
end

---@type UnstableFetcher
local function fetch(_, job)
	local counts = {}
	for _, file in ipairs(job.files) do
		local cha = file.cha
		if cha.is_dir or (cha.len or 0) > SIZE_CAP then
			-- skip directories and oversized files
		else
			local n = count_lines(tostring(file.url))
			if n then
				counts[tostring(file.url)] = n
			end
		end
	end

	if next(counts) then
		set(counts)
	end
	return false
end

return { setup = setup, fetch = fetch }
