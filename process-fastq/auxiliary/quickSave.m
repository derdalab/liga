function quickSave(savename, savedir, strings, numbers, tags, WRITE)
% strings have to be supplied as {Nuc, AA, otherstuff}, where
% each entry, Nuc, AA, can be either a cell array of strings of a char
% 'numbers' is a column or matrix of copy numbers
% 'tags' is/are a line(s) of tags to be added at the beginning of the file
% WRITE is a flag that specifies whether writing is done by addig to
% existing file or by writing into a new file from scratch (overWRITE)
% Options are: WRITE == 'new' or WRITE == 'add'
if isempty(strings{1}), return; end

if ~tags
    
    ONE = ones(size(strings{1},1),1);
    SP  = char(32*ONE);    % The ASCII value of space is 32_Bifang 
    toSave = [];

    for i=1:numel(strings)
        
        if ischar(strings{i})
            cSTR = strings{i};
        else
            cSTR = char( strings{i} );    
        end
        
        if i==1
            toSave = cSTR;
        else
            toSave = [toSave SP cSTR ];
        end
    end
   
    if numbers & size(numbers,2)==1

        % faster alternative to num2str(Fr)
        temp = textscan( sprintf('%d\n', numbers ), '%s' );
        cFr = char(temp{1});
        
        toSave = [toSave SP cFr ];

    end
end 
    if ~strcmp(savename(end-3:end),'.txt')
        savename = [savename '.txt'];
    end
    
    if strcmp(WRITE,'new')
        fh = fopen(fullfile(savedir, savename), 'w+');
    elseif strcmp(WRITE,'add')
        fh = fopen(fullfile(savedir, savename), 'a+');
    end
    
    ONE = ones(size(toSave,1),1);
    % to make files readable on Windows, I use \r\n  instead of just \n
    RET  = char( [ (13*ONE) (10*ONE)] );
    % remove the last two \r\n characters to avoid extra lines in txt file
    RET(end,:) = char([32 32]);
    
    
    fprintf(fh, '%s', [toSave RET]');
    fprintf(fh,'\n');
    fclose(fh);
    
end