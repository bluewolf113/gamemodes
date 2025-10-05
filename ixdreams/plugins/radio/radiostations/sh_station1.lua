
STATION.name = "Local Example"
STATION.frequency = 96.2                                -- assigned frequency, obviously

STATION.trackDelay = 1                                  -- since this isn't a live stream, this is the delay in seconds between each track being played from the tracklist. can be a number or a table of {["min"] = x, ["max"] = y} or {x, y, z}

STATION.isStream = false                                -- since this station is NOT a stream, local files will be used in order starting at a random index on server load
STATION.trackList = { -- these must be sound files stored on both the client and server; do NOT start with the 'sound/' prefix
    "vo/breencast/br_instinct01.wav",
    "vo/breencast/br_instinct02.wav",
    "vo/breencast/br_instinct03.wav",
    "vo/breencast/br_instinct04.wav",
    "vo/breencast/br_instinct05.wav",
    "vo/breencast/br_instinct06.wav",
    "vo/breencast/br_instinct07.wav",
    "vo/breencast/br_instinct08.wav",
    "vo/breencast/br_instinct09.wav",
    "vo/breencast/br_instinct10.wav",
    "vo/breencast/br_instinct11.wav",
    "vo/breencast/br_instinct12.wav",
    "vo/breencast/br_instinct13.wav",
    "vo/breencast/br_instinct14.wav",
    "vo/breencast/br_instinct15.wav",
    "vo/breencast/br_instinct16.wav",
    "vo/breencast/br_instinct17.wav",
    "vo/breencast/br_instinct18.wav",
    "vo/breencast/br_instinct19.wav",
    "vo/breencast/br_instinct20.wav",
    "vo/breencast/br_instinct21.wav",
    "vo/breencast/br_instinct22.wav",
    "vo/breencast/br_instinct23.wav",
    "vo/breencast/br_instinct24.wav",
    "vo/breencast/br_instinct25.wav"
}