
obj/user/divzero.debug:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 a0 1d 80 00       	push   $0x801da0
  800056:	e8 f8 00 00 00       	call   800153 <cprintf>
}
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800068:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80006b:	e8 2d 0a 00 00       	call   800a9d <sys_getenvid>
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 db                	test   %ebx,%ebx
  800084:	7e 07                	jle    80008d <libmain+0x2d>
		binaryname = argv[0];
  800086:	8b 06                	mov    (%esi),%eax
  800088:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008d:	83 ec 08             	sub    $0x8,%esp
  800090:	56                   	push   %esi
  800091:	53                   	push   %ebx
  800092:	e8 9c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800097:	e8 0a 00 00 00       	call   8000a6 <exit>
}
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a2:	5b                   	pop    %ebx
  8000a3:	5e                   	pop    %esi
  8000a4:	5d                   	pop    %ebp
  8000a5:	c3                   	ret    

008000a6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ac:	e8 e6 0d 00 00       	call   800e97 <close_all>
	sys_env_destroy(0);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	6a 00                	push   $0x0
  8000b6:	e8 a1 09 00 00       	call   800a5c <sys_env_destroy>
}
  8000bb:	83 c4 10             	add    $0x10,%esp
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 04             	sub    $0x4,%esp
  8000c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ca:	8b 13                	mov    (%ebx),%edx
  8000cc:	8d 42 01             	lea    0x1(%edx),%eax
  8000cf:	89 03                	mov    %eax,(%ebx)
  8000d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000dd:	75 1a                	jne    8000f9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	68 ff 00 00 00       	push   $0xff
  8000e7:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ea:	50                   	push   %eax
  8000eb:	e8 2f 09 00 00       	call   800a1f <sys_cputs>
		b->idx = 0;
  8000f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800100:	c9                   	leave  
  800101:	c3                   	ret    

00800102 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80010b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800112:	00 00 00 
	b.cnt = 0;
  800115:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011f:	ff 75 0c             	pushl  0xc(%ebp)
  800122:	ff 75 08             	pushl  0x8(%ebp)
  800125:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012b:	50                   	push   %eax
  80012c:	68 c0 00 80 00       	push   $0x8000c0
  800131:	e8 54 01 00 00       	call   80028a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800136:	83 c4 08             	add    $0x8,%esp
  800139:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80013f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800145:	50                   	push   %eax
  800146:	e8 d4 08 00 00       	call   800a1f <sys_cputs>

	return b.cnt;
}
  80014b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800151:	c9                   	leave  
  800152:	c3                   	ret    

00800153 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800159:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015c:	50                   	push   %eax
  80015d:	ff 75 08             	pushl  0x8(%ebp)
  800160:	e8 9d ff ff ff       	call   800102 <vcprintf>
	va_end(ap);

	return cnt;
}
  800165:	c9                   	leave  
  800166:	c3                   	ret    

00800167 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	57                   	push   %edi
  80016b:	56                   	push   %esi
  80016c:	53                   	push   %ebx
  80016d:	83 ec 1c             	sub    $0x1c,%esp
  800170:	89 c7                	mov    %eax,%edi
  800172:	89 d6                	mov    %edx,%esi
  800174:	8b 45 08             	mov    0x8(%ebp),%eax
  800177:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800180:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800183:	bb 00 00 00 00       	mov    $0x0,%ebx
  800188:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80018b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80018e:	39 d3                	cmp    %edx,%ebx
  800190:	72 05                	jb     800197 <printnum+0x30>
  800192:	39 45 10             	cmp    %eax,0x10(%ebp)
  800195:	77 45                	ja     8001dc <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	ff 75 18             	pushl  0x18(%ebp)
  80019d:	8b 45 14             	mov    0x14(%ebp),%eax
  8001a0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001a3:	53                   	push   %ebx
  8001a4:	ff 75 10             	pushl  0x10(%ebp)
  8001a7:	83 ec 08             	sub    $0x8,%esp
  8001aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8001b0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b6:	e8 45 19 00 00       	call   801b00 <__udivdi3>
  8001bb:	83 c4 18             	add    $0x18,%esp
  8001be:	52                   	push   %edx
  8001bf:	50                   	push   %eax
  8001c0:	89 f2                	mov    %esi,%edx
  8001c2:	89 f8                	mov    %edi,%eax
  8001c4:	e8 9e ff ff ff       	call   800167 <printnum>
  8001c9:	83 c4 20             	add    $0x20,%esp
  8001cc:	eb 18                	jmp    8001e6 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ce:	83 ec 08             	sub    $0x8,%esp
  8001d1:	56                   	push   %esi
  8001d2:	ff 75 18             	pushl  0x18(%ebp)
  8001d5:	ff d7                	call   *%edi
  8001d7:	83 c4 10             	add    $0x10,%esp
  8001da:	eb 03                	jmp    8001df <printnum+0x78>
  8001dc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001df:	83 eb 01             	sub    $0x1,%ebx
  8001e2:	85 db                	test   %ebx,%ebx
  8001e4:	7f e8                	jg     8001ce <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e6:	83 ec 08             	sub    $0x8,%esp
  8001e9:	56                   	push   %esi
  8001ea:	83 ec 04             	sub    $0x4,%esp
  8001ed:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f3:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f6:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f9:	e8 32 1a 00 00       	call   801c30 <__umoddi3>
  8001fe:	83 c4 14             	add    $0x14,%esp
  800201:	0f be 80 b8 1d 80 00 	movsbl 0x801db8(%eax),%eax
  800208:	50                   	push   %eax
  800209:	ff d7                	call   *%edi
}
  80020b:	83 c4 10             	add    $0x10,%esp
  80020e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800211:	5b                   	pop    %ebx
  800212:	5e                   	pop    %esi
  800213:	5f                   	pop    %edi
  800214:	5d                   	pop    %ebp
  800215:	c3                   	ret    

00800216 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800216:	55                   	push   %ebp
  800217:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800219:	83 fa 01             	cmp    $0x1,%edx
  80021c:	7e 0e                	jle    80022c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80021e:	8b 10                	mov    (%eax),%edx
  800220:	8d 4a 08             	lea    0x8(%edx),%ecx
  800223:	89 08                	mov    %ecx,(%eax)
  800225:	8b 02                	mov    (%edx),%eax
  800227:	8b 52 04             	mov    0x4(%edx),%edx
  80022a:	eb 22                	jmp    80024e <getuint+0x38>
	else if (lflag)
  80022c:	85 d2                	test   %edx,%edx
  80022e:	74 10                	je     800240 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800230:	8b 10                	mov    (%eax),%edx
  800232:	8d 4a 04             	lea    0x4(%edx),%ecx
  800235:	89 08                	mov    %ecx,(%eax)
  800237:	8b 02                	mov    (%edx),%eax
  800239:	ba 00 00 00 00       	mov    $0x0,%edx
  80023e:	eb 0e                	jmp    80024e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800240:	8b 10                	mov    (%eax),%edx
  800242:	8d 4a 04             	lea    0x4(%edx),%ecx
  800245:	89 08                	mov    %ecx,(%eax)
  800247:	8b 02                	mov    (%edx),%eax
  800249:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80024e:	5d                   	pop    %ebp
  80024f:	c3                   	ret    

00800250 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800256:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80025a:	8b 10                	mov    (%eax),%edx
  80025c:	3b 50 04             	cmp    0x4(%eax),%edx
  80025f:	73 0a                	jae    80026b <sprintputch+0x1b>
		*b->buf++ = ch;
  800261:	8d 4a 01             	lea    0x1(%edx),%ecx
  800264:	89 08                	mov    %ecx,(%eax)
  800266:	8b 45 08             	mov    0x8(%ebp),%eax
  800269:	88 02                	mov    %al,(%edx)
}
  80026b:	5d                   	pop    %ebp
  80026c:	c3                   	ret    

0080026d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800273:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800276:	50                   	push   %eax
  800277:	ff 75 10             	pushl  0x10(%ebp)
  80027a:	ff 75 0c             	pushl  0xc(%ebp)
  80027d:	ff 75 08             	pushl  0x8(%ebp)
  800280:	e8 05 00 00 00       	call   80028a <vprintfmt>
	va_end(ap);
}
  800285:	83 c4 10             	add    $0x10,%esp
  800288:	c9                   	leave  
  800289:	c3                   	ret    

0080028a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	83 ec 2c             	sub    $0x2c,%esp
  800293:	8b 75 08             	mov    0x8(%ebp),%esi
  800296:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800299:	8b 7d 10             	mov    0x10(%ebp),%edi
  80029c:	eb 12                	jmp    8002b0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80029e:	85 c0                	test   %eax,%eax
  8002a0:	0f 84 89 03 00 00    	je     80062f <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002a6:	83 ec 08             	sub    $0x8,%esp
  8002a9:	53                   	push   %ebx
  8002aa:	50                   	push   %eax
  8002ab:	ff d6                	call   *%esi
  8002ad:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002b0:	83 c7 01             	add    $0x1,%edi
  8002b3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002b7:	83 f8 25             	cmp    $0x25,%eax
  8002ba:	75 e2                	jne    80029e <vprintfmt+0x14>
  8002bc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002c0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002c7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002ce:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002da:	eb 07                	jmp    8002e3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002df:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e3:	8d 47 01             	lea    0x1(%edi),%eax
  8002e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e9:	0f b6 07             	movzbl (%edi),%eax
  8002ec:	0f b6 c8             	movzbl %al,%ecx
  8002ef:	83 e8 23             	sub    $0x23,%eax
  8002f2:	3c 55                	cmp    $0x55,%al
  8002f4:	0f 87 1a 03 00 00    	ja     800614 <vprintfmt+0x38a>
  8002fa:	0f b6 c0             	movzbl %al,%eax
  8002fd:	ff 24 85 00 1f 80 00 	jmp    *0x801f00(,%eax,4)
  800304:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800307:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80030b:	eb d6                	jmp    8002e3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800310:	b8 00 00 00 00       	mov    $0x0,%eax
  800315:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800318:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80031b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80031f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800322:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800325:	83 fa 09             	cmp    $0x9,%edx
  800328:	77 39                	ja     800363 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80032a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80032d:	eb e9                	jmp    800318 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80032f:	8b 45 14             	mov    0x14(%ebp),%eax
  800332:	8d 48 04             	lea    0x4(%eax),%ecx
  800335:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800338:	8b 00                	mov    (%eax),%eax
  80033a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800340:	eb 27                	jmp    800369 <vprintfmt+0xdf>
  800342:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800345:	85 c0                	test   %eax,%eax
  800347:	b9 00 00 00 00       	mov    $0x0,%ecx
  80034c:	0f 49 c8             	cmovns %eax,%ecx
  80034f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800352:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800355:	eb 8c                	jmp    8002e3 <vprintfmt+0x59>
  800357:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80035a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800361:	eb 80                	jmp    8002e3 <vprintfmt+0x59>
  800363:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800366:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800369:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80036d:	0f 89 70 ff ff ff    	jns    8002e3 <vprintfmt+0x59>
				width = precision, precision = -1;
  800373:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800376:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800379:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800380:	e9 5e ff ff ff       	jmp    8002e3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800385:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80038b:	e9 53 ff ff ff       	jmp    8002e3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800390:	8b 45 14             	mov    0x14(%ebp),%eax
  800393:	8d 50 04             	lea    0x4(%eax),%edx
  800396:	89 55 14             	mov    %edx,0x14(%ebp)
  800399:	83 ec 08             	sub    $0x8,%esp
  80039c:	53                   	push   %ebx
  80039d:	ff 30                	pushl  (%eax)
  80039f:	ff d6                	call   *%esi
			break;
  8003a1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003a7:	e9 04 ff ff ff       	jmp    8002b0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8003af:	8d 50 04             	lea    0x4(%eax),%edx
  8003b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b5:	8b 00                	mov    (%eax),%eax
  8003b7:	99                   	cltd   
  8003b8:	31 d0                	xor    %edx,%eax
  8003ba:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003bc:	83 f8 0f             	cmp    $0xf,%eax
  8003bf:	7f 0b                	jg     8003cc <vprintfmt+0x142>
  8003c1:	8b 14 85 60 20 80 00 	mov    0x802060(,%eax,4),%edx
  8003c8:	85 d2                	test   %edx,%edx
  8003ca:	75 18                	jne    8003e4 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003cc:	50                   	push   %eax
  8003cd:	68 d0 1d 80 00       	push   $0x801dd0
  8003d2:	53                   	push   %ebx
  8003d3:	56                   	push   %esi
  8003d4:	e8 94 fe ff ff       	call   80026d <printfmt>
  8003d9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003df:	e9 cc fe ff ff       	jmp    8002b0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003e4:	52                   	push   %edx
  8003e5:	68 ba 21 80 00       	push   $0x8021ba
  8003ea:	53                   	push   %ebx
  8003eb:	56                   	push   %esi
  8003ec:	e8 7c fe ff ff       	call   80026d <printfmt>
  8003f1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f7:	e9 b4 fe ff ff       	jmp    8002b0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ff:	8d 50 04             	lea    0x4(%eax),%edx
  800402:	89 55 14             	mov    %edx,0x14(%ebp)
  800405:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800407:	85 ff                	test   %edi,%edi
  800409:	b8 c9 1d 80 00       	mov    $0x801dc9,%eax
  80040e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800411:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800415:	0f 8e 94 00 00 00    	jle    8004af <vprintfmt+0x225>
  80041b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80041f:	0f 84 98 00 00 00    	je     8004bd <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800425:	83 ec 08             	sub    $0x8,%esp
  800428:	ff 75 d0             	pushl  -0x30(%ebp)
  80042b:	57                   	push   %edi
  80042c:	e8 86 02 00 00       	call   8006b7 <strnlen>
  800431:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800434:	29 c1                	sub    %eax,%ecx
  800436:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800439:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80043c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800440:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800443:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800446:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800448:	eb 0f                	jmp    800459 <vprintfmt+0x1cf>
					putch(padc, putdat);
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	53                   	push   %ebx
  80044e:	ff 75 e0             	pushl  -0x20(%ebp)
  800451:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800453:	83 ef 01             	sub    $0x1,%edi
  800456:	83 c4 10             	add    $0x10,%esp
  800459:	85 ff                	test   %edi,%edi
  80045b:	7f ed                	jg     80044a <vprintfmt+0x1c0>
  80045d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800460:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800463:	85 c9                	test   %ecx,%ecx
  800465:	b8 00 00 00 00       	mov    $0x0,%eax
  80046a:	0f 49 c1             	cmovns %ecx,%eax
  80046d:	29 c1                	sub    %eax,%ecx
  80046f:	89 75 08             	mov    %esi,0x8(%ebp)
  800472:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800475:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800478:	89 cb                	mov    %ecx,%ebx
  80047a:	eb 4d                	jmp    8004c9 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80047c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800480:	74 1b                	je     80049d <vprintfmt+0x213>
  800482:	0f be c0             	movsbl %al,%eax
  800485:	83 e8 20             	sub    $0x20,%eax
  800488:	83 f8 5e             	cmp    $0x5e,%eax
  80048b:	76 10                	jbe    80049d <vprintfmt+0x213>
					putch('?', putdat);
  80048d:	83 ec 08             	sub    $0x8,%esp
  800490:	ff 75 0c             	pushl  0xc(%ebp)
  800493:	6a 3f                	push   $0x3f
  800495:	ff 55 08             	call   *0x8(%ebp)
  800498:	83 c4 10             	add    $0x10,%esp
  80049b:	eb 0d                	jmp    8004aa <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80049d:	83 ec 08             	sub    $0x8,%esp
  8004a0:	ff 75 0c             	pushl  0xc(%ebp)
  8004a3:	52                   	push   %edx
  8004a4:	ff 55 08             	call   *0x8(%ebp)
  8004a7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004aa:	83 eb 01             	sub    $0x1,%ebx
  8004ad:	eb 1a                	jmp    8004c9 <vprintfmt+0x23f>
  8004af:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004bb:	eb 0c                	jmp    8004c9 <vprintfmt+0x23f>
  8004bd:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c9:	83 c7 01             	add    $0x1,%edi
  8004cc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004d0:	0f be d0             	movsbl %al,%edx
  8004d3:	85 d2                	test   %edx,%edx
  8004d5:	74 23                	je     8004fa <vprintfmt+0x270>
  8004d7:	85 f6                	test   %esi,%esi
  8004d9:	78 a1                	js     80047c <vprintfmt+0x1f2>
  8004db:	83 ee 01             	sub    $0x1,%esi
  8004de:	79 9c                	jns    80047c <vprintfmt+0x1f2>
  8004e0:	89 df                	mov    %ebx,%edi
  8004e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e8:	eb 18                	jmp    800502 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004ea:	83 ec 08             	sub    $0x8,%esp
  8004ed:	53                   	push   %ebx
  8004ee:	6a 20                	push   $0x20
  8004f0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004f2:	83 ef 01             	sub    $0x1,%edi
  8004f5:	83 c4 10             	add    $0x10,%esp
  8004f8:	eb 08                	jmp    800502 <vprintfmt+0x278>
  8004fa:	89 df                	mov    %ebx,%edi
  8004fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800502:	85 ff                	test   %edi,%edi
  800504:	7f e4                	jg     8004ea <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800506:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800509:	e9 a2 fd ff ff       	jmp    8002b0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80050e:	83 fa 01             	cmp    $0x1,%edx
  800511:	7e 16                	jle    800529 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800513:	8b 45 14             	mov    0x14(%ebp),%eax
  800516:	8d 50 08             	lea    0x8(%eax),%edx
  800519:	89 55 14             	mov    %edx,0x14(%ebp)
  80051c:	8b 50 04             	mov    0x4(%eax),%edx
  80051f:	8b 00                	mov    (%eax),%eax
  800521:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800524:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800527:	eb 32                	jmp    80055b <vprintfmt+0x2d1>
	else if (lflag)
  800529:	85 d2                	test   %edx,%edx
  80052b:	74 18                	je     800545 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80052d:	8b 45 14             	mov    0x14(%ebp),%eax
  800530:	8d 50 04             	lea    0x4(%eax),%edx
  800533:	89 55 14             	mov    %edx,0x14(%ebp)
  800536:	8b 00                	mov    (%eax),%eax
  800538:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053b:	89 c1                	mov    %eax,%ecx
  80053d:	c1 f9 1f             	sar    $0x1f,%ecx
  800540:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800543:	eb 16                	jmp    80055b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800545:	8b 45 14             	mov    0x14(%ebp),%eax
  800548:	8d 50 04             	lea    0x4(%eax),%edx
  80054b:	89 55 14             	mov    %edx,0x14(%ebp)
  80054e:	8b 00                	mov    (%eax),%eax
  800550:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800553:	89 c1                	mov    %eax,%ecx
  800555:	c1 f9 1f             	sar    $0x1f,%ecx
  800558:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80055b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80055e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800561:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800566:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80056a:	79 74                	jns    8005e0 <vprintfmt+0x356>
				putch('-', putdat);
  80056c:	83 ec 08             	sub    $0x8,%esp
  80056f:	53                   	push   %ebx
  800570:	6a 2d                	push   $0x2d
  800572:	ff d6                	call   *%esi
				num = -(long long) num;
  800574:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800577:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80057a:	f7 d8                	neg    %eax
  80057c:	83 d2 00             	adc    $0x0,%edx
  80057f:	f7 da                	neg    %edx
  800581:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800584:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800589:	eb 55                	jmp    8005e0 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80058b:	8d 45 14             	lea    0x14(%ebp),%eax
  80058e:	e8 83 fc ff ff       	call   800216 <getuint>
			base = 10;
  800593:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800598:	eb 46                	jmp    8005e0 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  80059a:	8d 45 14             	lea    0x14(%ebp),%eax
  80059d:	e8 74 fc ff ff       	call   800216 <getuint>
			base = 8;
  8005a2:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005a7:	eb 37                	jmp    8005e0 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005a9:	83 ec 08             	sub    $0x8,%esp
  8005ac:	53                   	push   %ebx
  8005ad:	6a 30                	push   $0x30
  8005af:	ff d6                	call   *%esi
			putch('x', putdat);
  8005b1:	83 c4 08             	add    $0x8,%esp
  8005b4:	53                   	push   %ebx
  8005b5:	6a 78                	push   $0x78
  8005b7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8d 50 04             	lea    0x4(%eax),%edx
  8005bf:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005c2:	8b 00                	mov    (%eax),%eax
  8005c4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005c9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005cc:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005d1:	eb 0d                	jmp    8005e0 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d6:	e8 3b fc ff ff       	call   800216 <getuint>
			base = 16;
  8005db:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005e0:	83 ec 0c             	sub    $0xc,%esp
  8005e3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005e7:	57                   	push   %edi
  8005e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8005eb:	51                   	push   %ecx
  8005ec:	52                   	push   %edx
  8005ed:	50                   	push   %eax
  8005ee:	89 da                	mov    %ebx,%edx
  8005f0:	89 f0                	mov    %esi,%eax
  8005f2:	e8 70 fb ff ff       	call   800167 <printnum>
			break;
  8005f7:	83 c4 20             	add    $0x20,%esp
  8005fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005fd:	e9 ae fc ff ff       	jmp    8002b0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800602:	83 ec 08             	sub    $0x8,%esp
  800605:	53                   	push   %ebx
  800606:	51                   	push   %ecx
  800607:	ff d6                	call   *%esi
			break;
  800609:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80060f:	e9 9c fc ff ff       	jmp    8002b0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800614:	83 ec 08             	sub    $0x8,%esp
  800617:	53                   	push   %ebx
  800618:	6a 25                	push   $0x25
  80061a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80061c:	83 c4 10             	add    $0x10,%esp
  80061f:	eb 03                	jmp    800624 <vprintfmt+0x39a>
  800621:	83 ef 01             	sub    $0x1,%edi
  800624:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800628:	75 f7                	jne    800621 <vprintfmt+0x397>
  80062a:	e9 81 fc ff ff       	jmp    8002b0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80062f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800632:	5b                   	pop    %ebx
  800633:	5e                   	pop    %esi
  800634:	5f                   	pop    %edi
  800635:	5d                   	pop    %ebp
  800636:	c3                   	ret    

