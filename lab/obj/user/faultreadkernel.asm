
obj/user/faultreadkernel.debug:     file format elf32-i386


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
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  800039:	ff 35 00 00 10 f0    	pushl  0xf0100000
  80003f:	68 c0 22 80 00       	push   $0x8022c0
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
  80009a:	e8 89 0e 00 00       	call   800f28 <close_all>
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
  8001a4:	e8 77 1e 00 00       	call   802020 <__udivdi3>
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
  8001e7:	e8 64 1f 00 00       	call   802150 <__umoddi3>
  8001ec:	83 c4 14             	add    $0x14,%esp
  8001ef:	0f be 80 f1 22 80 00 	movsbl 0x8022f1(%eax),%eax
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
  8002eb:	ff 24 85 40 24 80 00 	jmp    *0x802440(,%eax,4)
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
  8003af:	8b 14 85 a0 25 80 00 	mov    0x8025a0(,%eax,4),%edx
  8003b6:	85 d2                	test   %edx,%edx
  8003b8:	75 18                	jne    8003d2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003ba:	50                   	push   %eax
  8003bb:	68 09 23 80 00       	push   $0x802309
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
  8003d3:	68 d5 26 80 00       	push   $0x8026d5
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
  8003f7:	b8 02 23 80 00       	mov    $0x802302,%eax
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
  800a72:	68 ff 25 80 00       	push   $0x8025ff
  800a77:	6a 23                	push   $0x23
  800a79:	68 1c 26 80 00       	push   $0x80261c
  800a7e:	e8 1e 14 00 00       	call   801ea1 <_panic>

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
  800af3:	68 ff 25 80 00       	push   $0x8025ff
  800af8:	6a 23                	push   $0x23
  800afa:	68 1c 26 80 00       	push   $0x80261c
  800aff:	e8 9d 13 00 00       	call   801ea1 <_panic>

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
  800b35:	68 ff 25 80 00       	push   $0x8025ff
  800b3a:	6a 23                	push   $0x23
  800b3c:	68 1c 26 80 00       	push   $0x80261c
  800b41:	e8 5b 13 00 00       	call   801ea1 <_panic>

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
  800b77:	68 ff 25 80 00       	push   $0x8025ff
  800b7c:	6a 23                	push   $0x23
  800b7e:	68 1c 26 80 00       	push   $0x80261c
  800b83:	e8 19 13 00 00       	call   801ea1 <_panic>

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
  800bb9:	68 ff 25 80 00       	push   $0x8025ff
  800bbe:	6a 23                	push   $0x23
  800bc0:	68 1c 26 80 00       	push   $0x80261c
  800bc5:	e8 d7 12 00 00       	call   801ea1 <_panic>

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
  800bfb:	68 ff 25 80 00       	push   $0x8025ff
  800c00:	6a 23                	push   $0x23
  800c02:	68 1c 26 80 00       	push   $0x80261c
  800c07:	e8 95 12 00 00       	call   801ea1 <_panic>

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
  800c3d:	68 ff 25 80 00       	push   $0x8025ff
  800c42:	6a 23                	push   $0x23
  800c44:	68 1c 26 80 00       	push   $0x80261c
  800c49:	e8 53 12 00 00       	call   801ea1 <_panic>

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
  800ca1:	68 ff 25 80 00       	push   $0x8025ff
  800ca6:	6a 23                	push   $0x23
  800ca8:	68 1c 26 80 00       	push   $0x80261c
  800cad:	e8 ef 11 00 00       	call   801ea1 <_panic>

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

00800cd9 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	57                   	push   %edi
  800cdd:	56                   	push   %esi
  800cde:	53                   	push   %ebx
  800cdf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce7:	b8 0f 00 00 00       	mov    $0xf,%eax
  800cec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cef:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf2:	89 df                	mov    %ebx,%edi
  800cf4:	89 de                	mov    %ebx,%esi
  800cf6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf8:	85 c0                	test   %eax,%eax
  800cfa:	7e 17                	jle    800d13 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfc:	83 ec 0c             	sub    $0xc,%esp
  800cff:	50                   	push   %eax
  800d00:	6a 0f                	push   $0xf
  800d02:	68 ff 25 80 00       	push   $0x8025ff
  800d07:	6a 23                	push   $0x23
  800d09:	68 1c 26 80 00       	push   $0x80261c
  800d0e:	e8 8e 11 00 00       	call   801ea1 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800d13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5f                   	pop    %edi
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	57                   	push   %edi
  800d1f:	56                   	push   %esi
  800d20:	53                   	push   %ebx
  800d21:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d24:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d29:	b8 10 00 00 00       	mov    $0x10,%eax
  800d2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d31:	8b 55 08             	mov    0x8(%ebp),%edx
  800d34:	89 df                	mov    %ebx,%edi
  800d36:	89 de                	mov    %ebx,%esi
  800d38:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3a:	85 c0                	test   %eax,%eax
  800d3c:	7e 17                	jle    800d55 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3e:	83 ec 0c             	sub    $0xc,%esp
  800d41:	50                   	push   %eax
  800d42:	6a 10                	push   $0x10
  800d44:	68 ff 25 80 00       	push   $0x8025ff
  800d49:	6a 23                	push   $0x23
  800d4b:	68 1c 26 80 00       	push   $0x80261c
  800d50:	e8 4c 11 00 00       	call   801ea1 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  800d55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d58:	5b                   	pop    %ebx
  800d59:	5e                   	pop    %esi
  800d5a:	5f                   	pop    %edi
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    

00800d5d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d60:	8b 45 08             	mov    0x8(%ebp),%eax
  800d63:	05 00 00 00 30       	add    $0x30000000,%eax
  800d68:	c1 e8 0c             	shr    $0xc,%eax
}
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d70:	8b 45 08             	mov    0x8(%ebp),%eax
  800d73:	05 00 00 00 30       	add    $0x30000000,%eax
  800d78:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d7d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d8a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d8f:	89 c2                	mov    %eax,%edx
  800d91:	c1 ea 16             	shr    $0x16,%edx
  800d94:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d9b:	f6 c2 01             	test   $0x1,%dl
  800d9e:	74 11                	je     800db1 <fd_alloc+0x2d>
  800da0:	89 c2                	mov    %eax,%edx
  800da2:	c1 ea 0c             	shr    $0xc,%edx
  800da5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dac:	f6 c2 01             	test   $0x1,%dl
  800daf:	75 09                	jne    800dba <fd_alloc+0x36>
			*fd_store = fd;
  800db1:	89 01                	mov    %eax,(%ecx)
			return 0;
  800db3:	b8 00 00 00 00       	mov    $0x0,%eax
  800db8:	eb 17                	jmp    800dd1 <fd_alloc+0x4d>
  800dba:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dbf:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dc4:	75 c9                	jne    800d8f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dc6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800dcc:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    

00800dd3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dd9:	83 f8 1f             	cmp    $0x1f,%eax
  800ddc:	77 36                	ja     800e14 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dde:	c1 e0 0c             	shl    $0xc,%eax
  800de1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800de6:	89 c2                	mov    %eax,%edx
  800de8:	c1 ea 16             	shr    $0x16,%edx
  800deb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800df2:	f6 c2 01             	test   $0x1,%dl
  800df5:	74 24                	je     800e1b <fd_lookup+0x48>
  800df7:	89 c2                	mov    %eax,%edx
  800df9:	c1 ea 0c             	shr    $0xc,%edx
  800dfc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e03:	f6 c2 01             	test   $0x1,%dl
  800e06:	74 1a                	je     800e22 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e08:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e0b:	89 02                	mov    %eax,(%edx)
	return 0;
  800e0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e12:	eb 13                	jmp    800e27 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e14:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e19:	eb 0c                	jmp    800e27 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e1b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e20:	eb 05                	jmp    800e27 <fd_lookup+0x54>
  800e22:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	83 ec 08             	sub    $0x8,%esp
  800e2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e32:	ba a8 26 80 00       	mov    $0x8026a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e37:	eb 13                	jmp    800e4c <dev_lookup+0x23>
  800e39:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e3c:	39 08                	cmp    %ecx,(%eax)
  800e3e:	75 0c                	jne    800e4c <dev_lookup+0x23>
			*dev = devtab[i];
  800e40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e43:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e45:	b8 00 00 00 00       	mov    $0x0,%eax
  800e4a:	eb 2e                	jmp    800e7a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e4c:	8b 02                	mov    (%edx),%eax
  800e4e:	85 c0                	test   %eax,%eax
  800e50:	75 e7                	jne    800e39 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e52:	a1 08 40 80 00       	mov    0x804008,%eax
  800e57:	8b 40 48             	mov    0x48(%eax),%eax
  800e5a:	83 ec 04             	sub    $0x4,%esp
  800e5d:	51                   	push   %ecx
  800e5e:	50                   	push   %eax
  800e5f:	68 2c 26 80 00       	push   $0x80262c
  800e64:	e8 d8 f2 ff ff       	call   800141 <cprintf>
	*dev = 0;
  800e69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e72:	83 c4 10             	add    $0x10,%esp
  800e75:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e7a:	c9                   	leave  
  800e7b:	c3                   	ret    

00800e7c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	56                   	push   %esi
  800e80:	53                   	push   %ebx
  800e81:	83 ec 10             	sub    $0x10,%esp
  800e84:	8b 75 08             	mov    0x8(%ebp),%esi
  800e87:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e8d:	50                   	push   %eax
  800e8e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e94:	c1 e8 0c             	shr    $0xc,%eax
  800e97:	50                   	push   %eax
  800e98:	e8 36 ff ff ff       	call   800dd3 <fd_lookup>
  800e9d:	83 c4 08             	add    $0x8,%esp
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	78 05                	js     800ea9 <fd_close+0x2d>
	    || fd != fd2)
  800ea4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ea7:	74 0c                	je     800eb5 <fd_close+0x39>
		return (must_exist ? r : 0);
  800ea9:	84 db                	test   %bl,%bl
  800eab:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb0:	0f 44 c2             	cmove  %edx,%eax
  800eb3:	eb 41                	jmp    800ef6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800eb5:	83 ec 08             	sub    $0x8,%esp
  800eb8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ebb:	50                   	push   %eax
  800ebc:	ff 36                	pushl  (%esi)
  800ebe:	e8 66 ff ff ff       	call   800e29 <dev_lookup>
  800ec3:	89 c3                	mov    %eax,%ebx
  800ec5:	83 c4 10             	add    $0x10,%esp
  800ec8:	85 c0                	test   %eax,%eax
  800eca:	78 1a                	js     800ee6 <fd_close+0x6a>
		if (dev->dev_close)
  800ecc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ecf:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ed2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ed7:	85 c0                	test   %eax,%eax
  800ed9:	74 0b                	je     800ee6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800edb:	83 ec 0c             	sub    $0xc,%esp
  800ede:	56                   	push   %esi
  800edf:	ff d0                	call   *%eax
  800ee1:	89 c3                	mov    %eax,%ebx
  800ee3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ee6:	83 ec 08             	sub    $0x8,%esp
  800ee9:	56                   	push   %esi
  800eea:	6a 00                	push   $0x0
  800eec:	e8 5d fc ff ff       	call   800b4e <sys_page_unmap>
	return r;
  800ef1:	83 c4 10             	add    $0x10,%esp
  800ef4:	89 d8                	mov    %ebx,%eax
}
  800ef6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ef9:	5b                   	pop    %ebx
  800efa:	5e                   	pop    %esi
  800efb:	5d                   	pop    %ebp
  800efc:	c3                   	ret    

00800efd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800efd:	55                   	push   %ebp
  800efe:	89 e5                	mov    %esp,%ebp
  800f00:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f03:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f06:	50                   	push   %eax
  800f07:	ff 75 08             	pushl  0x8(%ebp)
  800f0a:	e8 c4 fe ff ff       	call   800dd3 <fd_lookup>
  800f0f:	83 c4 08             	add    $0x8,%esp
  800f12:	85 c0                	test   %eax,%eax
  800f14:	78 10                	js     800f26 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f16:	83 ec 08             	sub    $0x8,%esp
  800f19:	6a 01                	push   $0x1
  800f1b:	ff 75 f4             	pushl  -0xc(%ebp)
  800f1e:	e8 59 ff ff ff       	call   800e7c <fd_close>
  800f23:	83 c4 10             	add    $0x10,%esp
}
  800f26:	c9                   	leave  
  800f27:	c3                   	ret    

00800f28 <close_all>:

