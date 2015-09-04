inpin=6
gpio.mode(inpin, gpio.INT)

start=tmr.time()
lastEnd=0

function motionStart()
  start=tmr.time()
  print('Motion detected!')
  print('[DEBUG] start: '..start..', last: '..lastEnd..
        ', break: '..start - lastEnd)
  tmr.delay(1000000)
  gpio.trig(inpin, "down", motionStop)
end

function motionStop()
  duration = tmr.time() - start
  print('motion ended after '..duration..' seconds.')
  print('[DEBUG] start: '..start..', duration: '..duration)
  tmr.delay(1000000)
  lastEnd=start + duration
  gpio.trig(inpin, "up", motionStart)
end

gpio.trig(inpin, "up", motionStart)