00800637 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800637:	55                   	push   %ebp
  800638:	89 e5                	mov    %esp,%ebp
  80063a:	83 ec 18             	sub    $0x18,%esp
  80063d:	8b 45 08             	mov    0x8(%ebp),%eax
  800640:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800643:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800646:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80064a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80064d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800654:	85 c0                	test   %eax,%eax
  800656:	74 26                	je     80067e <vsnprintf+0x47>
  800658:	85 d2                	test   %edx,%edx
  80065a:	7e 22                	jle    80067e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80065c:	ff 75 14             	pushl  0x14(%ebp)
  80065f:	ff 75 10             	pushl  0x10(%ebp)
  800662:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800665:	50                   	push   %eax
  800666:	68 50 02 80 00       	push   $0x800250
  80066b:	e8 1a fc ff ff       	call   80028a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800670:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800673:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800676:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800679:	83 c4 10             	add    $0x10,%esp
  80067c:	eb 05                	jmp    800683 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80067e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800683:	c9                   	leave  
  800684:	c3                   	ret    

00800685 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800685:	55                   	push   %ebp
  800686:	89 e5                	mov    %esp,%ebp
  800688:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80068b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80068e:	50                   	push   %eax
  80068f:	ff 75 10             	pushl  0x10(%ebp)
  800692:	ff 75 0c             	pushl  0xc(%ebp)
  800695:	ff 75 08             	pushl  0x8(%ebp)
  800698:	e8 9a ff ff ff       	call   800637 <vsnprintf>
	va_end(ap);

	return rc;
}
  80069d:	c9                   	leave  
  80069e:	c3                   	ret    

0080069f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80069f:	55                   	push   %ebp
  8006a0:	89 e5                	mov    %esp,%ebp
  8006a2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006aa:	eb 03                	jmp    8006af <strlen+0x10>
		n++;
  8006ac:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006af:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006b3:	75 f7                	jne    8006ac <strlen+0xd>
		n++;
	return n;
}
  8006b5:	5d                   	pop    %ebp
  8006b6:	c3                   	ret    

008006b7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006b7:	55                   	push   %ebp
  8006b8:	89 e5                	mov    %esp,%ebp
  8006ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c5:	eb 03                	jmp    8006ca <strnlen+0x13>
		n++;
  8006c7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ca:	39 c2                	cmp    %eax,%edx
  8006cc:	74 08                	je     8006d6 <strnlen+0x1f>
  8006ce:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006d2:	75 f3                	jne    8006c7 <strnlen+0x10>
  8006d4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006d6:	5d                   	pop    %ebp
  8006d7:	c3                   	ret    

008006d8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006d8:	55                   	push   %ebp
  8006d9:	89 e5                	mov    %esp,%ebp
  8006db:	53                   	push   %ebx
  8006dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006e2:	89 c2                	mov    %eax,%edx
  8006e4:	83 c2 01             	add    $0x1,%edx
  8006e7:	83 c1 01             	add    $0x1,%ecx
  8006ea:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006ee:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006f1:	84 db                	test   %bl,%bl
  8006f3:	75 ef                	jne    8006e4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006f5:	5b                   	pop    %ebx
  8006f6:	5d                   	pop    %ebp
  8006f7:	c3                   	ret    

008006f8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	53                   	push   %ebx
  8006fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006ff:	53                   	push   %ebx
  800700:	e8 9a ff ff ff       	call   80069f <strlen>
  800705:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800708:	ff 75 0c             	pushl  0xc(%ebp)
  80070b:	01 d8                	add    %ebx,%eax
  80070d:	50                   	push   %eax
  80070e:	e8 c5 ff ff ff       	call   8006d8 <strcpy>
	return dst;
}
  800713:	89 d8                	mov    %ebx,%eax
  800715:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800718:	c9                   	leave  
  800719:	c3                   	ret    

0080071a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80071a:	55                   	push   %ebp
  80071b:	89 e5                	mov    %esp,%ebp
  80071d:	56                   	push   %esi
  80071e:	53                   	push   %ebx
  80071f:	8b 75 08             	mov    0x8(%ebp),%esi
  800722:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800725:	89 f3                	mov    %esi,%ebx
  800727:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80072a:	89 f2                	mov    %esi,%edx
  80072c:	eb 0f                	jmp    80073d <strncpy+0x23>
		*dst++ = *src;
  80072e:	83 c2 01             	add    $0x1,%edx
  800731:	0f b6 01             	movzbl (%ecx),%eax
  800734:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800737:	80 39 01             	cmpb   $0x1,(%ecx)
  80073a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80073d:	39 da                	cmp    %ebx,%edx
  80073f:	75 ed                	jne    80072e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800741:	89 f0                	mov    %esi,%eax
  800743:	5b                   	pop    %ebx
  800744:	5e                   	pop    %esi
  800745:	5d                   	pop    %ebp
  800746:	c3                   	ret    

00800747 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	56                   	push   %esi
  80074b:	53                   	push   %ebx
  80074c:	8b 75 08             	mov    0x8(%ebp),%esi
  80074f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800752:	8b 55 10             	mov    0x10(%ebp),%edx
  800755:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800757:	85 d2                	test   %edx,%edx
  800759:	74 21                	je     80077c <strlcpy+0x35>
  80075b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80075f:	89 f2                	mov    %esi,%edx
  800761:	eb 09                	jmp    80076c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800763:	83 c2 01             	add    $0x1,%edx
  800766:	83 c1 01             	add    $0x1,%ecx
  800769:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80076c:	39 c2                	cmp    %eax,%edx
  80076e:	74 09                	je     800779 <strlcpy+0x32>
  800770:	0f b6 19             	movzbl (%ecx),%ebx
  800773:	84 db                	test   %bl,%bl
  800775:	75 ec                	jne    800763 <strlcpy+0x1c>
  800777:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800779:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80077c:	29 f0                	sub    %esi,%eax
}
  80077e:	5b                   	pop    %ebx
  80077f:	5e                   	pop    %esi
  800780:	5d                   	pop    %ebp
  800781:	c3                   	ret    

00800782 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
  800785:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800788:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80078b:	eb 06                	jmp    800793 <strcmp+0x11>
		p++, q++;
  80078d:	83 c1 01             	add    $0x1,%ecx
  800790:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800793:	0f b6 01             	movzbl (%ecx),%eax
  800796:	84 c0                	test   %al,%al
  800798:	74 04                	je     80079e <strcmp+0x1c>
  80079a:	3a 02                	cmp    (%edx),%al
  80079c:	74 ef                	je     80078d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80079e:	0f b6 c0             	movzbl %al,%eax
  8007a1:	0f b6 12             	movzbl (%edx),%edx
  8007a4:	29 d0                	sub    %edx,%eax
}
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	53                   	push   %ebx
  8007ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8007af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b2:	89 c3                	mov    %eax,%ebx
  8007b4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007b7:	eb 06                	jmp    8007bf <strncmp+0x17>
		n--, p++, q++;
  8007b9:	83 c0 01             	add    $0x1,%eax
  8007bc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007bf:	39 d8                	cmp    %ebx,%eax
  8007c1:	74 15                	je     8007d8 <strncmp+0x30>
  8007c3:	0f b6 08             	movzbl (%eax),%ecx
  8007c6:	84 c9                	test   %cl,%cl
  8007c8:	74 04                	je     8007ce <strncmp+0x26>
  8007ca:	3a 0a                	cmp    (%edx),%cl
  8007cc:	74 eb                	je     8007b9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ce:	0f b6 00             	movzbl (%eax),%eax
  8007d1:	0f b6 12             	movzbl (%edx),%edx
  8007d4:	29 d0                	sub    %edx,%eax
  8007d6:	eb 05                	jmp    8007dd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007d8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007dd:	5b                   	pop    %ebx
  8007de:	5d                   	pop    %ebp
  8007df:	c3                   	ret    

008007e0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007ea:	eb 07                	jmp    8007f3 <strchr+0x13>
		if (*s == c)
  8007ec:	38 ca                	cmp    %cl,%dl
  8007ee:	74 0f                	je     8007ff <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007f0:	83 c0 01             	add    $0x1,%eax
  8007f3:	0f b6 10             	movzbl (%eax),%edx
  8007f6:	84 d2                	test   %dl,%dl
  8007f8:	75 f2                	jne    8007ec <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8007fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007ff:	5d                   	pop    %ebp
  800800:	c3                   	ret    

00800801 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	8b 45 08             	mov    0x8(%ebp),%eax
  800807:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80080b:	eb 03                	jmp    800810 <strfind+0xf>
  80080d:	83 c0 01             	add    $0x1,%eax
  800810:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800813:	38 ca                	cmp    %cl,%dl
  800815:	74 04                	je     80081b <strfind+0x1a>
  800817:	84 d2                	test   %dl,%dl
  800819:	75 f2                	jne    80080d <strfind+0xc>
			break;
	return (char *) s;
}
  80081b:	5d                   	pop    %ebp
  80081c:	c3                   	ret    

