
obj/user/hello.debug:     file format elf32-i386


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
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 c0 22 80 00       	push   $0x8022c0
  80003e:	e8 0e 01 00 00       	call   800151 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 08 40 80 00       	mov    0x804008,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 ce 22 80 00       	push   $0x8022ce
  800054:	e8 f8 00 00 00       	call   800151 <cprintf>
}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800066:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800069:	e8 2d 0a 00 00       	call   800a9b <sys_getenvid>
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800076:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007b:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800080:	85 db                	test   %ebx,%ebx
  800082:	7e 07                	jle    80008b <libmain+0x2d>
		binaryname = argv[0];
  800084:	8b 06                	mov    (%esi),%eax
  800086:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008b:	83 ec 08             	sub    $0x8,%esp
  80008e:	56                   	push   %esi
  80008f:	53                   	push   %ebx
  800090:	e8 9e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800095:	e8 0a 00 00 00       	call   8000a4 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a0:	5b                   	pop    %ebx
  8000a1:	5e                   	pop    %esi
  8000a2:	5d                   	pop    %ebp
  8000a3:	c3                   	ret    

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000aa:	e8 89 0e 00 00       	call   800f38 <close_all>
	sys_env_destroy(0);
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	6a 00                	push   $0x0
  8000b4:	e8 a1 09 00 00       	call   800a5a <sys_env_destroy>
}
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	c9                   	leave  
  8000bd:	c3                   	ret    

008000be <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	53                   	push   %ebx
  8000c2:	83 ec 04             	sub    $0x4,%esp
  8000c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c8:	8b 13                	mov    (%ebx),%edx
  8000ca:	8d 42 01             	lea    0x1(%edx),%eax
  8000cd:	89 03                	mov    %eax,(%ebx)
  8000cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000db:	75 1a                	jne    8000f7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000dd:	83 ec 08             	sub    $0x8,%esp
  8000e0:	68 ff 00 00 00       	push   $0xff
  8000e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e8:	50                   	push   %eax
  8000e9:	e8 2f 09 00 00       	call   800a1d <sys_cputs>
		b->idx = 0;
  8000ee:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000fe:	c9                   	leave  
  8000ff:	c3                   	ret    

00800100 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800109:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800110:	00 00 00 
	b.cnt = 0;
  800113:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011d:	ff 75 0c             	pushl  0xc(%ebp)
  800120:	ff 75 08             	pushl  0x8(%ebp)
  800123:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800129:	50                   	push   %eax
  80012a:	68 be 00 80 00       	push   $0x8000be
  80012f:	e8 54 01 00 00       	call   800288 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800134:	83 c4 08             	add    $0x8,%esp
  800137:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80013d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 d4 08 00 00       	call   800a1d <sys_cputs>

	return b.cnt;
}
  800149:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014f:	c9                   	leave  
  800150:	c3                   	ret    

00800151 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800157:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015a:	50                   	push   %eax
  80015b:	ff 75 08             	pushl  0x8(%ebp)
  80015e:	e8 9d ff ff ff       	call   800100 <vcprintf>
	va_end(ap);

	return cnt;
}
  800163:	c9                   	leave  
  800164:	c3                   	ret    

00800165 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	57                   	push   %edi
  800169:	56                   	push   %esi
  80016a:	53                   	push   %ebx
  80016b:	83 ec 1c             	sub    $0x1c,%esp
  80016e:	89 c7                	mov    %eax,%edi
  800170:	89 d6                	mov    %edx,%esi
  800172:	8b 45 08             	mov    0x8(%ebp),%eax
  800175:	8b 55 0c             	mov    0xc(%ebp),%edx
  800178:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80017e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800181:	bb 00 00 00 00       	mov    $0x0,%ebx
  800186:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800189:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80018c:	39 d3                	cmp    %edx,%ebx
  80018e:	72 05                	jb     800195 <printnum+0x30>
  800190:	39 45 10             	cmp    %eax,0x10(%ebp)
  800193:	77 45                	ja     8001da <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800195:	83 ec 0c             	sub    $0xc,%esp
  800198:	ff 75 18             	pushl  0x18(%ebp)
  80019b:	8b 45 14             	mov    0x14(%ebp),%eax
  80019e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001a1:	53                   	push   %ebx
  8001a2:	ff 75 10             	pushl  0x10(%ebp)
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b4:	e8 77 1e 00 00       	call   802030 <__udivdi3>
  8001b9:	83 c4 18             	add    $0x18,%esp
  8001bc:	52                   	push   %edx
  8001bd:	50                   	push   %eax
  8001be:	89 f2                	mov    %esi,%edx
  8001c0:	89 f8                	mov    %edi,%eax
  8001c2:	e8 9e ff ff ff       	call   800165 <printnum>
  8001c7:	83 c4 20             	add    $0x20,%esp
  8001ca:	eb 18                	jmp    8001e4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001cc:	83 ec 08             	sub    $0x8,%esp
  8001cf:	56                   	push   %esi
  8001d0:	ff 75 18             	pushl  0x18(%ebp)
  8001d3:	ff d7                	call   *%edi
  8001d5:	83 c4 10             	add    $0x10,%esp
  8001d8:	eb 03                	jmp    8001dd <printnum+0x78>
  8001da:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001dd:	83 eb 01             	sub    $0x1,%ebx
  8001e0:	85 db                	test   %ebx,%ebx
  8001e2:	7f e8                	jg     8001cc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e4:	83 ec 08             	sub    $0x8,%esp
  8001e7:	56                   	push   %esi
  8001e8:	83 ec 04             	sub    $0x4,%esp
  8001eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f7:	e8 64 1f 00 00       	call   802160 <__umoddi3>
  8001fc:	83 c4 14             	add    $0x14,%esp
  8001ff:	0f be 80 ef 22 80 00 	movsbl 0x8022ef(%eax),%eax
  800206:	50                   	push   %eax
  800207:	ff d7                	call   *%edi
}
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020f:	5b                   	pop    %ebx
  800210:	5e                   	pop    %esi
  800211:	5f                   	pop    %edi
  800212:	5d                   	pop    %ebp
  800213:	c3                   	ret    

00800214 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800217:	83 fa 01             	cmp    $0x1,%edx
  80021a:	7e 0e                	jle    80022a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80021c:	8b 10                	mov    (%eax),%edx
  80021e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800221:	89 08                	mov    %ecx,(%eax)
  800223:	8b 02                	mov    (%edx),%eax
  800225:	8b 52 04             	mov    0x4(%edx),%edx
  800228:	eb 22                	jmp    80024c <getuint+0x38>
	else if (lflag)
  80022a:	85 d2                	test   %edx,%edx
  80022c:	74 10                	je     80023e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80022e:	8b 10                	mov    (%eax),%edx
  800230:	8d 4a 04             	lea    0x4(%edx),%ecx
  800233:	89 08                	mov    %ecx,(%eax)
  800235:	8b 02                	mov    (%edx),%eax
  800237:	ba 00 00 00 00       	mov    $0x0,%edx
  80023c:	eb 0e                	jmp    80024c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80023e:	8b 10                	mov    (%eax),%edx
  800240:	8d 4a 04             	lea    0x4(%edx),%ecx
  800243:	89 08                	mov    %ecx,(%eax)
  800245:	8b 02                	mov    (%edx),%eax
  800247:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800254:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800258:	8b 10                	mov    (%eax),%edx
  80025a:	3b 50 04             	cmp    0x4(%eax),%edx
  80025d:	73 0a                	jae    800269 <sprintputch+0x1b>
		*b->buf++ = ch;
  80025f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800262:	89 08                	mov    %ecx,(%eax)
  800264:	8b 45 08             	mov    0x8(%ebp),%eax
  800267:	88 02                	mov    %al,(%edx)
}
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800271:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800274:	50                   	push   %eax
  800275:	ff 75 10             	pushl  0x10(%ebp)
  800278:	ff 75 0c             	pushl  0xc(%ebp)
  80027b:	ff 75 08             	pushl  0x8(%ebp)
  80027e:	e8 05 00 00 00       	call   800288 <vprintfmt>
	va_end(ap);
}
  800283:	83 c4 10             	add    $0x10,%esp
  800286:	c9                   	leave  
  800287:	c3                   	ret    

00800288 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	57                   	push   %edi
  80028c:	56                   	push   %esi
  80028d:	53                   	push   %ebx
  80028e:	83 ec 2c             	sub    $0x2c,%esp
  800291:	8b 75 08             	mov    0x8(%ebp),%esi
  800294:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800297:	8b 7d 10             	mov    0x10(%ebp),%edi
  80029a:	eb 12                	jmp    8002ae <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80029c:	85 c0                	test   %eax,%eax
  80029e:	0f 84 89 03 00 00    	je     80062d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002a4:	83 ec 08             	sub    $0x8,%esp
  8002a7:	53                   	push   %ebx
  8002a8:	50                   	push   %eax
  8002a9:	ff d6                	call   *%esi
  8002ab:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ae:	83 c7 01             	add    $0x1,%edi
  8002b1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002b5:	83 f8 25             	cmp    $0x25,%eax
  8002b8:	75 e2                	jne    80029c <vprintfmt+0x14>
  8002ba:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002be:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002c5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002cc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d8:	eb 07                	jmp    8002e1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002da:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002dd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e1:	8d 47 01             	lea    0x1(%edi),%eax
  8002e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e7:	0f b6 07             	movzbl (%edi),%eax
  8002ea:	0f b6 c8             	movzbl %al,%ecx
  8002ed:	83 e8 23             	sub    $0x23,%eax
  8002f0:	3c 55                	cmp    $0x55,%al
  8002f2:	0f 87 1a 03 00 00    	ja     800612 <vprintfmt+0x38a>
  8002f8:	0f b6 c0             	movzbl %al,%eax
  8002fb:	ff 24 85 40 24 80 00 	jmp    *0x802440(,%eax,4)
  800302:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800305:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800309:	eb d6                	jmp    8002e1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80030e:	b8 00 00 00 00       	mov    $0x0,%eax
  800313:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800316:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800319:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80031d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800320:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800323:	83 fa 09             	cmp    $0x9,%edx
  800326:	77 39                	ja     800361 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800328:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80032b:	eb e9                	jmp    800316 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80032d:	8b 45 14             	mov    0x14(%ebp),%eax
  800330:	8d 48 04             	lea    0x4(%eax),%ecx
  800333:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800336:	8b 00                	mov    (%eax),%eax
  800338:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80033e:	eb 27                	jmp    800367 <vprintfmt+0xdf>
  800340:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800343:	85 c0                	test   %eax,%eax
  800345:	b9 00 00 00 00       	mov    $0x0,%ecx
  80034a:	0f 49 c8             	cmovns %eax,%ecx
  80034d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800350:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800353:	eb 8c                	jmp    8002e1 <vprintfmt+0x59>
  800355:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800358:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80035f:	eb 80                	jmp    8002e1 <vprintfmt+0x59>
  800361:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800364:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800367:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80036b:	0f 89 70 ff ff ff    	jns    8002e1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800371:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800374:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800377:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80037e:	e9 5e ff ff ff       	jmp    8002e1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800383:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800386:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800389:	e9 53 ff ff ff       	jmp    8002e1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80038e:	8b 45 14             	mov    0x14(%ebp),%eax
  800391:	8d 50 04             	lea    0x4(%eax),%edx
  800394:	89 55 14             	mov    %edx,0x14(%ebp)
  800397:	83 ec 08             	sub    $0x8,%esp
  80039a:	53                   	push   %ebx
  80039b:	ff 30                	pushl  (%eax)
  80039d:	ff d6                	call   *%esi
			break;
  80039f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003a5:	e9 04 ff ff ff       	jmp    8002ae <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ad:	8d 50 04             	lea    0x4(%eax),%edx
  8003b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b3:	8b 00                	mov    (%eax),%eax
  8003b5:	99                   	cltd   
  8003b6:	31 d0                	xor    %edx,%eax
  8003b8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ba:	83 f8 0f             	cmp    $0xf,%eax
  8003bd:	7f 0b                	jg     8003ca <vprintfmt+0x142>
  8003bf:	8b 14 85 a0 25 80 00 	mov    0x8025a0(,%eax,4),%edx
  8003c6:	85 d2                	test   %edx,%edx
  8003c8:	75 18                	jne    8003e2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003ca:	50                   	push   %eax
  8003cb:	68 07 23 80 00       	push   $0x802307
  8003d0:	53                   	push   %ebx
  8003d1:	56                   	push   %esi
  8003d2:	e8 94 fe ff ff       	call   80026b <printfmt>
  8003d7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003dd:	e9 cc fe ff ff       	jmp    8002ae <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003e2:	52                   	push   %edx
  8003e3:	68 d5 26 80 00       	push   $0x8026d5
  8003e8:	53                   	push   %ebx
  8003e9:	56                   	push   %esi
  8003ea:	e8 7c fe ff ff       	call   80026b <printfmt>
  8003ef:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f5:	e9 b4 fe ff ff       	jmp    8002ae <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fd:	8d 50 04             	lea    0x4(%eax),%edx
  800400:	89 55 14             	mov    %edx,0x14(%ebp)
  800403:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800405:	85 ff                	test   %edi,%edi
  800407:	b8 00 23 80 00       	mov    $0x802300,%eax
  80040c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80040f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800413:	0f 8e 94 00 00 00    	jle    8004ad <vprintfmt+0x225>
  800419:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80041d:	0f 84 98 00 00 00    	je     8004bb <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800423:	83 ec 08             	sub    $0x8,%esp
  800426:	ff 75 d0             	pushl  -0x30(%ebp)
  800429:	57                   	push   %edi
  80042a:	e8 86 02 00 00       	call   8006b5 <strnlen>
  80042f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800432:	29 c1                	sub    %eax,%ecx
  800434:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800437:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80043a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80043e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800441:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800444:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800446:	eb 0f                	jmp    800457 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800448:	83 ec 08             	sub    $0x8,%esp
  80044b:	53                   	push   %ebx
  80044c:	ff 75 e0             	pushl  -0x20(%ebp)
  80044f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800451:	83 ef 01             	sub    $0x1,%edi
  800454:	83 c4 10             	add    $0x10,%esp
  800457:	85 ff                	test   %edi,%edi
  800459:	7f ed                	jg     800448 <vprintfmt+0x1c0>
  80045b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80045e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800461:	85 c9                	test   %ecx,%ecx
  800463:	b8 00 00 00 00       	mov    $0x0,%eax
  800468:	0f 49 c1             	cmovns %ecx,%eax
  80046b:	29 c1                	sub    %eax,%ecx
  80046d:	89 75 08             	mov    %esi,0x8(%ebp)
  800470:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800473:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800476:	89 cb                	mov    %ecx,%ebx
  800478:	eb 4d                	jmp    8004c7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80047a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80047e:	74 1b                	je     80049b <vprintfmt+0x213>
  800480:	0f be c0             	movsbl %al,%eax
  800483:	83 e8 20             	sub    $0x20,%eax
  800486:	83 f8 5e             	cmp    $0x5e,%eax
  800489:	76 10                	jbe    80049b <vprintfmt+0x213>
					putch('?', putdat);
  80048b:	83 ec 08             	sub    $0x8,%esp
  80048e:	ff 75 0c             	pushl  0xc(%ebp)
  800491:	6a 3f                	push   $0x3f
  800493:	ff 55 08             	call   *0x8(%ebp)
  800496:	83 c4 10             	add    $0x10,%esp
  800499:	eb 0d                	jmp    8004a8 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	ff 75 0c             	pushl  0xc(%ebp)
  8004a1:	52                   	push   %edx
  8004a2:	ff 55 08             	call   *0x8(%ebp)
  8004a5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a8:	83 eb 01             	sub    $0x1,%ebx
  8004ab:	eb 1a                	jmp    8004c7 <vprintfmt+0x23f>
  8004ad:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b9:	eb 0c                	jmp    8004c7 <vprintfmt+0x23f>
  8004bb:	89 75 08             	mov    %esi,0x8(%ebp)
  8004be:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c7:	83 c7 01             	add    $0x1,%edi
  8004ca:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004ce:	0f be d0             	movsbl %al,%edx
  8004d1:	85 d2                	test   %edx,%edx
  8004d3:	74 23                	je     8004f8 <vprintfmt+0x270>
  8004d5:	85 f6                	test   %esi,%esi
  8004d7:	78 a1                	js     80047a <vprintfmt+0x1f2>
  8004d9:	83 ee 01             	sub    $0x1,%esi
  8004dc:	79 9c                	jns    80047a <vprintfmt+0x1f2>
  8004de:	89 df                	mov    %ebx,%edi
  8004e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e6:	eb 18                	jmp    800500 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	53                   	push   %ebx
  8004ec:	6a 20                	push   $0x20
  8004ee:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004f0:	83 ef 01             	sub    $0x1,%edi
  8004f3:	83 c4 10             	add    $0x10,%esp
  8004f6:	eb 08                	jmp    800500 <vprintfmt+0x278>
  8004f8:	89 df                	mov    %ebx,%edi
  8004fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8004fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800500:	85 ff                	test   %edi,%edi
  800502:	7f e4                	jg     8004e8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800504:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800507:	e9 a2 fd ff ff       	jmp    8002ae <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80050c:	83 fa 01             	cmp    $0x1,%edx
  80050f:	7e 16                	jle    800527 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800511:	8b 45 14             	mov    0x14(%ebp),%eax
  800514:	8d 50 08             	lea    0x8(%eax),%edx
  800517:	89 55 14             	mov    %edx,0x14(%ebp)
  80051a:	8b 50 04             	mov    0x4(%eax),%edx
  80051d:	8b 00                	mov    (%eax),%eax
  80051f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800522:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800525:	eb 32                	jmp    800559 <vprintfmt+0x2d1>
	else if (lflag)
  800527:	85 d2                	test   %edx,%edx
  800529:	74 18                	je     800543 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80052b:	8b 45 14             	mov    0x14(%ebp),%eax
  80052e:	8d 50 04             	lea    0x4(%eax),%edx
  800531:	89 55 14             	mov    %edx,0x14(%ebp)
  800534:	8b 00                	mov    (%eax),%eax
  800536:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800539:	89 c1                	mov    %eax,%ecx
  80053b:	c1 f9 1f             	sar    $0x1f,%ecx
  80053e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800541:	eb 16                	jmp    800559 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8d 50 04             	lea    0x4(%eax),%edx
  800549:	89 55 14             	mov    %edx,0x14(%ebp)
  80054c:	8b 00                	mov    (%eax),%eax
  80054e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800551:	89 c1                	mov    %eax,%ecx
  800553:	c1 f9 1f             	sar    $0x1f,%ecx
  800556:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800559:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80055c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80055f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800564:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800568:	79 74                	jns    8005de <vprintfmt+0x356>
				putch('-', putdat);
  80056a:	83 ec 08             	sub    $0x8,%esp
  80056d:	53                   	push   %ebx
  80056e:	6a 2d                	push   $0x2d
  800570:	ff d6                	call   *%esi
				num = -(long long) num;
  800572:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800575:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800578:	f7 d8                	neg    %eax
  80057a:	83 d2 00             	adc    $0x0,%edx
  80057d:	f7 da                	neg    %edx
  80057f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800582:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800587:	eb 55                	jmp    8005de <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800589:	8d 45 14             	lea    0x14(%ebp),%eax
  80058c:	e8 83 fc ff ff       	call   800214 <getuint>
			base = 10;
  800591:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800596:	eb 46                	jmp    8005de <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800598:	8d 45 14             	lea    0x14(%ebp),%eax
  80059b:	e8 74 fc ff ff       	call   800214 <getuint>
			base = 8;
  8005a0:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005a5:	eb 37                	jmp    8005de <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	53                   	push   %ebx
  8005ab:	6a 30                	push   $0x30
  8005ad:	ff d6                	call   *%esi
			putch('x', putdat);
  8005af:	83 c4 08             	add    $0x8,%esp
  8005b2:	53                   	push   %ebx
  8005b3:	6a 78                	push   $0x78
  8005b5:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ba:	8d 50 04             	lea    0x4(%eax),%edx
  8005bd:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005c0:	8b 00                	mov    (%eax),%eax
  8005c2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005c7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005ca:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005cf:	eb 0d                	jmp    8005de <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005d1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d4:	e8 3b fc ff ff       	call   800214 <getuint>
			base = 16;
  8005d9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005de:	83 ec 0c             	sub    $0xc,%esp
  8005e1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005e5:	57                   	push   %edi
  8005e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8005e9:	51                   	push   %ecx
  8005ea:	52                   	push   %edx
  8005eb:	50                   	push   %eax
  8005ec:	89 da                	mov    %ebx,%edx
  8005ee:	89 f0                	mov    %esi,%eax
  8005f0:	e8 70 fb ff ff       	call   800165 <printnum>
			break;
  8005f5:	83 c4 20             	add    $0x20,%esp
  8005f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005fb:	e9 ae fc ff ff       	jmp    8002ae <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800600:	83 ec 08             	sub    $0x8,%esp
  800603:	53                   	push   %ebx
  800604:	51                   	push   %ecx
  800605:	ff d6                	call   *%esi
			break;
  800607:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80060d:	e9 9c fc ff ff       	jmp    8002ae <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	53                   	push   %ebx
  800616:	6a 25                	push   $0x25
  800618:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80061a:	83 c4 10             	add    $0x10,%esp
  80061d:	eb 03                	jmp    800622 <vprintfmt+0x39a>
  80061f:	83 ef 01             	sub    $0x1,%edi
  800622:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800626:	75 f7                	jne    80061f <vprintfmt+0x397>
  800628:	e9 81 fc ff ff       	jmp    8002ae <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80062d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800630:	5b                   	pop    %ebx
  800631:	5e                   	pop    %esi
  800632:	5f                   	pop    %edi
  800633:	5d                   	pop    %ebp
  800634:	c3                   	ret    

