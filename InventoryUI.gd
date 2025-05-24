extends Control

@onready var inventory_list = $Panel/ScrollContainer/InventoryList
@onready var message_label = $MessageLabel
@onready var item_info_label = $Panel/ItemInfoLabel
@onready var sell_button = $Panel/SellButton
@onready var use_button = $Panel/UseButton

var selected_item = null

func _ready():
    update_ui()
    sell_button.disabled = true
    use_button.disabled = true

func update_ui():
    inventory_list.clear()
    for item in PlayerData.inventory:
        var item_text = "%s (Цена: %d ₽)" % [item, StockMarket.get_item_price(item)]
        inventory_list.add_item(item_text)
    
    if PlayerData.inventory.size() == 0:
        item_info_label.text = "Инвентарь пуст"
    else:
        item_info_label.text = "Предметов: %d" % PlayerData.inventory.size()

func show_message(message):
    message_label.text = message
    var timer = get_tree().create_timer(3.0)
    timer.connect("timeout", Callable(message_label, "set_text").bind(""))

func _on_inventory_list_item_selected(index):
    if index >= 0 && index < PlayerData.inventory.size():
        selected_item = PlayerData.inventory[index]
        item_info_label.text = "Выбрано: %s\nТекущая цена: %d ₽" % [
            selected_item, 
            StockMarket.get_item_price(selected_item)
        ]
        sell_button.disabled = false
        # Проверяем, можно ли использовать предмет
        use_button.disabled = !is_usable_item(selected_item)

func is_usable_item(item_name):
    # Определяем, какие предметы можно использовать
    return item_name in ["Флешка", "Зарядный провод", "Билет в Дубай"]

func _on_sell_button_pressed():
    if selected_item:
        var result = PlayerData.sell_item(selected_item)
        if result.success:
            show_message("Продано: %s за %d ₽" % [selected_item, result.amount])
            update_ui()
            selected_item = null
            item_info_label.text = "Предмет продан"
            sell_button.disabled = true
            use_button.disabled = true
        else:
            show_message("Ошибка продажи предмета")

func _on_use_button_pressed():
    if selected_item:
        match selected_item:
            "Флешка":
                PlayerData.money += 500  # Бонус за использование
                PlayerData.inventory.erase(selected_item)
                show_message("Вы использовали флешку и заработали 500 ₽!")
            "Зарядный провод":
                PlayerData.crystals += 10
                PlayerData.inventory.erase(selected_item)
                show_message("Вы получили 10 кристаллов!")
            "Билет в Дубай":
                get_tree().change_scene_to_file("res://scenes/dubai_scene.tscn")
            _:
                show_message("Этот предмет нельзя использовать")
        update_ui()
        selected_item = null
        item_info_label.text = "Предмет использован"
        sell_button.disabled = true
        use_button.disabled = true

func _on_close_button_pressed():
    hide()
