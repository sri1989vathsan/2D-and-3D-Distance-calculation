function varargout = RNAColoc(varargin)
% RNACOLOC MATLAB code for RNAColoc.fig
%      RNACOLOC, by itself, creates a new RNACOLOC or raises the existing
%      singleton*.
%
%      H = RNACOLOC returns the handle to a new RNACOLOC or the handle to
%      the existing singleton*.
%
%      RNACOLOC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RNACOLOC.M with the given input arguments.
%
%      RNACOLOC('Property','Value',...) creates a new RNACOLOC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RNAColoc_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RNAColoc_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RNAColoc

% Last Modified by GUIDE v2.5 19-Jul-2016 17:53:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RNAColoc_OpeningFcn, ...
                   'gui_OutputFcn',  @RNAColoc_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
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
% varargin   command line arguments to RNAColoc (see VARARGIN)

% Choose default command line output for RNAColoc
handles.output = hObject;
handles.pathname='';
handles.ref=1;
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
% handles    structure with handles and user data (see GUIDATA)
hold off;
% threshold= (str2double(get(handles.edit9, 'String')));
% k= (str2double(get(handles.coeff, 'String')));
k=0;
threshold=-1;
mrna5file= (get(handles.mrna5, 'String'));
mrna3file= (get(handles.mrna3, 'String'));
mrnamidfile= (get(handles.mid, 'String'));
pix_size= str2double(get(handles.convert, 'String'));

if(strcmp(mrnamidfile, 'Anti-Sens eRNA loc file'))
    mrnamidfile='';
end

if(strcmp(mrna5file, 'mRNA loc file'))
    mrna5file='';
end

if(strcmp(mrna3file, 'Sens eRNA loc file'))
    mrna3file='';
end

mask = (get(handles.mask, 'String'));
% correction= get(handles.correctshift, 'Value')==get(handles.correctshift, 'Max');
% intronsig = get(handles.intron, 'Value') ==get(handles.intron, 'Max');
% label = get(handles.number, 'Value')==get(handles.number, 'Max');

% if(correction)
%     
%     disp('**RNAColoc with correction**');
%     filenames = unique(cellstr(get(handles.shift_list, 'String')));
%     %disp('debug')
%     type_list= get(handles.mrna5channel, 'String');
%     mrna_type= type_list{get(handles.mrna5channel, 'Value')};
%     serna_type= type_list{get(handles.mrna3channel, 'Value')};
%     aserna_type= type_list{get(handles.mrnamidchannel, 'Value')};
%     if(handles.ref==1)
%         s_ernacorrfile= get_Corr_File(filenames, mrna_type, serna_type, handles.pathname, mrna3file);
%         as_ernacorrfile=get_Corr_File(filenames, mrna_type, aserna_type, handles.pathname, mrnamidfile);
%         RNA_coloc(mask, s_ernacorrfile, as_ernacorrfile, mrna5file, k, threshold, pix_size,intronsig, 'Corr_', label);
%         
%     elseif(handles.ref==2)
%         mrnacorrfile= get_Corr_File(filenames, serna_type, mrna_type, handles.pathname, mrna5file);
%         as_ernacorrfile=get_Corr_File(filenames, serna_type, aserna_type, handles.pathname, mrnamidfile);
%         RNA_coloc(mask, mrna3file, as_ernacorrfile, mrnacorrfile, k, threshold, pix_size,intronsig,'Corr_', label );
%     else
%         mrnacorrfile= get_Corr_File(filenames, aserna_type, mrna_type, handles.pathname, mrna5file);
%         s_ernacorrfile=get_Corr_File(filenames, aserna_type, serna_type, handles.pathname, mrna3file);
%         RNA_coloc(mask, s_ernacorrfile, mrnamidfile, mrnacorrfile, k, threshold, pix_size,intronsig,'Corr_', label);
%     end
% end

disp('**RNAColoc without correction**')
RNA_coloc(mask,mrna3file,mrnamidfile, mrna5file,threshold, pix_size, '');
%close all;


