
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
  800039:	68 80 22 80 00       	push   $0x802280
  80003e:	e8 0e 01 00 00       	call   800151 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 08 40 80 00       	mov    0x804008,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 8e 22 80 00       	push   $0x80228e
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
  8000aa:	e8 47 0e 00 00       	call   800ef6 <close_all>
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
  8001b4:	e8 37 1e 00 00       	call   801ff0 <__udivdi3>
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
  8001f7:	e8 24 1f 00 00       	call   802120 <__umoddi3>
  8001fc:	83 c4 14             	add    $0x14,%esp
  8001ff:	0f be 80 af 22 80 00 	movsbl 0x8022af(%eax),%eax
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
  8002fb:	ff 24 85 00 24 80 00 	jmp    *0x802400(,%eax,4)
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
  8003bf:	8b 14 85 60 25 80 00 	mov    0x802560(,%eax,4),%edx
  8003c6:	85 d2                	test   %edx,%edx
  8003c8:	75 18                	jne    8003e2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003ca:	50                   	push   %eax
  8003cb:	68 c7 22 80 00       	push   $0x8022c7
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
  8003e3:	68 95 26 80 00       	push   $0x802695
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
  800407:	b8 c0 22 80 00       	mov    $0x8022c0,%eax
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
  800a82:	68 bf 25 80 00       	push   $0x8025bf
  800a87:	6a 23                	push   $0x23
  800a89:	68 dc 25 80 00       	push   $0x8025dc
  800a8e:	e8 dc 13 00 00       	call   801e6f <_panic>

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
  800b03:	68 bf 25 80 00       	push   $0x8025bf
  800b08:	6a 23                	push   $0x23
  800b0a:	68 dc 25 80 00       	push   $0x8025dc
  800b0f:	e8 5b 13 00 00       	call   801e6f <_panic>

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
  800b45:	68 bf 25 80 00       	push   $0x8025bf
  800b4a:	6a 23                	push   $0x23
  800b4c:	68 dc 25 80 00       	push   $0x8025dc
  800b51:	e8 19 13 00 00       	call   801e6f <_panic>

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
  800b87:	68 bf 25 80 00       	push   $0x8025bf
  800b8c:	6a 23                	push   $0x23
  800b8e:	68 dc 25 80 00       	push   $0x8025dc
  800b93:	e8 d7 12 00 00       	call   801e6f <_panic>

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
  800bc9:	68 bf 25 80 00       	push   $0x8025bf
  800bce:	6a 23                	push   $0x23
  800bd0:	68 dc 25 80 00       	push   $0x8025dc
  800bd5:	e8 95 12 00 00       	call   801e6f <_panic>

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
  800c0b:	68 bf 25 80 00       	push   $0x8025bf
  800c10:	6a 23                	push   $0x23
  800c12:	68 dc 25 80 00       	push   $0x8025dc
  800c17:	e8 53 12 00 00       	call   801e6f <_panic>

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
  800c4d:	68 bf 25 80 00       	push   $0x8025bf
  800c52:	6a 23                	push   $0x23
  800c54:	68 dc 25 80 00       	push   $0x8025dc
  800c59:	e8 11 12 00 00       	call   801e6f <_panic>

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
  800cb1:	68 bf 25 80 00       	push   $0x8025bf
  800cb6:	6a 23                	push   $0x23
  800cb8:	68 dc 25 80 00       	push   $0x8025dc
  800cbd:	e8 ad 11 00 00       	call   801e6f <_panic>

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
  800d12:	68 bf 25 80 00       	push   $0x8025bf
  800d17:	6a 23                	push   $0x23
  800d19:	68 dc 25 80 00       	push   $0x8025dc
  800d1e:	e8 4c 11 00 00       	call   801e6f <_panic>

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

00800d2b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d31:	05 00 00 00 30       	add    $0x30000000,%eax
  800d36:	c1 e8 0c             	shr    $0xc,%eax
}
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d41:	05 00 00 00 30       	add    $0x30000000,%eax
  800d46:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d4b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    

00800d52 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d52:	55                   	push   %ebp
  800d53:	89 e5                	mov    %esp,%ebp
  800d55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d58:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d5d:	89 c2                	mov    %eax,%edx
  800d5f:	c1 ea 16             	shr    $0x16,%edx
  800d62:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d69:	f6 c2 01             	test   $0x1,%dl
  800d6c:	74 11                	je     800d7f <fd_alloc+0x2d>
  800d6e:	89 c2                	mov    %eax,%edx
  800d70:	c1 ea 0c             	shr    $0xc,%edx
  800d73:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d7a:	f6 c2 01             	test   $0x1,%dl
  800d7d:	75 09                	jne    800d88 <fd_alloc+0x36>
			*fd_store = fd;
  800d7f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d81:	b8 00 00 00 00       	mov    $0x0,%eax
  800d86:	eb 17                	jmp    800d9f <fd_alloc+0x4d>
  800d88:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d8d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d92:	75 c9                	jne    800d5d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d94:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d9a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800da7:	83 f8 1f             	cmp    $0x1f,%eax
  800daa:	77 36                	ja     800de2 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dac:	c1 e0 0c             	shl    $0xc,%eax
  800daf:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800db4:	89 c2                	mov    %eax,%edx
  800db6:	c1 ea 16             	shr    $0x16,%edx
  800db9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dc0:	f6 c2 01             	test   $0x1,%dl
  800dc3:	74 24                	je     800de9 <fd_lookup+0x48>
  800dc5:	89 c2                	mov    %eax,%edx
  800dc7:	c1 ea 0c             	shr    $0xc,%edx
  800dca:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dd1:	f6 c2 01             	test   $0x1,%dl
  800dd4:	74 1a                	je     800df0 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dd6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dd9:	89 02                	mov    %eax,(%edx)
	return 0;
  800ddb:	b8 00 00 00 00       	mov    $0x0,%eax
  800de0:	eb 13                	jmp    800df5 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800de2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800de7:	eb 0c                	jmp    800df5 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800de9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dee:	eb 05                	jmp    800df5 <fd_lookup+0x54>
  800df0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800df5:	5d                   	pop    %ebp
  800df6:	c3                   	ret    

00800df7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	83 ec 08             	sub    $0x8,%esp
  800dfd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e00:	ba 68 26 80 00       	mov    $0x802668,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e05:	eb 13                	jmp    800e1a <dev_lookup+0x23>
  800e07:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e0a:	39 08                	cmp    %ecx,(%eax)
  800e0c:	75 0c                	jne    800e1a <dev_lookup+0x23>
			*dev = devtab[i];
  800e0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e11:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e13:	b8 00 00 00 00       	mov    $0x0,%eax
  800e18:	eb 2e                	jmp    800e48 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e1a:	8b 02                	mov    (%edx),%eax
  800e1c:	85 c0                	test   %eax,%eax
  800e1e:	75 e7                	jne    800e07 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e20:	a1 08 40 80 00       	mov    0x804008,%eax
  800e25:	8b 40 48             	mov    0x48(%eax),%eax
  800e28:	83 ec 04             	sub    $0x4,%esp
  800e2b:	51                   	push   %ecx
  800e2c:	50                   	push   %eax
  800e2d:	68 ec 25 80 00       	push   $0x8025ec
  800e32:	e8 1a f3 ff ff       	call   800151 <cprintf>
	*dev = 0;
  800e37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e3a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e40:	83 c4 10             	add    $0x10,%esp
  800e43:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e48:	c9                   	leave  
  800e49:	c3                   	ret    

00800e4a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	56                   	push   %esi
  800e4e:	53                   	push   %ebx
  800e4f:	83 ec 10             	sub    $0x10,%esp
  800e52:	8b 75 08             	mov    0x8(%ebp),%esi
  800e55:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e5b:	50                   	push   %eax
  800e5c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e62:	c1 e8 0c             	shr    $0xc,%eax
  800e65:	50                   	push   %eax
  800e66:	e8 36 ff ff ff       	call   800da1 <fd_lookup>
  800e6b:	83 c4 08             	add    $0x8,%esp
  800e6e:	85 c0                	test   %eax,%eax
  800e70:	78 05                	js     800e77 <fd_close+0x2d>
	    || fd != fd2)
  800e72:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e75:	74 0c                	je     800e83 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e77:	84 db                	test   %bl,%bl
  800e79:	ba 00 00 00 00       	mov    $0x0,%edx
  800e7e:	0f 44 c2             	cmove  %edx,%eax
  800e81:	eb 41                	jmp    800ec4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e83:	83 ec 08             	sub    $0x8,%esp
  800e86:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e89:	50                   	push   %eax
  800e8a:	ff 36                	pushl  (%esi)
  800e8c:	e8 66 ff ff ff       	call   800df7 <dev_lookup>
  800e91:	89 c3                	mov    %eax,%ebx
  800e93:	83 c4 10             	add    $0x10,%esp
  800e96:	85 c0                	test   %eax,%eax
  800e98:	78 1a                	js     800eb4 <fd_close+0x6a>
		if (dev->dev_close)
  800e9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e9d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ea0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ea5:	85 c0                	test   %eax,%eax
  800ea7:	74 0b                	je     800eb4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ea9:	83 ec 0c             	sub    $0xc,%esp
  800eac:	56                   	push   %esi
  800ead:	ff d0                	call   *%eax
  800eaf:	89 c3                	mov    %eax,%ebx
  800eb1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800eb4:	83 ec 08             	sub    $0x8,%esp
  800eb7:	56                   	push   %esi
  800eb8:	6a 00                	push   $0x0
  800eba:	e8 9f fc ff ff       	call   800b5e <sys_page_unmap>
	return r;
  800ebf:	83 c4 10             	add    $0x10,%esp
  800ec2:	89 d8                	mov    %ebx,%eax
}
  800ec4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ec7:	5b                   	pop    %ebx
  800ec8:	5e                   	pop    %esi
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ed1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ed4:	50                   	push   %eax
  800ed5:	ff 75 08             	pushl  0x8(%ebp)
  800ed8:	e8 c4 fe ff ff       	call   800da1 <fd_lookup>
  800edd:	83 c4 08             	add    $0x8,%esp
  800ee0:	85 c0                	test   %eax,%eax
  800ee2:	78 10                	js     800ef4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ee4:	83 ec 08             	sub    $0x8,%esp
  800ee7:	6a 01                	push   $0x1
  800ee9:	ff 75 f4             	pushl  -0xc(%ebp)
  800eec:	e8 59 ff ff ff       	call   800e4a <fd_close>
  800ef1:	83 c4 10             	add    $0x10,%esp
}
  800ef4:	c9                   	leave  
  800ef5:	c3                   	ret    

00800ef6 <close_all>:

void
close_all(void)
{
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
  800ef9:	53                   	push   %ebx
  800efa:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800efd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f02:	83 ec 0c             	sub    $0xc,%esp
  800f05:	53                   	push   %ebx
  800f06:	e8 c0 ff ff ff       	call   800ecb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f0b:	83 c3 01             	add    $0x1,%ebx
  800f0e:	83 c4 10             	add    $0x10,%esp
  800f11:	83 fb 20             	cmp    $0x20,%ebx
  800f14:	75 ec                	jne    800f02 <close_all+0xc>
		close(i);
}
  800f16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f19:	c9                   	leave  
  800f1a:	c3                   	ret    

00800f1b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f1b:	55                   	push   %ebp
  800f1c:	89 e5                	mov    %esp,%ebp
  800f1e:	57                   	push   %edi
  800f1f:	56                   	push   %esi
  800f20:	53                   	push   %ebx
  800f21:	83 ec 2c             	sub    $0x2c,%esp
  800f24:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f27:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f2a:	50                   	push   %eax
  800f2b:	ff 75 08             	pushl  0x8(%ebp)
  800f2e:	e8 6e fe ff ff       	call   800da1 <fd_lookup>
  800f33:	83 c4 08             	add    $0x8,%esp
  800f36:	85 c0                	test   %eax,%eax
  800f38:	0f 88 c1 00 00 00    	js     800fff <dup+0xe4>
		return r;
	close(newfdnum);
  800f3e:	83 ec 0c             	sub    $0xc,%esp
  800f41:	56                   	push   %esi
  800f42:	e8 84 ff ff ff       	call   800ecb <close>

	newfd = INDEX2FD(newfdnum);
  800f47:	89 f3                	mov    %esi,%ebx
  800f49:	c1 e3 0c             	shl    $0xc,%ebx
  800f4c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f52:	83 c4 04             	add    $0x4,%esp
  800f55:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f58:	e8 de fd ff ff       	call   800d3b <fd2data>
  800f5d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f5f:	89 1c 24             	mov    %ebx,(%esp)
  800f62:	e8 d4 fd ff ff       	call   800d3b <fd2data>
  800f67:	83 c4 10             	add    $0x10,%esp
  800f6a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f6d:	89 f8                	mov    %edi,%eax
  800f6f:	c1 e8 16             	shr    $0x16,%eax
  800f72:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f79:	a8 01                	test   $0x1,%al
  800f7b:	74 37                	je     800fb4 <dup+0x99>
  800f7d:	89 f8                	mov    %edi,%eax
  800f7f:	c1 e8 0c             	shr    $0xc,%eax
  800f82:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f89:	f6 c2 01             	test   $0x1,%dl
  800f8c:	74 26                	je     800fb4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f8e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f95:	83 ec 0c             	sub    $0xc,%esp
  800f98:	25 07 0e 00 00       	and    $0xe07,%eax
  800f9d:	50                   	push   %eax
  800f9e:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fa1:	6a 00                	push   $0x0
  800fa3:	57                   	push   %edi
  800fa4:	6a 00                	push   $0x0
  800fa6:	e8 71 fb ff ff       	call   800b1c <sys_page_map>
  800fab:	89 c7                	mov    %eax,%edi
  800fad:	83 c4 20             	add    $0x20,%esp
  800fb0:	85 c0                	test   %eax,%eax
  800fb2:	78 2e                	js     800fe2 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fb4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fb7:	89 d0                	mov    %edx,%eax
  800fb9:	c1 e8 0c             	shr    $0xc,%eax
  800fbc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fc3:	83 ec 0c             	sub    $0xc,%esp
  800fc6:	25 07 0e 00 00       	and    $0xe07,%eax
  800fcb:	50                   	push   %eax
  800fcc:	53                   	push   %ebx
  800fcd:	6a 00                	push   $0x0
  800fcf:	52                   	push   %edx
  800fd0:	6a 00                	push   $0x0
  800fd2:	e8 45 fb ff ff       	call   800b1c <sys_page_map>
  800fd7:	89 c7                	mov    %eax,%edi
  800fd9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fdc:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fde:	85 ff                	test   %edi,%edi
  800fe0:	79 1d                	jns    800fff <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fe2:	83 ec 08             	sub    $0x8,%esp
  800fe5:	53                   	push   %ebx
  800fe6:	6a 00                	push   $0x0
  800fe8:	e8 71 fb ff ff       	call   800b5e <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fed:	83 c4 08             	add    $0x8,%esp
  800ff0:	ff 75 d4             	pushl  -0x2c(%ebp)
  800ff3:	6a 00                	push   $0x0
  800ff5:	e8 64 fb ff ff       	call   800b5e <sys_page_unmap>
	return r;
  800ffa:	83 c4 10             	add    $0x10,%esp
  800ffd:	89 f8                	mov    %edi,%eax
}
  800fff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801002:	5b                   	pop    %ebx
  801003:	5e                   	pop    %esi
  801004:	5f                   	pop    %edi
  801005:	5d                   	pop    %ebp
  801006:	c3                   	ret    

00801007 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	53                   	push   %ebx
  80100b:	83 ec 14             	sub    $0x14,%esp
  80100e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801011:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801014:	50                   	push   %eax
  801015:	53                   	push   %ebx
  801016:	e8 86 fd ff ff       	call   800da1 <fd_lookup>
  80101b:	83 c4 08             	add    $0x8,%esp
  80101e:	89 c2                	mov    %eax,%edx
  801020:	85 c0                	test   %eax,%eax
  801022:	78 6d                	js     801091 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801024:	83 ec 08             	sub    $0x8,%esp
  801027:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80102a:	50                   	push   %eax
  80102b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80102e:	ff 30                	pushl  (%eax)
  801030:	e8 c2 fd ff ff       	call   800df7 <dev_lookup>
  801035:	83 c4 10             	add    $0x10,%esp
  801038:	85 c0                	test   %eax,%eax
  80103a:	78 4c                	js     801088 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80103c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80103f:	8b 42 08             	mov    0x8(%edx),%eax
  801042:	83 e0 03             	and    $0x3,%eax
  801045:	83 f8 01             	cmp    $0x1,%eax
  801048:	75 21                	jne    80106b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80104a:	a1 08 40 80 00       	mov    0x804008,%eax
  80104f:	8b 40 48             	mov    0x48(%eax),%eax
  801052:	83 ec 04             	sub    $0x4,%esp
  801055:	53                   	push   %ebx
  801056:	50                   	push   %eax
  801057:	68 2d 26 80 00       	push   $0x80262d
  80105c:	e8 f0 f0 ff ff       	call   800151 <cprintf>
		return -E_INVAL;
  801061:	83 c4 10             	add    $0x10,%esp
  801064:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801069:	eb 26                	jmp    801091 <read+0x8a>
	}
	if (!dev->dev_read)
  80106b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80106e:	8b 40 08             	mov    0x8(%eax),%eax
  801071:	85 c0                	test   %eax,%eax
  801073:	74 17                	je     80108c <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801075:	83 ec 04             	sub    $0x4,%esp
  801078:	ff 75 10             	pushl  0x10(%ebp)
  80107b:	ff 75 0c             	pushl  0xc(%ebp)
  80107e:	52                   	push   %edx
  80107f:	ff d0                	call   *%eax
  801081:	89 c2                	mov    %eax,%edx
  801083:	83 c4 10             	add    $0x10,%esp
  801086:	eb 09                	jmp    801091 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801088:	89 c2                	mov    %eax,%edx
  80108a:	eb 05                	jmp    801091 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80108c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801091:	89 d0                	mov    %edx,%eax
  801093:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801096:	c9                   	leave  
  801097:	c3                   	ret    

00801098 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	57                   	push   %edi
  80109c:	56                   	push   %esi
  80109d:	53                   	push   %ebx
  80109e:	83 ec 0c             	sub    $0xc,%esp
  8010a1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010a4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010a7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ac:	eb 21                	jmp    8010cf <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010ae:	83 ec 04             	sub    $0x4,%esp
  8010b1:	89 f0                	mov    %esi,%eax
  8010b3:	29 d8                	sub    %ebx,%eax
  8010b5:	50                   	push   %eax
  8010b6:	89 d8                	mov    %ebx,%eax
  8010b8:	03 45 0c             	add    0xc(%ebp),%eax
  8010bb:	50                   	push   %eax
  8010bc:	57                   	push   %edi
  8010bd:	e8 45 ff ff ff       	call   801007 <read>
		if (m < 0)
  8010c2:	83 c4 10             	add    $0x10,%esp
  8010c5:	85 c0                	test   %eax,%eax
  8010c7:	78 10                	js     8010d9 <readn+0x41>
			return m;
		if (m == 0)
  8010c9:	85 c0                	test   %eax,%eax
  8010cb:	74 0a                	je     8010d7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010cd:	01 c3                	add    %eax,%ebx
  8010cf:	39 f3                	cmp    %esi,%ebx
  8010d1:	72 db                	jb     8010ae <readn+0x16>
  8010d3:	89 d8                	mov    %ebx,%eax
  8010d5:	eb 02                	jmp    8010d9 <readn+0x41>
  8010d7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010dc:	5b                   	pop    %ebx
  8010dd:	5e                   	pop    %esi
  8010de:	5f                   	pop    %edi
  8010df:	5d                   	pop    %ebp
  8010e0:	c3                   	ret    

008010e1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	53                   	push   %ebx
  8010e5:	83 ec 14             	sub    $0x14,%esp
  8010e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010ee:	50                   	push   %eax
  8010ef:	53                   	push   %ebx
  8010f0:	e8 ac fc ff ff       	call   800da1 <fd_lookup>
  8010f5:	83 c4 08             	add    $0x8,%esp
  8010f8:	89 c2                	mov    %eax,%edx
  8010fa:	85 c0                	test   %eax,%eax
  8010fc:	78 68                	js     801166 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010fe:	83 ec 08             	sub    $0x8,%esp
  801101:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801104:	50                   	push   %eax
  801105:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801108:	ff 30                	pushl  (%eax)
  80110a:	e8 e8 fc ff ff       	call   800df7 <dev_lookup>
  80110f:	83 c4 10             	add    $0x10,%esp
  801112:	85 c0                	test   %eax,%eax
  801114:	78 47                	js     80115d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801116:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801119:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80111d:	75 21                	jne    801140 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80111f:	a1 08 40 80 00       	mov    0x804008,%eax
  801124:	8b 40 48             	mov    0x48(%eax),%eax
  801127:	83 ec 04             	sub    $0x4,%esp
  80112a:	53                   	push   %ebx
  80112b:	50                   	push   %eax
  80112c:	68 49 26 80 00       	push   $0x802649
  801131:	e8 1b f0 ff ff       	call   800151 <cprintf>
		return -E_INVAL;
  801136:	83 c4 10             	add    $0x10,%esp
  801139:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80113e:	eb 26                	jmp    801166 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801140:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801143:	8b 52 0c             	mov    0xc(%edx),%edx
  801146:	85 d2                	test   %edx,%edx
  801148:	74 17                	je     801161 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80114a:	83 ec 04             	sub    $0x4,%esp
  80114d:	ff 75 10             	pushl  0x10(%ebp)
  801150:	ff 75 0c             	pushl  0xc(%ebp)
  801153:	50                   	push   %eax
  801154:	ff d2                	call   *%edx
  801156:	89 c2                	mov    %eax,%edx
  801158:	83 c4 10             	add    $0x10,%esp
  80115b:	eb 09                	jmp    801166 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80115d:	89 c2                	mov    %eax,%edx
  80115f:	eb 05                	jmp    801166 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801161:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801166:	89 d0                	mov    %edx,%eax
  801168:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80116b:	c9                   	leave  
  80116c:	c3                   	ret    

