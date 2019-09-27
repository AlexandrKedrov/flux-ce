class 'Inventory'

function Inventory:init(id)
  self.type = 'default'
  self.width = 1
  self.height = 1
  self.slots = {}
  self.multislot = true

  if SERVER then
    self.infinite_width = false
    self.infinite_height = false
    self.default = false
    self.receivers = {}

    id = table.insert(Inventories.stored, self)
  else
    Inventories.stored[id] = self
  end

  self.id = id
end

function Inventory:to_networkable()
  return {
    id = self.id,
    inv_type = self.type,
    width = self.width,
    height = self.height,
    slots = self.slots,
    multislot = self.multislot,
    owner = self.owner
  }
end

function Inventory:set_width(width)
  self.width = width

  self:rebuild()
end

function Inventory:set_height(height)
  self.height = height

  self:rebuild()
end

function Inventory:set_size(width, height)
  self.width = width
  self.height = height

  self:rebuild()
end

function Inventory:get_width()
  return self.width
end

function Inventory:get_height()
  return self.height
end

function Inventory:get_size()
  return self.width, self.height
end

function Inventory:get_type()
  return self.type
end

function Inventory:is_multislot()
  return self.multislot
end

function Inventory:is_width_infinite()
  return self.infinite_width
end

function Inventory:is_height_infinite()
  return self.infinite_height
end

function Inventory:is_default()
  return self.default
end

function Inventory:rebuild()
  for i = 1, self.height do
    self.slots[i] = self.slots[i] or {}

    for k = 1, self.width do
      self.slots[i][k] = self.slots[i][k] or {}
    end
  end
end

function Inventory:get_items()
  local items = {}

  for k, v in pairs(self:get_items_list()) do
    local item_table = Item.find_instance_by_id(v)

    if item_table then
      table.insert(items, item_table)
    end
  end

  return items
end

function Inventory:get_items_list()
  local items = {}

  for i = 1, self.height do
    for k = 1, self.width do
      local stack = self.slots[i][k]

      if istable(stack) and !table.is_empty(stack) then
        for _, v in pairs(stack) do
          items[v] = true
        end
      end
    end
  end

  return table.get_keys(items)
end

function Inventory:get_slot(x, y)
  if x <= self.width and y <= self.height then
    return self.slots[y][x]
  end
end

function Inventory:get_first_in_slot(x, y)
  local slot = self:get_slot(x, y)

  if istable(slot) and !table.is_empty(slot) then
    return slot[1]
  end
end

function Inventory:get_items_count(id)
  return table.count(self:find_items(id))
end

function Inventory:get_item_pos(instance_id)
  for i = 1, self.height do
    for k = 1, self.width do
      if table.has_value(self:get_slot(k, i), instance_id) then
        return k, i
      end
    end
  end
end

function Inventory:find_item(id)
  for k, v in pairs(self:get_items()) do
    if v.id == id then
      return v
    end
  end
end

function Inventory:find_items(id)
  local items = {}

  for k, v in pairs(self:get_items()) do
    if v.id == id then
      table.insert(items, v)
    end
  end

  return items
end

function Inventory:has_item(id)
  local item_table = self:find_item(id)

  if item_table then
    return true, item_table
  end

  return false
end

function Inventory:has_items(id, amount)
  amount = amount or 1

  local items = self:find_items(id)

  if table.count(items) >= amount then
    return true, items
  end

  return false, items
end

function Inventory:has_item_by_id(instance_id)
  if table.has_value(self:get_items_list(), instance_id) then
    return true, Item.find_instance_by_id(instance_id)
  end

  return false
end

function Inventory:find_position(item_table, w, h)
  local x, y

  if item_table.stackable then
    x, y = self:find_stack(item_table, w, h)
  end

  if !x or !y then
    x, y = self:find_empty_slot(w, h)
  end

  return x, y
end

function Inventory:find_stack(item_table, w, h)
  for k, v in pairs(self:find_items(item_table.id)) do
    local x, y = v.x, v.y

    if self:can_stack(item_table, x, y) then
      return x, y
    end
  end
end

function Inventory:can_stack(item_table, x, y)
  local slot = self:get_slot(x, y)
  local stack_item = Item.find_instance_by_id(slot[1])

  if stack_item and stack_item.id == item_table.id
  and item_table.stackable and #slot < item_table.max_stack then
    return true
  end

  return false