0080081d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	57                   	push   %edi
  800821:	56                   	push   %esi
  800822:	53                   	push   %ebx
  800823:	8b 7d 08             	mov    0x8(%ebp),%edi
  800826:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800829:	85 c9                	test   %ecx,%ecx
  80082b:	74 36                	je     800863 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80082d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800833:	75 28                	jne    80085d <memset+0x40>
  800835:	f6 c1 03             	test   $0x3,%cl
  800838:	75 23                	jne    80085d <memset+0x40>
		c &= 0xFF;
  80083a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80083e:	89 d3                	mov    %edx,%ebx
  800840:	c1 e3 08             	shl    $0x8,%ebx
  800843:	89 d6                	mov    %edx,%esi
  800845:	c1 e6 18             	shl    $0x18,%esi
  800848:	89 d0                	mov    %edx,%eax
  80084a:	c1 e0 10             	shl    $0x10,%eax
  80084d:	09 f0                	or     %esi,%eax
  80084f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800851:	89 d8                	mov    %ebx,%eax
  800853:	09 d0                	or     %edx,%eax
  800855:	c1 e9 02             	shr    $0x2,%ecx
  800858:	fc                   	cld    
  800859:	f3 ab                	rep stos %eax,%es:(%edi)
  80085b:	eb 06                	jmp    800863 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80085d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800860:	fc                   	cld    
  800861:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800863:	89 f8                	mov    %edi,%eax
  800865:	5b                   	pop    %ebx
  800866:	5e                   	pop    %esi
  800867:	5f                   	pop    %edi
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	57                   	push   %edi
  80086e:	56                   	push   %esi
  80086f:	8b 45 08             	mov    0x8(%ebp),%eax
  800872:	8b 75 0c             	mov    0xc(%ebp),%esi
  800875:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800878:	39 c6                	cmp    %eax,%esi
  80087a:	73 35                	jae    8008b1 <memmove+0x47>
  80087c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80087f:	39 d0                	cmp    %edx,%eax
  800881:	73 2e                	jae    8008b1 <memmove+0x47>
		s += n;
		d += n;
  800883:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800886:	89 d6                	mov    %edx,%esi
  800888:	09 fe                	or     %edi,%esi
  80088a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800890:	75 13                	jne    8008a5 <memmove+0x3b>
  800892:	f6 c1 03             	test   $0x3,%cl
  800895:	75 0e                	jne    8008a5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800897:	83 ef 04             	sub    $0x4,%edi
  80089a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80089d:	c1 e9 02             	shr    $0x2,%ecx
  8008a0:	fd                   	std    
  8008a1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008a3:	eb 09                	jmp    8008ae <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008a5:	83 ef 01             	sub    $0x1,%edi
  8008a8:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008ab:	fd                   	std    
  8008ac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ae:	fc                   	cld    
  8008af:	eb 1d                	jmp    8008ce <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008b1:	89 f2                	mov    %esi,%edx
  8008b3:	09 c2                	or     %eax,%edx
  8008b5:	f6 c2 03             	test   $0x3,%dl
  8008b8:	75 0f                	jne    8008c9 <memmove+0x5f>
  8008ba:	f6 c1 03             	test   $0x3,%cl
  8008bd:	75 0a                	jne    8008c9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008bf:	c1 e9 02             	shr    $0x2,%ecx
  8008c2:	89 c7                	mov    %eax,%edi
  8008c4:	fc                   	cld    
  8008c5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c7:	eb 05                	jmp    8008ce <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008c9:	89 c7                	mov    %eax,%edi
  8008cb:	fc                   	cld    
  8008cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008ce:	5e                   	pop    %esi
  8008cf:	5f                   	pop    %edi
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008d5:	ff 75 10             	pushl  0x10(%ebp)
  8008d8:	ff 75 0c             	pushl  0xc(%ebp)
  8008db:	ff 75 08             	pushl  0x8(%ebp)
  8008de:	e8 87 ff ff ff       	call   80086a <memmove>
}
  8008e3:	c9                   	leave  
  8008e4:	c3                   	ret    

008008e5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	56                   	push   %esi
  8008e9:	53                   	push   %ebx
  8008ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f0:	89 c6                	mov    %eax,%esi
  8008f2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008f5:	eb 1a                	jmp    800911 <memcmp+0x2c>
		if (*s1 != *s2)
  8008f7:	0f b6 08             	movzbl (%eax),%ecx
  8008fa:	0f b6 1a             	movzbl (%edx),%ebx
  8008fd:	38 d9                	cmp    %bl,%cl
  8008ff:	74 0a                	je     80090b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800901:	0f b6 c1             	movzbl %cl,%eax
  800904:	0f b6 db             	movzbl %bl,%ebx
  800907:	29 d8                	sub    %ebx,%eax
  800909:	eb 0f                	jmp    80091a <memcmp+0x35>
		s1++, s2++;
  80090b:	83 c0 01             	add    $0x1,%eax
  80090e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800911:	39 f0                	cmp    %esi,%eax
  800913:	75 e2                	jne    8008f7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800915:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80091a:	5b                   	pop    %ebx
  80091b:	5e                   	pop    %esi
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	53                   	push   %ebx
  800922:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800925:	89 c1                	mov    %eax,%ecx
  800927:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80092a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80092e:	eb 0a                	jmp    80093a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800930:	0f b6 10             	movzbl (%eax),%edx
  800933:	39 da                	cmp    %ebx,%edx
  800935:	74 07                	je     80093e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800937:	83 c0 01             	add    $0x1,%eax
  80093a:	39 c8                	cmp    %ecx,%eax
  80093c:	72 f2                	jb     800930 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80093e:	5b                   	pop    %ebx
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	57                   	push   %edi
  800945:	56                   	push   %esi
  800946:	53                   	push   %ebx
  800947:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80094a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80094d:	eb 03                	jmp    800952 <strtol+0x11>
		s++;
  80094f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800952:	0f b6 01             	movzbl (%ecx),%eax
  800955:	3c 20                	cmp    $0x20,%al
  800957:	74 f6                	je     80094f <strtol+0xe>
  800959:	3c 09                	cmp    $0x9,%al
  80095b:	74 f2                	je     80094f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80095d:	3c 2b                	cmp    $0x2b,%al
  80095f:	75 0a                	jne    80096b <strtol+0x2a>
		s++;
  800961:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800964:	bf 00 00 00 00       	mov    $0x0,%edi
  800969:	eb 11                	jmp    80097c <strtol+0x3b>
  80096b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800970:	3c 2d                	cmp    $0x2d,%al
  800972:	75 08                	jne    80097c <strtol+0x3b>
		s++, neg = 1;
  800974:	83 c1 01             	add    $0x1,%ecx
  800977:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80097c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800982:	75 15                	jne    800999 <strtol+0x58>
  800984:	80 39 30             	cmpb   $0x30,(%ecx)
  800987:	75 10                	jne    800999 <strtol+0x58>
  800989:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80098d:	75 7c                	jne    800a0b <strtol+0xca>
		s += 2, base = 16;
  80098f:	83 c1 02             	add    $0x2,%ecx
  800992:	bb 10 00 00 00       	mov    $0x10,%ebx
  800997:	eb 16                	jmp    8009af <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800999:	85 db                	test   %ebx,%ebx
  80099b:	75 12                	jne    8009af <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80099d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009a2:	80 39 30             	cmpb   $0x30,(%ecx)
  8009a5:	75 08                	jne    8009af <strtol+0x6e>
		s++, base = 8;
  8009a7:	83 c1 01             	add    $0x1,%ecx
  8009aa:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009af:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009b7:	0f b6 11             	movzbl (%ecx),%edx
  8009ba:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009bd:	89 f3                	mov    %esi,%ebx
  8009bf:	80 fb 09             	cmp    $0x9,%bl
  8009c2:	77 08                	ja     8009cc <strtol+0x8b>
			dig = *s - '0';
  8009c4:	0f be d2             	movsbl %dl,%edx
  8009c7:	83 ea 30             	sub    $0x30,%edx
  8009ca:	eb 22                	jmp    8009ee <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009cc:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009cf:	89 f3                	mov    %esi,%ebx
  8009d1:	80 fb 19             	cmp    $0x19,%bl
  8009d4:	77 08                	ja     8009de <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009d6:	0f be d2             	movsbl %dl,%edx
  8009d9:	83 ea 57             	sub    $0x57,%edx
  8009dc:	eb 10                	jmp    8009ee <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009de:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009e1:	89 f3                	mov    %esi,%ebx
  8009e3:	80 fb 19             	cmp    $0x19,%bl
  8009e6:	77 16                	ja     8009fe <strtol+0xbd>
			dig = *s - 'A' + 10;
  8009e8:	0f be d2             	movsbl %dl,%edx
  8009eb:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009ee:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009f1:	7d 0b                	jge    8009fe <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8009f3:	83 c1 01             	add    $0x1,%ecx
  8009f6:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009fa:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8009fc:	eb b9                	jmp    8009b7 <strtol+0x76>

	if (endptr)
  8009fe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a02:	74 0d                	je     800a11 <strtol+0xd0>
		*endptr = (char *) s;
  800a04:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a07:	89 0e                	mov    %ecx,(%esi)
  800a09:	eb 06                	jmp    800a11 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a0b:	85 db                	test   %ebx,%ebx
  800a0d:	74 98                	je     8009a7 <strtol+0x66>
  800a0f:	eb 9e                	jmp    8009af <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a11:	89 c2                	mov    %eax,%edx
  800a13:	f7 da                	neg    %edx
  800a15:	85 ff                	test   %edi,%edi
  800a17:	0f 45 c2             	cmovne %edx,%eax
}
  800a1a:	5b                   	pop    %ebx
  800a1b:	5e                   	pop    %esi
  800a1c:	5f                   	pop    %edi
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	57                   	push   %edi
  800a23:	56                   	push   %esi
  800a24:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a25:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a30:	89 c3                	mov    %eax,%ebx
  800a32:	89 c7                	mov    %eax,%edi
  800a34:	89 c6                	mov    %eax,%esi
  800a36:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a38:	5b                   	pop    %ebx
  800a39:	5e                   	pop    %esi
  800a3a:	5f                   	pop    %edi
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <sys_cgetc>:

int
sys_cgetc(void)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	57                   	push   %edi
  800a41:	56                   	push   %esi
  800a42:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a43:	ba 00 00 00 00       	mov    $0x0,%edx
  800a48:	b8 01 00 00 00       	mov    $0x1,%eax
  800a4d:	89 d1                	mov    %edx,%ecx
  800a4f:	89 d3                	mov    %edx,%ebx
  800a51:	89 d7                	mov    %edx,%edi
  800a53:	89 d6                	mov    %edx,%esi
  800a55:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a57:	5b                   	pop    %ebx
  800a58:	5e                   	pop    %esi
  800a59:	5f                   	pop    %edi
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	57                   	push   %edi
  800a60:	56                   	push   %esi
  800a61:	53                   	push   %ebx
  800a62:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a65:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a6a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a72:	89 cb                	mov    %ecx,%ebx
  800a74:	89 cf                	mov    %ecx,%edi
  800a76:	89 ce                	mov    %ecx,%esi
  800a78:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a7a:	85 c0                	test   %eax,%eax
  800a7c:	7e 17                	jle    800a95 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a7e:	83 ec 0c             	sub    $0xc,%esp
  800a81:	50                   	push   %eax
  800a82:	6a 03                	push   $0x3
  800a84:	68 bf 20 80 00       	push   $0x8020bf
  800a89:	6a 23                	push   $0x23
  800a8b:	68 dc 20 80 00       	push   $0x8020dc
  800a90:	e8 f5 0e 00 00       	call   80198a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a98:	5b                   	pop    %ebx
  800a99:	5e                   	pop    %esi
  800a9a:	5f                   	pop    %edi
  800a9b:	5d                   	pop    %ebp
  800a9c:	c3                   	ret    

00800a9d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	57                   	push   %edi
  800aa1:	56                   	push   %esi
  800aa2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa3:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa8:	b8 02 00 00 00       	mov    $0x2,%eax
  800aad:	89 d1                	mov    %edx,%ecx
  800aaf:	89 d3                	mov    %edx,%ebx
  800ab1:	89 d7                	mov    %edx,%edi
  800ab3:	89 d6                	mov    %edx,%esi
  800ab5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ab7:	5b                   	pop    %ebx
  800ab8:	5e                   	pop    %esi
  800ab9:	5f                   	pop    %edi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <sys_yield>:

void
sys_yield(void)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	57                   	push   %edi
  800ac0:	56                   	push   %esi
  800ac1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800acc:	89 d1                	mov    %edx,%ecx
  800ace:	89 d3                	mov    %edx,%ebx
  800ad0:	89 d7                	mov    %edx,%edi
  800ad2:	89 d6                	mov    %edx,%esi
  800ad4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5f                   	pop    %edi
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	57                   	push   %edi
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
  800ae1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae4:	be 00 00 00 00       	mov    $0x0,%esi
  800ae9:	b8 04 00 00 00       	mov    $0x4,%eax
  800aee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af1:	8b 55 08             	mov    0x8(%ebp),%edx
  800af4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800af7:	89 f7                	mov    %esi,%edi
  800af9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800afb:	85 c0                	test   %eax,%eax
  800afd:	7e 17                	jle    800b16 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aff:	83 ec 0c             	sub    $0xc,%esp
  800b02:	50                   	push   %eax
  800b03:	6a 04                	push   $0x4
  800b05:	68 bf 20 80 00       	push   $0x8020bf
  800b0a:	6a 23                	push   $0x23
  800b0c:	68 dc 20 80 00       	push   $0x8020dc
  800b11:	e8 74 0e 00 00       	call   80198a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
  800b24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b27:	b8 05 00 00 00       	mov    $0x5,%eax
  800b2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b32:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b35:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b38:	8b 75 18             	mov    0x18(%ebp),%esi
  800b3b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b3d:	85 c0                	test   %eax,%eax
  800b3f:	7e 17                	jle    800b58 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b41:	83 ec 0c             	sub    $0xc,%esp
  800b44:	50                   	push   %eax
  800b45:	6a 05                	push   $0x5
  800b47:	68 bf 20 80 00       	push   $0x8020bf
  800b4c:	6a 23                	push   $0x23
  800b4e:	68 dc 20 80 00       	push   $0x8020dc
  800b53:	e8 32 0e 00 00       	call   80198a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5b:	5b                   	pop    %ebx
  800b5c:	5e                   	pop    %esi
  800b5d:	5f                   	pop    %edi
  800b5e:	5d                   	pop    %ebp
  800b5f:	c3                   	ret    

