MATCH (i)
  WHERE exists(i.shortcut) and i.shortcut = true
detach delete;