void
close_all(void)
{
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
  800f2b:	53                   	push   %ebx
  800f2c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f2f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f34:	83 ec 0c             	sub    $0xc,%esp
  800f37:	53                   	push   %ebx
  800f38:	e8 c0 ff ff ff       	call   800efd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f3d:	83 c3 01             	add    $0x1,%ebx
  800f40:	83 c4 10             	add    $0x10,%esp
  800f43:	83 fb 20             	cmp    $0x20,%ebx
  800f46:	75 ec                	jne    800f34 <close_all+0xc>
		close(i);
}
  800f48:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f4b:	c9                   	leave  
  800f4c:	c3                   	ret    

00800f4d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f4d:	55                   	push   %ebp
  800f4e:	89 e5                	mov    %esp,%ebp
  800f50:	57                   	push   %edi
  800f51:	56                   	push   %esi
  800f52:	53                   	push   %ebx
  800f53:	83 ec 2c             	sub    $0x2c,%esp
  800f56:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f59:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f5c:	50                   	push   %eax
  800f5d:	ff 75 08             	pushl  0x8(%ebp)
  800f60:	e8 6e fe ff ff       	call   800dd3 <fd_lookup>
  800f65:	83 c4 08             	add    $0x8,%esp
  800f68:	85 c0                	test   %eax,%eax
  800f6a:	0f 88 c1 00 00 00    	js     801031 <dup+0xe4>
		return r;
	close(newfdnum);
  800f70:	83 ec 0c             	sub    $0xc,%esp
  800f73:	56                   	push   %esi
  800f74:	e8 84 ff ff ff       	call   800efd <close>

	newfd = INDEX2FD(newfdnum);
  800f79:	89 f3                	mov    %esi,%ebx
  800f7b:	c1 e3 0c             	shl    $0xc,%ebx
  800f7e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f84:	83 c4 04             	add    $0x4,%esp
  800f87:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f8a:	e8 de fd ff ff       	call   800d6d <fd2data>
  800f8f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f91:	89 1c 24             	mov    %ebx,(%esp)
  800f94:	e8 d4 fd ff ff       	call   800d6d <fd2data>
  800f99:	83 c4 10             	add    $0x10,%esp
  800f9c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f9f:	89 f8                	mov    %edi,%eax
  800fa1:	c1 e8 16             	shr    $0x16,%eax
  800fa4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fab:	a8 01                	test   $0x1,%al
  800fad:	74 37                	je     800fe6 <dup+0x99>
  800faf:	89 f8                	mov    %edi,%eax
  800fb1:	c1 e8 0c             	shr    $0xc,%eax
  800fb4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fbb:	f6 c2 01             	test   $0x1,%dl
  800fbe:	74 26                	je     800fe6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fc0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fc7:	83 ec 0c             	sub    $0xc,%esp
  800fca:	25 07 0e 00 00       	and    $0xe07,%eax
  800fcf:	50                   	push   %eax
  800fd0:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fd3:	6a 00                	push   $0x0
  800fd5:	57                   	push   %edi
  800fd6:	6a 00                	push   $0x0
  800fd8:	e8 2f fb ff ff       	call   800b0c <sys_page_map>
  800fdd:	89 c7                	mov    %eax,%edi
  800fdf:	83 c4 20             	add    $0x20,%esp
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	78 2e                	js     801014 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fe6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fe9:	89 d0                	mov    %edx,%eax
  800feb:	c1 e8 0c             	shr    $0xc,%eax
  800fee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ff5:	83 ec 0c             	sub    $0xc,%esp
  800ff8:	25 07 0e 00 00       	and    $0xe07,%eax
  800ffd:	50                   	push   %eax
  800ffe:	53                   	push   %ebx
  800fff:	6a 00                	push   $0x0
  801001:	52                   	push   %edx
  801002:	6a 00                	push   $0x0
  801004:	e8 03 fb ff ff       	call   800b0c <sys_page_map>
  801009:	89 c7                	mov    %eax,%edi
  80100b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80100e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801010:	85 ff                	test   %edi,%edi
  801012:	79 1d                	jns    801031 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801014:	83 ec 08             	sub    $0x8,%esp
  801017:	53                   	push   %ebx
  801018:	6a 00                	push   $0x0
  80101a:	e8 2f fb ff ff       	call   800b4e <sys_page_unmap>
	sys_page_unmap(0, nva);
  80101f:	83 c4 08             	add    $0x8,%esp
  801022:	ff 75 d4             	pushl  -0x2c(%ebp)
  801025:	6a 00                	push   $0x0
  801027:	e8 22 fb ff ff       	call   800b4e <sys_page_unmap>
	return r;
  80102c:	83 c4 10             	add    $0x10,%esp
  80102f:	89 f8                	mov    %edi,%eax
}
  801031:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801034:	5b                   	pop    %ebx
  801035:	5e                   	pop    %esi
  801036:	5f                   	pop    %edi
  801037:	5d                   	pop    %ebp
  801038:	c3                   	ret    

00801039 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	53                   	push   %ebx
  80103d:	83 ec 14             	sub    $0x14,%esp
  801040:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801043:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801046:	50                   	push   %eax
  801047:	53                   	push   %ebx
  801048:	e8 86 fd ff ff       	call   800dd3 <fd_lookup>
  80104d:	83 c4 08             	add    $0x8,%esp
  801050:	89 c2                	mov    %eax,%edx
  801052:	85 c0                	test   %eax,%eax
  801054:	78 6d                	js     8010c3 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801056:	83 ec 08             	sub    $0x8,%esp
  801059:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80105c:	50                   	push   %eax
  80105d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801060:	ff 30                	pushl  (%eax)
  801062:	e8 c2 fd ff ff       	call   800e29 <dev_lookup>
  801067:	83 c4 10             	add    $0x10,%esp
  80106a:	85 c0                	test   %eax,%eax
  80106c:	78 4c                	js     8010ba <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80106e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801071:	8b 42 08             	mov    0x8(%edx),%eax
  801074:	83 e0 03             	and    $0x3,%eax
  801077:	83 f8 01             	cmp    $0x1,%eax
  80107a:	75 21                	jne    80109d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80107c:	a1 08 40 80 00       	mov    0x804008,%eax
  801081:	8b 40 48             	mov    0x48(%eax),%eax
  801084:	83 ec 04             	sub    $0x4,%esp
  801087:	53                   	push   %ebx
  801088:	50                   	push   %eax
  801089:	68 6d 26 80 00       	push   $0x80266d
  80108e:	e8 ae f0 ff ff       	call   800141 <cprintf>
		return -E_INVAL;
  801093:	83 c4 10             	add    $0x10,%esp
  801096:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80109b:	eb 26                	jmp    8010c3 <read+0x8a>
	}
	if (!dev->dev_read)
  80109d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010a0:	8b 40 08             	mov    0x8(%eax),%eax
  8010a3:	85 c0                	test   %eax,%eax
  8010a5:	74 17                	je     8010be <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010a7:	83 ec 04             	sub    $0x4,%esp
  8010aa:	ff 75 10             	pushl  0x10(%ebp)
  8010ad:	ff 75 0c             	pushl  0xc(%ebp)
  8010b0:	52                   	push   %edx
  8010b1:	ff d0                	call   *%eax
  8010b3:	89 c2                	mov    %eax,%edx
  8010b5:	83 c4 10             	add    $0x10,%esp
  8010b8:	eb 09                	jmp    8010c3 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010ba:	89 c2                	mov    %eax,%edx
  8010bc:	eb 05                	jmp    8010c3 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010be:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010c3:	89 d0                	mov    %edx,%eax
  8010c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c8:	c9                   	leave  
  8010c9:	c3                   	ret    

008010ca <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	57                   	push   %edi
  8010ce:	56                   	push   %esi
  8010cf:	53                   	push   %ebx
  8010d0:	83 ec 0c             	sub    $0xc,%esp
  8010d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010d6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010de:	eb 21                	jmp    801101 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010e0:	83 ec 04             	sub    $0x4,%esp
  8010e3:	89 f0                	mov    %esi,%eax
  8010e5:	29 d8                	sub    %ebx,%eax
  8010e7:	50                   	push   %eax
  8010e8:	89 d8                	mov    %ebx,%eax
  8010ea:	03 45 0c             	add    0xc(%ebp),%eax
  8010ed:	50                   	push   %eax
  8010ee:	57                   	push   %edi
  8010ef:	e8 45 ff ff ff       	call   801039 <read>
		if (m < 0)
  8010f4:	83 c4 10             	add    $0x10,%esp
  8010f7:	85 c0                	test   %eax,%eax
  8010f9:	78 10                	js     80110b <readn+0x41>
			return m;
		if (m == 0)
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	74 0a                	je     801109 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010ff:	01 c3                	add    %eax,%ebx
  801101:	39 f3                	cmp    %esi,%ebx
  801103:	72 db                	jb     8010e0 <readn+0x16>
  801105:	89 d8                	mov    %ebx,%eax
  801107:	eb 02                	jmp    80110b <readn+0x41>
  801109:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80110b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80110e:	5b                   	pop    %ebx
  80110f:	5e                   	pop    %esi
  801110:	5f                   	pop    %edi
  801111:	5d                   	pop    %ebp
  801112:	c3                   	ret    

00801113 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801113:	55                   	push   %ebp
  801114:	89 e5                	mov    %esp,%ebp
  801116:	53                   	push   %ebx
  801117:	83 ec 14             	sub    $0x14,%esp
  80111a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80111d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801120:	50                   	push   %eax
  801121:	53                   	push   %ebx
  801122:	e8 ac fc ff ff       	call   800dd3 <fd_lookup>
  801127:	83 c4 08             	add    $0x8,%esp
  80112a:	89 c2                	mov    %eax,%edx
  80112c:	85 c0                	test   %eax,%eax
  80112e:	78 68                	js     801198 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801130:	83 ec 08             	sub    $0x8,%esp
  801133:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801136:	50                   	push   %eax
  801137:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80113a:	ff 30                	pushl  (%eax)
  80113c:	e8 e8 fc ff ff       	call   800e29 <dev_lookup>
  801141:	83 c4 10             	add    $0x10,%esp
  801144:	85 c0                	test   %eax,%eax
  801146:	78 47                	js     80118f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801148:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80114b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80114f:	75 21                	jne    801172 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801151:	a1 08 40 80 00       	mov    0x804008,%eax
  801156:	8b 40 48             	mov    0x48(%eax),%eax
  801159:	83 ec 04             	sub    $0x4,%esp
  80115c:	53                   	push   %ebx
  80115d:	50                   	push   %eax
  80115e:	68 89 26 80 00       	push   $0x802689
  801163:	e8 d9 ef ff ff       	call   800141 <cprintf>
		return -E_INVAL;
  801168:	83 c4 10             	add    $0x10,%esp
  80116b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801170:	eb 26                	jmp    801198 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801172:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801175:	8b 52 0c             	mov    0xc(%edx),%edx
  801178:	85 d2                	test   %edx,%edx
  80117a:	74 17                	je     801193 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80117c:	83 ec 04             	sub    $0x4,%esp
  80117f:	ff 75 10             	pushl  0x10(%ebp)
  801182:	ff 75 0c             	pushl  0xc(%ebp)
  801185:	50                   	push   %eax
  801186:	ff d2                	call   *%edx
  801188:	89 c2                	mov    %eax,%edx
  80118a:	83 c4 10             	add    $0x10,%esp
  80118d:	eb 09                	jmp    801198 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118f:	89 c2                	mov    %eax,%edx
  801191:	eb 05                	jmp    801198 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801193:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801198:	89 d0                	mov    %edx,%eax
  80119a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80119d:	c9                   	leave  
  80119e:	c3                   	ret    

0080119f <seek>:

