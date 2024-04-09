extends Node3D
@export var chunk_config: ChunkConfig

func _ready():
	generate_chunk()

func generate_deffered():
	$MeshInstance3D.mesh = await $MapGenerator.get_mesh(chunk_config)

func generate_chunk():
	generate_deffered.call_deferred()

func _input(event):
	if(event.is_pressed() and event.as_text() == "R"):
		generate_chunk()
