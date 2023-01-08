
obj/user/faultread.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  800039:	ff 35 00 00 00 00    	pushl  0x0
  80003f:	68 40 22 80 00       	push   $0x802240
  800044:	e8 f8 00 00 00       	call   800141 <cprintf>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800059:	e8 2d 0a 00 00       	call   800a8b <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 05 0e 00 00       	call   800ea4 <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 a1 09 00 00       	call   800a4a <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	53                   	push   %ebx
  8000b2:	83 ec 04             	sub    $0x4,%esp
  8000b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b8:	8b 13                	mov    (%ebx),%edx
  8000ba:	8d 42 01             	lea    0x1(%edx),%eax
  8000bd:	89 03                	mov    %eax,(%ebx)
  8000bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000cb:	75 1a                	jne    8000e7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000cd:	83 ec 08             	sub    $0x8,%esp
  8000d0:	68 ff 00 00 00       	push   $0xff
  8000d5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d8:	50                   	push   %eax
  8000d9:	e8 2f 09 00 00       	call   800a0d <sys_cputs>
		b->idx = 0;
  8000de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000e4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000e7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000ee:	c9                   	leave  
  8000ef:	c3                   	ret    

008000f0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800100:	00 00 00 
	b.cnt = 0;
  800103:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80010a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80010d:	ff 75 0c             	pushl  0xc(%ebp)
  800110:	ff 75 08             	pushl  0x8(%ebp)
  800113:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800119:	50                   	push   %eax
  80011a:	68 ae 00 80 00       	push   $0x8000ae
  80011f:	e8 54 01 00 00       	call   800278 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800124:	83 c4 08             	add    $0x8,%esp
  800127:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80012d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800133:	50                   	push   %eax
  800134:	e8 d4 08 00 00       	call   800a0d <sys_cputs>

	return b.cnt;
}
  800139:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800147:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80014a:	50                   	push   %eax
  80014b:	ff 75 08             	pushl  0x8(%ebp)
  80014e:	e8 9d ff ff ff       	call   8000f0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800153:	c9                   	leave  
  800154:	c3                   	ret    

00800155 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	83 ec 1c             	sub    $0x1c,%esp
  80015e:	89 c7                	mov    %eax,%edi
  800160:	89 d6                	mov    %edx,%esi
  800162:	8b 45 08             	mov    0x8(%ebp),%eax
  800165:	8b 55 0c             	mov    0xc(%ebp),%edx
  800168:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80016b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80016e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800171:	bb 00 00 00 00       	mov    $0x0,%ebx
  800176:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800179:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80017c:	39 d3                	cmp    %edx,%ebx
  80017e:	72 05                	jb     800185 <printnum+0x30>
  800180:	39 45 10             	cmp    %eax,0x10(%ebp)
  800183:	77 45                	ja     8001ca <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800185:	83 ec 0c             	sub    $0xc,%esp
  800188:	ff 75 18             	pushl  0x18(%ebp)
  80018b:	8b 45 14             	mov    0x14(%ebp),%eax
  80018e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800191:	53                   	push   %ebx
  800192:	ff 75 10             	pushl  0x10(%ebp)
  800195:	83 ec 08             	sub    $0x8,%esp
  800198:	ff 75 e4             	pushl  -0x1c(%ebp)
  80019b:	ff 75 e0             	pushl  -0x20(%ebp)
  80019e:	ff 75 dc             	pushl  -0x24(%ebp)
  8001a1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001a4:	e8 f7 1d 00 00       	call   801fa0 <__udivdi3>
  8001a9:	83 c4 18             	add    $0x18,%esp
  8001ac:	52                   	push   %edx
  8001ad:	50                   	push   %eax
  8001ae:	89 f2                	mov    %esi,%edx
  8001b0:	89 f8                	mov    %edi,%eax
  8001b2:	e8 9e ff ff ff       	call   800155 <printnum>
  8001b7:	83 c4 20             	add    $0x20,%esp
  8001ba:	eb 18                	jmp    8001d4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001bc:	83 ec 08             	sub    $0x8,%esp
  8001bf:	56                   	push   %esi
  8001c0:	ff 75 18             	pushl  0x18(%ebp)
  8001c3:	ff d7                	call   *%edi
  8001c5:	83 c4 10             	add    $0x10,%esp
  8001c8:	eb 03                	jmp    8001cd <printnum+0x78>
  8001ca:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001cd:	83 eb 01             	sub    $0x1,%ebx
  8001d0:	85 db                	test   %ebx,%ebx
  8001d2:	7f e8                	jg     8001bc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001d4:	83 ec 08             	sub    $0x8,%esp
  8001d7:	56                   	push   %esi
  8001d8:	83 ec 04             	sub    $0x4,%esp
  8001db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001de:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e7:	e8 e4 1e 00 00       	call   8020d0 <__umoddi3>
  8001ec:	83 c4 14             	add    $0x14,%esp
  8001ef:	0f be 80 68 22 80 00 	movsbl 0x802268(%eax),%eax
  8001f6:	50                   	push   %eax
  8001f7:	ff d7                	call   *%edi
}
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ff:	5b                   	pop    %ebx
  800200:	5e                   	pop    %esi
  800201:	5f                   	pop    %edi
  800202:	5d                   	pop    %ebp
  800203:	c3                   	ret    

00800204 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800207:	83 fa 01             	cmp    $0x1,%edx
  80020a:	7e 0e                	jle    80021a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80020c:	8b 10                	mov    (%eax),%edx
  80020e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800211:	89 08                	mov    %ecx,(%eax)
  800213:	8b 02                	mov    (%edx),%eax
  800215:	8b 52 04             	mov    0x4(%edx),%edx
  800218:	eb 22                	jmp    80023c <getuint+0x38>
	else if (lflag)
  80021a:	85 d2                	test   %edx,%edx
  80021c:	74 10                	je     80022e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80021e:	8b 10                	mov    (%eax),%edx
  800220:	8d 4a 04             	lea    0x4(%edx),%ecx
  800223:	89 08                	mov    %ecx,(%eax)
  800225:	8b 02                	mov    (%edx),%eax
  800227:	ba 00 00 00 00       	mov    $0x0,%edx
  80022c:	eb 0e                	jmp    80023c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80022e:	8b 10                	mov    (%eax),%edx
  800230:	8d 4a 04             	lea    0x4(%edx),%ecx
  800233:	89 08                	mov    %ecx,(%eax)
  800235:	8b 02                	mov    (%edx),%eax
  800237:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80023c:	5d                   	pop    %ebp
  80023d:	c3                   	ret    

0080023e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80023e:	55                   	push   %ebp
  80023f:	89 e5                	mov    %esp,%ebp
  800241:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800244:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800248:	8b 10                	mov    (%eax),%edx
  80024a:	3b 50 04             	cmp    0x4(%eax),%edx
  80024d:	73 0a                	jae    800259 <sprintputch+0x1b>
		*b->buf++ = ch;
  80024f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800252:	89 08                	mov    %ecx,(%eax)
  800254:	8b 45 08             	mov    0x8(%ebp),%eax
  800257:	88 02                	mov    %al,(%edx)
}
  800259:	5d                   	pop    %ebp
  80025a:	c3                   	ret    

0080025b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800261:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800264:	50                   	push   %eax
  800265:	ff 75 10             	pushl  0x10(%ebp)
  800268:	ff 75 0c             	pushl  0xc(%ebp)
  80026b:	ff 75 08             	pushl  0x8(%ebp)
  80026e:	e8 05 00 00 00       	call   800278 <vprintfmt>
	va_end(ap);
}
  800273:	83 c4 10             	add    $0x10,%esp
  800276:	c9                   	leave  
  800277:	c3                   	ret    

00800278 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	57                   	push   %edi
  80027c:	56                   	push   %esi
  80027d:	53                   	push   %ebx
  80027e:	83 ec 2c             	sub    $0x2c,%esp
  800281:	8b 75 08             	mov    0x8(%ebp),%esi
  800284:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800287:	8b 7d 10             	mov    0x10(%ebp),%edi
  80028a:	eb 12                	jmp    80029e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80028c:	85 c0                	test   %eax,%eax
  80028e:	0f 84 89 03 00 00    	je     80061d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800294:	83 ec 08             	sub    $0x8,%esp
  800297:	53                   	push   %ebx
  800298:	50                   	push   %eax
  800299:	ff d6                	call   *%esi
  80029b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80029e:	83 c7 01             	add    $0x1,%edi
  8002a1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002a5:	83 f8 25             	cmp    $0x25,%eax
  8002a8:	75 e2                	jne    80028c <vprintfmt+0x14>
  8002aa:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002ae:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002b5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002bc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c8:	eb 07                	jmp    8002d1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002cd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d1:	8d 47 01             	lea    0x1(%edi),%eax
  8002d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002d7:	0f b6 07             	movzbl (%edi),%eax
  8002da:	0f b6 c8             	movzbl %al,%ecx
  8002dd:	83 e8 23             	sub    $0x23,%eax
  8002e0:	3c 55                	cmp    $0x55,%al
  8002e2:	0f 87 1a 03 00 00    	ja     800602 <vprintfmt+0x38a>
  8002e8:	0f b6 c0             	movzbl %al,%eax
  8002eb:	ff 24 85 a0 23 80 00 	jmp    *0x8023a0(,%eax,4)
  8002f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002f5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002f9:	eb d6                	jmp    8002d1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800303:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800306:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800309:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80030d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800310:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800313:	83 fa 09             	cmp    $0x9,%edx
  800316:	77 39                	ja     800351 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800318:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80031b:	eb e9                	jmp    800306 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80031d:	8b 45 14             	mov    0x14(%ebp),%eax
  800320:	8d 48 04             	lea    0x4(%eax),%ecx
  800323:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800326:	8b 00                	mov    (%eax),%eax
  800328:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80032e:	eb 27                	jmp    800357 <vprintfmt+0xdf>
  800330:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800333:	85 c0                	test   %eax,%eax
  800335:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033a:	0f 49 c8             	cmovns %eax,%ecx
  80033d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800340:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800343:	eb 8c                	jmp    8002d1 <vprintfmt+0x59>
  800345:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800348:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80034f:	eb 80                	jmp    8002d1 <vprintfmt+0x59>
  800351:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800354:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800357:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80035b:	0f 89 70 ff ff ff    	jns    8002d1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800361:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800364:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800367:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80036e:	e9 5e ff ff ff       	jmp    8002d1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800373:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800376:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800379:	e9 53 ff ff ff       	jmp    8002d1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80037e:	8b 45 14             	mov    0x14(%ebp),%eax
  800381:	8d 50 04             	lea    0x4(%eax),%edx
  800384:	89 55 14             	mov    %edx,0x14(%ebp)
  800387:	83 ec 08             	sub    $0x8,%esp
  80038a:	53                   	push   %ebx
  80038b:	ff 30                	pushl  (%eax)
  80038d:	ff d6                	call   *%esi
			break;
  80038f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800395:	e9 04 ff ff ff       	jmp    80029e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80039a:	8b 45 14             	mov    0x14(%ebp),%eax
  80039d:	8d 50 04             	lea    0x4(%eax),%edx
  8003a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a3:	8b 00                	mov    (%eax),%eax
  8003a5:	99                   	cltd   
  8003a6:	31 d0                	xor    %edx,%eax
  8003a8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003aa:	83 f8 0f             	cmp    $0xf,%eax
  8003ad:	7f 0b                	jg     8003ba <vprintfmt+0x142>
  8003af:	8b 14 85 00 25 80 00 	mov    0x802500(,%eax,4),%edx
  8003b6:	85 d2                	test   %edx,%edx
  8003b8:	75 18                	jne    8003d2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003ba:	50                   	push   %eax
  8003bb:	68 80 22 80 00       	push   $0x802280
  8003c0:	53                   	push   %ebx
  8003c1:	56                   	push   %esi
  8003c2:	e8 94 fe ff ff       	call   80025b <printfmt>
  8003c7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003cd:	e9 cc fe ff ff       	jmp    80029e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003d2:	52                   	push   %edx
  8003d3:	68 35 26 80 00       	push   $0x802635
  8003d8:	53                   	push   %ebx
  8003d9:	56                   	push   %esi
  8003da:	e8 7c fe ff ff       	call   80025b <printfmt>
  8003df:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e5:	e9 b4 fe ff ff       	jmp    80029e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ed:	8d 50 04             	lea    0x4(%eax),%edx
  8003f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003f5:	85 ff                	test   %edi,%edi
  8003f7:	b8 79 22 80 00       	mov    $0x802279,%eax
  8003fc:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003ff:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800403:	0f 8e 94 00 00 00    	jle    80049d <vprintfmt+0x225>
  800409:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80040d:	0f 84 98 00 00 00    	je     8004ab <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800413:	83 ec 08             	sub    $0x8,%esp
  800416:	ff 75 d0             	pushl  -0x30(%ebp)
  800419:	57                   	push   %edi
  80041a:	e8 86 02 00 00       	call   8006a5 <strnlen>
  80041f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800422:	29 c1                	sub    %eax,%ecx
  800424:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800427:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80042a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80042e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800431:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800434:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800436:	eb 0f                	jmp    800447 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800438:	83 ec 08             	sub    $0x8,%esp
  80043b:	53                   	push   %ebx
  80043c:	ff 75 e0             	pushl  -0x20(%ebp)
  80043f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800441:	83 ef 01             	sub    $0x1,%edi
  800444:	83 c4 10             	add    $0x10,%esp
  800447:	85 ff                	test   %edi,%edi
  800449:	7f ed                	jg     800438 <vprintfmt+0x1c0>
  80044b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80044e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800451:	85 c9                	test   %ecx,%ecx
  800453:	b8 00 00 00 00       	mov    $0x0,%eax
  800458:	0f 49 c1             	cmovns %ecx,%eax
  80045b:	29 c1                	sub    %eax,%ecx
  80045d:	89 75 08             	mov    %esi,0x8(%ebp)
  800460:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800463:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800466:	89 cb                	mov    %ecx,%ebx
  800468:	eb 4d                	jmp    8004b7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80046a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80046e:	74 1b                	je     80048b <vprintfmt+0x213>
  800470:	0f be c0             	movsbl %al,%eax
  800473:	83 e8 20             	sub    $0x20,%eax
  800476:	83 f8 5e             	cmp    $0x5e,%eax
  800479:	76 10                	jbe    80048b <vprintfmt+0x213>
					putch('?', putdat);
  80047b:	83 ec 08             	sub    $0x8,%esp
  80047e:	ff 75 0c             	pushl  0xc(%ebp)
  800481:	6a 3f                	push   $0x3f
  800483:	ff 55 08             	call   *0x8(%ebp)
  800486:	83 c4 10             	add    $0x10,%esp
  800489:	eb 0d                	jmp    800498 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80048b:	83 ec 08             	sub    $0x8,%esp
  80048e:	ff 75 0c             	pushl  0xc(%ebp)
  800491:	52                   	push   %edx
  800492:	ff 55 08             	call   *0x8(%ebp)
  800495:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800498:	83 eb 01             	sub    $0x1,%ebx
  80049b:	eb 1a                	jmp    8004b7 <vprintfmt+0x23f>
  80049d:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004a9:	eb 0c                	jmp    8004b7 <vprintfmt+0x23f>
  8004ab:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ae:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b7:	83 c7 01             	add    $0x1,%edi
  8004ba:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004be:	0f be d0             	movsbl %al,%edx
  8004c1:	85 d2                	test   %edx,%edx
  8004c3:	74 23                	je     8004e8 <vprintfmt+0x270>
  8004c5:	85 f6                	test   %esi,%esi
  8004c7:	78 a1                	js     80046a <vprintfmt+0x1f2>
  8004c9:	83 ee 01             	sub    $0x1,%esi
  8004cc:	79 9c                	jns    80046a <vprintfmt+0x1f2>
  8004ce:	89 df                	mov    %ebx,%edi
  8004d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004d6:	eb 18                	jmp    8004f0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	53                   	push   %ebx
  8004dc:	6a 20                	push   $0x20
  8004de:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004e0:	83 ef 01             	sub    $0x1,%edi
  8004e3:	83 c4 10             	add    $0x10,%esp
  8004e6:	eb 08                	jmp    8004f0 <vprintfmt+0x278>
  8004e8:	89 df                	mov    %ebx,%edi
  8004ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f0:	85 ff                	test   %edi,%edi
  8004f2:	7f e4                	jg     8004d8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f7:	e9 a2 fd ff ff       	jmp    80029e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004fc:	83 fa 01             	cmp    $0x1,%edx
  8004ff:	7e 16                	jle    800517 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800501:	8b 45 14             	mov    0x14(%ebp),%eax
  800504:	8d 50 08             	lea    0x8(%eax),%edx
  800507:	89 55 14             	mov    %edx,0x14(%ebp)
  80050a:	8b 50 04             	mov    0x4(%eax),%edx
  80050d:	8b 00                	mov    (%eax),%eax
  80050f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800512:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800515:	eb 32                	jmp    800549 <vprintfmt+0x2d1>
	else if (lflag)
  800517:	85 d2                	test   %edx,%edx
  800519:	74 18                	je     800533 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80051b:	8b 45 14             	mov    0x14(%ebp),%eax
  80051e:	8d 50 04             	lea    0x4(%eax),%edx
  800521:	89 55 14             	mov    %edx,0x14(%ebp)
  800524:	8b 00                	mov    (%eax),%eax
  800526:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800529:	89 c1                	mov    %eax,%ecx
  80052b:	c1 f9 1f             	sar    $0x1f,%ecx
  80052e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800531:	eb 16                	jmp    800549 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8d 50 04             	lea    0x4(%eax),%edx
  800539:	89 55 14             	mov    %edx,0x14(%ebp)
  80053c:	8b 00                	mov    (%eax),%eax
  80053e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800541:	89 c1                	mov    %eax,%ecx
  800543:	c1 f9 1f             	sar    $0x1f,%ecx
  800546:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800549:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80054c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80054f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800554:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800558:	79 74                	jns    8005ce <vprintfmt+0x356>
				putch('-', putdat);
  80055a:	83 ec 08             	sub    $0x8,%esp
  80055d:	53                   	push   %ebx
  80055e:	6a 2d                	push   $0x2d
  800560:	ff d6                	call   *%esi
				num = -(long long) num;
  800562:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800565:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800568:	f7 d8                	neg    %eax
  80056a:	83 d2 00             	adc    $0x0,%edx
  80056d:	f7 da                	neg    %edx
  80056f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800572:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800577:	eb 55                	jmp    8005ce <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800579:	8d 45 14             	lea    0x14(%ebp),%eax
  80057c:	e8 83 fc ff ff       	call   800204 <getuint>
			base = 10;
  800581:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800586:	eb 46                	jmp    8005ce <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800588:	8d 45 14             	lea    0x14(%ebp),%eax
  80058b:	e8 74 fc ff ff       	call   800204 <getuint>
			base = 8;
  800590:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800595:	eb 37                	jmp    8005ce <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800597:	83 ec 08             	sub    $0x8,%esp
  80059a:	53                   	push   %ebx
  80059b:	6a 30                	push   $0x30
  80059d:	ff d6                	call   *%esi
			putch('x', putdat);
  80059f:	83 c4 08             	add    $0x8,%esp
  8005a2:	53                   	push   %ebx
  8005a3:	6a 78                	push   $0x78
  8005a5:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005aa:	8d 50 04             	lea    0x4(%eax),%edx
  8005ad:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005b0:	8b 00                	mov    (%eax),%eax
  8005b2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005b7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005ba:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005bf:	eb 0d                	jmp    8005ce <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005c1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c4:	e8 3b fc ff ff       	call   800204 <getuint>
			base = 16;
  8005c9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005ce:	83 ec 0c             	sub    $0xc,%esp
  8005d1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005d5:	57                   	push   %edi
  8005d6:	ff 75 e0             	pushl  -0x20(%ebp)
  8005d9:	51                   	push   %ecx
  8005da:	52                   	push   %edx
  8005db:	50                   	push   %eax
  8005dc:	89 da                	mov    %ebx,%edx
  8005de:	89 f0                	mov    %esi,%eax
  8005e0:	e8 70 fb ff ff       	call   800155 <printnum>
			break;
  8005e5:	83 c4 20             	add    $0x20,%esp
  8005e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005eb:	e9 ae fc ff ff       	jmp    80029e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005f0:	83 ec 08             	sub    $0x8,%esp
  8005f3:	53                   	push   %ebx
  8005f4:	51                   	push   %ecx
  8005f5:	ff d6                	call   *%esi
			break;
  8005f7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8005fd:	e9 9c fc ff ff       	jmp    80029e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800602:	83 ec 08             	sub    $0x8,%esp
  800605:	53                   	push   %ebx
  800606:	6a 25                	push   $0x25
  800608:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80060a:	83 c4 10             	add    $0x10,%esp
  80060d:	eb 03                	jmp    800612 <vprintfmt+0x39a>
  80060f:	83 ef 01             	sub    $0x1,%edi
  800612:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800616:	75 f7                	jne    80060f <vprintfmt+0x397>
  800618:	e9 81 fc ff ff       	jmp    80029e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80061d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800620:	5b                   	pop    %ebx
  800621:	5e                   	pop    %esi
  800622:	5f                   	pop    %edi
  800623:	5d                   	pop    %ebp
  800624:	c3                   	ret    

