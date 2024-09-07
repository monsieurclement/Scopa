extends MarginContainer
var nb_players
var manche_nb: int
var on:bool = true

func _on_ready() -> void:
	pass

#func _process(_delta: float) -> void:
	#if manche_nb == get_node("../../..").active_manche+1:
		#self.visible = true
	#else:
		#self.visible = false

func _on_visibility_changed() -> void:
	nb_players = GeneralGame.nb_players
	
	if nb_players < 4:
		%Player4.visible = false
		%VSeparator4.visible = false
	if nb_players < 3:
		%Player3.visible = false
		%VSeparator3.visible = false
