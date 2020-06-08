% Chagos microscopy - photo processing
%
% JNS. Last edited 20200402 for MacOS 10.12.6
%
% For each water sample, 3 aliquots of 1 ml were examined - Sedgwick-Rafter chamber.
% Depending on sample density, full lateral transects of the chamber or
% successive grid cells were counted. Both transects and grid cells were
% selected using the Matlab rand function, primed using the rng function 
% with decimal time as input (rng(now)). Count information is stored in
% an Excel file, with one sheet per water sample (all 3 counts on one
% sheet).
% 1: Each grid cell is photographed at x100 (usually 2 photos, sometimes
% more). Task 1 is to place these into a separate, named folder with
% file-names that include the count reference.
% 2: Each type of phytoplankton (and some protozoa/other features) were 
%  photographed at least once. 
%  Task 2 is to present each image for cropping and cell sizing before 
%  storing the cropped image, appropriately named, in a separate
%  folder for the count.
%
% 1. Which sample - set by hand.
fileName = '/Users/jnschwarz/Documents/chagosMicroscopy/ChagosMicroscopy_counts_example'; % full count documentation.
sheetName='XXV_20200407';
sampleName = 'XXV'; % samples are VI, VII, VIII, XVI, XXV...
countDate = '20200407'; % use the date of the first count (out of 3) for labelling.
thisRange = 'A22:K892'; % XVI: 'A20:K953'; % VIII: 'A23:K528'; % VII: 'A19:K646'; % VI: 'A18:K466';
photoDir = '/Users/jnschwarz/Documents/chagosMicroscopy/XXV_2_20200408/';

% Output directory (outer):
outdir1 = '/Users/jnschwarz/Documents/chagosMicroscopy/';
outdir2 = [sampleName '_2_images'];
outdir3 = 'x100'; % code for this is on the PC - transfer later.
outdir4 = 'x400';

% Struct to hold catalog of cell information:
st = struct;

% Create directory structure:
if ~exist([outdir1 outdir2],'dir')
    [ok,mess,messid] = mkdir(outdir1,outdir2);
end
if ~exist([outdir1 outdir2 '/' outdir3],'dir')
    [ok,mess,messid] = mkdir([outdir1 outdir2],outdir3);
end
if ~exist([outdir1 outdir2 '/' outdir4],'dir')
    [ok,mess,messid] = mkdir([outdir1 outdir2],outdir4);
end

% Three counts per sample, beginning with count 1:
thiscount=1;

% Import all count data for this sample:
[num,txt,raw]=xlsread(fileName,sheetName,thisRange);

