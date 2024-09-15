extends AspectRatioContainer

const CARTE_PLIS = preload("res://scenes/carte_plis.tscn")

#func _ready() -> void:
	#actualize_plis([[1,2,3,4],[21,22,23],[39],[27,1,3]])
	


func actualize_plis(array): #ajout des plis au tableau des plis
	for i in range(4):
		for j in array[i].size():
			var new_card = CARTE_PLIS.instantiate()
			new_card.setup(array[i][j])
			
			get_node("VBox/Player"+str(i+1)).add_child(new_card)
	
	
