extends TextureButton

class_name LevelButton

@onready var levelLabel = $LevelNumber

var levelNumber: int

func _ready():
	levelLabel.text = str(levelNumber)



func _on_pressed() -> void:
	print("select")
	SignalManager.levelSelected.emit(levelNumber)
