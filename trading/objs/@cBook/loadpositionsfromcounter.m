function [] = loadpositionsfromcounter(obj,varargin)
%cBook
    if isempty(obj.counter_), return; end
    
    p = inputParser;
    p.CaseSensitive = false; p.KeepUnmatched = true;
    p.addParameter('FutList',{},...
        @(x) validateattributes(x,{'char','cell'},{},'','FutList'));
    p.addParameter('OptUndList',{},...
        @(x) validateattributes(x,{'char','cell'},{},'','OptUndList'));
    p.parse(varargin{:});
    
    futs = p.Results.FutList;
    allfutflag = false;
    if ischar(futs)
        if strcmpi(futs,'all'), allfutflag = true;end
        futs = {futs};
    end
    
    optund = p.Results.OptUndList;
    alloptflag = false;
    if ischar(optund)
        if strcmpi(optund,'all'),alloptflag = true;end
        optund = {optund};
    end
    
    obj.positions_ = {};
    
    pos = obj.counter_.queryPositions;
    npos = size(pos,2);
    
    if isempty(futs) && isempty(optund)
        % load all positions from counter
        for i = 1:npos
            if pos(i).total_position > 0
                s = code2instrument(pos(i).asset_code);
                multi = s.contract_size;
                if ~isempty(strfind(s.code_bbg,'TFC')) || ~isempty(strfind(s.code_bbg,'TFT'))
                    multi = multi/100;
                end
                
                obj.addpositions('code',pos(i).asset_code,...
                    'price',pos(i).avg_price/multi,'volume',pos(i).direction*pos(i).total_position);
            end
        end
        return
    end
    
    if ~isempty(futs) && allfutflag
        %load all futures positions within the counter
        for i = 1:npos
            if pos(i).total_position > 0
                isopt = isoptchar(pos(i).asset_code);
                if isopt, continue; end
                s = cFutures(pos(i).asset_code);
                s.loadinfo([pos(i).asset_code,'_info.txt']);
                multi = s.contract_size;
                if ~isempty(strfind(s.code_bbg,'TFC')) || ~isempty(strfind(s.code_bbg,'TFT'))
                    multi = multi/100;
                end
                obj.addpositions('code',pos(i).asset_code,...
                    'price',pos(i).avg_price/multi,'volume',pos(i).direction*pos(i).total_position);
            end
        end
    end
    
    if ~isempty(futs) && ~allfutflag
        nfut = size(futs,1);
        for i = 1:npos
            if pos(i).total_position == 0, continue;end
            for j = 1:nfut
                if strcmpi(pos(i).asset_code,futs{j})
                    s = cFutures(pos(i).asset_code);
                    s.loadinfo([pos(i).asset_code,'_info.txt']);
                    multi = s.contract_size;
                    if ~isempty(strfind(s.code_bbg,'TFC')) || ~isempty(strfind(s.code_bbg,'TFT'))
                        multi = multi/100;
                    end
                    obj.addpositions('code',pos(i).asset_code,...
                    'price',pos(i).avg_price/multi,'volume',pos(i).direction*pos(i).total_position);
                end
            end
        end
    end
    
    if ~isempty(optund) && alloptflag
        %load all option positions within the counter
        underliers = cell(npos,1);
        for i = 1:npos
            if pos(i).total_position == 0, continue;end
            [isopt,~,~,underlierstr,~] = isoptchar(pos(i).asset_code);
            if ~isopt, continue; end
            s = cOption(pos(i).asset_code);
            s.loadinfo([pos(i).asset_code,'_info.txt']);
            obj.addpositions('code',pos(i).asset_code,...
                'price',pos(i).avg_price/s.contract_size,'volume',pos(i).direction*pos(i).total_position);
            underliers{i,1} = underlierstr;
        end
        %load underlier futures
        for i = 1:npos
            if isempty(underliers{i,1}), continue; end
            for j = 1:npos
                if pos(j).total_position == 0, continue;end
                if strcmpi(pos(j).asset_code,underliers{i,1})
                    s = cFutures(pos(j).asset_code);
                    s.loadinfo([pos(j).asset_code,'_info.txt']);
                    obj.addpositions('code',pos(j).asset_code,...
                            'price',pos(j).avg_price/s.contract_size,...
                            'volume',pos(j).direction*pos(i).total_position);
                end
            end
        end
    end
    
    if ~isempty(optund) && ~alloptflag
        noptund = size(optund,1);
        for i = 1:npos
            if pos(i).total_position == 0, continue;end
            [isopt,~,~,underlierstr,~] = isoptchar(pos(i).asset_code);
            for j = 1:noptund
                if strcmpi(pos(i).asset_code,optund{j}) || ...
                        strcmpi(underlierstr,optund{j})
                    if isopt
                        s = cOption(pos(i).asset_code);
                    else
                        s = cFutures(pos(i).asset_code);
                    end
                    s.loadinfo([pos(i).asset_code,'_info.txt']);
                    obj.addpositions('code',pos(i).asset_code,...
                    'price',pos(i).avg_price/s.contract_size,'volume',pos(i).direction*pos(i).total_position);
                end
            end
        end
    end
    
    
        
end