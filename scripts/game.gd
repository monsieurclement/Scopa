extends Node2D


const CARTE = preload("res://scenes/carte.tscn")
const PLAYER = preload("res://scenes/player.tscn")
signal played
signal player_played
signal round_finished
signal scopa
signal game_finished
#var cardsToCapture = {} #dictionnaire liant les combis de cartes avec leurs IDs dans sums-possible
var sums_possible = [] 
var nb_cards_capture = []
var cards_to_consider = []
var has_played = false
var scopas = []
@export var timer = 0.7
var liste_intermediaire = []
@export var taille_init_board = 4
@export var nb_player = 4
var second_tour = false
var first_round = true
var nb_round = 1


func _ready():
	nb_player = GeneralGame.nb_players
	GeneralGame.timer = timer
	reset_game() #remise à zéro des arrays et destruction des enfants
	
	#var score_test = [[0,1,0,3],[1,0,0,0],[0,1,0,0],[0,0,1,0],[50,67,99,71],[0,0,1,0],[1,2,3,4],[9,12,14,19]]
	#%Score/Marges/Lignes.get_node("manche"+str(%Score.manche_array[-1])).actualize_points(score_test)
	
	
func _process(_delta):
	for i in [2,3,4]:
		$"Board/UI/Players".get_node("joueur"+str(i)).main(GeneralGame.players_hands[i-1].size())
		$"Board/UI/Players".get_node("joueur"+str(i)).pile(GeneralGame.players_plis[i-1].size())
			
func _on_settings_button_pressed():
	%Settings.visible = true

func quit():
	GeneralGame.deck = [] #reset des arrays
	GeneralGame.players_hands = [[],[],[],[]]
	GeneralGame.players_plis = [[],[],[],[]]
	GeneralGame.board = []
	GeneralGame.points = [0,0,0,0]
	
	get_tree().change_scene_to_file("res://scenes/menu.tscn") #retour au menu principal

func _on_score_button_pressed() -> void:
	$Board/UI/Score.visible = true


func _on_rules_button_pressed():
	$Board/UI/Rules.visible = true



func _on_play_button_pressed(): #animation de jouer la carte et passer son tour
	if GeneralGame.idCardSelected == null or GeneralGame.idCardSelected not in GeneralGame.players_hands[0]:
		pass #si aucune carte n'est sélectionnée on joue rien
	elif %play_message.visible:
		player1_play()
	for card in $Board/UI/Board.get_children():
		if card.onBoardSelected == true and !card.cardHighlighted :
			card.onBoardDeselect()
	
	$Board/UI/message_2.text = ""

func player_random_commence():
	#order suit le nb de joueurs
	GeneralGame.nb_players = nb_player
	GeneralGame.order.clear()
	
	for i in range(nb_player):
		GeneralGame.order.append(i)
	
	#randomisation de order
	var rand = randi() % 10
	for i in range(rand):
		turnover()

func reset_game():
	
	if first_round:
		player_random_commence()
		first_round = false
	else:
		turnover()
	
	#message de qui commence
	if GeneralGame.order[0] == 0:
		$Board/UI/message_1.text = "Vous commencez."
	else:
		$Board/UI/message_1.text = "Le joueur " + str(GeneralGame.order[0]+1) + " commence."
	
	#cleaning des listes générales
	GeneralGame.deck = []
	GeneralGame.players_hands = [[],[],[],[]]
	GeneralGame.players_plis = [[],[],[],[]]
	GeneralGame.board = []
	nb_round += 1
	scopas.clear()
	
	#virer la dernière carte jouée
	for idx in $Board/UI/to_play.get_children():
				if idx.name != "vide":
					idx.queue_free() #retirer tous les enfants sauf "vide"
	
	for n in $Board/UI/Board.get_children():
		$Board/UI/Board.remove_child(n)
		n.queue_free()
	for n in $Board/UI/Hand.get_children():
		$Board/UI/Hand.remove_child(n)
		n.queue_free()
	for i in range(0,40): #on remplit le deck des cartes
		GeneralGame.deck.append(i)
	GeneralGame.deck.shuffle() #mélange de début de game
	
	initiate_game() #plateau
	deal(GeneralGame.nb_players, GeneralGame.deck) #on distribue les cartes
	
	turn_manager()
	#print("deck : ",GeneralGame.deck)
	#print("nb cards : ",GeneralGame.deck.size())
	#print(GeneralGame.players_hands)
	

