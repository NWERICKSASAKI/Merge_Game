extends Node2D

var item_scene = preload("res://scenes/Item.tscn")  # Carrega a peça
onready var ItensBoard = $ItensBoard
onready var ColorGrid = $ColorGrid
var TILES_X = Global.TILES_X
var TILES_Y = Global.TILES_Y
var CELL_SIZE = Global.CELL_SIZE

func _ready():
	_create_grid()


func _create_grid():
	for x in range(TILES_X):
		ItensBoard.item_list.append([])
		for y in range(TILES_Y):
			ItensBoard.item_list[x].append([])
			var item = item_scene.instance()
			ItensBoard.add_child(item)
			item.position = Vector2(x * CELL_SIZE, y * CELL_SIZE)
			item.ID = Vector2(x,y)
			_generate_rand_itens(item,x,y)
			ItensBoard.item_list[x][y]=item
			_draw_cell_grid(x,y)


func _generate_rand_itens(item,x,y):
	#item.get_node("Sprite").visible = false
	#item.get_node("svg").visible = true
	#var r = randi() % 3 
	#item._set_item(r,r)
	if x==0 and y==0:
		item._set_item(1,0,true)
	else:
		item._set_item(0,0)

func _draw_cell_grid(x,y):
	var cell = ColorRect.new()
	cell.color = Color(0.2, 0.2, 0.2, 0.5 * ((x+y) % 2))
	cell.rect_min_size = Vector2(Global.CELL_SIZE, Global.CELL_SIZE)
	ColorGrid.add_child(cell)
	cell.rect_position = Vector2(x * Global.CELL_SIZE, y * Global.CELL_SIZE)
	cell.mouse_filter=Control.MOUSE_FILTER_IGNORE




# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
