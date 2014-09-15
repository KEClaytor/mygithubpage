%Kevin Claytor
%MPTE Project
%Spring 2006
%Contact claytor@rice.edu
%
%This function initializes a GUI for conversion of several image types.  It
%  will handle basic resizes as well as cropping (with resize).
%  The capability of transforming polar images into cartesian ones is also
%  being added, as is the main function of taking a set of polar images and
%  warping them into 2:1 images for a projector to bounce off of a sphere
%  and onto a larger dome.
%
%Usage MTPEWarp('action')
%

%Glossary

%Pseudocode
%
%Open the first image


function MPTEWarp(action)

if nargin<1                                 % If number of arguments input < 1
    action = 'initialize';
end

if strcmp(action,'initialize')  
    title='MTPE Dome Converter -- Version 0.82 (R6)';  % Title our graph, use a variable that we can later change
    figure('Name',title,...
           'NumberTitle','off', ...
	       'DoubleBuffer','on');   % turn off that flickering

       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%INFO FOR OPENING THE FILE
% A textbox to get the filepath.
    uicontrol('Style','PushButton',...
              'String','Select File Path',...  % Initial label on button
              'Position',[200 200 160 20],... % Position in pixel units
              'Callback','MTPEWarp(''getfilepath'')',... % What clicking on the button does
              'Tag','FilePath');              % Control name
    uicontrol('Style','Text',...              % Boring text box
              'String','Select Input File Path',...
              'Position',[200 220 160 20],...
              'Tag','FilePath_Label');
          
% One to get the filename without extension.
    uicontrol('Style','PushButton',...
              'String','Sepecify File Name',...  % Initial label on button
              'Position',[200 140 160 20],... % Position in pixel units
              'Callback','MTPEWarp(''getfilename'')',... % What clicking on the button does
              'Tag','FileName');              % Control name
    uicontrol('Style','Text',...
              'String','Sepecify Input File name (without numbers, or extension)',...
              'Position',[200 160 160 30],...
              'Tag','FileName_Label');
          
% And a drop down menu to get the extension.
    uicontrol('Style','Popupmenu',...
              'String','jpg|jpeg|tif|tiff|gif|bmp|Other',...
              'Position',[200 90 100 20],...
              'Tag','FileExt');
    uicontrol('Style','Text',...              % Boring text box
              'String','Sepecify Input Extension',...
              'Position',[200 110 160 20],...
              'Tag','FileExt_Label');
    uicontrol('Style','Text',...
              'Position',[300 90 60 20],...
              'Tag','Num_Frame');
          
          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%INFO FOR SAVING THE FILE
% A textbox to get the filepath.
    uicontrol('Style','PushButton',...
              'String','Select File Path',...  % Initial label on button
              'Position',[380 200 160 20],... % Position in pixel units
              'Callback','MTPEWarp(''getoutfilepath'')',... % What clicking on the button does
              'Tag','OutFilePath');              % Control name
    uicontrol('Style','Text',...              % Boring text box
              'String','Select Output File Path',...
              'Position',[380 220 160 20],...
              'Tag','OutFilePath_Label');
          
% One to get the filename without extension.
    uicontrol('Style','PushButton',...
              'String','Sepecify File Name',...  % Initial label on button
              'Position',[380 140 160 20],... % Position in pixel units
              'Callback','MTPEWarp(''getoutfilename'')',... % What clicking on the button does
              'Tag','OutFileName');              % Control name
    uicontrol('Style','Text',...
              'String','Sepecify Output File name (without numbers, or extension)',...
              'Position',[380 160 160 30],...
              'Tag','OutFileName_Label');
          
% And a drop down menu to get the extension.
    uicontrol('Style','Popupmenu',...
              'String','tif|tiff|gif|bmp|jpg|jpeg|Other',...
              'Position',[380 90 100 20],...
              'Tag','OutFileExt');
    uicontrol('Style','Text',...              % Boring text box
              'String','Sepecify Output Extension',...
              'Position',[380 110 160 20],...
              'Tag','OutFileExt_Label');
    uicontrol('Style','Text',...
              'Position',[480 90 60 20],...
              'Tag','OutNum_Frame');

