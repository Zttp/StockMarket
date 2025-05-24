extends Node

var money = 1000
var crystals = 0
var lrk = 0
var inventory = []
var owned_vehicles = []
var owned_properties = []
var goals = {
    "dubai_ticket": false,
    "luxury_car": false
}

func add_item(item_name, item_price):
    if money >= item_price:
        money -= item_price
        inventory.append(item_name)
        
        # Проверяем, не купили ли мы автомобиль или недвижимость
        if item_name == "Автомобиль":
            owned_vehicles.append(item_name)
            goals["luxury_car"] = true
        elif item_name == "Билет в Дубай":
            goals["dubai_ticket"] = true
            
        return true
    else:
        return false

func sell_item(item_name):
    if item_name in inventory:
        var sell_price = StockMarket.get_item_price(item_name) * 0.7  # Продаем за 70% цены
        money += sell_price
        inventory.erase(item_name)
        return {"success": true, "amount": sell_price}
    else:
        return {"success": false}