% Go line by line:      IF YOU STOP & restart matlab, REMEMBER TO RELOAD struct st !!!
for i=1:length(raw)
    clear this; this=raw(i,:);
    
    % Beginning a new count?
    clear newgrid; newgrid = strfind(this{1},'COUNT');
    if ~isempty(newgrid)
        thiscount = this{2};
    end
    
    % Check for lines of intervening text:
    clear gridcellLine; gridcellLine = strfind(this{1},'GridCell');
    if gridcellLine
        ; % do nothing
        
    % If this line has a gridcell number and x100 photos then transcribe
    % photos to the output folder with traceable name:
    elseif ~isnan(this{1}) & ~isnan(this{2})
        
        % How many x100 photos?
        x100 = strfind(this{2},'IMG_');
        for ix100 = 1:length(x100)
             clear newPhotoFile thisx100;
             thisx100=this{2}(x100(ix100):x100(ix100)+7);
             newPhotoFile = [outdir1 outdir2 '/' outdir3 '/count_' num2str(thiscount) ...
                 '_cell_' num2str(this{1}) '_' thisx100 '.jpg'];
            SUCCESS = copyfile([photoDir thisx100 '.JPG'], newPhotoFile);
            if SUCCESS < 1
                s = input('Error writing photo - ctrl+c to break & investigate','s');
            end
        end
        % x100 and x400 photos are mutually exclusive, so proceed with
        % else:
        
    % If this line has a numbered item and x400 photos then process:
    elseif ~isnan(this{3}) & ~isnan(this{11})
        % Guessed name:
        clear thisname; thisname=this{9};
        % Item number:
        clear thisitem; thisitem=this{3};
        % Guessed longest dimension:
        clear thisdim; thisdim=this{10};        
        % NB. 1 FOVx400 under the scope = 0.45 mm - convert:
        if ~isnan(thisdim)
            clear ispace; ispace=strfind(thisdim,' '); 
            clear islash; islash=strfind(thisdim,'/');
            clear iLT; iLT = strfind(thisdim, '<');
            clear iGT; iGT = strfind(thisdim, '>');
            clear thismetric thisM; thismetric=thisdim(ispace+1:end);
            if thismetric == 'FOVx400'
                thisM=450; % FOV dimension in microns
            elseif thismetric == 'FOVx100'
                thisM=1800; % FOV dimension in microns
            else
                thisM=nan; % type results in no estimate of cell longest dim.
            end
            clear thisA thisB thisR; 
            if ~isempty(iGT) | ~isempty(iLT)
                s1=2; % skip over <> if present
            else
                s1=1;
            end
            thisA = str2num(thisdim(s1:islash-1));
            if ~isempty(islash)
                thisB = str2num(thisdim(islash+1:ispace));
                thisR = thisA./thisB;
            else
                thisR = thisA;
            end
            thisGuess = thisR.*thisM; % Estimated longest cell dimension, in microns.
        else
            thisGuess = nan;
        end
        
        % Check whether there are x400 photos:
        clear thisPhotos; thisPhotos=this{11};
        if isnan(thisPhotos)
            % If no photos, do still store the name as a placeholder, with 
               % the guessed longest cell dimension if given:
            clear ispace; ispace = find(thisname(:) == ' ');
            thisname(ispace) = '_';

            st(thisitem).name = thisname;
            st(thisitem).longAxis = thisGuess;
            st(thisitem).shortAxis = nan;
            st(thisitem).goodImage = nan;
            % and now move on to the next line.
            
        else
            % How many photos?
            clear cm; cm=find(thisPhotos == ','); % if no commas, only one photo to process
            if isempty(cm)
                cm2 = 1;
            else
                cm2=length(cm)+1;
            end
            
            % For each photo..
            for iPh = 1:cm2  % Come back to this...
        
                % Pick out the next photo filename:
                if iPh == 1
                    clear nextPhotoFile; nextPhotoFile=thisPhotos(1:8);
                else
                    clear cm; cm=find(thisPhotos == ','); % only use it for indexing if we know it's not empty
                    clear nextPhotoFile; nextPhotoFile=thisPhotos(cm(iPh-1)+2:cm(iPh-1)+9);
                end
                if ~exist([photoDir nextPhotoFile '.JPG'],'file')
                    % If photo file is lost, do still store the name as a placeholder:
                    clear ispace; ispace = find(thisname(:) == ' ');
                    thisname(ispace) = '_';

                    st(thisitem).name = thisname;
                    st(thisitem).longAxis = thisGuess;
                    st(thisitem).shortAxis = nan;
                    st(thisitem).goodImage = nan;
                else
                    clear nextPhoto; nextPhoto=imread([photoDir nextPhotoFile '.JPG']);
                    figure(1); clf;
                    fh=image(nextPhoto);
                    title([thisname '  ' thisdim ' = ' num2str(thisGuess) ' \mum'])

                    % Ask whether to proceed with measurements:
                    clear s; s=input('Measure this cell? Yes=1: ', 's');
                    if s == '1'
                        
                        % Zoom to the cell ready to measure
                        clear s; s=input('Zoom into the cell and click enter when ready: ','s');

                        % What type of cell is it, for cell volume calculation?
                        clear str; str=input('Enter cell-shape number after Sun et al. (2006): ','s');
                        thisShape = str2num(str);

                        % Call to function biovolSun03 to log shape metrics and
                        % calculate volume. a,b and c can each have up to 4
                        % values; biovol has only 1 value:
                        [a,b,c,biovol,sa] = biovolSun03(thisShape);
                    

                        % Plot horizontal and vertical scale bars:
                        hold on
                        disp('Place upper left of SCALE BAR RIGHT-ANGLE on figure (518 pixels): ')
                        clear x y; [x,y] = ginput(1);
                        plot([x x+(1037/2)],[y y],'k');                    
                        disp('Place HORIZONTAL scalebar legend next to scale bar: ')
                        gtext('25 \mum','fontsize',12);

                        plot([x x],[y y+(1037/2)],'k');                   
                        disp('Place VERTICAL scalebar legend next to scale bar: ')
                        gtext('25 \mum','fontsize',12);

                        disp('Place dimension text on figure: ');
                        a2 = round(a,2,'decimals'); b2=round(b,2,'decimals');
                        gtext([num2str(a2(1)) ' x ' num2str(b2(1)) '\mum'],'fontsize',12);
                    
                        % Refine the figure title:
                        title(['Count ' num2str(thiscount) ', item ' num2str(thisitem) ', cf ' thisname])

                        % Final chance to adjust figure window dimensions here:
                        % Is this image useful for printing in the final catalog?
                        s = input('Adjust figure window & then enter 1 if this image is good for printing, else 0: ','s');

                        % Replace any spaces and questionmarks in the guessed species/genus name with
                        % underscore:
                        clear ispace; ispace = find(thisname(:) == ' ');
                        thisname(ispace) = '_';
                        clear iqm; iqm = find(thisname(:) == '?');
                        thisname(ispace) = '_';

                        clear newPhotoFile; 
                        newPhotoFile = [outdir1 outdir2 '/' outdir4 '/item_' num2str(thisitem) ...
                            '_' thisname '_' num2str(cm2) '.png'];
                        print('-dpng','-r400', newPhotoFile);


                        % Write measurements to .mat catalog:
                        st(thisitem).name = thisname;
                        st(thisitem).shape = thisShape;
                        st(thisitem).biovolume = biovol;
                        st(thisitem).surfaceArea = sa;
                        st(thisitem).cellMeasurements_a = a;
                        st(thisitem).cellMeasurements_b = b;
                        st(thisitem).cellMeasurements_c = c;
                        st(thisitem).goodImage = str2num(s);
                        st(thisitem).photo = newPhotoFile;
                    else % photos exist but we don't wish to measure:
                        st(thisitem).name = thisname;
                        st(thisitem).shape = nan;
                        st(thisitem).biovolume = nan;
                        st(thisitem).surfaceArea = nan;
                        st(thisitem).cellMeasurements_a(1:4) = nan;
                        st(thisitem).cellMeasurements_b(1:4) = nan;
                        st(thisitem).cellMeasurements_c(1:4) = nan;
                        st(thisitem).goodImage = 0;
                        st(thisitem).photo = '';
                    end                        
                end
            end % end loop over multiple photos per item
                    
        end % end check whether any x400 photo was taken for this item.
        
    end % First check - is this a x100 or a x400 line.
    
    
end

%save('/Users/jnschwarz/Documents/chagosMicroscopy/working_20200603.mat');

        
outfile = [outdir1 outdir2 '/cellMeasurements_' sampleName '_20200606.mat'];
save(outfile);