int
seek(int fdnum, off_t offset)
{
  80119f:	55                   	push   %ebp
  8011a0:	89 e5                	mov    %esp,%ebp
  8011a2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011a5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011a8:	50                   	push   %eax
  8011a9:	ff 75 08             	pushl  0x8(%ebp)
  8011ac:	e8 22 fc ff ff       	call   800dd3 <fd_lookup>
  8011b1:	83 c4 08             	add    $0x8,%esp
  8011b4:	85 c0                	test   %eax,%eax
  8011b6:	78 0e                	js     8011c6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011be:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011c6:	c9                   	leave  
  8011c7:	c3                   	ret    

008011c8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
  8011cb:	53                   	push   %ebx
  8011cc:	83 ec 14             	sub    $0x14,%esp
  8011cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d5:	50                   	push   %eax
  8011d6:	53                   	push   %ebx
  8011d7:	e8 f7 fb ff ff       	call   800dd3 <fd_lookup>
  8011dc:	83 c4 08             	add    $0x8,%esp
  8011df:	89 c2                	mov    %eax,%edx
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	78 65                	js     80124a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e5:	83 ec 08             	sub    $0x8,%esp
  8011e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011eb:	50                   	push   %eax
  8011ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ef:	ff 30                	pushl  (%eax)
  8011f1:	e8 33 fc ff ff       	call   800e29 <dev_lookup>
  8011f6:	83 c4 10             	add    $0x10,%esp
  8011f9:	85 c0                	test   %eax,%eax
  8011fb:	78 44                	js     801241 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801200:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801204:	75 21                	jne    801227 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801206:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80120b:	8b 40 48             	mov    0x48(%eax),%eax
  80120e:	83 ec 04             	sub    $0x4,%esp
  801211:	53                   	push   %ebx
  801212:	50                   	push   %eax
  801213:	68 4c 26 80 00       	push   $0x80264c
  801218:	e8 24 ef ff ff       	call   800141 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80121d:	83 c4 10             	add    $0x10,%esp
  801220:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801225:	eb 23                	jmp    80124a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801227:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80122a:	8b 52 18             	mov    0x18(%edx),%edx
  80122d:	85 d2                	test   %edx,%edx
  80122f:	74 14                	je     801245 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801231:	83 ec 08             	sub    $0x8,%esp
  801234:	ff 75 0c             	pushl  0xc(%ebp)
  801237:	50                   	push   %eax
  801238:	ff d2                	call   *%edx
  80123a:	89 c2                	mov    %eax,%edx
  80123c:	83 c4 10             	add    $0x10,%esp
  80123f:	eb 09                	jmp    80124a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801241:	89 c2                	mov    %eax,%edx
  801243:	eb 05                	jmp    80124a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801245:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80124a:	89 d0                	mov    %edx,%eax
  80124c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80124f:	c9                   	leave  
  801250:	c3                   	ret    

00801251 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801251:	55                   	push   %ebp
  801252:	89 e5                	mov    %esp,%ebp
  801254:	53                   	push   %ebx
  801255:	83 ec 14             	sub    $0x14,%esp
  801258:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80125b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80125e:	50                   	push   %eax
  80125f:	ff 75 08             	pushl  0x8(%ebp)
  801262:	e8 6c fb ff ff       	call   800dd3 <fd_lookup>
  801267:	83 c4 08             	add    $0x8,%esp
  80126a:	89 c2                	mov    %eax,%edx
  80126c:	85 c0                	test   %eax,%eax
  80126e:	78 58                	js     8012c8 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801270:	83 ec 08             	sub    $0x8,%esp
  801273:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801276:	50                   	push   %eax
  801277:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127a:	ff 30                	pushl  (%eax)
  80127c:	e8 a8 fb ff ff       	call   800e29 <dev_lookup>
  801281:	83 c4 10             	add    $0x10,%esp
  801284:	85 c0                	test   %eax,%eax
  801286:	78 37                	js     8012bf <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801288:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80128b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80128f:	74 32                	je     8012c3 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801291:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801294:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80129b:	00 00 00 
	stat->st_isdir = 0;
  80129e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012a5:	00 00 00 
	stat->st_dev = dev;
  8012a8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012ae:	83 ec 08             	sub    $0x8,%esp
  8012b1:	53                   	push   %ebx
  8012b2:	ff 75 f0             	pushl  -0x10(%ebp)
  8012b5:	ff 50 14             	call   *0x14(%eax)
  8012b8:	89 c2                	mov    %eax,%edx
  8012ba:	83 c4 10             	add    $0x10,%esp
  8012bd:	eb 09                	jmp    8012c8 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012bf:	89 c2                	mov    %eax,%edx
  8012c1:	eb 05                	jmp    8012c8 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012c3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012c8:	89 d0                	mov    %edx,%eax
  8012ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012cd:	c9                   	leave  
  8012ce:	c3                   	ret    

008012cf <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012cf:	55                   	push   %ebp
  8012d0:	89 e5                	mov    %esp,%ebp
  8012d2:	56                   	push   %esi
  8012d3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012d4:	83 ec 08             	sub    $0x8,%esp
  8012d7:	6a 00                	push   $0x0
  8012d9:	ff 75 08             	pushl  0x8(%ebp)
  8012dc:	e8 d6 01 00 00       	call   8014b7 <open>
  8012e1:	89 c3                	mov    %eax,%ebx
  8012e3:	83 c4 10             	add    $0x10,%esp
  8012e6:	85 c0                	test   %eax,%eax
  8012e8:	78 1b                	js     801305 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012ea:	83 ec 08             	sub    $0x8,%esp
  8012ed:	ff 75 0c             	pushl  0xc(%ebp)
  8012f0:	50                   	push   %eax
  8012f1:	e8 5b ff ff ff       	call   801251 <fstat>
  8012f6:	89 c6                	mov    %eax,%esi
	close(fd);
  8012f8:	89 1c 24             	mov    %ebx,(%esp)
  8012fb:	e8 fd fb ff ff       	call   800efd <close>
	return r;
  801300:	83 c4 10             	add    $0x10,%esp
  801303:	89 f0                	mov    %esi,%eax
}
  801305:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801308:	5b                   	pop    %ebx
  801309:	5e                   	pop    %esi
  80130a:	5d                   	pop    %ebp
  80130b:	c3                   	ret    

0080130c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80130c:	55                   	push   %ebp
  80130d:	89 e5                	mov    %esp,%ebp
  80130f:	56                   	push   %esi
  801310:	53                   	push   %ebx
  801311:	89 c6                	mov    %eax,%esi
  801313:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801315:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80131c:	75 12                	jne    801330 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80131e:	83 ec 0c             	sub    $0xc,%esp
  801321:	6a 01                	push   $0x1
  801323:	e8 7a 0c 00 00       	call   801fa2 <ipc_find_env>
  801328:	a3 00 40 80 00       	mov    %eax,0x804000
  80132d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801330:	6a 07                	push   $0x7
  801332:	68 00 50 80 00       	push   $0x805000
  801337:	56                   	push   %esi
  801338:	ff 35 00 40 80 00    	pushl  0x804000
  80133e:	e8 0b 0c 00 00       	call   801f4e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801343:	83 c4 0c             	add    $0xc,%esp
  801346:	6a 00                	push   $0x0
  801348:	53                   	push   %ebx
  801349:	6a 00                	push   $0x0
  80134b:	e8 97 0b 00 00       	call   801ee7 <ipc_recv>
}
  801350:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801353:	5b                   	pop    %ebx
  801354:	5e                   	pop    %esi
  801355:	5d                   	pop    %ebp
  801356:	c3                   	ret    

00801357 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801357:	55                   	push   %ebp
  801358:	89 e5                	mov    %esp,%ebp
  80135a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80135d:	8b 45 08             	mov    0x8(%ebp),%eax
  801360:	8b 40 0c             	mov    0xc(%eax),%eax
  801363:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801368:	8b 45 0c             	mov    0xc(%ebp),%eax
  80136b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801370:	ba 00 00 00 00       	mov    $0x0,%edx
  801375:	b8 02 00 00 00       	mov    $0x2,%eax
  80137a:	e8 8d ff ff ff       	call   80130c <fsipc>
}
  80137f:	c9                   	leave  
  801380:	c3                   	ret    

00801381 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801381:	55                   	push   %ebp
  801382:	89 e5                	mov    %esp,%ebp
  801384:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801387:	8b 45 08             	mov    0x8(%ebp),%eax
  80138a:	8b 40 0c             	mov    0xc(%eax),%eax
  80138d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801392:	ba 00 00 00 00       	mov    $0x0,%edx
  801397:	b8 06 00 00 00       	mov    $0x6,%eax
  80139c:	e8 6b ff ff ff       	call   80130c <fsipc>
}
  8013a1:	c9                   	leave  
  8013a2:	c3                   	ret    

008013a3 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013a3:	55                   	push   %ebp
  8013a4:	89 e5                	mov    %esp,%ebp
  8013a6:	53                   	push   %ebx
  8013a7:	83 ec 04             	sub    $0x4,%esp
  8013aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8013b3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8013bd:	b8 05 00 00 00       	mov    $0x5,%eax
  8013c2:	e8 45 ff ff ff       	call   80130c <fsipc>
  8013c7:	85 c0                	test   %eax,%eax
  8013c9:	78 2c                	js     8013f7 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013cb:	83 ec 08             	sub    $0x8,%esp
  8013ce:	68 00 50 80 00       	push   $0x805000
  8013d3:	53                   	push   %ebx
  8013d4:	e8 ed f2 ff ff       	call   8006c6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013d9:	a1 80 50 80 00       	mov    0x805080,%eax
  8013de:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013e4:	a1 84 50 80 00       	mov    0x805084,%eax
  8013e9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013ef:	83 c4 10             	add    $0x10,%esp
  8013f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fa:	c9                   	leave  
  8013fb:	c3                   	ret    

008013fc <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013fc:	55                   	push   %ebp
  8013fd:	89 e5                	mov    %esp,%ebp
  8013ff:	83 ec 0c             	sub    $0xc,%esp
  801402:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801405:	8b 55 08             	mov    0x8(%ebp),%edx
  801408:	8b 52 0c             	mov    0xc(%edx),%edx
  80140b:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801411:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801416:	50                   	push   %eax
  801417:	ff 75 0c             	pushl  0xc(%ebp)
  80141a:	68 08 50 80 00       	push   $0x805008
  80141f:	e8 34 f4 ff ff       	call   800858 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801424:	ba 00 00 00 00       	mov    $0x0,%edx
  801429:	b8 04 00 00 00       	mov    $0x4,%eax
  80142e:	e8 d9 fe ff ff       	call   80130c <fsipc>

}
  801433:	c9                   	leave  
  801434:	c3                   	ret    

00801435 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801435:	55                   	push   %ebp
  801436:	89 e5                	mov    %esp,%ebp
  801438:	56                   	push   %esi
  801439:	53                   	push   %ebx
  80143a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80143d:	8b 45 08             	mov    0x8(%ebp),%eax
  801440:	8b 40 0c             	mov    0xc(%eax),%eax
  801443:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801448:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80144e:	ba 00 00 00 00       	mov    $0x0,%edx
  801453:	b8 03 00 00 00       	mov    $0x3,%eax
  801458:	e8 af fe ff ff       	call   80130c <fsipc>
  80145d:	89 c3                	mov    %eax,%ebx
  80145f:	85 c0                	test   %eax,%eax
  801461:	78 4b                	js     8014ae <devfile_read+0x79>
		return r;
	assert(r <= n);
  801463:	39 c6                	cmp    %eax,%esi
  801465:	73 16                	jae    80147d <devfile_read+0x48>
  801467:	68 bc 26 80 00       	push   $0x8026bc
  80146c:	68 c3 26 80 00       	push   $0x8026c3
  801471:	6a 7c                	push   $0x7c
  801473:	68 d8 26 80 00       	push   $0x8026d8
  801478:	e8 24 0a 00 00       	call   801ea1 <_panic>
	assert(r <= PGSIZE);
  80147d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801482:	7e 16                	jle    80149a <devfile_read+0x65>
  801484:	68 e3 26 80 00       	push   $0x8026e3
  801489:	68 c3 26 80 00       	push   $0x8026c3
  80148e:	6a 7d                	push   $0x7d
  801490:	68 d8 26 80 00       	push   $0x8026d8
  801495:	e8 07 0a 00 00       	call   801ea1 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80149a:	83 ec 04             	sub    $0x4,%esp
  80149d:	50                   	push   %eax
  80149e:	68 00 50 80 00       	push   $0x805000
  8014a3:	ff 75 0c             	pushl  0xc(%ebp)
  8014a6:	e8 ad f3 ff ff       	call   800858 <memmove>
	return r;
  8014ab:	83 c4 10             	add    $0x10,%esp
}
  8014ae:	89 d8                	mov    %ebx,%eax
  8014b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b3:	5b                   	pop    %ebx
  8014b4:	5e                   	pop    %esi
  8014b5:	5d                   	pop    %ebp
  8014b6:	c3                   	ret    

