extends Control

var vide = true

func pile(t):
	if t == 0:
		$pile.visible = false
	else:
		$pile.visible = true

func main(a):
	if a == 0:
		$"1".visible = false
		$"2".visible = false
		$"3".visible = false
	elif a == 1 : 
		$"1".visible = false
		$"2".visible = false
		$"3".visible = true
	elif a == 2 : 
		$"1".visible = false
		$"2".visible = true
		$"3".visible = true
	elif a == 3 : 
		$"1".visible = true
		$"2".visible = true
		$"3".visible = true
