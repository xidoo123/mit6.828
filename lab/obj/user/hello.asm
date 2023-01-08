
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
  800039:	68 40 22 80 00       	push   $0x802240
  80003e:	e8 0e 01 00 00       	call   800151 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 08 40 80 00       	mov    0x804008,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 4e 22 80 00       	push   $0x80224e
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
  8000aa:	e8 05 0e 00 00       	call   800eb4 <close_all>
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
  8001b4:	e8 f7 1d 00 00       	call   801fb0 <__udivdi3>
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
  8001f7:	e8 e4 1e 00 00       	call   8020e0 <__umoddi3>
  8001fc:	83 c4 14             	add    $0x14,%esp
  8001ff:	0f be 80 6f 22 80 00 	movsbl 0x80226f(%eax),%eax
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
  8002fb:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
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
  8003bf:	8b 14 85 20 25 80 00 	mov    0x802520(,%eax,4),%edx
  8003c6:	85 d2                	test   %edx,%edx
  8003c8:	75 18                	jne    8003e2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003ca:	50                   	push   %eax
  8003cb:	68 87 22 80 00       	push   $0x802287
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
  8003e3:	68 55 26 80 00       	push   $0x802655
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
  800407:	b8 80 22 80 00       	mov    $0x802280,%eax
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
  800a82:	68 7f 25 80 00       	push   $0x80257f
  800a87:	6a 23                	push   $0x23
  800a89:	68 9c 25 80 00       	push   $0x80259c
  800a8e:	e8 9a 13 00 00       	call   801e2d <_panic>

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
  800b03:	68 7f 25 80 00       	push   $0x80257f
  800b08:	6a 23                	push   $0x23
  800b0a:	68 9c 25 80 00       	push   $0x80259c
  800b0f:	e8 19 13 00 00       	call   801e2d <_panic>

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
  800b45:	68 7f 25 80 00       	push   $0x80257f
  800b4a:	6a 23                	push   $0x23
  800b4c:	68 9c 25 80 00       	push   $0x80259c
  800b51:	e8 d7 12 00 00       	call   801e2d <_panic>

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
  800b87:	68 7f 25 80 00       	push   $0x80257f
  800b8c:	6a 23                	push   $0x23
  800b8e:	68 9c 25 80 00       	push   $0x80259c
  800b93:	e8 95 12 00 00       	call   801e2d <_panic>

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
  800bc9:	68 7f 25 80 00       	push   $0x80257f
  800bce:	6a 23                	push   $0x23
  800bd0:	68 9c 25 80 00       	push   $0x80259c
  800bd5:	e8 53 12 00 00       	call   801e2d <_panic>

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
  800c0b:	68 7f 25 80 00       	push   $0x80257f
  800c10:	6a 23                	push   $0x23
  800c12:	68 9c 25 80 00       	push   $0x80259c
  800c17:	e8 11 12 00 00       	call   801e2d <_panic>

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
  800c4d:	68 7f 25 80 00       	push   $0x80257f
  800c52:	6a 23                	push   $0x23
  800c54:	68 9c 25 80 00       	push   $0x80259c
  800c59:	e8 cf 11 00 00       	call   801e2d <_panic>

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
  800cb1:	68 7f 25 80 00       	push   $0x80257f
  800cb6:	6a 23                	push   $0x23
  800cb8:	68 9c 25 80 00       	push   $0x80259c
  800cbd:	e8 6b 11 00 00       	call   801e2d <_panic>

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

00800ce9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800cec:	8b 45 08             	mov    0x8(%ebp),%eax
  800cef:	05 00 00 00 30       	add    $0x30000000,%eax
  800cf4:	c1 e8 0c             	shr    $0xc,%eax
}
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800cfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cff:	05 00 00 00 30       	add    $0x30000000,%eax
  800d04:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d09:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d16:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d1b:	89 c2                	mov    %eax,%edx
  800d1d:	c1 ea 16             	shr    $0x16,%edx
  800d20:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d27:	f6 c2 01             	test   $0x1,%dl
  800d2a:	74 11                	je     800d3d <fd_alloc+0x2d>
  800d2c:	89 c2                	mov    %eax,%edx
  800d2e:	c1 ea 0c             	shr    $0xc,%edx
  800d31:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d38:	f6 c2 01             	test   $0x1,%dl
  800d3b:	75 09                	jne    800d46 <fd_alloc+0x36>
			*fd_store = fd;
  800d3d:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d44:	eb 17                	jmp    800d5d <fd_alloc+0x4d>
  800d46:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d4b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d50:	75 c9                	jne    800d1b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d52:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d58:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d65:	83 f8 1f             	cmp    $0x1f,%eax
  800d68:	77 36                	ja     800da0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d6a:	c1 e0 0c             	shl    $0xc,%eax
  800d6d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d72:	89 c2                	mov    %eax,%edx
  800d74:	c1 ea 16             	shr    $0x16,%edx
  800d77:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d7e:	f6 c2 01             	test   $0x1,%dl
  800d81:	74 24                	je     800da7 <fd_lookup+0x48>
  800d83:	89 c2                	mov    %eax,%edx
  800d85:	c1 ea 0c             	shr    $0xc,%edx
  800d88:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d8f:	f6 c2 01             	test   $0x1,%dl
  800d92:	74 1a                	je     800dae <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800d94:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d97:	89 02                	mov    %eax,(%edx)
	return 0;
  800d99:	b8 00 00 00 00       	mov    $0x0,%eax
  800d9e:	eb 13                	jmp    800db3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800da0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800da5:	eb 0c                	jmp    800db3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800da7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dac:	eb 05                	jmp    800db3 <fd_lookup+0x54>
  800dae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    

00800db5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	83 ec 08             	sub    $0x8,%esp
  800dbb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dbe:	ba 28 26 80 00       	mov    $0x802628,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800dc3:	eb 13                	jmp    800dd8 <dev_lookup+0x23>
  800dc5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800dc8:	39 08                	cmp    %ecx,(%eax)
  800dca:	75 0c                	jne    800dd8 <dev_lookup+0x23>
			*dev = devtab[i];
  800dcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcf:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dd1:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd6:	eb 2e                	jmp    800e06 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800dd8:	8b 02                	mov    (%edx),%eax
  800dda:	85 c0                	test   %eax,%eax
  800ddc:	75 e7                	jne    800dc5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800dde:	a1 08 40 80 00       	mov    0x804008,%eax
  800de3:	8b 40 48             	mov    0x48(%eax),%eax
  800de6:	83 ec 04             	sub    $0x4,%esp
  800de9:	51                   	push   %ecx
  800dea:	50                   	push   %eax
  800deb:	68 ac 25 80 00       	push   $0x8025ac
  800df0:	e8 5c f3 ff ff       	call   800151 <cprintf>
	*dev = 0;
  800df5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800df8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800dfe:	83 c4 10             	add    $0x10,%esp
  800e01:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e06:	c9                   	leave  
  800e07:	c3                   	ret    

00800e08 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
  800e0b:	56                   	push   %esi
  800e0c:	53                   	push   %ebx
  800e0d:	83 ec 10             	sub    $0x10,%esp
  800e10:	8b 75 08             	mov    0x8(%ebp),%esi
  800e13:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e16:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e19:	50                   	push   %eax
  800e1a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e20:	c1 e8 0c             	shr    $0xc,%eax
  800e23:	50                   	push   %eax
  800e24:	e8 36 ff ff ff       	call   800d5f <fd_lookup>
  800e29:	83 c4 08             	add    $0x8,%esp
  800e2c:	85 c0                	test   %eax,%eax
  800e2e:	78 05                	js     800e35 <fd_close+0x2d>
	    || fd != fd2)
  800e30:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e33:	74 0c                	je     800e41 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e35:	84 db                	test   %bl,%bl
  800e37:	ba 00 00 00 00       	mov    $0x0,%edx
  800e3c:	0f 44 c2             	cmove  %edx,%eax
  800e3f:	eb 41                	jmp    800e82 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e41:	83 ec 08             	sub    $0x8,%esp
  800e44:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e47:	50                   	push   %eax
  800e48:	ff 36                	pushl  (%esi)
  800e4a:	e8 66 ff ff ff       	call   800db5 <dev_lookup>
  800e4f:	89 c3                	mov    %eax,%ebx
  800e51:	83 c4 10             	add    $0x10,%esp
  800e54:	85 c0                	test   %eax,%eax
  800e56:	78 1a                	js     800e72 <fd_close+0x6a>
		if (dev->dev_close)
  800e58:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e5b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e5e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e63:	85 c0                	test   %eax,%eax
  800e65:	74 0b                	je     800e72 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800e67:	83 ec 0c             	sub    $0xc,%esp
  800e6a:	56                   	push   %esi
  800e6b:	ff d0                	call   *%eax
  800e6d:	89 c3                	mov    %eax,%ebx
  800e6f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e72:	83 ec 08             	sub    $0x8,%esp
  800e75:	56                   	push   %esi
  800e76:	6a 00                	push   $0x0
  800e78:	e8 e1 fc ff ff       	call   800b5e <sys_page_unmap>
	return r;
  800e7d:	83 c4 10             	add    $0x10,%esp
  800e80:	89 d8                	mov    %ebx,%eax
}
  800e82:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e85:	5b                   	pop    %ebx
  800e86:	5e                   	pop    %esi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e92:	50                   	push   %eax
  800e93:	ff 75 08             	pushl  0x8(%ebp)
  800e96:	e8 c4 fe ff ff       	call   800d5f <fd_lookup>
  800e9b:	83 c4 08             	add    $0x8,%esp
  800e9e:	85 c0                	test   %eax,%eax
  800ea0:	78 10                	js     800eb2 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ea2:	83 ec 08             	sub    $0x8,%esp
  800ea5:	6a 01                	push   $0x1
  800ea7:	ff 75 f4             	pushl  -0xc(%ebp)
  800eaa:	e8 59 ff ff ff       	call   800e08 <fd_close>
  800eaf:	83 c4 10             	add    $0x10,%esp
}
  800eb2:	c9                   	leave  
  800eb3:	c3                   	ret    

00800eb4 <close_all>:

void
close_all(void)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	53                   	push   %ebx
  800eb8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ebb:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ec0:	83 ec 0c             	sub    $0xc,%esp
  800ec3:	53                   	push   %ebx
  800ec4:	e8 c0 ff ff ff       	call   800e89 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ec9:	83 c3 01             	add    $0x1,%ebx
  800ecc:	83 c4 10             	add    $0x10,%esp
  800ecf:	83 fb 20             	cmp    $0x20,%ebx
  800ed2:	75 ec                	jne    800ec0 <close_all+0xc>
		close(i);
}
  800ed4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ed7:	c9                   	leave  
  800ed8:	c3                   	ret    

