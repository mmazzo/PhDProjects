function [MUdata] = PCAiterfunc_200ms(MUdata,fdat)
% PCA Function to use for individual muscles & composite PFs
warning('off','all')
PFidrs = [];
muscles = {};
    if isempty(MUdata.MG)
    else
        muscles = [muscles,{'MG'}];
    end
    if isempty(MUdata.LG)
    else
        muscles = [muscles,{'LG'}];
    end
    if isempty(MUdata.SOL)
    else
        muscles = [muscles,{'SOL'}];
    end
% --------- Individual Muscles -----------------------------------------

for m = 1:length(muscles)
    mus = muscles{m};
    % Smooth and detrend signals
    %   - 400ms hanning window and High pass filter all IDRs
    %   - 0.75 hz high pass filter "to remove offsets and trends" (Negro 2009)
    fs = 2000;
    len = length(MUdata.(mus).binary);
    idrs = [];
    for mu = 1:length(MUdata.(mus).rawlines)
        temp = MUdata.(mus).rawlines{mu};
        start = find(~isnan(temp),1,'first');
        endd = find(~isnan(temp),1,'last');
        if isempty(temp)
        else
            temp = temp(start:endd);
            temp = conv(temp,hann(400),'same');
            nans1 = repelem(NaN,start-1);
            nans2 = repelem(NaN,(len-endd));
            temp2 = highpass(temp, 0.75, fs);
            idrs(mu,:) = horzcat(nans1,temp2,nans2);
        end
    end
    
if exist('idrs','var') == 1
    if isempty(idrs)
    MUdata.(mus).PCA.iter = [];
    else
    PFidrs = vertcat(PFidrs,idrs);
% --------- PCA of smoothed, detrended IDR lines - 1s windows --------- 
    win = 2000;
    num = 30;
    rem = [];
    for w = 1:num
        ws = MUdata.start + (w*win) - win;
            MUdata.w1.starts(w) = ws;
        we = ws + win;
            MUdata.w1.endds(w) = we;
        % skip to next window if any flags in this one = 1
        if sum(MUdata.(mus).flags(ws:we)) == 0
            % Subset idrs
            idrsec = idrs(:,ws:we);
            for mu = 1:size(idrsec,1)
                if sum(isnan(idrsec(mu,:))) > 0
                    rem = horzcat(rem,mu);
                elseif sum((idrsec(mu,:))) == 0
                    rem = horzcat(rem,mu);
                end
            end
            % Remove empty IDRs
            idrdat = idrsec;
            idrdat(rem,:) = [];
            % If < 3 MUs are active
            if size(idrdat,1) < 3
                MUdata.(mus).PCA.iter.w1_200.coeffs{w} = {};
                MUdata.(mus).PCA.iter.w1_200.explained{w} = {};
                MUdata.(mus).PCA.iter.w1_200.latentvar{w} = {};
                MUdata.(mus).PCA.iter.w1_200.mu{w} = {};
            else
            % Run PCA for that window
            [pcadat] = PCAiter(idrdat,100);
                %MUdata.(mus).PCA.iter.w1.coeffs{w} = pcadat.coeff_all;
                MUdata.(mus).PCA.iter.w1_200.explained{w} = pcadat.expl_all;
                MUdata.(mus).PCA.iter.w1_200.latentvar{w} = pcadat.latentvar_all;
                MUdata.(mus).PCA.iter.w1_200.mu{w} = pcadat.muu_all;
                MUdata.(mus).PCA.iter.w1_200.coeffs_mean{w} = pcadat.coeff_mean;
                MUdata.(mus).PCA.iter.w1_200.explained_means{w} = pcadat.expl_mean;
                MUdata.(mus).PCA.iter.w1_200.latentvar_means{w} = pcadat.latentvar_mean;
                MUdata.(mus).PCA.iter.w1_200.mu_mean{w} = pcadat.muu_mean;
            end
        else
            MUdata.(mus).PCA.iter.w1_200.coeffs{w} = {};
            MUdata.(mus).PCA.iter.w1_200.explained{w} = {};
            MUdata.(mus).PCA.iter.w1_200.latentvar{w} = {};
            MUdata.(mus).PCA.iter.w1_200.mu{w} = {};
        end
        rem = [];
        idrdat = [];
    end