00800625 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800625:	55                   	push   %ebp
  800626:	89 e5                	mov    %esp,%ebp
  800628:	83 ec 18             	sub    $0x18,%esp
  80062b:	8b 45 08             	mov    0x8(%ebp),%eax
  80062e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800631:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800634:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800638:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80063b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800642:	85 c0                	test   %eax,%eax
  800644:	74 26                	je     80066c <vsnprintf+0x47>
  800646:	85 d2                	test   %edx,%edx
  800648:	7e 22                	jle    80066c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80064a:	ff 75 14             	pushl  0x14(%ebp)
  80064d:	ff 75 10             	pushl  0x10(%ebp)
  800650:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800653:	50                   	push   %eax
  800654:	68 3e 02 80 00       	push   $0x80023e
  800659:	e8 1a fc ff ff       	call   800278 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80065e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800661:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800664:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800667:	83 c4 10             	add    $0x10,%esp
  80066a:	eb 05                	jmp    800671 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80066c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800671:	c9                   	leave  
  800672:	c3                   	ret    

00800673 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800673:	55                   	push   %ebp
  800674:	89 e5                	mov    %esp,%ebp
  800676:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800679:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80067c:	50                   	push   %eax
  80067d:	ff 75 10             	pushl  0x10(%ebp)
  800680:	ff 75 0c             	pushl  0xc(%ebp)
  800683:	ff 75 08             	pushl  0x8(%ebp)
  800686:	e8 9a ff ff ff       	call   800625 <vsnprintf>
	va_end(ap);

	return rc;
}
  80068b:	c9                   	leave  
  80068c:	c3                   	ret    

0080068d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80068d:	55                   	push   %ebp
  80068e:	89 e5                	mov    %esp,%ebp
  800690:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800693:	b8 00 00 00 00       	mov    $0x0,%eax
  800698:	eb 03                	jmp    80069d <strlen+0x10>
		n++;
  80069a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80069d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006a1:	75 f7                	jne    80069a <strlen+0xd>
		n++;
	return n;
}
  8006a3:	5d                   	pop    %ebp
  8006a4:	c3                   	ret    

008006a5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006a5:	55                   	push   %ebp
  8006a6:	89 e5                	mov    %esp,%ebp
  8006a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006ab:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8006b3:	eb 03                	jmp    8006b8 <strnlen+0x13>
		n++;
  8006b5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006b8:	39 c2                	cmp    %eax,%edx
  8006ba:	74 08                	je     8006c4 <strnlen+0x1f>
  8006bc:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006c0:	75 f3                	jne    8006b5 <strnlen+0x10>
  8006c2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006c4:	5d                   	pop    %ebp
  8006c5:	c3                   	ret    

008006c6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006c6:	55                   	push   %ebp
  8006c7:	89 e5                	mov    %esp,%ebp
  8006c9:	53                   	push   %ebx
  8006ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006d0:	89 c2                	mov    %eax,%edx
  8006d2:	83 c2 01             	add    $0x1,%edx
  8006d5:	83 c1 01             	add    $0x1,%ecx
  8006d8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006dc:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006df:	84 db                	test   %bl,%bl
  8006e1:	75 ef                	jne    8006d2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006e3:	5b                   	pop    %ebx
  8006e4:	5d                   	pop    %ebp
  8006e5:	c3                   	ret    

008006e6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006e6:	55                   	push   %ebp
  8006e7:	89 e5                	mov    %esp,%ebp
  8006e9:	53                   	push   %ebx
  8006ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006ed:	53                   	push   %ebx
  8006ee:	e8 9a ff ff ff       	call   80068d <strlen>
  8006f3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8006f6:	ff 75 0c             	pushl  0xc(%ebp)
  8006f9:	01 d8                	add    %ebx,%eax
  8006fb:	50                   	push   %eax
  8006fc:	e8 c5 ff ff ff       	call   8006c6 <strcpy>
	return dst;
}
  800701:	89 d8                	mov    %ebx,%eax
  800703:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800706:	c9                   	leave  
  800707:	c3                   	ret    

00800708 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800708:	55                   	push   %ebp
  800709:	89 e5                	mov    %esp,%ebp
  80070b:	56                   	push   %esi
  80070c:	53                   	push   %ebx
  80070d:	8b 75 08             	mov    0x8(%ebp),%esi
  800710:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800713:	89 f3                	mov    %esi,%ebx
  800715:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800718:	89 f2                	mov    %esi,%edx
  80071a:	eb 0f                	jmp    80072b <strncpy+0x23>
		*dst++ = *src;
  80071c:	83 c2 01             	add    $0x1,%edx
  80071f:	0f b6 01             	movzbl (%ecx),%eax
  800722:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800725:	80 39 01             	cmpb   $0x1,(%ecx)
  800728:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80072b:	39 da                	cmp    %ebx,%edx
  80072d:	75 ed                	jne    80071c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80072f:	89 f0                	mov    %esi,%eax
  800731:	5b                   	pop    %ebx
  800732:	5e                   	pop    %esi
  800733:	5d                   	pop    %ebp
  800734:	c3                   	ret    

00800735 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	56                   	push   %esi
  800739:	53                   	push   %ebx
  80073a:	8b 75 08             	mov    0x8(%ebp),%esi
  80073d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800740:	8b 55 10             	mov    0x10(%ebp),%edx
  800743:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800745:	85 d2                	test   %edx,%edx
  800747:	74 21                	je     80076a <strlcpy+0x35>
  800749:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80074d:	89 f2                	mov    %esi,%edx
  80074f:	eb 09                	jmp    80075a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800751:	83 c2 01             	add    $0x1,%edx
  800754:	83 c1 01             	add    $0x1,%ecx
  800757:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80075a:	39 c2                	cmp    %eax,%edx
  80075c:	74 09                	je     800767 <strlcpy+0x32>
  80075e:	0f b6 19             	movzbl (%ecx),%ebx
  800761:	84 db                	test   %bl,%bl
  800763:	75 ec                	jne    800751 <strlcpy+0x1c>
  800765:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800767:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80076a:	29 f0                	sub    %esi,%eax
}
  80076c:	5b                   	pop    %ebx
  80076d:	5e                   	pop    %esi
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    

00800770 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800776:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800779:	eb 06                	jmp    800781 <strcmp+0x11>
		p++, q++;
  80077b:	83 c1 01             	add    $0x1,%ecx
  80077e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800781:	0f b6 01             	movzbl (%ecx),%eax
  800784:	84 c0                	test   %al,%al
  800786:	74 04                	je     80078c <strcmp+0x1c>
  800788:	3a 02                	cmp    (%edx),%al
  80078a:	74 ef                	je     80077b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80078c:	0f b6 c0             	movzbl %al,%eax
  80078f:	0f b6 12             	movzbl (%edx),%edx
  800792:	29 d0                	sub    %edx,%eax
}
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	53                   	push   %ebx
  80079a:	8b 45 08             	mov    0x8(%ebp),%eax
  80079d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a0:	89 c3                	mov    %eax,%ebx
  8007a2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007a5:	eb 06                	jmp    8007ad <strncmp+0x17>
		n--, p++, q++;
  8007a7:	83 c0 01             	add    $0x1,%eax
  8007aa:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007ad:	39 d8                	cmp    %ebx,%eax
  8007af:	74 15                	je     8007c6 <strncmp+0x30>
  8007b1:	0f b6 08             	movzbl (%eax),%ecx
  8007b4:	84 c9                	test   %cl,%cl
  8007b6:	74 04                	je     8007bc <strncmp+0x26>
  8007b8:	3a 0a                	cmp    (%edx),%cl
  8007ba:	74 eb                	je     8007a7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007bc:	0f b6 00             	movzbl (%eax),%eax
  8007bf:	0f b6 12             	movzbl (%edx),%edx
  8007c2:	29 d0                	sub    %edx,%eax
  8007c4:	eb 05                	jmp    8007cb <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007c6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007cb:	5b                   	pop    %ebx
  8007cc:	5d                   	pop    %ebp
  8007cd:	c3                   	ret    

008007ce <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007d8:	eb 07                	jmp    8007e1 <strchr+0x13>
		if (*s == c)
  8007da:	38 ca                	cmp    %cl,%dl
  8007dc:	74 0f                	je     8007ed <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007de:	83 c0 01             	add    $0x1,%eax
  8007e1:	0f b6 10             	movzbl (%eax),%edx
  8007e4:	84 d2                	test   %dl,%dl
  8007e6:	75 f2                	jne    8007da <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8007e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007f9:	eb 03                	jmp    8007fe <strfind+0xf>
  8007fb:	83 c0 01             	add    $0x1,%eax
  8007fe:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800801:	38 ca                	cmp    %cl,%dl
  800803:	74 04                	je     800809 <strfind+0x1a>
  800805:	84 d2                	test   %dl,%dl
  800807:	75 f2                	jne    8007fb <strfind+0xc>
			break;
	return (char *) s;
}
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	57                   	push   %edi
  80080f:	56                   	push   %esi
  800810:	53                   	push   %ebx
  800811:	8b 7d 08             	mov    0x8(%ebp),%edi
  800814:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800817:	85 c9                	test   %ecx,%ecx
  800819:	74 36                	je     800851 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80081b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800821:	75 28                	jne    80084b <memset+0x40>
  800823:	f6 c1 03             	test   $0x3,%cl
  800826:	75 23                	jne    80084b <memset+0x40>
		c &= 0xFF;
  800828:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80082c:	89 d3                	mov    %edx,%ebx
  80082e:	c1 e3 08             	shl    $0x8,%ebx
  800831:	89 d6                	mov    %edx,%esi
  800833:	c1 e6 18             	shl    $0x18,%esi
  800836:	89 d0                	mov    %edx,%eax
  800838:	c1 e0 10             	shl    $0x10,%eax
  80083b:	09 f0                	or     %esi,%eax
  80083d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80083f:	89 d8                	mov    %ebx,%eax
  800841:	09 d0                	or     %edx,%eax
  800843:	c1 e9 02             	shr    $0x2,%ecx
  800846:	fc                   	cld    
  800847:	f3 ab                	rep stos %eax,%es:(%edi)
  800849:	eb 06                	jmp    800851 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80084b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084e:	fc                   	cld    
  80084f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800851:	89 f8                	mov    %edi,%eax
  800853:	5b                   	pop    %ebx
  800854:	5e                   	pop    %esi
  800855:	5f                   	pop    %edi
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	57                   	push   %edi
  80085c:	56                   	push   %esi
  80085d:	8b 45 08             	mov    0x8(%ebp),%eax
  800860:	8b 75 0c             	mov    0xc(%ebp),%esi
  800863:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800866:	39 c6                	cmp    %eax,%esi
  800868:	73 35                	jae    80089f <memmove+0x47>
  80086a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80086d:	39 d0                	cmp    %edx,%eax
  80086f:	73 2e                	jae    80089f <memmove+0x47>
		s += n;
		d += n;
  800871:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800874:	89 d6                	mov    %edx,%esi
  800876:	09 fe                	or     %edi,%esi
  800878:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80087e:	75 13                	jne    800893 <memmove+0x3b>
  800880:	f6 c1 03             	test   $0x3,%cl
  800883:	75 0e                	jne    800893 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800885:	83 ef 04             	sub    $0x4,%edi
  800888:	8d 72 fc             	lea    -0x4(%edx),%esi
  80088b:	c1 e9 02             	shr    $0x2,%ecx
  80088e:	fd                   	std    
  80088f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800891:	eb 09                	jmp    80089c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800893:	83 ef 01             	sub    $0x1,%edi
  800896:	8d 72 ff             	lea    -0x1(%edx),%esi
  800899:	fd                   	std    
  80089a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80089c:	fc                   	cld    
  80089d:	eb 1d                	jmp    8008bc <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80089f:	89 f2                	mov    %esi,%edx
  8008a1:	09 c2                	or     %eax,%edx
  8008a3:	f6 c2 03             	test   $0x3,%dl
  8008a6:	75 0f                	jne    8008b7 <memmove+0x5f>
  8008a8:	f6 c1 03             	test   $0x3,%cl
  8008ab:	75 0a                	jne    8008b7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008ad:	c1 e9 02             	shr    $0x2,%ecx
  8008b0:	89 c7                	mov    %eax,%edi
  8008b2:	fc                   	cld    
  8008b3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008b5:	eb 05                	jmp    8008bc <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008b7:	89 c7                	mov    %eax,%edi
  8008b9:	fc                   	cld    
  8008ba:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008bc:	5e                   	pop    %esi
  8008bd:	5f                   	pop    %edi
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008c3:	ff 75 10             	pushl  0x10(%ebp)
  8008c6:	ff 75 0c             	pushl  0xc(%ebp)
  8008c9:	ff 75 08             	pushl  0x8(%ebp)
  8008cc:	e8 87 ff ff ff       	call   800858 <memmove>
}
  8008d1:	c9                   	leave  
  8008d2:	c3                   	ret    

008008d3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	56                   	push   %esi
  8008d7:	53                   	push   %ebx
  8008d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008de:	89 c6                	mov    %eax,%esi
  8008e0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008e3:	eb 1a                	jmp    8008ff <memcmp+0x2c>
		if (*s1 != *s2)
  8008e5:	0f b6 08             	movzbl (%eax),%ecx
  8008e8:	0f b6 1a             	movzbl (%edx),%ebx
  8008eb:	38 d9                	cmp    %bl,%cl
  8008ed:	74 0a                	je     8008f9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8008ef:	0f b6 c1             	movzbl %cl,%eax
  8008f2:	0f b6 db             	movzbl %bl,%ebx
  8008f5:	29 d8                	sub    %ebx,%eax
  8008f7:	eb 0f                	jmp    800908 <memcmp+0x35>
		s1++, s2++;
  8008f9:	83 c0 01             	add    $0x1,%eax
  8008fc:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008ff:	39 f0                	cmp    %esi,%eax
  800901:	75 e2                	jne    8008e5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800903:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800908:	5b                   	pop    %ebx
  800909:	5e                   	pop    %esi
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    

