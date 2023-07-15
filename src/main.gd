extends Node

@export var level_scenes: Array[PackedScene]
@export var music_resources: Array[AudioStreamMP3]
@export var game_over_hud: PackedScene
@export var level_complete_hud: PackedScene
@export var game_end_hud: PackedScene

var level_nb := 0
var total_rescued_zombies := 0

func end_game():
	level_nb = 0

func load_level():
	for child in $World.get_children():
		child.queue_free()
	var level: Level = level_scenes[level_nb].instantiate()
	$World.add_child(level)
	level.level_complete.connect(_on_level_complete)
	level.game_over.connect(_on_level_game_over)


func _ready():
	play_music()

func _process(delta):
	if Input.is_action_pressed("restart"):
		load_level()

func end_screen():
	for child in $World.get_children():
		child.queue_free()
	var hud := game_end_hud.instantiate()
	var subtitle: Label = hud.get_node("Subtitle")
	var button: Button = hud.get_node("Button")
	subtitle.text += str(total_rescued_zombies)
	add_child(hud)
	await button.pressed
	hud.queue_free()
	level_nb = 0
	total_rescued_zombies = 0

func _on_level_complete(surviving_zombies: int):
	total_rescued_zombies += surviving_zombies
	
	var hud := level_complete_hud.instantiate()
	var subtitle: Label = hud.get_node("Subtitle")
	var button: Button = hud.get_node("Button")
	subtitle.text += str(surviving_zombies)
	add_child(hud)
	await button.pressed
	level_nb += 1
	hud.queue_free()
	
	if level_nb == 1: # level_scenes.size():
		await end_screen()
	
	load_level()

func _on_level_game_over():
	var hud := game_over_hud.instantiate()
	var button: Button = hud.get_node("Button")
	add_child(hud)
	await button.pressed
	hud.queue_free()
	load_level()

func play_music():
	$AudioStreamPlayer.stream = music_resources.pick_random()
	$AudioStreamPlayer.play()

func _on_audio_stream_player_2d_finished():
	play_music()

func _on_start_screen_start_game():
	$StartScreen.queue_free()
	load_level()
