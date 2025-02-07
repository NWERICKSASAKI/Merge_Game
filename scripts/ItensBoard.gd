extends Node2D


var item_list = [] # objetos ( itens )
var selected_item_ID

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _get_item(tile_vector2:Vector2) -> Object:
	var a = tile_vector2[0]
	var b = tile_vector2[1]
	a = int(clamp(a, 0 , Global.TILES_X-1))
	b = int(clamp(b, 0 , Global.TILES_Y-1))
	return item_list[a][b]

func _update_item_list(obj1,obj2) -> void:
	var a_x = obj1.ID.x
	var a_y = obj1.ID.y
	var b_x = obj2.ID.x
	var b_y = obj2.ID.y
	item_list[a_x][a_y]=obj1
	item_list[b_x][b_y]=obj2
	return

func _select_item(item:Object):
	selected_item_ID = item.ID



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
