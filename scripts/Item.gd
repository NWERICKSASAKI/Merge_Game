extends Area2D



var group = 0
var level = 1
var dragging = false
var ID # vector2
var tile_has_item = false
var selected = false
var generator = false
var max_level = false
onready var sprite = $Sprite
onready var CanMergeParticles = $CanMergeParticles
onready var MergingParticles = $MergingParticles
onready var svg = $svg
onready var Tween_node = $Tween_node
onready var get_parent = get_parent() 



func _ready():
	_set_item(0,0)
	CanMergeParticles.visible = true
	CanMergeParticles.emitting = false
	CanMergeParticles.one_shot = true
	MergingParticles.visible = true
	MergingParticles.emitting = false
	MergingParticles.one_shot = true
	svg.visible = false
	monitoring = true
	input_pickable = true
	#if (self.connect("input_event", self, "_input_event") != 0):
	#	print("failed to connect")
	set_process(false)


func _merge_with(target:Object):
	var old_ID = ID
	_move_to(target.ID)
	yield(get_tree().create_timer(0.20), "timeout") # sleep
	target.MergingParticles.emitting=true
	target._level_up()
	_empty_this_tile(old_ID)


func _level_up() -> void:
	level += 1
	_update_img()
	return


func _empty_this_tile(old_ID:Vector2=ID) -> void:
	_set_item(0,0)
	_move_to(old_ID)


func _swap_with(target) -> void:
	var targetID = target.ID
	var this_ID = ID
	if targetID != this_ID:
		_move_to(targetID)
		target._move_to(this_ID)
	else: #soltar na mesma posição
		_move_to(ID)
	get_parent()._update_item_list(self,target)
	return


func _sell():
	_empty_this_tile()
	pass


func _generate():
	pass


func _set_item(new_group:int, new_level:int, new_generator:bool=false) -> void:
	group = new_group
	level = new_level
	generator = new_generator
	
	var bool_group = new_group > 0
	tile_has_item = bool_group
	svg.visible = bool_group
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



func _unhandled_input(event):
	#print("event",event)
	pass


func _can_merge(target:Object) -> bool:
	if target.ID == ID:
		return false
	elif (target.group == group and target.level == level):
		return true
	else:
		return false


func _mousepos_to_ID(mouse_pos:Vector2) -> Vector2:
	var nx = int((mouse_pos.x)/Global.CELL_SIZE)
	var ny = int((mouse_pos.y)/Global.CELL_SIZE)
	return Vector2(nx,ny)


func _get_tile_global_position(tile_Vector2:Vector2)->Vector2:
	var nx = Global.CELL_SIZE * tile_Vector2.x
	var ny = Global.CELL_SIZE * tile_Vector2.y
	return Vector2(nx,ny)


func _move_to(tile_Vector2:Vector2) -> void:
	ID = tile_Vector2
	var new_global_position = _get_tile_global_position(tile_Vector2) - get_parent().position
	Tween_node.interpolate_property(self,"position",global_position, new_global_position, 0.15, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	Tween_node.start()

##################################################################

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			print("clicked")
			dragging = true
			set_process(true)
			
			# TODO - item pickado esteja sempre na frente de todos
		elif not event.pressed:
			dragging = false
	get_tree().set_input_as_handled()


func _process(delta):
	if tile_has_item:
		var mouse_pos = get_global_mouse_position()
		var g_positon = mouse_pos# - Vector2( Global.CELL_SIZE/2 , Global.CELL_SIZE/2 )
		var tile_above_index = _mousepos_to_ID(g_positon)
		var target = get_parent()._get_item(tile_above_index)
		if dragging:
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