% --------- PCA of smoothed, detrended IDR lines - 5s windows ---------
    win = 10000;
    num = 6;
    rem = [];
    for w = 1:num
        ws = MUdata.start + (w*win) - win;
            MUdata.w5.starts(w) = ws;
        we = ws + win;
            MUdata.w5.endds(w) = we;
        % skip to next window if any flags in this one = 1
        if sum(MUdata.(mus).flags(ws:we)) == 0
            % Subset idrs
            idrsec = idrs(:,ws:we);
            for mu = 1:size(idrsec,1)
                if sum(isnan(idrsec(mu,:))) > 0
                    rem = horzcat(rem,mu);
                elseif sum((idrsec(mu,:))) == 0
                    rem = horzcat(rem,mu);
                end
            end
            % Remove empty IDRs
            idrdat = idrsec;
            idrdat(rem,:) = [];
            % If < 3 MUs are active
            if size(idrdat,1) < 3
                MUdata.(mus).PCA.iter.w5_200.coeffs{w} = {};
                MUdata.(mus).PCA.iter.w5_200.explained{w} = {};
                MUdata.(mus).PCA.iter.w5_200.latentvar{w} = {};
                MUdata.(mus).PCA.iter.w5_200.mu{w} = {};
            else
            % Run PCA for that window
            [pcadat] = PCAiter(idrdat,100);
               % MUdata.(mus).PCA.iter.w5_200.coeffs{w} = pcadat.coeff_all;
                MUdata.(mus).PCA.iter.w5_200.explained{w} = pcadat.expl_all;
                MUdata.(mus).PCA.iter.w5_200.latentvar{w} = pcadat.latentvar_all;
                MUdata.(mus).PCA.iter.w5_200.mu{w} = pcadat.muu_all;
                MUdata.(mus).PCA.iter.w5_200.coeffs_mean{w} = pcadat.coeff_mean;
                MUdata.(mus).PCA.iter.w5_200.explained_means{w} = pcadat.expl_mean;
                MUdata.(mus).PCA.iter.w5_200.latentvar_means{w} = pcadat.latentvar_mean;
                MUdata.(mus).PCA.iter.w5_200.mu_mean{w} = pcadat.muu_mean;
            end
        else
            MUdata.(mus).PCA.iter.w5_200.coeffs{w} = {};
            MUdata.(mus).PCA.iter.w5_200.explained{w} = {};
            MUdata.(mus).PCA.iter.w5_200.latentvar{w} = {};
            MUdata.(mus).PCA.iter.w5_200.mu{w} = {};
        end
        rem = [];
    end
    
% ------------- Averages for muscle per window length ------------------    
    % 1-s window length
    if ~isfield(MUdata.(mus).PCA.iter.w1_200,'explained_means')
    elseif isempty(MUdata.(mus).PCA.iter.w1_200.explained_means)
    else
        for w = 1:length(MUdata.(mus).PCA.iter.w1_200.explained_means)
            if isempty(MUdata.(mus).PCA.iter.w1_200.coeffs_mean{w})
            else
            mean_coeff{w} = mean(MUdata.(mus).PCA.iter.w1_200.coeffs_mean{w}(2:end,:),1);
            end
        end
        mat = zeros(30,length(MUdata.(mus).PCA.iter.w1_200.explained_means));
        for i = 1:length(MUdata.(mus).PCA.iter.w1_200.explained_means)
            num = length(MUdata.(mus).PCA.iter.w1_200.explained_means{i});
            mat(i,1:num) = MUdata.(mus).PCA.iter.w1_200.explained_means{i}(1:num);
        end
        mat(mat == 0) = NaN;
        mean_expl = nanmean(mat);
    end
    
    if exist('mean_expl','var') == 0
        MUdata.(mus).PCA.iter.w1_200.explained_mean = NaN;
        MUdata.(mus).PCA.iter.w1_200.coeff_mean = NaN;
    else
        MUdata.(mus).PCA.iter.w1_200.explained_mean = mean_expl;
        MUdata.(mus).PCA.iter.w1_200.coeff_mean = mean_coeff;
    end
    clear('mean_expl','mean_coeff');
    
    % 5-s window length
    if ~isfield(MUdata.(mus).PCA.iter.w5_200,'explained_means')
    elseif isempty(MUdata.(mus).PCA.iter.w5_200.explained_means)
    else
        for w = 1:length(MUdata.(mus).PCA.iter.w5_200.explained_means)
            if isempty(MUdata.(mus).PCA.iter.w5_200.coeffs_mean{w})
            else
            mean_coeff{w} = mean(MUdata.(mus).PCA.iter.w5_200.coeffs_mean{w}(2:end,:),1);
            end
        end
        mat = zeros(30,length(MUdata.(mus).PCA.iter.w5_200.explained_means));
        for i = 1:length(MUdata.(mus).PCA.iter.w5_200.explained_means)
            num = length(MUdata.(mus).PCA.iter.w5_200.explained_means{i});
            mat(i,1:num) = MUdata.(mus).PCA.iter.w5_200.explained_means{i}(1:num);
        end
        mat(mat == 0) = NaN;
        mean_expl = nanmean(mat);
    end
    
    if exist('mean_expl','var') == 0
        MUdata.(mus).PCA.iter.w5_200.explained_mean = NaN;
        MUdata.(mus).PCA.iter.w5_200.coeff_mean = NaN;
    else
        MUdata.(mus).PCA.iter.w5_200.explained_mean = mean_expl;
        MUdata.(mus).PCA.iter.w5_200.coeff_mean = mean_coeff;
    end
    clear('mean_expl','mean_coeff');
    end