008014b7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014b7:	55                   	push   %ebp
  8014b8:	89 e5                	mov    %esp,%ebp
  8014ba:	53                   	push   %ebx
  8014bb:	83 ec 20             	sub    $0x20,%esp
  8014be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014c1:	53                   	push   %ebx
  8014c2:	e8 c6 f1 ff ff       	call   80068d <strlen>
  8014c7:	83 c4 10             	add    $0x10,%esp
  8014ca:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014cf:	7f 67                	jg     801538 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014d1:	83 ec 0c             	sub    $0xc,%esp
  8014d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d7:	50                   	push   %eax
  8014d8:	e8 a7 f8 ff ff       	call   800d84 <fd_alloc>
  8014dd:	83 c4 10             	add    $0x10,%esp
		return r;
  8014e0:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014e2:	85 c0                	test   %eax,%eax
  8014e4:	78 57                	js     80153d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014e6:	83 ec 08             	sub    $0x8,%esp
  8014e9:	53                   	push   %ebx
  8014ea:	68 00 50 80 00       	push   $0x805000
  8014ef:	e8 d2 f1 ff ff       	call   8006c6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f7:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014ff:	b8 01 00 00 00       	mov    $0x1,%eax
  801504:	e8 03 fe ff ff       	call   80130c <fsipc>
  801509:	89 c3                	mov    %eax,%ebx
  80150b:	83 c4 10             	add    $0x10,%esp
  80150e:	85 c0                	test   %eax,%eax
  801510:	79 14                	jns    801526 <open+0x6f>
		fd_close(fd, 0);
  801512:	83 ec 08             	sub    $0x8,%esp
  801515:	6a 00                	push   $0x0
  801517:	ff 75 f4             	pushl  -0xc(%ebp)
  80151a:	e8 5d f9 ff ff       	call   800e7c <fd_close>
		return r;
  80151f:	83 c4 10             	add    $0x10,%esp
  801522:	89 da                	mov    %ebx,%edx
  801524:	eb 17                	jmp    80153d <open+0x86>
	}

	return fd2num(fd);
  801526:	83 ec 0c             	sub    $0xc,%esp
  801529:	ff 75 f4             	pushl  -0xc(%ebp)
  80152c:	e8 2c f8 ff ff       	call   800d5d <fd2num>
  801531:	89 c2                	mov    %eax,%edx
  801533:	83 c4 10             	add    $0x10,%esp
  801536:	eb 05                	jmp    80153d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801538:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80153d:	89 d0                	mov    %edx,%eax
  80153f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801542:	c9                   	leave  
  801543:	c3                   	ret    

00801544 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801544:	55                   	push   %ebp
  801545:	89 e5                	mov    %esp,%ebp
  801547:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80154a:	ba 00 00 00 00       	mov    $0x0,%edx
  80154f:	b8 08 00 00 00       	mov    $0x8,%eax
  801554:	e8 b3 fd ff ff       	call   80130c <fsipc>
}
  801559:	c9                   	leave  
  80155a:	c3                   	ret    

0080155b <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801561:	68 ef 26 80 00       	push   $0x8026ef
  801566:	ff 75 0c             	pushl  0xc(%ebp)
  801569:	e8 58 f1 ff ff       	call   8006c6 <strcpy>
	return 0;
}
  80156e:	b8 00 00 00 00       	mov    $0x0,%eax
  801573:	c9                   	leave  
  801574:	c3                   	ret    

00801575 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801575:	55                   	push   %ebp
  801576:	89 e5                	mov    %esp,%ebp
  801578:	53                   	push   %ebx
  801579:	83 ec 10             	sub    $0x10,%esp
  80157c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80157f:	53                   	push   %ebx
  801580:	e8 56 0a 00 00       	call   801fdb <pageref>
  801585:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801588:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80158d:	83 f8 01             	cmp    $0x1,%eax
  801590:	75 10                	jne    8015a2 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801592:	83 ec 0c             	sub    $0xc,%esp
  801595:	ff 73 0c             	pushl  0xc(%ebx)
  801598:	e8 c0 02 00 00       	call   80185d <nsipc_close>
  80159d:	89 c2                	mov    %eax,%edx
  80159f:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8015a2:	89 d0                	mov    %edx,%eax
  8015a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a7:	c9                   	leave  
  8015a8:	c3                   	ret    

008015a9 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8015a9:	55                   	push   %ebp
  8015aa:	89 e5                	mov    %esp,%ebp
  8015ac:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8015af:	6a 00                	push   $0x0
  8015b1:	ff 75 10             	pushl  0x10(%ebp)
  8015b4:	ff 75 0c             	pushl  0xc(%ebp)
  8015b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ba:	ff 70 0c             	pushl  0xc(%eax)
  8015bd:	e8 78 03 00 00       	call   80193a <nsipc_send>
}
  8015c2:	c9                   	leave  
  8015c3:	c3                   	ret    

008015c4 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8015c4:	55                   	push   %ebp
  8015c5:	89 e5                	mov    %esp,%ebp
  8015c7:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8015ca:	6a 00                	push   $0x0
  8015cc:	ff 75 10             	pushl  0x10(%ebp)
  8015cf:	ff 75 0c             	pushl  0xc(%ebp)
  8015d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d5:	ff 70 0c             	pushl  0xc(%eax)
  8015d8:	e8 f1 02 00 00       	call   8018ce <nsipc_recv>
}
  8015dd:	c9                   	leave  
  8015de:	c3                   	ret    

008015df <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8015df:	55                   	push   %ebp
  8015e0:	89 e5                	mov    %esp,%ebp
  8015e2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8015e5:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015e8:	52                   	push   %edx
  8015e9:	50                   	push   %eax
  8015ea:	e8 e4 f7 ff ff       	call   800dd3 <fd_lookup>
  8015ef:	83 c4 10             	add    $0x10,%esp
  8015f2:	85 c0                	test   %eax,%eax
  8015f4:	78 17                	js     80160d <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8015f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f9:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8015ff:	39 08                	cmp    %ecx,(%eax)
  801601:	75 05                	jne    801608 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801603:	8b 40 0c             	mov    0xc(%eax),%eax
  801606:	eb 05                	jmp    80160d <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801608:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80160d:	c9                   	leave  
  80160e:	c3                   	ret    

0080160f <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80160f:	55                   	push   %ebp
  801610:	89 e5                	mov    %esp,%ebp
  801612:	56                   	push   %esi
  801613:	53                   	push   %ebx
  801614:	83 ec 1c             	sub    $0x1c,%esp
  801617:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801619:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161c:	50                   	push   %eax
  80161d:	e8 62 f7 ff ff       	call   800d84 <fd_alloc>
  801622:	89 c3                	mov    %eax,%ebx
  801624:	83 c4 10             	add    $0x10,%esp
  801627:	85 c0                	test   %eax,%eax
  801629:	78 1b                	js     801646 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80162b:	83 ec 04             	sub    $0x4,%esp
  80162e:	68 07 04 00 00       	push   $0x407
  801633:	ff 75 f4             	pushl  -0xc(%ebp)
  801636:	6a 00                	push   $0x0
  801638:	e8 8c f4 ff ff       	call   800ac9 <sys_page_alloc>
  80163d:	89 c3                	mov    %eax,%ebx
  80163f:	83 c4 10             	add    $0x10,%esp
  801642:	85 c0                	test   %eax,%eax
  801644:	79 10                	jns    801656 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801646:	83 ec 0c             	sub    $0xc,%esp
  801649:	56                   	push   %esi
  80164a:	e8 0e 02 00 00       	call   80185d <nsipc_close>
		return r;
  80164f:	83 c4 10             	add    $0x10,%esp
  801652:	89 d8                	mov    %ebx,%eax
  801654:	eb 24                	jmp    80167a <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801656:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80165c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80165f:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801661:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801664:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80166b:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80166e:	83 ec 0c             	sub    $0xc,%esp
  801671:	50                   	push   %eax
  801672:	e8 e6 f6 ff ff       	call   800d5d <fd2num>
  801677:	83 c4 10             	add    $0x10,%esp
}
  80167a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167d:	5b                   	pop    %ebx
  80167e:	5e                   	pop    %esi
  80167f:	5d                   	pop    %ebp
  801680:	c3                   	ret    

00801681 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
  801684:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801687:	8b 45 08             	mov    0x8(%ebp),%eax
  80168a:	e8 50 ff ff ff       	call   8015df <fd2sockid>
		return r;
  80168f:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801691:	85 c0                	test   %eax,%eax
  801693:	78 1f                	js     8016b4 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801695:	83 ec 04             	sub    $0x4,%esp
  801698:	ff 75 10             	pushl  0x10(%ebp)
  80169b:	ff 75 0c             	pushl  0xc(%ebp)
  80169e:	50                   	push   %eax
  80169f:	e8 12 01 00 00       	call   8017b6 <nsipc_accept>
  8016a4:	83 c4 10             	add    $0x10,%esp
		return r;
  8016a7:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016a9:	85 c0                	test   %eax,%eax
  8016ab:	78 07                	js     8016b4 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8016ad:	e8 5d ff ff ff       	call   80160f <alloc_sockfd>
  8016b2:	89 c1                	mov    %eax,%ecx
}
  8016b4:	89 c8                	mov    %ecx,%eax
  8016b6:	c9                   	leave  
  8016b7:	c3                   	ret    

008016b8 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8016b8:	55                   	push   %ebp
  8016b9:	89 e5                	mov    %esp,%ebp
  8016bb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016be:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c1:	e8 19 ff ff ff       	call   8015df <fd2sockid>
  8016c6:	85 c0                	test   %eax,%eax
  8016c8:	78 12                	js     8016dc <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8016ca:	83 ec 04             	sub    $0x4,%esp
  8016cd:	ff 75 10             	pushl  0x10(%ebp)
  8016d0:	ff 75 0c             	pushl  0xc(%ebp)
  8016d3:	50                   	push   %eax
  8016d4:	e8 2d 01 00 00       	call   801806 <nsipc_bind>
  8016d9:	83 c4 10             	add    $0x10,%esp
}
  8016dc:	c9                   	leave  
  8016dd:	c3                   	ret    

008016de <shutdown>:

int
shutdown(int s, int how)
{
  8016de:	55                   	push   %ebp
  8016df:	89 e5                	mov    %esp,%ebp
  8016e1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e7:	e8 f3 fe ff ff       	call   8015df <fd2sockid>
  8016ec:	85 c0                	test   %eax,%eax
  8016ee:	78 0f                	js     8016ff <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8016f0:	83 ec 08             	sub    $0x8,%esp
  8016f3:	ff 75 0c             	pushl  0xc(%ebp)
  8016f6:	50                   	push   %eax
  8016f7:	e8 3f 01 00 00       	call   80183b <nsipc_shutdown>
  8016fc:	83 c4 10             	add    $0x10,%esp
}
  8016ff:	c9                   	leave  
  801700:	c3                   	ret    

00801701 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801701:	55                   	push   %ebp
  801702:	89 e5                	mov    %esp,%ebp
  801704:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801707:	8b 45 08             	mov    0x8(%ebp),%eax
  80170a:	e8 d0 fe ff ff       	call   8015df <fd2sockid>
  80170f:	85 c0                	test   %eax,%eax
  801711:	78 12                	js     801725 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801713:	83 ec 04             	sub    $0x4,%esp
  801716:	ff 75 10             	pushl  0x10(%ebp)
  801719:	ff 75 0c             	pushl  0xc(%ebp)
  80171c:	50                   	push   %eax
  80171d:	e8 55 01 00 00       	call   801877 <nsipc_connect>
  801722:	83 c4 10             	add    $0x10,%esp
}
  801725:	c9                   	leave  
  801726:	c3                   	ret    

00801727 <listen>:

int
listen(int s, int backlog)
{
  801727:	55                   	push   %ebp
  801728:	89 e5                	mov    %esp,%ebp
  80172a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80172d:	8b 45 08             	mov    0x8(%ebp),%eax
  801730:	e8 aa fe ff ff       	call   8015df <fd2sockid>
  801735:	85 c0                	test   %eax,%eax
  801737:	78 0f                	js     801748 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801739:	83 ec 08             	sub    $0x8,%esp
  80173c:	ff 75 0c             	pushl  0xc(%ebp)
  80173f:	50                   	push   %eax
  801740:	e8 67 01 00 00       	call   8018ac <nsipc_listen>
  801745:	83 c4 10             	add    $0x10,%esp
}
  801748:	c9                   	leave  
  801749:	c3                   	ret    

0080174a <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80174a:	55                   	push   %ebp
  80174b:	89 e5                	mov    %esp,%ebp
  80174d:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801750:	ff 75 10             	pushl  0x10(%ebp)
  801753:	ff 75 0c             	pushl  0xc(%ebp)
  801756:	ff 75 08             	pushl  0x8(%ebp)
  801759:	e8 3a 02 00 00       	call   801998 <nsipc_socket>
  80175e:	83 c4 10             	add    $0x10,%esp
  801761:	85 c0                	test   %eax,%eax
  801763:	78 05                	js     80176a <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801765:	e8 a5 fe ff ff       	call   80160f <alloc_sockfd>
}
  80176a:	c9                   	leave  
  80176b:	c3                   	ret    

