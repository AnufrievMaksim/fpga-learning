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