00800ed9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ed9:	55                   	push   %ebp
  800eda:	89 e5                	mov    %esp,%ebp
  800edc:	57                   	push   %edi
  800edd:	56                   	push   %esi
  800ede:	53                   	push   %ebx
  800edf:	83 ec 2c             	sub    $0x2c,%esp
  800ee2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ee5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ee8:	50                   	push   %eax
  800ee9:	ff 75 08             	pushl  0x8(%ebp)
  800eec:	e8 6e fe ff ff       	call   800d5f <fd_lookup>
  800ef1:	83 c4 08             	add    $0x8,%esp
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	0f 88 c1 00 00 00    	js     800fbd <dup+0xe4>
		return r;
	close(newfdnum);
  800efc:	83 ec 0c             	sub    $0xc,%esp
  800eff:	56                   	push   %esi
  800f00:	e8 84 ff ff ff       	call   800e89 <close>

	newfd = INDEX2FD(newfdnum);
  800f05:	89 f3                	mov    %esi,%ebx
  800f07:	c1 e3 0c             	shl    $0xc,%ebx
  800f0a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f10:	83 c4 04             	add    $0x4,%esp
  800f13:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f16:	e8 de fd ff ff       	call   800cf9 <fd2data>
  800f1b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f1d:	89 1c 24             	mov    %ebx,(%esp)
  800f20:	e8 d4 fd ff ff       	call   800cf9 <fd2data>
  800f25:	83 c4 10             	add    $0x10,%esp
  800f28:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f2b:	89 f8                	mov    %edi,%eax
  800f2d:	c1 e8 16             	shr    $0x16,%eax
  800f30:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f37:	a8 01                	test   $0x1,%al
  800f39:	74 37                	je     800f72 <dup+0x99>
  800f3b:	89 f8                	mov    %edi,%eax
  800f3d:	c1 e8 0c             	shr    $0xc,%eax
  800f40:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f47:	f6 c2 01             	test   $0x1,%dl
  800f4a:	74 26                	je     800f72 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f4c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f53:	83 ec 0c             	sub    $0xc,%esp
  800f56:	25 07 0e 00 00       	and    $0xe07,%eax
  800f5b:	50                   	push   %eax
  800f5c:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f5f:	6a 00                	push   $0x0
  800f61:	57                   	push   %edi
  800f62:	6a 00                	push   $0x0
  800f64:	e8 b3 fb ff ff       	call   800b1c <sys_page_map>
  800f69:	89 c7                	mov    %eax,%edi
  800f6b:	83 c4 20             	add    $0x20,%esp
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	78 2e                	js     800fa0 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f72:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f75:	89 d0                	mov    %edx,%eax
  800f77:	c1 e8 0c             	shr    $0xc,%eax
  800f7a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f81:	83 ec 0c             	sub    $0xc,%esp
  800f84:	25 07 0e 00 00       	and    $0xe07,%eax
  800f89:	50                   	push   %eax
  800f8a:	53                   	push   %ebx
  800f8b:	6a 00                	push   $0x0
  800f8d:	52                   	push   %edx
  800f8e:	6a 00                	push   $0x0
  800f90:	e8 87 fb ff ff       	call   800b1c <sys_page_map>
  800f95:	89 c7                	mov    %eax,%edi
  800f97:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800f9a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f9c:	85 ff                	test   %edi,%edi
  800f9e:	79 1d                	jns    800fbd <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fa0:	83 ec 08             	sub    $0x8,%esp
  800fa3:	53                   	push   %ebx
  800fa4:	6a 00                	push   $0x0
  800fa6:	e8 b3 fb ff ff       	call   800b5e <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fab:	83 c4 08             	add    $0x8,%esp
  800fae:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fb1:	6a 00                	push   $0x0
  800fb3:	e8 a6 fb ff ff       	call   800b5e <sys_page_unmap>
	return r;
  800fb8:	83 c4 10             	add    $0x10,%esp
  800fbb:	89 f8                	mov    %edi,%eax
}
  800fbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc0:	5b                   	pop    %ebx
  800fc1:	5e                   	pop    %esi
  800fc2:	5f                   	pop    %edi
  800fc3:	5d                   	pop    %ebp
  800fc4:	c3                   	ret    

00800fc5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fc5:	55                   	push   %ebp
  800fc6:	89 e5                	mov    %esp,%ebp
  800fc8:	53                   	push   %ebx
  800fc9:	83 ec 14             	sub    $0x14,%esp
  800fcc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fcf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fd2:	50                   	push   %eax
  800fd3:	53                   	push   %ebx
  800fd4:	e8 86 fd ff ff       	call   800d5f <fd_lookup>
  800fd9:	83 c4 08             	add    $0x8,%esp
  800fdc:	89 c2                	mov    %eax,%edx
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	78 6d                	js     80104f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800fe2:	83 ec 08             	sub    $0x8,%esp
  800fe5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe8:	50                   	push   %eax
  800fe9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fec:	ff 30                	pushl  (%eax)
  800fee:	e8 c2 fd ff ff       	call   800db5 <dev_lookup>
  800ff3:	83 c4 10             	add    $0x10,%esp
  800ff6:	85 c0                	test   %eax,%eax
  800ff8:	78 4c                	js     801046 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800ffa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ffd:	8b 42 08             	mov    0x8(%edx),%eax
  801000:	83 e0 03             	and    $0x3,%eax
  801003:	83 f8 01             	cmp    $0x1,%eax
  801006:	75 21                	jne    801029 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801008:	a1 08 40 80 00       	mov    0x804008,%eax
  80100d:	8b 40 48             	mov    0x48(%eax),%eax
  801010:	83 ec 04             	sub    $0x4,%esp
  801013:	53                   	push   %ebx
  801014:	50                   	push   %eax
  801015:	68 ed 25 80 00       	push   $0x8025ed
  80101a:	e8 32 f1 ff ff       	call   800151 <cprintf>
		return -E_INVAL;
  80101f:	83 c4 10             	add    $0x10,%esp
  801022:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801027:	eb 26                	jmp    80104f <read+0x8a>
	}
	if (!dev->dev_read)
  801029:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80102c:	8b 40 08             	mov    0x8(%eax),%eax
  80102f:	85 c0                	test   %eax,%eax
  801031:	74 17                	je     80104a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801033:	83 ec 04             	sub    $0x4,%esp
  801036:	ff 75 10             	pushl  0x10(%ebp)
  801039:	ff 75 0c             	pushl  0xc(%ebp)
  80103c:	52                   	push   %edx
  80103d:	ff d0                	call   *%eax
  80103f:	89 c2                	mov    %eax,%edx
  801041:	83 c4 10             	add    $0x10,%esp
  801044:	eb 09                	jmp    80104f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801046:	89 c2                	mov    %eax,%edx
  801048:	eb 05                	jmp    80104f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80104a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80104f:	89 d0                	mov    %edx,%eax
  801051:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801054:	c9                   	leave  
  801055:	c3                   	ret    

00801056 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	57                   	push   %edi
  80105a:	56                   	push   %esi
  80105b:	53                   	push   %ebx
  80105c:	83 ec 0c             	sub    $0xc,%esp
  80105f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801062:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801065:	bb 00 00 00 00       	mov    $0x0,%ebx
  80106a:	eb 21                	jmp    80108d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80106c:	83 ec 04             	sub    $0x4,%esp
  80106f:	89 f0                	mov    %esi,%eax
  801071:	29 d8                	sub    %ebx,%eax
  801073:	50                   	push   %eax
  801074:	89 d8                	mov    %ebx,%eax
  801076:	03 45 0c             	add    0xc(%ebp),%eax
  801079:	50                   	push   %eax
  80107a:	57                   	push   %edi
  80107b:	e8 45 ff ff ff       	call   800fc5 <read>
		if (m < 0)
  801080:	83 c4 10             	add    $0x10,%esp
  801083:	85 c0                	test   %eax,%eax
  801085:	78 10                	js     801097 <readn+0x41>
			return m;
		if (m == 0)
  801087:	85 c0                	test   %eax,%eax
  801089:	74 0a                	je     801095 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80108b:	01 c3                	add    %eax,%ebx
  80108d:	39 f3                	cmp    %esi,%ebx
  80108f:	72 db                	jb     80106c <readn+0x16>
  801091:	89 d8                	mov    %ebx,%eax
  801093:	eb 02                	jmp    801097 <readn+0x41>
  801095:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801097:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80109a:	5b                   	pop    %ebx
  80109b:	5e                   	pop    %esi
  80109c:	5f                   	pop    %edi
  80109d:	5d                   	pop    %ebp
  80109e:	c3                   	ret    

0080109f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80109f:	55                   	push   %ebp
  8010a0:	89 e5                	mov    %esp,%ebp
  8010a2:	53                   	push   %ebx
  8010a3:	83 ec 14             	sub    $0x14,%esp
  8010a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010ac:	50                   	push   %eax
  8010ad:	53                   	push   %ebx
  8010ae:	e8 ac fc ff ff       	call   800d5f <fd_lookup>
  8010b3:	83 c4 08             	add    $0x8,%esp
  8010b6:	89 c2                	mov    %eax,%edx
  8010b8:	85 c0                	test   %eax,%eax
  8010ba:	78 68                	js     801124 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010bc:	83 ec 08             	sub    $0x8,%esp
  8010bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010c2:	50                   	push   %eax
  8010c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010c6:	ff 30                	pushl  (%eax)
  8010c8:	e8 e8 fc ff ff       	call   800db5 <dev_lookup>
  8010cd:	83 c4 10             	add    $0x10,%esp
  8010d0:	85 c0                	test   %eax,%eax
  8010d2:	78 47                	js     80111b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010d7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8010db:	75 21                	jne    8010fe <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8010dd:	a1 08 40 80 00       	mov    0x804008,%eax
  8010e2:	8b 40 48             	mov    0x48(%eax),%eax
  8010e5:	83 ec 04             	sub    $0x4,%esp
  8010e8:	53                   	push   %ebx
  8010e9:	50                   	push   %eax
  8010ea:	68 09 26 80 00       	push   $0x802609
  8010ef:	e8 5d f0 ff ff       	call   800151 <cprintf>
		return -E_INVAL;
  8010f4:	83 c4 10             	add    $0x10,%esp
  8010f7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010fc:	eb 26                	jmp    801124 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8010fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801101:	8b 52 0c             	mov    0xc(%edx),%edx
  801104:	85 d2                	test   %edx,%edx
  801106:	74 17                	je     80111f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801108:	83 ec 04             	sub    $0x4,%esp
  80110b:	ff 75 10             	pushl  0x10(%ebp)
  80110e:	ff 75 0c             	pushl  0xc(%ebp)
  801111:	50                   	push   %eax
  801112:	ff d2                	call   *%edx
  801114:	89 c2                	mov    %eax,%edx
  801116:	83 c4 10             	add    $0x10,%esp
  801119:	eb 09                	jmp    801124 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80111b:	89 c2                	mov    %eax,%edx
  80111d:	eb 05                	jmp    801124 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80111f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801124:	89 d0                	mov    %edx,%eax
  801126:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801129:	c9                   	leave  
  80112a:	c3                   	ret    

0080112b <seek>:

