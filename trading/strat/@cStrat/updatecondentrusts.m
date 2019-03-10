function [] = updatecondentrusts(strategy)
%cStrat
    if isempty(strategy.helper_), return; end

    try
        ncondpending = strategy.helper_.condentrustspending_.latest;
        condentrusts2remove = EntrustArray;
        if ncondpending > 0
            for i = 1:ncondpending
                condentrust = strategy.helper_.condentrustspending_.node(i);
                signalinfo = condentrust.signalinfo_;
                codestr = condentrust.instrumentCode;
                condpx = condentrust.price;
                volume = condentrust.volume;
                lasttick = strategy.mde_fut_.getlasttick(codestr);
                
                if isempty(lasttick), continue; end
                
                direction = condentrust.direction;
                
                if ~isempty(signalinfo)
                    try
                        isflash = strcmpi(signalinfo.wrmode,'flash');
                    catch
                        isflash = false;
                    end    
                else
                    isflash = false;
                end
                
                if isflash
                    %need to make sure either the max or min prices are
                    %updated or not. if it is updated, then the existing
                    %conditional entrust shall be removed
                    if direction == 1 && lasttick(4) < signalinfo.lowestlow
                        condentrusts2remove.push(condentrust);
                        continue;
                    end
                    %
                    if direction == -1 && lasttick(4) > signalinfo.highesthigh
                        condentrusts2remove.push(condentrust);
                        continue;
                    end
                end
                %
                if ~isempty(signalinfo)
                    try
                        isflashma = strcmpi(signalinfo.wrmode,'flashma') && abs(condpx+9.99)<=1e-5;
                    catch
                        isflashma = false;
                    end    
                else
                    isflashma = false;
                end
                
                if isflashma
                    %we need to check the short ma of wr breaches
                    %above(below) the long ma of wr
%                     lead = strategy.riskcontrols_.getconfigvalue('code',codestr,'propname','wrmalead');
%                     lag = strategy.riskcontrols_.getconfigvalue('code',codestr,'propname','wrmalag');
%                     if abs(lead+9.99) < 1e-5 || abs(lag+9.99) < 1e-5
%                         return
%                     end
%                     ti = strategy.mde_fut_.calc_technical_indicators(codestr,'includeextraresults',true);
%                     try
%                         wrseries = ti{2};
%                     catch
%                         fprintf('%s:updatecondentrusts:time series of Williams%R not returned on %s\n',class(strategy),instrument.code_ctp);
%                     end
%                     [short,long] = movavg(wrseries,lead,lag,'e');
                    [~,idx] = strategy.hasinstrument(codestr);
                    short = strategy.wrmashort_(idx);
                    long = strategy.wrmalong_(idx);
                    if direction == 1 && short > long
                        condpx = lasttick(3);
                        condentrust.price = condpx;
                    elseif direction == -1 && short < long
                        condpx = lasttick(2);
                        condentrust.price = condpx;
                    end
                end
                %
                if direction == 1 && lasttick(3) >= condpx && abs(condpx+9.99) > 1e-5
                    condentrusts2remove.push(condentrust);
                    if isempty(condentrust.signalinfo_)
                        strategy.longopen(codestr,volume,'overrideprice',lasttick(3));
                    else
                        strategy.longopen(codestr,volume,'overrideprice',lasttick(3),...
                            'signalinfo',condentrust.signalinfo_);
                    end
                elseif direction == -1 && lasttick(2) <= condpx && abs(condpx+9.99) > 1e-5
                    condentrusts2remove.push(condentrust);
                    if isempty(condentrust.signalinfo_)
                        strategy.shortopen(codestr,volume,'overrideprice',lasttick(2));
                    else
                        strategy.shortopen(codestr,volume,'overrideprice',lasttick(2),...
                            'signalinfo',condentrust.signalinfo_);
                    end
                end
            end
        end
        %
        strategy.removecondentrusts(condentrusts2remove);
        %
    catch e
        msg = ['error:',class(strategy),':updatecondentrusts:',e.message,'\n'];
        fprintf(msg);
        if strcmpi(strategy.onerror_,'stop')
            strategy.stop;
        end
    end
    
end
%end of updatecondentrusts