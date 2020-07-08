% this function read in the unique file and then produce the summary of the
% unique file, including:
%   1. total number of frequencies for
%       a. tFreq, target sequence library
%       b. nFreq, non-insert ones
%       c. cFreq, contaimenations

function summaryTable =checkUniqueFile(filename)
    
    nFreq = 0;
   
    patterns = {'QFTQLHQ','SWYDLYH' ,'YPYDVPDYA' ,'DYKDDDDK' ,'SVEKNDQKTYHA', '^S[A-Z]C[A-Z]{3}C$','^S[A-Z]C[A-Z]{4}C$','^S[A-Z]C[A-Z]{5}C$',...
         '^S[A-Z]C[A-Z]{6}C$',  '^S[A-Z]C[A-Z]{7}C$', '^AC[A-Z]{7}C$', '^S[A-Z]{7}$',...
         '^[A-Z]{12}$', '^[A-Z]{7}$'}; %Nick: Switched order of PhD7 and PhD12 pattern to prevent PhD7 miss as PhD12 and added control phage
    
    
    % read the file
    FORM = '%s %s %f %*[^\n]';
    fid = fopen(filename);
    tbl = textscan(fid, FORM);
    fclose(fid);
    
    DNASeq = tbl{1};
    AASeq = tbl{2};
    Freq = tbl{3};
    
    TotalReads = sum(Freq);
    
    % determine if the library has sdb
    issdb = regexp(DNASeq,'^AAAAAA');
    issdb = cell2mat(issdb);
    issdb = sum(issdb)>(length(DNASeq)/2);
    % if sdb trim first 17
    if(issdb)
        seqStart = 18;
    else
        seqStart = 1;
    end
    
    % calculate the blank (non-insert) ones
    blank = zeros(1,length(DNASeq));
    if seqStart == 18
        for i=1:length(DNASeq)
            blank(i) = length(AASeq{i})<seqStart;
        end
    end
    
    blank = logical(blank);
    nFreq = sum(Freq(blank));

    DNASeq = DNASeq(~blank);
    AASeq = AASeq(~blank);
    Freq = Freq(~blank);
    
    % remove G's in the end
    tmp = regexp(AASeq, 'G{1,3}$');
    nonG = zeros(1, length(tmp));
    for i = 1:length(tmp)
        nonG(i) = isempty(tmp{i});
    end
    
    % sequences not has GGG in the end
    nonG = logical(nonG);
    nonGFreq = Freq(nonG);
    
    AASeq = AASeq(~nonG);
    Freq = Freq(~nonG);
    tmp = cell2mat(tmp);
    tmp = tmp-1;
   
    for i = 1:length(Freq)
        tmpSeq = AASeq{i};
        AASeq{i} = tmpSeq(seqStart:tmp(i));
    end
    
    % count frequencies for each patterns
    counts = zeros(1,length(patterns));
    for i = 1:length(counts)
        tmp = regexp(AASeq, patterns{i});
        match = zeros(1,length(tmp));
        for j = 1:length(tmp)
            match(j) = ~isempty(tmp{j});
        end
        match = logical(match);
        counts(i) = sum(Freq(match));
        AASeq = AASeq(~match);
        Freq = Freq(~match);
    end
    
    % calculate frequencies of sequencies that cannot defined
    cFreq = sum(Freq) + sum(nonGFreq);
    
     tags = {'total', 'noInsert', 'undefined', 'blank48','conA','ha','flag','svek', 'sxc3c',...
'sxc4c','sxc5c','sxc6c','sxc7c','phdc7c','sx7','phd12','phd7'};
    counts = [TotalReads, nFreq, cFreq, counts];
    
    summaryTable = array2table(counts);
    summaryTable.Properties.VariableNames = tags;
    summaryTable.Properties.RowNames = {filename};
end
