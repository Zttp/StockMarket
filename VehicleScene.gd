extends Node3D

var vehicle_name = ""
var is_owned = false

func setup(name, owned):
    vehicle_name = name
    is_owned = owned
    $Label3D.text = vehicle_name + (" (Куплен)" if owned else " (Цена: %s ₽" % StockMarket.get_item_price(vehicle_name))
    
    if owned:
        $MeshInstance3D.material_override.albedo_color = Color(0, 1, 0)
    else:
        $MeshInstance3D.material_override.albedo_color = Color(1, 0, 0)

func _on_interact_area_body_entered(body):
    if body.is_in_group("player"):
        if is_owned:
            UI.show_message("Это ваш %s" % vehicle_name)
        else:
            UI.show_message("Нажми E чтобы купить %s за %s ₽" % [vehicle_name, StockMarket.get_item_price(vehicle_name)])

func _on_interact_area_input_event(camera, event, position, normal, shape_idx):
    if event.is_action_pressed("interact") and not is_owned:
        if PlayerData.money >= StockMarket.get_item_price(vehicle_name):
            if PlayerData.add_item(vehicle_name, StockMarket.get_item_price(vehicle_name)):
                setup(vehicle_name, true)
                UI.show_message("Поздравляем! Вы купили %s!" % vehicle_name)
