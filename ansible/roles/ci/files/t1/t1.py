from gpiozero import Button, LED

led = LED(10)
button = Button(8, pull_up=False)

led.on()
assert button.value==1

led.off()
assert button.value==0