00800635 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800635:	55                   	push   %ebp
  800636:	89 e5                	mov    %esp,%ebp
  800638:	83 ec 18             	sub    $0x18,%esp
  80063b:	8b 45 08             	mov    0x8(%ebp),%eax
  80063e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800641:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800644:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800648:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80064b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800652:	85 c0                	test   %eax,%eax
  800654:	74 26                	je     80067c <vsnprintf+0x47>
  800656:	85 d2                	test   %edx,%edx
  800658:	7e 22                	jle    80067c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80065a:	ff 75 14             	pushl  0x14(%ebp)
  80065d:	ff 75 10             	pushl  0x10(%ebp)
  800660:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800663:	50                   	push   %eax
  800664:	68 4e 02 80 00       	push   $0x80024e
  800669:	e8 1a fc ff ff       	call   800288 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80066e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800671:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800674:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800677:	83 c4 10             	add    $0x10,%esp
  80067a:	eb 05                	jmp    800681 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80067c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800681:	c9                   	leave  
  800682:	c3                   	ret    

00800683 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800683:	55                   	push   %ebp
  800684:	89 e5                	mov    %esp,%ebp
  800686:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800689:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80068c:	50                   	push   %eax
  80068d:	ff 75 10             	pushl  0x10(%ebp)
  800690:	ff 75 0c             	pushl  0xc(%ebp)
  800693:	ff 75 08             	pushl  0x8(%ebp)
  800696:	e8 9a ff ff ff       	call   800635 <vsnprintf>
	va_end(ap);

	return rc;
}
  80069b:	c9                   	leave  
  80069c:	c3                   	ret    

0080069d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80069d:	55                   	push   %ebp
  80069e:	89 e5                	mov    %esp,%ebp
  8006a0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a8:	eb 03                	jmp    8006ad <strlen+0x10>
		n++;
  8006aa:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ad:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006b1:	75 f7                	jne    8006aa <strlen+0xd>
		n++;
	return n;
}
  8006b3:	5d                   	pop    %ebp
  8006b4:	c3                   	ret    

008006b5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006b5:	55                   	push   %ebp
  8006b6:	89 e5                	mov    %esp,%ebp
  8006b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006bb:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006be:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c3:	eb 03                	jmp    8006c8 <strnlen+0x13>
		n++;
  8006c5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006c8:	39 c2                	cmp    %eax,%edx
  8006ca:	74 08                	je     8006d4 <strnlen+0x1f>
  8006cc:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006d0:	75 f3                	jne    8006c5 <strnlen+0x10>
  8006d2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006d4:	5d                   	pop    %ebp
  8006d5:	c3                   	ret    

008006d6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006d6:	55                   	push   %ebp
  8006d7:	89 e5                	mov    %esp,%ebp
  8006d9:	53                   	push   %ebx
  8006da:	8b 45 08             	mov    0x8(%ebp),%eax
  8006dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006e0:	89 c2                	mov    %eax,%edx
  8006e2:	83 c2 01             	add    $0x1,%edx
  8006e5:	83 c1 01             	add    $0x1,%ecx
  8006e8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006ec:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006ef:	84 db                	test   %bl,%bl
  8006f1:	75 ef                	jne    8006e2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006f3:	5b                   	pop    %ebx
  8006f4:	5d                   	pop    %ebp
  8006f5:	c3                   	ret    

008006f6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  8006f9:	53                   	push   %ebx
  8006fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006fd:	53                   	push   %ebx
  8006fe:	e8 9a ff ff ff       	call   80069d <strlen>
  800703:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800706:	ff 75 0c             	pushl  0xc(%ebp)
  800709:	01 d8                	add    %ebx,%eax
  80070b:	50                   	push   %eax
  80070c:	e8 c5 ff ff ff       	call   8006d6 <strcpy>
	return dst;
}
  800711:	89 d8                	mov    %ebx,%eax
  800713:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800716:	c9                   	leave  
  800717:	c3                   	ret    

00800718 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	56                   	push   %esi
  80071c:	53                   	push   %ebx
  80071d:	8b 75 08             	mov    0x8(%ebp),%esi
  800720:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800723:	89 f3                	mov    %esi,%ebx
  800725:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800728:	89 f2                	mov    %esi,%edx
  80072a:	eb 0f                	jmp    80073b <strncpy+0x23>
		*dst++ = *src;
  80072c:	83 c2 01             	add    $0x1,%edx
  80072f:	0f b6 01             	movzbl (%ecx),%eax
  800732:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800735:	80 39 01             	cmpb   $0x1,(%ecx)
  800738:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80073b:	39 da                	cmp    %ebx,%edx
  80073d:	75 ed                	jne    80072c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80073f:	89 f0                	mov    %esi,%eax
  800741:	5b                   	pop    %ebx
  800742:	5e                   	pop    %esi
  800743:	5d                   	pop    %ebp
  800744:	c3                   	ret    

00800745 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	56                   	push   %esi
  800749:	53                   	push   %ebx
  80074a:	8b 75 08             	mov    0x8(%ebp),%esi
  80074d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800750:	8b 55 10             	mov    0x10(%ebp),%edx
  800753:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800755:	85 d2                	test   %edx,%edx
  800757:	74 21                	je     80077a <strlcpy+0x35>
  800759:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80075d:	89 f2                	mov    %esi,%edx
  80075f:	eb 09                	jmp    80076a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800761:	83 c2 01             	add    $0x1,%edx
  800764:	83 c1 01             	add    $0x1,%ecx
  800767:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80076a:	39 c2                	cmp    %eax,%edx
  80076c:	74 09                	je     800777 <strlcpy+0x32>
  80076e:	0f b6 19             	movzbl (%ecx),%ebx
  800771:	84 db                	test   %bl,%bl
  800773:	75 ec                	jne    800761 <strlcpy+0x1c>
  800775:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800777:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80077a:	29 f0                	sub    %esi,%eax
}
  80077c:	5b                   	pop    %ebx
  80077d:	5e                   	pop    %esi
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800786:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800789:	eb 06                	jmp    800791 <strcmp+0x11>
		p++, q++;
  80078b:	83 c1 01             	add    $0x1,%ecx
  80078e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800791:	0f b6 01             	movzbl (%ecx),%eax
  800794:	84 c0                	test   %al,%al
  800796:	74 04                	je     80079c <strcmp+0x1c>
  800798:	3a 02                	cmp    (%edx),%al
  80079a:	74 ef                	je     80078b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80079c:	0f b6 c0             	movzbl %al,%eax
  80079f:	0f b6 12             	movzbl (%edx),%edx
  8007a2:	29 d0                	sub    %edx,%eax
}
  8007a4:	5d                   	pop    %ebp
  8007a5:	c3                   	ret    

008007a6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	53                   	push   %ebx
  8007aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b0:	89 c3                	mov    %eax,%ebx
  8007b2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007b5:	eb 06                	jmp    8007bd <strncmp+0x17>
		n--, p++, q++;
  8007b7:	83 c0 01             	add    $0x1,%eax
  8007ba:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007bd:	39 d8                	cmp    %ebx,%eax
  8007bf:	74 15                	je     8007d6 <strncmp+0x30>
  8007c1:	0f b6 08             	movzbl (%eax),%ecx
  8007c4:	84 c9                	test   %cl,%cl
  8007c6:	74 04                	je     8007cc <strncmp+0x26>
  8007c8:	3a 0a                	cmp    (%edx),%cl
  8007ca:	74 eb                	je     8007b7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007cc:	0f b6 00             	movzbl (%eax),%eax
  8007cf:	0f b6 12             	movzbl (%edx),%edx
  8007d2:	29 d0                	sub    %edx,%eax
  8007d4:	eb 05                	jmp    8007db <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007d6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007db:	5b                   	pop    %ebx
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    

008007de <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007e8:	eb 07                	jmp    8007f1 <strchr+0x13>
		if (*s == c)
  8007ea:	38 ca                	cmp    %cl,%dl
  8007ec:	74 0f                	je     8007fd <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007ee:	83 c0 01             	add    $0x1,%eax
  8007f1:	0f b6 10             	movzbl (%eax),%edx
  8007f4:	84 d2                	test   %dl,%dl
  8007f6:	75 f2                	jne    8007ea <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8007f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	8b 45 08             	mov    0x8(%ebp),%eax
  800805:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800809:	eb 03                	jmp    80080e <strfind+0xf>
  80080b:	83 c0 01             	add    $0x1,%eax
  80080e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800811:	38 ca                	cmp    %cl,%dl
  800813:	74 04                	je     800819 <strfind+0x1a>
  800815:	84 d2                	test   %dl,%dl
  800817:	75 f2                	jne    80080b <strfind+0xc>
			break;
	return (char *) s;
}
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	57                   	push   %edi
  80081f:	56                   	push   %esi
  800820:	53                   	push   %ebx
  800821:	8b 7d 08             	mov    0x8(%ebp),%edi
  800824:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800827:	85 c9                	test   %ecx,%ecx
  800829:	74 36                	je     800861 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80082b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800831:	75 28                	jne    80085b <memset+0x40>
  800833:	f6 c1 03             	test   $0x3,%cl
  800836:	75 23                	jne    80085b <memset+0x40>
		c &= 0xFF;
  800838:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80083c:	89 d3                	mov    %edx,%ebx
  80083e:	c1 e3 08             	shl    $0x8,%ebx
  800841:	89 d6                	mov    %edx,%esi
  800843:	c1 e6 18             	shl    $0x18,%esi
  800846:	89 d0                	mov    %edx,%eax
  800848:	c1 e0 10             	shl    $0x10,%eax
  80084b:	09 f0                	or     %esi,%eax
  80084d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80084f:	89 d8                	mov    %ebx,%eax
  800851:	09 d0                	or     %edx,%eax
  800853:	c1 e9 02             	shr    $0x2,%ecx
  800856:	fc                   	cld    
  800857:	f3 ab                	rep stos %eax,%es:(%edi)
  800859:	eb 06                	jmp    800861 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80085b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085e:	fc                   	cld    
  80085f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800861:	89 f8                	mov    %edi,%eax
  800863:	5b                   	pop    %ebx
  800864:	5e                   	pop    %esi
  800865:	5f                   	pop    %edi
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	57                   	push   %edi
  80086c:	56                   	push   %esi
  80086d:	8b 45 08             	mov    0x8(%ebp),%eax
  800870:	8b 75 0c             	mov    0xc(%ebp),%esi
  800873:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800876:	39 c6                	cmp    %eax,%esi
  800878:	73 35                	jae    8008af <memmove+0x47>
  80087a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80087d:	39 d0                	cmp    %edx,%eax
  80087f:	73 2e                	jae    8008af <memmove+0x47>
		s += n;
		d += n;
  800881:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800884:	89 d6                	mov    %edx,%esi
  800886:	09 fe                	or     %edi,%esi
  800888:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80088e:	75 13                	jne    8008a3 <memmove+0x3b>
  800890:	f6 c1 03             	test   $0x3,%cl
  800893:	75 0e                	jne    8008a3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800895:	83 ef 04             	sub    $0x4,%edi
  800898:	8d 72 fc             	lea    -0x4(%edx),%esi
  80089b:	c1 e9 02             	shr    $0x2,%ecx
  80089e:	fd                   	std    
  80089f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008a1:	eb 09                	jmp    8008ac <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008a3:	83 ef 01             	sub    $0x1,%edi
  8008a6:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008a9:	fd                   	std    
  8008aa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ac:	fc                   	cld    
  8008ad:	eb 1d                	jmp    8008cc <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008af:	89 f2                	mov    %esi,%edx
  8008b1:	09 c2                	or     %eax,%edx
  8008b3:	f6 c2 03             	test   $0x3,%dl
  8008b6:	75 0f                	jne    8008c7 <memmove+0x5f>
  8008b8:	f6 c1 03             	test   $0x3,%cl
  8008bb:	75 0a                	jne    8008c7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008bd:	c1 e9 02             	shr    $0x2,%ecx
  8008c0:	89 c7                	mov    %eax,%edi
  8008c2:	fc                   	cld    
  8008c3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c5:	eb 05                	jmp    8008cc <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008c7:	89 c7                	mov    %eax,%edi
  8008c9:	fc                   	cld    
  8008ca:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008cc:	5e                   	pop    %esi
  8008cd:	5f                   	pop    %edi
  8008ce:	5d                   	pop    %ebp
  8008cf:	c3                   	ret    

008008d0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008d3:	ff 75 10             	pushl  0x10(%ebp)
  8008d6:	ff 75 0c             	pushl  0xc(%ebp)
  8008d9:	ff 75 08             	pushl  0x8(%ebp)
  8008dc:	e8 87 ff ff ff       	call   800868 <memmove>
}
  8008e1:	c9                   	leave  
  8008e2:	c3                   	ret    

