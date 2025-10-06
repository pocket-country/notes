class_name ANote extends Resource
# --- A class for a single note.  All the data, all the methods to go from this to that

@export var midi_note_number: int	# 0 - 127

# cached lookup parameters - these are all derived from above but 
# looked up and stored for quick access
var freq: float		# assume equal temperament tuning

#so the pitches below are (offsets) relative to this octave number
var octave: int		

# for our (not often used) chromatic or half tone scales
var chromatic_pitch: int	# or offset 0..11 index into semi-tone within a given octave scale
var name: String

# for our diatonic scales
var diatonic_pitch: int		# or offset 0..7, index into diatonic scale pitch offset lookup table
var solf: String			# name for diatonic pitch

func _init(init_midi_note: int):
	if init_midi_note < 0 or init_midi_note > 127:
		print("Bad MIDI Number")  #TODO figure out how to throw an error
		return
		
	set_note(init_midi_note) 


func set_note(midi_number: int):
	midi_note_number = midi_number
		
	# set up cached lookup values
	freq = Theory.FREQUENCY_TABLE[midi_number]
	octave = floor((midi_number - 12) / 12)
	
	chromatic_pitch = midi_number % 12
	name = Theory.NOTE_NAME[chromatic_pitch]
	
	## a LOT of thinking in this line of code.
	# Diatonic_pitch is actually an index into an array that gives an offset
	diatonic_pitch = Theory.SCALE_OFFSETS[Theory.MODE_MAJOR].find((chromatic_pitch - PlayContext.active_key_tonic) % 12)
	solf = Theory.SOLFEG[diatonic_pitch]

#
## Functions to return values (getters)
func get_freq() -> float:
	return(freq)

func get_octave() -> int:
	return(octave)

func get_chromatic_name() -> String:
	return(name)

func get_solfeg_name() -> String:
	return(solf)


# functions to run up or down a scale
func bump_chromatic(dir: int) -> int:   # or should I return a freq?  Or bump and then get so return void?
	var new_note: int = clamp(midi_note_number + dir, 0, 127)
	set_note(new_note)  # should be +/- one, should I check?
	return(midi_note_number)


func bump_diatonic(dir: int) -> int:
	# we can re-use the scale offset lookup table for key
	var key_offset = Theory.SCALE_OFFSETS[Theory.MODE_MAJOR][PlayContext.active_key_tonic]
	
	var trial_pitch = diatonic_pitch + dir
	var new_pitch = posmod(trial_pitch, 7)
	var pitch_offset = Theory.SCALE_OFFSETS[Theory.MODE_MAJOR][new_pitch]
	
	# TODO there is a bug in this line of code.
	var new_octave = octave + floor(trial_pitch/7)

	# add up all the offsets to get new midi note number
	print("Bump Diatonic offsets: Octave: %d  Key: %d  Pitch: %d" % [new_octave, key_offset, pitch_offset])
	var new_note = ((new_octave + 1) * 12) + key_offset + pitch_offset
	set_note(new_note)
	return(midi_note_number)
