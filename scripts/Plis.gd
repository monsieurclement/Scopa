extends HBoxContainer

func _process(_delta):
	if GeneralGame.players_plis[0].size() == 0 :
		$plein.visible = false
	else:
		$plein.visible = true
