unit uart;

interface

uses gpio;

var

GPFSEL1 : LongWord;
GPSET0  : LongWord;
GPCLR0  : LongWord;

GPPUD       : LongWord;
GPPUDCLK0   : LongWord;

AUX_ENABLES     : LongWord;
AUX_MU_IO_REG   : LongWord;
AUX_MU_IER_REG  : LongWord;
AUX_MU_IIR_REG  : LongWord;
AUX_MU_LCR_REG  : LongWord;
AUX_MU_MCR_REG  : LongWord;
AUX_MU_LSR_REG  : LongWord;
AUX_MU_MSR_REG  : LongWord;
AUX_MU_SCRATCH  : LongWord;
AUX_MU_CNTL_REG : LongWord;
AUX_MU_STAT_REG : LongWord;
AUX_MU_BAUD_REG : LongWord;

ar, rb, rc: longword;
i: longword;
digits: pchar;
pos: longword;

procedure uartinit();
procedure uart_putc( c: longword );
procedure uart_puts( s: pchar );

procedure PUT32 ( address: longword; value:longword ); external 'PUT32';
function GET32 ( address: longword ): longword; external 'GET32';
Function makehex(val: longword): pchar;


implementation

procedure uartinit();
begin

GPFSEL1 := $20200004;
GPSET0  := $2020001C;
GPCLR0  := $20200028;

GPPUD       := $20200094;
GPPUDCLK0   := $20200098;

AUX_ENABLES     := $20215004;
AUX_MU_IO_REG   := $20215040;
AUX_MU_IER_REG  := $20215044;
AUX_MU_IIR_REG  := $20215048;
AUX_MU_LCR_REG  := $2021504C;
AUX_MU_MCR_REG  := $20215050;
AUX_MU_LSR_REG  := $20215054;
AUX_MU_MSR_REG  := $20215058;
AUX_MU_SCRATCH  := $2021505C;
AUX_MU_CNTL_REG := $20215060;
AUX_MU_STAT_REG := $20215064;
AUX_MU_BAUD_REG := $20215068;

PUT32(AUX_ENABLES,1);
PUT32(AUX_MU_IER_REG,0);
PUT32(AUX_MU_CNTL_REG,0);
PUT32(AUX_MU_LCR_REG,3);
PUT32(AUX_MU_MCR_REG,0);
PUT32(AUX_MU_IER_REG,0);
PUT32(AUX_MU_IIR_REG,$C6);
PUT32(AUX_MU_BAUD_REG,270);

ar := GET32(GPFSEL1);
ar := ar and not (7 shl 12);
ar := ar or (2 shl 12);
PUT32(GPFSEL1,ar);

PUT32(GPPUD,0);
for ar:=0 to 149 do dummy(ar);
PUT32(GPPUDCLK0,(1 shl 14));
for ar:=0 to 149 do dummy(ar);
PUT32(GPPUDCLK0,0);
PUT32(AUX_MU_CNTL_REG,2);

end;

procedure uart_putc( c: longword );
begin
    while(true) do
    begin
	if boolean(GET32(AUX_MU_LSR_REG) and $20)=true then break;
    end;
    PUT32(AUX_MU_IO_REG,longword(c));
end;

Function makehex(val: longword): pchar;
begin
    makehex:='';
    pos:=0;

    rb:=32;
    while(true) do
    begin
        rb := rb - 4;
        rc := (val shr rb) and $F;
        if(rc>9) then rc := rc + $37 else rc := rc +$30;
        makehex[pos] := chr(rc);
        pos:=pos+1;
        if(rb=0) then break;
    end;
    makehex[pos] := chr($20);
end;

procedure uart_puts( s: pchar );
begin
	for i := 0 to strlen(s)-1 do
	begin
		uart_putc( longword(char(s[i])) );
	end;
end;

end.