0080116d <seek>:

int
seek(int fdnum, off_t offset)
{
  80116d:	55                   	push   %ebp
  80116e:	89 e5                	mov    %esp,%ebp
  801170:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801173:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801176:	50                   	push   %eax
  801177:	ff 75 08             	pushl  0x8(%ebp)
  80117a:	e8 22 fc ff ff       	call   800da1 <fd_lookup>
  80117f:	83 c4 08             	add    $0x8,%esp
  801182:	85 c0                	test   %eax,%eax
  801184:	78 0e                	js     801194 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801186:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801189:	8b 55 0c             	mov    0xc(%ebp),%edx
  80118c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80118f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801194:	c9                   	leave  
  801195:	c3                   	ret    

00801196 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801196:	55                   	push   %ebp
  801197:	89 e5                	mov    %esp,%ebp
  801199:	53                   	push   %ebx
  80119a:	83 ec 14             	sub    $0x14,%esp
  80119d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011a3:	50                   	push   %eax
  8011a4:	53                   	push   %ebx
  8011a5:	e8 f7 fb ff ff       	call   800da1 <fd_lookup>
  8011aa:	83 c4 08             	add    $0x8,%esp
  8011ad:	89 c2                	mov    %eax,%edx
  8011af:	85 c0                	test   %eax,%eax
  8011b1:	78 65                	js     801218 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b3:	83 ec 08             	sub    $0x8,%esp
  8011b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b9:	50                   	push   %eax
  8011ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011bd:	ff 30                	pushl  (%eax)
  8011bf:	e8 33 fc ff ff       	call   800df7 <dev_lookup>
  8011c4:	83 c4 10             	add    $0x10,%esp
  8011c7:	85 c0                	test   %eax,%eax
  8011c9:	78 44                	js     80120f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ce:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011d2:	75 21                	jne    8011f5 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011d4:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011d9:	8b 40 48             	mov    0x48(%eax),%eax
  8011dc:	83 ec 04             	sub    $0x4,%esp
  8011df:	53                   	push   %ebx
  8011e0:	50                   	push   %eax
  8011e1:	68 0c 26 80 00       	push   $0x80260c
  8011e6:	e8 66 ef ff ff       	call   800151 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011eb:	83 c4 10             	add    $0x10,%esp
  8011ee:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011f3:	eb 23                	jmp    801218 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011f8:	8b 52 18             	mov    0x18(%edx),%edx
  8011fb:	85 d2                	test   %edx,%edx
  8011fd:	74 14                	je     801213 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011ff:	83 ec 08             	sub    $0x8,%esp
  801202:	ff 75 0c             	pushl  0xc(%ebp)
  801205:	50                   	push   %eax
  801206:	ff d2                	call   *%edx
  801208:	89 c2                	mov    %eax,%edx
  80120a:	83 c4 10             	add    $0x10,%esp
  80120d:	eb 09                	jmp    801218 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120f:	89 c2                	mov    %eax,%edx
  801211:	eb 05                	jmp    801218 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801213:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801218:	89 d0                	mov    %edx,%eax
  80121a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80121d:	c9                   	leave  
  80121e:	c3                   	ret    

0080121f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	53                   	push   %ebx
  801223:	83 ec 14             	sub    $0x14,%esp
  801226:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801229:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80122c:	50                   	push   %eax
  80122d:	ff 75 08             	pushl  0x8(%ebp)
  801230:	e8 6c fb ff ff       	call   800da1 <fd_lookup>
  801235:	83 c4 08             	add    $0x8,%esp
  801238:	89 c2                	mov    %eax,%edx
  80123a:	85 c0                	test   %eax,%eax
  80123c:	78 58                	js     801296 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80123e:	83 ec 08             	sub    $0x8,%esp
  801241:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801244:	50                   	push   %eax
  801245:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801248:	ff 30                	pushl  (%eax)
  80124a:	e8 a8 fb ff ff       	call   800df7 <dev_lookup>
  80124f:	83 c4 10             	add    $0x10,%esp
  801252:	85 c0                	test   %eax,%eax
  801254:	78 37                	js     80128d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801256:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801259:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80125d:	74 32                	je     801291 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80125f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801262:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801269:	00 00 00 
	stat->st_isdir = 0;
  80126c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801273:	00 00 00 
	stat->st_dev = dev;
  801276:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80127c:	83 ec 08             	sub    $0x8,%esp
  80127f:	53                   	push   %ebx
  801280:	ff 75 f0             	pushl  -0x10(%ebp)
  801283:	ff 50 14             	call   *0x14(%eax)
  801286:	89 c2                	mov    %eax,%edx
  801288:	83 c4 10             	add    $0x10,%esp
  80128b:	eb 09                	jmp    801296 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128d:	89 c2                	mov    %eax,%edx
  80128f:	eb 05                	jmp    801296 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801291:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801296:	89 d0                	mov    %edx,%eax
  801298:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80129b:	c9                   	leave  
  80129c:	c3                   	ret    

0080129d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
  8012a0:	56                   	push   %esi
  8012a1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012a2:	83 ec 08             	sub    $0x8,%esp
  8012a5:	6a 00                	push   $0x0
  8012a7:	ff 75 08             	pushl  0x8(%ebp)
  8012aa:	e8 d6 01 00 00       	call   801485 <open>
  8012af:	89 c3                	mov    %eax,%ebx
  8012b1:	83 c4 10             	add    $0x10,%esp
  8012b4:	85 c0                	test   %eax,%eax
  8012b6:	78 1b                	js     8012d3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012b8:	83 ec 08             	sub    $0x8,%esp
  8012bb:	ff 75 0c             	pushl  0xc(%ebp)
  8012be:	50                   	push   %eax
  8012bf:	e8 5b ff ff ff       	call   80121f <fstat>
  8012c4:	89 c6                	mov    %eax,%esi
	close(fd);
  8012c6:	89 1c 24             	mov    %ebx,(%esp)
  8012c9:	e8 fd fb ff ff       	call   800ecb <close>
	return r;
  8012ce:	83 c4 10             	add    $0x10,%esp
  8012d1:	89 f0                	mov    %esi,%eax
}
  8012d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d6:	5b                   	pop    %ebx
  8012d7:	5e                   	pop    %esi
  8012d8:	5d                   	pop    %ebp
  8012d9:	c3                   	ret    

008012da <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012da:	55                   	push   %ebp
  8012db:	89 e5                	mov    %esp,%ebp
  8012dd:	56                   	push   %esi
  8012de:	53                   	push   %ebx
  8012df:	89 c6                	mov    %eax,%esi
  8012e1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012e3:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012ea:	75 12                	jne    8012fe <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012ec:	83 ec 0c             	sub    $0xc,%esp
  8012ef:	6a 01                	push   $0x1
  8012f1:	e8 7a 0c 00 00       	call   801f70 <ipc_find_env>
  8012f6:	a3 00 40 80 00       	mov    %eax,0x804000
  8012fb:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012fe:	6a 07                	push   $0x7
  801300:	68 00 50 80 00       	push   $0x805000
  801305:	56                   	push   %esi
  801306:	ff 35 00 40 80 00    	pushl  0x804000
  80130c:	e8 0b 0c 00 00       	call   801f1c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801311:	83 c4 0c             	add    $0xc,%esp
  801314:	6a 00                	push   $0x0
  801316:	53                   	push   %ebx
  801317:	6a 00                	push   $0x0
  801319:	e8 97 0b 00 00       	call   801eb5 <ipc_recv>
}
  80131e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801321:	5b                   	pop    %ebx
  801322:	5e                   	pop    %esi
  801323:	5d                   	pop    %ebp
  801324:	c3                   	ret    

00801325 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801325:	55                   	push   %ebp
  801326:	89 e5                	mov    %esp,%ebp
  801328:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80132b:	8b 45 08             	mov    0x8(%ebp),%eax
  80132e:	8b 40 0c             	mov    0xc(%eax),%eax
  801331:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801336:	8b 45 0c             	mov    0xc(%ebp),%eax
  801339:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80133e:	ba 00 00 00 00       	mov    $0x0,%edx
  801343:	b8 02 00 00 00       	mov    $0x2,%eax
  801348:	e8 8d ff ff ff       	call   8012da <fsipc>
}
  80134d:	c9                   	leave  
  80134e:	c3                   	ret    

0080134f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80134f:	55                   	push   %ebp
  801350:	89 e5                	mov    %esp,%ebp
  801352:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801355:	8b 45 08             	mov    0x8(%ebp),%eax
  801358:	8b 40 0c             	mov    0xc(%eax),%eax
  80135b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801360:	ba 00 00 00 00       	mov    $0x0,%edx
  801365:	b8 06 00 00 00       	mov    $0x6,%eax
  80136a:	e8 6b ff ff ff       	call   8012da <fsipc>
}
  80136f:	c9                   	leave  
  801370:	c3                   	ret    

00801371 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801371:	55                   	push   %ebp
  801372:	89 e5                	mov    %esp,%ebp
  801374:	53                   	push   %ebx
  801375:	83 ec 04             	sub    $0x4,%esp
  801378:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80137b:	8b 45 08             	mov    0x8(%ebp),%eax
  80137e:	8b 40 0c             	mov    0xc(%eax),%eax
  801381:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801386:	ba 00 00 00 00       	mov    $0x0,%edx
  80138b:	b8 05 00 00 00       	mov    $0x5,%eax
  801390:	e8 45 ff ff ff       	call   8012da <fsipc>
  801395:	85 c0                	test   %eax,%eax
  801397:	78 2c                	js     8013c5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801399:	83 ec 08             	sub    $0x8,%esp
  80139c:	68 00 50 80 00       	push   $0x805000
  8013a1:	53                   	push   %ebx
  8013a2:	e8 2f f3 ff ff       	call   8006d6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013a7:	a1 80 50 80 00       	mov    0x805080,%eax
  8013ac:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013b2:	a1 84 50 80 00       	mov    0x805084,%eax
  8013b7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013bd:	83 c4 10             	add    $0x10,%esp
  8013c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c8:	c9                   	leave  
  8013c9:	c3                   	ret    

