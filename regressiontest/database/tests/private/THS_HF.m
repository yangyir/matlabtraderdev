function data = THS_HF(varargin)
% Offline fixture: return only end-labelled bars in the provider query range.
    global thsIntradayTestData thsIntradayTestCalls
    thsIntradayTestCalls{end+1} = varargin;
    times = datenum(thsIntradayTestData.time,'yyyy-mm-dd HH:MM');
    first = datenum(varargin{4});
    last = datenum(varargin{5});
    data = thsIntradayTestData(times >= first & times <= last,:);
end