func deal(nb_players, deck):
	var z
	for i in range(0,nb_players): #distribution initiale
		for j in range (0,3):
			z = deck.pop_back()
			GeneralGame.players_hands[i].append(z)
		#if i in [1,2,3]:
			#$Board/UI/Players.get_node("joueur"+str(i+1)).main(GeneralGame.players_hands[i].size())	
	initiate_player_hand()

func initiate_player_hand(): #a est le tableau de la main du joueur
	for i in range(0,3):
		var carte = CARTE.instantiate()
		carte.cardInHand = true
		carte.setup(GeneralGame.players_hands[0][i])
		carte.flip()
		$Board/UI/Hand.add_child(carte)

	
func initiate_game(): 
	##pioche des 4 cartes initiales
	var kings = [9,19,29,39] #ids des rois
	var nb_kings = 0 #nb de rois dans la donne initiale
	var id #id qui va passer sur le plateau
	#var new_card #var de nvelles instance
	for i in range(0,taille_init_board):
		id = GeneralGame.deck.pop_back() #on pioche une carte
		if id in kings:
			nb_kings +=1
			if nb_kings >= 3: #si 3 rois ou plus on change la carte
				var id_suivant = GeneralGame.deck.pop_back()
				GeneralGame.deck.append(id)
				GeneralGame.deck.shuffle()
				nb_kings -= 1
				id = id_suivant
				if id in kings:#cas où la carte d'après est le dernier roi :
					id_suivant = GeneralGame.deck.pop_back()
					GeneralGame.deck.append(id)
					GeneralGame.deck.shuffle()
					id = id_suivant
				
		add_to_board(id)
		
	##initialisation des objets des mains adverses
	for j in range(2,GeneralGame.nb_players+1):
		$Board/UI/Players.get_node("joueur"+str(j)).visible = true
		$Board/UI/Players.get_node("joueur"+str(j)+"/Label").text = "Joueur "+str(j)
		
	
		
func add_to_board(id):
	var new_card
	GeneralGame.board.append(id) #ajout de la carte au board
	new_card = CARTE.instantiate() 
	new_card.onBoard = true
	new_card.setup(id)
	new_card.flip()
	$Board/UI/Board.add_child(new_card)
	
func remove_from_board(id):
	GeneralGame.board.erase(id)
	$Board/UI/Board.remove_child(get_node("Board/UI/Board/"+str(id)))

func turn_manager():
	while GeneralGame.players_hands != [[],[],[],[]]:#tant que round pas fini
		play()
		await played
	if GeneralGame.deck.size() == 0:
		round_finished.emit()
	else:
		await get_tree().create_timer(timer*3).timeout
		deal(GeneralGame.nb_players,GeneralGame.deck)
		await get_tree().create_timer(timer).timeout
		turn_manager()
	
func play():
	if GeneralGame.order[0] == 0:
		%play_message.text = "A vous de jouer !"
		%play_message.visible = true
		await player_played
		turnover()
	else:
		await ai_play(GeneralGame.order[0])
		#ajouter timer ici ?
		turnover()
	played.emit()



func player1_play():
	var cardToPlay = GeneralGame.idCardSelected	#sélection de la carte
	
	
	##logique d'un tour
	sums_possible.clear()
	nb_cards_capture.clear()
	liste_intermediaire.clear()
	cards_to_consider = GeneralGame.board
	
	for i in $Board/UI/Board.get_children(): #quelles sont les cartes sélectionnées ?
		if i.onBoardSelected:
			liste_intermediaire.append(int(i.id))
	
	#si sélection de cartes ou pas de possibilité considérer la liste intermédiaire
	#if %play_message.visible == true or liste_intermediaire.size() != 0:
		#cards_to_consider = liste_intermediaire
		#print(cards_to_consider)
	
	second_tour = false #premier round
	logique_tour(cardToPlay) #calcul de défausse ou capture évidente
	
	
	if sums_possible.size() > 1: #si rien d'évident
		cards_to_consider = liste_intermediaire #on ne considère que les cartes sélect
		
		sums_possible.clear() #reset des calculs
		nb_cards_capture.clear()
		
		second_tour = true #on cancel le cas de défausse vu qu'il a été vu au 1er round
		logique_tour(cardToPlay)
		if !has_played:	
			%play_message.text = "Vous devez choisir la bonne carte à capturer." #si pas les bonnes cartes sélect
			%play_message.visible = true
	
		
		
		
	#on nettoie derrière
	await get_tree().create_timer(timer).timeout
	
	nb_cards_capture.clear()
	sums_possible.clear()
	liste_intermediaire.clear()
	
	if has_played:
		player_played.emit()
		pass
	has_played = false
	#else:
		#
		#$Board/UI/play_message.visible = true
		#cardsToCapture.clear()
		#sums_possible.clear()
		#pass
	#print(cardToPlay)
	#print(cardsToCapture)
	#print(choix)
	#print(sums_possible)
	#print(sums_possible.pick_random())
	
	