008013ca <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	83 ec 0c             	sub    $0xc,%esp
  8013d0:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8013d6:	8b 52 0c             	mov    0xc(%edx),%edx
  8013d9:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8013df:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8013e4:	50                   	push   %eax
  8013e5:	ff 75 0c             	pushl  0xc(%ebp)
  8013e8:	68 08 50 80 00       	push   $0x805008
  8013ed:	e8 76 f4 ff ff       	call   800868 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8013f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f7:	b8 04 00 00 00       	mov    $0x4,%eax
  8013fc:	e8 d9 fe ff ff       	call   8012da <fsipc>

}
  801401:	c9                   	leave  
  801402:	c3                   	ret    

00801403 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801403:	55                   	push   %ebp
  801404:	89 e5                	mov    %esp,%ebp
  801406:	56                   	push   %esi
  801407:	53                   	push   %ebx
  801408:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80140b:	8b 45 08             	mov    0x8(%ebp),%eax
  80140e:	8b 40 0c             	mov    0xc(%eax),%eax
  801411:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801416:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80141c:	ba 00 00 00 00       	mov    $0x0,%edx
  801421:	b8 03 00 00 00       	mov    $0x3,%eax
  801426:	e8 af fe ff ff       	call   8012da <fsipc>
  80142b:	89 c3                	mov    %eax,%ebx
  80142d:	85 c0                	test   %eax,%eax
  80142f:	78 4b                	js     80147c <devfile_read+0x79>
		return r;
	assert(r <= n);
  801431:	39 c6                	cmp    %eax,%esi
  801433:	73 16                	jae    80144b <devfile_read+0x48>
  801435:	68 7c 26 80 00       	push   $0x80267c
  80143a:	68 83 26 80 00       	push   $0x802683
  80143f:	6a 7c                	push   $0x7c
  801441:	68 98 26 80 00       	push   $0x802698
  801446:	e8 24 0a 00 00       	call   801e6f <_panic>
	assert(r <= PGSIZE);
  80144b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801450:	7e 16                	jle    801468 <devfile_read+0x65>
  801452:	68 a3 26 80 00       	push   $0x8026a3
  801457:	68 83 26 80 00       	push   $0x802683
  80145c:	6a 7d                	push   $0x7d
  80145e:	68 98 26 80 00       	push   $0x802698
  801463:	e8 07 0a 00 00       	call   801e6f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801468:	83 ec 04             	sub    $0x4,%esp
  80146b:	50                   	push   %eax
  80146c:	68 00 50 80 00       	push   $0x805000
  801471:	ff 75 0c             	pushl  0xc(%ebp)
  801474:	e8 ef f3 ff ff       	call   800868 <memmove>
	return r;
  801479:	83 c4 10             	add    $0x10,%esp
}
  80147c:	89 d8                	mov    %ebx,%eax
  80147e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801481:	5b                   	pop    %ebx
  801482:	5e                   	pop    %esi
  801483:	5d                   	pop    %ebp
  801484:	c3                   	ret    

00801485 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801485:	55                   	push   %ebp
  801486:	89 e5                	mov    %esp,%ebp
  801488:	53                   	push   %ebx
  801489:	83 ec 20             	sub    $0x20,%esp
  80148c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80148f:	53                   	push   %ebx
  801490:	e8 08 f2 ff ff       	call   80069d <strlen>
  801495:	83 c4 10             	add    $0x10,%esp
  801498:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80149d:	7f 67                	jg     801506 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80149f:	83 ec 0c             	sub    $0xc,%esp
  8014a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a5:	50                   	push   %eax
  8014a6:	e8 a7 f8 ff ff       	call   800d52 <fd_alloc>
  8014ab:	83 c4 10             	add    $0x10,%esp
		return r;
  8014ae:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014b0:	85 c0                	test   %eax,%eax
  8014b2:	78 57                	js     80150b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014b4:	83 ec 08             	sub    $0x8,%esp
  8014b7:	53                   	push   %ebx
  8014b8:	68 00 50 80 00       	push   $0x805000
  8014bd:	e8 14 f2 ff ff       	call   8006d6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014c5:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8014d2:	e8 03 fe ff ff       	call   8012da <fsipc>
  8014d7:	89 c3                	mov    %eax,%ebx
  8014d9:	83 c4 10             	add    $0x10,%esp
  8014dc:	85 c0                	test   %eax,%eax
  8014de:	79 14                	jns    8014f4 <open+0x6f>
		fd_close(fd, 0);
  8014e0:	83 ec 08             	sub    $0x8,%esp
  8014e3:	6a 00                	push   $0x0
  8014e5:	ff 75 f4             	pushl  -0xc(%ebp)
  8014e8:	e8 5d f9 ff ff       	call   800e4a <fd_close>
		return r;
  8014ed:	83 c4 10             	add    $0x10,%esp
  8014f0:	89 da                	mov    %ebx,%edx
  8014f2:	eb 17                	jmp    80150b <open+0x86>
	}

	return fd2num(fd);
  8014f4:	83 ec 0c             	sub    $0xc,%esp
  8014f7:	ff 75 f4             	pushl  -0xc(%ebp)
  8014fa:	e8 2c f8 ff ff       	call   800d2b <fd2num>
  8014ff:	89 c2                	mov    %eax,%edx
  801501:	83 c4 10             	add    $0x10,%esp
  801504:	eb 05                	jmp    80150b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801506:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80150b:	89 d0                	mov    %edx,%eax
  80150d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801510:	c9                   	leave  
  801511:	c3                   	ret    

00801512 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801512:	55                   	push   %ebp
  801513:	89 e5                	mov    %esp,%ebp
  801515:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801518:	ba 00 00 00 00       	mov    $0x0,%edx
  80151d:	b8 08 00 00 00       	mov    $0x8,%eax
  801522:	e8 b3 fd ff ff       	call   8012da <fsipc>
}
  801527:	c9                   	leave  
  801528:	c3                   	ret    

00801529 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801529:	55                   	push   %ebp
  80152a:	89 e5                	mov    %esp,%ebp
  80152c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80152f:	68 af 26 80 00       	push   $0x8026af
  801534:	ff 75 0c             	pushl  0xc(%ebp)
  801537:	e8 9a f1 ff ff       	call   8006d6 <strcpy>
	return 0;
}
  80153c:	b8 00 00 00 00       	mov    $0x0,%eax
  801541:	c9                   	leave  
  801542:	c3                   	ret    

00801543 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801543:	55                   	push   %ebp
  801544:	89 e5                	mov    %esp,%ebp
  801546:	53                   	push   %ebx
  801547:	83 ec 10             	sub    $0x10,%esp
  80154a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80154d:	53                   	push   %ebx
  80154e:	e8 56 0a 00 00       	call   801fa9 <pageref>
  801553:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801556:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80155b:	83 f8 01             	cmp    $0x1,%eax
  80155e:	75 10                	jne    801570 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801560:	83 ec 0c             	sub    $0xc,%esp
  801563:	ff 73 0c             	pushl  0xc(%ebx)
  801566:	e8 c0 02 00 00       	call   80182b <nsipc_close>
  80156b:	89 c2                	mov    %eax,%edx
  80156d:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801570:	89 d0                	mov    %edx,%eax
  801572:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801575:	c9                   	leave  
  801576:	c3                   	ret    

00801577 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801577:	55                   	push   %ebp
  801578:	89 e5                	mov    %esp,%ebp
  80157a:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80157d:	6a 00                	push   $0x0
  80157f:	ff 75 10             	pushl  0x10(%ebp)
  801582:	ff 75 0c             	pushl  0xc(%ebp)
  801585:	8b 45 08             	mov    0x8(%ebp),%eax
  801588:	ff 70 0c             	pushl  0xc(%eax)
  80158b:	e8 78 03 00 00       	call   801908 <nsipc_send>
}
  801590:	c9                   	leave  
  801591:	c3                   	ret    

00801592 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801592:	55                   	push   %ebp
  801593:	89 e5                	mov    %esp,%ebp
  801595:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801598:	6a 00                	push   $0x0
  80159a:	ff 75 10             	pushl  0x10(%ebp)
  80159d:	ff 75 0c             	pushl  0xc(%ebp)
  8015a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a3:	ff 70 0c             	pushl  0xc(%eax)
  8015a6:	e8 f1 02 00 00       	call   80189c <nsipc_recv>
}
  8015ab:	c9                   	leave  
  8015ac:	c3                   	ret    

008015ad <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8015ad:	55                   	push   %ebp
  8015ae:	89 e5                	mov    %esp,%ebp
  8015b0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8015b3:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015b6:	52                   	push   %edx
  8015b7:	50                   	push   %eax
  8015b8:	e8 e4 f7 ff ff       	call   800da1 <fd_lookup>
  8015bd:	83 c4 10             	add    $0x10,%esp
  8015c0:	85 c0                	test   %eax,%eax
  8015c2:	78 17                	js     8015db <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8015c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c7:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8015cd:	39 08                	cmp    %ecx,(%eax)
  8015cf:	75 05                	jne    8015d6 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8015d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8015d4:	eb 05                	jmp    8015db <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8015d6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8015db:	c9                   	leave  
  8015dc:	c3                   	ret    

008015dd <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8015dd:	55                   	push   %ebp
  8015de:	89 e5                	mov    %esp,%ebp
  8015e0:	56                   	push   %esi
  8015e1:	53                   	push   %ebx
  8015e2:	83 ec 1c             	sub    $0x1c,%esp
  8015e5:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8015e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ea:	50                   	push   %eax
  8015eb:	e8 62 f7 ff ff       	call   800d52 <fd_alloc>
  8015f0:	89 c3                	mov    %eax,%ebx
  8015f2:	83 c4 10             	add    $0x10,%esp
  8015f5:	85 c0                	test   %eax,%eax
  8015f7:	78 1b                	js     801614 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8015f9:	83 ec 04             	sub    $0x4,%esp
  8015fc:	68 07 04 00 00       	push   $0x407
  801601:	ff 75 f4             	pushl  -0xc(%ebp)
  801604:	6a 00                	push   $0x0
  801606:	e8 ce f4 ff ff       	call   800ad9 <sys_page_alloc>
  80160b:	89 c3                	mov    %eax,%ebx
  80160d:	83 c4 10             	add    $0x10,%esp
  801610:	85 c0                	test   %eax,%eax
  801612:	79 10                	jns    801624 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801614:	83 ec 0c             	sub    $0xc,%esp
  801617:	56                   	push   %esi
  801618:	e8 0e 02 00 00       	call   80182b <nsipc_close>
		return r;
  80161d:	83 c4 10             	add    $0x10,%esp
  801620:	89 d8                	mov    %ebx,%eax
  801622:	eb 24                	jmp    801648 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801624:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80162a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162d:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80162f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801632:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801639:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80163c:	83 ec 0c             	sub    $0xc,%esp
  80163f:	50                   	push   %eax
  801640:	e8 e6 f6 ff ff       	call   800d2b <fd2num>
  801645:	83 c4 10             	add    $0x10,%esp
}
  801648:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80164b:	5b                   	pop    %ebx
  80164c:	5e                   	pop    %esi
  80164d:	5d                   	pop    %ebp
  80164e:	c3                   	ret    

