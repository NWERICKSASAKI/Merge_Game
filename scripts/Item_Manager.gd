extends Reference
class_name Item_Manager

var item_list = [] # objetos ( itens )
var selected_item_ID
var empty_itens_list = []

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

func _update_itens_in_empty_list_after_swap(obj1,obj2):
	if obj1.tile_has_item==false or obj2.tile_has_item==false: # swap with empty tile
		var ID1 = obj1.ID # had the item - now is empty
		var ID2 = obj2.ID # have the item
		# registering the empty tile
		empty_itens_list.erase(ID1)
		print('empty_itens_list.erase(ID2)',ID1)
		# registering the item tile
		empty_itens_list.append(ID2)
		print('empty_itens_list.append',ID2)
		return

func _get_nearest_empty_tile(ID:Vector2) -> Vector2:
	var nearest_ID:Vector2
	var nearest_dist = 99
	for itens in empty_itens_list:
		var new_dist = ID.distance_to(itens)
		if new_dist < nearest_dist:
			nearest_ID = itens
			nearest_dist = new_dist
	return nearest_ID


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