008008e3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	56                   	push   %esi
  8008e7:	53                   	push   %ebx
  8008e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ee:	89 c6                	mov    %eax,%esi
  8008f0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008f3:	eb 1a                	jmp    80090f <memcmp+0x2c>
		if (*s1 != *s2)
  8008f5:	0f b6 08             	movzbl (%eax),%ecx
  8008f8:	0f b6 1a             	movzbl (%edx),%ebx
  8008fb:	38 d9                	cmp    %bl,%cl
  8008fd:	74 0a                	je     800909 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8008ff:	0f b6 c1             	movzbl %cl,%eax
  800902:	0f b6 db             	movzbl %bl,%ebx
  800905:	29 d8                	sub    %ebx,%eax
  800907:	eb 0f                	jmp    800918 <memcmp+0x35>
		s1++, s2++;
  800909:	83 c0 01             	add    $0x1,%eax
  80090c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80090f:	39 f0                	cmp    %esi,%eax
  800911:	75 e2                	jne    8008f5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800913:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800918:	5b                   	pop    %ebx
  800919:	5e                   	pop    %esi
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	53                   	push   %ebx
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800923:	89 c1                	mov    %eax,%ecx
  800925:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800928:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80092c:	eb 0a                	jmp    800938 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80092e:	0f b6 10             	movzbl (%eax),%edx
  800931:	39 da                	cmp    %ebx,%edx
  800933:	74 07                	je     80093c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800935:	83 c0 01             	add    $0x1,%eax
  800938:	39 c8                	cmp    %ecx,%eax
  80093a:	72 f2                	jb     80092e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80093c:	5b                   	pop    %ebx
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	57                   	push   %edi
  800943:	56                   	push   %esi
  800944:	53                   	push   %ebx
  800945:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800948:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80094b:	eb 03                	jmp    800950 <strtol+0x11>
		s++;
  80094d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800950:	0f b6 01             	movzbl (%ecx),%eax
  800953:	3c 20                	cmp    $0x20,%al
  800955:	74 f6                	je     80094d <strtol+0xe>
  800957:	3c 09                	cmp    $0x9,%al
  800959:	74 f2                	je     80094d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80095b:	3c 2b                	cmp    $0x2b,%al
  80095d:	75 0a                	jne    800969 <strtol+0x2a>
		s++;
  80095f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800962:	bf 00 00 00 00       	mov    $0x0,%edi
  800967:	eb 11                	jmp    80097a <strtol+0x3b>
  800969:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80096e:	3c 2d                	cmp    $0x2d,%al
  800970:	75 08                	jne    80097a <strtol+0x3b>
		s++, neg = 1;
  800972:	83 c1 01             	add    $0x1,%ecx
  800975:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80097a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800980:	75 15                	jne    800997 <strtol+0x58>
  800982:	80 39 30             	cmpb   $0x30,(%ecx)
  800985:	75 10                	jne    800997 <strtol+0x58>
  800987:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80098b:	75 7c                	jne    800a09 <strtol+0xca>
		s += 2, base = 16;
  80098d:	83 c1 02             	add    $0x2,%ecx
  800990:	bb 10 00 00 00       	mov    $0x10,%ebx
  800995:	eb 16                	jmp    8009ad <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800997:	85 db                	test   %ebx,%ebx
  800999:	75 12                	jne    8009ad <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80099b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009a0:	80 39 30             	cmpb   $0x30,(%ecx)
  8009a3:	75 08                	jne    8009ad <strtol+0x6e>
		s++, base = 8;
  8009a5:	83 c1 01             	add    $0x1,%ecx
  8009a8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009b5:	0f b6 11             	movzbl (%ecx),%edx
  8009b8:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009bb:	89 f3                	mov    %esi,%ebx
  8009bd:	80 fb 09             	cmp    $0x9,%bl
  8009c0:	77 08                	ja     8009ca <strtol+0x8b>
			dig = *s - '0';
  8009c2:	0f be d2             	movsbl %dl,%edx
  8009c5:	83 ea 30             	sub    $0x30,%edx
  8009c8:	eb 22                	jmp    8009ec <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009ca:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009cd:	89 f3                	mov    %esi,%ebx
  8009cf:	80 fb 19             	cmp    $0x19,%bl
  8009d2:	77 08                	ja     8009dc <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009d4:	0f be d2             	movsbl %dl,%edx
  8009d7:	83 ea 57             	sub    $0x57,%edx
  8009da:	eb 10                	jmp    8009ec <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009dc:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009df:	89 f3                	mov    %esi,%ebx
  8009e1:	80 fb 19             	cmp    $0x19,%bl
  8009e4:	77 16                	ja     8009fc <strtol+0xbd>
			dig = *s - 'A' + 10;
  8009e6:	0f be d2             	movsbl %dl,%edx
  8009e9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009ec:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009ef:	7d 0b                	jge    8009fc <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8009f1:	83 c1 01             	add    $0x1,%ecx
  8009f4:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009f8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8009fa:	eb b9                	jmp    8009b5 <strtol+0x76>

	if (endptr)
  8009fc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a00:	74 0d                	je     800a0f <strtol+0xd0>
		*endptr = (char *) s;
  800a02:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a05:	89 0e                	mov    %ecx,(%esi)
  800a07:	eb 06                	jmp    800a0f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a09:	85 db                	test   %ebx,%ebx
  800a0b:	74 98                	je     8009a5 <strtol+0x66>
  800a0d:	eb 9e                	jmp    8009ad <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a0f:	89 c2                	mov    %eax,%edx
  800a11:	f7 da                	neg    %edx
  800a13:	85 ff                	test   %edi,%edi
  800a15:	0f 45 c2             	cmovne %edx,%eax
}
  800a18:	5b                   	pop    %ebx
  800a19:	5e                   	pop    %esi
  800a1a:	5f                   	pop    %edi
  800a1b:	5d                   	pop    %ebp
  800a1c:	c3                   	ret    

00800a1d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	57                   	push   %edi
  800a21:	56                   	push   %esi
  800a22:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a23:	b8 00 00 00 00       	mov    $0x0,%eax
  800a28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a2e:	89 c3                	mov    %eax,%ebx
  800a30:	89 c7                	mov    %eax,%edi
  800a32:	89 c6                	mov    %eax,%esi
  800a34:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a36:	5b                   	pop    %ebx
  800a37:	5e                   	pop    %esi
  800a38:	5f                   	pop    %edi
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <sys_cgetc>:

int
sys_cgetc(void)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	57                   	push   %edi
  800a3f:	56                   	push   %esi
  800a40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a41:	ba 00 00 00 00       	mov    $0x0,%edx
  800a46:	b8 01 00 00 00       	mov    $0x1,%eax
  800a4b:	89 d1                	mov    %edx,%ecx
  800a4d:	89 d3                	mov    %edx,%ebx
  800a4f:	89 d7                	mov    %edx,%edi
  800a51:	89 d6                	mov    %edx,%esi
  800a53:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a55:	5b                   	pop    %ebx
  800a56:	5e                   	pop    %esi
  800a57:	5f                   	pop    %edi
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	57                   	push   %edi
  800a5e:	56                   	push   %esi
  800a5f:	53                   	push   %ebx
  800a60:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a63:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a68:	b8 03 00 00 00       	mov    $0x3,%eax
  800a6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a70:	89 cb                	mov    %ecx,%ebx
  800a72:	89 cf                	mov    %ecx,%edi
  800a74:	89 ce                	mov    %ecx,%esi
  800a76:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a78:	85 c0                	test   %eax,%eax
  800a7a:	7e 17                	jle    800a93 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a7c:	83 ec 0c             	sub    $0xc,%esp
  800a7f:	50                   	push   %eax
  800a80:	6a 03                	push   $0x3
  800a82:	68 ff 25 80 00       	push   $0x8025ff
  800a87:	6a 23                	push   $0x23
  800a89:	68 1c 26 80 00       	push   $0x80261c
  800a8e:	e8 1e 14 00 00       	call   801eb1 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a96:	5b                   	pop    %ebx
  800a97:	5e                   	pop    %esi
  800a98:	5f                   	pop    %edi
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	57                   	push   %edi
  800a9f:	56                   	push   %esi
  800aa0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa1:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa6:	b8 02 00 00 00       	mov    $0x2,%eax
  800aab:	89 d1                	mov    %edx,%ecx
  800aad:	89 d3                	mov    %edx,%ebx
  800aaf:	89 d7                	mov    %edx,%edi
  800ab1:	89 d6                	mov    %edx,%esi
  800ab3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ab5:	5b                   	pop    %ebx
  800ab6:	5e                   	pop    %esi
  800ab7:	5f                   	pop    %edi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <sys_yield>:

void
sys_yield(void)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	57                   	push   %edi
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800aca:	89 d1                	mov    %edx,%ecx
  800acc:	89 d3                	mov    %edx,%ebx
  800ace:	89 d7                	mov    %edx,%edi
  800ad0:	89 d6                	mov    %edx,%esi
  800ad2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ad4:	5b                   	pop    %ebx
  800ad5:	5e                   	pop    %esi
  800ad6:	5f                   	pop    %edi
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	57                   	push   %edi
  800add:	56                   	push   %esi
  800ade:	53                   	push   %ebx
  800adf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae2:	be 00 00 00 00       	mov    $0x0,%esi
  800ae7:	b8 04 00 00 00       	mov    $0x4,%eax
  800aec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aef:	8b 55 08             	mov    0x8(%ebp),%edx
  800af2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800af5:	89 f7                	mov    %esi,%edi
  800af7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800af9:	85 c0                	test   %eax,%eax
  800afb:	7e 17                	jle    800b14 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800afd:	83 ec 0c             	sub    $0xc,%esp
  800b00:	50                   	push   %eax
  800b01:	6a 04                	push   $0x4
  800b03:	68 ff 25 80 00       	push   $0x8025ff
  800b08:	6a 23                	push   $0x23
  800b0a:	68 1c 26 80 00       	push   $0x80261c
  800b0f:	e8 9d 13 00 00       	call   801eb1 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b17:	5b                   	pop    %ebx
  800b18:	5e                   	pop    %esi
  800b19:	5f                   	pop    %edi
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
  800b22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b25:	b8 05 00 00 00       	mov    $0x5,%eax
  800b2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b33:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b36:	8b 75 18             	mov    0x18(%ebp),%esi
  800b39:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b3b:	85 c0                	test   %eax,%eax
  800b3d:	7e 17                	jle    800b56 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3f:	83 ec 0c             	sub    $0xc,%esp
  800b42:	50                   	push   %eax
  800b43:	6a 05                	push   $0x5
  800b45:	68 ff 25 80 00       	push   $0x8025ff
  800b4a:	6a 23                	push   $0x23
  800b4c:	68 1c 26 80 00       	push   $0x80261c
  800b51:	e8 5b 13 00 00       	call   801eb1 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
  800b64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b6c:	b8 06 00 00 00       	mov    $0x6,%eax
  800b71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b74:	8b 55 08             	mov    0x8(%ebp),%edx
  800b77:	89 df                	mov    %ebx,%edi
  800b79:	89 de                	mov    %ebx,%esi
  800b7b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b7d:	85 c0                	test   %eax,%eax
  800b7f:	7e 17                	jle    800b98 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b81:	83 ec 0c             	sub    $0xc,%esp
  800b84:	50                   	push   %eax
  800b85:	6a 06                	push   $0x6
  800b87:	68 ff 25 80 00       	push   $0x8025ff
  800b8c:	6a 23                	push   $0x23
  800b8e:	68 1c 26 80 00       	push   $0x80261c
  800b93:	e8 19 13 00 00       	call   801eb1 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9b:	5b                   	pop    %ebx
  800b9c:	5e                   	pop    %esi
  800b9d:	5f                   	pop    %edi
  800b9e:	5d                   	pop    %ebp
  800b9f:	c3                   	ret    

00800ba0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	57                   	push   %edi
  800ba4:	56                   	push   %esi
  800ba5:	53                   	push   %ebx
  800ba6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bae:	b8 08 00 00 00       	mov    $0x8,%eax
  800bb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb9:	89 df                	mov    %ebx,%edi
  800bbb:	89 de                	mov    %ebx,%esi
  800bbd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bbf:	85 c0                	test   %eax,%eax
  800bc1:	7e 17                	jle    800bda <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc3:	83 ec 0c             	sub    $0xc,%esp
  800bc6:	50                   	push   %eax
  800bc7:	6a 08                	push   $0x8
  800bc9:	68 ff 25 80 00       	push   $0x8025ff
  800bce:	6a 23                	push   $0x23
  800bd0:	68 1c 26 80 00       	push   $0x80261c
  800bd5:	e8 d7 12 00 00       	call   801eb1 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
  800be8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800beb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf0:	b8 09 00 00 00       	mov    $0x9,%eax
  800bf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfb:	89 df                	mov    %ebx,%edi
  800bfd:	89 de                	mov    %ebx,%esi
  800bff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c01:	85 c0                	test   %eax,%eax
  800c03:	7e 17                	jle    800c1c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c05:	83 ec 0c             	sub    $0xc,%esp
  800c08:	50                   	push   %eax
  800c09:	6a 09                	push   $0x9
  800c0b:	68 ff 25 80 00       	push   $0x8025ff
  800c10:	6a 23                	push   $0x23
  800c12:	68 1c 26 80 00       	push   $0x80261c
  800c17:	e8 95 12 00 00       	call   801eb1 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1f:	5b                   	pop    %ebx
  800c20:	5e                   	pop    %esi
  800c21:	5f                   	pop    %edi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	57                   	push   %edi
  800c28:	56                   	push   %esi
  800c29:	53                   	push   %ebx
  800c2a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c32:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3d:	89 df                	mov    %ebx,%edi
  800c3f:	89 de                	mov    %ebx,%esi
  800c41:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c43:	85 c0                	test   %eax,%eax
  800c45:	7e 17                	jle    800c5e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c47:	83 ec 0c             	sub    $0xc,%esp
  800c4a:	50                   	push   %eax
  800c4b:	6a 0a                	push   $0xa
  800c4d:	68 ff 25 80 00       	push   $0x8025ff
  800c52:	6a 23                	push   $0x23
  800c54:	68 1c 26 80 00       	push   $0x80261c
  800c59:	e8 53 12 00 00       	call   801eb1 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c61:	5b                   	pop    %ebx
  800c62:	5e                   	pop    %esi
  800c63:	5f                   	pop    %edi
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    

00800c66 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	57                   	push   %edi
  800c6a:	56                   	push   %esi
  800c6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6c:	be 00 00 00 00       	mov    $0x0,%esi
  800c71:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c79:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c7f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c82:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c92:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c97:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9f:	89 cb                	mov    %ecx,%ebx
  800ca1:	89 cf                	mov    %ecx,%edi
  800ca3:	89 ce                	mov    %ecx,%esi
  800ca5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca7:	85 c0                	test   %eax,%eax
  800ca9:	7e 17                	jle    800cc2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cab:	83 ec 0c             	sub    $0xc,%esp
  800cae:	50                   	push   %eax
  800caf:	6a 0d                	push   $0xd
  800cb1:	68 ff 25 80 00       	push   $0x8025ff
  800cb6:	6a 23                	push   $0x23
  800cb8:	68 1c 26 80 00       	push   $0x80261c
  800cbd:	e8 ef 11 00 00       	call   801eb1 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	57                   	push   %edi
  800cce:	56                   	push   %esi
  800ccf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd5:	b8 0e 00 00 00       	mov    $0xe,%eax
  800cda:	89 d1                	mov    %edx,%ecx
  800cdc:	89 d3                	mov    %edx,%ebx
  800cde:	89 d7                	mov    %edx,%edi
  800ce0:	89 d6                	mov    %edx,%esi
  800ce2:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	57                   	push   %edi
  800ced:	56                   	push   %esi
  800cee:	53                   	push   %ebx
  800cef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf7:	b8 0f 00 00 00       	mov    $0xf,%eax
  800cfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cff:	8b 55 08             	mov    0x8(%ebp),%edx
  800d02:	89 df                	mov    %ebx,%edi
  800d04:	89 de                	mov    %ebx,%esi
  800d06:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d08:	85 c0                	test   %eax,%eax
  800d0a:	7e 17                	jle    800d23 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0c:	83 ec 0c             	sub    $0xc,%esp
  800d0f:	50                   	push   %eax
  800d10:	6a 0f                	push   $0xf
  800d12:	68 ff 25 80 00       	push   $0x8025ff
  800d17:	6a 23                	push   $0x23
  800d19:	68 1c 26 80 00       	push   $0x80261c
  800d1e:	e8 8e 11 00 00       	call   801eb1 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800d23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d26:	5b                   	pop    %ebx
  800d27:	5e                   	pop    %esi
  800d28:	5f                   	pop    %edi
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    

00800d2b <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	57                   	push   %edi
  800d2f:	56                   	push   %esi
  800d30:	53                   	push   %ebx
  800d31:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d34:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d39:	b8 10 00 00 00       	mov    $0x10,%eax
  800d3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d41:	8b 55 08             	mov    0x8(%ebp),%edx
  800d44:	89 df                	mov    %ebx,%edi
  800d46:	89 de                	mov    %ebx,%esi
  800d48:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d4a:	85 c0                	test   %eax,%eax
  800d4c:	7e 17                	jle    800d65 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4e:	83 ec 0c             	sub    $0xc,%esp
  800d51:	50                   	push   %eax
  800d52:	6a 10                	push   $0x10
  800d54:	68 ff 25 80 00       	push   $0x8025ff
  800d59:	6a 23                	push   $0x23
  800d5b:	68 1c 26 80 00       	push   $0x80261c
  800d60:	e8 4c 11 00 00       	call   801eb1 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  800d65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d68:	5b                   	pop    %ebx
  800d69:	5e                   	pop    %esi
  800d6a:	5f                   	pop    %edi
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d70:	8b 45 08             	mov    0x8(%ebp),%eax
  800d73:	05 00 00 00 30       	add    $0x30000000,%eax
  800d78:	c1 e8 0c             	shr    $0xc,%eax
}
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d80:	8b 45 08             	mov    0x8(%ebp),%eax
  800d83:	05 00 00 00 30       	add    $0x30000000,%eax
  800d88:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d8d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    

00800d94 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d9a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d9f:	89 c2                	mov    %eax,%edx
  800da1:	c1 ea 16             	shr    $0x16,%edx
  800da4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dab:	f6 c2 01             	test   $0x1,%dl
  800dae:	74 11                	je     800dc1 <fd_alloc+0x2d>
  800db0:	89 c2                	mov    %eax,%edx
  800db2:	c1 ea 0c             	shr    $0xc,%edx
  800db5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dbc:	f6 c2 01             	test   $0x1,%dl
  800dbf:	75 09                	jne    800dca <fd_alloc+0x36>
			*fd_store = fd;
  800dc1:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dc3:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc8:	eb 17                	jmp    800de1 <fd_alloc+0x4d>
  800dca:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dcf:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dd4:	75 c9                	jne    800d9f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dd6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ddc:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800de1:	5d                   	pop    %ebp
  800de2:	c3                   	ret    

00800de3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800de3:	55                   	push   %ebp
  800de4:	89 e5                	mov    %esp,%ebp
  800de6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800de9:	83 f8 1f             	cmp    $0x1f,%eax
  800dec:	77 36                	ja     800e24 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dee:	c1 e0 0c             	shl    $0xc,%eax
  800df1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800df6:	89 c2                	mov    %eax,%edx
  800df8:	c1 ea 16             	shr    $0x16,%edx
  800dfb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e02:	f6 c2 01             	test   $0x1,%dl
  800e05:	74 24                	je     800e2b <fd_lookup+0x48>
  800e07:	89 c2                	mov    %eax,%edx
  800e09:	c1 ea 0c             	shr    $0xc,%edx
  800e0c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e13:	f6 c2 01             	test   $0x1,%dl
  800e16:	74 1a                	je     800e32 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e18:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e1b:	89 02                	mov    %eax,(%edx)
	return 0;
  800e1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e22:	eb 13                	jmp    800e37 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e24:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e29:	eb 0c                	jmp    800e37 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e2b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e30:	eb 05                	jmp    800e37 <fd_lookup+0x54>
  800e32:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e37:	5d                   	pop    %ebp
  800e38:	c3                   	ret    

