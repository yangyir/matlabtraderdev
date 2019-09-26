function [tag,count] = tdsq_snbd(sn)
% scenario name break down
    if strcmpi(sn,'blank')
        tag = '';
        count = 0;
        return
    end

    snbd = regexp(sn,'-','split');
    if strcmpi(snbd{1},'bslast') || strcmpi(snbd{1},'bsonly')
        if strcmpi(snbd{3}(1:4),'semi')
            tag = 'semiperfectbs';
            count = str2double(snbd{3}(14:end));
        elseif strcmpi(snbd{3}(1:9),'perfectbs')
            tag = 'perfectbs';
            count = str2double(snbd{3}(10:end));
        else
            tag = 'imperfectbs';
            count = str2double(snbd{3}(12:end));
        end
    elseif strcmpi(snbd{1},'sslast') || strcmpi(snbd{1},'ssonly')
        if strcmpi(snbd{3}(1:4),'semi')
            tag = 'semiperfectss';
            count = str2double(snbd{3}(14:end));
        elseif strcmpi(snbd{3}(1:9),'perfectss')
            tag = 'perfectss';
            count = str2double(snbd{3}(10:end));
        else
            tag = 'imperfectss';
            count = str2double(snbd{3}(12:end));
        end
    end
end