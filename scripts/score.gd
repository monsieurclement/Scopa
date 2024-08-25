extends PanelContainer

var nb_players = 0


func _on_close_score_button_pressed() -> void:
	self.visible = false




func _on_ready() -> void:
	await get_tree().create_timer(GeneralGame.timer).timeout
	nb_players = GeneralGame.nb_players
	
	if nb_players < 4:
		%Player4.visible = false
		%VSeparator4.visible = false
	if nb_players < 3:
		%Player3.visible = false
		%VSeparator3.visible = false