00800e39 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e39:	55                   	push   %ebp
  800e3a:	89 e5                	mov    %esp,%ebp
  800e3c:	83 ec 08             	sub    $0x8,%esp
  800e3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e42:	ba a8 26 80 00       	mov    $0x8026a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e47:	eb 13                	jmp    800e5c <dev_lookup+0x23>
  800e49:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e4c:	39 08                	cmp    %ecx,(%eax)
  800e4e:	75 0c                	jne    800e5c <dev_lookup+0x23>
			*dev = devtab[i];
  800e50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e53:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e55:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5a:	eb 2e                	jmp    800e8a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e5c:	8b 02                	mov    (%edx),%eax
  800e5e:	85 c0                	test   %eax,%eax
  800e60:	75 e7                	jne    800e49 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e62:	a1 08 40 80 00       	mov    0x804008,%eax
  800e67:	8b 40 48             	mov    0x48(%eax),%eax
  800e6a:	83 ec 04             	sub    $0x4,%esp
  800e6d:	51                   	push   %ecx
  800e6e:	50                   	push   %eax
  800e6f:	68 2c 26 80 00       	push   $0x80262c
  800e74:	e8 d8 f2 ff ff       	call   800151 <cprintf>
	*dev = 0;
  800e79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e82:	83 c4 10             	add    $0x10,%esp
  800e85:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e8a:	c9                   	leave  
  800e8b:	c3                   	ret    

00800e8c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	56                   	push   %esi
  800e90:	53                   	push   %ebx
  800e91:	83 ec 10             	sub    $0x10,%esp
  800e94:	8b 75 08             	mov    0x8(%ebp),%esi
  800e97:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e9d:	50                   	push   %eax
  800e9e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ea4:	c1 e8 0c             	shr    $0xc,%eax
  800ea7:	50                   	push   %eax
  800ea8:	e8 36 ff ff ff       	call   800de3 <fd_lookup>
  800ead:	83 c4 08             	add    $0x8,%esp
  800eb0:	85 c0                	test   %eax,%eax
  800eb2:	78 05                	js     800eb9 <fd_close+0x2d>
	    || fd != fd2)
  800eb4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800eb7:	74 0c                	je     800ec5 <fd_close+0x39>
		return (must_exist ? r : 0);
  800eb9:	84 db                	test   %bl,%bl
  800ebb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec0:	0f 44 c2             	cmove  %edx,%eax
  800ec3:	eb 41                	jmp    800f06 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ec5:	83 ec 08             	sub    $0x8,%esp
  800ec8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ecb:	50                   	push   %eax
  800ecc:	ff 36                	pushl  (%esi)
  800ece:	e8 66 ff ff ff       	call   800e39 <dev_lookup>
  800ed3:	89 c3                	mov    %eax,%ebx
  800ed5:	83 c4 10             	add    $0x10,%esp
  800ed8:	85 c0                	test   %eax,%eax
  800eda:	78 1a                	js     800ef6 <fd_close+0x6a>
		if (dev->dev_close)
  800edc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800edf:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ee2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ee7:	85 c0                	test   %eax,%eax
  800ee9:	74 0b                	je     800ef6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800eeb:	83 ec 0c             	sub    $0xc,%esp
  800eee:	56                   	push   %esi
  800eef:	ff d0                	call   *%eax
  800ef1:	89 c3                	mov    %eax,%ebx
  800ef3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ef6:	83 ec 08             	sub    $0x8,%esp
  800ef9:	56                   	push   %esi
  800efa:	6a 00                	push   $0x0
  800efc:	e8 5d fc ff ff       	call   800b5e <sys_page_unmap>
	return r;
  800f01:	83 c4 10             	add    $0x10,%esp
  800f04:	89 d8                	mov    %ebx,%eax
}
  800f06:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f09:	5b                   	pop    %ebx
  800f0a:	5e                   	pop    %esi
  800f0b:	5d                   	pop    %ebp
  800f0c:	c3                   	ret    

00800f0d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f16:	50                   	push   %eax
  800f17:	ff 75 08             	pushl  0x8(%ebp)
  800f1a:	e8 c4 fe ff ff       	call   800de3 <fd_lookup>
  800f1f:	83 c4 08             	add    $0x8,%esp
  800f22:	85 c0                	test   %eax,%eax
  800f24:	78 10                	js     800f36 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f26:	83 ec 08             	sub    $0x8,%esp
  800f29:	6a 01                	push   $0x1
  800f2b:	ff 75 f4             	pushl  -0xc(%ebp)
  800f2e:	e8 59 ff ff ff       	call   800e8c <fd_close>
  800f33:	83 c4 10             	add    $0x10,%esp
}
  800f36:	c9                   	leave  
  800f37:	c3                   	ret    

00800f38 <close_all>:

void
close_all(void)
{
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
  800f3b:	53                   	push   %ebx
  800f3c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f3f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f44:	83 ec 0c             	sub    $0xc,%esp
  800f47:	53                   	push   %ebx
  800f48:	e8 c0 ff ff ff       	call   800f0d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f4d:	83 c3 01             	add    $0x1,%ebx
  800f50:	83 c4 10             	add    $0x10,%esp
  800f53:	83 fb 20             	cmp    $0x20,%ebx
  800f56:	75 ec                	jne    800f44 <close_all+0xc>
		close(i);
}
  800f58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f5b:	c9                   	leave  
  800f5c:	c3                   	ret    

00800f5d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f5d:	55                   	push   %ebp
  800f5e:	89 e5                	mov    %esp,%ebp
  800f60:	57                   	push   %edi
  800f61:	56                   	push   %esi
  800f62:	53                   	push   %ebx
  800f63:	83 ec 2c             	sub    $0x2c,%esp
  800f66:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f69:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f6c:	50                   	push   %eax
  800f6d:	ff 75 08             	pushl  0x8(%ebp)
  800f70:	e8 6e fe ff ff       	call   800de3 <fd_lookup>
  800f75:	83 c4 08             	add    $0x8,%esp
  800f78:	85 c0                	test   %eax,%eax
  800f7a:	0f 88 c1 00 00 00    	js     801041 <dup+0xe4>
		return r;
	close(newfdnum);
  800f80:	83 ec 0c             	sub    $0xc,%esp
  800f83:	56                   	push   %esi
  800f84:	e8 84 ff ff ff       	call   800f0d <close>

	newfd = INDEX2FD(newfdnum);
  800f89:	89 f3                	mov    %esi,%ebx
  800f8b:	c1 e3 0c             	shl    $0xc,%ebx
  800f8e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f94:	83 c4 04             	add    $0x4,%esp
  800f97:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f9a:	e8 de fd ff ff       	call   800d7d <fd2data>
  800f9f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fa1:	89 1c 24             	mov    %ebx,(%esp)
  800fa4:	e8 d4 fd ff ff       	call   800d7d <fd2data>
  800fa9:	83 c4 10             	add    $0x10,%esp
  800fac:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800faf:	89 f8                	mov    %edi,%eax
  800fb1:	c1 e8 16             	shr    $0x16,%eax
  800fb4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fbb:	a8 01                	test   $0x1,%al
  800fbd:	74 37                	je     800ff6 <dup+0x99>
  800fbf:	89 f8                	mov    %edi,%eax
  800fc1:	c1 e8 0c             	shr    $0xc,%eax
  800fc4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fcb:	f6 c2 01             	test   $0x1,%dl
  800fce:	74 26                	je     800ff6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fd0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fd7:	83 ec 0c             	sub    $0xc,%esp
  800fda:	25 07 0e 00 00       	and    $0xe07,%eax
  800fdf:	50                   	push   %eax
  800fe0:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fe3:	6a 00                	push   $0x0
  800fe5:	57                   	push   %edi
  800fe6:	6a 00                	push   $0x0
  800fe8:	e8 2f fb ff ff       	call   800b1c <sys_page_map>
  800fed:	89 c7                	mov    %eax,%edi
  800fef:	83 c4 20             	add    $0x20,%esp
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	78 2e                	js     801024 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800ff6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ff9:	89 d0                	mov    %edx,%eax
  800ffb:	c1 e8 0c             	shr    $0xc,%eax
  800ffe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801005:	83 ec 0c             	sub    $0xc,%esp
  801008:	25 07 0e 00 00       	and    $0xe07,%eax
  80100d:	50                   	push   %eax
  80100e:	53                   	push   %ebx
  80100f:	6a 00                	push   $0x0
  801011:	52                   	push   %edx
  801012:	6a 00                	push   $0x0
  801014:	e8 03 fb ff ff       	call   800b1c <sys_page_map>
  801019:	89 c7                	mov    %eax,%edi
  80101b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80101e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801020:	85 ff                	test   %edi,%edi
  801022:	79 1d                	jns    801041 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801024:	83 ec 08             	sub    $0x8,%esp
  801027:	53                   	push   %ebx
  801028:	6a 00                	push   $0x0
  80102a:	e8 2f fb ff ff       	call   800b5e <sys_page_unmap>
	sys_page_unmap(0, nva);
  80102f:	83 c4 08             	add    $0x8,%esp
  801032:	ff 75 d4             	pushl  -0x2c(%ebp)
  801035:	6a 00                	push   $0x0
  801037:	e8 22 fb ff ff       	call   800b5e <sys_page_unmap>
	return r;
  80103c:	83 c4 10             	add    $0x10,%esp
  80103f:	89 f8                	mov    %edi,%eax
}
  801041:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801044:	5b                   	pop    %ebx
  801045:	5e                   	pop    %esi
  801046:	5f                   	pop    %edi
  801047:	5d                   	pop    %ebp
  801048:	c3                   	ret    

00801049 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801049:	55                   	push   %ebp
  80104a:	89 e5                	mov    %esp,%ebp
  80104c:	53                   	push   %ebx
  80104d:	83 ec 14             	sub    $0x14,%esp
  801050:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801053:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801056:	50                   	push   %eax
  801057:	53                   	push   %ebx
  801058:	e8 86 fd ff ff       	call   800de3 <fd_lookup>
  80105d:	83 c4 08             	add    $0x8,%esp
  801060:	89 c2                	mov    %eax,%edx
  801062:	85 c0                	test   %eax,%eax
  801064:	78 6d                	js     8010d3 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801066:	83 ec 08             	sub    $0x8,%esp
  801069:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80106c:	50                   	push   %eax
  80106d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801070:	ff 30                	pushl  (%eax)
  801072:	e8 c2 fd ff ff       	call   800e39 <dev_lookup>
  801077:	83 c4 10             	add    $0x10,%esp
  80107a:	85 c0                	test   %eax,%eax
  80107c:	78 4c                	js     8010ca <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80107e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801081:	8b 42 08             	mov    0x8(%edx),%eax
  801084:	83 e0 03             	and    $0x3,%eax
  801087:	83 f8 01             	cmp    $0x1,%eax
  80108a:	75 21                	jne    8010ad <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80108c:	a1 08 40 80 00       	mov    0x804008,%eax
  801091:	8b 40 48             	mov    0x48(%eax),%eax
  801094:	83 ec 04             	sub    $0x4,%esp
  801097:	53                   	push   %ebx
  801098:	50                   	push   %eax
  801099:	68 6d 26 80 00       	push   $0x80266d
  80109e:	e8 ae f0 ff ff       	call   800151 <cprintf>
		return -E_INVAL;
  8010a3:	83 c4 10             	add    $0x10,%esp
  8010a6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010ab:	eb 26                	jmp    8010d3 <read+0x8a>
	}
	if (!dev->dev_read)
  8010ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010b0:	8b 40 08             	mov    0x8(%eax),%eax
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	74 17                	je     8010ce <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010b7:	83 ec 04             	sub    $0x4,%esp
  8010ba:	ff 75 10             	pushl  0x10(%ebp)
  8010bd:	ff 75 0c             	pushl  0xc(%ebp)
  8010c0:	52                   	push   %edx
  8010c1:	ff d0                	call   *%eax
  8010c3:	89 c2                	mov    %eax,%edx
  8010c5:	83 c4 10             	add    $0x10,%esp
  8010c8:	eb 09                	jmp    8010d3 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010ca:	89 c2                	mov    %eax,%edx
  8010cc:	eb 05                	jmp    8010d3 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010ce:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010d3:	89 d0                	mov    %edx,%eax
  8010d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d8:	c9                   	leave  
  8010d9:	c3                   	ret    

008010da <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010da:	55                   	push   %ebp
  8010db:	89 e5                	mov    %esp,%ebp
  8010dd:	57                   	push   %edi
  8010de:	56                   	push   %esi
  8010df:	53                   	push   %ebx
  8010e0:	83 ec 0c             	sub    $0xc,%esp
  8010e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010e6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ee:	eb 21                	jmp    801111 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010f0:	83 ec 04             	sub    $0x4,%esp
  8010f3:	89 f0                	mov    %esi,%eax
  8010f5:	29 d8                	sub    %ebx,%eax
  8010f7:	50                   	push   %eax
  8010f8:	89 d8                	mov    %ebx,%eax
  8010fa:	03 45 0c             	add    0xc(%ebp),%eax
  8010fd:	50                   	push   %eax
  8010fe:	57                   	push   %edi
  8010ff:	e8 45 ff ff ff       	call   801049 <read>
		if (m < 0)
  801104:	83 c4 10             	add    $0x10,%esp
  801107:	85 c0                	test   %eax,%eax
  801109:	78 10                	js     80111b <readn+0x41>
			return m;
		if (m == 0)
  80110b:	85 c0                	test   %eax,%eax
  80110d:	74 0a                	je     801119 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80110f:	01 c3                	add    %eax,%ebx
  801111:	39 f3                	cmp    %esi,%ebx
  801113:	72 db                	jb     8010f0 <readn+0x16>
  801115:	89 d8                	mov    %ebx,%eax
  801117:	eb 02                	jmp    80111b <readn+0x41>
  801119:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80111b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111e:	5b                   	pop    %ebx
  80111f:	5e                   	pop    %esi
  801120:	5f                   	pop    %edi
  801121:	5d                   	pop    %ebp
  801122:	c3                   	ret    

00801123 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801123:	55                   	push   %ebp
  801124:	89 e5                	mov    %esp,%ebp
  801126:	53                   	push   %ebx
  801127:	83 ec 14             	sub    $0x14,%esp
  80112a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80112d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801130:	50                   	push   %eax
  801131:	53                   	push   %ebx
  801132:	e8 ac fc ff ff       	call   800de3 <fd_lookup>
  801137:	83 c4 08             	add    $0x8,%esp
  80113a:	89 c2                	mov    %eax,%edx
  80113c:	85 c0                	test   %eax,%eax
  80113e:	78 68                	js     8011a8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801140:	83 ec 08             	sub    $0x8,%esp
  801143:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801146:	50                   	push   %eax
  801147:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80114a:	ff 30                	pushl  (%eax)
  80114c:	e8 e8 fc ff ff       	call   800e39 <dev_lookup>
  801151:	83 c4 10             	add    $0x10,%esp
  801154:	85 c0                	test   %eax,%eax
  801156:	78 47                	js     80119f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801158:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80115b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80115f:	75 21                	jne    801182 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801161:	a1 08 40 80 00       	mov    0x804008,%eax
  801166:	8b 40 48             	mov    0x48(%eax),%eax
  801169:	83 ec 04             	sub    $0x4,%esp
  80116c:	53                   	push   %ebx
  80116d:	50                   	push   %eax
  80116e:	68 89 26 80 00       	push   $0x802689
  801173:	e8 d9 ef ff ff       	call   800151 <cprintf>
		return -E_INVAL;
  801178:	83 c4 10             	add    $0x10,%esp
  80117b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801180:	eb 26                	jmp    8011a8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801182:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801185:	8b 52 0c             	mov    0xc(%edx),%edx
  801188:	85 d2                	test   %edx,%edx
  80118a:	74 17                	je     8011a3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80118c:	83 ec 04             	sub    $0x4,%esp
  80118f:	ff 75 10             	pushl  0x10(%ebp)
  801192:	ff 75 0c             	pushl  0xc(%ebp)
  801195:	50                   	push   %eax
  801196:	ff d2                	call   *%edx
  801198:	89 c2                	mov    %eax,%edx
  80119a:	83 c4 10             	add    $0x10,%esp
  80119d:	eb 09                	jmp    8011a8 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80119f:	89 c2                	mov    %eax,%edx
  8011a1:	eb 05                	jmp    8011a8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011a3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011a8:	89 d0                	mov    %edx,%eax
  8011aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ad:	c9                   	leave  
  8011ae:	c3                   	ret    

008011af <seek>:

int
seek(int fdnum, off_t offset)
{
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011b5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011b8:	50                   	push   %eax
  8011b9:	ff 75 08             	pushl  0x8(%ebp)
  8011bc:	e8 22 fc ff ff       	call   800de3 <fd_lookup>
  8011c1:	83 c4 08             	add    $0x8,%esp
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	78 0e                	js     8011d6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ce:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011d6:	c9                   	leave  
  8011d7:	c3                   	ret    

008011d8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	53                   	push   %ebx
  8011dc:	83 ec 14             	sub    $0x14,%esp
  8011df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e5:	50                   	push   %eax
  8011e6:	53                   	push   %ebx
  8011e7:	e8 f7 fb ff ff       	call   800de3 <fd_lookup>
  8011ec:	83 c4 08             	add    $0x8,%esp
  8011ef:	89 c2                	mov    %eax,%edx
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	78 65                	js     80125a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f5:	83 ec 08             	sub    $0x8,%esp
  8011f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fb:	50                   	push   %eax
  8011fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ff:	ff 30                	pushl  (%eax)
  801201:	e8 33 fc ff ff       	call   800e39 <dev_lookup>
  801206:	83 c4 10             	add    $0x10,%esp
  801209:	85 c0                	test   %eax,%eax
  80120b:	78 44                	js     801251 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80120d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801210:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801214:	75 21                	jne    801237 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801216:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80121b:	8b 40 48             	mov    0x48(%eax),%eax
  80121e:	83 ec 04             	sub    $0x4,%esp
  801221:	53                   	push   %ebx
  801222:	50                   	push   %eax
  801223:	68 4c 26 80 00       	push   $0x80264c
  801228:	e8 24 ef ff ff       	call   800151 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80122d:	83 c4 10             	add    $0x10,%esp
  801230:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801235:	eb 23                	jmp    80125a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801237:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80123a:	8b 52 18             	mov    0x18(%edx),%edx
  80123d:	85 d2                	test   %edx,%edx
  80123f:	74 14                	je     801255 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801241:	83 ec 08             	sub    $0x8,%esp
  801244:	ff 75 0c             	pushl  0xc(%ebp)
  801247:	50                   	push   %eax
  801248:	ff d2                	call   *%edx
  80124a:	89 c2                	mov    %eax,%edx
  80124c:	83 c4 10             	add    $0x10,%esp
  80124f:	eb 09                	jmp    80125a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801251:	89 c2                	mov    %eax,%edx
  801253:	eb 05                	jmp    80125a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801255:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80125a:	89 d0                	mov    %edx,%eax
  80125c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80125f:	c9                   	leave  
  801260:	c3                   	ret    

00801261 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801261:	55                   	push   %ebp
  801262:	89 e5                	mov    %esp,%ebp
  801264:	53                   	push   %ebx
  801265:	83 ec 14             	sub    $0x14,%esp
  801268:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80126b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80126e:	50                   	push   %eax
  80126f:	ff 75 08             	pushl  0x8(%ebp)
  801272:	e8 6c fb ff ff       	call   800de3 <fd_lookup>
  801277:	83 c4 08             	add    $0x8,%esp
  80127a:	89 c2                	mov    %eax,%edx
  80127c:	85 c0                	test   %eax,%eax
  80127e:	78 58                	js     8012d8 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801280:	83 ec 08             	sub    $0x8,%esp
  801283:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801286:	50                   	push   %eax
  801287:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128a:	ff 30                	pushl  (%eax)
  80128c:	e8 a8 fb ff ff       	call   800e39 <dev_lookup>
  801291:	83 c4 10             	add    $0x10,%esp
  801294:	85 c0                	test   %eax,%eax
  801296:	78 37                	js     8012cf <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801298:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80129b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80129f:	74 32                	je     8012d3 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012a1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012a4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012ab:	00 00 00 
	stat->st_isdir = 0;
  8012ae:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012b5:	00 00 00 
	stat->st_dev = dev;
  8012b8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012be:	83 ec 08             	sub    $0x8,%esp
  8012c1:	53                   	push   %ebx
  8012c2:	ff 75 f0             	pushl  -0x10(%ebp)
  8012c5:	ff 50 14             	call   *0x14(%eax)
  8012c8:	89 c2                	mov    %eax,%edx
  8012ca:	83 c4 10             	add    $0x10,%esp
  8012cd:	eb 09                	jmp    8012d8 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012cf:	89 c2                	mov    %eax,%edx
  8012d1:	eb 05                	jmp    8012d8 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012d3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012d8:	89 d0                	mov    %edx,%eax
  8012da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012dd:	c9                   	leave  
  8012de:	c3                   	ret    

008012df <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012df:	55                   	push   %ebp
  8012e0:	89 e5                	mov    %esp,%ebp
  8012e2:	56                   	push   %esi
  8012e3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012e4:	83 ec 08             	sub    $0x8,%esp
  8012e7:	6a 00                	push   $0x0
  8012e9:	ff 75 08             	pushl  0x8(%ebp)
  8012ec:	e8 d6 01 00 00       	call   8014c7 <open>
  8012f1:	89 c3                	mov    %eax,%ebx
  8012f3:	83 c4 10             	add    $0x10,%esp
  8012f6:	85 c0                	test   %eax,%eax
  8012f8:	78 1b                	js     801315 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012fa:	83 ec 08             	sub    $0x8,%esp
  8012fd:	ff 75 0c             	pushl  0xc(%ebp)
  801300:	50                   	push   %eax
  801301:	e8 5b ff ff ff       	call   801261 <fstat>
  801306:	89 c6                	mov    %eax,%esi
	close(fd);
  801308:	89 1c 24             	mov    %ebx,(%esp)
  80130b:	e8 fd fb ff ff       	call   800f0d <close>
	return r;
  801310:	83 c4 10             	add    $0x10,%esp
  801313:	89 f0                	mov    %esi,%eax
}
  801315:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801318:	5b                   	pop    %ebx
  801319:	5e                   	pop    %esi
  80131a:	5d                   	pop    %ebp
  80131b:	c3                   	ret    

0080131c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
  80131f:	56                   	push   %esi
  801320:	53                   	push   %ebx
  801321:	89 c6                	mov    %eax,%esi
  801323:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801325:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80132c:	75 12                	jne    801340 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80132e:	83 ec 0c             	sub    $0xc,%esp
  801331:	6a 01                	push   $0x1
  801333:	e8 7a 0c 00 00       	call   801fb2 <ipc_find_env>
  801338:	a3 00 40 80 00       	mov    %eax,0x804000
  80133d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801340:	6a 07                	push   $0x7
  801342:	68 00 50 80 00       	push   $0x805000
  801347:	56                   	push   %esi
  801348:	ff 35 00 40 80 00    	pushl  0x804000
  80134e:	e8 0b 0c 00 00       	call   801f5e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801353:	83 c4 0c             	add    $0xc,%esp
  801356:	6a 00                	push   $0x0
  801358:	53                   	push   %ebx
  801359:	6a 00                	push   $0x0
  80135b:	e8 97 0b 00 00       	call   801ef7 <ipc_recv>
}
  801360:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801363:	5b                   	pop    %ebx
  801364:	5e                   	pop    %esi
  801365:	5d                   	pop    %ebp
  801366:	c3                   	ret    

00801367 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801367:	55                   	push   %ebp
  801368:	89 e5                	mov    %esp,%ebp
  80136a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80136d:	8b 45 08             	mov    0x8(%ebp),%eax
  801370:	8b 40 0c             	mov    0xc(%eax),%eax
  801373:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801378:	8b 45 0c             	mov    0xc(%ebp),%eax
  80137b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801380:	ba 00 00 00 00       	mov    $0x0,%edx
  801385:	b8 02 00 00 00       	mov    $0x2,%eax
  80138a:	e8 8d ff ff ff       	call   80131c <fsipc>
}
  80138f:	c9                   	leave  
  801390:	c3                   	ret    

00801391 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801391:	55                   	push   %ebp
  801392:	89 e5                	mov    %esp,%ebp
  801394:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801397:	8b 45 08             	mov    0x8(%ebp),%eax
  80139a:	8b 40 0c             	mov    0xc(%eax),%eax
  80139d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a7:	b8 06 00 00 00       	mov    $0x6,%eax
  8013ac:	e8 6b ff ff ff       	call   80131c <fsipc>
}
  8013b1:	c9                   	leave  
  8013b2:	c3                   	ret    

008013b3 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013b3:	55                   	push   %ebp
  8013b4:	89 e5                	mov    %esp,%ebp
  8013b6:	53                   	push   %ebx
  8013b7:	83 ec 04             	sub    $0x4,%esp
  8013ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c0:	8b 40 0c             	mov    0xc(%eax),%eax
  8013c3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8013cd:	b8 05 00 00 00       	mov    $0x5,%eax
  8013d2:	e8 45 ff ff ff       	call   80131c <fsipc>
  8013d7:	85 c0                	test   %eax,%eax
  8013d9:	78 2c                	js     801407 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013db:	83 ec 08             	sub    $0x8,%esp
  8013de:	68 00 50 80 00       	push   $0x805000
  8013e3:	53                   	push   %ebx
  8013e4:	e8 ed f2 ff ff       	call   8006d6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013e9:	a1 80 50 80 00       	mov    0x805080,%eax
  8013ee:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013f4:	a1 84 50 80 00       	mov    0x805084,%eax
  8013f9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013ff:	83 c4 10             	add    $0x10,%esp
  801402:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801407:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140a:	c9                   	leave  
  80140b:	c3                   	ret    

0080140c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
  80140f:	83 ec 0c             	sub    $0xc,%esp
  801412:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801415:	8b 55 08             	mov    0x8(%ebp),%edx
  801418:	8b 52 0c             	mov    0xc(%edx),%edx
  80141b:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801421:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801426:	50                   	push   %eax
  801427:	ff 75 0c             	pushl  0xc(%ebp)
  80142a:	68 08 50 80 00       	push   $0x805008
  80142f:	e8 34 f4 ff ff       	call   800868 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801434:	ba 00 00 00 00       	mov    $0x0,%edx
  801439:	b8 04 00 00 00       	mov    $0x4,%eax
  80143e:	e8 d9 fe ff ff       	call   80131c <fsipc>

}
  801443:	c9                   	leave  
  801444:	c3                   	ret    

00801445 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801445:	55                   	push   %ebp
  801446:	89 e5                	mov    %esp,%ebp
  801448:	56                   	push   %esi
  801449:	53                   	push   %ebx
  80144a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80144d:	8b 45 08             	mov    0x8(%ebp),%eax
  801450:	8b 40 0c             	mov    0xc(%eax),%eax
  801453:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801458:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80145e:	ba 00 00 00 00       	mov    $0x0,%edx
  801463:	b8 03 00 00 00       	mov    $0x3,%eax
  801468:	e8 af fe ff ff       	call   80131c <fsipc>
  80146d:	89 c3                	mov    %eax,%ebx
  80146f:	85 c0                	test   %eax,%eax
  801471:	78 4b                	js     8014be <devfile_read+0x79>
		return r;
	assert(r <= n);
  801473:	39 c6                	cmp    %eax,%esi
  801475:	73 16                	jae    80148d <devfile_read+0x48>
  801477:	68 bc 26 80 00       	push   $0x8026bc
  80147c:	68 c3 26 80 00       	push   $0x8026c3
  801481:	6a 7c                	push   $0x7c
  801483:	68 d8 26 80 00       	push   $0x8026d8
  801488:	e8 24 0a 00 00       	call   801eb1 <_panic>
	assert(r <= PGSIZE);
  80148d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801492:	7e 16                	jle    8014aa <devfile_read+0x65>
  801494:	68 e3 26 80 00       	push   $0x8026e3
  801499:	68 c3 26 80 00       	push   $0x8026c3
  80149e:	6a 7d                	push   $0x7d
  8014a0:	68 d8 26 80 00       	push   $0x8026d8
  8014a5:	e8 07 0a 00 00       	call   801eb1 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014aa:	83 ec 04             	sub    $0x4,%esp
  8014ad:	50                   	push   %eax
  8014ae:	68 00 50 80 00       	push   $0x805000
  8014b3:	ff 75 0c             	pushl  0xc(%ebp)
  8014b6:	e8 ad f3 ff ff       	call   800868 <memmove>
	return r;
  8014bb:	83 c4 10             	add    $0x10,%esp
}
  8014be:	89 d8                	mov    %ebx,%eax
  8014c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014c3:	5b                   	pop    %ebx
  8014c4:	5e                   	pop    %esi
  8014c5:	5d                   	pop    %ebp
  8014c6:	c3                   	ret    

008014c7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014c7:	55                   	push   %ebp
  8014c8:	89 e5                	mov    %esp,%ebp
  8014ca:	53                   	push   %ebx
  8014cb:	83 ec 20             	sub    $0x20,%esp
  8014ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014d1:	53                   	push   %ebx
  8014d2:	e8 c6 f1 ff ff       	call   80069d <strlen>
  8014d7:	83 c4 10             	add    $0x10,%esp
  8014da:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014df:	7f 67                	jg     801548 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014e1:	83 ec 0c             	sub    $0xc,%esp
  8014e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e7:	50                   	push   %eax
  8014e8:	e8 a7 f8 ff ff       	call   800d94 <fd_alloc>
  8014ed:	83 c4 10             	add    $0x10,%esp
		return r;
  8014f0:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014f2:	85 c0                	test   %eax,%eax
  8014f4:	78 57                	js     80154d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014f6:	83 ec 08             	sub    $0x8,%esp
  8014f9:	53                   	push   %ebx
  8014fa:	68 00 50 80 00       	push   $0x805000
  8014ff:	e8 d2 f1 ff ff       	call   8006d6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801504:	8b 45 0c             	mov    0xc(%ebp),%eax
  801507:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80150c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80150f:	b8 01 00 00 00       	mov    $0x1,%eax
  801514:	e8 03 fe ff ff       	call   80131c <fsipc>
  801519:	89 c3                	mov    %eax,%ebx
  80151b:	83 c4 10             	add    $0x10,%esp
  80151e:	85 c0                	test   %eax,%eax
  801520:	79 14                	jns    801536 <open+0x6f>
		fd_close(fd, 0);
  801522:	83 ec 08             	sub    $0x8,%esp
  801525:	6a 00                	push   $0x0
  801527:	ff 75 f4             	pushl  -0xc(%ebp)
  80152a:	e8 5d f9 ff ff       	call   800e8c <fd_close>
		return r;
  80152f:	83 c4 10             	add    $0x10,%esp
  801532:	89 da                	mov    %ebx,%edx
  801534:	eb 17                	jmp    80154d <open+0x86>
	}

	return fd2num(fd);
  801536:	83 ec 0c             	sub    $0xc,%esp
  801539:	ff 75 f4             	pushl  -0xc(%ebp)
  80153c:	e8 2c f8 ff ff       	call   800d6d <fd2num>
  801541:	89 c2                	mov    %eax,%edx
  801543:	83 c4 10             	add    $0x10,%esp
  801546:	eb 05                	jmp    80154d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801548:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80154d:	89 d0                	mov    %edx,%eax
  80154f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801552:	c9                   	leave  
  801553:	c3                   	ret    

00801554 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801554:	55                   	push   %ebp
  801555:	89 e5                	mov    %esp,%ebp
  801557:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80155a:	ba 00 00 00 00       	mov    $0x0,%edx
  80155f:	b8 08 00 00 00       	mov    $0x8,%eax
  801564:	e8 b3 fd ff ff       	call   80131c <fsipc>
}
  801569:	c9                   	leave  
  80156a:	c3                   	ret    

0080156b <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801571:	68 ef 26 80 00       	push   $0x8026ef
  801576:	ff 75 0c             	pushl  0xc(%ebp)
  801579:	e8 58 f1 ff ff       	call   8006d6 <strcpy>
	return 0;
}
  80157e:	b8 00 00 00 00       	mov    $0x0,%eax
  801583:	c9                   	leave  
  801584:	c3                   	ret    

00801585 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801585:	55                   	push   %ebp
  801586:	89 e5                	mov    %esp,%ebp
  801588:	53                   	push   %ebx
  801589:	83 ec 10             	sub    $0x10,%esp
  80158c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80158f:	53                   	push   %ebx
  801590:	e8 56 0a 00 00       	call   801feb <pageref>
  801595:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801598:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80159d:	83 f8 01             	cmp    $0x1,%eax
  8015a0:	75 10                	jne    8015b2 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8015a2:	83 ec 0c             	sub    $0xc,%esp
  8015a5:	ff 73 0c             	pushl  0xc(%ebx)
  8015a8:	e8 c0 02 00 00       	call   80186d <nsipc_close>
  8015ad:	89 c2                	mov    %eax,%edx
  8015af:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8015b2:	89 d0                	mov    %edx,%eax
  8015b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b7:	c9                   	leave  
  8015b8:	c3                   	ret    

008015b9 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8015b9:	55                   	push   %ebp
  8015ba:	89 e5                	mov    %esp,%ebp
  8015bc:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8015bf:	6a 00                	push   $0x0
  8015c1:	ff 75 10             	pushl  0x10(%ebp)
  8015c4:	ff 75 0c             	pushl  0xc(%ebp)
  8015c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ca:	ff 70 0c             	pushl  0xc(%eax)
  8015cd:	e8 78 03 00 00       	call   80194a <nsipc_send>
}
  8015d2:	c9                   	leave  
  8015d3:	c3                   	ret    

008015d4 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8015d4:	55                   	push   %ebp
  8015d5:	89 e5                	mov    %esp,%ebp
  8015d7:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8015da:	6a 00                	push   $0x0
  8015dc:	ff 75 10             	pushl  0x10(%ebp)
  8015df:	ff 75 0c             	pushl  0xc(%ebp)
  8015e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e5:	ff 70 0c             	pushl  0xc(%eax)
  8015e8:	e8 f1 02 00 00       	call   8018de <nsipc_recv>
}
  8015ed:	c9                   	leave  
  8015ee:	c3                   	ret    

008015ef <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8015ef:	55                   	push   %ebp
  8015f0:	89 e5                	mov    %esp,%ebp
  8015f2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8015f5:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015f8:	52                   	push   %edx
  8015f9:	50                   	push   %eax
  8015fa:	e8 e4 f7 ff ff       	call   800de3 <fd_lookup>
  8015ff:	83 c4 10             	add    $0x10,%esp
  801602:	85 c0                	test   %eax,%eax
  801604:	78 17                	js     80161d <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801606:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801609:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80160f:	39 08                	cmp    %ecx,(%eax)
  801611:	75 05                	jne    801618 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801613:	8b 40 0c             	mov    0xc(%eax),%eax
  801616:	eb 05                	jmp    80161d <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801618:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80161d:	c9                   	leave  
  80161e:	c3                   	ret    

0080161f <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80161f:	55                   	push   %ebp
  801620:	89 e5                	mov    %esp,%ebp
  801622:	56                   	push   %esi
  801623:	53                   	push   %ebx
  801624:	83 ec 1c             	sub    $0x1c,%esp
  801627:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801629:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162c:	50                   	push   %eax
  80162d:	e8 62 f7 ff ff       	call   800d94 <fd_alloc>
  801632:	89 c3                	mov    %eax,%ebx
  801634:	83 c4 10             	add    $0x10,%esp
  801637:	85 c0                	test   %eax,%eax
  801639:	78 1b                	js     801656 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80163b:	83 ec 04             	sub    $0x4,%esp
  80163e:	68 07 04 00 00       	push   $0x407
  801643:	ff 75 f4             	pushl  -0xc(%ebp)
  801646:	6a 00                	push   $0x0
  801648:	e8 8c f4 ff ff       	call   800ad9 <sys_page_alloc>
  80164d:	89 c3                	mov    %eax,%ebx
  80164f:	83 c4 10             	add    $0x10,%esp
  801652:	85 c0                	test   %eax,%eax
  801654:	79 10                	jns    801666 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801656:	83 ec 0c             	sub    $0xc,%esp
  801659:	56                   	push   %esi
  80165a:	e8 0e 02 00 00       	call   80186d <nsipc_close>
		return r;
  80165f:	83 c4 10             	add    $0x10,%esp
  801662:	89 d8                	mov    %ebx,%eax
  801664:	eb 24                	jmp    80168a <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801666:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80166c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80166f:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801671:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801674:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80167b:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80167e:	83 ec 0c             	sub    $0xc,%esp
  801681:	50                   	push   %eax
  801682:	e8 e6 f6 ff ff       	call   800d6d <fd2num>
  801687:	83 c4 10             	add    $0x10,%esp
}
  80168a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80168d:	5b                   	pop    %ebx
  80168e:	5e                   	pop    %esi
  80168f:	5d                   	pop    %ebp
  801690:	c3                   	ret    