00800b60 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	57                   	push   %edi
  800b64:	56                   	push   %esi
  800b65:	53                   	push   %ebx
  800b66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b69:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b6e:	b8 06 00 00 00       	mov    $0x6,%eax
  800b73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b76:	8b 55 08             	mov    0x8(%ebp),%edx
  800b79:	89 df                	mov    %ebx,%edi
  800b7b:	89 de                	mov    %ebx,%esi
  800b7d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b7f:	85 c0                	test   %eax,%eax
  800b81:	7e 17                	jle    800b9a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b83:	83 ec 0c             	sub    $0xc,%esp
  800b86:	50                   	push   %eax
  800b87:	6a 06                	push   $0x6
  800b89:	68 bf 20 80 00       	push   $0x8020bf
  800b8e:	6a 23                	push   $0x23
  800b90:	68 dc 20 80 00       	push   $0x8020dc
  800b95:	e8 f0 0d 00 00       	call   80198a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9d:	5b                   	pop    %ebx
  800b9e:	5e                   	pop    %esi
  800b9f:	5f                   	pop    %edi
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb0:	b8 08 00 00 00       	mov    $0x8,%eax
  800bb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbb:	89 df                	mov    %ebx,%edi
  800bbd:	89 de                	mov    %ebx,%esi
  800bbf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc1:	85 c0                	test   %eax,%eax
  800bc3:	7e 17                	jle    800bdc <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc5:	83 ec 0c             	sub    $0xc,%esp
  800bc8:	50                   	push   %eax
  800bc9:	6a 08                	push   $0x8
  800bcb:	68 bf 20 80 00       	push   $0x8020bf
  800bd0:	6a 23                	push   $0x23
  800bd2:	68 dc 20 80 00       	push   $0x8020dc
  800bd7:	e8 ae 0d 00 00       	call   80198a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5f                   	pop    %edi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	57                   	push   %edi
  800be8:	56                   	push   %esi
  800be9:	53                   	push   %ebx
  800bea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bed:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf2:	b8 09 00 00 00       	mov    $0x9,%eax
  800bf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfd:	89 df                	mov    %ebx,%edi
  800bff:	89 de                	mov    %ebx,%esi
  800c01:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c03:	85 c0                	test   %eax,%eax
  800c05:	7e 17                	jle    800c1e <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c07:	83 ec 0c             	sub    $0xc,%esp
  800c0a:	50                   	push   %eax
  800c0b:	6a 09                	push   $0x9
  800c0d:	68 bf 20 80 00       	push   $0x8020bf
  800c12:	6a 23                	push   $0x23
  800c14:	68 dc 20 80 00       	push   $0x8020dc
  800c19:	e8 6c 0d 00 00       	call   80198a <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
  800c2c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c34:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3f:	89 df                	mov    %ebx,%edi
  800c41:	89 de                	mov    %ebx,%esi
  800c43:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c45:	85 c0                	test   %eax,%eax
  800c47:	7e 17                	jle    800c60 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c49:	83 ec 0c             	sub    $0xc,%esp
  800c4c:	50                   	push   %eax
  800c4d:	6a 0a                	push   $0xa
  800c4f:	68 bf 20 80 00       	push   $0x8020bf
  800c54:	6a 23                	push   $0x23
  800c56:	68 dc 20 80 00       	push   $0x8020dc
  800c5b:	e8 2a 0d 00 00       	call   80198a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5f                   	pop    %edi
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	57                   	push   %edi
  800c6c:	56                   	push   %esi
  800c6d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6e:	be 00 00 00 00       	mov    $0x0,%esi
  800c73:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c81:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c84:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c86:	5b                   	pop    %ebx
  800c87:	5e                   	pop    %esi
  800c88:	5f                   	pop    %edi
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    

00800c8b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	57                   	push   %edi
  800c8f:	56                   	push   %esi
  800c90:	53                   	push   %ebx
  800c91:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c94:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c99:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca1:	89 cb                	mov    %ecx,%ebx
  800ca3:	89 cf                	mov    %ecx,%edi
  800ca5:	89 ce                	mov    %ecx,%esi
  800ca7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca9:	85 c0                	test   %eax,%eax
  800cab:	7e 17                	jle    800cc4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cad:	83 ec 0c             	sub    $0xc,%esp
  800cb0:	50                   	push   %eax
  800cb1:	6a 0d                	push   $0xd
  800cb3:	68 bf 20 80 00       	push   $0x8020bf
  800cb8:	6a 23                	push   $0x23
  800cba:	68 dc 20 80 00       	push   $0x8020dc
  800cbf:	e8 c6 0c 00 00       	call   80198a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ccf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd2:	05 00 00 00 30       	add    $0x30000000,%eax
  800cd7:	c1 e8 0c             	shr    $0xc,%eax
}
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    

00800cdc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800cdf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce2:	05 00 00 00 30       	add    $0x30000000,%eax
  800ce7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800cec:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800cf1:	5d                   	pop    %ebp
  800cf2:	c3                   	ret    

00800cf3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800cfe:	89 c2                	mov    %eax,%edx
  800d00:	c1 ea 16             	shr    $0x16,%edx
  800d03:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d0a:	f6 c2 01             	test   $0x1,%dl
  800d0d:	74 11                	je     800d20 <fd_alloc+0x2d>
  800d0f:	89 c2                	mov    %eax,%edx
  800d11:	c1 ea 0c             	shr    $0xc,%edx
  800d14:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d1b:	f6 c2 01             	test   $0x1,%dl
  800d1e:	75 09                	jne    800d29 <fd_alloc+0x36>
			*fd_store = fd;
  800d20:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d22:	b8 00 00 00 00       	mov    $0x0,%eax
  800d27:	eb 17                	jmp    800d40 <fd_alloc+0x4d>
  800d29:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d2e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d33:	75 c9                	jne    800cfe <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d35:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d3b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    

00800d42 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d48:	83 f8 1f             	cmp    $0x1f,%eax
  800d4b:	77 36                	ja     800d83 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d4d:	c1 e0 0c             	shl    $0xc,%eax
  800d50:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d55:	89 c2                	mov    %eax,%edx
  800d57:	c1 ea 16             	shr    $0x16,%edx
  800d5a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d61:	f6 c2 01             	test   $0x1,%dl
  800d64:	74 24                	je     800d8a <fd_lookup+0x48>
  800d66:	89 c2                	mov    %eax,%edx
  800d68:	c1 ea 0c             	shr    $0xc,%edx
  800d6b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d72:	f6 c2 01             	test   $0x1,%dl
  800d75:	74 1a                	je     800d91 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800d77:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d7a:	89 02                	mov    %eax,(%edx)
	return 0;
  800d7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d81:	eb 13                	jmp    800d96 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800d83:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d88:	eb 0c                	jmp    800d96 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800d8a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d8f:	eb 05                	jmp    800d96 <fd_lookup+0x54>
  800d91:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    

00800d98 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	83 ec 08             	sub    $0x8,%esp
  800d9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da1:	ba 68 21 80 00       	mov    $0x802168,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800da6:	eb 13                	jmp    800dbb <dev_lookup+0x23>
  800da8:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800dab:	39 08                	cmp    %ecx,(%eax)
  800dad:	75 0c                	jne    800dbb <dev_lookup+0x23>
			*dev = devtab[i];
  800daf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db2:	89 01                	mov    %eax,(%ecx)
			return 0;
  800db4:	b8 00 00 00 00       	mov    $0x0,%eax
  800db9:	eb 2e                	jmp    800de9 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800dbb:	8b 02                	mov    (%edx),%eax
  800dbd:	85 c0                	test   %eax,%eax
  800dbf:	75 e7                	jne    800da8 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800dc1:	a1 08 40 80 00       	mov    0x804008,%eax
  800dc6:	8b 40 48             	mov    0x48(%eax),%eax
  800dc9:	83 ec 04             	sub    $0x4,%esp
  800dcc:	51                   	push   %ecx
  800dcd:	50                   	push   %eax
  800dce:	68 ec 20 80 00       	push   $0x8020ec
  800dd3:	e8 7b f3 ff ff       	call   800153 <cprintf>
	*dev = 0;
  800dd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ddb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800de1:	83 c4 10             	add    $0x10,%esp
  800de4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800de9:	c9                   	leave  
  800dea:	c3                   	ret    

00800deb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	56                   	push   %esi
  800def:	53                   	push   %ebx
  800df0:	83 ec 10             	sub    $0x10,%esp
  800df3:	8b 75 08             	mov    0x8(%ebp),%esi
  800df6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800df9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800dfc:	50                   	push   %eax
  800dfd:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e03:	c1 e8 0c             	shr    $0xc,%eax
  800e06:	50                   	push   %eax
  800e07:	e8 36 ff ff ff       	call   800d42 <fd_lookup>
  800e0c:	83 c4 08             	add    $0x8,%esp
  800e0f:	85 c0                	test   %eax,%eax
  800e11:	78 05                	js     800e18 <fd_close+0x2d>
	    || fd != fd2)
  800e13:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e16:	74 0c                	je     800e24 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e18:	84 db                	test   %bl,%bl
  800e1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e1f:	0f 44 c2             	cmove  %edx,%eax
  800e22:	eb 41                	jmp    800e65 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e24:	83 ec 08             	sub    $0x8,%esp
  800e27:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e2a:	50                   	push   %eax
  800e2b:	ff 36                	pushl  (%esi)
  800e2d:	e8 66 ff ff ff       	call   800d98 <dev_lookup>
  800e32:	89 c3                	mov    %eax,%ebx
  800e34:	83 c4 10             	add    $0x10,%esp
  800e37:	85 c0                	test   %eax,%eax
  800e39:	78 1a                	js     800e55 <fd_close+0x6a>
		if (dev->dev_close)
  800e3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e3e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e41:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e46:	85 c0                	test   %eax,%eax
  800e48:	74 0b                	je     800e55 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800e4a:	83 ec 0c             	sub    $0xc,%esp
  800e4d:	56                   	push   %esi
  800e4e:	ff d0                	call   *%eax
  800e50:	89 c3                	mov    %eax,%ebx
  800e52:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e55:	83 ec 08             	sub    $0x8,%esp
  800e58:	56                   	push   %esi
  800e59:	6a 00                	push   $0x0
  800e5b:	e8 00 fd ff ff       	call   800b60 <sys_page_unmap>
	return r;
  800e60:	83 c4 10             	add    $0x10,%esp
  800e63:	89 d8                	mov    %ebx,%eax
}
  800e65:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e68:	5b                   	pop    %ebx
  800e69:	5e                   	pop    %esi
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    

00800e6c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e75:	50                   	push   %eax
  800e76:	ff 75 08             	pushl  0x8(%ebp)
  800e79:	e8 c4 fe ff ff       	call   800d42 <fd_lookup>
  800e7e:	83 c4 08             	add    $0x8,%esp
  800e81:	85 c0                	test   %eax,%eax
  800e83:	78 10                	js     800e95 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800e85:	83 ec 08             	sub    $0x8,%esp
  800e88:	6a 01                	push   $0x1
  800e8a:	ff 75 f4             	pushl  -0xc(%ebp)
  800e8d:	e8 59 ff ff ff       	call   800deb <fd_close>
  800e92:	83 c4 10             	add    $0x10,%esp
}
  800e95:	c9                   	leave  
  800e96:	c3                   	ret    

00800e97 <close_all>:

void
close_all(void)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	53                   	push   %ebx
  800e9b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800e9e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ea3:	83 ec 0c             	sub    $0xc,%esp
  800ea6:	53                   	push   %ebx
  800ea7:	e8 c0 ff ff ff       	call   800e6c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800eac:	83 c3 01             	add    $0x1,%ebx
  800eaf:	83 c4 10             	add    $0x10,%esp
  800eb2:	83 fb 20             	cmp    $0x20,%ebx
  800eb5:	75 ec                	jne    800ea3 <close_all+0xc>
		close(i);
}
  800eb7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eba:	c9                   	leave  
  800ebb:	c3                   	ret    

00800ebc <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	57                   	push   %edi
  800ec0:	56                   	push   %esi
  800ec1:	53                   	push   %ebx
  800ec2:	83 ec 2c             	sub    $0x2c,%esp
  800ec5:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ec8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ecb:	50                   	push   %eax
  800ecc:	ff 75 08             	pushl  0x8(%ebp)
  800ecf:	e8 6e fe ff ff       	call   800d42 <fd_lookup>
  800ed4:	83 c4 08             	add    $0x8,%esp
  800ed7:	85 c0                	test   %eax,%eax
  800ed9:	0f 88 c1 00 00 00    	js     800fa0 <dup+0xe4>
		return r;
	close(newfdnum);
  800edf:	83 ec 0c             	sub    $0xc,%esp
  800ee2:	56                   	push   %esi
  800ee3:	e8 84 ff ff ff       	call   800e6c <close>

	newfd = INDEX2FD(newfdnum);
  800ee8:	89 f3                	mov    %esi,%ebx
  800eea:	c1 e3 0c             	shl    $0xc,%ebx
  800eed:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800ef3:	83 c4 04             	add    $0x4,%esp
  800ef6:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ef9:	e8 de fd ff ff       	call   800cdc <fd2data>
  800efe:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f00:	89 1c 24             	mov    %ebx,(%esp)
  800f03:	e8 d4 fd ff ff       	call   800cdc <fd2data>
  800f08:	83 c4 10             	add    $0x10,%esp
  800f0b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f0e:	89 f8                	mov    %edi,%eax
  800f10:	c1 e8 16             	shr    $0x16,%eax
  800f13:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f1a:	a8 01                	test   $0x1,%al
  800f1c:	74 37                	je     800f55 <dup+0x99>
  800f1e:	89 f8                	mov    %edi,%eax
  800f20:	c1 e8 0c             	shr    $0xc,%eax
  800f23:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f2a:	f6 c2 01             	test   $0x1,%dl
  800f2d:	74 26                	je     800f55 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f2f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f36:	83 ec 0c             	sub    $0xc,%esp
  800f39:	25 07 0e 00 00       	and    $0xe07,%eax
  800f3e:	50                   	push   %eax
  800f3f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f42:	6a 00                	push   $0x0
  800f44:	57                   	push   %edi
  800f45:	6a 00                	push   $0x0
  800f47:	e8 d2 fb ff ff       	call   800b1e <sys_page_map>
  800f4c:	89 c7                	mov    %eax,%edi
  800f4e:	83 c4 20             	add    $0x20,%esp
  800f51:	85 c0                	test   %eax,%eax
  800f53:	78 2e                	js     800f83 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f55:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f58:	89 d0                	mov    %edx,%eax
  800f5a:	c1 e8 0c             	shr    $0xc,%eax
  800f5d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f64:	83 ec 0c             	sub    $0xc,%esp
  800f67:	25 07 0e 00 00       	and    $0xe07,%eax
  800f6c:	50                   	push   %eax
  800f6d:	53                   	push   %ebx
  800f6e:	6a 00                	push   $0x0
  800f70:	52                   	push   %edx
  800f71:	6a 00                	push   $0x0
  800f73:	e8 a6 fb ff ff       	call   800b1e <sys_page_map>
  800f78:	89 c7                	mov    %eax,%edi
  800f7a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800f7d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f7f:	85 ff                	test   %edi,%edi
  800f81:	79 1d                	jns    800fa0 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800f83:	83 ec 08             	sub    $0x8,%esp
  800f86:	53                   	push   %ebx
  800f87:	6a 00                	push   $0x0
  800f89:	e8 d2 fb ff ff       	call   800b60 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800f8e:	83 c4 08             	add    $0x8,%esp
  800f91:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f94:	6a 00                	push   $0x0
  800f96:	e8 c5 fb ff ff       	call   800b60 <sys_page_unmap>
	return r;
  800f9b:	83 c4 10             	add    $0x10,%esp
  800f9e:	89 f8                	mov    %edi,%eax
}
  800fa0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa3:	5b                   	pop    %ebx
  800fa4:	5e                   	pop    %esi
  800fa5:	5f                   	pop    %edi
  800fa6:	5d                   	pop    %ebp
  800fa7:	c3                   	ret    