0080176c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80176c:	55                   	push   %ebp
  80176d:	89 e5                	mov    %esp,%ebp
  80176f:	53                   	push   %ebx
  801770:	83 ec 04             	sub    $0x4,%esp
  801773:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801775:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80177c:	75 12                	jne    801790 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80177e:	83 ec 0c             	sub    $0xc,%esp
  801781:	6a 02                	push   $0x2
  801783:	e8 1a 08 00 00       	call   801fa2 <ipc_find_env>
  801788:	a3 04 40 80 00       	mov    %eax,0x804004
  80178d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801790:	6a 07                	push   $0x7
  801792:	68 00 60 80 00       	push   $0x806000
  801797:	53                   	push   %ebx
  801798:	ff 35 04 40 80 00    	pushl  0x804004
  80179e:	e8 ab 07 00 00       	call   801f4e <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8017a3:	83 c4 0c             	add    $0xc,%esp
  8017a6:	6a 00                	push   $0x0
  8017a8:	6a 00                	push   $0x0
  8017aa:	6a 00                	push   $0x0
  8017ac:	e8 36 07 00 00       	call   801ee7 <ipc_recv>
}
  8017b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b4:	c9                   	leave  
  8017b5:	c3                   	ret    

008017b6 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017b6:	55                   	push   %ebp
  8017b7:	89 e5                	mov    %esp,%ebp
  8017b9:	56                   	push   %esi
  8017ba:	53                   	push   %ebx
  8017bb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8017be:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8017c6:	8b 06                	mov    (%esi),%eax
  8017c8:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8017cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8017d2:	e8 95 ff ff ff       	call   80176c <nsipc>
  8017d7:	89 c3                	mov    %eax,%ebx
  8017d9:	85 c0                	test   %eax,%eax
  8017db:	78 20                	js     8017fd <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8017dd:	83 ec 04             	sub    $0x4,%esp
  8017e0:	ff 35 10 60 80 00    	pushl  0x806010
  8017e6:	68 00 60 80 00       	push   $0x806000
  8017eb:	ff 75 0c             	pushl  0xc(%ebp)
  8017ee:	e8 65 f0 ff ff       	call   800858 <memmove>
		*addrlen = ret->ret_addrlen;
  8017f3:	a1 10 60 80 00       	mov    0x806010,%eax
  8017f8:	89 06                	mov    %eax,(%esi)
  8017fa:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8017fd:	89 d8                	mov    %ebx,%eax
  8017ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801802:	5b                   	pop    %ebx
  801803:	5e                   	pop    %esi
  801804:	5d                   	pop    %ebp
  801805:	c3                   	ret    

00801806 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801806:	55                   	push   %ebp
  801807:	89 e5                	mov    %esp,%ebp
  801809:	53                   	push   %ebx
  80180a:	83 ec 08             	sub    $0x8,%esp
  80180d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801810:	8b 45 08             	mov    0x8(%ebp),%eax
  801813:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801818:	53                   	push   %ebx
  801819:	ff 75 0c             	pushl  0xc(%ebp)
  80181c:	68 04 60 80 00       	push   $0x806004
  801821:	e8 32 f0 ff ff       	call   800858 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801826:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80182c:	b8 02 00 00 00       	mov    $0x2,%eax
  801831:	e8 36 ff ff ff       	call   80176c <nsipc>
}
  801836:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801839:	c9                   	leave  
  80183a:	c3                   	ret    

0080183b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80183b:	55                   	push   %ebp
  80183c:	89 e5                	mov    %esp,%ebp
  80183e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801841:	8b 45 08             	mov    0x8(%ebp),%eax
  801844:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801849:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184c:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801851:	b8 03 00 00 00       	mov    $0x3,%eax
  801856:	e8 11 ff ff ff       	call   80176c <nsipc>
}
  80185b:	c9                   	leave  
  80185c:	c3                   	ret    

0080185d <nsipc_close>:

int
nsipc_close(int s)
{
  80185d:	55                   	push   %ebp
  80185e:	89 e5                	mov    %esp,%ebp
  801860:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801863:	8b 45 08             	mov    0x8(%ebp),%eax
  801866:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  80186b:	b8 04 00 00 00       	mov    $0x4,%eax
  801870:	e8 f7 fe ff ff       	call   80176c <nsipc>
}
  801875:	c9                   	leave  
  801876:	c3                   	ret    

00801877 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801877:	55                   	push   %ebp
  801878:	89 e5                	mov    %esp,%ebp
  80187a:	53                   	push   %ebx
  80187b:	83 ec 08             	sub    $0x8,%esp
  80187e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801881:	8b 45 08             	mov    0x8(%ebp),%eax
  801884:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801889:	53                   	push   %ebx
  80188a:	ff 75 0c             	pushl  0xc(%ebp)
  80188d:	68 04 60 80 00       	push   $0x806004
  801892:	e8 c1 ef ff ff       	call   800858 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801897:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  80189d:	b8 05 00 00 00       	mov    $0x5,%eax
  8018a2:	e8 c5 fe ff ff       	call   80176c <nsipc>
}
  8018a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018aa:	c9                   	leave  
  8018ab:	c3                   	ret    

008018ac <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8018ac:	55                   	push   %ebp
  8018ad:	89 e5                	mov    %esp,%ebp
  8018af:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8018b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8018ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018bd:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8018c2:	b8 06 00 00 00       	mov    $0x6,%eax
  8018c7:	e8 a0 fe ff ff       	call   80176c <nsipc>
}
  8018cc:	c9                   	leave  
  8018cd:	c3                   	ret    

008018ce <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8018ce:	55                   	push   %ebp
  8018cf:	89 e5                	mov    %esp,%ebp
  8018d1:	56                   	push   %esi
  8018d2:	53                   	push   %ebx
  8018d3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8018d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8018de:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8018e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8018e7:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8018ec:	b8 07 00 00 00       	mov    $0x7,%eax
  8018f1:	e8 76 fe ff ff       	call   80176c <nsipc>
  8018f6:	89 c3                	mov    %eax,%ebx
  8018f8:	85 c0                	test   %eax,%eax
  8018fa:	78 35                	js     801931 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8018fc:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801901:	7f 04                	jg     801907 <nsipc_recv+0x39>
  801903:	39 c6                	cmp    %eax,%esi
  801905:	7d 16                	jge    80191d <nsipc_recv+0x4f>
  801907:	68 fb 26 80 00       	push   $0x8026fb
  80190c:	68 c3 26 80 00       	push   $0x8026c3
  801911:	6a 62                	push   $0x62
  801913:	68 10 27 80 00       	push   $0x802710
  801918:	e8 84 05 00 00       	call   801ea1 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80191d:	83 ec 04             	sub    $0x4,%esp
  801920:	50                   	push   %eax
  801921:	68 00 60 80 00       	push   $0x806000
  801926:	ff 75 0c             	pushl  0xc(%ebp)
  801929:	e8 2a ef ff ff       	call   800858 <memmove>
  80192e:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801931:	89 d8                	mov    %ebx,%eax
  801933:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801936:	5b                   	pop    %ebx
  801937:	5e                   	pop    %esi
  801938:	5d                   	pop    %ebp
  801939:	c3                   	ret    

0080193a <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80193a:	55                   	push   %ebp
  80193b:	89 e5                	mov    %esp,%ebp
  80193d:	53                   	push   %ebx
  80193e:	83 ec 04             	sub    $0x4,%esp
  801941:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801944:	8b 45 08             	mov    0x8(%ebp),%eax
  801947:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  80194c:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801952:	7e 16                	jle    80196a <nsipc_send+0x30>
  801954:	68 1c 27 80 00       	push   $0x80271c
  801959:	68 c3 26 80 00       	push   $0x8026c3
  80195e:	6a 6d                	push   $0x6d
  801960:	68 10 27 80 00       	push   $0x802710
  801965:	e8 37 05 00 00       	call   801ea1 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80196a:	83 ec 04             	sub    $0x4,%esp
  80196d:	53                   	push   %ebx
  80196e:	ff 75 0c             	pushl  0xc(%ebp)
  801971:	68 0c 60 80 00       	push   $0x80600c
  801976:	e8 dd ee ff ff       	call   800858 <memmove>
	nsipcbuf.send.req_size = size;
  80197b:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801981:	8b 45 14             	mov    0x14(%ebp),%eax
  801984:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801989:	b8 08 00 00 00       	mov    $0x8,%eax
  80198e:	e8 d9 fd ff ff       	call   80176c <nsipc>
}
  801993:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801996:	c9                   	leave  
  801997:	c3                   	ret    

00801998 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801998:	55                   	push   %ebp
  801999:	89 e5                	mov    %esp,%ebp
  80199b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80199e:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8019a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a9:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8019ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8019b1:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8019b6:	b8 09 00 00 00       	mov    $0x9,%eax
  8019bb:	e8 ac fd ff ff       	call   80176c <nsipc>
}
  8019c0:	c9                   	leave  
  8019c1:	c3                   	ret    

008019c2 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019c2:	55                   	push   %ebp
  8019c3:	89 e5                	mov    %esp,%ebp
  8019c5:	56                   	push   %esi
  8019c6:	53                   	push   %ebx
  8019c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019ca:	83 ec 0c             	sub    $0xc,%esp
  8019cd:	ff 75 08             	pushl  0x8(%ebp)
  8019d0:	e8 98 f3 ff ff       	call   800d6d <fd2data>
  8019d5:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019d7:	83 c4 08             	add    $0x8,%esp
  8019da:	68 28 27 80 00       	push   $0x802728
  8019df:	53                   	push   %ebx
  8019e0:	e8 e1 ec ff ff       	call   8006c6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019e5:	8b 46 04             	mov    0x4(%esi),%eax
  8019e8:	2b 06                	sub    (%esi),%eax
  8019ea:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019f0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019f7:	00 00 00 
	stat->st_dev = &devpipe;
  8019fa:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a01:	30 80 00 
	return 0;
}
  801a04:	b8 00 00 00 00       	mov    $0x0,%eax
  801a09:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0c:	5b                   	pop    %ebx
  801a0d:	5e                   	pop    %esi
  801a0e:	5d                   	pop    %ebp
  801a0f:	c3                   	ret    

00801a10 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	53                   	push   %ebx
  801a14:	83 ec 0c             	sub    $0xc,%esp
  801a17:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a1a:	53                   	push   %ebx
  801a1b:	6a 00                	push   $0x0
  801a1d:	e8 2c f1 ff ff       	call   800b4e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a22:	89 1c 24             	mov    %ebx,(%esp)
  801a25:	e8 43 f3 ff ff       	call   800d6d <fd2data>
  801a2a:	83 c4 08             	add    $0x8,%esp
  801a2d:	50                   	push   %eax
  801a2e:	6a 00                	push   $0x0
  801a30:	e8 19 f1 ff ff       	call   800b4e <sys_page_unmap>
}
  801a35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a38:	c9                   	leave  
  801a39:	c3                   	ret    

00801a3a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a3a:	55                   	push   %ebp
  801a3b:	89 e5                	mov    %esp,%ebp
  801a3d:	57                   	push   %edi
  801a3e:	56                   	push   %esi
  801a3f:	53                   	push   %ebx
  801a40:	83 ec 1c             	sub    $0x1c,%esp
  801a43:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a46:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a48:	a1 08 40 80 00       	mov    0x804008,%eax
  801a4d:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a50:	83 ec 0c             	sub    $0xc,%esp
  801a53:	ff 75 e0             	pushl  -0x20(%ebp)
  801a56:	e8 80 05 00 00       	call   801fdb <pageref>
  801a5b:	89 c3                	mov    %eax,%ebx
  801a5d:	89 3c 24             	mov    %edi,(%esp)
  801a60:	e8 76 05 00 00       	call   801fdb <pageref>
  801a65:	83 c4 10             	add    $0x10,%esp
  801a68:	39 c3                	cmp    %eax,%ebx
  801a6a:	0f 94 c1             	sete   %cl
  801a6d:	0f b6 c9             	movzbl %cl,%ecx
  801a70:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a73:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a79:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a7c:	39 ce                	cmp    %ecx,%esi
  801a7e:	74 1b                	je     801a9b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a80:	39 c3                	cmp    %eax,%ebx
  801a82:	75 c4                	jne    801a48 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a84:	8b 42 58             	mov    0x58(%edx),%eax
  801a87:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a8a:	50                   	push   %eax
  801a8b:	56                   	push   %esi
  801a8c:	68 2f 27 80 00       	push   $0x80272f
  801a91:	e8 ab e6 ff ff       	call   800141 <cprintf>
  801a96:	83 c4 10             	add    $0x10,%esp
  801a99:	eb ad                	jmp    801a48 <_pipeisclosed+0xe>
	}
}
  801a9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa1:	5b                   	pop    %ebx
  801aa2:	5e                   	pop    %esi
  801aa3:	5f                   	pop    %edi
  801aa4:	5d                   	pop    %ebp
  801aa5:	c3                   	ret    