int
seek(int fdnum, off_t offset)
{
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
  80112e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801131:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801134:	50                   	push   %eax
  801135:	ff 75 08             	pushl  0x8(%ebp)
  801138:	e8 22 fc ff ff       	call   800d5f <fd_lookup>
  80113d:	83 c4 08             	add    $0x8,%esp
  801140:	85 c0                	test   %eax,%eax
  801142:	78 0e                	js     801152 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801144:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801147:	8b 55 0c             	mov    0xc(%ebp),%edx
  80114a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80114d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801152:	c9                   	leave  
  801153:	c3                   	ret    

00801154 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801154:	55                   	push   %ebp
  801155:	89 e5                	mov    %esp,%ebp
  801157:	53                   	push   %ebx
  801158:	83 ec 14             	sub    $0x14,%esp
  80115b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80115e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801161:	50                   	push   %eax
  801162:	53                   	push   %ebx
  801163:	e8 f7 fb ff ff       	call   800d5f <fd_lookup>
  801168:	83 c4 08             	add    $0x8,%esp
  80116b:	89 c2                	mov    %eax,%edx
  80116d:	85 c0                	test   %eax,%eax
  80116f:	78 65                	js     8011d6 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801171:	83 ec 08             	sub    $0x8,%esp
  801174:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801177:	50                   	push   %eax
  801178:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80117b:	ff 30                	pushl  (%eax)
  80117d:	e8 33 fc ff ff       	call   800db5 <dev_lookup>
  801182:	83 c4 10             	add    $0x10,%esp
  801185:	85 c0                	test   %eax,%eax
  801187:	78 44                	js     8011cd <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801189:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80118c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801190:	75 21                	jne    8011b3 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801192:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801197:	8b 40 48             	mov    0x48(%eax),%eax
  80119a:	83 ec 04             	sub    $0x4,%esp
  80119d:	53                   	push   %ebx
  80119e:	50                   	push   %eax
  80119f:	68 cc 25 80 00       	push   $0x8025cc
  8011a4:	e8 a8 ef ff ff       	call   800151 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011a9:	83 c4 10             	add    $0x10,%esp
  8011ac:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011b1:	eb 23                	jmp    8011d6 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011b6:	8b 52 18             	mov    0x18(%edx),%edx
  8011b9:	85 d2                	test   %edx,%edx
  8011bb:	74 14                	je     8011d1 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011bd:	83 ec 08             	sub    $0x8,%esp
  8011c0:	ff 75 0c             	pushl  0xc(%ebp)
  8011c3:	50                   	push   %eax
  8011c4:	ff d2                	call   *%edx
  8011c6:	89 c2                	mov    %eax,%edx
  8011c8:	83 c4 10             	add    $0x10,%esp
  8011cb:	eb 09                	jmp    8011d6 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011cd:	89 c2                	mov    %eax,%edx
  8011cf:	eb 05                	jmp    8011d6 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011d1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8011d6:	89 d0                	mov    %edx,%eax
  8011d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011db:	c9                   	leave  
  8011dc:	c3                   	ret    

008011dd <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
  8011e0:	53                   	push   %ebx
  8011e1:	83 ec 14             	sub    $0x14,%esp
  8011e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ea:	50                   	push   %eax
  8011eb:	ff 75 08             	pushl  0x8(%ebp)
  8011ee:	e8 6c fb ff ff       	call   800d5f <fd_lookup>
  8011f3:	83 c4 08             	add    $0x8,%esp
  8011f6:	89 c2                	mov    %eax,%edx
  8011f8:	85 c0                	test   %eax,%eax
  8011fa:	78 58                	js     801254 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011fc:	83 ec 08             	sub    $0x8,%esp
  8011ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801202:	50                   	push   %eax
  801203:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801206:	ff 30                	pushl  (%eax)
  801208:	e8 a8 fb ff ff       	call   800db5 <dev_lookup>
  80120d:	83 c4 10             	add    $0x10,%esp
  801210:	85 c0                	test   %eax,%eax
  801212:	78 37                	js     80124b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801214:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801217:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80121b:	74 32                	je     80124f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80121d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801220:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801227:	00 00 00 
	stat->st_isdir = 0;
  80122a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801231:	00 00 00 
	stat->st_dev = dev;
  801234:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80123a:	83 ec 08             	sub    $0x8,%esp
  80123d:	53                   	push   %ebx
  80123e:	ff 75 f0             	pushl  -0x10(%ebp)
  801241:	ff 50 14             	call   *0x14(%eax)
  801244:	89 c2                	mov    %eax,%edx
  801246:	83 c4 10             	add    $0x10,%esp
  801249:	eb 09                	jmp    801254 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80124b:	89 c2                	mov    %eax,%edx
  80124d:	eb 05                	jmp    801254 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80124f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801254:	89 d0                	mov    %edx,%eax
  801256:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801259:	c9                   	leave  
  80125a:	c3                   	ret    

0080125b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80125b:	55                   	push   %ebp
  80125c:	89 e5                	mov    %esp,%ebp
  80125e:	56                   	push   %esi
  80125f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801260:	83 ec 08             	sub    $0x8,%esp
  801263:	6a 00                	push   $0x0
  801265:	ff 75 08             	pushl  0x8(%ebp)
  801268:	e8 d6 01 00 00       	call   801443 <open>
  80126d:	89 c3                	mov    %eax,%ebx
  80126f:	83 c4 10             	add    $0x10,%esp
  801272:	85 c0                	test   %eax,%eax
  801274:	78 1b                	js     801291 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801276:	83 ec 08             	sub    $0x8,%esp
  801279:	ff 75 0c             	pushl  0xc(%ebp)
  80127c:	50                   	push   %eax
  80127d:	e8 5b ff ff ff       	call   8011dd <fstat>
  801282:	89 c6                	mov    %eax,%esi
	close(fd);
  801284:	89 1c 24             	mov    %ebx,(%esp)
  801287:	e8 fd fb ff ff       	call   800e89 <close>
	return r;
  80128c:	83 c4 10             	add    $0x10,%esp
  80128f:	89 f0                	mov    %esi,%eax
}
  801291:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801294:	5b                   	pop    %ebx
  801295:	5e                   	pop    %esi
  801296:	5d                   	pop    %ebp
  801297:	c3                   	ret    

00801298 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	56                   	push   %esi
  80129c:	53                   	push   %ebx
  80129d:	89 c6                	mov    %eax,%esi
  80129f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012a1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012a8:	75 12                	jne    8012bc <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012aa:	83 ec 0c             	sub    $0xc,%esp
  8012ad:	6a 01                	push   $0x1
  8012af:	e8 7a 0c 00 00       	call   801f2e <ipc_find_env>
  8012b4:	a3 00 40 80 00       	mov    %eax,0x804000
  8012b9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012bc:	6a 07                	push   $0x7
  8012be:	68 00 50 80 00       	push   $0x805000
  8012c3:	56                   	push   %esi
  8012c4:	ff 35 00 40 80 00    	pushl  0x804000
  8012ca:	e8 0b 0c 00 00       	call   801eda <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012cf:	83 c4 0c             	add    $0xc,%esp
  8012d2:	6a 00                	push   $0x0
  8012d4:	53                   	push   %ebx
  8012d5:	6a 00                	push   $0x0
  8012d7:	e8 97 0b 00 00       	call   801e73 <ipc_recv>
}
  8012dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012df:	5b                   	pop    %ebx
  8012e0:	5e                   	pop    %esi
  8012e1:	5d                   	pop    %ebp
  8012e2:	c3                   	ret    

008012e3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8012e3:	55                   	push   %ebp
  8012e4:	89 e5                	mov    %esp,%ebp
  8012e6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8012e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ec:	8b 40 0c             	mov    0xc(%eax),%eax
  8012ef:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8012f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012f7:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8012fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801301:	b8 02 00 00 00       	mov    $0x2,%eax
  801306:	e8 8d ff ff ff       	call   801298 <fsipc>
}
  80130b:	c9                   	leave  
  80130c:	c3                   	ret    

0080130d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80130d:	55                   	push   %ebp
  80130e:	89 e5                	mov    %esp,%ebp
  801310:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801313:	8b 45 08             	mov    0x8(%ebp),%eax
  801316:	8b 40 0c             	mov    0xc(%eax),%eax
  801319:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80131e:	ba 00 00 00 00       	mov    $0x0,%edx
  801323:	b8 06 00 00 00       	mov    $0x6,%eax
  801328:	e8 6b ff ff ff       	call   801298 <fsipc>
}
  80132d:	c9                   	leave  
  80132e:	c3                   	ret    

0080132f <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80132f:	55                   	push   %ebp
  801330:	89 e5                	mov    %esp,%ebp
  801332:	53                   	push   %ebx
  801333:	83 ec 04             	sub    $0x4,%esp
  801336:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801339:	8b 45 08             	mov    0x8(%ebp),%eax
  80133c:	8b 40 0c             	mov    0xc(%eax),%eax
  80133f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801344:	ba 00 00 00 00       	mov    $0x0,%edx
  801349:	b8 05 00 00 00       	mov    $0x5,%eax
  80134e:	e8 45 ff ff ff       	call   801298 <fsipc>
  801353:	85 c0                	test   %eax,%eax
  801355:	78 2c                	js     801383 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801357:	83 ec 08             	sub    $0x8,%esp
  80135a:	68 00 50 80 00       	push   $0x805000
  80135f:	53                   	push   %ebx
  801360:	e8 71 f3 ff ff       	call   8006d6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801365:	a1 80 50 80 00       	mov    0x805080,%eax
  80136a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801370:	a1 84 50 80 00       	mov    0x805084,%eax
  801375:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80137b:	83 c4 10             	add    $0x10,%esp
  80137e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801383:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801386:	c9                   	leave  
  801387:	c3                   	ret    

00801388 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	83 ec 0c             	sub    $0xc,%esp
  80138e:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801391:	8b 55 08             	mov    0x8(%ebp),%edx
  801394:	8b 52 0c             	mov    0xc(%edx),%edx
  801397:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80139d:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8013a2:	50                   	push   %eax
  8013a3:	ff 75 0c             	pushl  0xc(%ebp)
  8013a6:	68 08 50 80 00       	push   $0x805008
  8013ab:	e8 b8 f4 ff ff       	call   800868 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8013b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b5:	b8 04 00 00 00       	mov    $0x4,%eax
  8013ba:	e8 d9 fe ff ff       	call   801298 <fsipc>

}
  8013bf:	c9                   	leave  
  8013c0:	c3                   	ret    

008013c1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013c1:	55                   	push   %ebp
  8013c2:	89 e5                	mov    %esp,%ebp
  8013c4:	56                   	push   %esi
  8013c5:	53                   	push   %ebx
  8013c6:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013cc:	8b 40 0c             	mov    0xc(%eax),%eax
  8013cf:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013d4:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013da:	ba 00 00 00 00       	mov    $0x0,%edx
  8013df:	b8 03 00 00 00       	mov    $0x3,%eax
  8013e4:	e8 af fe ff ff       	call   801298 <fsipc>
  8013e9:	89 c3                	mov    %eax,%ebx
  8013eb:	85 c0                	test   %eax,%eax
  8013ed:	78 4b                	js     80143a <devfile_read+0x79>
		return r;
	assert(r <= n);
  8013ef:	39 c6                	cmp    %eax,%esi
  8013f1:	73 16                	jae    801409 <devfile_read+0x48>
  8013f3:	68 3c 26 80 00       	push   $0x80263c
  8013f8:	68 43 26 80 00       	push   $0x802643
  8013fd:	6a 7c                	push   $0x7c
  8013ff:	68 58 26 80 00       	push   $0x802658
  801404:	e8 24 0a 00 00       	call   801e2d <_panic>
	assert(r <= PGSIZE);
  801409:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80140e:	7e 16                	jle    801426 <devfile_read+0x65>
  801410:	68 63 26 80 00       	push   $0x802663
  801415:	68 43 26 80 00       	push   $0x802643
  80141a:	6a 7d                	push   $0x7d
  80141c:	68 58 26 80 00       	push   $0x802658
  801421:	e8 07 0a 00 00       	call   801e2d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801426:	83 ec 04             	sub    $0x4,%esp
  801429:	50                   	push   %eax
  80142a:	68 00 50 80 00       	push   $0x805000
  80142f:	ff 75 0c             	pushl  0xc(%ebp)
  801432:	e8 31 f4 ff ff       	call   800868 <memmove>
	return r;
  801437:	83 c4 10             	add    $0x10,%esp
}
  80143a:	89 d8                	mov    %ebx,%eax
  80143c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80143f:	5b                   	pop    %ebx
  801440:	5e                   	pop    %esi
  801441:	5d                   	pop    %ebp
  801442:	c3                   	ret    

00801443 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801443:	55                   	push   %ebp
  801444:	89 e5                	mov    %esp,%ebp
  801446:	53                   	push   %ebx
  801447:	83 ec 20             	sub    $0x20,%esp
  80144a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80144d:	53                   	push   %ebx
  80144e:	e8 4a f2 ff ff       	call   80069d <strlen>
  801453:	83 c4 10             	add    $0x10,%esp
  801456:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80145b:	7f 67                	jg     8014c4 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80145d:	83 ec 0c             	sub    $0xc,%esp
  801460:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801463:	50                   	push   %eax
  801464:	e8 a7 f8 ff ff       	call   800d10 <fd_alloc>
  801469:	83 c4 10             	add    $0x10,%esp
		return r;
  80146c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80146e:	85 c0                	test   %eax,%eax
  801470:	78 57                	js     8014c9 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801472:	83 ec 08             	sub    $0x8,%esp
  801475:	53                   	push   %ebx
  801476:	68 00 50 80 00       	push   $0x805000
  80147b:	e8 56 f2 ff ff       	call   8006d6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801480:	8b 45 0c             	mov    0xc(%ebp),%eax
  801483:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801488:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80148b:	b8 01 00 00 00       	mov    $0x1,%eax
  801490:	e8 03 fe ff ff       	call   801298 <fsipc>
  801495:	89 c3                	mov    %eax,%ebx
  801497:	83 c4 10             	add    $0x10,%esp
  80149a:	85 c0                	test   %eax,%eax
  80149c:	79 14                	jns    8014b2 <open+0x6f>
		fd_close(fd, 0);
  80149e:	83 ec 08             	sub    $0x8,%esp
  8014a1:	6a 00                	push   $0x0
  8014a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8014a6:	e8 5d f9 ff ff       	call   800e08 <fd_close>
		return r;
  8014ab:	83 c4 10             	add    $0x10,%esp
  8014ae:	89 da                	mov    %ebx,%edx
  8014b0:	eb 17                	jmp    8014c9 <open+0x86>
	}

	return fd2num(fd);
  8014b2:	83 ec 0c             	sub    $0xc,%esp
  8014b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8014b8:	e8 2c f8 ff ff       	call   800ce9 <fd2num>
  8014bd:	89 c2                	mov    %eax,%edx
  8014bf:	83 c4 10             	add    $0x10,%esp
  8014c2:	eb 05                	jmp    8014c9 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014c4:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8014c9:	89 d0                	mov    %edx,%eax
  8014cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ce:	c9                   	leave  
  8014cf:	c3                   	ret    

008014d0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8014d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014db:	b8 08 00 00 00       	mov    $0x8,%eax
  8014e0:	e8 b3 fd ff ff       	call   801298 <fsipc>
}
  8014e5:	c9                   	leave  
  8014e6:	c3                   	ret    

