function phase = DeterminePhase(altitude, throttle)
    % Simple logic for flight phase classification
    
    if altitude <= 50 && throttle <= 0.4
        phase = "Taxi";
    elseif altitude <= 200 && throttle > 0.8
        phase = "Takeoff";
    elseif altitude > 200 && altitude <= 10000
        phase = "Climb";
    elseif altitude > 10000 && altitude <= 11000
        phase = "Cruise";
    elseif altitude > 1000 && throttle < 0.3
        phase = "Descent";
    else
        phase = "Landing";
    end
end