func logique_tour(cardToPlay):
	var choix
	#sums_possible.clear()
	#nb_cards_capture.clear()
	#faire la liste de toutes les sommes possibles des valeurs du board par 1 ou 2 cartes
	for c in range(cards_to_consider.size()): #pour chaque carte du board
		var value = cards_to_consider[c]%10+1
		if value == cardToPlay%10+1: #même valeur que carte du board - carte seule à capturer
			sums_possible.append([cards_to_consider[c]]) #id enregistré
			nb_cards_capture.append(1) #taille de la capture
		for b in range(c):
			var sum = cards_to_consider[b]%10+1 + value
			if sum == cardToPlay%10+1:
				sums_possible.append([cards_to_consider[c],cards_to_consider[b]])
				nb_cards_capture.append(2)

	
	##élimination des options avec trop de cartes
	while 1 in nb_cards_capture and 2 in nb_cards_capture:
		var index = nb_cards_capture.find(2)
		nb_cards_capture.pop_at(index)
		sums_possible.pop_at(index)

	
	if nb_cards_capture.size() == 0:
		if second_tour:#cas de défausse géré au 1er tour des calculs
			#%play_message.text = "Avez-vous sélectionné les bonnes cartes ?" #pas sûr de ça en vrai
			#%play_message.visible = true
			pass
		else:
			##effacement de la carte de la main (objet)
			$Board/UI/Hand.get_node(str(GeneralGame.idCardSelected)).queue_free()
			#retirer de la main (liste GG)
			GeneralGame.players_hands[0].erase(cardToPlay)
			
			
			##ajout à la card just played
			for idx in $Board/UI/to_play.get_children():
				if idx.name != "vide":
					idx.queue_free() #retirer tous les enfants sauf "vide"
					
			var new_card
			new_card = CARTE.instantiate() 
			new_card.setup(cardToPlay)
			new_card.flip()
			$Board/UI/to_play.add_child(new_card)
			
			#await get_tree().create_timer(1).timeout
			add_to_board(cardToPlay) #si la carte ne peut rien capturer on l'ajoute au board

			has_played = true

		
	if sums_possible.size() == 1:
		##effacement de la carte de la main (objet)
		$Board/UI/Hand.get_node(str(GeneralGame.idCardSelected)).queue_free() 	
		#retirer de la main (liste GG)
		GeneralGame.players_hands[0].erase(cardToPlay)
		
		##ajout à la card just played
		for idx in $Board/UI/to_play.get_children():
			if idx.name != "vide":
				idx.queue_free() #retirer tous les enfants sauf "vide"
				
		var new_card
		new_card = CARTE.instantiate() 
		new_card.setup(cardToPlay)
		new_card.flip()
		$Board/UI/to_play.add_child(new_card)
		
		#capture
		choix = sums_possible[0]
		
		GeneralGame.players_plis[0].append(cardToPlay) #ajout de la carte à la pile capturée
		for id in choix: #on joue une anim de mise en valeur
			GeneralGame.players_plis[0].append(id)
			$Board/UI/Board.get_node(str(id)).cardHighlighted = true
			if !$Board/UI/Board.get_node(str(id)).onBoardSelected:
				$Board/UI/Board.get_node(str(id)+"/Anim").play("Select")
			
		await get_tree().create_timer(timer).timeout #délai d'1 sec
		
		for id in choix:
			remove_from_board(id)
			
		#prise en compte des scopas
		if GeneralGame.board.size()==0:
			scopa.emit()
			
		has_played = true


