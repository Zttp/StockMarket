extends CharacterBody2D
class_name NPC

## Настройки NPC
@export_category("Dialogue")
@export var dialogue: Dialogue  # Основной диалог
@export var default_dialogue: Dialogue  # Диалог, если основной недоступен
@export var look_at_player: bool = true  # Поворачиваться ли к игроку

## Настройки взаимодействия
@export_category("Interaction")
@export var interaction_offset: Vector2 = Vector2(0, -50)  # Смещение метки
@export var interaction_cooldown: float = 0.5  # Задержка между взаимодействиями

## Внутренние переменные
var _can_interact: bool = false
var _player_ref: Node2D = null
var _cooldown_timer: Timer

func _ready():
    # Создаем таймер кулдауна
    _cooldown_timer = Timer.new()
    _cooldown_timer.wait_time = interaction_cooldown
    _cooldown_timer.one_shot = true
    add_child(_cooldown_timer)
    
    # Проверяем наличие диалога
    if not dialogue and default_dialogue:
        dialogue = default_dialogue
        push_warning("У NPC %s не задан основной диалог, используется запасной" % name)

## Основная функция взаимодействия
func interact():
    if _cooldown_timer.time_left > 0:
        return
    
    if not dialogue:
        push_error("У NPC %s нет заданного диалога!" % name)
        return
    
    # Поворачиваемся к игроку если нужно
    if look_at_player and _player_ref:
        var direction = sign(_player_ref.global_position.x - global_position.x)
        if direction != 0:
            transform.x.x = direction
    
    # Запускаем диалог
    DialogueManager.start_dialogue(self, get_available_dialogue())
    _cooldown_timer.start()

## Получаем доступный диалог
func get_available_dialogue() -> Dialogue:
    if dialogue and dialogue.is_available():
        return dialogue
    elif default_dialogue and default_dialogue.is_available():
        return default_dialogue
    return null

## Вызывается когда игрок входит в зону взаимодействия
func _on_interaction_possible(player: Node2D):
    _player_ref = player
    _can_interact = true
    
    # Показываем индикатор взаимодействия
    $Label.visible = true
    $Label.text = "Нажмите E"
    $Label.position = interaction_offset

## Вызывается когда игрок выходит из зоны
func _on_interaction_impossible():
    _can_interact = false
    _player_ref = null
    $Label.visible = false

## Обработка ввода (альтернативный способ)
func _unhandled_input(event: InputEvent):
    if (event.is_action_pressed("interact") 
        and _can_interact 
        and _cooldown_timer.is_stopped()):
            interact()
