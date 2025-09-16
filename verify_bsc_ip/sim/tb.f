+incdir+${UART_IP_VERIF_PATH}/sequences
+incdir+${UART_IP_VERIF_PATH}/testcases
+incdir+${UART_IP_VERIF_PATH}/environment
+incdir+${UART_IP_VERIF_PATH}/tb
+incdir+${UART_IP_VERIF_PATH}/regmodel
+incdir+${UART_IP_VERIF_PATH}/regmodel/register


// Compilation VIP design (agent) list
-f ${UART_VIP_ROOT}/uart_vip.f
-f ${AHB_VIP_ROOT}/ahb_vip.f

// Compilation Environment
${UART_IP_VERIF_PATH}/regmodel/register/uart_register_pkg.sv
${UART_IP_VERIF_PATH}/regmodel/uart_regmodel_pkg.sv
${UART_IP_VERIF_PATH}/environment/env_pkg.sv
${UART_IP_VERIF_PATH}/sequences/seq_pkg.sv
${UART_IP_VERIF_PATH}/testcases/test_pkg.sv
${UART_IP_VERIF_PATH}/tb/testbench.sv