00801691 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801691:	55                   	push   %ebp
  801692:	89 e5                	mov    %esp,%ebp
  801694:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801697:	8b 45 08             	mov    0x8(%ebp),%eax
  80169a:	e8 50 ff ff ff       	call   8015ef <fd2sockid>
		return r;
  80169f:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016a1:	85 c0                	test   %eax,%eax
  8016a3:	78 1f                	js     8016c4 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016a5:	83 ec 04             	sub    $0x4,%esp
  8016a8:	ff 75 10             	pushl  0x10(%ebp)
  8016ab:	ff 75 0c             	pushl  0xc(%ebp)
  8016ae:	50                   	push   %eax
  8016af:	e8 12 01 00 00       	call   8017c6 <nsipc_accept>
  8016b4:	83 c4 10             	add    $0x10,%esp
		return r;
  8016b7:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016b9:	85 c0                	test   %eax,%eax
  8016bb:	78 07                	js     8016c4 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8016bd:	e8 5d ff ff ff       	call   80161f <alloc_sockfd>
  8016c2:	89 c1                	mov    %eax,%ecx
}
  8016c4:	89 c8                	mov    %ecx,%eax
  8016c6:	c9                   	leave  
  8016c7:	c3                   	ret    

008016c8 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d1:	e8 19 ff ff ff       	call   8015ef <fd2sockid>
  8016d6:	85 c0                	test   %eax,%eax
  8016d8:	78 12                	js     8016ec <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8016da:	83 ec 04             	sub    $0x4,%esp
  8016dd:	ff 75 10             	pushl  0x10(%ebp)
  8016e0:	ff 75 0c             	pushl  0xc(%ebp)
  8016e3:	50                   	push   %eax
  8016e4:	e8 2d 01 00 00       	call   801816 <nsipc_bind>
  8016e9:	83 c4 10             	add    $0x10,%esp
}
  8016ec:	c9                   	leave  
  8016ed:	c3                   	ret    

008016ee <shutdown>:

int
shutdown(int s, int how)
{
  8016ee:	55                   	push   %ebp
  8016ef:	89 e5                	mov    %esp,%ebp
  8016f1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f7:	e8 f3 fe ff ff       	call   8015ef <fd2sockid>
  8016fc:	85 c0                	test   %eax,%eax
  8016fe:	78 0f                	js     80170f <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801700:	83 ec 08             	sub    $0x8,%esp
  801703:	ff 75 0c             	pushl  0xc(%ebp)
  801706:	50                   	push   %eax
  801707:	e8 3f 01 00 00       	call   80184b <nsipc_shutdown>
  80170c:	83 c4 10             	add    $0x10,%esp
}
  80170f:	c9                   	leave  
  801710:	c3                   	ret    

00801711 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801711:	55                   	push   %ebp
  801712:	89 e5                	mov    %esp,%ebp
  801714:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801717:	8b 45 08             	mov    0x8(%ebp),%eax
  80171a:	e8 d0 fe ff ff       	call   8015ef <fd2sockid>
  80171f:	85 c0                	test   %eax,%eax
  801721:	78 12                	js     801735 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801723:	83 ec 04             	sub    $0x4,%esp
  801726:	ff 75 10             	pushl  0x10(%ebp)
  801729:	ff 75 0c             	pushl  0xc(%ebp)
  80172c:	50                   	push   %eax
  80172d:	e8 55 01 00 00       	call   801887 <nsipc_connect>
  801732:	83 c4 10             	add    $0x10,%esp
}
  801735:	c9                   	leave  
  801736:	c3                   	ret    

00801737 <listen>:

int
listen(int s, int backlog)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80173d:	8b 45 08             	mov    0x8(%ebp),%eax
  801740:	e8 aa fe ff ff       	call   8015ef <fd2sockid>
  801745:	85 c0                	test   %eax,%eax
  801747:	78 0f                	js     801758 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801749:	83 ec 08             	sub    $0x8,%esp
  80174c:	ff 75 0c             	pushl  0xc(%ebp)
  80174f:	50                   	push   %eax
  801750:	e8 67 01 00 00       	call   8018bc <nsipc_listen>
  801755:	83 c4 10             	add    $0x10,%esp
}
  801758:	c9                   	leave  
  801759:	c3                   	ret    

0080175a <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801760:	ff 75 10             	pushl  0x10(%ebp)
  801763:	ff 75 0c             	pushl  0xc(%ebp)
  801766:	ff 75 08             	pushl  0x8(%ebp)
  801769:	e8 3a 02 00 00       	call   8019a8 <nsipc_socket>
  80176e:	83 c4 10             	add    $0x10,%esp
  801771:	85 c0                	test   %eax,%eax
  801773:	78 05                	js     80177a <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801775:	e8 a5 fe ff ff       	call   80161f <alloc_sockfd>
}
  80177a:	c9                   	leave  
  80177b:	c3                   	ret    

0080177c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80177c:	55                   	push   %ebp
  80177d:	89 e5                	mov    %esp,%ebp
  80177f:	53                   	push   %ebx
  801780:	83 ec 04             	sub    $0x4,%esp
  801783:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801785:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80178c:	75 12                	jne    8017a0 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80178e:	83 ec 0c             	sub    $0xc,%esp
  801791:	6a 02                	push   $0x2
  801793:	e8 1a 08 00 00       	call   801fb2 <ipc_find_env>
  801798:	a3 04 40 80 00       	mov    %eax,0x804004
  80179d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8017a0:	6a 07                	push   $0x7
  8017a2:	68 00 60 80 00       	push   $0x806000
  8017a7:	53                   	push   %ebx
  8017a8:	ff 35 04 40 80 00    	pushl  0x804004
  8017ae:	e8 ab 07 00 00       	call   801f5e <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8017b3:	83 c4 0c             	add    $0xc,%esp
  8017b6:	6a 00                	push   $0x0
  8017b8:	6a 00                	push   $0x0
  8017ba:	6a 00                	push   $0x0
  8017bc:	e8 36 07 00 00       	call   801ef7 <ipc_recv>
}
  8017c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c4:	c9                   	leave  
  8017c5:	c3                   	ret    

008017c6 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017c6:	55                   	push   %ebp
  8017c7:	89 e5                	mov    %esp,%ebp
  8017c9:	56                   	push   %esi
  8017ca:	53                   	push   %ebx
  8017cb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8017ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8017d6:	8b 06                	mov    (%esi),%eax
  8017d8:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8017dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8017e2:	e8 95 ff ff ff       	call   80177c <nsipc>
  8017e7:	89 c3                	mov    %eax,%ebx
  8017e9:	85 c0                	test   %eax,%eax
  8017eb:	78 20                	js     80180d <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8017ed:	83 ec 04             	sub    $0x4,%esp
  8017f0:	ff 35 10 60 80 00    	pushl  0x806010
  8017f6:	68 00 60 80 00       	push   $0x806000
  8017fb:	ff 75 0c             	pushl  0xc(%ebp)
  8017fe:	e8 65 f0 ff ff       	call   800868 <memmove>
		*addrlen = ret->ret_addrlen;
  801803:	a1 10 60 80 00       	mov    0x806010,%eax
  801808:	89 06                	mov    %eax,(%esi)
  80180a:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80180d:	89 d8                	mov    %ebx,%eax
  80180f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801812:	5b                   	pop    %ebx
  801813:	5e                   	pop    %esi
  801814:	5d                   	pop    %ebp
  801815:	c3                   	ret    

00801816 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801816:	55                   	push   %ebp
  801817:	89 e5                	mov    %esp,%ebp
  801819:	53                   	push   %ebx
  80181a:	83 ec 08             	sub    $0x8,%esp
  80181d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801820:	8b 45 08             	mov    0x8(%ebp),%eax
  801823:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801828:	53                   	push   %ebx
  801829:	ff 75 0c             	pushl  0xc(%ebp)
  80182c:	68 04 60 80 00       	push   $0x806004
  801831:	e8 32 f0 ff ff       	call   800868 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801836:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80183c:	b8 02 00 00 00       	mov    $0x2,%eax
  801841:	e8 36 ff ff ff       	call   80177c <nsipc>
}
  801846:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801849:	c9                   	leave  
  80184a:	c3                   	ret    

0080184b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80184b:	55                   	push   %ebp
  80184c:	89 e5                	mov    %esp,%ebp
  80184e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801851:	8b 45 08             	mov    0x8(%ebp),%eax
  801854:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801859:	8b 45 0c             	mov    0xc(%ebp),%eax
  80185c:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801861:	b8 03 00 00 00       	mov    $0x3,%eax
  801866:	e8 11 ff ff ff       	call   80177c <nsipc>
}
  80186b:	c9                   	leave  
  80186c:	c3                   	ret    

0080186d <nsipc_close>:

int
nsipc_close(int s)
{
  80186d:	55                   	push   %ebp
  80186e:	89 e5                	mov    %esp,%ebp
  801870:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801873:	8b 45 08             	mov    0x8(%ebp),%eax
  801876:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  80187b:	b8 04 00 00 00       	mov    $0x4,%eax
  801880:	e8 f7 fe ff ff       	call   80177c <nsipc>
}
  801885:	c9                   	leave  
  801886:	c3                   	ret    

00801887 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801887:	55                   	push   %ebp
  801888:	89 e5                	mov    %esp,%ebp
  80188a:	53                   	push   %ebx
  80188b:	83 ec 08             	sub    $0x8,%esp
  80188e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801891:	8b 45 08             	mov    0x8(%ebp),%eax
  801894:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801899:	53                   	push   %ebx
  80189a:	ff 75 0c             	pushl  0xc(%ebp)
  80189d:	68 04 60 80 00       	push   $0x806004
  8018a2:	e8 c1 ef ff ff       	call   800868 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8018a7:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8018ad:	b8 05 00 00 00       	mov    $0x5,%eax
  8018b2:	e8 c5 fe ff ff       	call   80177c <nsipc>
}
  8018b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ba:	c9                   	leave  
  8018bb:	c3                   	ret    

008018bc <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8018c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8018ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018cd:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8018d2:	b8 06 00 00 00       	mov    $0x6,%eax
  8018d7:	e8 a0 fe ff ff       	call   80177c <nsipc>
}
  8018dc:	c9                   	leave  
  8018dd:	c3                   	ret    

008018de <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8018de:	55                   	push   %ebp
  8018df:	89 e5                	mov    %esp,%ebp
  8018e1:	56                   	push   %esi
  8018e2:	53                   	push   %ebx
  8018e3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8018e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8018ee:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8018f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8018f7:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8018fc:	b8 07 00 00 00       	mov    $0x7,%eax
  801901:	e8 76 fe ff ff       	call   80177c <nsipc>
  801906:	89 c3                	mov    %eax,%ebx
  801908:	85 c0                	test   %eax,%eax
  80190a:	78 35                	js     801941 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  80190c:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801911:	7f 04                	jg     801917 <nsipc_recv+0x39>
  801913:	39 c6                	cmp    %eax,%esi
  801915:	7d 16                	jge    80192d <nsipc_recv+0x4f>
  801917:	68 fb 26 80 00       	push   $0x8026fb
  80191c:	68 c3 26 80 00       	push   $0x8026c3
  801921:	6a 62                	push   $0x62
  801923:	68 10 27 80 00       	push   $0x802710
  801928:	e8 84 05 00 00       	call   801eb1 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80192d:	83 ec 04             	sub    $0x4,%esp
  801930:	50                   	push   %eax
  801931:	68 00 60 80 00       	push   $0x806000
  801936:	ff 75 0c             	pushl  0xc(%ebp)
  801939:	e8 2a ef ff ff       	call   800868 <memmove>
  80193e:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801941:	89 d8                	mov    %ebx,%eax
  801943:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801946:	5b                   	pop    %ebx
  801947:	5e                   	pop    %esi
  801948:	5d                   	pop    %ebp
  801949:	c3                   	ret    

0080194a <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80194a:	55                   	push   %ebp
  80194b:	89 e5                	mov    %esp,%ebp
  80194d:	53                   	push   %ebx
  80194e:	83 ec 04             	sub    $0x4,%esp
  801951:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801954:	8b 45 08             	mov    0x8(%ebp),%eax
  801957:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  80195c:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801962:	7e 16                	jle    80197a <nsipc_send+0x30>
  801964:	68 1c 27 80 00       	push   $0x80271c
  801969:	68 c3 26 80 00       	push   $0x8026c3
  80196e:	6a 6d                	push   $0x6d
  801970:	68 10 27 80 00       	push   $0x802710
  801975:	e8 37 05 00 00       	call   801eb1 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80197a:	83 ec 04             	sub    $0x4,%esp
  80197d:	53                   	push   %ebx
  80197e:	ff 75 0c             	pushl  0xc(%ebp)
  801981:	68 0c 60 80 00       	push   $0x80600c
  801986:	e8 dd ee ff ff       	call   800868 <memmove>
	nsipcbuf.send.req_size = size;
  80198b:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801991:	8b 45 14             	mov    0x14(%ebp),%eax
  801994:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801999:	b8 08 00 00 00       	mov    $0x8,%eax
  80199e:	e8 d9 fd ff ff       	call   80177c <nsipc>
}
  8019a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a6:	c9                   	leave  
  8019a7:	c3                   	ret    

008019a8 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8019ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8019b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b9:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8019be:	8b 45 10             	mov    0x10(%ebp),%eax
  8019c1:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8019c6:	b8 09 00 00 00       	mov    $0x9,%eax
  8019cb:	e8 ac fd ff ff       	call   80177c <nsipc>
}
  8019d0:	c9                   	leave  
  8019d1:	c3                   	ret    

008019d2 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019d2:	55                   	push   %ebp
  8019d3:	89 e5                	mov    %esp,%ebp
  8019d5:	56                   	push   %esi
  8019d6:	53                   	push   %ebx
  8019d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019da:	83 ec 0c             	sub    $0xc,%esp
  8019dd:	ff 75 08             	pushl  0x8(%ebp)
  8019e0:	e8 98 f3 ff ff       	call   800d7d <fd2data>
  8019e5:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019e7:	83 c4 08             	add    $0x8,%esp
  8019ea:	68 28 27 80 00       	push   $0x802728
  8019ef:	53                   	push   %ebx
  8019f0:	e8 e1 ec ff ff       	call   8006d6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019f5:	8b 46 04             	mov    0x4(%esi),%eax
  8019f8:	2b 06                	sub    (%esi),%eax
  8019fa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a00:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a07:	00 00 00 
	stat->st_dev = &devpipe;
  801a0a:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a11:	30 80 00 
	return 0;
}
  801a14:	b8 00 00 00 00       	mov    $0x0,%eax
  801a19:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a1c:	5b                   	pop    %ebx
  801a1d:	5e                   	pop    %esi
  801a1e:	5d                   	pop    %ebp
  801a1f:	c3                   	ret    

00801a20 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a20:	55                   	push   %ebp
  801a21:	89 e5                	mov    %esp,%ebp
  801a23:	53                   	push   %ebx
  801a24:	83 ec 0c             	sub    $0xc,%esp
  801a27:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a2a:	53                   	push   %ebx
  801a2b:	6a 00                	push   $0x0
  801a2d:	e8 2c f1 ff ff       	call   800b5e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a32:	89 1c 24             	mov    %ebx,(%esp)
  801a35:	e8 43 f3 ff ff       	call   800d7d <fd2data>
  801a3a:	83 c4 08             	add    $0x8,%esp
  801a3d:	50                   	push   %eax
  801a3e:	6a 00                	push   $0x0
  801a40:	e8 19 f1 ff ff       	call   800b5e <sys_page_unmap>
}
  801a45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a48:	c9                   	leave  
  801a49:	c3                   	ret    

00801a4a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a4a:	55                   	push   %ebp
  801a4b:	89 e5                	mov    %esp,%ebp
  801a4d:	57                   	push   %edi
  801a4e:	56                   	push   %esi
  801a4f:	53                   	push   %ebx
  801a50:	83 ec 1c             	sub    $0x1c,%esp
  801a53:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a56:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a58:	a1 08 40 80 00       	mov    0x804008,%eax
  801a5d:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a60:	83 ec 0c             	sub    $0xc,%esp
  801a63:	ff 75 e0             	pushl  -0x20(%ebp)
  801a66:	e8 80 05 00 00       	call   801feb <pageref>
  801a6b:	89 c3                	mov    %eax,%ebx
  801a6d:	89 3c 24             	mov    %edi,(%esp)
  801a70:	e8 76 05 00 00       	call   801feb <pageref>
  801a75:	83 c4 10             	add    $0x10,%esp
  801a78:	39 c3                	cmp    %eax,%ebx
  801a7a:	0f 94 c1             	sete   %cl
  801a7d:	0f b6 c9             	movzbl %cl,%ecx
  801a80:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a83:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a89:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a8c:	39 ce                	cmp    %ecx,%esi
  801a8e:	74 1b                	je     801aab <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a90:	39 c3                	cmp    %eax,%ebx
  801a92:	75 c4                	jne    801a58 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a94:	8b 42 58             	mov    0x58(%edx),%eax
  801a97:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a9a:	50                   	push   %eax
  801a9b:	56                   	push   %esi
  801a9c:	68 2f 27 80 00       	push   $0x80272f
  801aa1:	e8 ab e6 ff ff       	call   800151 <cprintf>
  801aa6:	83 c4 10             	add    $0x10,%esp
  801aa9:	eb ad                	jmp    801a58 <_pipeisclosed+0xe>
	}
}
  801aab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801aae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab1:	5b                   	pop    %ebx
  801ab2:	5e                   	pop    %esi
  801ab3:	5f                   	pop    %edi
  801ab4:	5d                   	pop    %ebp
  801ab5:	c3                   	ret    

