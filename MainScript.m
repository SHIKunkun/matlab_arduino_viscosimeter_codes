clc;
clear all;
%%
% Save the serial port name in comPort variable.
delete(instrfindall);
freq =30; %freq=input('Please input your sampling frequency: ');
buf_len =100;
%% Setup serial port object
arduino=setupSerial();
%% create a figure object

h1 = figure(1);
set(h1,'UserData',1,...
    'Visible','on',...
    'name','control panel',...
    'Color',[1 1 1],...
    'Resize','on',...
    'Position',[200 100 1050 500],...
    'menubar','none'); %set the visibility on 'off' of the default figure menubar

movegui(h1,'center');
set(0,'Defaultuicontrolfontsize',10);
%% Create all the components of GUI
%UserData
%3 RX togglebutton
%4 speed  Editable text
%5 result   Editable text
%6
%7 line 1
%8 line 2
%9 variance Editable text

hp = uipanel('Title','Main Panel',... %uipanel object
    'FontSize',12,...
    'BackgroundColor','white',...
    'Position',[.5 .175 .45 .725],...
    'parent',h1,...
    'BorderWidth',2,...
    'Title','Control panel');

hm1 = uimenu('label','file'); %uimenu object

hm2 = uimenu('label','help');

uimenu( hm1,'label','New file',...
    'Accelerator','N',...
    'Callback',@create_Excel);

uimenu(hm1,'label','save as...',...
    'Accelerator','S',...
    'Callback',@save_file);

uimenu(hm2,'label','User Guide',...
    'Accelerator','H',...
    'Callback',@readme_callback)

Autorun = uicontrol('Style','radiobutton',...
    'String','Auto',...
    'Callback',{@auto_manipulations,arduino,buf_len,freq},...
    'Units','normalized',...
    'Position',[0.4 0.85 0.15 0.08],...
    'BackgroundColor','w',...
    'ForegroundColor',[0 0 0],...
    'parent',hp);

Quit = uicontrol('Style','pushbutton',...
    'String','Quit',...
    'Callback','fclose(arduino), delete(arduino), close gcf ',...
    'Units','normalized',...
    'Position',[0.8 0.85 0.15 0.08],...
    'BackgroundColor',[0.8 0 0],...
    'ForegroundColor',[1 1 1],...
    'parent',hp);

material_type = uicontrol('Style','popup',...
    'String',{'low viscosity material','high viscosity material'},...
    'Units','normalized',...
    'Position',[0.4 0.6 0.3 0.09],...
    'UserData',10,...
    'parent',hp);

initial_value = uicontrol('Style','Edit',...
    'Units','normalized',...
    'UserData',11,...
    'Position',[0.55 0.5 0.15 0.09],...
    'String','0',...
    'parent',hp);

text_initial_value = uicontrol('Style','text',...
    'Units','normalized',...
    'Position',[0.4 0.5 0.15 0.09],...
    'String','Initial Value',...
    'FontWeight','normal',...
    'parent',hp);

speed = uicontrol('Style','Edit',...
    'Units','normalized',...
    'Position',[0.55 0.4 0.15 0.09],...
    'UserData',4,... %Its 'UserData' property is very necessary here....
    'String','30','FontWeight','bold',...
    'parent',hp);

text_speed = uicontrol('Style','text',...
    'Units','normalized',...
    'Position',[0.4 0.4 0.15 0.09],...
    'String','Speed/rpm',...
    'FontWeight','normal',...
    'parent',hp);


result = uicontrol('Style','Edit',...
    'Units','normalized',...
    'Position',[0.55 0.3 0.15 0.09],...
    'UserData',5,...
    'ForegroundColor','b','FontWeight','bold','FontSize',14,...
    'parent',hp);

text_result = uicontrol('Style','text',...
    'Units','normalized',...
    'Position',[0.4 0.3 0.15 0.09],...
    'String','Viscosity',...
    'FontWeight','normal',...
    'parent',hp);

variance = uicontrol('Style','Edit',...
    'Units','normalized',...
    'Position',[0.55 0.2 0.15 0.09],...
    'ForegroundColor','b','FontWeight','normal',...
    'UserData',9,...
    'parent',hp);

text_variance = uicontrol('Style','text',...
    'Units','normalized',...
    'Position',[0.4 0.2 0.15 0.09],...
    'String','Variance','FontWeight','normal',...
    'parent',hp);

RX = uicontrol('Style','togglebutton',...
    'String','RX',...
    'Userdata',3,...
    'Units','normalized',...
    'Position',[0.8 0.6 0.15 0.09],...
    'BackgroundColor',[0.5 0 0.5],'ForegroundColor',[1 1 1],...
    'parent',hp);

h_uc_Save = uicontextmenu;
uimenu(h_uc_Save,'label','save the data');
Save = uicontrol('Style','pushbutton',...
    'String','Save',...
    'Callback',@save_data,...
    'Units','normalized',...
    'Position',[0.8 0.47 0.15 0.09],...
    'BackgroundColor',[0 0 0.8],'ForegroundColor',[1 1 1],...
    'uicontextmenu',h_uc_Save,...
    'parent',hp);

