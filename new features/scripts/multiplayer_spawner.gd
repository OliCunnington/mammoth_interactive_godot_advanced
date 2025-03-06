extends MultiplayerSpawner

var peer = ENetMultiplayerPeer.new()
var hostButton
var joinButton

@export var player_scene : PackedScene
@export var spawn_position : Vector3



func multiplayerControl():
	pass


func _on_host():
	if !GlobalVar.hosted and !GlobalVar.joined:
		GlobalVar.hosted = true
		peer.create_server(1337)
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(_add_player)
		_add_player(1)


func _add_player(id):
	var player = player_scene.instantiate()
	get_parent().add_child(player, true)
	player.position = spawn_position
	#call_deferred("add_child", player)


func _on_join():
	if !GlobalVar.hosted and !GlobalVar.joined:
		GlobalVar.hosted = true
		peer.create_client("localhost", 1337)
		multiplayer.multiplayer_peer = peer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
