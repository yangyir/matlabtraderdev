function [] = bkf_printtrades_tdsq( tradesin,varargin )
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('price',[],@isnumeric);
    p.addParameter('printscenario',false,@islogical);
    p.parse(varargin{:});
    px = p.Results.price;
    printscenario = p.Results.printscenario;
    totalpnl = 0;
    for i = 1:tradesin.latest_
        if ~isempty(tradesin.node_(i).closepnl_)
            pnl_i = tradesin.node_(i).closepnl_;
        else
            pnl_i = tradesin.node_(i).runningpnl_;
            if isempty(pnl_i), pnl_i = 0;end
        end
    
        if i == 1
            if isempty(px)
                if ~printscenario
                    fprintf('%s\t%s\t%s\t%s\t%s\n','code','id','b/s','opentime','pnl');
                else
                    fprintf('%s\t%s\t%s\t%s\t%s\t%s\n','code','id','b/s','opentime','pnl','scenario');
                end
            else
                if ~printscenario
                    fprintf('%s\t%s\t%s\t%s\t%s\t%s\n','code','id','b/s','openidx','closeidx','pnl');
                else
                    fprintf('%s\t%s\t%s\t%s\t%s\t%s\t%s\n','code','id','b/s','openidx','closeidx','pnl','scenario');
                end
            end
        end
        
        if isempty(px)
            if ~printscenario
                fprintf('%s\t%d\t%d\t%s\t%s\n',tradesin.node_(i).code_,...
                    tradesin.node_(i).id_,...
                    tradesin.node_(i).opendirection_*tradesin.node_(i).openvolume_,...
                    datestr(tradesin.node_(i).opendatetime2_,'yy-mm-dd HH:MM'),...
                    num2str(pnl_i));
            else
                fprintf('%s\%d\t%d\t%s\t%s\t%s\n',tradesin.node_(i).code_,...
                    tradesin.node_(i).id_,...
                    tradesin.node_(i).opendirection_*tradesin.node_(i).openvolume_,...
                    datestr(tradesin.node_(i).opendatetime2_,'yy-mm-dd HH:MM'),...
                    num2str(pnl_i),...
                    tradesin.node_(i).opensignal_.scenario_);
            end
        else
            openidx = find(px(:,1) <= tradesin.node_(i).opendatetime1_,1,'last');
            try
                closeidx = find(px(:,1) <= tradesin.node_(i).closedatetime1_,1,'last');
            catch
                closeidx = size(px,1);
            end
            if ~printscenario
                fprintf('%s\t%d\t%d\t%s\t%s\t%s\n',tradesin.node_(i).code_,...
                    tradesin.node_(i).id_,...
                    tradesin.node_(i).opendirection_*tradesin.node_(i).openvolume_,...
                    num2str(openidx),...
                    num2str(closeidx),...
                    num2str(pnl_i));
            else
                fprintf('%s\t%d\t%d\t%s\t%s\t%s\t%s\n',tradesin.node_(i).code_,...
                    tradesin.node_(i).id_,...
                    tradesin.node_(i).opendirection_*tradesin.node_(i).openvolume_,...
                    num2str(openidx),...
                    num2str(closeidx),...
                    num2str(pnl_i),...
                    tradesin.node_(i).opensignal_.scenario_);
            end
        end
        totalpnl = totalpnl + pnl_i;
    end
    
    fprintf('totalpnl:%s\n',num2str(totalpnl));

end

