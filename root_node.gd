extends Node
# --- RootNode (root_node.gd) --- Application Root

# Set up for  keyboard click sound effect for note transition
# Attribution:  Thanks to https://opengameart.org/users/bluszcz for this:
const CLICK_SFX = preload("res://keyboard01.ogg") 
@onready var click_player: AudioStreamPlayer2D = $klickPlayer

# Set up the main "root" notes, for a three note chord
@onready var Voice1: AudioStreamPlayer2D = $Voice1
@onready var Voice2: AudioStreamPlayer2D = $Voice2
@onready var Voice3: AudioStreamPlayer2D = $Voice3

# an evil global variable holding midi note number & freq 
# for now, for testing, when not usin the voice articulation nodes
var current_midi_note: int = 69   # A4 for tuning
var tuning_hz: float = 440.0 

func _ready():
	# set up transition sfx
	click_player.stream = CLICK_SFX
	
	# NOTE voice/note stream init moved into that node!
	Voice1.start_note(tuning_hz)


func _process(delta):
	pass
	
	
func _input(event):
	if event is InputEventKey:
		
		print("Keycode: %d, key label: %s" % [event.keycode, OS.get_keycode_string(event.keycode)])
		print("  Pressed: %s" % [event.pressed])
		print("  Echo: %s" % [event.echo])
		print("-")
		
		if event.pressed:
			if not event.echo and (event.keycode == KEY_W or event.keycode == KEY_S):
				# 'gear shift' note change sound
				click_player.play() 
				
			if event.keycode == KEY_Q:
				get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
				get_tree().quit()
				
			if event.keycode == KEY_V:
					if event.shift_pressed:
						print("Raising Volume --- not implemented yet")
					else:
						print("Lowering Volume --- not impemented yet")
				
		else: # in a released state?  Actually change the note here
			if event.keycode == KEY_W:
				#bump_note(1) 
				print("Bump Note Currently Broken")
				Voice2.start_note(tuning_hz * 2.0)
			if event.keycode == KEY_S:
				#bump_note(-1)
				print("Bump Note Currently Broken")
				Voice3.start_note(tuning_hz * 0.5)


func show_note(voice: AudioStreamPlayer2D, slot: Label) -> void:
	
	var scale_note_name: String = voice.get_chromatic_name()
	slot.text = scale_note_name
	