00801aa6 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801aa6:	55                   	push   %ebp
  801aa7:	89 e5                	mov    %esp,%ebp
  801aa9:	57                   	push   %edi
  801aaa:	56                   	push   %esi
  801aab:	53                   	push   %ebx
  801aac:	83 ec 28             	sub    $0x28,%esp
  801aaf:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ab2:	56                   	push   %esi
  801ab3:	e8 b5 f2 ff ff       	call   800d6d <fd2data>
  801ab8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aba:	83 c4 10             	add    $0x10,%esp
  801abd:	bf 00 00 00 00       	mov    $0x0,%edi
  801ac2:	eb 4b                	jmp    801b0f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ac4:	89 da                	mov    %ebx,%edx
  801ac6:	89 f0                	mov    %esi,%eax
  801ac8:	e8 6d ff ff ff       	call   801a3a <_pipeisclosed>
  801acd:	85 c0                	test   %eax,%eax
  801acf:	75 48                	jne    801b19 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ad1:	e8 d4 ef ff ff       	call   800aaa <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ad6:	8b 43 04             	mov    0x4(%ebx),%eax
  801ad9:	8b 0b                	mov    (%ebx),%ecx
  801adb:	8d 51 20             	lea    0x20(%ecx),%edx
  801ade:	39 d0                	cmp    %edx,%eax
  801ae0:	73 e2                	jae    801ac4 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ae2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ae5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ae9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801aec:	89 c2                	mov    %eax,%edx
  801aee:	c1 fa 1f             	sar    $0x1f,%edx
  801af1:	89 d1                	mov    %edx,%ecx
  801af3:	c1 e9 1b             	shr    $0x1b,%ecx
  801af6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801af9:	83 e2 1f             	and    $0x1f,%edx
  801afc:	29 ca                	sub    %ecx,%edx
  801afe:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b02:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b06:	83 c0 01             	add    $0x1,%eax
  801b09:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b0c:	83 c7 01             	add    $0x1,%edi
  801b0f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b12:	75 c2                	jne    801ad6 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b14:	8b 45 10             	mov    0x10(%ebp),%eax
  801b17:	eb 05                	jmp    801b1e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b19:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b21:	5b                   	pop    %ebx
  801b22:	5e                   	pop    %esi
  801b23:	5f                   	pop    %edi
  801b24:	5d                   	pop    %ebp
  801b25:	c3                   	ret    

00801b26 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b26:	55                   	push   %ebp
  801b27:	89 e5                	mov    %esp,%ebp
  801b29:	57                   	push   %edi
  801b2a:	56                   	push   %esi
  801b2b:	53                   	push   %ebx
  801b2c:	83 ec 18             	sub    $0x18,%esp
  801b2f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b32:	57                   	push   %edi
  801b33:	e8 35 f2 ff ff       	call   800d6d <fd2data>
  801b38:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b3a:	83 c4 10             	add    $0x10,%esp
  801b3d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b42:	eb 3d                	jmp    801b81 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b44:	85 db                	test   %ebx,%ebx
  801b46:	74 04                	je     801b4c <devpipe_read+0x26>
				return i;
  801b48:	89 d8                	mov    %ebx,%eax
  801b4a:	eb 44                	jmp    801b90 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b4c:	89 f2                	mov    %esi,%edx
  801b4e:	89 f8                	mov    %edi,%eax
  801b50:	e8 e5 fe ff ff       	call   801a3a <_pipeisclosed>
  801b55:	85 c0                	test   %eax,%eax
  801b57:	75 32                	jne    801b8b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b59:	e8 4c ef ff ff       	call   800aaa <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b5e:	8b 06                	mov    (%esi),%eax
  801b60:	3b 46 04             	cmp    0x4(%esi),%eax
  801b63:	74 df                	je     801b44 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b65:	99                   	cltd   
  801b66:	c1 ea 1b             	shr    $0x1b,%edx
  801b69:	01 d0                	add    %edx,%eax
  801b6b:	83 e0 1f             	and    $0x1f,%eax
  801b6e:	29 d0                	sub    %edx,%eax
  801b70:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b78:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b7b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b7e:	83 c3 01             	add    $0x1,%ebx
  801b81:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b84:	75 d8                	jne    801b5e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b86:	8b 45 10             	mov    0x10(%ebp),%eax
  801b89:	eb 05                	jmp    801b90 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b8b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b93:	5b                   	pop    %ebx
  801b94:	5e                   	pop    %esi
  801b95:	5f                   	pop    %edi
  801b96:	5d                   	pop    %ebp
  801b97:	c3                   	ret    

00801b98 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b98:	55                   	push   %ebp
  801b99:	89 e5                	mov    %esp,%ebp
  801b9b:	56                   	push   %esi
  801b9c:	53                   	push   %ebx
  801b9d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ba0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba3:	50                   	push   %eax
  801ba4:	e8 db f1 ff ff       	call   800d84 <fd_alloc>
  801ba9:	83 c4 10             	add    $0x10,%esp
  801bac:	89 c2                	mov    %eax,%edx
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	0f 88 2c 01 00 00    	js     801ce2 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb6:	83 ec 04             	sub    $0x4,%esp
  801bb9:	68 07 04 00 00       	push   $0x407
  801bbe:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc1:	6a 00                	push   $0x0
  801bc3:	e8 01 ef ff ff       	call   800ac9 <sys_page_alloc>
  801bc8:	83 c4 10             	add    $0x10,%esp
  801bcb:	89 c2                	mov    %eax,%edx
  801bcd:	85 c0                	test   %eax,%eax
  801bcf:	0f 88 0d 01 00 00    	js     801ce2 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bd5:	83 ec 0c             	sub    $0xc,%esp
  801bd8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bdb:	50                   	push   %eax
  801bdc:	e8 a3 f1 ff ff       	call   800d84 <fd_alloc>
  801be1:	89 c3                	mov    %eax,%ebx
  801be3:	83 c4 10             	add    $0x10,%esp
  801be6:	85 c0                	test   %eax,%eax
  801be8:	0f 88 e2 00 00 00    	js     801cd0 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bee:	83 ec 04             	sub    $0x4,%esp
  801bf1:	68 07 04 00 00       	push   $0x407
  801bf6:	ff 75 f0             	pushl  -0x10(%ebp)
  801bf9:	6a 00                	push   $0x0
  801bfb:	e8 c9 ee ff ff       	call   800ac9 <sys_page_alloc>
  801c00:	89 c3                	mov    %eax,%ebx
  801c02:	83 c4 10             	add    $0x10,%esp
  801c05:	85 c0                	test   %eax,%eax
  801c07:	0f 88 c3 00 00 00    	js     801cd0 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c0d:	83 ec 0c             	sub    $0xc,%esp
  801c10:	ff 75 f4             	pushl  -0xc(%ebp)
  801c13:	e8 55 f1 ff ff       	call   800d6d <fd2data>
  801c18:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c1a:	83 c4 0c             	add    $0xc,%esp
  801c1d:	68 07 04 00 00       	push   $0x407
  801c22:	50                   	push   %eax
  801c23:	6a 00                	push   $0x0
  801c25:	e8 9f ee ff ff       	call   800ac9 <sys_page_alloc>
  801c2a:	89 c3                	mov    %eax,%ebx
  801c2c:	83 c4 10             	add    $0x10,%esp
  801c2f:	85 c0                	test   %eax,%eax
  801c31:	0f 88 89 00 00 00    	js     801cc0 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c37:	83 ec 0c             	sub    $0xc,%esp
  801c3a:	ff 75 f0             	pushl  -0x10(%ebp)
  801c3d:	e8 2b f1 ff ff       	call   800d6d <fd2data>
  801c42:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c49:	50                   	push   %eax
  801c4a:	6a 00                	push   $0x0
  801c4c:	56                   	push   %esi
  801c4d:	6a 00                	push   $0x0
  801c4f:	e8 b8 ee ff ff       	call   800b0c <sys_page_map>
  801c54:	89 c3                	mov    %eax,%ebx
  801c56:	83 c4 20             	add    $0x20,%esp
  801c59:	85 c0                	test   %eax,%eax
  801c5b:	78 55                	js     801cb2 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c5d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c66:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c72:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c78:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c7b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c80:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c87:	83 ec 0c             	sub    $0xc,%esp
  801c8a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c8d:	e8 cb f0 ff ff       	call   800d5d <fd2num>
  801c92:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c95:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c97:	83 c4 04             	add    $0x4,%esp
  801c9a:	ff 75 f0             	pushl  -0x10(%ebp)
  801c9d:	e8 bb f0 ff ff       	call   800d5d <fd2num>
  801ca2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ca5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ca8:	83 c4 10             	add    $0x10,%esp
  801cab:	ba 00 00 00 00       	mov    $0x0,%edx
  801cb0:	eb 30                	jmp    801ce2 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cb2:	83 ec 08             	sub    $0x8,%esp
  801cb5:	56                   	push   %esi
  801cb6:	6a 00                	push   $0x0
  801cb8:	e8 91 ee ff ff       	call   800b4e <sys_page_unmap>
  801cbd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cc0:	83 ec 08             	sub    $0x8,%esp
  801cc3:	ff 75 f0             	pushl  -0x10(%ebp)
  801cc6:	6a 00                	push   $0x0
  801cc8:	e8 81 ee ff ff       	call   800b4e <sys_page_unmap>
  801ccd:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cd0:	83 ec 08             	sub    $0x8,%esp
  801cd3:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd6:	6a 00                	push   $0x0
  801cd8:	e8 71 ee ff ff       	call   800b4e <sys_page_unmap>
  801cdd:	83 c4 10             	add    $0x10,%esp
  801ce0:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ce2:	89 d0                	mov    %edx,%eax
  801ce4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ce7:	5b                   	pop    %ebx
  801ce8:	5e                   	pop    %esi
  801ce9:	5d                   	pop    %ebp
  801cea:	c3                   	ret    

00801ceb <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ceb:	55                   	push   %ebp
  801cec:	89 e5                	mov    %esp,%ebp
  801cee:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cf1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cf4:	50                   	push   %eax
  801cf5:	ff 75 08             	pushl  0x8(%ebp)
  801cf8:	e8 d6 f0 ff ff       	call   800dd3 <fd_lookup>
  801cfd:	83 c4 10             	add    $0x10,%esp
  801d00:	85 c0                	test   %eax,%eax
  801d02:	78 18                	js     801d1c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d04:	83 ec 0c             	sub    $0xc,%esp
  801d07:	ff 75 f4             	pushl  -0xc(%ebp)
  801d0a:	e8 5e f0 ff ff       	call   800d6d <fd2data>
	return _pipeisclosed(fd, p);
  801d0f:	89 c2                	mov    %eax,%edx
  801d11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d14:	e8 21 fd ff ff       	call   801a3a <_pipeisclosed>
  801d19:	83 c4 10             	add    $0x10,%esp
}
  801d1c:	c9                   	leave  
  801d1d:	c3                   	ret    

00801d1e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d1e:	55                   	push   %ebp
  801d1f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d21:	b8 00 00 00 00       	mov    $0x0,%eax
  801d26:	5d                   	pop    %ebp
  801d27:	c3                   	ret    

00801d28 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d28:	55                   	push   %ebp
  801d29:	89 e5                	mov    %esp,%ebp
  801d2b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d2e:	68 47 27 80 00       	push   $0x802747
  801d33:	ff 75 0c             	pushl  0xc(%ebp)
  801d36:	e8 8b e9 ff ff       	call   8006c6 <strcpy>
	return 0;
}
  801d3b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d40:	c9                   	leave  
  801d41:	c3                   	ret    

00801d42 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d42:	55                   	push   %ebp
  801d43:	89 e5                	mov    %esp,%ebp
  801d45:	57                   	push   %edi
  801d46:	56                   	push   %esi
  801d47:	53                   	push   %ebx
  801d48:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d4e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d53:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d59:	eb 2d                	jmp    801d88 <devcons_write+0x46>
		m = n - tot;
  801d5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d5e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d60:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d63:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d68:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d6b:	83 ec 04             	sub    $0x4,%esp
  801d6e:	53                   	push   %ebx
  801d6f:	03 45 0c             	add    0xc(%ebp),%eax
  801d72:	50                   	push   %eax
  801d73:	57                   	push   %edi
  801d74:	e8 df ea ff ff       	call   800858 <memmove>
		sys_cputs(buf, m);
  801d79:	83 c4 08             	add    $0x8,%esp
  801d7c:	53                   	push   %ebx
  801d7d:	57                   	push   %edi
  801d7e:	e8 8a ec ff ff       	call   800a0d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d83:	01 de                	add    %ebx,%esi
  801d85:	83 c4 10             	add    $0x10,%esp
  801d88:	89 f0                	mov    %esi,%eax
  801d8a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d8d:	72 cc                	jb     801d5b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d92:	5b                   	pop    %ebx
  801d93:	5e                   	pop    %esi
  801d94:	5f                   	pop    %edi
  801d95:	5d                   	pop    %ebp
  801d96:	c3                   	ret    