h_uc_Delete = uicontextmenu;
uimenu(h_uc_Delete,'label','delete last input');
Delete = uicontrol('Style','pushbutton',...
    'String','Delete',...
    'Callback',@delete_data,...
    'Units','normalized',...
    'Position',[0.8 0.33 0.15 0.09],...
    'BackgroundColor',[0 0 0.8],'ForegroundColor',[1 1 1],...
    'uicontextmenu',h_uc_Delete,...
    'parent',hp);

Plot=uicontrol('Style','pushbutton',...
    'String','Plot',...
    'Callback',@linear_regression,...
    'Units','normalized',...
    'Position',[0.8 0.2 0.15 0.09],...
    'BackgroundColor',[0 0 0.8],'ForegroundColor',[1 1 1],...
    'parent',hp);

inplace = uicontrol('Style','pushbutton',...
    'String','inplace',...
    'Units','normalized',...
    'Position',[0.05 0.6 0.12 0.09],...
    'BackgroundColor',[0 0 0],...
    'ForegroundColor',[1 1 1],...
    'Callback','if ~RX.Value, fprintf(arduino,''%s\r'',''j''); fprintf(arduino,''%s'',''f'' );end',...
    'parent',hp);

Adjust = uicontrol('Style','pushbutton',...
    'String','adjust',...
    'Units','normalized',...
    'Position',[0.05 0.5 0.12 0.09],...
    'BackgroundColor',[0 0 0],...
    'ForegroundColor',[1 1 1],...
    'Callback','if ~RX.Value, fprintf(arduino,''%s\r'',''a'');end',...
    'parent',hp);

up = uicontrol('Style','pushbutton',...
    'String','up',...
    'Units','normalized',...
    'Position',[0.05 0.4 0.12 0.09],...
    'BackgroundColor',[0 0 0],...
    'ForegroundColor',[1 1 1],...
    'Callback','if ~RX.Value, fprintf(arduino,''%s\r'',''u'');fprintf(arduino,''%s'',speed.String);end',...
    'parent',hp);

down = uicontrol('Style','pushbutton',...
    'String','down',...
    'Units','normalized',...
    'Position',[0.05 0.3 0.12 0.09],...
    'BackgroundColor',[0 0 0],...
    'ForegroundColor',[1 1 1],...
    'Callback','if ~RX.Value, fprintf(arduino,''%s\r'',''i'' );fprintf(arduino,''%s'',speed.String);end',...
    'parent',hp);

rotate = uicontrol('Style','pushbutton',...
    'String','rotate',...
    'Units','normalized',...
    'Position',[0.05 0.2 0.12 0.09],...
    'BackgroundColor',[0 0 0],'ForegroundColor',[1 1 1],...
    'Callback',' if ~RX.Value, fprintf(arduino,''%s\r'',''p'' );fprintf(arduino,''%s'',speed.String);end',...
    'parent',hp);

stop = uicontrol('Style','pushbutton',...
    'String','STOP',...
    'Units','normalized',...
    'Position',[0.2 0.385 0.095 0.12],...
    'BackgroundColor',[1 0 0],'ForegroundColor',[1 1 1],...
    'Callback',' if ~RX.Value, fprintf(arduino,''%s'',''m'' );end',...
    'parent',hp);

%% Axis and lines objects

if(~exist('myAxes','var'))
    
    index = 1: buf_len;
    zeroIndex = zeros(size(index));
    
    tc_data = zeroIndex; % Pre-allocation
    viscosity_data=zeros(1,buf_len);
    
    myAxes = axes('Xlim',[0 buf_len],'parent',h1,...
        'OuterPosition',[0 0.1 0.5 0.8]);
    title('Real Time Data from Rheologymeter','Fontsize',14);
    
    grid on;
    
    line_1 = line(index,[tc_data;zeroIndex],'Color','r', 'parent',myAxes,'UserData',7);
    
    line_2 = line(index,[tc_data;zeroIndex],'Color','b', 'parent',myAxes,'UserData',8);
    
    drawnow;
end
%% We do all the satffs here
a=RX.Value;
arduino.ReadAsyncMode='continuous';
%readasync(arduino);

try % no error message appear when close gcf
    
    while 1
        
        b=RX.Value;
        if a>b
            fprintf(arduino,'%s','x');
            flushinput(arduino); %Clear input buffer
            set(RX,'String','RX off','BackgroundColor','r');
        elseif a<b
            fprintf(arduino,'%s','d');
            set(RX,'String','RX on','BackgroundColor','g');
        end
        a=b;
        
        speedval=str2double(speed.String);
        m=round(60.*freq./speedval); %When sampling frequency is freq, we get 'm' as the amount of data in one
        %mechanical vibration period
        
        while (RX.Value == 1 ) % Start to read data from serial port
            
            tc = str2double(fgetl(arduino))-str2double(initial_value.String);
            
            [tc_data,viscosity,viscosity_data,var_visco]=updateplot(tc,tc_data,viscosity_data,m,buf_len);
            
            %Can it improve the performance of codes?
            
            set(line_1,'Ydata',tc_data);
            
            set(line_2,'Ydata',viscosity_data);
            
            set(result,'String',num2str(viscosity));
            
            set(variance,'String',num2str(var_visco));
            
            drawnow; % update line 20 times per second
            
        end
        
        pause(0.001)
        
    end
    
end
%% Clean up the serial port and object
% I add fclose(arduino) order to the Callback property of QUIT button.