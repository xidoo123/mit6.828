
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
  800039:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 80 22 80 00       	push   $0x802280
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
  80007d:	a3 0c 40 80 00       	mov    %eax,0x80400c

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
  8000ac:	e8 47 0e 00 00       	call   800ef8 <close_all>
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
  8001b6:	e8 35 1e 00 00       	call   801ff0 <__udivdi3>
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
  8001f9:	e8 22 1f 00 00       	call   802120 <__umoddi3>
  8001fe:	83 c4 14             	add    $0x14,%esp
  800201:	0f be 80 98 22 80 00 	movsbl 0x802298(%eax),%eax
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
  8002fd:	ff 24 85 e0 23 80 00 	jmp    *0x8023e0(,%eax,4)
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
  8003c1:	8b 14 85 40 25 80 00 	mov    0x802540(,%eax,4),%edx
  8003c8:	85 d2                	test   %edx,%edx
  8003ca:	75 18                	jne    8003e4 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003cc:	50                   	push   %eax
  8003cd:	68 b0 22 80 00       	push   $0x8022b0
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
  8003e5:	68 75 26 80 00       	push   $0x802675
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
  800409:	b8 a9 22 80 00       	mov    $0x8022a9,%eax
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
  800a84:	68 9f 25 80 00       	push   $0x80259f
  800a89:	6a 23                	push   $0x23
  800a8b:	68 bc 25 80 00       	push   $0x8025bc
  800a90:	e8 dc 13 00 00       	call   801e71 <_panic>

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
  800b05:	68 9f 25 80 00       	push   $0x80259f
  800b0a:	6a 23                	push   $0x23
  800b0c:	68 bc 25 80 00       	push   $0x8025bc
  800b11:	e8 5b 13 00 00       	call   801e71 <_panic>

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
  800b47:	68 9f 25 80 00       	push   $0x80259f
  800b4c:	6a 23                	push   $0x23
  800b4e:	68 bc 25 80 00       	push   $0x8025bc
  800b53:	e8 19 13 00 00       	call   801e71 <_panic>

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
  800b89:	68 9f 25 80 00       	push   $0x80259f
  800b8e:	6a 23                	push   $0x23
  800b90:	68 bc 25 80 00       	push   $0x8025bc
  800b95:	e8 d7 12 00 00       	call   801e71 <_panic>

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
  800bcb:	68 9f 25 80 00       	push   $0x80259f
  800bd0:	6a 23                	push   $0x23
  800bd2:	68 bc 25 80 00       	push   $0x8025bc
  800bd7:	e8 95 12 00 00       	call   801e71 <_panic>

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
  800c0d:	68 9f 25 80 00       	push   $0x80259f
  800c12:	6a 23                	push   $0x23
  800c14:	68 bc 25 80 00       	push   $0x8025bc
  800c19:	e8 53 12 00 00       	call   801e71 <_panic>

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
  800c4f:	68 9f 25 80 00       	push   $0x80259f
  800c54:	6a 23                	push   $0x23
  800c56:	68 bc 25 80 00       	push   $0x8025bc
  800c5b:	e8 11 12 00 00       	call   801e71 <_panic>

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
  800cb3:	68 9f 25 80 00       	push   $0x80259f
  800cb8:	6a 23                	push   $0x23
  800cba:	68 bc 25 80 00       	push   $0x8025bc
  800cbf:	e8 ad 11 00 00       	call   801e71 <_panic>

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

00800ccc <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd7:	b8 0e 00 00 00       	mov    $0xe,%eax
  800cdc:	89 d1                	mov    %edx,%ecx
  800cde:	89 d3                	mov    %edx,%ebx
  800ce0:	89 d7                	mov    %edx,%edi
  800ce2:	89 d6                	mov    %edx,%esi
  800ce4:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ce6:	5b                   	pop    %ebx
  800ce7:	5e                   	pop    %esi
  800ce8:	5f                   	pop    %edi
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    

00800ceb <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	57                   	push   %edi
  800cef:	56                   	push   %esi
  800cf0:	53                   	push   %ebx
  800cf1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf9:	b8 0f 00 00 00       	mov    $0xf,%eax
  800cfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d01:	8b 55 08             	mov    0x8(%ebp),%edx
  800d04:	89 df                	mov    %ebx,%edi
  800d06:	89 de                	mov    %ebx,%esi
  800d08:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0a:	85 c0                	test   %eax,%eax
  800d0c:	7e 17                	jle    800d25 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0e:	83 ec 0c             	sub    $0xc,%esp
  800d11:	50                   	push   %eax
  800d12:	6a 0f                	push   $0xf
  800d14:	68 9f 25 80 00       	push   $0x80259f
  800d19:	6a 23                	push   $0x23
  800d1b:	68 bc 25 80 00       	push   $0x8025bc
  800d20:	e8 4c 11 00 00       	call   801e71 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800d25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5f                   	pop    %edi
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    

00800d2d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d30:	8b 45 08             	mov    0x8(%ebp),%eax
  800d33:	05 00 00 00 30       	add    $0x30000000,%eax
  800d38:	c1 e8 0c             	shr    $0xc,%eax
}
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d40:	8b 45 08             	mov    0x8(%ebp),%eax
  800d43:	05 00 00 00 30       	add    $0x30000000,%eax
  800d48:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d4d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d5a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d5f:	89 c2                	mov    %eax,%edx
  800d61:	c1 ea 16             	shr    $0x16,%edx
  800d64:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d6b:	f6 c2 01             	test   $0x1,%dl
  800d6e:	74 11                	je     800d81 <fd_alloc+0x2d>
  800d70:	89 c2                	mov    %eax,%edx
  800d72:	c1 ea 0c             	shr    $0xc,%edx
  800d75:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d7c:	f6 c2 01             	test   $0x1,%dl
  800d7f:	75 09                	jne    800d8a <fd_alloc+0x36>
			*fd_store = fd;
  800d81:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d83:	b8 00 00 00 00       	mov    $0x0,%eax
  800d88:	eb 17                	jmp    800da1 <fd_alloc+0x4d>
  800d8a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d8f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d94:	75 c9                	jne    800d5f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d96:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d9c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    

00800da3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800da9:	83 f8 1f             	cmp    $0x1f,%eax
  800dac:	77 36                	ja     800de4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dae:	c1 e0 0c             	shl    $0xc,%eax
  800db1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800db6:	89 c2                	mov    %eax,%edx
  800db8:	c1 ea 16             	shr    $0x16,%edx
  800dbb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dc2:	f6 c2 01             	test   $0x1,%dl
  800dc5:	74 24                	je     800deb <fd_lookup+0x48>
  800dc7:	89 c2                	mov    %eax,%edx
  800dc9:	c1 ea 0c             	shr    $0xc,%edx
  800dcc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dd3:	f6 c2 01             	test   $0x1,%dl
  800dd6:	74 1a                	je     800df2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dd8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ddb:	89 02                	mov    %eax,(%edx)
	return 0;
  800ddd:	b8 00 00 00 00       	mov    $0x0,%eax
  800de2:	eb 13                	jmp    800df7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800de4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800de9:	eb 0c                	jmp    800df7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800deb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800df0:	eb 05                	jmp    800df7 <fd_lookup+0x54>
  800df2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800df7:	5d                   	pop    %ebp
  800df8:	c3                   	ret    

00800df9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
  800dfc:	83 ec 08             	sub    $0x8,%esp
  800dff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e02:	ba 48 26 80 00       	mov    $0x802648,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e07:	eb 13                	jmp    800e1c <dev_lookup+0x23>
  800e09:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e0c:	39 08                	cmp    %ecx,(%eax)
  800e0e:	75 0c                	jne    800e1c <dev_lookup+0x23>
			*dev = devtab[i];
  800e10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e13:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e15:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1a:	eb 2e                	jmp    800e4a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e1c:	8b 02                	mov    (%edx),%eax
  800e1e:	85 c0                	test   %eax,%eax
  800e20:	75 e7                	jne    800e09 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e22:	a1 0c 40 80 00       	mov    0x80400c,%eax
  800e27:	8b 40 48             	mov    0x48(%eax),%eax
  800e2a:	83 ec 04             	sub    $0x4,%esp
  800e2d:	51                   	push   %ecx
  800e2e:	50                   	push   %eax
  800e2f:	68 cc 25 80 00       	push   $0x8025cc
  800e34:	e8 1a f3 ff ff       	call   800153 <cprintf>
	*dev = 0;
  800e39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e3c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e42:	83 c4 10             	add    $0x10,%esp
  800e45:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e4a:	c9                   	leave  
  800e4b:	c3                   	ret    

00800e4c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	56                   	push   %esi
  800e50:	53                   	push   %ebx
  800e51:	83 ec 10             	sub    $0x10,%esp
  800e54:	8b 75 08             	mov    0x8(%ebp),%esi
  800e57:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e5d:	50                   	push   %eax
  800e5e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e64:	c1 e8 0c             	shr    $0xc,%eax
  800e67:	50                   	push   %eax
  800e68:	e8 36 ff ff ff       	call   800da3 <fd_lookup>
  800e6d:	83 c4 08             	add    $0x8,%esp
  800e70:	85 c0                	test   %eax,%eax
  800e72:	78 05                	js     800e79 <fd_close+0x2d>
	    || fd != fd2)
  800e74:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e77:	74 0c                	je     800e85 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e79:	84 db                	test   %bl,%bl
  800e7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e80:	0f 44 c2             	cmove  %edx,%eax
  800e83:	eb 41                	jmp    800ec6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e85:	83 ec 08             	sub    $0x8,%esp
  800e88:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e8b:	50                   	push   %eax
  800e8c:	ff 36                	pushl  (%esi)
  800e8e:	e8 66 ff ff ff       	call   800df9 <dev_lookup>
  800e93:	89 c3                	mov    %eax,%ebx
  800e95:	83 c4 10             	add    $0x10,%esp
  800e98:	85 c0                	test   %eax,%eax
  800e9a:	78 1a                	js     800eb6 <fd_close+0x6a>
		if (dev->dev_close)
  800e9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e9f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ea2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ea7:	85 c0                	test   %eax,%eax
  800ea9:	74 0b                	je     800eb6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800eab:	83 ec 0c             	sub    $0xc,%esp
  800eae:	56                   	push   %esi
  800eaf:	ff d0                	call   *%eax
  800eb1:	89 c3                	mov    %eax,%ebx
  800eb3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800eb6:	83 ec 08             	sub    $0x8,%esp
  800eb9:	56                   	push   %esi
  800eba:	6a 00                	push   $0x0
  800ebc:	e8 9f fc ff ff       	call   800b60 <sys_page_unmap>
	return r;
  800ec1:	83 c4 10             	add    $0x10,%esp
  800ec4:	89 d8                	mov    %ebx,%eax
}
  800ec6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ec9:	5b                   	pop    %ebx
  800eca:	5e                   	pop    %esi
  800ecb:	5d                   	pop    %ebp
  800ecc:	c3                   	ret    

00800ecd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ecd:	55                   	push   %ebp
  800ece:	89 e5                	mov    %esp,%ebp
  800ed0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ed3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ed6:	50                   	push   %eax
  800ed7:	ff 75 08             	pushl  0x8(%ebp)
  800eda:	e8 c4 fe ff ff       	call   800da3 <fd_lookup>
  800edf:	83 c4 08             	add    $0x8,%esp
  800ee2:	85 c0                	test   %eax,%eax
  800ee4:	78 10                	js     800ef6 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ee6:	83 ec 08             	sub    $0x8,%esp
  800ee9:	6a 01                	push   $0x1
  800eeb:	ff 75 f4             	pushl  -0xc(%ebp)
  800eee:	e8 59 ff ff ff       	call   800e4c <fd_close>
  800ef3:	83 c4 10             	add    $0x10,%esp
}
  800ef6:	c9                   	leave  
  800ef7:	c3                   	ret    

00800ef8 <close_all>:

void
close_all(void)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	53                   	push   %ebx
  800efc:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800eff:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f04:	83 ec 0c             	sub    $0xc,%esp
  800f07:	53                   	push   %ebx
  800f08:	e8 c0 ff ff ff       	call   800ecd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f0d:	83 c3 01             	add    $0x1,%ebx
  800f10:	83 c4 10             	add    $0x10,%esp
  800f13:	83 fb 20             	cmp    $0x20,%ebx
  800f16:	75 ec                	jne    800f04 <close_all+0xc>
		close(i);
}
  800f18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f1b:	c9                   	leave  
  800f1c:	c3                   	ret    