00801d97 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d97:	55                   	push   %ebp
  801d98:	89 e5                	mov    %esp,%ebp
  801d9a:	83 ec 08             	sub    $0x8,%esp
  801d9d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801da2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801da6:	74 2a                	je     801dd2 <devcons_read+0x3b>
  801da8:	eb 05                	jmp    801daf <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801daa:	e8 fb ec ff ff       	call   800aaa <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801daf:	e8 77 ec ff ff       	call   800a2b <sys_cgetc>
  801db4:	85 c0                	test   %eax,%eax
  801db6:	74 f2                	je     801daa <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801db8:	85 c0                	test   %eax,%eax
  801dba:	78 16                	js     801dd2 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dbc:	83 f8 04             	cmp    $0x4,%eax
  801dbf:	74 0c                	je     801dcd <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801dc1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dc4:	88 02                	mov    %al,(%edx)
	return 1;
  801dc6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dcb:	eb 05                	jmp    801dd2 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dcd:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801dd2:	c9                   	leave  
  801dd3:	c3                   	ret    

00801dd4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801dd4:	55                   	push   %ebp
  801dd5:	89 e5                	mov    %esp,%ebp
  801dd7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dda:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddd:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801de0:	6a 01                	push   $0x1
  801de2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801de5:	50                   	push   %eax
  801de6:	e8 22 ec ff ff       	call   800a0d <sys_cputs>
}
  801deb:	83 c4 10             	add    $0x10,%esp
  801dee:	c9                   	leave  
  801def:	c3                   	ret    

00801df0 <getchar>:

int
getchar(void)
{
  801df0:	55                   	push   %ebp
  801df1:	89 e5                	mov    %esp,%ebp
  801df3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801df6:	6a 01                	push   $0x1
  801df8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dfb:	50                   	push   %eax
  801dfc:	6a 00                	push   $0x0
  801dfe:	e8 36 f2 ff ff       	call   801039 <read>
	if (r < 0)
  801e03:	83 c4 10             	add    $0x10,%esp
  801e06:	85 c0                	test   %eax,%eax
  801e08:	78 0f                	js     801e19 <getchar+0x29>
		return r;
	if (r < 1)
  801e0a:	85 c0                	test   %eax,%eax
  801e0c:	7e 06                	jle    801e14 <getchar+0x24>
		return -E_EOF;
	return c;
  801e0e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e12:	eb 05                	jmp    801e19 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e14:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e19:	c9                   	leave  
  801e1a:	c3                   	ret    

00801e1b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e1b:	55                   	push   %ebp
  801e1c:	89 e5                	mov    %esp,%ebp
  801e1e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e24:	50                   	push   %eax
  801e25:	ff 75 08             	pushl  0x8(%ebp)
  801e28:	e8 a6 ef ff ff       	call   800dd3 <fd_lookup>
  801e2d:	83 c4 10             	add    $0x10,%esp
  801e30:	85 c0                	test   %eax,%eax
  801e32:	78 11                	js     801e45 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e37:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e3d:	39 10                	cmp    %edx,(%eax)
  801e3f:	0f 94 c0             	sete   %al
  801e42:	0f b6 c0             	movzbl %al,%eax
}
  801e45:	c9                   	leave  
  801e46:	c3                   	ret    

00801e47 <opencons>:

int
opencons(void)
{
  801e47:	55                   	push   %ebp
  801e48:	89 e5                	mov    %esp,%ebp
  801e4a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e50:	50                   	push   %eax
  801e51:	e8 2e ef ff ff       	call   800d84 <fd_alloc>
  801e56:	83 c4 10             	add    $0x10,%esp
		return r;
  801e59:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e5b:	85 c0                	test   %eax,%eax
  801e5d:	78 3e                	js     801e9d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e5f:	83 ec 04             	sub    $0x4,%esp
  801e62:	68 07 04 00 00       	push   $0x407
  801e67:	ff 75 f4             	pushl  -0xc(%ebp)
  801e6a:	6a 00                	push   $0x0
  801e6c:	e8 58 ec ff ff       	call   800ac9 <sys_page_alloc>
  801e71:	83 c4 10             	add    $0x10,%esp
		return r;
  801e74:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e76:	85 c0                	test   %eax,%eax
  801e78:	78 23                	js     801e9d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e7a:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e83:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e88:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e8f:	83 ec 0c             	sub    $0xc,%esp
  801e92:	50                   	push   %eax
  801e93:	e8 c5 ee ff ff       	call   800d5d <fd2num>
  801e98:	89 c2                	mov    %eax,%edx
  801e9a:	83 c4 10             	add    $0x10,%esp
}
  801e9d:	89 d0                	mov    %edx,%eax
  801e9f:	c9                   	leave  
  801ea0:	c3                   	ret    

00801ea1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ea1:	55                   	push   %ebp
  801ea2:	89 e5                	mov    %esp,%ebp
  801ea4:	56                   	push   %esi
  801ea5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ea6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ea9:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801eaf:	e8 d7 eb ff ff       	call   800a8b <sys_getenvid>
  801eb4:	83 ec 0c             	sub    $0xc,%esp
  801eb7:	ff 75 0c             	pushl  0xc(%ebp)
  801eba:	ff 75 08             	pushl  0x8(%ebp)
  801ebd:	56                   	push   %esi
  801ebe:	50                   	push   %eax
  801ebf:	68 54 27 80 00       	push   $0x802754
  801ec4:	e8 78 e2 ff ff       	call   800141 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ec9:	83 c4 18             	add    $0x18,%esp
  801ecc:	53                   	push   %ebx
  801ecd:	ff 75 10             	pushl  0x10(%ebp)
  801ed0:	e8 1b e2 ff ff       	call   8000f0 <vcprintf>
	cprintf("\n");
  801ed5:	c7 04 24 40 27 80 00 	movl   $0x802740,(%esp)
  801edc:	e8 60 e2 ff ff       	call   800141 <cprintf>
  801ee1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ee4:	cc                   	int3   
  801ee5:	eb fd                	jmp    801ee4 <_panic+0x43>

00801ee7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ee7:	55                   	push   %ebp
  801ee8:	89 e5                	mov    %esp,%ebp
  801eea:	56                   	push   %esi
  801eeb:	53                   	push   %ebx
  801eec:	8b 75 08             	mov    0x8(%ebp),%esi
  801eef:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801ef5:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801ef7:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801efc:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801eff:	83 ec 0c             	sub    $0xc,%esp
  801f02:	50                   	push   %eax
  801f03:	e8 71 ed ff ff       	call   800c79 <sys_ipc_recv>

	if (from_env_store != NULL)
  801f08:	83 c4 10             	add    $0x10,%esp
  801f0b:	85 f6                	test   %esi,%esi
  801f0d:	74 14                	je     801f23 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801f0f:	ba 00 00 00 00       	mov    $0x0,%edx
  801f14:	85 c0                	test   %eax,%eax
  801f16:	78 09                	js     801f21 <ipc_recv+0x3a>
  801f18:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f1e:	8b 52 74             	mov    0x74(%edx),%edx
  801f21:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801f23:	85 db                	test   %ebx,%ebx
  801f25:	74 14                	je     801f3b <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801f27:	ba 00 00 00 00       	mov    $0x0,%edx
  801f2c:	85 c0                	test   %eax,%eax
  801f2e:	78 09                	js     801f39 <ipc_recv+0x52>
  801f30:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f36:	8b 52 78             	mov    0x78(%edx),%edx
  801f39:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801f3b:	85 c0                	test   %eax,%eax
  801f3d:	78 08                	js     801f47 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801f3f:	a1 08 40 80 00       	mov    0x804008,%eax
  801f44:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f47:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f4a:	5b                   	pop    %ebx
  801f4b:	5e                   	pop    %esi
  801f4c:	5d                   	pop    %ebp
  801f4d:	c3                   	ret    

00801f4e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f4e:	55                   	push   %ebp
  801f4f:	89 e5                	mov    %esp,%ebp
  801f51:	57                   	push   %edi
  801f52:	56                   	push   %esi
  801f53:	53                   	push   %ebx
  801f54:	83 ec 0c             	sub    $0xc,%esp
  801f57:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f5a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801f60:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801f62:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f67:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801f6a:	ff 75 14             	pushl  0x14(%ebp)
  801f6d:	53                   	push   %ebx
  801f6e:	56                   	push   %esi
  801f6f:	57                   	push   %edi
  801f70:	e8 e1 ec ff ff       	call   800c56 <sys_ipc_try_send>

		if (err < 0) {
  801f75:	83 c4 10             	add    $0x10,%esp
  801f78:	85 c0                	test   %eax,%eax
  801f7a:	79 1e                	jns    801f9a <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801f7c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f7f:	75 07                	jne    801f88 <ipc_send+0x3a>
				sys_yield();
  801f81:	e8 24 eb ff ff       	call   800aaa <sys_yield>
  801f86:	eb e2                	jmp    801f6a <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f88:	50                   	push   %eax
  801f89:	68 78 27 80 00       	push   $0x802778
  801f8e:	6a 49                	push   $0x49
  801f90:	68 85 27 80 00       	push   $0x802785
  801f95:	e8 07 ff ff ff       	call   801ea1 <_panic>
		}

	} while (err < 0);

}
  801f9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f9d:	5b                   	pop    %ebx
  801f9e:	5e                   	pop    %esi
  801f9f:	5f                   	pop    %edi
  801fa0:	5d                   	pop    %ebp
  801fa1:	c3                   	ret    

00801fa2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fa2:	55                   	push   %ebp
  801fa3:	89 e5                	mov    %esp,%ebp
  801fa5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fa8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fad:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fb0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fb6:	8b 52 50             	mov    0x50(%edx),%edx
  801fb9:	39 ca                	cmp    %ecx,%edx
  801fbb:	75 0d                	jne    801fca <ipc_find_env+0x28>
			return envs[i].env_id;
  801fbd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fc0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fc5:	8b 40 48             	mov    0x48(%eax),%eax
  801fc8:	eb 0f                	jmp    801fd9 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fca:	83 c0 01             	add    $0x1,%eax
  801fcd:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fd2:	75 d9                	jne    801fad <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fd4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fd9:	5d                   	pop    %ebp
  801fda:	c3                   	ret    

00801fdb <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fdb:	55                   	push   %ebp
  801fdc:	89 e5                	mov    %esp,%ebp
  801fde:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fe1:	89 d0                	mov    %edx,%eax
  801fe3:	c1 e8 16             	shr    $0x16,%eax
  801fe6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fed:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ff2:	f6 c1 01             	test   $0x1,%cl
  801ff5:	74 1d                	je     802014 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ff7:	c1 ea 0c             	shr    $0xc,%edx
  801ffa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802001:	f6 c2 01             	test   $0x1,%dl
  802004:	74 0e                	je     802014 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802006:	c1 ea 0c             	shr    $0xc,%edx
  802009:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802010:	ef 
  802011:	0f b7 c0             	movzwl %ax,%eax
}
  802014:	5d                   	pop    %ebp
  802015:	c3                   	ret    
  802016:	66 90                	xchg   %ax,%ax
  802018:	66 90                	xchg   %ax,%ax
  80201a:	66 90                	xchg   %ax,%ax
  80201c:	66 90                	xchg   %ax,%ax
  80201e:	66 90                	xchg   %ax,%ax

