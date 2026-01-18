extends Node

var SCORE_FILE_PATH = "user://score.dat"
var scoreData: Array




func loadScoreFile():
	var file = FileAccess.open(SCORE_FILE_PATH, FileAccess.READ)
	scoreData = JSON.parse_string(file.get_as_text())
	file.close()


func createDefaultScoreFile():
	var file = FileAccess.open(SCORE_FILE_PATH, FileAccess.WRITE)
	for i in range (GameData.getAllLevels().size()):
		var ld := {"level": (i+1), "best": -1}
		scoreData.append(ld)

	file.store_string(JSON.stringify(scoreData))
	file.close()


func _ready():
	SignalManager.levelFinished.connect(saveScore)
	if FileAccess.file_exists(SCORE_FILE_PATH):
		loadScoreFile()
	else:
		createDefaultScoreFile()
	print(scoreData)


func getBestForLevel(level: int):
	return scoreData[level-1].best

func saveScore(level, moves):
	var levelBest = scoreData[level-1].best
	if levelBest == -1:
		scoreData[level-1].best = moves
	elif int(levelBest) > moves :
		scoreData[level-1].best = moves
	else:
		return
		
	var file = FileAccess.open(SCORE_FILE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(scoreData))
	file.close()
	
