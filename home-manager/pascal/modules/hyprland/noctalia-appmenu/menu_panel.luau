--!nonstrict
-- Dropdown for one top-level menu, with drill-down into submenus. Each panel size
-- in plugin.toml is a small entry that calls this module with its own name.
return function(name)
  local stack = {}
  local isOpen = false

  local function find(items, id)
    for _, item in ipairs(items or {}) do
      if item.id == id then
        return item
      end
      local child = find(item.children, id)
      if child then
        return child
      end
    end
    return nil
  end

  local function send(action, id)
    local open = noctalia.state.get("open") or {}
    noctalia.runAsync({ "@desktop@", "send", noctalia.json.encode({ action = action, id = id, key = open.key }) })
  end

  local function render()
    if not isOpen then
      return
    end
    local menu = noctalia.state.get("menu") or {}
    local open = noctalia.state.get("open") or {}
    local node = find(menu.menus, stack[#stack] or open.id)
    if not node then
      panel.close()
      return
    end
    local rows = {}
    if #stack > 0 then
      table.insert(rows, ui.button({
        text = "‹ " .. node.text,
        variant = "ghost",
        contentAlign = "start",
        controlSize = "sm",
        onClick = function()
          table.remove(stack)
          render()
        end,
      }))
      table.insert(rows, ui.separator({}))
    end
    for _, item in ipairs(node.children or {}) do
      if item.separator then
        table.insert(rows, ui.separator({}))
      else
        local submenu = item.submenu or #(item.children or {}) > 0
        table.insert(rows, ui.button({
          text = (item.checked and "✓  " or "") .. item.text .. (submenu and "  ›" or ""),
          variant = "ghost",
          contentAlign = "start",
          controlSize = "sm",
          enabled = item.enabled,
          onClick = function()
            if submenu then
              table.insert(stack, item.id)
              send("menu-open", item.id)
              render()
            else
              send("menu-click", item.id)
              panel.close()
            end
          end,
        }))
      end
    end
    panel.render(ui.scroll({ flexGrow = 1, gap = 0 }, rows))
  end

  noctalia.state.watch("menu", function()
    render()
  end)
  noctalia.state.watch("open", function()
    stack = {}
    render()
  end)

  return {
    onOpen = function(_context)
      isOpen = true
      stack = {}
      noctalia.state.set("panelOpen", name)
      render()
    end,
    onClose = function()
      isOpen = false
      if noctalia.state.get("panelOpen") == name then
        noctalia.state.set("panelOpen", "")
      end
    end,
  }
end
