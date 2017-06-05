function delete_data(hObject,eventdata)
%you can delete your last input in Excel

excel = actxserver('Excel.Application');
%excel.Visible=1;

h1= findobj('label','New file');
    
    if ~isempty(h1.UserData);
        str1=pwd;
        str2 = char(h1.UserData);
        str=[str1,'\',str2];
    else
        mbox = msgbox('Sorry, we can''t decide which file to open. Maybe you can help us! ');
        uiwait(mbox);
        [Filename,Pathname]=uigetfile({'*.xls';'*.xlsx'},'Ñ¡ÔñÎÄ¼þ');
        str=[Pathname,Filename];
    end

file = excel.Workbooks.Open(str);

sheet1=excel.Worksheets.get('Item', 'Sheet1');

[previous_size,~]=size(xlsread(str));
n=previous_size;
StartCell=['A',num2str(n)];
EndCell = ['B',num2str(n)];    
range1=get(sheet1,'Range', StartCell,EndCell);

range1.Value=[];

file.Save;
file.Close;

delete_data(excel);

end