0080164f <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80164f:	55                   	push   %ebp
  801650:	89 e5                	mov    %esp,%ebp
  801652:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801655:	8b 45 08             	mov    0x8(%ebp),%eax
  801658:	e8 50 ff ff ff       	call   8015ad <fd2sockid>
		return r;
  80165d:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80165f:	85 c0                	test   %eax,%eax
  801661:	78 1f                	js     801682 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801663:	83 ec 04             	sub    $0x4,%esp
  801666:	ff 75 10             	pushl  0x10(%ebp)
  801669:	ff 75 0c             	pushl  0xc(%ebp)
  80166c:	50                   	push   %eax
  80166d:	e8 12 01 00 00       	call   801784 <nsipc_accept>
  801672:	83 c4 10             	add    $0x10,%esp
		return r;
  801675:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801677:	85 c0                	test   %eax,%eax
  801679:	78 07                	js     801682 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80167b:	e8 5d ff ff ff       	call   8015dd <alloc_sockfd>
  801680:	89 c1                	mov    %eax,%ecx
}
  801682:	89 c8                	mov    %ecx,%eax
  801684:	c9                   	leave  
  801685:	c3                   	ret    

00801686 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801686:	55                   	push   %ebp
  801687:	89 e5                	mov    %esp,%ebp
  801689:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80168c:	8b 45 08             	mov    0x8(%ebp),%eax
  80168f:	e8 19 ff ff ff       	call   8015ad <fd2sockid>
  801694:	85 c0                	test   %eax,%eax
  801696:	78 12                	js     8016aa <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801698:	83 ec 04             	sub    $0x4,%esp
  80169b:	ff 75 10             	pushl  0x10(%ebp)
  80169e:	ff 75 0c             	pushl  0xc(%ebp)
  8016a1:	50                   	push   %eax
  8016a2:	e8 2d 01 00 00       	call   8017d4 <nsipc_bind>
  8016a7:	83 c4 10             	add    $0x10,%esp
}
  8016aa:	c9                   	leave  
  8016ab:	c3                   	ret    

008016ac <shutdown>:

int
shutdown(int s, int how)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b5:	e8 f3 fe ff ff       	call   8015ad <fd2sockid>
  8016ba:	85 c0                	test   %eax,%eax
  8016bc:	78 0f                	js     8016cd <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8016be:	83 ec 08             	sub    $0x8,%esp
  8016c1:	ff 75 0c             	pushl  0xc(%ebp)
  8016c4:	50                   	push   %eax
  8016c5:	e8 3f 01 00 00       	call   801809 <nsipc_shutdown>
  8016ca:	83 c4 10             	add    $0x10,%esp
}
  8016cd:	c9                   	leave  
  8016ce:	c3                   	ret    

008016cf <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8016cf:	55                   	push   %ebp
  8016d0:	89 e5                	mov    %esp,%ebp
  8016d2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d8:	e8 d0 fe ff ff       	call   8015ad <fd2sockid>
  8016dd:	85 c0                	test   %eax,%eax
  8016df:	78 12                	js     8016f3 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8016e1:	83 ec 04             	sub    $0x4,%esp
  8016e4:	ff 75 10             	pushl  0x10(%ebp)
  8016e7:	ff 75 0c             	pushl  0xc(%ebp)
  8016ea:	50                   	push   %eax
  8016eb:	e8 55 01 00 00       	call   801845 <nsipc_connect>
  8016f0:	83 c4 10             	add    $0x10,%esp
}
  8016f3:	c9                   	leave  
  8016f4:	c3                   	ret    

008016f5 <listen>:

int
listen(int s, int backlog)
{
  8016f5:	55                   	push   %ebp
  8016f6:	89 e5                	mov    %esp,%ebp
  8016f8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fe:	e8 aa fe ff ff       	call   8015ad <fd2sockid>
  801703:	85 c0                	test   %eax,%eax
  801705:	78 0f                	js     801716 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801707:	83 ec 08             	sub    $0x8,%esp
  80170a:	ff 75 0c             	pushl  0xc(%ebp)
  80170d:	50                   	push   %eax
  80170e:	e8 67 01 00 00       	call   80187a <nsipc_listen>
  801713:	83 c4 10             	add    $0x10,%esp
}
  801716:	c9                   	leave  
  801717:	c3                   	ret    

00801718 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80171e:	ff 75 10             	pushl  0x10(%ebp)
  801721:	ff 75 0c             	pushl  0xc(%ebp)
  801724:	ff 75 08             	pushl  0x8(%ebp)
  801727:	e8 3a 02 00 00       	call   801966 <nsipc_socket>
  80172c:	83 c4 10             	add    $0x10,%esp
  80172f:	85 c0                	test   %eax,%eax
  801731:	78 05                	js     801738 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801733:	e8 a5 fe ff ff       	call   8015dd <alloc_sockfd>
}
  801738:	c9                   	leave  
  801739:	c3                   	ret    

0080173a <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80173a:	55                   	push   %ebp
  80173b:	89 e5                	mov    %esp,%ebp
  80173d:	53                   	push   %ebx
  80173e:	83 ec 04             	sub    $0x4,%esp
  801741:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801743:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80174a:	75 12                	jne    80175e <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80174c:	83 ec 0c             	sub    $0xc,%esp
  80174f:	6a 02                	push   $0x2
  801751:	e8 1a 08 00 00       	call   801f70 <ipc_find_env>
  801756:	a3 04 40 80 00       	mov    %eax,0x804004
  80175b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80175e:	6a 07                	push   $0x7
  801760:	68 00 60 80 00       	push   $0x806000
  801765:	53                   	push   %ebx
  801766:	ff 35 04 40 80 00    	pushl  0x804004
  80176c:	e8 ab 07 00 00       	call   801f1c <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801771:	83 c4 0c             	add    $0xc,%esp
  801774:	6a 00                	push   $0x0
  801776:	6a 00                	push   $0x0
  801778:	6a 00                	push   $0x0
  80177a:	e8 36 07 00 00       	call   801eb5 <ipc_recv>
}
  80177f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801782:	c9                   	leave  
  801783:	c3                   	ret    

00801784 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801784:	55                   	push   %ebp
  801785:	89 e5                	mov    %esp,%ebp
  801787:	56                   	push   %esi
  801788:	53                   	push   %ebx
  801789:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80178c:	8b 45 08             	mov    0x8(%ebp),%eax
  80178f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801794:	8b 06                	mov    (%esi),%eax
  801796:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80179b:	b8 01 00 00 00       	mov    $0x1,%eax
  8017a0:	e8 95 ff ff ff       	call   80173a <nsipc>
  8017a5:	89 c3                	mov    %eax,%ebx
  8017a7:	85 c0                	test   %eax,%eax
  8017a9:	78 20                	js     8017cb <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8017ab:	83 ec 04             	sub    $0x4,%esp
  8017ae:	ff 35 10 60 80 00    	pushl  0x806010
  8017b4:	68 00 60 80 00       	push   $0x806000
  8017b9:	ff 75 0c             	pushl  0xc(%ebp)
  8017bc:	e8 a7 f0 ff ff       	call   800868 <memmove>
		*addrlen = ret->ret_addrlen;
  8017c1:	a1 10 60 80 00       	mov    0x806010,%eax
  8017c6:	89 06                	mov    %eax,(%esi)
  8017c8:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8017cb:	89 d8                	mov    %ebx,%eax
  8017cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d0:	5b                   	pop    %ebx
  8017d1:	5e                   	pop    %esi
  8017d2:	5d                   	pop    %ebp
  8017d3:	c3                   	ret    

008017d4 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	53                   	push   %ebx
  8017d8:	83 ec 08             	sub    $0x8,%esp
  8017db:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8017de:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e1:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8017e6:	53                   	push   %ebx
  8017e7:	ff 75 0c             	pushl  0xc(%ebp)
  8017ea:	68 04 60 80 00       	push   $0x806004
  8017ef:	e8 74 f0 ff ff       	call   800868 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8017f4:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8017fa:	b8 02 00 00 00       	mov    $0x2,%eax
  8017ff:	e8 36 ff ff ff       	call   80173a <nsipc>
}
  801804:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801807:	c9                   	leave  
  801808:	c3                   	ret    

00801809 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801809:	55                   	push   %ebp
  80180a:	89 e5                	mov    %esp,%ebp
  80180c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80180f:	8b 45 08             	mov    0x8(%ebp),%eax
  801812:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801817:	8b 45 0c             	mov    0xc(%ebp),%eax
  80181a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  80181f:	b8 03 00 00 00       	mov    $0x3,%eax
  801824:	e8 11 ff ff ff       	call   80173a <nsipc>
}
  801829:	c9                   	leave  
  80182a:	c3                   	ret    

0080182b <nsipc_close>:

int
nsipc_close(int s)
{
  80182b:	55                   	push   %ebp
  80182c:	89 e5                	mov    %esp,%ebp
  80182e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801831:	8b 45 08             	mov    0x8(%ebp),%eax
  801834:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801839:	b8 04 00 00 00       	mov    $0x4,%eax
  80183e:	e8 f7 fe ff ff       	call   80173a <nsipc>
}
  801843:	c9                   	leave  
  801844:	c3                   	ret    

00801845 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801845:	55                   	push   %ebp
  801846:	89 e5                	mov    %esp,%ebp
  801848:	53                   	push   %ebx
  801849:	83 ec 08             	sub    $0x8,%esp
  80184c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80184f:	8b 45 08             	mov    0x8(%ebp),%eax
  801852:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801857:	53                   	push   %ebx
  801858:	ff 75 0c             	pushl  0xc(%ebp)
  80185b:	68 04 60 80 00       	push   $0x806004
  801860:	e8 03 f0 ff ff       	call   800868 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801865:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  80186b:	b8 05 00 00 00       	mov    $0x5,%eax
  801870:	e8 c5 fe ff ff       	call   80173a <nsipc>
}
  801875:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801878:	c9                   	leave  
  801879:	c3                   	ret    

