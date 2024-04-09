extends MeshProvider

var thread = Thread.new()
signal on_done(generated_mesh: Mesh)

func _exit_tree():
	if(thread.is_started()):
		thread.wait_to_finish()

func get_noise_value(pos: Vector2, config: ChunkConfig) -> float:
	var generation_seed = config.generation_seed
	var result = 1
	for noise_index in range(len(config.noises)):
		var noise = config.noises[noise_index]
		noise.seed = generation_seed
		result *= noise.get_noise_2dv(pos) * config.noiseHeightScales[noise_index]
	return result

func generate_chunk_mesh(pos, config) -> Mesh:
	
	var mesh = ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	for x in config.resolution.x:
		for y in config.resolution.y:
			var step_x = config.size.x / config.resolution.x
			var step_y = config.size.y / config.resolution.y
			var local_pos = Vector2(-config.size.x / 2 + x * step_x, -config.size.y / 2 + y * step_y)
			var quad_positions = [
				local_pos,
				local_pos + Vector2.RIGHT * step_x,
				local_pos + Vector2.RIGHT * step_x + Vector2.UP * step_y,
				local_pos + Vector2.UP * step_y
			]
			var quad_heights = []
			for i in len(quad_positions):
				quad_heights.append(get_noise_value(quad_positions[i] + Vector2(pos) * config.size, config) * config.max_height)
			var get_heightv = func(i):
				return Vector3(quad_positions[i].x, quad_heights[i], quad_positions[i].y)
			
			var plane1 = Plane(get_heightv.call(2), get_heightv.call(1), get_heightv.call(0))
			mesh.surface_set_normal(plane1.normal)
			mesh.surface_set_tangent(plane1)
			mesh.surface_add_vertex(get_heightv.call(2))
			mesh.surface_add_vertex(get_heightv.call(1))
			mesh.surface_add_vertex(get_heightv.call(0))
			
			var plane2 = Plane(get_heightv.call(3), get_heightv.call(2), get_heightv.call(0))
			mesh.surface_set_normal(plane2.normal)
			mesh.surface_set_tangent(plane2)
			mesh.surface_add_vertex(get_heightv.call(3))
			mesh.surface_add_vertex(get_heightv.call(2))
			mesh.surface_add_vertex(get_heightv.call(0))
	mesh.surface_end()
	return mesh

func _thread_generate(pos, config):
	var result = generate_chunk_mesh(pos, config)
	on_done.emit(result)

func get_mesh(pos: Vector2i, config: ChunkConfig) -> Mesh:
	thread.start(_thread_generate.bind(pos, config))
	var result = await on_done
	return result
