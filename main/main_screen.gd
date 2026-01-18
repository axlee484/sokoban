extends CanvasLayer


@onready var levelButtonScene: PackedScene = preload("res://ui/level_button.tscn")
@onready var levelGrid = $MC/VB/SC/GC

const GRID_COLUMNS = 5

func _ready():
	var levelsData = GameData.getAllLevels()
	levelGrid.columns = GRID_COLUMNS
	for i in range(levelsData.size()):
		var levelButton: LevelButton = levelButtonScene.instantiate()
		levelButton.levelNumber = i+1
		levelGrid.add_child(levelButton)
		