0080187a <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80187a:	55                   	push   %ebp
  80187b:	89 e5                	mov    %esp,%ebp
  80187d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801880:	8b 45 08             	mov    0x8(%ebp),%eax
  801883:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801888:	8b 45 0c             	mov    0xc(%ebp),%eax
  80188b:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801890:	b8 06 00 00 00       	mov    $0x6,%eax
  801895:	e8 a0 fe ff ff       	call   80173a <nsipc>
}
  80189a:	c9                   	leave  
  80189b:	c3                   	ret    

0080189c <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80189c:	55                   	push   %ebp
  80189d:	89 e5                	mov    %esp,%ebp
  80189f:	56                   	push   %esi
  8018a0:	53                   	push   %ebx
  8018a1:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8018a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8018ac:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8018b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8018b5:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8018ba:	b8 07 00 00 00       	mov    $0x7,%eax
  8018bf:	e8 76 fe ff ff       	call   80173a <nsipc>
  8018c4:	89 c3                	mov    %eax,%ebx
  8018c6:	85 c0                	test   %eax,%eax
  8018c8:	78 35                	js     8018ff <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8018ca:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8018cf:	7f 04                	jg     8018d5 <nsipc_recv+0x39>
  8018d1:	39 c6                	cmp    %eax,%esi
  8018d3:	7d 16                	jge    8018eb <nsipc_recv+0x4f>
  8018d5:	68 bb 26 80 00       	push   $0x8026bb
  8018da:	68 83 26 80 00       	push   $0x802683
  8018df:	6a 62                	push   $0x62
  8018e1:	68 d0 26 80 00       	push   $0x8026d0
  8018e6:	e8 84 05 00 00       	call   801e6f <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8018eb:	83 ec 04             	sub    $0x4,%esp
  8018ee:	50                   	push   %eax
  8018ef:	68 00 60 80 00       	push   $0x806000
  8018f4:	ff 75 0c             	pushl  0xc(%ebp)
  8018f7:	e8 6c ef ff ff       	call   800868 <memmove>
  8018fc:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8018ff:	89 d8                	mov    %ebx,%eax
  801901:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801904:	5b                   	pop    %ebx
  801905:	5e                   	pop    %esi
  801906:	5d                   	pop    %ebp
  801907:	c3                   	ret    

00801908 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801908:	55                   	push   %ebp
  801909:	89 e5                	mov    %esp,%ebp
  80190b:	53                   	push   %ebx
  80190c:	83 ec 04             	sub    $0x4,%esp
  80190f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801912:	8b 45 08             	mov    0x8(%ebp),%eax
  801915:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  80191a:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801920:	7e 16                	jle    801938 <nsipc_send+0x30>
  801922:	68 dc 26 80 00       	push   $0x8026dc
  801927:	68 83 26 80 00       	push   $0x802683
  80192c:	6a 6d                	push   $0x6d
  80192e:	68 d0 26 80 00       	push   $0x8026d0
  801933:	e8 37 05 00 00       	call   801e6f <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801938:	83 ec 04             	sub    $0x4,%esp
  80193b:	53                   	push   %ebx
  80193c:	ff 75 0c             	pushl  0xc(%ebp)
  80193f:	68 0c 60 80 00       	push   $0x80600c
  801944:	e8 1f ef ff ff       	call   800868 <memmove>
	nsipcbuf.send.req_size = size;
  801949:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80194f:	8b 45 14             	mov    0x14(%ebp),%eax
  801952:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801957:	b8 08 00 00 00       	mov    $0x8,%eax
  80195c:	e8 d9 fd ff ff       	call   80173a <nsipc>
}
  801961:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801964:	c9                   	leave  
  801965:	c3                   	ret    

00801966 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801966:	55                   	push   %ebp
  801967:	89 e5                	mov    %esp,%ebp
  801969:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80196c:	8b 45 08             	mov    0x8(%ebp),%eax
  80196f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801974:	8b 45 0c             	mov    0xc(%ebp),%eax
  801977:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80197c:	8b 45 10             	mov    0x10(%ebp),%eax
  80197f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801984:	b8 09 00 00 00       	mov    $0x9,%eax
  801989:	e8 ac fd ff ff       	call   80173a <nsipc>
}
  80198e:	c9                   	leave  
  80198f:	c3                   	ret    

00801990 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	56                   	push   %esi
  801994:	53                   	push   %ebx
  801995:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801998:	83 ec 0c             	sub    $0xc,%esp
  80199b:	ff 75 08             	pushl  0x8(%ebp)
  80199e:	e8 98 f3 ff ff       	call   800d3b <fd2data>
  8019a3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019a5:	83 c4 08             	add    $0x8,%esp
  8019a8:	68 e8 26 80 00       	push   $0x8026e8
  8019ad:	53                   	push   %ebx
  8019ae:	e8 23 ed ff ff       	call   8006d6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019b3:	8b 46 04             	mov    0x4(%esi),%eax
  8019b6:	2b 06                	sub    (%esi),%eax
  8019b8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019be:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019c5:	00 00 00 
	stat->st_dev = &devpipe;
  8019c8:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8019cf:	30 80 00 
	return 0;
}
  8019d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019da:	5b                   	pop    %ebx
  8019db:	5e                   	pop    %esi
  8019dc:	5d                   	pop    %ebp
  8019dd:	c3                   	ret    

008019de <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	53                   	push   %ebx
  8019e2:	83 ec 0c             	sub    $0xc,%esp
  8019e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019e8:	53                   	push   %ebx
  8019e9:	6a 00                	push   $0x0
  8019eb:	e8 6e f1 ff ff       	call   800b5e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019f0:	89 1c 24             	mov    %ebx,(%esp)
  8019f3:	e8 43 f3 ff ff       	call   800d3b <fd2data>
  8019f8:	83 c4 08             	add    $0x8,%esp
  8019fb:	50                   	push   %eax
  8019fc:	6a 00                	push   $0x0
  8019fe:	e8 5b f1 ff ff       	call   800b5e <sys_page_unmap>
}
  801a03:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a06:	c9                   	leave  
  801a07:	c3                   	ret    

00801a08 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a08:	55                   	push   %ebp
  801a09:	89 e5                	mov    %esp,%ebp
  801a0b:	57                   	push   %edi
  801a0c:	56                   	push   %esi
  801a0d:	53                   	push   %ebx
  801a0e:	83 ec 1c             	sub    $0x1c,%esp
  801a11:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a14:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a16:	a1 08 40 80 00       	mov    0x804008,%eax
  801a1b:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a1e:	83 ec 0c             	sub    $0xc,%esp
  801a21:	ff 75 e0             	pushl  -0x20(%ebp)
  801a24:	e8 80 05 00 00       	call   801fa9 <pageref>
  801a29:	89 c3                	mov    %eax,%ebx
  801a2b:	89 3c 24             	mov    %edi,(%esp)
  801a2e:	e8 76 05 00 00       	call   801fa9 <pageref>
  801a33:	83 c4 10             	add    $0x10,%esp
  801a36:	39 c3                	cmp    %eax,%ebx
  801a38:	0f 94 c1             	sete   %cl
  801a3b:	0f b6 c9             	movzbl %cl,%ecx
  801a3e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a41:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a47:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a4a:	39 ce                	cmp    %ecx,%esi
  801a4c:	74 1b                	je     801a69 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a4e:	39 c3                	cmp    %eax,%ebx
  801a50:	75 c4                	jne    801a16 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a52:	8b 42 58             	mov    0x58(%edx),%eax
  801a55:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a58:	50                   	push   %eax
  801a59:	56                   	push   %esi
  801a5a:	68 ef 26 80 00       	push   $0x8026ef
  801a5f:	e8 ed e6 ff ff       	call   800151 <cprintf>
  801a64:	83 c4 10             	add    $0x10,%esp
  801a67:	eb ad                	jmp    801a16 <_pipeisclosed+0xe>
	}
}
  801a69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a6f:	5b                   	pop    %ebx
  801a70:	5e                   	pop    %esi
  801a71:	5f                   	pop    %edi
  801a72:	5d                   	pop    %ebp
  801a73:	c3                   	ret    

00801a74 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a74:	55                   	push   %ebp
  801a75:	89 e5                	mov    %esp,%ebp
  801a77:	57                   	push   %edi
  801a78:	56                   	push   %esi
  801a79:	53                   	push   %ebx
  801a7a:	83 ec 28             	sub    $0x28,%esp
  801a7d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a80:	56                   	push   %esi
  801a81:	e8 b5 f2 ff ff       	call   800d3b <fd2data>
  801a86:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a88:	83 c4 10             	add    $0x10,%esp
  801a8b:	bf 00 00 00 00       	mov    $0x0,%edi
  801a90:	eb 4b                	jmp    801add <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a92:	89 da                	mov    %ebx,%edx
  801a94:	89 f0                	mov    %esi,%eax
  801a96:	e8 6d ff ff ff       	call   801a08 <_pipeisclosed>
  801a9b:	85 c0                	test   %eax,%eax
  801a9d:	75 48                	jne    801ae7 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a9f:	e8 16 f0 ff ff       	call   800aba <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801aa4:	8b 43 04             	mov    0x4(%ebx),%eax
  801aa7:	8b 0b                	mov    (%ebx),%ecx
  801aa9:	8d 51 20             	lea    0x20(%ecx),%edx
  801aac:	39 d0                	cmp    %edx,%eax
  801aae:	73 e2                	jae    801a92 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ab0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ab3:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ab7:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801aba:	89 c2                	mov    %eax,%edx
  801abc:	c1 fa 1f             	sar    $0x1f,%edx
  801abf:	89 d1                	mov    %edx,%ecx
  801ac1:	c1 e9 1b             	shr    $0x1b,%ecx
  801ac4:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ac7:	83 e2 1f             	and    $0x1f,%edx
  801aca:	29 ca                	sub    %ecx,%edx
  801acc:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ad0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ad4:	83 c0 01             	add    $0x1,%eax
  801ad7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ada:	83 c7 01             	add    $0x1,%edi
  801add:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ae0:	75 c2                	jne    801aa4 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ae2:	8b 45 10             	mov    0x10(%ebp),%eax
  801ae5:	eb 05                	jmp    801aec <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ae7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801aec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aef:	5b                   	pop    %ebx
  801af0:	5e                   	pop    %esi
  801af1:	5f                   	pop    %edi
  801af2:	5d                   	pop    %ebp
  801af3:	c3                   	ret    

