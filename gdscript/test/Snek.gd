extends Node

var snek_dir = Vector2(-1, 0)
var updated_dir = Vector2(-1, 0)
var snek_body
var meats = []
var time_count = 0
var eat_meat = []
var snek_lif = true
var hiss_time = 0
var hisssss = [0, 1]
var show_hiss = false

var map = TileMap.new()

func _ready():
	get_tree().set_screen_stretch(
		get_tree().STRETCH_MODE_VIEWPORT,
		get_tree().STRETCH_ASPECT_KEEP,
		Vector2(64, 64)
	)
	VisualServer.set_default_clear_color(Color(0.677186, 0.851563, 0.44574))
	OS.window_size = Vector2(64, 64)*3
	OS.center_window()
	call_deferred('sssstart')

func sssstart():
	map.cell_size = Vector2(2, 2)
	add_child(map)
	map.tile_set = create_tile_ssset()
	snek_body = [map.world_to_map(Vector2(32, 32))]
	map.clear()
	spawn_meat()
	for i in range(5):
		snek_body.append(snek_body[0]-snek_dir*(i+1))
	update_snek_body()

func create_tile_ssset():
	var shit = TileSet.new()
	var tex = create_texxxture()
	
	# hiss0
	shit.create_tile(0)
	shit.tile_set_texture(0, tex)
	shit.tile_set_region(0, Rect2( 0, 0, 2, 2 ))
	# hiss1
	shit.create_tile(1)
	shit.tile_set_texture(1, tex)
	shit.tile_set_region(1, Rect2( 2, 0, 2, 2 ))
	# snek
	shit.create_tile(2)
	shit.tile_set_texture(2, tex)
	shit.tile_set_region(2, Rect2( 4, 0, 2, 2 ))
	# met
	shit.create_tile(3)
	shit.tile_set_texture(3, tex)
	shit.tile_set_region(3, Rect2( 6, 0, 2, 2 ))
	return shit

func create_texxxture():
	var img = Image.new()
	img.create(8, 2, false, Image.FORMAT_RGBA8)
	var colors = [
		Color(), Color(1,1,1), Color(0,0,0,0),
		Color('#fffa63'), Color('#0f200f'),
		Color('#914348'), Color('#ff636c')
	]
	var data = [
		[0,2,2,0,3,4,5,1],
		[2,0,0,2,4,3,6,5]
	]
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			img.lock()
			img.set_pixel(x, y, colors[data[y][x]])
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	return tex

func _process(delta):
	if snek_lif:
		time_count += delta
		if time_count >= 0.1:
			time_count = 0
			if updated_dir != snek_dir:
				snek_dir = updated_dir
			move_snek()
		
		hiss_time += delta
		if hiss_time >= 1 and not show_hiss:
			show_hiss = true
			hiss_time = 0
		
		if show_hiss and hiss_time >= 0.15:
			hiss_time = 0
			if hisssss[0] == 1:
				show_hiss = false
			hisssss.invert()

func _input(event):
	var next_dir
	if event.is_action_pressed('ui_left'):
		next_dir = Vector2(-1, 0)
	elif event.is_action_pressed('ui_right'):
		next_dir = Vector2(1, 0)
	elif event.is_action_pressed('ui_up'):
		next_dir = Vector2(0, -1)
	elif event.is_action_pressed('ui_down'):
		next_dir = Vector2(0, 1)
	if next_dir != null:
		if next_dir != snek_dir*-1:
			updated_dir = next_dir

func move_snek():
	snek_body.push_front(snek_body[0]+snek_dir)
	snek_body.pop_back()
	for m in eat_meat:
		if m == snek_body.back():
			eat_meat.remove(eat_meat.find(m))
			snek_body.append(snek_body[-1]+snek_dir)
			
	if snek_body.count(snek_body[0]) > 1:
		print('dead')
		snek_lif = false
	if snek_body[0].x < 0 or snek_body[0].x >= 64/2:
		snek_lif = false
	if snek_body[0].y < 0 or snek_body[0].y >= 64/2:
		snek_lif = false
	if snek_body[0] in meats:
		meats.remove(meats.find(snek_body[0]))
		eat_meat.append(snek_body[0])
		spawn_meat()
	update_snek_body()

func update_snek_body():
	map.clear()
	for p in snek_body:
		map.set_cellv(p, 2)
	for e in eat_meat:
		map.set_cellv(e, 2, true)
	if show_hiss:
		map.set_cellv(snek_body[0]+snek_dir, hisssss[0])
	for m in meats:
		map.set_cellv(m, 3)

func spawn_meat():
	var m = map.world_to_map(Vector2(64, 64))
	var pos = snek_body[0]
	while pos in snek_body:
		pos = Vector2(rand_range(0, int(m.x)), rand_range(0, int(m.y))).floor()
	meats.append(pos)