function corr_file=get_Corr_File(filenames, type1, type2,pathname, file_to_shift)
cellfind = @(string)(@(cell_contents)(nnz(strcmp(strsplit(cell_contents, {'_', '.shift'}), string))));
cont = (cellfun(cellfind(type1),filenames)) & (cellfun(cellfind(type2),filenames));
ind=find(cont);
if (isempty(file_to_shift))
    corr_file=file_to_shift; 
elseif length(ind)==1
    [sens, mean_shift]=read_shift(fullfile(pathname, filenames{ind}), type1);
    locdata= load(file_to_shift);
    corr_file=correct_shift(file_to_shift,mean_shift',locdata, sens,2);
else
    error('Shift file incorrect or not found');
end


function [sens, mean_shift]=read_shift(filename, type1)
fID= fopen(filename, 'r');
shift_type=fgetl(fID);   
shifts=strsplit(shift_type,'-');
sens=1;
if strcmp(type1, shifts{2})
      sens=0;
end
mean_shift = fscanf(fID, '%f');


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



function mid_Callback(hObject, eventdata, handles)
% hObject    handle to mid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mid as text
%        str2double(get(hObject,'String')) returns contents of mid as a double


% --- Executes during object creation, after setting all properties.
function mid_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browse1.
function browse1_Callback(hObject, eventdata, handles)
% hObject    handle to browse1 (see GCBO)s
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, pathname]= uigetfile({'*.tif;*.tiff','Microscopy image file'; '*.*','All (*.*)'}, 'Pick the Nucleus mask file');
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
mrna= fullfile(pathname, file);
set(handles.mrna5, 'String', mrna);
m=load(mrna);

[min_int, min_ind] =min(m(:,3));
[max_int, max_ind] =max(m(:,3));

binranges = min_int:500:max_int+100;
[bincounts] = histc(m(:,3),binranges);
bar(binranges,bincounts,'r');


% --- Executes on button press in browse3.
function browse3_Callback(hObject, eventdata, handles)
% hObject    handle to browse3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, pathname]= uigetfile({'*.loc','Localize file (.loc)'; '*.*','All (*.*)'}, 'Pick the s-eRNA file');
srna= fullfile(pathname, file);
set(handles.mrna3, 'String', srna);
se=load(srna);
[min_int, min_ind] =min(se(:,3));
[max_int, max_ind] =max(se(:,3));
binranges = min_int:100:max_int;
[bincounts] = histc(se(:,3),binranges);
bar(binranges,bincounts,'b');


% --- Executes on button press in browse4.
function browse4_Callback(hObject, eventdata, handles)
% hObject    handle to browse4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, pathname]= uigetfile({'*.loc','Localize file (.loc)'; '*.*','All (*.*)'}, 'Pick the as-eRNA file');
asrna= fullfile(pathname, file);
set(handles.mid, 'String', asrna);
ase=load(asrna);
[min_int, min_ind] =min(ase(:,3));
[max_int, max_ind] =max(ase(:,3));
binranges = min_int:100:max_int+100;
[bincounts] = histc(ase(:,3),binranges);
bar(binranges,bincounts, 'g');



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


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
function midchannel_Callback(hObject, eventdata, handles)
% hObject    handle to mrnamidchannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns mrnamidchannel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from mrnamidchannel


% --- Executes during object creation, after setting all properties.
function midchannel_CreateFcn(hObject, eventdata, handles)
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




% --- Executes when selected object is changed in refdata.
function refdata_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in refdata 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'mrna5ref'
        handles.ref=1;
    case 'mrna3ref'
        handles.ref=2;
    case 'mrnamidref'
        handles.ref=3;
end
guidata(hObject, handles);



function convert_Callback(hObject, eventdata, handles)
% hObject    handle to convert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of convert as text
%        str2double(get(hObject,'String')) returns contents of convert as a double


% --- Executes during object creation, after setting all properties.
function convert_CreateFcn(hObject, eventdata, handles)
% hObject    handle to convert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in number.
function number_Callback(hObject, eventdata, handles)
% hObject    handle to number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of number



 function mrna5ref_Callback(hObject, eventdata, handles)
% hObject    handle to mrna5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mrna5 as text
%        str2double(get(hObject,'String')) returns contents of mrna5 as a double


% --- Executes during object creation, after setting all properties.
function mrna5ref_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mrna5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