end
end

% ------------- For all PFs combined ---------------------------------

% --------- PCA of smoothed, detrended IDR lines - 1s windows --------
    win = 2000;
    num = 30;
    rem = [];
    for w = 1:num
        ws = MUdata.start + (w*win) - win;
        we = ws + win;
        % skip to next window if any flags in this one = 1
        if sum(fdat.allflags(ws:we)) == 0
            % Subset PFidrs
            idrsec = PFidrs(:,ws:we);
            for mu = 1:size(idrsec,1)
                if sum(isnan(idrsec(mu,:))) > 0
                    rem = horzcat(rem,mu);
                elseif sum((idrsec(mu,:))) == 0
                    rem = horzcat(rem,mu);
                end
            end
            % Remove empty IDRs
            idrdat = idrsec;
            idrdat(rem,:) = [];
            % If < 3 MUs are active
            if size(idrdat,1) < 3
                MUdata.PCA.iter.w1_200.coeffs{w} = {};
                MUdata.PCA.iter.w1_200.explained{w} = {};
                MUdata.PCA.iter.w1_200.latentvar{w} = {};
                MUdata.PCA.iter.w1_200.mu{w} = {};
            else
            % Run PCA for that window
            pcadat = PCAiter(idrdat,100);
                MUdata.PCA.iter.w1_200.coeffs{w} = pcadat.coeff_all;
                MUdata.PCA.iter.w1_200.explained{w} = pcadat.expl_all;
                MUdata.PCA.iter.w1_200.latentvar{w} = pcadat.latentvar_all;
                MUdata.PCA.iter.w1_200.mu{w} = pcadat.muu_all;
                MUdata.PCA.iter.w1_200.coeffs_mean{w} = pcadat.coeff_mean;
                MUdata.PCA.iter.w1_200.explained_means{w} = pcadat.expl_mean;
                MUdata.PCA.iter.w1_200.latentvar_means{w} = pcadat.latentvar_mean;
                MUdata.PCA.iter.w1_200.mu_mean{w} = pcadat.muu_mean;
            end
        else
            MUdata.PCA.iter.w1_200.coeffs{w} = {};
            MUdata.PCA.iter.w1_200.explained{w} = {};
            MUdata.PCA.iter.w1_200.latentvar{w} = {};
            MUdata.PCA.iter.w1_200.mu{w} = {};
        end
        rem = [];
        idrdat = [];
    end