008014e7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8014e7:	55                   	push   %ebp
  8014e8:	89 e5                	mov    %esp,%ebp
  8014ea:	56                   	push   %esi
  8014eb:	53                   	push   %ebx
  8014ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8014ef:	83 ec 0c             	sub    $0xc,%esp
  8014f2:	ff 75 08             	pushl  0x8(%ebp)
  8014f5:	e8 ff f7 ff ff       	call   800cf9 <fd2data>
  8014fa:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8014fc:	83 c4 08             	add    $0x8,%esp
  8014ff:	68 6f 26 80 00       	push   $0x80266f
  801504:	53                   	push   %ebx
  801505:	e8 cc f1 ff ff       	call   8006d6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80150a:	8b 46 04             	mov    0x4(%esi),%eax
  80150d:	2b 06                	sub    (%esi),%eax
  80150f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801515:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80151c:	00 00 00 
	stat->st_dev = &devpipe;
  80151f:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801526:	30 80 00 
	return 0;
}
  801529:	b8 00 00 00 00       	mov    $0x0,%eax
  80152e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801531:	5b                   	pop    %ebx
  801532:	5e                   	pop    %esi
  801533:	5d                   	pop    %ebp
  801534:	c3                   	ret    

00801535 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801535:	55                   	push   %ebp
  801536:	89 e5                	mov    %esp,%ebp
  801538:	53                   	push   %ebx
  801539:	83 ec 0c             	sub    $0xc,%esp
  80153c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80153f:	53                   	push   %ebx
  801540:	6a 00                	push   $0x0
  801542:	e8 17 f6 ff ff       	call   800b5e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801547:	89 1c 24             	mov    %ebx,(%esp)
  80154a:	e8 aa f7 ff ff       	call   800cf9 <fd2data>
  80154f:	83 c4 08             	add    $0x8,%esp
  801552:	50                   	push   %eax
  801553:	6a 00                	push   $0x0
  801555:	e8 04 f6 ff ff       	call   800b5e <sys_page_unmap>
}
  80155a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80155d:	c9                   	leave  
  80155e:	c3                   	ret    

0080155f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80155f:	55                   	push   %ebp
  801560:	89 e5                	mov    %esp,%ebp
  801562:	57                   	push   %edi
  801563:	56                   	push   %esi
  801564:	53                   	push   %ebx
  801565:	83 ec 1c             	sub    $0x1c,%esp
  801568:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80156b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80156d:	a1 08 40 80 00       	mov    0x804008,%eax
  801572:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801575:	83 ec 0c             	sub    $0xc,%esp
  801578:	ff 75 e0             	pushl  -0x20(%ebp)
  80157b:	e8 e7 09 00 00       	call   801f67 <pageref>
  801580:	89 c3                	mov    %eax,%ebx
  801582:	89 3c 24             	mov    %edi,(%esp)
  801585:	e8 dd 09 00 00       	call   801f67 <pageref>
  80158a:	83 c4 10             	add    $0x10,%esp
  80158d:	39 c3                	cmp    %eax,%ebx
  80158f:	0f 94 c1             	sete   %cl
  801592:	0f b6 c9             	movzbl %cl,%ecx
  801595:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801598:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80159e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015a1:	39 ce                	cmp    %ecx,%esi
  8015a3:	74 1b                	je     8015c0 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8015a5:	39 c3                	cmp    %eax,%ebx
  8015a7:	75 c4                	jne    80156d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015a9:	8b 42 58             	mov    0x58(%edx),%eax
  8015ac:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015af:	50                   	push   %eax
  8015b0:	56                   	push   %esi
  8015b1:	68 76 26 80 00       	push   $0x802676
  8015b6:	e8 96 eb ff ff       	call   800151 <cprintf>
  8015bb:	83 c4 10             	add    $0x10,%esp
  8015be:	eb ad                	jmp    80156d <_pipeisclosed+0xe>
	}
}
  8015c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015c6:	5b                   	pop    %ebx
  8015c7:	5e                   	pop    %esi
  8015c8:	5f                   	pop    %edi
  8015c9:	5d                   	pop    %ebp
  8015ca:	c3                   	ret    

008015cb <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8015cb:	55                   	push   %ebp
  8015cc:	89 e5                	mov    %esp,%ebp
  8015ce:	57                   	push   %edi
  8015cf:	56                   	push   %esi
  8015d0:	53                   	push   %ebx
  8015d1:	83 ec 28             	sub    $0x28,%esp
  8015d4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8015d7:	56                   	push   %esi
  8015d8:	e8 1c f7 ff ff       	call   800cf9 <fd2data>
  8015dd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015df:	83 c4 10             	add    $0x10,%esp
  8015e2:	bf 00 00 00 00       	mov    $0x0,%edi
  8015e7:	eb 4b                	jmp    801634 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8015e9:	89 da                	mov    %ebx,%edx
  8015eb:	89 f0                	mov    %esi,%eax
  8015ed:	e8 6d ff ff ff       	call   80155f <_pipeisclosed>
  8015f2:	85 c0                	test   %eax,%eax
  8015f4:	75 48                	jne    80163e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8015f6:	e8 bf f4 ff ff       	call   800aba <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8015fb:	8b 43 04             	mov    0x4(%ebx),%eax
  8015fe:	8b 0b                	mov    (%ebx),%ecx
  801600:	8d 51 20             	lea    0x20(%ecx),%edx
  801603:	39 d0                	cmp    %edx,%eax
  801605:	73 e2                	jae    8015e9 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801607:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80160a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80160e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801611:	89 c2                	mov    %eax,%edx
  801613:	c1 fa 1f             	sar    $0x1f,%edx
  801616:	89 d1                	mov    %edx,%ecx
  801618:	c1 e9 1b             	shr    $0x1b,%ecx
  80161b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80161e:	83 e2 1f             	and    $0x1f,%edx
  801621:	29 ca                	sub    %ecx,%edx
  801623:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801627:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80162b:	83 c0 01             	add    $0x1,%eax
  80162e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801631:	83 c7 01             	add    $0x1,%edi
  801634:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801637:	75 c2                	jne    8015fb <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801639:	8b 45 10             	mov    0x10(%ebp),%eax
  80163c:	eb 05                	jmp    801643 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80163e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801643:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801646:	5b                   	pop    %ebx
  801647:	5e                   	pop    %esi
  801648:	5f                   	pop    %edi
  801649:	5d                   	pop    %ebp
  80164a:	c3                   	ret    

0080164b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80164b:	55                   	push   %ebp
  80164c:	89 e5                	mov    %esp,%ebp
  80164e:	57                   	push   %edi
  80164f:	56                   	push   %esi
  801650:	53                   	push   %ebx
  801651:	83 ec 18             	sub    $0x18,%esp
  801654:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801657:	57                   	push   %edi
  801658:	e8 9c f6 ff ff       	call   800cf9 <fd2data>
  80165d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80165f:	83 c4 10             	add    $0x10,%esp
  801662:	bb 00 00 00 00       	mov    $0x0,%ebx
  801667:	eb 3d                	jmp    8016a6 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801669:	85 db                	test   %ebx,%ebx
  80166b:	74 04                	je     801671 <devpipe_read+0x26>
				return i;
  80166d:	89 d8                	mov    %ebx,%eax
  80166f:	eb 44                	jmp    8016b5 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801671:	89 f2                	mov    %esi,%edx
  801673:	89 f8                	mov    %edi,%eax
  801675:	e8 e5 fe ff ff       	call   80155f <_pipeisclosed>
  80167a:	85 c0                	test   %eax,%eax
  80167c:	75 32                	jne    8016b0 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80167e:	e8 37 f4 ff ff       	call   800aba <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801683:	8b 06                	mov    (%esi),%eax
  801685:	3b 46 04             	cmp    0x4(%esi),%eax
  801688:	74 df                	je     801669 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80168a:	99                   	cltd   
  80168b:	c1 ea 1b             	shr    $0x1b,%edx
  80168e:	01 d0                	add    %edx,%eax
  801690:	83 e0 1f             	and    $0x1f,%eax
  801693:	29 d0                	sub    %edx,%eax
  801695:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80169a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80169d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016a0:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016a3:	83 c3 01             	add    $0x1,%ebx
  8016a6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016a9:	75 d8                	jne    801683 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8016ae:	eb 05                	jmp    8016b5 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016b0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b8:	5b                   	pop    %ebx
  8016b9:	5e                   	pop    %esi
  8016ba:	5f                   	pop    %edi
  8016bb:	5d                   	pop    %ebp
  8016bc:	c3                   	ret    

008016bd <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8016bd:	55                   	push   %ebp
  8016be:	89 e5                	mov    %esp,%ebp
  8016c0:	56                   	push   %esi
  8016c1:	53                   	push   %ebx
  8016c2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8016c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c8:	50                   	push   %eax
  8016c9:	e8 42 f6 ff ff       	call   800d10 <fd_alloc>
  8016ce:	83 c4 10             	add    $0x10,%esp
  8016d1:	89 c2                	mov    %eax,%edx
  8016d3:	85 c0                	test   %eax,%eax
  8016d5:	0f 88 2c 01 00 00    	js     801807 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016db:	83 ec 04             	sub    $0x4,%esp
  8016de:	68 07 04 00 00       	push   $0x407
  8016e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8016e6:	6a 00                	push   $0x0
  8016e8:	e8 ec f3 ff ff       	call   800ad9 <sys_page_alloc>
  8016ed:	83 c4 10             	add    $0x10,%esp
  8016f0:	89 c2                	mov    %eax,%edx
  8016f2:	85 c0                	test   %eax,%eax
  8016f4:	0f 88 0d 01 00 00    	js     801807 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8016fa:	83 ec 0c             	sub    $0xc,%esp
  8016fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801700:	50                   	push   %eax
  801701:	e8 0a f6 ff ff       	call   800d10 <fd_alloc>
  801706:	89 c3                	mov    %eax,%ebx
  801708:	83 c4 10             	add    $0x10,%esp
  80170b:	85 c0                	test   %eax,%eax
  80170d:	0f 88 e2 00 00 00    	js     8017f5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801713:	83 ec 04             	sub    $0x4,%esp
  801716:	68 07 04 00 00       	push   $0x407
  80171b:	ff 75 f0             	pushl  -0x10(%ebp)
  80171e:	6a 00                	push   $0x0
  801720:	e8 b4 f3 ff ff       	call   800ad9 <sys_page_alloc>
  801725:	89 c3                	mov    %eax,%ebx
  801727:	83 c4 10             	add    $0x10,%esp
  80172a:	85 c0                	test   %eax,%eax
  80172c:	0f 88 c3 00 00 00    	js     8017f5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801732:	83 ec 0c             	sub    $0xc,%esp
  801735:	ff 75 f4             	pushl  -0xc(%ebp)
  801738:	e8 bc f5 ff ff       	call   800cf9 <fd2data>
  80173d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80173f:	83 c4 0c             	add    $0xc,%esp
  801742:	68 07 04 00 00       	push   $0x407
  801747:	50                   	push   %eax
  801748:	6a 00                	push   $0x0
  80174a:	e8 8a f3 ff ff       	call   800ad9 <sys_page_alloc>
  80174f:	89 c3                	mov    %eax,%ebx
  801751:	83 c4 10             	add    $0x10,%esp
  801754:	85 c0                	test   %eax,%eax
  801756:	0f 88 89 00 00 00    	js     8017e5 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80175c:	83 ec 0c             	sub    $0xc,%esp
  80175f:	ff 75 f0             	pushl  -0x10(%ebp)
  801762:	e8 92 f5 ff ff       	call   800cf9 <fd2data>
  801767:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80176e:	50                   	push   %eax
  80176f:	6a 00                	push   $0x0
  801771:	56                   	push   %esi
  801772:	6a 00                	push   $0x0
  801774:	e8 a3 f3 ff ff       	call   800b1c <sys_page_map>
  801779:	89 c3                	mov    %eax,%ebx
  80177b:	83 c4 20             	add    $0x20,%esp
  80177e:	85 c0                	test   %eax,%eax
  801780:	78 55                	js     8017d7 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801782:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801788:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80178b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80178d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801790:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801797:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80179d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a0:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017ac:	83 ec 0c             	sub    $0xc,%esp
  8017af:	ff 75 f4             	pushl  -0xc(%ebp)
  8017b2:	e8 32 f5 ff ff       	call   800ce9 <fd2num>
  8017b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017ba:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017bc:	83 c4 04             	add    $0x4,%esp
  8017bf:	ff 75 f0             	pushl  -0x10(%ebp)
  8017c2:	e8 22 f5 ff ff       	call   800ce9 <fd2num>
  8017c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017ca:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8017cd:	83 c4 10             	add    $0x10,%esp
  8017d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d5:	eb 30                	jmp    801807 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8017d7:	83 ec 08             	sub    $0x8,%esp
  8017da:	56                   	push   %esi
  8017db:	6a 00                	push   $0x0
  8017dd:	e8 7c f3 ff ff       	call   800b5e <sys_page_unmap>
  8017e2:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8017e5:	83 ec 08             	sub    $0x8,%esp
  8017e8:	ff 75 f0             	pushl  -0x10(%ebp)
  8017eb:	6a 00                	push   $0x0
  8017ed:	e8 6c f3 ff ff       	call   800b5e <sys_page_unmap>
  8017f2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8017f5:	83 ec 08             	sub    $0x8,%esp
  8017f8:	ff 75 f4             	pushl  -0xc(%ebp)
  8017fb:	6a 00                	push   $0x0
  8017fd:	e8 5c f3 ff ff       	call   800b5e <sys_page_unmap>
  801802:	83 c4 10             	add    $0x10,%esp
  801805:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801807:	89 d0                	mov    %edx,%eax
  801809:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80180c:	5b                   	pop    %ebx
  80180d:	5e                   	pop    %esi
  80180e:	5d                   	pop    %ebp
  80180f:	c3                   	ret    