00801ab6 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ab6:	55                   	push   %ebp
  801ab7:	89 e5                	mov    %esp,%ebp
  801ab9:	57                   	push   %edi
  801aba:	56                   	push   %esi
  801abb:	53                   	push   %ebx
  801abc:	83 ec 28             	sub    $0x28,%esp
  801abf:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ac2:	56                   	push   %esi
  801ac3:	e8 b5 f2 ff ff       	call   800d7d <fd2data>
  801ac8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aca:	83 c4 10             	add    $0x10,%esp
  801acd:	bf 00 00 00 00       	mov    $0x0,%edi
  801ad2:	eb 4b                	jmp    801b1f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ad4:	89 da                	mov    %ebx,%edx
  801ad6:	89 f0                	mov    %esi,%eax
  801ad8:	e8 6d ff ff ff       	call   801a4a <_pipeisclosed>
  801add:	85 c0                	test   %eax,%eax
  801adf:	75 48                	jne    801b29 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ae1:	e8 d4 ef ff ff       	call   800aba <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ae6:	8b 43 04             	mov    0x4(%ebx),%eax
  801ae9:	8b 0b                	mov    (%ebx),%ecx
  801aeb:	8d 51 20             	lea    0x20(%ecx),%edx
  801aee:	39 d0                	cmp    %edx,%eax
  801af0:	73 e2                	jae    801ad4 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801af2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801af5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801af9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801afc:	89 c2                	mov    %eax,%edx
  801afe:	c1 fa 1f             	sar    $0x1f,%edx
  801b01:	89 d1                	mov    %edx,%ecx
  801b03:	c1 e9 1b             	shr    $0x1b,%ecx
  801b06:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b09:	83 e2 1f             	and    $0x1f,%edx
  801b0c:	29 ca                	sub    %ecx,%edx
  801b0e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b12:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b16:	83 c0 01             	add    $0x1,%eax
  801b19:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b1c:	83 c7 01             	add    $0x1,%edi
  801b1f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b22:	75 c2                	jne    801ae6 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b24:	8b 45 10             	mov    0x10(%ebp),%eax
  801b27:	eb 05                	jmp    801b2e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b29:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b31:	5b                   	pop    %ebx
  801b32:	5e                   	pop    %esi
  801b33:	5f                   	pop    %edi
  801b34:	5d                   	pop    %ebp
  801b35:	c3                   	ret    

00801b36 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b36:	55                   	push   %ebp
  801b37:	89 e5                	mov    %esp,%ebp
  801b39:	57                   	push   %edi
  801b3a:	56                   	push   %esi
  801b3b:	53                   	push   %ebx
  801b3c:	83 ec 18             	sub    $0x18,%esp
  801b3f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b42:	57                   	push   %edi
  801b43:	e8 35 f2 ff ff       	call   800d7d <fd2data>
  801b48:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b4a:	83 c4 10             	add    $0x10,%esp
  801b4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b52:	eb 3d                	jmp    801b91 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b54:	85 db                	test   %ebx,%ebx
  801b56:	74 04                	je     801b5c <devpipe_read+0x26>
				return i;
  801b58:	89 d8                	mov    %ebx,%eax
  801b5a:	eb 44                	jmp    801ba0 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b5c:	89 f2                	mov    %esi,%edx
  801b5e:	89 f8                	mov    %edi,%eax
  801b60:	e8 e5 fe ff ff       	call   801a4a <_pipeisclosed>
  801b65:	85 c0                	test   %eax,%eax
  801b67:	75 32                	jne    801b9b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b69:	e8 4c ef ff ff       	call   800aba <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b6e:	8b 06                	mov    (%esi),%eax
  801b70:	3b 46 04             	cmp    0x4(%esi),%eax
  801b73:	74 df                	je     801b54 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b75:	99                   	cltd   
  801b76:	c1 ea 1b             	shr    $0x1b,%edx
  801b79:	01 d0                	add    %edx,%eax
  801b7b:	83 e0 1f             	and    $0x1f,%eax
  801b7e:	29 d0                	sub    %edx,%eax
  801b80:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b88:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b8b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b8e:	83 c3 01             	add    $0x1,%ebx
  801b91:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b94:	75 d8                	jne    801b6e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b96:	8b 45 10             	mov    0x10(%ebp),%eax
  801b99:	eb 05                	jmp    801ba0 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b9b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ba0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ba3:	5b                   	pop    %ebx
  801ba4:	5e                   	pop    %esi
  801ba5:	5f                   	pop    %edi
  801ba6:	5d                   	pop    %ebp
  801ba7:	c3                   	ret    

00801ba8 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ba8:	55                   	push   %ebp
  801ba9:	89 e5                	mov    %esp,%ebp
  801bab:	56                   	push   %esi
  801bac:	53                   	push   %ebx
  801bad:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bb3:	50                   	push   %eax
  801bb4:	e8 db f1 ff ff       	call   800d94 <fd_alloc>
  801bb9:	83 c4 10             	add    $0x10,%esp
  801bbc:	89 c2                	mov    %eax,%edx
  801bbe:	85 c0                	test   %eax,%eax
  801bc0:	0f 88 2c 01 00 00    	js     801cf2 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc6:	83 ec 04             	sub    $0x4,%esp
  801bc9:	68 07 04 00 00       	push   $0x407
  801bce:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd1:	6a 00                	push   $0x0
  801bd3:	e8 01 ef ff ff       	call   800ad9 <sys_page_alloc>
  801bd8:	83 c4 10             	add    $0x10,%esp
  801bdb:	89 c2                	mov    %eax,%edx
  801bdd:	85 c0                	test   %eax,%eax
  801bdf:	0f 88 0d 01 00 00    	js     801cf2 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801be5:	83 ec 0c             	sub    $0xc,%esp
  801be8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801beb:	50                   	push   %eax
  801bec:	e8 a3 f1 ff ff       	call   800d94 <fd_alloc>
  801bf1:	89 c3                	mov    %eax,%ebx
  801bf3:	83 c4 10             	add    $0x10,%esp
  801bf6:	85 c0                	test   %eax,%eax
  801bf8:	0f 88 e2 00 00 00    	js     801ce0 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bfe:	83 ec 04             	sub    $0x4,%esp
  801c01:	68 07 04 00 00       	push   $0x407
  801c06:	ff 75 f0             	pushl  -0x10(%ebp)
  801c09:	6a 00                	push   $0x0
  801c0b:	e8 c9 ee ff ff       	call   800ad9 <sys_page_alloc>
  801c10:	89 c3                	mov    %eax,%ebx
  801c12:	83 c4 10             	add    $0x10,%esp
  801c15:	85 c0                	test   %eax,%eax
  801c17:	0f 88 c3 00 00 00    	js     801ce0 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c1d:	83 ec 0c             	sub    $0xc,%esp
  801c20:	ff 75 f4             	pushl  -0xc(%ebp)
  801c23:	e8 55 f1 ff ff       	call   800d7d <fd2data>
  801c28:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c2a:	83 c4 0c             	add    $0xc,%esp
  801c2d:	68 07 04 00 00       	push   $0x407
  801c32:	50                   	push   %eax
  801c33:	6a 00                	push   $0x0
  801c35:	e8 9f ee ff ff       	call   800ad9 <sys_page_alloc>
  801c3a:	89 c3                	mov    %eax,%ebx
  801c3c:	83 c4 10             	add    $0x10,%esp
  801c3f:	85 c0                	test   %eax,%eax
  801c41:	0f 88 89 00 00 00    	js     801cd0 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c47:	83 ec 0c             	sub    $0xc,%esp
  801c4a:	ff 75 f0             	pushl  -0x10(%ebp)
  801c4d:	e8 2b f1 ff ff       	call   800d7d <fd2data>
  801c52:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c59:	50                   	push   %eax
  801c5a:	6a 00                	push   $0x0
  801c5c:	56                   	push   %esi
  801c5d:	6a 00                	push   $0x0
  801c5f:	e8 b8 ee ff ff       	call   800b1c <sys_page_map>
  801c64:	89 c3                	mov    %eax,%ebx
  801c66:	83 c4 20             	add    $0x20,%esp
  801c69:	85 c0                	test   %eax,%eax
  801c6b:	78 55                	js     801cc2 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c6d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c76:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c7b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c82:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c88:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c8b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c90:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c97:	83 ec 0c             	sub    $0xc,%esp
  801c9a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c9d:	e8 cb f0 ff ff       	call   800d6d <fd2num>
  801ca2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ca5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ca7:	83 c4 04             	add    $0x4,%esp
  801caa:	ff 75 f0             	pushl  -0x10(%ebp)
  801cad:	e8 bb f0 ff ff       	call   800d6d <fd2num>
  801cb2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cb5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cb8:	83 c4 10             	add    $0x10,%esp
  801cbb:	ba 00 00 00 00       	mov    $0x0,%edx
  801cc0:	eb 30                	jmp    801cf2 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cc2:	83 ec 08             	sub    $0x8,%esp
  801cc5:	56                   	push   %esi
  801cc6:	6a 00                	push   $0x0
  801cc8:	e8 91 ee ff ff       	call   800b5e <sys_page_unmap>
  801ccd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cd0:	83 ec 08             	sub    $0x8,%esp
  801cd3:	ff 75 f0             	pushl  -0x10(%ebp)
  801cd6:	6a 00                	push   $0x0
  801cd8:	e8 81 ee ff ff       	call   800b5e <sys_page_unmap>
  801cdd:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ce0:	83 ec 08             	sub    $0x8,%esp
  801ce3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce6:	6a 00                	push   $0x0
  801ce8:	e8 71 ee ff ff       	call   800b5e <sys_page_unmap>
  801ced:	83 c4 10             	add    $0x10,%esp
  801cf0:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cf2:	89 d0                	mov    %edx,%eax
  801cf4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cf7:	5b                   	pop    %ebx
  801cf8:	5e                   	pop    %esi
  801cf9:	5d                   	pop    %ebp
  801cfa:	c3                   	ret    

00801cfb <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d04:	50                   	push   %eax
  801d05:	ff 75 08             	pushl  0x8(%ebp)
  801d08:	e8 d6 f0 ff ff       	call   800de3 <fd_lookup>
  801d0d:	83 c4 10             	add    $0x10,%esp
  801d10:	85 c0                	test   %eax,%eax
  801d12:	78 18                	js     801d2c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d14:	83 ec 0c             	sub    $0xc,%esp
  801d17:	ff 75 f4             	pushl  -0xc(%ebp)
  801d1a:	e8 5e f0 ff ff       	call   800d7d <fd2data>
	return _pipeisclosed(fd, p);
  801d1f:	89 c2                	mov    %eax,%edx
  801d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d24:	e8 21 fd ff ff       	call   801a4a <_pipeisclosed>
  801d29:	83 c4 10             	add    $0x10,%esp
}
  801d2c:	c9                   	leave  
  801d2d:	c3                   	ret    

00801d2e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d2e:	55                   	push   %ebp
  801d2f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d31:	b8 00 00 00 00       	mov    $0x0,%eax
  801d36:	5d                   	pop    %ebp
  801d37:	c3                   	ret    

00801d38 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d38:	55                   	push   %ebp
  801d39:	89 e5                	mov    %esp,%ebp
  801d3b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d3e:	68 47 27 80 00       	push   $0x802747
  801d43:	ff 75 0c             	pushl  0xc(%ebp)
  801d46:	e8 8b e9 ff ff       	call   8006d6 <strcpy>
	return 0;
}
  801d4b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d50:	c9                   	leave  
  801d51:	c3                   	ret    

00801d52 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d52:	55                   	push   %ebp
  801d53:	89 e5                	mov    %esp,%ebp
  801d55:	57                   	push   %edi
  801d56:	56                   	push   %esi
  801d57:	53                   	push   %ebx
  801d58:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d5e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d63:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d69:	eb 2d                	jmp    801d98 <devcons_write+0x46>
		m = n - tot;
  801d6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d6e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d70:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d73:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d78:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d7b:	83 ec 04             	sub    $0x4,%esp
  801d7e:	53                   	push   %ebx
  801d7f:	03 45 0c             	add    0xc(%ebp),%eax
  801d82:	50                   	push   %eax
  801d83:	57                   	push   %edi
  801d84:	e8 df ea ff ff       	call   800868 <memmove>
		sys_cputs(buf, m);
  801d89:	83 c4 08             	add    $0x8,%esp
  801d8c:	53                   	push   %ebx
  801d8d:	57                   	push   %edi
  801d8e:	e8 8a ec ff ff       	call   800a1d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d93:	01 de                	add    %ebx,%esi
  801d95:	83 c4 10             	add    $0x10,%esp
  801d98:	89 f0                	mov    %esi,%eax
  801d9a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d9d:	72 cc                	jb     801d6b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801da2:	5b                   	pop    %ebx
  801da3:	5e                   	pop    %esi
  801da4:	5f                   	pop    %edi
  801da5:	5d                   	pop    %ebp
  801da6:	c3                   	ret    

00801da7 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801da7:	55                   	push   %ebp
  801da8:	89 e5                	mov    %esp,%ebp
  801daa:	83 ec 08             	sub    $0x8,%esp
  801dad:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801db2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801db6:	74 2a                	je     801de2 <devcons_read+0x3b>
  801db8:	eb 05                	jmp    801dbf <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801dba:	e8 fb ec ff ff       	call   800aba <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801dbf:	e8 77 ec ff ff       	call   800a3b <sys_cgetc>
  801dc4:	85 c0                	test   %eax,%eax
  801dc6:	74 f2                	je     801dba <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801dc8:	85 c0                	test   %eax,%eax
  801dca:	78 16                	js     801de2 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dcc:	83 f8 04             	cmp    $0x4,%eax
  801dcf:	74 0c                	je     801ddd <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801dd1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dd4:	88 02                	mov    %al,(%edx)
	return 1;
  801dd6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ddb:	eb 05                	jmp    801de2 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ddd:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801de2:	c9                   	leave  
  801de3:	c3                   	ret    

00801de4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801de4:	55                   	push   %ebp
  801de5:	89 e5                	mov    %esp,%ebp
  801de7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dea:	8b 45 08             	mov    0x8(%ebp),%eax
  801ded:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801df0:	6a 01                	push   $0x1
  801df2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801df5:	50                   	push   %eax
  801df6:	e8 22 ec ff ff       	call   800a1d <sys_cputs>
}
  801dfb:	83 c4 10             	add    $0x10,%esp
  801dfe:	c9                   	leave  
  801dff:	c3                   	ret    

00801e00 <getchar>:

int
getchar(void)
{
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e06:	6a 01                	push   $0x1
  801e08:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e0b:	50                   	push   %eax
  801e0c:	6a 00                	push   $0x0
  801e0e:	e8 36 f2 ff ff       	call   801049 <read>
	if (r < 0)
  801e13:	83 c4 10             	add    $0x10,%esp
  801e16:	85 c0                	test   %eax,%eax
  801e18:	78 0f                	js     801e29 <getchar+0x29>
		return r;
	if (r < 1)
  801e1a:	85 c0                	test   %eax,%eax
  801e1c:	7e 06                	jle    801e24 <getchar+0x24>
		return -E_EOF;
	return c;
  801e1e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e22:	eb 05                	jmp    801e29 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e24:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e29:	c9                   	leave  
  801e2a:	c3                   	ret    

00801e2b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e2b:	55                   	push   %ebp
  801e2c:	89 e5                	mov    %esp,%ebp
  801e2e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e34:	50                   	push   %eax
  801e35:	ff 75 08             	pushl  0x8(%ebp)
  801e38:	e8 a6 ef ff ff       	call   800de3 <fd_lookup>
  801e3d:	83 c4 10             	add    $0x10,%esp
  801e40:	85 c0                	test   %eax,%eax
  801e42:	78 11                	js     801e55 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e47:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e4d:	39 10                	cmp    %edx,(%eax)
  801e4f:	0f 94 c0             	sete   %al
  801e52:	0f b6 c0             	movzbl %al,%eax
}
  801e55:	c9                   	leave  
  801e56:	c3                   	ret    

00801e57 <opencons>:

int
opencons(void)
{
  801e57:	55                   	push   %ebp
  801e58:	89 e5                	mov    %esp,%ebp
  801e5a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e60:	50                   	push   %eax
  801e61:	e8 2e ef ff ff       	call   800d94 <fd_alloc>
  801e66:	83 c4 10             	add    $0x10,%esp
		return r;
  801e69:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e6b:	85 c0                	test   %eax,%eax
  801e6d:	78 3e                	js     801ead <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e6f:	83 ec 04             	sub    $0x4,%esp
  801e72:	68 07 04 00 00       	push   $0x407
  801e77:	ff 75 f4             	pushl  -0xc(%ebp)
  801e7a:	6a 00                	push   $0x0
  801e7c:	e8 58 ec ff ff       	call   800ad9 <sys_page_alloc>
  801e81:	83 c4 10             	add    $0x10,%esp
		return r;
  801e84:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e86:	85 c0                	test   %eax,%eax
  801e88:	78 23                	js     801ead <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e8a:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e93:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e98:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e9f:	83 ec 0c             	sub    $0xc,%esp
  801ea2:	50                   	push   %eax
  801ea3:	e8 c5 ee ff ff       	call   800d6d <fd2num>
  801ea8:	89 c2                	mov    %eax,%edx
  801eaa:	83 c4 10             	add    $0x10,%esp
}
  801ead:	89 d0                	mov    %edx,%eax
  801eaf:	c9                   	leave  
  801eb0:	c3                   	ret    

00801eb1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
  801eb4:	56                   	push   %esi
  801eb5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801eb6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801eb9:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ebf:	e8 d7 eb ff ff       	call   800a9b <sys_getenvid>
  801ec4:	83 ec 0c             	sub    $0xc,%esp
  801ec7:	ff 75 0c             	pushl  0xc(%ebp)
  801eca:	ff 75 08             	pushl  0x8(%ebp)
  801ecd:	56                   	push   %esi
  801ece:	50                   	push   %eax
  801ecf:	68 54 27 80 00       	push   $0x802754
  801ed4:	e8 78 e2 ff ff       	call   800151 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ed9:	83 c4 18             	add    $0x18,%esp
  801edc:	53                   	push   %ebx
  801edd:	ff 75 10             	pushl  0x10(%ebp)
  801ee0:	e8 1b e2 ff ff       	call   800100 <vcprintf>
	cprintf("\n");
  801ee5:	c7 04 24 40 27 80 00 	movl   $0x802740,(%esp)
  801eec:	e8 60 e2 ff ff       	call   800151 <cprintf>
  801ef1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ef4:	cc                   	int3   
  801ef5:	eb fd                	jmp    801ef4 <_panic+0x43>

