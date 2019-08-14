function tag = tdsq_snbd(sn)
% scenario name break down
    if strcmpi(sn,'blank')
        tag = '';
        return
    end

    snbd = regexp(sn,'-','split');
    if strcmpi(snbd{1},'bslast') || strcmpi(snbd{1},'bsonly')
        if strcmpi(snbd{3}(1:4),'semi')
            tag = 'semiperfectbs';
        elseif strcmpi(snbd{3}(1:9),'perfectbs')
            tag = 'perfectbs';
        else
            tag = 'imperfectbs';
        end
    elseif strcmpi(snbd{1},'sslast') || strcmpi(snbd{1},'ssonly')
        if strcmpi(snbd{3}(1:4),'semi')
            tag = 'semiperfectss';
        elseif strcmpi(snbd{3}(1:9),'perfectss')
            tag = 'perfectss';
        else
            tag = 'imperfectss';
        end
    end
end