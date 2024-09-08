extends MarginContainer
var nb_players
var manche_nb: int
var plis
#var on:bool = true

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

func actualize_points(array):
	var categories = ["Scopas","NbCards","NbDeniers","7d","PrimieraScore","Primiera","RoundScore","GameScore"]
	for i in [1,2,3,4]: #pour chaque joueur
		for j in range(8):#pour chaque item
			$Colonnes.get_node("Player"+str(i)).get_node(categories[j]).text = str(array[j][i-1]) #maj du score
			mask_zero(array[j][i-1],$Colonnes.get_node("Player"+str(i)).get_node(categories[j]))#on cache un peu les 0
			if j in [0,1,2,3,5]:#dans les catégories de points classiques d'une manche on met en doré les valeurs non nulles
				golden(array[j][i-1],$Colonnes.get_node("Player"+str(i)).get_node(categories[j]))

	
func mask_zero(score:int,node):
	if score == 0:
		node.set("theme_override_colors/font_color",Color("535353"))
	

func golden(score,node):
	if score != 0:
		node.set("theme_override_colors/font_color",Color("f79f0e"))
	
