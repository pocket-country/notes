extends Node
# -- PlayContext -- 
# Global context vars for sound play, things like key, mix, volume

# These two variables define the key we are currently playing in 
var active_key_mode: int = Theory.MODE_MAJOR
var active_key_tonic: int	# range 0 - 11, MIDI note number normalized to octave independent offset

var master_bus_volume: float  	# range 0 - 1, converted to DB by audio bus function


func _init():
	active_key_mode = Theory.MODE_MAJOR
	active_key_tonic = 0
	master_bus_volume = 0.75
	
# for display
func get_key_mode_name() -> String:
	return "<NA>"

func get_key_tonic_name() -> String:
	return "<NA>"


func adjust_volume(linear_increment):
	var vol_db: float
	master_bus_volume = clampf(master_bus_volume + linear_increment, 0.0, 1.0)
	# lowest volume you can still hear a little
	if master_bus_volume < 0.02:
		vol_db = -100
	else:
		vol_db = linear_to_db(master_bus_volume)
	print("Volume Setting: %.2f, %.2f" % [master_bus_volume, vol_db])
	AudioServer.set_bus_volume_db(0, vol_db)
