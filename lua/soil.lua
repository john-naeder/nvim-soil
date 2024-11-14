local Logger = require("soil.logger"):new("Soil")
local M = {}

M.DEFAULTS = {
  image = {
    darkmode = true,
    format = "svg",
    execute_to_open = function(img)
      return os.getenv("OS") == "Windows_NT" and "start" or "nsxiv " .. img
    end,
  },
}

function M.setup(opts)
  if opts.puml_jar then
    M.DEFAULTS.puml_jar = opts.puml_jar
  end
  if opts.image then
    local img = opts.image

    if img.format then
      if img.format == "png" or img.format == "svg" then
        M.DEFAULTS.image.format = img.format
      else
        Logger:error(
          "Setup Error: The values allowed for image.format are 'png' or 'svg'."
        )
      end
    end

    if img.darkmode then
      if type(img.darkmode) == "boolean" then
        M.DEFAULTS.image.darkmode = img.darkmode
      else
        Logger:error("Setup Error: image.darkmode must be a boolean value.")
      end
    end

    if img.execute_to_open then
      if type(img.execute_to_open) == "function" then
        M.DEFAULTS.image.execute_to_open = img.execute_to_open
      else
        Logger:error("Setup Error: image.execute_to_open must be a function.")
      end
    end
  end
end

return M
