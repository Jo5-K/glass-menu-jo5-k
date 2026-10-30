-- Presentation only: native content, layout and input are never replaced.
return function(mod)
 local unpack=table.unpack or unpack
 local function pack(...) return {n=select('#',...),...} end
 local version=require('src.core.GameVersion').get()
 if not ({emerald=true,ruby=true,sapphire=true,firered=true,leafgreen=true})[version] then return end
 local Game=require('src.core.Game3')
 local lease='_glass_menu_jo5k_owner'
 if Game[lease] then Game[lease].shutdown() end
 local S=assert(load(assert(mod:read('skin.lua')),'@glass_menu_jo5k/skin.lua'))()()
 local R={active=true,depth=0,patches={},subscriptions={},failures=0}
 Game[lease]=R
 mod.options:define({
  {key='language',label='Language / Idioma',type='choice',default='en',group='Glass Menu - Jo5-k',choices={{'English','en'},{'Português','pt-BR'}}},
  {key='enabled',label='Glass Menu',type='toggle',default=true,group='Glass Menu - Jo5-k'},
  {key='text_style',label='Text / Texto',type='choice',default='native',group='Glass Menu - Jo5-k',choices={{'Native','native'},{'Light','light'},{'Dark','dark'}}},
  {key='theme',label='Theme / Tema',type='choice',default='crystal_glass',group='Glass Menu - Jo5-k',choices={{'Original','original'},{'Glass','crystal_glass'},{'Ivory','emerald_ivory'},{'GBA','emerald_gba'},{'Current','current'},{'Classic','classic'},{'Floating','floating_glass'},{'Emerald Green','emerald_green'},{'Emerald GBA','emerald_native'}}}
 })
 local function battle()
  local B=package.loaded['src.core.game3.battle.init']
  if B and B.isActive and B.isActive() then return true end
  local E=package.loaded['src.ui.game3.evolution_scene']
  if E and E._isBattle and (E.active or E._active or E.open or (E.isActive and E.isActive())) then return true end
  return R.battleOrigin==true
 end
 local function enabled() return R.active and R.depth>0 and not battle() and mod.options:get('enabled')~=false and mod.options:get('theme')~='original' end
 local function wrap(t,key,fn)
  if type(t[key])~='function' then return end
  local old=t[key];local new=function(...) if not R.active then return old(...) end;return fn(old,...) end
  t[key]=new;R.patches[#R.patches+1]={t,key,old,new}
 end
 local function scoped(old,...)
  if battle() then return old(...) end
  R.depth=R.depth+1
  local result=pack(pcall(old,...));R.depth=R.depth-1
  if not result[1] then error(result[2],0) end
  return unpack(result,2,result.n)
 end
 local function panel(x,y,w,h)
  local g=love.graphics;g.push('all')
  local ok,err=pcall(function()
   local theme=mod.options:get('theme') or 'crystal_glass'
   S.menuPanel(x,y,w,h,theme)
  end)
  g.pop()
  if not ok then R.failures=R.failures+1;return false end
  return true
 end
 local Chrome=require('src.ui.game3.chrome')
 for _,key in ipairs({'stdFrame','fixedStdFrame','userFrame'}) do
  wrap(Chrome,key,function(old,...)
   local a={...};local start=key=='userFrame' and 2 or 1
   local x,y,w,h=a[start],a[start+1],a[start+2],a[start+3]
   if enabled() and type(h)=='number' and panel(x*8-8,y*8-8,(w+2)*8,(h+2)*8) then return end
   return old(...)
  end)
 end
 for _,key in ipairs({'dialogueFrame'}) do
  wrap(Chrome,key,function(old,...)
   local x,y,w,h=Chrome.dialogueWindow()
   if enabled() and panel(x*8-8,y*8-8,(w+2)*8,(h+2)*8) then return end
   return old(...)
  end)
 end
 -- Fill is separate from the native frame; keep it inside the same bounds.
 local Window=require('src.ui.game3.window')
 wrap(Window,'fill',function(old,tpl,...)
  if enabled() and type(tpl)=='table' then
   local x,y,w,h=tpl.left or tpl.tilemapLeft,tpl.top or tpl.tilemapTop,tpl.w or tpl.width,tpl.h or tpl.height
   if x and y and w and h and panel(x*8,y*8,w*8,h*8) then return end
  end
  return old(tpl,...)
 end)
 wrap(require('src.ui.game3.ui_pass'),'drawUi',scoped)
 -- Typography is independent from the selected panel theme.
 local Font=require('src.ui.game3.frlg_font')
 local function textColors()
  local style=mod.options:get('text_style') or 'native'
  if style=='light' then return {.98,.98,.95,1},{.025,.04,.06,1} end
  if style=='dark' then return {.08,.14,.18,1},{.96,.98,1,1} end
 end
 wrap(Font,'draw',function(old,text,x,y,opts)
  if R.active and R.depth>0 and not battle() and mod.options:get('enabled')~=false then
   local ink,shadow=textColors()
   if ink then
    local copy={};for k,v in pairs(opts or {}) do copy[k]=v end
    local colors={};for k,v in pairs(copy.colors or {}) do colors[k]=v end
    colors.fg=ink;colors.shadow=shadow;colors.bg=colors.bg or copy.bg or Font.STDPAL[0]
    copy.colors=colors;copy.color=ink;copy.shadow=shadow;opts=copy
   end
  end
  return old(text,x,y,opts)
 end)
 local floating=assert(load(assert(mod:read('floating.lua')),'@glass_menu_jo5k/floating.lua'))()(R,wrap,mod,S,battle)
 local stopSurfaces=assert(load(assert(mod:read('surfaces.lua')),'@glass_menu_jo5k/surfaces.lua'))()(R,wrap,enabled,mod,S)
 local SCREEN='glass_menu_jo5k:settings'
 local words={
  en={title='GLASS / SETTINGS',hint='A: apply   B: back',theme='Theme',text='Text',language='Language',
   original='Original',crystal_glass='Glass',emerald_ivory='Ivory',emerald_gba='GBA',current='Current',classic='Classic',floating_glass='Floating',emerald_green='Emerald Green',emerald_native='Emerald GBA',native='Native',light='Light',dark='Dark'},
  ['pt-BR']={title='GLASS / AJUSTES',hint='A: aplicar   B: voltar',theme='Tema',text='Texto',language='Idioma',
   original='Original',crystal_glass='Glass',emerald_ivory='Marfim',emerald_gba='GBA',current='Atual',classic='Clássico',floating_glass='Flutuante',emerald_green='Emerald Verde',emerald_native='Emerald GBA',native='Nativo',light='Claro',dark='Escuro'}
 }
 local function lang() return words[mod.options:get('language')] or words.en end
 local defaults={language='en',theme='crystal_glass',text_style='native'}
 local themes={'original','crystal_glass','emerald_ivory','emerald_gba','current','classic','floating_glass','emerald_green','emerald_native'}
 mod.content.screens:register(SCREEN,{new=function(game)
  local items={}
  -- Language is first, and English is its first choice.
  for _,entry in ipairs({{'English','en'},{'Português','pt-BR'}}) do
   items[#items+1]={key='language',value=entry[2],name=entry[1]}
  end
  for _,value in ipairs(themes) do items[#items+1]={key='theme',value=value} end
  for _,value in ipairs({'native','light','dark'}) do items[#items+1]={key='text_style',value=value} end
  local function refresh(menu)
   local l=lang();menu.title=l.title
   for _,row in ipairs(menu.items) do
    local group=row.key=='text_style' and 'text' or row.key
    row.label=l[group]..': '..(row.name or l[row.value])
    row.right=(mod.options:get(row.key) or defaults[row.key])==row.value and '*' or ''
   end
  end
  local menu=mod.ui.ListMenu.new(game,lang().title,items,{onChoose=function(item,menu)
   require('src.mods.ManagerState').new(game):setOption(mod.id,item.key,item.value)
   require('src.mods.ManagerState').new(game):setOption(mod.id,'enabled',true)
   refresh(menu)
  end})
  refresh(menu)
  -- Gen3 must use its ROM font; the generic ListMenu renderer uses Gen1 glyphs.
  menu.glass_menu_jo5k=true
  menu.gbaCanvas=true
  menu.rows=6
  function menu:draw()
   local g=love.graphics;g.push('all')
   local ok,err=pcall(function()
    refresh(self)
    local theme=mod.options:get('theme') or 'crystal_glass'
    if theme=='original' then
     g.setColor(1,1,.90,1);g.rectangle('fill',14,7,212,146)
     g.setColor(.18,.25,.23,1);g.setLineWidth(1);g.rectangle('line',14.5,7.5,211,145)
    else S.menuPanel(14,7,212,146,theme) end
    local opts={colors=Font.COLOR.NORMAL,maxWidth=192}
    Font.draw(lang().title,24,13,opts)
    for r=1,self.rows do
     local i=self.scroll+r;local row=self.items[i]
     if not row then break end
     local y=34+(r-1)*16
     if i==self.index then
      g.setColor(.08,.14,.18,.12);g.rectangle('fill',22,y-1,194,16,1,1)
      Font.draw('>',24,y,opts)
     end
     Font.draw(row.label,38,y,opts)
     if row.right=='*' then Font.draw('*',201,y,opts) end
    end
    Font.draw(lang().hint,24,135,opts)
   end)
   g.pop();if not ok then error(err,0) end
  end
  return menu
 end})
 R.subscriptions[#R.subscriptions+1]=mod.hooks:wrap('ui.start_menu.items',function(nextFn,game,items)
  local out=nextFn(game,items)
  if battle() or type(out)~='table' then return out end
  for _,item in ipairs(out) do if item.id=='glass_menu_settings' then return out end end
  return mod.ui.insertBefore(out,'SAVE',{id='glass_menu_settings',label='GLASS',onSelect=function() mod.ui.push(game,SCREEN) end})
 end)
 R.subscriptions[#R.subscriptions+1]=mod.events:on('battle.started',function() R.battleOrigin=true end)
 -- Exclude follow-up screens until the field UI stack has actually closed.
 R.subscriptions[#R.subscriptions+1]=mod.events:on('battle.ended',function() R.ended=true end)
 R.subscriptions[#R.subscriptions+1]=mod.hooks:wrap('input.step',function(nextFn,...)
  local result=pack(nextFn(...))
  local Stack=package.loaded['src.ui.game3.stack']
  local E=package.loaded['src.ui.game3.evolution_scene']
  if R.ended and (not Stack or Stack.depth()==0) and not (E and E.open) then R.battleOrigin=false;R.ended=false end
  return unpack(result,1,result.n)
 end)
 function R.shutdown()
  if not R.active then return end;R.active=false
  for i=#R.subscriptions,1,-1 do if type(R.subscriptions[i])=='function' then R.subscriptions[i]() end end
  for i=#R.patches,1,-1 do local p=R.patches[i];if p[1][p[2]]==p[4] then p[1][p[2]]=p[3] end end
  stopSurfaces();S.shutdown();if Game[lease]==R then Game[lease]=nil end
 end
 R.subscriptions[#R.subscriptions+1]=mod.hooks:wrap('core.quit_to_launcher',function(nextFn,...) R.shutdown();return nextFn(...) end)
 mod.exports.shutdown=R.shutdown
 mod.exports.diagnostics=function() return {active=R.active,failures=R.failures,battleExcluded=battle(),floating=floating.active()} end
end
