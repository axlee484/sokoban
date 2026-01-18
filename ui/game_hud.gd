extends CanvasLayer

@onready var levelval = $MarginContainer/VB/HBLevel/Level
@onready var movesval = $MarginContainer/VB/HBMoves/Moves
@onready var bestVal = $MarginContainer/VB/HBBest/Best


func updateHud(level, moves, best):
    levelval.text = str(level)
    movesval.text = str(moves)
    bestVal.text = str(best)

func _ready():
    pass



func _on_texture_button_pressed() -> void:
    SignalManager.exitToMainScreen.emit()
