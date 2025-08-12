-- lua/stats.lua ---------------------------------------------------------------
local M = {}

-- ── configuration ────────────────────────────────────────────────────────────
local ignored_filenames = { ["package-lock.json"] = true }   -- single‑file ignores
local ignored_extensions = {
	png = true, jpg = true, jpeg = true, gif = true, svg = true, webp = true, ico = true, icns = true, bmp = true,
	exe = true, dll = true, so = true, dylib = true, bin = true, dat = true, jar = true,
	class = true, pyc = true, pyo = true,
	sqlite = true, db = true,
	zip = true, tar = true, gz = true, ["7z"] = true, pdf = true,
	mp4 = true, mp3 = true, avi = true, mov = true,
	wav = true, flac = true, ogg = true, webm = true,
	ttf = true, pro = true, gradle = true, log = true, lock = true,
}

local ext2lang = {
	lua = "Lua",  py  = "Python",  js  = "JavaScript",  jsx = "JavaScript",
	ts  = "TypeScript", tsx = "TypeScript",
	c   = "C",    h   = "C‑Headers",   cpp = "C++",   hpp = "C++‑Headers",
	rs  = "Rust", go  = "Go",          java = "Java",
	cs  = "C#",   rb  = "Ruby",        php = "PHP",
	html= "HTML", css = "CSS",         json = "JSON",
}

-- returns true if *any* path segment starts with a dot ( .git , .vscode , .env … )
local function is_dot_path(path)
	for segment in path:gmatch("[^/]+") do
		if segment:sub(1, 1) == "." then return true end
	end
	return false
end

local function in_git_repo()
	return vim.fn.isdirectory(".git") == 1
end

-- Get file list while respecting .gitignore (if present)
local function list_files()
	if in_git_repo() and vim.fn.executable("git") == 1 then
		-- -c = cached (tracked)  -o = others (untracked)  --exclude-standard = .gitignore + .git/info/exclude + $GIT_IGNORE
		return vim.fn.systemlist("git ls-files -co --exclude-standard -z | tr '\\0' '\\n'")
	end

	-- fall back to fd (fast) or find (POSIX)
	if vim.fn.executable("fd") == 1 then
		return vim.fn.systemlist("fd --type f --hidden --exclude .git -0 | tr '\\0' '\\n'")
	end
	return vim.fn.systemlist("find . -type f -not -path '*/.*'")  -- crude, but portable
end

-- Count lines in a file; uses `wc -l` when available (fast), else pure Lua fallback.
local function count_lines(path)
	if vim.fn.executable("wc") == 1 then
		return tonumber(vim.fn.system(string.format("wc -l < '%s'", path))) or 0
	end
	local f = io.open(path, "r")
	if not f then return 0 end
	local n = 0
	for _ in f:lines() do n = n + 1 end
	f:close()
	return n
end

-- Core aggregator ------------------------------------------------------------
local function gather()
	local stats = { total_lines = 0, total_files = 0, langs = {} }

	for _, file in ipairs(list_files()) do
		if file ~= ""                               -- skip empty rows
			and not ignored_filenames[file]          -- explicit file ignore
			and not is_dot_path(file)                -- any dot‑file / dot‑dir
			then
				local ext = file:match("%.([%w_%-]+)$")
				if ext and not ignored_extensions[ext] then
					local lang = ext2lang[ext] or ext
					local lines = count_lines(file)
					stats.total_lines = stats.total_lines + lines
					stats.total_files = stats.total_files + 1

					local L = stats.langs[lang] or { lines = 0, files = 0 }
					L.lines, L.files = L.lines + lines, L.files + 1
					stats.langs[lang] = L
				end
			end
		end
		return stats
	end

	-- Pretty‑print ----------------------------------------------------------------
	function M.print_stats()
		local S = gather()
		if S.total_files == 0 then
			vim.notify("No source files found.", vim.log.levels.INFO, { title = "Project Stats" })
			return
		end

		local header = string.format(" 🚀 %d lines in %d files", S.total_lines, S.total_files)
		local rows, keys = { header, string.rep("─", #header) }, {}

		for lang in pairs(S.langs) do table.insert(keys, lang) end
		table.sort(keys, function(a, b) return S.langs[a].lines > S.langs[b].lines end)

		for _, lang in ipairs(keys) do
			local d = S.langs[lang]
			local pct = (d.lines / S.total_lines) * 100
			table.insert(
			rows,
			string.format("  %-14s %8d lines  (%5.1f%%)  in %3d files", lang, d.lines, pct, d.files)
			)
		end

		vim.notify(table.concat(rows, "\n"), vim.log.levels.INFO, { title = "Project Stats" })
	end

	-- :Stats command --------------------------------------------------------------
	vim.api.nvim_create_user_command("Stats", M.print_stats, {})
	return M
