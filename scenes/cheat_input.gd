extends LineEdit

var item_manager

func _ready():
	visible = false # Replace with function body.

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if not visible:
			grab_focus()
			visible=true
		elif visible:
			_enter_on_cheat()


func _enter_on_cheat():
	var txt = text
	visible = false
	if txt:
		var word_list = text.to_lower().split(" ")
		match word_list[0]:
			"create":
				_cheat_create_item(word_list)
		text = ""
		grab_focus()

func _cheat_create_item(word_list):
	var g = int(word_list[1])
	var l = int(word_list[2])
	var b = bool(word_list[3])
	var empty_slot:Vector2 = item_manager._get_nearest_empty_tile(Vector2(0,0))
	var empty_item_slot = item_manager._get_item(empty_slot)
	empty_item_slot._set_item(g,l,b)
	print("CREATED A NEW ITEM ON", empty_slot, g,l,b)
