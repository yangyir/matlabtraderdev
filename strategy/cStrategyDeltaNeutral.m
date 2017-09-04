classdef cStrategyDeltaNeutral < cStrategy
   %delta-neutral strategy with vanilla option positions
   properties
       %use breakeven return to control the frequency of delta hedging
       UseBreakEvenReturn
   end
   
   properties (Access = private)
       %end of day time window to automatically relance delta neutral position
       EODHedgeTimeWindow
       
       %the market might be volatile up and down when it opens, no hedging
       %is done at during the period since market opens
       InactiveHedgeTimeWindow
       
       %when use breakeven return to control the frequency of delta hedging
       %it is crucial to determine how much of the breakeven return is the
       %threshold, e.g. 50%, 100% or 150%
       ParticipateRatio
       
   end
   
   properties (GetAccess = public, SetAccess = private, Dependent)
       EODHedgeTimwWindowDayFrac
       InactiveHedgeTimeWindowDayFrac
   end
   
   methods
       %GET methods
       function timewindowdayfrac = get.EODHedgeTimwWindowDayFrac(obj)
           timewindowdayfrac = str2double(obj.EODHedgeTimeWindow(1:end-1))/1440;
       end
       %
       
       function timewindowdayfrac = get.InactiveHedgeTimeWindowDayFrac(obj)
           timewindowdayfrac = str2double(obj.InactiveHedgeTimeWindow(1:end-1))/1440;
       end
       %
       
   end
   
   methods
       function obj = cStrategyDeltaNeutral(varargin)
           obj = init(obj,varargin{:});
       end %end of constructor
       %
       
   end
   
   methods (Access = public)
       function [order,retbreakeven] = genorder(obj,varargin)
           p = inputParser;
           p.CaseSensitive = false;p.KeepUnmatched = true;
           p.addParameter('Book',{},@iscell);
           p.addParameter('UnderlierInfo',{},@(x)validateattributes(x,{'struct'},{},'UnderlierInfo'));
           p.addParameter('UnderlierVol',{},@(x)validateattributes(x,{'cMarketVol','struct'},{},'UnderlierVol'));
           p.addParameter('TradingPlatform',{},@(x)validateattributes(x,{'cTradingPlatform'},{},'TradingPlatform'));
           p.addParameter('LiquidityAdjustment',{},@(x)validateattributes(x,{'numeric'},{},'LiquidityAdjustment'));
           p.addParameter('MaximumSizePerOrder',{},@(x)validateattributes(x,{'numeric'},{},'MaximumSizePerOrder'));
           p.addParameter('MarketMoveBreakEven',{},@(x)validateattributes(x,{'numeric'},{},'MarketMoveBreakEven'));
           p.parse(varargin{:});
           book = p.Results.Book;
           for i = 1:size(book,1)
               if ~isa(book{i},'cSecurity')
                   error('cStrategyDeltaNeutral:genorder:invalid input of Book.')
               end
           end
           underlierinfo = p.Results.UnderlierInfo;
           vol = p.Results.UnderlierVol; 
           platform = p.Results.TradingPlatform;
           if isempty(platform)
               error('cStrategyDeltaNeutral:a tradingplatform is required!')
           end
           
           liqadj = p.Results.LiquidityAdjustment;
           if isempty(liqadj)
               liqadj = 0;
           end
           
           maxOrderSize = p.Results.MaximumSizePerOrder;
           if isempty(maxOrderSize)
               %by default we assume we can buy or sell any size of the
               %underlying futures
               maxOrderSize = inf;
           end
           
           breakeveninfo = p.Results.MarketMoveBreakEven;
           if isempty(breakeveninfo)
               breakeveninfo = NaN;
           end
           
           time = underlierinfo.Time;
           dateEOD = floor(time);
           issueDate = datenum(book{1}.IssueDate,'yyyy-mm-dd');
           
           %if the time is before 
           if dateEOD < issueDate
               order = {};
               retbreakeven = NaN;
               return
           end
           
           openTimes = underlierinfo.Instrument.getOpenTimes;
           if size(openTimes,1) > 2
               hasEvening = 1;
           else
               hasEvening = 0;
           end
           hh = hour(time)/24;
           if ~hasEvening
               isEvening = 0;
               if hh >= openTimes(2)
                   isAfternoon = 1;
                   isMorning = 0;
               else
                   isAfternoon = 0;
                   isMorning = 1;
               end
           else
               if hh >= openTimes(1) && hh < openTimes(2)
                   isMorning = 1;
                   isAfternoon = 0;
                   isEvening = 0;
               elseif hh >= openTimes(2) && hh < openTimes(3)
                   isMorning = 0;
                   isAfternoon = 1;
                   isEvening = 0;
               else
                   isMorning = 0;
                   isAfternoon = 0;
                   isEvening = 1;
               end
           end
           
           rebalanceTime = underlierinfo.Instrument.getReblanceTime;
           mktCloseNum = dateEOD+rebalanceTime;
           
           inactiveTimeWindow = obj.InactiveHedgeTimeWindowDayFrac;
           if isMorning
               if time - (dateEOD+openTimes(1)) <= inactiveTimeWindow
                   % nothing to do if the market just opened in the morning
                   % session
                   order = {};
                   retbreakeven = NaN;
                   return
               end
           elseif isAfternoon
               %we may just continue trading in the afternoon session
           elseif isEvening
               if (time >= dateEOD+openTimes(3)) && (time-(dateEOD+openTimes(3))<=inactiveTimeWindow)
                   %nothing to do if the market just opened in the evening
                   %session
                   order = {};
                   retbreakeven = NaN;
                   return
               end
           end
           
           if isEvening && time-dateEOD >= openTimes(3)
               %some underliers traded during the night hours and we shall
               %move the mktClose time to the next business date
               dateEOD = businessdate(dateEOD,1);
               mktCloseNum = dateEOD+rebalanceTime;               
           end
           
           timeWindow = obj.EODHedgeTimwWindowDayFrac;
           if ((dateEOD==issueDate) && (mktCloseNum-time>timeWindow))
               order = {};
               retbreakeven = NaN;
               return
           end
           
           if obj.UseBreakEvenReturn && ~strcmpi(underlierinfo.Type,'eod') ...
                   && ~isnan(breakeveninfo)
               threshold = obj.ParticipateRatio*breakeveninfo;
               ret = underlierinfo.Price/underlierinfo.ReferencePrice-1;
               if abs(ret) < threshold 
                   order = {};
                   retbreakeven = NaN;
                   return
               end
           end
           
           if isempty(vol)
               %old code shall be removed
               error('cOrder:genorder:invalid UnderlierVol input!');
           end
           
           model = loadobjfromfile('model_ccbsmc','model');
           paycurrency = book{1}.PayCurrency;
           yc = loadobjfromfile([paycurrency,datestr(dateEOD,'yyyymmdd')],'yieldcurve');
           mktdata = CreateObj(book{1}.AssetName,'mktdata',...
               'valuationdate',dateEOD,...
               'assetname',book{1}.AssetName,...
               'currency',paycurrency,...
               'type','forward',...
               'spot',underlierinfo.Price);
               
           if mktCloseNum-time<=timeWindow
              %end of day reblance time
              %it is compulsory to hedge to guarantee the delta-neurtal
              dateCarry = businessdate(dateEOD,1);
              ycUsed = yc.DecayYieldCurve('DecayDate',dateCarry);
              mktdataUsed = mktdata.DecayMktData('DecayDate',dateCarry);
           else
               %intraday hedge
               %todo:intraday hedge methodologies
               ycUsed = yc;
               ycUsed.ValuationDate = dateEOD;
               mktdataUsed = mktdata;
           end
           
           dictionary = CreateObj('dict','DICTIONARY',...
               'YieldCurve',ycUsed,...
               'MktData',mktdataUsed,...
               'Vol',vol,...
               'Book',book,...
               'Model',model,...
               'Mode','SPOTGAMMA');
           
           [order,retbreakeven] = optstrat_deltaneutral(dictionary,platform,underlierinfo,...
               'LiquidityAdjustment',liqadj,...
               'MaximumSizePerOrder',maxOrderSize);
           
       end %end of function "genorde"
   end
   
   methods (Access = private)
       function obj = init(obj,varargin)
           p = inputParser;
           p.CaseSensitive = false;p.KeepUnmatched = true;
           p.addParameter('EODHedgeTimeWindow','2m',@(x)validateattributes(x,{'char'},{},'','EODHedgeTimeWindow'));
           p.addParameter('InactiveHedgeTimeWindow','5m',@(x)validateattributes(x,{'char'},{},'','InactiveHedgeTimeWindow'));
           p.addParameter('UseBreakEvenReturn',false,@(x)validateattributes(x,{'logical'},{},'','UseBreakEvenReturn'));
           p.addParameter('ParticipateRatio',1.0,@(x)validateattributes(x,{'numeric'},{},'','ParticipateRatio'));
           p.parse(varargin{:});
           obj.EODHedgeTimeWindow = p.Results.EODHedgeTimeWindow;
           obj.InactiveHedgeTimeWindow = p.Results.InactiveHedgeTimeWindow;
           obj.UseBreakEvenReturn = p.Results.UseBreakEvenReturn;
           obj.ParticipateRatio = p.Results.ParticipateRatio;
       end %end of function "init"
       %
       
   end
    
end