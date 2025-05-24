extends Control

@onready var item_list = $Panel/ScrollContainer/ItemList
@onready var money_label = $Panel/MoneyLabel
@onready var crystals_label = $Panel/CrystalsLabel
@onready var message_label = $MessageLabel
@onready var buy_button = $Panel/BuyButton
@onready var item_info_label = $Panel/ItemInfoLabel

var shop_items = [
    {"name": "Карандаш", "base_price": 10, "category": "Канцелярия"},
    {"name": "Ручка", "base_price": 50, "category": "Канцелярия"},
    {"name": "Корректор", "base_price": 100, "category": "Канцелярия"},
    {"name": "Зарядный провод", "base_price": 500, "category": "Электроника"},
    {"name": "Флешка", "base_price": 1000, "category": "Электроника"},
    {"name": "Видеокарта", "base_price": 30000, "category": "Техника"},
    {"name": "Яблоки", "base_price": 15, "category": "Продукты"},
    {"name": "Рыба", "base_price": 70, "category": "Продукты"},
    {"name": "Инструменты", "base_price": 130, "category": "Инвентарь"},
    {"name": "Автомобиль", "base_price": 50000, "category": "Транспорт"},
    {"name": "Билет в Дубай", "base_price": 100000, "category": "Путешествия"}
]

var selected_item = null

func _ready():
    update_shop_items()
    update_player_info()
    buy_button.disabled = true

func update_shop_items():
    item_list.clear()
    for item in shop_items:
        var current_price = StockMarket.get_item_price(item.name)
        var price_change = (current_price - item.base_price) / item.base_price * 100
        var price_change_text = "↑%.1f%%" % price_change if price_change >= 0 else "↓%.1f%%" % -price_change
        var color = Color.GREEN if price_change >= 0 else Color.RED
        
        item_list.add_item("%s - %d ₽ (%s)" % [item.name, current_price, price_change_text])
        item_list.set_item_custom_fg_color(item_list.item_count - 1, color)

func update_player_info():
    money_label.text = "Деньги: %d ₽" % PlayerData.money
    crystals_label.text = "Кристаллы: %d" % PlayerData.crystals

func show_message(message):
    message_label.text = message
    var timer = get_tree().create_timer(3.0)
    timer.connect("timeout", Callable(message_label, "set_text").bind(""))

func _on_item_list_item_selected(index):
    if index >= 0 && index < shop_items.size():
        selected_item = shop_items[index].name
        var current_price = StockMarket.get_item_price(selected_item)
        var base_price = shop_items[index].base_price
        var price_change = (current_price - base_price) / base_price * 100
        
        item_info_label.text = "%s\nКатегория: %s\nЦена: %d ₽ (Исходная: %d ₽)\nИзменение: %s%.1f%%" % [
            selected_item,
            shop_items[index].category,
            current_price,
            base_price,
            "+" if price_change >= 0 else "",
            price_change
        ]
        
        buy_button.disabled = false
        # Проверяем, хватает ли денег
        if PlayerData.money < current_price:
            buy_button.text = "Недостаточно денег"
            buy_button.disabled = true
        else:
            buy_button.text = "Купить"

func _on_buy_button_pressed():
    if selected_item:
        var current_price = StockMarket.get_item_price(selected_item)
        if PlayerData.add_item(selected_item, current_price):
            show_message("Вы купили %s за %d ₽" % [selected_item, current_price])
            update_player_info()
            # Обновляем список, так как цены могли измениться
            update_shop_items()
        else:
            show_message("Недостаточно денег для покупки %s" % selected_item)

func _on_close_button_pressed():
    hide()

func _on_category_button_pressed(category):
    item_list.clear()
    for item in shop_items:
        if item.category == category || category == "Все":
            var current_price = StockMarket.get_item_price(item.name)
            item_list.add_item("%s - %d ₽" % [item.name, current_price])
