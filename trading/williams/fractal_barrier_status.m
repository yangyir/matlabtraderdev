function [hhstatus,llstatus] = fractal_barrier_status(extrainfo,ticksize)
% utility function to check status of fractal barriers, i.e.HH or LL
% the status shall be upward or downward or flat of the HH and LL
% respectively
    %
    last2hhidx = find(extrainfo.idxhh == 1,2,'last');
    if isempty(last2hhidx)
        hhstatus = 'unknown';
    else
        if size(last2hhidx,1) == 1
            hhstatus = 'flat';
        elseif size(last2hhidx,1) == 2
            last2hh = extrainfo.hh(last2hhidx);
            if abs(last2hh(end) - last2hh(1)) <= 2*ticksize
                if abs(last2hh(end) - last2hh(1)) <= 1e-6
                    hhstatus = 'flat';
                else 
                    last3hhidx = find(extrainfo.idxhh == 1,3,'last');
                    try
                        if min(last2hh) - extrainfo.hh(last3hhidx(1)) >= 2*ticksize
                            hhstatus = 'upward';
                        else
                            hhstatus = 'dnward';
                        end
                    catch
                        hhstatus = 'flat';
                    end
                end
            else
                if last2hh(end) - last2hh(1) > 2*ticksize
                    hhstatus = 'upward';
                else
                    hhstatus = 'dnward';
                end
            end
        end
    end
    %
    %
    last2llidx = find(extrainfo.idxll == -1,2,'last');
    if isempty(last2llidx)
        llstatus = 'unknown';
    else
        if size(last2llidx,1) == 1
            llstatus = 'flat';
        elseif size(last2llidx,1) == 2
            last2ll = extrainfo.ll(last2llidx);
            if abs(last2ll(end) - last2ll(1)) <= 2*ticksize
                if abs(last2ll(end) - last2ll(1)) <= 1e-6
                    llstatus = 'flat';
                else
                    last3llidx = find(extrainfo.idxll == -1,3,'last');
                    try
                        if max(last2ll) - extrainfo.ll(last3llidx(1)) <= -2*ticksize
                            llstatus = 'dnward';
                        else
                            llstatus = 'upward';
                        end
                    catch
                        llstatus = 'flat';
                    end
                end
            else
                if last2ll(end) - last2ll(1) < -2*ticksize
                    llstatus = 'dnward';
                else
                    llstatus = 'upward';
                end
            end
        end
    end
            

end

