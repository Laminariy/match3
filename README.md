# Match-3 Board model
Простая модель доски для игр три-в-ряд.

Тестовое задание для Red Brix Wall.

## Зависимости:

  [lume](https://github.com/rxi/lume) - для работы с таблицами.
  [hump.class](https://github.com/vrld/hump) - для работы с классами.

## Запуск:

Основной файл - match3/init.lua

Проверено на LuaJIT (Lua 5.1 совместимый с 5.2)

## Команды:

- `q` выход из программы
- `color` включить/выключить цвета (по умолчанию включено)
- `clear` включить/выключить очистку экрана перед отрисовкой (по умолчанию включено)
- `m` <kbd>x</kbd> <kbd>y</kbd> <kbd>dir</kbd> передвинуть фишку (x,y - координата, dir - направление l/r/u/d)