00800f1d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f1d:	55                   	push   %ebp
  800f1e:	89 e5                	mov    %esp,%ebp
  800f20:	57                   	push   %edi
  800f21:	56                   	push   %esi
  800f22:	53                   	push   %ebx
  800f23:	83 ec 2c             	sub    $0x2c,%esp
  800f26:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f29:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f2c:	50                   	push   %eax
  800f2d:	ff 75 08             	pushl  0x8(%ebp)
  800f30:	e8 6e fe ff ff       	call   800da3 <fd_lookup>
  800f35:	83 c4 08             	add    $0x8,%esp
  800f38:	85 c0                	test   %eax,%eax
  800f3a:	0f 88 c1 00 00 00    	js     801001 <dup+0xe4>
		return r;
	close(newfdnum);
  800f40:	83 ec 0c             	sub    $0xc,%esp
  800f43:	56                   	push   %esi
  800f44:	e8 84 ff ff ff       	call   800ecd <close>

	newfd = INDEX2FD(newfdnum);
  800f49:	89 f3                	mov    %esi,%ebx
  800f4b:	c1 e3 0c             	shl    $0xc,%ebx
  800f4e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f54:	83 c4 04             	add    $0x4,%esp
  800f57:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f5a:	e8 de fd ff ff       	call   800d3d <fd2data>
  800f5f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f61:	89 1c 24             	mov    %ebx,(%esp)
  800f64:	e8 d4 fd ff ff       	call   800d3d <fd2data>
  800f69:	83 c4 10             	add    $0x10,%esp
  800f6c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f6f:	89 f8                	mov    %edi,%eax
  800f71:	c1 e8 16             	shr    $0x16,%eax
  800f74:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f7b:	a8 01                	test   $0x1,%al
  800f7d:	74 37                	je     800fb6 <dup+0x99>
  800f7f:	89 f8                	mov    %edi,%eax
  800f81:	c1 e8 0c             	shr    $0xc,%eax
  800f84:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f8b:	f6 c2 01             	test   $0x1,%dl
  800f8e:	74 26                	je     800fb6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f90:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f97:	83 ec 0c             	sub    $0xc,%esp
  800f9a:	25 07 0e 00 00       	and    $0xe07,%eax
  800f9f:	50                   	push   %eax
  800fa0:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fa3:	6a 00                	push   $0x0
  800fa5:	57                   	push   %edi
  800fa6:	6a 00                	push   $0x0
  800fa8:	e8 71 fb ff ff       	call   800b1e <sys_page_map>
  800fad:	89 c7                	mov    %eax,%edi
  800faf:	83 c4 20             	add    $0x20,%esp
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	78 2e                	js     800fe4 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fb6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fb9:	89 d0                	mov    %edx,%eax
  800fbb:	c1 e8 0c             	shr    $0xc,%eax
  800fbe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fc5:	83 ec 0c             	sub    $0xc,%esp
  800fc8:	25 07 0e 00 00       	and    $0xe07,%eax
  800fcd:	50                   	push   %eax
  800fce:	53                   	push   %ebx
  800fcf:	6a 00                	push   $0x0
  800fd1:	52                   	push   %edx
  800fd2:	6a 00                	push   $0x0
  800fd4:	e8 45 fb ff ff       	call   800b1e <sys_page_map>
  800fd9:	89 c7                	mov    %eax,%edi
  800fdb:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fde:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fe0:	85 ff                	test   %edi,%edi
  800fe2:	79 1d                	jns    801001 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fe4:	83 ec 08             	sub    $0x8,%esp
  800fe7:	53                   	push   %ebx
  800fe8:	6a 00                	push   $0x0
  800fea:	e8 71 fb ff ff       	call   800b60 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fef:	83 c4 08             	add    $0x8,%esp
  800ff2:	ff 75 d4             	pushl  -0x2c(%ebp)
  800ff5:	6a 00                	push   $0x0
  800ff7:	e8 64 fb ff ff       	call   800b60 <sys_page_unmap>
	return r;
  800ffc:	83 c4 10             	add    $0x10,%esp
  800fff:	89 f8                	mov    %edi,%eax
}
  801001:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801004:	5b                   	pop    %ebx
  801005:	5e                   	pop    %esi
  801006:	5f                   	pop    %edi
  801007:	5d                   	pop    %ebp
  801008:	c3                   	ret    

00801009 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801009:	55                   	push   %ebp
  80100a:	89 e5                	mov    %esp,%ebp
  80100c:	53                   	push   %ebx
  80100d:	83 ec 14             	sub    $0x14,%esp
  801010:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801013:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801016:	50                   	push   %eax
  801017:	53                   	push   %ebx
  801018:	e8 86 fd ff ff       	call   800da3 <fd_lookup>
  80101d:	83 c4 08             	add    $0x8,%esp
  801020:	89 c2                	mov    %eax,%edx
  801022:	85 c0                	test   %eax,%eax
  801024:	78 6d                	js     801093 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801026:	83 ec 08             	sub    $0x8,%esp
  801029:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80102c:	50                   	push   %eax
  80102d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801030:	ff 30                	pushl  (%eax)
  801032:	e8 c2 fd ff ff       	call   800df9 <dev_lookup>
  801037:	83 c4 10             	add    $0x10,%esp
  80103a:	85 c0                	test   %eax,%eax
  80103c:	78 4c                	js     80108a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80103e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801041:	8b 42 08             	mov    0x8(%edx),%eax
  801044:	83 e0 03             	and    $0x3,%eax
  801047:	83 f8 01             	cmp    $0x1,%eax
  80104a:	75 21                	jne    80106d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80104c:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801051:	8b 40 48             	mov    0x48(%eax),%eax
  801054:	83 ec 04             	sub    $0x4,%esp
  801057:	53                   	push   %ebx
  801058:	50                   	push   %eax
  801059:	68 0d 26 80 00       	push   $0x80260d
  80105e:	e8 f0 f0 ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  801063:	83 c4 10             	add    $0x10,%esp
  801066:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80106b:	eb 26                	jmp    801093 <read+0x8a>
	}
	if (!dev->dev_read)
  80106d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801070:	8b 40 08             	mov    0x8(%eax),%eax
  801073:	85 c0                	test   %eax,%eax
  801075:	74 17                	je     80108e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801077:	83 ec 04             	sub    $0x4,%esp
  80107a:	ff 75 10             	pushl  0x10(%ebp)
  80107d:	ff 75 0c             	pushl  0xc(%ebp)
  801080:	52                   	push   %edx
  801081:	ff d0                	call   *%eax
  801083:	89 c2                	mov    %eax,%edx
  801085:	83 c4 10             	add    $0x10,%esp
  801088:	eb 09                	jmp    801093 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80108a:	89 c2                	mov    %eax,%edx
  80108c:	eb 05                	jmp    801093 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80108e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801093:	89 d0                	mov    %edx,%eax
  801095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801098:	c9                   	leave  
  801099:	c3                   	ret    

0080109a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80109a:	55                   	push   %ebp
  80109b:	89 e5                	mov    %esp,%ebp
  80109d:	57                   	push   %edi
  80109e:	56                   	push   %esi
  80109f:	53                   	push   %ebx
  8010a0:	83 ec 0c             	sub    $0xc,%esp
  8010a3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010a6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ae:	eb 21                	jmp    8010d1 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010b0:	83 ec 04             	sub    $0x4,%esp
  8010b3:	89 f0                	mov    %esi,%eax
  8010b5:	29 d8                	sub    %ebx,%eax
  8010b7:	50                   	push   %eax
  8010b8:	89 d8                	mov    %ebx,%eax
  8010ba:	03 45 0c             	add    0xc(%ebp),%eax
  8010bd:	50                   	push   %eax
  8010be:	57                   	push   %edi
  8010bf:	e8 45 ff ff ff       	call   801009 <read>
		if (m < 0)
  8010c4:	83 c4 10             	add    $0x10,%esp
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	78 10                	js     8010db <readn+0x41>
			return m;
		if (m == 0)
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	74 0a                	je     8010d9 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010cf:	01 c3                	add    %eax,%ebx
  8010d1:	39 f3                	cmp    %esi,%ebx
  8010d3:	72 db                	jb     8010b0 <readn+0x16>
  8010d5:	89 d8                	mov    %ebx,%eax
  8010d7:	eb 02                	jmp    8010db <readn+0x41>
  8010d9:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010de:	5b                   	pop    %ebx
  8010df:	5e                   	pop    %esi
  8010e0:	5f                   	pop    %edi
  8010e1:	5d                   	pop    %ebp
  8010e2:	c3                   	ret    

008010e3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	53                   	push   %ebx
  8010e7:	83 ec 14             	sub    $0x14,%esp
  8010ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010f0:	50                   	push   %eax
  8010f1:	53                   	push   %ebx
  8010f2:	e8 ac fc ff ff       	call   800da3 <fd_lookup>
  8010f7:	83 c4 08             	add    $0x8,%esp
  8010fa:	89 c2                	mov    %eax,%edx
  8010fc:	85 c0                	test   %eax,%eax
  8010fe:	78 68                	js     801168 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801100:	83 ec 08             	sub    $0x8,%esp
  801103:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801106:	50                   	push   %eax
  801107:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80110a:	ff 30                	pushl  (%eax)
  80110c:	e8 e8 fc ff ff       	call   800df9 <dev_lookup>
  801111:	83 c4 10             	add    $0x10,%esp
  801114:	85 c0                	test   %eax,%eax
  801116:	78 47                	js     80115f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801118:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80111b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80111f:	75 21                	jne    801142 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801121:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801126:	8b 40 48             	mov    0x48(%eax),%eax
  801129:	83 ec 04             	sub    $0x4,%esp
  80112c:	53                   	push   %ebx
  80112d:	50                   	push   %eax
  80112e:	68 29 26 80 00       	push   $0x802629
  801133:	e8 1b f0 ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  801138:	83 c4 10             	add    $0x10,%esp
  80113b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801140:	eb 26                	jmp    801168 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801142:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801145:	8b 52 0c             	mov    0xc(%edx),%edx
  801148:	85 d2                	test   %edx,%edx
  80114a:	74 17                	je     801163 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80114c:	83 ec 04             	sub    $0x4,%esp
  80114f:	ff 75 10             	pushl  0x10(%ebp)
  801152:	ff 75 0c             	pushl  0xc(%ebp)
  801155:	50                   	push   %eax
  801156:	ff d2                	call   *%edx
  801158:	89 c2                	mov    %eax,%edx
  80115a:	83 c4 10             	add    $0x10,%esp
  80115d:	eb 09                	jmp    801168 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80115f:	89 c2                	mov    %eax,%edx
  801161:	eb 05                	jmp    801168 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801163:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801168:	89 d0                	mov    %edx,%eax
  80116a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80116d:	c9                   	leave  
  80116e:	c3                   	ret    

0080116f <seek>:

int
seek(int fdnum, off_t offset)
{
  80116f:	55                   	push   %ebp
  801170:	89 e5                	mov    %esp,%ebp
  801172:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801175:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801178:	50                   	push   %eax
  801179:	ff 75 08             	pushl  0x8(%ebp)
  80117c:	e8 22 fc ff ff       	call   800da3 <fd_lookup>
  801181:	83 c4 08             	add    $0x8,%esp
  801184:	85 c0                	test   %eax,%eax
  801186:	78 0e                	js     801196 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801188:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80118b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80118e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801191:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801196:	c9                   	leave  
  801197:	c3                   	ret    

00801198 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801198:	55                   	push   %ebp
  801199:	89 e5                	mov    %esp,%ebp
  80119b:	53                   	push   %ebx
  80119c:	83 ec 14             	sub    $0x14,%esp
  80119f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011a5:	50                   	push   %eax
  8011a6:	53                   	push   %ebx
  8011a7:	e8 f7 fb ff ff       	call   800da3 <fd_lookup>
  8011ac:	83 c4 08             	add    $0x8,%esp
  8011af:	89 c2                	mov    %eax,%edx
  8011b1:	85 c0                	test   %eax,%eax
  8011b3:	78 65                	js     80121a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b5:	83 ec 08             	sub    $0x8,%esp
  8011b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011bb:	50                   	push   %eax
  8011bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011bf:	ff 30                	pushl  (%eax)
  8011c1:	e8 33 fc ff ff       	call   800df9 <dev_lookup>
  8011c6:	83 c4 10             	add    $0x10,%esp
  8011c9:	85 c0                	test   %eax,%eax
  8011cb:	78 44                	js     801211 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011d4:	75 21                	jne    8011f7 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011d6:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011db:	8b 40 48             	mov    0x48(%eax),%eax
  8011de:	83 ec 04             	sub    $0x4,%esp
  8011e1:	53                   	push   %ebx
  8011e2:	50                   	push   %eax
  8011e3:	68 ec 25 80 00       	push   $0x8025ec
  8011e8:	e8 66 ef ff ff       	call   800153 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011ed:	83 c4 10             	add    $0x10,%esp
  8011f0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011f5:	eb 23                	jmp    80121a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011fa:	8b 52 18             	mov    0x18(%edx),%edx
  8011fd:	85 d2                	test   %edx,%edx
  8011ff:	74 14                	je     801215 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801201:	83 ec 08             	sub    $0x8,%esp
  801204:	ff 75 0c             	pushl  0xc(%ebp)
  801207:	50                   	push   %eax
  801208:	ff d2                	call   *%edx
  80120a:	89 c2                	mov    %eax,%edx
  80120c:	83 c4 10             	add    $0x10,%esp
  80120f:	eb 09                	jmp    80121a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801211:	89 c2                	mov    %eax,%edx
  801213:	eb 05                	jmp    80121a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801215:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80121a:	89 d0                	mov    %edx,%eax
  80121c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80121f:	c9                   	leave  
  801220:	c3                   	ret    

00801221 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
  801224:	53                   	push   %ebx
  801225:	83 ec 14             	sub    $0x14,%esp
  801228:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80122b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80122e:	50                   	push   %eax
  80122f:	ff 75 08             	pushl  0x8(%ebp)
  801232:	e8 6c fb ff ff       	call   800da3 <fd_lookup>
  801237:	83 c4 08             	add    $0x8,%esp
  80123a:	89 c2                	mov    %eax,%edx
  80123c:	85 c0                	test   %eax,%eax
  80123e:	78 58                	js     801298 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801240:	83 ec 08             	sub    $0x8,%esp
  801243:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801246:	50                   	push   %eax
  801247:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124a:	ff 30                	pushl  (%eax)
  80124c:	e8 a8 fb ff ff       	call   800df9 <dev_lookup>
  801251:	83 c4 10             	add    $0x10,%esp
  801254:	85 c0                	test   %eax,%eax
  801256:	78 37                	js     80128f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801258:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80125b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80125f:	74 32                	je     801293 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801261:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801264:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80126b:	00 00 00 
	stat->st_isdir = 0;
  80126e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801275:	00 00 00 
	stat->st_dev = dev;
  801278:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80127e:	83 ec 08             	sub    $0x8,%esp
  801281:	53                   	push   %ebx
  801282:	ff 75 f0             	pushl  -0x10(%ebp)
  801285:	ff 50 14             	call   *0x14(%eax)
  801288:	89 c2                	mov    %eax,%edx
  80128a:	83 c4 10             	add    $0x10,%esp
  80128d:	eb 09                	jmp    801298 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128f:	89 c2                	mov    %eax,%edx
  801291:	eb 05                	jmp    801298 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801293:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801298:	89 d0                	mov    %edx,%eax
  80129a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80129d:	c9                   	leave  
  80129e:	c3                   	ret    

0080129f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	56                   	push   %esi
  8012a3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012a4:	83 ec 08             	sub    $0x8,%esp
  8012a7:	6a 00                	push   $0x0
  8012a9:	ff 75 08             	pushl  0x8(%ebp)
  8012ac:	e8 d6 01 00 00       	call   801487 <open>
  8012b1:	89 c3                	mov    %eax,%ebx
  8012b3:	83 c4 10             	add    $0x10,%esp
  8012b6:	85 c0                	test   %eax,%eax
  8012b8:	78 1b                	js     8012d5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012ba:	83 ec 08             	sub    $0x8,%esp
  8012bd:	ff 75 0c             	pushl  0xc(%ebp)
  8012c0:	50                   	push   %eax
  8012c1:	e8 5b ff ff ff       	call   801221 <fstat>
  8012c6:	89 c6                	mov    %eax,%esi
	close(fd);
  8012c8:	89 1c 24             	mov    %ebx,(%esp)
  8012cb:	e8 fd fb ff ff       	call   800ecd <close>
	return r;
  8012d0:	83 c4 10             	add    $0x10,%esp
  8012d3:	89 f0                	mov    %esi,%eax
}
  8012d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d8:	5b                   	pop    %ebx
  8012d9:	5e                   	pop    %esi
  8012da:	5d                   	pop    %ebp
  8012db:	c3                   	ret    

008012dc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012dc:	55                   	push   %ebp
  8012dd:	89 e5                	mov    %esp,%ebp
  8012df:	56                   	push   %esi
  8012e0:	53                   	push   %ebx
  8012e1:	89 c6                	mov    %eax,%esi
  8012e3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012e5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012ec:	75 12                	jne    801300 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012ee:	83 ec 0c             	sub    $0xc,%esp
  8012f1:	6a 01                	push   $0x1
  8012f3:	e8 7a 0c 00 00       	call   801f72 <ipc_find_env>
  8012f8:	a3 00 40 80 00       	mov    %eax,0x804000
  8012fd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801300:	6a 07                	push   $0x7
  801302:	68 00 50 80 00       	push   $0x805000
  801307:	56                   	push   %esi
  801308:	ff 35 00 40 80 00    	pushl  0x804000
  80130e:	e8 0b 0c 00 00       	call   801f1e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801313:	83 c4 0c             	add    $0xc,%esp
  801316:	6a 00                	push   $0x0
  801318:	53                   	push   %ebx
  801319:	6a 00                	push   $0x0
  80131b:	e8 97 0b 00 00       	call   801eb7 <ipc_recv>
}
  801320:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801323:	5b                   	pop    %ebx
  801324:	5e                   	pop    %esi
  801325:	5d                   	pop    %ebp
  801326:	c3                   	ret    

00801327 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801327:	55                   	push   %ebp
  801328:	89 e5                	mov    %esp,%ebp
  80132a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80132d:	8b 45 08             	mov    0x8(%ebp),%eax
  801330:	8b 40 0c             	mov    0xc(%eax),%eax
  801333:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801338:	8b 45 0c             	mov    0xc(%ebp),%eax
  80133b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801340:	ba 00 00 00 00       	mov    $0x0,%edx
  801345:	b8 02 00 00 00       	mov    $0x2,%eax
  80134a:	e8 8d ff ff ff       	call   8012dc <fsipc>
}
  80134f:	c9                   	leave  
  801350:	c3                   	ret    

00801351 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801351:	55                   	push   %ebp
  801352:	89 e5                	mov    %esp,%ebp
  801354:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801357:	8b 45 08             	mov    0x8(%ebp),%eax
  80135a:	8b 40 0c             	mov    0xc(%eax),%eax
  80135d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801362:	ba 00 00 00 00       	mov    $0x0,%edx
  801367:	b8 06 00 00 00       	mov    $0x6,%eax
  80136c:	e8 6b ff ff ff       	call   8012dc <fsipc>
}
  801371:	c9                   	leave  
  801372:	c3                   	ret    

00801373 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	53                   	push   %ebx
  801377:	83 ec 04             	sub    $0x4,%esp
  80137a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80137d:	8b 45 08             	mov    0x8(%ebp),%eax
  801380:	8b 40 0c             	mov    0xc(%eax),%eax
  801383:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801388:	ba 00 00 00 00       	mov    $0x0,%edx
  80138d:	b8 05 00 00 00       	mov    $0x5,%eax
  801392:	e8 45 ff ff ff       	call   8012dc <fsipc>
  801397:	85 c0                	test   %eax,%eax
  801399:	78 2c                	js     8013c7 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80139b:	83 ec 08             	sub    $0x8,%esp
  80139e:	68 00 50 80 00       	push   $0x805000
  8013a3:	53                   	push   %ebx
  8013a4:	e8 2f f3 ff ff       	call   8006d8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013a9:	a1 80 50 80 00       	mov    0x805080,%eax
  8013ae:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013b4:	a1 84 50 80 00       	mov    0x805084,%eax
  8013b9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013bf:	83 c4 10             	add    $0x10,%esp
  8013c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ca:	c9                   	leave  
  8013cb:	c3                   	ret    

008013cc <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013cc:	55                   	push   %ebp
  8013cd:	89 e5                	mov    %esp,%ebp
  8013cf:	83 ec 0c             	sub    $0xc,%esp
  8013d2:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8013d8:	8b 52 0c             	mov    0xc(%edx),%edx
  8013db:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8013e1:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8013e6:	50                   	push   %eax
  8013e7:	ff 75 0c             	pushl  0xc(%ebp)
  8013ea:	68 08 50 80 00       	push   $0x805008
  8013ef:	e8 76 f4 ff ff       	call   80086a <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8013f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f9:	b8 04 00 00 00       	mov    $0x4,%eax
  8013fe:	e8 d9 fe ff ff       	call   8012dc <fsipc>

}
  801403:	c9                   	leave  
  801404:	c3                   	ret    

00801405 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801405:	55                   	push   %ebp
  801406:	89 e5                	mov    %esp,%ebp
  801408:	56                   	push   %esi
  801409:	53                   	push   %ebx
  80140a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80140d:	8b 45 08             	mov    0x8(%ebp),%eax
  801410:	8b 40 0c             	mov    0xc(%eax),%eax
  801413:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801418:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80141e:	ba 00 00 00 00       	mov    $0x0,%edx
  801423:	b8 03 00 00 00       	mov    $0x3,%eax
  801428:	e8 af fe ff ff       	call   8012dc <fsipc>
  80142d:	89 c3                	mov    %eax,%ebx
  80142f:	85 c0                	test   %eax,%eax
  801431:	78 4b                	js     80147e <devfile_read+0x79>
		return r;
	assert(r <= n);
  801433:	39 c6                	cmp    %eax,%esi
  801435:	73 16                	jae    80144d <devfile_read+0x48>
  801437:	68 5c 26 80 00       	push   $0x80265c
  80143c:	68 63 26 80 00       	push   $0x802663
  801441:	6a 7c                	push   $0x7c
  801443:	68 78 26 80 00       	push   $0x802678
  801448:	e8 24 0a 00 00       	call   801e71 <_panic>
	assert(r <= PGSIZE);
  80144d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801452:	7e 16                	jle    80146a <devfile_read+0x65>
  801454:	68 83 26 80 00       	push   $0x802683
  801459:	68 63 26 80 00       	push   $0x802663
  80145e:	6a 7d                	push   $0x7d
  801460:	68 78 26 80 00       	push   $0x802678
  801465:	e8 07 0a 00 00       	call   801e71 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80146a:	83 ec 04             	sub    $0x4,%esp
  80146d:	50                   	push   %eax
  80146e:	68 00 50 80 00       	push   $0x805000
  801473:	ff 75 0c             	pushl  0xc(%ebp)
  801476:	e8 ef f3 ff ff       	call   80086a <memmove>
	return r;
  80147b:	83 c4 10             	add    $0x10,%esp
}
  80147e:	89 d8                	mov    %ebx,%eax
  801480:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801483:	5b                   	pop    %ebx
  801484:	5e                   	pop    %esi
  801485:	5d                   	pop    %ebp
  801486:	c3                   	ret    

00801487 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801487:	55                   	push   %ebp
  801488:	89 e5                	mov    %esp,%ebp
  80148a:	53                   	push   %ebx
  80148b:	83 ec 20             	sub    $0x20,%esp
  80148e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801491:	53                   	push   %ebx
  801492:	e8 08 f2 ff ff       	call   80069f <strlen>
  801497:	83 c4 10             	add    $0x10,%esp
  80149a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80149f:	7f 67                	jg     801508 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014a1:	83 ec 0c             	sub    $0xc,%esp
  8014a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a7:	50                   	push   %eax
  8014a8:	e8 a7 f8 ff ff       	call   800d54 <fd_alloc>
  8014ad:	83 c4 10             	add    $0x10,%esp
		return r;
  8014b0:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014b2:	85 c0                	test   %eax,%eax
  8014b4:	78 57                	js     80150d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014b6:	83 ec 08             	sub    $0x8,%esp
  8014b9:	53                   	push   %ebx
  8014ba:	68 00 50 80 00       	push   $0x805000
  8014bf:	e8 14 f2 ff ff       	call   8006d8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014c7:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014cf:	b8 01 00 00 00       	mov    $0x1,%eax
  8014d4:	e8 03 fe ff ff       	call   8012dc <fsipc>
  8014d9:	89 c3                	mov    %eax,%ebx
  8014db:	83 c4 10             	add    $0x10,%esp
  8014de:	85 c0                	test   %eax,%eax
  8014e0:	79 14                	jns    8014f6 <open+0x6f>
		fd_close(fd, 0);
  8014e2:	83 ec 08             	sub    $0x8,%esp
  8014e5:	6a 00                	push   $0x0
  8014e7:	ff 75 f4             	pushl  -0xc(%ebp)
  8014ea:	e8 5d f9 ff ff       	call   800e4c <fd_close>
		return r;
  8014ef:	83 c4 10             	add    $0x10,%esp
  8014f2:	89 da                	mov    %ebx,%edx
  8014f4:	eb 17                	jmp    80150d <open+0x86>
	}

	return fd2num(fd);
  8014f6:	83 ec 0c             	sub    $0xc,%esp
  8014f9:	ff 75 f4             	pushl  -0xc(%ebp)
  8014fc:	e8 2c f8 ff ff       	call   800d2d <fd2num>
  801501:	89 c2                	mov    %eax,%edx
  801503:	83 c4 10             	add    $0x10,%esp
  801506:	eb 05                	jmp    80150d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801508:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80150d:	89 d0                	mov    %edx,%eax
  80150f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801512:	c9                   	leave  
  801513:	c3                   	ret    

