function [ret] = riskmanagement_wadupdate(obj,varargin)
%cSpiderman private method:riskmanagement_wad
    ret = struct('inconsistence',0,...
        'reason','n/a');
    if strcmpi(obj.status_,'closed'), return; end
    if strcmpi(obj.trade_.status_,'closed'), return; end
    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('ExtraInfo',{},@isstruct);
    p.parse(varargin{:});
    extrainfo = p.Results.ExtraInfo;
    
    trade = obj.trade_;
    direction = trade.opendirection_;
    p = extrainfo.p;
    wad = extrainfo.wad;
    
    if ~isempty(trade.instrument_)
        ticksize = trade.instrument_.tick_size;
    else
        ticksize = 0;
    end
    
    if direction == 1
        if p(end,5) > obj.cphigh_
            obj.cphigh_ = p(end,5);
            if wad(end) < obj.wadhigh_ - 2*ticksize
                ret = struct('inconsistence',1,...
                    'reason','new high price w/o wad being higher');
                return
            else
                if wad(end) >  obj.wadhigh_
                    obj.wadhigh_ = wad(end);
                end
            end
        end
        %
        if wad(end) >= obj.wadhigh_
            obj.wadhigh_ = wad(end);
            if p(end,5) < obj.cphigh_ - 2*ticksize
                ret = struct('inconsistence',1,...
                    'reason','new high wad w/o price being higher');
                return
            else
                if p(end,5) > obj.cphigh_
                    obj.cphigh_ = p(end,5);
                end
            end
        end
        %
%         if p(end,5) > obj.cpopen_ && wad(end) <= obj.wadopen_
%             ret = struct('inconsistence',1,...
%                 'reason','higher price to open w/o wad being higher');
%             return
%         end
        %
%         if p(end,5) == obj.cpopen_ && wad(end) < obj.wadopen_
%             ret = struct('inconsistence',1,...
%                 'reason','same price to open with lower wad');
%             return
%         end
        %
    elseif direction == -1
        if p(end,5) < obj.cplow_-ticksize
            obj.cplow_ = p(end,5);
            if wad(end) > obj.wadlow_ + 2*ticksize
                ret = struct('inconsistence',1,...
                    'reason','new low price w/o wad being lower');
                return
            else
                if wad(end) <= obj.wadlow_
                    obj.wadlow_ = wad(end);
                end
            end
        end
        
        if wad(end) <= obj.wadlow_
            obj.wadlow_ = wad(end);
            if p(end,5) > obj.cplow_ + 2*ticksize
                ret = struct('inconsistence',1,...
                    'reason','new low wad w/o price being lower');
                return
            else
                if p(end,5) <= obj.cplow_
                    obj.cplow_ = p(end,5);
                end
            end
        end
        %
%         if p(end,5) < obj.cpopen_ && wad(end) >= obj.wadopen_
%             ret = struct('inconsistence',1,...
%                 'reason','lower price to open w/o wad being lower');
%             return
%         end
        %
%         if p(end,5) == obj.cpopen_ && wad(end) > obj.wadopen_
%             ret = struct('inconsistence',1,...
%                 'reason','same price to open with higher wad');
%             return
%         end
        %
    end
    
end