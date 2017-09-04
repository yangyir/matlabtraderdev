function [order,retbreakeven] = optstrat_deltaneutral(dictionary,tradingplatform,underlierinfo,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    %parameters
    p.addRequired('Dictionary',@(x) validateattributes(x,{'cDictionary'},{},'','Dictionary'));
    p.addRequired('TradingPlatform',@(x) validateattributes(x,{'cTradingPlatform'},{},'','TradingPlatform'));
    p.addRequired('UnderlierInfo',@isstruct);
    p.addParameter('MaximumSizePerOrder',{},@(x) validateattributes(x,{'numeric'},{},'','MaximumSizePerOrder'));
    p.addParameter('LiquidityAdjustment',{},@(x) validateattributes(x,{'numeric'},{},'','LiquidityAdjustment'));
    
    p.parse(dictionary,tradingplatform,underlierinfo,varargin{:});
    dictIn = p.Results.Dictionary;
    platform = p.Results.TradingPlatform;
    underlierinfo = p.Results.UnderlierInfo;
    px = underlierinfo.Price;
    nSize = underlierinfo.Volume;
    time = underlierinfo.Time;
    
    nMax = p.Results.MaximumSizePerOrder;

    if isempty(nMax)
        nMax = inf;  %default values
    end
    
    %assuming only the half of the tick can be executed
    if nMax > round(nSize/2)
        nMax = round(nSize/2);
    end
    
    liqAdj = p.Results.LiquidityAdjustment;
    if isempty(liqAdj)
        liqAdj = 0;
    end
        
    dict = dictIn;
    dict.Mode = 'SpotGamma-Cash';
    results = CCBPrice(dict);
    deltaCarryTarget = results.spotdelta;
    
    %todo:with multiple underlyings
%     book = dict.SecurityCollection;
%     underlier = book{1}.Underlier;
    underlier = underlierinfo.Instrument;
    
    positions = platform.getposition('Instrument',underlier);
    orders = platform.getorders;
    nOrders = size(orders,1);
    if isempty(positions)
        deltaCarried = 0;
        nCarried = 0;
    else
        direction = positions.pDirection;
        volume = positions.pVolume;
        if strcmpi(direction,'buy')
            deltaCarried = px*volume*underlier.ContractSize;
            nCarried = volume;
        else
            deltaCarried = -px*volume*underlier.ContractSize;
            nCarried = -volume;
        end
    end
    
    deltaResidual = deltaCarryTarget - deltaCarried;
    contractNotional = px*underlier.ContractSize;
    if abs(deltaResidual) >= contractNotional
        n = round(deltaResidual/contractNotional);
        if n > nMax
            n = nMax;
        end
        orderID = ['order',num2str(nOrders+1)];
        if nCarried == 0 || (sign(n) == sign(nCarried))
            %no existing positions or
            %direciton of the existing postion are the same as the new
            %positions
            if sign(n) == 1
                order = cOrder('OrderID',orderID,'Instrument',underlier,...
                    'direction','buy','offsetflag','open',...
                    'price',px+liqAdj*underlier.TickSize,...
                    'volume',n,'time',time);
            elseif sign(n) == -1
                order = cOrder('OrderID',orderID,'Instrument',underlier,...
                    'direction','sell','offsetflag','open',...
                    'price',px-liqAdj*underlier.TickSize,...
                    'volume',-n,'time',time);
            end
        else
            %direction of the existing positions are the opposite of the
            %new positions
            if sign(n) == 1 && sign(nCarried) == -1
                order = cOrder('OrderID',orderID,'Instrument',underlier,...
                    'direction','buy','offsetflag','close',...
                    'price',px+liqAdj*underlier.TickSize,...
                    'volume',n,'time',time);
            elseif sign(n) == -1 && sign(nCarried) == 1
                order = cOrder('OrderID',orderID,'Instrument',underlier,...
                    'direction','sell','offsetflag','close',...
                    'price',px-liqAdj*underlier.TickSize,...
                    'volume',-n,'time',time);
            end
        end
        %
        %calculate the break-even return
        gamma = results.spotgamma;
        ycs = dict.YieldCurveCollection;
        mktdatas = dict.MktDataCollection;
        for i = 1:size(ycs,1)
            ycs{i} = ycs{i}.DecayYieldCurve('DecayDate',businessdate(ycs{i}.ValuationDate,-1));
        end
        for i = 1:size(mktdatas,1)
            mktdatas{i} = mktdatas{i}.DecayMktData('DecayDate',businessdate(mktdatas{i}.ValuationDate,-1));
        end
        dict.YieldCurveCollection = ycs;
        dict.MktDataCollection = mktdatas;
        dict.Mode = 'SpotTheta';
        results = CCBPrice(dict);
        theta = results.spottheta;
        retbreakeven = 0.1*sqrt(2*abs(theta)/gamma);
        %
    else
        order = {};
        retbreakeven = NaN;
    end  
end