00800fa8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	53                   	push   %ebx
  800fac:	83 ec 14             	sub    $0x14,%esp
  800faf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fb2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fb5:	50                   	push   %eax
  800fb6:	53                   	push   %ebx
  800fb7:	e8 86 fd ff ff       	call   800d42 <fd_lookup>
  800fbc:	83 c4 08             	add    $0x8,%esp
  800fbf:	89 c2                	mov    %eax,%edx
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	78 6d                	js     801032 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800fc5:	83 ec 08             	sub    $0x8,%esp
  800fc8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fcb:	50                   	push   %eax
  800fcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fcf:	ff 30                	pushl  (%eax)
  800fd1:	e8 c2 fd ff ff       	call   800d98 <dev_lookup>
  800fd6:	83 c4 10             	add    $0x10,%esp
  800fd9:	85 c0                	test   %eax,%eax
  800fdb:	78 4c                	js     801029 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800fdd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fe0:	8b 42 08             	mov    0x8(%edx),%eax
  800fe3:	83 e0 03             	and    $0x3,%eax
  800fe6:	83 f8 01             	cmp    $0x1,%eax
  800fe9:	75 21                	jne    80100c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800feb:	a1 08 40 80 00       	mov    0x804008,%eax
  800ff0:	8b 40 48             	mov    0x48(%eax),%eax
  800ff3:	83 ec 04             	sub    $0x4,%esp
  800ff6:	53                   	push   %ebx
  800ff7:	50                   	push   %eax
  800ff8:	68 2d 21 80 00       	push   $0x80212d
  800ffd:	e8 51 f1 ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  801002:	83 c4 10             	add    $0x10,%esp
  801005:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80100a:	eb 26                	jmp    801032 <read+0x8a>
	}
	if (!dev->dev_read)
  80100c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80100f:	8b 40 08             	mov    0x8(%eax),%eax
  801012:	85 c0                	test   %eax,%eax
  801014:	74 17                	je     80102d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801016:	83 ec 04             	sub    $0x4,%esp
  801019:	ff 75 10             	pushl  0x10(%ebp)
  80101c:	ff 75 0c             	pushl  0xc(%ebp)
  80101f:	52                   	push   %edx
  801020:	ff d0                	call   *%eax
  801022:	89 c2                	mov    %eax,%edx
  801024:	83 c4 10             	add    $0x10,%esp
  801027:	eb 09                	jmp    801032 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801029:	89 c2                	mov    %eax,%edx
  80102b:	eb 05                	jmp    801032 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80102d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801032:	89 d0                	mov    %edx,%eax
  801034:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801037:	c9                   	leave  
  801038:	c3                   	ret    

00801039 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	57                   	push   %edi
  80103d:	56                   	push   %esi
  80103e:	53                   	push   %ebx
  80103f:	83 ec 0c             	sub    $0xc,%esp
  801042:	8b 7d 08             	mov    0x8(%ebp),%edi
  801045:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801048:	bb 00 00 00 00       	mov    $0x0,%ebx
  80104d:	eb 21                	jmp    801070 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80104f:	83 ec 04             	sub    $0x4,%esp
  801052:	89 f0                	mov    %esi,%eax
  801054:	29 d8                	sub    %ebx,%eax
  801056:	50                   	push   %eax
  801057:	89 d8                	mov    %ebx,%eax
  801059:	03 45 0c             	add    0xc(%ebp),%eax
  80105c:	50                   	push   %eax
  80105d:	57                   	push   %edi
  80105e:	e8 45 ff ff ff       	call   800fa8 <read>
		if (m < 0)
  801063:	83 c4 10             	add    $0x10,%esp
  801066:	85 c0                	test   %eax,%eax
  801068:	78 10                	js     80107a <readn+0x41>
			return m;
		if (m == 0)
  80106a:	85 c0                	test   %eax,%eax
  80106c:	74 0a                	je     801078 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80106e:	01 c3                	add    %eax,%ebx
  801070:	39 f3                	cmp    %esi,%ebx
  801072:	72 db                	jb     80104f <readn+0x16>
  801074:	89 d8                	mov    %ebx,%eax
  801076:	eb 02                	jmp    80107a <readn+0x41>
  801078:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80107a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80107d:	5b                   	pop    %ebx
  80107e:	5e                   	pop    %esi
  80107f:	5f                   	pop    %edi
  801080:	5d                   	pop    %ebp
  801081:	c3                   	ret    

00801082 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801082:	55                   	push   %ebp
  801083:	89 e5                	mov    %esp,%ebp
  801085:	53                   	push   %ebx
  801086:	83 ec 14             	sub    $0x14,%esp
  801089:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80108c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80108f:	50                   	push   %eax
  801090:	53                   	push   %ebx
  801091:	e8 ac fc ff ff       	call   800d42 <fd_lookup>
  801096:	83 c4 08             	add    $0x8,%esp
  801099:	89 c2                	mov    %eax,%edx
  80109b:	85 c0                	test   %eax,%eax
  80109d:	78 68                	js     801107 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80109f:	83 ec 08             	sub    $0x8,%esp
  8010a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010a5:	50                   	push   %eax
  8010a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010a9:	ff 30                	pushl  (%eax)
  8010ab:	e8 e8 fc ff ff       	call   800d98 <dev_lookup>
  8010b0:	83 c4 10             	add    $0x10,%esp
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	78 47                	js     8010fe <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010ba:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8010be:	75 21                	jne    8010e1 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8010c0:	a1 08 40 80 00       	mov    0x804008,%eax
  8010c5:	8b 40 48             	mov    0x48(%eax),%eax
  8010c8:	83 ec 04             	sub    $0x4,%esp
  8010cb:	53                   	push   %ebx
  8010cc:	50                   	push   %eax
  8010cd:	68 49 21 80 00       	push   $0x802149
  8010d2:	e8 7c f0 ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  8010d7:	83 c4 10             	add    $0x10,%esp
  8010da:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010df:	eb 26                	jmp    801107 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8010e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010e4:	8b 52 0c             	mov    0xc(%edx),%edx
  8010e7:	85 d2                	test   %edx,%edx
  8010e9:	74 17                	je     801102 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8010eb:	83 ec 04             	sub    $0x4,%esp
  8010ee:	ff 75 10             	pushl  0x10(%ebp)
  8010f1:	ff 75 0c             	pushl  0xc(%ebp)
  8010f4:	50                   	push   %eax
  8010f5:	ff d2                	call   *%edx
  8010f7:	89 c2                	mov    %eax,%edx
  8010f9:	83 c4 10             	add    $0x10,%esp
  8010fc:	eb 09                	jmp    801107 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010fe:	89 c2                	mov    %eax,%edx
  801100:	eb 05                	jmp    801107 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801102:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801107:	89 d0                	mov    %edx,%eax
  801109:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80110c:	c9                   	leave  
  80110d:	c3                   	ret    

0080110e <seek>:

int
seek(int fdnum, off_t offset)
{
  80110e:	55                   	push   %ebp
  80110f:	89 e5                	mov    %esp,%ebp
  801111:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801114:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801117:	50                   	push   %eax
  801118:	ff 75 08             	pushl  0x8(%ebp)
  80111b:	e8 22 fc ff ff       	call   800d42 <fd_lookup>
  801120:	83 c4 08             	add    $0x8,%esp
  801123:	85 c0                	test   %eax,%eax
  801125:	78 0e                	js     801135 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801127:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80112a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80112d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801130:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801135:	c9                   	leave  
  801136:	c3                   	ret    

00801137 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	53                   	push   %ebx
  80113b:	83 ec 14             	sub    $0x14,%esp
  80113e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801141:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801144:	50                   	push   %eax
  801145:	53                   	push   %ebx
  801146:	e8 f7 fb ff ff       	call   800d42 <fd_lookup>
  80114b:	83 c4 08             	add    $0x8,%esp
  80114e:	89 c2                	mov    %eax,%edx
  801150:	85 c0                	test   %eax,%eax
  801152:	78 65                	js     8011b9 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801154:	83 ec 08             	sub    $0x8,%esp
  801157:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80115a:	50                   	push   %eax
  80115b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80115e:	ff 30                	pushl  (%eax)
  801160:	e8 33 fc ff ff       	call   800d98 <dev_lookup>
  801165:	83 c4 10             	add    $0x10,%esp
  801168:	85 c0                	test   %eax,%eax
  80116a:	78 44                	js     8011b0 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80116c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80116f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801173:	75 21                	jne    801196 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801175:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80117a:	8b 40 48             	mov    0x48(%eax),%eax
  80117d:	83 ec 04             	sub    $0x4,%esp
  801180:	53                   	push   %ebx
  801181:	50                   	push   %eax
  801182:	68 0c 21 80 00       	push   $0x80210c
  801187:	e8 c7 ef ff ff       	call   800153 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80118c:	83 c4 10             	add    $0x10,%esp
  80118f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801194:	eb 23                	jmp    8011b9 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801196:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801199:	8b 52 18             	mov    0x18(%edx),%edx
  80119c:	85 d2                	test   %edx,%edx
  80119e:	74 14                	je     8011b4 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011a0:	83 ec 08             	sub    $0x8,%esp
  8011a3:	ff 75 0c             	pushl  0xc(%ebp)
  8011a6:	50                   	push   %eax
  8011a7:	ff d2                	call   *%edx
  8011a9:	89 c2                	mov    %eax,%edx
  8011ab:	83 c4 10             	add    $0x10,%esp
  8011ae:	eb 09                	jmp    8011b9 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b0:	89 c2                	mov    %eax,%edx
  8011b2:	eb 05                	jmp    8011b9 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011b4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8011b9:	89 d0                	mov    %edx,%eax
  8011bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011be:	c9                   	leave  
  8011bf:	c3                   	ret    

008011c0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
  8011c3:	53                   	push   %ebx
  8011c4:	83 ec 14             	sub    $0x14,%esp
  8011c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011cd:	50                   	push   %eax
  8011ce:	ff 75 08             	pushl  0x8(%ebp)
  8011d1:	e8 6c fb ff ff       	call   800d42 <fd_lookup>
  8011d6:	83 c4 08             	add    $0x8,%esp
  8011d9:	89 c2                	mov    %eax,%edx
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	78 58                	js     801237 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011df:	83 ec 08             	sub    $0x8,%esp
  8011e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e5:	50                   	push   %eax
  8011e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e9:	ff 30                	pushl  (%eax)
  8011eb:	e8 a8 fb ff ff       	call   800d98 <dev_lookup>
  8011f0:	83 c4 10             	add    $0x10,%esp
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	78 37                	js     80122e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8011f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011fa:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8011fe:	74 32                	je     801232 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801200:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801203:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80120a:	00 00 00 
	stat->st_isdir = 0;
  80120d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801214:	00 00 00 
	stat->st_dev = dev;
  801217:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80121d:	83 ec 08             	sub    $0x8,%esp
  801220:	53                   	push   %ebx
  801221:	ff 75 f0             	pushl  -0x10(%ebp)
  801224:	ff 50 14             	call   *0x14(%eax)
  801227:	89 c2                	mov    %eax,%edx
  801229:	83 c4 10             	add    $0x10,%esp
  80122c:	eb 09                	jmp    801237 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80122e:	89 c2                	mov    %eax,%edx
  801230:	eb 05                	jmp    801237 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801232:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801237:	89 d0                	mov    %edx,%eax
  801239:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80123c:	c9                   	leave  
  80123d:	c3                   	ret    

0080123e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80123e:	55                   	push   %ebp
  80123f:	89 e5                	mov    %esp,%ebp
  801241:	56                   	push   %esi
  801242:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801243:	83 ec 08             	sub    $0x8,%esp
  801246:	6a 00                	push   $0x0
  801248:	ff 75 08             	pushl  0x8(%ebp)
  80124b:	e8 b7 01 00 00       	call   801407 <open>
  801250:	89 c3                	mov    %eax,%ebx
  801252:	83 c4 10             	add    $0x10,%esp
  801255:	85 c0                	test   %eax,%eax
  801257:	78 1b                	js     801274 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801259:	83 ec 08             	sub    $0x8,%esp
  80125c:	ff 75 0c             	pushl  0xc(%ebp)
  80125f:	50                   	push   %eax
  801260:	e8 5b ff ff ff       	call   8011c0 <fstat>
  801265:	89 c6                	mov    %eax,%esi
	close(fd);
  801267:	89 1c 24             	mov    %ebx,(%esp)
  80126a:	e8 fd fb ff ff       	call   800e6c <close>
	return r;
  80126f:	83 c4 10             	add    $0x10,%esp
  801272:	89 f0                	mov    %esi,%eax
}
  801274:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801277:	5b                   	pop    %ebx
  801278:	5e                   	pop    %esi
  801279:	5d                   	pop    %ebp
  80127a:	c3                   	ret    

0080127b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
  80127e:	56                   	push   %esi
  80127f:	53                   	push   %ebx
  801280:	89 c6                	mov    %eax,%esi
  801282:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801284:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80128b:	75 12                	jne    80129f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80128d:	83 ec 0c             	sub    $0xc,%esp
  801290:	6a 01                	push   $0x1
  801292:	e8 f4 07 00 00       	call   801a8b <ipc_find_env>
  801297:	a3 00 40 80 00       	mov    %eax,0x804000
  80129c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80129f:	6a 07                	push   $0x7
  8012a1:	68 00 50 80 00       	push   $0x805000
  8012a6:	56                   	push   %esi
  8012a7:	ff 35 00 40 80 00    	pushl  0x804000
  8012ad:	e8 85 07 00 00       	call   801a37 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012b2:	83 c4 0c             	add    $0xc,%esp
  8012b5:	6a 00                	push   $0x0
  8012b7:	53                   	push   %ebx
  8012b8:	6a 00                	push   $0x0
  8012ba:	e8 11 07 00 00       	call   8019d0 <ipc_recv>
}
  8012bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012c2:	5b                   	pop    %ebx
  8012c3:	5e                   	pop    %esi
  8012c4:	5d                   	pop    %ebp
  8012c5:	c3                   	ret    

008012c6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8012c6:	55                   	push   %ebp
  8012c7:	89 e5                	mov    %esp,%ebp
  8012c9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8012cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8012cf:	8b 40 0c             	mov    0xc(%eax),%eax
  8012d2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8012d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012da:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8012df:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e4:	b8 02 00 00 00       	mov    $0x2,%eax
  8012e9:	e8 8d ff ff ff       	call   80127b <fsipc>
}
  8012ee:	c9                   	leave  
  8012ef:	c3                   	ret    

008012f0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8012f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f9:	8b 40 0c             	mov    0xc(%eax),%eax
  8012fc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801301:	ba 00 00 00 00       	mov    $0x0,%edx
  801306:	b8 06 00 00 00       	mov    $0x6,%eax
  80130b:	e8 6b ff ff ff       	call   80127b <fsipc>
}
  801310:	c9                   	leave  
  801311:	c3                   	ret    

00801312 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801312:	55                   	push   %ebp
  801313:	89 e5                	mov    %esp,%ebp
  801315:	53                   	push   %ebx
  801316:	83 ec 04             	sub    $0x4,%esp
  801319:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80131c:	8b 45 08             	mov    0x8(%ebp),%eax
  80131f:	8b 40 0c             	mov    0xc(%eax),%eax
  801322:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801327:	ba 00 00 00 00       	mov    $0x0,%edx
  80132c:	b8 05 00 00 00       	mov    $0x5,%eax
  801331:	e8 45 ff ff ff       	call   80127b <fsipc>
  801336:	85 c0                	test   %eax,%eax
  801338:	78 2c                	js     801366 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80133a:	83 ec 08             	sub    $0x8,%esp
  80133d:	68 00 50 80 00       	push   $0x805000
  801342:	53                   	push   %ebx
  801343:	e8 90 f3 ff ff       	call   8006d8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801348:	a1 80 50 80 00       	mov    0x805080,%eax
  80134d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801353:	a1 84 50 80 00       	mov    0x805084,%eax
  801358:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80135e:	83 c4 10             	add    $0x10,%esp
  801361:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801366:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801369:	c9                   	leave  
  80136a:	c3                   	ret    

0080136b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
  80136e:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801371:	68 78 21 80 00       	push   $0x802178
  801376:	68 90 00 00 00       	push   $0x90
  80137b:	68 96 21 80 00       	push   $0x802196
  801380:	e8 05 06 00 00       	call   80198a <_panic>

