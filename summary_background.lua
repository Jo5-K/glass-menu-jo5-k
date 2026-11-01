-- Recolor only summary surfaces. Preserve native text, move badges, bars and art.
return function(wrap,allowed,palette)
 local depth,background=0,0
 local tagged=setmetatable({},{__mode='k'})
 local shader
 local unpack=table.unpack or unpack
 local function callScoped(old,...)
  depth=depth+1;local r={pcall(old,...)};depth=depth-1
  if not r[1]then error(r[2],0)end;return unpack(r,2)
 end
 local function module(path)local ok,m=pcall(require,path);return ok and m or nil end
 local K=module('src.ui.game3.rse.scene_kit')
 if K then wrap(K,'image',function(old,path,...)
  local img=old(path,...)
  if img and img.getDimensions and tostring(path):find('/summary/',1,true)then
   local w,h=img:getDimensions();if w>=128 and h>=96 then tagged[img]=true end
  end
  return img
 end)end
 for _,path in ipairs({'summary_menu','rse.summary_menu','rs.summary_menu'})do
  local m=module('src.ui.game3.'..path)
  if m then wrap(m,'draw',function(old,...)
   if allowed(m)then return callScoped(old,...)end;return old(...)
  end)end
 end
 local C=module('src.ui.game3.summary_chrome')
 if C then for _,key in ipairs({'drawBg3','drawLayer'})do wrap(C,key,function(old,...)
  background=background+1;local r={pcall(old,...)};background=background-1
  if not r[1]then error(r[2],0)end;return unpack(r,2)
 end)end end
 local g=love.graphics
 wrap(g,'draw',function(old,img,...)
  if depth==0 or not(tagged[img]or background>0)then return old(img,...)end
  local p=palette();local color=g.getColor and {g.getColor()}or {1,1,1,1}
  local previous=g.getShader and g.getShader()
  if not previous and g.newShader and g.setShader then
   if shader==nil then
    local ok,v=pcall(g.newShader,[[extern vec3 tint;vec4 effect(vec4 c,Image t,vec2 u,vec2 s){vec4 p=Texel(t,u);float l=dot(p.rgb,vec3(.2126,.7152,.0722));return vec4(mix(tint*.55,tint,.35+.65*l),p.a*.92)*c;}]])
    shader=ok and v or false
   end
   if shader then shader:send('tint',p);g.setShader(shader)end
  end
  if previous or not shader then g.setColor(color[1]*p[1],color[2]*p[2],color[3]*p[3],color[4]*.92)end
  local r={pcall(old,img,...)}
  if g.setShader then g.setShader(previous)end;g.setColor(unpack(color))
  if not r[1]then error(r[2],0)end;return unpack(r,2)
 end)
 wrap(g,'rectangle',function(old,mode,x,y,w,h,...)
  if depth>0 and mode=='fill' and x==0 and y==0 and w>=240 and h>=160 then
   local color={g.getColor()};local p=palette();g.setColor(p[1],p[2],p[3],.08)
   local r={pcall(old,mode,x,y,w,h,...)};g.setColor(unpack(color));if not r[1]then error(r[2],0)end;return unpack(r,2)
  end;return old(mode,x,y,w,h,...)
 end)
 return function()if shader and shader.release then shader:release()end;shader=nil end
end
