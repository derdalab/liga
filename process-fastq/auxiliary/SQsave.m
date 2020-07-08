function SQsave(DIR, NameSeq, cSeq, cQua)  % saves seq & quality data 

    if ~strcmp('.txt',NameSeq(end-4:end))
        NameSeq = [    NameSeq '.txt'];
        NameQua = ['Q' NameSeq(2:end)];
    else
        NameQua = ['Q' NameSeq(2:end)];
    end
    
    if isempty(cSeq)
        return
    end

    fh = fopen(fullfile(DIR, NameSeq), 'a+');
    
    RET  = char( [ 13*ones(size(cSeq,1),1) 10*ones(size(cSeq,1),1)] );
    %RET(end,:) = char([32 32]);
    
    fprintf(fh, '%s\r\n', [cSeq RE ]');
    fclose(fh);

    fhQ = fopen(fullfile(DIR, NameQua), 'a+');
    fprintf(fhQ, '%s\r\n', [cQua RE ]');
    fclose(fhQ);
     
end