extends Node

# Set up for  keyboard click sound effect for note transition
# Attribution:  Thanks to https://opengameart.org/users/bluszcz for this:
const CLICK_SFX = preload("res://keyboard01.ogg") 
@onready var click_player: AudioStreamPlayer2D = $klickPlayer

# Set up the main "root" note
@onready var Voice1: AudioStreamPlayer2D = $Voice1

# an evil global variable holding the midi note number of the tone playing
var current_midi_note: int = 60   # this should be middle C
# and another holding a frequncy for testing
var tuning_hz: float = 440.0 

func _ready():
	# set up transition sfx
	click_player.stream = CLICK_SFX
	
	# NOTE voice/note stream init moved into that node!
	Voice1.start_note(tuning_hz)

func _input(event):
	if event is InputEventKey:
		if event.pressed and not event.echo:
			if event.keycode == KEY_W or event.keycode == KEY_S:
				# 'gear shift' note change sound
				click_player.play() 
			if event.keycode == KEY_Q:
				get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
				get_tree().quit
			if event.keycode == KEY_V:
					if event.shift_pressed:
						print("Raising Volume --- not implemented yet")
					else:
						print("Lowering Volume --- not impemented yet")
				
		else: # in a released state?  Actually change the note here
			if event.keycode == KEY_W:
				#bump_note(1) 
				print("Bump Note Currently Broken")
			if event.keycode == KEY_S:
				#bump_note(-1)
				print("Bump Note Currently Broken")


func _process(_delta):
	pass


func bump_note(dir):
	# up and down a musical vs chromatic scale is a bit trickier
	# decompose into an octave and a pitch
	var pitch: int = get_pitch(current_midi_note)
	var octave: int = get_octave(current_midi_note)
	
	# are you a good witch or a bad witch?
	if dir == 1:  #up is simple
		pitch = (pitch + Theory.SCALE_OFFSETS[0][pitch]) % 7  # fix in major mode for now
	else: # down is more complicated, we have to back up to find the right interval
		var back_up: int = (pitch - 1 + 7) % 7  # because GG does not think that mod works corrcctly on negative numbers TODO check this
		pitch = (pitch + Theory.SCALE_OFFSETS[0][back_up]) % 7
			
	current_midi_note = clamp(get_midi(octave, pitch), 0, 127)
	print(current_midi_note)
	show_note(current_midi_note)


func show_note(midi_note):
	var scale_midi_note: int = midi_note % 12
	var scale_note_name: String = Theory.NOTE_NAME[scale_midi_note]
	# TODO this is a kludge.  Will want to set it up so we write 
	# into one of three note lable slots ... 
	$UIRoot/Background/MarginContainer/VBoxContainer/Row1/Label.text = scale_note_name

## handle note composition/decompositon

# return the octave number for a midi note.  Off by 1, what musicians call "4" will be a "5"?
func get_octave(midi_number) -> int:
	return floor(midi_number/12)

# and the companion decompositoin, the pitch within the octave
func get_pitch(midi_number) -> int:
	return midi_number % 12

#combine pitch and octave to get back the midi number
func get_midi(octave, pitch) -> int:
	return (octave * 12 ) + pitch




	
