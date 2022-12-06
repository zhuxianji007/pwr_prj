vcs -sverilog \
    +v2k \
    +plusarg_save \
    +nospecify \
    +notimeingcheck \
    +libext+.svh+.v+.sv+.vh \
    -full64 \
    -debug_acc+all \
    -kdb \
    -f test.f \
    -timescale=1ns/100ps \
    -l ./vcs_cmp.log \
    -o test_simv
