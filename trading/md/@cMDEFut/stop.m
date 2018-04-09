function [] = stop(mdefut)
    mdefut.status_ = 'sleep';
    if isempty(mdefut.timer_), return; else stop(mdefut.timer_); end
end
%end of stop