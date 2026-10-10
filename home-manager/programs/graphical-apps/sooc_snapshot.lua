--[[
  sooc_snapshot.lua — pin the camera's embedded (SOOC) JPEG as a darkroom
  snapshot, automatically, every time you open a raw.

  Standalone script for stock darktable (needs Lua support and exiftool
  on $PATH — no darktable modifications required).

  How it works, per raw opened in the darkroom:
   1. the embedded JPEG is extracted with exiftool (cached in a "sooc"
      subfolder next to the raw, extracted only once per file)
   2. the JPEG is imported into the library and grouped with the raw
   3. the script briefly opens the JPEG in the darkroom, takes a snapshot
      of it, and returns to the raw — darktable keeps snapshots across
      image switches (they show a "↗ taken from …" marker), so the SOOC
      look is now available in the snapshots panel for direct overlay
      comparison against your edit

  Copyright (c) 2026 Rafael. MIT license.
]]

local dt = require "darktable"

local MODULE = "sooc_snapshot"

dt.preferences.register(
  MODULE, "auto", "bool",
  "SOOC snapshot: create automatically when opening a raw",
  "extract the embedded camera JPEG and take a snapshot of it whenever a raw "
    .. "is opened in the darkroom (once per image and session); when off, "
    .. "use the 'create SOOC JPEG snapshot' shortcut instead",
  true)

-- session state
local done = {}          -- raw imgid -> true, already handled this session
local pending = nil      -- { raw = image, jpg = image } during the dance

local function quote(path)
  return '"' .. tostring(path):gsub('"', '\\"') .. '"'
end

local function file_nonempty(path)
  local f = io.open(path, "rb")
  if not f then return false end
  local size = f:seek("end")
  f:close()
  return size ~= nil and size > 0
end

-- extract the embedded jpeg next to the raw (cached); returns path or nil
local function extract_sooc(raw)
  local raw_path = raw.path .. "/" .. raw.filename
  local dest_dir = raw.path .. "/sooc"
  local base = raw.filename:gsub("%.[^.]+$", "")
  local jpg_path = dest_dir .. "/" .. base .. ".jpg"

  if file_nonempty(jpg_path) then return jpg_path end

  dt.control.execute("mkdir -p " .. quote(dest_dir))

  -- best (full-size) preview tag first
  for _, tag in ipairs({ "JpgFromRaw", "OtherImage", "PreviewImage" }) do
    dt.control.execute("exiftool -b -" .. tag .. " " .. quote(raw_path)
                       .. " > " .. quote(jpg_path) .. " 2>/dev/null")
    if file_nonempty(jpg_path) then
      -- the bare stream loses the orientation flag; copy it from the raw
      dt.control.execute(
        "exiftool -overwrite_original -TagsFromFile " .. quote(raw_path)
        .. " -Orientation " .. quote(jpg_path) .. " >/dev/null 2>&1")
      return jpg_path
    end
  end

  dt.control.execute("rm -f " .. quote(jpg_path))
  dt.print_log(MODULE .. ": no embedded JPEG found in " .. raw_path)
  return nil
end

-- find the already-grouped sooc image, or import + group it
local function find_or_import(raw, jpg_path)
  for _, member in ipairs(raw:get_group_members()) do
    if member.path .. "/" .. member.filename == jpg_path then
      return member
    end
  end
  local jpg = dt.database.import(jpg_path)
  if jpg == nil then
    dt.print_log(MODULE .. ": import failed for " .. jpg_path)
    return nil
  end
  jpg:group_with(raw)
  raw:make_group_leader()
  return jpg
end

local function start_snapshot(raw)
  if raw == nil or not raw.is_raw then return end
  if raw.path:match("/sooc$") then return end

  local snaplib = dt.gui.libs.snapshots
  if #snaplib >= snaplib.max_snapshot then
    dt.print("SOOC snapshot: snapshot slots full — clear some snapshots first")
    done[raw.id] = true
    return
  end

  local jpg_path = extract_sooc(raw)
  if jpg_path == nil then
    done[raw.id] = true
    return
  end

  local jpg = find_or_import(raw, jpg_path)
  if jpg == nil then
    done[raw.id] = true
    return
  end

  -- open the jpeg in the darkroom; the image-loaded handler below then
  -- takes the snapshot and brings the raw back
  pending = { raw = raw, jpg = jpg }
  dt.gui.views.darkroom.display_image(jpg)
end

local function on_image_loaded(event, clean, image)
  if image == nil then return end

  -- phase 2 of the dance: the jpeg is loaded, snapshot it and go back
  if pending ~= nil and image.id == pending.jpg.id then
    local raw = pending.raw
    pending = nil
    dt.gui.libs.snapshots.take_snapshot()
    done[raw.id] = true
    dt.gui.views.darkroom.display_image(raw)
    dt.print("SOOC JPEG snapshot ready")
    return
  end

  pending = nil

  if not dt.preferences.read(MODULE, "auto", "bool") then return end
  if done[image.id] then return end

  local ok, err = pcall(start_snapshot, image)
  if not ok then dt.print_log(MODULE .. ": " .. tostring(err)) end
end

dt.register_event(MODULE, "darkroom-image-loaded", on_image_loaded)

-- manual trigger (works even with auto off, and redoes a cleared snapshot);
-- map it under settings > shortcuts > lua
dt.register_event(MODULE .. "_manual", "shortcut",
  function(event, shortcut)
    local image = dt.gui.action_images[1]
    if image ~= nil then done[image.id] = nil end
    local ok, err = pcall(start_snapshot, image)
    if not ok then dt.print_log(MODULE .. ": " .. tostring(err)) end
  end,
  "create SOOC JPEG snapshot")

local script_data = {
  metadata = {
    name = "SOOC snapshot",
    purpose = "pin the embedded camera JPEG as a darkroom snapshot",
    author = "Rafael",
  },
  destroy = function()
    dt.destroy_event(MODULE, "darkroom-image-loaded")
    dt.destroy_event(MODULE .. "_manual", "shortcut")
  end,
}

return script_data
