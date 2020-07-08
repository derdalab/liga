function [TOT, lines] = findPAR(FID,chunk)

    BlockL=0;
    fseek(FID,0,'eof');
    LAST = ftell(FID);  % position of the last element of the file
    
    % find the middle position, go there
    MIDDLE = round(LAST/2);
    fseek(FID,MIDDLE,0);
    
    % read some random line and throw it away, cus it's probably truncated
    fgets(FID);
    frewind(FID);
    
    % FASTQ format has 4 lines, repeated N times. What I call a BLOCK is a
    % block of 4 lines. To find an average length of the block of 4 lines,
    % we read 4000 lines, calculate the length and divide it by 1000. In
    % other words, its an average length of the first 1000 blocks.
    
    % read 4000 lines (1000 blocks) to estimate the length of the block
    N=1000;
    
    currL2 = cell(4*N,1); % preallocate memory like a good programmer you are
    for i=1:4*N 
       currL2{i,1} = fgets(FID);
       BlockL = BlockL + numel(currL2{i,1}) ;
    end
    
    TOT = floor(LAST/(chunk*BlockL/N));
    lines = floor(LAST/(BlockL/N));
    if TOT ==0
        TOT = 1;
    end

end

