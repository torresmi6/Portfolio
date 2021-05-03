pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-------------------------------
----- init function -----------
-------------------------------

-- globals for init
health = 5

-- four studios logo
function logo()
 cls()
 rectfill(47, 60, 52, 65, 11)
 rectfill(47, 64, 48, 65, 0)
 delay(5)
 rectfill(47, 52, 52, 57, 11)
 rectfill(47, 52, 48, 53, 0)
 delay(5)
 rectfill(55, 52, 60, 57, 11)
 rectfill(59, 52, 60, 53, 0)
 delay(5)
 rectfill(55, 60, 60, 65, 11)
 rectfill(59, 64, 60, 65, 0)
 delay(5)
 rectfill(53, 58, 54, 59,11)

 delay(10)
 color(7)
 print("four", 63, 54)
 delay(10)
 color(6)
 print("studios", 63, 60)
 
 delay(30)
 cls()
   
end

function delay(t)
 for i=0, t do
  flip()
 end
end

function _init()
 
 -- intro logo
 logo()
 
 -- initial cam placement
 camx = -64
 camy = -64
 
 -- initial floorgen
 floorgen()

 -- title screen
 scene = "title"

end
-->8
 -------------------------------
----------- update  -----------
-------------------------------
-- note: function update every
-- 60 fps

-- globals for update
score = 0
-- test

test = false

-- rooms to draw
room_max = 1

-- save cam location
camx_old = camx
camy_old = camy

-- test var for creeping dark
trigger = false

--cursor directions
-- if 0, cursor moves right/down
-- if 1, cursor moves left/up
-- if 2, cursor stops moving
cursor_h_dir = 0
cursor_v_dir = 0

--combat state
-- if 0, not current
-- if 1, current state
combat_h = 1
combat_v = 0

--attempts set based on enemies
-- cnt used to keep track of btn presses
attempts = 1
atmpt_cnt_x = 0
atmpt_cnt_y = 0

--array of user attempts
usr_atmpts = {}

--keeps track of successful hits
hits = 0
--keeps track of previous hits for printing
hits_temp = 0
--when true, stops calculating
calc_done = false

function _update60()

	if(scene == "title" or
	   scene == "title_idle") then
		if(scene == "title") then
			sfx(1)
		end
		title_controls()
	elseif(scene == "instr") then
		instr_controls()
	elseif(scene == "game") then
		game_controls()
	elseif(scene == "combat") then
		combat_controls() 
	elseif(scene == "end_idle") then
		clear_map()
		end_controls()
	end

end -- end _update60()

-- controls for title menu,
-- do later!
function title_controls()

  scene = "game"
  
end -- end title_controls()

