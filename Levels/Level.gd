extends Node2D

const COIN := 4
const DOOR := 9
const KEY := 2
const LADDER := 3
const PLAYER := 11

export (PackedScene) var coin
export (PackedScene) var door
export (PackedScene) var key
export (PackedScene) var ladder
export (PackedScene) var player

func _ready():
	call_deferred("setup_tiles")
	
func setup_tiles():
	var cells = $TileMap.get_used_cells()
	
	for cell in cells:
		var tileIndex = $TileMap.get_cell(cell.x, cell.y)
		match tileIndex:
			COIN:
				create_instance_from_tilemap(cell, coin, $Items, Vector2(6, 6))
			DOOR:
				create_instance_from_tilemap(cell, door, $Triggerables, Vector2(6, 6))
			KEY:
				create_instance_from_tilemap(cell, key, $Items, Vector2(6, 6))
#			LADDER:
#				create_instance_from_tilemap(cell, ladder, $Triggerables, Vector2(6, 6))
			PLAYER:
				create_instance_from_tilemap(cell, player, self, Vector2(6, 12))
				
func create_instance_from_tilemap(coord:Vector2, prefab:PackedScene, parent:Node2D, offset:Vector2 = Vector2.ZERO):
#	We're going to set that cell
#	An empty cell is a negative one like I said before
	$TileMap.set_cell(coord.x, coord.y, -1)
	
	var pf = prefab.instance()
	pf.position = $TileMap.map_to_world(coord) + offset
	parent.add_child(pf)