00801ef7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ef7:	55                   	push   %ebp
  801ef8:	89 e5                	mov    %esp,%ebp
  801efa:	56                   	push   %esi
  801efb:	53                   	push   %ebx
  801efc:	8b 75 08             	mov    0x8(%ebp),%esi
  801eff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f02:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801f05:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801f07:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f0c:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801f0f:	83 ec 0c             	sub    $0xc,%esp
  801f12:	50                   	push   %eax
  801f13:	e8 71 ed ff ff       	call   800c89 <sys_ipc_recv>

	if (from_env_store != NULL)
  801f18:	83 c4 10             	add    $0x10,%esp
  801f1b:	85 f6                	test   %esi,%esi
  801f1d:	74 14                	je     801f33 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801f1f:	ba 00 00 00 00       	mov    $0x0,%edx
  801f24:	85 c0                	test   %eax,%eax
  801f26:	78 09                	js     801f31 <ipc_recv+0x3a>
  801f28:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f2e:	8b 52 74             	mov    0x74(%edx),%edx
  801f31:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801f33:	85 db                	test   %ebx,%ebx
  801f35:	74 14                	je     801f4b <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801f37:	ba 00 00 00 00       	mov    $0x0,%edx
  801f3c:	85 c0                	test   %eax,%eax
  801f3e:	78 09                	js     801f49 <ipc_recv+0x52>
  801f40:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f46:	8b 52 78             	mov    0x78(%edx),%edx
  801f49:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801f4b:	85 c0                	test   %eax,%eax
  801f4d:	78 08                	js     801f57 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801f4f:	a1 08 40 80 00       	mov    0x804008,%eax
  801f54:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f57:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f5a:	5b                   	pop    %ebx
  801f5b:	5e                   	pop    %esi
  801f5c:	5d                   	pop    %ebp
  801f5d:	c3                   	ret    

00801f5e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f5e:	55                   	push   %ebp
  801f5f:	89 e5                	mov    %esp,%ebp
  801f61:	57                   	push   %edi
  801f62:	56                   	push   %esi
  801f63:	53                   	push   %ebx
  801f64:	83 ec 0c             	sub    $0xc,%esp
  801f67:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f6a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801f70:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801f72:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f77:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801f7a:	ff 75 14             	pushl  0x14(%ebp)
  801f7d:	53                   	push   %ebx
  801f7e:	56                   	push   %esi
  801f7f:	57                   	push   %edi
  801f80:	e8 e1 ec ff ff       	call   800c66 <sys_ipc_try_send>

		if (err < 0) {
  801f85:	83 c4 10             	add    $0x10,%esp
  801f88:	85 c0                	test   %eax,%eax
  801f8a:	79 1e                	jns    801faa <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801f8c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f8f:	75 07                	jne    801f98 <ipc_send+0x3a>
				sys_yield();
  801f91:	e8 24 eb ff ff       	call   800aba <sys_yield>
  801f96:	eb e2                	jmp    801f7a <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f98:	50                   	push   %eax
  801f99:	68 78 27 80 00       	push   $0x802778
  801f9e:	6a 49                	push   $0x49
  801fa0:	68 85 27 80 00       	push   $0x802785
  801fa5:	e8 07 ff ff ff       	call   801eb1 <_panic>
		}

	} while (err < 0);

}
  801faa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fad:	5b                   	pop    %ebx
  801fae:	5e                   	pop    %esi
  801faf:	5f                   	pop    %edi
  801fb0:	5d                   	pop    %ebp
  801fb1:	c3                   	ret    

00801fb2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fb2:	55                   	push   %ebp
  801fb3:	89 e5                	mov    %esp,%ebp
  801fb5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fb8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fbd:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fc0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fc6:	8b 52 50             	mov    0x50(%edx),%edx
  801fc9:	39 ca                	cmp    %ecx,%edx
  801fcb:	75 0d                	jne    801fda <ipc_find_env+0x28>
			return envs[i].env_id;
  801fcd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fd0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fd5:	8b 40 48             	mov    0x48(%eax),%eax
  801fd8:	eb 0f                	jmp    801fe9 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fda:	83 c0 01             	add    $0x1,%eax
  801fdd:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fe2:	75 d9                	jne    801fbd <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fe4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fe9:	5d                   	pop    %ebp
  801fea:	c3                   	ret    

00801feb <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801feb:	55                   	push   %ebp
  801fec:	89 e5                	mov    %esp,%ebp
  801fee:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ff1:	89 d0                	mov    %edx,%eax
  801ff3:	c1 e8 16             	shr    $0x16,%eax
  801ff6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ffd:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802002:	f6 c1 01             	test   $0x1,%cl
  802005:	74 1d                	je     802024 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802007:	c1 ea 0c             	shr    $0xc,%edx
  80200a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802011:	f6 c2 01             	test   $0x1,%dl
  802014:	74 0e                	je     802024 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802016:	c1 ea 0c             	shr    $0xc,%edx
  802019:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802020:	ef 
  802021:	0f b7 c0             	movzwl %ax,%eax
}
  802024:	5d                   	pop    %ebp
  802025:	c3                   	ret    
  802026:	66 90                	xchg   %ax,%ax
  802028:	66 90                	xchg   %ax,%ax
  80202a:	66 90                	xchg   %ax,%ax
  80202c:	66 90                	xchg   %ax,%ax
  80202e:	66 90                	xchg   %ax,%ax

00802030 <__udivdi3>:
  802030:	55                   	push   %ebp
  802031:	57                   	push   %edi
  802032:	56                   	push   %esi
  802033:	53                   	push   %ebx
  802034:	83 ec 1c             	sub    $0x1c,%esp
  802037:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80203b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80203f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802043:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802047:	85 f6                	test   %esi,%esi
  802049:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80204d:	89 ca                	mov    %ecx,%edx
  80204f:	89 f8                	mov    %edi,%eax
  802051:	75 3d                	jne    802090 <__udivdi3+0x60>
  802053:	39 cf                	cmp    %ecx,%edi
  802055:	0f 87 c5 00 00 00    	ja     802120 <__udivdi3+0xf0>
  80205b:	85 ff                	test   %edi,%edi
  80205d:	89 fd                	mov    %edi,%ebp
  80205f:	75 0b                	jne    80206c <__udivdi3+0x3c>
  802061:	b8 01 00 00 00       	mov    $0x1,%eax
  802066:	31 d2                	xor    %edx,%edx
  802068:	f7 f7                	div    %edi
  80206a:	89 c5                	mov    %eax,%ebp
  80206c:	89 c8                	mov    %ecx,%eax
  80206e:	31 d2                	xor    %edx,%edx
  802070:	f7 f5                	div    %ebp
  802072:	89 c1                	mov    %eax,%ecx
  802074:	89 d8                	mov    %ebx,%eax
  802076:	89 cf                	mov    %ecx,%edi
  802078:	f7 f5                	div    %ebp
  80207a:	89 c3                	mov    %eax,%ebx
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
  802090:	39 ce                	cmp    %ecx,%esi
  802092:	77 74                	ja     802108 <__udivdi3+0xd8>
  802094:	0f bd fe             	bsr    %esi,%edi
  802097:	83 f7 1f             	xor    $0x1f,%edi
  80209a:	0f 84 98 00 00 00    	je     802138 <__udivdi3+0x108>
  8020a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020a5:	89 f9                	mov    %edi,%ecx
  8020a7:	89 c5                	mov    %eax,%ebp
  8020a9:	29 fb                	sub    %edi,%ebx
  8020ab:	d3 e6                	shl    %cl,%esi
  8020ad:	89 d9                	mov    %ebx,%ecx
  8020af:	d3 ed                	shr    %cl,%ebp
  8020b1:	89 f9                	mov    %edi,%ecx
  8020b3:	d3 e0                	shl    %cl,%eax
  8020b5:	09 ee                	or     %ebp,%esi
  8020b7:	89 d9                	mov    %ebx,%ecx
  8020b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020bd:	89 d5                	mov    %edx,%ebp
  8020bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020c3:	d3 ed                	shr    %cl,%ebp
  8020c5:	89 f9                	mov    %edi,%ecx
  8020c7:	d3 e2                	shl    %cl,%edx
  8020c9:	89 d9                	mov    %ebx,%ecx
  8020cb:	d3 e8                	shr    %cl,%eax
  8020cd:	09 c2                	or     %eax,%edx
  8020cf:	89 d0                	mov    %edx,%eax
  8020d1:	89 ea                	mov    %ebp,%edx
  8020d3:	f7 f6                	div    %esi
  8020d5:	89 d5                	mov    %edx,%ebp
  8020d7:	89 c3                	mov    %eax,%ebx
  8020d9:	f7 64 24 0c          	mull   0xc(%esp)
  8020dd:	39 d5                	cmp    %edx,%ebp
  8020df:	72 10                	jb     8020f1 <__udivdi3+0xc1>
  8020e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020e5:	89 f9                	mov    %edi,%ecx
  8020e7:	d3 e6                	shl    %cl,%esi
  8020e9:	39 c6                	cmp    %eax,%esi
  8020eb:	73 07                	jae    8020f4 <__udivdi3+0xc4>
  8020ed:	39 d5                	cmp    %edx,%ebp
  8020ef:	75 03                	jne    8020f4 <__udivdi3+0xc4>
  8020f1:	83 eb 01             	sub    $0x1,%ebx
  8020f4:	31 ff                	xor    %edi,%edi
  8020f6:	89 d8                	mov    %ebx,%eax
  8020f8:	89 fa                	mov    %edi,%edx
  8020fa:	83 c4 1c             	add    $0x1c,%esp
  8020fd:	5b                   	pop    %ebx
  8020fe:	5e                   	pop    %esi
  8020ff:	5f                   	pop    %edi
  802100:	5d                   	pop    %ebp
  802101:	c3                   	ret    
  802102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802108:	31 ff                	xor    %edi,%edi
  80210a:	31 db                	xor    %ebx,%ebx
  80210c:	89 d8                	mov    %ebx,%eax
  80210e:	89 fa                	mov    %edi,%edx
  802110:	83 c4 1c             	add    $0x1c,%esp
  802113:	5b                   	pop    %ebx
  802114:	5e                   	pop    %esi
  802115:	5f                   	pop    %edi
  802116:	5d                   	pop    %ebp
  802117:	c3                   	ret    
  802118:	90                   	nop
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	89 d8                	mov    %ebx,%eax
  802122:	f7 f7                	div    %edi
  802124:	31 ff                	xor    %edi,%edi
  802126:	89 c3                	mov    %eax,%ebx
  802128:	89 d8                	mov    %ebx,%eax
  80212a:	89 fa                	mov    %edi,%edx
  80212c:	83 c4 1c             	add    $0x1c,%esp
  80212f:	5b                   	pop    %ebx
  802130:	5e                   	pop    %esi
  802131:	5f                   	pop    %edi
  802132:	5d                   	pop    %ebp
  802133:	c3                   	ret    
  802134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802138:	39 ce                	cmp    %ecx,%esi
  80213a:	72 0c                	jb     802148 <__udivdi3+0x118>
  80213c:	31 db                	xor    %ebx,%ebx
  80213e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802142:	0f 87 34 ff ff ff    	ja     80207c <__udivdi3+0x4c>
  802148:	bb 01 00 00 00       	mov    $0x1,%ebx
  80214d:	e9 2a ff ff ff       	jmp    80207c <__udivdi3+0x4c>
  802152:	66 90                	xchg   %ax,%ax
  802154:	66 90                	xchg   %ax,%ax
  802156:	66 90                	xchg   %ax,%ax
  802158:	66 90                	xchg   %ax,%ax
  80215a:	66 90                	xchg   %ax,%ax
  80215c:	66 90                	xchg   %ax,%ax
  80215e:	66 90                	xchg   %ax,%ax

00802160 <__umoddi3>:
  802160:	55                   	push   %ebp
  802161:	57                   	push   %edi
  802162:	56                   	push   %esi
  802163:	53                   	push   %ebx
  802164:	83 ec 1c             	sub    $0x1c,%esp
  802167:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80216b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80216f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802173:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802177:	85 d2                	test   %edx,%edx
  802179:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80217d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802181:	89 f3                	mov    %esi,%ebx
  802183:	89 3c 24             	mov    %edi,(%esp)
  802186:	89 74 24 04          	mov    %esi,0x4(%esp)
  80218a:	75 1c                	jne    8021a8 <__umoddi3+0x48>
  80218c:	39 f7                	cmp    %esi,%edi
  80218e:	76 50                	jbe    8021e0 <__umoddi3+0x80>
  802190:	89 c8                	mov    %ecx,%eax
  802192:	89 f2                	mov    %esi,%edx
  802194:	f7 f7                	div    %edi
  802196:	89 d0                	mov    %edx,%eax
  802198:	31 d2                	xor    %edx,%edx
  80219a:	83 c4 1c             	add    $0x1c,%esp
  80219d:	5b                   	pop    %ebx
  80219e:	5e                   	pop    %esi
  80219f:	5f                   	pop    %edi
  8021a0:	5d                   	pop    %ebp
  8021a1:	c3                   	ret    
  8021a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021a8:	39 f2                	cmp    %esi,%edx
  8021aa:	89 d0                	mov    %edx,%eax
  8021ac:	77 52                	ja     802200 <__umoddi3+0xa0>
  8021ae:	0f bd ea             	bsr    %edx,%ebp
  8021b1:	83 f5 1f             	xor    $0x1f,%ebp
  8021b4:	75 5a                	jne    802210 <__umoddi3+0xb0>
  8021b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021ba:	0f 82 e0 00 00 00    	jb     8022a0 <__umoddi3+0x140>
  8021c0:	39 0c 24             	cmp    %ecx,(%esp)
  8021c3:	0f 86 d7 00 00 00    	jbe    8022a0 <__umoddi3+0x140>
  8021c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021d1:	83 c4 1c             	add    $0x1c,%esp
  8021d4:	5b                   	pop    %ebx
  8021d5:	5e                   	pop    %esi
  8021d6:	5f                   	pop    %edi
  8021d7:	5d                   	pop    %ebp
  8021d8:	c3                   	ret    
  8021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	85 ff                	test   %edi,%edi
  8021e2:	89 fd                	mov    %edi,%ebp
  8021e4:	75 0b                	jne    8021f1 <__umoddi3+0x91>
  8021e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021eb:	31 d2                	xor    %edx,%edx
  8021ed:	f7 f7                	div    %edi
  8021ef:	89 c5                	mov    %eax,%ebp
  8021f1:	89 f0                	mov    %esi,%eax
  8021f3:	31 d2                	xor    %edx,%edx
  8021f5:	f7 f5                	div    %ebp
  8021f7:	89 c8                	mov    %ecx,%eax
  8021f9:	f7 f5                	div    %ebp
  8021fb:	89 d0                	mov    %edx,%eax
  8021fd:	eb 99                	jmp    802198 <__umoddi3+0x38>
  8021ff:	90                   	nop
  802200:	89 c8                	mov    %ecx,%eax
  802202:	89 f2                	mov    %esi,%edx
  802204:	83 c4 1c             	add    $0x1c,%esp
  802207:	5b                   	pop    %ebx
  802208:	5e                   	pop    %esi
  802209:	5f                   	pop    %edi
  80220a:	5d                   	pop    %ebp
  80220b:	c3                   	ret    
  80220c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802210:	8b 34 24             	mov    (%esp),%esi
  802213:	bf 20 00 00 00       	mov    $0x20,%edi
  802218:	89 e9                	mov    %ebp,%ecx
  80221a:	29 ef                	sub    %ebp,%edi
  80221c:	d3 e0                	shl    %cl,%eax
  80221e:	89 f9                	mov    %edi,%ecx
  802220:	89 f2                	mov    %esi,%edx
  802222:	d3 ea                	shr    %cl,%edx
  802224:	89 e9                	mov    %ebp,%ecx
  802226:	09 c2                	or     %eax,%edx
  802228:	89 d8                	mov    %ebx,%eax
  80222a:	89 14 24             	mov    %edx,(%esp)
  80222d:	89 f2                	mov    %esi,%edx
  80222f:	d3 e2                	shl    %cl,%edx
  802231:	89 f9                	mov    %edi,%ecx
  802233:	89 54 24 04          	mov    %edx,0x4(%esp)
  802237:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80223b:	d3 e8                	shr    %cl,%eax
  80223d:	89 e9                	mov    %ebp,%ecx
  80223f:	89 c6                	mov    %eax,%esi
  802241:	d3 e3                	shl    %cl,%ebx
  802243:	89 f9                	mov    %edi,%ecx
  802245:	89 d0                	mov    %edx,%eax
  802247:	d3 e8                	shr    %cl,%eax
  802249:	89 e9                	mov    %ebp,%ecx
  80224b:	09 d8                	or     %ebx,%eax
  80224d:	89 d3                	mov    %edx,%ebx
  80224f:	89 f2                	mov    %esi,%edx
  802251:	f7 34 24             	divl   (%esp)
  802254:	89 d6                	mov    %edx,%esi
  802256:	d3 e3                	shl    %cl,%ebx
  802258:	f7 64 24 04          	mull   0x4(%esp)
  80225c:	39 d6                	cmp    %edx,%esi
  80225e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802262:	89 d1                	mov    %edx,%ecx
  802264:	89 c3                	mov    %eax,%ebx
  802266:	72 08                	jb     802270 <__umoddi3+0x110>
  802268:	75 11                	jne    80227b <__umoddi3+0x11b>
  80226a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80226e:	73 0b                	jae    80227b <__umoddi3+0x11b>
  802270:	2b 44 24 04          	sub    0x4(%esp),%eax
  802274:	1b 14 24             	sbb    (%esp),%edx
  802277:	89 d1                	mov    %edx,%ecx
  802279:	89 c3                	mov    %eax,%ebx
  80227b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80227f:	29 da                	sub    %ebx,%edx
  802281:	19 ce                	sbb    %ecx,%esi
  802283:	89 f9                	mov    %edi,%ecx
  802285:	89 f0                	mov    %esi,%eax
  802287:	d3 e0                	shl    %cl,%eax
  802289:	89 e9                	mov    %ebp,%ecx
  80228b:	d3 ea                	shr    %cl,%edx
  80228d:	89 e9                	mov    %ebp,%ecx
  80228f:	d3 ee                	shr    %cl,%esi
  802291:	09 d0                	or     %edx,%eax
  802293:	89 f2                	mov    %esi,%edx
  802295:	83 c4 1c             	add    $0x1c,%esp
  802298:	5b                   	pop    %ebx
  802299:	5e                   	pop    %esi
  80229a:	5f                   	pop    %edi
  80229b:	5d                   	pop    %ebp
  80229c:	c3                   	ret    
  80229d:	8d 76 00             	lea    0x0(%esi),%esi
  8022a0:	29 f9                	sub    %edi,%ecx
  8022a2:	19 d6                	sbb    %edx,%esi
  8022a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022ac:	e9 18 ff ff ff       	jmp    8021c9 <__umoddi3+0x69>
