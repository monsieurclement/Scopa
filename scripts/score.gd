extends PanelContainer

var nb_players
const MANCHE_1 = preload("res://scenes/manche_1.tscn")
const PLIS = preload("res://scenes/plis.tscn")

var end_of_manche:bool = false
var end_of_game:bool = false
var manche_array = [] #array qui contient toutes les manches
var active_manche:int = 0 #indice de la manche active
signal change_active_manche
signal next_manche

func _on_close_score_button_pressed() -> void:
	self.visible = false #fermer la fenêtre


	
func _on_ready() -> void:
	#await get_tree().create_timer(0.05).timeout
	
	new_round()

func new_round() -> void: #création d'une manche
	var new_manche
	if manche_array.is_empty():
		new_manche = 1
	else:
		new_manche = manche_array[-1] + 1
		
	manche_array.append(new_manche) #changer les arrays
	
	var manche = MANCHE_1.instantiate() #ajout de la feuille de pts
	manche.visible = false
	manche.manche_nb = new_manche
	manche.name = "manche"+str(new_manche)
	$Marges/Lignes.add_child(manche) #ajout de la nouvelle manche
	$Marges/Lignes.move_child($Marges/Lignes.get_node("manche"+str(new_manche)),-3) #mise en place pour pas bouger le bouton
	
	var plis = PLIS.instantiate() #ajout des plis
	plis.visible = false
	plis.name = "plis"+str(new_manche)
	$Marges/Lignes.add_child(plis) #ajout de la nouvelle manche
	$Marges/Lignes.move_child($Marges/Lignes.get_node("plis"+str(new_manche)),-3) #mise en place pour pas bouger le bouton
	
	
	change_active_manche.emit()


func _on_right_button_pressed() -> void:#manche suivante
	active_manche = (active_manche + 1) % manche_array.size() #cycle dans l'array
	change_active_manche.emit()

func _on_left_button_pressed() -> void: #manche suivante
	active_manche = (active_manche - 1) % manche_array.size()#cycle dans l'array
	if active_manche == -1: #fix le bug de désaffichage au passage du cycle précédent
		active_manche = manche_array.size()-1
	
	change_active_manche.emit()


func _on_change_active_manche() -> void:
	%RoundNb.text = "MANCHE " + str(manche_array[active_manche]) #check que le nb de la manche affichée est le bon
	
	for j in $"Marges/Lignes".get_children(): #on garde visible que la bonne manche
		for i in manche_array: 
			if %PlisButton.state == false:
				if j.name == "manche"+str(i) and i == active_manche+1:
					j.visible = true
				elif j.name == "manche"+str(i) and i != active_manche+1:
					j.visible = false
				elif j.name == "plis"+str(i):
					j.visible = false
			else:
				if j.name == "plis"+str(i) and i == active_manche+1:
					j.visible = true
				elif j.name == "plis"+str(i) and i != active_manche+1:
					j.visible = false
				elif j.name == "manche"+str(i):
					j.visible = false
		
	

func _on_plis_button_pressed() -> void:
	%PlisButton.change_state() #état plis ou score
	if %PlisButton.state == false: #si score
		for j in $"Marges/Lignes".get_children(): #on rend invisibles les plis
			for i in manche_array: 
				if j.name == "plis"+str(i):
					j.visible = false
				if j.name == "manche"+str(i) and i == active_manche+1:#rend visible le pli en cours
					j.visible = true
	else: #si plis
		for j in $"Marges/Lignes".get_children(): #on rend invisibles les points
			for i in manche_array: 
				if j.name == "manche"+str(i):
					j.visible = false
				if j.name == "plis"+str(i) and i == active_manche+1: #rend visible le pli en cours
					j.visible = true
		

func _on_next_round_button_pressed() -> void:
	%NextRoundButton.visible = false
	$CloseScoreButton.visible = true
	self.visible = false
	next_manche.emit()

func _on_next_manche() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_again_button_pressed() -> void:
	$".".get_parent().get_parent().get_parent().first_round = true
	$".".get_parent().get_parent().get_parent().reset_game()
	GeneralGame.score_to_actualize = [[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0]]
	$".".get_parent().get_node("EndConfetti").emitting = false
	
	
	%NextRoundButton.visible = false
	$CloseScoreButton.visible = true
	$Marges/Lignes/EndingButtons.visible = false
	self.visible = false
	
