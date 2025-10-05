class_name SynthNote extends AudioStreamPlayer2D
##
## Voice one note.  
##

# The Playback Object - talks to the audio buffer.
var _playback: AudioStreamGeneratorPlayback

# Sample Rate: The hardware's speed (e.g., 44100 Hz).
# Set by the stream generator (can change in editor)
var _sample_hz: float

## These three parameters control the actual sound waveform
# Wave Frequency: The pitch we want to hear (e.g., 440 Hz).  
# Called pulse cause we are geeks
var _pulse_hz: float

# Phase Tracker: Where we are in the current cycle (0.0 to 1.0). 
# Still pondering but this unrolls against time 
var _phase: float = 0.0

# Amplitude Control: How loud the note is (0.0 to 1.0).
# Variable to control the volume/amplitude (0.0 = silence, 1.0 = full volume)
var _amplitude: float = 0.0


func _process(_delta: float) -> void:
	# keep the note going.  Start note does the setup (and change control).
	# put a guard condition on this so it does not try to execute until 
	# the playback mechanism is in place (multi threading)
	if _playback != null:
		_fill_buffer()


# Functions to Control the Note 
# This is what you call to silence the note
# It keeps the whole waveform thing rolling along, just mods it to be zero volume
func off():
	_amplitude = 0.0
	# Optional: You could fade out here for a smoother stop

func on():
	_amplitude = 1.0

func sounding() -> bool:
	return _amplitude > 0


# This is what you call to play the note - both initially 
# and when changing sound parameters
func start_note(target_frequency: float, target_amplitude = null, target_phase = null):
	# amp & phase should be floats, not typing them so can handle default of null
	print("In Start Note")
	# Gemini gave me a lot of reasons why this is not in a ready function.
	# Has to do with timing and sync issues, threading ... currently above my pay grade.
	# but still, some stuff only happens once ... 
	
	## Setup once per note instance
	if _playback == null: 
		# Ensure the AudioStreamGenerator resource is assigned.
		if not stream is AudioStreamGenerator:
			print("ERROR: AudioStreamGenerator resource not set on player!")
			return
		# Get the hardware's sample rate & set buffer length (affects responsivienes)
		_sample_hz = stream.mix_rate
		stream.buffer_length = 0.05
		
		# Tell the AudioStreamPlayer to start demanding frames.
		play()
		
			# Get the object that lets the script talk to the audio server.
		_playback = get_stream_playback()
		
	# Set the note parameters.  This happens every time we start a new note
	# or change a currently playing note.  The fill buffer process just keeps 
	# generating frames in the background with whatever we set here.
	
	#  amp & phase params default to null ==> no change
	_pulse_hz = target_frequency
	if target_amplitude != null:
		_amplitude = target_amplitude
	
	if target_phase != null:
		_phase = target_phase


# fill the something buffer with samples - which are just amplitude of the wave at the moment
func _fill_buffer():
	#Check the audio server's demand.  Weird nomenclature.  Means frame SLOTS available
	var frames_available = _playback.get_frames_available() 

	if frames_available == 0:
		return # Buffer is full, nothing to do
		
	# Calculate the constant phase step size for this pitch
	var increment = _pulse_hz / _sample_hz
	
	for i in range(frames_available):
		
		# Calculate the raw sample value
		##  NOTE This is where we would implement something other than a pure sine wave tone
		var raw_sample = sin(_phase * TAU)
		
		# APPLY THE AMPLITUDE (This is the key step!)
		var final_sample = raw_sample * _amplitude 
		
		# Push the final attenuated stereo frame to the buffer
		# Note we have two channels, as this is 2D stereo sound
		_playback.push_frame(Vector2(final_sample, final_sample))
		
		# Advance the phase (always advance, even when silent)
		_phase = fmod(_phase + increment, 1.0)
