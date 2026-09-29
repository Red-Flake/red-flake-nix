--!nonstrict
-- Bar widget: the focused app's name followed by its top-level menus.
local menu = noctalia.state.get("menu") or {}

local function panelFor(entry)
  local count = #(entry.children or {})
  if count <= 3 then
    return "menu_xs"
  elseif count <= 6 then
    return "menu_s"
  elseif count <= 13 then
    return "menu_m"
  end
  return "menu_l"
end

local function open(entry)
  local panel = panelFor(entry)
  local current = noctalia.state.get("panelOpen")
  local shown = noctalia.state.get("open")
  noctalia.state.set("open", { id = entry.id, key = menu.menuKey })
  noctalia.runAsync({ "@desktop@", "send", noctalia.json.encode({ action = "menu-open", id = entry.id, key = menu.menuKey }) })
  -- Switching between menus of the same size re-renders the open dropdown instead of closing it.
  if current == panel and shown and shown.id ~= entry.id then
    return
  end
  noctalia.togglePanel("stellaris/appmenu:" .. panel)
end

local function render()
  local items = {}
  for _, entry in ipairs(menu.menus or {}) do
    if not entry.separator and entry.text ~= "" then
      table.insert(items, ui.button({
        text = entry.text,
        variant = "ghost",
        enabled = entry.enabled,
        onClick = function()
          open(entry)
        end,
      }))
    end
  end
  if menu.app and menu.app ~= "" then
    table.insert(items, 1, ui.label({ text = menu.app, fontWeight = "bold" }))
  end
  barWidget.setVisible(#items > 0)
  if #items > 0 then
    barWidget.render(ui.row({ gap = 2, align = "center" }, items))
  end
end

noctalia.state.watch("menu", function(value)
  menu = value or {}
  render()
end)

function update()
  render()
end

-- `noctalia msg plugin stellaris/appmenu:menu focused open [Label]` opens a menu from
-- a keybind or script; without a label it opens the first one.
function onIpc(event, payload)
  if event ~= "open" then
    return
  end
  for _, entry in ipairs(menu.menus or {}) do
    if not entry.separator and (payload == nil or payload == "" or entry.text == payload) then
      open(entry)
      return
    end
  end
end
