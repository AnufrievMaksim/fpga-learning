# FPGA Learning

Репозиторий для изучения ПЛИС (Verilog).

## Проекты

### Light (FSM)

Светофор на Verilog — FSM Moore.

**Что делает:**
- Три состояния: RED, GREEN, YELLOW.
- Переключение по такту с счётчиком.
- RED = 10 тактов, GREEN = 10, YELLOW = 5.

**Файлы:**
- `light/light.v` — модуль светофора
- `light/tb_light.v` — testbench

![Симуляция](light/simulation.PNG)

### UART TX (Verilog)

Передатчик UART на Verilog.

**Что делает:**
- Передаёт байт по линии TX.
- Формат: START, 8 бит данных, STOP.
- Бодовая скорость: 9600 (в симуляции ускорено).

**Файлы:**
- `uart_tx/uart_tx.v` — модуль передатчика
- `uart_tx/tb_uart_tx.v` — testbench

![Симуляция](uart_tx/simulation_uart_tx.PNG)

*BAUD = 5 000 000 (ускорено для симуляции).*


