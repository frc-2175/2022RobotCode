extends Node

class_name SimClient

var devices = {}

export var websocket_url = "ws://127.0.0.1:3300/wpilibws"
var client = WebSocketClient.new()
var reconnect_timer = Timer.new()

export(Array, String) var print_if_message_contains = []

var connected: bool = false

func _ready():
	client.connect("server_close_request", self, "_close_requested")
	client.connect("connection_closed", self, "_close")
	client.connect("connection_error", self, "_close")
	client.connect("connection_established", self, "_connected")
	client.connect("data_received", self, "_on_data")
	
	reconnect_timer.connect("timeout", self, "reconnect")

	reconnect()

func connect_to_sim() -> bool:
	var err = client.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect: ", err)
	return err == OK

func reconnect():
	connected = false
	var success = connect_to_sim()
	if !success:
		print("Retrying in 5s...")
		reconnect_timer.start(5)

func _close_requested(code, reason):
	print("Server requested close: ", code, reason)
	print("Reconnecting...")
	reconnect()

func _close(was_clean = false):
	print("Connection closed. Reconnecting...")
	reconnect()

func _connected(proto = ""):
	print("Connected to simulator.")
	connected = true
	client.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)

func _on_data():
	var json = client.get_peer(1).get_packet().get_string_from_utf8()
	var p = JSON.parse(json)
	if p.error != OK:
		print("Malformed data: ", json)
		return
	
	var do_print = false
	for substring in print_if_message_contains:
		if substring in json:
			do_print = true
			break
	if do_print:
		print(json)
	
	var type = p.result["type"]
	var id = p.result["device"]
	var data = p.result["data"]
	
	if not type in devices:
		devices[type] = {}
	
	if not id in devices[type]:
		devices[type][id] = {}
	
	for key in data:
		devices[type][id][key] = data[key]

func get_data(type, id, field, default):
	if not type in devices:
		return default
	if not id in devices[type]:
		return default
	if not field in devices[type][id]:
		return default
	return devices[type][id][field]

func send_data(type, id, fields):
	if not client.get_peer(1).is_connected_to_host():
		return

	var msg = {
		"type": type,
		"device": id,
		"data": fields,
	}
	client.get_peer(1).put_packet(JSON.print(msg).to_utf8())

func _process(_delta):
	client.poll()
