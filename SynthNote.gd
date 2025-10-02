class_name SynthNote extends AudioStreamPlayer2D
##
## Voice one note.  Ho I don't have hands-on experience making "boneheaded mistakes,"ld necessary playback apparatus.
##

# The Playback Object - talks to the audio buffer.
var _playback: AudioStreamGeneratorPlayback
# Sample Rate: The hardware's speed (e.g., 44100 Hz).
# Set by the stream generator (can change in editor)
var _sample_hz: float

# Wave Frequency: The pitch we want to hear (e.g., 440 Hz).  
# Called pulse cause we are geeks
var _pulse_hz: float

# Phase Tracker: Where we are in the current cycle (0.0 to 1.0). 
# Still pondering but this unrolls against time 
var _phase: float = 0.0

# Amplitude Control: How loud the note is (0.0 to 1.0).
# Variable to control the volume/amplitude (0.0 = silence, 1.0 = full volume)
var _amplitude: float = 0.0


func _process(delta: float) -> void:
	# keep the note going.  Start note does the setup.
	# put a guard condition on this so it does not try to execute until 
	# the playback mechanism is in place (multi threading)
	print(delta)
	if _playback != null:
		print("filling buffer")
		_fill_buffer()


# Functions to Control the Note
# This is what you call to silence the note
func stop_note():
	_amplitude = 0.0
	# Optional: You could fade out here for a smoother stop

# This is what you call to play the note
func start_note(frequency: float, target_amplitude: float = 1.0):
	print("In Start Note")
	# target_amplitude 1/0 is our note on/off.  Better name?
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
		await play()
		
			# Get the object that lets the script talk to the audio server.
		_playback = get_stream_playback()
		
	# Set the note parameters.  This happens every time we start a new note
	# or change a currently playing note
	_pulse_hz = frequency	# new pitch
	_phase = 0.0 # Start the wave cleanly at the beginning of its cycle
	_amplitude = target_amplitude # Start playing at full volume (can be customized)

	# Immediately fill the buffer once to prevent glitches.
	#_fill_buffer()

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
		# This is where we would implement something other than a pure sine wave tone
		var raw_sample = sin(_phase * TAU)
		
		# APPLY THE AMPLITUDE (This is the key step!)
		var final_sample = raw_sample * _amplitude 
		
		# Push the final attenuated stereo frame to the buffer
		# Note we have two channels, as this is 2D stereo sound
		_playback.push_frame(Vector2(final_sample, final_sample))
		
		# Advance the phase (always advance, even when silent)
		_phase = fmod(_phase + increment, 1.0)
