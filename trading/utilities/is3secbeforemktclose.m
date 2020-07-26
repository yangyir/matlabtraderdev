function [ flag ] = is3secbeforemktclose( t )
%IS3SECBEFOREMKTCLOSE Summary of this function goes here
%   Detailed explanation goes here
    runningmm = hour(t)*60+minute(t);
    
    flag = false;
    if (runningmm == 899 || runningmm == 914) && second(runningt) >= 56
        cobd = floor(runningt);
        nextbd = businessdate(cobd);
        flag = nextbd - cobd <= 3;
    end


end

