class_name Card extends Container


@export var card_color : GeneralGame.Couleurs
@export var card_valor : GeneralGame.Valeurs

var cardHighlighted = false
var cardInHand = false
var cardSelected = false
var id
var onBoard = false
var onBoardSelected = false

func _ready():
	pass
	
func _process(_delta):
	if cardSelected:
		if GeneralGame.idCardSelected != id:
			cardInHand = true
			cardSelected = false
			#await $Anim.animation_finished
			$Anim.play_backwards("Select")
	pass #si on détecte un changement d'id dans la carte sélected alors on joue 
	#l'anim select en backwards et on remet la carte dans la main
	


func setup(i):
	id = i
	%Cardface.frame = id
	card_valor = id % 10
	card_color = id / 10
	self.name = str(i)


func _on_mouse_entered(): #anim de parcourir les cartes en main
	if cardInHand:
		$Anim.queue("Select") #monter la carte
		cardHighlighted = true 


func _on_mouse_exited(): #anim de parcourir les cartes en main
	if cardInHand:
		if cardSelected:
			pass
		else:
			#await $Anim.animation_finished
			$Anim.play_backwards("Select") #descendre la carte
		cardHighlighted = false

func _on_gui_input(event): #au clic sur une carte
	if (event is InputEventMouseButton) and (event.button_index == 1) and (event.button_mask == 1):
		#if cardSelected:
			#cardSelected = false
			#cardInHand = true
			#GeneralGame.idCardSelected = null #on conserve l'id de la carte sélectionnée
			#$Anim.play_backwards("Select")
		if cardInHand:
			if !cardSelected:
				cardSelected = true #la carte est sélectionnée
				GeneralGame.idCardSelected = id #on conserve l'id de la carte sélectionnée
				cardInHand = false
		
		if onBoard: #sélection sur le plateau
			if onBoardSelected: ##j'arrive pas à faire marcher ça
				onBoardDeselect()
			elif onBoardSelected == false:
				onBoardSelect()
		
	
func onBoardSelect():
	$Cardback/Contour.visible = true
	$Anim.queue("Select") #monter la carte
	onBoardSelected = true

func onBoardDeselect():
	if cardHighlighted:
		pass
	else:
		$Cardback/Contour.visible = false
		#await $Anim.animation_finished
		$Anim.play_backwards("Select") #descendre la carte
		onBoardSelected = false


func flip():
	$Anim.queue("flip")
		
		#if event.button_mask == 1:
			##press down
			#if cardHighlighted:
				#var cardTemp = card.instantiate()
				#get_tree().get_root().get_node("Game/Board/CardHolder").add_child(cardTemp)
				#GeneralGame.CardSelected = true
				#if cardHighlighted:
					#self.get_child(0).hide()
		#elif event.button_mask == 0:
			##press up
			#if !GeneralGame.mouseOnPlacement: #place card not on board
				#cardHighlighted = false
				#self.get_child(0).show()
				##self.queue_free() #supprimer la carte de la main
			#else:
				#pass
				##place card on board : DECIDER WHAT HAPPENS NEXT
				##self.queue_free()
				##get_node("%ZoneDepot").placeCard()

