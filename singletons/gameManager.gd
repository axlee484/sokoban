extends Node


var worldScene: PackedScene = preload("res://world/world.tscn")
var mainScene: PackedScene = preload("res://main/main_screen.tscn")
var level := 0

func _ready():
    SignalManager.levelSelected.connect(onLevelSelected)
    SignalManager.exitToMainScreen.connect(onExitToMainScreen)
    pass



func loadMainScene():
    get_tree().change_scene_to_packed(mainScene)

func onExitToMainScreen():
    loadMainScene()

func onLevelSelected(_level: int):
    level = _level
    get_tree().change_scene_to_packed(worldScene)
