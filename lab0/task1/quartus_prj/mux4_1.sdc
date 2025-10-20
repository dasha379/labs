set_time_format -unit ns -decimal_places 3

create_clock -name {clk_150} -period 6.666 -waveform { 0.000 10.000 } [get_ports {clk_150_mhz_i}]

derive_clock_uncertainty