func ai_play(i):
	var choix
	#sélection de la carte
	if GeneralGame.players_hands[i].size()==0:
		pass
	else:
		var cardToPlay = GeneralGame.players_hands[i][randi()%GeneralGame.players_hands[i].size()]
		#retirer de la main
		GeneralGame.players_hands[i].erase(cardToPlay)
		
		##effacement de la carte de la main (objet)

		##ajout à la card just played
		for idx in $Board/UI/to_play.get_children():
			if idx.name != "vide":
				idx.queue_free() #retirer tous les enfants sauf "vide"
				
		var new_card
		new_card = CARTE.instantiate() 
		new_card.setup(cardToPlay)
		new_card.flip()
		$Board/UI/to_play.add_child(new_card)
		
		
		
		##logique d'un tour
		sums_possible.clear()
		nb_cards_capture.clear()
		#faire la liste de toutes les sommes possibles des valeurs du board par 1 ou 2 cartes
		for c in range(GeneralGame.board.size()): #pour chaque carte du board
			var value = GeneralGame.board[c]%10+1
			if value == cardToPlay%10+1: #même valeur que carte du board - carte seule à capturer
				sums_possible.append([GeneralGame.board[c]]) #id enregistré
				nb_cards_capture.append(1) #taille de la capture
			for b in range(c):
				var sum = GeneralGame.board[b]%10+1 + value
				if sum == cardToPlay%10+1:
					sums_possible.append([GeneralGame.board[c],GeneralGame.board[b]])
					nb_cards_capture.append(2)
	
		
		##élimination des options avec trop de cartes
		
		while 1 in nb_cards_capture and 2 in nb_cards_capture:
			var index = nb_cards_capture.find(2)
			nb_cards_capture.pop_at(index)
			sums_possible.pop_at(index)
		
		#await get_tree().create_timer(timer).timeout #délai d'1 sec
		
		if sums_possible.size() >= 1:
			#capture
			
			await get_tree().create_timer(timer).timeout #délai d'1 sec
			
			choix = sums_possible[randi()%sums_possible.size()]
			
			GeneralGame.players_plis[i].append(cardToPlay) #ajout de la carte à la pile capturée
			for id in choix: #on joue une anim de mise en valeur
				GeneralGame.players_plis[i].append(id)
				$Board/UI/Board.get_node(str(id)+"/Anim").queue("Select")
				
			await get_tree().create_timer(timer).timeout #délai d'1 sec
			
			for id in choix:
				remove_from_board(id)
			
			#prise en compte des scopas
			if GeneralGame.board.size()==0:
				scopa.emit()
			
		
		
		if sums_possible.size() == 0:
					
			await get_tree().create_timer(timer).timeout
			add_to_board(cardToPlay) #si la carte ne peut rien capturer on l'ajoute au board
			
			
			
		#on nettoie derrière
		await get_tree().create_timer(timer).timeout
		nb_cards_capture.clear()
		sums_possible.clear()

		#played.emit()

	
	
	
		

func turnover(): #tour de la boucle des joueurs
	GeneralGame.order.append(GeneralGame.order.pop_front())
	
	#if GeneralGame.players_hands == [[],[],[],[]] and GeneralGame.deck.size() > 0: #redistrib
		#await get_tree().create_timer(timer*4).timeout
		#deal(GeneralGame.nb_players,GeneralGame.deck)


func _on_played():
	%play_message.visible = false

	
	#await get_tree().create_timer(timer).timeout 
	#for i in range(1,4):
		#await ai_play(i)
	#play()
 

func _on_round_finished():
	decompte_points(GeneralGame.players_plis)
	#print(GeneralGame.players_plis)
	#print(GeneralGame.points)
	
		#apparition d'un menu de point, et on relance pas avant qu'on appuie sur un bouton
	%Score.visible = true
	%Score/CloseScoreButton.visible = false
	if !%Score.end_of_game:
		%Score/Marges/Lignes/NextRoundButton.visible = true
	await %Score.next_manche
	reset_game()
	
