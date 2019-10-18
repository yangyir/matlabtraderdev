function [ret] = tdsq_reverseshort(candlek,bsnum,macdnum,macdbsnum,ptrigger,pshift)
% function to return boolean
% true:to open a short position
% false:not to open a short position
    if nargin == 7
        pshift = 0;
    end
    
    %满足以下条件
    %1.收盘价小于ptrigger
    %  或者当开盘低开的时候满足开盘价小于ptrigger-pshift
    %2.如果macdnum为负并且同时满足bsnum>=1且macdbsnum>=1
    %  或者满足macdnum为正但是同时满足bsnum>=1且macdbsnum>=3
    
    f1 = candlek(5) < ptrigger || candlek(2) < ptrigger - pshift;
    f2 = (macdnum < 0 && bsnum >= 1 && macdbsnum >= 1) || ...
        (macdnum > 0 && bsnum >= 3 && macdbsnum >= 3);
    ret = f1 && f2;

end