00801514 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801514:	55                   	push   %ebp
  801515:	89 e5                	mov    %esp,%ebp
  801517:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80151a:	ba 00 00 00 00       	mov    $0x0,%edx
  80151f:	b8 08 00 00 00       	mov    $0x8,%eax
  801524:	e8 b3 fd ff ff       	call   8012dc <fsipc>
}
  801529:	c9                   	leave  
  80152a:	c3                   	ret    

0080152b <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80152b:	55                   	push   %ebp
  80152c:	89 e5                	mov    %esp,%ebp
  80152e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801531:	68 8f 26 80 00       	push   $0x80268f
  801536:	ff 75 0c             	pushl  0xc(%ebp)
  801539:	e8 9a f1 ff ff       	call   8006d8 <strcpy>
	return 0;
}
  80153e:	b8 00 00 00 00       	mov    $0x0,%eax
  801543:	c9                   	leave  
  801544:	c3                   	ret    

00801545 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801545:	55                   	push   %ebp
  801546:	89 e5                	mov    %esp,%ebp
  801548:	53                   	push   %ebx
  801549:	83 ec 10             	sub    $0x10,%esp
  80154c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80154f:	53                   	push   %ebx
  801550:	e8 56 0a 00 00       	call   801fab <pageref>
  801555:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801558:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80155d:	83 f8 01             	cmp    $0x1,%eax
  801560:	75 10                	jne    801572 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801562:	83 ec 0c             	sub    $0xc,%esp
  801565:	ff 73 0c             	pushl  0xc(%ebx)
  801568:	e8 c0 02 00 00       	call   80182d <nsipc_close>
  80156d:	89 c2                	mov    %eax,%edx
  80156f:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801572:	89 d0                	mov    %edx,%eax
  801574:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801577:	c9                   	leave  
  801578:	c3                   	ret    

00801579 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801579:	55                   	push   %ebp
  80157a:	89 e5                	mov    %esp,%ebp
  80157c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80157f:	6a 00                	push   $0x0
  801581:	ff 75 10             	pushl  0x10(%ebp)
  801584:	ff 75 0c             	pushl  0xc(%ebp)
  801587:	8b 45 08             	mov    0x8(%ebp),%eax
  80158a:	ff 70 0c             	pushl  0xc(%eax)
  80158d:	e8 78 03 00 00       	call   80190a <nsipc_send>
}
  801592:	c9                   	leave  
  801593:	c3                   	ret    

00801594 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801594:	55                   	push   %ebp
  801595:	89 e5                	mov    %esp,%ebp
  801597:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80159a:	6a 00                	push   $0x0
  80159c:	ff 75 10             	pushl  0x10(%ebp)
  80159f:	ff 75 0c             	pushl  0xc(%ebp)
  8015a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a5:	ff 70 0c             	pushl  0xc(%eax)
  8015a8:	e8 f1 02 00 00       	call   80189e <nsipc_recv>
}
  8015ad:	c9                   	leave  
  8015ae:	c3                   	ret    

008015af <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8015af:	55                   	push   %ebp
  8015b0:	89 e5                	mov    %esp,%ebp
  8015b2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8015b5:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015b8:	52                   	push   %edx
  8015b9:	50                   	push   %eax
  8015ba:	e8 e4 f7 ff ff       	call   800da3 <fd_lookup>
  8015bf:	83 c4 10             	add    $0x10,%esp
  8015c2:	85 c0                	test   %eax,%eax
  8015c4:	78 17                	js     8015dd <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8015c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c9:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8015cf:	39 08                	cmp    %ecx,(%eax)
  8015d1:	75 05                	jne    8015d8 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8015d3:	8b 40 0c             	mov    0xc(%eax),%eax
  8015d6:	eb 05                	jmp    8015dd <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8015d8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8015dd:	c9                   	leave  
  8015de:	c3                   	ret    

008015df <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8015df:	55                   	push   %ebp
  8015e0:	89 e5                	mov    %esp,%ebp
  8015e2:	56                   	push   %esi
  8015e3:	53                   	push   %ebx
  8015e4:	83 ec 1c             	sub    $0x1c,%esp
  8015e7:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8015e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ec:	50                   	push   %eax
  8015ed:	e8 62 f7 ff ff       	call   800d54 <fd_alloc>
  8015f2:	89 c3                	mov    %eax,%ebx
  8015f4:	83 c4 10             	add    $0x10,%esp
  8015f7:	85 c0                	test   %eax,%eax
  8015f9:	78 1b                	js     801616 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8015fb:	83 ec 04             	sub    $0x4,%esp
  8015fe:	68 07 04 00 00       	push   $0x407
  801603:	ff 75 f4             	pushl  -0xc(%ebp)
  801606:	6a 00                	push   $0x0
  801608:	e8 ce f4 ff ff       	call   800adb <sys_page_alloc>
  80160d:	89 c3                	mov    %eax,%ebx
  80160f:	83 c4 10             	add    $0x10,%esp
  801612:	85 c0                	test   %eax,%eax
  801614:	79 10                	jns    801626 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801616:	83 ec 0c             	sub    $0xc,%esp
  801619:	56                   	push   %esi
  80161a:	e8 0e 02 00 00       	call   80182d <nsipc_close>
		return r;
  80161f:	83 c4 10             	add    $0x10,%esp
  801622:	89 d8                	mov    %ebx,%eax
  801624:	eb 24                	jmp    80164a <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801626:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80162c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162f:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801631:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801634:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80163b:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80163e:	83 ec 0c             	sub    $0xc,%esp
  801641:	50                   	push   %eax
  801642:	e8 e6 f6 ff ff       	call   800d2d <fd2num>
  801647:	83 c4 10             	add    $0x10,%esp
}
  80164a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80164d:	5b                   	pop    %ebx
  80164e:	5e                   	pop    %esi
  80164f:	5d                   	pop    %ebp
  801650:	c3                   	ret    

00801651 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801651:	55                   	push   %ebp
  801652:	89 e5                	mov    %esp,%ebp
  801654:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801657:	8b 45 08             	mov    0x8(%ebp),%eax
  80165a:	e8 50 ff ff ff       	call   8015af <fd2sockid>
		return r;
  80165f:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801661:	85 c0                	test   %eax,%eax
  801663:	78 1f                	js     801684 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801665:	83 ec 04             	sub    $0x4,%esp
  801668:	ff 75 10             	pushl  0x10(%ebp)
  80166b:	ff 75 0c             	pushl  0xc(%ebp)
  80166e:	50                   	push   %eax
  80166f:	e8 12 01 00 00       	call   801786 <nsipc_accept>
  801674:	83 c4 10             	add    $0x10,%esp
		return r;
  801677:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801679:	85 c0                	test   %eax,%eax
  80167b:	78 07                	js     801684 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80167d:	e8 5d ff ff ff       	call   8015df <alloc_sockfd>
  801682:	89 c1                	mov    %eax,%ecx
}
  801684:	89 c8                	mov    %ecx,%eax
  801686:	c9                   	leave  
  801687:	c3                   	ret    

00801688 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80168e:	8b 45 08             	mov    0x8(%ebp),%eax
  801691:	e8 19 ff ff ff       	call   8015af <fd2sockid>
  801696:	85 c0                	test   %eax,%eax
  801698:	78 12                	js     8016ac <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  80169a:	83 ec 04             	sub    $0x4,%esp
  80169d:	ff 75 10             	pushl  0x10(%ebp)
  8016a0:	ff 75 0c             	pushl  0xc(%ebp)
  8016a3:	50                   	push   %eax
  8016a4:	e8 2d 01 00 00       	call   8017d6 <nsipc_bind>
  8016a9:	83 c4 10             	add    $0x10,%esp
}
  8016ac:	c9                   	leave  
  8016ad:	c3                   	ret    

008016ae <shutdown>:

int
shutdown(int s, int how)
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b7:	e8 f3 fe ff ff       	call   8015af <fd2sockid>
  8016bc:	85 c0                	test   %eax,%eax
  8016be:	78 0f                	js     8016cf <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8016c0:	83 ec 08             	sub    $0x8,%esp
  8016c3:	ff 75 0c             	pushl  0xc(%ebp)
  8016c6:	50                   	push   %eax
  8016c7:	e8 3f 01 00 00       	call   80180b <nsipc_shutdown>
  8016cc:	83 c4 10             	add    $0x10,%esp
}
  8016cf:	c9                   	leave  
  8016d0:	c3                   	ret    

008016d1 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8016d1:	55                   	push   %ebp
  8016d2:	89 e5                	mov    %esp,%ebp
  8016d4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016da:	e8 d0 fe ff ff       	call   8015af <fd2sockid>
  8016df:	85 c0                	test   %eax,%eax
  8016e1:	78 12                	js     8016f5 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8016e3:	83 ec 04             	sub    $0x4,%esp
  8016e6:	ff 75 10             	pushl  0x10(%ebp)
  8016e9:	ff 75 0c             	pushl  0xc(%ebp)
  8016ec:	50                   	push   %eax
  8016ed:	e8 55 01 00 00       	call   801847 <nsipc_connect>
  8016f2:	83 c4 10             	add    $0x10,%esp
}
  8016f5:	c9                   	leave  
  8016f6:	c3                   	ret    

008016f7 <listen>:

int
listen(int s, int backlog)
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801700:	e8 aa fe ff ff       	call   8015af <fd2sockid>
  801705:	85 c0                	test   %eax,%eax
  801707:	78 0f                	js     801718 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801709:	83 ec 08             	sub    $0x8,%esp
  80170c:	ff 75 0c             	pushl  0xc(%ebp)
  80170f:	50                   	push   %eax
  801710:	e8 67 01 00 00       	call   80187c <nsipc_listen>
  801715:	83 c4 10             	add    $0x10,%esp
}
  801718:	c9                   	leave  
  801719:	c3                   	ret    

0080171a <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80171a:	55                   	push   %ebp
  80171b:	89 e5                	mov    %esp,%ebp
  80171d:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801720:	ff 75 10             	pushl  0x10(%ebp)
  801723:	ff 75 0c             	pushl  0xc(%ebp)
  801726:	ff 75 08             	pushl  0x8(%ebp)
  801729:	e8 3a 02 00 00       	call   801968 <nsipc_socket>
  80172e:	83 c4 10             	add    $0x10,%esp
  801731:	85 c0                	test   %eax,%eax
  801733:	78 05                	js     80173a <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801735:	e8 a5 fe ff ff       	call   8015df <alloc_sockfd>
}
  80173a:	c9                   	leave  
  80173b:	c3                   	ret    

0080173c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	53                   	push   %ebx
  801740:	83 ec 04             	sub    $0x4,%esp
  801743:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801745:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80174c:	75 12                	jne    801760 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80174e:	83 ec 0c             	sub    $0xc,%esp
  801751:	6a 02                	push   $0x2
  801753:	e8 1a 08 00 00       	call   801f72 <ipc_find_env>
  801758:	a3 04 40 80 00       	mov    %eax,0x804004
  80175d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801760:	6a 07                	push   $0x7
  801762:	68 00 60 80 00       	push   $0x806000
  801767:	53                   	push   %ebx
  801768:	ff 35 04 40 80 00    	pushl  0x804004
  80176e:	e8 ab 07 00 00       	call   801f1e <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801773:	83 c4 0c             	add    $0xc,%esp
  801776:	6a 00                	push   $0x0
  801778:	6a 00                	push   $0x0
  80177a:	6a 00                	push   $0x0
  80177c:	e8 36 07 00 00       	call   801eb7 <ipc_recv>
}
  801781:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801784:	c9                   	leave  
  801785:	c3                   	ret    

