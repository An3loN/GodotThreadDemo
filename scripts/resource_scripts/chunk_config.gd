extends Resource
class_name ChunkConfig

@export var chunk_render_radius: int
@export var size: Vector2
@export var max_height: float
@export var resolution: Vector2
@export var generation_seed: int
@export var generation_noises: Array[GenerationNoise]
var noises_dict: Dictionary :
	get:
		var dict = {}
		for noise in generation_noises:
			dict[noise.name] = noise
		return dict

func _init(p_chunk_render_radius = 5, p_size = Vector2.ONE, p_max_height = 1, p_resolution = Vector2.ONE, p_generation_seed = 0, generation_noises = []):
	self.chunk_render_radius = p_chunk_render_radius
	self.size = p_size
	self.max_height = p_max_height
	self.resolution = p_resolution
	self.generation_seed = p_generation_seed
