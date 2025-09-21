% Extract altitude and throttle vectors (no time column)
altitude = log_Altitude;
throttle = log_Throttle;

numPoints = length(altitude);
TruePhase = strings(numPoints,1);

for i = 1:numPoints
    TruePhase(i) = DeterminePhase(altitude(i), throttle(i));
end

phaseCategories = {'Taxi','Takeoff','Climb','Cruise','Descent','Landing'};
TruePhase = categorical(TruePhase, phaseCategories);
