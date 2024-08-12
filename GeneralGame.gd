extends Node


var idCardSelected #carte sélectionnée


#types de cartes
enum Couleurs {BATON, EPEE, DENIER, COUPE}
enum Valeurs {AS, DEUX, TROIS, QUATRE, CINQ, SIX, SEPT, VALET, CAVALIER, ROI}

#nombre de players
var nb_players = 4

#arrays qui vont être utilisés
var deck = Array([], TYPE_INT,&"", null )
var board = []
var players_hands = [[],[],[],[]]
var players_plis = [[],[],[],[]]
var points = Array([0,0,0,0], TYPE_INT,&"", null )
var order = [0,1,2,3]
var valeurs_des_cartes = {0:16,1:12,2:13,3:14,4:15,5:18,6:21,7:10,8:10,9:10}
