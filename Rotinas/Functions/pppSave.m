function pppSave(perc, power, peak, save, fileID)
    if save
        fprintf(fileID, perc);
%         fprintf(fileID, power);
%         fprintf(fileID, peak);
    end
end