00801810 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801816:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801819:	50                   	push   %eax
  80181a:	ff 75 08             	pushl  0x8(%ebp)
  80181d:	e8 3d f5 ff ff       	call   800d5f <fd_lookup>
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	85 c0                	test   %eax,%eax
  801827:	78 18                	js     801841 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801829:	83 ec 0c             	sub    $0xc,%esp
  80182c:	ff 75 f4             	pushl  -0xc(%ebp)
  80182f:	e8 c5 f4 ff ff       	call   800cf9 <fd2data>
	return _pipeisclosed(fd, p);
  801834:	89 c2                	mov    %eax,%edx
  801836:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801839:	e8 21 fd ff ff       	call   80155f <_pipeisclosed>
  80183e:	83 c4 10             	add    $0x10,%esp
}
  801841:	c9                   	leave  
  801842:	c3                   	ret    

00801843 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801843:	55                   	push   %ebp
  801844:	89 e5                	mov    %esp,%ebp
  801846:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801849:	68 8e 26 80 00       	push   $0x80268e
  80184e:	ff 75 0c             	pushl  0xc(%ebp)
  801851:	e8 80 ee ff ff       	call   8006d6 <strcpy>
	return 0;
}
  801856:	b8 00 00 00 00       	mov    $0x0,%eax
  80185b:	c9                   	leave  
  80185c:	c3                   	ret    

0080185d <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80185d:	55                   	push   %ebp
  80185e:	89 e5                	mov    %esp,%ebp
  801860:	53                   	push   %ebx
  801861:	83 ec 10             	sub    $0x10,%esp
  801864:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801867:	53                   	push   %ebx
  801868:	e8 fa 06 00 00       	call   801f67 <pageref>
  80186d:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801870:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801875:	83 f8 01             	cmp    $0x1,%eax
  801878:	75 10                	jne    80188a <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80187a:	83 ec 0c             	sub    $0xc,%esp
  80187d:	ff 73 0c             	pushl  0xc(%ebx)
  801880:	e8 c0 02 00 00       	call   801b45 <nsipc_close>
  801885:	89 c2                	mov    %eax,%edx
  801887:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80188a:	89 d0                	mov    %edx,%eax
  80188c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80188f:	c9                   	leave  
  801890:	c3                   	ret    

00801891 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801891:	55                   	push   %ebp
  801892:	89 e5                	mov    %esp,%ebp
  801894:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801897:	6a 00                	push   $0x0
  801899:	ff 75 10             	pushl  0x10(%ebp)
  80189c:	ff 75 0c             	pushl  0xc(%ebp)
  80189f:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a2:	ff 70 0c             	pushl  0xc(%eax)
  8018a5:	e8 78 03 00 00       	call   801c22 <nsipc_send>
}
  8018aa:	c9                   	leave  
  8018ab:	c3                   	ret    

008018ac <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8018ac:	55                   	push   %ebp
  8018ad:	89 e5                	mov    %esp,%ebp
  8018af:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8018b2:	6a 00                	push   $0x0
  8018b4:	ff 75 10             	pushl  0x10(%ebp)
  8018b7:	ff 75 0c             	pushl  0xc(%ebp)
  8018ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bd:	ff 70 0c             	pushl  0xc(%eax)
  8018c0:	e8 f1 02 00 00       	call   801bb6 <nsipc_recv>
}
  8018c5:	c9                   	leave  
  8018c6:	c3                   	ret    

008018c7 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8018c7:	55                   	push   %ebp
  8018c8:	89 e5                	mov    %esp,%ebp
  8018ca:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8018cd:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8018d0:	52                   	push   %edx
  8018d1:	50                   	push   %eax
  8018d2:	e8 88 f4 ff ff       	call   800d5f <fd_lookup>
  8018d7:	83 c4 10             	add    $0x10,%esp
  8018da:	85 c0                	test   %eax,%eax
  8018dc:	78 17                	js     8018f5 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8018de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e1:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  8018e7:	39 08                	cmp    %ecx,(%eax)
  8018e9:	75 05                	jne    8018f0 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8018eb:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ee:	eb 05                	jmp    8018f5 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8018f0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8018f5:	c9                   	leave  
  8018f6:	c3                   	ret    

008018f7 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	56                   	push   %esi
  8018fb:	53                   	push   %ebx
  8018fc:	83 ec 1c             	sub    $0x1c,%esp
  8018ff:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801901:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801904:	50                   	push   %eax
  801905:	e8 06 f4 ff ff       	call   800d10 <fd_alloc>
  80190a:	89 c3                	mov    %eax,%ebx
  80190c:	83 c4 10             	add    $0x10,%esp
  80190f:	85 c0                	test   %eax,%eax
  801911:	78 1b                	js     80192e <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801913:	83 ec 04             	sub    $0x4,%esp
  801916:	68 07 04 00 00       	push   $0x407
  80191b:	ff 75 f4             	pushl  -0xc(%ebp)
  80191e:	6a 00                	push   $0x0
  801920:	e8 b4 f1 ff ff       	call   800ad9 <sys_page_alloc>
  801925:	89 c3                	mov    %eax,%ebx
  801927:	83 c4 10             	add    $0x10,%esp
  80192a:	85 c0                	test   %eax,%eax
  80192c:	79 10                	jns    80193e <alloc_sockfd+0x47>
		nsipc_close(sockid);
  80192e:	83 ec 0c             	sub    $0xc,%esp
  801931:	56                   	push   %esi
  801932:	e8 0e 02 00 00       	call   801b45 <nsipc_close>
		return r;
  801937:	83 c4 10             	add    $0x10,%esp
  80193a:	89 d8                	mov    %ebx,%eax
  80193c:	eb 24                	jmp    801962 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80193e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801944:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801947:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801949:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80194c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801953:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801956:	83 ec 0c             	sub    $0xc,%esp
  801959:	50                   	push   %eax
  80195a:	e8 8a f3 ff ff       	call   800ce9 <fd2num>
  80195f:	83 c4 10             	add    $0x10,%esp
}
  801962:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801965:	5b                   	pop    %ebx
  801966:	5e                   	pop    %esi
  801967:	5d                   	pop    %ebp
  801968:	c3                   	ret    

00801969 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801969:	55                   	push   %ebp
  80196a:	89 e5                	mov    %esp,%ebp
  80196c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80196f:	8b 45 08             	mov    0x8(%ebp),%eax
  801972:	e8 50 ff ff ff       	call   8018c7 <fd2sockid>
		return r;
  801977:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801979:	85 c0                	test   %eax,%eax
  80197b:	78 1f                	js     80199c <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80197d:	83 ec 04             	sub    $0x4,%esp
  801980:	ff 75 10             	pushl  0x10(%ebp)
  801983:	ff 75 0c             	pushl  0xc(%ebp)
  801986:	50                   	push   %eax
  801987:	e8 12 01 00 00       	call   801a9e <nsipc_accept>
  80198c:	83 c4 10             	add    $0x10,%esp
		return r;
  80198f:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801991:	85 c0                	test   %eax,%eax
  801993:	78 07                	js     80199c <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801995:	e8 5d ff ff ff       	call   8018f7 <alloc_sockfd>
  80199a:	89 c1                	mov    %eax,%ecx
}
  80199c:	89 c8                	mov    %ecx,%eax
  80199e:	c9                   	leave  
  80199f:	c3                   	ret    

008019a0 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a9:	e8 19 ff ff ff       	call   8018c7 <fd2sockid>
  8019ae:	85 c0                	test   %eax,%eax
  8019b0:	78 12                	js     8019c4 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8019b2:	83 ec 04             	sub    $0x4,%esp
  8019b5:	ff 75 10             	pushl  0x10(%ebp)
  8019b8:	ff 75 0c             	pushl  0xc(%ebp)
  8019bb:	50                   	push   %eax
  8019bc:	e8 2d 01 00 00       	call   801aee <nsipc_bind>
  8019c1:	83 c4 10             	add    $0x10,%esp
}
  8019c4:	c9                   	leave  
  8019c5:	c3                   	ret    

008019c6 <shutdown>:

int
shutdown(int s, int how)
{
  8019c6:	55                   	push   %ebp
  8019c7:	89 e5                	mov    %esp,%ebp
  8019c9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8019cf:	e8 f3 fe ff ff       	call   8018c7 <fd2sockid>
  8019d4:	85 c0                	test   %eax,%eax
  8019d6:	78 0f                	js     8019e7 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8019d8:	83 ec 08             	sub    $0x8,%esp
  8019db:	ff 75 0c             	pushl  0xc(%ebp)
  8019de:	50                   	push   %eax
  8019df:	e8 3f 01 00 00       	call   801b23 <nsipc_shutdown>
  8019e4:	83 c4 10             	add    $0x10,%esp
}
  8019e7:	c9                   	leave  
  8019e8:	c3                   	ret    

008019e9 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019e9:	55                   	push   %ebp
  8019ea:	89 e5                	mov    %esp,%ebp
  8019ec:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f2:	e8 d0 fe ff ff       	call   8018c7 <fd2sockid>
  8019f7:	85 c0                	test   %eax,%eax
  8019f9:	78 12                	js     801a0d <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8019fb:	83 ec 04             	sub    $0x4,%esp
  8019fe:	ff 75 10             	pushl  0x10(%ebp)
  801a01:	ff 75 0c             	pushl  0xc(%ebp)
  801a04:	50                   	push   %eax
  801a05:	e8 55 01 00 00       	call   801b5f <nsipc_connect>
  801a0a:	83 c4 10             	add    $0x10,%esp
}
  801a0d:	c9                   	leave  
  801a0e:	c3                   	ret    

00801a0f <listen>:

int
listen(int s, int backlog)
{
  801a0f:	55                   	push   %ebp
  801a10:	89 e5                	mov    %esp,%ebp
  801a12:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a15:	8b 45 08             	mov    0x8(%ebp),%eax
  801a18:	e8 aa fe ff ff       	call   8018c7 <fd2sockid>
  801a1d:	85 c0                	test   %eax,%eax
  801a1f:	78 0f                	js     801a30 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801a21:	83 ec 08             	sub    $0x8,%esp
  801a24:	ff 75 0c             	pushl  0xc(%ebp)
  801a27:	50                   	push   %eax
  801a28:	e8 67 01 00 00       	call   801b94 <nsipc_listen>
  801a2d:	83 c4 10             	add    $0x10,%esp
}
  801a30:	c9                   	leave  
  801a31:	c3                   	ret    

00801a32 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801a32:	55                   	push   %ebp
  801a33:	89 e5                	mov    %esp,%ebp
  801a35:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a38:	ff 75 10             	pushl  0x10(%ebp)
  801a3b:	ff 75 0c             	pushl  0xc(%ebp)
  801a3e:	ff 75 08             	pushl  0x8(%ebp)
  801a41:	e8 3a 02 00 00       	call   801c80 <nsipc_socket>
  801a46:	83 c4 10             	add    $0x10,%esp
  801a49:	85 c0                	test   %eax,%eax
  801a4b:	78 05                	js     801a52 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801a4d:	e8 a5 fe ff ff       	call   8018f7 <alloc_sockfd>
}
  801a52:	c9                   	leave  
  801a53:	c3                   	ret    