% --------- PCA of smoothed, detrended IDR lines - 5s windows ---------
    win = 10000;
    num = 6;
    rem = [];
    for w = 1:num
        ws = MUdata.start + (w*win) - win;
            MUdata.w5_200.starts(w) = ws;
        we = ws + win;
            MUdata.w5_200.endds(w) = we;
        % skip to next window if any flags in this one = 1
        if sum(fdat.allflags(ws:we)) == 0
            % Subset idrs
            idrsec = PFidrs(:,ws:we);
            for mu = 1:size(idrsec,1)
                if sum(isnan(idrsec(mu,:))) > 0
                    rem = horzcat(rem,mu);
                elseif sum((idrsec(mu,:))) == 0
                    rem = horzcat(rem,mu);
                end
            end
            % Remove empty IDRs
            idrdat = idrsec;
            idrdat(rem,:) = [];
            % If < 3 MUs are active
            if size(idrdat,1) < 3
                MUdata.PCA.iter.w5_200.coeffs{w} = {};
                MUdata.PCA.iter.w5_200.explained{w} = {};
                MUdata.PCA.iter.w5_200.latentvar{w} = {};
                MUdata.PCA.iter.w5_200.mu{w} = {};
            else
            % Run PCA for that window
            [pcadat] = PCAiter(idrdat,100);
                MUdata.PCA.iter.w5_200.coeffs{w} = pcadat.coeff_all;
                MUdata.PCA.iter.w5_200.explained{w} = pcadat.expl_all;
                MUdata.PCA.iter.w5_200.latentvar{w} = pcadat.latentvar_all;
                MUdata.PCA.iter.w5_200.mu{w} = pcadat.muu_all;
                MUdata.PCA.iter.w5_200.coeffs_mean{w} = pcadat.coeff_mean;
                MUdata.PCA.iter.w5_200.explained_means{w} = pcadat.expl_mean;
                MUdata.PCA.iter.w5_200.latentvar_means{w} = pcadat.latentvar_mean;
                MUdata.PCA.iter.w5_200.mu_mean{w} = pcadat.muu_mean;
            end
        else
            MUdata.PCA.iter.w5_200.coeffs{w} = {};
            MUdata.PCA.iter.w5_200.explained{w} = {};
            MUdata.PCA.iter.w5_200.latentvar{w} = {};
            MUdata.PCA.iter.w5_200.mu{w} = {};
        end
        rem = [];
    end
    
% ------------- Averages for muscle per window length ------------------    
    % 1-s window length
    if ~isfield(MUdata.PCA.iter.w1_200,'explained_means')
    elseif isempty(MUdata.PCA.iter.w1_200.explained_means)
    else
        for w = 1:length(MUdata.PCA.iter.w1_200.explained_means)
            if isempty(MUdata.PCA.iter.w1_200.coeffs_mean{w})
            else
            mean_coeff{w} = mean(MUdata.PCA.iter.w1_200.coeffs_mean{w}(2:end,:),1);
            end
        end
        mat = zeros(30,length(MUdata.PCA.iter.w1_200.explained_means));
        for i = 1:length(MUdata.PCA.iter.w1_200.explained_means)
            num = length(MUdata.PCA.iter.w1_200.explained_means{i});
            mat(i,1:num) = MUdata.PCA.iter.w1_200.explained_means{i}(1:num);
        end
        mat(mat == 0) = NaN;
        mean_expl = nanmean(mat);
    end
    
    if exist('mean_expl','var') == 0
        MUdata.PCA.iter.w1_200.explained_mean = NaN;
        MUdata.PCA.iter.w1_200.coeff_mean = NaN;
    else
        MUdata.PCA.iter.w1_200.explained_mean = mean_expl;
        MUdata.PCA.iter.w1_200.coeff_mean = mean_coeff;
    end
    clear('mean_expl','mean_coeff');
    
    % 5-s window length
    if ~isfield(MUdata.PCA.iter.w5_200,'explained_means')
    elseif isempty(MUdata.PCA.iter.w5_200.explained_means)
    else
        for w = 1:length(MUdata.PCA.iter.w5_200.explained_means)
            if isempty(MUdata.PCA.iter.w5_200.coeffs_mean{w})
            else
            mean_coeff{w} = mean(MUdata.PCA.iter.w5_200.coeffs_mean{w}(2:end,:),1);
            end
        end
        mat = zeros(30,length(MUdata.PCA.iter.w5_200.explained_means));
        for i = 1:length(MUdata.PCA.iter.w5_200.explained_means)
            num = length(MUdata.PCA.iter.w5_200.explained_means{i});
            mat(i,1:num) = MUdata.PCA.iter.w5_200.explained_means{i}(1:num);
        end
        mat(mat == 0) = NaN;
        mean_expl = nanmean(mat);
    end
    
    
    if exist('mean_expl','var') == 0
        MUdata.PCA.iter.w5_200.explained_mean = NaN;
        MUdata.PCA.iter.w5_200.coeff_mean = NaN;
    else
        MUdata.PCA.iter.w5_200.explained_mean = mean_expl;
        MUdata.PCA.iter.w5_200.coeff_mean = mean_coeff;
    end
    clear('mean_expl','mean_coeff');
% ----------------------------------------------------------------
end
