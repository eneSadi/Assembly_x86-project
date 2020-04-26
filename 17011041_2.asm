myss           SEGMENT PARA STACK 'yigin'
               DW 24 DUP(?)
myss           ENDS

myds           SEGMENT PARA 'veri'
               dizi DW 100 DUP(?)  ;max 100 elemanlı dizimin tutulacağı dizi
               nn DW ?             ;n+n değerini tutacağım değişken
               n DW ?              ;dizinin eleman sayısı
               CR EQU 13           ;yeni satıra geçmek için kullanılan iki tanımlama
               LF EQU 10
               minUcgen DW 1000,1000,1000     ;olası üçgen üçlülerinin en küçüğünü tutacak olan dizi
               min DW ?                       ;diziyi sıralarken kullandığım minimum tutan değişken
               uc_eleman_toplam DW ?          ;üçlülerin kontrolünde kullanılacak
               var_mi DW 0                    ;uygun üçlü olup olmadığı bilgisi tutulacak
               uzunluk_err1 DB CR, LF, 'Uzunluk 1000 den buyuk olamaz: ',0
               hata_negatif DB CR,LF, 'Pozitif eleman giriniz: ',0
               msg1 DB CR,LF, 'Dizinin eleman sayisini giriniz (3-100 arasinda): ',0
               hata DB CR, LF, 'Lutfen sayi giriniz: ',0
               eleman DB CR, LF, 'Eleman giriniz: ',0
               hata_tam_sayi DB CR, LF, 'Lutfen tam sayi giriniz: ',0
               ucgen_yok DB 'Verilen dizide ucgen olusturabilecek eleman yok !',0
myds           ENDS

mycs           SEGMENT PARA 'kod'
               ASSUME CS: mycs, DS: myds, SS: myss

;PUTN fonksiyonu AX'in içindeki sayıyı ekrana onluk tabanda basamak basamak yazdırır.
PUTN           PROC NEAR
               PUSH CX
               PUSH DX
               XOR DX, DX
               PUSH DX
               MOV CX, 10
               CMP AX, 0
               JGE calc_digits
               NEG AX
               PUSH AX
               MOV AL, '-'
               CALL PUTC
               POP AX
calc_digits:   DIV CX
               ADD DX, '0'
               PUSH DX
               XOR DX, DX
               CMP AX, 0
               JNE calc_digits
disp_loop:     POP AX
               CMP AX, 0
               JE end_disp_loop
               CALL PUTC
               JMP disp_loop
end_disp_loop: POP DX
               POP CX
               RET
PUTN           ENDP

;Klavyeden girilen sayıyı okur, sonucu AX registerı üzerinden döndürür.
GETN           PROC NEAR
               PUSH BX
               PUSH CX
               PUSH DX
getn_start:    MOV DX, 1
               XOR BX, BX
               XOR CX, CX
new:           CALL GETC
               CMP AL, '.'          ;Kullanıcı '.' veya ',' karakteri giridiğinde tam_s_error labelına zıplayacak
               JE tam_s_error
               CMP AL, ','          ;Kullanıcı '.' veya ',' karakteri giridiğinde tam_s_error labelına zıplayacak
               JE tam_s_error
               CMP AL, '-'
               JE neg_error
               CMP AL, CR
               JE fin_read
               CMP AL, '-'
               JNE ctrl_num
negative:      MOV DX, -1
               JMP new
ctrl_num:      CMP AL, '0'
               JB error
               CMP AL, '9'
               JA error
               SUB AL, '0'
               MOV BL, AL
               MOV AX, 10
               PUSH DX
               MUL CX
               POP DX
               MOV CX, AX
               ADD CX, BX
               JMP new
tam_s_error:   MOV AX, OFFSET hata_tam_sayi  ;Kullanıcı numara verirken '.' veya ',' kullanırsa oluşacak uyarı
               CALL PUT_STR
               JMP getn_start
neg_error:     MOV AX, OFFSET hata_negatif  ;Kullanıcı numara verirken '-' kullanırsa oluşacak uyarı
               CALL PUT_STR
               JMP getn_start
error:         MOV AX, OFFSET hata          ;Rakam harici input durumunda oluşacak uyarı
               CALL PUT_STR
               JMP getn_start
fin_read:      MOV AX, CX
               CMP DX, 1
               JE fin_getn
               NEG AX
fin_getn:      POP DX
               POP CX
               POP BX
               RET
GETN           ENDP

;Klavyeden tek bir karakter alıp AL yazmacına atar
GETC           PROC NEAR
               MOV AH, 1H
               INT 21H
               RET
GETC           ENDP

;AL Yazmacındaki değeri ekrana yazdırır.
PUTC           PROC NEAR
               PUSH AX
               PUSH DX
               MOV DL, AL
               MOV AH, 2
               INT 21H
               POP DX
               POP AX
               RET
PUTC           ENDP

;Adresi AX üzerinden verilen, sonunda 0 olan stringi karakter karakter ekrana bastırır.
PUT_STR        PROC NEAR
               PUSH BX
               MOV BX,AX
               MOV AL, BYTE PTR [BX]
put_loop:      CMP AL, 0
               JE put_fin
               CALL PUTC
               INC BX
               MOV AL, BYTE PTR [BX]
               JMP put_loop
put_fin:       POP BX
               RET
PUT_STR        ENDP

MAIN           PROC FAR
               PUSH DS
               XOR AX, AX
               PUSH AX
               MOV AX, myds
               MOV DS, AX