func decompte_points(plis):
	var score = [0,0,0,0]
	
	#GeneralGame.score_to_actualize[0] = scopas #nb de scopas par joueurs
	
	
	#print("\n \n ------- DECOMPTE DES POINTS DE LA MANCHE ",nb_round," : ------- \n")
	#decompte du plus grand nb de cartes
	for i in range(4):
		score[i] = plis[i].size()
	
	
	
	if score.count(score.max()) == 1:
		GeneralGame.points[score.find(score.max())] += 1
		GeneralGame.score_to_actualize[1][score.find(score.max())] += 1
		%Score.end_of_game = true
		#print("plus gd nb de carte : Joueur ",score.find(score.max())+1)
	#else:
		#print("plus gd nb de carte : aucun joueur")
	
	score.clear()
	
	
	
	#decompte du nb de deniers
	score = [0,0,0,0]
	for i in range(4):
		for j in plis[i]:
			if j/10 == 2:
				score[i] += 1
	if score.count(score.max()) == 1:
		GeneralGame.points[score.find(score.max())] += 1
		GeneralGame.score_to_actualize[2][score.find(score.max())] += 1
		#print("plus gd nb de deniers : Joueur ",score.find(score.max())+1)
	#else:
		#print("plus gd nb de deniers : aucun joueur")
		
	score.clear()
	
	#decompte du 7 de deniers
	var _sept = null
	for i in range(4):
		if plis[i].has(26):
			_sept = i
			GeneralGame.points[i] += 1
			GeneralGame.score_to_actualize[3][i] += 1
			
	#if sept == null:
		#print("7 de deniers : aucun joueur")
	#else:
		#print("7 de deniers : Joueur ",sept+1)
	#sept.free() #éliminer cette var ?
	
	
	#decompte de la premiera
	score = [0,0,0,0]
	var jetons = [0,0,0,0]
	var color
	var value
	for i in range(4):
		for j in plis[i]:
			color = j/10
			value = j%10
			if jetons[color] < GeneralGame.valeurs_des_cartes[value]: #on trouve le max de points fourni par les cartes de chaque couleur
				jetons[color] = GeneralGame.valeurs_des_cartes[value]
		score[i] = jetons[0] + jetons[1] + jetons[2] + jetons[3] #sommes des jetons de chaque couleur pour chaque joueur
	
	GeneralGame.score_to_actualize[4] = score #actualisation des scores de scopas
		
	if score.count(score.max()) == 1:
		GeneralGame.points[score.find(score.max())] += 1
		GeneralGame.score_to_actualize[5][score.find(score.max())] += 1
		#print("primiera : Joueur ",score.find(score.max())+1)
	#else:
		#print("primiera : aucun joueur")
	
	
	#decompte des scopas du round
	#print("Scopas : \n", "Joueur 1 : ",scopas.count(0), "\nJoueur 2 : ",scopas.count(1), "\nJoueur 3 : ",scopas.count(2), "\nJoueur 4 : ",scopas.count(3))
	
	for i in scopas:
		GeneralGame.points[i] +=1
		GeneralGame.score_to_actualize[0][i]+=1
		
	scopas.clear()
	
	#print("Score final de la manche : \n", "Joueur 1 : ",GeneralGame.points[0], "\nJoueur 2 : ",GeneralGame.points[1], "\nJoueur 3 : ",GeneralGame.points[2], "\nJoueur 4 : ",GeneralGame.points[3])
	
	GeneralGame.score_to_actualize[6] = sum_of_arrays( 
		sum_of_arrays(
		sum_of_arrays(GeneralGame.score_to_actualize[0],GeneralGame.score_to_actualize[1]),
		sum_of_arrays(GeneralGame.score_to_actualize[2],GeneralGame.score_to_actualize[3])),
	GeneralGame.score_to_actualize[5])
	
	
	GeneralGame.score_to_actualize[7] = GeneralGame.points
	
	
	%Score/Marges/Lignes.get_node("manche"+str(%Score.manche_array[-1])).actualize_points(GeneralGame.score_to_actualize)
	%Score/Marges/Lignes.get_node("plis"+str(%Score.manche_array[-1])).actualize_plis(GeneralGame.players_plis)
	#%Score.active_manche = nb_round-1
	%Score.new_round()
	GeneralGame.score_to_actualize = [[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0]]
	
	
	for i in range(GeneralGame.points.size()):
		if GeneralGame.points[i]>GeneralGame.points_to_win: #!!! prendre en compte égalités et scores multiples supérieurs à 21
			#print("Joueur "+str(i+1)+" a gagné !!")
			GeneralGame.winner = i+1
			game_finished.emit()
	
	
func _on_scopa():
	scopas.append(GeneralGame.order[0])
	%ScopaConf1.emitting = true
	%ScopaConf2.emitting = true	
	$Board/UI/message_2.text = "Bravo ! Scopa ! Joueur " + str(GeneralGame.order[0]+1) +" marque 1 point !"
	
	

func _on_player_played():
	pass # Replace with function body.


func _on_game_finished() -> void:
	%Score.visible = true
	%EndConfetti.emitting = true
	%Score/Marges/Lignes/EndingLabel.text = "JOUEUR " + str(GeneralGame.winner) + " A GAGNE !!"
	%Score/Marges/Lignes/EndingLabel.visible = true
	%Score/Marges/Lignes/EndingButtons.visible = true
	%Score/Marges/Lignes/NextRoundButton.visible = false
	#get_tree().change_scene_to_file("res://scenes/menu.tscn") #retour au menu principal
	pass

func sum_of_arrays(array1,array2):
	if array1.size() == array2.size():
		var array3 = []
		for i in range(array1.size()):
			array3.append(array1[i] + array2[i])
		return array3