00801a54 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801a54:	55                   	push   %ebp
  801a55:	89 e5                	mov    %esp,%ebp
  801a57:	53                   	push   %ebx
  801a58:	83 ec 04             	sub    $0x4,%esp
  801a5b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801a5d:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801a64:	75 12                	jne    801a78 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801a66:	83 ec 0c             	sub    $0xc,%esp
  801a69:	6a 02                	push   $0x2
  801a6b:	e8 be 04 00 00       	call   801f2e <ipc_find_env>
  801a70:	a3 04 40 80 00       	mov    %eax,0x804004
  801a75:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801a78:	6a 07                	push   $0x7
  801a7a:	68 00 60 80 00       	push   $0x806000
  801a7f:	53                   	push   %ebx
  801a80:	ff 35 04 40 80 00    	pushl  0x804004
  801a86:	e8 4f 04 00 00       	call   801eda <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801a8b:	83 c4 0c             	add    $0xc,%esp
  801a8e:	6a 00                	push   $0x0
  801a90:	6a 00                	push   $0x0
  801a92:	6a 00                	push   $0x0
  801a94:	e8 da 03 00 00       	call   801e73 <ipc_recv>
}
  801a99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a9c:	c9                   	leave  
  801a9d:	c3                   	ret    

00801a9e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a9e:	55                   	push   %ebp
  801a9f:	89 e5                	mov    %esp,%ebp
  801aa1:	56                   	push   %esi
  801aa2:	53                   	push   %ebx
  801aa3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801aae:	8b 06                	mov    (%esi),%eax
  801ab0:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ab5:	b8 01 00 00 00       	mov    $0x1,%eax
  801aba:	e8 95 ff ff ff       	call   801a54 <nsipc>
  801abf:	89 c3                	mov    %eax,%ebx
  801ac1:	85 c0                	test   %eax,%eax
  801ac3:	78 20                	js     801ae5 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801ac5:	83 ec 04             	sub    $0x4,%esp
  801ac8:	ff 35 10 60 80 00    	pushl  0x806010
  801ace:	68 00 60 80 00       	push   $0x806000
  801ad3:	ff 75 0c             	pushl  0xc(%ebp)
  801ad6:	e8 8d ed ff ff       	call   800868 <memmove>
		*addrlen = ret->ret_addrlen;
  801adb:	a1 10 60 80 00       	mov    0x806010,%eax
  801ae0:	89 06                	mov    %eax,(%esi)
  801ae2:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801ae5:	89 d8                	mov    %ebx,%eax
  801ae7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aea:	5b                   	pop    %ebx
  801aeb:	5e                   	pop    %esi
  801aec:	5d                   	pop    %ebp
  801aed:	c3                   	ret    

00801aee <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801aee:	55                   	push   %ebp
  801aef:	89 e5                	mov    %esp,%ebp
  801af1:	53                   	push   %ebx
  801af2:	83 ec 08             	sub    $0x8,%esp
  801af5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801af8:	8b 45 08             	mov    0x8(%ebp),%eax
  801afb:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801b00:	53                   	push   %ebx
  801b01:	ff 75 0c             	pushl  0xc(%ebp)
  801b04:	68 04 60 80 00       	push   $0x806004
  801b09:	e8 5a ed ff ff       	call   800868 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b0e:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801b14:	b8 02 00 00 00       	mov    $0x2,%eax
  801b19:	e8 36 ff ff ff       	call   801a54 <nsipc>
}
  801b1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b21:	c9                   	leave  
  801b22:	c3                   	ret    

00801b23 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b23:	55                   	push   %ebp
  801b24:	89 e5                	mov    %esp,%ebp
  801b26:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b29:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801b31:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b34:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801b39:	b8 03 00 00 00       	mov    $0x3,%eax
  801b3e:	e8 11 ff ff ff       	call   801a54 <nsipc>
}
  801b43:	c9                   	leave  
  801b44:	c3                   	ret    

00801b45 <nsipc_close>:

int
nsipc_close(int s)
{
  801b45:	55                   	push   %ebp
  801b46:	89 e5                	mov    %esp,%ebp
  801b48:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4e:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801b53:	b8 04 00 00 00       	mov    $0x4,%eax
  801b58:	e8 f7 fe ff ff       	call   801a54 <nsipc>
}
  801b5d:	c9                   	leave  
  801b5e:	c3                   	ret    

00801b5f <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b5f:	55                   	push   %ebp
  801b60:	89 e5                	mov    %esp,%ebp
  801b62:	53                   	push   %ebx
  801b63:	83 ec 08             	sub    $0x8,%esp
  801b66:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801b69:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801b71:	53                   	push   %ebx
  801b72:	ff 75 0c             	pushl  0xc(%ebp)
  801b75:	68 04 60 80 00       	push   $0x806004
  801b7a:	e8 e9 ec ff ff       	call   800868 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801b7f:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801b85:	b8 05 00 00 00       	mov    $0x5,%eax
  801b8a:	e8 c5 fe ff ff       	call   801a54 <nsipc>
}
  801b8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b92:	c9                   	leave  
  801b93:	c3                   	ret    

00801b94 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
  801b97:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801b9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801ba2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba5:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801baa:	b8 06 00 00 00       	mov    $0x6,%eax
  801baf:	e8 a0 fe ff ff       	call   801a54 <nsipc>
}
  801bb4:	c9                   	leave  
  801bb5:	c3                   	ret    

00801bb6 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801bb6:	55                   	push   %ebp
  801bb7:	89 e5                	mov    %esp,%ebp
  801bb9:	56                   	push   %esi
  801bba:	53                   	push   %ebx
  801bbb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801bbe:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801bc6:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801bcc:	8b 45 14             	mov    0x14(%ebp),%eax
  801bcf:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801bd4:	b8 07 00 00 00       	mov    $0x7,%eax
  801bd9:	e8 76 fe ff ff       	call   801a54 <nsipc>
  801bde:	89 c3                	mov    %eax,%ebx
  801be0:	85 c0                	test   %eax,%eax
  801be2:	78 35                	js     801c19 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801be4:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801be9:	7f 04                	jg     801bef <nsipc_recv+0x39>
  801beb:	39 c6                	cmp    %eax,%esi
  801bed:	7d 16                	jge    801c05 <nsipc_recv+0x4f>
  801bef:	68 9a 26 80 00       	push   $0x80269a
  801bf4:	68 43 26 80 00       	push   $0x802643
  801bf9:	6a 62                	push   $0x62
  801bfb:	68 af 26 80 00       	push   $0x8026af
  801c00:	e8 28 02 00 00       	call   801e2d <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801c05:	83 ec 04             	sub    $0x4,%esp
  801c08:	50                   	push   %eax
  801c09:	68 00 60 80 00       	push   $0x806000
  801c0e:	ff 75 0c             	pushl  0xc(%ebp)
  801c11:	e8 52 ec ff ff       	call   800868 <memmove>
  801c16:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801c19:	89 d8                	mov    %ebx,%eax
  801c1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c1e:	5b                   	pop    %ebx
  801c1f:	5e                   	pop    %esi
  801c20:	5d                   	pop    %ebp
  801c21:	c3                   	ret    

00801c22 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c22:	55                   	push   %ebp
  801c23:	89 e5                	mov    %esp,%ebp
  801c25:	53                   	push   %ebx
  801c26:	83 ec 04             	sub    $0x4,%esp
  801c29:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c2c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2f:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801c34:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c3a:	7e 16                	jle    801c52 <nsipc_send+0x30>
  801c3c:	68 bb 26 80 00       	push   $0x8026bb
  801c41:	68 43 26 80 00       	push   $0x802643
  801c46:	6a 6d                	push   $0x6d
  801c48:	68 af 26 80 00       	push   $0x8026af
  801c4d:	e8 db 01 00 00       	call   801e2d <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c52:	83 ec 04             	sub    $0x4,%esp
  801c55:	53                   	push   %ebx
  801c56:	ff 75 0c             	pushl  0xc(%ebp)
  801c59:	68 0c 60 80 00       	push   $0x80600c
  801c5e:	e8 05 ec ff ff       	call   800868 <memmove>
	nsipcbuf.send.req_size = size;
  801c63:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801c69:	8b 45 14             	mov    0x14(%ebp),%eax
  801c6c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801c71:	b8 08 00 00 00       	mov    $0x8,%eax
  801c76:	e8 d9 fd ff ff       	call   801a54 <nsipc>
}
  801c7b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c7e:	c9                   	leave  
  801c7f:	c3                   	ret    

00801c80 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801c80:	55                   	push   %ebp
  801c81:	89 e5                	mov    %esp,%ebp
  801c83:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801c86:	8b 45 08             	mov    0x8(%ebp),%eax
  801c89:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801c8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c91:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801c96:	8b 45 10             	mov    0x10(%ebp),%eax
  801c99:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801c9e:	b8 09 00 00 00       	mov    $0x9,%eax
  801ca3:	e8 ac fd ff ff       	call   801a54 <nsipc>
}
  801ca8:	c9                   	leave  
  801ca9:	c3                   	ret    

00801caa <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801caa:	55                   	push   %ebp
  801cab:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cad:	b8 00 00 00 00       	mov    $0x0,%eax
  801cb2:	5d                   	pop    %ebp
  801cb3:	c3                   	ret    

00801cb4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cb4:	55                   	push   %ebp
  801cb5:	89 e5                	mov    %esp,%ebp
  801cb7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cba:	68 c7 26 80 00       	push   $0x8026c7
  801cbf:	ff 75 0c             	pushl  0xc(%ebp)
  801cc2:	e8 0f ea ff ff       	call   8006d6 <strcpy>
	return 0;
}
  801cc7:	b8 00 00 00 00       	mov    $0x0,%eax
  801ccc:	c9                   	leave  
  801ccd:	c3                   	ret    

00801cce <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cce:	55                   	push   %ebp
  801ccf:	89 e5                	mov    %esp,%ebp
  801cd1:	57                   	push   %edi
  801cd2:	56                   	push   %esi
  801cd3:	53                   	push   %ebx
  801cd4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cda:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cdf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ce5:	eb 2d                	jmp    801d14 <devcons_write+0x46>
		m = n - tot;
  801ce7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cea:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801cec:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801cef:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801cf4:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cf7:	83 ec 04             	sub    $0x4,%esp
  801cfa:	53                   	push   %ebx
  801cfb:	03 45 0c             	add    0xc(%ebp),%eax
  801cfe:	50                   	push   %eax
  801cff:	57                   	push   %edi
  801d00:	e8 63 eb ff ff       	call   800868 <memmove>
		sys_cputs(buf, m);
  801d05:	83 c4 08             	add    $0x8,%esp
  801d08:	53                   	push   %ebx
  801d09:	57                   	push   %edi
  801d0a:	e8 0e ed ff ff       	call   800a1d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d0f:	01 de                	add    %ebx,%esi
  801d11:	83 c4 10             	add    $0x10,%esp
  801d14:	89 f0                	mov    %esi,%eax
  801d16:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d19:	72 cc                	jb     801ce7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d1e:	5b                   	pop    %ebx
  801d1f:	5e                   	pop    %esi
  801d20:	5f                   	pop    %edi
  801d21:	5d                   	pop    %ebp
  801d22:	c3                   	ret    

00801d23 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d23:	55                   	push   %ebp
  801d24:	89 e5                	mov    %esp,%ebp
  801d26:	83 ec 08             	sub    $0x8,%esp
  801d29:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d2e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d32:	74 2a                	je     801d5e <devcons_read+0x3b>
  801d34:	eb 05                	jmp    801d3b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d36:	e8 7f ed ff ff       	call   800aba <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d3b:	e8 fb ec ff ff       	call   800a3b <sys_cgetc>
  801d40:	85 c0                	test   %eax,%eax
  801d42:	74 f2                	je     801d36 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d44:	85 c0                	test   %eax,%eax
  801d46:	78 16                	js     801d5e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d48:	83 f8 04             	cmp    $0x4,%eax
  801d4b:	74 0c                	je     801d59 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d4d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d50:	88 02                	mov    %al,(%edx)
	return 1;
  801d52:	b8 01 00 00 00       	mov    $0x1,%eax
  801d57:	eb 05                	jmp    801d5e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d59:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d5e:	c9                   	leave  
  801d5f:	c3                   	ret    

