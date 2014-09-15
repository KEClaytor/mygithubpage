%Kevin Claytor
%MPTE Project
%Spring 2006
%Contact claytor@rice.edu
%
%This function initializes a GUI for easy batch trimming of images.
%  Originally concieved to trim dome masters for planetarium shows
%  but it can be used to trim any square region from an image.
%
%Usage MTPETrim('action')
%

%Glossary

%Pseudocode
%
%Open the first image
% Perform the trim
%Save the image
%Repeat


function MPTETrim(action)

if nargin<1                                 % If number of arguments input < 1
    action = 'initialize';
end

if strcmp(action,'initialize')  
    title='MTPE Dome Trimmer -- Version 1.00 (R3)';  % Title our graph, use a variable that we can later change
    figure('Name',title,...
           'NumberTitle','off', ...
	       'DoubleBuffer','on');   % turn off that flickering

       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%INFO FOR OPENING THE FILE
% A textbox to get the filepath.
    uicontrol('Style','PushButton',...
              'String','Select File Path',...  % Initial label on button
              'Position',[200 200 160 20],... % Position in pixel units
              'Callback','MTPETrim(''getfilepath'')',... % What clicking on the button does
              'Tag','FilePath');              % Control name
    uicontrol('Style','Text',...              % Boring text box
              'String','Select Input File Path',...
              'Position',[200 220 160 20],...
              'Tag','FilePath_Label');
          
% One to get the filename without extension.
    uicontrol('Style','PushButton',...
              'String','Specify File Name',...  % Initial label on button
              'Position',[200 140 160 20],... % Position in pixel units
              'Callback','MTPETrim(''getfilename'')',... % What clicking on the button does
              'Tag','FileName');              % Control name
    uicontrol('Style','Text',...
              'String','Specify Input File name (without numbers, or extension)',...
              'Position',[200 160 160 30],...
              'Tag','FileName_Label');
          
% And a drop down menu to get the extension.
    uicontrol('Style','Popupmenu',...
              'String','jpg|jpeg|tif|tiff|gif|bmp|Other',...
              'Position',[200 90 100 20],...
              'Tag','FileExt');
    uicontrol('Style','Text',...              % Boring text box
              'String','Specify Input Extension',...
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
              'Callback','MTPETrim(''getoutfilepath'')',... % What clicking on the button does
              'Tag','OutFilePath');              % Control name
    uicontrol('Style','Text',...              % Boring text box
              'String','Select Output File Path',...
              'Position',[380 220 160 20],...
              'Tag','OutFilePath_Label');
          
% One to get the filename without extension.
    uicontrol('Style','PushButton',...
              'String','Specify File Name',...  % Initial label on button
              'Position',[380 140 160 20],... % Position in pixel units
              'Callback','MTPETrim(''getoutfilename'')',... % What clicking on the button does
              'Tag','OutFileName');              % Control name
    uicontrol('Style','Text',...
              'String','Specify Output File name (without numbers, or extension)',...
              'Position',[380 160 160 30],...
              'Tag','OutFileName_Label');
          
