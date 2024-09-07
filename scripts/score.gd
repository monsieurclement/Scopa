extends PanelContainer

var nb_players
const MANCHE_1 = preload("res://scenes/manche_1.tscn")
var manche_array = [] #array qui contient toutes les manches
var active_manche:int = 0 #indice de la manche active
signal change_active_manche


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
		
	manche_array.append(new_manche)
	var manche = MANCHE_1.instantiate()
	manche.visible = false
	manche.manche_nb = new_manche
	manche.name = "manche"+str(new_manche)
	$Marges/Lignes.add_child(manche) #ajout de la nouvelle manche
	
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
			if j.name == "manche"+str(i) and i == active_manche+1:
				j.visible = true
			elif j.name == "manche"+str(i) and i != active_manche+1:
				j.visible = false
		
	

func _on_plis_button_pressed() -> void:
	new_round()