0080090c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	53                   	push   %ebx
  800910:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800913:	89 c1                	mov    %eax,%ecx
  800915:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800918:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80091c:	eb 0a                	jmp    800928 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80091e:	0f b6 10             	movzbl (%eax),%edx
  800921:	39 da                	cmp    %ebx,%edx
  800923:	74 07                	je     80092c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800925:	83 c0 01             	add    $0x1,%eax
  800928:	39 c8                	cmp    %ecx,%eax
  80092a:	72 f2                	jb     80091e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80092c:	5b                   	pop    %ebx
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	57                   	push   %edi
  800933:	56                   	push   %esi
  800934:	53                   	push   %ebx
  800935:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800938:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80093b:	eb 03                	jmp    800940 <strtol+0x11>
		s++;
  80093d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800940:	0f b6 01             	movzbl (%ecx),%eax
  800943:	3c 20                	cmp    $0x20,%al
  800945:	74 f6                	je     80093d <strtol+0xe>
  800947:	3c 09                	cmp    $0x9,%al
  800949:	74 f2                	je     80093d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80094b:	3c 2b                	cmp    $0x2b,%al
  80094d:	75 0a                	jne    800959 <strtol+0x2a>
		s++;
  80094f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800952:	bf 00 00 00 00       	mov    $0x0,%edi
  800957:	eb 11                	jmp    80096a <strtol+0x3b>
  800959:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80095e:	3c 2d                	cmp    $0x2d,%al
  800960:	75 08                	jne    80096a <strtol+0x3b>
		s++, neg = 1;
  800962:	83 c1 01             	add    $0x1,%ecx
  800965:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80096a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800970:	75 15                	jne    800987 <strtol+0x58>
  800972:	80 39 30             	cmpb   $0x30,(%ecx)
  800975:	75 10                	jne    800987 <strtol+0x58>
  800977:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80097b:	75 7c                	jne    8009f9 <strtol+0xca>
		s += 2, base = 16;
  80097d:	83 c1 02             	add    $0x2,%ecx
  800980:	bb 10 00 00 00       	mov    $0x10,%ebx
  800985:	eb 16                	jmp    80099d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800987:	85 db                	test   %ebx,%ebx
  800989:	75 12                	jne    80099d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80098b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800990:	80 39 30             	cmpb   $0x30,(%ecx)
  800993:	75 08                	jne    80099d <strtol+0x6e>
		s++, base = 8;
  800995:	83 c1 01             	add    $0x1,%ecx
  800998:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80099d:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009a5:	0f b6 11             	movzbl (%ecx),%edx
  8009a8:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009ab:	89 f3                	mov    %esi,%ebx
  8009ad:	80 fb 09             	cmp    $0x9,%bl
  8009b0:	77 08                	ja     8009ba <strtol+0x8b>
			dig = *s - '0';
  8009b2:	0f be d2             	movsbl %dl,%edx
  8009b5:	83 ea 30             	sub    $0x30,%edx
  8009b8:	eb 22                	jmp    8009dc <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009ba:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009bd:	89 f3                	mov    %esi,%ebx
  8009bf:	80 fb 19             	cmp    $0x19,%bl
  8009c2:	77 08                	ja     8009cc <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009c4:	0f be d2             	movsbl %dl,%edx
  8009c7:	83 ea 57             	sub    $0x57,%edx
  8009ca:	eb 10                	jmp    8009dc <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009cc:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009cf:	89 f3                	mov    %esi,%ebx
  8009d1:	80 fb 19             	cmp    $0x19,%bl
  8009d4:	77 16                	ja     8009ec <strtol+0xbd>
			dig = *s - 'A' + 10;
  8009d6:	0f be d2             	movsbl %dl,%edx
  8009d9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009dc:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009df:	7d 0b                	jge    8009ec <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8009e1:	83 c1 01             	add    $0x1,%ecx
  8009e4:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009e8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8009ea:	eb b9                	jmp    8009a5 <strtol+0x76>

	if (endptr)
  8009ec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009f0:	74 0d                	je     8009ff <strtol+0xd0>
		*endptr = (char *) s;
  8009f2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f5:	89 0e                	mov    %ecx,(%esi)
  8009f7:	eb 06                	jmp    8009ff <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009f9:	85 db                	test   %ebx,%ebx
  8009fb:	74 98                	je     800995 <strtol+0x66>
  8009fd:	eb 9e                	jmp    80099d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8009ff:	89 c2                	mov    %eax,%edx
  800a01:	f7 da                	neg    %edx
  800a03:	85 ff                	test   %edi,%edi
  800a05:	0f 45 c2             	cmovne %edx,%eax
}
  800a08:	5b                   	pop    %ebx
  800a09:	5e                   	pop    %esi
  800a0a:	5f                   	pop    %edi
  800a0b:	5d                   	pop    %ebp
  800a0c:	c3                   	ret    

00800a0d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	57                   	push   %edi
  800a11:	56                   	push   %esi
  800a12:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a13:	b8 00 00 00 00       	mov    $0x0,%eax
  800a18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1e:	89 c3                	mov    %eax,%ebx
  800a20:	89 c7                	mov    %eax,%edi
  800a22:	89 c6                	mov    %eax,%esi
  800a24:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a26:	5b                   	pop    %ebx
  800a27:	5e                   	pop    %esi
  800a28:	5f                   	pop    %edi
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <sys_cgetc>:

int
sys_cgetc(void)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	57                   	push   %edi
  800a2f:	56                   	push   %esi
  800a30:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a31:	ba 00 00 00 00       	mov    $0x0,%edx
  800a36:	b8 01 00 00 00       	mov    $0x1,%eax
  800a3b:	89 d1                	mov    %edx,%ecx
  800a3d:	89 d3                	mov    %edx,%ebx
  800a3f:	89 d7                	mov    %edx,%edi
  800a41:	89 d6                	mov    %edx,%esi
  800a43:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a45:	5b                   	pop    %ebx
  800a46:	5e                   	pop    %esi
  800a47:	5f                   	pop    %edi
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	57                   	push   %edi
  800a4e:	56                   	push   %esi
  800a4f:	53                   	push   %ebx
  800a50:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a53:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a58:	b8 03 00 00 00       	mov    $0x3,%eax
  800a5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a60:	89 cb                	mov    %ecx,%ebx
  800a62:	89 cf                	mov    %ecx,%edi
  800a64:	89 ce                	mov    %ecx,%esi
  800a66:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a68:	85 c0                	test   %eax,%eax
  800a6a:	7e 17                	jle    800a83 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a6c:	83 ec 0c             	sub    $0xc,%esp
  800a6f:	50                   	push   %eax
  800a70:	6a 03                	push   $0x3
  800a72:	68 5f 25 80 00       	push   $0x80255f
  800a77:	6a 23                	push   $0x23
  800a79:	68 7c 25 80 00       	push   $0x80257c
  800a7e:	e8 9a 13 00 00       	call   801e1d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a86:	5b                   	pop    %ebx
  800a87:	5e                   	pop    %esi
  800a88:	5f                   	pop    %edi
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	57                   	push   %edi
  800a8f:	56                   	push   %esi
  800a90:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a91:	ba 00 00 00 00       	mov    $0x0,%edx
  800a96:	b8 02 00 00 00       	mov    $0x2,%eax
  800a9b:	89 d1                	mov    %edx,%ecx
  800a9d:	89 d3                	mov    %edx,%ebx
  800a9f:	89 d7                	mov    %edx,%edi
  800aa1:	89 d6                	mov    %edx,%esi
  800aa3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800aa5:	5b                   	pop    %ebx
  800aa6:	5e                   	pop    %esi
  800aa7:	5f                   	pop    %edi
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <sys_yield>:

void
sys_yield(void)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	57                   	push   %edi
  800aae:	56                   	push   %esi
  800aaf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800aba:	89 d1                	mov    %edx,%ecx
  800abc:	89 d3                	mov    %edx,%ebx
  800abe:	89 d7                	mov    %edx,%edi
  800ac0:	89 d6                	mov    %edx,%esi
  800ac2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ac4:	5b                   	pop    %ebx
  800ac5:	5e                   	pop    %esi
  800ac6:	5f                   	pop    %edi
  800ac7:	5d                   	pop    %ebp
  800ac8:	c3                   	ret    

00800ac9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	57                   	push   %edi
  800acd:	56                   	push   %esi
  800ace:	53                   	push   %ebx
  800acf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad2:	be 00 00 00 00       	mov    $0x0,%esi
  800ad7:	b8 04 00 00 00       	mov    $0x4,%eax
  800adc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800adf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ae5:	89 f7                	mov    %esi,%edi
  800ae7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ae9:	85 c0                	test   %eax,%eax
  800aeb:	7e 17                	jle    800b04 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aed:	83 ec 0c             	sub    $0xc,%esp
  800af0:	50                   	push   %eax
  800af1:	6a 04                	push   $0x4
  800af3:	68 5f 25 80 00       	push   $0x80255f
  800af8:	6a 23                	push   $0x23
  800afa:	68 7c 25 80 00       	push   $0x80257c
  800aff:	e8 19 13 00 00       	call   801e1d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b07:	5b                   	pop    %ebx
  800b08:	5e                   	pop    %esi
  800b09:	5f                   	pop    %edi
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	57                   	push   %edi
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
  800b12:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b15:	b8 05 00 00 00       	mov    $0x5,%eax
  800b1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b20:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b23:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b26:	8b 75 18             	mov    0x18(%ebp),%esi
  800b29:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b2b:	85 c0                	test   %eax,%eax
  800b2d:	7e 17                	jle    800b46 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2f:	83 ec 0c             	sub    $0xc,%esp
  800b32:	50                   	push   %eax
  800b33:	6a 05                	push   $0x5
  800b35:	68 5f 25 80 00       	push   $0x80255f
  800b3a:	6a 23                	push   $0x23
  800b3c:	68 7c 25 80 00       	push   $0x80257c
  800b41:	e8 d7 12 00 00       	call   801e1d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b49:	5b                   	pop    %ebx
  800b4a:	5e                   	pop    %esi
  800b4b:	5f                   	pop    %edi
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
  800b54:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b57:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b5c:	b8 06 00 00 00       	mov    $0x6,%eax
  800b61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b64:	8b 55 08             	mov    0x8(%ebp),%edx
  800b67:	89 df                	mov    %ebx,%edi
  800b69:	89 de                	mov    %ebx,%esi
  800b6b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b6d:	85 c0                	test   %eax,%eax
  800b6f:	7e 17                	jle    800b88 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b71:	83 ec 0c             	sub    $0xc,%esp
  800b74:	50                   	push   %eax
  800b75:	6a 06                	push   $0x6
  800b77:	68 5f 25 80 00       	push   $0x80255f
  800b7c:	6a 23                	push   $0x23
  800b7e:	68 7c 25 80 00       	push   $0x80257c
  800b83:	e8 95 12 00 00       	call   801e1d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5f                   	pop    %edi
  800b8e:	5d                   	pop    %ebp
  800b8f:	c3                   	ret    

00800b90 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	57                   	push   %edi
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
  800b96:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b99:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b9e:	b8 08 00 00 00       	mov    $0x8,%eax
  800ba3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba9:	89 df                	mov    %ebx,%edi
  800bab:	89 de                	mov    %ebx,%esi
  800bad:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800baf:	85 c0                	test   %eax,%eax
  800bb1:	7e 17                	jle    800bca <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb3:	83 ec 0c             	sub    $0xc,%esp
  800bb6:	50                   	push   %eax
  800bb7:	6a 08                	push   $0x8
  800bb9:	68 5f 25 80 00       	push   $0x80255f
  800bbe:	6a 23                	push   $0x23
  800bc0:	68 7c 25 80 00       	push   $0x80257c
  800bc5:	e8 53 12 00 00       	call   801e1d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5f                   	pop    %edi
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	57                   	push   %edi
  800bd6:	56                   	push   %esi
  800bd7:	53                   	push   %ebx
  800bd8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be0:	b8 09 00 00 00       	mov    $0x9,%eax
  800be5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be8:	8b 55 08             	mov    0x8(%ebp),%edx
  800beb:	89 df                	mov    %ebx,%edi
  800bed:	89 de                	mov    %ebx,%esi
  800bef:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf1:	85 c0                	test   %eax,%eax
  800bf3:	7e 17                	jle    800c0c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf5:	83 ec 0c             	sub    $0xc,%esp
  800bf8:	50                   	push   %eax
  800bf9:	6a 09                	push   $0x9
  800bfb:	68 5f 25 80 00       	push   $0x80255f
  800c00:	6a 23                	push   $0x23
  800c02:	68 7c 25 80 00       	push   $0x80257c
  800c07:	e8 11 12 00 00       	call   801e1d <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
  800c1a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c22:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2d:	89 df                	mov    %ebx,%edi
  800c2f:	89 de                	mov    %ebx,%esi
  800c31:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c33:	85 c0                	test   %eax,%eax
  800c35:	7e 17                	jle    800c4e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c37:	83 ec 0c             	sub    $0xc,%esp
  800c3a:	50                   	push   %eax
  800c3b:	6a 0a                	push   $0xa
  800c3d:	68 5f 25 80 00       	push   $0x80255f
  800c42:	6a 23                	push   $0x23
  800c44:	68 7c 25 80 00       	push   $0x80257c
  800c49:	e8 cf 11 00 00       	call   801e1d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5c:	be 00 00 00 00       	mov    $0x0,%esi
  800c61:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c69:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c72:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	57                   	push   %edi
  800c7d:	56                   	push   %esi
  800c7e:	53                   	push   %ebx
  800c7f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c82:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c87:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8f:	89 cb                	mov    %ecx,%ebx
  800c91:	89 cf                	mov    %ecx,%edi
  800c93:	89 ce                	mov    %ecx,%esi
  800c95:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c97:	85 c0                	test   %eax,%eax
  800c99:	7e 17                	jle    800cb2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9b:	83 ec 0c             	sub    $0xc,%esp
  800c9e:	50                   	push   %eax
  800c9f:	6a 0d                	push   $0xd
  800ca1:	68 5f 25 80 00       	push   $0x80255f
  800ca6:	6a 23                	push   $0x23
  800ca8:	68 7c 25 80 00       	push   $0x80257c
  800cad:	e8 6b 11 00 00       	call   801e1d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    

00800cba <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	57                   	push   %edi
  800cbe:	56                   	push   %esi
  800cbf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc5:	b8 0e 00 00 00       	mov    $0xe,%eax
  800cca:	89 d1                	mov    %edx,%ecx
  800ccc:	89 d3                	mov    %edx,%ebx
  800cce:	89 d7                	mov    %edx,%edi
  800cd0:	89 d6                	mov    %edx,%esi
  800cd2:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800cdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdf:	05 00 00 00 30       	add    $0x30000000,%eax
  800ce4:	c1 e8 0c             	shr    $0xc,%eax
}
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800cec:	8b 45 08             	mov    0x8(%ebp),%eax
  800cef:	05 00 00 00 30       	add    $0x30000000,%eax
  800cf4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800cf9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d06:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d0b:	89 c2                	mov    %eax,%edx
  800d0d:	c1 ea 16             	shr    $0x16,%edx
  800d10:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d17:	f6 c2 01             	test   $0x1,%dl
  800d1a:	74 11                	je     800d2d <fd_alloc+0x2d>
  800d1c:	89 c2                	mov    %eax,%edx
  800d1e:	c1 ea 0c             	shr    $0xc,%edx
  800d21:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d28:	f6 c2 01             	test   $0x1,%dl
  800d2b:	75 09                	jne    800d36 <fd_alloc+0x36>
			*fd_store = fd;
  800d2d:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d34:	eb 17                	jmp    800d4d <fd_alloc+0x4d>
  800d36:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d3b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d40:	75 c9                	jne    800d0b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d42:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d48:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d4d:	5d                   	pop    %ebp
  800d4e:	c3                   	ret    

00800d4f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d55:	83 f8 1f             	cmp    $0x1f,%eax
  800d58:	77 36                	ja     800d90 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d5a:	c1 e0 0c             	shl    $0xc,%eax
  800d5d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d62:	89 c2                	mov    %eax,%edx
  800d64:	c1 ea 16             	shr    $0x16,%edx
  800d67:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d6e:	f6 c2 01             	test   $0x1,%dl
  800d71:	74 24                	je     800d97 <fd_lookup+0x48>
  800d73:	89 c2                	mov    %eax,%edx
  800d75:	c1 ea 0c             	shr    $0xc,%edx
  800d78:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d7f:	f6 c2 01             	test   $0x1,%dl
  800d82:	74 1a                	je     800d9e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800d84:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d87:	89 02                	mov    %eax,(%edx)
	return 0;
  800d89:	b8 00 00 00 00       	mov    $0x0,%eax
  800d8e:	eb 13                	jmp    800da3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800d90:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d95:	eb 0c                	jmp    800da3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800d97:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d9c:	eb 05                	jmp    800da3 <fd_lookup+0x54>
  800d9e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	83 ec 08             	sub    $0x8,%esp
  800dab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dae:	ba 08 26 80 00       	mov    $0x802608,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800db3:	eb 13                	jmp    800dc8 <dev_lookup+0x23>
  800db5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800db8:	39 08                	cmp    %ecx,(%eax)
  800dba:	75 0c                	jne    800dc8 <dev_lookup+0x23>
			*dev = devtab[i];
  800dbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbf:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc6:	eb 2e                	jmp    800df6 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800dc8:	8b 02                	mov    (%edx),%eax
  800dca:	85 c0                	test   %eax,%eax
  800dcc:	75 e7                	jne    800db5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800dce:	a1 08 40 80 00       	mov    0x804008,%eax
  800dd3:	8b 40 48             	mov    0x48(%eax),%eax
  800dd6:	83 ec 04             	sub    $0x4,%esp
  800dd9:	51                   	push   %ecx
  800dda:	50                   	push   %eax
  800ddb:	68 8c 25 80 00       	push   $0x80258c
  800de0:	e8 5c f3 ff ff       	call   800141 <cprintf>
	*dev = 0;
  800de5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800dee:	83 c4 10             	add    $0x10,%esp
  800df1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800df6:	c9                   	leave  
  800df7:	c3                   	ret    

00800df8 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	56                   	push   %esi
  800dfc:	53                   	push   %ebx
  800dfd:	83 ec 10             	sub    $0x10,%esp
  800e00:	8b 75 08             	mov    0x8(%ebp),%esi
  800e03:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e06:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e09:	50                   	push   %eax
  800e0a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e10:	c1 e8 0c             	shr    $0xc,%eax
  800e13:	50                   	push   %eax
  800e14:	e8 36 ff ff ff       	call   800d4f <fd_lookup>
  800e19:	83 c4 08             	add    $0x8,%esp
  800e1c:	85 c0                	test   %eax,%eax
  800e1e:	78 05                	js     800e25 <fd_close+0x2d>
	    || fd != fd2)
  800e20:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e23:	74 0c                	je     800e31 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e25:	84 db                	test   %bl,%bl
  800e27:	ba 00 00 00 00       	mov    $0x0,%edx
  800e2c:	0f 44 c2             	cmove  %edx,%eax
  800e2f:	eb 41                	jmp    800e72 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e31:	83 ec 08             	sub    $0x8,%esp
  800e34:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e37:	50                   	push   %eax
  800e38:	ff 36                	pushl  (%esi)
  800e3a:	e8 66 ff ff ff       	call   800da5 <dev_lookup>
  800e3f:	89 c3                	mov    %eax,%ebx
  800e41:	83 c4 10             	add    $0x10,%esp
  800e44:	85 c0                	test   %eax,%eax
  800e46:	78 1a                	js     800e62 <fd_close+0x6a>
		if (dev->dev_close)
  800e48:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e4b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e4e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e53:	85 c0                	test   %eax,%eax
  800e55:	74 0b                	je     800e62 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800e57:	83 ec 0c             	sub    $0xc,%esp
  800e5a:	56                   	push   %esi
  800e5b:	ff d0                	call   *%eax
  800e5d:	89 c3                	mov    %eax,%ebx
  800e5f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e62:	83 ec 08             	sub    $0x8,%esp
  800e65:	56                   	push   %esi
  800e66:	6a 00                	push   $0x0
  800e68:	e8 e1 fc ff ff       	call   800b4e <sys_page_unmap>
	return r;
  800e6d:	83 c4 10             	add    $0x10,%esp
  800e70:	89 d8                	mov    %ebx,%eax
}
  800e72:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e75:	5b                   	pop    %ebx
  800e76:	5e                   	pop    %esi
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    

