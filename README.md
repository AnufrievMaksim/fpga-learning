# FPGA Learning

Репозиторий для изучения ПЛИС (Verilog).

## Проекты

### Light (FSM)

Реализовал светофор на Verilog — FSM Moore.

**Что делает:**
- Три состояния: RED, GREEN, YELLOW.
- Переключение по такту с счётчиком.
- RED = 10 тактов, GREEN = 10, YELLOW = 5.

**Файлы:**
- `light.v` — модуль светофора
- `tb_light.v` — testbench

**Симуляция:**
Симулировал в EDA Playground.

## Стек
Verilog HDL, EDA Playground

## Симуляция

![Симуляция светофора](simulation.png)
