# DHT22 - read temperature / humidity and post to ThingSpeak #

## DHT22 Notes ##
  * pins (L->R): power (3-5v), data, ground

## Scripts ##

#### dht22.lua
reads temp/humidity from a DHT22 sensor and posts to ThingSpeak (note: TS_API must be configured before running!  dht22.lua will attempt to source this key from 'secrets.lua', if this file exists)

#### secrets.lua
contains the API key for posting to ThingSpeak (TS_KEY)