00801d60 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d60:	55                   	push   %ebp
  801d61:	89 e5                	mov    %esp,%ebp
  801d63:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d66:	8b 45 08             	mov    0x8(%ebp),%eax
  801d69:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d6c:	6a 01                	push   $0x1
  801d6e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d71:	50                   	push   %eax
  801d72:	e8 a6 ec ff ff       	call   800a1d <sys_cputs>
}
  801d77:	83 c4 10             	add    $0x10,%esp
  801d7a:	c9                   	leave  
  801d7b:	c3                   	ret    

00801d7c <getchar>:

int
getchar(void)
{
  801d7c:	55                   	push   %ebp
  801d7d:	89 e5                	mov    %esp,%ebp
  801d7f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d82:	6a 01                	push   $0x1
  801d84:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d87:	50                   	push   %eax
  801d88:	6a 00                	push   $0x0
  801d8a:	e8 36 f2 ff ff       	call   800fc5 <read>
	if (r < 0)
  801d8f:	83 c4 10             	add    $0x10,%esp
  801d92:	85 c0                	test   %eax,%eax
  801d94:	78 0f                	js     801da5 <getchar+0x29>
		return r;
	if (r < 1)
  801d96:	85 c0                	test   %eax,%eax
  801d98:	7e 06                	jle    801da0 <getchar+0x24>
		return -E_EOF;
	return c;
  801d9a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d9e:	eb 05                	jmp    801da5 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801da0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801da5:	c9                   	leave  
  801da6:	c3                   	ret    

00801da7 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801da7:	55                   	push   %ebp
  801da8:	89 e5                	mov    %esp,%ebp
  801daa:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801db0:	50                   	push   %eax
  801db1:	ff 75 08             	pushl  0x8(%ebp)
  801db4:	e8 a6 ef ff ff       	call   800d5f <fd_lookup>
  801db9:	83 c4 10             	add    $0x10,%esp
  801dbc:	85 c0                	test   %eax,%eax
  801dbe:	78 11                	js     801dd1 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801dc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc3:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801dc9:	39 10                	cmp    %edx,(%eax)
  801dcb:	0f 94 c0             	sete   %al
  801dce:	0f b6 c0             	movzbl %al,%eax
}
  801dd1:	c9                   	leave  
  801dd2:	c3                   	ret    

00801dd3 <opencons>:

int
opencons(void)
{
  801dd3:	55                   	push   %ebp
  801dd4:	89 e5                	mov    %esp,%ebp
  801dd6:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801dd9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ddc:	50                   	push   %eax
  801ddd:	e8 2e ef ff ff       	call   800d10 <fd_alloc>
  801de2:	83 c4 10             	add    $0x10,%esp
		return r;
  801de5:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801de7:	85 c0                	test   %eax,%eax
  801de9:	78 3e                	js     801e29 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801deb:	83 ec 04             	sub    $0x4,%esp
  801dee:	68 07 04 00 00       	push   $0x407
  801df3:	ff 75 f4             	pushl  -0xc(%ebp)
  801df6:	6a 00                	push   $0x0
  801df8:	e8 dc ec ff ff       	call   800ad9 <sys_page_alloc>
  801dfd:	83 c4 10             	add    $0x10,%esp
		return r;
  801e00:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e02:	85 c0                	test   %eax,%eax
  801e04:	78 23                	js     801e29 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e06:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e14:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e1b:	83 ec 0c             	sub    $0xc,%esp
  801e1e:	50                   	push   %eax
  801e1f:	e8 c5 ee ff ff       	call   800ce9 <fd2num>
  801e24:	89 c2                	mov    %eax,%edx
  801e26:	83 c4 10             	add    $0x10,%esp
}
  801e29:	89 d0                	mov    %edx,%eax
  801e2b:	c9                   	leave  
  801e2c:	c3                   	ret    

00801e2d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e2d:	55                   	push   %ebp
  801e2e:	89 e5                	mov    %esp,%ebp
  801e30:	56                   	push   %esi
  801e31:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e32:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e35:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e3b:	e8 5b ec ff ff       	call   800a9b <sys_getenvid>
  801e40:	83 ec 0c             	sub    $0xc,%esp
  801e43:	ff 75 0c             	pushl  0xc(%ebp)
  801e46:	ff 75 08             	pushl  0x8(%ebp)
  801e49:	56                   	push   %esi
  801e4a:	50                   	push   %eax
  801e4b:	68 d4 26 80 00       	push   $0x8026d4
  801e50:	e8 fc e2 ff ff       	call   800151 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e55:	83 c4 18             	add    $0x18,%esp
  801e58:	53                   	push   %ebx
  801e59:	ff 75 10             	pushl  0x10(%ebp)
  801e5c:	e8 9f e2 ff ff       	call   800100 <vcprintf>
	cprintf("\n");
  801e61:	c7 04 24 87 26 80 00 	movl   $0x802687,(%esp)
  801e68:	e8 e4 e2 ff ff       	call   800151 <cprintf>
  801e6d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e70:	cc                   	int3   
  801e71:	eb fd                	jmp    801e70 <_panic+0x43>

00801e73 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e73:	55                   	push   %ebp
  801e74:	89 e5                	mov    %esp,%ebp
  801e76:	56                   	push   %esi
  801e77:	53                   	push   %ebx
  801e78:	8b 75 08             	mov    0x8(%ebp),%esi
  801e7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801e81:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801e83:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801e88:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801e8b:	83 ec 0c             	sub    $0xc,%esp
  801e8e:	50                   	push   %eax
  801e8f:	e8 f5 ed ff ff       	call   800c89 <sys_ipc_recv>

	if (from_env_store != NULL)
  801e94:	83 c4 10             	add    $0x10,%esp
  801e97:	85 f6                	test   %esi,%esi
  801e99:	74 14                	je     801eaf <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801e9b:	ba 00 00 00 00       	mov    $0x0,%edx
  801ea0:	85 c0                	test   %eax,%eax
  801ea2:	78 09                	js     801ead <ipc_recv+0x3a>
  801ea4:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801eaa:	8b 52 74             	mov    0x74(%edx),%edx
  801ead:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801eaf:	85 db                	test   %ebx,%ebx
  801eb1:	74 14                	je     801ec7 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801eb3:	ba 00 00 00 00       	mov    $0x0,%edx
  801eb8:	85 c0                	test   %eax,%eax
  801eba:	78 09                	js     801ec5 <ipc_recv+0x52>
  801ebc:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ec2:	8b 52 78             	mov    0x78(%edx),%edx
  801ec5:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801ec7:	85 c0                	test   %eax,%eax
  801ec9:	78 08                	js     801ed3 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801ecb:	a1 08 40 80 00       	mov    0x804008,%eax
  801ed0:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ed3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ed6:	5b                   	pop    %ebx
  801ed7:	5e                   	pop    %esi
  801ed8:	5d                   	pop    %ebp
  801ed9:	c3                   	ret    

00801eda <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801eda:	55                   	push   %ebp
  801edb:	89 e5                	mov    %esp,%ebp
  801edd:	57                   	push   %edi
  801ede:	56                   	push   %esi
  801edf:	53                   	push   %ebx
  801ee0:	83 ec 0c             	sub    $0xc,%esp
  801ee3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ee6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ee9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801eec:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801eee:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ef3:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801ef6:	ff 75 14             	pushl  0x14(%ebp)
  801ef9:	53                   	push   %ebx
  801efa:	56                   	push   %esi
  801efb:	57                   	push   %edi
  801efc:	e8 65 ed ff ff       	call   800c66 <sys_ipc_try_send>

		if (err < 0) {
  801f01:	83 c4 10             	add    $0x10,%esp
  801f04:	85 c0                	test   %eax,%eax
  801f06:	79 1e                	jns    801f26 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801f08:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f0b:	75 07                	jne    801f14 <ipc_send+0x3a>
				sys_yield();
  801f0d:	e8 a8 eb ff ff       	call   800aba <sys_yield>
  801f12:	eb e2                	jmp    801ef6 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f14:	50                   	push   %eax
  801f15:	68 f8 26 80 00       	push   $0x8026f8
  801f1a:	6a 49                	push   $0x49
  801f1c:	68 05 27 80 00       	push   $0x802705
  801f21:	e8 07 ff ff ff       	call   801e2d <_panic>
		}

	} while (err < 0);

}
  801f26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f29:	5b                   	pop    %ebx
  801f2a:	5e                   	pop    %esi
  801f2b:	5f                   	pop    %edi
  801f2c:	5d                   	pop    %ebp
  801f2d:	c3                   	ret    

00801f2e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f2e:	55                   	push   %ebp
  801f2f:	89 e5                	mov    %esp,%ebp
  801f31:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f34:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f39:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f3c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f42:	8b 52 50             	mov    0x50(%edx),%edx
  801f45:	39 ca                	cmp    %ecx,%edx
  801f47:	75 0d                	jne    801f56 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f49:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f4c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f51:	8b 40 48             	mov    0x48(%eax),%eax
  801f54:	eb 0f                	jmp    801f65 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f56:	83 c0 01             	add    $0x1,%eax
  801f59:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f5e:	75 d9                	jne    801f39 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f65:	5d                   	pop    %ebp
  801f66:	c3                   	ret    

00801f67 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f67:	55                   	push   %ebp
  801f68:	89 e5                	mov    %esp,%ebp
  801f6a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f6d:	89 d0                	mov    %edx,%eax
  801f6f:	c1 e8 16             	shr    $0x16,%eax
  801f72:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f79:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f7e:	f6 c1 01             	test   $0x1,%cl
  801f81:	74 1d                	je     801fa0 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f83:	c1 ea 0c             	shr    $0xc,%edx
  801f86:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f8d:	f6 c2 01             	test   $0x1,%dl
  801f90:	74 0e                	je     801fa0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f92:	c1 ea 0c             	shr    $0xc,%edx
  801f95:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f9c:	ef 
  801f9d:	0f b7 c0             	movzwl %ax,%eax
}
  801fa0:	5d                   	pop    %ebp
  801fa1:	c3                   	ret    
  801fa2:	66 90                	xchg   %ax,%ax
  801fa4:	66 90                	xchg   %ax,%ax
  801fa6:	66 90                	xchg   %ax,%ax
  801fa8:	66 90                	xchg   %ax,%ax
  801faa:	66 90                	xchg   %ax,%ax
  801fac:	66 90                	xchg   %ax,%ax
  801fae:	66 90                	xchg   %ax,%ax

