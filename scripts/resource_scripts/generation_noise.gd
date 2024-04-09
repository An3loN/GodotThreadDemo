extends Resource
class_name GenerationNoise

@export var name: String
@export var noise: Noise
@export var height_scale: float
@export var material: Material

func _init(p_name = "new_noise", p_noise = FastNoiseLite.new(), p_height_scale = 1):
	self.name = p_name
	self.noise = p_noise
	self.height_scale = p_height_scale
	
