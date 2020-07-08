function [Nuc, Fr] = quickRead(savename, savedir)

    if ~strcmp(savename(end-3:end),'.txt')
        savename = [savename '.txt'];
    end
    
    fh = fopen(fullfile(savedir, savename), 'r+');
    A = textscan(fh,'%s %*s %f %*[^\n]');
    Nuc = A{1};
    Fr  = A{2};
    
end