00800e79 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e7f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e82:	50                   	push   %eax
  800e83:	ff 75 08             	pushl  0x8(%ebp)
  800e86:	e8 c4 fe ff ff       	call   800d4f <fd_lookup>
  800e8b:	83 c4 08             	add    $0x8,%esp
  800e8e:	85 c0                	test   %eax,%eax
  800e90:	78 10                	js     800ea2 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800e92:	83 ec 08             	sub    $0x8,%esp
  800e95:	6a 01                	push   $0x1
  800e97:	ff 75 f4             	pushl  -0xc(%ebp)
  800e9a:	e8 59 ff ff ff       	call   800df8 <fd_close>
  800e9f:	83 c4 10             	add    $0x10,%esp
}
  800ea2:	c9                   	leave  
  800ea3:	c3                   	ret    

00800ea4 <close_all>:

void
close_all(void)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	53                   	push   %ebx
  800ea8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800eab:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800eb0:	83 ec 0c             	sub    $0xc,%esp
  800eb3:	53                   	push   %ebx
  800eb4:	e8 c0 ff ff ff       	call   800e79 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800eb9:	83 c3 01             	add    $0x1,%ebx
  800ebc:	83 c4 10             	add    $0x10,%esp
  800ebf:	83 fb 20             	cmp    $0x20,%ebx
  800ec2:	75 ec                	jne    800eb0 <close_all+0xc>
		close(i);
}
  800ec4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ec7:	c9                   	leave  
  800ec8:	c3                   	ret    

00800ec9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ec9:	55                   	push   %ebp
  800eca:	89 e5                	mov    %esp,%ebp
  800ecc:	57                   	push   %edi
  800ecd:	56                   	push   %esi
  800ece:	53                   	push   %ebx
  800ecf:	83 ec 2c             	sub    $0x2c,%esp
  800ed2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ed5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ed8:	50                   	push   %eax
  800ed9:	ff 75 08             	pushl  0x8(%ebp)
  800edc:	e8 6e fe ff ff       	call   800d4f <fd_lookup>
  800ee1:	83 c4 08             	add    $0x8,%esp
  800ee4:	85 c0                	test   %eax,%eax
  800ee6:	0f 88 c1 00 00 00    	js     800fad <dup+0xe4>
		return r;
	close(newfdnum);
  800eec:	83 ec 0c             	sub    $0xc,%esp
  800eef:	56                   	push   %esi
  800ef0:	e8 84 ff ff ff       	call   800e79 <close>

	newfd = INDEX2FD(newfdnum);
  800ef5:	89 f3                	mov    %esi,%ebx
  800ef7:	c1 e3 0c             	shl    $0xc,%ebx
  800efa:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f00:	83 c4 04             	add    $0x4,%esp
  800f03:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f06:	e8 de fd ff ff       	call   800ce9 <fd2data>
  800f0b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f0d:	89 1c 24             	mov    %ebx,(%esp)
  800f10:	e8 d4 fd ff ff       	call   800ce9 <fd2data>
  800f15:	83 c4 10             	add    $0x10,%esp
  800f18:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f1b:	89 f8                	mov    %edi,%eax
  800f1d:	c1 e8 16             	shr    $0x16,%eax
  800f20:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f27:	a8 01                	test   $0x1,%al
  800f29:	74 37                	je     800f62 <dup+0x99>
  800f2b:	89 f8                	mov    %edi,%eax
  800f2d:	c1 e8 0c             	shr    $0xc,%eax
  800f30:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f37:	f6 c2 01             	test   $0x1,%dl
  800f3a:	74 26                	je     800f62 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f3c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f43:	83 ec 0c             	sub    $0xc,%esp
  800f46:	25 07 0e 00 00       	and    $0xe07,%eax
  800f4b:	50                   	push   %eax
  800f4c:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f4f:	6a 00                	push   $0x0
  800f51:	57                   	push   %edi
  800f52:	6a 00                	push   $0x0
  800f54:	e8 b3 fb ff ff       	call   800b0c <sys_page_map>
  800f59:	89 c7                	mov    %eax,%edi
  800f5b:	83 c4 20             	add    $0x20,%esp
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	78 2e                	js     800f90 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f62:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f65:	89 d0                	mov    %edx,%eax
  800f67:	c1 e8 0c             	shr    $0xc,%eax
  800f6a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f71:	83 ec 0c             	sub    $0xc,%esp
  800f74:	25 07 0e 00 00       	and    $0xe07,%eax
  800f79:	50                   	push   %eax
  800f7a:	53                   	push   %ebx
  800f7b:	6a 00                	push   $0x0
  800f7d:	52                   	push   %edx
  800f7e:	6a 00                	push   $0x0
  800f80:	e8 87 fb ff ff       	call   800b0c <sys_page_map>
  800f85:	89 c7                	mov    %eax,%edi
  800f87:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800f8a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f8c:	85 ff                	test   %edi,%edi
  800f8e:	79 1d                	jns    800fad <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800f90:	83 ec 08             	sub    $0x8,%esp
  800f93:	53                   	push   %ebx
  800f94:	6a 00                	push   $0x0
  800f96:	e8 b3 fb ff ff       	call   800b4e <sys_page_unmap>
	sys_page_unmap(0, nva);
  800f9b:	83 c4 08             	add    $0x8,%esp
  800f9e:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fa1:	6a 00                	push   $0x0
  800fa3:	e8 a6 fb ff ff       	call   800b4e <sys_page_unmap>
	return r;
  800fa8:	83 c4 10             	add    $0x10,%esp
  800fab:	89 f8                	mov    %edi,%eax
}
  800fad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fb0:	5b                   	pop    %ebx
  800fb1:	5e                   	pop    %esi
  800fb2:	5f                   	pop    %edi
  800fb3:	5d                   	pop    %ebp
  800fb4:	c3                   	ret    

00800fb5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fb5:	55                   	push   %ebp
  800fb6:	89 e5                	mov    %esp,%ebp
  800fb8:	53                   	push   %ebx
  800fb9:	83 ec 14             	sub    $0x14,%esp
  800fbc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fbf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fc2:	50                   	push   %eax
  800fc3:	53                   	push   %ebx
  800fc4:	e8 86 fd ff ff       	call   800d4f <fd_lookup>
  800fc9:	83 c4 08             	add    $0x8,%esp
  800fcc:	89 c2                	mov    %eax,%edx
  800fce:	85 c0                	test   %eax,%eax
  800fd0:	78 6d                	js     80103f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800fd2:	83 ec 08             	sub    $0x8,%esp
  800fd5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd8:	50                   	push   %eax
  800fd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fdc:	ff 30                	pushl  (%eax)
  800fde:	e8 c2 fd ff ff       	call   800da5 <dev_lookup>
  800fe3:	83 c4 10             	add    $0x10,%esp
  800fe6:	85 c0                	test   %eax,%eax
  800fe8:	78 4c                	js     801036 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800fea:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fed:	8b 42 08             	mov    0x8(%edx),%eax
  800ff0:	83 e0 03             	and    $0x3,%eax
  800ff3:	83 f8 01             	cmp    $0x1,%eax
  800ff6:	75 21                	jne    801019 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800ff8:	a1 08 40 80 00       	mov    0x804008,%eax
  800ffd:	8b 40 48             	mov    0x48(%eax),%eax
  801000:	83 ec 04             	sub    $0x4,%esp
  801003:	53                   	push   %ebx
  801004:	50                   	push   %eax
  801005:	68 cd 25 80 00       	push   $0x8025cd
  80100a:	e8 32 f1 ff ff       	call   800141 <cprintf>
		return -E_INVAL;
  80100f:	83 c4 10             	add    $0x10,%esp
  801012:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801017:	eb 26                	jmp    80103f <read+0x8a>
	}
	if (!dev->dev_read)
  801019:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101c:	8b 40 08             	mov    0x8(%eax),%eax
  80101f:	85 c0                	test   %eax,%eax
  801021:	74 17                	je     80103a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801023:	83 ec 04             	sub    $0x4,%esp
  801026:	ff 75 10             	pushl  0x10(%ebp)
  801029:	ff 75 0c             	pushl  0xc(%ebp)
  80102c:	52                   	push   %edx
  80102d:	ff d0                	call   *%eax
  80102f:	89 c2                	mov    %eax,%edx
  801031:	83 c4 10             	add    $0x10,%esp
  801034:	eb 09                	jmp    80103f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801036:	89 c2                	mov    %eax,%edx
  801038:	eb 05                	jmp    80103f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80103a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80103f:	89 d0                	mov    %edx,%eax
  801041:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801044:	c9                   	leave  
  801045:	c3                   	ret    

00801046 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801046:	55                   	push   %ebp
  801047:	89 e5                	mov    %esp,%ebp
  801049:	57                   	push   %edi
  80104a:	56                   	push   %esi
  80104b:	53                   	push   %ebx
  80104c:	83 ec 0c             	sub    $0xc,%esp
  80104f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801052:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801055:	bb 00 00 00 00       	mov    $0x0,%ebx
  80105a:	eb 21                	jmp    80107d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80105c:	83 ec 04             	sub    $0x4,%esp
  80105f:	89 f0                	mov    %esi,%eax
  801061:	29 d8                	sub    %ebx,%eax
  801063:	50                   	push   %eax
  801064:	89 d8                	mov    %ebx,%eax
  801066:	03 45 0c             	add    0xc(%ebp),%eax
  801069:	50                   	push   %eax
  80106a:	57                   	push   %edi
  80106b:	e8 45 ff ff ff       	call   800fb5 <read>
		if (m < 0)
  801070:	83 c4 10             	add    $0x10,%esp
  801073:	85 c0                	test   %eax,%eax
  801075:	78 10                	js     801087 <readn+0x41>
			return m;
		if (m == 0)
  801077:	85 c0                	test   %eax,%eax
  801079:	74 0a                	je     801085 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80107b:	01 c3                	add    %eax,%ebx
  80107d:	39 f3                	cmp    %esi,%ebx
  80107f:	72 db                	jb     80105c <readn+0x16>
  801081:	89 d8                	mov    %ebx,%eax
  801083:	eb 02                	jmp    801087 <readn+0x41>
  801085:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801087:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108a:	5b                   	pop    %ebx
  80108b:	5e                   	pop    %esi
  80108c:	5f                   	pop    %edi
  80108d:	5d                   	pop    %ebp
  80108e:	c3                   	ret    

0080108f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80108f:	55                   	push   %ebp
  801090:	89 e5                	mov    %esp,%ebp
  801092:	53                   	push   %ebx
  801093:	83 ec 14             	sub    $0x14,%esp
  801096:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801099:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80109c:	50                   	push   %eax
  80109d:	53                   	push   %ebx
  80109e:	e8 ac fc ff ff       	call   800d4f <fd_lookup>
  8010a3:	83 c4 08             	add    $0x8,%esp
  8010a6:	89 c2                	mov    %eax,%edx
  8010a8:	85 c0                	test   %eax,%eax
  8010aa:	78 68                	js     801114 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010ac:	83 ec 08             	sub    $0x8,%esp
  8010af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010b2:	50                   	push   %eax
  8010b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010b6:	ff 30                	pushl  (%eax)
  8010b8:	e8 e8 fc ff ff       	call   800da5 <dev_lookup>
  8010bd:	83 c4 10             	add    $0x10,%esp
  8010c0:	85 c0                	test   %eax,%eax
  8010c2:	78 47                	js     80110b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010c7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8010cb:	75 21                	jne    8010ee <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8010cd:	a1 08 40 80 00       	mov    0x804008,%eax
  8010d2:	8b 40 48             	mov    0x48(%eax),%eax
  8010d5:	83 ec 04             	sub    $0x4,%esp
  8010d8:	53                   	push   %ebx
  8010d9:	50                   	push   %eax
  8010da:	68 e9 25 80 00       	push   $0x8025e9
  8010df:	e8 5d f0 ff ff       	call   800141 <cprintf>
		return -E_INVAL;
  8010e4:	83 c4 10             	add    $0x10,%esp
  8010e7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010ec:	eb 26                	jmp    801114 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8010ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010f1:	8b 52 0c             	mov    0xc(%edx),%edx
  8010f4:	85 d2                	test   %edx,%edx
  8010f6:	74 17                	je     80110f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8010f8:	83 ec 04             	sub    $0x4,%esp
  8010fb:	ff 75 10             	pushl  0x10(%ebp)
  8010fe:	ff 75 0c             	pushl  0xc(%ebp)
  801101:	50                   	push   %eax
  801102:	ff d2                	call   *%edx
  801104:	89 c2                	mov    %eax,%edx
  801106:	83 c4 10             	add    $0x10,%esp
  801109:	eb 09                	jmp    801114 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80110b:	89 c2                	mov    %eax,%edx
  80110d:	eb 05                	jmp    801114 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80110f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801114:	89 d0                	mov    %edx,%eax
  801116:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801119:	c9                   	leave  
  80111a:	c3                   	ret    

0080111b <seek>:

int
seek(int fdnum, off_t offset)
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801121:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801124:	50                   	push   %eax
  801125:	ff 75 08             	pushl  0x8(%ebp)
  801128:	e8 22 fc ff ff       	call   800d4f <fd_lookup>
  80112d:	83 c4 08             	add    $0x8,%esp
  801130:	85 c0                	test   %eax,%eax
  801132:	78 0e                	js     801142 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801134:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801137:	8b 55 0c             	mov    0xc(%ebp),%edx
  80113a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80113d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801142:	c9                   	leave  
  801143:	c3                   	ret    

00801144 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801144:	55                   	push   %ebp
  801145:	89 e5                	mov    %esp,%ebp
  801147:	53                   	push   %ebx
  801148:	83 ec 14             	sub    $0x14,%esp
  80114b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80114e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801151:	50                   	push   %eax
  801152:	53                   	push   %ebx
  801153:	e8 f7 fb ff ff       	call   800d4f <fd_lookup>
  801158:	83 c4 08             	add    $0x8,%esp
  80115b:	89 c2                	mov    %eax,%edx
  80115d:	85 c0                	test   %eax,%eax
  80115f:	78 65                	js     8011c6 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801161:	83 ec 08             	sub    $0x8,%esp
  801164:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801167:	50                   	push   %eax
  801168:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80116b:	ff 30                	pushl  (%eax)
  80116d:	e8 33 fc ff ff       	call   800da5 <dev_lookup>
  801172:	83 c4 10             	add    $0x10,%esp
  801175:	85 c0                	test   %eax,%eax
  801177:	78 44                	js     8011bd <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801179:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80117c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801180:	75 21                	jne    8011a3 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801182:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801187:	8b 40 48             	mov    0x48(%eax),%eax
  80118a:	83 ec 04             	sub    $0x4,%esp
  80118d:	53                   	push   %ebx
  80118e:	50                   	push   %eax
  80118f:	68 ac 25 80 00       	push   $0x8025ac
  801194:	e8 a8 ef ff ff       	call   800141 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801199:	83 c4 10             	add    $0x10,%esp
  80119c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011a1:	eb 23                	jmp    8011c6 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011a6:	8b 52 18             	mov    0x18(%edx),%edx
  8011a9:	85 d2                	test   %edx,%edx
  8011ab:	74 14                	je     8011c1 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011ad:	83 ec 08             	sub    $0x8,%esp
  8011b0:	ff 75 0c             	pushl  0xc(%ebp)
  8011b3:	50                   	push   %eax
  8011b4:	ff d2                	call   *%edx
  8011b6:	89 c2                	mov    %eax,%edx
  8011b8:	83 c4 10             	add    $0x10,%esp
  8011bb:	eb 09                	jmp    8011c6 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011bd:	89 c2                	mov    %eax,%edx
  8011bf:	eb 05                	jmp    8011c6 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011c1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8011c6:	89 d0                	mov    %edx,%eax
  8011c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011cb:	c9                   	leave  
  8011cc:	c3                   	ret    

008011cd <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
  8011d0:	53                   	push   %ebx
  8011d1:	83 ec 14             	sub    $0x14,%esp
  8011d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011da:	50                   	push   %eax
  8011db:	ff 75 08             	pushl  0x8(%ebp)
  8011de:	e8 6c fb ff ff       	call   800d4f <fd_lookup>
  8011e3:	83 c4 08             	add    $0x8,%esp
  8011e6:	89 c2                	mov    %eax,%edx
  8011e8:	85 c0                	test   %eax,%eax
  8011ea:	78 58                	js     801244 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ec:	83 ec 08             	sub    $0x8,%esp
  8011ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f2:	50                   	push   %eax
  8011f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f6:	ff 30                	pushl  (%eax)
  8011f8:	e8 a8 fb ff ff       	call   800da5 <dev_lookup>
  8011fd:	83 c4 10             	add    $0x10,%esp
  801200:	85 c0                	test   %eax,%eax
  801202:	78 37                	js     80123b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801204:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801207:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80120b:	74 32                	je     80123f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80120d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801210:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801217:	00 00 00 
	stat->st_isdir = 0;
  80121a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801221:	00 00 00 
	stat->st_dev = dev;
  801224:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80122a:	83 ec 08             	sub    $0x8,%esp
  80122d:	53                   	push   %ebx
  80122e:	ff 75 f0             	pushl  -0x10(%ebp)
  801231:	ff 50 14             	call   *0x14(%eax)
  801234:	89 c2                	mov    %eax,%edx
  801236:	83 c4 10             	add    $0x10,%esp
  801239:	eb 09                	jmp    801244 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80123b:	89 c2                	mov    %eax,%edx
  80123d:	eb 05                	jmp    801244 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80123f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801244:	89 d0                	mov    %edx,%eax
  801246:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801249:	c9                   	leave  
  80124a:	c3                   	ret    

