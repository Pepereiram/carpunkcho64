extends Node3D

@export var player_1_scene: PackedScene
@export var player_2_scene: PackedScene
@export var enemy_capybara_basic: PackedScene

@onready var playerMarkers: Node3D = $PlayerMarkers
@onready var enemyMarkers: Node3D = $EnemyMarkers


var t = 0
var enemy_spawn_time = 5



# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	print('in game level')
	if Game.multiplayer_test:
		for i in Game.test_players.size():
			var test_player = Game.test_players[i]
			var player_data = Statics.PlayerData.new(i, test_player.name, i, test_player.role)
			Game.players.push_back(player_data)
	
	
	print(Game.players)
	for i in Game.players.size():
		var player_data
		if Game.multiplayer_test:
			var player_test = Game.test_players[i]
			player_data = Statics.PlayerData.new(i, player_test.name, i, player_test.role)
		else:
			player_data = Game.players[i]
		#print(player_data.id, player_data.index, player_data.name, player_data.role)
		
		var player_inst
		if player_data.role == Statics.Role.ROLE_A:
			player_inst = player_1_scene.instantiate()
		elif player_data.role == Statics.Role.ROLE_B:
			player_inst = player_2_scene.instantiate()
		
		player_inst.name = str(player_inst.id)
		player_inst.global_position = playerMarkers.get_child(i).global_position
		player_inst.id = player_data.id
		add_child(player_inst)
		player_data.local_scene = player_inst
		
		
	


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	t = t + delta
	if t > enemy_spawn_time:
		var enemyMarker : Marker3D = enemyMarkers.get_children()[randi() % enemyMarkers.get_child_count()]
		var enemyInstance = enemy_capybara_basic.instantiate()
		enemyInstance.global_transform = enemyMarker.global_transform
		$MultiplayerSpawner.add_child(enemyInstance, true)

		t = 0
