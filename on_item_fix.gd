func _on_item_list_item_selected(index):
    if index >= 0 && index < shop_items.size():
        selected_item = shop_items[index].name
        var current_price = StockMarket.get_item_price(selected_item)
        var base_price = shop_items[index].base_price
        
        item_info_label.text = "%s\nЦена: %d ₽ (Исходная: %d ₽)" % [
            selected_item,
            current_price,
            base_price
        ]
        
        # Всегда активируем кнопку сначала
        buy_button.disabled = false
        buy_button.text = "Купить (%d ₽)" % current_price
        
        # Затем проверяем деньги и обновляем статус
        if PlayerData.money < current_price:
            buy_button.text = "Недостаточно денег"
            buy_button.disabled = true
        else:
            buy_button.text = "Купить (%d ₽)" % current_price
            buy_button.disabled = false
        
        print("Выбран: ", selected_item, " Цена: ", current_price, 
              " Деньги: ", PlayerData.money, " Доступно: ", PlayerData.money >= current_price)
