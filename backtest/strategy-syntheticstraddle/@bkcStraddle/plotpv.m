function [] = plotpv(obj)
%bkcStraddle
    if isempty(obj.pvs_),return;end
    figure(1);
    subplot(211);plot(obj.pvs_);title('straddle pv');
    subplot(212);plot(obj.S_);title('spot');
end