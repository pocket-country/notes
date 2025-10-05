extends Node
# --- RootNode (root_node.gd) --- Application Root

# Set up for  keyboard click sound effect for note transition
# Attribution:  Thanks to https://opengameart.org/users/bluszcz for this:
const CLICK_SFX = preload("res://keyboard01.ogg") 
@onready var click_player: AudioStreamPlayer2D = $klickPlayer

# Set up the  audio players, for a three note chord
@onready var Voice1: AudioStreamPlayer2D = $Voice1
@onready var Voice2: AudioStreamPlayer2D = $Voice2
@onready var Voice3: AudioStreamPlayer2D = $Voice3

# corresponding display "slots"
var slots = []

# Generate the inital note resource/objects
var Chord_root = ANote.new(69)		# A4
var Chord_3rd = ANote.new(73)		# C#5
var Chord_5th = ANote.new(76)		# E5

# an evil global variable holding midi note number & freq 
# Set to A4 for tuning, currently app starts voicing this note.
var current_midi_note: int = 69   # A4 for tuning
var tuning_hz: float = 440.0 

func _ready():
	# set up note transition sfx
	click_player.stream = CLICK_SFX

	# load up display slot references
	slots.append($UIRoot/BG/MC/VBox/Display/NotePanel/VBox/Slot1)
	slots.append($UIRoot/BG/MC/VBox/Display/NotePanel/VBox/Slot2)
	slots.append($UIRoot/BG/MC/VBox/Display/NotePanel/VBox/Slot3)
	
	# start making noise
	# NOTE voice/note stream init moved into synth note (a mod of audio player) node!
	# NOTE we are only turning on the root, the others off via the amp. parameter
	
	"""
PHASE ALIGNMENT RATIONALE (Why sequential start_note() is OK):

This application uses sequential calls to start audio voices for chords (e.g., Voice1.start(), Voice2.start(), etc.), 
which results in a small, out-of-phase temporal offset due to GDScript execution time.

1.  **Delay:** The gap between calls is extremely small, estimated to be under 0.05 milliseconds (50 microseconds).
2.  **Audibility:** The human ear's temporal fusion threshold is 10-20 ms. The calculated delay is hundreds of times smaller than this threshold.
3.  **Conclusion:** The notes will be perceived as starting simultaneously. Advanced phase-sync techniques (like those in ChucK) are not necessary for a clean, stable attack in this context. 
The minimal phase difference is masked by the voice's amplitude envelope.

This would be a hard problem to solve given my level of expertise and tool set we are using.  For 
a real solution, we would turn to the ChucK musical programming system.

"""
	Voice1.start_note(Chord_root.get_freq(), 1.0, 0.0)
	# be sure to set the color correctly
	slots[0].get_node("Box/OnOff").color = Color("#FFA07A")
	Voice2.start_note(Chord_3rd.get_freq(), 0.0, 0.0)
	slots[1].get_node("Box/OnOff").color = Color("#D4CAA3")
	Voice3.start_note(Chord_5th.get_freq(), 0.0, 0.0)
	slots[2].get_node("Box/OnOff").color = Color("#D4CAA3")


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
						PlayContext.adjust_volume(+0.06)
					else:
						PlayContext.adjust_volume(-0.06)
			
			# turn on/of notes in the chord
			# TODO outline for labels when we get to it #222222
			if event.keycode == KEY_1:
				if Voice1.sounding() == true:
					Voice1.off()
					slots[0].get_node("Box/OnOff").color = Color("#D4CAA3")
				else:
					Voice1.on()
					slots[0].get_node("Box/OnOff").color = Color("#FFA07A")
			
			if event.keycode == KEY_2:
				if Voice2.sounding() == true:
					Voice2.off()
					slots[1].get_node("Box/OnOff").color = Color("#D4CAA3")
				else:
					Voice2.on()
					slots[1].get_node("Box/OnOff").color = Color("#FFA07A")
			
			if event.keycode == KEY_3:
				if Voice3.sounding() == true:
					slots[2].get_node("Box/OnOff").color = Color("#D4CAA3")
					Voice3.off()
				else:
					Voice3.on()
					slots[2].get_node("Box/OnOff").color = Color("#FFA07A")
			
				
		else: # in a released state?  Actually change the note here
			# NOTE we always operate on all the voices so they stay in sync 
			if event.keycode == KEY_W:
				Chord_root.bump_chromatic(+1)
				Chord_3rd.bump_chromatic(+1)
				Chord_5th.bump_chromatic(+1)
				Voice1.start_note(Chord_root.get_freq()) 
				Voice2.start_note(Chord_3rd.get_freq())
				Voice3.start_note(Chord_5th.get_freq())
				# for testing Voice2.start_note(tuning_hz * 2.0)
			if event.keycode == KEY_S:
				Voice1.bump_chromatic(-1) 
				Voice2.bump_chromatic(-1)
				Voice3.bump_chromatic(-1)
				Voice1.start_note(Chord_root.get_freq()) 
				Voice2.start_note(Chord_3rd.get_freq())
				Voice3.start_note(Chord_5th.get_freq())
				# for testing Voice3.start_note(tuning_hz * 0.5)


func show_note(voice: AudioStreamPlayer2D, slot: Label) -> void:
	
	var scale_note_name: String = voice.get_chromatic_name()
	slot.text = scale_note_name
	