00802020 <__udivdi3>:
  802020:	55                   	push   %ebp
  802021:	57                   	push   %edi
  802022:	56                   	push   %esi
  802023:	53                   	push   %ebx
  802024:	83 ec 1c             	sub    $0x1c,%esp
  802027:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80202b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80202f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802033:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802037:	85 f6                	test   %esi,%esi
  802039:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80203d:	89 ca                	mov    %ecx,%edx
  80203f:	89 f8                	mov    %edi,%eax
  802041:	75 3d                	jne    802080 <__udivdi3+0x60>
  802043:	39 cf                	cmp    %ecx,%edi
  802045:	0f 87 c5 00 00 00    	ja     802110 <__udivdi3+0xf0>
  80204b:	85 ff                	test   %edi,%edi
  80204d:	89 fd                	mov    %edi,%ebp
  80204f:	75 0b                	jne    80205c <__udivdi3+0x3c>
  802051:	b8 01 00 00 00       	mov    $0x1,%eax
  802056:	31 d2                	xor    %edx,%edx
  802058:	f7 f7                	div    %edi
  80205a:	89 c5                	mov    %eax,%ebp
  80205c:	89 c8                	mov    %ecx,%eax
  80205e:	31 d2                	xor    %edx,%edx
  802060:	f7 f5                	div    %ebp
  802062:	89 c1                	mov    %eax,%ecx
  802064:	89 d8                	mov    %ebx,%eax
  802066:	89 cf                	mov    %ecx,%edi
  802068:	f7 f5                	div    %ebp
  80206a:	89 c3                	mov    %eax,%ebx
  80206c:	89 d8                	mov    %ebx,%eax
  80206e:	89 fa                	mov    %edi,%edx
  802070:	83 c4 1c             	add    $0x1c,%esp
  802073:	5b                   	pop    %ebx
  802074:	5e                   	pop    %esi
  802075:	5f                   	pop    %edi
  802076:	5d                   	pop    %ebp
  802077:	c3                   	ret    
  802078:	90                   	nop
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	39 ce                	cmp    %ecx,%esi
  802082:	77 74                	ja     8020f8 <__udivdi3+0xd8>
  802084:	0f bd fe             	bsr    %esi,%edi
  802087:	83 f7 1f             	xor    $0x1f,%edi
  80208a:	0f 84 98 00 00 00    	je     802128 <__udivdi3+0x108>
  802090:	bb 20 00 00 00       	mov    $0x20,%ebx
  802095:	89 f9                	mov    %edi,%ecx
  802097:	89 c5                	mov    %eax,%ebp
  802099:	29 fb                	sub    %edi,%ebx
  80209b:	d3 e6                	shl    %cl,%esi
  80209d:	89 d9                	mov    %ebx,%ecx
  80209f:	d3 ed                	shr    %cl,%ebp
  8020a1:	89 f9                	mov    %edi,%ecx
  8020a3:	d3 e0                	shl    %cl,%eax
  8020a5:	09 ee                	or     %ebp,%esi
  8020a7:	89 d9                	mov    %ebx,%ecx
  8020a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020ad:	89 d5                	mov    %edx,%ebp
  8020af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020b3:	d3 ed                	shr    %cl,%ebp
  8020b5:	89 f9                	mov    %edi,%ecx
  8020b7:	d3 e2                	shl    %cl,%edx
  8020b9:	89 d9                	mov    %ebx,%ecx
  8020bb:	d3 e8                	shr    %cl,%eax
  8020bd:	09 c2                	or     %eax,%edx
  8020bf:	89 d0                	mov    %edx,%eax
  8020c1:	89 ea                	mov    %ebp,%edx
  8020c3:	f7 f6                	div    %esi
  8020c5:	89 d5                	mov    %edx,%ebp
  8020c7:	89 c3                	mov    %eax,%ebx
  8020c9:	f7 64 24 0c          	mull   0xc(%esp)
  8020cd:	39 d5                	cmp    %edx,%ebp
  8020cf:	72 10                	jb     8020e1 <__udivdi3+0xc1>
  8020d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020d5:	89 f9                	mov    %edi,%ecx
  8020d7:	d3 e6                	shl    %cl,%esi
  8020d9:	39 c6                	cmp    %eax,%esi
  8020db:	73 07                	jae    8020e4 <__udivdi3+0xc4>
  8020dd:	39 d5                	cmp    %edx,%ebp
  8020df:	75 03                	jne    8020e4 <__udivdi3+0xc4>
  8020e1:	83 eb 01             	sub    $0x1,%ebx
  8020e4:	31 ff                	xor    %edi,%edi
  8020e6:	89 d8                	mov    %ebx,%eax
  8020e8:	89 fa                	mov    %edi,%edx
  8020ea:	83 c4 1c             	add    $0x1c,%esp
  8020ed:	5b                   	pop    %ebx
  8020ee:	5e                   	pop    %esi
  8020ef:	5f                   	pop    %edi
  8020f0:	5d                   	pop    %ebp
  8020f1:	c3                   	ret    
  8020f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020f8:	31 ff                	xor    %edi,%edi
  8020fa:	31 db                	xor    %ebx,%ebx
  8020fc:	89 d8                	mov    %ebx,%eax
  8020fe:	89 fa                	mov    %edi,%edx
  802100:	83 c4 1c             	add    $0x1c,%esp
  802103:	5b                   	pop    %ebx
  802104:	5e                   	pop    %esi
  802105:	5f                   	pop    %edi
  802106:	5d                   	pop    %ebp
  802107:	c3                   	ret    
  802108:	90                   	nop
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	89 d8                	mov    %ebx,%eax
  802112:	f7 f7                	div    %edi
  802114:	31 ff                	xor    %edi,%edi
  802116:	89 c3                	mov    %eax,%ebx
  802118:	89 d8                	mov    %ebx,%eax
  80211a:	89 fa                	mov    %edi,%edx
  80211c:	83 c4 1c             	add    $0x1c,%esp
  80211f:	5b                   	pop    %ebx
  802120:	5e                   	pop    %esi
  802121:	5f                   	pop    %edi
  802122:	5d                   	pop    %ebp
  802123:	c3                   	ret    
  802124:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802128:	39 ce                	cmp    %ecx,%esi
  80212a:	72 0c                	jb     802138 <__udivdi3+0x118>
  80212c:	31 db                	xor    %ebx,%ebx
  80212e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802132:	0f 87 34 ff ff ff    	ja     80206c <__udivdi3+0x4c>
  802138:	bb 01 00 00 00       	mov    $0x1,%ebx
  80213d:	e9 2a ff ff ff       	jmp    80206c <__udivdi3+0x4c>
  802142:	66 90                	xchg   %ax,%ax
  802144:	66 90                	xchg   %ax,%ax
  802146:	66 90                	xchg   %ax,%ax
  802148:	66 90                	xchg   %ax,%ax
  80214a:	66 90                	xchg   %ax,%ax
  80214c:	66 90                	xchg   %ax,%ax
  80214e:	66 90                	xchg   %ax,%ax

00802150 <__umoddi3>:
  802150:	55                   	push   %ebp
  802151:	57                   	push   %edi
  802152:	56                   	push   %esi
  802153:	53                   	push   %ebx
  802154:	83 ec 1c             	sub    $0x1c,%esp
  802157:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80215b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80215f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802163:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802167:	85 d2                	test   %edx,%edx
  802169:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80216d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802171:	89 f3                	mov    %esi,%ebx
  802173:	89 3c 24             	mov    %edi,(%esp)
  802176:	89 74 24 04          	mov    %esi,0x4(%esp)
  80217a:	75 1c                	jne    802198 <__umoddi3+0x48>
  80217c:	39 f7                	cmp    %esi,%edi
  80217e:	76 50                	jbe    8021d0 <__umoddi3+0x80>
  802180:	89 c8                	mov    %ecx,%eax
  802182:	89 f2                	mov    %esi,%edx
  802184:	f7 f7                	div    %edi
  802186:	89 d0                	mov    %edx,%eax
  802188:	31 d2                	xor    %edx,%edx
  80218a:	83 c4 1c             	add    $0x1c,%esp
  80218d:	5b                   	pop    %ebx
  80218e:	5e                   	pop    %esi
  80218f:	5f                   	pop    %edi
  802190:	5d                   	pop    %ebp
  802191:	c3                   	ret    
  802192:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802198:	39 f2                	cmp    %esi,%edx
  80219a:	89 d0                	mov    %edx,%eax
  80219c:	77 52                	ja     8021f0 <__umoddi3+0xa0>
  80219e:	0f bd ea             	bsr    %edx,%ebp
  8021a1:	83 f5 1f             	xor    $0x1f,%ebp
  8021a4:	75 5a                	jne    802200 <__umoddi3+0xb0>
  8021a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021aa:	0f 82 e0 00 00 00    	jb     802290 <__umoddi3+0x140>
  8021b0:	39 0c 24             	cmp    %ecx,(%esp)
  8021b3:	0f 86 d7 00 00 00    	jbe    802290 <__umoddi3+0x140>
  8021b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021c1:	83 c4 1c             	add    $0x1c,%esp
  8021c4:	5b                   	pop    %ebx
  8021c5:	5e                   	pop    %esi
  8021c6:	5f                   	pop    %edi
  8021c7:	5d                   	pop    %ebp
  8021c8:	c3                   	ret    
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	85 ff                	test   %edi,%edi
  8021d2:	89 fd                	mov    %edi,%ebp
  8021d4:	75 0b                	jne    8021e1 <__umoddi3+0x91>
  8021d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021db:	31 d2                	xor    %edx,%edx
  8021dd:	f7 f7                	div    %edi
  8021df:	89 c5                	mov    %eax,%ebp
  8021e1:	89 f0                	mov    %esi,%eax
  8021e3:	31 d2                	xor    %edx,%edx
  8021e5:	f7 f5                	div    %ebp
  8021e7:	89 c8                	mov    %ecx,%eax
  8021e9:	f7 f5                	div    %ebp
  8021eb:	89 d0                	mov    %edx,%eax
  8021ed:	eb 99                	jmp    802188 <__umoddi3+0x38>
  8021ef:	90                   	nop
  8021f0:	89 c8                	mov    %ecx,%eax
  8021f2:	89 f2                	mov    %esi,%edx
  8021f4:	83 c4 1c             	add    $0x1c,%esp
  8021f7:	5b                   	pop    %ebx
  8021f8:	5e                   	pop    %esi
  8021f9:	5f                   	pop    %edi
  8021fa:	5d                   	pop    %ebp
  8021fb:	c3                   	ret    
  8021fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802200:	8b 34 24             	mov    (%esp),%esi
  802203:	bf 20 00 00 00       	mov    $0x20,%edi
  802208:	89 e9                	mov    %ebp,%ecx
  80220a:	29 ef                	sub    %ebp,%edi
  80220c:	d3 e0                	shl    %cl,%eax
  80220e:	89 f9                	mov    %edi,%ecx
  802210:	89 f2                	mov    %esi,%edx
  802212:	d3 ea                	shr    %cl,%edx
  802214:	89 e9                	mov    %ebp,%ecx
  802216:	09 c2                	or     %eax,%edx
  802218:	89 d8                	mov    %ebx,%eax
  80221a:	89 14 24             	mov    %edx,(%esp)
  80221d:	89 f2                	mov    %esi,%edx
  80221f:	d3 e2                	shl    %cl,%edx
  802221:	89 f9                	mov    %edi,%ecx
  802223:	89 54 24 04          	mov    %edx,0x4(%esp)
  802227:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80222b:	d3 e8                	shr    %cl,%eax
  80222d:	89 e9                	mov    %ebp,%ecx
  80222f:	89 c6                	mov    %eax,%esi
  802231:	d3 e3                	shl    %cl,%ebx
  802233:	89 f9                	mov    %edi,%ecx
  802235:	89 d0                	mov    %edx,%eax
  802237:	d3 e8                	shr    %cl,%eax
  802239:	89 e9                	mov    %ebp,%ecx
  80223b:	09 d8                	or     %ebx,%eax
  80223d:	89 d3                	mov    %edx,%ebx
  80223f:	89 f2                	mov    %esi,%edx
  802241:	f7 34 24             	divl   (%esp)
  802244:	89 d6                	mov    %edx,%esi
  802246:	d3 e3                	shl    %cl,%ebx
  802248:	f7 64 24 04          	mull   0x4(%esp)
  80224c:	39 d6                	cmp    %edx,%esi
  80224e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802252:	89 d1                	mov    %edx,%ecx
  802254:	89 c3                	mov    %eax,%ebx
  802256:	72 08                	jb     802260 <__umoddi3+0x110>
  802258:	75 11                	jne    80226b <__umoddi3+0x11b>
  80225a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80225e:	73 0b                	jae    80226b <__umoddi3+0x11b>
  802260:	2b 44 24 04          	sub    0x4(%esp),%eax
  802264:	1b 14 24             	sbb    (%esp),%edx
  802267:	89 d1                	mov    %edx,%ecx
  802269:	89 c3                	mov    %eax,%ebx
  80226b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80226f:	29 da                	sub    %ebx,%edx
  802271:	19 ce                	sbb    %ecx,%esi
  802273:	89 f9                	mov    %edi,%ecx
  802275:	89 f0                	mov    %esi,%eax
  802277:	d3 e0                	shl    %cl,%eax
  802279:	89 e9                	mov    %ebp,%ecx
  80227b:	d3 ea                	shr    %cl,%edx
  80227d:	89 e9                	mov    %ebp,%ecx
  80227f:	d3 ee                	shr    %cl,%esi
  802281:	09 d0                	or     %edx,%eax
  802283:	89 f2                	mov    %esi,%edx
  802285:	83 c4 1c             	add    $0x1c,%esp
  802288:	5b                   	pop    %ebx
  802289:	5e                   	pop    %esi
  80228a:	5f                   	pop    %edi
  80228b:	5d                   	pop    %ebp
  80228c:	c3                   	ret    
  80228d:	8d 76 00             	lea    0x0(%esi),%esi
  802290:	29 f9                	sub    %edi,%ecx
  802292:	19 d6                	sbb    %edx,%esi
  802294:	89 74 24 04          	mov    %esi,0x4(%esp)
  802298:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80229c:	e9 18 ff ff ff       	jmp    8021b9 <__umoddi3+0x69>
