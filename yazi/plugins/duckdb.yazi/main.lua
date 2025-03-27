-- This function generates the SQL query based on the preview mode.
local function generate_sql(job, mode)
	if mode == "standard" then
		return string.format("SELECT * FROM '%s' LIMIT 500", tostring(job.file.url))
	else
		return string.format(
			[[SELECT
				column_name AS column,
				column_type AS type,
				count,
				approx_unique AS unique,
				null_percentage AS null,
				LEFT(min, 10) AS min,
				LEFT(max, 10) AS max,
				CASE
					WHEN column_type IN ('TIMESTAMP', 'DATE') THEN '-'
					WHEN avg IS NULL THEN 'NULL'
					WHEN TRY_CAST(avg AS DOUBLE) IS NULL THEN avg
					WHEN CAST(avg AS DOUBLE) < 100000 THEN CAST(ROUND(CAST(avg AS DOUBLE), 2) AS VARCHAR)
					WHEN CAST(avg AS DOUBLE) < 1000000 THEN CAST(ROUND(CAST(avg AS DOUBLE) / 1000, 1) AS VARCHAR) || 'k'
					WHEN CAST(avg AS DOUBLE) < 1000000000 THEN CAST(ROUND(CAST(avg AS DOUBLE) / 1000000, 2) AS VARCHAR) || 'm'
					WHEN CAST(avg AS DOUBLE) < 1000000000000 THEN CAST(ROUND(CAST(avg AS DOUBLE) / 1000000000, 2) AS VARCHAR) || 'b'
					ELSE '∞'
				END AS avg,
				CASE
					WHEN column_type IN ('TIMESTAMP', 'DATE') THEN '-'
					WHEN std IS NULL THEN 'NULL'
					WHEN TRY_CAST(std AS DOUBLE) IS NULL THEN std
					WHEN CAST(std AS DOUBLE) < 100000 THEN CAST(ROUND(CAST(std AS DOUBLE), 2) AS VARCHAR)
					WHEN CAST(std AS DOUBLE) < 1000000 THEN CAST(ROUND(CAST(std AS DOUBLE) / 1000, 1) AS VARCHAR) || 'k'
					WHEN CAST(std AS DOUBLE) < 1000000000 THEN CAST(ROUND(CAST(std AS DOUBLE) / 1000000, 2) AS VARCHAR) || 'm'
					WHEN CAST(std AS DOUBLE) < 1000000000000 THEN CAST(ROUND(CAST(std AS DOUBLE) / 1000000000, 2) AS VARCHAR) || 'b'
					ELSE '∞'
				END AS std,
				CASE
					WHEN column_type IN ('TIMESTAMP', 'DATE') THEN '-'
					WHEN q25 IS NULL THEN 'NULL'
					WHEN TRY_CAST(q25 AS DOUBLE) IS NULL THEN q25
					WHEN CAST(q25 AS DOUBLE) < 100000 THEN CAST(ROUND(CAST(q25 AS DOUBLE), 2) AS VARCHAR)
					WHEN CAST(q25 AS DOUBLE) < 1000000 THEN CAST(ROUND(CAST(q25 AS DOUBLE) / 1000, 1) AS VARCHAR) || 'k'
					WHEN CAST(q25 AS DOUBLE) < 1000000000 THEN CAST(ROUND(CAST(q25 AS DOUBLE) / 1000000, 2) AS VARCHAR) || 'm'
					WHEN CAST(q25 AS DOUBLE) < 1000000000000 THEN CAST(ROUND(CAST(q25 AS DOUBLE) / 1000000000, 2) AS VARCHAR) || 'b'
					ELSE '∞'
				END AS q25,
				CASE
					WHEN column_type IN ('TIMESTAMP', 'DATE') THEN '-'
					WHEN q50 IS NULL THEN 'NULL'
					WHEN TRY_CAST(q50 AS DOUBLE) IS NULL THEN q50
					WHEN CAST(q50 AS DOUBLE) < 100000 THEN CAST(ROUND(CAST(q50 AS DOUBLE), 2) AS VARCHAR)
					WHEN CAST(q50 AS DOUBLE) < 1000000 THEN CAST(ROUND(CAST(q50 AS DOUBLE) / 1000, 1) AS VARCHAR) || 'k'
					WHEN CAST(q50 AS DOUBLE) < 1000000000 THEN CAST(ROUND(CAST(q50 AS DOUBLE) / 1000000, 2) AS VARCHAR) || 'm'
					WHEN CAST(q50 AS DOUBLE) < 1000000000000 THEN CAST(ROUND(CAST(q50 AS DOUBLE) / 1000000000, 2) AS VARCHAR) || 'b'
					ELSE '∞'
				END AS q50,
				CASE
					WHEN column_type IN ('TIMESTAMP', 'DATE') THEN '-'
					WHEN q75 IS NULL THEN 'NULL'
					WHEN TRY_CAST(q75 AS DOUBLE) IS NULL THEN q75
					WHEN CAST(q75 AS DOUBLE) < 100000 THEN CAST(ROUND(CAST(q75 AS DOUBLE), 2) AS VARCHAR)
					WHEN CAST(q75 AS DOUBLE) < 1000000 THEN CAST(ROUND(CAST(q75 AS DOUBLE) / 1000, 1) AS VARCHAR) || 'k'
					WHEN CAST(q75 AS DOUBLE) < 1000000000 THEN CAST(ROUND(CAST(q75 AS DOUBLE) / 1000000, 2) AS VARCHAR) || 'm'
					WHEN CAST(q75 AS DOUBLE) < 1000000000000 THEN CAST(ROUND(CAST(q75 AS DOUBLE) / 1000000000, 2) AS VARCHAR) || 'b'
					ELSE '∞'
				END AS q75
			FROM (summarize FROM '%s')]],
			tostring(job.file.url)
		)
	end
