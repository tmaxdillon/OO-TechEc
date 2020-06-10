[x_wave,y_wave] = wgs2utm(argBasin.wave.lat, argBasin.wave.lon);
[x_met,y_met] = wgs2utm(argBasin.met.lat, argBasin.met.lon);

diff = round(sqrt((x_wave-x_met)^2 + (y_wave-y_met)^2),1)