extends Node

var LEVEL_DATA_PATH: String = "res://data/level_data.json"
var tileSize: int = 32

var levelData: Dictionary = {}





func loadLevelData():
	var file = FileAccess.open(LEVEL_DATA_PATH, FileAccess.READ)
	levelData = JSON.parse_string(file.get_as_text())


func getAllLevels():
	return levelData

func getLevelData(level: int):
	return levelData.get(str(level))


func _ready():
	loadLevelData()
