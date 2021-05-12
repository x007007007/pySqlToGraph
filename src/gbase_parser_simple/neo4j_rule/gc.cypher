MATCH (i)
  WHERE exists(i.shortcut) and i.delete = true
  detach delete;