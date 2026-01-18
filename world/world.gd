extends Node2D

class_name World


@onready var floorLayer: TileMapLayer = $Floor
@onready var wallLayer: TileMapLayer = $Wall
@onready var targetLayer: TileMapLayer = $Target
@onready var boxLayer: TileMapLayer = $Box

@onready var player = $Player
@onready var camera = $Camera2D
@onready var gameHud = $GameHUD


const TILE_SIZE = 32
const SOURCE_ID := 0
const BOX_TILE := Vector2i(1,0)
const TARGET_BOX_TILE := Vector2i(0,0)
const WALL_TILE := Vector2i(2,0)
const TARGET_TILE := Vector2i(9,0)
const FLOOR_TILE_START := Vector2i(3,0)
const FLOOR_TILE_END := Vector2i(8,0)

const FLOOR_LAYER_NAME = "floor"
const WALL_LAYER_NAME = "walls"
const BOX_LAYER_NAME = "boxes"
const TARGET_LAYER_NAME = "targets"
const TARGET_BOX_LAYER_NAME = "targetBox"

var tileMapData: Dictionary

var boxes: Array


var _level := 0
var moveDirection := Vector2i.ZERO
var isMoving := false
var moves:= 0
var levelBest :=0

func getRandomFloorTile():
	var x := randi_range(FLOOR_TILE_START.x, FLOOR_TILE_END.x)
	var y := randi_range(FLOOR_TILE_START.y, FLOOR_TILE_END.y)
	return Vector2i(x,y)


func getLayerTileFromName(layerName: String):
	match layerName:
		FLOOR_LAYER_NAME: return [floorLayer, getRandomFloorTile()]
		WALL_LAYER_NAME: return [wallLayer, WALL_TILE]
		BOX_LAYER_NAME: return [boxLayer, BOX_TILE]
		TARGET_LAYER_NAME: return [targetLayer, TARGET_TILE]
		TARGET_BOX_LAYER_NAME: return [boxLayer, TARGET_BOX_TILE]


func setupLayer(layerName: String):
	var layerCoords: Array = tileMapData[layerName]
	for coord in layerCoords:
		var coords = Vector2i(coord.coord.x, coord.coord.y)
		var layerTile = getLayerTileFromName(layerName)
		layerTile[0].set_cell(coords,SOURCE_ID, layerTile[1])
	return self





func setupPlayer(level):
	var playerCoord = GameData.getLevelData(level).player_start
	player.global_position = TILE_SIZE* Vector2(playerCoord.x, playerCoord.y)


func setupCamera():
	var levelBox := floorLayer.get_used_rect()
	var size_in_pixels := levelBox.size * TILE_SIZE
	var offset_in_pixels := levelBox.position * TILE_SIZE
	var midPoint := offset_in_pixels + (size_in_pixels / 2)
	camera.global_position = global_position + Vector2(midPoint)


func setup():
	_level = GameManager.level
	tileMapData = GameData.getLevelData(_level).tiles
	floorLayer.clear()
	wallLayer.clear()
	targetLayer.clear()
	boxLayer.clear()
	setupLayer(FLOOR_LAYER_NAME)
	setupLayer(WALL_LAYER_NAME)
	setupLayer(TARGET_LAYER_NAME)
	setupLayer(BOX_LAYER_NAME)


	setupCamera()
	setupPlayer(_level)
	gameHud.updateHud(_level, moves, "-" if levelBest == -1 else str(levelBest))






func renderTargetBoxTile(coords: Vector2):
	var layerTile = getLayerTileFromName(TARGET_BOX_LAYER_NAME)
	layerTile[0].set_cell(coords,SOURCE_ID, layerTile[1])


func checkTargetCovered():
	var targets: Array = tileMapData.targets
	var count = targets.size()
	var targetsHit= 0

	for coord in targets:
		var targetX = coord.coord.x
		var targetY = coord.coord.y
		for boxCoord in boxes:
			var x = boxCoord.coord.x
			var y = boxCoord.coord.y
			if x == targetX and y == targetY:
				targetsHit +=1
				renderTargetBoxTile(Vector2(x,y))
	if targetsHit == count:
		SignalManager.levelFinished.emit(_level, moves)
		set_process(false)


func _ready():
	setup()
	levelBest = ScoreManager.getBestForLevel(_level)
	gameHud.updateHud(_level, moves, "-" if levelBest == -1 else str(levelBest))
	boxes = JSON.parse_string(JSON.stringify(tileMapData.boxes))
	checkTargetCovered()




func isWallTile(cell: Vector2i):
	if cell in wallLayer.get_used_cells():
		return true
	return false


func isBoxTile(cell: Vector2i):
	if cell in boxLayer.get_used_cells():
		return true
	return false

func isEmptyTile(cell: Vector2i):
	if !(isBoxTile(cell) or isWallTile(cell)):
		return true
	return false


func getBoxNextCell(boxCell: Vector2i, direction: Vector2i):
	if moveDirection == Vector2i.ZERO:
		return
	return boxCell + Vector2i(direction)


func getPlayerNextCell(direction: Vector2i):
	if moveDirection == Vector2i.ZERO:
		return
	var playerPos = player.global_position
	var nextCellPos = playerPos + Vector2(direction)*TILE_SIZE
	return Vector2i(nextCellPos)/TILE_SIZE


func moveBox(currentCell: Vector2i, nextCell: Vector2i):
	boxLayer.erase_cell(currentCell)

	var idx = 0
	for i in range(boxes.size()):
		if boxes[i].coord.x == currentCell.x and boxes[i].coord.y == currentCell.y:
			idx = i
			break
	boxes.remove_at(idx)
	boxes.append({"coord": { "x": nextCell.x, "y": nextCell.y } })	
	boxLayer.set_cell(nextCell, SOURCE_ID, BOX_TILE)


func canPlayerMove():
	if moveDirection == Vector2i.ZERO:
		return false
	var playerNextCell = getPlayerNextCell(moveDirection)
	if isWallTile(playerNextCell):
		return false
	if isEmptyTile(playerNextCell):
		return true
	if isBoxTile(playerNextCell):
		var boxNextCell = getBoxNextCell(playerNextCell, moveDirection)
		if isEmptyTile(boxNextCell):
			moveBox(playerNextCell, boxNextCell)
			return true
	
	return false



func movePlayer():
	isMoving = true
	player.global_position += Vector2(moveDirection*TILE_SIZE)
	moves += 1
	isMoving = false
	moveDirection = Vector2i.ZERO
	gameHud.updateHud(_level, moves, "-" if levelBest == -1 else str(levelBest))

			


func  _process(_delta):
	if isMoving:
		return
	if Input.is_action_just_pressed("left"):
		moveDirection = Vector2i.LEFT
	if Input.is_action_just_pressed("right"):
		moveDirection = Vector2i.RIGHT
	if Input.is_action_just_pressed("up"):
		moveDirection = Vector2i.UP
	if Input.is_action_just_pressed("down"):
		moveDirection = Vector2i.DOWN
	
	if canPlayerMove():
		movePlayer()
	checkTargetCovered()
	
	
	