00801786 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801786:	55                   	push   %ebp
  801787:	89 e5                	mov    %esp,%ebp
  801789:	56                   	push   %esi
  80178a:	53                   	push   %ebx
  80178b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80178e:	8b 45 08             	mov    0x8(%ebp),%eax
  801791:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801796:	8b 06                	mov    (%esi),%eax
  801798:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80179d:	b8 01 00 00 00       	mov    $0x1,%eax
  8017a2:	e8 95 ff ff ff       	call   80173c <nsipc>
  8017a7:	89 c3                	mov    %eax,%ebx
  8017a9:	85 c0                	test   %eax,%eax
  8017ab:	78 20                	js     8017cd <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8017ad:	83 ec 04             	sub    $0x4,%esp
  8017b0:	ff 35 10 60 80 00    	pushl  0x806010
  8017b6:	68 00 60 80 00       	push   $0x806000
  8017bb:	ff 75 0c             	pushl  0xc(%ebp)
  8017be:	e8 a7 f0 ff ff       	call   80086a <memmove>
		*addrlen = ret->ret_addrlen;
  8017c3:	a1 10 60 80 00       	mov    0x806010,%eax
  8017c8:	89 06                	mov    %eax,(%esi)
  8017ca:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8017cd:	89 d8                	mov    %ebx,%eax
  8017cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d2:	5b                   	pop    %ebx
  8017d3:	5e                   	pop    %esi
  8017d4:	5d                   	pop    %ebp
  8017d5:	c3                   	ret    

008017d6 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	53                   	push   %ebx
  8017da:	83 ec 08             	sub    $0x8,%esp
  8017dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8017e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e3:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8017e8:	53                   	push   %ebx
  8017e9:	ff 75 0c             	pushl  0xc(%ebp)
  8017ec:	68 04 60 80 00       	push   $0x806004
  8017f1:	e8 74 f0 ff ff       	call   80086a <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8017f6:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8017fc:	b8 02 00 00 00       	mov    $0x2,%eax
  801801:	e8 36 ff ff ff       	call   80173c <nsipc>
}
  801806:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801809:	c9                   	leave  
  80180a:	c3                   	ret    

0080180b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80180b:	55                   	push   %ebp
  80180c:	89 e5                	mov    %esp,%ebp
  80180e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801811:	8b 45 08             	mov    0x8(%ebp),%eax
  801814:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801819:	8b 45 0c             	mov    0xc(%ebp),%eax
  80181c:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801821:	b8 03 00 00 00       	mov    $0x3,%eax
  801826:	e8 11 ff ff ff       	call   80173c <nsipc>
}
  80182b:	c9                   	leave  
  80182c:	c3                   	ret    

0080182d <nsipc_close>:

int
nsipc_close(int s)
{
  80182d:	55                   	push   %ebp
  80182e:	89 e5                	mov    %esp,%ebp
  801830:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801833:	8b 45 08             	mov    0x8(%ebp),%eax
  801836:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  80183b:	b8 04 00 00 00       	mov    $0x4,%eax
  801840:	e8 f7 fe ff ff       	call   80173c <nsipc>
}
  801845:	c9                   	leave  
  801846:	c3                   	ret    

00801847 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801847:	55                   	push   %ebp
  801848:	89 e5                	mov    %esp,%ebp
  80184a:	53                   	push   %ebx
  80184b:	83 ec 08             	sub    $0x8,%esp
  80184e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801851:	8b 45 08             	mov    0x8(%ebp),%eax
  801854:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801859:	53                   	push   %ebx
  80185a:	ff 75 0c             	pushl  0xc(%ebp)
  80185d:	68 04 60 80 00       	push   $0x806004
  801862:	e8 03 f0 ff ff       	call   80086a <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801867:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  80186d:	b8 05 00 00 00       	mov    $0x5,%eax
  801872:	e8 c5 fe ff ff       	call   80173c <nsipc>
}
  801877:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187a:	c9                   	leave  
  80187b:	c3                   	ret    

0080187c <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80187c:	55                   	push   %ebp
  80187d:	89 e5                	mov    %esp,%ebp
  80187f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801882:	8b 45 08             	mov    0x8(%ebp),%eax
  801885:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80188a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80188d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801892:	b8 06 00 00 00       	mov    $0x6,%eax
  801897:	e8 a0 fe ff ff       	call   80173c <nsipc>
}
  80189c:	c9                   	leave  
  80189d:	c3                   	ret    

0080189e <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80189e:	55                   	push   %ebp
  80189f:	89 e5                	mov    %esp,%ebp
  8018a1:	56                   	push   %esi
  8018a2:	53                   	push   %ebx
  8018a3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8018a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8018ae:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8018b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8018b7:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8018bc:	b8 07 00 00 00       	mov    $0x7,%eax
  8018c1:	e8 76 fe ff ff       	call   80173c <nsipc>
  8018c6:	89 c3                	mov    %eax,%ebx
  8018c8:	85 c0                	test   %eax,%eax
  8018ca:	78 35                	js     801901 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8018cc:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8018d1:	7f 04                	jg     8018d7 <nsipc_recv+0x39>
  8018d3:	39 c6                	cmp    %eax,%esi
  8018d5:	7d 16                	jge    8018ed <nsipc_recv+0x4f>
  8018d7:	68 9b 26 80 00       	push   $0x80269b
  8018dc:	68 63 26 80 00       	push   $0x802663
  8018e1:	6a 62                	push   $0x62
  8018e3:	68 b0 26 80 00       	push   $0x8026b0
  8018e8:	e8 84 05 00 00       	call   801e71 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8018ed:	83 ec 04             	sub    $0x4,%esp
  8018f0:	50                   	push   %eax
  8018f1:	68 00 60 80 00       	push   $0x806000
  8018f6:	ff 75 0c             	pushl  0xc(%ebp)
  8018f9:	e8 6c ef ff ff       	call   80086a <memmove>
  8018fe:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801901:	89 d8                	mov    %ebx,%eax
  801903:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801906:	5b                   	pop    %ebx
  801907:	5e                   	pop    %esi
  801908:	5d                   	pop    %ebp
  801909:	c3                   	ret    

0080190a <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80190a:	55                   	push   %ebp
  80190b:	89 e5                	mov    %esp,%ebp
  80190d:	53                   	push   %ebx
  80190e:	83 ec 04             	sub    $0x4,%esp
  801911:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801914:	8b 45 08             	mov    0x8(%ebp),%eax
  801917:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  80191c:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801922:	7e 16                	jle    80193a <nsipc_send+0x30>
  801924:	68 bc 26 80 00       	push   $0x8026bc
  801929:	68 63 26 80 00       	push   $0x802663
  80192e:	6a 6d                	push   $0x6d
  801930:	68 b0 26 80 00       	push   $0x8026b0
  801935:	e8 37 05 00 00       	call   801e71 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80193a:	83 ec 04             	sub    $0x4,%esp
  80193d:	53                   	push   %ebx
  80193e:	ff 75 0c             	pushl  0xc(%ebp)
  801941:	68 0c 60 80 00       	push   $0x80600c
  801946:	e8 1f ef ff ff       	call   80086a <memmove>
	nsipcbuf.send.req_size = size;
  80194b:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801951:	8b 45 14             	mov    0x14(%ebp),%eax
  801954:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801959:	b8 08 00 00 00       	mov    $0x8,%eax
  80195e:	e8 d9 fd ff ff       	call   80173c <nsipc>
}
  801963:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801966:	c9                   	leave  
  801967:	c3                   	ret    

00801968 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801968:	55                   	push   %ebp
  801969:	89 e5                	mov    %esp,%ebp
  80196b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80196e:	8b 45 08             	mov    0x8(%ebp),%eax
  801971:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801976:	8b 45 0c             	mov    0xc(%ebp),%eax
  801979:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80197e:	8b 45 10             	mov    0x10(%ebp),%eax
  801981:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801986:	b8 09 00 00 00       	mov    $0x9,%eax
  80198b:	e8 ac fd ff ff       	call   80173c <nsipc>
}
  801990:	c9                   	leave  
  801991:	c3                   	ret    

00801992 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801992:	55                   	push   %ebp
  801993:	89 e5                	mov    %esp,%ebp
  801995:	56                   	push   %esi
  801996:	53                   	push   %ebx
  801997:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80199a:	83 ec 0c             	sub    $0xc,%esp
  80199d:	ff 75 08             	pushl  0x8(%ebp)
  8019a0:	e8 98 f3 ff ff       	call   800d3d <fd2data>
  8019a5:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019a7:	83 c4 08             	add    $0x8,%esp
  8019aa:	68 c8 26 80 00       	push   $0x8026c8
  8019af:	53                   	push   %ebx
  8019b0:	e8 23 ed ff ff       	call   8006d8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019b5:	8b 46 04             	mov    0x4(%esi),%eax
  8019b8:	2b 06                	sub    (%esi),%eax
  8019ba:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019c0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019c7:	00 00 00 
	stat->st_dev = &devpipe;
  8019ca:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8019d1:	30 80 00 
	return 0;
}
  8019d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019dc:	5b                   	pop    %ebx
  8019dd:	5e                   	pop    %esi
  8019de:	5d                   	pop    %ebp
  8019df:	c3                   	ret    

008019e0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019e0:	55                   	push   %ebp
  8019e1:	89 e5                	mov    %esp,%ebp
  8019e3:	53                   	push   %ebx
  8019e4:	83 ec 0c             	sub    $0xc,%esp
  8019e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019ea:	53                   	push   %ebx
  8019eb:	6a 00                	push   $0x0
  8019ed:	e8 6e f1 ff ff       	call   800b60 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019f2:	89 1c 24             	mov    %ebx,(%esp)
  8019f5:	e8 43 f3 ff ff       	call   800d3d <fd2data>
  8019fa:	83 c4 08             	add    $0x8,%esp
  8019fd:	50                   	push   %eax
  8019fe:	6a 00                	push   $0x0
  801a00:	e8 5b f1 ff ff       	call   800b60 <sys_page_unmap>
}
  801a05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a08:	c9                   	leave  
  801a09:	c3                   	ret    

00801a0a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a0a:	55                   	push   %ebp
  801a0b:	89 e5                	mov    %esp,%ebp
  801a0d:	57                   	push   %edi
  801a0e:	56                   	push   %esi
  801a0f:	53                   	push   %ebx
  801a10:	83 ec 1c             	sub    $0x1c,%esp
  801a13:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a16:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a18:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801a1d:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a20:	83 ec 0c             	sub    $0xc,%esp
  801a23:	ff 75 e0             	pushl  -0x20(%ebp)
  801a26:	e8 80 05 00 00       	call   801fab <pageref>
  801a2b:	89 c3                	mov    %eax,%ebx
  801a2d:	89 3c 24             	mov    %edi,(%esp)
  801a30:	e8 76 05 00 00       	call   801fab <pageref>
  801a35:	83 c4 10             	add    $0x10,%esp
  801a38:	39 c3                	cmp    %eax,%ebx
  801a3a:	0f 94 c1             	sete   %cl
  801a3d:	0f b6 c9             	movzbl %cl,%ecx
  801a40:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a43:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801a49:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a4c:	39 ce                	cmp    %ecx,%esi
  801a4e:	74 1b                	je     801a6b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a50:	39 c3                	cmp    %eax,%ebx
  801a52:	75 c4                	jne    801a18 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a54:	8b 42 58             	mov    0x58(%edx),%eax
  801a57:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a5a:	50                   	push   %eax
  801a5b:	56                   	push   %esi
  801a5c:	68 cf 26 80 00       	push   $0x8026cf
  801a61:	e8 ed e6 ff ff       	call   800153 <cprintf>
  801a66:	83 c4 10             	add    $0x10,%esp
  801a69:	eb ad                	jmp    801a18 <_pipeisclosed+0xe>
	}
}
  801a6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a71:	5b                   	pop    %ebx
  801a72:	5e                   	pop    %esi
  801a73:	5f                   	pop    %edi
  801a74:	5d                   	pop    %ebp
  801a75:	c3                   	ret    