00801385 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801385:	55                   	push   %ebp
  801386:	89 e5                	mov    %esp,%ebp
  801388:	56                   	push   %esi
  801389:	53                   	push   %ebx
  80138a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80138d:	8b 45 08             	mov    0x8(%ebp),%eax
  801390:	8b 40 0c             	mov    0xc(%eax),%eax
  801393:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801398:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80139e:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a3:	b8 03 00 00 00       	mov    $0x3,%eax
  8013a8:	e8 ce fe ff ff       	call   80127b <fsipc>
  8013ad:	89 c3                	mov    %eax,%ebx
  8013af:	85 c0                	test   %eax,%eax
  8013b1:	78 4b                	js     8013fe <devfile_read+0x79>
		return r;
	assert(r <= n);
  8013b3:	39 c6                	cmp    %eax,%esi
  8013b5:	73 16                	jae    8013cd <devfile_read+0x48>
  8013b7:	68 a1 21 80 00       	push   $0x8021a1
  8013bc:	68 a8 21 80 00       	push   $0x8021a8
  8013c1:	6a 7c                	push   $0x7c
  8013c3:	68 96 21 80 00       	push   $0x802196
  8013c8:	e8 bd 05 00 00       	call   80198a <_panic>
	assert(r <= PGSIZE);
  8013cd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8013d2:	7e 16                	jle    8013ea <devfile_read+0x65>
  8013d4:	68 bd 21 80 00       	push   $0x8021bd
  8013d9:	68 a8 21 80 00       	push   $0x8021a8
  8013de:	6a 7d                	push   $0x7d
  8013e0:	68 96 21 80 00       	push   $0x802196
  8013e5:	e8 a0 05 00 00       	call   80198a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8013ea:	83 ec 04             	sub    $0x4,%esp
  8013ed:	50                   	push   %eax
  8013ee:	68 00 50 80 00       	push   $0x805000
  8013f3:	ff 75 0c             	pushl  0xc(%ebp)
  8013f6:	e8 6f f4 ff ff       	call   80086a <memmove>
	return r;
  8013fb:	83 c4 10             	add    $0x10,%esp
}
  8013fe:	89 d8                	mov    %ebx,%eax
  801400:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801403:	5b                   	pop    %ebx
  801404:	5e                   	pop    %esi
  801405:	5d                   	pop    %ebp
  801406:	c3                   	ret    

00801407 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
  80140a:	53                   	push   %ebx
  80140b:	83 ec 20             	sub    $0x20,%esp
  80140e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801411:	53                   	push   %ebx
  801412:	e8 88 f2 ff ff       	call   80069f <strlen>
  801417:	83 c4 10             	add    $0x10,%esp
  80141a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80141f:	7f 67                	jg     801488 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801421:	83 ec 0c             	sub    $0xc,%esp
  801424:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801427:	50                   	push   %eax
  801428:	e8 c6 f8 ff ff       	call   800cf3 <fd_alloc>
  80142d:	83 c4 10             	add    $0x10,%esp
		return r;
  801430:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801432:	85 c0                	test   %eax,%eax
  801434:	78 57                	js     80148d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801436:	83 ec 08             	sub    $0x8,%esp
  801439:	53                   	push   %ebx
  80143a:	68 00 50 80 00       	push   $0x805000
  80143f:	e8 94 f2 ff ff       	call   8006d8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801444:	8b 45 0c             	mov    0xc(%ebp),%eax
  801447:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80144c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80144f:	b8 01 00 00 00       	mov    $0x1,%eax
  801454:	e8 22 fe ff ff       	call   80127b <fsipc>
  801459:	89 c3                	mov    %eax,%ebx
  80145b:	83 c4 10             	add    $0x10,%esp
  80145e:	85 c0                	test   %eax,%eax
  801460:	79 14                	jns    801476 <open+0x6f>
		fd_close(fd, 0);
  801462:	83 ec 08             	sub    $0x8,%esp
  801465:	6a 00                	push   $0x0
  801467:	ff 75 f4             	pushl  -0xc(%ebp)
  80146a:	e8 7c f9 ff ff       	call   800deb <fd_close>
		return r;
  80146f:	83 c4 10             	add    $0x10,%esp
  801472:	89 da                	mov    %ebx,%edx
  801474:	eb 17                	jmp    80148d <open+0x86>
	}

	return fd2num(fd);
  801476:	83 ec 0c             	sub    $0xc,%esp
  801479:	ff 75 f4             	pushl  -0xc(%ebp)
  80147c:	e8 4b f8 ff ff       	call   800ccc <fd2num>
  801481:	89 c2                	mov    %eax,%edx
  801483:	83 c4 10             	add    $0x10,%esp
  801486:	eb 05                	jmp    80148d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801488:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80148d:	89 d0                	mov    %edx,%eax
  80148f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801492:	c9                   	leave  
  801493:	c3                   	ret    

00801494 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801494:	55                   	push   %ebp
  801495:	89 e5                	mov    %esp,%ebp
  801497:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80149a:	ba 00 00 00 00       	mov    $0x0,%edx
  80149f:	b8 08 00 00 00       	mov    $0x8,%eax
  8014a4:	e8 d2 fd ff ff       	call   80127b <fsipc>
}
  8014a9:	c9                   	leave  
  8014aa:	c3                   	ret    

008014ab <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8014ab:	55                   	push   %ebp
  8014ac:	89 e5                	mov    %esp,%ebp
  8014ae:	56                   	push   %esi
  8014af:	53                   	push   %ebx
  8014b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8014b3:	83 ec 0c             	sub    $0xc,%esp
  8014b6:	ff 75 08             	pushl  0x8(%ebp)
  8014b9:	e8 1e f8 ff ff       	call   800cdc <fd2data>
  8014be:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8014c0:	83 c4 08             	add    $0x8,%esp
  8014c3:	68 c9 21 80 00       	push   $0x8021c9
  8014c8:	53                   	push   %ebx
  8014c9:	e8 0a f2 ff ff       	call   8006d8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8014ce:	8b 46 04             	mov    0x4(%esi),%eax
  8014d1:	2b 06                	sub    (%esi),%eax
  8014d3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8014d9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014e0:	00 00 00 
	stat->st_dev = &devpipe;
  8014e3:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8014ea:	30 80 00 
	return 0;
}
  8014ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8014f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014f5:	5b                   	pop    %ebx
  8014f6:	5e                   	pop    %esi
  8014f7:	5d                   	pop    %ebp
  8014f8:	c3                   	ret    

008014f9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8014f9:	55                   	push   %ebp
  8014fa:	89 e5                	mov    %esp,%ebp
  8014fc:	53                   	push   %ebx
  8014fd:	83 ec 0c             	sub    $0xc,%esp
  801500:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801503:	53                   	push   %ebx
  801504:	6a 00                	push   $0x0
  801506:	e8 55 f6 ff ff       	call   800b60 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80150b:	89 1c 24             	mov    %ebx,(%esp)
  80150e:	e8 c9 f7 ff ff       	call   800cdc <fd2data>
  801513:	83 c4 08             	add    $0x8,%esp
  801516:	50                   	push   %eax
  801517:	6a 00                	push   $0x0
  801519:	e8 42 f6 ff ff       	call   800b60 <sys_page_unmap>
}
  80151e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801521:	c9                   	leave  
  801522:	c3                   	ret    

00801523 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	57                   	push   %edi
  801527:	56                   	push   %esi
  801528:	53                   	push   %ebx
  801529:	83 ec 1c             	sub    $0x1c,%esp
  80152c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80152f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801531:	a1 08 40 80 00       	mov    0x804008,%eax
  801536:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801539:	83 ec 0c             	sub    $0xc,%esp
  80153c:	ff 75 e0             	pushl  -0x20(%ebp)
  80153f:	e8 80 05 00 00       	call   801ac4 <pageref>
  801544:	89 c3                	mov    %eax,%ebx
  801546:	89 3c 24             	mov    %edi,(%esp)
  801549:	e8 76 05 00 00       	call   801ac4 <pageref>
  80154e:	83 c4 10             	add    $0x10,%esp
  801551:	39 c3                	cmp    %eax,%ebx
  801553:	0f 94 c1             	sete   %cl
  801556:	0f b6 c9             	movzbl %cl,%ecx
  801559:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80155c:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801562:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801565:	39 ce                	cmp    %ecx,%esi
  801567:	74 1b                	je     801584 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801569:	39 c3                	cmp    %eax,%ebx
  80156b:	75 c4                	jne    801531 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80156d:	8b 42 58             	mov    0x58(%edx),%eax
  801570:	ff 75 e4             	pushl  -0x1c(%ebp)
  801573:	50                   	push   %eax
  801574:	56                   	push   %esi
  801575:	68 d0 21 80 00       	push   $0x8021d0
  80157a:	e8 d4 eb ff ff       	call   800153 <cprintf>
  80157f:	83 c4 10             	add    $0x10,%esp
  801582:	eb ad                	jmp    801531 <_pipeisclosed+0xe>
	}
}
  801584:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801587:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80158a:	5b                   	pop    %ebx
  80158b:	5e                   	pop    %esi
  80158c:	5f                   	pop    %edi
  80158d:	5d                   	pop    %ebp
  80158e:	c3                   	ret    

0080158f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80158f:	55                   	push   %ebp
  801590:	89 e5                	mov    %esp,%ebp
  801592:	57                   	push   %edi
  801593:	56                   	push   %esi
  801594:	53                   	push   %ebx
  801595:	83 ec 28             	sub    $0x28,%esp
  801598:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80159b:	56                   	push   %esi
  80159c:	e8 3b f7 ff ff       	call   800cdc <fd2data>
  8015a1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015a3:	83 c4 10             	add    $0x10,%esp
  8015a6:	bf 00 00 00 00       	mov    $0x0,%edi
  8015ab:	eb 4b                	jmp    8015f8 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8015ad:	89 da                	mov    %ebx,%edx
  8015af:	89 f0                	mov    %esi,%eax
  8015b1:	e8 6d ff ff ff       	call   801523 <_pipeisclosed>
  8015b6:	85 c0                	test   %eax,%eax
  8015b8:	75 48                	jne    801602 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8015ba:	e8 fd f4 ff ff       	call   800abc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8015bf:	8b 43 04             	mov    0x4(%ebx),%eax
  8015c2:	8b 0b                	mov    (%ebx),%ecx
  8015c4:	8d 51 20             	lea    0x20(%ecx),%edx
  8015c7:	39 d0                	cmp    %edx,%eax
  8015c9:	73 e2                	jae    8015ad <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8015cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015ce:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8015d2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8015d5:	89 c2                	mov    %eax,%edx
  8015d7:	c1 fa 1f             	sar    $0x1f,%edx
  8015da:	89 d1                	mov    %edx,%ecx
  8015dc:	c1 e9 1b             	shr    $0x1b,%ecx
  8015df:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8015e2:	83 e2 1f             	and    $0x1f,%edx
  8015e5:	29 ca                	sub    %ecx,%edx
  8015e7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8015eb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8015ef:	83 c0 01             	add    $0x1,%eax
  8015f2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015f5:	83 c7 01             	add    $0x1,%edi
  8015f8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8015fb:	75 c2                	jne    8015bf <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8015fd:	8b 45 10             	mov    0x10(%ebp),%eax
  801600:	eb 05                	jmp    801607 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801602:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801607:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80160a:	5b                   	pop    %ebx
  80160b:	5e                   	pop    %esi
  80160c:	5f                   	pop    %edi
  80160d:	5d                   	pop    %ebp
  80160e:	c3                   	ret    

0080160f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80160f:	55                   	push   %ebp
  801610:	89 e5                	mov    %esp,%ebp
  801612:	57                   	push   %edi
  801613:	56                   	push   %esi
  801614:	53                   	push   %ebx
  801615:	83 ec 18             	sub    $0x18,%esp
  801618:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80161b:	57                   	push   %edi
  80161c:	e8 bb f6 ff ff       	call   800cdc <fd2data>
  801621:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801623:	83 c4 10             	add    $0x10,%esp
  801626:	bb 00 00 00 00       	mov    $0x0,%ebx
  80162b:	eb 3d                	jmp    80166a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80162d:	85 db                	test   %ebx,%ebx
  80162f:	74 04                	je     801635 <devpipe_read+0x26>
				return i;
  801631:	89 d8                	mov    %ebx,%eax
  801633:	eb 44                	jmp    801679 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801635:	89 f2                	mov    %esi,%edx
  801637:	89 f8                	mov    %edi,%eax
  801639:	e8 e5 fe ff ff       	call   801523 <_pipeisclosed>
  80163e:	85 c0                	test   %eax,%eax
  801640:	75 32                	jne    801674 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801642:	e8 75 f4 ff ff       	call   800abc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801647:	8b 06                	mov    (%esi),%eax
  801649:	3b 46 04             	cmp    0x4(%esi),%eax
  80164c:	74 df                	je     80162d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80164e:	99                   	cltd   
  80164f:	c1 ea 1b             	shr    $0x1b,%edx
  801652:	01 d0                	add    %edx,%eax
  801654:	83 e0 1f             	and    $0x1f,%eax
  801657:	29 d0                	sub    %edx,%eax
  801659:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80165e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801661:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801664:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801667:	83 c3 01             	add    $0x1,%ebx
  80166a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80166d:	75 d8                	jne    801647 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80166f:	8b 45 10             	mov    0x10(%ebp),%eax
  801672:	eb 05                	jmp    801679 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801674:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801679:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80167c:	5b                   	pop    %ebx
  80167d:	5e                   	pop    %esi
  80167e:	5f                   	pop    %edi
  80167f:	5d                   	pop    %ebp
  801680:	c3                   	ret    

