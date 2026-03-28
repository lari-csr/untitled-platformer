extends CharacterBody2D

@export_category("Locomotion")
@export var _speed : float = 8
@export var _acceleration : float = 16
@export var _deceleration : float = 16

@export_category("Jump")
@export var _jump_height : float = 2.5
@export var _air_control : float = 0.5
var _jump_velocity : float 

@onready var _sprite : Sprite2D = $Sprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

#variaveis com o _ no inicio pertencem apenas a este script
var _direction : float

func _ready():
	_speed *= Global.ppt
	_acceleration *= Global.ppt
	_deceleration *= Global.ppt
	_jump_height *= Global.ppt
	
	# Essa fórmula
	_jump_velocity = sqrt( _jump_height * gravity * 2 ) * -1
	# serve para garantir que o personagem sempre vai atingir exatamente a altura _jump_height
	# vem da equação da física do movimento retilíneo uniformemente variado (MRUV)
	# v0 = sqrt(2 * gravity * jump_height)
	# o "-1" vem do fato do eixo y crescer para baixo, então multiplicar por "-1" faz o personagem subir

#region Public Methods
func face_left():
	_sprite.flip_h = true
	
func face_right():
	_sprite.flip_h = false
	
func run(direction: float):
	_direction = direction
	return
	
func jump():
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = _jump_velocity
		
func stop_jump():
		if velocity.y < 0:
			velocity.y = 0
			
#endregion

func _physics_process(delta: float) -> void:
	if sign(_direction) == -1:
		face_left()
	else :
		face_right()
	
	# Adicionando a gravidade

	#Como boa prática, você deve substituir as ações da interface do usuário por ações de jogabilidade personalizadas.

	if is_on_floor():
		_ground_physics(delta)
	if not is_on_floor():
		_air_physics(delta)
	move_and_slide()

func _ground_physics(delta: float):
#var direction := Input.get_axis("ui_left", "ui_right")
# Obtém a direção da input e lida com o movimento/desaceleração horizontal.
	if _direction == 0:
		# Condição para DESACELERAR: Se o jogador não está pressionando nenhuma direção, reduza a velocidade horizontal até parar.
		#move_toward(atual, alvo, passo)
		velocity.x = move_toward(velocity.x, 0, _deceleration * delta)
	elif velocity.x==0  or (sign(_direction) == sign(velocity.x)) :
		#se o jogador quiser ACELERAR, ele pode estar atualmente PARADO, ou querer acelerar na mesma direção em que estava indo
		velocity.x = move_toward(velocity.x, _direction * _speed, _acceleration * delta)
	else :
		# mas pode ser que ele queira ACELERAR, porém  na direção contrária 
		var _turn_speed = _deceleration # essa linha não é necessária, porém quero destacar que essa é velocidade com a qual ele se vira
		velocity.x = move_toward(velocity.x, _direction * _speed, _turn_speed * delta)

func _air_physics(delta):
	velocity.y += gravity * delta
	if _direction != 0:
		# Só aplica controle horizontal se houver input (esquerda ou direita )
		velocity.x = move_toward(velocity.x, _direction * _speed, _acceleration *_air_control * delta)

	
	