end

local function get_cache_path(job, type)
	local skip = job.skip
	job.skip = 0
	local base = ya.file_cache(job)
	job.skip = skip
	if not base then
		return nil
	end
	local suffix = ({ standard = "_standard.db", summarized = "_summarized.db", mode = "_mode.db" })[type or "standard"]
	return Url(tostring(base) .. suffix)
end

local function run_query(job, query, target)
	local args = {}
	if target ~= job.file.url then
		table.insert(args, tostring(target))
	end
	table.insert(args, "-c")
	table.insert(args, query)
	local child = Command("duckdb"):args(args):stdout(Command.PIPED):stderr(Command.PIPED):spawn()
	if not child then
		return nil
	end
	local output, err = child:wait_with_output()
	if err then
		return nil
	end
	if not output.status.success then
		ya.err("DuckDB exited with error: " .. output.stderr)
		return nil
	end
	return output
end

local function create_cache(job, mode, path)
	local filename = job.file.url:name() or "unknown"
	if fs.cha(path) then
		return true
	end
	local sql = (mode == "mode") and "CREATE TABLE My_table AS SELECT 'standard' AS Preview_mode;"
		or string.format("CREATE TABLE My_table AS (%s);", generate_sql(job, mode))
	local out = run_query(job, sql, path, mode == "mode" and "mode" or nil)
	if not out then
		ya.err("Preload - Failed to generate " .. mode .. " cache for file: " .. tostring(filename) .. ".")
		return false
	end
	return true
end

local function get_preview_mode(job)
	local mode = "standard"
	local mode_cache = get_cache_path(job, "mode")
	if not mode_cache then
		return mode
	end
	if not fs.cha(mode_cache) then
		create_cache(job, "mode", mode_cache)
	end
	local result = run_query(job, "SELECT Preview_mode FROM My_table LIMIT 1;", mode_cache, "mode")
	if result and result.stdout and result.stdout ~= "" then
		local value = result.stdout:lower()
		if value:match("summarized") then
			mode = "summarized"
		end
	end
	return mode
end

local function generate_query(target, job, limit, offset)
	local mode = get_preview_mode(job)
	if target == job.file.url then
		if mode == "standard" then
			return string.format("SELECT * FROM '%s' LIMIT %d OFFSET %d;", tostring(target), limit, offset)
		else
			local query = generate_sql(job, mode)
			return string.format("WITH query AS (%s) SELECT * FROM query LIMIT %d OFFSET %d;", query, limit, offset)
		end
	else
		return string.format("SELECT * FROM My_table LIMIT %d OFFSET %d;", limit, offset)
	end
end

local function set_preview_mode(job, mode)
	local mode_cache = get_cache_path(job, "mode")
	if not mode_cache then
		return false
	end
	run_query(job, "DELETE FROM My_table;", mode_cache, "mode")
	local sql = string.format("INSERT INTO My_table VALUES ('%s');", mode)
	local result = run_query(job, sql, mode_cache, "mode")
	if not result then
		ya.err("SetPreviewMode - Failed to update preview mode.")
		return false
	end
	return true
end

local M = {}

function M:preload(job)
	local cache_standard = get_cache_path(job, "standard")
	local cache_summarized = get_cache_path(job, "summarized")
	if not cache_standard or not cache_summarized then
		return false
	end
	if fs.cha(cache_standard) and fs.cha(cache_summarized) then
		return true
	end
	local success = true
	success = create_cache(job, "standard", cache_standard) and success
	success = create_cache(job, "summarized", cache_summarized) and success
	return success
end

function M:peek(job)
	local raw_skip = job.skip or 0
	local skip = math.max(0, raw_skip - 50)
	if raw_skip > 0 and raw_skip < 50 then
		local current_mode = get_preview_mode(job)
		local new_mode = current_mode == "standard" and "summarized" or "standard"
		set_preview_mode(job, new_mode)
		skip = 0
	end
	job.skip = skip
	local mode = get_preview_mode(job)
	local cache = get_cache_path(job, mode)
	local file_url = job.file.url
	local target = cache
	local limit = job.area.h - 7
	local offset = skip
	if not cache or not fs.cha(cache) then
		target = file_url
	end
	local query = generate_query(target, job, limit, offset)
	local output = run_query(job, query, target)
	if not output or output.stdout == "" then
		if target ~= file_url then
			target = file_url
			query = generate_query(target, job, limit, offset)
			output = run_query(job, query, target)
			if not output or output.stdout == "" then
				return require("code"):peek(job)
			end
		else
			return require("code"):peek(job)
		end
	end
	ya.preview_widgets(job, { ui.Text.parse(output.stdout):area(job.area) })
end

function M:seek(job)
	local OFFSET_BASE = 50
	local encoded_current_skip = cx.active.preview.skip or 0
	local current_skip = math.max(0, encoded_current_skip - OFFSET_BASE)
	local units = job.units or 0
	local new_skip = current_skip + units
	local encoded_skip = new_skip + OFFSET_BASE
	ya.manager_emit("peek", { encoded_skip, only_if = job.file.url })
end

return M
