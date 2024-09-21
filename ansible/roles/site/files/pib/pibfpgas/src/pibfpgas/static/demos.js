// demos.js
// https://github.com/huashengdun/webssh?tab=readme-ov-file#browser-console
// wssh.send('ls -l');

function wssh_run(e,cmd) {
    e.preventDefault();
    const wssh_if = document.getElementById("wssh_if").contentWindow;
    wssh_if.wssh.send(cmd);
};

document.getElementById('blink_leds').onclick = function(e) {
    wssh_run(e,'cd ~/tests/counter_test')
    wssh_run(e,'./t2.sh')
};

document.getElementById('boot_micro_python').onclick = function(e) {
    wssh_run(e,'ls -l')
};

document.getElementById('boot_linux').onclick = function(e) {
    wssh_run(e,'cd ~/tests/linux_litex_t1')
    wssh_run(e,'cp -v tftp/* /srv/tftp')
    wssh_run(e,'openFPGALoader -b arty top.bit')
    wssh_run(e,'tio /dev/ttyUSB1')
};

document.getElementById('check_wire').onclick = function(e) {
    wssh_run(e,'cd ~/ci/t1')
    wssh_run(e,'openFPGALoader -b arty top.bit')
    wssh_run(e,'python3 t1.py')
    wssh_run(e,'echo $?')
};
