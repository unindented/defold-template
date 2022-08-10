----------------------------------------------------------------------------------------------------
-- I18n: Internationalization module.
----------------------------------------------------------------------------------------------------

local csv = require("modules.csv")
local log = require("modules.log")
local settings = require("modules.settings")

local M = {}

M.default_language = "en"
M.language = nil
M.language_list = nil
M.locale_data = nil

----------------------------------------------------------------------------------------------------
-- Internal API
----------------------------------------------------------------------------------------------------

local function load_languages()
  local result = {}

  local languages = sys.get_config("i18n.localizations")
  for language in string.gmatch(languages, "%w+") do
    table.insert(result, language)
  end

  return result
end

local function load_locale(key)
  local result = {}

  log.debug("loading locale '" .. key .. "'")
  local csv_str, err = sys.load_resource("/i18n/" .. key .. "/strings.csv")

  if csv_str == nil or err then
    log.error("locale '" .. key .. "' could not be loaded: " .. err)
    return result, err
  end

  local _, data_iter = csv.parse(csv_str)
  for original, translation in data_iter do
    result[original] = translation
  end

  return result
end

local function load_locales(language_list)
  local result = {}

  for _, language in ipairs(language_list) do
    result[language] = load_locale(language)
  end

  return result
end

local function detect_language(language_list, default_language, desired_language)
  local language_list_lookup = {}
  for _, language in ipairs(language_list) do
    language_list_lookup[language] = true
  end

  local language = desired_language or sys.get_sys_info().language
  if language_list_lookup[language] then
    return language
  end

  if language_list_lookup[default_language] then
    log.warn(
      "language '"
        .. language
        .. "' not in language list; using default '"
        .. default_language
        .. "' as fallback"
    )
    return default_language
  end

  log.error("default language'" .. default_language .. "' not in language list")
end

----------------------------------------------------------------------------------------------------
-- Public API
----------------------------------------------------------------------------------------------------

--- Initialize module.
function M.init()
  M.language_list = load_languages()
  M.locale_data = load_locales(M.language_list)
  M.language = detect_language(M.language_list, M.default_language, settings.get_language())
end

--- Return the language list.
--- @return table
function M.get_language_list()
  return M.language_list
end

--- Return the current language.
--- @return string
function M.get_language()
  return M.language
end

--- Set the current language.
--- @param language string New language
function M.set_language(language)
  M.language = language
  settings.set_language(language)
end

--- Get the translation for a key.
--- @param key string|nil Key to translate
--- @return string
function M.get_text(key)
  if key == nil then
    log.error("key not specified")
    return "KEY NOT SPECIFIED!"
  end

  local text = M.locale_data[M.language][key]
  if text == nil then
    log.error("key '" .. key .. "' missing for language '" .. M.language .. "'")
    return "MISSING KEY! " .. key
  end

  return text
end

return M
