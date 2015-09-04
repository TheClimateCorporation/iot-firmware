# Notes on HC-SR501 PIR motion sensor #

## Sample Code ##

#### motion.lua
Connect output of sensor to D6.  If sensor is in 'hold HIGH' mode, a line will be logged while motion is being detected.  If sensor is in 'motion event' mode, a line will be logged for every motion event.


## Specs ##

* power: 5v
* jumper on middle and inside: holds output pin HIGH when motion detected.
* jumper on outside and middle: output is raised HIGH once / "motion event".  No motion for X interval ends a motion event.
* with jumper on the left, left-most dial is sensitivity (3m-7m), right dial is 'time delay before triggering' (300ms - 5s).


## Notes ##

* attempting to run off < 5v results in the output flapping.  HC-SR501 includes a 5v -> 3v regulator that could be bypassed if 3.3v supply is required.


## Helpful links ##

* http://www.esp8266-projects.com/2015/03/esp8266-pir-motion-sensor-detection.html
* http://www.amazon.com/gp/product/B00FDPO9B8
* http://www.mpja.com/download/31227sc.pdf
