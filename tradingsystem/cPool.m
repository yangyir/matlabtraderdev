classdef cPool
    %class for a collection or pool of cPostions
    properties
        pPositions
    end
    
    methods
        function print(obj)
            for i = 1:size(obj.pPositions,1)
                obj.pPositions{i}.print;
            end
        end
        
        
        function pos = getposition(obj,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addParameter('Instrument',{},@(x)validateattributes(x,{'cContract','struct'},{},'','Instrument'));
            p.parse(varargin{:});
            instrument = p.Results.Instrument;
            if isempty(instrument)
                pos = obj.pPositions;
            else
                if isempty(obj.pPositions)
                    pos = {};
                    return
                end
                flag = false;
                for i = 1:size(obj.pPositions,1)
                    if strcmpi(obj.pPositions{i}.pInstrument.BloombergCode,instrument.BloombergCode)
                        flag = true;
                        break
                    end
                end
                if flag
                    pos = obj.pPositions{i};
                else
                    pos = {};
                end
            end
        end % end of getposition function
        %
        
        function obj = updateposition(obj,trade)
            %update the pool with new trade
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addRequired('Trade',@(x)validateattributes(x,{'cTrade'},{},'','Trade'));
            p.parse(trade);
            trade = p.Results.Trade;
            if isempty(trade)
                %nothing to do in case no trade is given
                return
            end
            
            if strcmpi(trade.pOffsetFlag,'open')
                %open a new trade    
                obj = obj.add(trade);
            else
                %close exisiting positions
                obj = obj.remove(trade);
            end   
        end %end of updateposition function
        %
        
        
    end %end of methods
    
    
    methods (Access = public)
        function obj = cPool(varargin)
            obj = init(obj,varargin{:});
        end
        %
    end %end of methods
    
    methods (Access = private)
        function obj = init(obj,varargin)
            if isempty(varargin)
                obj.pPositions = {};
            end
        end % end of init function
        %
        
        function obj = add(obj,trade)
            if ~isa(trade,'cTrade')
                error('cPool:add:invalid input!');
            end
                        
            instrument = trade.pInstrument;
            posOld = obj.getposition('Instrument',instrument);
            
            if isempty(posOld)
                %there is no existing postion with such contract
                n = size(obj.pPositions,1);
                posNew = cell(n+1,1);
                posNew(1:end-1) = obj.pPositions;
                posNew{end} = cPosition('Trade',trade);
                obj.pPositions = posNew;
            else
                if strcmpi(posOld.pDirection,'neutral')
                    %there were positions but unwinded completely at later
                    %stage
                    posNew = cPosition('Trade',trade);
                else
                    %there are existing positions
                    priceOld = posOld.pPrice;
                    volumeOld = posOld.pVolume;
                    volumeNew = volumeOld+trade.pVolume;
                    priceNew = priceOld*volumeOld+trade.pPrice*trade.pVolume;
                    priceNew = priceNew/volumeNew;
                    posNew = posOld;
                    posNew.pTime = trade.pTime;
                    posNew.pPrice = priceNew;
                    posNew.pVolume = volumeNew;
                end
                for i = 1:size(obj.pPositions,1)
                    if strcmpi(obj.pPositions{i}.pInstrument.BloombergCode,trade.pInstrument.BloombergCode)
                        obj.pPositions{i}=posNew;
                        break
                    end
                end
            end
        end % end of add function
        %
        
        function obj = remove(obj,trade)
            %todo:to distinguish the close/closetoday and
            %closeyesterday
            if ~isa(trade,'cTrade')
                error('cPool:remove:invalid input!');
            end
            
            instrument = trade.pInstrument;
            posOld = obj.getposition('Instrument',instrument);
            
            if isempty(posOld)
                %this must be an error as there are no positions
                %associated with the same futures instrument
                error('cPool:remove:trade is required!');
            end
            
            if posOld.pVolume < trade.pVolume
                error('cPool:remove:close size is bigger than the current position size');
            end
            
            priceOld = posOld.pPrice;
            volumeOld = posOld.pVolume;
            volumeNew = volumeOld-trade.pVolume;
            priceNew = priceOld*volumeOld-trade.pPrice*trade.pVolume;
            if volumeNew ~= 0
                priceNew = priceNew/volumeNew;
                posNew = posOld;
                posNew.pTime = trade.pTime;
                posNew.pPrice = priceNew;
                posNew.pVolume = volumeNew;
            else
                posNew = posOld;
                posNew.pTime = trade.pTime;
                posNew.pPrice = 0;
                posNew.pVolume = 0;
                posNew.pDirection = 'neutral';
            end
            
            
            for i = 1:size(obj.pPositions,1)
                if strcmpi(obj.pPositions{i}.pInstrument.BloombergCode,trade.pInstrument.BloombergCode)
                    obj.pPositions{i}=posNew;
                    break
                end
            end
            
        end %end of remove function
        %
    end %end of methods
end