function obj = init(obj,varargin)
%cAShareWindIndustires
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Name','asharewindindustries',@ischar);
    p.addParameter('InitiateWind',true,@islogical);
    p.parse(varargin{:});
    obj.name_ = p.Results.Name;
    %
    %other default values
    initiatewind = p.Results.InitiateWind;
    if initiatewind
        obj.conn_ = cWind;
    else
        fprintf('cETFWatcher:init:wind not initiated!!!\n');
    end
    obj.settimerinterval(1);
    %
    
    obj.codes_index_ = {'886001.WI';'886002.WI';'886003.WI';'886004.WI';'886005.WI';'886006.WI';'886007.WI';'886008.WI';'886009.WI';'886010.WI';...
    '886011.WI';'886012.WI';'886013.WI';'886014.WI';'886015.WI';'886016.WI';'886017.WI';'886018.WI';'886019.WI';'886020.WI';...
    '886021.WI';'886022.WI';'886023.WI';'886024.WI';'886025.WI';'886026.WI';'886027.WI';'886028.WI';'886029.WI';'886030.WI';...
    '886031.WI';'886032.WI';'886033.WI';'886034.WI';'886035.WI';'886036.WI';'886037.WI';'886038.WI';'886039.WI';'886040.WI';...
    '886041.WI';'886042.WI';'886043.WI';'886044.WI';'886045.WI';'886046.WI';'886048.WI';'886049.WI';'886050.WI';...
    '886051.WI';'886052.WI';'886053.WI';'886054.WI';'886055.WI';'886057.WI';'886058.WI';'886059.WI';'886060.WI';...
    '886061.WI';'886062.WI';'886063.WI';'886064.WI';'886065.WI';'886066.WI';'886067.WI';'886068.WI';'886069.WI'};
    %
    n_index = length(obj.codes_index_);
    names_index = cell(n_index,1);
    pos_index = cell(n_index,1);
    
    for i = 1:n_index
        instrument = code2instrument(obj.codes_index_{i});
        names_index{i} = instrument.asset_name;
        pos_index{i} = {};
    end
    %
    obj.names_index_ = names_index;
    %
    obj.pos_index_ = pos_index;
    %
    obj.dailystatus_index_ = nan(n_index,1);
    %
    obj.reload;
    %
    %generate daily-frequency trades
    nfractal = 2;
    for i = 1:n_index
        stock = code2instrument(obj.codes_index_{i});
        d = obj.dailybarstruct_index_{i};
        [idxb1,idxs1] = fractal_genindicators1(d.px,...
            d.hh,d.ll,...
            d.jaw,d.teeth,d.lips,...
            'instrument',stock);
        lastb = idxb1(end,1);
        lasts = idxs1(end,1);
        if lastb > lasts                                                   %last bullish
            b1type = idxb1(end,2);
            if b1type == 1                                                  %weak breach
                if ~(obj.dailystatus_index_(i) == 2  || obj.dailystatus_index_(i) == -2)
                    obj.dailystatus_index_(i) = 0;
                end
                continue;
            end
            j = idxb1(end,1);
            ei = fractal_truncate(d,j);
            [~,op] = fractal_signal_unconditional(ei,stock.tick_size,nfractal);
            if op.use
