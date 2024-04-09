extends Node3D

var ChunkMeshProvider = preload('res://scripts/terrain_generator.gd')
var pos: Vector2i

func initialize(p_pos: Vector2i, config: ChunkConfig):
	self.pos = p_pos
	$MeshInstance3D.mesh = await ChunkMeshProvider.new().get_mesh(self.pos, config)
