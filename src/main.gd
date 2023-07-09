extends Node

@export var level_scenes: Array[PackedScene]
@export var music_resources: Array[AudioStreamMP3]
var level_nb: int = 0

func end_game():
	level_nb = 0

func load_level():
	for child in $World.get_children():
		child.queue_free()
	if level_nb == level_scenes.size():
		end_game()
	var level: Level = level_scenes[level_nb].instantiate()
	$World.add_child(level)
	level.level_complete.connect(_on_level_complete)
	level.game_over.connect(_on_level_game_over)


func _ready():
	play_music()
	load_level()


func _on_level_complete(surviving_zombies):
	level_nb += 1
	load_level()

func _on_level_game_over():
	load_level()
	

func play_music():
	$AudioStreamPlayer2D.stream = music_resources.pick_random()
	$AudioStreamPlayer2D.play()

func _on_audio_stream_player_2d_finished():
	play_music()
