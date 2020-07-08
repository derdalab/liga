function [FA, NUC, RA] = matchReads(Matches,FR, FB, RB, LIB, kind)

% create regular expression that will be used to search for reads    
expres = MakeExpression(FB, RB, LIB, kind);

% matching in done in chunks to avoid overloading the memory during the
% regexp search. This chunk is controlled only locally. It might not be 
% necessary in the future, where entire aligned2unique function is written
% as chunky-function that reads and processes input in chunks.
CHUNK=100000;

% fuse all nucleotides into one long string; insert an extra space %%%%%%%%
    cMatches={};
    if size(Matches,1)>CHUNK
        for ii=1 : floor( size(Matches,1)/CHUNK )
            cMatches{ii}=Matches( CHUNK*(ii-1)+1:CHUNK*ii );
        end
        cMatches{ii+1}=Matches( CHUNK*ii+1:end );
    else
        cMatches{1}=Matches;
    end
    
%%%%%%%%%%%%%%%%%%%% loop through sub-Matches to find the library %%%%%%%%%
%%%%%%%%%%%%%%%%%%%% using regexp constructed above %%%%%%%%%%%%%%%%%%%%%%%

    for ii=1:numel(cMatches)

        SP = char(32*ones(size(cMatches{ii},1),1));
        input = sprintf('%s\r\n', [FR(cMatches{ii},:) SP]');

        % search for the regular expression (the slowest step)
        temp = regexp(input,expres,'names');
        
        if ii==1
            out=temp;
        else
            out = [out temp];
        end   
        fprintf('.');
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isempty(out)
        disp(['; zero matched reads, ' num2str(toc,'%10.1f')   ' s'])
        NUC = '';
        FA  = '';
        RA  = '';
        return    % do not save anything if no reads have been matched
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    NUC = char(out.SEQ);
    FA  = char(out.FA);
    RA  = char(out.RA);
    
    fprintf([num2str(size(out,2)) ' mapped ' ...
                                 '(' num2str(toc,'%10.1f')   ' s); ']);
end


function [expres] = MakeExpression(FB, RB, LIB, kind)

% this function take a perfect adapter and creates a random expression that
% corresponds either to mutated or partial adapter.
% The variable "kind" defined is. Options are
% 'perfect'
% 'mutant'
% 'half'


FA = LIB.FA;
RA = LIB.RA;
SEQ = LIB.SEQ;

if strcmp(kind,'half')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%% define regular expression that matches half of the adapter %%%%

    half1 = floor(numel(FA)/2);
    half2 = numel(FA) - half1;

    modFA = ['((' FA(1:half1) '[ATGC]{' num2str(half2) '})|('...
           '[ATGC]{' num2str(half1) '}' FA(half1+1:end) '))'];
       
    half1 = floor(numel(RA)/2);
    half2 = numel(RA) - half1;

    modRA = ['((' RA(1:half1) '[ATGC]{' num2str(half2) '})|('...
           '[ATGC]{' num2str(half1) '}' RA(half1+1:end) '))'];
       
elseif strcmp(kind,'mutant')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%  make the point mutants of barcodes  %%%%%%%%%%%%%%%%%%%%%%%

        modFA = ['(' FA ];
        for i=1:numel(FA)
            modFA = [modFA '|' FA(1:i-1) '[ATCG]' FA(i+1:end)];
        end
        modFA = [ modFA ')' ];


        modRA = ['(' FA ];
        for i=1:numel(RA)
            modRA = [modRA '|' RA(1:i-1) '[ATCG]' RA(i+1:end)];
        end
        modRA = [ modRA ')' ];
elseif strcmp(kind,'perfect')
    
    modFA = FA;
    modRA = RA;
    
else
    error(['Define how you want to match your adapters; the options are'...
           ' half/mutant/perfect']);
end
    % match forward barcode (FB) then modified forward adapter FA and place 
    % the result into token FA1   
    FA1 = [ FB '(?<FA>' modFA ')' ]; 
    
    % match modified reverse adapter RA, place the result into token RA1,
    % then match the reverse barcode
    RA1 = [ '(?<RA>' modRA ')' RB ];

    % match SEQ and place the result from this regexp into token SEQ1 
    SEQ1 = [ '(?<SEQ>' SEQ ')' ];

    expres = [FA1 SEQ1 RA1];
end