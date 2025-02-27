extends Area2D

const MIN_DIST_TO_DRAG = 20

var group = 0
var level = 1
var mouse_down_on_item = false
var ID # vector2
var tile_has_item = false
var generator = false
var which_itens_can_generate = []
var max_level = false
var mouse_pos_when_was_pressed
var has_been_dragged = false
var item_manager # atribuido ao ser criado em MainBoard
var itens_config # atribuido ao ser criado em MainBoard
var on_animation = false

onready var GeneratorParticles = $GeneratorParticles
onready var CanMergeParticles = $CanMergeParticles
onready var MergingParticles = $MergingParticles
onready var svg = $svg
onready var Tween_node = $Tween_node
onready var Get_parent = get_parent()


func _ready():
	#_set_item(0,0)
	Tween_node.connect("tween_completed", self, "_on_tween_completed")
	CanMergeParticles.visible = true
	CanMergeParticles.emitting = false
	CanMergeParticles.one_shot = true
	MergingParticles.visible = true
	MergingParticles.emitting = false
	MergingParticles.one_shot = true
	svg.visible = false
	monitoring = true
	input_pickable = true
	set_process(false)

func _on_tween_completed(A,B):
	on_animation = false

func _level_up() -> void:
	on_animation  = true
	level += 1
	_created_item_animation()
	_update_img()
	return

func _empty_this_tile(old_ID:Vector2=ID) -> void:
	_move_to(old_ID) # 1) move_to
	_set_item(0,0) # 2) set_item


func _swap_with(target) -> void:
	var targetID = target.ID
	var this_ID = ID
	if targetID != this_ID:
		_move_to(targetID)
		target._move_to(this_ID)
		item_manager._update_item_list(self,target)
		item_manager._update_itens_in_empty_list_after_swap(self,target)
	else: #soltar na mesma posição
		_move_to(ID)
	return


func _sell():
	_empty_this_tile()
	pass


func _generate():
	if item_manager.empty_itens_list: # se houver um espaço vazio disponivel
		var item = item_manager._get_nearest_empty_item(ID)

		var rand_i = randi() % which_itens_can_generate.size()
		var rand_item = which_itens_can_generate[rand_i]
		var rand_item_g = int(rand_item[0])
		var rand_item_l = int(rand_item[1])
		item._set_item(rand_item_g,rand_item_l)

		var final_pos = _ID_to_pos(ID)
		item._created_item_animation(item.ID,final_pos)
	else:
		print("SEM ESPAÇO DISPONÍVEL")


func _set_item(new_group:int, new_level:int) -> void:
	group = new_group
	level = new_level
	_update_which_itens_can_generate(group,level)
	
	var b  = new_group > 0 # true se tem grupo
	tile_has_item = b
	svg.visible = b
	if b: # item novo / atualização
		if item_manager.empty_itens_list.find(ID) != -1:
			item_manager.empty_itens_list.erase(ID)
	else: # for item vazio
		item_manager.empty_itens_list.append(ID)
	_update_img()



func _update_img():
	var g = str(group).pad_zeros(2)
	var l = str(level).pad_zeros(2)
	var path = "res://assets/itens/" + g + "/" + l + ".svg" 
	var dir = Directory.new()
	modulate = Color(1,1,1,1)
	scale = Vector2(1,1)
	if dir.file_exists(path):
		svg.texture = load(path)
		return true
	else:
		svg.visible = false
		return false


func _can_merge(target:Object) -> bool:
	if target.ID == ID: # caso soltar o item em sua posição original
		return false
	elif (target.group == group and target.level == level):
		return true
	else:
		return false


func _merge_with(target:Object):
	var old_ID = ID
	_move_and_merge_to(target.ID)
	yield(get_tree().create_timer(0.20), "timeout") # sleep
	target.MergingParticles.emitting=true
	target._level_up()
	_empty_this_tile(old_ID)


func _mousepos_to_ID(mouse_pos:Vector2) -> Vector2:
	var v = (mouse_pos - Global.margins_board)/Global.CELL_SIZE
	var rounded_v = Vector2( round(v.x) , round(v.y) )
	return rounded_v

func _ID_to_pos(tile_Vector2:Vector2)->Vector2:
	return Global.CELL_SIZE * tile_Vector2 + Global.CELL_OFFSET

