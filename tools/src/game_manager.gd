extends Node

signal score_changed(value: int)
signal coins_changed(value: int)
signal lives_changed(value: int)

const SFX_PATHS := {
	"bump": "res://assets/sfx/sfx_00.ogg",
	"coin": "res://assets/sfx/sfx_01.ogg",
	"stomp": "res://assets/sfx/sfx_02.ogg",
	"power": "res://assets/sfx/sfx_03.ogg",
	"hurt": "res://assets/sfx/sfx_04.ogg",
	"die": "res://assets/sfx/sfx_05.ogg",
}

var score := 0
var coins := 0
var lives := 3
var level_completed := false

var _bgm: AudioStreamPlayer
var _sfx: Dictionary = {}

func _ready() -> void:
	_bgm = AudioStreamPlayer.new()
	_bgm.name = "BGM"
	_bgm.stream = load("res://assets/music/bgm_05.ogg")
	_bgm.volume_db = -8.0
	add_child(_bgm)
	_bgm.finished.connect(func() -> void: _bgm.play())
	_bgm.play()
	for key: String in SFX_PATHS.keys():
		var p := AudioStreamPlayer.new()
		p.name = key
		p.volume_db = -4.0
		p.stream = load(SFX_PATHS[key])
		add_child(p)
		_sfx[key] = p

func reset_run() -> void:
	score = 0
	coins = 0
	lives = 3
	level_completed = false
	emit_changes()

func add_score(value: int) -> void:
	score += value
	emit_changes()

func add_coin() -> void:
	coins += 1
	score += 100
	emit_changes()
	play_sfx("coin")

func lose_life() -> bool:
	lives -= 1
	emit_changes()
	return lives <= 0

func add_life() -> void:
	lives += 1
	emit_changes()

func emit_changes() -> void:
	score_changed.emit(score)
	coins_changed.emit(coins)
	lives_changed.emit(lives)

func play_sfx(sfx_name: String) -> void:
	var p: AudioStreamPlayer = _sfx.get(sfx_name)
	if p != null:
		if p.playing:
			p.stop()
		p.play()
