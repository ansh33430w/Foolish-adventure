extends CharacterBody2D


const patrolspeed = 40
const chasespeed = 70
var gravity = 1200
var fallcap = 700


const maxhlt = 50
var hlt = maxhlt
var atkdmg = 10
var atktime = .3
var atkrange = 40.0
var atkcdnmax = 1.0
var atkcdn = 0.0

var loserange = 220.0

var isdead = false
var inaction = false

var patroldir = 1

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var hitbpx: Area2D = $hitbpx
@onready var collision_shape_2d: CollisionShape2D = $hitbpx/CollisionShape2D


@onready var hurtbox: Area2D = $hurtbox
@onready var hurtboxshape: Area2D = $hurtbox

@onready var detect: Area2D = $Detect

@onready var checkwall: RayCast2D = $raycastes/checkwall
@onready var checkledge: RayCast2D = $raycastes/checkledge




enum states{
	patrol , hunt, atk ,hurt,death
}

var state : states = states.patrol



var target : Node2D = null


func _ready() -> void:
	collision_shape_2d.disabled = true
	
	hitbpx.area_entered.connect(_on_hitbpx_area_enterd)
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	
	detect.body_entered.connect(_on_detect_body_entered)
	detect.body_exited.connect(_on_detect_body_exited)
	
	animated_sprite_2d.animation_finished.connect(_on_aniamtion_finished)

func _physics_process(delta: float) -> void:
	if isdead:
		return
	Gravity(delta)
	tick_atk_cdn(delta)
	tick_state(delta)
	move_and_slide()
	update_animation()
	
	


func Gravity(delta):
	if is_on_floor():
		return
	velocity.y += gravity*delta
	velocity.y =min(velocity.y , fallcap)
	
	
func tick_atk_cdn(delta) -> void:
	if atkcdn > 0.0 :
		atkcdn-= delta
		
		
		
		
func tick_state(delta):
	match state:
		states.hurt ,states.death:
			velocity.x = 0.0
		states.atk:
				velocity.x=0.0
			
		states.patrol:
			if target==null:
				state =states.patrol
				return
			var distance = global_position.distance_to(target.global_position)
			
			if distance> loserange :
				target= null
				state = states.patrol
				return
				
			if distance <= atkrange and atkcdn <= 0.0:
				pass #----
				
			else:
				#chase()
				pass
				
		states.patrol ,_ :
			if target != null:
				state = states.hunt
				return
				
			#patrol
			
			
			
			
			
func patrol() :
	if (checkwall and checkwall.is_colliding()) or (checkledge and not checkledge.is_colliding()):
		patroldir *= -1
		
	velocity.x = patroldir * patrolspeed
	animated_sprite_2d.flip_h =patroldir<0
	
	
	
	
func chase():
	var dir = sign(target.global_position.x - global_position.x)
	velocity.x = dir *chasespeed
	animated_sprite_2d.flip_h = dir < 0
	
	
	
func attack():
	state = states.atk
	inaction = true
	velocity.x = 0.0 
	animated_sprite_2d.play("atk")
	
	hitbpx.scale.x = -1 if animated_sprite_2d.flip_h else 1 
	collision_shape_2d.disabled = false
	
	await get_tree().create_timer(atktime).timeout
	
	collision_shape_2d.disabled=true
	
	
	
	
	
	
	
	
	
func _on_detect_body_entered(body:Node2D):
	if body.is_in_group("player"):
		target = body
		
		

func _on_detect_body_exited(body : Node2D):
	if body == target:
		target=null
		
		
		
		
		
		
		
func _on_hitbpx_area_enterd(area:Area2D):
	var atktarget = area.get_parent()
	if atktarget and atktarget.is_in_group("player") :
		atktarget.damage(atkdmg)
		
		
		
		
func _on_hurtbox_area_entered(area:Area2D):
	damage(12.5)
	
	

func damage(dmg):
	if isdead:
		return
	hlt -=dmg
	
	if hlt <= 0:
		die()
		
	else:
		state = states.hurt
		inaction = false
		collision_shape_2d.disabled = true
		animated_sprite_2d.play("hit")
		
		
func die():
	isdead =true
	state =states.death
	inaction = true
	velocity = Vector2.ZERO
	animated_sprite_2d.play("death"
	)
	set_physics_process(false)
	
	
func update_animation():
	if state == states.atk or state == states.hurt or state== states.death:
		return
	
	if abs(velocity.x) > .1 :
		if not animated_sprite_2d.is_playing() or animated_sprite_2d.animation != "run":
			animated_sprite_2d.play("run")
			
	else :
		if not animated_sprite_2d.is_playing() or animated_sprite_2d.animation!= "idle":
			animated_sprite_2d.play("idle")
			


func _on_aniamtion_finished():
	var anim = animated_sprite_2d.animation
	if anim == "atk":
		inaction = false
		atkcdn = atkcdnmax
		state = states.hunt if target != null else states.patrol
	elif anim == "hurt ":
		inaction = false
		state = states.hunt if target!=null else states.patrol
		
	elif anim == "death":
		queue_free()
			
			
			
			
			
			
			
