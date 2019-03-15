pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- tallest towers
-- by zakaria chowdhury

block_width = 60
block_height = 8
block_colors = {7,8}

speed_increment = .1
speed_decrement = .2
max_speed = 3
min_speed = 1.5
perfect_offset = 1
camera_y_threshold = 30
camera_shake_power = 4
camera_shake_speed = 0.8 -- less than 1

screen_width = 128
screen_height = 128	

function _init()
	init_game()
end

function _update()
	on_input()
	move_top_block()
	manage_camera()
end

function _draw()
	cls()
	draw_all_blocks()
	draw_score()
	draw_game_over_screen()
end

function init_game()
	blocks = {}
	move_direction = 1
	move_speed = min_speed
	is_game_over = false
	camera_y = 0
	camera_shake = 0
	
	move_camera()
	create_block()
	create_block(block_width, 0)
end

function restart_game()
	init_game()
end

function game_over()
	is_game_over = true
	sfx(2)
	shake_camera()
end

function manage_camera()
	if is_game_over then
		camera_slide_down()
	else
		camera_slide_up()
	end
	
	handle_camera_shake()
end

function move_camera()
	camera(0, camera_y)
end

function camera_slide_up()
	if blocks[#blocks].y - camera_y < camera_y_threshold then
		camera_y -= 1
		move_camera()
	end
end

function camera_slide_down()
	if camera_y < 0 then
		camera_y += 1
		move_camera()
	end
end

function shake_camera()
	camera_shake = 1
end
-->8
-- update blocks


function create_block(width, x, y)
	local number = #blocks + 1
	local col = block_colors[number % #block_colors + 1]
	
 if (width == nil) width = block_width
	
	if (x == nil) x = screen_width/2 - width/2
	if (y == nil) y = screen_height - block_height * number
	
	local block = {
		x = x,
		y = y, 
		width = width,
		col = col
	}
	
	add(blocks, block)
end

function move_top_block()
	if (is_game_over) return
	
	local block = blocks[#blocks]
		
	if block.x >= screen_width - block.width then
		move_direction = -1
		block.x = screen_width - block.width
	elseif block.x <= 0 then
		move_direction = 1
		block.x = 0
	end

	block.x += move_direction * move_speed
end

function drop_top_block()
	local width = trim_top_block()
	local x = 0
	
	if move_direction > 0 then
		x = screen_width - width
	end
	
	create_block(width, x)
end

function trim_top_block()
	local top_block = blocks[#blocks]
	local next_block = blocks[#blocks-1]
	local offset_position = top_block.x - next_block.x
	
	if offset_position < 0 then
		top_block.x = next_block.x
	end
	
	if offset_position != 0 then
		increase_move_speed()
	end
	
	if abs(offset_position) >= next_block.width then
		top_block.width = 0
		game_over()
		return 0
	else
		top_block.width -= abs(offset_position)
	end
	
	if abs(top_block.width -  next_block.width) <= perfect_offset then
		top_block.width = next_block.width
		top_block.x = next_block.x
		sfx(1)
		decrease_move_speed()
	end
	
	return top_block.width
end

function increase_move_speed()
	move_speed += speed_increment
	
	if (move_speed > max_speed) move_speed = max_speed
end

function decrease_move_speed()
	move_speed -= speed_decrement
	
	if (move_speed < min_speed) move_speed = min_speed
end
-->8
-- draw blocks

function draw_single_block(block)
	if (block.width == 0) return 
	
	local x0 = block.x
	local y0 = block.y
	local x1 = x0+block.width
	local y1 = y0+block_height-1
	local col = block.col
	
	rectfill(x0, y0, x1, y1, col)
end

function draw_all_blocks()
	for i, block in pairs(blocks) do
		draw_single_block(block)
	end
end
-->8
-- inputs

function on_input()
	game_running_input()
	game_over_input()
end

function game_running_input()
	if (is_game_over) return
	
	if btnp(❎) then
		drop_top_block()
		sfx(0)
	elseif btnp(🅾️) then
		restart_game()
	end
end

function game_over_input()
	if (not is_game_over) return
	
	if btnp(🅾️) then
		restart_game()
	end
end
-->8
-- hud

function draw_score()
	local score = tostr(#blocks-2)
	print_center(score, 8, 2)
end

function draw_game_over_screen()
	if (not is_game_over) return
	
	print_center("game over", 10, screen_height/2 - 6)
end
-->8
-- utility

function print_center(text, col, y)
	if y == nil then
		y = screen_height/2 - 8
	end

	print(text, screen_width/2-#text*2, y + camera_y, col)
end
-->8
-- effects

function handle_camera_shake()
	if (camera_shake <= 0) return
	
	local shakex=camera_shake_power-rnd(camera_shake_power*2)
 local shakey=camera_shake_power-rnd(camera_shake_power*2)
 
 shakex=shakex*camera_shake
 shakey=camera_y+shakey*camera_shake
 
 camera(shakex,shakey)
 
 camera_shake*=camera_shake_speed
 if camera_shake<0.05 then
  camera_shake=0
 end
end
__gfx__
0000000088888888ffffffffcccccccccccccccc55555555cccccccccccaaccc3333333355555555000000000000000000000000000000000000000000000000
0000000088888888ffffffffcc3333cccccccccc55555555cccccccccaaaaaac3333333355555555000000000000000000000000000000000000000000000000
007007008ff88ff8f77ff77fc333333ccccccccc55555555cccccccccaaaaaac3333333355555555000000000000000000000000000000000000000000000000
000770008ff88ff8f77ff77f33633363cccccccc55555555cccc777caaaaaaaa3333333377777777000000000000000000000000000000000000000000000000
000770008ff88ff8f77ff77f36333633cccccccc55555555cc776677aaaaaaaa3333333377777777000000000000000000000000000000000000000000000000
007007008ff88ff8f77ff77fc333333ccccccccc55555555c776677ccaaaaaac3333333355555555000000000000000000000000000000000000000000000000
0000000088888888ffffffffccc44ccccccccccc55555555cc7777cccaaaaaac3333333355555555000000000000000000000000000000000000000000000000
0000000088888888ffffffffccc44ccccccccccc55555555cccccccccccaaccc3333333355555555000000000000000000000000000000000000000000000000
__map__
0404040404040404040404040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0406040407040101010104040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0604040404040101010104040606040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404040101010104040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404040101010104040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404040101010104040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040402020101010102020404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0403030302020101010102020303040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0509090505090905050909050509090500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0808080808080808080808080808080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0808080808080808080808080808080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0808080808080808080808080808080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0102000013730117301073011730137301573017730170002f00025000220001e00024000190001500011000100000d0000a00005000040000000000000000000000000000000000000000000000000000000000
010800001a055180551c0551d055210551f055230552405523000140002100020000160001600017000170001700017000180000000019000000001b000110001e0001d0001d0001f0001e000200001e00021000
011000001855117551155511355111551105510e5510c5510c5000c5000c5000c5001870018700187001800018100182001830018500184001850018500000000000000000000000000000000000000000000000
