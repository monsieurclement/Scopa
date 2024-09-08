extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	%Start.grab_focus()
	
	

func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_quit_pressed():
	get_tree().quit()


func _on_rules_pressed():
	%Rules.visible = true
	


func _on_close_rules_button_pressed():
	%Rules.visible = false