00801fb0 <__udivdi3>:
  801fb0:	55                   	push   %ebp
  801fb1:	57                   	push   %edi
  801fb2:	56                   	push   %esi
  801fb3:	53                   	push   %ebx
  801fb4:	83 ec 1c             	sub    $0x1c,%esp
  801fb7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fbb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fbf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fc7:	85 f6                	test   %esi,%esi
  801fc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fcd:	89 ca                	mov    %ecx,%edx
  801fcf:	89 f8                	mov    %edi,%eax
  801fd1:	75 3d                	jne    802010 <__udivdi3+0x60>
  801fd3:	39 cf                	cmp    %ecx,%edi
  801fd5:	0f 87 c5 00 00 00    	ja     8020a0 <__udivdi3+0xf0>
  801fdb:	85 ff                	test   %edi,%edi
  801fdd:	89 fd                	mov    %edi,%ebp
  801fdf:	75 0b                	jne    801fec <__udivdi3+0x3c>
  801fe1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fe6:	31 d2                	xor    %edx,%edx
  801fe8:	f7 f7                	div    %edi
  801fea:	89 c5                	mov    %eax,%ebp
  801fec:	89 c8                	mov    %ecx,%eax
  801fee:	31 d2                	xor    %edx,%edx
  801ff0:	f7 f5                	div    %ebp
  801ff2:	89 c1                	mov    %eax,%ecx
  801ff4:	89 d8                	mov    %ebx,%eax
  801ff6:	89 cf                	mov    %ecx,%edi
  801ff8:	f7 f5                	div    %ebp
  801ffa:	89 c3                	mov    %eax,%ebx
  801ffc:	89 d8                	mov    %ebx,%eax
  801ffe:	89 fa                	mov    %edi,%edx
  802000:	83 c4 1c             	add    $0x1c,%esp
  802003:	5b                   	pop    %ebx
  802004:	5e                   	pop    %esi
  802005:	5f                   	pop    %edi
  802006:	5d                   	pop    %ebp
  802007:	c3                   	ret    
  802008:	90                   	nop
  802009:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802010:	39 ce                	cmp    %ecx,%esi
  802012:	77 74                	ja     802088 <__udivdi3+0xd8>
  802014:	0f bd fe             	bsr    %esi,%edi
  802017:	83 f7 1f             	xor    $0x1f,%edi
  80201a:	0f 84 98 00 00 00    	je     8020b8 <__udivdi3+0x108>
  802020:	bb 20 00 00 00       	mov    $0x20,%ebx
  802025:	89 f9                	mov    %edi,%ecx
  802027:	89 c5                	mov    %eax,%ebp
  802029:	29 fb                	sub    %edi,%ebx
  80202b:	d3 e6                	shl    %cl,%esi
  80202d:	89 d9                	mov    %ebx,%ecx
  80202f:	d3 ed                	shr    %cl,%ebp
  802031:	89 f9                	mov    %edi,%ecx
  802033:	d3 e0                	shl    %cl,%eax
  802035:	09 ee                	or     %ebp,%esi
  802037:	89 d9                	mov    %ebx,%ecx
  802039:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80203d:	89 d5                	mov    %edx,%ebp
  80203f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802043:	d3 ed                	shr    %cl,%ebp
  802045:	89 f9                	mov    %edi,%ecx
  802047:	d3 e2                	shl    %cl,%edx
  802049:	89 d9                	mov    %ebx,%ecx
  80204b:	d3 e8                	shr    %cl,%eax
  80204d:	09 c2                	or     %eax,%edx
  80204f:	89 d0                	mov    %edx,%eax
  802051:	89 ea                	mov    %ebp,%edx
  802053:	f7 f6                	div    %esi
  802055:	89 d5                	mov    %edx,%ebp
  802057:	89 c3                	mov    %eax,%ebx
  802059:	f7 64 24 0c          	mull   0xc(%esp)
  80205d:	39 d5                	cmp    %edx,%ebp
  80205f:	72 10                	jb     802071 <__udivdi3+0xc1>
  802061:	8b 74 24 08          	mov    0x8(%esp),%esi
  802065:	89 f9                	mov    %edi,%ecx
  802067:	d3 e6                	shl    %cl,%esi
  802069:	39 c6                	cmp    %eax,%esi
  80206b:	73 07                	jae    802074 <__udivdi3+0xc4>
  80206d:	39 d5                	cmp    %edx,%ebp
  80206f:	75 03                	jne    802074 <__udivdi3+0xc4>
  802071:	83 eb 01             	sub    $0x1,%ebx
  802074:	31 ff                	xor    %edi,%edi
  802076:	89 d8                	mov    %ebx,%eax
  802078:	89 fa                	mov    %edi,%edx
  80207a:	83 c4 1c             	add    $0x1c,%esp
  80207d:	5b                   	pop    %ebx
  80207e:	5e                   	pop    %esi
  80207f:	5f                   	pop    %edi
  802080:	5d                   	pop    %ebp
  802081:	c3                   	ret    
  802082:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802088:	31 ff                	xor    %edi,%edi
  80208a:	31 db                	xor    %ebx,%ebx
  80208c:	89 d8                	mov    %ebx,%eax
  80208e:	89 fa                	mov    %edi,%edx
  802090:	83 c4 1c             	add    $0x1c,%esp
  802093:	5b                   	pop    %ebx
  802094:	5e                   	pop    %esi
  802095:	5f                   	pop    %edi
  802096:	5d                   	pop    %ebp
  802097:	c3                   	ret    
  802098:	90                   	nop
  802099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020a0:	89 d8                	mov    %ebx,%eax
  8020a2:	f7 f7                	div    %edi
  8020a4:	31 ff                	xor    %edi,%edi
  8020a6:	89 c3                	mov    %eax,%ebx
  8020a8:	89 d8                	mov    %ebx,%eax
  8020aa:	89 fa                	mov    %edi,%edx
  8020ac:	83 c4 1c             	add    $0x1c,%esp
  8020af:	5b                   	pop    %ebx
  8020b0:	5e                   	pop    %esi
  8020b1:	5f                   	pop    %edi
  8020b2:	5d                   	pop    %ebp
  8020b3:	c3                   	ret    
  8020b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020b8:	39 ce                	cmp    %ecx,%esi
  8020ba:	72 0c                	jb     8020c8 <__udivdi3+0x118>
  8020bc:	31 db                	xor    %ebx,%ebx
  8020be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020c2:	0f 87 34 ff ff ff    	ja     801ffc <__udivdi3+0x4c>
  8020c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020cd:	e9 2a ff ff ff       	jmp    801ffc <__udivdi3+0x4c>
  8020d2:	66 90                	xchg   %ax,%ax
  8020d4:	66 90                	xchg   %ax,%ax
  8020d6:	66 90                	xchg   %ax,%ax
  8020d8:	66 90                	xchg   %ax,%ax
  8020da:	66 90                	xchg   %ax,%ax
  8020dc:	66 90                	xchg   %ax,%ax
  8020de:	66 90                	xchg   %ax,%ax

008020e0 <__umoddi3>:
  8020e0:	55                   	push   %ebp
  8020e1:	57                   	push   %edi
  8020e2:	56                   	push   %esi
  8020e3:	53                   	push   %ebx
  8020e4:	83 ec 1c             	sub    $0x1c,%esp
  8020e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020f7:	85 d2                	test   %edx,%edx
  8020f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802101:	89 f3                	mov    %esi,%ebx
  802103:	89 3c 24             	mov    %edi,(%esp)
  802106:	89 74 24 04          	mov    %esi,0x4(%esp)
  80210a:	75 1c                	jne    802128 <__umoddi3+0x48>
  80210c:	39 f7                	cmp    %esi,%edi
  80210e:	76 50                	jbe    802160 <__umoddi3+0x80>
  802110:	89 c8                	mov    %ecx,%eax
  802112:	89 f2                	mov    %esi,%edx
  802114:	f7 f7                	div    %edi
  802116:	89 d0                	mov    %edx,%eax
  802118:	31 d2                	xor    %edx,%edx
  80211a:	83 c4 1c             	add    $0x1c,%esp
  80211d:	5b                   	pop    %ebx
  80211e:	5e                   	pop    %esi
  80211f:	5f                   	pop    %edi
  802120:	5d                   	pop    %ebp
  802121:	c3                   	ret    
  802122:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802128:	39 f2                	cmp    %esi,%edx
  80212a:	89 d0                	mov    %edx,%eax
  80212c:	77 52                	ja     802180 <__umoddi3+0xa0>
  80212e:	0f bd ea             	bsr    %edx,%ebp
  802131:	83 f5 1f             	xor    $0x1f,%ebp
  802134:	75 5a                	jne    802190 <__umoddi3+0xb0>
  802136:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80213a:	0f 82 e0 00 00 00    	jb     802220 <__umoddi3+0x140>
  802140:	39 0c 24             	cmp    %ecx,(%esp)
  802143:	0f 86 d7 00 00 00    	jbe    802220 <__umoddi3+0x140>
  802149:	8b 44 24 08          	mov    0x8(%esp),%eax
  80214d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802151:	83 c4 1c             	add    $0x1c,%esp
  802154:	5b                   	pop    %ebx
  802155:	5e                   	pop    %esi
  802156:	5f                   	pop    %edi
  802157:	5d                   	pop    %ebp
  802158:	c3                   	ret    
  802159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802160:	85 ff                	test   %edi,%edi
  802162:	89 fd                	mov    %edi,%ebp
  802164:	75 0b                	jne    802171 <__umoddi3+0x91>
  802166:	b8 01 00 00 00       	mov    $0x1,%eax
  80216b:	31 d2                	xor    %edx,%edx
  80216d:	f7 f7                	div    %edi
  80216f:	89 c5                	mov    %eax,%ebp
  802171:	89 f0                	mov    %esi,%eax
  802173:	31 d2                	xor    %edx,%edx
  802175:	f7 f5                	div    %ebp
  802177:	89 c8                	mov    %ecx,%eax
  802179:	f7 f5                	div    %ebp
  80217b:	89 d0                	mov    %edx,%eax
  80217d:	eb 99                	jmp    802118 <__umoddi3+0x38>
  80217f:	90                   	nop
  802180:	89 c8                	mov    %ecx,%eax
  802182:	89 f2                	mov    %esi,%edx
  802184:	83 c4 1c             	add    $0x1c,%esp
  802187:	5b                   	pop    %ebx
  802188:	5e                   	pop    %esi
  802189:	5f                   	pop    %edi
  80218a:	5d                   	pop    %ebp
  80218b:	c3                   	ret    
  80218c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802190:	8b 34 24             	mov    (%esp),%esi
  802193:	bf 20 00 00 00       	mov    $0x20,%edi
  802198:	89 e9                	mov    %ebp,%ecx
  80219a:	29 ef                	sub    %ebp,%edi
  80219c:	d3 e0                	shl    %cl,%eax
  80219e:	89 f9                	mov    %edi,%ecx
  8021a0:	89 f2                	mov    %esi,%edx
  8021a2:	d3 ea                	shr    %cl,%edx
  8021a4:	89 e9                	mov    %ebp,%ecx
  8021a6:	09 c2                	or     %eax,%edx
  8021a8:	89 d8                	mov    %ebx,%eax
  8021aa:	89 14 24             	mov    %edx,(%esp)
  8021ad:	89 f2                	mov    %esi,%edx
  8021af:	d3 e2                	shl    %cl,%edx
  8021b1:	89 f9                	mov    %edi,%ecx
  8021b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021bb:	d3 e8                	shr    %cl,%eax
  8021bd:	89 e9                	mov    %ebp,%ecx
  8021bf:	89 c6                	mov    %eax,%esi
  8021c1:	d3 e3                	shl    %cl,%ebx
  8021c3:	89 f9                	mov    %edi,%ecx
  8021c5:	89 d0                	mov    %edx,%eax
  8021c7:	d3 e8                	shr    %cl,%eax
  8021c9:	89 e9                	mov    %ebp,%ecx
  8021cb:	09 d8                	or     %ebx,%eax
  8021cd:	89 d3                	mov    %edx,%ebx
  8021cf:	89 f2                	mov    %esi,%edx
  8021d1:	f7 34 24             	divl   (%esp)
  8021d4:	89 d6                	mov    %edx,%esi
  8021d6:	d3 e3                	shl    %cl,%ebx
  8021d8:	f7 64 24 04          	mull   0x4(%esp)
  8021dc:	39 d6                	cmp    %edx,%esi
  8021de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021e2:	89 d1                	mov    %edx,%ecx
  8021e4:	89 c3                	mov    %eax,%ebx
  8021e6:	72 08                	jb     8021f0 <__umoddi3+0x110>
  8021e8:	75 11                	jne    8021fb <__umoddi3+0x11b>
  8021ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021ee:	73 0b                	jae    8021fb <__umoddi3+0x11b>
  8021f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021f4:	1b 14 24             	sbb    (%esp),%edx
  8021f7:	89 d1                	mov    %edx,%ecx
  8021f9:	89 c3                	mov    %eax,%ebx
  8021fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021ff:	29 da                	sub    %ebx,%edx
  802201:	19 ce                	sbb    %ecx,%esi
  802203:	89 f9                	mov    %edi,%ecx
  802205:	89 f0                	mov    %esi,%eax
  802207:	d3 e0                	shl    %cl,%eax
  802209:	89 e9                	mov    %ebp,%ecx
  80220b:	d3 ea                	shr    %cl,%edx
  80220d:	89 e9                	mov    %ebp,%ecx
  80220f:	d3 ee                	shr    %cl,%esi
  802211:	09 d0                	or     %edx,%eax
  802213:	89 f2                	mov    %esi,%edx
  802215:	83 c4 1c             	add    $0x1c,%esp
  802218:	5b                   	pop    %ebx
  802219:	5e                   	pop    %esi
  80221a:	5f                   	pop    %edi
  80221b:	5d                   	pop    %ebp
  80221c:	c3                   	ret    
  80221d:	8d 76 00             	lea    0x0(%esi),%esi
  802220:	29 f9                	sub    %edi,%ecx
  802222:	19 d6                	sbb    %edx,%esi
  802224:	89 74 24 04          	mov    %esi,0x4(%esp)
  802228:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80222c:	e9 18 ff ff ff       	jmp    802149 <__umoddi3+0x69>
