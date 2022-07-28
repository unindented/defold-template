local csv = require("modules.csv")
local log = require("modules.log")

local M = {}

M.language = nil
M.default_language = "en"
M.default_fallback_if_missing = not sys.get_engine_info().is_debug

M.language_list = nil
M.language_names = nil
M.locale_data = nil

local function load_languages()
  local list = {}
  local names = {}

  local csv_str, error = sys.load_resource("/i18n/languages.csv")
  if csv_str then
    local _, data_iter = csv.parse(csv_str)
    for code, name in data_iter do
      table.insert(list, code)
      names[code] = name
    end
  else
    log.e(error)
  end

  return list, names
end

local function load_locale(key)
  local result = {}

  local csv_str, error = sys.load_resource("/i18n/" .. key .. "/strings.csv")
  if csv_str then
    local _, data_iter = csv.parse(csv_str)
    for original, translation in data_iter do
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
    result[language] = load_locale(language)
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

--- Initialize i18n data.
function M.init()
  local language_list, language_names = load_languages()
  M.language_list = language_list
  M.language_names = language_names
  M.locale_data = load_locales(M.language_list, M.default_language)
  M.language = set_language(M.language_list, M.default_language, M.language)
end

--- Return current language.
--- @return string
function M.get_language()
  return M.language
end

--- Return language list.
--- @return table
function M.get_language_list()
  return M.language_list
end

--- Return language label.
--- @param language_name string Language name
--- @return string
function M.get_language_label(language_name)
  local label = language_name

  if language_name ~= M.language_names[M.language] then
    label = label .. " (" .. M.locale_data[M.language][language_name] .. ")"
  end

  return label
end

--- Get translation for key.
--- @param key string|nil Key to translate
--- @param config table|nil Transform to apply to text
--- @return string
function M.get_text(key, config)
  if key == nil then
    log.e("key not specified")
    return "KEY NOT SPECIFIED!"
  end

  local native_language = config and config.native_language or false
  local text_transform = config and config.text_transform or nil

  if native_language or M.language == M.default_language then
    return text_transform and text_transform(key) or key
  end

  local text = M.locale_data[M.language][key]
  if text ~= nil then
    return text_transform and text_transform(text) or text
  end

  if M.default_fallback_if_missing then
    text = M.locale_data[M.default_language][key]
    if text ~= nil then
      log.w("key " .. key .. " missing for " .. M.language .. "; using default as fallback")
      return text_transform and text_transform(text) or text
    end
  end

  log.e("key " .. key .. " missing for " .. M.language)
  return "MISSING KEY! " .. key
end

--- Translate text for target.
--- @param target userdata Node or label to translate
--- @param key string|nil Key to translate
--- @param config table|nil Transform to apply to text
function M.set_text(target, key, config)
  if is_gui_context() then
    key = key or gui.get_text(target)
    gui.set_text(target, M.get_text(key, config))
    autofit_text(target)
  else
    label.set_text(target, M.get_text(key, config))
  end
end

return M
