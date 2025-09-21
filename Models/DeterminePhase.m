function phase = DeterminePhase(altitude, throttle)
    if altitude <= 50 && throttle <= 0.4
        phase = "Taxi";
    elseif throttle > 0.9 && altitude < 1000
        phase = "Takeoff";
    elseif throttle > 0.7 && altitude < 9000
        phase = "Climb";
    elseif throttle >= 0.5 && altitude >= 9000
        phase = "Cruise";
    elseif throttle < 0.6 && altitude < 9000 && altitude > 500
        phase = "Descent";
    elseif throttle < 0.4 && altitude <= 500
        phase = "Landing";
    else
        if altitude <= 50
            phase = "Taxi";
        else
            phase = "Cruise";
        end
    end
end
