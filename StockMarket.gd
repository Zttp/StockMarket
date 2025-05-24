extends Node

var lrk_price = 100
var price_history = []
var price_change_interval = 5.0  # Изменение цены каждые 5 секунд
var timer = 0
var volatility = 0.2  # Волатильность акций
var market_mood = 0.0  # -1.0 до 1.0 (медвежий/бычий рынок)

# Добавим другие товары
var item_prices = {
    "Яблоки": 15,
    "Рыба": 70,
    "Инструменты": 130,
    "Карандаш": 10,
    "Ручка": 50,
    "Корректор": 100,
    "Зарядный провод": 500,
    "Флешка": 1000,
    "Автомобиль": 50000,
    "Билет в Дубай": 100000,
    "Видеокарта": 30000
}

func _ready():
    price_history.append(lrk_price)
    # Инициализируем случайные цены для товаров
    for item in item_prices.keys():
        item_prices[item] = randf_range(item_prices[item]*0.8, item_prices[item]*1.2)

func _process(delta):
    timer += delta
    if timer >= price_change_interval:
        update_prices()
        timer = 0
        # Меняем настроение рынка
        market_mood = clamp(market_mood + randf_range(-0.1, 0.1), -0.5, 0.5)

func update_prices():
    # Обновляем цену LRK с учетом настроения рынка
    var change_percent = randf_range(-volatility, volatility) + market_mood * 0.1
    lrk_price += lrk_price * change_percent
    lrk_price = max(lrk_price, 1)
    price_history.append(lrk_price)
    
    # Обновляем цены на товары
    for item in item_prices.keys():
        var item_change = randf_range(-0.05, 0.05)
        item_prices[item] = max(item_prices[item] * (1 + item_change), 1)
    
    print("Рынок обновлен. Цена LRK: ", lrk_price, " ₽")

func buy_lrk(amount, player):
    var total_cost = amount * lrk_price
    if player.money >= total_cost:
        player.money -= total_cost
        player.lrk += amount
        # Покупка влияет на рынок
        market_mood += amount * 0.0001
        return {"success": true, "message": "Куплено %s LRK за %s ₽" % [amount, total_cost]}
    else:
        return {"success": false, "message": "Недостаточно денег!"}

func sell_lrk(amount, player):
    if player.lrk >= amount:
        var total_income = amount * lrk_price
        player.money += total_income
        player.lrk -= amount
        # Продажа влияет на рынок
        market_mood -= amount * 0.0001
        return {"success": true, "message": "Продано %s LRK за %s ₽" % [amount, total_income]}
    else:
        return {"success": false, "message": "Недостаточно LRK!"}

func get_item_price(item_name):
    return item_prices.get(item_name, 0)