% And a drop down menu to get the extension.
    uicontrol('Style','Popupmenu',...
              'String','tif|tiff|gif|bmp|jpg|jpeg|Other',...
              'Position',[380 90 100 20],...
              'Tag','OutFileExt');
    uicontrol('Style','Text',...              % Boring text box
              'String','Specify Output Extension',...
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
          
          
% The variable inputs
%====================
%dx
    uicontrol('Style','Edit',...
              'min',2,...
              'max',3,...
              'String','0',...
              'Position',[45 130 50 20],...
              'Tag','dxdist');
    uicontrol('Style','Text',...
              'String','dx = ',...
              'Position',[20 130 25 20],...
              'Tag','dx_Label');
%dy
    uicontrol('Style','Edit',...
              'min',2,...
              'max',3,...
              'String','0',...
              'Position',[45 110 50 20],...
              'Tag','dydist');
    uicontrol('Style','Text',...
              'String','dy = ',...
              'Position',[20 110 25 20],...
              'Tag','dy_Label');
%OR

    uicontrol('Style','Text',...
              'String','OR',...
              'Position',[115 130 50 20],...
              'Tag','dia_Label');
%dia
    uicontrol('Style','Edit',...
              'min',2,...
              'max',3,...
              'String','0',...
              'Position',[130 110 50 20],...
              'Tag','diadist');
    uicontrol('Style','Text',...
              'String','dia = ',...
              'Position',[105 110 25 20],...
              'Tag','dia_Label');

% A reference image for showing one how to crop.
    uicontrol('Style','Text',...
              'String','Reference Image:',...
              'Position',[90 390 150 20]);
    insimg;
          
          
%%%%% START, HELP AND ABOUT
% The start pushbutton
    uicontrol('Style','PushButton',...
              'String','Start',...  % Initial label on button
              'Position',[90 40 90 40],... % Position in pixel units
              'Callback','MTPETrim(''start'')',... % What clicking on the button does
              'Tag','MainControl');              % Control name
% A Help pushbutton and dialouge
    uicontrol('Style','PushButton',...
              'String','Help',...  % Initial label on button
              'Position',[10 40 60 40],... % Position in pixel units
              'Callback','MTPETrim(''help'')',... % What clicking on the button does
              'Tag','HelpButton');              % Control name
% An about dialouge
    uicontrol('Style','PushButton',...
              'String','About',...
              'Position',[10 1 50 15],...
              'Callback','MTPETrim(''about'')',... % give our about message
              'Tag','AboutButton');
% A reset button if you really get messed up
    uicontrol('Style','PushButton',...
              'String','Reset',...
              'Position',[70 1 50 15],...
              'Callback','MTPETrim(''clear'')',... % give our about message
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
    cdx = findobj(gcf,'Tag','dxdist');
    cdy = findobj(gcf,'Tag','dydist');
    cdia = findobj(gcf,'Tag','diadist');
    %%THE BIG IMPORTANT BUTTON
    ct = findobj(gcf,'Tag','MainControl');
    
    %Do some checkst to make sure that the user didn't leave a field blank.
    if strcmp(get(fp,'String'),'Select File Path')
        filepath = inputdlg('Filepath?','Specify the path to the images',1);
        set(fp,'String',filepath)
    end
    if strcmp(get(fn,'String'),'Specify File Name')
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
    if strcmp(get(ofn,'String'),'Specify File Name')
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
    offset=str2double(get(os,'String'));  % The offset on the number
    if isnan(offset)  %Give an error and reset if the user input anything other than a number
        errordlg('You must enter a numeric value for the number of images offset that the conversion should start at','Bad Input','modal')
        set(ct,'String','Start Conversion')  %reset
    end
    if offset<0      %Likewise, we can't take negatives or zeros for the number of images
        errordlg('You must enter a positive or zero value for the number of images offset that the conversion should start at','Bad Input','modal')
        set(ct,'String','Start Conversion')  %reset
    end
    %CHECK THE IMAGE SIZE
    dx=str2double(get(cdx,'String'));  % The x we want to crop off
    if isnan(dx)  %Give an error and reset if the user input anything other than a number
        errordlg('You must enter a numeric value for the horizontal number of pixels to trim','Bad Input','modal')
        set(ct,'String','Start Conversion')  %reset
    end
    if dx<0      %Likewise, we can't take negatives or zeros for the number of images
        errordlg('You must enter a positive value for the horizontal number of pixels to trim','Bad Input','modal')
        set(ct,'String','Start Conversion')  %reset
    end
    dy=str2double(get(cdy,'String'));  % The y we want to crop off
    if isnan(dy)  %Give an error and reset if the user input anything other than a number
        errordlg('You must enter a numeric value for the vertical number of pixels to trim','Bad Input','modal')
        set(ct,'String','Start Conversion')  %reset
    end
    if dy<0      %Likewise, we can't take negatives or zeros for the number of images
        errordlg('You must enter a positive value for the vertical number of pixels to trim','Bad Input','modal')
        set(ct,'String','Start Conversion')  %reset
    end
    dia=str2double(get(cdia,'String'));  % The diameter we want to keep
    if isnan(dia)  %Give an error and reset if the user input anything other than a number
        errordlg('You must enter a numeric value for the diameter of the image to keep','Bad Input','modal')
        set(ct,'String','Start Conversion')  %reset
    end
    if dia<0      %Likewise, we can't take negatives or zeros for the number of images
        errordlg('You must enter a positive value for the diameter of the image to keep','Bad Input','modal')
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
            fmt = inputdlg('input the extension with the . prefix; eg .gif','User Specified Extension',1);
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
            ofmt = inputdlg('input the extension with the . prefix; eg .gif','User Specified Extension',1);
    end
    
    %%==================================================
    %% With the checks out of the way, let's get down to business
    %%==================================================
    %NOTE TO SELF: Write
    %  results as a tiff and
    %  convert later, the jpg
    %  encoder in matlab
    %  sucks major @55.
    %%Begin to do the transform.
    set(ct,'String','Stop');
    itc = 0;                                % Start the counter
    while itc < num & strcmp(get(ct,'String'),'Stop')
        %%FILE SELECTION STUFF -- DON"T TREAD ON ME
        [path,outpath]=getFilePath(num,offset,itc,filepath,filename,fmt,outfilepath,outfilename,ofmt);
        
        image=imread(path);                 % Open the image
        [row,col,z]=size(image);            % Get the PROPER size of the image
        % Do the trim
        if dia==0 %use dx and dy to figure the cropsize
            cropsize = [dx+1,dy+1,(col-2*dx)-1,(row-2*dy)-1];  %The +\-1 takes into account matlab's wish to take the half pixel
        else %use dia to figure the crop size
            cropsize = [((col-dia)/2+1),((row-dia)/2+1),dia-1,dia-1];  %The +\-1 takes into account matlab's wish to take the half pixel
        end
        %newimage = image;
        %Reference array; [60 40 100 90]
        newimage = imcrop(image,cropsize);
        imwrite(newimage,outpath);          % Write the output
        itc = itc+1;                        % Increase the counter
    end
    %We're done converting reset this button back to initial conditions
    set(ct,'String','Start');
elseif strcmp(action,'help')  %display a help box indicating where the user can go to get some help
    msgbox('Please consult the users manual at http://www.owlnet.rice.edu/~kec4482/mtpe/MTPETrimGuide.pdf','Additional resources')
    
elseif strcmp(action,'about')  %display a little about box, it's really totally worthless, but I thought it was fun.
                               % for some reason the cariage return \n
                               % wasn't working in this case so I just put
                               % in a whole bunch of spaces to get it to
                               % display properly, it seems to have worked
    msgbox('MTPE Trimming program | Version 1.0                                      Designed by Kevin Claytor in 2006 for MPTE                                   For results and more examples see: http://www.owlnet.rice.edu/~kec4482/','About MTPE Warp - V 1.0')
elseif strcmp(action,'clear')  %The user screwed up somewhere or wanted to start over clear everything and let's have a go at it again.
    fp = findobj(gcf,'Tag','FilePath');
    fn = findobj(gcf,'Tag','FileName');
    ofp = findobj(gcf,'Tag','OutFilePath');
    ofn = findobj(gcf,'Tag','OutFileName');
    ni = findobj(gcf,'Tag','NumImages');
    ct = findobj(gcf,'Tag','MainControl');
    set(ct,'String','Start');
    set(fp,'String','Select File Path');
    set(fn,'String','Sepecify File Name');
    set(ofp,'String','Select File Path');
    set(ofn,'String','Sepecify File Name');
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

%% A function that plots our demo image so peeps don't get confused
function insimg()
instruc=imread('\trimdemo.jpg');
subplot(2,2,1)
imshow(instruc)
title='Before conversion';
axis off

drawnow

return