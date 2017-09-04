classdef cEntrust < handle
    %cEntrust 委托下单类
    
    properties
        % 核心信息 
        marketNo = '1';             %（@char）市场编号，'1'上交所，'2'深交所， 并非必须
        instrumentCode = '000000';  % （@char）合约代码,
        instrumentName = 'Untitled';    % 为了方便
        instrumentNo;   % 合约编号
        volume;         % 数量， TODO: 仅为正值？( 这是委托的数量 )
        price;          % 价格
        direction;      % （@double，setter控制）买卖方向，buy = 1; sell = -1;
        offsetFlag = 1; % （@double，setter控制）开平性质, open = 1; close = -1;
                
        entrustNo;            % 委托编号
        entrustType;          % 委托类型, market, limit, stop, fok etc.
        entrustStatus = 0;    % 委托状态, 0表示新对象
                               % 1表示填好了的新单（TODO：检查有效？）
                               % 2表示已下单（获得entrsutNo）
                               % 3，4，...未了结，每查一次加1
                               % -1表示了结了。
        %为CTP使用新增两个域
        entrustId = 0;        %柜台内部委托编号
        assetType = 'Futures'; %标的类型：'ETF'/'Option'/'Futures'
        
        %以下
        date@double = today;  % 日期， matlab 格式， 如735773
        time@double = now;    % 时间，matlab格式，如735773.324
        
        % 成交
        dealVolume@double = 0; % 成交数目
        dealAmount@double = 0; % 成交金额
        dealPrice;             % 成交均价
        dealNum@double = 0;    % 成交笔数


        % 撤单信息
        cancelVolume@double = 0;   % 撤单数量
        cancelTime;                % 撤单时间
        cancelNo;                  % 撤单号
        
        recvTime;   % 后台系统接收时间
        updateTime; % 最后修改时间
        
        
        % 相关信息
        tick;       % 时间对应的tick号
        strategyNo; % 策略编号，整数
        orderRef;   % 订单编号
        combNo;     % 组合编号
        roundNo;    % 回合编号
        
        % 费用信息
        fee@double = 0; % 手续费
        % 保证金
        
        % 合约乘数
        multiplier = 1;
        
        % 挂单排序（估计值）， 用于高频策略
        rankBE = -1;  % best estimation
        rankWE = -1;  % worst estimation
      
    end
    
    properties (SetAccess = 'private',Hidden = true)
        isCompleted;
    end
    
    properties
        % 增加委托、挂出、成交时间戳
        issue_time_;
        accept_time_;
        complete_time_;
        
        % 增加组合单ID， 默认简单单此处值为-1；
        combi_no_ = -1;
        
        
    end
    
    properties (GetAccess = public, SetAccess = private, Dependent)
        date2;                % 日期，double或char？，如'20140623'
        time2;                % double或char？ 时间 'HHMMSSFFF'
    end
    
    methods
        function date2 = get.date2(obj)
            date2 = datestr(obj.date,'yyyymmdd');
        end
        
        function time2 = get.time2(obj)
            time2 = datestr(obj.time,'yyyymmdd HH:MM:SS:FFF');
        end
        
    end
    
    methods
        function fillEntrust(obj,varargin)
            %fillEntrust(obj,Name,Value)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addParameter('MarketNo','1',@ischar);
            p.addParameter('InstrumentCode','000000',@ischar);
            p.addParameter('Direction',[],@(x) validateattributes(x,{'numeric','char'},{},'','Direction'));
            p.addParameter('Price',[],@isnumeric);
            p.addParameter('Volume',[],@isnumeric);
            p.addParameter('OffsetFlag',[],@(x) validateattributes(x,{'numeric','char'},{},'','OffsetFlag'));
            p.addParameter('InstrumentName','Untitled',@ischar);
            p.parse(varargin{:});
            
            obj.marketNo = p.Results.MarketNo;
            obj.instrumentCode = p.Results.InstrumentCode;
            
            directionIn = p.Results.Direction;
            if ischar(directionIn)
                switch directionIn
                    case {'1','buy','b'}   %买
                        obj.direction = 1;
                    case {'2','sell','s'}   
                        obj.direction = -1;
                    otherwise
                        obj.direction = 0;
                end
            elseif isnumeric(directionIn)
                obj.direction = directionIn;
            end
            
            priceIn = p.Results.Price;
            if priceIn <= 0
                error('cEntrust:fillEntrust with negative price')
            end
            obj.price = priceIn;
            
            volumeIn = p.Results.Volume;
            if volumeIn <= 0
                error('cEntrust:fillEntrust with negative volue')
            end
            obj.volume = volumeIn;
            
            
            offsetflag = p.Results.OffsetFlag;
            if ischar(offsetflag)
                switch offsetflag
                    case {'1','open','o'}   %开仓
                        obj.offsetFlag = 1;
                    case {'2','close','c'}  %平仓
                        obj.offsetFlag = -1;
                    otherwise
                        obj.offsetFlag = 0;
                end
            elseif isnumeric(offsetflag)
                obj.offsetFlag = offsetflag;
            end
            
            obj.date = today;
            obj.time = now;
            
             
        end
        
    end
    
    
end