%%%%%%%%%%%%%%%%%%Number of images, outputsize and radii
          
% A text box for the number of images we want to convert
    uicontrol('Style','Edit',...
              'min',2,...
              'max',3,...
              'String','100',...
              'Position',[20 200 80 20],...
              'Tag','NumImages');
    uicontrol('Style','Text',...
              'String','Number of images to convert',...
              'Position',[20 220 150 20],...
              'Tag','Num_Label');
% How many images offeset we are in the conversion
    uicontrol('Style','Edit',...
              'min',2,...
              'max',3,...
              'String','0',...
              'Position',[140 200 30 20],...
              'Tag','OffsetNum');
    uicontrol('Style','Text',...
              'String','Offset',...
              'Position',[100 200 40 20],...
              'Tag','Ost_Label');
          
% A text box for the size we want the output image
    uicontrol('Style','Edit',...
              'min',2,...
              'max',3,...
              'String','2200',...
              'Position',[20 150 100 20],...
              'Tag','ImageSize');
% Text to title the edit text box
    uicontrol('Style','Text',...
              'String','Size of output image (pixels)',...
              'Position',[20 170 150 20],...
              'Tag','Size_Label');
    uicontrol('Style','Text',...
              'Position',[120 150 50 20],...
              'Tag','Size_Frame');

% And a drop down menu for the type of interpolation
    uicontrol('Style','Popupmenu',...
              'String','Nearest|Bilinear|Bicubic',...
              'Position',[20 90 150 20],...
              'Tag','InterpType');
    uicontrol('Style','Text',...              % Boring text box
              'String','Interpolation Method',...
              'Position',[20 110 150 20],...
              'Tag','Interp_Label');
          
% A text box for the smaller mirror radius (r1)
    uicontrol('Style','Edit',...
              'min',2,...
              'max',3,...
              'String','.5',...
              'Position',[130 115 50 20],...
              'Tag','SmRadius',...
              'Visible','off');
% Text to title the edit text box
    uicontrol('Style','Text',...
              'String','Small dome radius (m)',...
              'Position',[20 115 110 20],...
              'Tag','Sm_Label',...
              'Visible','off');
% A text box for the larger mirror radius (r2)
    uicontrol('Style','Edit',...
              'min',2,...
              'max',3,...
              'String','10',...
              'Position',[130 90 50 20],...
              'Tag','LgRadius',...
              'Visible','off');
% Text to title the edit text box
    uicontrol('Style','Text',...
              'String','Large dome radius (m)',...
              'Position',[20 90 110 20],...
              'Tag','Lg_Label',...
              'Visible','off');
          
% A text box for the width
    uicontrol('Style','Edit',...
              'min',2,...
              'max',3,...
              'String','2200',...
              'Position',[130 165 50 20],...
              'Tag','Width',...
              'Visible','off');
% Text to title the edit text box
    uicontrol('Style','Text',...
              'String','Width of output image',...
              'Position',[20 165 110 20],...
              'Tag','W_Label',...
              'Visible','off');
% A text box for the heitht
    uicontrol('Style','Edit',...
              'min',2,...
              'max',3,...
              'String','2200',...
              'Position',[130 140 50 20],...
              'Tag','Height',...
              'Visible','off');
% Text to title the edit text box
    uicontrol('Style','Text',...
              'String','Height of output image',...
              'Position',[20 140 110 20],...
              'Tag','H_Label',...
              'Visible','off');
          
% Text boxes to title the graphs
    uicontrol('Style','Text',...
              'String','Before Conversion',...
              'Position',[90 390 150 20]);
    uicontrol('Style','Text',...
              'String','After Conversion',...
              'Position',[340 390 150 20]);
          
          
%%%%% START, HELP AND ABOUT
          