00801af4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801af4:	55                   	push   %ebp
  801af5:	89 e5                	mov    %esp,%ebp
  801af7:	57                   	push   %edi
  801af8:	56                   	push   %esi
  801af9:	53                   	push   %ebx
  801afa:	83 ec 18             	sub    $0x18,%esp
  801afd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b00:	57                   	push   %edi
  801b01:	e8 35 f2 ff ff       	call   800d3b <fd2data>
  801b06:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b08:	83 c4 10             	add    $0x10,%esp
  801b0b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b10:	eb 3d                	jmp    801b4f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b12:	85 db                	test   %ebx,%ebx
  801b14:	74 04                	je     801b1a <devpipe_read+0x26>
				return i;
  801b16:	89 d8                	mov    %ebx,%eax
  801b18:	eb 44                	jmp    801b5e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b1a:	89 f2                	mov    %esi,%edx
  801b1c:	89 f8                	mov    %edi,%eax
  801b1e:	e8 e5 fe ff ff       	call   801a08 <_pipeisclosed>
  801b23:	85 c0                	test   %eax,%eax
  801b25:	75 32                	jne    801b59 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b27:	e8 8e ef ff ff       	call   800aba <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b2c:	8b 06                	mov    (%esi),%eax
  801b2e:	3b 46 04             	cmp    0x4(%esi),%eax
  801b31:	74 df                	je     801b12 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b33:	99                   	cltd   
  801b34:	c1 ea 1b             	shr    $0x1b,%edx
  801b37:	01 d0                	add    %edx,%eax
  801b39:	83 e0 1f             	and    $0x1f,%eax
  801b3c:	29 d0                	sub    %edx,%eax
  801b3e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b46:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b49:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b4c:	83 c3 01             	add    $0x1,%ebx
  801b4f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b52:	75 d8                	jne    801b2c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b54:	8b 45 10             	mov    0x10(%ebp),%eax
  801b57:	eb 05                	jmp    801b5e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b59:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b61:	5b                   	pop    %ebx
  801b62:	5e                   	pop    %esi
  801b63:	5f                   	pop    %edi
  801b64:	5d                   	pop    %ebp
  801b65:	c3                   	ret    

00801b66 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b66:	55                   	push   %ebp
  801b67:	89 e5                	mov    %esp,%ebp
  801b69:	56                   	push   %esi
  801b6a:	53                   	push   %ebx
  801b6b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b6e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b71:	50                   	push   %eax
  801b72:	e8 db f1 ff ff       	call   800d52 <fd_alloc>
  801b77:	83 c4 10             	add    $0x10,%esp
  801b7a:	89 c2                	mov    %eax,%edx
  801b7c:	85 c0                	test   %eax,%eax
  801b7e:	0f 88 2c 01 00 00    	js     801cb0 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b84:	83 ec 04             	sub    $0x4,%esp
  801b87:	68 07 04 00 00       	push   $0x407
  801b8c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b8f:	6a 00                	push   $0x0
  801b91:	e8 43 ef ff ff       	call   800ad9 <sys_page_alloc>
  801b96:	83 c4 10             	add    $0x10,%esp
  801b99:	89 c2                	mov    %eax,%edx
  801b9b:	85 c0                	test   %eax,%eax
  801b9d:	0f 88 0d 01 00 00    	js     801cb0 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ba3:	83 ec 0c             	sub    $0xc,%esp
  801ba6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ba9:	50                   	push   %eax
  801baa:	e8 a3 f1 ff ff       	call   800d52 <fd_alloc>
  801baf:	89 c3                	mov    %eax,%ebx
  801bb1:	83 c4 10             	add    $0x10,%esp
  801bb4:	85 c0                	test   %eax,%eax
  801bb6:	0f 88 e2 00 00 00    	js     801c9e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bbc:	83 ec 04             	sub    $0x4,%esp
  801bbf:	68 07 04 00 00       	push   $0x407
  801bc4:	ff 75 f0             	pushl  -0x10(%ebp)
  801bc7:	6a 00                	push   $0x0
  801bc9:	e8 0b ef ff ff       	call   800ad9 <sys_page_alloc>
  801bce:	89 c3                	mov    %eax,%ebx
  801bd0:	83 c4 10             	add    $0x10,%esp
  801bd3:	85 c0                	test   %eax,%eax
  801bd5:	0f 88 c3 00 00 00    	js     801c9e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bdb:	83 ec 0c             	sub    $0xc,%esp
  801bde:	ff 75 f4             	pushl  -0xc(%ebp)
  801be1:	e8 55 f1 ff ff       	call   800d3b <fd2data>
  801be6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be8:	83 c4 0c             	add    $0xc,%esp
  801beb:	68 07 04 00 00       	push   $0x407
  801bf0:	50                   	push   %eax
  801bf1:	6a 00                	push   $0x0
  801bf3:	e8 e1 ee ff ff       	call   800ad9 <sys_page_alloc>
  801bf8:	89 c3                	mov    %eax,%ebx
  801bfa:	83 c4 10             	add    $0x10,%esp
  801bfd:	85 c0                	test   %eax,%eax
  801bff:	0f 88 89 00 00 00    	js     801c8e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c05:	83 ec 0c             	sub    $0xc,%esp
  801c08:	ff 75 f0             	pushl  -0x10(%ebp)
  801c0b:	e8 2b f1 ff ff       	call   800d3b <fd2data>
  801c10:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c17:	50                   	push   %eax
  801c18:	6a 00                	push   $0x0
  801c1a:	56                   	push   %esi
  801c1b:	6a 00                	push   $0x0
  801c1d:	e8 fa ee ff ff       	call   800b1c <sys_page_map>
  801c22:	89 c3                	mov    %eax,%ebx
  801c24:	83 c4 20             	add    $0x20,%esp
  801c27:	85 c0                	test   %eax,%eax
  801c29:	78 55                	js     801c80 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c2b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c34:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c39:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c40:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c46:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c49:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c4e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c55:	83 ec 0c             	sub    $0xc,%esp
  801c58:	ff 75 f4             	pushl  -0xc(%ebp)
  801c5b:	e8 cb f0 ff ff       	call   800d2b <fd2num>
  801c60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c63:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c65:	83 c4 04             	add    $0x4,%esp
  801c68:	ff 75 f0             	pushl  -0x10(%ebp)
  801c6b:	e8 bb f0 ff ff       	call   800d2b <fd2num>
  801c70:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c73:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c76:	83 c4 10             	add    $0x10,%esp
  801c79:	ba 00 00 00 00       	mov    $0x0,%edx
  801c7e:	eb 30                	jmp    801cb0 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c80:	83 ec 08             	sub    $0x8,%esp
  801c83:	56                   	push   %esi
  801c84:	6a 00                	push   $0x0
  801c86:	e8 d3 ee ff ff       	call   800b5e <sys_page_unmap>
  801c8b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c8e:	83 ec 08             	sub    $0x8,%esp
  801c91:	ff 75 f0             	pushl  -0x10(%ebp)
  801c94:	6a 00                	push   $0x0
  801c96:	e8 c3 ee ff ff       	call   800b5e <sys_page_unmap>
  801c9b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c9e:	83 ec 08             	sub    $0x8,%esp
  801ca1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca4:	6a 00                	push   $0x0
  801ca6:	e8 b3 ee ff ff       	call   800b5e <sys_page_unmap>
  801cab:	83 c4 10             	add    $0x10,%esp
  801cae:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cb0:	89 d0                	mov    %edx,%eax
  801cb2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cb5:	5b                   	pop    %ebx
  801cb6:	5e                   	pop    %esi
  801cb7:	5d                   	pop    %ebp
  801cb8:	c3                   	ret    

00801cb9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cb9:	55                   	push   %ebp
  801cba:	89 e5                	mov    %esp,%ebp
  801cbc:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cbf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cc2:	50                   	push   %eax
  801cc3:	ff 75 08             	pushl  0x8(%ebp)
  801cc6:	e8 d6 f0 ff ff       	call   800da1 <fd_lookup>
  801ccb:	83 c4 10             	add    $0x10,%esp
  801cce:	85 c0                	test   %eax,%eax
  801cd0:	78 18                	js     801cea <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cd2:	83 ec 0c             	sub    $0xc,%esp
  801cd5:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd8:	e8 5e f0 ff ff       	call   800d3b <fd2data>
	return _pipeisclosed(fd, p);
  801cdd:	89 c2                	mov    %eax,%edx
  801cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce2:	e8 21 fd ff ff       	call   801a08 <_pipeisclosed>
  801ce7:	83 c4 10             	add    $0x10,%esp
}
  801cea:	c9                   	leave  
  801ceb:	c3                   	ret    

00801cec <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cec:	55                   	push   %ebp
  801ced:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cef:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf4:	5d                   	pop    %ebp
  801cf5:	c3                   	ret    

00801cf6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cf6:	55                   	push   %ebp
  801cf7:	89 e5                	mov    %esp,%ebp
  801cf9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cfc:	68 07 27 80 00       	push   $0x802707
  801d01:	ff 75 0c             	pushl  0xc(%ebp)
  801d04:	e8 cd e9 ff ff       	call   8006d6 <strcpy>
	return 0;
}
  801d09:	b8 00 00 00 00       	mov    $0x0,%eax
  801d0e:	c9                   	leave  
  801d0f:	c3                   	ret    

00801d10 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d10:	55                   	push   %ebp
  801d11:	89 e5                	mov    %esp,%ebp
  801d13:	57                   	push   %edi
  801d14:	56                   	push   %esi
  801d15:	53                   	push   %ebx
  801d16:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d1c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d21:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d27:	eb 2d                	jmp    801d56 <devcons_write+0x46>
		m = n - tot;
  801d29:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d2c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d2e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d31:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d36:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d39:	83 ec 04             	sub    $0x4,%esp
  801d3c:	53                   	push   %ebx
  801d3d:	03 45 0c             	add    0xc(%ebp),%eax
  801d40:	50                   	push   %eax
  801d41:	57                   	push   %edi
  801d42:	e8 21 eb ff ff       	call   800868 <memmove>
		sys_cputs(buf, m);
  801d47:	83 c4 08             	add    $0x8,%esp
  801d4a:	53                   	push   %ebx
  801d4b:	57                   	push   %edi
  801d4c:	e8 cc ec ff ff       	call   800a1d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d51:	01 de                	add    %ebx,%esi
  801d53:	83 c4 10             	add    $0x10,%esp
  801d56:	89 f0                	mov    %esi,%eax
  801d58:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d5b:	72 cc                	jb     801d29 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d60:	5b                   	pop    %ebx
  801d61:	5e                   	pop    %esi
  801d62:	5f                   	pop    %edi
  801d63:	5d                   	pop    %ebp
  801d64:	c3                   	ret    

