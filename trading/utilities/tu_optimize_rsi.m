function [ mat,rsi_last ] = tu_optimize_rsi( eoddata, doplot )
%function to optimize the rsi parameter for signal
rsi = rsindex(eoddata(:,2),14);

%use the rsi as the signal indicator
mat = [rsi(15:end-1),eoddata(16:end,2)-eoddata(15:end-1,2)];

%sort the indicator 
mat = sortrows(mat);
mat = [mat(:,1),cumsum(mat(:,2))];

if nargin < 2
    doplot = true;
end

if doplot
    close all;
    plot(mat(:,1),mat(:,2),'b');grid on;
    xlabel('relative strength index');
    ylabel('cumulative performance');
end

rsi_last = rsi(end);

fprintf('last rsi:%4.2f\n',rsi_last);

end

