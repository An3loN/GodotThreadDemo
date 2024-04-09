extends Node

signal on_done(generated_mesh: Mesh)
var thread = Thread.new()
var time = 0.0

func _exit_tree():
	if(thread.is_started()):
		thread.wait_to_finish()

func get_noise_value(pos: Vector2, config: ChunkConfig) -> float:
	var generation_seed = config.generation_seed
	for noise in config.generation_noises:
		noise.noise.seed = generation_seed
	var result = 1
	var noises_dict = config.noises_dict
	result *= noises_dict['main_height'].noise.get_noise_2dv(pos) * noises_dict['main_height'].height_scale
	result *= noises_dict['mountain'].noise.get_noise_2dv(pos) * noises_dict['mountain'].height_scale
	return result
	
func generate_chunk_mesh(config) -> Mesh:
	var heights = []
	var step_x = config.size.x / config.resolution.x
	var step_y = config.size.y / config.resolution.y
	for x in config.resolution.x:
		var row = [] 
		for y in config.resolution.y:
			row.push_back(get_noise_value(Vector2(-config.size.x / 2 + x * step_x, -config.size.y / 2 + y * step_y),
			config) * config.max_height)
		heights.push_back(row)
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(config.noises_dict['main_height'].material)
	for x in config.resolution.x - 1:
		for y in config.resolution.y - 1:
			var local_pos = Vector2(-config.size.x / 2 + x * step_x, -config.size.y / 2 + y * step_y)
			var quad_positions = [
				local_pos,
				local_pos + Vector2.RIGHT * step_x,
				local_pos + Vector2.RIGHT * step_x + Vector2.UP * step_y,
				local_pos + Vector2.UP * step_y
			]
			var quad_heights = [
				heights[x][y+1],
				heights[x+1][y+1],
				heights[x+1][y],
				heights[x][y],
			]
			
			st.add_vertex(Vector3(quad_positions[2].x, quad_heights[2], quad_positions[2].y))
			st.add_vertex(Vector3(quad_positions[1].x, quad_heights[1], quad_positions[1].y))
			st.add_vertex(Vector3(quad_positions[0].x, quad_heights[0], quad_positions[0].y))
			
			st.add_vertex(Vector3(quad_positions[3].x, quad_heights[3], quad_positions[3].y))
			st.add_vertex(Vector3(quad_positions[2].x, quad_heights[2], quad_positions[2].y))
			st.add_vertex(Vector3(quad_positions[0].x, quad_heights[0], quad_positions[0].y))
	st.generate_normals()
	#st.generate_tangents()
	return st.commit()

func _thread_generate(config):
	time = -Time.get_ticks_msec()
	var result = generate_chunk_mesh(config)
	_after_done.call_deferred(result)
	
func _after_done(result):
	on_done.emit(result)
	time += Time.get_ticks_msec()
	print('done in ', time)
	thread.wait_to_finish()

func get_mesh(config: ChunkConfig) -> Mesh:
	#print(config.noises_dict['mountain'].noise.get_noise_2dv(Vector2(1.0, 1.0)))
	if(thread.is_started()): return Mesh.new()
	thread.start(_thread_generate.bind(config))
	var result = await on_done
	return result
