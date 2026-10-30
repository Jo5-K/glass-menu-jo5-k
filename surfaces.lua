-- Theme native UI surfaces, never the final screen or Pokemon artwork.
return function(R,wrap,enabled,mod,S)
 local marked=setmetatable({},{__mode='k'})
 local depth=0
 local shader,failed
 local unpack=table.unpack or unpack
 local function pack(...)return {n=select('#',...),...}end
 local function allowedPath(path)
  path=tostring(path or ''):lower()
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
 install('src.ui.game3.rse.pokedex_gfx','renderMap8',function(old,entries,key,...)
  return mark(old(entries,key,...),key)
 end)
 local chrome={
  shop_chrome={'drawBg'},
  naming_chrome={'drawBg'},
  pc_chrome={'drawBackground','drawInterfaceFrame','drawScreenBars'},
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
    return vec4(paint,p.a)*color;
   }
  ]])
  if ok then shader=value else failed=true;R.failures=R.failures+1 end
  return shader
 end
 wrap(love.graphics,'draw',function(old,img,...)
  if not enabled() or not(depth>0 or marked[img]) then return old(img,...) end
  local g=love.graphics
  if g.getShader and g.getShader() then return old(img,...) end
  local fx=getShader();if not fx then return old(img,...) end
  local p=S.menuPalette(mod.options:get('theme'))
  local ok=pcall(function()fx:send('menuBase',p[1]);fx:send('menuEdge',p[3])end)
  if not ok then return old(img,...) end
  local previous=g.getShader();g.setShader(fx)
  local result=pack(pcall(old,img,...));g.setShader(previous)
  if not result[1] then error(result[2],0) end
  return unpack(result,2,result.n)
 end)
 return function()if shader and shader.release then shader:release() end;shader=nil end
end
