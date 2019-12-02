###################################################################

# Created by write_sdc on Mon Dec  2 03:37:36 2019

###################################################################
set sdc_version 2.1

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current A
set_wire_load_mode top
set_wire_load_model -name tsmcwire -library lec25dscc25_TT
set_driving_cell -lib_cell dffacs1 [get_ports clock]
set_driving_cell -min -lib_cell dffacs1 [get_ports reset]
set_driving_cell -lib_cell dffacs1 [get_ports start]
set_driving_cell -lib_cell dffacs1 [get_ports {input_val[5]}]
set_driving_cell -lib_cell dffacs1 [get_ports {input_val[4]}]
set_driving_cell -lib_cell dffacs1 [get_ports {input_val[3]}]
set_driving_cell -lib_cell dffacs1 [get_ports {input_val[2]}]
set_driving_cell -lib_cell dffacs1 [get_ports {input_val[1]}]
set_driving_cell -lib_cell dffacs1 [get_ports {input_val[0]}]
set_driving_cell -lib_cell dffacs1 [get_ports input_ready]
set_driving_cell -lib_cell dffacs1 [get_ports {weight_vals[1][1][5]}]
set_driving_cell -lib_cell dffacs1 [get_ports {weight_vals[1][1][4]}]
set_driving_cell -lib_cell dffacs1 [get_ports {weight_vals[1][1][3]}]
set_driving_cell -lib_cell dffacs1 [get_ports {weight_vals[1][1][2]}]
set_driving_cell -lib_cell dffacs1 [get_ports {weight_vals[1][1][1]}]
set_driving_cell -lib_cell dffacs1 [get_ports {weight_vals[1][1][0]}]
set_driving_cell -lib_cell dffacs1 [get_ports {weight_vals[1][0][5]}]
set_driving_cell -lib_cell dffacs1 [get_ports {weight_vals[1][0][4]}]
set_driving_cell -lib_cell dffacs1 [get_ports {weight_vals[1][0][3]}]
set_driving_cell -lib_cell dffacs1 [get_ports {weight_vals[1][0][2]}]
set_driving_cell -lib_cell dffacs1 [get_ports {weight_vals[1][0][1]}]
set_driving_cell -lib_cell dffacs1 [get_ports {weight_vals[1][0][0]}]
set_driving_cell -lib_cell dffacs1 [get_ports {weight_vals[0][1][5]}]
set_driving_cell -lib_cell dffacs1 [get_ports {weight_vals[0][1][4]}]
set_driving_cell -lib_cell dffacs1 [get_ports {weight_vals[0][1][3]}]
set_driving_cell -lib_cell dffacs1 [get_ports {weight_vals[0][1][2]}]
set_driving_cell -lib_cell dffacs1 [get_ports {weight_vals[0][1][1]}]
set_driving_cell -lib_cell dffacs1 [get_ports {weight_vals[0][1][0]}]
set_driving_cell -lib_cell dffacs1 [get_ports {weight_vals[0][0][5]}]
set_driving_cell -lib_cell dffacs1 [get_ports {weight_vals[0][0][4]}]
set_driving_cell -lib_cell dffacs1 [get_ports {weight_vals[0][0][3]}]
set_driving_cell -lib_cell dffacs1 [get_ports {weight_vals[0][0][2]}]
set_driving_cell -lib_cell dffacs1 [get_ports {weight_vals[0][0][1]}]
set_driving_cell -lib_cell dffacs1 [get_ports {weight_vals[0][0][0]}]
create_clock [get_ports clock]  -period 2.39  -waveform {0 1.195}
group_path -name input_grp  -from [list [get_ports clock] [get_ports reset] [get_ports start] [get_ports  \
{input_val[5]}] [get_ports {input_val[4]}] [get_ports {input_val[3]}]          \
[get_ports {input_val[2]}] [get_ports {input_val[1]}] [get_ports               \
{input_val[0]}] [get_ports input_ready] [get_ports {weight_vals[1][1][5]}]     \
[get_ports {weight_vals[1][1][4]}] [get_ports {weight_vals[1][1][3]}]          \
[get_ports {weight_vals[1][1][2]}] [get_ports {weight_vals[1][1][1]}]          \
[get_ports {weight_vals[1][1][0]}] [get_ports {weight_vals[1][0][5]}]          \
[get_ports {weight_vals[1][0][4]}] [get_ports {weight_vals[1][0][3]}]          \
[get_ports {weight_vals[1][0][2]}] [get_ports {weight_vals[1][0][1]}]          \
[get_ports {weight_vals[1][0][0]}] [get_ports {weight_vals[0][1][5]}]          \
[get_ports {weight_vals[0][1][4]}] [get_ports {weight_vals[0][1][3]}]          \
[get_ports {weight_vals[0][1][2]}] [get_ports {weight_vals[0][1][1]}]          \
[get_ports {weight_vals[0][1][0]}] [get_ports {weight_vals[0][0][5]}]          \
[get_ports {weight_vals[0][0][4]}] [get_ports {weight_vals[0][0][3]}]          \
[get_ports {weight_vals[0][0][2]}] [get_ports {weight_vals[0][0][1]}]          \
[get_ports {weight_vals[0][0][0]}]]
group_path -name output_grp  -to [list [get_ports input_req] [get_ports {output_val[5]}] [get_ports        \
{output_val[4]}] [get_ports {output_val[3]}] [get_ports {output_val[2]}]       \
[get_ports {output_val[1]}] [get_ports {output_val[0]}] [get_ports             \
output_valid] [get_ports done]]
set_max_delay 2.39  -to [get_ports input_req]
set_max_delay 2.39  -to [get_ports {output_val[5]}]
set_max_delay 2.39  -to [get_ports {output_val[4]}]
set_max_delay 2.39  -to [get_ports {output_val[3]}]
set_max_delay 2.39  -to [get_ports {output_val[2]}]
set_max_delay 2.39  -to [get_ports {output_val[1]}]
set_max_delay 2.39  -to [get_ports {output_val[0]}]
set_max_delay 2.39  -to [get_ports output_valid]
set_max_delay 2.39  -to [get_ports done]
set_resistance 0  [get_nets reset]
