function [ret] = tdsq_reverselong(candlek,ssnum,macdnum,macdssnum,ptrigger,pshift)
% function to return boolean
% true:to open a long position
% false:not to open a long position
    if nargin == 7
        pshift = 0;
    end
    
    %满足以下条件
    %1.收盘价大于ptrigger
    %  或者当开盘高开的时候满足开盘价大于ptrigger+pshift
    %2.如果macdnum为正并且同时满足ssnum>=1且macdssnum>=1
    %  或者满足macdnum为负但是同时满足ssnum>=1且macdssnum>=3
    
    f1 = candlek(5) > ptrigger || candlek(2) > ptrigger + pshift;
    f2 = (macdnum > 0 && ssnum >= 1 && macdssnum >= 1) || ...
        (macdnum < 0 && ssnum >= 3 && macdssnum >= 3);
    ret = f1 && f2;

end