00801681 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
  801684:	56                   	push   %esi
  801685:	53                   	push   %ebx
  801686:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801689:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80168c:	50                   	push   %eax
  80168d:	e8 61 f6 ff ff       	call   800cf3 <fd_alloc>
  801692:	83 c4 10             	add    $0x10,%esp
  801695:	89 c2                	mov    %eax,%edx
  801697:	85 c0                	test   %eax,%eax
  801699:	0f 88 2c 01 00 00    	js     8017cb <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80169f:	83 ec 04             	sub    $0x4,%esp
  8016a2:	68 07 04 00 00       	push   $0x407
  8016a7:	ff 75 f4             	pushl  -0xc(%ebp)
  8016aa:	6a 00                	push   $0x0
  8016ac:	e8 2a f4 ff ff       	call   800adb <sys_page_alloc>
  8016b1:	83 c4 10             	add    $0x10,%esp
  8016b4:	89 c2                	mov    %eax,%edx
  8016b6:	85 c0                	test   %eax,%eax
  8016b8:	0f 88 0d 01 00 00    	js     8017cb <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8016be:	83 ec 0c             	sub    $0xc,%esp
  8016c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c4:	50                   	push   %eax
  8016c5:	e8 29 f6 ff ff       	call   800cf3 <fd_alloc>
  8016ca:	89 c3                	mov    %eax,%ebx
  8016cc:	83 c4 10             	add    $0x10,%esp
  8016cf:	85 c0                	test   %eax,%eax
  8016d1:	0f 88 e2 00 00 00    	js     8017b9 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016d7:	83 ec 04             	sub    $0x4,%esp
  8016da:	68 07 04 00 00       	push   $0x407
  8016df:	ff 75 f0             	pushl  -0x10(%ebp)
  8016e2:	6a 00                	push   $0x0
  8016e4:	e8 f2 f3 ff ff       	call   800adb <sys_page_alloc>
  8016e9:	89 c3                	mov    %eax,%ebx
  8016eb:	83 c4 10             	add    $0x10,%esp
  8016ee:	85 c0                	test   %eax,%eax
  8016f0:	0f 88 c3 00 00 00    	js     8017b9 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8016f6:	83 ec 0c             	sub    $0xc,%esp
  8016f9:	ff 75 f4             	pushl  -0xc(%ebp)
  8016fc:	e8 db f5 ff ff       	call   800cdc <fd2data>
  801701:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801703:	83 c4 0c             	add    $0xc,%esp
  801706:	68 07 04 00 00       	push   $0x407
  80170b:	50                   	push   %eax
  80170c:	6a 00                	push   $0x0
  80170e:	e8 c8 f3 ff ff       	call   800adb <sys_page_alloc>
  801713:	89 c3                	mov    %eax,%ebx
  801715:	83 c4 10             	add    $0x10,%esp
  801718:	85 c0                	test   %eax,%eax
  80171a:	0f 88 89 00 00 00    	js     8017a9 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801720:	83 ec 0c             	sub    $0xc,%esp
  801723:	ff 75 f0             	pushl  -0x10(%ebp)
  801726:	e8 b1 f5 ff ff       	call   800cdc <fd2data>
  80172b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801732:	50                   	push   %eax
  801733:	6a 00                	push   $0x0
  801735:	56                   	push   %esi
  801736:	6a 00                	push   $0x0
  801738:	e8 e1 f3 ff ff       	call   800b1e <sys_page_map>
  80173d:	89 c3                	mov    %eax,%ebx
  80173f:	83 c4 20             	add    $0x20,%esp
  801742:	85 c0                	test   %eax,%eax
  801744:	78 55                	js     80179b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801746:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80174c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80174f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801751:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801754:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80175b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801761:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801764:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801766:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801769:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801770:	83 ec 0c             	sub    $0xc,%esp
  801773:	ff 75 f4             	pushl  -0xc(%ebp)
  801776:	e8 51 f5 ff ff       	call   800ccc <fd2num>
  80177b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80177e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801780:	83 c4 04             	add    $0x4,%esp
  801783:	ff 75 f0             	pushl  -0x10(%ebp)
  801786:	e8 41 f5 ff ff       	call   800ccc <fd2num>
  80178b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80178e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801791:	83 c4 10             	add    $0x10,%esp
  801794:	ba 00 00 00 00       	mov    $0x0,%edx
  801799:	eb 30                	jmp    8017cb <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80179b:	83 ec 08             	sub    $0x8,%esp
  80179e:	56                   	push   %esi
  80179f:	6a 00                	push   $0x0
  8017a1:	e8 ba f3 ff ff       	call   800b60 <sys_page_unmap>
  8017a6:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8017a9:	83 ec 08             	sub    $0x8,%esp
  8017ac:	ff 75 f0             	pushl  -0x10(%ebp)
  8017af:	6a 00                	push   $0x0
  8017b1:	e8 aa f3 ff ff       	call   800b60 <sys_page_unmap>
  8017b6:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8017b9:	83 ec 08             	sub    $0x8,%esp
  8017bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8017bf:	6a 00                	push   $0x0
  8017c1:	e8 9a f3 ff ff       	call   800b60 <sys_page_unmap>
  8017c6:	83 c4 10             	add    $0x10,%esp
  8017c9:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8017cb:	89 d0                	mov    %edx,%eax
  8017cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d0:	5b                   	pop    %ebx
  8017d1:	5e                   	pop    %esi
  8017d2:	5d                   	pop    %ebp
  8017d3:	c3                   	ret    

008017d4 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017dd:	50                   	push   %eax
  8017de:	ff 75 08             	pushl  0x8(%ebp)
  8017e1:	e8 5c f5 ff ff       	call   800d42 <fd_lookup>
  8017e6:	83 c4 10             	add    $0x10,%esp
  8017e9:	85 c0                	test   %eax,%eax
  8017eb:	78 18                	js     801805 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8017ed:	83 ec 0c             	sub    $0xc,%esp
  8017f0:	ff 75 f4             	pushl  -0xc(%ebp)
  8017f3:	e8 e4 f4 ff ff       	call   800cdc <fd2data>
	return _pipeisclosed(fd, p);
  8017f8:	89 c2                	mov    %eax,%edx
  8017fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017fd:	e8 21 fd ff ff       	call   801523 <_pipeisclosed>
  801802:	83 c4 10             	add    $0x10,%esp
}
  801805:	c9                   	leave  
  801806:	c3                   	ret    

00801807 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801807:	55                   	push   %ebp
  801808:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80180a:	b8 00 00 00 00       	mov    $0x0,%eax
  80180f:	5d                   	pop    %ebp
  801810:	c3                   	ret    

00801811 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801811:	55                   	push   %ebp
  801812:	89 e5                	mov    %esp,%ebp
  801814:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801817:	68 e8 21 80 00       	push   $0x8021e8
  80181c:	ff 75 0c             	pushl  0xc(%ebp)
  80181f:	e8 b4 ee ff ff       	call   8006d8 <strcpy>
	return 0;
}
  801824:	b8 00 00 00 00       	mov    $0x0,%eax
  801829:	c9                   	leave  
  80182a:	c3                   	ret    

0080182b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80182b:	55                   	push   %ebp
  80182c:	89 e5                	mov    %esp,%ebp
  80182e:	57                   	push   %edi
  80182f:	56                   	push   %esi
  801830:	53                   	push   %ebx
  801831:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801837:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80183c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801842:	eb 2d                	jmp    801871 <devcons_write+0x46>
		m = n - tot;
  801844:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801847:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801849:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80184c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801851:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801854:	83 ec 04             	sub    $0x4,%esp
  801857:	53                   	push   %ebx
  801858:	03 45 0c             	add    0xc(%ebp),%eax
  80185b:	50                   	push   %eax
  80185c:	57                   	push   %edi
  80185d:	e8 08 f0 ff ff       	call   80086a <memmove>
		sys_cputs(buf, m);
  801862:	83 c4 08             	add    $0x8,%esp
  801865:	53                   	push   %ebx
  801866:	57                   	push   %edi
  801867:	e8 b3 f1 ff ff       	call   800a1f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80186c:	01 de                	add    %ebx,%esi
  80186e:	83 c4 10             	add    $0x10,%esp
  801871:	89 f0                	mov    %esi,%eax
  801873:	3b 75 10             	cmp    0x10(%ebp),%esi
  801876:	72 cc                	jb     801844 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801878:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80187b:	5b                   	pop    %ebx
  80187c:	5e                   	pop    %esi
  80187d:	5f                   	pop    %edi
  80187e:	5d                   	pop    %ebp
  80187f:	c3                   	ret    

00801880 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	83 ec 08             	sub    $0x8,%esp
  801886:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80188b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80188f:	74 2a                	je     8018bb <devcons_read+0x3b>
  801891:	eb 05                	jmp    801898 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801893:	e8 24 f2 ff ff       	call   800abc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801898:	e8 a0 f1 ff ff       	call   800a3d <sys_cgetc>
  80189d:	85 c0                	test   %eax,%eax
  80189f:	74 f2                	je     801893 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8018a1:	85 c0                	test   %eax,%eax
  8018a3:	78 16                	js     8018bb <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8018a5:	83 f8 04             	cmp    $0x4,%eax
  8018a8:	74 0c                	je     8018b6 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8018aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ad:	88 02                	mov    %al,(%edx)
	return 1;
  8018af:	b8 01 00 00 00       	mov    $0x1,%eax
  8018b4:	eb 05                	jmp    8018bb <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8018b6:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8018bb:	c9                   	leave  
  8018bc:	c3                   	ret    

008018bd <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8018bd:	55                   	push   %ebp
  8018be:	89 e5                	mov    %esp,%ebp
  8018c0:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8018c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c6:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8018c9:	6a 01                	push   $0x1
  8018cb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8018ce:	50                   	push   %eax
  8018cf:	e8 4b f1 ff ff       	call   800a1f <sys_cputs>
}
  8018d4:	83 c4 10             	add    $0x10,%esp
  8018d7:	c9                   	leave  
  8018d8:	c3                   	ret    

008018d9 <getchar>:

int
getchar(void)
{
  8018d9:	55                   	push   %ebp
  8018da:	89 e5                	mov    %esp,%ebp
  8018dc:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8018df:	6a 01                	push   $0x1
  8018e1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8018e4:	50                   	push   %eax
  8018e5:	6a 00                	push   $0x0
  8018e7:	e8 bc f6 ff ff       	call   800fa8 <read>
	if (r < 0)
  8018ec:	83 c4 10             	add    $0x10,%esp
  8018ef:	85 c0                	test   %eax,%eax
  8018f1:	78 0f                	js     801902 <getchar+0x29>
		return r;
	if (r < 1)
  8018f3:	85 c0                	test   %eax,%eax
  8018f5:	7e 06                	jle    8018fd <getchar+0x24>
		return -E_EOF;
	return c;
  8018f7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8018fb:	eb 05                	jmp    801902 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8018fd:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801902:	c9                   	leave  
  801903:	c3                   	ret    

00801904 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801904:	55                   	push   %ebp
  801905:	89 e5                	mov    %esp,%ebp
  801907:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80190a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80190d:	50                   	push   %eax
  80190e:	ff 75 08             	pushl  0x8(%ebp)
  801911:	e8 2c f4 ff ff       	call   800d42 <fd_lookup>
  801916:	83 c4 10             	add    $0x10,%esp
  801919:	85 c0                	test   %eax,%eax
  80191b:	78 11                	js     80192e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80191d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801920:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801926:	39 10                	cmp    %edx,(%eax)
  801928:	0f 94 c0             	sete   %al
  80192b:	0f b6 c0             	movzbl %al,%eax
}
  80192e:	c9                   	leave  
  80192f:	c3                   	ret    

00801930 <opencons>:

int
opencons(void)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801936:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801939:	50                   	push   %eax
  80193a:	e8 b4 f3 ff ff       	call   800cf3 <fd_alloc>
  80193f:	83 c4 10             	add    $0x10,%esp
		return r;
  801942:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801944:	85 c0                	test   %eax,%eax
  801946:	78 3e                	js     801986 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801948:	83 ec 04             	sub    $0x4,%esp
  80194b:	68 07 04 00 00       	push   $0x407
  801950:	ff 75 f4             	pushl  -0xc(%ebp)
  801953:	6a 00                	push   $0x0
  801955:	e8 81 f1 ff ff       	call   800adb <sys_page_alloc>
  80195a:	83 c4 10             	add    $0x10,%esp
		return r;
  80195d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80195f:	85 c0                	test   %eax,%eax
  801961:	78 23                	js     801986 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801963:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801969:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80196c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80196e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801971:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801978:	83 ec 0c             	sub    $0xc,%esp
  80197b:	50                   	push   %eax
  80197c:	e8 4b f3 ff ff       	call   800ccc <fd2num>
  801981:	89 c2                	mov    %eax,%edx
  801983:	83 c4 10             	add    $0x10,%esp
}
  801986:	89 d0                	mov    %edx,%eax
  801988:	c9                   	leave  
  801989:	c3                   	ret    

0080198a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	56                   	push   %esi
  80198e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80198f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801992:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801998:	e8 00 f1 ff ff       	call   800a9d <sys_getenvid>
  80199d:	83 ec 0c             	sub    $0xc,%esp
  8019a0:	ff 75 0c             	pushl  0xc(%ebp)
  8019a3:	ff 75 08             	pushl  0x8(%ebp)
  8019a6:	56                   	push   %esi
  8019a7:	50                   	push   %eax
  8019a8:	68 f4 21 80 00       	push   $0x8021f4
  8019ad:	e8 a1 e7 ff ff       	call   800153 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019b2:	83 c4 18             	add    $0x18,%esp
  8019b5:	53                   	push   %ebx
  8019b6:	ff 75 10             	pushl  0x10(%ebp)
  8019b9:	e8 44 e7 ff ff       	call   800102 <vcprintf>
	cprintf("\n");
  8019be:	c7 04 24 ac 1d 80 00 	movl   $0x801dac,(%esp)
  8019c5:	e8 89 e7 ff ff       	call   800153 <cprintf>
  8019ca:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8019cd:	cc                   	int3   
  8019ce:	eb fd                	jmp    8019cd <_panic+0x43>

008019d0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	56                   	push   %esi
  8019d4:	53                   	push   %ebx
  8019d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8019d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019db:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8019de:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8019e0:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8019e5:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8019e8:	83 ec 0c             	sub    $0xc,%esp
  8019eb:	50                   	push   %eax
  8019ec:	e8 9a f2 ff ff       	call   800c8b <sys_ipc_recv>

	if (from_env_store != NULL)
  8019f1:	83 c4 10             	add    $0x10,%esp
  8019f4:	85 f6                	test   %esi,%esi
  8019f6:	74 14                	je     801a0c <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8019f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8019fd:	85 c0                	test   %eax,%eax
  8019ff:	78 09                	js     801a0a <ipc_recv+0x3a>
  801a01:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a07:	8b 52 74             	mov    0x74(%edx),%edx
  801a0a:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801a0c:	85 db                	test   %ebx,%ebx
  801a0e:	74 14                	je     801a24 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801a10:	ba 00 00 00 00       	mov    $0x0,%edx
  801a15:	85 c0                	test   %eax,%eax
  801a17:	78 09                	js     801a22 <ipc_recv+0x52>
  801a19:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a1f:	8b 52 78             	mov    0x78(%edx),%edx
  801a22:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801a24:	85 c0                	test   %eax,%eax
  801a26:	78 08                	js     801a30 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801a28:	a1 08 40 80 00       	mov    0x804008,%eax
  801a2d:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a30:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a33:	5b                   	pop    %ebx
  801a34:	5e                   	pop    %esi
  801a35:	5d                   	pop    %ebp
  801a36:	c3                   	ret    

00801a37 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a37:	55                   	push   %ebp
  801a38:	89 e5                	mov    %esp,%ebp
  801a3a:	57                   	push   %edi
  801a3b:	56                   	push   %esi
  801a3c:	53                   	push   %ebx
  801a3d:	83 ec 0c             	sub    $0xc,%esp
  801a40:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a43:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a46:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801a49:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801a4b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a50:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801a53:	ff 75 14             	pushl  0x14(%ebp)
  801a56:	53                   	push   %ebx
  801a57:	56                   	push   %esi
  801a58:	57                   	push   %edi
  801a59:	e8 0a f2 ff ff       	call   800c68 <sys_ipc_try_send>

		if (err < 0) {
  801a5e:	83 c4 10             	add    $0x10,%esp
  801a61:	85 c0                	test   %eax,%eax
  801a63:	79 1e                	jns    801a83 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801a65:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a68:	75 07                	jne    801a71 <ipc_send+0x3a>
				sys_yield();
  801a6a:	e8 4d f0 ff ff       	call   800abc <sys_yield>
  801a6f:	eb e2                	jmp    801a53 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801a71:	50                   	push   %eax
  801a72:	68 18 22 80 00       	push   $0x802218
  801a77:	6a 49                	push   $0x49
  801a79:	68 25 22 80 00       	push   $0x802225
  801a7e:	e8 07 ff ff ff       	call   80198a <_panic>
		}

	} while (err < 0);

}
  801a83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a86:	5b                   	pop    %ebx
  801a87:	5e                   	pop    %esi
  801a88:	5f                   	pop    %edi
  801a89:	5d                   	pop    %ebp
  801a8a:	c3                   	ret    

00801a8b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a8b:	55                   	push   %ebp
  801a8c:	89 e5                	mov    %esp,%ebp
  801a8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801a91:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801a96:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801a99:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801a9f:	8b 52 50             	mov    0x50(%edx),%edx
  801aa2:	39 ca                	cmp    %ecx,%edx
  801aa4:	75 0d                	jne    801ab3 <ipc_find_env+0x28>
			return envs[i].env_id;
  801aa6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801aa9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801aae:	8b 40 48             	mov    0x48(%eax),%eax
  801ab1:	eb 0f                	jmp    801ac2 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ab3:	83 c0 01             	add    $0x1,%eax
  801ab6:	3d 00 04 00 00       	cmp    $0x400,%eax
  801abb:	75 d9                	jne    801a96 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801abd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ac2:	5d                   	pop    %ebp
  801ac3:	c3                   	ret    

