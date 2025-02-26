extends Node
# RESOLUTION 720 X 1280 
const TILES_X = 7
const TILES_Y = 9
const RESOLUTION = Vector2(720,1280)
const CELL_SIZE = 70 # pixels
onready var CELL_OFFSET = Vector2(CELL_SIZE,CELL_SIZE)/2
onready var left_margin_board = ( RESOLUTION[0] - TILES_X * CELL_SIZE ) / 2
onready var upper_margin_board = ( RESOLUTION[1] - TILES_X * CELL_SIZE ) / 1.5
onready var margins_board = Vector2( left_margin_board , upper_margin_board )
# BOARD
# X : 70 x 7 = 490
# dX : 720 - 490 = 280
# Y : 70 x 9 = 630

func _ready():
	print(left_margin_board)