%                 trade = fractal_gentrade(d,obj.codes_index_{i},j,op.comment,1,'daily');
%                 trade.riskmanager_.setusefractalupdateflag(0);
%                 trade.riskmanager_.setusefibonacciflag(0);
            else
                if ~isempty(op) && op.direction == 1 && j == size(d.px,1)
                    fprintf('%s:bullish invalid:%s\n',obj.codes_index_{i},op.comment);
                end
                if ~isempty(op) && op.direction == -1 && j == size(d.px,1)
                    fprintf('%s:bearish invalid:%s\n',obj.codes_index_{i},op.comment);
                end
                %not a valid signal
                if ~(obj.dailystatus_index_(i) == 2  || obj.dailystatus_index_(i) == -2)
                    obj.dailystatus_index_(i) = 0;
                end
                continue;
            end
            %
            firstbuysincelastsell = idxb1(find(idxb1(:,1)>lasts,1,'first'),1);
            [~,~,~,~,~,~,~,validtradesb,~] = fractal_gettradesummary(obj.codes_index_{i},...
                'frequency','daily',...
                'direction','long',...
                'fromdate',d.px(firstbuysincelastsell,1),...
                'usefractalupdate',0,...
                'usefibonacci',0);
            for j = 1:validtradesb.latest_
                trade = validtradesb.node_(j);
                if strcmpi(trade.status_,'set')
                    if trade.id_ == size(d.px,1)
                        fprintf('%s:bullish live-newly open.\n',trade.code_);
                    else
                        fprintf('%s:bullish live.\n',trade.code_);
                    end
                    obj.pos_index_{i} = trade;
                    obj.dailystatus_index_(i) = 1;                          %bullish
                    break
                elseif strcmpi(trade.status_,'closed') && trade.closedatetime1_ >= d.px(end,1)
                    fprintf('%s:bullish closed:%s\n',trade.code_,trade.riskmanager_.closestr_);
                    if ~(obj.dailystatus_index_(i) == 2  || obj.dailystatus_index_(i) == -2)
                        obj.dailystatus_index_(i) = 0;                      %neutral
                    end
                    break
                end
            end
            %
        elseif lastb < lasts                                                %last bearish
            s1type = idxs1(end,2);
            if s1type == 1                                                  %weak breach
                if ~(obj.dailystatus_index_(i) == 2  || obj.dailystatus_index_(i) == -2)
                    obj.dailystatus_index_(i) = 0;
                end
                continue;
            end
            j = idxs1(end,1);
            ei = fractal_truncate(d,j);
            [~,op] = fractal_signal_unconditional(ei,stock.tick_size,nfractal);
            if op.use
%                 trade = fractal_gentrade(d,obj.codes_index_{i},j,op.comment,-1,'daily');
            else
                if ~isempty(op) && op.direction == 1 && j == size(d.px,1)
                    fprintf('%s:bullish invalid:%s\n',obj.codes_index_{i},op.comment);
                end
                if ~isempty(op) && op.direction == -1 && j == size(d.px,1)
                    fprintf('%s:bearish invalid:%s\n',obj.codes_index_{i},op.comment);
                end
                %not a valid signal
                if ~(obj.dailystatus_index_(i) == 2  || obj.dailystatus_index_(i) == -2)
                    obj.dailystatus_index_(i) = 0;
                end
                continue;
            end
            %
            firstsellsincelastbuy = idxs1(find(idxs1(:,1)>lastb,1,'first'),1);
            [~,~,~,~,~,~,~,~,validtradess] = fractal_gettradesummary(obj.codes_index_{i},...
                'frequency','daily',...
                'direction','short',...
                'fromdate',d.px(firstsellsincelastbuy,1),...
                'usefractalupdate',0,...
                'usefibonacci',0);
            for j = 1:validtradess.latest_
                trade = validtradess.node_(j);
                if strcmpi(trade.status_,'set')
                    if trade.id_ == size(d.px,1)
                        fprintf('%s:bearish live-newly open.\n',trade.code_);
                    else
                        fprintf('%s:bearish live.\n',trade.code_);
                    end
                    obj.pos_index_{i} = trade;
                    obj.dailystatus_index_(i) = -1;                         %bearish
                    break
                elseif strcmpi(trade.status_,'closed') && trade.closedatetime1_ >= d.px(end,1)
                    fprintf('%s:bearish closed:%s\n',trade.code_,trade.riskmanager_.closestr_);
                    if ~(obj.dailystatus_index_(i) == 2  || obj.dailystatus_index_(i) == -2)
                        obj.dailystatus_index_(i) = 0;                      %neutral
                    end
                    break
                end
            end
        end
    end
    
    fprintf('\n');
    
   
    
end 