% And a drop down menu for the type of action we are to execute
    uicontrol('Style','Popupmenu',...
              'String','Resize|Crop (and Resize)|Cartesian Transform|Mirror Dome Transform',...
              'Position',[200 40 160 20],...
              'Tag','TransformType');
    uicontrol('Style','Text',...              % Boring text box
              'String','Select Action',...
              'Position',[200 60 160 20],...
              'Tag','Trans_Label');
% The start pushbutton
    uicontrol('Style','PushButton',...
              'String','Options',...  % Initial label on button
              'Position',[90 40 90 40],... % Position in pixel units
              'Callback','MTPEWarp(''start'')',... % What clicking on the button does
              'Tag','MainControl');              % Control name
% A Help pushbutton and dialouge
    uicontrol('Style','PushButton',...
              'String','Help',...  % Initial label on button
              'Position',[10 40 60 40],... % Position in pixel units
              'Callback','MTPEWarp(''help'')',... % What clicking on the button does
              'Tag','HelpButton');              % Control name
% An about dialouge
    uicontrol('Style','PushButton',...
              'String','About',...
              'Position',[10 1 50 15],...
              'Callback','MTPEWarp(''about'')',... % give our about message
              'Tag','AboutButton');
% A reset button if you really get messed up
    uicontrol('Style','PushButton',...
              'String','Reset',...
              'Position',[70 1 50 15],...
              'Callback','MTPEWarp(''clear'')',... % give our about message
              'Tag','ResetButton');


%%==================================================
%% Now decide what to do on what button was pressed
%%==================================================
elseif strcmp(action,'getfilepath')
    fp = findobj(gcf,'Tag','FilePath');
    filepath = inputdlg('Filepath?','Specify the path to the images',1);
    set(fp,'String',filepath)
elseif strcmp(action,'getfilename')
    fn = findobj(gcf,'Tag','FileName');
    filename = inputdlg('Name of the file without end numbers or extension?','Specify the generic file name',1);
    set(fn,'String',filename)
elseif strcmp(action,'getoutfilepath')
    ofp = findobj(gcf,'Tag','OutFilePath');
    outfilepath = inputdlg('Filepath?','Specify the path to the images',1);
    set(ofp,'String',outfilepath)
elseif strcmp(action,'getoutfilename')
    ofn = findobj(gcf,'Tag','OutFileName');
    outfilename = inputdlg('Name of the file without end numbers or extension?','Specify the generic file name',1);
    set(ofn,'String',outfilename)
    