end

function Inventory:find_empty_slot(w, h)
  for i = 1, self:get_height() - h + 1 do
    for k = 1, self:get_width() - w + 1 do
      if self:slots_empty(k, i, w, h) then
        return k, i
      end
    end
  end
end

function Inventory:slots_empty(x, y, w, h)
  for i = y, y + h - 1 do
    for k = x, x + w - 1 do
      if !table.is_empty(self.slots[i][k]) then
        return false
      end
    end
  end

  return true
end

function Inventory:overlaps_stack(item_table, x, y, w, h)
  for i = y, y + h - 1 do
    for k = x, x + w - 1 do
      local slot = self:get_slot(k, i)

      if self:can_stack(item_table, k, i) and !table.has_value(slot, item_table.instance_id) then
        return true, self:get_item_pos(slot[1])
      end
    end
  end
end

function Inventory:overlaps_itself(instance_id, x, y, w, h)
  for i = y, y + h - 1 do
    for k = x, x + w - 1 do
      local slot = self.slots[i][k]

      if table.has_value(slot, instance_id) then
        return true
      end
    end
  end

  return false
end

function Inventory:overlaps_only_itself(instance_id, x, y, w, h)
  for i = y, y + h - 1 do
    for k = x, x + w - 1 do
      local slot = self.slots[i][k]

      if !table.has_value(slot, instance_id) and !table.is_empty(slot) then
        return false
      end
    end
  end

  return true
end

