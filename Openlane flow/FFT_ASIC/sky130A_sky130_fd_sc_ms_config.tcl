# SCL Configs
set ::env(CLOCK_PERIOD) "20"
set ::env(FP_CORE_UTIL) 40
set ::env(SYNTH_MAX_FANOUT) 40
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]

# Regression
set ::env(FP_CORE_UTIL) "30"

# Extra
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]


# Suggested Clock Period:
set ::env(CLOCK_PERIOD) "18.86"
