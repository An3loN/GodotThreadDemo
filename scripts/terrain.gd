extends Node3D

const Chunk = preload('res://scripts/chunk.gd')
const chunk_config = preload('res://config/chunk_config.tres')

@export var chunk_scene: PackedScene
@export var player: Node3D

var chunks = []
var active_chunk_pos = Vector2i(0, 0)
	
func set_child(chunk):
	$Chunks.add_child(chunk)
	
func add_chunk(pos: Vector2i):
	var chunk = chunk_scene.instantiate() as Chunk
	chunks.append(chunk)
	var position2 = chunk_config.size * Vector2(pos)
	chunk.position = Vector3(position2.x, 0, position2.y)
	await chunk.initialize(pos, chunk_config)
	call_deferred('set_child', chunk)

func set_active_chunk(new_active_chunk_pos: Vector2i):
	active_chunk_pos = new_active_chunk_pos
	var chunk_creation_pos_queue = []
	for x in range(active_chunk_pos.x - chunk_config.chunk_render_radius/2, active_chunk_pos.x + chunk_config.chunk_render_radius/2 + 1):
		for y in range(active_chunk_pos.y - chunk_config.chunk_render_radius/2, active_chunk_pos.y + chunk_config.chunk_render_radius/2 + 1):
			chunk_creation_pos_queue.append(Vector2i(x, y))
	
	for chunk in chunks:
		chunk_creation_pos_queue.erase(Vector2i(chunk.pos.x, chunk.pos.y))
		if(abs(chunk.pos.x - active_chunk_pos.x) > chunk_config.chunk_render_radius/2 or abs(chunk.pos.y - active_chunk_pos.y) > chunk_config.chunk_render_radius/2):
			chunks.erase(chunk)
			chunk.queue_free()
	
	for pos in chunk_creation_pos_queue:
		add_chunk.call_deferred(pos)

func global_pos_to_chunk_pos(global_pos: Vector3) -> Vector2i:
	var local_pos = global_pos - global_position
	return Vector2i(local_pos.x/chunk_config.size.x, local_pos.z/chunk_config.size.y)

func _ready():
	set_active_chunk(Vector2i(0, 0))
	print(player.global_position)
	print(global_position)
	
func _process(delta):
	if(player):
		var player_chunk = global_pos_to_chunk_pos(player.global_position)
		if(player_chunk != active_chunk_pos):
			set_active_chunk(player_chunk)