%%==================================================
%% The main deal, the start button was pressed
%%==================================================
elseif strcmp(action,'start')
    %%ALL THINGS THAT WE WANT NO MATTER WHAT WE'RE DOING
    fp = findobj(gcf,'Tag','FilePath');
    fn = findobj(gcf,'Tag','FileName');
    fe = findobj(gcf,'Tag','FileExt');
    ofp = findobj(gcf,'Tag','OutFilePath');
    ofn = findobj(gcf,'Tag','OutFileName');
    ofe = findobj(gcf,'Tag','OutFileExt');
    ni = findobj(gcf,'Tag','NumImages');
    os = findobj(gcf,'Tag','OffsetNum');
    tt = findobj(gcf,'Tag','TransformType');
    sz = findobj(gcf,'Tag','ImageSize');
    szl = findobj(gcf,'Tag','Size_Label');
    szf = findobj(gcf,'Tag','Size_Frame');
    %%MORE FOR THE SPECIFIC TYPE OF TRANSFORM
    sr = findobj(gcf,'Tag','SmRadius');
    srl = findobj(gcf,'Tag','Sm_Label');
    lr = findobj(gcf,'Tag','LgRadius');
    lrl = findobj(gcf,'Tag','Lg_Label');
    wd = findobj(gcf,'Tag','Width');
    wdl = findobj(gcf,'Tag','W_Label');
    ht = findobj(gcf,'Tag','Height');
    htl = findobj(gcf,'Tag','H_Label');
    it = findobj(gcf,'Tag','InterpType');
    itl = findobj(gcf,'Tag','Interp_Label');
    %%THE BIG IMPORTANT BUTTON
    ct = findobj(gcf,'Tag','MainControl');
    
    %% If we're currently set to display more options
    if strcmp(get(ct,'String'),'Options')
        %%Set the button for the next round
        set(ct,'String','Start Conversion')
        %Hide and unhide options based on what we chose at the end go ahead
        %and set us up for the conversion
        switch (get(tt,'Value'))
            case 1
                %%Unhid the main size
                set(sz,'Visible','On')
                set(szl,'Visible','On')
                set(szf,'Visible','On')
                set(it,'Visible','On')
                set(itl,'Visible','On')
                %%Hide the rest
                set(sr,'Visible','Off')
                set(srl,'Visible','Off')
                set(lr,'Visible','Off')
                set(lrl,'Visible','Off')
                set(wd,'Visible','Off')
                set(wdl,'Visible','Off')
                set(ht,'Visible','Off')
                set(htl,'Visible','Off')
            case 2
                %%Unhid the sub sizes
                set(wd,'Visible','On')
                set(wdl,'Visible','On')
                set(ht,'Visible','On')
                set(htl,'Visible','On')
                set(it,'Visible','On')
                set(itl,'Visible','On')
                %%Hide the rest
                set(sz,'Visible','Off')
                set(szl,'Visible','Off')
                set(szf,'Visible','Off')
                set(sr,'Visible','Off')
                set(srl,'Visible','Off')
                set(lr,'Visible','Off')
                set(lrl,'Visible','Off')
            case 3
                %%Unhid the main size
                set(sz,'Visible','On')
                set(szl,'Visible','On')
                set(szf,'Visible','On')
                %%Hide the rest
                set(sr,'Visible','Off')
                set(srl,'Visible','Off')
                set(lr,'Visible','Off')
                set(lrl,'Visible','Off')
                set(wd,'Visible','Off')
                set(wdl,'Visible','Off')
                set(ht,'Visible','Off')
                set(htl,'Visible','Off')
                set(it,'Visible','Off')
                set(itl,'Visible','Off')
            case 4
                %%Unhid the main size
                set(sz,'Visible','On')
                set(szl,'Visible','On')
                set(szf,'Visible','On')
                set(sr,'Visible','On')
                set(srl,'Visible','On')
                set(lr,'Visible','On')
                set(lrl,'Visible','On')
                %%Hide the rest
                set(it,'Visible','Off')
                set(itl,'Visible','Off')
                set(wd,'Visible','Off')
                set(wdl,'Visible','Off')
                set(ht,'Visible','Off')
                set(htl,'Visible','Off')
        end
    elseif strcmp(get(ct,'String'),'Start Conversion')
        set(ct,'String','Stop Conversion');
        %Do some checkst to make sure that the user didn't leave a field blank.
        if strcmp(get(fp,'String'),'Select File Path')
            filepath = inputdlg('Filepath?','Specify the path to the images',1);
            set(fp,'String',filepath)
        end
        if strcmp(get(fn,'String'),'Sepecify File Name')
            filename = inputdlg('Name of the file without end numbers or extension?','Specify the generic file name',1);
            set(fn,'String',filename)
        end
        filepath = char(get(fp,'String'));
        filename = char(get(fn,'String'));
        %Set the output fields to the input ones if the user left them
        %    blank
        if strcmp(get(ofp,'String'),'Select File Path')
            outfilepath = filepath;
            set(ofp,'String',outfilepath);
        else
            outfilepath = char(get(ofp,'String'));
        end
        if strcmp(get(ofn,'String'),'Sepecify File Name')
            outfilename = filename;
            set(ofn,'String',outfilename);
        else
            outfilename = char(get(ofn,'String'));
        end
        %Get the stuff from the other input fields and make sure they're
        %  adaquate as well.
        %CHECK THE NUMBER OF IMAGES
        num=str2double(get(ni,'String'));  % The number of images we want to convert
        if isnan(num)  %Give an error and reset if the user input anything other than a number
            errordlg('You must enter a numeric value for the number of images to convert','Bad Input','modal')
            set(ct,'String','Start Conversion')  %reset
        end
        if num<=0      %Likewise, we can't take negatives or zeros for the number of images
            errordlg('You must enter a positive non-zero value for the number of images to convert','Bad Input','modal')
            set(ct,'String','Start Conversion')  %reset
        end
        %CHECK THE OFFSET NUMBER
        offset=str2double(get(os,'String'));  % The number of images we want to convert
        if isnan(offset)  %Give an error and reset if the user input anything other than a number
            errordlg('You must enter a numeric value for the number of images offset that the conversion should start at','Bad Input','modal')
            set(ct,'String','Start Conversion')  %reset
        end
        if offset<0      %Likewise, we can't take negatives or zeros for the number of images
            errordlg('You must enter a positive or zero value for the number of images offset that the conversion should start at','Bad Input','modal')
            set(ct,'String','Start Conversion')  %reset
        end
        %CHECK THE IMAGE SIZE
        size=str2double(get(sz,'String'));  % The number of images we want to convert
        if isnan(size)  %Give an error and reset if the user input anything other than a number
            errordlg('You must enter a numeric value for the output image size','Bad Input','modal')
            set(ct,'String','Start Conversion')  %reset
        end
        if size<=0      %Likewise, we can't take negatives or zeros for the number of images
            errordlg('You must enter a positive non-zero value for the output image size','Bad Input','modal')
            set(ct,'String','Start Conversion')  %reset
        end
        
        %GET THE FORMAT OF THE IMAGE
        switch get(fe,'Value')
            case 1
                fmt='.jpg';
            case 2
                fmt='.jpeg';
            case 3
                fmt='.tif';
            case 4
                fmt='.tiff';
            case 5
                fmt='.gif';
            case 6
                fmt='.bmp';
            case 7
                fmt = inputdlg('imput the extension with the . prefix; eg .gif','User Specified Extension',1);
        end
        %GET THE OUTPUT FORMAT VALUE
        switch get(ofe,'Value')
            case 1
                ofmt='.tif';  %We make tif default as matlab has a better tif than jpg writer
            case 2
                ofmt='.tiff';
            case 3
                ofmt='.gif';
            case 4
                ofmt='.bmp';
            case 5
                ofmt='.jpg';
            case 6
                ofmt='.jpeg';
            case 7
                ofmt = inputdlg('imput the extension with the . prefix; eg .gif','User Specified Extension',1);
        end
        
        %%==================================================
        %% With the checks out of the way, let's get down to business
        %%==================================================
        %NOTE TO SELF: Write
        %  results as a tiff and
        %  convert later, the jpg
        %  encoder in matlab
        %  sucks major ---.
        %%Check to see what the user wanted again
        switch (get(tt,'Value'))
            case 1  %Do the simple scale
                switch get(it,'Value')  %what method do we want to use to resize
                    case 1
                        method = 'nearest';
                    case 2
                        method = 'bilinear';
                    case 3
                        method = 'bicubic';
                end
                itc = 0;                                % Start the counter
                while itc < num & strcmp(get(ct,'String'),'Stop Conversion')
                    %%FILE SELECTION STUFF -- DON"T TREAD ON ME
                    [path,outpath]=getFilePath(num,offset,itc,filepath,filename,fmt,outfilepath,outfilename,ofmt);
                    
                    image=imread(path);                 % Open the image
                    [row,col,z]=size(image);            % Get the PROPER size of the image
                    newimage=imresize(image,(size/col),method);% Resize the image
                    if itc==0;                          % Show the demo for the first image
                        demo(image,newimage);
                    end
                    imwrite(newimage,outpath);          % Write the output
                    itc = itc+1;                        % Increase the counter
                end
                set(ct,'String','Options')         % Reset for the next time
            case 2  %Do the more complex scale
                %CHECK THE WIDTH AND HEIGHT VALUES
                iwidth=str2double(get(wd,'String'));  % The number of images we want to convert
                if isnan(iwidth)  %Give an error and reset if the user input anything other than a number
                    errordlg('You must enter a numeric value for the output image width','Bad Input','modal')
                    set(ct,'String','Start Conversion')  %reset
                end
                if iwidth<=0      %Likewise, we can't take negatives or zeros for the number of images
                    errordlg('You must enter a positive non-zero value for the output image width','Bad Input','modal')
                    set(ct,'String','Start Conversion')  %reset
                end
                iheight=str2double(get(ht,'String'));  % The number of images we want to convert
                if isnan(iheight)  %Give an error and reset if the user input anything other than a number
                    errordlg('You must enter a numeric value for the output image height','Bad Input','modal')
                    set(ct,'String','Start Conversion')  %reset
                end
                if iheight<=0      %Likewise, we can't take negatives or zeros for the number of images
                    errordlg('You must enter a positive non-zero value for the output image height','Bad Input','modal')
                    set(ct,'String','Start Conversion')  %reset
                end
                if iheight>iwidth
                    errordlg('The height cannot be larger than the width','Bad Input','modal')
                    set(ct,'String','Start Conversion')  %reset
                end
                switch get(it,'Value')  %what method do we want to use to resize
                    case 1
                        method = 'nearest';
                    case 2
                        method = 'bilinear';
                    case 3
                        method = 'bicubic';
                end
                
                itc = 0;                                % Start the counter
                numlength=length(num2str(num));
                while itc < num & strcmp(get(ct,'String'),'Stop Conversion')
                    %%FILE SELECTION STUFF -- DON"T TREAD ON ME
                    [path,outpath]=getFilePath(num,offset,itc,filepath,filename,fmt,outfilepath,outfilename,ofmt);
                    
                    image=imread(path);                 % Open the image
                    [row,col,z]=size(image);            % Get the PROPER size of the image
                    if col==iwidth                      % If the widths are already the same then we just need to crop
                        startrow=row-height+1;                  % Find out where we should start the crop
                        newimage=image(startrow:end,:,:);       % We just want the lower part, so crop the vertical off.
                    else
                        newimage=imresize(image,(iwidth/col),method); % Resize the image
                        %Get the new properties of the image
                        [row,col,z]=size(newimage);
                        startrow=row-iheight+1;                      % Find out where we should start the crop
                        newimage=newimage(startrow:end,:,:);        % We just want the lower part, so crop the vertical off.
                    end
                    if itc==0;                          % Show the demo for the first image
                        demo(image,newimage);
                    end
                    imwrite(newimage,outpath);          % Write the output
                    itc = itc+1;                        % Increase the counter
                end
                set(ct,'String','Options')         % Reset for the next time
            case 3  %Do the cartesian transform
                msgbox('This option is currently being developed','Not Currently Available');
            case 4
                %%DO SOME CHECKS RELEVANT TO THIS CONVERSION ONLY
                %CHECK THE SMALL RADIUS
                r1=str2double(get(sr,'String'));  % The small reflective mirror radius
                if isnan(r1)  %Give an error and reset if the user input anything other than a number
                    errordlg('You must enter a numeric value for the mirror radus (in meters)','Bad Input','modal')
                    set(ct,'String','Start Conversion')  %reset
                end
                if r1<=0      %Likewise, we can't take negatives or zeros for the radius
                    errordlg('You must enter a positive non-zero value for tthe mirror radus (in meters)','Bad Input','modal')
                    set(ct,'String','Start Conversion')  %reset
                end
                %CHECK THE LARGE RADIUS
                r2=str2double(get(lr,'String'));  % The large dome radius
                if isnan(r2)  %Give an error and reset if the user input anything other than a number
                    errordlg('You must enter a numeric value for the dome radus (in meters)','Bad Input','modal')
                    set(ct,'String','Start Conversion')  %reset
                end
                if r2<=0      %Likewise, we can't take negatives or zeros for the radius
                    errordlg('You must enter a positive non-zero value for the dome radus (in meters)','Bad Input','modal')
                    set(ct,'String','Start Conversion')  %reset
                end
                
                itc = 0;
                numlength=length(num2str(num));
                %%FILE SELECTION STUFF -- DON"T TREAD ON ME
                while itc < num & strcmp(get(ct,'String'),'Stop Conversion')
                    [path,outpath]=getFilePath(num,offset,itc,filepath,filename,fmt,outfilepath,outfilename,ofmt);
                    
                    image=imread(path);                             % Open the image
                    [row,col,z]=size(image);                        % Find the REAL size of the image
                    %newimage=domeconvert(image,r1,r2);              % Get the transformed image
                    if itc==0;                          % Show the demo for the first image
                        demo(image,newimage);
                    end
                    imwrite(newimage,outpath);                      % Save the result
                    %figure
                    %imshow(newimage)
                    %imwrite(newimage,filename2,fmt);        %And save the result
                    itc = itc+1;
                end
                set(ct,'String','Options')         % Reset for the next time
        end
    end
    