0080124b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	56                   	push   %esi
  80124f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801250:	83 ec 08             	sub    $0x8,%esp
  801253:	6a 00                	push   $0x0
  801255:	ff 75 08             	pushl  0x8(%ebp)
  801258:	e8 d6 01 00 00       	call   801433 <open>
  80125d:	89 c3                	mov    %eax,%ebx
  80125f:	83 c4 10             	add    $0x10,%esp
  801262:	85 c0                	test   %eax,%eax
  801264:	78 1b                	js     801281 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801266:	83 ec 08             	sub    $0x8,%esp
  801269:	ff 75 0c             	pushl  0xc(%ebp)
  80126c:	50                   	push   %eax
  80126d:	e8 5b ff ff ff       	call   8011cd <fstat>
  801272:	89 c6                	mov    %eax,%esi
	close(fd);
  801274:	89 1c 24             	mov    %ebx,(%esp)
  801277:	e8 fd fb ff ff       	call   800e79 <close>
	return r;
  80127c:	83 c4 10             	add    $0x10,%esp
  80127f:	89 f0                	mov    %esi,%eax
}
  801281:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801284:	5b                   	pop    %ebx
  801285:	5e                   	pop    %esi
  801286:	5d                   	pop    %ebp
  801287:	c3                   	ret    

00801288 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
  80128b:	56                   	push   %esi
  80128c:	53                   	push   %ebx
  80128d:	89 c6                	mov    %eax,%esi
  80128f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801291:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801298:	75 12                	jne    8012ac <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80129a:	83 ec 0c             	sub    $0xc,%esp
  80129d:	6a 01                	push   $0x1
  80129f:	e8 7a 0c 00 00       	call   801f1e <ipc_find_env>
  8012a4:	a3 00 40 80 00       	mov    %eax,0x804000
  8012a9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012ac:	6a 07                	push   $0x7
  8012ae:	68 00 50 80 00       	push   $0x805000
  8012b3:	56                   	push   %esi
  8012b4:	ff 35 00 40 80 00    	pushl  0x804000
  8012ba:	e8 0b 0c 00 00       	call   801eca <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012bf:	83 c4 0c             	add    $0xc,%esp
  8012c2:	6a 00                	push   $0x0
  8012c4:	53                   	push   %ebx
  8012c5:	6a 00                	push   $0x0
  8012c7:	e8 97 0b 00 00       	call   801e63 <ipc_recv>
}
  8012cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012cf:	5b                   	pop    %ebx
  8012d0:	5e                   	pop    %esi
  8012d1:	5d                   	pop    %ebp
  8012d2:	c3                   	ret    

008012d3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8012d3:	55                   	push   %ebp
  8012d4:	89 e5                	mov    %esp,%ebp
  8012d6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8012d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012dc:	8b 40 0c             	mov    0xc(%eax),%eax
  8012df:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8012e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012e7:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8012ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f1:	b8 02 00 00 00       	mov    $0x2,%eax
  8012f6:	e8 8d ff ff ff       	call   801288 <fsipc>
}
  8012fb:	c9                   	leave  
  8012fc:	c3                   	ret    

008012fd <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8012fd:	55                   	push   %ebp
  8012fe:	89 e5                	mov    %esp,%ebp
  801300:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801303:	8b 45 08             	mov    0x8(%ebp),%eax
  801306:	8b 40 0c             	mov    0xc(%eax),%eax
  801309:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80130e:	ba 00 00 00 00       	mov    $0x0,%edx
  801313:	b8 06 00 00 00       	mov    $0x6,%eax
  801318:	e8 6b ff ff ff       	call   801288 <fsipc>
}
  80131d:	c9                   	leave  
  80131e:	c3                   	ret    

0080131f <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80131f:	55                   	push   %ebp
  801320:	89 e5                	mov    %esp,%ebp
  801322:	53                   	push   %ebx
  801323:	83 ec 04             	sub    $0x4,%esp
  801326:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801329:	8b 45 08             	mov    0x8(%ebp),%eax
  80132c:	8b 40 0c             	mov    0xc(%eax),%eax
  80132f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801334:	ba 00 00 00 00       	mov    $0x0,%edx
  801339:	b8 05 00 00 00       	mov    $0x5,%eax
  80133e:	e8 45 ff ff ff       	call   801288 <fsipc>
  801343:	85 c0                	test   %eax,%eax
  801345:	78 2c                	js     801373 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801347:	83 ec 08             	sub    $0x8,%esp
  80134a:	68 00 50 80 00       	push   $0x805000
  80134f:	53                   	push   %ebx
  801350:	e8 71 f3 ff ff       	call   8006c6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801355:	a1 80 50 80 00       	mov    0x805080,%eax
  80135a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801360:	a1 84 50 80 00       	mov    0x805084,%eax
  801365:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80136b:	83 c4 10             	add    $0x10,%esp
  80136e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801373:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801376:	c9                   	leave  
  801377:	c3                   	ret    

00801378 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801378:	55                   	push   %ebp
  801379:	89 e5                	mov    %esp,%ebp
  80137b:	83 ec 0c             	sub    $0xc,%esp
  80137e:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801381:	8b 55 08             	mov    0x8(%ebp),%edx
  801384:	8b 52 0c             	mov    0xc(%edx),%edx
  801387:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80138d:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801392:	50                   	push   %eax
  801393:	ff 75 0c             	pushl  0xc(%ebp)
  801396:	68 08 50 80 00       	push   $0x805008
  80139b:	e8 b8 f4 ff ff       	call   800858 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8013a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a5:	b8 04 00 00 00       	mov    $0x4,%eax
  8013aa:	e8 d9 fe ff ff       	call   801288 <fsipc>

}
  8013af:	c9                   	leave  
  8013b0:	c3                   	ret    

008013b1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013b1:	55                   	push   %ebp
  8013b2:	89 e5                	mov    %esp,%ebp
  8013b4:	56                   	push   %esi
  8013b5:	53                   	push   %ebx
  8013b6:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013bc:	8b 40 0c             	mov    0xc(%eax),%eax
  8013bf:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013c4:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8013cf:	b8 03 00 00 00       	mov    $0x3,%eax
  8013d4:	e8 af fe ff ff       	call   801288 <fsipc>
  8013d9:	89 c3                	mov    %eax,%ebx
  8013db:	85 c0                	test   %eax,%eax
  8013dd:	78 4b                	js     80142a <devfile_read+0x79>
		return r;
	assert(r <= n);
  8013df:	39 c6                	cmp    %eax,%esi
  8013e1:	73 16                	jae    8013f9 <devfile_read+0x48>
  8013e3:	68 1c 26 80 00       	push   $0x80261c
  8013e8:	68 23 26 80 00       	push   $0x802623
  8013ed:	6a 7c                	push   $0x7c
  8013ef:	68 38 26 80 00       	push   $0x802638
  8013f4:	e8 24 0a 00 00       	call   801e1d <_panic>
	assert(r <= PGSIZE);
  8013f9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8013fe:	7e 16                	jle    801416 <devfile_read+0x65>
  801400:	68 43 26 80 00       	push   $0x802643
  801405:	68 23 26 80 00       	push   $0x802623
  80140a:	6a 7d                	push   $0x7d
  80140c:	68 38 26 80 00       	push   $0x802638
  801411:	e8 07 0a 00 00       	call   801e1d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801416:	83 ec 04             	sub    $0x4,%esp
  801419:	50                   	push   %eax
  80141a:	68 00 50 80 00       	push   $0x805000
  80141f:	ff 75 0c             	pushl  0xc(%ebp)
  801422:	e8 31 f4 ff ff       	call   800858 <memmove>
	return r;
  801427:	83 c4 10             	add    $0x10,%esp
}
  80142a:	89 d8                	mov    %ebx,%eax
  80142c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80142f:	5b                   	pop    %ebx
  801430:	5e                   	pop    %esi
  801431:	5d                   	pop    %ebp
  801432:	c3                   	ret    

00801433 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801433:	55                   	push   %ebp
  801434:	89 e5                	mov    %esp,%ebp
  801436:	53                   	push   %ebx
  801437:	83 ec 20             	sub    $0x20,%esp
  80143a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80143d:	53                   	push   %ebx
  80143e:	e8 4a f2 ff ff       	call   80068d <strlen>
  801443:	83 c4 10             	add    $0x10,%esp
  801446:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80144b:	7f 67                	jg     8014b4 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80144d:	83 ec 0c             	sub    $0xc,%esp
  801450:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801453:	50                   	push   %eax
  801454:	e8 a7 f8 ff ff       	call   800d00 <fd_alloc>
  801459:	83 c4 10             	add    $0x10,%esp
		return r;
  80145c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80145e:	85 c0                	test   %eax,%eax
  801460:	78 57                	js     8014b9 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801462:	83 ec 08             	sub    $0x8,%esp
  801465:	53                   	push   %ebx
  801466:	68 00 50 80 00       	push   $0x805000
  80146b:	e8 56 f2 ff ff       	call   8006c6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801470:	8b 45 0c             	mov    0xc(%ebp),%eax
  801473:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801478:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80147b:	b8 01 00 00 00       	mov    $0x1,%eax
  801480:	e8 03 fe ff ff       	call   801288 <fsipc>
  801485:	89 c3                	mov    %eax,%ebx
  801487:	83 c4 10             	add    $0x10,%esp
  80148a:	85 c0                	test   %eax,%eax
  80148c:	79 14                	jns    8014a2 <open+0x6f>
		fd_close(fd, 0);
  80148e:	83 ec 08             	sub    $0x8,%esp
  801491:	6a 00                	push   $0x0
  801493:	ff 75 f4             	pushl  -0xc(%ebp)
  801496:	e8 5d f9 ff ff       	call   800df8 <fd_close>
		return r;
  80149b:	83 c4 10             	add    $0x10,%esp
  80149e:	89 da                	mov    %ebx,%edx
  8014a0:	eb 17                	jmp    8014b9 <open+0x86>
	}

	return fd2num(fd);
  8014a2:	83 ec 0c             	sub    $0xc,%esp
  8014a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8014a8:	e8 2c f8 ff ff       	call   800cd9 <fd2num>
  8014ad:	89 c2                	mov    %eax,%edx
  8014af:	83 c4 10             	add    $0x10,%esp
  8014b2:	eb 05                	jmp    8014b9 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014b4:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8014b9:	89 d0                	mov    %edx,%eax
  8014bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014be:	c9                   	leave  
  8014bf:	c3                   	ret    

008014c0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8014c0:	55                   	push   %ebp
  8014c1:	89 e5                	mov    %esp,%ebp
  8014c3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8014c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014cb:	b8 08 00 00 00       	mov    $0x8,%eax
  8014d0:	e8 b3 fd ff ff       	call   801288 <fsipc>
}
  8014d5:	c9                   	leave  
  8014d6:	c3                   	ret    

008014d7 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8014d7:	55                   	push   %ebp
  8014d8:	89 e5                	mov    %esp,%ebp
  8014da:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8014dd:	68 4f 26 80 00       	push   $0x80264f
  8014e2:	ff 75 0c             	pushl  0xc(%ebp)
  8014e5:	e8 dc f1 ff ff       	call   8006c6 <strcpy>
	return 0;
}
  8014ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ef:	c9                   	leave  
  8014f0:	c3                   	ret    

008014f1 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8014f1:	55                   	push   %ebp
  8014f2:	89 e5                	mov    %esp,%ebp
  8014f4:	53                   	push   %ebx
  8014f5:	83 ec 10             	sub    $0x10,%esp
  8014f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8014fb:	53                   	push   %ebx
  8014fc:	e8 56 0a 00 00       	call   801f57 <pageref>
  801501:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801504:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801509:	83 f8 01             	cmp    $0x1,%eax
  80150c:	75 10                	jne    80151e <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80150e:	83 ec 0c             	sub    $0xc,%esp
  801511:	ff 73 0c             	pushl  0xc(%ebx)
  801514:	e8 c0 02 00 00       	call   8017d9 <nsipc_close>
  801519:	89 c2                	mov    %eax,%edx
  80151b:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80151e:	89 d0                	mov    %edx,%eax
  801520:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801523:	c9                   	leave  
  801524:	c3                   	ret    

00801525 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801525:	55                   	push   %ebp
  801526:	89 e5                	mov    %esp,%ebp
  801528:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80152b:	6a 00                	push   $0x0
  80152d:	ff 75 10             	pushl  0x10(%ebp)
  801530:	ff 75 0c             	pushl  0xc(%ebp)
  801533:	8b 45 08             	mov    0x8(%ebp),%eax
  801536:	ff 70 0c             	pushl  0xc(%eax)
  801539:	e8 78 03 00 00       	call   8018b6 <nsipc_send>
}
  80153e:	c9                   	leave  
  80153f:	c3                   	ret    

00801540 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801546:	6a 00                	push   $0x0
  801548:	ff 75 10             	pushl  0x10(%ebp)
  80154b:	ff 75 0c             	pushl  0xc(%ebp)
  80154e:	8b 45 08             	mov    0x8(%ebp),%eax
  801551:	ff 70 0c             	pushl  0xc(%eax)
  801554:	e8 f1 02 00 00       	call   80184a <nsipc_recv>
}
  801559:	c9                   	leave  
  80155a:	c3                   	ret    

0080155b <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801561:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801564:	52                   	push   %edx
  801565:	50                   	push   %eax
  801566:	e8 e4 f7 ff ff       	call   800d4f <fd_lookup>
  80156b:	83 c4 10             	add    $0x10,%esp
  80156e:	85 c0                	test   %eax,%eax
  801570:	78 17                	js     801589 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801572:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801575:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80157b:	39 08                	cmp    %ecx,(%eax)
  80157d:	75 05                	jne    801584 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80157f:	8b 40 0c             	mov    0xc(%eax),%eax
  801582:	eb 05                	jmp    801589 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801584:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801589:	c9                   	leave  
  80158a:	c3                   	ret    

0080158b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80158b:	55                   	push   %ebp
  80158c:	89 e5                	mov    %esp,%ebp
  80158e:	56                   	push   %esi
  80158f:	53                   	push   %ebx
  801590:	83 ec 1c             	sub    $0x1c,%esp
  801593:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801595:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801598:	50                   	push   %eax
  801599:	e8 62 f7 ff ff       	call   800d00 <fd_alloc>
  80159e:	89 c3                	mov    %eax,%ebx
  8015a0:	83 c4 10             	add    $0x10,%esp
  8015a3:	85 c0                	test   %eax,%eax
  8015a5:	78 1b                	js     8015c2 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8015a7:	83 ec 04             	sub    $0x4,%esp
  8015aa:	68 07 04 00 00       	push   $0x407
  8015af:	ff 75 f4             	pushl  -0xc(%ebp)
  8015b2:	6a 00                	push   $0x0
  8015b4:	e8 10 f5 ff ff       	call   800ac9 <sys_page_alloc>
  8015b9:	89 c3                	mov    %eax,%ebx
  8015bb:	83 c4 10             	add    $0x10,%esp
  8015be:	85 c0                	test   %eax,%eax
  8015c0:	79 10                	jns    8015d2 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8015c2:	83 ec 0c             	sub    $0xc,%esp
  8015c5:	56                   	push   %esi
  8015c6:	e8 0e 02 00 00       	call   8017d9 <nsipc_close>
		return r;
  8015cb:	83 c4 10             	add    $0x10,%esp
  8015ce:	89 d8                	mov    %ebx,%eax
  8015d0:	eb 24                	jmp    8015f6 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8015d2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8015d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015db:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8015dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8015e7:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8015ea:	83 ec 0c             	sub    $0xc,%esp
  8015ed:	50                   	push   %eax
  8015ee:	e8 e6 f6 ff ff       	call   800cd9 <fd2num>
  8015f3:	83 c4 10             	add    $0x10,%esp
}
  8015f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015f9:	5b                   	pop    %ebx
  8015fa:	5e                   	pop    %esi
  8015fb:	5d                   	pop    %ebp
  8015fc:	c3                   	ret    

008015fd <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8015fd:	55                   	push   %ebp
  8015fe:	89 e5                	mov    %esp,%ebp
  801600:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801603:	8b 45 08             	mov    0x8(%ebp),%eax
  801606:	e8 50 ff ff ff       	call   80155b <fd2sockid>
		return r;
  80160b:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80160d:	85 c0                	test   %eax,%eax
  80160f:	78 1f                	js     801630 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801611:	83 ec 04             	sub    $0x4,%esp
  801614:	ff 75 10             	pushl  0x10(%ebp)
  801617:	ff 75 0c             	pushl  0xc(%ebp)
  80161a:	50                   	push   %eax
  80161b:	e8 12 01 00 00       	call   801732 <nsipc_accept>
  801620:	83 c4 10             	add    $0x10,%esp
		return r;
  801623:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801625:	85 c0                	test   %eax,%eax
  801627:	78 07                	js     801630 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801629:	e8 5d ff ff ff       	call   80158b <alloc_sockfd>
  80162e:	89 c1                	mov    %eax,%ecx
}
  801630:	89 c8                	mov    %ecx,%eax
  801632:	c9                   	leave  
  801633:	c3                   	ret    

00801634 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801634:	55                   	push   %ebp
  801635:	89 e5                	mov    %esp,%ebp
  801637:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80163a:	8b 45 08             	mov    0x8(%ebp),%eax
  80163d:	e8 19 ff ff ff       	call   80155b <fd2sockid>
  801642:	85 c0                	test   %eax,%eax
  801644:	78 12                	js     801658 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801646:	83 ec 04             	sub    $0x4,%esp
  801649:	ff 75 10             	pushl  0x10(%ebp)
  80164c:	ff 75 0c             	pushl  0xc(%ebp)
  80164f:	50                   	push   %eax
  801650:	e8 2d 01 00 00       	call   801782 <nsipc_bind>
  801655:	83 c4 10             	add    $0x10,%esp
}
  801658:	c9                   	leave  
  801659:	c3                   	ret    

