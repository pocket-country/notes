extends Node
# -- Theory.gd -- 
# Autoload to define musical notes, scales, all that structural theory stuff.
# "I get by with a little help from my friends ...
# Notes.gd (Auto-load or Utility Script)

const A4_FREQ = 440.0
const TWELFTH_ROOT_OF_TWO = 1.059463094359
const MIDI_NOTE_A4 = 69 # MIDI number for A4
const MAX_MIDI_NOTE = 127

var FREQUENCY_TABLE = {} # Dictionary to store pre-calculated frequencies

 # lookup to convert "scale" midi notes 0 - 12 to their text name
const NOTE_NAME: Array[String] = ["C ", "C#", "D ", "D#", "E ", "F ", "F#", "G ", "G#", "A ", "A#", "B "]
const SOLFEG: Array[String] = ["Do", "Re", "Mi", "Fa", "So", "La", "Ti"]

# These set up for walking up and down what we think of as musical scales in a given key
# The big constant array gives the half-step interval to the next note
# (you will also have to adjust for key ... but ok hold that though)
# Constants for easy index lookup (Our Little Friend hates enums)
const MODE_MAJOR 			= 0
const MODE_MINOR 			= 1
const MODE_MIXOLYDIAN	 	= 2
const MODE_DORIAN   		= 3

# The structure is: [Mode Index][Scale Step]
# The numbers are the TOTAL half-step distance from the ROOT (Do).
# Note: This array has 7 elements, corresponding to Do through Ti (0-6).
const SCALE_OFFSETS = [
	# 0: Ionian (Major) - W W H W W W H
	# Offsets: 0 +2 +2 +1 +2 +2 +2 = [0, 2, 4, 5, 7, 9, 11]
	[0, 2, 4, 5, 7, 9, 11], 
	# 1: Aeolian (Natural Minor) - W H W W H W W
	# Offsets: 0 +2 +1 +2 +2 +1 +2 = [0, 2, 3, 5, 7, 8, 10],
	[0, 2, 3, 5, 7, 8, 10], 
	# 2: Mixolydian - W W H W W H W
	# Offsets: 0 +2 +2 +1 +2 +2 +1 = [0, 2, 4, 5, 7, 9, 10],
	[0, 2, 4, 5, 7, 9, 10], 
	# 3: Dorian - W H W W W H W
	# Offsets: 0 +2 +1 +2 +2 +2 +1 = [0, 2, 3, 5, 7, 9, 10]
	[0, 2, 3, 5, 7, 9, 10] 
]


func _ready():
	# To get the frequency of Middle C (MIDI 60) in your audio generator:
	# var c4_freq = Notes.FREQUENCY_TABLE[60] # Simple, fast lookup
	
	# Loop through the relevant MIDI range (0 to 127)
	for midi_note in range(MAX_MIDI_NOTE + 1):  #range does not include limit hence + 1
		# Calculate 'n': the number of half steps away from A4 (MIDI 69)
		var n = midi_note - MIDI_NOTE_A4
		
		# Calculate the frequency using the exponential formula
		var frequency = A4_FREQ * pow(TWELFTH_ROOT_OF_TWO, n)
		
		# Store it for fast lookup later
		FREQUENCY_TABLE[midi_note] = frequency
