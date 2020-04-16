% This Matlab file is a simple example on how to download Covid19 Data 
% from the Web. In particular, the deaths cases (global) corresponding 
% to the Covid19 Data Repository by Johns Hopkins CSSE at GitHub 
% (https://github.com/CSSEGISandData/COVID-19). 
% See https://arxiv.org/abs/2004.06111 for other data sets 
% and Open Data Resources to Fight Covid19 (arxiv review paper) . 
% 
% By Teodoro Alamo and Jose Luis Guzman (members of CONCO-TEAM)
% 
% If we have already downloaded the recent data from the GitHub reposiroty 
% and saved them into a mat file we could load directly the mat file
% (much faster). If not, we have to answer '1' to the following question.

Download=input('Download Data from JHU-CSSE GitHub Repository (1/0)? ');

if (Download)
    URL='https://github.com/CSSEGISandData/COVID-19/'
    Folder='raw/master/csse_covid_19_data/csse_covid_19_time_series/';   
    FileName_Deaths='time_series_covid19_deaths_global.csv';
    
    Deaths_CSV=webread([URL,Folder,FileName_Deaths]);
    Deaths_Raw=Csv_to_Cell_Array(Deaths_CSV);
    save('Deaths_Raw_Data_from_GitHub','Deaths_Raw');
    disp('Covid Data downloaded from JHU-CSSE GitHub and saved locally.');   
else
    load('Deaths_Raw_Data_from_GitHub');
    disp('Covid19 Data loaded from a local mat file.')
end

% The available countries can be displayed with the next commented command
% unique(Deaths_Raw(:,2))

% Select Countries for display:
Countries=[{'Spain'},{'Italy'},{'France'},{'US'},{'Germany'},{'United Kingdom'}];

N_Countries=length(Countries);

N_Days=size(Deaths_Raw,2)-4; %The first day starts in the 5th column.
D_mat=nan(N_Countries,N_Days); % Matrix with all the Deaths.

for kk=1:N_Countries
   Is_Country=strcmp(Countries{kk},Deaths_Raw(:,2));
   Index_Country=find(Is_Country==1);
   Deaths_Raw(Index_Country,1:2)
   for jj=1:length(Index_Country)%Some countries have several regions(rows)
       Deaths=str2num(char(Deaths_Raw(Index_Country(jj),5:end)));
       if (jj==1)
           D_mat(kk,:)=Deaths';
       else
           D_mat(kk,:)=D_mat(kk,:)+Deaths';
       end
   end
end

close all
for kk=1:N_Countries
    subplot(2,1,1);
    semilogy(D_mat(kk,:))
    hold on; 
    subplot(2,1,2);
    set_diff=D_mat(kk,2:end)-D_mat(kk,1:end-1);
    plot(set_diff)
    hold on;
end
subplot(2,1,1);
grid
xlabel('Days')
ylabel('Accumulative Deaths Covid-19');
title('Accumulative Deaths Covid-19 (logarithmic scale)');
legend(Countries)
subplot(2,1,2);
grid
xlabel('Days')
ylabel('Daily Covid-19 Deaths');
title('New Covid-19 Deaths (lineal scale)');
legend(Countries)


% The following function converts the csv files from JHU 
% into an array of cells.

function Cell_Array=Csv_to_Cell_Array(CSV_Raw)

% We compute the number of lines counting the number of Line Feed characters
% in the vector of characters (ascii 10)

N_Rows=length(find(abs(CSV_Raw)==10));

% Computation of number of columns
N_Columns=1;
kk=1;
while(abs(CSV_Raw(kk))~=10)
    if (CSV_Raw(kk)==',')
        N_Columns=N_Columns+1;
    end
    kk=kk+1;
end

Cell_Array=cell(N_Rows,N_Columns);
Column=1; Row=1; Text='';
Literal=false;

for kk=1:length(CSV_Raw)
    c=CSV_Raw(kk);
    if c=='"'
        Literal=~Literal;
    end
    if (~Literal)&&((abs(c)==10)||(c==',')) 
        Cell_Array{Row,Column}=Text;
        Text='';
        if (c==',')
            Column=Column+1;
        else
            Row=Row+1;
            Column=1;
        end
    else
        if (abs(c)~=13) % Discard Return character 
            Text=[Text,c];
        end
    end
end

end
