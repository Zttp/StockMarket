extends Button
class_name OptionButton

# Настройки кнопки
@export var text_speed: float = 0.02  # Скорость появления текста
@export var hover_scale: Vector2 = Vector2(1.05, 1.05)  # Эффект при наведении
@export var click_sound: AudioStream  # Звук при нажатии

# Связанные данные
var dialogue_option: Dialogue:  # Привязанный вариант диалога
    set(value):
        dialogue_option = value
        update_button()

# Ссылки на узлы
@onready var tween: Tween = create_tween()
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready():
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)
    pressed.connect(_on_pressed)
    
    if click_sound:
        audio_player.stream = click_sound

# Обновляем вид кнопки
func update_button():
    if not dialogue_option:
        return
    
    text = dialogue_option.path_option if dialogue_option.path_option else dialogue_option.dialogue_text
    hint_tooltip = dialogue_option.dialogue_text
    
    # Можно добавить дополнительные стили в зависимости от условий
    if dialogue_option.required_triggers.size() > 0:
        add_theme_color_override("font_color", Color.LIGHT_GRAY)

# Обработчики событий
func _on_mouse_entered():
    if dialogue_option and dialogue_option.is_available():
        tween.kill()
        tween = create_tween()
        tween.tween_property(self, "scale", hover_scale, 0.1)

func _on_mouse_exited():
    tween.kill()
    tween = create_tween()
    tween.tween_property(self, "scale", Vector2.ONE, 0.1)

func _on_pressed():
    if not dialogue_option or not dialogue_option.is_available():
        return
    
    if click_sound:
        audio_player.play()
    
    # Анимация нажатия
    tween.kill()
    tween = create_tween()
    tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.05)
    tween.tween_property(self, "scale", Vector2.ONE, 0.15)
    
    # Передаем выбор в DialogueManager
    DialogueManager.select_option(dialogue_option)

# Вспомогательные функции
func set_disabled_state(is_disabled: bool):
    disabled = is_disabled
    modulate = Color.GRAY if is_disabled else Color.WHITE

func animate_text():
    if not dialogue_option:
        return
    
    var full_text = dialogue_option.dialogue_text
    visible_ratio = 0
    
    for i in range(full_text.length() + 1):
        visible_ratio = float(i) / full_text.length()
        await get_tree().create_timer(text_speed).timeout
