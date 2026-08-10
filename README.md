# Configurable UART Controller with FIFO (Verilog HDL)

A fully configurable Universal Asynchronous Receiver-Transmitter (UART) controller implemented in Verilog HDL using AMD Xilinx Vivado.

---

## 📌 Features
- **Dynamic Baud Rate Generator**: Programmable clock divider for flexible baud rate selection.
- **Configurable Parity**: Supports Even/Odd parity checking and generation.
- **Error Detection**: Real-time detection for **Parity Errors** and **Framing Errors**.
- **FIFO Buffers**: Integrated 16-depth TX and RX FIFO buffers to ensure zero data loss.
- **Metastability Protection**: Double-flop synchronizer on asynchronous serial inputs.

---

## 🏗️ Architecture
- `baud_gen.v` - Baud tick generator
- `uart_tx.v` - Dynamic serializer
- `uart_rx.v` - Deserializer with mid-bit sampling
- `fifo.v` - Circular queue buffer
- `uart_top.v` - Top-level module integrating TX, RX, FIFO & Baud Generator

---

## 📊 Simulation Results

Verified through a full TX-to-RX external loopback simulation in Vivado (Transmitted `0x8A` and successfully received `0x8A`).

![UART Simulation Waveform](UART_wave)
