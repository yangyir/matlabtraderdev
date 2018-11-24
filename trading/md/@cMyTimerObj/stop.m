function stop(mytimerobj)
    mytimerobj.status_ = 'sleep';
    try
        stop(mytimerobj.timer_);
        %delete the timer object from memory
%         delete(mytimerobj.timer_);

        if ~isempty(mytimerobj.gui_)
            classname = class(mytimerobj);
            if strcmpi(classname,'cMDEFut')
                try
                    set(mytimerobj.gui_.tradingstats.mdestatus_edit,'string',mytimerobj.status_);
                    set(mytimerobj.gui_.tradingstats.mderunning_edit,'string',mytimerobj.timer_.running);
                catch
                end
            elseif strcmpi(classname,'cOps')
                try
                    set(mytimerobj.gui_.tradingstats.opsstatus_edit,'string',mytimerobj.status_);
                    set(mytimerobj.gui_.tradingstats.opsrunning_edit,'string',mytimerobj.timer_.running);
                catch
                end
            else
                try
                    set(mytimerobj.gui_.tradingstats.strategystatus_edit,'string',mytimerobj.status_);
                    set(mytimerobj.gui_.tradingstats.strategyrunning_edit,'string',mytimerobj.timer_.running);
                catch
                end
            end
        end
    catch e
        fprintf('%s\n',e.message);
    end
end
%end of stop