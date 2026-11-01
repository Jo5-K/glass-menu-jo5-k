-- Keep the field render plane under owned native menus. Never unpause the field.
return function(R,wrap,mod,S,battle)
 local Stack=require('src.ui.game3.stack')
 local ids={item_pc=true,rse_item_storage=true,trainer=true,rse_pokedex=true,bag=true,party=true,summary=true,pokedex=true,region_map=true,option=true,save=true,
  trainer_card=true,pc=true,pc_menu=true,box_storage=true,shop=true,naming=true,controls=true,
  berry_pouch=true,tm_case=true,pyramid_bag=true,item_storage=true,pokenav=true,mod_manager=true}
 local function managed(layer)
  return ids[layer.id] or (layer.mod and layer.mod.state and layer.mod.state.glass_menu_jo5k==true)
 end
 local function active()
  return R.active and not battle() and mod.options:get('enabled')~=false and mod.options:get('theme')~='original'
 end
 local function owned()
  local top=Stack.top()
  return top and managed(top)
 end
 wrap(Stack,'fullscreen',function(old,...)
  local native=old(...)
  if not native or not active() then return native end
  local order=Stack.drawOrder()
  for _,layer in ipairs(order) do
   if layer.fullscreen and not managed(layer) then return native end
  end
  return false
 end)
 -- Many native screens fill a complete opaque rectangle before drawing icons.
 -- Change only large UI fills, in the UI pass of one of the supported menus.
 wrap(love.graphics,'rectangle',function(old,mode,x,y,w,h,...)
  if active() and R.depth>0 and owned() and Stack.top().id~='summary' and mode=='fill' and type(w)=='number' and type(h)=='number' and w>=80 and h>=24 then
   local g=love.graphics
   if not(g.getColor and g.setColor) then return old(mode,x,y,w,h,...) end
   local r,green,b,a=g.getColor()
   -- Transparent fades, animation wipes and darkening overlays remain native.
   if (a or 1)<.95 then return old(mode,x,y,w,h,...) end
   local p=S.menuPalette(mod.options:get('theme'))
   local alpha=(w>=240 and h>=160) and .08 or .87
   g.setColor(p[1][1],p[1][2],p[1][3],alpha)
   local unpack=table.unpack or unpack
   local result={pcall(old,mode,x,y,w,h,...)}
   g.setColor(r,green,b,a)
   if not result[1] then error(result[2],0) end
   return unpack(result,2)
  end
  return old(mode,x,y,w,h,...)
 end)
 return {active=active,owned=owned}
end