;Dizinin eleman sayısının kullanıcıdan alındığı kısım
tekrarAl:      MOV AX, OFFSET msg1
               CALL PUT_STR
               CALL GETN
               CMP AX, 3    ;3'ten büyük ve
               JL tekrarAl
               CMP AX, 100  ;100'den küçük olması, gerekli karşılaştırmalarla sağlanır.
               JG tekrarAl
               MOV n, AX

;Dizi elemanlarının for yapısı kullanılarak kullanıcıdan alındığı kısım
               XOR SI, SI
               MOV CX, n
diziAl:        MOV AX, OFFSET eleman
               CALL PUT_STR
               CALL GETN
               CMP AX, 1000
               JNA alDizi               ;Verilen elemanın 1000'den küçük olduğu kontrolü
               MOV AX, OFFSET uzunluk_err1
               CALL PUT_STR
alDizi:        MOV dizi[SI], AX
               ADD SI, 2     ;word tipindeki dizi için index artırımı 2 byte olarak uygulanmıştır
               LOOP diziAl

;Dizideki uygun üçlüler bulunmadan önce dizinin BUBBLE SORT ile sıralandığı kısım
               MOV AX, n
               ADD AX, AX
               MOV nn, AX              ;while yapısında kullanılacak olan n+n sonucu bulunuyor
               MOV CX, n
               DEC CX
               XOR SI,SI
dis_don:       MOV min, SI            ;dış döngü for yapısıyla tasarlanmıştır.
               MOV DI,SI
ic_don:        CMP DI, nn             ;iç döngü while yapısıyla tasarlanmıştır.
               JE don_dis
               MOV BX, min
               MOV AX, dizi[BX]
               CMP AX, dizi[DI]
               JNA don_ic
               XCHG AX, dizi[DI]
               MOV dizi[BX], AX
don_ic:        ADD DI,2
               JMP ic_don
don_dis:       ADD SI,2
               LOOP dis_don

;Üçgen oluşturabilecek uygun üçlülerin sıralı dizi üzerinden teker tekerbulunduğu ve kontrollerle en küçüğünün bulunduğu kısım
               XOR SI, SI               ;kontrol edilecek üçlünün ilki için index
               MOV CX, n
               DEC CX
forLoop:       XOR DI, DI               ;kontrol edilecek üçlünün ikincisi için index
               ADD DI, SI
               ADD DI, 2
whileLoop:     XOR AX, AX               ;CMP komutu için kullanılacak olan DI+2 değişkenini AX'te tutarak DI'nın değeri korunmakta
               MOV AX, DI
               ADD AX, 2
               CMP AX, nn               ;Dizinin sonuna gelip gelinmediği kontrolü
               JNB forSon
               MOV BX, dizi[SI]         ;Sıralı dizideki ilk iki
               ADD BX, dizi[DI]         ;değer toplanarak
               CMP BX, dizi[DI+2]       ;üçüncü değerle karşılaştırılır. (üçgen olma şartı 1. kontrol)
               JNA artirDI
               MOV BX, dizi[DI]         ;Sıralı dizideki ikinci elemanın
               SUB BX, dizi[SI]         ;birinci elemandan farkı bulunarak
               CMP BX, dizi[DI+2]       ;üçüncü değerle karşılaştırılır. (üçgen olma şartı 2. kontrol)
               JNB artirDI
               MOV BX, dizi[SI]         ;BX yazmacı üzerinde
               ADD BX, dizi[DI]         ;uygun olduğuna karar verilen üçlünün
               ADD BX, dizi[DI+2]       ;toplamı atanır.
               MOV DX, minUcgen[0]      ;Minimum üçgenin tutulduğu
               ADD DX, minUcgen[2]      ;dizinin elemanları toplamı ise
               ADD DX, minUcgen[4]      ;DX yazmacında toplanır.
               CMP BX, DX               ;Gerekli kontrol ile gerekiyorsa minimum üçgen dizisi elemanları değiştirilir.
               JNB artirDI
               MOV BX, dizi[SI]         ;Elemanların değiştirildiği kısım
               MOV minUcgen[0], BX
               MOV BX, dizi[DI]
               MOV minUcgen[2], BX
               MOV BX, dizi[DI+2]
               MOV minUcgen[4], BX
               MOV var_mi, 1            ;Uygun en az 1 tane üçlü olduğunu belirtme amaçlı yapılacak kontrolde kullanılacak değişken 1 yapılır. (KONTROL DEĞİŞKENİ)
artirDI:       ADD DI, 2                ;While döngüsü bitmeden önce DI yazmacı 2 byte arttırılır çünkü dizi  word tipinde
               JMP whileLoop
forSon:        ADD SI, 2                ;For döngüsü bitmeden önce SI yazmacı 2 byte arttırılır çünkü dizi word tipinde
               LOOP forLoop

;Uygun üçlünün (varsa) yazdırıldığı, yoksa gerekli mesajın yazdırıldığı kısım
               CMP var_mi, 1                 ;Kontrol değişkenini burada kullandım
               JE var
               MOV AX, OFFSET ucgen_yok
               CALL PUT_STR
               JMP final
var:           MOV AL, '('
               CALL PUTC
               MOV AX, minUcgen[0]
               CALL PUTN
               MOV AL, ','
               CALL PUTC
               MOV AX, minUcgen[2]
               CALL PUTN
               MOV AL, ','
               CALL PUTC
               MOV AX, minUcgen[4]
               CALL PUTN
               MOV AL, ')'
               CALL PUTC                ;üçlü (x,y,z) formatında yazdırılır.

final:         RETF
MAIN           ENDP
mycs           ENDS
               END MAIN
