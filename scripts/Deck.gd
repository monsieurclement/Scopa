extends HBoxContainer


func _process(_delta):
	if GeneralGame.deck.size() == 0 :
		$plein.visible = false
	else:
		$plein.visible = true
