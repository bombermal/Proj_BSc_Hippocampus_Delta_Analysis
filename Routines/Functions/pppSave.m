function pppSave(perc, save, fileID)
    if save
        fprintf(fileID, perc);
    end
end