0080165a <shutdown>:

int
shutdown(int s, int how)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801660:	8b 45 08             	mov    0x8(%ebp),%eax
  801663:	e8 f3 fe ff ff       	call   80155b <fd2sockid>
  801668:	85 c0                	test   %eax,%eax
  80166a:	78 0f                	js     80167b <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80166c:	83 ec 08             	sub    $0x8,%esp
  80166f:	ff 75 0c             	pushl  0xc(%ebp)
  801672:	50                   	push   %eax
  801673:	e8 3f 01 00 00       	call   8017b7 <nsipc_shutdown>
  801678:	83 c4 10             	add    $0x10,%esp
}
  80167b:	c9                   	leave  
  80167c:	c3                   	ret    

0080167d <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80167d:	55                   	push   %ebp
  80167e:	89 e5                	mov    %esp,%ebp
  801680:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801683:	8b 45 08             	mov    0x8(%ebp),%eax
  801686:	e8 d0 fe ff ff       	call   80155b <fd2sockid>
  80168b:	85 c0                	test   %eax,%eax
  80168d:	78 12                	js     8016a1 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80168f:	83 ec 04             	sub    $0x4,%esp
  801692:	ff 75 10             	pushl  0x10(%ebp)
  801695:	ff 75 0c             	pushl  0xc(%ebp)
  801698:	50                   	push   %eax
  801699:	e8 55 01 00 00       	call   8017f3 <nsipc_connect>
  80169e:	83 c4 10             	add    $0x10,%esp
}
  8016a1:	c9                   	leave  
  8016a2:	c3                   	ret    

008016a3 <listen>:

int
listen(int s, int backlog)
{
  8016a3:	55                   	push   %ebp
  8016a4:	89 e5                	mov    %esp,%ebp
  8016a6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ac:	e8 aa fe ff ff       	call   80155b <fd2sockid>
  8016b1:	85 c0                	test   %eax,%eax
  8016b3:	78 0f                	js     8016c4 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8016b5:	83 ec 08             	sub    $0x8,%esp
  8016b8:	ff 75 0c             	pushl  0xc(%ebp)
  8016bb:	50                   	push   %eax
  8016bc:	e8 67 01 00 00       	call   801828 <nsipc_listen>
  8016c1:	83 c4 10             	add    $0x10,%esp
}
  8016c4:	c9                   	leave  
  8016c5:	c3                   	ret    

008016c6 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8016c6:	55                   	push   %ebp
  8016c7:	89 e5                	mov    %esp,%ebp
  8016c9:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8016cc:	ff 75 10             	pushl  0x10(%ebp)
  8016cf:	ff 75 0c             	pushl  0xc(%ebp)
  8016d2:	ff 75 08             	pushl  0x8(%ebp)
  8016d5:	e8 3a 02 00 00       	call   801914 <nsipc_socket>
  8016da:	83 c4 10             	add    $0x10,%esp
  8016dd:	85 c0                	test   %eax,%eax
  8016df:	78 05                	js     8016e6 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8016e1:	e8 a5 fe ff ff       	call   80158b <alloc_sockfd>
}
  8016e6:	c9                   	leave  
  8016e7:	c3                   	ret    

008016e8 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	53                   	push   %ebx
  8016ec:	83 ec 04             	sub    $0x4,%esp
  8016ef:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8016f1:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8016f8:	75 12                	jne    80170c <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8016fa:	83 ec 0c             	sub    $0xc,%esp
  8016fd:	6a 02                	push   $0x2
  8016ff:	e8 1a 08 00 00       	call   801f1e <ipc_find_env>
  801704:	a3 04 40 80 00       	mov    %eax,0x804004
  801709:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80170c:	6a 07                	push   $0x7
  80170e:	68 00 60 80 00       	push   $0x806000
  801713:	53                   	push   %ebx
  801714:	ff 35 04 40 80 00    	pushl  0x804004
  80171a:	e8 ab 07 00 00       	call   801eca <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80171f:	83 c4 0c             	add    $0xc,%esp
  801722:	6a 00                	push   $0x0
  801724:	6a 00                	push   $0x0
  801726:	6a 00                	push   $0x0
  801728:	e8 36 07 00 00       	call   801e63 <ipc_recv>
}
  80172d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801730:	c9                   	leave  
  801731:	c3                   	ret    

00801732 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801732:	55                   	push   %ebp
  801733:	89 e5                	mov    %esp,%ebp
  801735:	56                   	push   %esi
  801736:	53                   	push   %ebx
  801737:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80173a:	8b 45 08             	mov    0x8(%ebp),%eax
  80173d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801742:	8b 06                	mov    (%esi),%eax
  801744:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801749:	b8 01 00 00 00       	mov    $0x1,%eax
  80174e:	e8 95 ff ff ff       	call   8016e8 <nsipc>
  801753:	89 c3                	mov    %eax,%ebx
  801755:	85 c0                	test   %eax,%eax
  801757:	78 20                	js     801779 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801759:	83 ec 04             	sub    $0x4,%esp
  80175c:	ff 35 10 60 80 00    	pushl  0x806010
  801762:	68 00 60 80 00       	push   $0x806000
  801767:	ff 75 0c             	pushl  0xc(%ebp)
  80176a:	e8 e9 f0 ff ff       	call   800858 <memmove>
		*addrlen = ret->ret_addrlen;
  80176f:	a1 10 60 80 00       	mov    0x806010,%eax
  801774:	89 06                	mov    %eax,(%esi)
  801776:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801779:	89 d8                	mov    %ebx,%eax
  80177b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80177e:	5b                   	pop    %ebx
  80177f:	5e                   	pop    %esi
  801780:	5d                   	pop    %ebp
  801781:	c3                   	ret    

00801782 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801782:	55                   	push   %ebp
  801783:	89 e5                	mov    %esp,%ebp
  801785:	53                   	push   %ebx
  801786:	83 ec 08             	sub    $0x8,%esp
  801789:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80178c:	8b 45 08             	mov    0x8(%ebp),%eax
  80178f:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801794:	53                   	push   %ebx
  801795:	ff 75 0c             	pushl  0xc(%ebp)
  801798:	68 04 60 80 00       	push   $0x806004
  80179d:	e8 b6 f0 ff ff       	call   800858 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8017a2:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8017a8:	b8 02 00 00 00       	mov    $0x2,%eax
  8017ad:	e8 36 ff ff ff       	call   8016e8 <nsipc>
}
  8017b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b5:	c9                   	leave  
  8017b6:	c3                   	ret    

008017b7 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8017bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8017c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c8:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8017cd:	b8 03 00 00 00       	mov    $0x3,%eax
  8017d2:	e8 11 ff ff ff       	call   8016e8 <nsipc>
}
  8017d7:	c9                   	leave  
  8017d8:	c3                   	ret    

008017d9 <nsipc_close>:

int
nsipc_close(int s)
{
  8017d9:	55                   	push   %ebp
  8017da:	89 e5                	mov    %esp,%ebp
  8017dc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8017df:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e2:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8017e7:	b8 04 00 00 00       	mov    $0x4,%eax
  8017ec:	e8 f7 fe ff ff       	call   8016e8 <nsipc>
}
  8017f1:	c9                   	leave  
  8017f2:	c3                   	ret    

008017f3 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8017f3:	55                   	push   %ebp
  8017f4:	89 e5                	mov    %esp,%ebp
  8017f6:	53                   	push   %ebx
  8017f7:	83 ec 08             	sub    $0x8,%esp
  8017fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8017fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801800:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801805:	53                   	push   %ebx
  801806:	ff 75 0c             	pushl  0xc(%ebp)
  801809:	68 04 60 80 00       	push   $0x806004
  80180e:	e8 45 f0 ff ff       	call   800858 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801813:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801819:	b8 05 00 00 00       	mov    $0x5,%eax
  80181e:	e8 c5 fe ff ff       	call   8016e8 <nsipc>
}
  801823:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801826:	c9                   	leave  
  801827:	c3                   	ret    

00801828 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801828:	55                   	push   %ebp
  801829:	89 e5                	mov    %esp,%ebp
  80182b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80182e:	8b 45 08             	mov    0x8(%ebp),%eax
  801831:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801836:	8b 45 0c             	mov    0xc(%ebp),%eax
  801839:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80183e:	b8 06 00 00 00       	mov    $0x6,%eax
  801843:	e8 a0 fe ff ff       	call   8016e8 <nsipc>
}
  801848:	c9                   	leave  
  801849:	c3                   	ret    

0080184a <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80184a:	55                   	push   %ebp
  80184b:	89 e5                	mov    %esp,%ebp
  80184d:	56                   	push   %esi
  80184e:	53                   	push   %ebx
  80184f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801852:	8b 45 08             	mov    0x8(%ebp),%eax
  801855:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80185a:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801860:	8b 45 14             	mov    0x14(%ebp),%eax
  801863:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801868:	b8 07 00 00 00       	mov    $0x7,%eax
  80186d:	e8 76 fe ff ff       	call   8016e8 <nsipc>
  801872:	89 c3                	mov    %eax,%ebx
  801874:	85 c0                	test   %eax,%eax
  801876:	78 35                	js     8018ad <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801878:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80187d:	7f 04                	jg     801883 <nsipc_recv+0x39>
  80187f:	39 c6                	cmp    %eax,%esi
  801881:	7d 16                	jge    801899 <nsipc_recv+0x4f>
  801883:	68 5b 26 80 00       	push   $0x80265b
  801888:	68 23 26 80 00       	push   $0x802623
  80188d:	6a 62                	push   $0x62
  80188f:	68 70 26 80 00       	push   $0x802670
  801894:	e8 84 05 00 00       	call   801e1d <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801899:	83 ec 04             	sub    $0x4,%esp
  80189c:	50                   	push   %eax
  80189d:	68 00 60 80 00       	push   $0x806000
  8018a2:	ff 75 0c             	pushl  0xc(%ebp)
  8018a5:	e8 ae ef ff ff       	call   800858 <memmove>
  8018aa:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8018ad:	89 d8                	mov    %ebx,%eax
  8018af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b2:	5b                   	pop    %ebx
  8018b3:	5e                   	pop    %esi
  8018b4:	5d                   	pop    %ebp
  8018b5:	c3                   	ret    

008018b6 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8018b6:	55                   	push   %ebp
  8018b7:	89 e5                	mov    %esp,%ebp
  8018b9:	53                   	push   %ebx
  8018ba:	83 ec 04             	sub    $0x4,%esp
  8018bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8018c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c3:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8018c8:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8018ce:	7e 16                	jle    8018e6 <nsipc_send+0x30>
  8018d0:	68 7c 26 80 00       	push   $0x80267c
  8018d5:	68 23 26 80 00       	push   $0x802623
  8018da:	6a 6d                	push   $0x6d
  8018dc:	68 70 26 80 00       	push   $0x802670
  8018e1:	e8 37 05 00 00       	call   801e1d <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8018e6:	83 ec 04             	sub    $0x4,%esp
  8018e9:	53                   	push   %ebx
  8018ea:	ff 75 0c             	pushl  0xc(%ebp)
  8018ed:	68 0c 60 80 00       	push   $0x80600c
  8018f2:	e8 61 ef ff ff       	call   800858 <memmove>
	nsipcbuf.send.req_size = size;
  8018f7:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8018fd:	8b 45 14             	mov    0x14(%ebp),%eax
  801900:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801905:	b8 08 00 00 00       	mov    $0x8,%eax
  80190a:	e8 d9 fd ff ff       	call   8016e8 <nsipc>
}
  80190f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801912:	c9                   	leave  
  801913:	c3                   	ret    

00801914 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80191a:	8b 45 08             	mov    0x8(%ebp),%eax
  80191d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801922:	8b 45 0c             	mov    0xc(%ebp),%eax
  801925:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80192a:	8b 45 10             	mov    0x10(%ebp),%eax
  80192d:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801932:	b8 09 00 00 00       	mov    $0x9,%eax
  801937:	e8 ac fd ff ff       	call   8016e8 <nsipc>
}
  80193c:	c9                   	leave  
  80193d:	c3                   	ret    

0080193e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80193e:	55                   	push   %ebp
  80193f:	89 e5                	mov    %esp,%ebp
  801941:	56                   	push   %esi
  801942:	53                   	push   %ebx
  801943:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801946:	83 ec 0c             	sub    $0xc,%esp
  801949:	ff 75 08             	pushl  0x8(%ebp)
  80194c:	e8 98 f3 ff ff       	call   800ce9 <fd2data>
  801951:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801953:	83 c4 08             	add    $0x8,%esp
  801956:	68 88 26 80 00       	push   $0x802688
  80195b:	53                   	push   %ebx
  80195c:	e8 65 ed ff ff       	call   8006c6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801961:	8b 46 04             	mov    0x4(%esi),%eax
  801964:	2b 06                	sub    (%esi),%eax
  801966:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80196c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801973:	00 00 00 
	stat->st_dev = &devpipe;
  801976:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80197d:	30 80 00 
	return 0;
}
  801980:	b8 00 00 00 00       	mov    $0x0,%eax
  801985:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801988:	5b                   	pop    %ebx
  801989:	5e                   	pop    %esi
  80198a:	5d                   	pop    %ebp
  80198b:	c3                   	ret    

0080198c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80198c:	55                   	push   %ebp
  80198d:	89 e5                	mov    %esp,%ebp
  80198f:	53                   	push   %ebx
  801990:	83 ec 0c             	sub    $0xc,%esp
  801993:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801996:	53                   	push   %ebx
  801997:	6a 00                	push   $0x0
  801999:	e8 b0 f1 ff ff       	call   800b4e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80199e:	89 1c 24             	mov    %ebx,(%esp)
  8019a1:	e8 43 f3 ff ff       	call   800ce9 <fd2data>
  8019a6:	83 c4 08             	add    $0x8,%esp
  8019a9:	50                   	push   %eax
  8019aa:	6a 00                	push   $0x0
  8019ac:	e8 9d f1 ff ff       	call   800b4e <sys_page_unmap>
}
  8019b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b4:	c9                   	leave  
  8019b5:	c3                   	ret    

008019b6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	57                   	push   %edi
  8019ba:	56                   	push   %esi
  8019bb:	53                   	push   %ebx
  8019bc:	83 ec 1c             	sub    $0x1c,%esp
  8019bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019c2:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019c4:	a1 08 40 80 00       	mov    0x804008,%eax
  8019c9:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019cc:	83 ec 0c             	sub    $0xc,%esp
  8019cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8019d2:	e8 80 05 00 00       	call   801f57 <pageref>
  8019d7:	89 c3                	mov    %eax,%ebx
  8019d9:	89 3c 24             	mov    %edi,(%esp)
  8019dc:	e8 76 05 00 00       	call   801f57 <pageref>
  8019e1:	83 c4 10             	add    $0x10,%esp
  8019e4:	39 c3                	cmp    %eax,%ebx
  8019e6:	0f 94 c1             	sete   %cl
  8019e9:	0f b6 c9             	movzbl %cl,%ecx
  8019ec:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019ef:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8019f5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019f8:	39 ce                	cmp    %ecx,%esi
  8019fa:	74 1b                	je     801a17 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8019fc:	39 c3                	cmp    %eax,%ebx
  8019fe:	75 c4                	jne    8019c4 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a00:	8b 42 58             	mov    0x58(%edx),%eax
  801a03:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a06:	50                   	push   %eax
  801a07:	56                   	push   %esi
  801a08:	68 8f 26 80 00       	push   $0x80268f
  801a0d:	e8 2f e7 ff ff       	call   800141 <cprintf>
  801a12:	83 c4 10             	add    $0x10,%esp
  801a15:	eb ad                	jmp    8019c4 <_pipeisclosed+0xe>
	}
}
  801a17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a1d:	5b                   	pop    %ebx
  801a1e:	5e                   	pop    %esi
  801a1f:	5f                   	pop    %edi
  801a20:	5d                   	pop    %ebp
  801a21:	c3                   	ret    

00801a22 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a22:	55                   	push   %ebp
  801a23:	89 e5                	mov    %esp,%ebp
  801a25:	57                   	push   %edi
  801a26:	56                   	push   %esi
  801a27:	53                   	push   %ebx
  801a28:	83 ec 28             	sub    $0x28,%esp
  801a2b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a2e:	56                   	push   %esi
  801a2f:	e8 b5 f2 ff ff       	call   800ce9 <fd2data>
  801a34:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a36:	83 c4 10             	add    $0x10,%esp
  801a39:	bf 00 00 00 00       	mov    $0x0,%edi
  801a3e:	eb 4b                	jmp    801a8b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a40:	89 da                	mov    %ebx,%edx
  801a42:	89 f0                	mov    %esi,%eax
  801a44:	e8 6d ff ff ff       	call   8019b6 <_pipeisclosed>
  801a49:	85 c0                	test   %eax,%eax
  801a4b:	75 48                	jne    801a95 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a4d:	e8 58 f0 ff ff       	call   800aaa <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a52:	8b 43 04             	mov    0x4(%ebx),%eax
  801a55:	8b 0b                	mov    (%ebx),%ecx
  801a57:	8d 51 20             	lea    0x20(%ecx),%edx
  801a5a:	39 d0                	cmp    %edx,%eax
  801a5c:	73 e2                	jae    801a40 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a61:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a65:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a68:	89 c2                	mov    %eax,%edx
  801a6a:	c1 fa 1f             	sar    $0x1f,%edx
  801a6d:	89 d1                	mov    %edx,%ecx
  801a6f:	c1 e9 1b             	shr    $0x1b,%ecx
  801a72:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a75:	83 e2 1f             	and    $0x1f,%edx
  801a78:	29 ca                	sub    %ecx,%edx
  801a7a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a7e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a82:	83 c0 01             	add    $0x1,%eax
  801a85:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a88:	83 c7 01             	add    $0x1,%edi
  801a8b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a8e:	75 c2                	jne    801a52 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a90:	8b 45 10             	mov    0x10(%ebp),%eax
  801a93:	eb 05                	jmp    801a9a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a95:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a9d:	5b                   	pop    %ebx
  801a9e:	5e                   	pop    %esi
  801a9f:	5f                   	pop    %edi
  801aa0:	5d                   	pop    %ebp
  801aa1:	c3                   	ret    

