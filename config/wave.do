onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_hdl/i_KeyBus_if/clk
add wave -noupdate /top_hdl/i_KeyBus_if/resetH
add wave -noupdate /top_hdl/i_KeyBus_if/i_start
add wave -noupdate /top_hdl/i_KeyBus_if/i_key_mode
add wave -noupdate /top_hdl/i_KeyBus_if/i_key
add wave -noupdate /top_hdl/i_KeyBus_if/o_key_ready
add wave -noupdate /top_hdl/i_CipherBus_if/clk
add wave -noupdate /top_hdl/i_CipherBus_if/resetH
add wave -noupdate /top_hdl/i_CipherBus_if/i_enable
add wave -noupdate /top_hdl/i_CipherBus_if/i_ende
add wave -noupdate /top_hdl/i_CipherBus_if/i_data_valid
add wave -noupdate /top_hdl/i_CipherBus_if/i_data
add wave -noupdate /top_hdl/i_CipherBus_if/o_ready
add wave -noupdate /top_hdl/i_CipherBus_if/o_data_valid
add wave -noupdate /top_hdl/i_CipherBus_if/o_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1 ns}
