extends Resource
class_name Dialogue

# ... (остальные свойства остаются без изменений) ...

## Получить доступные варианты ответа
func get_available_options() -> Array[Dialogue]:
    var available: Array[Dialogue] = []
    
    for i in range(options.size()):
        # Пропускаем варианты с невыполненными условиями
        if option_conditions.size() > i:
            if not StoryManager.has_trigger(option_conditions[i]):
                continue
        
        # Проверяем доступность самого варианта
        if options[i].is_available():
            available.append(options[i])
    
    if random_options:
        available.shuffle()
    
    return available

## Проверка наличия видимых вариантов
func has_visible_options() -> bool:
    if options.is_empty():
        return false
    
    # Проверяем каждый вариант с учетом условий
    for i in range(options.size()):
        # Если есть условие и оно не выполнено - пропускаем
        if option_conditions.size() > i:
            if not StoryManager.has_trigger(option_conditions[i]):
                continue
        
        # Если вариант доступен - возвращаем true
        if options[i].is_available():
            return true
    
    return false
