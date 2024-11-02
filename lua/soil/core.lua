local Logger = require("soil.logger"):new("Soil")
local settings = require("soil").DEFAULTS
local M = {}

local function validate()
  if vim.bo.filetype ~= "plantuml" then
    Logger:warn("This is not a Plant UML file.")
    return false
  end
  if vim.fn.executable("java") == 0 then
    Logger:warn("Java is required. Install it to use this plugin.")
    return false
  end
  if vim.fn.executable("nsxiv") == 0 and settings.image.execute_to_open then
    if string.find(settings.image.execute_to_open(""), "nsxiv") then
      Logger:warn("Nsxiv is required. Install it to use this plugin.")
      return false
    end
  end
  return true
end

local function get_image_command(file)
  if not file then
    return nil
  end
  local image_file = string.format("%s.%s", file, settings.image.format)
  Logger:info(string.format("Image %s generated!", image_file))
  return string.format(
    "%s %s",
    settings.image.execute_to_open(image_file),
    image_file
  )
end

local function execute_command(command, error_msg)
  if command then
    vim.fn.system(command)
    if vim.v.shell_error ~= 0 then
      Logger:error(error_msg or "Execution error!")
        end
  end
end

function M.run()
  if not validate() then
    return
  end

  local file_with_extension = vim.fn.expand("%:p")
  local file = vim.fn.expand("%:p:r")
  local format = settings.image.format
  local darkmode = settings.image.darkmode and "-darkmode" or ""
  local cli_puml = vim.fn.executable("plantuml") ~= 0
  local puml_jar = settings.puml_jar

  Logger:info("Building...")
  local puml_command = cli_puml
      and string.format(
        "plantuml %s -t%s %s",
        file_with_extension,
        format,
        darkmode
      )
    or string.format(
      "java -jar %s %s -t%s %s",
      puml_jar,
      file_with_extension,
      format,
      darkmode
    )

  execute_command(puml_command, "Failed to generate PlantUML diagram.")
  execute_command(get_image_command(file), "Image not generated.")
end

function M.open_image()
  execute_command(
    get_image_command(vim.fn.expand("%:p:r")),
    "Image not found. Run :Soil command to generate it."
  )
end

return M