00801ac4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ac4:	55                   	push   %ebp
  801ac5:	89 e5                	mov    %esp,%ebp
  801ac7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801aca:	89 d0                	mov    %edx,%eax
  801acc:	c1 e8 16             	shr    $0x16,%eax
  801acf:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ad6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801adb:	f6 c1 01             	test   $0x1,%cl
  801ade:	74 1d                	je     801afd <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ae0:	c1 ea 0c             	shr    $0xc,%edx
  801ae3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801aea:	f6 c2 01             	test   $0x1,%dl
  801aed:	74 0e                	je     801afd <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801aef:	c1 ea 0c             	shr    $0xc,%edx
  801af2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801af9:	ef 
  801afa:	0f b7 c0             	movzwl %ax,%eax
}
  801afd:	5d                   	pop    %ebp
  801afe:	c3                   	ret    
  801aff:	90                   	nop

00801b00 <__udivdi3>:
  801b00:	55                   	push   %ebp
  801b01:	57                   	push   %edi
  801b02:	56                   	push   %esi
  801b03:	53                   	push   %ebx
  801b04:	83 ec 1c             	sub    $0x1c,%esp
  801b07:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b0b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b0f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b17:	85 f6                	test   %esi,%esi
  801b19:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b1d:	89 ca                	mov    %ecx,%edx
  801b1f:	89 f8                	mov    %edi,%eax
  801b21:	75 3d                	jne    801b60 <__udivdi3+0x60>
  801b23:	39 cf                	cmp    %ecx,%edi
  801b25:	0f 87 c5 00 00 00    	ja     801bf0 <__udivdi3+0xf0>
  801b2b:	85 ff                	test   %edi,%edi
  801b2d:	89 fd                	mov    %edi,%ebp
  801b2f:	75 0b                	jne    801b3c <__udivdi3+0x3c>
  801b31:	b8 01 00 00 00       	mov    $0x1,%eax
  801b36:	31 d2                	xor    %edx,%edx
  801b38:	f7 f7                	div    %edi
  801b3a:	89 c5                	mov    %eax,%ebp
  801b3c:	89 c8                	mov    %ecx,%eax
  801b3e:	31 d2                	xor    %edx,%edx
  801b40:	f7 f5                	div    %ebp
  801b42:	89 c1                	mov    %eax,%ecx
  801b44:	89 d8                	mov    %ebx,%eax
  801b46:	89 cf                	mov    %ecx,%edi
  801b48:	f7 f5                	div    %ebp
  801b4a:	89 c3                	mov    %eax,%ebx
  801b4c:	89 d8                	mov    %ebx,%eax
  801b4e:	89 fa                	mov    %edi,%edx
  801b50:	83 c4 1c             	add    $0x1c,%esp
  801b53:	5b                   	pop    %ebx
  801b54:	5e                   	pop    %esi
  801b55:	5f                   	pop    %edi
  801b56:	5d                   	pop    %ebp
  801b57:	c3                   	ret    
  801b58:	90                   	nop
  801b59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b60:	39 ce                	cmp    %ecx,%esi
  801b62:	77 74                	ja     801bd8 <__udivdi3+0xd8>
  801b64:	0f bd fe             	bsr    %esi,%edi
  801b67:	83 f7 1f             	xor    $0x1f,%edi
  801b6a:	0f 84 98 00 00 00    	je     801c08 <__udivdi3+0x108>
  801b70:	bb 20 00 00 00       	mov    $0x20,%ebx
  801b75:	89 f9                	mov    %edi,%ecx
  801b77:	89 c5                	mov    %eax,%ebp
  801b79:	29 fb                	sub    %edi,%ebx
  801b7b:	d3 e6                	shl    %cl,%esi
  801b7d:	89 d9                	mov    %ebx,%ecx
  801b7f:	d3 ed                	shr    %cl,%ebp
  801b81:	89 f9                	mov    %edi,%ecx
  801b83:	d3 e0                	shl    %cl,%eax
  801b85:	09 ee                	or     %ebp,%esi
  801b87:	89 d9                	mov    %ebx,%ecx
  801b89:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b8d:	89 d5                	mov    %edx,%ebp
  801b8f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801b93:	d3 ed                	shr    %cl,%ebp
  801b95:	89 f9                	mov    %edi,%ecx
  801b97:	d3 e2                	shl    %cl,%edx
  801b99:	89 d9                	mov    %ebx,%ecx
  801b9b:	d3 e8                	shr    %cl,%eax
  801b9d:	09 c2                	or     %eax,%edx
  801b9f:	89 d0                	mov    %edx,%eax
  801ba1:	89 ea                	mov    %ebp,%edx
  801ba3:	f7 f6                	div    %esi
  801ba5:	89 d5                	mov    %edx,%ebp
  801ba7:	89 c3                	mov    %eax,%ebx
  801ba9:	f7 64 24 0c          	mull   0xc(%esp)
  801bad:	39 d5                	cmp    %edx,%ebp
  801baf:	72 10                	jb     801bc1 <__udivdi3+0xc1>
  801bb1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801bb5:	89 f9                	mov    %edi,%ecx
  801bb7:	d3 e6                	shl    %cl,%esi
  801bb9:	39 c6                	cmp    %eax,%esi
  801bbb:	73 07                	jae    801bc4 <__udivdi3+0xc4>
  801bbd:	39 d5                	cmp    %edx,%ebp
  801bbf:	75 03                	jne    801bc4 <__udivdi3+0xc4>
  801bc1:	83 eb 01             	sub    $0x1,%ebx
  801bc4:	31 ff                	xor    %edi,%edi
  801bc6:	89 d8                	mov    %ebx,%eax
  801bc8:	89 fa                	mov    %edi,%edx
  801bca:	83 c4 1c             	add    $0x1c,%esp
  801bcd:	5b                   	pop    %ebx
  801bce:	5e                   	pop    %esi
  801bcf:	5f                   	pop    %edi
  801bd0:	5d                   	pop    %ebp
  801bd1:	c3                   	ret    
  801bd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801bd8:	31 ff                	xor    %edi,%edi
  801bda:	31 db                	xor    %ebx,%ebx
  801bdc:	89 d8                	mov    %ebx,%eax
  801bde:	89 fa                	mov    %edi,%edx
  801be0:	83 c4 1c             	add    $0x1c,%esp
  801be3:	5b                   	pop    %ebx
  801be4:	5e                   	pop    %esi
  801be5:	5f                   	pop    %edi
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    
  801be8:	90                   	nop
  801be9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bf0:	89 d8                	mov    %ebx,%eax
  801bf2:	f7 f7                	div    %edi
  801bf4:	31 ff                	xor    %edi,%edi
  801bf6:	89 c3                	mov    %eax,%ebx
  801bf8:	89 d8                	mov    %ebx,%eax
  801bfa:	89 fa                	mov    %edi,%edx
  801bfc:	83 c4 1c             	add    $0x1c,%esp
  801bff:	5b                   	pop    %ebx
  801c00:	5e                   	pop    %esi
  801c01:	5f                   	pop    %edi
  801c02:	5d                   	pop    %ebp
  801c03:	c3                   	ret    
  801c04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c08:	39 ce                	cmp    %ecx,%esi
  801c0a:	72 0c                	jb     801c18 <__udivdi3+0x118>
  801c0c:	31 db                	xor    %ebx,%ebx
  801c0e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c12:	0f 87 34 ff ff ff    	ja     801b4c <__udivdi3+0x4c>
  801c18:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c1d:	e9 2a ff ff ff       	jmp    801b4c <__udivdi3+0x4c>
  801c22:	66 90                	xchg   %ax,%ax
  801c24:	66 90                	xchg   %ax,%ax
  801c26:	66 90                	xchg   %ax,%ax
  801c28:	66 90                	xchg   %ax,%ax
  801c2a:	66 90                	xchg   %ax,%ax
  801c2c:	66 90                	xchg   %ax,%ax
  801c2e:	66 90                	xchg   %ax,%ax

00801c30 <__umoddi3>:
  801c30:	55                   	push   %ebp
  801c31:	57                   	push   %edi
  801c32:	56                   	push   %esi
  801c33:	53                   	push   %ebx
  801c34:	83 ec 1c             	sub    $0x1c,%esp
  801c37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c3b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c3f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c47:	85 d2                	test   %edx,%edx
  801c49:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801c4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c51:	89 f3                	mov    %esi,%ebx
  801c53:	89 3c 24             	mov    %edi,(%esp)
  801c56:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c5a:	75 1c                	jne    801c78 <__umoddi3+0x48>
  801c5c:	39 f7                	cmp    %esi,%edi
  801c5e:	76 50                	jbe    801cb0 <__umoddi3+0x80>
  801c60:	89 c8                	mov    %ecx,%eax
  801c62:	89 f2                	mov    %esi,%edx
  801c64:	f7 f7                	div    %edi
  801c66:	89 d0                	mov    %edx,%eax
  801c68:	31 d2                	xor    %edx,%edx
  801c6a:	83 c4 1c             	add    $0x1c,%esp
  801c6d:	5b                   	pop    %ebx
  801c6e:	5e                   	pop    %esi
  801c6f:	5f                   	pop    %edi
  801c70:	5d                   	pop    %ebp
  801c71:	c3                   	ret    
  801c72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c78:	39 f2                	cmp    %esi,%edx
  801c7a:	89 d0                	mov    %edx,%eax
  801c7c:	77 52                	ja     801cd0 <__umoddi3+0xa0>
  801c7e:	0f bd ea             	bsr    %edx,%ebp
  801c81:	83 f5 1f             	xor    $0x1f,%ebp
  801c84:	75 5a                	jne    801ce0 <__umoddi3+0xb0>
  801c86:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801c8a:	0f 82 e0 00 00 00    	jb     801d70 <__umoddi3+0x140>
  801c90:	39 0c 24             	cmp    %ecx,(%esp)
  801c93:	0f 86 d7 00 00 00    	jbe    801d70 <__umoddi3+0x140>
  801c99:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c9d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ca1:	83 c4 1c             	add    $0x1c,%esp
  801ca4:	5b                   	pop    %ebx
  801ca5:	5e                   	pop    %esi
  801ca6:	5f                   	pop    %edi
  801ca7:	5d                   	pop    %ebp
  801ca8:	c3                   	ret    
  801ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cb0:	85 ff                	test   %edi,%edi
  801cb2:	89 fd                	mov    %edi,%ebp
  801cb4:	75 0b                	jne    801cc1 <__umoddi3+0x91>
  801cb6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cbb:	31 d2                	xor    %edx,%edx
  801cbd:	f7 f7                	div    %edi
  801cbf:	89 c5                	mov    %eax,%ebp
  801cc1:	89 f0                	mov    %esi,%eax
  801cc3:	31 d2                	xor    %edx,%edx
  801cc5:	f7 f5                	div    %ebp
  801cc7:	89 c8                	mov    %ecx,%eax
  801cc9:	f7 f5                	div    %ebp
  801ccb:	89 d0                	mov    %edx,%eax
  801ccd:	eb 99                	jmp    801c68 <__umoddi3+0x38>
  801ccf:	90                   	nop
  801cd0:	89 c8                	mov    %ecx,%eax
  801cd2:	89 f2                	mov    %esi,%edx
  801cd4:	83 c4 1c             	add    $0x1c,%esp
  801cd7:	5b                   	pop    %ebx
  801cd8:	5e                   	pop    %esi
  801cd9:	5f                   	pop    %edi
  801cda:	5d                   	pop    %ebp
  801cdb:	c3                   	ret    
  801cdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ce0:	8b 34 24             	mov    (%esp),%esi
  801ce3:	bf 20 00 00 00       	mov    $0x20,%edi
  801ce8:	89 e9                	mov    %ebp,%ecx
  801cea:	29 ef                	sub    %ebp,%edi
  801cec:	d3 e0                	shl    %cl,%eax
  801cee:	89 f9                	mov    %edi,%ecx
  801cf0:	89 f2                	mov    %esi,%edx
  801cf2:	d3 ea                	shr    %cl,%edx
  801cf4:	89 e9                	mov    %ebp,%ecx
  801cf6:	09 c2                	or     %eax,%edx
  801cf8:	89 d8                	mov    %ebx,%eax
  801cfa:	89 14 24             	mov    %edx,(%esp)
  801cfd:	89 f2                	mov    %esi,%edx
  801cff:	d3 e2                	shl    %cl,%edx
  801d01:	89 f9                	mov    %edi,%ecx
  801d03:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d07:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d0b:	d3 e8                	shr    %cl,%eax
  801d0d:	89 e9                	mov    %ebp,%ecx
  801d0f:	89 c6                	mov    %eax,%esi
  801d11:	d3 e3                	shl    %cl,%ebx
  801d13:	89 f9                	mov    %edi,%ecx
  801d15:	89 d0                	mov    %edx,%eax
  801d17:	d3 e8                	shr    %cl,%eax
  801d19:	89 e9                	mov    %ebp,%ecx
  801d1b:	09 d8                	or     %ebx,%eax
  801d1d:	89 d3                	mov    %edx,%ebx
  801d1f:	89 f2                	mov    %esi,%edx
  801d21:	f7 34 24             	divl   (%esp)
  801d24:	89 d6                	mov    %edx,%esi
  801d26:	d3 e3                	shl    %cl,%ebx
  801d28:	f7 64 24 04          	mull   0x4(%esp)
  801d2c:	39 d6                	cmp    %edx,%esi
  801d2e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d32:	89 d1                	mov    %edx,%ecx
  801d34:	89 c3                	mov    %eax,%ebx
  801d36:	72 08                	jb     801d40 <__umoddi3+0x110>
  801d38:	75 11                	jne    801d4b <__umoddi3+0x11b>
  801d3a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d3e:	73 0b                	jae    801d4b <__umoddi3+0x11b>
  801d40:	2b 44 24 04          	sub    0x4(%esp),%eax
  801d44:	1b 14 24             	sbb    (%esp),%edx
  801d47:	89 d1                	mov    %edx,%ecx
  801d49:	89 c3                	mov    %eax,%ebx
  801d4b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d4f:	29 da                	sub    %ebx,%edx
  801d51:	19 ce                	sbb    %ecx,%esi
  801d53:	89 f9                	mov    %edi,%ecx
  801d55:	89 f0                	mov    %esi,%eax
  801d57:	d3 e0                	shl    %cl,%eax
  801d59:	89 e9                	mov    %ebp,%ecx
  801d5b:	d3 ea                	shr    %cl,%edx
  801d5d:	89 e9                	mov    %ebp,%ecx
  801d5f:	d3 ee                	shr    %cl,%esi
  801d61:	09 d0                	or     %edx,%eax
  801d63:	89 f2                	mov    %esi,%edx
  801d65:	83 c4 1c             	add    $0x1c,%esp
  801d68:	5b                   	pop    %ebx
  801d69:	5e                   	pop    %esi
  801d6a:	5f                   	pop    %edi
  801d6b:	5d                   	pop    %ebp
  801d6c:	c3                   	ret    
  801d6d:	8d 76 00             	lea    0x0(%esi),%esi
  801d70:	29 f9                	sub    %edi,%ecx
  801d72:	19 d6                	sbb    %edx,%esi
  801d74:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d78:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d7c:	e9 18 ff ff ff       	jmp    801c99 <__umoddi3+0x69>
