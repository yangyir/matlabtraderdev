function [ flag ] = is2minbeforemktopen( t )
    runningmm = hour(t)*60+minute(t);
    
    flag = (runningmm >= 538 && runningmm < 540) || ...                     %08:58 to 08:59
            (runningmm >= 778 && runningmm < 780) || ...                    %12:58 to 12:59
            (runningmm >= 1258 && runningmm < 1260);                        %20:58 to 21:00

end

