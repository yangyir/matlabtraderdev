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
                    if isa(signalinfo,'cWilliamsRInfo')
                        isflash = strcmpi(signalinfo.wrmode_,'flash');
                    else
                        isflash = false;
                    end    
                else
                    isflash = false;
                end
                
                if isflash
                    %need to make sure either the max or min prices are
                    %updated or not. if it is updated, then the existing
                    %conditional entrust shall be removed
                    if direction == 1 && lasttick(4) < signalinfo.lowestlow_
                        condentrusts2remove.push(condentrust);
                        continue;
                    end
                    %
                    if direction == -1 && lasttick(4) > signalinfo.highesthigh_
                        condentrusts2remove.push(condentrust);
                        continue;
                    end
                end
                %
                if direction == 1 && lasttick(3) >= condpx
                    condentrusts2remove.push(condentrust);
                    if isempty(condentrust.signalinfo_)
                        strategy.longopen(codestr,volume,'overrideprice',lasttick(3));
                    else
                        strategy.longopen(codestr,volume,'overrideprice',lasttick(3),...
                            'signalinfo',condentrust.signalinfo_);
                    end
                elseif direction == -1 && lasttick(2) <= condpx
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
        n2remove = condentrusts2remove.latest;
        for k = 1:n2remove
            e2remove = condentrusts2remove.node(k);
            ncondpending = strategy.helper_.condentrustspending_.latest;
            for kk = ncondpending:-1:1
                econd = strategy.helper_.condentrustspending_.node(kk);
                if strcmpi(e2remove.instrumentCode,econd.instrumentCode) && ...
                        e2remove.direction ==  econd.direction && ...
                        e2remove.volume == econd.volume && ...
                        e2remove.price == econd.price
                    rmidx = kk;
                    strategy.helper_.condentrustspending_.removeByIndex(rmidx);
                    break
                end
            end
        end
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