elseif strcmp(action,'help')  %display a help box indicating where the user can go to get some help
    msgbox('Please consult the users manual at http://www.owlnet.rice.edu/~kec4482/mtpe/MTPEWarpGuide.pdf','Additional resources')
    
elseif strcmp(action,'about')  %display a little about box, it's really totally worthless, but I thought it was fun.
                               % for some reason the cariage return \n
                               % wasn't working in this case so I just put
                               % in a whole bunch of spaces to get it to
                               % display properly, it seems to have worked
    msgbox('MTPE Warping program | Version 1.0                                      Designed by Kevin Claytor in 2006 for MPTE                                   For results and more examples see: http://www.owlnet.rice.edu/~kec4482/','About MTPE Warp - V 1.0')
elseif strcmp(action,'clear')  %The user screwed up somewhere or wanted to start over clear everything and let's have a go at it again.
    fp = findobj(gcf,'Tag','FilePath');
    fn = findobj(gcf,'Tag','FileName');
    ofp = findobj(gcf,'Tag','OutFilePath');
    ofn = findobj(gcf,'Tag','OutFileName');
    ni = findobj(gcf,'Tag','NumImages');
    ct = findobj(gcf,'Tag','MainControl');
    set(ct,'String','Options')
    set(fp,'String','Select File Path')
    set(fn,'String','Sepecify File Name')
    set(ofp,'String','Select File Path')
    set(ofn,'String','Sepecify File Name')
end

return


%%A little function that mushes together all that we know about the files.

function [path,outpath]=getFilePath(num,offset,itc,filepath,filename,fmt,outfilepath,outfilename,ofmt)
if num>offset  %if the number of images to convert is larger than the offset eg; num=10000 offset = 15
    numlength=length(num2str(num));  %we use the larger one
else
    numlength=length(num2str(offset+num));  %otherwise we have to add them together to find out how long the final product will be  eg; num=500 offset=1000 our final length will be at least 1500
end
filenumber=[];
actualnum=itc+offset;
currentlength=length(num2str(actualnum));         %find out how many digits long itc is
for o=1:(numlength-currentlength)           %tack on enough zeros to make it match the length of num
    filenumber=[filenumber,'0'];
end
filenumber=[filenumber,num2str(actualnum)];
%Now make the full filepath
path=strcat(filepath,filename,filenumber,fmt);
%And also make one for the output
outpath=strcat(outfilepath,outfilename,filenumber,ofmt);

return

%% A function that goes ahead and plots our two preview images
function demo(image,newimage)

subplot(2,2,1)
imshow(image)
title='Before conversion';
axis off

subplot(2,2,2)
imshow(newimage)
title='After Conversion';
axis off

drawnow

return