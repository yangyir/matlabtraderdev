function [] = loadpositionsfromcounter(obj,varargin)
%cBook
    p = inputParser;
    p.CaseSensitive = false; p.KeepUnmatched = true;
    p.addParameter('FutList',{},...
        @(x) validateattributes(x,{'char','cell'},{},'','FutList'));
    p.addParameter('OptUndList',{},...
        @(x) validateattributes(x,{'char','cell'},{},'','OptUndList'));
    p.parse(varargin{:});
    
    p.parse(varargin{:});
    futs = p.Results.FutList;
    optund = p.Results.OptUndList;
    
    if isempty(obj.counter_), return; end
    
    obj.positions_ = {};
    
    pos = obj.counter_.queryPositions;
    npos = size(pos,2);
    
    if isempty(futs) && isempty(optund)
        % load all positions from counter
        for i = 1:npos
            if pos(i).total_position > 0
                obj.addpositions('code',pos(i).asset_code,...
                    'price',pos(i).avg_price,'volume',pos(i).direction*pos(i).total_position);
            end
        end
        return
    end
    
    if ~isempty(futs) 
    end
    
    if ~isempty(futs)
        nfut = size(futs,1);
        for i = 1:nfut
            
        end
    end
    
    if ~isempty(optund)
        noptund = size(optund);
        
    end
    
    
        
end