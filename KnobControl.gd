# UNTESTED CODE FROM GEMINI TO POSSIBLY INTEGRATE
# KnobControl.gd extends Control

class_name KnobControl extends Control

# --- Exported Properties (Set in the Inspector) ---
# The parameter this knob controls (e.g., "Harmonic Gain")
@export var parameter_name: String = "Cutoff" 

# The keys used to control the knob
@export var key_positive: Key = KEY_EQUAL # Typically the '+' key
@export var key_negative: Key = KEY_MINUS # Typically the '-' key

# --- Runtime State ---
# The output value, clamped between -1.0 and 1.0
var knob_value: float = 0.0

# How quickly the value changes when a key is pressed
const SENSITIVITY: float = 0.01 

# ----------------------------------------------------
# 1. INPUT HANDLING
# ----------------------------------------------------
func _input(event):
	var delta_change: float = 0.0
	
	# Check for the positive input key
	if event.is_action_pressed(key_positive):
		delta_change = SENSITIVITY
		
	# Check for the negative input key
	elif event.is_action_pressed(key_negative):
		delta_change = -SENSITIVITY
	
	# Apply the change and update the knob state
	if delta_change != 0:
		# Clamp the value between -1.0 and 1.0
		knob_value = clampf(knob_value + delta_change, -1.0, 1.0)
		
		# This signal will alert other nodes (like your SynthNote) that the knob has changed.
		emit_signal("value_changed", knob_value) 
		
		# We can update the visualization here if you add a Label later
		queue_redraw() 


# ----------------------------------------------------
# 2. VISUALIZATION (Optional, but helpful)
# ----------------------------------------------------

# Define the signal so other nodes can connect to it
signal value_changed(new_value: float)

# Simple drawing function to visually represent the knob's value in the editor
func _draw():
	# Draw a background rectangle
	draw_rect(Rect2(Vector2.ZERO, size), Color.GRAY, false)
	
	# Draw a line that represents the knob's current value (-1.0 at left, +1.0 at right)
	var center_y = size.y / 2
	var marker_x = lerp(0, size.x, (knob_value + 1.0) / 2.0)
	
	draw_line(Vector2(marker_x, 0), Vector2(marker_x, size.y), Color.RED, 2.0)
	
	# Draw the parameter name
	#draw_string(get_theme_default_font(), Vector2(5, 15), parameter_name, Color.WHITE)
	#draw_string(get_theme_default_font(), Vector2(5, size.y - 5), str(snappedf(knob_value, 0.01)), Color.YELLOW)
