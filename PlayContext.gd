extends Node
# -- PlayContext -- 

# Global context vars for sound play
# These two variables define the key we are currently playing in 
var active_key_mode: int = Theory.MODE_MAJOR
var active_key_tonic: int = 0		# range 0 - 11, normalized to octave independent offset
