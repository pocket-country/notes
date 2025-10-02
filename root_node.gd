extends Node

# Set up for  keyboard click sound effect for note transition
# Attribution:  Thanks to https://opengameart.org/users/bluszcz for this:
const CLICK_SFX = preload("res://keyboard01.ogg") 
@onready var click_player: AudioStreamPlayer2D = $klickPlayer

# Set up the main "root" note
@onready var player: AudioStreamPlayer2D = $RootNote
var playback: AudioStreamGeneratorPlayback
var sample_hz: float
#var note_hz: float = 440.0 # the frequency of the note we want to play
var phase: float = 0.0

# an evil global variable holding the midi note number of the tone playing
var current_midi_note: int = 60   # this should be middle C

# Define the sample rate (44100 Hz is standard CD quality)
const MIX_RATE: float = 44100.0

# Set the current key - this will be a ... humm ... note name? Number?


func _ready():
	# set up transition sfx
	click_player.stream = CLICK_SFX

	#
	#generator_stream.mix_rate = MIX_RATE
	# Set the buffer length (lower = less latency, more CPU)
	#generator_stream.buffer_length = 0.05 
	# Assign the new resource to the player
	#player.stream = generator_stream
	#sample_hz = generator_stream.mix_rate
	
	# 3. Start playback (This creates the internal 'playback' object)
	# So I think that because this is hear the tone just plays until we quit ???
	player.play()
	# 4. Get the playback object (it is no longer null)
	playback = player.get_stream_playback()

	# NOTE: You should confirm playback is not null before continuing, 
	# but in _ready, it should usually be available right after play().
	if playback == null:
		print("ERROR: Failed to get AudioStreamGeneratorPlayback!")
		set_process(false) # Stop processing if it failed


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
				bump_note(1) 
			if event.keycode == KEY_S:
				bump_note(-1)


func _process(_delta):
	# Dont want continuous ... so input handling goes into _input. 
	# The below is for something like player movement in space.
	# handle movement keys
	# Get a Vector2 representing the combined WASD state
	# This automatically normalizes diagonal input and assigns keys
	# input_vector.x is A/D (-1.0 to 1.0)
	# input_vector.y is W/S (-1.0 to 1.0)
	# var input_vector = Input.get_vector("key_left", "key_right", "key_up", "key_down")
	# var note_bump = sign(input_vector.y)
	
	#tone generation stuff
	if playback == null:
		return

	var note_hz = Notes.FREQUENCY_TABLE[current_midi_note]
	var increment: float = note_hz / sample_hz
	var frames_available: int = playback.get_frames_available()

	for i in range(frames_available):
		# Calculate the sample value (-1.0 to 1.0)
		# this is where we are generating the waveform currently sin wave
		var sample_value: float = sin(phase * TAU)
		
		# Push a stereo frame (left and right channel)
		playback.push_frame(Vector2.ONE * sample_value)
		
		# Advance the phase and wrap it back to 0.0 if it exceeds 1.0
		phase = fmod(phase + increment, 1.0)


func bump_note(dir):
	# up and down a musical vs chromatic scale is a bit trickier
	# decompose into an octave and a pitch
	var pitch: int = get_pitch(current_midi_note)
	var octave: int = get_octave(current_midi_note)
	
	# are you a good witch or a bad witch?
	if dir == 1:  #up is simple
		pitch = (pitch + Notes.SCALE_INTERVALS[0][pitch]) % 7  # fix in major mode for now
	else: # down is more complicated, we have to back up to find the right interval
		var back_up: int = (pitch - 1 + 7) % 7  # because GG does not think that mod works corrcctly on negative numbers TODO check this
		pitch = (pitch + Notes.SCALE_INTERVALS[0][back_up]) % 7
			
	current_midi_note = clamp(get_midi(octave, pitch), 0, 127)
	print(current_midi_note)
	show_note(current_midi_note)


func show_note(midi_note):
	var scale_midi_note: int = midi_note % 12
	var scale_note_name: String = Notes.NOTE_NAME[scale_midi_note]
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




	
