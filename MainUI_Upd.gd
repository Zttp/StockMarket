func _on_vehicles_button_pressed():
    var message = "Ваши автомобили:\n"
    if PlayerData.owned_vehicles.size() > 0:
        for vehicle in PlayerData.owned_vehicles:
            message += "- " + vehicle + "\n"
    else:
        message += "У вас нет автомобилей"
    show_message(message)