00801a76 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a76:	55                   	push   %ebp
  801a77:	89 e5                	mov    %esp,%ebp
  801a79:	57                   	push   %edi
  801a7a:	56                   	push   %esi
  801a7b:	53                   	push   %ebx
  801a7c:	83 ec 28             	sub    $0x28,%esp
  801a7f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a82:	56                   	push   %esi
  801a83:	e8 b5 f2 ff ff       	call   800d3d <fd2data>
  801a88:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a8a:	83 c4 10             	add    $0x10,%esp
  801a8d:	bf 00 00 00 00       	mov    $0x0,%edi
  801a92:	eb 4b                	jmp    801adf <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a94:	89 da                	mov    %ebx,%edx
  801a96:	89 f0                	mov    %esi,%eax
  801a98:	e8 6d ff ff ff       	call   801a0a <_pipeisclosed>
  801a9d:	85 c0                	test   %eax,%eax
  801a9f:	75 48                	jne    801ae9 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801aa1:	e8 16 f0 ff ff       	call   800abc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801aa6:	8b 43 04             	mov    0x4(%ebx),%eax
  801aa9:	8b 0b                	mov    (%ebx),%ecx
  801aab:	8d 51 20             	lea    0x20(%ecx),%edx
  801aae:	39 d0                	cmp    %edx,%eax
  801ab0:	73 e2                	jae    801a94 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ab2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ab5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ab9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801abc:	89 c2                	mov    %eax,%edx
  801abe:	c1 fa 1f             	sar    $0x1f,%edx
  801ac1:	89 d1                	mov    %edx,%ecx
  801ac3:	c1 e9 1b             	shr    $0x1b,%ecx
  801ac6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ac9:	83 e2 1f             	and    $0x1f,%edx
  801acc:	29 ca                	sub    %ecx,%edx
  801ace:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ad2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ad6:	83 c0 01             	add    $0x1,%eax
  801ad9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801adc:	83 c7 01             	add    $0x1,%edi
  801adf:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ae2:	75 c2                	jne    801aa6 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ae4:	8b 45 10             	mov    0x10(%ebp),%eax
  801ae7:	eb 05                	jmp    801aee <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ae9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801aee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af1:	5b                   	pop    %ebx
  801af2:	5e                   	pop    %esi
  801af3:	5f                   	pop    %edi
  801af4:	5d                   	pop    %ebp
  801af5:	c3                   	ret    

00801af6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	57                   	push   %edi
  801afa:	56                   	push   %esi
  801afb:	53                   	push   %ebx
  801afc:	83 ec 18             	sub    $0x18,%esp
  801aff:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b02:	57                   	push   %edi
  801b03:	e8 35 f2 ff ff       	call   800d3d <fd2data>
  801b08:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b0a:	83 c4 10             	add    $0x10,%esp
  801b0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b12:	eb 3d                	jmp    801b51 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b14:	85 db                	test   %ebx,%ebx
  801b16:	74 04                	je     801b1c <devpipe_read+0x26>
				return i;
  801b18:	89 d8                	mov    %ebx,%eax
  801b1a:	eb 44                	jmp    801b60 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b1c:	89 f2                	mov    %esi,%edx
  801b1e:	89 f8                	mov    %edi,%eax
  801b20:	e8 e5 fe ff ff       	call   801a0a <_pipeisclosed>
  801b25:	85 c0                	test   %eax,%eax
  801b27:	75 32                	jne    801b5b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b29:	e8 8e ef ff ff       	call   800abc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b2e:	8b 06                	mov    (%esi),%eax
  801b30:	3b 46 04             	cmp    0x4(%esi),%eax
  801b33:	74 df                	je     801b14 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b35:	99                   	cltd   
  801b36:	c1 ea 1b             	shr    $0x1b,%edx
  801b39:	01 d0                	add    %edx,%eax
  801b3b:	83 e0 1f             	and    $0x1f,%eax
  801b3e:	29 d0                	sub    %edx,%eax
  801b40:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b48:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b4b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b4e:	83 c3 01             	add    $0x1,%ebx
  801b51:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b54:	75 d8                	jne    801b2e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b56:	8b 45 10             	mov    0x10(%ebp),%eax
  801b59:	eb 05                	jmp    801b60 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b5b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b63:	5b                   	pop    %ebx
  801b64:	5e                   	pop    %esi
  801b65:	5f                   	pop    %edi
  801b66:	5d                   	pop    %ebp
  801b67:	c3                   	ret    

00801b68 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b68:	55                   	push   %ebp
  801b69:	89 e5                	mov    %esp,%ebp
  801b6b:	56                   	push   %esi
  801b6c:	53                   	push   %ebx
  801b6d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b73:	50                   	push   %eax
  801b74:	e8 db f1 ff ff       	call   800d54 <fd_alloc>
  801b79:	83 c4 10             	add    $0x10,%esp
  801b7c:	89 c2                	mov    %eax,%edx
  801b7e:	85 c0                	test   %eax,%eax
  801b80:	0f 88 2c 01 00 00    	js     801cb2 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b86:	83 ec 04             	sub    $0x4,%esp
  801b89:	68 07 04 00 00       	push   $0x407
  801b8e:	ff 75 f4             	pushl  -0xc(%ebp)
  801b91:	6a 00                	push   $0x0
  801b93:	e8 43 ef ff ff       	call   800adb <sys_page_alloc>
  801b98:	83 c4 10             	add    $0x10,%esp
  801b9b:	89 c2                	mov    %eax,%edx
  801b9d:	85 c0                	test   %eax,%eax
  801b9f:	0f 88 0d 01 00 00    	js     801cb2 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ba5:	83 ec 0c             	sub    $0xc,%esp
  801ba8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bab:	50                   	push   %eax
  801bac:	e8 a3 f1 ff ff       	call   800d54 <fd_alloc>
  801bb1:	89 c3                	mov    %eax,%ebx
  801bb3:	83 c4 10             	add    $0x10,%esp
  801bb6:	85 c0                	test   %eax,%eax
  801bb8:	0f 88 e2 00 00 00    	js     801ca0 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bbe:	83 ec 04             	sub    $0x4,%esp
  801bc1:	68 07 04 00 00       	push   $0x407
  801bc6:	ff 75 f0             	pushl  -0x10(%ebp)
  801bc9:	6a 00                	push   $0x0
  801bcb:	e8 0b ef ff ff       	call   800adb <sys_page_alloc>
  801bd0:	89 c3                	mov    %eax,%ebx
  801bd2:	83 c4 10             	add    $0x10,%esp
  801bd5:	85 c0                	test   %eax,%eax
  801bd7:	0f 88 c3 00 00 00    	js     801ca0 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bdd:	83 ec 0c             	sub    $0xc,%esp
  801be0:	ff 75 f4             	pushl  -0xc(%ebp)
  801be3:	e8 55 f1 ff ff       	call   800d3d <fd2data>
  801be8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bea:	83 c4 0c             	add    $0xc,%esp
  801bed:	68 07 04 00 00       	push   $0x407
  801bf2:	50                   	push   %eax
  801bf3:	6a 00                	push   $0x0
  801bf5:	e8 e1 ee ff ff       	call   800adb <sys_page_alloc>
  801bfa:	89 c3                	mov    %eax,%ebx
  801bfc:	83 c4 10             	add    $0x10,%esp
  801bff:	85 c0                	test   %eax,%eax
  801c01:	0f 88 89 00 00 00    	js     801c90 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c07:	83 ec 0c             	sub    $0xc,%esp
  801c0a:	ff 75 f0             	pushl  -0x10(%ebp)
  801c0d:	e8 2b f1 ff ff       	call   800d3d <fd2data>
  801c12:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c19:	50                   	push   %eax
  801c1a:	6a 00                	push   $0x0
  801c1c:	56                   	push   %esi
  801c1d:	6a 00                	push   $0x0
  801c1f:	e8 fa ee ff ff       	call   800b1e <sys_page_map>
  801c24:	89 c3                	mov    %eax,%ebx
  801c26:	83 c4 20             	add    $0x20,%esp
  801c29:	85 c0                	test   %eax,%eax
  801c2b:	78 55                	js     801c82 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c2d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c36:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c42:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c48:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c4b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c50:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c57:	83 ec 0c             	sub    $0xc,%esp
  801c5a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c5d:	e8 cb f0 ff ff       	call   800d2d <fd2num>
  801c62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c65:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c67:	83 c4 04             	add    $0x4,%esp
  801c6a:	ff 75 f0             	pushl  -0x10(%ebp)
  801c6d:	e8 bb f0 ff ff       	call   800d2d <fd2num>
  801c72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c75:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c78:	83 c4 10             	add    $0x10,%esp
  801c7b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c80:	eb 30                	jmp    801cb2 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c82:	83 ec 08             	sub    $0x8,%esp
  801c85:	56                   	push   %esi
  801c86:	6a 00                	push   $0x0
  801c88:	e8 d3 ee ff ff       	call   800b60 <sys_page_unmap>
  801c8d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c90:	83 ec 08             	sub    $0x8,%esp
  801c93:	ff 75 f0             	pushl  -0x10(%ebp)
  801c96:	6a 00                	push   $0x0
  801c98:	e8 c3 ee ff ff       	call   800b60 <sys_page_unmap>
  801c9d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ca0:	83 ec 08             	sub    $0x8,%esp
  801ca3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca6:	6a 00                	push   $0x0
  801ca8:	e8 b3 ee ff ff       	call   800b60 <sys_page_unmap>
  801cad:	83 c4 10             	add    $0x10,%esp
  801cb0:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cb2:	89 d0                	mov    %edx,%eax
  801cb4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cb7:	5b                   	pop    %ebx
  801cb8:	5e                   	pop    %esi
  801cb9:	5d                   	pop    %ebp
  801cba:	c3                   	ret    

00801cbb <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cbb:	55                   	push   %ebp
  801cbc:	89 e5                	mov    %esp,%ebp
  801cbe:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cc1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cc4:	50                   	push   %eax
  801cc5:	ff 75 08             	pushl  0x8(%ebp)
  801cc8:	e8 d6 f0 ff ff       	call   800da3 <fd_lookup>
  801ccd:	83 c4 10             	add    $0x10,%esp
  801cd0:	85 c0                	test   %eax,%eax
  801cd2:	78 18                	js     801cec <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cd4:	83 ec 0c             	sub    $0xc,%esp
  801cd7:	ff 75 f4             	pushl  -0xc(%ebp)
  801cda:	e8 5e f0 ff ff       	call   800d3d <fd2data>
	return _pipeisclosed(fd, p);
  801cdf:	89 c2                	mov    %eax,%edx
  801ce1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce4:	e8 21 fd ff ff       	call   801a0a <_pipeisclosed>
  801ce9:	83 c4 10             	add    $0x10,%esp
}
  801cec:	c9                   	leave  
  801ced:	c3                   	ret    

00801cee <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cee:	55                   	push   %ebp
  801cef:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cf1:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf6:	5d                   	pop    %ebp
  801cf7:	c3                   	ret    

00801cf8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cf8:	55                   	push   %ebp
  801cf9:	89 e5                	mov    %esp,%ebp
  801cfb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cfe:	68 e7 26 80 00       	push   $0x8026e7
  801d03:	ff 75 0c             	pushl  0xc(%ebp)
  801d06:	e8 cd e9 ff ff       	call   8006d8 <strcpy>
	return 0;
}
  801d0b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d10:	c9                   	leave  
  801d11:	c3                   	ret    

00801d12 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d12:	55                   	push   %ebp
  801d13:	89 e5                	mov    %esp,%ebp
  801d15:	57                   	push   %edi
  801d16:	56                   	push   %esi
  801d17:	53                   	push   %ebx
  801d18:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d1e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d23:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d29:	eb 2d                	jmp    801d58 <devcons_write+0x46>
		m = n - tot;
  801d2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d2e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d30:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d33:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d38:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d3b:	83 ec 04             	sub    $0x4,%esp
  801d3e:	53                   	push   %ebx
  801d3f:	03 45 0c             	add    0xc(%ebp),%eax
  801d42:	50                   	push   %eax
  801d43:	57                   	push   %edi
  801d44:	e8 21 eb ff ff       	call   80086a <memmove>
		sys_cputs(buf, m);
  801d49:	83 c4 08             	add    $0x8,%esp
  801d4c:	53                   	push   %ebx
  801d4d:	57                   	push   %edi
  801d4e:	e8 cc ec ff ff       	call   800a1f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d53:	01 de                	add    %ebx,%esi
  801d55:	83 c4 10             	add    $0x10,%esp
  801d58:	89 f0                	mov    %esi,%eax
  801d5a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d5d:	72 cc                	jb     801d2b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d62:	5b                   	pop    %ebx
  801d63:	5e                   	pop    %esi
  801d64:	5f                   	pop    %edi
  801d65:	5d                   	pop    %ebp
  801d66:	c3                   	ret    

