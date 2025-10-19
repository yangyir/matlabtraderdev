function [] = updatecondentrusts(strategy)
%cStrat
    if isempty(strategy.helper_), return; end
    
    isfractal = isa(strategy,'cStratFutMultiFractal');
    isfractalopt = isa(strategy,'cStratOptMultiFractal');

    try
        ncondpending = strategy.helper_.condentrustspending_.latest;
        condentrusts2remove = EntrustArray;
        if ncondpending > 0
            for i = 1:ncondpending
                condentrust = strategy.helper_.condentrustspending_.node(i);               
                codestr = condentrust.instrumentCode;
                instrument = code2instrument(codestr);
                if strcmpi(strategy.mode_,'realtime') || strcmpi(strategy.mode_,'demo')
                    ordertime = now;
                else
                    ordertime = strategy.getreplaytime;
                end
                
                if ~instrument.isable2trade(ordertime), continue; end
                
                [flag,idx] = strategy.helper_.book_.hasposition(instrument);
                if ~flag
                    volume_exist = 0;
                    direction_exist = 0;
                else
                    pos = strategy.helper_.book_.positions_{idx};
                    volume_exist = pos.position_total_;
                    direction_exist = pos.direction_;
                end
                volume = condentrust.volume;
                direction = condentrust.direction;
                volume2check = volume*direction + volume_exist*direction_exist;
                if isfractalopt
                    %a dummy position of the underlier for now
                    %and a maximum volume of 1 is allowed
                    maxvolume = 1;
                else
                    try
                        maxvolume = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','maxunits');
                    catch
                        maxvolume = 0;
                    end
                end
                if abs(volume2check) > maxvolume, continue;end
                
                signalinfo = condentrust.signalinfo_;
                condpx = condentrust.price;
                
                if isfractalopt
                    lasttick = strategy.mde_opt_.getlasttick(codestr);
                else
                    lasttick = strategy.mde_fut_.getlasttick(codestr);
                end
                
                if isempty(lasttick), continue; end
                ticktime = lasttick(1);
                if ordertime - ticktime > 1/1440, continue;end
                
                if ~isfractal && ~isfractalopt
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
                end
                %
                %
                if direction == 1
                    if isfractalopt
                        sprd = 0;
                    else
                        sprd = strategy.riskcontrols_.getconfigvalue('code',codestr,'propname','bidopenspread');
                    end
                else
                    if isfractalopt
                       sprd = 0; 
                    else
                        sprd = strategy.riskcontrols_.getconfigvalue('code',codestr,'propname','askopenspread');
                    end
                end
                ticksize = instrument.tick_size;
                if isfractalopt
                    lasttick = strategy.mde_opt_.getlasttick(codestr);
                else
                    lasttick = strategy.mde_fut_.getlasttick(codestr);
                end
                bid = lasttick(3);
                ask = lasttick(4);
                
                if direction == 1 && bid >= condpx && abs(condpx+9.99) > 1e-5
                    [ret,~,errmsg] = strategy.longopen(codestr,volume,'overrideprice',bid+sprd*ticksize,...
                        'signalinfo',condentrust.signalinfo_);
                    if ret
                        condentrusts2remove.push(condentrust);
                        if isfractalopt && ~strategy.helper_.book_.hasposition(strategy.call_)
                            strategy.longopen(strategy.call_,volume,'signalinfo',condentrust.signalinfo_);
                        end
                    else
                        if ~isempty(strfind(errmsg,'max allowance'))
                            condentrusts2remove.push(condentrust);
                        end
                    end
                elseif direction == -1 && ask <= condpx && abs(condpx+9.99) > 1e-5                    
                    [ret,~,errmsg] = strategy.shortopen(codestr,volume,'overrideprice',ask-sprd*ticksize,...
                        'signalinfo',condentrust.signalinfo_);
                    if ret
                        condentrusts2remove.push(condentrust);
                        if isfractalopt && ~strategy.helper_.book_.hasposition(strategy.put_)
                            strategy.longopen(strategy.put_,volume,'signalinfo',condentrust.signalinfo_);
                        end
                    else
                        if ~isempty(strfind(errmsg,'max allowance'))
                            condentrusts2remove.push(condentrust);
                        end
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