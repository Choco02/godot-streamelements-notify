extends Node


export var websocket_url = "ws://localhost:8080"

var _client = WebSocketClient.new()

func _ready():
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	_client.connect("data_received", self, "_on_data")

	var err = _client.connect_to_url(websocket_url, ["lws-mirror-protocol"])
	if err != OK:
		print("Unable to connect")
		set_process(false)

func _closed(was_clean = false):
	print("Closed, clean: ", was_clean)
	set_process(false)

func _connected(proto = ""):
	print("Connected with protocol: ", proto)
	_client.get_peer(1).put_packet("Test packet".to_utf8())


func _on_data():
	var ws_data = JSON.parse(_client.get_peer(1).get_packet().get_string_from_utf8() as String)
	if typeof(ws_data.result) != TYPE_DICTIONARY:
		return

	print("Got data from server: ", JSON.print(ws_data.result, "\t"))

	if ws_data.result.type != "tip":
		# change here if you want to receive another notify
		return

	print("notification type: " + ws_data.result.type)

#	data.result tip format:
#	{
#		"channel": "",
#		"provider": "twitch",
#		"type": "tip",
#		"createdAt": "2024-01-17T23:02:36.625Z",
#		"data": {
#			"amount": 1,
#			"currency": "BRL",
#			"username": "",
#			"message": "Teste",
#			"avatar": "https://cdn.streamelements.com/static/default-avatar.png"
#		}
#	}

	var donator = ws_data.result.data.username
	var amount = ws_data.result.data.amount
	var currency = ws_data.result.data.currency
	# var message = ws_data.result.data.message
	print(donator + " doou " + str(amount) + " " + currency)
	# print("%s doou %d %s" % [donator, amount, currency])

func _process(_delta):
	_client.poll()
