-- lua/core/contributors.lua --------------------------------------------------
local M = {}

-- ── configuration (reused from stats.lua) ───────────────────────────────────
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

-- ── custom ignore patterns ──────────────────────────────────────────────────
-- Add your custom files/folders to ignore here:
local custom_ignored_files = {
	["config.php"] = true,
	["run_email.bat"] = true,           -- batch script for running emails
}

local custom_ignored_folders = {
	["PHPMailer-master"] = true,        -- third-party library
	["images"] = true,                  -- image assets
	[".idea"] = true,                   -- IDE configuration files
}

local custom_ignored_patterns = {
	"%.iml$",                          -- IntelliJ IDEA module files
    "%.vscode$",                       -- Visual Studio Code settings
	"%.bat$",                          -- batch files
	-- Example: "%.test%.js$",         -- ignore *.test.js files
	-- "%.spec%.lua$",                 -- ignore *.spec.lua files
	-- "^temp/",                       -- ignore files starting with temp/
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
	return {}  -- No git repo, no files to analyze
end

-- Filter files based on the same criteria as stats.lua + custom patterns
local function filter_file(file)
	if file == "" or ignored_filenames[file] or custom_ignored_files[file] or is_dot_path(file) then
		return false
	end
	
	-- Check custom folder patterns (exclude entire directory trees)
	for folder in pairs(custom_ignored_folders) do
		-- Escape special regex characters in folder name
		local escaped_folder = folder:gsub("[%-%^%$%(%)%%%.%[%]%*%+%?]", "%%%1")
		
		-- Check if file path contains this folder as a directory component
		if file:match("^" .. escaped_folder .. "/") or                    -- starts with folder/
		   file == escaped_folder or                                      -- exact folder name
		   file:match("/" .. escaped_folder .. "/") or                    -- contains /folder/
		   file:match("/" .. escaped_folder .. "$") then                  -- ends with /folder
			return false
		end
	end
	
	-- Check custom file patterns
	for _, pattern in ipairs(custom_ignored_patterns) do
		if file:match(pattern) then
			return false
		end
	end
	
	local ext = file:match("%.([%w_%-]+)$")
	if ext and ignored_extensions[ext] then
		return false
	end
	
	return true
end

-- Fallback method: analyze current file ownership (slower but more accurate for current state)
local function gather_current_ownership(files)
	local contributors = {}
	
	-- Process files individually for better error handling and debugging
	for i, file in ipairs(files) do
		-- Show progress for larger repos
		if #files > 50 and i % 20 == 0 then
			vim.notify(string.format("Processing %d/%d files", i, #files), 
				vim.log.levels.INFO, { title = "Contributors" })
		end
		
		-- Get blame for this specific file
		local blame_cmd = string.format("git blame --line-porcelain '%s' 2>/dev/null", file)
		local blame_output = vim.fn.systemlist(blame_cmd)
		
		if vim.v.shell_error == 0 and #blame_output > 0 then
			local current_author = nil
			
			for _, line in ipairs(blame_output) do
				-- Look for author lines in blame output
				if line:match("^author ") then
					current_author = line:match("^author (.+)")
				elseif line:match("^filename ") and current_author then
					-- This marks the end of metadata for one line
					if not contributors[current_author] then
						contributors[current_author] = { lines = 0, files = {} }
					end
					contributors[current_author].lines = contributors[current_author].lines + 1
					contributors[current_author].files[file] = true
				end
			end
		end
	end

	-- Convert file sets to counts and clean up
	for author, data in pairs(contributors) do
		local file_count = 0
		for _ in pairs(data.files) do
			file_count = file_count + 1
		end
		data.file_count = file_count
		data.files = nil -- Clean up to save memory
	end

	return contributors
end

-- Get contributors with their line counts and file counts (optimized)
local function gather_contributor_stats()
	if not in_git_repo() then
		vim.notify("Not in a git repository.", vim.log.levels.WARN, { title = "Contributors" })
		return nil
	end

	if vim.fn.executable("git") ~= 1 then
		vim.notify("Git not found.", vim.log.levels.ERROR, { title = "Contributors" })
		return nil
	end

	vim.notify("Analyzing contributors...", vim.log.levels.INFO, { title = "Contributors" })

	local files = list_files()
	local filtered_files = {}
	
	-- Pre-filter files
	for _, file in ipairs(files) do
		if filter_file(file) then
			table.insert(filtered_files, file)
		end
	end

	if #filtered_files == 0 then
		vim.notify("No source files found.", vim.log.levels.INFO, { title = "Contributors" })
		return nil
	end

	-- Debug: Show what files are being processed
	if #filtered_files > 50 then
		vim.notify(string.format("Processing %d files (filtered from %d total)", #filtered_files, #files), 
			vim.log.levels.INFO, { title = "Contributors" })
		
		-- Debug: Show some examples of filtered vs unfiltered files
		local phpmailer_files = {}
		local images_files = {}
		local processed_files = {}
		
		for _, file in ipairs(files) do
			if file:match("PHPMailer") then
				table.insert(phpmailer_files, file)
			elseif file:match("images") then
				table.insert(images_files, file)
			end
		end
		
		for i = 1, math.min(5, #filtered_files) do
			table.insert(processed_files, filtered_files[i])
		end
		
		vim.notify(string.format("PHPMailer files found: %d (e.g. %s)", 
			#phpmailer_files, phpmailer_files[1] or "none"), 
			vim.log.levels.INFO, { title = "Debug" })
		vim.notify(string.format("Images files found: %d (e.g. %s)", 
			#images_files, images_files[1] or "none"), 
			vim.log.levels.INFO, { title = "Debug" })
		vim.notify(string.format("First 5 processed files: %s", 
			table.concat(processed_files, ", ")), 
			vim.log.levels.INFO, { title = "Debug" })
	else
		-- For smaller repos, show the actual files
		local sample_files = {}
		for i = 1, math.min(10, #filtered_files) do
			table.insert(sample_files, filtered_files[i])
		end
		local files_preview = table.concat(sample_files, ", ")
		if #filtered_files > 10 then
			files_preview = files_preview .. "... and " .. (#filtered_files - 10) .. " more"
		end
		vim.notify(string.format("Processing %d files: %s", #filtered_files, files_preview), 
			vim.log.levels.INFO, { title = "Contributors" })
	end

	local contributors = {}

	-- Method 1: Use git log with --numstat for line counts (much faster)
	-- This gives us insertions/deletions per commit per file
	local log_cmd = "git log --numstat --pretty=format:'COMMIT:%H:%an' --no-merges"
	local log_output = vim.fn.systemlist(log_cmd)
	
	if vim.v.shell_error ~= 0 then
		vim.notify("Failed to get git log, using fallback method.", vim.log.levels.WARN, { title = "Contributors" })
		return gather_current_ownership(filtered_files)
	end

	local current_author = nil
	for _, line in ipairs(log_output) do
		if line:match("^COMMIT:") then
			current_author = line:match("^COMMIT:[^:]+:(.+)")
		elseif current_author and line:match("^%d+%s+%d+%s+") then
			local added, deleted, file = line:match("^(%d+)%s+(%d+)%s+(.+)")
			if added and file and filter_file(file) then
				if not contributors[current_author] then
					contributors[current_author] = { net_lines = 0, files = {}, commits = 0 }
				end
				-- Net contribution (added - deleted)
				contributors[current_author].net_lines = contributors[current_author].net_lines + (tonumber(added) - tonumber(deleted))
				contributors[current_author].files[file] = true
				contributors[current_author].commits = contributors[current_author].commits + 1
			end
		end
	end

	-- Method 2: Use git shortlog for commit counts and author verification
	local shortlog_cmd = "git shortlog -sn --no-merges"
	local shortlog_output = vim.fn.systemlist(shortlog_cmd)
	
	-- Cross-reference and clean up data
	local verified_contributors = {}
	for _, line in ipairs(shortlog_output) do
		local commits, author = line:match("^%s*(%d+)%s+(.+)")
		if author and contributors[author] then
			verified_contributors[author] = {
				lines = math.max(0, contributors[author].net_lines), -- Ensure non-negative
				file_count = 0,
				commits = tonumber(commits)
			}
			
			-- Count unique files
			for _ in pairs(contributors[author].files) do
				verified_contributors[author].file_count = verified_contributors[author].file_count + 1
			end
		end
	end

	-- Check if we have reasonable results
	local contributor_count = 0
	local total_lines = 0
	for _, data in pairs(verified_contributors) do
		contributor_count = contributor_count + 1
		total_lines = total_lines + data.lines
	end

	-- If no contributors found or results seem off, use fallback method
	if contributor_count == 0 or total_lines <= 0 then
		vim.notify("Git log method incomplete, using current file ownership...", vim.log.levels.INFO, { title = "Contributors" })
		return gather_current_ownership(filtered_files)
	end

	return verified_contributors
end

-- Pretty print the contributor statistics
function M.print_contributors()
	local contributors = gather_contributor_stats()
	if not contributors then return end

	-- Check if there are any contributors
	local contributor_count = 0
	for _ in pairs(contributors) do
		contributor_count = contributor_count + 1
	end

	if contributor_count == 0 then
		vim.notify("No contributors found.", vim.log.levels.INFO, { title = "Contributors" })
		return
	end

	-- Sort contributors by line count (descending)
	local sorted_contributors = {}
	for author, data in pairs(contributors) do
		table.insert(sorted_contributors, { 
			author = author, 
			lines = data.lines, 
			files = data.file_count,
			commits = data.commits or 0
		})
	end
	
	table.sort(sorted_contributors, function(a, b) return a.lines > b.lines end)

	-- Calculate total lines for percentage
	local total_lines = 0
	for _, data in ipairs(sorted_contributors) do
		total_lines = total_lines + data.lines
	end

	-- Build the output table
	local header = string.format(" 👥 %d contributors, %d total lines", contributor_count, total_lines)
	local separator = string.rep("─", #header)
	local column_header = string.format("  %-25s %10s %8s %8s %10s", "Contributor", "Lines", "Files", "Commits", "Percentage")
	local column_separator = string.rep("─", #column_header)
	
	local rows = { header, separator, "", column_header, column_separator }

	for _, data in ipairs(sorted_contributors) do
		local percentage = total_lines > 0 and (data.lines / total_lines) * 100 or 0
		local row = string.format("  %-25s %10d %8d %8d %9.1f%%", 
			data.author:sub(1, 25), data.lines, data.files, data.commits, percentage)
		table.insert(rows, row)
	end

	-- Display the results
	vim.notify(table.concat(rows, "\n"), vim.log.levels.INFO, { title = "Contributors" })
end

-- Create the :Contributors command
vim.api.nvim_create_user_command("Contributors", M.print_contributors, {
	desc = "Show contributor statistics with line counts and file counts"
})

return M