00801d67 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d67:	55                   	push   %ebp
  801d68:	89 e5                	mov    %esp,%ebp
  801d6a:	83 ec 08             	sub    $0x8,%esp
  801d6d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d72:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d76:	74 2a                	je     801da2 <devcons_read+0x3b>
  801d78:	eb 05                	jmp    801d7f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d7a:	e8 3d ed ff ff       	call   800abc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d7f:	e8 b9 ec ff ff       	call   800a3d <sys_cgetc>
  801d84:	85 c0                	test   %eax,%eax
  801d86:	74 f2                	je     801d7a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d88:	85 c0                	test   %eax,%eax
  801d8a:	78 16                	js     801da2 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d8c:	83 f8 04             	cmp    $0x4,%eax
  801d8f:	74 0c                	je     801d9d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d91:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d94:	88 02                	mov    %al,(%edx)
	return 1;
  801d96:	b8 01 00 00 00       	mov    $0x1,%eax
  801d9b:	eb 05                	jmp    801da2 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d9d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801da2:	c9                   	leave  
  801da3:	c3                   	ret    

00801da4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801daa:	8b 45 08             	mov    0x8(%ebp),%eax
  801dad:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801db0:	6a 01                	push   $0x1
  801db2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801db5:	50                   	push   %eax
  801db6:	e8 64 ec ff ff       	call   800a1f <sys_cputs>
}
  801dbb:	83 c4 10             	add    $0x10,%esp
  801dbe:	c9                   	leave  
  801dbf:	c3                   	ret    

00801dc0 <getchar>:

int
getchar(void)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dc6:	6a 01                	push   $0x1
  801dc8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dcb:	50                   	push   %eax
  801dcc:	6a 00                	push   $0x0
  801dce:	e8 36 f2 ff ff       	call   801009 <read>
	if (r < 0)
  801dd3:	83 c4 10             	add    $0x10,%esp
  801dd6:	85 c0                	test   %eax,%eax
  801dd8:	78 0f                	js     801de9 <getchar+0x29>
		return r;
	if (r < 1)
  801dda:	85 c0                	test   %eax,%eax
  801ddc:	7e 06                	jle    801de4 <getchar+0x24>
		return -E_EOF;
	return c;
  801dde:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801de2:	eb 05                	jmp    801de9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801de4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801de9:	c9                   	leave  
  801dea:	c3                   	ret    

00801deb <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801deb:	55                   	push   %ebp
  801dec:	89 e5                	mov    %esp,%ebp
  801dee:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801df1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df4:	50                   	push   %eax
  801df5:	ff 75 08             	pushl  0x8(%ebp)
  801df8:	e8 a6 ef ff ff       	call   800da3 <fd_lookup>
  801dfd:	83 c4 10             	add    $0x10,%esp
  801e00:	85 c0                	test   %eax,%eax
  801e02:	78 11                	js     801e15 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e07:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e0d:	39 10                	cmp    %edx,(%eax)
  801e0f:	0f 94 c0             	sete   %al
  801e12:	0f b6 c0             	movzbl %al,%eax
}
  801e15:	c9                   	leave  
  801e16:	c3                   	ret    

00801e17 <opencons>:

int
opencons(void)
{
  801e17:	55                   	push   %ebp
  801e18:	89 e5                	mov    %esp,%ebp
  801e1a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e20:	50                   	push   %eax
  801e21:	e8 2e ef ff ff       	call   800d54 <fd_alloc>
  801e26:	83 c4 10             	add    $0x10,%esp
		return r;
  801e29:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e2b:	85 c0                	test   %eax,%eax
  801e2d:	78 3e                	js     801e6d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e2f:	83 ec 04             	sub    $0x4,%esp
  801e32:	68 07 04 00 00       	push   $0x407
  801e37:	ff 75 f4             	pushl  -0xc(%ebp)
  801e3a:	6a 00                	push   $0x0
  801e3c:	e8 9a ec ff ff       	call   800adb <sys_page_alloc>
  801e41:	83 c4 10             	add    $0x10,%esp
		return r;
  801e44:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e46:	85 c0                	test   %eax,%eax
  801e48:	78 23                	js     801e6d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e4a:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e53:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e58:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e5f:	83 ec 0c             	sub    $0xc,%esp
  801e62:	50                   	push   %eax
  801e63:	e8 c5 ee ff ff       	call   800d2d <fd2num>
  801e68:	89 c2                	mov    %eax,%edx
  801e6a:	83 c4 10             	add    $0x10,%esp
}
  801e6d:	89 d0                	mov    %edx,%eax
  801e6f:	c9                   	leave  
  801e70:	c3                   	ret    

00801e71 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e71:	55                   	push   %ebp
  801e72:	89 e5                	mov    %esp,%ebp
  801e74:	56                   	push   %esi
  801e75:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e76:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e79:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e7f:	e8 19 ec ff ff       	call   800a9d <sys_getenvid>
  801e84:	83 ec 0c             	sub    $0xc,%esp
  801e87:	ff 75 0c             	pushl  0xc(%ebp)
  801e8a:	ff 75 08             	pushl  0x8(%ebp)
  801e8d:	56                   	push   %esi
  801e8e:	50                   	push   %eax
  801e8f:	68 f4 26 80 00       	push   $0x8026f4
  801e94:	e8 ba e2 ff ff       	call   800153 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e99:	83 c4 18             	add    $0x18,%esp
  801e9c:	53                   	push   %ebx
  801e9d:	ff 75 10             	pushl  0x10(%ebp)
  801ea0:	e8 5d e2 ff ff       	call   800102 <vcprintf>
	cprintf("\n");
  801ea5:	c7 04 24 8c 22 80 00 	movl   $0x80228c,(%esp)
  801eac:	e8 a2 e2 ff ff       	call   800153 <cprintf>
  801eb1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801eb4:	cc                   	int3   
  801eb5:	eb fd                	jmp    801eb4 <_panic+0x43>

00801eb7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801eb7:	55                   	push   %ebp
  801eb8:	89 e5                	mov    %esp,%ebp
  801eba:	56                   	push   %esi
  801ebb:	53                   	push   %ebx
  801ebc:	8b 75 08             	mov    0x8(%ebp),%esi
  801ebf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801ec5:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801ec7:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ecc:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801ecf:	83 ec 0c             	sub    $0xc,%esp
  801ed2:	50                   	push   %eax
  801ed3:	e8 b3 ed ff ff       	call   800c8b <sys_ipc_recv>

	if (from_env_store != NULL)
  801ed8:	83 c4 10             	add    $0x10,%esp
  801edb:	85 f6                	test   %esi,%esi
  801edd:	74 14                	je     801ef3 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801edf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ee4:	85 c0                	test   %eax,%eax
  801ee6:	78 09                	js     801ef1 <ipc_recv+0x3a>
  801ee8:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801eee:	8b 52 74             	mov    0x74(%edx),%edx
  801ef1:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801ef3:	85 db                	test   %ebx,%ebx
  801ef5:	74 14                	je     801f0b <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801ef7:	ba 00 00 00 00       	mov    $0x0,%edx
  801efc:	85 c0                	test   %eax,%eax
  801efe:	78 09                	js     801f09 <ipc_recv+0x52>
  801f00:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801f06:	8b 52 78             	mov    0x78(%edx),%edx
  801f09:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801f0b:	85 c0                	test   %eax,%eax
  801f0d:	78 08                	js     801f17 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801f0f:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801f14:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f17:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f1a:	5b                   	pop    %ebx
  801f1b:	5e                   	pop    %esi
  801f1c:	5d                   	pop    %ebp
  801f1d:	c3                   	ret    

00801f1e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f1e:	55                   	push   %ebp
  801f1f:	89 e5                	mov    %esp,%ebp
  801f21:	57                   	push   %edi
  801f22:	56                   	push   %esi
  801f23:	53                   	push   %ebx
  801f24:	83 ec 0c             	sub    $0xc,%esp
  801f27:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f2a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801f30:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801f32:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f37:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801f3a:	ff 75 14             	pushl  0x14(%ebp)
  801f3d:	53                   	push   %ebx
  801f3e:	56                   	push   %esi
  801f3f:	57                   	push   %edi
  801f40:	e8 23 ed ff ff       	call   800c68 <sys_ipc_try_send>

		if (err < 0) {
  801f45:	83 c4 10             	add    $0x10,%esp
  801f48:	85 c0                	test   %eax,%eax
  801f4a:	79 1e                	jns    801f6a <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801f4c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f4f:	75 07                	jne    801f58 <ipc_send+0x3a>
				sys_yield();
  801f51:	e8 66 eb ff ff       	call   800abc <sys_yield>
  801f56:	eb e2                	jmp    801f3a <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f58:	50                   	push   %eax
  801f59:	68 18 27 80 00       	push   $0x802718
  801f5e:	6a 49                	push   $0x49
  801f60:	68 25 27 80 00       	push   $0x802725
  801f65:	e8 07 ff ff ff       	call   801e71 <_panic>
		}

	} while (err < 0);

}
  801f6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f6d:	5b                   	pop    %ebx
  801f6e:	5e                   	pop    %esi
  801f6f:	5f                   	pop    %edi
  801f70:	5d                   	pop    %ebp
  801f71:	c3                   	ret    

00801f72 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f72:	55                   	push   %ebp
  801f73:	89 e5                	mov    %esp,%ebp
  801f75:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f78:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f7d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f80:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f86:	8b 52 50             	mov    0x50(%edx),%edx
  801f89:	39 ca                	cmp    %ecx,%edx
  801f8b:	75 0d                	jne    801f9a <ipc_find_env+0x28>
			return envs[i].env_id;
  801f8d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f90:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f95:	8b 40 48             	mov    0x48(%eax),%eax
  801f98:	eb 0f                	jmp    801fa9 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f9a:	83 c0 01             	add    $0x1,%eax
  801f9d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fa2:	75 d9                	jne    801f7d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fa4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fa9:	5d                   	pop    %ebp
  801faa:	c3                   	ret    

00801fab <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fab:	55                   	push   %ebp
  801fac:	89 e5                	mov    %esp,%ebp
  801fae:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fb1:	89 d0                	mov    %edx,%eax
  801fb3:	c1 e8 16             	shr    $0x16,%eax
  801fb6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fbd:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fc2:	f6 c1 01             	test   $0x1,%cl
  801fc5:	74 1d                	je     801fe4 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fc7:	c1 ea 0c             	shr    $0xc,%edx
  801fca:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fd1:	f6 c2 01             	test   $0x1,%dl
  801fd4:	74 0e                	je     801fe4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fd6:	c1 ea 0c             	shr    $0xc,%edx
  801fd9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fe0:	ef 
  801fe1:	0f b7 c0             	movzwl %ax,%eax
}
  801fe4:	5d                   	pop    %ebp
  801fe5:	c3                   	ret    
  801fe6:	66 90                	xchg   %ax,%ax
  801fe8:	66 90                	xchg   %ax,%ax
  801fea:	66 90                	xchg   %ax,%ax
  801fec:	66 90                	xchg   %ax,%ax
  801fee:	66 90                	xchg   %ax,%ax

