extends Node


var worldScene: PackedScene = preload("res://world/world.tscn")
var level := 0

func _ready():
    SignalManager.levelSelected.connect(onLevelSelected)
    pass


func onLevelSelected(_level: int):
    level = _level
    get_tree().change_scene_to_packed(worldScene)