func _move_to(to_ID:Vector2, from_this_pos=0) -> void:
	on_animation = true
	if from_this_pos is int:
		from_this_pos = position#global_position - Global.margins_board
	ID = to_ID
	var new_global_position = _ID_to_pos(to_ID) 
	Tween_node.interpolate_property(self,"position",from_this_pos, new_global_position, 0.15, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	Tween_node.start()

func _move_and_merge_to(to_ID:Vector2) -> void:
	on_animation = true
	var from_this_pos = position#global_position - Global.margins_board
	ID = to_ID
	var new_global_position = _ID_to_pos(to_ID)
	Tween_node.interpolate_property(self,"position",from_this_pos, new_global_position, 0.2, Tween.TRANS_QUAD, Tween.EASE_IN)
	Tween_node.interpolate_property(self,"scale",Vector2(1,1),Vector2(0,0), 0.2, Tween.TRANS_QUAD, Tween.EASE_IN)
	Tween_node.interpolate_property(self,"modulate",Color(1,1,1,1),Color(1,1,1,0), 0.2, Tween.TRANS_QUAD, Tween.EASE_IN)
	Tween_node.start()

func _created_item_animation(to_ID:Vector2=ID, from_this_pos=0):
	Tween_node.stop_all()
	if from_this_pos is int: #  se nao definido uma posicao inicial
		from_this_pos = position#global_position - Global.margins_board # sua posição atual
	var final_global_position = _ID_to_pos(to_ID)
	if final_global_position == from_this_pos: # se pos inicial = pos final
		pass
	else:
		on_animation = true
		Tween_node.interpolate_property(self,"position",from_this_pos, final_global_position, 0.2, Tween.TRANS_QUAD, Tween.EASE_IN)
		ID = to_ID
	var S = 1.5
	var MAX_SIZE = Vector2(S,S)
	Tween_node.interpolate_property(self, "modulate", Color(1,1,1,0.3), Color(1,1,1,1), 0.2, Tween.TRANS_QUAD, Tween.EASE_IN)  # Aumenta para 2 em 0.5s
	Tween_node.interpolate_property(self, "scale", MAX_SIZE, Vector2(1, 1), 0.2, Tween.TRANS_QUAD, Tween.EASE_IN)  # Retorna para 1 em 0.5s
	Tween_node.start()
	return

func _update_which_itens_can_generate(new_group , new_level):
	if new_group == 0:
		which_itens_can_generate = []
		generator = false
	else:
		var can_generate_list = []
		var string_of_itens = itens_config[new_group][new_level]
		if not string_of_itens.empty():
			string_of_itens = string_of_itens.split('-')
			for itens in string_of_itens:
				can_generate_list.append(itens.split('.'))
			generator = true
		else:
			generator = false
		which_itens_can_generate = can_generate_list
	GeneratorParticles.visible = generator
	return


##################################################################

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and not on_animation:
		if event.pressed:
			if !mouse_down_on_item:
				mouse_pos_when_was_pressed = Get_parent.to_local(get_global_mouse_position())
			item_manager.selected_item_ID = ID
			z_index = 1
			mouse_down_on_item = true
			set_process(true)
			
			# TODO - item pickado esteja sempre na frente de todos
		elif not event.pressed:
			z_index = 0
			has_been_dragged = false
			mouse_down_on_item = false
			if item_manager.selected_item_ID == ID:
				if position == _ID_to_pos(ID):
					if generator:
						_generate()
	get_tree().set_input_as_handled()


func _process(delta):
#	if not on_animation:
	if tile_has_item:
		var mouse_pos = Get_parent.to_local(get_global_mouse_position())
		var tile_above_index = _mousepos_to_ID(mouse_pos)
		var target = item_manager._get_item(tile_above_index)
		if mouse_down_on_item:
			if has_been_dragged == false:
				if mouse_pos.distance_to(mouse_pos_when_was_pressed) >= MIN_DIST_TO_DRAG:
					has_been_dragged = true
			else:
				position = mouse_pos
				if target:
					if _can_merge(target):
						target.CanMergeParticles.emitting = true
		else:
			set_process(false)
			if _can_merge(target):
				_merge_with(target)
			else:
				_swap_with(target)

