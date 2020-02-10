function varargout = RNAColoc(varargin)
%RNACOLOC MATLAB code file for RNAColoc.fig
%      RNACOLOC, by itself, creates a new RNACOLOC or raises the existing
%      singleton*.
%
%      H = RNACOLOC returns the handle to a new RNACOLOC or the handle to
%      the existing singleton*.
%
%      RNACOLOC('Property','Value',...) creates a new RNACOLOC using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to RNAColoc_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      RNACOLOC('CALLBACK') and RNACOLOC('CALLBACK',hObject,...) call the
%      local function named CALLBACK in RNACOLOC.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RNAColoc

% Last Modified by GUIDE v2.5 10-Nov-2016 13:56:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RNAColoc_OpeningFcn, ...
                   'gui_OutputFcn',  @RNAColoc_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before RNAColoc is made visible.
function RNAColoc_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for RNAColoc
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RNAColoc wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = RNAColoc_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg('Are you sure you want to close this program?',...
    'Close Request','Yes','No','Yes');
switch selection
    case 'Yes',
        close all;
    case 'No'
        return
end %switch



% --- Executes on button press in ok.
function ok_Callback(hObject, eventdata, handles)
% hObject    handle to ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)hold off;
threshold= -1;
k= 0.2;
mrna5file= (get(handles.mrna5, 'String'));
mrna3file= (get(handles.mrna3, 'String'));
midmrnafile= (get(handles.mrnamid, 'String'));
pix_size= str2double(get(handles.pixelsize, 'String'));
radius_size= str2double(get(handles.radius, 'String'));

if(strcmp(mrna5file, '5 mRNA loc file'))
    mrna5file='';
end

if(strcmp(mrna3file, '3 mRNA loc file'))
    mrna3file='';
end

if(strcmp(midmrnafile, 'mid mRNA loc file'))
    midmrnafile='';
end

mask = (get(handles.mask, 'String'));


RNA_coloc(mask,mrna3file,midmrnafile, mrna5file,k, threshold, pix_size, radius_size);




function mask_Callback(hObject, eventdata, handles)
% hObject    handle to mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mask as text
%        str2double(get(hObject,'String')) returns contents of mask as a double


% --- Executes during object creation, after setting all properties.
function mask_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mrna5_Callback(hObject, eventdata, handles)
% hObject    handle to mrna5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mrna5 as text
%        str2double(get(hObject,'String')) returns contents of mrna5 as a double


% --- Executes during object creation, after setting all properties.
function mrna5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mrna5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mrnamid_Callback(hObject, eventdata, handles)
% hObject    handle to mrnamid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mrnamid as text
%        str2double(get(hObject,'String')) returns contents of mrnamid as a double


% --- Executes during object creation, after setting all properties.
function mrnamid_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mrnamid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browse1.
function browse1_Callback(hObject, eventdata, handles)
% hObject    handle to browse1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, pathname]= uigetfile({'*.tif;*.tiff','Microscopy image file'; '*.*','All (*.*)'}, 'Pick the mask file');
mask= fullfile(pathname, file);
set(handles.mask, 'String', mask);
i=imread(mask);
imshow(i, []);



% --- Executes on button press in browse2.
function browse2_Callback(hObject, eventdata, handles)
% hObject    handle to browse2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, pathname]= uigetfile({'*.loc','Localize file (.loc)'; '*.*','All (*.*)'}, 'Pick the mRNA file');
mrna5= fullfile(pathname, file);
set(handles.mrna5, 'String', mrna5);
m5=load(mrna5);

[min_int, min_ind] =min(m5(:,3));
[max_int, max_ind] =max(m5(:,3));

binranges = min_int:500:max_int+100;
[bincounts] = histc(m5(:,3),binranges);
bar(binranges,bincounts,'r');


% --- Executes on button press in browse3.
function browse3_Callback(hObject, eventdata, handles)
% hObject    handle to browse3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, pathname]= uigetfile({'*.loc','Localize file (.loc)'; '*.*','All (*.*)'}, 'Pick the s-eRNA file');
mrna3= fullfile(pathname, file);
set(handles.mrna3, 'String', mrna3);
m3=load(mrna3);
[min_int, min_ind] =min(m3(:,3));
[max_int, max_ind] =max(m3(:,3));
binranges = min_int:100:max_int;
[bincounts] = histc(m3(:,3),binranges);
bar(binranges,bincounts,'b');



% --- Executes on button press in browse4.
function browse4_Callback(hObject, eventdata, handles)
% hObject    handle to browse4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, pathname]= uigetfile({'*.loc','Localize file (.loc)'; '*.*','All (*.*)'}, 'Pick the as-eRNA file');
mrnamid= fullfile(pathname, file);
set(handles.mrnamid, 'String', mrnamid);
mid=load(mrnamid);
[min_int, min_ind] =min(mid(:,3));
[max_int, max_ind] =max(mid(:,3));
binranges = min_int:100:max_int+100;
[bincounts] = histc(mid(:,3),binranges);
bar(binranges,bincounts, 'g');


% --- Executes on selection change in mrna3channel.
function mrna3channel_Callback(hObject, eventdata, handles)
% hObject    handle to mrna3channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns mrna3channel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from mrna3channel


% --- Executes during object creation, after setting all properties.
function mrna3channel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mrna3channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in mrnamidchannel.
function mrnamidchannel_Callback(hObject, eventdata, handles)
% hObject    handle to mrnamidchannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns mrnamidchannel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from mrnamidchannel


% --- Executes during object creation, after setting all properties.
function mrnamidchannel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mrnamidchannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in mrna5channel.
function mrna5channel_Callback(hObject, eventdata, handles)
% hObject    handle to mrna5channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns mrna5channel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from mrna5channel


% --- Executes during object creation, after setting all properties.
function mrna5channel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mrna5channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function refdata_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in refdata 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'mrna5ref '
        handles.ref=1;
    case 'mrna3ref'
        handles.ref=2;
    case 'mrnamidref'
        handles.ref=3;
end
guidata(hObject, handles);

function pixelsize_Callback(hObject, eventdata, handles)
% hObject    handle to pixelsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pixelsize as text
%        str2double(get(hObject,'String')) returns contents of pixelsize as a double


% --- Executes during object creation, after setting all properties.
function pixelsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pixelsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mrna3_Callback(hObject, eventdata, handles)
% hObject    handle to mrna3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mrna3 as text
%        str2double(get(hObject,'String')) returns contents of mrna3 as a double


% --- Executes during object creation, after setting all properties.
function mrna3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mrna3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function radius_Callback(hObject, eventdata, handles)
% hObject    handle to radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of radius as text
%        str2double(get(hObject,'String')) returns contents of radius as a double


% --- Executes during object creation, after setting all properties.
function radius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
