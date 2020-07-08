function [Seq, Qua, ID, START] = loadNparse(FID,chunk,START,CH)
    
    %CH = ; trtr
    % start from reading 10000 characters from the current position in the
    % FASTQ file
    
    
    N=10000;
    fseek(FID,START,'bof');
    temp = (fread(FID, N, '*char'))';
    
    COORD = find(temp==CH, 1 );  % coordinate of the reference character
    
    split = regexp (temp, CH, 'split');
    
    % crude estimate of the read length to read exactly "chunk" lines
    readL=floor(N*chunk/(numel(split)-1));  
    
    % rewind to the start, read the readL and count the number of "@"
    fseek(FID,START,'bof');
    temp2 = (fread(FID, readL, '*char'))';
    
    IX = find(temp2==CH);
    N2 = numel(IX);
    
    if N2<chunk+1
        
        % by how much the reading missed the exact chunk
        miss=chunk-N2+1;
        % find the readL, which is 2x the missed chunk, read it and count @
        readL2=N*miss*2/(numel(split)-1);   
        temp3 = (fread(FID, readL2, '*char'))';   
        IX = find(temp3==CH);
        if miss > size(IX,2)
            miss= size(IX,2);
        end

        % IX(miss) is index of the @ at the line # equall to "chunk+1"
        % create a final string that contains the necessary number of "@"
        if ~isempty(IX)
           
            
             try 
                final = [temp2 temp3( 1:IX(miss)-COORD )];
            catch 
                fprintf('hello');
             end
        else
            final = temp2;
        end
        
    elseif N2>chunk+1
        
        % IX(chunk+1) is index of the @ at the line # equall to "chunk+1"
        % create a final string that contains the necessary number of "@"
        final = temp2( 1:IX(chunk+1)-COORD );
         
    end
    
    %clear temp*; 
    
    Splitline = regexp (final, '\n', 'split');
    
    START=START+numel(final);
    
    Seq = char(Splitline(2:4:end));
    Qua = char(Splitline(4:4:end));
    ID  = char(Splitline(1:4:end));
        fclose(FID);
end