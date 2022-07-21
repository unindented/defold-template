local log = require("modules.log")

local M = {}

M.language = nil
M.default_language = "en"
M.language_list = { "en", "es", "fr" }
M.default_fallback_if_missing = not sys.get_engine_info().is_debug

M.locale_data = {}

local function load_locale(key)
  local result = {}

  local data, error = sys.load_resource("/i18n/" .. key .. "/strings.csv")
  if data then
    for line in data:gmatch("[^\r\n]+") do
      local original, translation = line:match("%s*(.-),%s*(.-),%s*(.-),%s*(.-)")
      result[original] = translation
    end
  else
    log.e(error)
  end

  return result
end

local function load_locales(language_list, default_language)
  local result = {}

  for _, language in ipairs(language_list) do
    if language ~= default_language then
      result[language] = load_locale(language)
    end
  end

  return result
end

local function set_language(language_list, default_language, chosen_language)
  local language_list_lookup = {}
  for _, language in ipairs(language_list) do
    language_list_lookup[language] = true
  end

  local language = chosen_language or sys.get_sys_info().language
  if language_list_lookup[language] then
    return language
  end

  if language_list_lookup[default_language] then
    log.w("language not in language list; using default as fallback")
    return default_language
  else
    log.e("default language not in language list")
  end
end

local function is_gui_context()
  local success = pcall(go.get_id)
  return not success
end

local function autofit_text(node)
  local text_metrics = gui.get_text_metrics_from_node(node)
  local original_scale = gui.get_scale(node).x
  local new_scale = math.min(1, gui.get_size(node).x / text_metrics.width) * original_scale
  gui.set_scale(node, vmath.vector3(new_scale, new_scale, new_scale))
end

--- Initialize locale data, and set current language.
function M.init()
  M.locale_data = load_locales(M.language_list, M.default_language)
  M.language = set_language(M.language_list, M.default_language, M.language)
end

--- Return current language.
--- @return string
function M.get_language()
  return M.language
end

--- Get translation for key.
--- @param key string|nil Key to translate
--- @param transform function|nil Transform to apply to text
--- @return string
function M.get_text(key, transform)
  if key == nil then
    log.e("key not specified")
    return "KEY NOT SPECIFIED!"
  end

  if M.language == M.default_language then
    return transform and transform(key) or key
  end

  local text = M.locale_data[M.language][key]
  if text ~= nil then
    return transform and transform(text) or text
  end

  if M.default_fallback_if_missing then
    text = M.locale_data[M.default_language][key]
    if text ~= nil then
      log.w("key " .. key .. " missing for " .. M.language .. "; using default as fallback")
      return transform and transform(text) or text
    end
  end

  log.e("key " .. key .. " missing for " .. M.language)
  return "MISSING KEY! " .. key
end

--- Translate text for target.
--- @param target userdata Node or label to translate
--- @param key string|nil Key to translate
--- @param transform function|nil Transform to apply to text
function M.set_text(target, key, transform)
  if is_gui_context() then
    key = key or gui.get_text(target)
    gui.set_text(target, M.get_text(key, transform))
    autofit_text(target)
  else
    label.set_text(target, M.get_text(key, transform))
  end
end

return M
