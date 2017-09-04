function orders = optstrat_genorders(tp,underlierinfo,delta,varargin)
    %sanity checks
    if ~isa(tp,'cTradingPlatform')
        error('optstrat_genorders:invalid input of tradingplatform')
    end
    if ~isstruct(underlierinfo)
        error('optstrat_genorders:invalid input of underlierinfo')
    end
    
    if isempty(varargin)
        participateRate = 1.0;
    else
        participateRate = varargin{1};
    end
    
    underlier = underlierinfo.Instrument;
    time = underlierinfo.Time;
    price = underlierinfo.Price;
    contractSize = underlier.ContractSize;
    
    position = tp.getposition('Instrument',underlier);
    if isempty(position)
        nCarry = 0;
    else
        if strcmpi(position.pDirection,'buy') 
            nCarry = position.pVolume;
        else
            nCarry = -position.pVolume;
        end
    end
    
    deltaCarry = price*nCarry*contractSize;
    deltaResidual = delta-deltaCarry;
    nExtra = deltaResidual/price/contractSize;
    
    if nExtra > 0
        if nExtra - floor(nExtra) >= participateRate
            nExtra = floor(nExtra)+1;
        else
            nExtra = floor(nExtra);
        end
    elseif nExtra < 0
        if ceil(nExtra) - nExtra >= participateRate
            nExtra = ceil(nExtra)-1;
        else
            nExtra = ceil(nExtra);
        end
    end
    
    if nExtra == 0
        orders = {};
        return
    elseif nExtra > 0
        direction = 'buy';
    else
        direction = 'sell';
    end
        
    if nCarry == 0 || sign(nCarry) == sign(nExtra)
        offsetflag = 'open';
        orderid = ['order',num2str(size(tp.getorders,1)+1)];
        order = cOrder('orderid',orderid,...
            'instrument',underlier,...
            'direction',direction,...
            'offsetflag',offsetflag,...
            'price',price,...
            'volume',abs(nExtra),....
            'time',time);
       orders = {order};     
    elseif sign(nCarry) + sign(nExtra) == 0
        %note:here we are to close trades or even open trades in the
        %opposite direction as of the existing old trades, however, we
        %might need to update the code for SHFE in case we can automatilly
        %trade with these codes in the future
       
        if abs(nExtra) <= abs(nCarry)
            offsetflag = 'close';
            orderid = ['order',num2str(size(tp.getorders,1)+1)];
            order = cOrder('orderid',orderid,...
                'instrument',underlier,...
                'direction',direction,...
                'offsetflag',offsetflag,...
                'price',price,...
                'volume',abs(nExtra),....
                'time',time);
            orders = {order};
        else
            offsetflag = 'close';
            orderid = ['order',num2str(size(tp.getorders,1)+1)];
            order1 = cOrder('orderid',orderid,...
                'instrument',underlier,...
                'direction',direction,...
                'offsetflag',offsetflag,...
                'price',price,...
                'volume',nCarry,....
                'time',time);
            %
            offsetflag = 'open';
            orderid = ['order',num2str(size(tp.getorders,1)+1)];
            order2 = cOrder('orderid',orderid,...
                'instrument',underlier,...
                'direction',direction,...
                'offsetflag',offsetflag,...
                'price',price,...
                'volume',abs(nCarry-nExtra),....
                'time',time);
            orders = {order1;order2};
        end
    end
    

        