00801aa2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801aa2:	55                   	push   %ebp
  801aa3:	89 e5                	mov    %esp,%ebp
  801aa5:	57                   	push   %edi
  801aa6:	56                   	push   %esi
  801aa7:	53                   	push   %ebx
  801aa8:	83 ec 18             	sub    $0x18,%esp
  801aab:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801aae:	57                   	push   %edi
  801aaf:	e8 35 f2 ff ff       	call   800ce9 <fd2data>
  801ab4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ab6:	83 c4 10             	add    $0x10,%esp
  801ab9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801abe:	eb 3d                	jmp    801afd <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ac0:	85 db                	test   %ebx,%ebx
  801ac2:	74 04                	je     801ac8 <devpipe_read+0x26>
				return i;
  801ac4:	89 d8                	mov    %ebx,%eax
  801ac6:	eb 44                	jmp    801b0c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ac8:	89 f2                	mov    %esi,%edx
  801aca:	89 f8                	mov    %edi,%eax
  801acc:	e8 e5 fe ff ff       	call   8019b6 <_pipeisclosed>
  801ad1:	85 c0                	test   %eax,%eax
  801ad3:	75 32                	jne    801b07 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ad5:	e8 d0 ef ff ff       	call   800aaa <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ada:	8b 06                	mov    (%esi),%eax
  801adc:	3b 46 04             	cmp    0x4(%esi),%eax
  801adf:	74 df                	je     801ac0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ae1:	99                   	cltd   
  801ae2:	c1 ea 1b             	shr    $0x1b,%edx
  801ae5:	01 d0                	add    %edx,%eax
  801ae7:	83 e0 1f             	and    $0x1f,%eax
  801aea:	29 d0                	sub    %edx,%eax
  801aec:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801af1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801af4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801af7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801afa:	83 c3 01             	add    $0x1,%ebx
  801afd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b00:	75 d8                	jne    801ada <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b02:	8b 45 10             	mov    0x10(%ebp),%eax
  801b05:	eb 05                	jmp    801b0c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b07:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b0f:	5b                   	pop    %ebx
  801b10:	5e                   	pop    %esi
  801b11:	5f                   	pop    %edi
  801b12:	5d                   	pop    %ebp
  801b13:	c3                   	ret    

00801b14 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b14:	55                   	push   %ebp
  801b15:	89 e5                	mov    %esp,%ebp
  801b17:	56                   	push   %esi
  801b18:	53                   	push   %ebx
  801b19:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b1f:	50                   	push   %eax
  801b20:	e8 db f1 ff ff       	call   800d00 <fd_alloc>
  801b25:	83 c4 10             	add    $0x10,%esp
  801b28:	89 c2                	mov    %eax,%edx
  801b2a:	85 c0                	test   %eax,%eax
  801b2c:	0f 88 2c 01 00 00    	js     801c5e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b32:	83 ec 04             	sub    $0x4,%esp
  801b35:	68 07 04 00 00       	push   $0x407
  801b3a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b3d:	6a 00                	push   $0x0
  801b3f:	e8 85 ef ff ff       	call   800ac9 <sys_page_alloc>
  801b44:	83 c4 10             	add    $0x10,%esp
  801b47:	89 c2                	mov    %eax,%edx
  801b49:	85 c0                	test   %eax,%eax
  801b4b:	0f 88 0d 01 00 00    	js     801c5e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b51:	83 ec 0c             	sub    $0xc,%esp
  801b54:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b57:	50                   	push   %eax
  801b58:	e8 a3 f1 ff ff       	call   800d00 <fd_alloc>
  801b5d:	89 c3                	mov    %eax,%ebx
  801b5f:	83 c4 10             	add    $0x10,%esp
  801b62:	85 c0                	test   %eax,%eax
  801b64:	0f 88 e2 00 00 00    	js     801c4c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b6a:	83 ec 04             	sub    $0x4,%esp
  801b6d:	68 07 04 00 00       	push   $0x407
  801b72:	ff 75 f0             	pushl  -0x10(%ebp)
  801b75:	6a 00                	push   $0x0
  801b77:	e8 4d ef ff ff       	call   800ac9 <sys_page_alloc>
  801b7c:	89 c3                	mov    %eax,%ebx
  801b7e:	83 c4 10             	add    $0x10,%esp
  801b81:	85 c0                	test   %eax,%eax
  801b83:	0f 88 c3 00 00 00    	js     801c4c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b89:	83 ec 0c             	sub    $0xc,%esp
  801b8c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b8f:	e8 55 f1 ff ff       	call   800ce9 <fd2data>
  801b94:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b96:	83 c4 0c             	add    $0xc,%esp
  801b99:	68 07 04 00 00       	push   $0x407
  801b9e:	50                   	push   %eax
  801b9f:	6a 00                	push   $0x0
  801ba1:	e8 23 ef ff ff       	call   800ac9 <sys_page_alloc>
  801ba6:	89 c3                	mov    %eax,%ebx
  801ba8:	83 c4 10             	add    $0x10,%esp
  801bab:	85 c0                	test   %eax,%eax
  801bad:	0f 88 89 00 00 00    	js     801c3c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb3:	83 ec 0c             	sub    $0xc,%esp
  801bb6:	ff 75 f0             	pushl  -0x10(%ebp)
  801bb9:	e8 2b f1 ff ff       	call   800ce9 <fd2data>
  801bbe:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bc5:	50                   	push   %eax
  801bc6:	6a 00                	push   $0x0
  801bc8:	56                   	push   %esi
  801bc9:	6a 00                	push   $0x0
  801bcb:	e8 3c ef ff ff       	call   800b0c <sys_page_map>
  801bd0:	89 c3                	mov    %eax,%ebx
  801bd2:	83 c4 20             	add    $0x20,%esp
  801bd5:	85 c0                	test   %eax,%eax
  801bd7:	78 55                	js     801c2e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bd9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bee:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bf4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bf7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801bf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bfc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c03:	83 ec 0c             	sub    $0xc,%esp
  801c06:	ff 75 f4             	pushl  -0xc(%ebp)
  801c09:	e8 cb f0 ff ff       	call   800cd9 <fd2num>
  801c0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c11:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c13:	83 c4 04             	add    $0x4,%esp
  801c16:	ff 75 f0             	pushl  -0x10(%ebp)
  801c19:	e8 bb f0 ff ff       	call   800cd9 <fd2num>
  801c1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c21:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c24:	83 c4 10             	add    $0x10,%esp
  801c27:	ba 00 00 00 00       	mov    $0x0,%edx
  801c2c:	eb 30                	jmp    801c5e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c2e:	83 ec 08             	sub    $0x8,%esp
  801c31:	56                   	push   %esi
  801c32:	6a 00                	push   $0x0
  801c34:	e8 15 ef ff ff       	call   800b4e <sys_page_unmap>
  801c39:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c3c:	83 ec 08             	sub    $0x8,%esp
  801c3f:	ff 75 f0             	pushl  -0x10(%ebp)
  801c42:	6a 00                	push   $0x0
  801c44:	e8 05 ef ff ff       	call   800b4e <sys_page_unmap>
  801c49:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c4c:	83 ec 08             	sub    $0x8,%esp
  801c4f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c52:	6a 00                	push   $0x0
  801c54:	e8 f5 ee ff ff       	call   800b4e <sys_page_unmap>
  801c59:	83 c4 10             	add    $0x10,%esp
  801c5c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c5e:	89 d0                	mov    %edx,%eax
  801c60:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c63:	5b                   	pop    %ebx
  801c64:	5e                   	pop    %esi
  801c65:	5d                   	pop    %ebp
  801c66:	c3                   	ret    

00801c67 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c67:	55                   	push   %ebp
  801c68:	89 e5                	mov    %esp,%ebp
  801c6a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c70:	50                   	push   %eax
  801c71:	ff 75 08             	pushl  0x8(%ebp)
  801c74:	e8 d6 f0 ff ff       	call   800d4f <fd_lookup>
  801c79:	83 c4 10             	add    $0x10,%esp
  801c7c:	85 c0                	test   %eax,%eax
  801c7e:	78 18                	js     801c98 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c80:	83 ec 0c             	sub    $0xc,%esp
  801c83:	ff 75 f4             	pushl  -0xc(%ebp)
  801c86:	e8 5e f0 ff ff       	call   800ce9 <fd2data>
	return _pipeisclosed(fd, p);
  801c8b:	89 c2                	mov    %eax,%edx
  801c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c90:	e8 21 fd ff ff       	call   8019b6 <_pipeisclosed>
  801c95:	83 c4 10             	add    $0x10,%esp
}
  801c98:	c9                   	leave  
  801c99:	c3                   	ret    

00801c9a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c9a:	55                   	push   %ebp
  801c9b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c9d:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca2:	5d                   	pop    %ebp
  801ca3:	c3                   	ret    

00801ca4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ca4:	55                   	push   %ebp
  801ca5:	89 e5                	mov    %esp,%ebp
  801ca7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801caa:	68 a7 26 80 00       	push   $0x8026a7
  801caf:	ff 75 0c             	pushl  0xc(%ebp)
  801cb2:	e8 0f ea ff ff       	call   8006c6 <strcpy>
	return 0;
}
  801cb7:	b8 00 00 00 00       	mov    $0x0,%eax
  801cbc:	c9                   	leave  
  801cbd:	c3                   	ret    

00801cbe <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cbe:	55                   	push   %ebp
  801cbf:	89 e5                	mov    %esp,%ebp
  801cc1:	57                   	push   %edi
  801cc2:	56                   	push   %esi
  801cc3:	53                   	push   %ebx
  801cc4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cca:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ccf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cd5:	eb 2d                	jmp    801d04 <devcons_write+0x46>
		m = n - tot;
  801cd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cda:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801cdc:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801cdf:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ce4:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ce7:	83 ec 04             	sub    $0x4,%esp
  801cea:	53                   	push   %ebx
  801ceb:	03 45 0c             	add    0xc(%ebp),%eax
  801cee:	50                   	push   %eax
  801cef:	57                   	push   %edi
  801cf0:	e8 63 eb ff ff       	call   800858 <memmove>
		sys_cputs(buf, m);
  801cf5:	83 c4 08             	add    $0x8,%esp
  801cf8:	53                   	push   %ebx
  801cf9:	57                   	push   %edi
  801cfa:	e8 0e ed ff ff       	call   800a0d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cff:	01 de                	add    %ebx,%esi
  801d01:	83 c4 10             	add    $0x10,%esp
  801d04:	89 f0                	mov    %esi,%eax
  801d06:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d09:	72 cc                	jb     801cd7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d0e:	5b                   	pop    %ebx
  801d0f:	5e                   	pop    %esi
  801d10:	5f                   	pop    %edi
  801d11:	5d                   	pop    %ebp
  801d12:	c3                   	ret    

00801d13 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d13:	55                   	push   %ebp
  801d14:	89 e5                	mov    %esp,%ebp
  801d16:	83 ec 08             	sub    $0x8,%esp
  801d19:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d1e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d22:	74 2a                	je     801d4e <devcons_read+0x3b>
  801d24:	eb 05                	jmp    801d2b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d26:	e8 7f ed ff ff       	call   800aaa <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d2b:	e8 fb ec ff ff       	call   800a2b <sys_cgetc>
  801d30:	85 c0                	test   %eax,%eax
  801d32:	74 f2                	je     801d26 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d34:	85 c0                	test   %eax,%eax
  801d36:	78 16                	js     801d4e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d38:	83 f8 04             	cmp    $0x4,%eax
  801d3b:	74 0c                	je     801d49 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d3d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d40:	88 02                	mov    %al,(%edx)
	return 1;
  801d42:	b8 01 00 00 00       	mov    $0x1,%eax
  801d47:	eb 05                	jmp    801d4e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d49:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d4e:	c9                   	leave  
  801d4f:	c3                   	ret    

00801d50 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d50:	55                   	push   %ebp
  801d51:	89 e5                	mov    %esp,%ebp
  801d53:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d56:	8b 45 08             	mov    0x8(%ebp),%eax
  801d59:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d5c:	6a 01                	push   $0x1
  801d5e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d61:	50                   	push   %eax
  801d62:	e8 a6 ec ff ff       	call   800a0d <sys_cputs>
}
  801d67:	83 c4 10             	add    $0x10,%esp
  801d6a:	c9                   	leave  
  801d6b:	c3                   	ret    

00801d6c <getchar>:

int
getchar(void)
{
  801d6c:	55                   	push   %ebp
  801d6d:	89 e5                	mov    %esp,%ebp
  801d6f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d72:	6a 01                	push   $0x1
  801d74:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d77:	50                   	push   %eax
  801d78:	6a 00                	push   $0x0
  801d7a:	e8 36 f2 ff ff       	call   800fb5 <read>
	if (r < 0)
  801d7f:	83 c4 10             	add    $0x10,%esp
  801d82:	85 c0                	test   %eax,%eax
  801d84:	78 0f                	js     801d95 <getchar+0x29>
		return r;
	if (r < 1)
  801d86:	85 c0                	test   %eax,%eax
  801d88:	7e 06                	jle    801d90 <getchar+0x24>
		return -E_EOF;
	return c;
  801d8a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d8e:	eb 05                	jmp    801d95 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d90:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d95:	c9                   	leave  
  801d96:	c3                   	ret    

00801d97 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d97:	55                   	push   %ebp
  801d98:	89 e5                	mov    %esp,%ebp
  801d9a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d9d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da0:	50                   	push   %eax
  801da1:	ff 75 08             	pushl  0x8(%ebp)
  801da4:	e8 a6 ef ff ff       	call   800d4f <fd_lookup>
  801da9:	83 c4 10             	add    $0x10,%esp
  801dac:	85 c0                	test   %eax,%eax
  801dae:	78 11                	js     801dc1 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db3:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801db9:	39 10                	cmp    %edx,(%eax)
  801dbb:	0f 94 c0             	sete   %al
  801dbe:	0f b6 c0             	movzbl %al,%eax
}
  801dc1:	c9                   	leave  
  801dc2:	c3                   	ret    

00801dc3 <opencons>:

int
opencons(void)
{
  801dc3:	55                   	push   %ebp
  801dc4:	89 e5                	mov    %esp,%ebp
  801dc6:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801dc9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dcc:	50                   	push   %eax
  801dcd:	e8 2e ef ff ff       	call   800d00 <fd_alloc>
  801dd2:	83 c4 10             	add    $0x10,%esp
		return r;
  801dd5:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801dd7:	85 c0                	test   %eax,%eax
  801dd9:	78 3e                	js     801e19 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ddb:	83 ec 04             	sub    $0x4,%esp
  801dde:	68 07 04 00 00       	push   $0x407
  801de3:	ff 75 f4             	pushl  -0xc(%ebp)
  801de6:	6a 00                	push   $0x0
  801de8:	e8 dc ec ff ff       	call   800ac9 <sys_page_alloc>
  801ded:	83 c4 10             	add    $0x10,%esp
		return r;
  801df0:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801df2:	85 c0                	test   %eax,%eax
  801df4:	78 23                	js     801e19 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801df6:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dff:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e04:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e0b:	83 ec 0c             	sub    $0xc,%esp
  801e0e:	50                   	push   %eax
  801e0f:	e8 c5 ee ff ff       	call   800cd9 <fd2num>
  801e14:	89 c2                	mov    %eax,%edx
  801e16:	83 c4 10             	add    $0x10,%esp
}
  801e19:	89 d0                	mov    %edx,%eax
  801e1b:	c9                   	leave  
  801e1c:	c3                   	ret    

00801e1d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e1d:	55                   	push   %ebp
  801e1e:	89 e5                	mov    %esp,%ebp
  801e20:	56                   	push   %esi
  801e21:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e22:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e25:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e2b:	e8 5b ec ff ff       	call   800a8b <sys_getenvid>
  801e30:	83 ec 0c             	sub    $0xc,%esp
  801e33:	ff 75 0c             	pushl  0xc(%ebp)
  801e36:	ff 75 08             	pushl  0x8(%ebp)
  801e39:	56                   	push   %esi
  801e3a:	50                   	push   %eax
  801e3b:	68 b4 26 80 00       	push   $0x8026b4
  801e40:	e8 fc e2 ff ff       	call   800141 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e45:	83 c4 18             	add    $0x18,%esp
  801e48:	53                   	push   %ebx
  801e49:	ff 75 10             	pushl  0x10(%ebp)
  801e4c:	e8 9f e2 ff ff       	call   8000f0 <vcprintf>
	cprintf("\n");
  801e51:	c7 04 24 5c 22 80 00 	movl   $0x80225c,(%esp)
  801e58:	e8 e4 e2 ff ff       	call   800141 <cprintf>
  801e5d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e60:	cc                   	int3   
  801e61:	eb fd                	jmp    801e60 <_panic+0x43>

00801e63 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e63:	55                   	push   %ebp
  801e64:	89 e5                	mov    %esp,%ebp
  801e66:	56                   	push   %esi
  801e67:	53                   	push   %ebx
  801e68:	8b 75 08             	mov    0x8(%ebp),%esi
  801e6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801e71:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801e73:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801e78:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801e7b:	83 ec 0c             	sub    $0xc,%esp
  801e7e:	50                   	push   %eax
  801e7f:	e8 f5 ed ff ff       	call   800c79 <sys_ipc_recv>

	if (from_env_store != NULL)
  801e84:	83 c4 10             	add    $0x10,%esp
  801e87:	85 f6                	test   %esi,%esi
  801e89:	74 14                	je     801e9f <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801e8b:	ba 00 00 00 00       	mov    $0x0,%edx
  801e90:	85 c0                	test   %eax,%eax
  801e92:	78 09                	js     801e9d <ipc_recv+0x3a>
  801e94:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801e9a:	8b 52 74             	mov    0x74(%edx),%edx
  801e9d:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801e9f:	85 db                	test   %ebx,%ebx
  801ea1:	74 14                	je     801eb7 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801ea3:	ba 00 00 00 00       	mov    $0x0,%edx
  801ea8:	85 c0                	test   %eax,%eax
  801eaa:	78 09                	js     801eb5 <ipc_recv+0x52>
  801eac:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801eb2:	8b 52 78             	mov    0x78(%edx),%edx
  801eb5:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801eb7:	85 c0                	test   %eax,%eax
  801eb9:	78 08                	js     801ec3 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801ebb:	a1 08 40 80 00       	mov    0x804008,%eax
  801ec0:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ec3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ec6:	5b                   	pop    %ebx
  801ec7:	5e                   	pop    %esi
  801ec8:	5d                   	pop    %ebp
  801ec9:	c3                   	ret    