00801ff0 <__udivdi3>:
  801ff0:	55                   	push   %ebp
  801ff1:	57                   	push   %edi
  801ff2:	56                   	push   %esi
  801ff3:	53                   	push   %ebx
  801ff4:	83 ec 1c             	sub    $0x1c,%esp
  801ff7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801ffb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802003:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802007:	85 f6                	test   %esi,%esi
  802009:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80200d:	89 ca                	mov    %ecx,%edx
  80200f:	89 f8                	mov    %edi,%eax
  802011:	75 3d                	jne    802050 <__udivdi3+0x60>
  802013:	39 cf                	cmp    %ecx,%edi
  802015:	0f 87 c5 00 00 00    	ja     8020e0 <__udivdi3+0xf0>
  80201b:	85 ff                	test   %edi,%edi
  80201d:	89 fd                	mov    %edi,%ebp
  80201f:	75 0b                	jne    80202c <__udivdi3+0x3c>
  802021:	b8 01 00 00 00       	mov    $0x1,%eax
  802026:	31 d2                	xor    %edx,%edx
  802028:	f7 f7                	div    %edi
  80202a:	89 c5                	mov    %eax,%ebp
  80202c:	89 c8                	mov    %ecx,%eax
  80202e:	31 d2                	xor    %edx,%edx
  802030:	f7 f5                	div    %ebp
  802032:	89 c1                	mov    %eax,%ecx
  802034:	89 d8                	mov    %ebx,%eax
  802036:	89 cf                	mov    %ecx,%edi
  802038:	f7 f5                	div    %ebp
  80203a:	89 c3                	mov    %eax,%ebx
  80203c:	89 d8                	mov    %ebx,%eax
  80203e:	89 fa                	mov    %edi,%edx
  802040:	83 c4 1c             	add    $0x1c,%esp
  802043:	5b                   	pop    %ebx
  802044:	5e                   	pop    %esi
  802045:	5f                   	pop    %edi
  802046:	5d                   	pop    %ebp
  802047:	c3                   	ret    
  802048:	90                   	nop
  802049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802050:	39 ce                	cmp    %ecx,%esi
  802052:	77 74                	ja     8020c8 <__udivdi3+0xd8>
  802054:	0f bd fe             	bsr    %esi,%edi
  802057:	83 f7 1f             	xor    $0x1f,%edi
  80205a:	0f 84 98 00 00 00    	je     8020f8 <__udivdi3+0x108>
  802060:	bb 20 00 00 00       	mov    $0x20,%ebx
  802065:	89 f9                	mov    %edi,%ecx
  802067:	89 c5                	mov    %eax,%ebp
  802069:	29 fb                	sub    %edi,%ebx
  80206b:	d3 e6                	shl    %cl,%esi
  80206d:	89 d9                	mov    %ebx,%ecx
  80206f:	d3 ed                	shr    %cl,%ebp
  802071:	89 f9                	mov    %edi,%ecx
  802073:	d3 e0                	shl    %cl,%eax
  802075:	09 ee                	or     %ebp,%esi
  802077:	89 d9                	mov    %ebx,%ecx
  802079:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80207d:	89 d5                	mov    %edx,%ebp
  80207f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802083:	d3 ed                	shr    %cl,%ebp
  802085:	89 f9                	mov    %edi,%ecx
  802087:	d3 e2                	shl    %cl,%edx
  802089:	89 d9                	mov    %ebx,%ecx
  80208b:	d3 e8                	shr    %cl,%eax
  80208d:	09 c2                	or     %eax,%edx
  80208f:	89 d0                	mov    %edx,%eax
  802091:	89 ea                	mov    %ebp,%edx
  802093:	f7 f6                	div    %esi
  802095:	89 d5                	mov    %edx,%ebp
  802097:	89 c3                	mov    %eax,%ebx
  802099:	f7 64 24 0c          	mull   0xc(%esp)
  80209d:	39 d5                	cmp    %edx,%ebp
  80209f:	72 10                	jb     8020b1 <__udivdi3+0xc1>
  8020a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020a5:	89 f9                	mov    %edi,%ecx
  8020a7:	d3 e6                	shl    %cl,%esi
  8020a9:	39 c6                	cmp    %eax,%esi
  8020ab:	73 07                	jae    8020b4 <__udivdi3+0xc4>
  8020ad:	39 d5                	cmp    %edx,%ebp
  8020af:	75 03                	jne    8020b4 <__udivdi3+0xc4>
  8020b1:	83 eb 01             	sub    $0x1,%ebx
  8020b4:	31 ff                	xor    %edi,%edi
  8020b6:	89 d8                	mov    %ebx,%eax
  8020b8:	89 fa                	mov    %edi,%edx
  8020ba:	83 c4 1c             	add    $0x1c,%esp
  8020bd:	5b                   	pop    %ebx
  8020be:	5e                   	pop    %esi
  8020bf:	5f                   	pop    %edi
  8020c0:	5d                   	pop    %ebp
  8020c1:	c3                   	ret    
  8020c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020c8:	31 ff                	xor    %edi,%edi
  8020ca:	31 db                	xor    %ebx,%ebx
  8020cc:	89 d8                	mov    %ebx,%eax
  8020ce:	89 fa                	mov    %edi,%edx
  8020d0:	83 c4 1c             	add    $0x1c,%esp
  8020d3:	5b                   	pop    %ebx
  8020d4:	5e                   	pop    %esi
  8020d5:	5f                   	pop    %edi
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    
  8020d8:	90                   	nop
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	89 d8                	mov    %ebx,%eax
  8020e2:	f7 f7                	div    %edi
  8020e4:	31 ff                	xor    %edi,%edi
  8020e6:	89 c3                	mov    %eax,%ebx
  8020e8:	89 d8                	mov    %ebx,%eax
  8020ea:	89 fa                	mov    %edi,%edx
  8020ec:	83 c4 1c             	add    $0x1c,%esp
  8020ef:	5b                   	pop    %ebx
  8020f0:	5e                   	pop    %esi
  8020f1:	5f                   	pop    %edi
  8020f2:	5d                   	pop    %ebp
  8020f3:	c3                   	ret    
  8020f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020f8:	39 ce                	cmp    %ecx,%esi
  8020fa:	72 0c                	jb     802108 <__udivdi3+0x118>
  8020fc:	31 db                	xor    %ebx,%ebx
  8020fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802102:	0f 87 34 ff ff ff    	ja     80203c <__udivdi3+0x4c>
  802108:	bb 01 00 00 00       	mov    $0x1,%ebx
  80210d:	e9 2a ff ff ff       	jmp    80203c <__udivdi3+0x4c>
  802112:	66 90                	xchg   %ax,%ax
  802114:	66 90                	xchg   %ax,%ax
  802116:	66 90                	xchg   %ax,%ax
  802118:	66 90                	xchg   %ax,%ax
  80211a:	66 90                	xchg   %ax,%ax
  80211c:	66 90                	xchg   %ax,%ax
  80211e:	66 90                	xchg   %ax,%ax

00802120 <__umoddi3>:
  802120:	55                   	push   %ebp
  802121:	57                   	push   %edi
  802122:	56                   	push   %esi
  802123:	53                   	push   %ebx
  802124:	83 ec 1c             	sub    $0x1c,%esp
  802127:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80212b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80212f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802133:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802137:	85 d2                	test   %edx,%edx
  802139:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80213d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802141:	89 f3                	mov    %esi,%ebx
  802143:	89 3c 24             	mov    %edi,(%esp)
  802146:	89 74 24 04          	mov    %esi,0x4(%esp)
  80214a:	75 1c                	jne    802168 <__umoddi3+0x48>
  80214c:	39 f7                	cmp    %esi,%edi
  80214e:	76 50                	jbe    8021a0 <__umoddi3+0x80>
  802150:	89 c8                	mov    %ecx,%eax
  802152:	89 f2                	mov    %esi,%edx
  802154:	f7 f7                	div    %edi
  802156:	89 d0                	mov    %edx,%eax
  802158:	31 d2                	xor    %edx,%edx
  80215a:	83 c4 1c             	add    $0x1c,%esp
  80215d:	5b                   	pop    %ebx
  80215e:	5e                   	pop    %esi
  80215f:	5f                   	pop    %edi
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    
  802162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802168:	39 f2                	cmp    %esi,%edx
  80216a:	89 d0                	mov    %edx,%eax
  80216c:	77 52                	ja     8021c0 <__umoddi3+0xa0>
  80216e:	0f bd ea             	bsr    %edx,%ebp
  802171:	83 f5 1f             	xor    $0x1f,%ebp
  802174:	75 5a                	jne    8021d0 <__umoddi3+0xb0>
  802176:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80217a:	0f 82 e0 00 00 00    	jb     802260 <__umoddi3+0x140>
  802180:	39 0c 24             	cmp    %ecx,(%esp)
  802183:	0f 86 d7 00 00 00    	jbe    802260 <__umoddi3+0x140>
  802189:	8b 44 24 08          	mov    0x8(%esp),%eax
  80218d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802191:	83 c4 1c             	add    $0x1c,%esp
  802194:	5b                   	pop    %ebx
  802195:	5e                   	pop    %esi
  802196:	5f                   	pop    %edi
  802197:	5d                   	pop    %ebp
  802198:	c3                   	ret    
  802199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	85 ff                	test   %edi,%edi
  8021a2:	89 fd                	mov    %edi,%ebp
  8021a4:	75 0b                	jne    8021b1 <__umoddi3+0x91>
  8021a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ab:	31 d2                	xor    %edx,%edx
  8021ad:	f7 f7                	div    %edi
  8021af:	89 c5                	mov    %eax,%ebp
  8021b1:	89 f0                	mov    %esi,%eax
  8021b3:	31 d2                	xor    %edx,%edx
  8021b5:	f7 f5                	div    %ebp
  8021b7:	89 c8                	mov    %ecx,%eax
  8021b9:	f7 f5                	div    %ebp
  8021bb:	89 d0                	mov    %edx,%eax
  8021bd:	eb 99                	jmp    802158 <__umoddi3+0x38>
  8021bf:	90                   	nop
  8021c0:	89 c8                	mov    %ecx,%eax
  8021c2:	89 f2                	mov    %esi,%edx
  8021c4:	83 c4 1c             	add    $0x1c,%esp
  8021c7:	5b                   	pop    %ebx
  8021c8:	5e                   	pop    %esi
  8021c9:	5f                   	pop    %edi
  8021ca:	5d                   	pop    %ebp
  8021cb:	c3                   	ret    
  8021cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	8b 34 24             	mov    (%esp),%esi
  8021d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021d8:	89 e9                	mov    %ebp,%ecx
  8021da:	29 ef                	sub    %ebp,%edi
  8021dc:	d3 e0                	shl    %cl,%eax
  8021de:	89 f9                	mov    %edi,%ecx
  8021e0:	89 f2                	mov    %esi,%edx
  8021e2:	d3 ea                	shr    %cl,%edx
  8021e4:	89 e9                	mov    %ebp,%ecx
  8021e6:	09 c2                	or     %eax,%edx
  8021e8:	89 d8                	mov    %ebx,%eax
  8021ea:	89 14 24             	mov    %edx,(%esp)
  8021ed:	89 f2                	mov    %esi,%edx
  8021ef:	d3 e2                	shl    %cl,%edx
  8021f1:	89 f9                	mov    %edi,%ecx
  8021f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021fb:	d3 e8                	shr    %cl,%eax
  8021fd:	89 e9                	mov    %ebp,%ecx
  8021ff:	89 c6                	mov    %eax,%esi
  802201:	d3 e3                	shl    %cl,%ebx
  802203:	89 f9                	mov    %edi,%ecx
  802205:	89 d0                	mov    %edx,%eax
  802207:	d3 e8                	shr    %cl,%eax
  802209:	89 e9                	mov    %ebp,%ecx
  80220b:	09 d8                	or     %ebx,%eax
  80220d:	89 d3                	mov    %edx,%ebx
  80220f:	89 f2                	mov    %esi,%edx
  802211:	f7 34 24             	divl   (%esp)
  802214:	89 d6                	mov    %edx,%esi
  802216:	d3 e3                	shl    %cl,%ebx
  802218:	f7 64 24 04          	mull   0x4(%esp)
  80221c:	39 d6                	cmp    %edx,%esi
  80221e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802222:	89 d1                	mov    %edx,%ecx
  802224:	89 c3                	mov    %eax,%ebx
  802226:	72 08                	jb     802230 <__umoddi3+0x110>
  802228:	75 11                	jne    80223b <__umoddi3+0x11b>
  80222a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80222e:	73 0b                	jae    80223b <__umoddi3+0x11b>
  802230:	2b 44 24 04          	sub    0x4(%esp),%eax
  802234:	1b 14 24             	sbb    (%esp),%edx
  802237:	89 d1                	mov    %edx,%ecx
  802239:	89 c3                	mov    %eax,%ebx
  80223b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80223f:	29 da                	sub    %ebx,%edx
  802241:	19 ce                	sbb    %ecx,%esi
  802243:	89 f9                	mov    %edi,%ecx
  802245:	89 f0                	mov    %esi,%eax
  802247:	d3 e0                	shl    %cl,%eax
  802249:	89 e9                	mov    %ebp,%ecx
  80224b:	d3 ea                	shr    %cl,%edx
  80224d:	89 e9                	mov    %ebp,%ecx
  80224f:	d3 ee                	shr    %cl,%esi
  802251:	09 d0                	or     %edx,%eax
  802253:	89 f2                	mov    %esi,%edx
  802255:	83 c4 1c             	add    $0x1c,%esp
  802258:	5b                   	pop    %ebx
  802259:	5e                   	pop    %esi
  80225a:	5f                   	pop    %edi
  80225b:	5d                   	pop    %ebp
  80225c:	c3                   	ret    
  80225d:	8d 76 00             	lea    0x0(%esi),%esi
  802260:	29 f9                	sub    %edi,%ecx
  802262:	19 d6                	sbb    %edx,%esi
  802264:	89 74 24 04          	mov    %esi,0x4(%esp)
  802268:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80226c:	e9 18 ff ff ff       	jmp    802189 <__umoddi3+0x69>
