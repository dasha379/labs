set_time_format -unit ns -decimal_places 3
create_clock -name {clk_i} -period 150MHz [get_ports {clk_i}]
derive_clock_uncertainty
