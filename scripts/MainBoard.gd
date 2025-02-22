extends Node2D

var item_scene = preload("res://scenes/Item.tscn")  # Carrega a peça
var itens_config = []
var TILES_X = Global.TILES_X
var TILES_Y = Global.TILES_Y
var CELL_SIZE = Global.CELL_SIZE

onready var ItensBoard = $ItensBoard
onready var ColorGrid = $ItensBoard/ColorGrid
onready var item_manager = Item_Manager.new()
onready var player_manager = Player_Manager.new()

func _ready():
	itens_config = load_itens_config_in_csv()
	_create_grid()

	$ItensBoard.position.x = Global.left_margin_board
	$ItensBoard.position.y = Global.upper_margin_board
	$cheat_input.item_manager = item_manager

func _create_grid():
	for x in range(TILES_X):
		item_manager.item_list.append([])
		for y in range(TILES_Y):
			item_manager.item_list[x].append([])
			var item = item_scene.instance()
			_place_itens_in_grid(item,x,y)
			_load_itens_in_board(item,x,y)
			_draw_cell_grid(x,y)


func _place_itens_in_grid(item,x,y):
	ItensBoard.add_child(item)
	item.position = Vector2(x * CELL_SIZE , y * CELL_SIZE ) # + Vector2(CELL_SIZE / 2,+ CELL_SIZE / 2)
	item.ID = Vector2(x,y)
	item.item_manager = item_manager
	item.itens_config = itens_config
	item_manager.item_list[x][y]=item


func _load_itens_in_board(item,x,y):
	#item.get_node("Sprite").visible = false
	#item.get_node("svg").visible = true
	#var r = randi() % 3 
	#item._set_item(r,r)
	if x==0 and y==0:
		item._set_item(1,1)
	else:
		item._set_item(0,0)

func _draw_cell_grid(x,y):
	var cell = ColorRect.new()
	cell.color = Color(0.2, 0.2, 0.2, 0.5 * ((x+y) % 2))
	cell.rect_min_size = Vector2(Global.CELL_SIZE, Global.CELL_SIZE)
	ColorGrid.add_child(cell)
	cell.rect_position = Vector2(x * Global.CELL_SIZE, y * Global.CELL_SIZE)
	cell.mouse_filter=Control.MOUSE_FILTER_IGNORE


func load_itens_config_in_csv():
	var file_path = "res://ItensConfig.csv"
	var file = File.new()
	if file.open(file_path, File.READ) != OK:
		print("Erro ao abrir o arquivo CSV")
		return []
	var data = []
	while not file.eof_reached():
		var line = file.get_line()
		if line.empty():
			continue
		data.append(line.split(","))  # Divide cada linha pelos separadores de vírgula
	file.close()
	return data


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
