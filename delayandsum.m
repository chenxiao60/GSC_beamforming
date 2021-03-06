clear all

%Parametros:
Fs=16000; %frecuencia de muestreo
nc=15;    %numero de canales
L=400;    %longitud de la STFT
N=15;
c=340;
f=1:L/2;
win=sqrt(hanning(L)); %Ventana de Hanning
load('steering_vector.mat')

w=(1/N)*ds.';

% Generamos la matriz de bloqueo

block = [zeros(1,N-1)' -1*eye(N-1)] + [eye(N-1) zeros(1,N-1)'];


%Cargar las señales
Leer_Array_Signals;

%Dividir el mensaje en tramas
ntrama=Nsamp/(L/2);
ntrama=round(ntrama)-1;

xout=zeros(length(x{1}),1); %Creamos el vector de salida con zeros.

ini=1;
for k=1:ntrama-1
   xtemp=zeros;
    for nc=1:N
        x1=fft((win.*x{nc}(ini:ini+(L-1)))); %Aplicamos la ventana de Hanning a cada trama de cada canal y le hacemos la FFT
        xtemp=xtemp+w(:,nc).*x1(1:(L/2)+1); %Multiplicamos por el vector de pesos y vamos sumando cada uno de los canales, 
                                            %a fin de tener una señal resultante constructiva
    end
    xout(ini:ini+L-1)=xout(ini:ini+L-1)+win.*real(ifft([xtemp ;conj(xtemp(end-1:-1:2))])); %Formamos la otra mitad de xtemp, hacemos la ifft y la multiplicamos por la ventana.
    ini=ini+L/2;
end

% xout es la salida del Beam Forming






%Audio Array
array = 'array.wav';
audiowrite(array,xout,Fs)
%soundsc(xout,Fs);

%Cargar señal limpia
fname = 'an103-mtms-senn4.adc';
[fid,msg] = fopen(fname,'r','b');
if fid < 0
  disp(msg);
else
  data = fread(fid,'int16');
  fclose(fid);
end
xlimpia=data;
%soundsc(xlimpia,Fs);

%Audio señal limpia
limpia = 'limpia.wav';
audiowrite(limpia,xlimpia,Fs)

%Comparación
pesq(limpia,array)
