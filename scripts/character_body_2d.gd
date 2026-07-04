extends CharacterBody2D


var movespeed = 100
var runspeed = 200

var gravity = 1200
var gravity_multi = 1.4
var fall_cap = 700
var atk_safety_timer = 0.0
var jumppower = -400
var jump_cut = .5
const maxhealth = 100.0
var health = maxhealth

var isdead :bool = false
var atking = false

var atkcombo = 0
var atktimer = 0
var inaction = false
@onready var hitbox: Area2D = $hitbox
@onready var collision_shape_2d: CollisionShape2D = $hitbox/CollisionShape2D


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var animlock = 0.45
var maxcombotime = 1
var combotime = 0
enum states {idle,walk,run,atk1,atk2,atk3,huet,death ,fall , jump 
}
var state:states = states.idle


func _ready() -> void:
	collision_shape_2d.disabled = true
	hitbox.area_entered.connect(_on_area_hitbox_entered)
	animated_sprite_2d.animation_finished.connect(animation_finished)
	
func _physics_process(delta: float) -> void:
	# checking if player is alive
	if isdead :
		return
	Gravity(delta)
	controlls()
	combotimmer(delta)
	atksafecheck(delta)
	movement(delta)
	move_and_slide()
	animationmechine()
	
	
	
	
	
	
	
	
	#gravityyyyyy will pull u down\\\
	
func Gravity(delta:float) -> void :
	if is_on_floor():
		return
	var g = gravity * gravity_multi if velocity.y > 0 else gravity
	
	velocity.y += g * delta
	velocity.y = min(velocity.y , fall_cap)
		
		
func controlls()-> void :
	if state == states.huet or state == states.death:
		return
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jumppower
	if Input.is_action_just_released("jump")and velocity.y < 0 :
		velocity.y *= jump_cut
		
	if Input.is_action_just_pressed("atk"):
		checkatk()
	


func checkatk() -> void:
	if atkcombo == 0:
		attack(1)
	else:
		atking = true




func attack(step:int) ->void:
	atkcombo = step
	atking = false
	inaction = true
	atk_safety_timer = 1.0
	
	state = states.atk1 if step == 1 else (states.atk2 if step == 2 else states.atk3
	)
	var atkname = "atk%d" % step
	animated_sprite_2d.play(atkname)
	initialize_hitbox(step)
	
	
	
func initialize_hitbox(step:int) -> void:
	hitbox.scale.x = -1 if animated_sprite_2d.flip_h else 1 
	collision_shape_2d.disabled = false
	var activetime = [0.15,0.15,0.2][step - 1 ]
	await get_tree().create_timer(activetime).timeout
	collision_shape_2d.disabled=true
	
	
	
func _on_area_hitbox_entered(area:Area2D) -> void:
	if atkcombo == 0 :
		return
	var target = area.get_parent()
	var damage = [10,15,20][atkcombo-1]
	
	if target.has_method("Damage"):
		target.Damage(damage)
		
		
		
func combotimmer(delta :float) -> void:
	if atkcombo != 0 and combotime  > 0.0:
		combotime -= delta
		if combotime <= 0.0:
			if not atking:
				atkcombo=0
				
	
	
	
func atksafecheck(delta) -> void:
	if atkcombo ==0:
		return
	atk_safety_timer -= delta
	if atk_safety_timer<= 0.0:
		inaction = false
		combotime = maxcombotime
		atkcombo = 0 
		atking = false
		state=states.idle
		
		
	
	
func movement(delta) -> void :
	if state == states.atk1 or state == states.atk2 or state == states.atk3 or state == states.huet or state == states.death:
		velocity.x = move_toward(velocity.x , 0 , 120 *delta)
		return
	var direction = Input.get_axis("left","right")
	var running := Input.is_action_pressed("run")
	var speed =  runspeed if running else movespeed
	
	if direction!=0:
		velocity.x= move_toward(velocity.x , direction* speed, 300*delta)
		animated_sprite_2d.flip_h = direction<0
	else:
		velocity.x = move_toward(velocity.x , 0 , 120 *delta)
		
		
		
func animationmechine()-> void:
	if state == states.atk1 or state == states.atk2 or state == states.atk3 or state == states.huet or state == states.death:
		return
	var previousstate :=state
	if not is_on_floor():
		state = states.jump if velocity.y < 0 else states.fall
		
	elif abs(velocity.x) > 0.1:
		state=states.run if Input.is_action_pressed("run") else states.walk
	
	else:
		state=states.idle
		
	if state != previousstate or not animated_sprite_2d.is_playing():
		match state:
			states.idle:  animated_sprite_2d.play("Idle"
			)
			states.walk  :   animated_sprite_2d.play("walk")
			
			states.run :   animated_sprite_2d.play("run")
			states.jump : animated_sprite_2d.play("jump")
			states.fall :animated_sprite_2d.play("fall")
			
	

func animation_finished() -> void:
	var animation = animated_sprite_2d.animation
	if animation.begins_with("atk"):
		if atking and atkcombo < 3 :
			attack(atkcombo+1)
		else:
			inaction = false
			combotime = maxcombotime
			if not atking:
				atkcombo = 0 
			state=states.idle
	elif animation == "hurt":
		inaction = false
		state = states.idle
	elif animation == "death":
		queue_free()
		
		
		
		
		
func Damage(amt) -> void:
	if isdead:
		return
	health -= amt
	atkcombo = 0
	inaction = false
	collision_shape_2d.disabled=true
	
	if health <= 0 :
		die()
		
	else:
		state= states.huet
		animated_sprite_2d.play("hurt")
		
		
# now i really wana die :(

func die() -> void:
	isdead =true
	state=states.death
	inaction =true
	animated_sprite_2d.play("death")
	set_physics_process(false)
	
		
	
