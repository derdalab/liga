function tags2table(varargin)


    if exist('varargin','var')
        L = length(varargin);
        if rem(L,2) ~= 0, 
            error('Parameters/Values must come in pairs.'); 
        end

        % read input variables
        for ni = 1:2:L
            switch lower(varargin{ni})
                case 'outdir',          savepath = varargin{ni+1};
                case 'indir',           indir=varargin{ni+1};
                case 'barcodes',        B=varargin{ni+1}; 
                case 'library',         LIB=varargin{ni+1}; 
                case 'adaptermatch',    kind=varargin{ni+1}; 
                case 'files',           files=varargin{ni+1}; 
            end
        end
    end

    if ~isdir(savepath)
        mkdir(savepath)
    end

    names = dir(fullfile(indir,files));
    AllFiles = [];

    for i = 1:numel(names)

        AllFiles = [AllFiles ' ' names(i).name];

    end
    
    expr = ['(?<DATE>\d{8}-)'...
            '(?<NAME>R\d{1,2}F\d{1,2}-.{7,15}-)' ... 
            '(?<JUNK>\d+)'...
            '(?<ID>[A-Z]+)' ...
            '(?<NUM>\d+)' ...
            '(?<EXT>[.txt]*)'];
        
    X = regexp(AllFiles,expr,'names');
   

    uniID = unique(char(X.ID),'rows');

    for jj=1:size(uniID,1)
        files={};
        TAG={};
        

        for i=1:numel(X)
            if strcmp(strtrim(uniID(jj,:)),X(i).ID)
                
                % use the number built into the ID as index for files
                % variable. Rebuild the complete name from tags
                N=str2num(X(i).NUM);
                files{N} = [X(i).DATE X(i).NAME X(i).JUNK X(i).ID X(i).NUM X(i).EXT];
                  TAG{N} = [X(i).ID X(i).NUM];
            end
        end

        savename=[strtrim(uniID(jj,:)) '_unfiltered.txt'];
        sortby= 0;
        tic
        compareNfiles(files,indir,savepath,savename,sortby,TAG);
        toc
    end
end

    