00801eca <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801eca:	55                   	push   %ebp
  801ecb:	89 e5                	mov    %esp,%ebp
  801ecd:	57                   	push   %edi
  801ece:	56                   	push   %esi
  801ecf:	53                   	push   %ebx
  801ed0:	83 ec 0c             	sub    $0xc,%esp
  801ed3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ed6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ed9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801edc:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801ede:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ee3:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801ee6:	ff 75 14             	pushl  0x14(%ebp)
  801ee9:	53                   	push   %ebx
  801eea:	56                   	push   %esi
  801eeb:	57                   	push   %edi
  801eec:	e8 65 ed ff ff       	call   800c56 <sys_ipc_try_send>

		if (err < 0) {
  801ef1:	83 c4 10             	add    $0x10,%esp
  801ef4:	85 c0                	test   %eax,%eax
  801ef6:	79 1e                	jns    801f16 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801ef8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801efb:	75 07                	jne    801f04 <ipc_send+0x3a>
				sys_yield();
  801efd:	e8 a8 eb ff ff       	call   800aaa <sys_yield>
  801f02:	eb e2                	jmp    801ee6 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f04:	50                   	push   %eax
  801f05:	68 d8 26 80 00       	push   $0x8026d8
  801f0a:	6a 49                	push   $0x49
  801f0c:	68 e5 26 80 00       	push   $0x8026e5
  801f11:	e8 07 ff ff ff       	call   801e1d <_panic>
		}

	} while (err < 0);

}
  801f16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f19:	5b                   	pop    %ebx
  801f1a:	5e                   	pop    %esi
  801f1b:	5f                   	pop    %edi
  801f1c:	5d                   	pop    %ebp
  801f1d:	c3                   	ret    

00801f1e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f1e:	55                   	push   %ebp
  801f1f:	89 e5                	mov    %esp,%ebp
  801f21:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f24:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f29:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f2c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f32:	8b 52 50             	mov    0x50(%edx),%edx
  801f35:	39 ca                	cmp    %ecx,%edx
  801f37:	75 0d                	jne    801f46 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f39:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f3c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f41:	8b 40 48             	mov    0x48(%eax),%eax
  801f44:	eb 0f                	jmp    801f55 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f46:	83 c0 01             	add    $0x1,%eax
  801f49:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f4e:	75 d9                	jne    801f29 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f50:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f55:	5d                   	pop    %ebp
  801f56:	c3                   	ret    

00801f57 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f57:	55                   	push   %ebp
  801f58:	89 e5                	mov    %esp,%ebp
  801f5a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f5d:	89 d0                	mov    %edx,%eax
  801f5f:	c1 e8 16             	shr    $0x16,%eax
  801f62:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f69:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f6e:	f6 c1 01             	test   $0x1,%cl
  801f71:	74 1d                	je     801f90 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f73:	c1 ea 0c             	shr    $0xc,%edx
  801f76:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f7d:	f6 c2 01             	test   $0x1,%dl
  801f80:	74 0e                	je     801f90 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f82:	c1 ea 0c             	shr    $0xc,%edx
  801f85:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f8c:	ef 
  801f8d:	0f b7 c0             	movzwl %ax,%eax
}
  801f90:	5d                   	pop    %ebp
  801f91:	c3                   	ret    
  801f92:	66 90                	xchg   %ax,%ax
  801f94:	66 90                	xchg   %ax,%ax
  801f96:	66 90                	xchg   %ax,%ax
  801f98:	66 90                	xchg   %ax,%ax
  801f9a:	66 90                	xchg   %ax,%ax
  801f9c:	66 90                	xchg   %ax,%ax
  801f9e:	66 90                	xchg   %ax,%ax

00801fa0 <__udivdi3>:
  801fa0:	55                   	push   %ebp
  801fa1:	57                   	push   %edi
  801fa2:	56                   	push   %esi
  801fa3:	53                   	push   %ebx
  801fa4:	83 ec 1c             	sub    $0x1c,%esp
  801fa7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801faf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fb7:	85 f6                	test   %esi,%esi
  801fb9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fbd:	89 ca                	mov    %ecx,%edx
  801fbf:	89 f8                	mov    %edi,%eax
  801fc1:	75 3d                	jne    802000 <__udivdi3+0x60>
  801fc3:	39 cf                	cmp    %ecx,%edi
  801fc5:	0f 87 c5 00 00 00    	ja     802090 <__udivdi3+0xf0>
  801fcb:	85 ff                	test   %edi,%edi
  801fcd:	89 fd                	mov    %edi,%ebp
  801fcf:	75 0b                	jne    801fdc <__udivdi3+0x3c>
  801fd1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fd6:	31 d2                	xor    %edx,%edx
  801fd8:	f7 f7                	div    %edi
  801fda:	89 c5                	mov    %eax,%ebp
  801fdc:	89 c8                	mov    %ecx,%eax
  801fde:	31 d2                	xor    %edx,%edx
  801fe0:	f7 f5                	div    %ebp
  801fe2:	89 c1                	mov    %eax,%ecx
  801fe4:	89 d8                	mov    %ebx,%eax
  801fe6:	89 cf                	mov    %ecx,%edi
  801fe8:	f7 f5                	div    %ebp
  801fea:	89 c3                	mov    %eax,%ebx
  801fec:	89 d8                	mov    %ebx,%eax
  801fee:	89 fa                	mov    %edi,%edx
  801ff0:	83 c4 1c             	add    $0x1c,%esp
  801ff3:	5b                   	pop    %ebx
  801ff4:	5e                   	pop    %esi
  801ff5:	5f                   	pop    %edi
  801ff6:	5d                   	pop    %ebp
  801ff7:	c3                   	ret    
  801ff8:	90                   	nop
  801ff9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802000:	39 ce                	cmp    %ecx,%esi
  802002:	77 74                	ja     802078 <__udivdi3+0xd8>
  802004:	0f bd fe             	bsr    %esi,%edi
  802007:	83 f7 1f             	xor    $0x1f,%edi
  80200a:	0f 84 98 00 00 00    	je     8020a8 <__udivdi3+0x108>
  802010:	bb 20 00 00 00       	mov    $0x20,%ebx
  802015:	89 f9                	mov    %edi,%ecx
  802017:	89 c5                	mov    %eax,%ebp
  802019:	29 fb                	sub    %edi,%ebx
  80201b:	d3 e6                	shl    %cl,%esi
  80201d:	89 d9                	mov    %ebx,%ecx
  80201f:	d3 ed                	shr    %cl,%ebp
  802021:	89 f9                	mov    %edi,%ecx
  802023:	d3 e0                	shl    %cl,%eax
  802025:	09 ee                	or     %ebp,%esi
  802027:	89 d9                	mov    %ebx,%ecx
  802029:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80202d:	89 d5                	mov    %edx,%ebp
  80202f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802033:	d3 ed                	shr    %cl,%ebp
  802035:	89 f9                	mov    %edi,%ecx
  802037:	d3 e2                	shl    %cl,%edx
  802039:	89 d9                	mov    %ebx,%ecx
  80203b:	d3 e8                	shr    %cl,%eax
  80203d:	09 c2                	or     %eax,%edx
  80203f:	89 d0                	mov    %edx,%eax
  802041:	89 ea                	mov    %ebp,%edx
  802043:	f7 f6                	div    %esi
  802045:	89 d5                	mov    %edx,%ebp
  802047:	89 c3                	mov    %eax,%ebx
  802049:	f7 64 24 0c          	mull   0xc(%esp)
  80204d:	39 d5                	cmp    %edx,%ebp
  80204f:	72 10                	jb     802061 <__udivdi3+0xc1>
  802051:	8b 74 24 08          	mov    0x8(%esp),%esi
  802055:	89 f9                	mov    %edi,%ecx
  802057:	d3 e6                	shl    %cl,%esi
  802059:	39 c6                	cmp    %eax,%esi
  80205b:	73 07                	jae    802064 <__udivdi3+0xc4>
  80205d:	39 d5                	cmp    %edx,%ebp
  80205f:	75 03                	jne    802064 <__udivdi3+0xc4>
  802061:	83 eb 01             	sub    $0x1,%ebx
  802064:	31 ff                	xor    %edi,%edi
  802066:	89 d8                	mov    %ebx,%eax
  802068:	89 fa                	mov    %edi,%edx
  80206a:	83 c4 1c             	add    $0x1c,%esp
  80206d:	5b                   	pop    %ebx
  80206e:	5e                   	pop    %esi
  80206f:	5f                   	pop    %edi
  802070:	5d                   	pop    %ebp
  802071:	c3                   	ret    
  802072:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802078:	31 ff                	xor    %edi,%edi
  80207a:	31 db                	xor    %ebx,%ebx
  80207c:	89 d8                	mov    %ebx,%eax
  80207e:	89 fa                	mov    %edi,%edx
  802080:	83 c4 1c             	add    $0x1c,%esp
  802083:	5b                   	pop    %ebx
  802084:	5e                   	pop    %esi
  802085:	5f                   	pop    %edi
  802086:	5d                   	pop    %ebp
  802087:	c3                   	ret    
  802088:	90                   	nop
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	89 d8                	mov    %ebx,%eax
  802092:	f7 f7                	div    %edi
  802094:	31 ff                	xor    %edi,%edi
  802096:	89 c3                	mov    %eax,%ebx
  802098:	89 d8                	mov    %ebx,%eax
  80209a:	89 fa                	mov    %edi,%edx
  80209c:	83 c4 1c             	add    $0x1c,%esp
  80209f:	5b                   	pop    %ebx
  8020a0:	5e                   	pop    %esi
  8020a1:	5f                   	pop    %edi
  8020a2:	5d                   	pop    %ebp
  8020a3:	c3                   	ret    
  8020a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020a8:	39 ce                	cmp    %ecx,%esi
  8020aa:	72 0c                	jb     8020b8 <__udivdi3+0x118>
  8020ac:	31 db                	xor    %ebx,%ebx
  8020ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020b2:	0f 87 34 ff ff ff    	ja     801fec <__udivdi3+0x4c>
  8020b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020bd:	e9 2a ff ff ff       	jmp    801fec <__udivdi3+0x4c>
  8020c2:	66 90                	xchg   %ax,%ax
  8020c4:	66 90                	xchg   %ax,%ax
  8020c6:	66 90                	xchg   %ax,%ax
  8020c8:	66 90                	xchg   %ax,%ax
  8020ca:	66 90                	xchg   %ax,%ax
  8020cc:	66 90                	xchg   %ax,%ax
  8020ce:	66 90                	xchg   %ax,%ax

008020d0 <__umoddi3>:
  8020d0:	55                   	push   %ebp
  8020d1:	57                   	push   %edi
  8020d2:	56                   	push   %esi
  8020d3:	53                   	push   %ebx
  8020d4:	83 ec 1c             	sub    $0x1c,%esp
  8020d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020e7:	85 d2                	test   %edx,%edx
  8020e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020f1:	89 f3                	mov    %esi,%ebx
  8020f3:	89 3c 24             	mov    %edi,(%esp)
  8020f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020fa:	75 1c                	jne    802118 <__umoddi3+0x48>
  8020fc:	39 f7                	cmp    %esi,%edi
  8020fe:	76 50                	jbe    802150 <__umoddi3+0x80>
  802100:	89 c8                	mov    %ecx,%eax
  802102:	89 f2                	mov    %esi,%edx
  802104:	f7 f7                	div    %edi
  802106:	89 d0                	mov    %edx,%eax
  802108:	31 d2                	xor    %edx,%edx
  80210a:	83 c4 1c             	add    $0x1c,%esp
  80210d:	5b                   	pop    %ebx
  80210e:	5e                   	pop    %esi
  80210f:	5f                   	pop    %edi
  802110:	5d                   	pop    %ebp
  802111:	c3                   	ret    
  802112:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802118:	39 f2                	cmp    %esi,%edx
  80211a:	89 d0                	mov    %edx,%eax
  80211c:	77 52                	ja     802170 <__umoddi3+0xa0>
  80211e:	0f bd ea             	bsr    %edx,%ebp
  802121:	83 f5 1f             	xor    $0x1f,%ebp
  802124:	75 5a                	jne    802180 <__umoddi3+0xb0>
  802126:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80212a:	0f 82 e0 00 00 00    	jb     802210 <__umoddi3+0x140>
  802130:	39 0c 24             	cmp    %ecx,(%esp)
  802133:	0f 86 d7 00 00 00    	jbe    802210 <__umoddi3+0x140>
  802139:	8b 44 24 08          	mov    0x8(%esp),%eax
  80213d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802141:	83 c4 1c             	add    $0x1c,%esp
  802144:	5b                   	pop    %ebx
  802145:	5e                   	pop    %esi
  802146:	5f                   	pop    %edi
  802147:	5d                   	pop    %ebp
  802148:	c3                   	ret    
  802149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802150:	85 ff                	test   %edi,%edi
  802152:	89 fd                	mov    %edi,%ebp
  802154:	75 0b                	jne    802161 <__umoddi3+0x91>
  802156:	b8 01 00 00 00       	mov    $0x1,%eax
  80215b:	31 d2                	xor    %edx,%edx
  80215d:	f7 f7                	div    %edi
  80215f:	89 c5                	mov    %eax,%ebp
  802161:	89 f0                	mov    %esi,%eax
  802163:	31 d2                	xor    %edx,%edx
  802165:	f7 f5                	div    %ebp
  802167:	89 c8                	mov    %ecx,%eax
  802169:	f7 f5                	div    %ebp
  80216b:	89 d0                	mov    %edx,%eax
  80216d:	eb 99                	jmp    802108 <__umoddi3+0x38>
  80216f:	90                   	nop
  802170:	89 c8                	mov    %ecx,%eax
  802172:	89 f2                	mov    %esi,%edx
  802174:	83 c4 1c             	add    $0x1c,%esp
  802177:	5b                   	pop    %ebx
  802178:	5e                   	pop    %esi
  802179:	5f                   	pop    %edi
  80217a:	5d                   	pop    %ebp
  80217b:	c3                   	ret    
  80217c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802180:	8b 34 24             	mov    (%esp),%esi
  802183:	bf 20 00 00 00       	mov    $0x20,%edi
  802188:	89 e9                	mov    %ebp,%ecx
  80218a:	29 ef                	sub    %ebp,%edi
  80218c:	d3 e0                	shl    %cl,%eax
  80218e:	89 f9                	mov    %edi,%ecx
  802190:	89 f2                	mov    %esi,%edx
  802192:	d3 ea                	shr    %cl,%edx
  802194:	89 e9                	mov    %ebp,%ecx
  802196:	09 c2                	or     %eax,%edx
  802198:	89 d8                	mov    %ebx,%eax
  80219a:	89 14 24             	mov    %edx,(%esp)
  80219d:	89 f2                	mov    %esi,%edx
  80219f:	d3 e2                	shl    %cl,%edx
  8021a1:	89 f9                	mov    %edi,%ecx
  8021a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021ab:	d3 e8                	shr    %cl,%eax
  8021ad:	89 e9                	mov    %ebp,%ecx
  8021af:	89 c6                	mov    %eax,%esi
  8021b1:	d3 e3                	shl    %cl,%ebx
  8021b3:	89 f9                	mov    %edi,%ecx
  8021b5:	89 d0                	mov    %edx,%eax
  8021b7:	d3 e8                	shr    %cl,%eax
  8021b9:	89 e9                	mov    %ebp,%ecx
  8021bb:	09 d8                	or     %ebx,%eax
  8021bd:	89 d3                	mov    %edx,%ebx
  8021bf:	89 f2                	mov    %esi,%edx
  8021c1:	f7 34 24             	divl   (%esp)
  8021c4:	89 d6                	mov    %edx,%esi
  8021c6:	d3 e3                	shl    %cl,%ebx
  8021c8:	f7 64 24 04          	mull   0x4(%esp)
  8021cc:	39 d6                	cmp    %edx,%esi
  8021ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021d2:	89 d1                	mov    %edx,%ecx
  8021d4:	89 c3                	mov    %eax,%ebx
  8021d6:	72 08                	jb     8021e0 <__umoddi3+0x110>
  8021d8:	75 11                	jne    8021eb <__umoddi3+0x11b>
  8021da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021de:	73 0b                	jae    8021eb <__umoddi3+0x11b>
  8021e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021e4:	1b 14 24             	sbb    (%esp),%edx
  8021e7:	89 d1                	mov    %edx,%ecx
  8021e9:	89 c3                	mov    %eax,%ebx
  8021eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021ef:	29 da                	sub    %ebx,%edx
  8021f1:	19 ce                	sbb    %ecx,%esi
  8021f3:	89 f9                	mov    %edi,%ecx
  8021f5:	89 f0                	mov    %esi,%eax
  8021f7:	d3 e0                	shl    %cl,%eax
  8021f9:	89 e9                	mov    %ebp,%ecx
  8021fb:	d3 ea                	shr    %cl,%edx
  8021fd:	89 e9                	mov    %ebp,%ecx
  8021ff:	d3 ee                	shr    %cl,%esi
  802201:	09 d0                	or     %edx,%eax
  802203:	89 f2                	mov    %esi,%edx
  802205:	83 c4 1c             	add    $0x1c,%esp
  802208:	5b                   	pop    %ebx
  802209:	5e                   	pop    %esi
  80220a:	5f                   	pop    %edi
  80220b:	5d                   	pop    %ebp
  80220c:	c3                   	ret    
  80220d:	8d 76 00             	lea    0x0(%esi),%esi
  802210:	29 f9                	sub    %edi,%ecx
  802212:	19 d6                	sbb    %edx,%esi
  802214:	89 74 24 04          	mov    %esi,0x4(%esp)
  802218:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80221c:	e9 18 ff ff ff       	jmp    802139 <__umoddi3+0x69>
