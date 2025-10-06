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
var Chord_root = ANote.new(60)		# C4  A4
var Chord_3rd = ANote.new(64)		# E4  C#5
var Chord_5th = ANote.new(67)		# G4  E5

# put 'em in an array for easy reference when updating display ...
var chord_notes = []

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
	
	# put 'em in an array for easy reference when updating display ...
	chord_notes.append(Chord_root)
	chord_notes.append(Chord_3rd)
	chord_notes.append(Chord_5th)

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
	update_note_display()

func _input(event):
	if event is InputEventKey:
		
		#print("Keycode: %d, key label: %s" % [event.keycode, OS.get_keycode_string(event.keycode)])
		#print("  Pressed: %s" % [event.pressed])
		#print("  Echo: %s" % [event.echo])
		#print("-")
		
		# We had this set up to generate mechanical noise when switching notes, etc.
		# by playing a sound effect on press and making the change on release.
		# This was fun, but decided (for branch no-mech-noise) to take it out.
		# Leaving some of the unused infrastructure in place ... maybe when I make 
		# visual switches I will build it back out more fully.  A rusty door for key switches, etc.
		
		if event.pressed and not event.echo:
			
			# NOTE we always operate on all the voices so they stay in sync 
			if event.keycode == KEY_W:
				if PlayContext.active_scale_mode == PlayContext.SCALE_CHROMATIC:
					Chord_root.bump_chromatic(+1)
					Chord_3rd.bump_chromatic(+1)
					Chord_5th.bump_chromatic(+1)
				
				if PlayContext.active_scale_mode == PlayContext.SCALE_DIATONIC:
					Chord_root.bump_diatonic(+1)
					Chord_3rd.bump_diatonic(+1)
					Chord_5th.bump_diatonic(+1)
					
				Voice1.start_note(Chord_root.get_freq()) 
				Voice2.start_note(Chord_3rd.get_freq())
				Voice3.start_note(Chord_5th.get_freq())
				
				update_note_display()
			
			if event.keycode == KEY_S:
				if PlayContext.active_scale_mode == PlayContext.SCALE_CHROMATIC:
					Chord_root.bump_chromatic(-1) 
					Chord_3rd.bump_chromatic(-1)
					Chord_5th.bump_chromatic(-1)
				
				if PlayContext.active_scale_mode == PlayContext.SCALE_DIATONIC:
					Chord_root.bump_diatonic(-1) 
					Chord_3rd.bump_diatonic(-1)
					Chord_5th.bump_diatonic(-1)
					
				Voice1.start_note(Chord_root.get_freq()) 
				Voice2.start_note(Chord_3rd.get_freq())
				Voice3.start_note(Chord_5th.get_freq())
				
				update_note_display()
			
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
		# else: # in a released state?  Actually change the note here - UNUSED SEE COMMENT ABOVE


func update_note_display() -> void:
	var solfeg: String
	var note_name: String
	
	for s in range(3):
		note_name = chord_notes[s].get_chromatic_name()
		if note_name.length() == 1:
			note_name = note_name + " "
		
		if PlayContext.active_scale_mode == PlayContext.SCALE_CHROMATIC:
			solfeg = "--"
			
		if PlayContext.active_scale_mode == PlayContext.SCALE_DIATONIC:
			solfeg = chord_notes[s].get_solfeg_name()
			
		slots[s].get_node("Box/Pitch").text = "%s [%d]" % [note_name, chord_notes[s].get_octave()]
		slots[s].get_node("Box/Sof").text = solfeg
		slots[s].get_node("Box/Freq").text = "%.3f" % [chord_notes[s].get_freq()]