if SERVER then
  function Inventory:add_item(item_table, x, y)
    if !item_table then return false, 'error.inventory.invalid_item' end

    local w, h = item_table.width, item_table.height

    if !self:is_multislot() then
      w, h = 1, 1
    end

    if !x or !y or x < 1 or y < 1 or x + w - 1 > self:get_width() or y + h - 1 > self:get_height() then
      x, y = self:find_position(item_table, w, h)
    end

    if x and y then
      item_table.inventory_id = self.id
      item_table.inventory_type = self.type
      item_table.x = x
      item_table.y = y

      for i = y, y + h - 1 do
        for k = x, x + w - 1 do
          table.insert(self.slots[i][k], item_table.instance_id)
        end
      end
    else
      return false, 'error.inventory.no_space'
    end

    hook.run('OnItemAdded', item_table, self, x, y)

    return true
  end

  function Inventory:add_item_by_id(instance_id, x, y)
    return self:add_item(Item.find_instance_by_id(instance_id), x, y)
  end

  function Inventory:give_item(id, data, amount)
    amount = amount or 1

    for i = 1, amount do
      local item_table = Item.create(id, data)
      local success, error_text = self:add_item(item_table)

      if !success then
        return success, error_text
      end

      hook.run('OnItemGiven', item_table, self, data)
    end

    return true
  end

  function Inventory:take_item_table(item_table)
    if !item_table then return false, 'error.inventory.invalid_item' end

    local x, y, w, h = item_table.x, item_table.y, item_table.width, item_table.height

    if !self:is_multislot() then
      w, h = 1, 1
    end

    item_table.inventory_id = nil
    item_table.inventory_type = nil
    item_table.x = nil
    item_table.y = nil

    for i = y, y + h - 1 do
      for k = x, x + w - 1 do
        table.remove_by_value(self.slots[i][k], item_table.instance_id)
      end
    end

    hook.run('OnItemTaken', item_table, self)

    return true
  end

  function Inventory:take_item(id)
    local item_table = self:find_item(id)

    if item_table then
      return self:take_item_by_id(item_table.instance_id)
    end

    return false, 'error.inventory.invalid_item'
  end

  function Inventory:take_items(id, amount)
    if self:get_items_count(id) < amount then
      return false, 'error.inventory.not_enough_items'
    end

    for i = 1, amount do
      self:take_item(id)
    end

    return true
  end

  function Inventory:take_item_by_id(instance_id)
    return self:take_item_table(Item.find_instance_by_id(instance_id))
  end

  function Inventory:move_item(instance_id, x, y)
    local item_table = Item.find_instance_by_id(instance_id)

    if !item_table then return false, 'error.inventory.invalid_item' end

    local success, error_text = hook.run('CanItemMove', item_table, inventory, x, y)

    if success == false then
      return false, error_text
    end

    local old_x, old_y, w, h = item_table.x, item_table.y, item_table.width, item_table.height

    if !self:is_multislot() then
      w, h = 1, 1
    end

    if !x or !y or x < 1 or y < 1 or x + w - 1 > self:get_width() or y + h - 1 > self:get_height() then
      x, y = self:find_position(item_table, w, h)
    end

    if !self:slots_empty(x, y, w, h) then
      local overlap, new_x, new_y = self:overlaps_stack(item_table, x, y, w, h)

      if overlap then
        x, y = new_x, new_y
      elseif !self:overlaps_only_itself(instance_id, x, y, w, h) then
        return false, 'error.inventory.slot_occupied'
      end
    end

    item_table.x = x
    item_table.y = y

    for i = old_y, old_y + h - 1 do
      for k = old_x, old_x + w - 1 do
        table.remove_by_value(self.slots[i][k], instance_id)
      end
    end

    for i = y, y + h - 1 do
      for k = x, x + w - 1 do
        table.insert(self.slots[i][k], instance_id)
      end
    end

    return true
  end

  function Inventory:transfer_item(instance_id, inventory, x, y)
    local item_table = Item.find_instance_by_id(instance_id)

    if !item_table then return false, 'error.inventory.invalid_item' end

    local success, error_text = hook.run('CanItemTransfer', item_table, inventory, x, y)

    if success == false then
      return false, error_text
    end

    local old_x, old_y, w, h = item_table.x, item_table.y, item_table.width, item_table.height
    local old_w, old_h = w, h

    if !inventory:is_multislot() then
      w, h = 1, 1
    end

    if !self:is_multislot() then
      old_w, old_h = 1, 1
    end

    if !x or !y or x < 1 or y < 1 or x + w - 1 > inventory:get_width() or y + h - 1 > inventory:get_height() then
      x, y = inventory:find_position(item_table, w, h)
    end

    if !inventory:slots_empty(x, y, w, h) then
      local overlap, new_x, new_y = inventory:overlaps_stack(item_table, x, y, w, h)

      if overlap then
        x, y = new_x, new_y
      else
        return false, 'error.inventory.slot_occupied'
      end
    end

    item_table.inventory_id = inventory.id
    item_table.inventory_type = inventory.type
    item_table.x = x
    item_table.y = y

    for i = old_y, old_y + old_h - 1 do
      for k = old_x, old_x + old_w - 1 do
        table.remove_by_value(self.slots[i][k], instance_id)
      end
    end

    for i = y, y + h - 1 do
      for k = x, x + w - 1 do
        table.insert(inventory.slots[i][k], instance_id)
      end
    end

    hook.run('ItemTransferred', item_table, inventory, self)

    return true
  end

  function Inventory:move_stack(instance_ids, x, y)
    local instance_id = instance_ids[1]
    local item_table = Item.find_instance_by_id(instance_id)
    local old_x, old_y, w, h = item_table.x, item_table.y, item_table.width, item_table.height
    local slot = self:get_slot(old_x, old_y)

    if !self:is_multislot() then
      w, h = 1, 1
    end

    if !table.equal(instance_ids, slot) and self:overlaps_itself(instance_id, x, y, w, h) then
      return true
    end
 
    for k, v in ipairs(instance_ids) do
      local success, error_text = self:move_item(v, x, y)

      if !success then
        return success, error_text
      end
    end

    return true
  end

  function Inventory:transfer_stack(instance_ids, inventory, x, y)
    for k, v in ipairs(instance_ids) do
      local success, error_text = self:transfer_item(v, inventory, x, y)
 
      if !success then
        return success, error_text
      end
    end
 
    return true
  end

  function Inventory:get_receivers()
    return self.receivers
  end

  function Inventory:add_receiver(player)
    table.insert(self.receivers, player)
  end

  function Inventory:remove_receiver(player)
    table.remove_by_value(self.receivers, player)
  end

  function Inventory:sync()
    for k, v in pairs(self:get_receivers()) do
      if IsValid(v) then
        for k1, v1 in pairs(self:get_items_list()) do
          Item.network_item(v, v1)
        end

        Cable.send(v, 'fl_inventory_sync', self:to_networkable())
      else
        self:remove_receiver(v)
      end
    end
  end
else
  function Inventory:create_panel(parent)
    local panel = vgui.create('fl_inventory', parent)
    panel:set_inventory(self)
    panel:rebuild()
    
    self.panel = panel

    return panel
  end
end
