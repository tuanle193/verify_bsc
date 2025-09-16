#!/bin/bash -f

## QUESTA license path
export LM_LICENSE_FILE=/home/shared_folder/questasim/license.dat

## UVM library path
export UVM_HOME=/home/shared_folder/questasim/verilog_src/uvm-1.2

## Verify root path
export UART_IP_VERIF_PATH=./..

## AHB VIP Design root path
export AHB_VIP_ROOT=$UART_IP_VERIF_PATH/vip/ahb_vip

## UART VIP Design root path
export UART_VIP_ROOT=$UART_IP_VERIF_PATH/vip/uart_vip
