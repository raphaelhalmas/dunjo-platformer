extends Node2D

const CHAIN := 11
const COIN := 7
const DOOR := 4
const KEY := 2
const LADDER := 12
const LADDER_TOP := 13
const PLAYER := 5

export (PackedScene) var coin
export (PackedScene) var chain
export (PackedScene) var door
export (PackedScene) var key
export (PackedScene) var ladder
export (PackedScene) var ladder_top
export (PackedScene) var player

func _ready():
	call_deferred("setup_tiles")
	
func setup_tiles():
	var cells = $TileMap.get_used_cells()
	
	for cell in cells:
		var tileIndex = $TileMap.get_cell(cell.x, cell.y)
		match tileIndex:
			CHAIN:
				create_instance_from_tilemap(cell, chain, $Items, Vector2(6, 6))
			COIN:
				create_instance_from_tilemap(cell, coin, $Items, Vector2(6, 6))
			DOOR:
				create_instance_from_tilemap(cell, door, $Triggerables, Vector2(6, 6))
			KEY:
				create_instance_from_tilemap(cell, key, $Items, Vector2(6, 6))
			LADDER:
				create_instance_from_tilemap(cell, ladder, $Interactables, Vector2(6, 6))
			LADDER_TOP:
				create_instance_from_tilemap(cell, ladder_top, $Interactables, Vector2(6, 6))				
			PLAYER:
				create_instance_from_tilemap(cell, player, self, Vector2(6, 12))
				
func create_instance_from_tilemap(coord:Vector2, prefab:PackedScene, parent:Node2D, offset:Vector2 = Vector2.ZERO):
#	We're going to set that cell
#	An empty cell is a negative one like I said before
	$TileMap.set_cell(coord.x, coord.y, -1)
	
	var pf = prefab.instance()
	pf.position = $TileMap.map_to_world(coord) + offset
	parent.add_child(pf)
