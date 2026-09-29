--!nonstrict
-- Streams the daemon's state into the plugin's shared state. The loop reconnects
-- when the daemon restarts; it resends its current state to every new watcher.
noctalia.runStream("while true; do @desktop@ watch; sleep 1; done", function(line)
  local state = noctalia.json.decode(line)
  if state then
    noctalia.state.set("menu", state)
  end
end)
