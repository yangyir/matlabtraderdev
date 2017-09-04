function varargout = pairs_trading(varargin)
p = inputParser;
p.CaseSensitive = false; p.KeepUnmatched = true;
p.addParameter('Leg1',{},@(x) validateattributes(x,{'cContract'},{},'','Leg1'));
p.addParameter('Leg2',{},@(x) validateattributes(x,{'cContract'},{},'','Leg2'));
p.addParameter('FromDate',[],@(x) validateattributes(x,{'char','numeric'},{},'','FromDate'));
p.addParameter('ToDate',[],@(x) validateattributes(x,{'char','numeric'},{},'','ToDate'));
p.addParameter('Model','cointegration',@ischar);
p.addParameter('Frequency','1m',@ischar);
p.addParameter('LookbackPeriod','1d',@(x) validateattributes(x,{'char','numeric'},{},'','FromDate'));
p.addParameter('RebalancePeriod','1h',@(x) validateattributes(x,{'char','numeric'},{},'','FromDate'));
p.addParameter('UpperBound',1.96,@isnumeric);
p.addParameter('LowerBound',-1.96,@isnumeric);
p.addParameter('TransactionCost',0,@isnumeric);


p.parse(varargin{:});
leg1 = p.Results.Leg1;
leg2 = p.Results.Leg2;
date_from = p.Results.FromDate;
date_to = p.Results.ToDate;
model = p.Results.Model;

if ~strcmpi(model,'cointegration')
    error('invalid trading model')
end

freq = p.Results.Frequency;
period_lookback = p.Results.LookbackPeriod;
period_rebalance = p.Results.RebalancePeriod;
bound_upper = p.Results.UpperBound;
bound_lower = p.Results.LowerBound;
cost = p.Results.TransactionCost;

if ~isnumeric(period_lookback)
    error('error for now')
    %todo:
end

if ~isnumeric(period_rebalance)
    error('error for now')
    %todo:
end


data1 = leg1.getTimeSeries('connection','bloomberg','frequency',freq,...
    'fields',{'close','volume'},'fromdate',date_from,'enddate',date_to);

data2 = leg2.getTimeSeries('connection','bloomberg','frequency',freq,...
    'fields',{'close','volume'},'fromdate',date_from,'enddate',date_to);

[~,idx1,idx2] = intersect(data1(:,1),data2(:,1));
series2 = [data1(idx1,2),data2(idx2,2)];

if strcmpi(model,'cointegration')
    % very often, the pairs will be convincingly cointegrated, or convincingly
    % NOT integrated. In these cases, a warning is issued not to read too much
    % into the test statistic. Since we don't use the test statistic, we can
    % suppress these warnings
    warning('off','econ:egcitest:LeftTailStatTooSmall')
    warning('off','econ:egcitest:LeftTailStatTooBig')
end

M = period_lookback;
N = period_rebalance;

% sweep across the entire time series
% every N periods, we use the previous M period's worth of information to
% estimate the cointegrating relationship (if it exits)
% we then use this estimated relationship to identify trading opportunities
% until the next rebalancing date

s = zeros(size(series2,1),2);

indicate = zeros(length(series2),1);

for i = max(M,N):N:length(s)-N
    % calibrate cointegration model by looking back
    [h,~,~,~,reg1] = egcitest(series2(i-M+1:i,:));
    if h ~= 0
        % only engage in trading if we reject the null hypothesis that no
        % cointegrating relationship exists.
        
        % The strategy
        % 1. Compute residuals over next N observations
        res = series2(i:i+N-1,1) ...
            - (reg1.coeff(1) + reg1.coeff(2).*series2(i:i+N-1,2));
        
        % 2. If the residuals are large and positive, then the first series
        % is likely to decline vs. the seond series. Short the first series
        % by a scaled number of shares and long the second series by 1
        % share. If the residuals are large and negative, do the opposite
        indicate(i:i+N-1) = res/reg1.RMSE;
        
        s(i:i+N-1, 2) = (res/reg1.RMSE > bound_upper) ...
            - (res/reg1.RMSE < bound_lower);
        s(i:i+N-1, 1) = -reg1.coeff(2) .* s(i:i+N-1, 2);
        
    end
    
end

% calculate 
r  = sum([0 0; s(1:end-1, :) .* diff(series2) - abs(diff(s))*cost/2] ,2);
sh = sqrt(252)*sharpe(r,0); 

if nargout == 0
    % Plot results
    ax(1) = subplot(3,1,1);
    plot(series2), grid on
    legend('5y bondfut','10y bondfut')
    title(['Pairs trading results, Sharpe Ratio = ',num2str(sh,3)])
    ylabel('Price (CNY)')
    
    ax(2) = subplot(3,1,2);
    plot([indicate,bound_upper*ones(size(indicate)),bound_lower*ones(size(indicate))])
    grid on
    legend('Indicator','5y bondfut: Over bought','5y bondfut: Over sold',...
        'Location','NorthWest')
    title(['Pairs indicator: rebalance every ' num2str(N)...
        ' minutes with previous ' num2str(M) ' minutes'' prices.'])
    ylabel('Indicator')
    
    ax(3) = subplot(3,1,3);
    plot([s,cumsum(r)]), grid on
    legend('Position for 5y bondfut','Position for 10y bondfut','Cumulative Return',...
        'Location', 'NorthWest')
    title(['Final Return = ',num2str(sum(r),3),' (',num2str(sum(r)/mean(series2(1,:))*100,3),'%)'])
    ylabel('Return (CNY)')
    xlabel('Serial time number')
    linkaxes(ax,'x')
else
   % Return values
    for i = 1:nargout
        switch i
            case 1
                varargout{1} = s; % signal
            case 2
                varargout{2} = r; % return (pnl)
            case 3
                varargout{3} = sh; % sharpe ratio
            case 4
                varargout{4} = indicate; % indicator
            otherwise
                warning('PAIRS:OutputArg',...
                    'Too many output arguments requested, ignoring last ones');
        end 
    end
end




end