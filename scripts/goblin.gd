extends CharacterBody2D


const patrolspeed = 40
const chasespeed = 70
var gravity = 1200
var fallcap = 700


const maxhlt = 50
var hlt = maxhlt
var atkdmg = 10
var atktime = .3
var atkrange = 30
var atkcdnmax = 1.0
var atkcdn = 0.0

var loserange = 220.0

var isdead = false
var inaction = false

var patroldir = 1

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var hitbpx: Area2D = $Node2D/hitbpx
@onready var collision_shape_2d: CollisionShape2D = $Node2D/hitbpx/CollisionShape2D


@onready var hurtbox: Area2D = $hurtbox
@onready var hurtbox_shape: CollisionShape2D = $hurtbox/CollisionShape2D


@onready var detect: Area2D = $Detect

@onready var checkwall: RayCast2D = $Node2D/raycastes/checkwall
@onready var checkledge: RayCast2D = $Node2D/raycastes/checkledge

@onready var node_2d: Node2D = $Node2D



enum states{
	patrol , hunt, atk ,hurt,death
}

var state : states = states.patrol



var target : Node2D = null


func _ready() -> void:
	collision_shape_2d.disabled = true
	
	
	hitbpx.body_entered.connect(_on_hitbpx_body_enterd)
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
			
		states.hunt:
			if target==null:
				state =states.patrol
				return
			var distance = abs(global_position.x -  target.global_position.x)
			print(distance)
			if distance> loserange :
				target= null
				state = states.patrol
				return
				
			if distance <= atkrange:
				velocity.x =0.0
				if atkcdn<=0.0:
					attack()
				
				
				
			else:
				chase()
				pass
				
		states.patrol  :
			if target != null:
				state = states.hunt
				return
				
			patrol()
			
			
			
			
			
func patrol() :
	if (checkwall and checkwall.is_colliding()) or (checkledge and not checkledge.is_colliding()):
		patroldir *= -1
		
	velocity.x = patroldir * patrolspeed
	animated_sprite_2d.flip_h =patroldir<0
	
	
	
	
func chase():
	print(velocity.x)
	var dx = target.global_position.x - global_position.x
	if abs(dx)>2.0:
		var dir = sign(dx)
		velocity.x = dir *chasespeed
		animated_sprite_2d.flip_h = dir < 0
	else :
		velocity.x= 0.0
	
	
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
		print("UU")
		target = body
		
		

func _on_detect_body_exited(body : Node2D):
	if body == target:
		target=null
		
		
		
		
		
		
		
func _on_hitbpx_body_enterd(body :Node2D):
	print(body)
	if body.is_in_group("player"):
		print("o")
		body.Damage(atkdmg)
		
		
		
func _on_hurtbox_area_entered(area:Area2D):
	var attker = area.get_parent()
	if attker.is_in_group("player"):
	 
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
	elif anim == "hit":
		inaction = false
		state = states.hunt if target!=null else states.patrol
		
	elif anim == "death":
		queue_free()
			
			
			
			
			
			
			
