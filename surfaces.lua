-- Theme native UI surfaces, never the final screen or Pokemon artwork.
return function(R,wrap,enabled,mod,S)
 local marked=setmetatable({},{__mode='k'})
 local depth=0
 local trainerDepth=0
 local function isCardLayer(path)
  path=tostring(path or ''):lower()
  return path:find('/trainer_card/',1,true) and (path:find('/front',1,true) or path:find('/back',1,true) or path:find('/screen',1,true))
 end
 local shader,failed
 local unpack=table.unpack or unpack
 local function pack(...)return {n=select('#',...),...}end
 local function allowedPath(path)
  path=tostring(path or ''):lower()
  if isCardLayer(path) then return true end
  for _,word in ipairs({'sprite','portrait','pokemon','trainer','icon','type','status','map','area_map','region_map','wave','needle','marking'}) do
   if path:find(word,1,true) then return false end
  end
  return true
 end
 local function mark(img,path)
  if img and img.getDimensions and allowedPath(path) then
   local w,h=img:getDimensions()
   if w>=128 and h>=96 then marked[img]=true end
  end
  return img
 end
 local function install(path,key,fn)
  local ok,t=pcall(require,path)
  if ok and type(t)=='table' then wrap(t,key,fn) end
 end
 for _,key in ipairs({'image','rgbaImage','maskedLayer'}) do
  install('src.ui.game3.rse.scene_kit',key,function(old,path,...)
   return mark(old(path,...),path)
  end)
 end
 for _,method in ipairs({'renderMap','renderMap8'}) do
  install('src.ui.game3.rse.pokedex_gfx',method,function(old,entries,key,...)
   return mark(old(entries,key,...),key)
  end)
 end
 -- FRLG card surfaces are privately cached; identify them only in its draw call,
 -- by the native full-card footprint. Canvases, portraits and badge quads stay native.
 for _,path in ipairs({'src.ui.game3.trainer_card','src.ui.game3.rs.trainer_card'}) do
  install(path,'draw',function(old,...)
   trainerDepth=trainerDepth+1;local out=pack(pcall(old,...));trainerDepth=trainerDepth-1
   if not out[1] then error(out[2],0) end
   return unpack(out,2,out.n)
  end)
 end
 if love.graphics.clear then
  wrap(love.graphics,'clear',function(old,...)
   local RS=package.loaded['src.ui.game3.rs.trainer_card']
   if enabled() and trainerDepth>0 and RS and RS._canvas and love.graphics.getCanvas and love.graphics.getCanvas()==RS._canvas then
    return old(0,0,0,0)
   end
   return old(...)
  end)
 end
 -- Storage panels are private textures and include small strips/slots.
 -- Register their exact identities instead of filtering the whole PC draw,
 -- which would also recolor Pokémon, item icons, cursors and wallpaper.
 install('src.ui.game3.pc_chrome','ensure',function(old,...)
  local out=pack(old(...))
  local C=package.loaded['src.ui.game3.pc_chrome']
  if C then
   for _,key in ipairs({'_bgImg','_frameImg','_buttonPartyImg','_buttonCloseImg',
    '_partyDrawerBgImg','_partySlotFilledImg','_partySlotEmptyImg',
    '_chooseBoxCenterImg','_chooseBoxSidesImg','_pcScreenBarImg'}) do
    local img=C[key];if img then marked[img]=true end
   end
  end
  return unpack(out,1,out.n)
 end)
 local chrome={
  shop_chrome={'drawBg'},
  naming_chrome={'drawBg'},
  pc_chrome={'drawBackground','drawInterfaceFrame','drawScreenBars','drawTopButtons'},
  tm_case_chrome={'drawBg','drawCover'},
  berry_pouch_chrome={'drawBg'},
  bag_chrome={'drawBg','drawListFrame','drawDescSelected'},
  party_chrome={'drawBg','drawSlot','drawCancelButton','drawConfirmButton'},
  summary_chrome={'drawBg3','drawProgress','drawLayer'},
  pokedex_chrome={'drawBars','drawPaperBg'},
  ['rs.party_chrome']={'drawBg','drawCancelButton','drawConfirmButton'},
 }
 for path,keys in pairs(chrome) do for _,key in ipairs(keys) do
  install('src.ui.game3.'..path,key,function(old,...)
   depth=depth+1;local out=pack(pcall(old,...));depth=depth-1
   if not out[1] then error(out[2],0) end
   return unpack(out,2,out.n)
  end)
 end end
 local function getShader()
  if shader or failed then return shader end
  local g=love.graphics
  if not(g.newShader and g.getShader and g.setShader) then failed=true;return end
  local ok,value=pcall(g.newShader,[[
   extern vec3 menuBase;
   extern vec3 menuEdge;
   vec4 effect(vec4 color, Image image, vec2 uv, vec2 screen) {
    vec4 p=Texel(image,uv);
    float l=dot(p.rgb,vec3(0.2126,0.7152,0.0722));
    vec3 paint=mix(menuEdge,menuBase,smoothstep(0.06,0.92,l));
    return vec4(paint,p.a*0.87)*color;
   }
  ]])
  if ok then shader=value else failed=true;R.failures=R.failures+1 end
  return shader
 end
 wrap(love.graphics,'draw',function(old,img,...)
  local cardSurface=false
  if trainerDepth>0 and img and img.getDimensions and not(img.typeOf and img:typeOf('Canvas')) then
   local w,h=img:getDimensions()
   local args={...};local q=args[1]
   if q and (type(q)=='table' or type(q)=='userdata') and q.getViewport then local x,y; x,y,w,h=q:getViewport() end
   cardSurface=w==240 and h==160
  end
  if not enabled() or not(depth>0 or marked[img] or cardSurface) then return old(img,...) end
  local g=love.graphics
  local nativeShader=g.getShader and g.getShader()
  local fx=not nativeShader and getShader()
  local p=S.menuPalette(mod.options:get('theme'))
  if not fx then
   -- No shader support: retain transparency and theme without CPU pixel work.
   if not(g.getColor and g.setColor) then return old(img,...) end
   local r,green,b,a=g.getColor()
   g.setColor(r*p[1][1],green*p[1][2],b*p[1][3],(a or 1)*.87)
   local result=pack(pcall(old,img,...));g.setColor(r,green,b,a)
   if not result[1] then error(result[2],0) end
   return unpack(result,2,result.n)
  end
  local ok=pcall(function()fx:send('menuBase',p[1]);fx:send('menuEdge',p[3])end)
  if not ok then return old(img,...) end
  local previous=g.getShader();g.setShader(fx)
  local result=pack(pcall(old,img,...));g.setShader(previous)
  if not result[1] then error(result[2],0) end
  return unpack(result,2,result.n)
 end)
 return function()if shader and shader.release then shader:release() end;shader=nil end
end
