// demos.js
// https://github.com/huashengdun/webssh?tab=readme-ov-file#browser-console
// wssh.send('ls -l');

function wssh_run(e,cmd) {
    e.preventDefault();
    const wssh_if = document.getElementById("wssh_if").contentWindow;
    wssh_if.wssh.send(cmd);
};


function button_click(button_id,fn) {
    btn = document.getElementById(button_id);
    if (btn) {
      btn.onclick = fn
    }
};

button_click('blink_leds',
 function(e) {
    wssh_run(e,'cd ~/Demos/counter_test')
    wssh_run(e,'./run_demo.sh')
});

button_click('boot_micro_python',
  function(e) {
    wssh_run(e,'cd ~/Demos/micro_python')
    wssh_run(e,'./run_demo.sh')
});

button_click('boot_linux',
  function(e) {
    wssh_run(e,'cd ~/Demos/linux_litex')
    wssh_run(e,'./run_demo.sh')
});

button_click('check_wire',
  function(e) {
    wssh_run(e,'cd ~/ci/t1')
    wssh_run(e,'openFPGALoader -b arty top.bit')
    wssh_run(e,'python3 t1.py')
    wssh_run(e,'echo $?')
});

button_click('tt910',
  function(e) {
    wssh_run(e,'mpremote')
});

button_click('usb_off',
  function(e) {
    wssh_run(e,'/sbin/uhubctl -S --ports 2 --action off')
});

button_click('usb_on',
  function(e) {
    wssh_run(e,'/sbin/uhubctl -S --ports 2 --action on')
});

