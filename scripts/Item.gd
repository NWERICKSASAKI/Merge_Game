extends Area2D

const MIN_DIST_TO_DRAG = 30

var group = 0
var level = 1
var dragging = false
var ID # vector2
var tile_has_item = false
var selected = false
var generator = false
var max_level = false
var mouse_pos_when_was_pressed
var has_been_dragged = false
var item_manager # atribuido ao ser criado em MainBoard

onready var sprite = $Sprite
onready var CanMergeParticles = $CanMergeParticles
onready var MergingParticles = $MergingParticles
onready var svg = $svg
onready var Tween_node = $Tween_node

func _ready():
	#_set_item(0,0)
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



func _level_up() -> void:
	level += 1
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
	if item_manager.empty_itens_list:
		var empty_ID = item_manager._get_nearest_empty_tile(ID)
		var x = empty_ID[0]
		var y = empty_ID[1]
		var item = item_manager.item_list[x][y]
		var final_pos = _ID_to_global_position(ID)
		item._set_item(group,0,false)
		item._move_to(item.ID,final_pos)
	else:
		print("SEM ESPAÇO DISPONÍVEL")


func _set_item(new_group:int, new_level:int, new_generator:bool=false) -> void:
	group = new_group
	level = new_level
	generator = new_generator
	
	var b  = new_group > 0 # true se tem grupo
	tile_has_item = b
	svg.visible = b
	if b: # item novo / atualização
		if item_manager.empty_itens_list.find(ID) != -1:
			item_manager.empty_itens_list.erase(ID)
		else:
			print('espaço vazio nao encontrado',ID,item_manager.empty_itens_list)
	else: # for item vazio
		item_manager.empty_itens_list.append(ID)
	#sprite.visible = true
	_update_img()



func _update_img():
	var g = str(group).pad_zeros(2)
	var l = str(level).pad_zeros(2)
	var t = "g" if generator else "s"
	var path = "res://assets/itens/"+g+"/"+g+t+l+".svg" 
	var dir = Directory.new()
	if dir.file_exists(path):
		svg.texture = load(path)
		return true
	else:
		svg.visible = false
		return false


func _can_merge(target:Object) -> bool:
	if target.ID == ID:
		return false
	elif (target.group == group and target.level == level and target.generator == generator):
		return true
	else:
		return false


func _merge_with(target:Object):
	var old_ID = ID
	_move_to(target.ID)
	yield(get_tree().create_timer(0.20), "timeout") # sleep
	target.MergingParticles.emitting=true
	target._level_up()
	_empty_this_tile(old_ID)


func _mousepos_to_ID(mouse_pos:Vector2) -> Vector2:
	var nx = int((mouse_pos.x)/Global.CELL_SIZE)
	var ny = int((mouse_pos.y)/Global.CELL_SIZE)
	return Vector2(nx,ny)


func _ID_to_global_position(tile_Vector2:Vector2)->Vector2:
	var nx = Global.CELL_SIZE * tile_Vector2.x
	var ny = Global.CELL_SIZE * tile_Vector2.y
	return Vector2(nx,ny)


func _move_to(to_ID:Vector2, from_this_pos:Vector2=global_position) -> void:
	ID = to_ID
	var new_global_position = _ID_to_global_position(to_ID) - get_parent().position
	Tween_node.interpolate_property(self,"position",from_this_pos, new_global_position, 0.15, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	Tween_node.start()

##################################################################

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			if !dragging:
				mouse_pos_when_was_pressed = get_global_mouse_position()
			item_manager.selected_item_ID = ID
			dragging = true
			set_process(true)
			var selected = item_manager.selected_item_ID

			
			# TODO - item pickado esteja sempre na frente de todos
		elif not event.pressed and item_manager.selected_item_ID == ID:
			has_been_dragged = false
			dragging = false
			if global_position == _ID_to_global_position(ID):
				if generator:
					_generate()
	get_tree().set_input_as_handled()


func _process(delta):
	if tile_has_item:
		var mouse_pos = get_global_mouse_position()
		var g_positon = mouse_pos# - Vector2( Global.CELL_SIZE/2 , Global.CELL_SIZE/2 )
		var tile_above_index = _mousepos_to_ID(g_positon)
		var target = item_manager._get_item(tile_above_index)
		if dragging:
			if has_been_dragged == false:
				if get_global_mouse_position().distance_to(mouse_pos_when_was_pressed) >= MIN_DIST_TO_DRAG:
					has_been_dragged = true
			else:
				global_position = g_positon - Vector2( Global.CELL_SIZE/2 , Global.CELL_SIZE/2 )
				if target:
					if _can_merge(target):
						target.CanMergeParticles.emitting = true
		else:
			set_process(false)
			if _can_merge(target):
				_merge_with(target)
			else:
				_swap_with(target)
#	pass
