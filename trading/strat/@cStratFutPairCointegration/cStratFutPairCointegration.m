classdef cStratFutPairCointegration < cStrat
    properties
        data_@double
        lookbackperiod_@double = 270
        rebalanceperiod_@double = 180
        upperbound_@double = 1.96
        lowerbound_@double = -1.96
        %
        lastrebalancedatetime1_@double
    end
    
    properties (Dependent = true)
        lastrebalancedatetime2_@char
        nextrebalancedatetime1_@double
        nextrebalancedatetime2_@char
    end
    
    properties (Access = public)
        cointegrationparams_
    end
    
    methods
        function obj = cStratFutPairCointegration
            obj.name_ = 'futpaircointegration';
            warning('off','econ:egcitest:LeftTailStatTooSmall')
            warning('off','econ:egcitest:LeftTailStatTooBig')
        end    
    end
        
    %derived (abstract) methods from superclass
    methods
        function signals = gensignals(obj)
            signals = obj.gensignals_futpaircointegration;
        end
        %end of gensignals
        
        function [] = autoplacenewentrusts(obj,signals)
            obj.autoplacenewentrusts_futpaircointegration(signals)
        end
        %end of autoplacenewentrusts
        
        function [] = updategreeks(obj)
            obj.updategreeks_futpaircointegration
        end
            
        
        function [] = initdata(obj)
            obj.initdata_futpaircointegration;
        end
        %end of initdata
                
    end
    
    methods
        function lastrebalancedatetime2 = get.lastrebalancedatetime2_(obj)
            if ~isempty(obj.lastrebalancedatetime1_)
                lastrebalancedatetime2 = datestr(obj.lastrebalancedatetime1_,'yyyy-mm-dd HH:MM:SS');
            else
                lastrebalancedatetime2 = '';
            end
        end
        
        function nextrebalancedatetime1 = get.nextrebalancedatetime1_(obj)
            if ~isempty(obj.lastrebalancedatetime1_)
                datelast = floor(obj.lastrebalancedatetime1_);
                instruments = obj.getinstruments;
                if isempty(instruments)
                    nextrebalancedatetime1 = [];
                    return
                end
                try
                    samplefreqstr = obj.riskcontrols_.getconfigvalue('code',instruments{1}.code_ctp,'propname','SampleFreq');
                catch
                    samplefreqstr = '1m';
                end
                buckets = getintradaybuckets2('date',datelast,'frequency',samplefreqstr,'tradinghours',instruments{1}.trading_hours,'tradingbreak',instruments{1}.trading_break);
                lastindex = find(buckets == obj.lastrebalancedatetime1_);
                if isempty(lastindex), error('invalid last rebalance date/time specified');end
                nextindex = lastindex + obj.rebalanceperiod_;
                date1 = datelast;
                if nextindex > size(buckets,1)
                    indexshortfall = nextindex;
                    while indexshortfall > size(buckets,1)
                        indexshortfall = indexshortfall - size(buckets,1);
                        date2 = businessdate(date1,1);
                        date1 = date2;
                    end
                    nextrebalancedatetime1 = buckets(indexshortfall,1) + date1-datelast;
                else
                    nextrebalancedatetime1 = buckets(nextindex,1);
                end
            else
                nextrebalancedatetime1 = [];
            end
        end
        
        function nextrebalancedatetime2 = get.nextrebalancedatetime2_(obj)
            if ~isempty(obj.nextrebalancedatetime1_)
                nextrebalancedatetime2 = datestr(obj.nextrebalancedatetime1_,'yyyy-mm-dd HH:MM:SS');
            else
                nextrebalancedatetime2 = '';
            end
        end
        
        
    end
    
    methods (Access = private)

        [] = updategreeks_futpaircointegration(obj)
        signals = gensignals_futpaircointegration(obj)
        [] = autoplacenewentrusts_futpaircointegration(obj,signals)
        [] = initdata_futpaircointegration(obj)
        [] = updatapairdata(obj)
    end
    
    
    
    
end