clear
notas = ["G#", "A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G"];
nota_base = 440;
num_nota = @(frecuencia, nota_base)((log2(frecuencia/nota_base)*12)+49);

Fs = 96000;
nBits = 24;
nChan = 1;
audio=audiorecorder(Fs, nBits, nChan);
pause(0.5);
for m = 1: 20
%while(true)
	record(audio);
	pause(.70);
	stop(audio);
	vectorAudio=getaudiodata(audio);
	transformada=abs(fft(vectorAudio));
    %quitar las frecuencias debajo de 15 hz y el reflejo de la transformada que se encuentra en la segunda mitad
    transformada = [ones(2,1); transformada(3:end/4)]; 
	l = length(transformada);
    frecuencias = linspace(0, Fs/4, l);
    figure(1);
    subplot(211);
    plot(frecuencias,transformada, 'b-', frecuencias/2,transformada, 'r:', frecuencias/3,transformada, 'g:', frecuencias/4,transformada, 'k:');
    axis([0,2000,0,inf]);
    %calculo del producto de espectro Armónico
    magnitud_fundamental = transformada;
    armonicos = 4;
    for i =2:armonicos
        temp = [];
        for n = 1:i:(length(transformada)-i-2)
            temp = [temp; sum(transformada(n:(n+i-1),1))/i];
        end
        magnitud_fundamental = magnitud_fundamental.*([temp; ones(length(magnitud_fundamental)-length(temp),1)]);
        
    end
    magnitud_fundamental = magnitud_fundamental.^(1/armonicos);
    magnitud_fundamental = [ones(5,1); magnitud_fundamental(6:end)];
    subplot(212);
    plot(frecuencias,magnitud_fundamental);
    axis([0,2000,0,inf]);
    %tomo la nota fundamental para mostrarla
    [~, indice_fundamental] = max(magnitud_fundamental);
    frecuencia_fundamental = frecuencias(indice_fundamental);
    numero_nota = abs(num_nota(frecuencia_fundamental,nota_base));
    entero_nota =round(numero_nota);
    residuo_nota = numero_nota-entero_nota;
    temperado = residuo_nota*100;
    letra_nota = notas(mod(entero_nota,12)+1);
    octava = floor((entero_nota+8)/12);
    fprintf("\n\tFrec: %.2f\tNum-Nota: %d\tNota: %s\tOct: %d cent: %.2f",frecuencia_fundamental, entero_nota, letra_nota, octava, temperado);
end
