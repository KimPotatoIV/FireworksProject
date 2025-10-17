extends Node2D

##################################################
const PARTICLE_TEXTURE: Texture = preload("res://sprites/particle.png")
const RISE_STREAM: AudioStream = preload("res://audio/rise.mp3")
const EXPLODE_STREAM: AudioStream = preload("res://audio/explode.mp3")

const SCREEN_SIZE: Vector2 = Vector2(1920.0, 1080.0)
const EXPLOSION_DURATION: float = 1.0
const RISE_SPEED: float = -2.0
const PARTICLE_LIFETIME_AFTER_STOP: float = 8.0

@onready var rise_particles_node: GPUParticles2D = $RiseGPUParticles2D
@onready var explode_particles_node: GPUParticles2D = $ExplodeGPUParticles2D
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

var is_launched: bool = false
var is_exploded: bool = false
var is_explode_audio_played: bool = false
var explosion_position_y: float
var explosion_timer: float = 0.0

##################################################
func _ready() -> void:
	explosion_position_y = \
		randf_range(SCREEN_SIZE.y * 0.33, SCREEN_SIZE.y * 0.66)
	
	_init_rise_particles()
	_init_explode_particles()

##################################################
func _process(delta: float) -> void:
	if is_launched and not is_exploded:
		rise_particles_node.global_position += Vector2(0.0, RISE_SPEED)
	
	if rise_particles_node.global_position.y <= explosion_position_y:
		is_exploded = true
		explode_particles_node.global_position = \
			rise_particles_node.global_position
		
		_explode()
	
	if is_exploded:
		explosion_timer += delta
		if explosion_timer >= EXPLOSION_DURATION:
			explode_particles_node.emitting = false
			
			await get_tree().create_timer(PARTICLE_LIFETIME_AFTER_STOP).timeout
			queue_free()

##################################################
func _init_rise_particles() -> void:
	rise_particles_node.global_position = \
		Vector2(randf_range(0.0, SCREEN_SIZE.x), SCREEN_SIZE.y)
	
	rise_particles_node.emitting = false
	rise_particles_node.amount = 40
	rise_particles_node.texture = PARTICLE_TEXTURE
	rise_particles_node.lifetime = 0.3
	rise_particles_node.randomness = 0.8
	
	var p_material: ParticleProcessMaterial = ParticleProcessMaterial.new()
	p_material.initial_velocity_min = -50.0
	p_material.initial_velocity_max = 50.0
	
	var c_ramp: GradientTexture1D = GradientTexture1D.new()
	var gradient_value: Gradient = Gradient.new()
	gradient_value.add_point(0.0, Color(1.0, 1.0, 1.0, 1.0))
	gradient_value.add_point(0.3, Color(1.0, 0.8, 0.3, 0.9))
	gradient_value.add_point(1.0, Color(1.0, 0.4, 0.0, 0.0))
	c_ramp.gradient = gradient_value
	p_material.color_ramp = c_ramp
	rise_particles_node.process_material = p_material
	
	var material_value: CanvasItemMaterial = CanvasItemMaterial.new()
	material_value.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	rise_particles_node.material = material_value

##################################################
func _init_explode_particles() -> void:
	explode_particles_node.emitting = false
	explode_particles_node.amount = 500
	explode_particles_node.texture = PARTICLE_TEXTURE
	explode_particles_node.lifetime = 1.0
	explode_particles_node.randomness = 0.8
	
	var p_p_material: ParticleProcessMaterial = ParticleProcessMaterial.new()
	p_p_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	p_p_material.emission_sphere_radius = 15.0
	p_p_material.direction = Vector3(0.0, -1.0, 0.0)
	p_p_material.spread = 180.0
	p_p_material.initial_velocity_min = 200.0
	p_p_material.initial_velocity_max = 400.0
	
	var c_texture: CurveTexture = CurveTexture.new()
	var c_value: Curve = Curve.new()
	c_value.add_point(Vector2(0.75, 1.0))
	c_value.add_point(Vector2(1.0, 0.0))
	c_texture.curve = c_value
	p_p_material.scale_curve = c_texture
	
	var gradient_texture_1d: GradientTexture1D = GradientTexture1D.new()
	var g_value: Gradient = Gradient.new()
	g_value.add_point(0.0, Color(1.0, 1.0, 1.0, 1.0))
	g_value.add_point(0.2, Color(1.0, 0.5, 0.0, 1.0))
	g_value.add_point(0.4, Color(1.0, 0.2, 0.6, 1.0))
	g_value.add_point(0.6, Color(0.3, 0.5, 1.0, 1.0))
	g_value.add_point(0.8, Color(0.2, 1.0, 0.4, 1.0))
	g_value.add_point(1.0, Color(0.0, 0.0, 0.0, 0.0))
	gradient_texture_1d.gradient = g_value
	p_p_material.color_ramp = gradient_texture_1d
	explode_particles_node.process_material = p_p_material
	
	var c_i_material: CanvasItemMaterial = CanvasItemMaterial.new()
	c_i_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	explode_particles_node.material = c_i_material

##################################################
func _explode() -> void:
	rise_particles_node.emitting = false
	explode_particles_node.emitting = true
	
	if not is_explode_audio_played:
		is_explode_audio_played = true
		audio_player.stream = EXPLODE_STREAM
		audio_player.play()

##################################################
func launch() -> void:
	rise_particles_node.emitting = true
	is_launched = true
	
	audio_player.stream = RISE_STREAM
	audio_player.play()