-- main character controls
function game_controls()
 -- determine collisions
 collide()
 -- cam
 camx = player.pos.x
 camy = player.pos.y
 camera(camx-64, camy-64)
 
 -- darkness consumption
 consumed()
 
 -- buttons
 if(btnp(🅾️,0)) then
  if(room_max <= #floor) then
   if(fget(to_top, 2) and
    room_max == 4)then
    scene = "end_idle"
   elseif(fget(to_top, 2))then
   room_max += 1
   opn_door()
   delay(80)
   -- found door, start combat
   camx_old = camx
   camy_old = camy
   camx = 0
   camy = 0
   camera(camx, camy)
   set_enemies()
   draw_game()
   scene = "combat"
   
   trigger = false
   end
  end
 end
 if(btnp(❎,0)) then
  destroy()
 end
 if(btn(⬆️,0)) then
  player.move = true
  if(fl_top == false) then
   player.pos.y-=player.speed
  else
   player.pos.y=player.pos.y
  end
  player.anim = 56
  player.fram = 2
  player.flip = false
 elseif(btn(⬇️,0)) then
  player.move = true
  if(fl_bot == false) then
   player.pos.y+=player.speed
  else
   player.pos.y=player.pos.y
  end
  player.anim = 58
  player.fram = 2
  player.flip = false
 elseif(btn(➡️,0)) then
  player.move = true
  if(fl_right == false) then
   player.pos.x+=player.speed
  else
   player.pos.x=player.pos.x
  end
  player.anim = 54
  player.fram = 2
  player.flip = true
 elseif(btn(⬅️,0)) then
  player.move = true
  if(fl_left == false) then
   player.pos.x-=player.speed
  else
   player.pos.x=player.pos.x
  end
  player.anim = 54
  player.fram = 2
  player.flip = false
 else
  player.move = false
  player.fram = 1
 end
 
end -- end game_controls()

-- combat controls
function combat_controls()

	if (combat_v == 1) then
		
		if atmpt_cnt_y == atmpt_cnt_x then
			--cursor_v_dir = 2
			combat_v = 0	
			combat_h = 1
		end
		
		if atmpt_cnt_y == attempts then
			cursor_v_dir = 2
			combat_v = 0
			combat_h = 0
		end
		
		if (btnp(🅾️,0)) then
			atmpt_cnt_y += 1
			usr_atmpts[atmpt_cnt_y][2] = cursor_v.y+4
			cursor_v.clr += 1
			cursor_v.sprite +=2
			if cursor_v.sprite == 86 then
			 cursor_v.sprite = 76 
			end
		end
	end


 if (combat_h == 1) then
		
		if atmpt_cnt_x != atmpt_cnt_y then
			--cursor_h_dir = 2
			combat_h = 0
			combat_v = 1
		end
		
		if atmpt_cnt_x == attempts then
			cursor_h_dir = 2
		end
		
		if (btnp(🅾️,0)) then
			atmpt_cnt_x += 1
			usr_atmpts[atmpt_cnt_x][1] = cursor_h.x+4
		 cursor_h.clr += 1
		 cursor_h.sprite += 2
		 if cursor_h.sprite == 85 then 
		  cursor_h.sprite = 75
		 end 
		end
	end
end -- end combat_controls()

function move_cursor_h()


	if(cursor_h.x == 114) then
		cursor_h_dir = 1
	end
	
	if(cursor_h.x == 13) then
		cursor_h_dir = 0
	end
	
	if(cursor_h_dir == 0) then
		cursor_h.x += 1
	elseif (cursor_h_dir == 1) then
	 cursor_h.x -= 1
	end
	
end -- end move_cursor_h()

function move_cursor_v()

	if(cursor_v.y == 98) then
		cursor_v_dir = 1
	end
	
	if(cursor_v.y == 4) then
		cursor_v_dir = 0
	end
	
	if(cursor_v_dir == 0) then
		cursor_v.y += 1
	elseif (cursor_v_dir == 1) then
	 cursor_v.y -= 1
	end
	
end -- end move_cursor_v()

function calc_results()
	for i = 1, num_enm do
		for a = 1, num_enm do
			if (usr_atmpts[a][1] - enemies[i][1]) < 8 and (usr_atmpts[a][1] - enemies[i][1]) > 0 then
				if (usr_atmpts[a][2] - enemies[i][2]) < 8 and (usr_atmpts[a][2] - enemies[i][2]) > 0 then
				hits += 1
				end
			end	
		end
	end
	
	life_lost = num_enm - hits
	health = health - life_lost
	if health < 0 then health = 0
	end
	hits_temp = hits
	calc_done = true
end

function end_controls()
 if(btnp(🅾️,0) or
    btnp(❎,0)) then
 
  -- reset
  dark_line = 0
  floorgen()
  player.pos={x=(mapx*8),
              y=(mapy*8)-25}
  room_max = 1
  trigger = false
  scene = "title"
  
 end
end
-->8
-------------------------------
------------ draw -------------
-------------------------------

-- globals for draw
mapx = 48
mapy = 32

col_obj = {}
-- initial horizontal cursor values
cursor_h = {
    x=12,
    y=108,
    sprite=75,
    clr = 7
}

-- initial vertical cursor values
cursor_v = {
    x=5,
    y=4,
    sprite=76,
    clr = 7
}

--stops the intersection from drawing when true
itrs_done = false

function _draw()

 if(scene == "title") then
 	draw_title()
 elseif(scene == "instr") then
  draw_instr()
 elseif(scene == "game") then
  draw_game()
 elseif(scene == "combat") then
 	draw_combat()
 elseif(scene == "end_idle") then
 	draw_end()
 end
 
end -- end draw()

-- draw the title splash screen
function draw_title()
	
	cls()

end -- end draw_title()

-- draw the instructions page, maybe a short
-- intro to the story
function draw_instr()
 cls()
       
end

function draw_game()
	cls()
      
 -- draw coords
 --print((camx/8), camx,
 --					 camy-16)
 --print((camy/8), camx,
 --      camy-8)
 
 -- draw floor
 draw_floor()
 
 -- draw player
 animp(player.move,
       player, player.anim,
       player.fram, 10,
       player.flip)
 
 -- draw health
 draw_health()
 
 -- draw creeping darkness
 if(trigger == true) then
  creepdark()
 end

end

-- draw a single room
function draw_room(matx, x, y) 
 j = 0
 i = 0
 temp = false
 for k=1, #matx.r do
  -- if top layer, draw opaque
  --if(matx.r[k] == 1 or
  --   matx.r[k] == 2 or
  --   matx.r[k] == 3 or
  --   matx.r[k] == 7 or
  --   matx.r[k] == 18) then
  -- palt(0, false)
  --end
  -- dont draw under the
  -- darkness line
  if(y+j*8 < dark_line) then
	  -- draw room objects
	  --spr(matx.o[k], x+i*8, y+j*8)
	  -- draw room tiles
	  --spr(matx.r[k], x+i*8, y+j*8)
	  -- draw room tiles
	   mset(mapx+(x/8)+i,
	        mapy+(y/8)+j,
	        matx.r[k])
	   --mset(8+(x/8)+i, 24+(y/8)+j,
	   --    matx.o[k])
	   spr(matx.o[k],
	      (mapx*8)+x+i*8,
	      (mapy*8)+y+j*8)
	      
  end
  -- reset draw transparency
  palt()
 
  -- loop variables
  i += 1
  if(i%matx.w == 0) then
   j += 1
   i = 0
  end
 end
 
end -- end draw_room()

-- draw the whole discovered floor
function draw_floor()
 map()
 for i=room_max, 1, -1 do 
  draw_room(floor[i],
         floor.coord_x[i], 
         floor.coord_y[i])
 end

end -- end draw_floor()

-- draw door open "animation",
-- needs improvement!
function opn_door()
 floor[room_max-1].r[floor[room_max-1].tpdr+1] = 18
end

function draw_combat()
 cls()
 --static map, can add more
 map() 
 draw_enemies()
	draw_cursor_h()
	draw_cursor_v()
	draw_attempts()
	if (combat_h == 1) then
		move_cursor_h()
	end
	if (combat_v == 1) then
		move_cursor_v()
	end
	
	if (cursor_h_dir == 2 and
	    cursor_v_dir == 2) then
		draw_intersection()
		if calc_done == false then
			calc_results()
		end
		draw_result()
		delay(110)
		hits = 0
		
		if health == 0 then
		 camx = 64
	  camy = 64
	  scene = "end_idle"
	  return
	 end	
		
		-- end of all attempts
		-- go back to main game
		camx = camx_old
		camy = camy_old
		
		
		--reset values
		cursor_h_dir = 0
  cursor_v_dir = 0
  combat_h = 1
  combat_v = 0
  attempts = 1
  atmpt_cnt_x = 0
  atmpt_cnt_y = 0
  cursor_h.sprite = 75
  cursor_v.sprite = 76
  itrs_done = false
  usr_atmpts = {}
		calc_done = false
		scene = "game"
	
		--start darkness
		trigger = true
		
	end

end

function draw_cursor_h()
	spr(cursor_h.sprite, cursor_h.x, cursor_h.y)
end

function draw_cursor_v()
	spr(cursor_v.sprite, cursor_v.x, cursor_v.y)
end

function draw_enemies()
	for i = 1, num_enm do
		spr(85, enemies[i][1], enemies[i][2])
	end
end

function draw_intersection()
		for y = 1, num_enm do
			rect(16, usr_atmpts[y][2], usr_atmpts[y][1], usr_atmpts[y][2],7+y)
			rect(usr_atmpts[y][1], usr_atmpts[y][2],usr_atmpts[y][1], 102,7+y)
		end
		delay(60)
--	end
end

function draw_attempts()
	for i = 1, atmpt_cnt_x do
		rect(usr_atmpts[i][1],103,usr_atmpts[i][1],104,7+i) 
	end
	
	for i = 1, atmpt_cnt_y do
		rect(15,usr_atmpts[i][2],16,usr_atmpts[i][2],7+i) 
	end
	
end

function draw_result()
	
	if life_lost == 0 then
		print(hits_temp.." hits!  no life lost  lives:"..health,7)
	elseif life_lost > 1 then print(hits_temp.." hits!  "..life_lost.." lives lost  lives:"..health,7)
	else print(hits_temp.." hits!  1 life lost  lives:"..health,7)
	end
	
end

function draw_end()
	cls()
	print("score", camx-10, camy-16)
	if(score >= 100) then
	 print(score, camx-7, camy-8)
	else
	 print(score, camx-4, camy-8)
	end
	print("gameover", camx-16, camy)
	print("press 🅾️ or ❎ to restart",
	      camx-48, camy+10)
end

function draw_health()
	for i = 0, health-1  do
		spr(86, camx+24+(8*i),
		    camy-63)
	end
end

function clear_map()
 for i=16, 128 do
  for j=0, 128 do
   mset(i, j, 0)
  end
 end
end

-->8
-------------------------------
------- full floor gen --------
-------------------------------

function floorgen()

 -- floor collection
 floor = {}
 local floornum = 4
 floor.coord_x = {}
 floor.coord_y = {}
 
 -- generate and set rooms
 for i=1, floornum do 
  roomgen()
  floor[i] = room
 end
 
 -- determine door placement
 local strt_x = 0
 local strt_y = -8
 for i=1, floornum do 
  -- set start position
  strt_x -= (floor[i].btdr*8) 
  strt_y -= (floor[i].h)*8
  -- set point
  add(floor.coord_x, strt_x)
  add(floor.coord_y, strt_y)  
  -- update start position
  strt_x += floor[i].tpdr*8
  
  -- old operations (keep for
  -- reference)
  --strt_x=strt_x+(floor[i].tpdr*8-floor[i].btdr*8) 
  --strt_y=strt_y-(floor[i].h-1)*8 
 end
 
 -- remove bottom door
 -- from first room in floor
 for i=1, #floor[1].r do 
  if(floor[1].r[i] == 18) then
   floor[1].r[i] = 12
   floor[1].r[i-floor[1].w] = 5
  end
 end
 
 -- remove bottom door
 -- from first room in floor
 for i=1, #floor[4].r do 
  if(floor[4].r[i] == 7) then
   floor[4].r[i] = 20
  end
 end
 
 
end -- floorgen()

-->8
-------------------------------
-------- full room gen --------
-------------------------------

function roomgen()
 -- gen room
 room = {}
 
 -- room tiles
 room.r = {flr(rnd(2))}
 
 -- variables for insuring
 -- door placements and setting
 -- room "divits" for complexity
 -- complexity is 2 max for gen
 -- reasons
 room.comp = 2
 room.drf = false
 
 -- variable for figuring out
 -- divit start
 room.lcrn = 0
 
 -- variables for storing top
 -- and bottom door offsets
 room.tpdr = 0
 room.btdr = 0
 
 -- det. top layer
 topnxt(room)
 
 -- set room width and height
 -- based on top layer gen with
 -- minumum of 5 height
 room.w = #room.r
 room.h = (flr(rnd(room.w/2)+5))
 --room.h = 10
 
 -- det. rest of room
 for i=2, room.h do
  room.drf = false --door plcmt
  room.tp = 0  -- tiles placed
  room.cr = i  -- current row
  nxt(room) 
 end
 
 -- room objects
 roomfill()
 room.o = obj
 
end

-->8
-------------------------------
----- top room layer gen  -----
-------------------------------

function topnxt(f)
 -- prev tile
 local prev = f.r[#f.r]
 
 -- base case
 if(f.comp == 0) then
  return
 end
 
 -- randomizer variable
 local ch = flr(rnd(2))
 
 -- recurse case to det. next
 -- no tile
 if(prev == 0) then
  if(ch == 0) then
   add(f.r, 0)
  end
  add(f.r, 1)
   f.lcrn = #f.r
  return topnxt(f)
 -- left corner tile
 elseif(prev == 1) then
  -- insure door
  if((ch == 0 or 
      f.comp == 1) and
      f.drf == false) then
   add(f.r, 7)
   -- set top door offset
   f.tpdr = #f.r-1
  else
   add(f.r, 2)
  end
  return topnxt(f)
 -- wall tile
 elseif(prev == 2) then
  -- bigger rooms
  -- remove to shrink rooms
  local ch2 = flr(rnd(2))
  if(ch2 == 0) then
   add(f.r, 2)
  end
  -- remove to here
  if(ch == 0 and
     f.drf == false) then
   add(f.r, 7)
   -- set top door offset
   f.tpdr = #f.r-1 
  else
   add(f.r, 3)
  end
  return topnxt(f)
 -- door tile
 elseif(prev == 7) then
  f.drf = true
  if(ch == 0) then
   add(f.r, 2)
  else
   add(f.r, 3)
  end
  return topnxt(f)
 -- right corner tile
 elseif(prev == 3) then
  f.comp -= 1
  add(f.r, 0)
  return topnxt(f)
 end
end -- topnxt()

-->8
-------------------------------
------- room layers gen -------
-------------------------------
-- note: potential to reduce 
-- token count if need be

function nxt(f)
 -- previous tile, above tile
 -- above-1 tile, above+1 tile
 -- and current tile
 local abov =(f.r[(#f.r-f.w)+1])
 local prev =f.r[#f.r]
 local tpr =(f.r[(#f.r-f.w)+2])
 local tpl =(f.r[#f.r-f.w])
 local pos =((#f.r+1) % f.w)
 
 -- set prev and above-1 to 
 -- 0 if first in line
 if(#f.r % f.w == 0) then
  prev = 0
  tpl = 0
 end

 -- base case
 if(f.tp == f.w) then
  return
 end
 
 -- increment tiles placed
 f.tp+=1
 
 -- recurse cases to det. next
 -- based on tile above, 
 -- topleft, topright, and
 -- previous
 
 -- randomizer variable
 local ch = flr(rnd(2))
 
 -- production rules
 -- no tile
 if(abov == 0) then
  if(prev == 0 or
     prev == 3 or
     prev == 6 or
     prev == 10 or
     prev == 13) then
   if(pos == 0 or
      pos >= f.lcrn or
      f.cr >= f.h-2) then
    add(f.r, 0)
   elseif(pos == 1 or
        ch == 0 or 
        tpr == 8
        ) then
    add(f.r, 1)
   else
    add(f.r, 0)
   end
  elseif(prev == 1 and
         pos == 0) then
    add(f.r, 3)
  elseif(prev == 2 or
         prev == 15) then
   if(pos == 0 or
      pos >= f.lcrn or
      f.cr == 1) then
    add(f.r, 3)
   else
    add(f.r, 2)
   end
  else
    add(f.r, 2)
  end
  return nxt(f)
  
 -- upper left corner
 elseif(abov == 1) then
  if(prev == 1 or
     prev == 2 or
     prev == 15) then
   add(f.r, 14)
  elseif(f.cr >= f.h-1) then
   add(f.r, 4)
  else
   add(f.r, 8)
  end
  return nxt(f)
  
 -- wall or door tiles
 elseif(abov == 2 or
        abov == 7) then
   if(prev == 4 or
      prev == 5) then
    if(f.cr >= f.h-1 or
       pos >= f.w-2) then
     add(f.r, 5)
    elseif(tpr == 14) then
     add(f.r, 16)
    elseif(ch == 0) then
     add(f.r, 5)
    else
     add(f.r, 16)
    end
  else
   add(f.r, 9)
  end
  return nxt(f)
  
 -- upper right corner tile
 elseif(abov == 3) then
  -- helper for door rand
  if(f.cr == f.h-1) then
   f.comp += 1
  end 
  if(prev == 8 or
     prev == 9 or
     prev == 14 or
     prev == 15 or
     prev == 16) then
   if(pos == 0) then
    add(f.r, 10)
   else
    add(f.r, 15)
   end
  else
    add(f.r, 6)
  end
  return nxt(f)
  
 -- lower left corner tile 
 elseif(abov == 4) then
  if(prev == 1 or
     prev == 2 or
     prev == 15) then
   add(f.r, 2)
  elseif(prev == 6) then
   if(ch == 0 and
      f.cr < f.h-1) then
    add(f.r, 1)
   else
    add(f.r, 11)
   end  
  else
   add(f.r, 11)
  end
  return nxt(f)
  
 -- bottom wall tile 
 elseif(abov == 5) then
  if(prev == 1 or
     prev == 2) then
   if(ch == 0) then
    add(f.r, 2)
   else
    add(f.r, 3)
   end
  elseif(prev == 5 and
         tpr == 6) then
   add(f.r, 6)
  elseif(prev == 15) then
   add(f.r, 2)
  elseif(prev == 11 or
         prev == 12 or
         prev == 18) then
   -- revise code for door!!
   -- insure bottom door
   if(f.cr == f.h) then
    if(tpr == 6) then
     if(f.comp == 1 and
        f.drf == false) then
      f.drf = true
      add(f.r, 18)
      -- adjust tile above door
      -- (might move to open
      -- door animation func)
      f.r[#f.r-f.w] = 9
      -- set bottom door offset
      f.btdr = f.tp-1
     else
      f.comp -= 1
      add(f.r, 12)
     end
    elseif(ch == 0 and
       f.drf == false) then
     f.drf = true
     add(f.r, 18)
     -- adjust tile above door
     -- (might move to open
     -- door animation func)
     f.r[#f.r-f.w] = 9
     -- set bottom door offset
     f.btdr = f.tp-1
    else
     add(f.r, 12)
    end
   else
    add(f.r, 12)
   end
   -- end revision area
  else  
   add(f.r, 12)
  end
  return nxt(f)
  
 -- lower right corner tile 
 elseif(abov == 6) then
  if(prev == 2) then
   if(pos == 0 or
      ch == 0 or
     (tpr != 0 and
      f.cr < f.h -3)) then
    add(f.r, 3)
   else
    add(f.r, 2)
   end
  elseif(prev == 15) then
   if(pos == 0) then
    add(f.r, 3)
   else 
    add(f.r, 2)
   end
  else
   add(f.r, 13)
  end
  return nxt(f)
  
 -- left wall tile
 elseif(abov == 8) then
  if(prev == 0 or
     prev == 3 or
     prev == 6 or
     prev == 10 or
     prev == 13) then 
   if(f.cr >= f.h-1) then
    add(f.r, 4)
   elseif(pos >= f.lcrn) then
    add(f.r, 8)
   elseif(ch == 0 and
      pos <= f.w-3) then
    add(f.r, 4)
   else
    add(f.r, 8)
   end
  else
   add(f.r, 14)
  end
  return nxt(f)
  
 -- ground tile
 elseif(abov == 9) then
  if(prev == 4) then
   if(f.cr >= f.h-1 or
     pos >= f.w-2) then
    add(f.r, 5)
   elseif(tpr == 6) then
    add(f.r, 6)
   else
    add(f.r, 16)
   end
  elseif(prev == 5 or
         prev == 17) then
   if(ch == 0 or
      f.cr >= f.h-1) then
    add(f.r, 5)
   elseif(pos >= f.w-2) then
    add(f.r, 5)
   else
    add(f.r, 16)
   end  
  elseif(prev == 9) then
   if(ch == 0) then
    add(f.r, 17)
   else
    add(f.r, 9)
   end
  elseif(prev == 11 or
         prev == 12) then
   add(f.r, 8)
  else
   add(f.r, 9)
  end
  return nxt(f)
  
 -- right wall tile
 elseif(abov == 10) then
  -- helper for door rand
  if(f.cr == f.h-1 and
     prev == 5) then
   f.comp += 1
  end 
  if(prev == 8 or
     prev == 9 or
     prev == 14 or
     prev == 16) then
   if(pos == 0) then
    add(f.r, 10)
   else
    add(f.r, 15)
   end
  elseif(prev == 12) then
   add(f.r, 13)
  else
   add(f.r, 6)
  end
  return nxt(f)
  
 -- outside left corner tile 
 elseif(abov == 11 or
        abov == 12) then
  if(prev == 1 or
     prev == 2 or
     prev == 15) then
   if(ch == 0 or
      pos <= f.lcrn) then
    add(f.r, 2)
   elseif(ch == 1 and
         abov == 12) then
    add(f.r, 3)
   end
  else
   add(f.r, 0)
  end
  return nxt(f)
  
 -- outside right corner tile 
 elseif(abov == 13) then
  if(prev == 0 or
     prev == 3 or
     prev == 6 or
     prev == 10 or
     prev == 13) then
   if(pos >= f.lcrn) then
    add(f.r, 0)
   elseif(tpr == 8 and
      f.cr <= f.h-2 and
      pos != 0) then
    add(f.r, 1)
   elseif(ch == 0 or
          pos == 0 or
          f.cr >= f.h-3) then
    add(f.r, 0)
   else
    add(f.r, 1)
   end 
  elseif(prev == 2 or
         prev == 9) then
   if(pos == 0 or 
      f.cr >= f.h-2) then
    add(f.r, 3)
   elseif(ch == 0) then
    add(f.r, 2)
   else
    add(f.r, 3)
   end
  elseif(prev == 15) then
   if(pos == 0) then
    add(f.r, 3)
   else
    add(f.r, 2)
   end
  end
  return nxt(f)
 
  -- inside left wall tile 
 elseif(abov == 14) then
  if(prev == 4 or
     prev == 5) then
   if(f.cr >= f.h-1) then
    add(f.r, 5)
   else
    add(f.r, 16)
   end
  else
   add(f.r, 9)
  end
  return nxt(f)
 
 -- inside right wall tile 
 elseif(abov == 15) then
  if(prev == 4 or 
     prev == 5 or
     prev == 17) then
   if(f.cr >= f.h-1) then
    add(f.r, 5)
   elseif(pos >= f.w-2) then
    add(f.r, 5)
   elseif((pos <= f.lcrn and
          prev == 4) or
          f.cr >= f.h-3) then
    add(f.r, 16)
   else
    add(f.r, 5)
   end
  else
   add(f.r, 9)
  end
  return nxt(f)
  
 -- inside left corner tile 
 elseif(abov == 16) then
  if(prev == 3 or
     prev == 6 or
     prev == 10 or
  			prev == 11 or
     prev == 12) then
   if(f.cr >= f.h-1) then
    add(f.r, 4)
   elseif(pos >= f.lcrn) then
    add(f.r, 8)
   elseif(ch == 0 and
          f.cr >= f.h/2) then
    add(f.r, 4)
   else
    add(f.r, 8)
   end
  else
   add(f.r, 14) 
  end
  return nxt(f)
  
 -- inside right corner tile 
 elseif(abov == 17) then
  -- helper for door rand
  if(f.cr == f.h-1) then
   f.comp += 1
  end
  if(prev == 5 or
     prev == 17) then
   add(f.r, 6)
  elseif(prev == 9) then
   if(pos >= f.lcrn) then
    add(f.r, 10)
   elseif(ch == 0 or
      f.cr >= f.h-2) then
    add(f.r, 15)
   else
    add(f.r, 10)
   end
  elseif(prev == 16) then
    add(f.r, 15)
  end
  return nxt(f)
  
 end
end -- nxt()

-->8
-------------------------------
----- room object fill gen ----
-------------------------------

function roomfill()
 -- parallel matrix, holding
 -- room entity objects

 -- objects collection
 obj = {}

 -- loop through room layout
 -- and add objects
 for i=1, #room.r do
  -- randomizer variable
  -- value in rand determines
  -- percentage. ex. 5 means
  -- 1/5 chance to spawn!!
  local ch = flr(rnd(7))
 
  -- if at an object valid
  -- tile, have a chance
  -- to place object
  if(i == #room.r-(room.w
             +(room.w
              -room.btdr-1)) or
     i == room.tpdr+room.w+1
    ) then
   add(obj, 0)
  elseif(ch == 0 and
        (room.r[i] == 4 or
         room.r[i] == 5 or
         room.r[i] == 6 or
         room.r[i] == 8 or
         room.r[i] == 9 or
         room.r[i] == 10 or
         room.r[i] == 14 or
         room.r[i] == 15)) then
   ch = flr(rnd(20))
   -- barrel: base 70% chance
   -- 16/20 
   if(ch < 16) then
    add(obj, 48)
   -- crate: base 25% chance
   -- 5/20 
   elseif(ch >= 16 and
          ch < 19) then
    add(obj, 49)
   -- chest: base 5% chance
   -- 1/20 
   else
    add(obj, 50)
   end
   
   -- set flag
	  if(room.r[i] == 4) then
	   room.r[i] = 22
	  end
	  if(room.r[i] == 5) then
	   room.r[i] = 23
	  end
	  if(room.r[i] == 6) then
	   room.r[i] = 24
	  end
	  if(room.r[i] == 8) then
	   room.r[i] = 25
	  end
	  if(room.r[i] == 9) then
	   room.r[i] = 26
	  end
	  if(room.r[i] == 10) then
	   room.r[i] = 27
	  end
	  if(room.r[i] == 14) then
	   room.r[i] = 28
	  end
	  if(room.r[i] == 15) then
	   room.r[i] = 29
	  end
	  
  else
   add(obj, 0)
  end
  
 end
 
end -- end roomfill()
-->8
-------------------------------
------ creeping darkness ------
-------------------------------
-- note: work in progress!!!!


-- globals for creepdark
-- start line for darkness
dark_line = 0

t = 0
crp_flip = false
spr_off = 0
function creepdark()
 -- var for 30 frames  
 t = (t+1) % 30
 -- flip sprite draw
 if(t == 0) then
  crp_flip = not crp_flip
  spr_off = flr(rnd(2))
  dark_line -= 5
 end
 for i=0, 16 do
  ch = i % 2
	 --palt(0, false)
	 -- draw creeping darkness
	 spr(32+(ch+spr_off),
	     (camx-64)+i*8,
	     (mapy*8)+dark_line-8,
	     1, 1, crp_flip)
	 spr(35+(ch+spr_off),
	     (camx-64)+i*8, 
	     (mapy*8)+dark_line,
	     1, 1, crp_flip)
	 for j=1, 8 do
	  spr(38+(ch+spr_off),
	     (camx-64)+i*8, 
	     (mapy*8)+dark_line+j*8,
	     1, 1, crp_flip)
	 end
	 for j=4, 8 do
	  spr(39+(ch+spr_off),
	     (camx-64)+i*8, 
	     (mapy*8)+dark_line+j*8,
	     1, 1, crp_flip)
	 end
	    
	 --palt()
	 -- possible option
	 --sspr(0+spr_off*8, 16, 8, 8,
	 --     -32, clmb, 128, 64,
	 --     crp_flip) 
 end
end
-->8
-------------------------------
-------- set enemies ----------
-------------------------------

-- globals for enemies
num_enm = 0

function set_enemies()

 -- matrix for enemies
 -- 	2d array where [i][1] = x
 -- 		and [i][2] = y
 enemies = {}
 num_enm = flr(rnd(5)) + 1
 
 for i = 1, num_enm do
  enemies[i] = {}

  for j = 1, 2 do
   enemies[i][j] = 0 -- fill the values here
  end
	end
	
 for i = 1, num_enm do
 	enemies[i][1] = flr(rnd(97))+16
 	enemies[i][2] = flr(rnd(86))+8
 
 --check boundaries between previous sprites
 	if i > 1 then
 		for a = 1, i-1 do
 			while abs(enemies[i][1] - enemies[a][1]) < 10 do
 				enemies[i][1] = flr(rnd(96))+16
 			end
 		
 			while abs(enemies[i][2] - enemies[a][2]) < 10 do
 				enemies[i][2] = flr(rnd(86))+8
 			end
 		end
 	end
 end
 
 --sets usr attempts array
 for i = 1, num_enm do
  usr_atmpts[i] = {}

  for j = 1, 2 do
   usr_atmpts[i][j] = 0 -- fill the values here
  end
	end
	attempts = num_enm
	
end
-->8
-------------------------------
----------- player ------------
-------------------------------

-- globals for player

-- player object
player = {}
player.move = false
player.pos={x=(mapx*8),
            y=(mapy*8)-25}
player.hitbox = {x=1,y=0,w=7,h=8}
player.speed= 1
player.anim = 54
player.fram = 1
player.flip = false

-- animate user
-- object, start frame,
-- num frames, speed, flip
function animp(m,o,sf,nf,sp,fl,a)
	
	-- if moving
	if(m == true) then
	
	 if(not o.a_ct) o.a_ct=0
	 if(not o.a_st)	o.a_st=0

	 o.a_ct+=1

	 if(o.a_ct%(60/sp)==0) then
	  o.a_st+=1
	  if(o.a_st==nf) o.a_st=0
	 end

	 o.a_fr=sf+o.a_st
	 pal(c11,c9)
	 spr(o.a_fr,o.pos.x,o.pos.y,1,1,fl)
 else
  spr(player.anim, 
      player.pos.x,
      player.pos.y,1,1,fl)
 end
 
end -- animp




-->8
-------------------------------
---------- collision ----------
-------------------------------

-- collision globals
ret_val = false

-- collision with creeping darkness
function consumed()
 if(player.pos.y > 
    (mapy*8)+dark_line) then
  scene = "end_idle"
 end
end

-- collision
function collide()
 to_right=mget(camx/8+0.5+0.8, camy/8+0.5)
 to_left=mget(camx/8+0.5-0.8, camy/8+0.5)
 to_top=mget(camx/8+0.5, camy/8+0.5-0.8)
 to_bot=mget(camx/8+0.5, camy/8+0.5+0.8)
 
 fl_right=fget(to_right,0)
 fl_left=fget(to_left,0)
 fl_top=fget(to_top,0)
 fl_bot=fget(to_bot,0)
 
end

function destroy()
 if(fget(to_right,1) or
    fget(to_left,1) or
    fget(to_top,1) or
    fget(to_bot,1)) then
  mset(camx/8+0.5+0.8,
       camy/8+0.5, 51)
  mset(camx/8+0.5-0.8,
       camy/8+0.5, 51)
  mset(camx/8+0.5,
       camy/8+0.5-0.8, 51)
  mset(camx/8+0.5,
       camy/8+0.5+0.8, 51)
               
  -- clear objects in room
  for i=1, #floor[room_max].o do 
   if(floor[room_max].o[i] == 48 or
      floor[room_max].o[i] == 49 or
      floor[room_max].o[i] == 50) then
    floor[room_max].o[i] = 0
    score += 10
   end
  end
  
  for i=1, #floor[room_max].r do 
   if(floor[room_max].r[i]==22) then
    floor[room_max].r[i] = 4
   end
   if(floor[room_max].r[i]==23) then
    floor[room_max].r[i] = 5
   end
   if(floor[room_max].r[i]==24) then
    floor[room_max].r[i] = 6
   end
   if(floor[room_max].r[i]==25) then
    floor[room_max].r[i] = 8
   end
   if(floor[room_max].r[i]==26) then
    floor[room_max].r[i] = 9
   end
   if(floor[room_max].r[i]==27) then
    floor[room_max].r[i] = 10
   end
   if(floor[room_max].r[i]==28) then
    floor[room_max].r[i] = 14
   end
   if(floor[room_max].r[i]==29) then
    floor[room_max].r[i] = 15
   end
  end
  
 end     
 
end
__gfx__
00000000007777777777777777777500700000500500000005000075777777777000005005000000050000755050050000500050000005057500000505005077
00000000075005000500050005000750700000000000000000000075066666607000000000000000000000755050050000500000005000055000000000000050
00000000750005000500050005000575700000000000000000000075060000607000000000000000000000755000000500000005005000055000000000000050
00000000750005000500050005000575700000000000000000000075060000607000000000000050000000755000500500005005000000055000000000000050
00000000750005000500050005000575700000000000000050000075060005607000000000000000500000755000500000005000000500055000005000000050
00000000750005000500050005000575700000000000005000000075060000607000000000000000000000755000500005005000000500055000000050000050
00000000750005000500050005000575570000500000000000000755060000607000000000000000000000750500000005000000500000505000000000000050
00000000755555555555555555555575507777777777777777777505566666657005000000005000000050750055555555555555555555005050000000050055
05000005050000006500000600000000777007770000000070000050050000000500007570000050050000000500007575000005050050770000000000000000
00000000000000506500000600655600006666000000000070000000000000000000007570000000000000000000007550000000000000500000000000000000
00000000000000006500000605666650006006000000000070000000000000000000007570000000000000000000007550000000000000500000000000000000
00000000000000006500000650600605006666000000000070000000000000000000007570000000000000500000007550000000000000500000000000000000
00000050000000006500000650666605006006000000000070000000000000005000007570000000000000005000007550000050000000500000000000000000
00000000000000006500000605600650006666000000000070000000000000500000007570000000000000000000007550000000500000500000000000000000
00000000000000006500000600555500006006000000000057000050000000000000075570000000000000000000007550000000000000500000000000000000
75005000000500776500000600000000556556550000000050777777777777777777750570050000000050000000507550500000000500550000000000000000
00100000000001000000000000000000000000000001000000010100011100000001110001111110000000000000000000000000000000000000000000000000
01001000001000100000000010000001000100000001000010110101101101011111000111110111000000000000000000000000000000000000000000000000
01000010000100100000001010001011100000100000001010101111111111111011101110111111000000000000000000000000000000000000000000000000
00000010000100010010000011101001101000011010000011101001111111111110111111111111000000000000000000000000000000000000000000000000
00000000000000000000000001001000000010011000100101001001011010111111100111111111000000000000000000000000000000000000000000000000
10000000000000100000000000011110010010011000001010011111111111111001111111011111000000000000000000000000000000000000000000000000
00000100000000000100000001010010010110100101001011010011111111101111111011111111000000000000000000000000000000000000000000000000
00000000100000000000000000000010010100100001010110110010101110100110111011101111000000000000000000000000000000000000000000000000
0000000000000000000000006000060000000000000000000055550000000000005555000000000000555500000000000000000000000cccc000000cccc00000
00666000066666000066600005060506006666000000000005ffff5000555500055555500055550005ffff500055550000000000000ccc70c700007c07ccc000
060006000600060006000600006000600600006000000000053f3f5005ffff500555555005555550053ff35005ffff5000cccc0000cc7700cc7007cc0077cc00
06666600066666000660660006600000066066600000000005fff55a053f3f5005a559500555555005ffff50053ff3500cc77cc000c700000c7007c000007c00
06000600060066000606060006006056060606000000000000555d1005fff51a015a951005a559500155551005ffff500c7007c000c700000cc77cc000007c00
060006000606060006000600005060600600060000000000001ddd1000555d1001d9ad10065aa51001d55d1001555570cc7007cc00cc770000cccc000077cc00
006660000666660006666600060606000666660000000000006222600002262006922a6000922a000622226000222200c700007c000ccc700000000007ccc000
000000000000000000000000600000500000000000000000000505000000550000500500000550000050050000055000c000000c00000ccc00000000ccc00000
0000000070000000000000007000000000000007777777777777777700000007777777770a00000000000000000080000000000000009000000000000000a000
0000000070000000000000007000000000000007000000077000000000000007000000000a0000000000000000088800888000000009990099900000000aaa00
0000000070000000000000007000000000000007000000077000000000000007000000000a0000000000000000088800088880000009990009999000000aaa00
0000000070000000000000007000000000000007000000077000000000000007000000000a000000000000000088888000888880009999900099999000aaaaa0
0000000070000000000000007000000000000007000000077000000000000007000000000a000000000000000088088000008888009909900000999900aa0aa0
0000000070000000000000007000000000000007000000077000000000000007000000000a00000000000000088808880088888009990999009999900aaa0aaa
0000000070000000000000007000000000000007000000077000000000000007000000000a00000000000000088000880888800009900099099990000aa000aa
0000000070000000777777777777777777777777000000077000000000000007000000000a000000aaaaaaaa080000088880000009000009999000000a00000a
000000000000b000000000000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaa00000000bbb00bbb00000000ccc00ccc000000077777008808800000000000000000000000000000000000000000000000000000000000000000000000000
0aaaa000000bbb000bbbb000000ccc000cccc0000700700788888880000000000000000000000000000000000000000000000000000000000000000000000000
00aaaaa000bbbbb000bbbbb000ccccc000ccccc00700700788888880000000000000000000000000000000000000000000000000000000000000000000000000
0000aaaa00bb0bb00000bbbb00cc0cc00000cccc0777777708888800000000000000000000000000000000000000000000000000000000000000000000000000
00aaaaa00bbb0bbb00bbbbb00ccc0ccc00ccccc00777077700888000000000000000000000000000000000000000000000000000000000000000000000000000
0aaaa0000bb000bb0bbbb0000cc000cc0cccc0000077777000080000000000000000000000000000000000000000000000000000000000000000000000000000
aaa000000b00000bbbb000000c00000cccc000000070707000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000bbbbbb00000bb0000b000000b00bbbbbbb00000000000bbbb000b000000b00bbbbbbb00bbbbb0000000000000000000000000000
00000000000000000000000bb22222b0000bb0000bb0000bb0bb2222220000000000b2222b00bb0000bb0bb2222220b22222b000000000000000000000000000
00000000000000000000000bb000002000bbbb000bbb00bbb0b2000000000000000bb0000bb02b0000b20b20000000b00000b000000000000000000000000000
00000000000000000000000b2000000000b22b000b22bb22b0bbbbbbb0000000000b200002b00bb00bb00bbbbbbb00b00000b000000000000000000000000000
00000000000000000000000b00bbbbb00bb00bb00b00bb00b0b2222220000000000b000000b002b00b200b22222200bbbbbb2000000000000000000000000000
00000000000000000000000b002222b00bbbbbb00b002200b0b0000000000000000bb0000bb000bbbb000b00000000b222b20000000000000000000000000000
00000000000000000000000bb0000bb0bb2222bb0b000000b0bb0000000000000002b0000b20002bb2000bb0000000b0002b0000000000000000000000000000
000000000000000000000002bbbbbb20b200002b0b000000b02bbbbbbb00000000002bbbb200000bb00002bbbbbbb0b00002b000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000a0a0aaa00aa0a0a00aa00aa00aa0aaa0aaa000000000aaa0aaa000000000000000000000000000000000000000
00000000000000000000000000000000000000a0a00a00a000a0a0a000a000a0a0a0a0a0000a000000a00000a000000000000000000000000000000000000000
00000000000000000000000000000000000000aaa00a00a000aaa0aaa0a000a0a0aa00aa0000000000aaa00aa000000000000000000000000000000000000000
00000000000000000000000000000000000000a0a00a00a0a0a0a000a0a000a0a0a0a0a0000a00000000a000a000000000000000000000000000000000000000
00000000000000000000000000000000000000a0a0aaa0aaa0a0a0aa000aa0aa00a0a0aaa000000000aaa0aaa000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000a0a00aa0a0a0aaa000000aa00aa00aa0aaa0aaa000000000a00000000000000000000000000000000000000000
00000000000000000000000000000000000000a0a0a0a0a0a0a0a00000a000a000a0a0a0a0a0000a000000a00000000000000000000000000000000000000000
00000000000000000000000000000000000000aaa0a0a0a0a0aa000000aaa0a000a0a0aa00aa0000000000aaa000000000000000000000000000000000000000
0000000000000000000000000000000000000000a0a0a0a0a0a0a0000000a0a000a0a0a0a0a0000a000000a0a000000000000000000000000000000000000000
00000000000000000000000000000000000000aaa0aa000aa0a0a00000aa000aa0aa00a0a0aaa000000000aaa000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000077707770777007700770000007777700000077700770000077707770777077707070000000000000000000000000000000
00000000000000000000000000000070707070700070007000000077070770000007007070000070707000070070707070000000000000000000000000000000
00000000000000000000000000000077707700770077707770000077707770000007007070000077007700070077007770000000000000000000000000000000
00000000000000000000000000000070007070700000700070000077070770000007007070000070707000070070700070000000000000000000000000000000
00000000000000000000000000000070007070777077007700000007777700000007007700000070707770070070707770000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000000000000777077700770077000000777770000007770077000007770777077707070777077000000777007700000777077707770700077700000000000
07000000000000707070007000700000007700077000000700707000007070700007007070707070700000070070700000070007000700700070000000000000
00700000000000770077007770777000007707077000000700707000007700770007007070770070700000070070700000070007000700700077000000000000
07000000000000707070000070007000007700077000000700707000007070700007007070707070700000070070700000070007000700700070000000000000
70000000000000707077707700770000000777770000000700770000007070777007000770707070700000070077000000070077700700777077700000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0101010100000005000000010101000000000000050003030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0049464848484848484848484848450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0049410000000000000000000000470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0049410000000000000000000000470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0049410000000000000000000000470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0049410000000000000000000000470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0049410000000000000000000000470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0049410000000000000000000000470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0049410000000000000000000000470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0049410000000000000000000000470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0049410000000000000000000000470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0049410000000000000000000000470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0049434242424242424242424242440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00004a4a4a4a4a4a4a4a4a4a4a4a4a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100003e6203e62037620376203a6203c6202762028620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040000020200102001020020200202002020030200302004020050200602007020090200b0200d0200f020110201402016020190201c0201e0202102025020280202b0202f02033020370203a0203d0203f020
010500000532004320043200432003320033200332003320033200332003320033200232002320013200132002320023200332003320043200432005320053200532006320083200c3200e3203a7203f7203a720
010a00210032000320003200032000320003200032000320003200032000320003200032000320003200032000320013200132001320013200132001320013200132000320003200032000320003200032000320
010200200cd200cd200cd200cd200cd200cd200cd200cd200cd200cd200bd200bd200bd200bd200bd200ad200ad200ad200ad2009d2009d2009d2009d2009d2009d2009d2009d2009d2009d2009d2009d2009d20
010d00002a30021720207201f7201d7201c720103001670011300260001c7201a7201972018720187201772017720177201b3001c3001c3001b3001472013720127201172011720127202b3002d3002e3002e300
0102002029b2027b2026b2023b2020b201db201ab2017b2015b2014b2013b2012b2011b2010b2010b2010b200fb200fb200fb200fb2010b2011b2012b2014b2016b2019b201cb2020b2025b202bb2031b2036b20
010800200272001720017200172001720017200172001720017200172001720017200172000720007200072000720007200372003720037200372003720037200372003720037200372003720037200372003720
0105000a01020010200202000020010200102000020000200002001020297002670024700227001f7001d7001b70019700187001470013700107000f7000d7000c7000a700097000870006700057000370001700
000500003e5203d5203c5203b520385203652032520305202d520285202652024520225201f5201d5201b5201a52019520185201752015520145201352011520105200f5200e5200e5200e520105201352015520
000500003e5203d5203c5203b520385203652032520305202d520285202652024520225201f5201d5201b5201a52019520185201752015520145201352011520105200f5200e5200e5200e520105201352015520
000a00210032000320003200032000320003200032000320003200032000320003200032000320003200032000320013200132001320013200132001320013200132000320003200032000320003200032000320
0002002029b2027b2026b2023b2020b201db201ab2017b2015b2014b2013b2012b2011b2010b2010b2010b200fb200fb200fb200fb2010b2011b2012b2014b2016b2019b201cb2020b2025b202bb2031b2036b20
000200200cd200cd200cd200cd200cd200cd200cd200cd200cd200cd200bd200bd200bd200bd200bd200ad200ad200ad200ad2009d2009d2009d2009d2009d2009d2009d2009d2009d2009d2009d2009d2009d20
000800200272001720017200172001720017200172001720017200172001720017200172000720007200072000720007200372003720037200372003720037200372003720037200372003720037200372003720
__music__
00 0b450445
00 0c450d46
00 0b450d44
00 0c420d44
00 0b420d44
02 0e424344
04 0e424344

