function varargout = bai2(varargin)
% BAI2 MATLAB code for bai2.fig
%      BAI2, by itself, creates a new BAI2 or raises the existing
%      singleton*.
%
%      H = BAI2 returns the handle to a new BAI2 or the handle to
%      the existing singleton*.
%
%      BAI2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BAI2.M with the given input arguments.
%
%      BAI2('Property','Value',...) creates a new BAI2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bai2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bai2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bai2

% Last Modified by GUIDE v2.5 17-Mar-2015 00:14:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bai2_OpeningFcn, ...
                   'gui_OutputFcn',  @bai2_OutputFcn, ...
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


% --- Executes just before bai2 is made visible.
function bai2_OpeningFcn(hObject, eventdata, handles, varargin)

[sig,Fs,nbits] = auread('start.au');
load handel.mat
sound(sig,Fs,nbits);
sizeinfo = auread('start.au','size');
t = [0:length(sig)-1]/Fs;
plot(handles.axesStart,t,sig);
xlabel('t');

% Choose default command line output for bai2
handles.output = hObject;
handles.Fs = Fs;
handles.nbits = nbits;
handles.sig = sig;
set(handles.txtFs,'String',Fs);
set(handles.txtNumberOfSample,'String',length(sig));
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes bai2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = bai2_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


% --- Executes on button press in btnProcess.
function btnProcess_Callback(hObject, eventdata, handles)

%get sample rate
str = get(handles.edtWindowsSize,'string');
winLen = str2num(str);

wHamm = hamming(winLen);
sigFrame = buffer(handles.sig,winLen,0,'nodelay');
sigWindowed = diag(sparse(wHamm)) * sigFrame;

%calculate short-time energy
energyST = sum(sigWindowed.^2,1);

%calculate zero crossing rate
ZCR = sum(abs(diff(sigFrame>=0)));

%build date
[n m] = size(sigFrame)
decision = {};
voiceSample = 0;
unvoiceSample = 0;
voiceSignal = [];
unvoiceSignal = [];
size(sigFrame(:,1))
for i=1:m
     if energyST(i) > 0.1
         decision{i} = 'Voiced';
         voiceSignal = cat(2,voiceSignal,sigFrame(:,i)');
         if(voiceSample == 0)
             voiceSample = i;
         end
     else
         decision{i} = 'Unvoiced';
         unvoiceSignal = cat(2,unvoiceSignal,sigFrame(:,i)')
         if unvoiceSample == 0
             unvoiceSample = i;
         end
     end
end
disp('hihi');
size(voiceSignal)
size(unvoiceSignal)
%draw table
f = figure(2);
datacells = [num2cell((1:m)'),num2cell(ZCR'),num2cell(energyST'),cellstr(decision')];
cnames = {'Frames','ZCR','Engery','Decision'};
tTable = uitable(f,'Data',datacells,'ColumnName',cnames,'Position',[50 100 400 200],'FontSize',12);


figure(3);
ax = gca;
ax.xTick = linspace(1,800,10);
plot(sigFrame(:,voiceSample));
xLim(gca,[winLen/3,winLen]);
title('A piece of voice');

figure(4);
ax = gca;
ax.yTick = [-1 0 1];
plot(sigFrame(:,unvoiceSample));
axis([winLen/3 winLen -0.1 0.1])
title('A piece of unvoice');

figure(5);
ax = gca;
% ax.xTick = linspace(1,800,10);
plot(voiceSignal);
title('Total voice signal');
figure(6);
ax = gca;
ax.yTick = [-1 0 1]
plot(unvoiceSignal);
title('Total unvoice signal');

function edtWindowsSize_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edtWindowsSize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