00801d65 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d65:	55                   	push   %ebp
  801d66:	89 e5                	mov    %esp,%ebp
  801d68:	83 ec 08             	sub    $0x8,%esp
  801d6b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d70:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d74:	74 2a                	je     801da0 <devcons_read+0x3b>
  801d76:	eb 05                	jmp    801d7d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d78:	e8 3d ed ff ff       	call   800aba <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d7d:	e8 b9 ec ff ff       	call   800a3b <sys_cgetc>
  801d82:	85 c0                	test   %eax,%eax
  801d84:	74 f2                	je     801d78 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d86:	85 c0                	test   %eax,%eax
  801d88:	78 16                	js     801da0 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d8a:	83 f8 04             	cmp    $0x4,%eax
  801d8d:	74 0c                	je     801d9b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d92:	88 02                	mov    %al,(%edx)
	return 1;
  801d94:	b8 01 00 00 00       	mov    $0x1,%eax
  801d99:	eb 05                	jmp    801da0 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d9b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801da0:	c9                   	leave  
  801da1:	c3                   	ret    

00801da2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801da2:	55                   	push   %ebp
  801da3:	89 e5                	mov    %esp,%ebp
  801da5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801da8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dab:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801dae:	6a 01                	push   $0x1
  801db0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801db3:	50                   	push   %eax
  801db4:	e8 64 ec ff ff       	call   800a1d <sys_cputs>
}
  801db9:	83 c4 10             	add    $0x10,%esp
  801dbc:	c9                   	leave  
  801dbd:	c3                   	ret    

00801dbe <getchar>:

int
getchar(void)
{
  801dbe:	55                   	push   %ebp
  801dbf:	89 e5                	mov    %esp,%ebp
  801dc1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dc4:	6a 01                	push   $0x1
  801dc6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dc9:	50                   	push   %eax
  801dca:	6a 00                	push   $0x0
  801dcc:	e8 36 f2 ff ff       	call   801007 <read>
	if (r < 0)
  801dd1:	83 c4 10             	add    $0x10,%esp
  801dd4:	85 c0                	test   %eax,%eax
  801dd6:	78 0f                	js     801de7 <getchar+0x29>
		return r;
	if (r < 1)
  801dd8:	85 c0                	test   %eax,%eax
  801dda:	7e 06                	jle    801de2 <getchar+0x24>
		return -E_EOF;
	return c;
  801ddc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801de0:	eb 05                	jmp    801de7 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801de2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801de7:	c9                   	leave  
  801de8:	c3                   	ret    

00801de9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801de9:	55                   	push   %ebp
  801dea:	89 e5                	mov    %esp,%ebp
  801dec:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801def:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df2:	50                   	push   %eax
  801df3:	ff 75 08             	pushl  0x8(%ebp)
  801df6:	e8 a6 ef ff ff       	call   800da1 <fd_lookup>
  801dfb:	83 c4 10             	add    $0x10,%esp
  801dfe:	85 c0                	test   %eax,%eax
  801e00:	78 11                	js     801e13 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e05:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e0b:	39 10                	cmp    %edx,(%eax)
  801e0d:	0f 94 c0             	sete   %al
  801e10:	0f b6 c0             	movzbl %al,%eax
}
  801e13:	c9                   	leave  
  801e14:	c3                   	ret    

00801e15 <opencons>:

int
opencons(void)
{
  801e15:	55                   	push   %ebp
  801e16:	89 e5                	mov    %esp,%ebp
  801e18:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e1e:	50                   	push   %eax
  801e1f:	e8 2e ef ff ff       	call   800d52 <fd_alloc>
  801e24:	83 c4 10             	add    $0x10,%esp
		return r;
  801e27:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e29:	85 c0                	test   %eax,%eax
  801e2b:	78 3e                	js     801e6b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e2d:	83 ec 04             	sub    $0x4,%esp
  801e30:	68 07 04 00 00       	push   $0x407
  801e35:	ff 75 f4             	pushl  -0xc(%ebp)
  801e38:	6a 00                	push   $0x0
  801e3a:	e8 9a ec ff ff       	call   800ad9 <sys_page_alloc>
  801e3f:	83 c4 10             	add    $0x10,%esp
		return r;
  801e42:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e44:	85 c0                	test   %eax,%eax
  801e46:	78 23                	js     801e6b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e48:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e51:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e56:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e5d:	83 ec 0c             	sub    $0xc,%esp
  801e60:	50                   	push   %eax
  801e61:	e8 c5 ee ff ff       	call   800d2b <fd2num>
  801e66:	89 c2                	mov    %eax,%edx
  801e68:	83 c4 10             	add    $0x10,%esp
}
  801e6b:	89 d0                	mov    %edx,%eax
  801e6d:	c9                   	leave  
  801e6e:	c3                   	ret    

00801e6f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e6f:	55                   	push   %ebp
  801e70:	89 e5                	mov    %esp,%ebp
  801e72:	56                   	push   %esi
  801e73:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e74:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e77:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e7d:	e8 19 ec ff ff       	call   800a9b <sys_getenvid>
  801e82:	83 ec 0c             	sub    $0xc,%esp
  801e85:	ff 75 0c             	pushl  0xc(%ebp)
  801e88:	ff 75 08             	pushl  0x8(%ebp)
  801e8b:	56                   	push   %esi
  801e8c:	50                   	push   %eax
  801e8d:	68 14 27 80 00       	push   $0x802714
  801e92:	e8 ba e2 ff ff       	call   800151 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e97:	83 c4 18             	add    $0x18,%esp
  801e9a:	53                   	push   %ebx
  801e9b:	ff 75 10             	pushl  0x10(%ebp)
  801e9e:	e8 5d e2 ff ff       	call   800100 <vcprintf>
	cprintf("\n");
  801ea3:	c7 04 24 00 27 80 00 	movl   $0x802700,(%esp)
  801eaa:	e8 a2 e2 ff ff       	call   800151 <cprintf>
  801eaf:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801eb2:	cc                   	int3   
  801eb3:	eb fd                	jmp    801eb2 <_panic+0x43>

00801eb5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801eb5:	55                   	push   %ebp
  801eb6:	89 e5                	mov    %esp,%ebp
  801eb8:	56                   	push   %esi
  801eb9:	53                   	push   %ebx
  801eba:	8b 75 08             	mov    0x8(%ebp),%esi
  801ebd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801ec3:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801ec5:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801eca:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801ecd:	83 ec 0c             	sub    $0xc,%esp
  801ed0:	50                   	push   %eax
  801ed1:	e8 b3 ed ff ff       	call   800c89 <sys_ipc_recv>

	if (from_env_store != NULL)
  801ed6:	83 c4 10             	add    $0x10,%esp
  801ed9:	85 f6                	test   %esi,%esi
  801edb:	74 14                	je     801ef1 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801edd:	ba 00 00 00 00       	mov    $0x0,%edx
  801ee2:	85 c0                	test   %eax,%eax
  801ee4:	78 09                	js     801eef <ipc_recv+0x3a>
  801ee6:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801eec:	8b 52 74             	mov    0x74(%edx),%edx
  801eef:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801ef1:	85 db                	test   %ebx,%ebx
  801ef3:	74 14                	je     801f09 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801ef5:	ba 00 00 00 00       	mov    $0x0,%edx
  801efa:	85 c0                	test   %eax,%eax
  801efc:	78 09                	js     801f07 <ipc_recv+0x52>
  801efe:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f04:	8b 52 78             	mov    0x78(%edx),%edx
  801f07:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801f09:	85 c0                	test   %eax,%eax
  801f0b:	78 08                	js     801f15 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801f0d:	a1 08 40 80 00       	mov    0x804008,%eax
  801f12:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f15:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f18:	5b                   	pop    %ebx
  801f19:	5e                   	pop    %esi
  801f1a:	5d                   	pop    %ebp
  801f1b:	c3                   	ret    

00801f1c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f1c:	55                   	push   %ebp
  801f1d:	89 e5                	mov    %esp,%ebp
  801f1f:	57                   	push   %edi
  801f20:	56                   	push   %esi
  801f21:	53                   	push   %ebx
  801f22:	83 ec 0c             	sub    $0xc,%esp
  801f25:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f28:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801f2e:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801f30:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f35:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801f38:	ff 75 14             	pushl  0x14(%ebp)
  801f3b:	53                   	push   %ebx
  801f3c:	56                   	push   %esi
  801f3d:	57                   	push   %edi
  801f3e:	e8 23 ed ff ff       	call   800c66 <sys_ipc_try_send>

		if (err < 0) {
  801f43:	83 c4 10             	add    $0x10,%esp
  801f46:	85 c0                	test   %eax,%eax
  801f48:	79 1e                	jns    801f68 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801f4a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f4d:	75 07                	jne    801f56 <ipc_send+0x3a>
				sys_yield();
  801f4f:	e8 66 eb ff ff       	call   800aba <sys_yield>
  801f54:	eb e2                	jmp    801f38 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801f56:	50                   	push   %eax
  801f57:	68 38 27 80 00       	push   $0x802738
  801f5c:	6a 49                	push   $0x49
  801f5e:	68 45 27 80 00       	push   $0x802745
  801f63:	e8 07 ff ff ff       	call   801e6f <_panic>
		}

	} while (err < 0);

}
  801f68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f6b:	5b                   	pop    %ebx
  801f6c:	5e                   	pop    %esi
  801f6d:	5f                   	pop    %edi
  801f6e:	5d                   	pop    %ebp
  801f6f:	c3                   	ret    

00801f70 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f70:	55                   	push   %ebp
  801f71:	89 e5                	mov    %esp,%ebp
  801f73:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f76:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f7b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f7e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f84:	8b 52 50             	mov    0x50(%edx),%edx
  801f87:	39 ca                	cmp    %ecx,%edx
  801f89:	75 0d                	jne    801f98 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f8b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f8e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f93:	8b 40 48             	mov    0x48(%eax),%eax
  801f96:	eb 0f                	jmp    801fa7 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f98:	83 c0 01             	add    $0x1,%eax
  801f9b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fa0:	75 d9                	jne    801f7b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fa2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fa7:	5d                   	pop    %ebp
  801fa8:	c3                   	ret    

00801fa9 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fa9:	55                   	push   %ebp
  801faa:	89 e5                	mov    %esp,%ebp
  801fac:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801faf:	89 d0                	mov    %edx,%eax
  801fb1:	c1 e8 16             	shr    $0x16,%eax
  801fb4:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fbb:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fc0:	f6 c1 01             	test   $0x1,%cl
  801fc3:	74 1d                	je     801fe2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fc5:	c1 ea 0c             	shr    $0xc,%edx
  801fc8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fcf:	f6 c2 01             	test   $0x1,%dl
  801fd2:	74 0e                	je     801fe2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fd4:	c1 ea 0c             	shr    $0xc,%edx
  801fd7:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fde:	ef 
  801fdf:	0f b7 c0             	movzwl %ax,%eax
}
  801fe2:	5d                   	pop    %ebp
  801fe3:	c3                   	ret    
  801fe4:	66 90                	xchg   %ax,%ax
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
