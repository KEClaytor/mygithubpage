%Function pmDensity
% Kevin Claytor
% LANL EES-GEO
% May 18, 2007
%
% pmDensity.m
% Usage
%    pmDensity(PMspace,'name')
%
% A helper function to PMPro that plots the density of points in grayscale
%    for easier viewing.  It can also be used stand-alone to get the same
%    figure out, but send it the PMspace (eg; myPM).  The variable name
%    appears in the title for easier viewing post processing.
%
% Additional Resources
%   LANL
%     http://www.lanl.gov/
%   For examples, results, and troubleshooting;
%     http://www.owlnet.rice.edu/~kec4482/
%

% Glossary:
%   Global vars:
%   myPM - the result of generatePMspace
%   newPM - a rounded version of myPM
%   size - the integer of MPa that we go to - hence the size of the density
%           matrix.
%   density - the number of HEU's in a given bin
%   ratio - the ratio used to scale density from arbitray units to relative
%           proportions
%   denstiy255 - the relative proportions of elements in each division and
%           displayed for a 255 grayscale / color graph
%

function pmDensity(myPM,name)
if nargin < 2
    name=[''];      %Provide noname if none is provided
    if nargin<1     %If we're not provided a PMspace, just draw from the saved one
        load PMspace
    end
end
%Get our PMspace data out
newPM(:,1:2) = myPM(:,1:2);
%get the absolute maximum that the matrix size needs to be
size = max(ceil(max(newPM)));
%and build a matrix of that size
density = zeros(size);
%floor everything - we don't need decimals and we don't want anything above
%the diagonal
newPM = floor(newPM);
%find out where the elements fall and add one to that space
for k=1:length(newPM)
    %the closing pressure is column 1
    %the opening pressure is column 2
    row = newPM(k,2);
    col = newPM(k,1);
    if row==0
        row = 1;
    end
    if col==0
        col=1;
    end
    density(row,col) = density(row,col) + 1;
end

%Now we conform to matlab's silly scheme where 0 is black (high density) and 255 is white (our low density)
ratio = 255/max(max(density));  %scale factor
density255 = ones(size)*255;
density255 = density255-(ratio*density);    %255 - rescaled
%display
figure
imagesc(density255)
colormap(gray)
set(0,'defaultAxesFontSize',24)
colorbar('horiz');
axis xy;            %orient away from matrix axis and into cartesian
%FOR good printing use fontsize = 18, title fontsize = 22
%set(gca,'FontSize',20)  %How big do we want the font to be - legible in publication
axis square
set(gcf,'Position',[234 36 560 650])        %and where / how large should the pic be on the screen
set(gcf,'PaperPosition',[0.25 2.5 8 10.5])    %and where / how large it should be when we print
xlabel('Closing Pressure (MPa)')
ylabel('Opening Pressure (MPa)')
if strcmp(name,'')  %for no title     PS, Make the font a bit larger
    title(['PM Space Density with ',num2str(length(newPM)),' Elements'],'FontSize',28)
else                %we want a title
    %x=['PM Space Density for ',name,' with ',num2str(length(newPM)),' Elements'];
    %header=sprintf(x);
    x=['PM Space Density for ',name];
    y=['    with ',num2str(length(myPM)),' Elements     '];
    header={x;y};
    title(header,'FontSize',28)
end
colormapeditor
%This command will bring up the colormap editor which is useful for highly
%    skewed distributions