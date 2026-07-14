extends CharacterBody2D


const movingspped = 70.0
const JUMP_VELOCITY = -400.0
var gravity = 1200
var fallcap = 700

const maxhealth = 52

var health = maxhealth

var atkdmg =  10
var atktime = 0.3
var atkcdnmax = 1
var atkcdn = 0

var isdead = false
var inaction = false

var searchdir = 1
var searchspd = 40

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var hitbox: Area2D = $hitbpx
@onready var collision_shape_2d: CollisionShape2D = $hitbpx/CollisionShape2D

@onready var detect: Area2D = $Detect
@onready var detect_collision_shape_2d: CollisionShape2D = $Detect/CollisionShape2D

@onready var checkledge: RayCast2D = $raycastes/checkledge
@onready var checkwall: RayCast2D = $raycastes/checkwall


enum states {idle,search, hunt,atk,hurt,death
	
}
var state: states = states.search

var target :Node2D=null


func _ready() -> void:
	collision_shape_2d.disabled=true
	hitbox.area_entered.connect(_on_hitbox_entered)
	detect.body_entered.connect(_on_detect_body_entered)
	detect.body_exited.connect(on_detect_body_exited)
	animated_sprite_2d.animation_finished.connect(animation_finished)
	
	
	
	
	
	
	
func _physics_process(delta: float) -> void:
	if isdead:
		return
		
	Gravity(delta)
	tickatkcdn(delta)
	movement(delta)
	move_and_slide()
	animationmechine()
		
		
		
		
		
		
		
		
		
func Gravity(delta) -> void:
	if is_on_floor():
		return
		
	velocity.y = gravity*delta
	velocity.y = min(velocity.y,fallcap)
	
	
	
	
func tickatkcdn(delta) -> void:
	if atkcdn > 0.0 :
		atkcdn -= delta


@warning_ignore("unused_parameter")
func movement(delta) -> void:
	if state == states.hurt or state ==states.death:
		velocity.x = 0.0
		
	if target == null :
		search(delta)
		return
	var distance = global_position.distance_to(target.global_position)
	if state == states.atk:
		velocity.x = 0
		return
	if distance <= 40 and atkcdn<= 0.0:
		attack()
		pass
	elif distance<= 200.0:
		hunt(delta)
		pass
	else:
		target = null
		search(delta)
		

func search(delta) ->void:
	state =states.search
	
	if (checkwall and checkwall.is_colliding()) or (checkledge and  not checkledge.is_colliding()):
		searchspd *= -1 
	velocity.x = searchdir*searchspd
	animated_sprite_2d.flip_h = searchdir < 0
	
	


@warning_ignore("unused_parameter")
func hunt(delta) -> void:
	state = states.hunt
	var dir = sign(target.global_position.x- global_position.x)
	velocity.x = dir*movingspped
	animated_sprite_2d.flip_h = dir< 0 
	
	
func attack()-> void:
	state = states.atk
	inaction = true
	velocity.x = 21
	animated_sprite_2d.play("atk")
	
	#fliping hitboxxx  
	
	hitbox.scale.x = -1  if animated_sprite_2d.flip_h else 1
	collision_shape_2d.disabled = false
	await get_tree().create_timer(atktime).timeout
	collision_shape_2d.disabled = true
	
	
	
	
func _on_detect_body_entered(body:Node2D) ->void:
	if body.is_in_group("player"):
		target = body
		
		
func on_detect_body_exited(body:Node2D) -> void:
	if body == target :
		
		target = null
		
	
func _on_hitbox_entered(area:Area2D) -> void:
	var atktarget = area.get_parent()
	if atktarget.is_in_group("player"):
		atktarget.Damage(atkdmg)




func animationmechine() -> void:
	if state == states.atk or state==states.hurt or state == states.death:
		return
		
	match state :
		states.search , states.hunt :
			if abs(velocity.x) >0.1 :
				if not animated_sprite_2d.is_playing() or animated_sprite_2d.animation != "run":
					animated_sprite_2d.play("run")
			else :
				if not animated_sprite_2d.is_playing() or animated_sprite_2d.animation!= "idle" :
					animated_sprite_2d.play("idle")
						
						
						
func animation_finished() -> void:
	var anim = animated_sprite_2d.animation
	if anim == "atk" :
		inaction = false
		atkcdn = atkcdnmax
		state = states.hunt if target!= null else states.search 
	elif anim == "hit" :
		inaction = false
		state = states.hunt if target != null else states.search
		
	elif anim == "death":
		queue_free()
		
		
		
		
		
		
		
		
		
		
func damage(amt) ->void :
	if isdead:
		return
	health -=amt
	
	if health <= 0 :
		die()
	else:
		state= states.hurt
		inaction= false
		collision_shape_2d.disabled=true
		animated_sprite_2d.play("hit")
		
		
		
func die() -> void:
	isdead =true
	state=states.death
	inaction = true
	velocity = Vector2.ZERO
	animated_sprite_2d.play("death")
	set_physics_process(false)
				
	
