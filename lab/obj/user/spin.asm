
obj/user/spin.debug:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 20 26 80 00       	push   $0x802620
  80003f:	e8 64 01 00 00       	call   8001a8 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 54 0e 00 00       	call   800e9d <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 98 26 80 00       	push   $0x802698
  800058:	e8 4b 01 00 00       	call   8001a8 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 48 26 80 00       	push   $0x802648
  80006c:	e8 37 01 00 00       	call   8001a8 <cprintf>
	sys_yield();
  800071:	e8 9b 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  800076:	e8 96 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  80007b:	e8 91 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  800080:	e8 8c 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  800085:	e8 87 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  80008a:	e8 82 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  80008f:	e8 7d 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  800094:	e8 78 0a 00 00       	call   800b11 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 70 26 80 00 	movl   $0x802670,(%esp)
  8000a0:	e8 03 01 00 00       	call   8001a8 <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 04 0a 00 00       	call   800ab1 <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c0:	e8 2d 0a 00 00       	call   800af2 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 47 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800101:	e8 19 11 00 00       	call   80121f <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 a1 09 00 00       	call   800ab1 <sys_env_destroy>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	53                   	push   %ebx
  800119:	83 ec 04             	sub    $0x4,%esp
  80011c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011f:	8b 13                	mov    (%ebx),%edx
  800121:	8d 42 01             	lea    0x1(%edx),%eax
  800124:	89 03                	mov    %eax,(%ebx)
  800126:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800129:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80012d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800132:	75 1a                	jne    80014e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800134:	83 ec 08             	sub    $0x8,%esp
  800137:	68 ff 00 00 00       	push   $0xff
  80013c:	8d 43 08             	lea    0x8(%ebx),%eax
  80013f:	50                   	push   %eax
  800140:	e8 2f 09 00 00       	call   800a74 <sys_cputs>
		b->idx = 0;
  800145:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80014b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80014e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800152:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800155:	c9                   	leave  
  800156:	c3                   	ret    

00800157 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800160:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800167:	00 00 00 
	b.cnt = 0;
  80016a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800171:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800174:	ff 75 0c             	pushl  0xc(%ebp)
  800177:	ff 75 08             	pushl  0x8(%ebp)
  80017a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800180:	50                   	push   %eax
  800181:	68 15 01 80 00       	push   $0x800115
  800186:	e8 54 01 00 00       	call   8002df <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018b:	83 c4 08             	add    $0x8,%esp
  80018e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800194:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019a:	50                   	push   %eax
  80019b:	e8 d4 08 00 00       	call   800a74 <sys_cputs>

	return b.cnt;
}
  8001a0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b1:	50                   	push   %eax
  8001b2:	ff 75 08             	pushl  0x8(%ebp)
  8001b5:	e8 9d ff ff ff       	call   800157 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    

008001bc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	57                   	push   %edi
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 1c             	sub    $0x1c,%esp
  8001c5:	89 c7                	mov    %eax,%edi
  8001c7:	89 d6                	mov    %edx,%esi
  8001c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001dd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001e3:	39 d3                	cmp    %edx,%ebx
  8001e5:	72 05                	jb     8001ec <printnum+0x30>
  8001e7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ea:	77 45                	ja     800231 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ec:	83 ec 0c             	sub    $0xc,%esp
  8001ef:	ff 75 18             	pushl  0x18(%ebp)
  8001f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f8:	53                   	push   %ebx
  8001f9:	ff 75 10             	pushl  0x10(%ebp)
  8001fc:	83 ec 08             	sub    $0x8,%esp
  8001ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800202:	ff 75 e0             	pushl  -0x20(%ebp)
  800205:	ff 75 dc             	pushl  -0x24(%ebp)
  800208:	ff 75 d8             	pushl  -0x28(%ebp)
  80020b:	e8 70 21 00 00       	call   802380 <__udivdi3>
  800210:	83 c4 18             	add    $0x18,%esp
  800213:	52                   	push   %edx
  800214:	50                   	push   %eax
  800215:	89 f2                	mov    %esi,%edx
  800217:	89 f8                	mov    %edi,%eax
  800219:	e8 9e ff ff ff       	call   8001bc <printnum>
  80021e:	83 c4 20             	add    $0x20,%esp
  800221:	eb 18                	jmp    80023b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800223:	83 ec 08             	sub    $0x8,%esp
  800226:	56                   	push   %esi
  800227:	ff 75 18             	pushl  0x18(%ebp)
  80022a:	ff d7                	call   *%edi
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	eb 03                	jmp    800234 <printnum+0x78>
  800231:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800234:	83 eb 01             	sub    $0x1,%ebx
  800237:	85 db                	test   %ebx,%ebx
  800239:	7f e8                	jg     800223 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023b:	83 ec 08             	sub    $0x8,%esp
  80023e:	56                   	push   %esi
  80023f:	83 ec 04             	sub    $0x4,%esp
  800242:	ff 75 e4             	pushl  -0x1c(%ebp)
  800245:	ff 75 e0             	pushl  -0x20(%ebp)
  800248:	ff 75 dc             	pushl  -0x24(%ebp)
  80024b:	ff 75 d8             	pushl  -0x28(%ebp)
  80024e:	e8 5d 22 00 00       	call   8024b0 <__umoddi3>
  800253:	83 c4 14             	add    $0x14,%esp
  800256:	0f be 80 c0 26 80 00 	movsbl 0x8026c0(%eax),%eax
  80025d:	50                   	push   %eax
  80025e:	ff d7                	call   *%edi
}
  800260:	83 c4 10             	add    $0x10,%esp
  800263:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800266:	5b                   	pop    %ebx
  800267:	5e                   	pop    %esi
  800268:	5f                   	pop    %edi
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80026e:	83 fa 01             	cmp    $0x1,%edx
  800271:	7e 0e                	jle    800281 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800273:	8b 10                	mov    (%eax),%edx
  800275:	8d 4a 08             	lea    0x8(%edx),%ecx
  800278:	89 08                	mov    %ecx,(%eax)
  80027a:	8b 02                	mov    (%edx),%eax
  80027c:	8b 52 04             	mov    0x4(%edx),%edx
  80027f:	eb 22                	jmp    8002a3 <getuint+0x38>
	else if (lflag)
  800281:	85 d2                	test   %edx,%edx
  800283:	74 10                	je     800295 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800285:	8b 10                	mov    (%eax),%edx
  800287:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028a:	89 08                	mov    %ecx,(%eax)
  80028c:	8b 02                	mov    (%edx),%eax
  80028e:	ba 00 00 00 00       	mov    $0x0,%edx
  800293:	eb 0e                	jmp    8002a3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800295:	8b 10                	mov    (%eax),%edx
  800297:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029a:	89 08                	mov    %ecx,(%eax)
  80029c:	8b 02                	mov    (%edx),%eax
  80029e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ab:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002af:	8b 10                	mov    (%eax),%edx
  8002b1:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b4:	73 0a                	jae    8002c0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002b6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002b9:	89 08                	mov    %ecx,(%eax)
  8002bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002be:	88 02                	mov    %al,(%edx)
}
  8002c0:	5d                   	pop    %ebp
  8002c1:	c3                   	ret    

008002c2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002c2:	55                   	push   %ebp
  8002c3:	89 e5                	mov    %esp,%ebp
  8002c5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002cb:	50                   	push   %eax
  8002cc:	ff 75 10             	pushl  0x10(%ebp)
  8002cf:	ff 75 0c             	pushl  0xc(%ebp)
  8002d2:	ff 75 08             	pushl  0x8(%ebp)
  8002d5:	e8 05 00 00 00       	call   8002df <vprintfmt>
	va_end(ap);
}
  8002da:	83 c4 10             	add    $0x10,%esp
  8002dd:	c9                   	leave  
  8002de:	c3                   	ret    

008002df <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	57                   	push   %edi
  8002e3:	56                   	push   %esi
  8002e4:	53                   	push   %ebx
  8002e5:	83 ec 2c             	sub    $0x2c,%esp
  8002e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8002eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ee:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002f1:	eb 12                	jmp    800305 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f3:	85 c0                	test   %eax,%eax
  8002f5:	0f 84 89 03 00 00    	je     800684 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002fb:	83 ec 08             	sub    $0x8,%esp
  8002fe:	53                   	push   %ebx
  8002ff:	50                   	push   %eax
  800300:	ff d6                	call   *%esi
  800302:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800305:	83 c7 01             	add    $0x1,%edi
  800308:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80030c:	83 f8 25             	cmp    $0x25,%eax
  80030f:	75 e2                	jne    8002f3 <vprintfmt+0x14>
  800311:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800315:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80031c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800323:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80032a:	ba 00 00 00 00       	mov    $0x0,%edx
  80032f:	eb 07                	jmp    800338 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800331:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800334:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800338:	8d 47 01             	lea    0x1(%edi),%eax
  80033b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80033e:	0f b6 07             	movzbl (%edi),%eax
  800341:	0f b6 c8             	movzbl %al,%ecx
  800344:	83 e8 23             	sub    $0x23,%eax
  800347:	3c 55                	cmp    $0x55,%al
  800349:	0f 87 1a 03 00 00    	ja     800669 <vprintfmt+0x38a>
  80034f:	0f b6 c0             	movzbl %al,%eax
  800352:	ff 24 85 00 28 80 00 	jmp    *0x802800(,%eax,4)
  800359:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80035c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800360:	eb d6                	jmp    800338 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800362:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800365:	b8 00 00 00 00       	mov    $0x0,%eax
  80036a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80036d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800370:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800374:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800377:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80037a:	83 fa 09             	cmp    $0x9,%edx
  80037d:	77 39                	ja     8003b8 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80037f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800382:	eb e9                	jmp    80036d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800384:	8b 45 14             	mov    0x14(%ebp),%eax
  800387:	8d 48 04             	lea    0x4(%eax),%ecx
  80038a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80038d:	8b 00                	mov    (%eax),%eax
  80038f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800395:	eb 27                	jmp    8003be <vprintfmt+0xdf>
  800397:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80039a:	85 c0                	test   %eax,%eax
  80039c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a1:	0f 49 c8             	cmovns %eax,%ecx
  8003a4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003aa:	eb 8c                	jmp    800338 <vprintfmt+0x59>
  8003ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003af:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003b6:	eb 80                	jmp    800338 <vprintfmt+0x59>
  8003b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003bb:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003be:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c2:	0f 89 70 ff ff ff    	jns    800338 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003c8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ce:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003d5:	e9 5e ff ff ff       	jmp    800338 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003da:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003e0:	e9 53 ff ff ff       	jmp    800338 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e8:	8d 50 04             	lea    0x4(%eax),%edx
  8003eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ee:	83 ec 08             	sub    $0x8,%esp
  8003f1:	53                   	push   %ebx
  8003f2:	ff 30                	pushl  (%eax)
  8003f4:	ff d6                	call   *%esi
			break;
  8003f6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003fc:	e9 04 ff ff ff       	jmp    800305 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800401:	8b 45 14             	mov    0x14(%ebp),%eax
  800404:	8d 50 04             	lea    0x4(%eax),%edx
  800407:	89 55 14             	mov    %edx,0x14(%ebp)
  80040a:	8b 00                	mov    (%eax),%eax
  80040c:	99                   	cltd   
  80040d:	31 d0                	xor    %edx,%eax
  80040f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800411:	83 f8 0f             	cmp    $0xf,%eax
  800414:	7f 0b                	jg     800421 <vprintfmt+0x142>
  800416:	8b 14 85 60 29 80 00 	mov    0x802960(,%eax,4),%edx
  80041d:	85 d2                	test   %edx,%edx
  80041f:	75 18                	jne    800439 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800421:	50                   	push   %eax
  800422:	68 d8 26 80 00       	push   $0x8026d8
  800427:	53                   	push   %ebx
  800428:	56                   	push   %esi
  800429:	e8 94 fe ff ff       	call   8002c2 <printfmt>
  80042e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800431:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800434:	e9 cc fe ff ff       	jmp    800305 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800439:	52                   	push   %edx
  80043a:	68 4d 2b 80 00       	push   $0x802b4d
  80043f:	53                   	push   %ebx
  800440:	56                   	push   %esi
  800441:	e8 7c fe ff ff       	call   8002c2 <printfmt>
  800446:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80044c:	e9 b4 fe ff ff       	jmp    800305 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800451:	8b 45 14             	mov    0x14(%ebp),%eax
  800454:	8d 50 04             	lea    0x4(%eax),%edx
  800457:	89 55 14             	mov    %edx,0x14(%ebp)
  80045a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80045c:	85 ff                	test   %edi,%edi
  80045e:	b8 d1 26 80 00       	mov    $0x8026d1,%eax
  800463:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800466:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80046a:	0f 8e 94 00 00 00    	jle    800504 <vprintfmt+0x225>
  800470:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800474:	0f 84 98 00 00 00    	je     800512 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80047a:	83 ec 08             	sub    $0x8,%esp
  80047d:	ff 75 d0             	pushl  -0x30(%ebp)
  800480:	57                   	push   %edi
  800481:	e8 86 02 00 00       	call   80070c <strnlen>
  800486:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800489:	29 c1                	sub    %eax,%ecx
  80048b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80048e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800491:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800495:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800498:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80049b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80049d:	eb 0f                	jmp    8004ae <vprintfmt+0x1cf>
					putch(padc, putdat);
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	53                   	push   %ebx
  8004a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a8:	83 ef 01             	sub    $0x1,%edi
  8004ab:	83 c4 10             	add    $0x10,%esp
  8004ae:	85 ff                	test   %edi,%edi
  8004b0:	7f ed                	jg     80049f <vprintfmt+0x1c0>
  8004b2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004b5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004b8:	85 c9                	test   %ecx,%ecx
  8004ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bf:	0f 49 c1             	cmovns %ecx,%eax
  8004c2:	29 c1                	sub    %eax,%ecx
  8004c4:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ca:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004cd:	89 cb                	mov    %ecx,%ebx
  8004cf:	eb 4d                	jmp    80051e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004d1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004d5:	74 1b                	je     8004f2 <vprintfmt+0x213>
  8004d7:	0f be c0             	movsbl %al,%eax
  8004da:	83 e8 20             	sub    $0x20,%eax
  8004dd:	83 f8 5e             	cmp    $0x5e,%eax
  8004e0:	76 10                	jbe    8004f2 <vprintfmt+0x213>
					putch('?', putdat);
  8004e2:	83 ec 08             	sub    $0x8,%esp
  8004e5:	ff 75 0c             	pushl  0xc(%ebp)
  8004e8:	6a 3f                	push   $0x3f
  8004ea:	ff 55 08             	call   *0x8(%ebp)
  8004ed:	83 c4 10             	add    $0x10,%esp
  8004f0:	eb 0d                	jmp    8004ff <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004f2:	83 ec 08             	sub    $0x8,%esp
  8004f5:	ff 75 0c             	pushl  0xc(%ebp)
  8004f8:	52                   	push   %edx
  8004f9:	ff 55 08             	call   *0x8(%ebp)
  8004fc:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ff:	83 eb 01             	sub    $0x1,%ebx
  800502:	eb 1a                	jmp    80051e <vprintfmt+0x23f>
  800504:	89 75 08             	mov    %esi,0x8(%ebp)
  800507:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80050a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800510:	eb 0c                	jmp    80051e <vprintfmt+0x23f>
  800512:	89 75 08             	mov    %esi,0x8(%ebp)
  800515:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800518:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051e:	83 c7 01             	add    $0x1,%edi
  800521:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800525:	0f be d0             	movsbl %al,%edx
  800528:	85 d2                	test   %edx,%edx
  80052a:	74 23                	je     80054f <vprintfmt+0x270>
  80052c:	85 f6                	test   %esi,%esi
  80052e:	78 a1                	js     8004d1 <vprintfmt+0x1f2>
  800530:	83 ee 01             	sub    $0x1,%esi
  800533:	79 9c                	jns    8004d1 <vprintfmt+0x1f2>
  800535:	89 df                	mov    %ebx,%edi
  800537:	8b 75 08             	mov    0x8(%ebp),%esi
  80053a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053d:	eb 18                	jmp    800557 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	53                   	push   %ebx
  800543:	6a 20                	push   $0x20
  800545:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800547:	83 ef 01             	sub    $0x1,%edi
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	eb 08                	jmp    800557 <vprintfmt+0x278>
  80054f:	89 df                	mov    %ebx,%edi
  800551:	8b 75 08             	mov    0x8(%ebp),%esi
  800554:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800557:	85 ff                	test   %edi,%edi
  800559:	7f e4                	jg     80053f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80055e:	e9 a2 fd ff ff       	jmp    800305 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800563:	83 fa 01             	cmp    $0x1,%edx
  800566:	7e 16                	jle    80057e <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8d 50 08             	lea    0x8(%eax),%edx
  80056e:	89 55 14             	mov    %edx,0x14(%ebp)
  800571:	8b 50 04             	mov    0x4(%eax),%edx
  800574:	8b 00                	mov    (%eax),%eax
  800576:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800579:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057c:	eb 32                	jmp    8005b0 <vprintfmt+0x2d1>
	else if (lflag)
  80057e:	85 d2                	test   %edx,%edx
  800580:	74 18                	je     80059a <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	8d 50 04             	lea    0x4(%eax),%edx
  800588:	89 55 14             	mov    %edx,0x14(%ebp)
  80058b:	8b 00                	mov    (%eax),%eax
  80058d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800590:	89 c1                	mov    %eax,%ecx
  800592:	c1 f9 1f             	sar    $0x1f,%ecx
  800595:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800598:	eb 16                	jmp    8005b0 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8d 50 04             	lea    0x4(%eax),%edx
  8005a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a3:	8b 00                	mov    (%eax),%eax
  8005a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a8:	89 c1                	mov    %eax,%ecx
  8005aa:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ad:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005b0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b3:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005b6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005bb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005bf:	79 74                	jns    800635 <vprintfmt+0x356>
				putch('-', putdat);
  8005c1:	83 ec 08             	sub    $0x8,%esp
  8005c4:	53                   	push   %ebx
  8005c5:	6a 2d                	push   $0x2d
  8005c7:	ff d6                	call   *%esi
				num = -(long long) num;
  8005c9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005cc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005cf:	f7 d8                	neg    %eax
  8005d1:	83 d2 00             	adc    $0x0,%edx
  8005d4:	f7 da                	neg    %edx
  8005d6:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005d9:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005de:	eb 55                	jmp    800635 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005e0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e3:	e8 83 fc ff ff       	call   80026b <getuint>
			base = 10;
  8005e8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005ed:	eb 46                	jmp    800635 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8005ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f2:	e8 74 fc ff ff       	call   80026b <getuint>
			base = 8;
  8005f7:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005fc:	eb 37                	jmp    800635 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	53                   	push   %ebx
  800602:	6a 30                	push   $0x30
  800604:	ff d6                	call   *%esi
			putch('x', putdat);
  800606:	83 c4 08             	add    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	6a 78                	push   $0x78
  80060c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8d 50 04             	lea    0x4(%eax),%edx
  800614:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800617:	8b 00                	mov    (%eax),%eax
  800619:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80061e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800621:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800626:	eb 0d                	jmp    800635 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800628:	8d 45 14             	lea    0x14(%ebp),%eax
  80062b:	e8 3b fc ff ff       	call   80026b <getuint>
			base = 16;
  800630:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800635:	83 ec 0c             	sub    $0xc,%esp
  800638:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80063c:	57                   	push   %edi
  80063d:	ff 75 e0             	pushl  -0x20(%ebp)
  800640:	51                   	push   %ecx
  800641:	52                   	push   %edx
  800642:	50                   	push   %eax
  800643:	89 da                	mov    %ebx,%edx
  800645:	89 f0                	mov    %esi,%eax
  800647:	e8 70 fb ff ff       	call   8001bc <printnum>
			break;
  80064c:	83 c4 20             	add    $0x20,%esp
  80064f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800652:	e9 ae fc ff ff       	jmp    800305 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800657:	83 ec 08             	sub    $0x8,%esp
  80065a:	53                   	push   %ebx
  80065b:	51                   	push   %ecx
  80065c:	ff d6                	call   *%esi
			break;
  80065e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800661:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800664:	e9 9c fc ff ff       	jmp    800305 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800669:	83 ec 08             	sub    $0x8,%esp
  80066c:	53                   	push   %ebx
  80066d:	6a 25                	push   $0x25
  80066f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800671:	83 c4 10             	add    $0x10,%esp
  800674:	eb 03                	jmp    800679 <vprintfmt+0x39a>
  800676:	83 ef 01             	sub    $0x1,%edi
  800679:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80067d:	75 f7                	jne    800676 <vprintfmt+0x397>
  80067f:	e9 81 fc ff ff       	jmp    800305 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800684:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800687:	5b                   	pop    %ebx
  800688:	5e                   	pop    %esi
  800689:	5f                   	pop    %edi
  80068a:	5d                   	pop    %ebp
  80068b:	c3                   	ret    

0080068c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80068c:	55                   	push   %ebp
  80068d:	89 e5                	mov    %esp,%ebp
  80068f:	83 ec 18             	sub    $0x18,%esp
  800692:	8b 45 08             	mov    0x8(%ebp),%eax
  800695:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800698:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80069b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80069f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006a9:	85 c0                	test   %eax,%eax
  8006ab:	74 26                	je     8006d3 <vsnprintf+0x47>
  8006ad:	85 d2                	test   %edx,%edx
  8006af:	7e 22                	jle    8006d3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006b1:	ff 75 14             	pushl  0x14(%ebp)
  8006b4:	ff 75 10             	pushl  0x10(%ebp)
  8006b7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ba:	50                   	push   %eax
  8006bb:	68 a5 02 80 00       	push   $0x8002a5
  8006c0:	e8 1a fc ff ff       	call   8002df <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006c8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ce:	83 c4 10             	add    $0x10,%esp
  8006d1:	eb 05                	jmp    8006d8 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006d8:	c9                   	leave  
  8006d9:	c3                   	ret    

008006da <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006da:	55                   	push   %ebp
  8006db:	89 e5                	mov    %esp,%ebp
  8006dd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006e3:	50                   	push   %eax
  8006e4:	ff 75 10             	pushl  0x10(%ebp)
  8006e7:	ff 75 0c             	pushl  0xc(%ebp)
  8006ea:	ff 75 08             	pushl  0x8(%ebp)
  8006ed:	e8 9a ff ff ff       	call   80068c <vsnprintf>
	va_end(ap);

	return rc;
}
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ff:	eb 03                	jmp    800704 <strlen+0x10>
		n++;
  800701:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800704:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800708:	75 f7                	jne    800701 <strlen+0xd>
		n++;
	return n;
}
  80070a:	5d                   	pop    %ebp
  80070b:	c3                   	ret    

0080070c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800712:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800715:	ba 00 00 00 00       	mov    $0x0,%edx
  80071a:	eb 03                	jmp    80071f <strnlen+0x13>
		n++;
  80071c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80071f:	39 c2                	cmp    %eax,%edx
  800721:	74 08                	je     80072b <strnlen+0x1f>
  800723:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800727:	75 f3                	jne    80071c <strnlen+0x10>
  800729:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80072b:	5d                   	pop    %ebp
  80072c:	c3                   	ret    

0080072d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80072d:	55                   	push   %ebp
  80072e:	89 e5                	mov    %esp,%ebp
  800730:	53                   	push   %ebx
  800731:	8b 45 08             	mov    0x8(%ebp),%eax
  800734:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800737:	89 c2                	mov    %eax,%edx
  800739:	83 c2 01             	add    $0x1,%edx
  80073c:	83 c1 01             	add    $0x1,%ecx
  80073f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800743:	88 5a ff             	mov    %bl,-0x1(%edx)
  800746:	84 db                	test   %bl,%bl
  800748:	75 ef                	jne    800739 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80074a:	5b                   	pop    %ebx
  80074b:	5d                   	pop    %ebp
  80074c:	c3                   	ret    

0080074d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80074d:	55                   	push   %ebp
  80074e:	89 e5                	mov    %esp,%ebp
  800750:	53                   	push   %ebx
  800751:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800754:	53                   	push   %ebx
  800755:	e8 9a ff ff ff       	call   8006f4 <strlen>
  80075a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80075d:	ff 75 0c             	pushl  0xc(%ebp)
  800760:	01 d8                	add    %ebx,%eax
  800762:	50                   	push   %eax
  800763:	e8 c5 ff ff ff       	call   80072d <strcpy>
	return dst;
}
  800768:	89 d8                	mov    %ebx,%eax
  80076a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80076d:	c9                   	leave  
  80076e:	c3                   	ret    

0080076f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	56                   	push   %esi
  800773:	53                   	push   %ebx
  800774:	8b 75 08             	mov    0x8(%ebp),%esi
  800777:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80077a:	89 f3                	mov    %esi,%ebx
  80077c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80077f:	89 f2                	mov    %esi,%edx
  800781:	eb 0f                	jmp    800792 <strncpy+0x23>
		*dst++ = *src;
  800783:	83 c2 01             	add    $0x1,%edx
  800786:	0f b6 01             	movzbl (%ecx),%eax
  800789:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80078c:	80 39 01             	cmpb   $0x1,(%ecx)
  80078f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800792:	39 da                	cmp    %ebx,%edx
  800794:	75 ed                	jne    800783 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800796:	89 f0                	mov    %esi,%eax
  800798:	5b                   	pop    %ebx
  800799:	5e                   	pop    %esi
  80079a:	5d                   	pop    %ebp
  80079b:	c3                   	ret    

0080079c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	56                   	push   %esi
  8007a0:	53                   	push   %ebx
  8007a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a7:	8b 55 10             	mov    0x10(%ebp),%edx
  8007aa:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ac:	85 d2                	test   %edx,%edx
  8007ae:	74 21                	je     8007d1 <strlcpy+0x35>
  8007b0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007b4:	89 f2                	mov    %esi,%edx
  8007b6:	eb 09                	jmp    8007c1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007b8:	83 c2 01             	add    $0x1,%edx
  8007bb:	83 c1 01             	add    $0x1,%ecx
  8007be:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007c1:	39 c2                	cmp    %eax,%edx
  8007c3:	74 09                	je     8007ce <strlcpy+0x32>
  8007c5:	0f b6 19             	movzbl (%ecx),%ebx
  8007c8:	84 db                	test   %bl,%bl
  8007ca:	75 ec                	jne    8007b8 <strlcpy+0x1c>
  8007cc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007ce:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007d1:	29 f0                	sub    %esi,%eax
}
  8007d3:	5b                   	pop    %ebx
  8007d4:	5e                   	pop    %esi
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007dd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007e0:	eb 06                	jmp    8007e8 <strcmp+0x11>
		p++, q++;
  8007e2:	83 c1 01             	add    $0x1,%ecx
  8007e5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007e8:	0f b6 01             	movzbl (%ecx),%eax
  8007eb:	84 c0                	test   %al,%al
  8007ed:	74 04                	je     8007f3 <strcmp+0x1c>
  8007ef:	3a 02                	cmp    (%edx),%al
  8007f1:	74 ef                	je     8007e2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f3:	0f b6 c0             	movzbl %al,%eax
  8007f6:	0f b6 12             	movzbl (%edx),%edx
  8007f9:	29 d0                	sub    %edx,%eax
}
  8007fb:	5d                   	pop    %ebp
  8007fc:	c3                   	ret    

008007fd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	53                   	push   %ebx
  800801:	8b 45 08             	mov    0x8(%ebp),%eax
  800804:	8b 55 0c             	mov    0xc(%ebp),%edx
  800807:	89 c3                	mov    %eax,%ebx
  800809:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80080c:	eb 06                	jmp    800814 <strncmp+0x17>
		n--, p++, q++;
  80080e:	83 c0 01             	add    $0x1,%eax
  800811:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800814:	39 d8                	cmp    %ebx,%eax
  800816:	74 15                	je     80082d <strncmp+0x30>
  800818:	0f b6 08             	movzbl (%eax),%ecx
  80081b:	84 c9                	test   %cl,%cl
  80081d:	74 04                	je     800823 <strncmp+0x26>
  80081f:	3a 0a                	cmp    (%edx),%cl
  800821:	74 eb                	je     80080e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800823:	0f b6 00             	movzbl (%eax),%eax
  800826:	0f b6 12             	movzbl (%edx),%edx
  800829:	29 d0                	sub    %edx,%eax
  80082b:	eb 05                	jmp    800832 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80082d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800832:	5b                   	pop    %ebx
  800833:	5d                   	pop    %ebp
  800834:	c3                   	ret    

00800835 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	8b 45 08             	mov    0x8(%ebp),%eax
  80083b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80083f:	eb 07                	jmp    800848 <strchr+0x13>
		if (*s == c)
  800841:	38 ca                	cmp    %cl,%dl
  800843:	74 0f                	je     800854 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800845:	83 c0 01             	add    $0x1,%eax
  800848:	0f b6 10             	movzbl (%eax),%edx
  80084b:	84 d2                	test   %dl,%dl
  80084d:	75 f2                	jne    800841 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80084f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	8b 45 08             	mov    0x8(%ebp),%eax
  80085c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800860:	eb 03                	jmp    800865 <strfind+0xf>
  800862:	83 c0 01             	add    $0x1,%eax
  800865:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800868:	38 ca                	cmp    %cl,%dl
  80086a:	74 04                	je     800870 <strfind+0x1a>
  80086c:	84 d2                	test   %dl,%dl
  80086e:	75 f2                	jne    800862 <strfind+0xc>
			break;
	return (char *) s;
}
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	57                   	push   %edi
  800876:	56                   	push   %esi
  800877:	53                   	push   %ebx
  800878:	8b 7d 08             	mov    0x8(%ebp),%edi
  80087b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80087e:	85 c9                	test   %ecx,%ecx
  800880:	74 36                	je     8008b8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800882:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800888:	75 28                	jne    8008b2 <memset+0x40>
  80088a:	f6 c1 03             	test   $0x3,%cl
  80088d:	75 23                	jne    8008b2 <memset+0x40>
		c &= 0xFF;
  80088f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800893:	89 d3                	mov    %edx,%ebx
  800895:	c1 e3 08             	shl    $0x8,%ebx
  800898:	89 d6                	mov    %edx,%esi
  80089a:	c1 e6 18             	shl    $0x18,%esi
  80089d:	89 d0                	mov    %edx,%eax
  80089f:	c1 e0 10             	shl    $0x10,%eax
  8008a2:	09 f0                	or     %esi,%eax
  8008a4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008a6:	89 d8                	mov    %ebx,%eax
  8008a8:	09 d0                	or     %edx,%eax
  8008aa:	c1 e9 02             	shr    $0x2,%ecx
  8008ad:	fc                   	cld    
  8008ae:	f3 ab                	rep stos %eax,%es:(%edi)
  8008b0:	eb 06                	jmp    8008b8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b5:	fc                   	cld    
  8008b6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008b8:	89 f8                	mov    %edi,%eax
  8008ba:	5b                   	pop    %ebx
  8008bb:	5e                   	pop    %esi
  8008bc:	5f                   	pop    %edi
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	57                   	push   %edi
  8008c3:	56                   	push   %esi
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008cd:	39 c6                	cmp    %eax,%esi
  8008cf:	73 35                	jae    800906 <memmove+0x47>
  8008d1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008d4:	39 d0                	cmp    %edx,%eax
  8008d6:	73 2e                	jae    800906 <memmove+0x47>
		s += n;
		d += n;
  8008d8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008db:	89 d6                	mov    %edx,%esi
  8008dd:	09 fe                	or     %edi,%esi
  8008df:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008e5:	75 13                	jne    8008fa <memmove+0x3b>
  8008e7:	f6 c1 03             	test   $0x3,%cl
  8008ea:	75 0e                	jne    8008fa <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008ec:	83 ef 04             	sub    $0x4,%edi
  8008ef:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008f2:	c1 e9 02             	shr    $0x2,%ecx
  8008f5:	fd                   	std    
  8008f6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f8:	eb 09                	jmp    800903 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008fa:	83 ef 01             	sub    $0x1,%edi
  8008fd:	8d 72 ff             	lea    -0x1(%edx),%esi
  800900:	fd                   	std    
  800901:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800903:	fc                   	cld    
  800904:	eb 1d                	jmp    800923 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800906:	89 f2                	mov    %esi,%edx
  800908:	09 c2                	or     %eax,%edx
  80090a:	f6 c2 03             	test   $0x3,%dl
  80090d:	75 0f                	jne    80091e <memmove+0x5f>
  80090f:	f6 c1 03             	test   $0x3,%cl
  800912:	75 0a                	jne    80091e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800914:	c1 e9 02             	shr    $0x2,%ecx
  800917:	89 c7                	mov    %eax,%edi
  800919:	fc                   	cld    
  80091a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091c:	eb 05                	jmp    800923 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80091e:	89 c7                	mov    %eax,%edi
  800920:	fc                   	cld    
  800921:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800923:	5e                   	pop    %esi
  800924:	5f                   	pop    %edi
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80092a:	ff 75 10             	pushl  0x10(%ebp)
  80092d:	ff 75 0c             	pushl  0xc(%ebp)
  800930:	ff 75 08             	pushl  0x8(%ebp)
  800933:	e8 87 ff ff ff       	call   8008bf <memmove>
}
  800938:	c9                   	leave  
  800939:	c3                   	ret    

0080093a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	56                   	push   %esi
  80093e:	53                   	push   %ebx
  80093f:	8b 45 08             	mov    0x8(%ebp),%eax
  800942:	8b 55 0c             	mov    0xc(%ebp),%edx
  800945:	89 c6                	mov    %eax,%esi
  800947:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094a:	eb 1a                	jmp    800966 <memcmp+0x2c>
		if (*s1 != *s2)
  80094c:	0f b6 08             	movzbl (%eax),%ecx
  80094f:	0f b6 1a             	movzbl (%edx),%ebx
  800952:	38 d9                	cmp    %bl,%cl
  800954:	74 0a                	je     800960 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800956:	0f b6 c1             	movzbl %cl,%eax
  800959:	0f b6 db             	movzbl %bl,%ebx
  80095c:	29 d8                	sub    %ebx,%eax
  80095e:	eb 0f                	jmp    80096f <memcmp+0x35>
		s1++, s2++;
  800960:	83 c0 01             	add    $0x1,%eax
  800963:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800966:	39 f0                	cmp    %esi,%eax
  800968:	75 e2                	jne    80094c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80096a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80096f:	5b                   	pop    %ebx
  800970:	5e                   	pop    %esi
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    

00800973 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	53                   	push   %ebx
  800977:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80097a:	89 c1                	mov    %eax,%ecx
  80097c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80097f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800983:	eb 0a                	jmp    80098f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800985:	0f b6 10             	movzbl (%eax),%edx
  800988:	39 da                	cmp    %ebx,%edx
  80098a:	74 07                	je     800993 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80098c:	83 c0 01             	add    $0x1,%eax
  80098f:	39 c8                	cmp    %ecx,%eax
  800991:	72 f2                	jb     800985 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800993:	5b                   	pop    %ebx
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	57                   	push   %edi
  80099a:	56                   	push   %esi
  80099b:	53                   	push   %ebx
  80099c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a2:	eb 03                	jmp    8009a7 <strtol+0x11>
		s++;
  8009a4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a7:	0f b6 01             	movzbl (%ecx),%eax
  8009aa:	3c 20                	cmp    $0x20,%al
  8009ac:	74 f6                	je     8009a4 <strtol+0xe>
  8009ae:	3c 09                	cmp    $0x9,%al
  8009b0:	74 f2                	je     8009a4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009b2:	3c 2b                	cmp    $0x2b,%al
  8009b4:	75 0a                	jne    8009c0 <strtol+0x2a>
		s++;
  8009b6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009b9:	bf 00 00 00 00       	mov    $0x0,%edi
  8009be:	eb 11                	jmp    8009d1 <strtol+0x3b>
  8009c0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009c5:	3c 2d                	cmp    $0x2d,%al
  8009c7:	75 08                	jne    8009d1 <strtol+0x3b>
		s++, neg = 1;
  8009c9:	83 c1 01             	add    $0x1,%ecx
  8009cc:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009d1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009d7:	75 15                	jne    8009ee <strtol+0x58>
  8009d9:	80 39 30             	cmpb   $0x30,(%ecx)
  8009dc:	75 10                	jne    8009ee <strtol+0x58>
  8009de:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009e2:	75 7c                	jne    800a60 <strtol+0xca>
		s += 2, base = 16;
  8009e4:	83 c1 02             	add    $0x2,%ecx
  8009e7:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009ec:	eb 16                	jmp    800a04 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009ee:	85 db                	test   %ebx,%ebx
  8009f0:	75 12                	jne    800a04 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009f2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009f7:	80 39 30             	cmpb   $0x30,(%ecx)
  8009fa:	75 08                	jne    800a04 <strtol+0x6e>
		s++, base = 8;
  8009fc:	83 c1 01             	add    $0x1,%ecx
  8009ff:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a04:	b8 00 00 00 00       	mov    $0x0,%eax
  800a09:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a0c:	0f b6 11             	movzbl (%ecx),%edx
  800a0f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a12:	89 f3                	mov    %esi,%ebx
  800a14:	80 fb 09             	cmp    $0x9,%bl
  800a17:	77 08                	ja     800a21 <strtol+0x8b>
			dig = *s - '0';
  800a19:	0f be d2             	movsbl %dl,%edx
  800a1c:	83 ea 30             	sub    $0x30,%edx
  800a1f:	eb 22                	jmp    800a43 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a21:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a24:	89 f3                	mov    %esi,%ebx
  800a26:	80 fb 19             	cmp    $0x19,%bl
  800a29:	77 08                	ja     800a33 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a2b:	0f be d2             	movsbl %dl,%edx
  800a2e:	83 ea 57             	sub    $0x57,%edx
  800a31:	eb 10                	jmp    800a43 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a33:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a36:	89 f3                	mov    %esi,%ebx
  800a38:	80 fb 19             	cmp    $0x19,%bl
  800a3b:	77 16                	ja     800a53 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a3d:	0f be d2             	movsbl %dl,%edx
  800a40:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a43:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a46:	7d 0b                	jge    800a53 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a48:	83 c1 01             	add    $0x1,%ecx
  800a4b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a4f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a51:	eb b9                	jmp    800a0c <strtol+0x76>

	if (endptr)
  800a53:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a57:	74 0d                	je     800a66 <strtol+0xd0>
		*endptr = (char *) s;
  800a59:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5c:	89 0e                	mov    %ecx,(%esi)
  800a5e:	eb 06                	jmp    800a66 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a60:	85 db                	test   %ebx,%ebx
  800a62:	74 98                	je     8009fc <strtol+0x66>
  800a64:	eb 9e                	jmp    800a04 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a66:	89 c2                	mov    %eax,%edx
  800a68:	f7 da                	neg    %edx
  800a6a:	85 ff                	test   %edi,%edi
  800a6c:	0f 45 c2             	cmovne %edx,%eax
}
  800a6f:	5b                   	pop    %ebx
  800a70:	5e                   	pop    %esi
  800a71:	5f                   	pop    %edi
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	57                   	push   %edi
  800a78:	56                   	push   %esi
  800a79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a82:	8b 55 08             	mov    0x8(%ebp),%edx
  800a85:	89 c3                	mov    %eax,%ebx
  800a87:	89 c7                	mov    %eax,%edi
  800a89:	89 c6                	mov    %eax,%esi
  800a8b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a8d:	5b                   	pop    %ebx
  800a8e:	5e                   	pop    %esi
  800a8f:	5f                   	pop    %edi
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	57                   	push   %edi
  800a96:	56                   	push   %esi
  800a97:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a98:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9d:	b8 01 00 00 00       	mov    $0x1,%eax
  800aa2:	89 d1                	mov    %edx,%ecx
  800aa4:	89 d3                	mov    %edx,%ebx
  800aa6:	89 d7                	mov    %edx,%edi
  800aa8:	89 d6                	mov    %edx,%esi
  800aaa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aac:	5b                   	pop    %ebx
  800aad:	5e                   	pop    %esi
  800aae:	5f                   	pop    %edi
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	57                   	push   %edi
  800ab5:	56                   	push   %esi
  800ab6:	53                   	push   %ebx
  800ab7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aba:	b9 00 00 00 00       	mov    $0x0,%ecx
  800abf:	b8 03 00 00 00       	mov    $0x3,%eax
  800ac4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac7:	89 cb                	mov    %ecx,%ebx
  800ac9:	89 cf                	mov    %ecx,%edi
  800acb:	89 ce                	mov    %ecx,%esi
  800acd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800acf:	85 c0                	test   %eax,%eax
  800ad1:	7e 17                	jle    800aea <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ad3:	83 ec 0c             	sub    $0xc,%esp
  800ad6:	50                   	push   %eax
  800ad7:	6a 03                	push   $0x3
  800ad9:	68 bf 29 80 00       	push   $0x8029bf
  800ade:	6a 23                	push   $0x23
  800ae0:	68 dc 29 80 00       	push   $0x8029dc
  800ae5:	e8 ae 16 00 00       	call   802198 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af8:	ba 00 00 00 00       	mov    $0x0,%edx
  800afd:	b8 02 00 00 00       	mov    $0x2,%eax
  800b02:	89 d1                	mov    %edx,%ecx
  800b04:	89 d3                	mov    %edx,%ebx
  800b06:	89 d7                	mov    %edx,%edi
  800b08:	89 d6                	mov    %edx,%esi
  800b0a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <sys_yield>:

void
sys_yield(void)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	57                   	push   %edi
  800b15:	56                   	push   %esi
  800b16:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b17:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b21:	89 d1                	mov    %edx,%ecx
  800b23:	89 d3                	mov    %edx,%ebx
  800b25:	89 d7                	mov    %edx,%edi
  800b27:	89 d6                	mov    %edx,%esi
  800b29:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b2b:	5b                   	pop    %ebx
  800b2c:	5e                   	pop    %esi
  800b2d:	5f                   	pop    %edi
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    

00800b30 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	57                   	push   %edi
  800b34:	56                   	push   %esi
  800b35:	53                   	push   %ebx
  800b36:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b39:	be 00 00 00 00       	mov    $0x0,%esi
  800b3e:	b8 04 00 00 00       	mov    $0x4,%eax
  800b43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b46:	8b 55 08             	mov    0x8(%ebp),%edx
  800b49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b4c:	89 f7                	mov    %esi,%edi
  800b4e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b50:	85 c0                	test   %eax,%eax
  800b52:	7e 17                	jle    800b6b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b54:	83 ec 0c             	sub    $0xc,%esp
  800b57:	50                   	push   %eax
  800b58:	6a 04                	push   $0x4
  800b5a:	68 bf 29 80 00       	push   $0x8029bf
  800b5f:	6a 23                	push   $0x23
  800b61:	68 dc 29 80 00       	push   $0x8029dc
  800b66:	e8 2d 16 00 00       	call   802198 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6e:	5b                   	pop    %ebx
  800b6f:	5e                   	pop    %esi
  800b70:	5f                   	pop    %edi
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	57                   	push   %edi
  800b77:	56                   	push   %esi
  800b78:	53                   	push   %ebx
  800b79:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7c:	b8 05 00 00 00       	mov    $0x5,%eax
  800b81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b8a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b8d:	8b 75 18             	mov    0x18(%ebp),%esi
  800b90:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b92:	85 c0                	test   %eax,%eax
  800b94:	7e 17                	jle    800bad <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b96:	83 ec 0c             	sub    $0xc,%esp
  800b99:	50                   	push   %eax
  800b9a:	6a 05                	push   $0x5
  800b9c:	68 bf 29 80 00       	push   $0x8029bf
  800ba1:	6a 23                	push   $0x23
  800ba3:	68 dc 29 80 00       	push   $0x8029dc
  800ba8:	e8 eb 15 00 00       	call   802198 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb0:	5b                   	pop    %ebx
  800bb1:	5e                   	pop    %esi
  800bb2:	5f                   	pop    %edi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	57                   	push   %edi
  800bb9:	56                   	push   %esi
  800bba:	53                   	push   %ebx
  800bbb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bc3:	b8 06 00 00 00       	mov    $0x6,%eax
  800bc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bce:	89 df                	mov    %ebx,%edi
  800bd0:	89 de                	mov    %ebx,%esi
  800bd2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd4:	85 c0                	test   %eax,%eax
  800bd6:	7e 17                	jle    800bef <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd8:	83 ec 0c             	sub    $0xc,%esp
  800bdb:	50                   	push   %eax
  800bdc:	6a 06                	push   $0x6
  800bde:	68 bf 29 80 00       	push   $0x8029bf
  800be3:	6a 23                	push   $0x23
  800be5:	68 dc 29 80 00       	push   $0x8029dc
  800bea:	e8 a9 15 00 00       	call   802198 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf2:	5b                   	pop    %ebx
  800bf3:	5e                   	pop    %esi
  800bf4:	5f                   	pop    %edi
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    

00800bf7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	57                   	push   %edi
  800bfb:	56                   	push   %esi
  800bfc:	53                   	push   %ebx
  800bfd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c05:	b8 08 00 00 00       	mov    $0x8,%eax
  800c0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c10:	89 df                	mov    %ebx,%edi
  800c12:	89 de                	mov    %ebx,%esi
  800c14:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c16:	85 c0                	test   %eax,%eax
  800c18:	7e 17                	jle    800c31 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1a:	83 ec 0c             	sub    $0xc,%esp
  800c1d:	50                   	push   %eax
  800c1e:	6a 08                	push   $0x8
  800c20:	68 bf 29 80 00       	push   $0x8029bf
  800c25:	6a 23                	push   $0x23
  800c27:	68 dc 29 80 00       	push   $0x8029dc
  800c2c:	e8 67 15 00 00       	call   802198 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	57                   	push   %edi
  800c3d:	56                   	push   %esi
  800c3e:	53                   	push   %ebx
  800c3f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c42:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c47:	b8 09 00 00 00       	mov    $0x9,%eax
  800c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c52:	89 df                	mov    %ebx,%edi
  800c54:	89 de                	mov    %ebx,%esi
  800c56:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c58:	85 c0                	test   %eax,%eax
  800c5a:	7e 17                	jle    800c73 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5c:	83 ec 0c             	sub    $0xc,%esp
  800c5f:	50                   	push   %eax
  800c60:	6a 09                	push   $0x9
  800c62:	68 bf 29 80 00       	push   $0x8029bf
  800c67:	6a 23                	push   $0x23
  800c69:	68 dc 29 80 00       	push   $0x8029dc
  800c6e:	e8 25 15 00 00       	call   802198 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c76:	5b                   	pop    %ebx
  800c77:	5e                   	pop    %esi
  800c78:	5f                   	pop    %edi
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	57                   	push   %edi
  800c7f:	56                   	push   %esi
  800c80:	53                   	push   %ebx
  800c81:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c84:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c89:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c91:	8b 55 08             	mov    0x8(%ebp),%edx
  800c94:	89 df                	mov    %ebx,%edi
  800c96:	89 de                	mov    %ebx,%esi
  800c98:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9a:	85 c0                	test   %eax,%eax
  800c9c:	7e 17                	jle    800cb5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9e:	83 ec 0c             	sub    $0xc,%esp
  800ca1:	50                   	push   %eax
  800ca2:	6a 0a                	push   $0xa
  800ca4:	68 bf 29 80 00       	push   $0x8029bf
  800ca9:	6a 23                	push   $0x23
  800cab:	68 dc 29 80 00       	push   $0x8029dc
  800cb0:	e8 e3 14 00 00       	call   802198 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb8:	5b                   	pop    %ebx
  800cb9:	5e                   	pop    %esi
  800cba:	5f                   	pop    %edi
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    

00800cbd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	57                   	push   %edi
  800cc1:	56                   	push   %esi
  800cc2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc3:	be 00 00 00 00       	mov    $0x0,%esi
  800cc8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ccd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	57                   	push   %edi
  800ce4:	56                   	push   %esi
  800ce5:	53                   	push   %ebx
  800ce6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cee:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf6:	89 cb                	mov    %ecx,%ebx
  800cf8:	89 cf                	mov    %ecx,%edi
  800cfa:	89 ce                	mov    %ecx,%esi
  800cfc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	7e 17                	jle    800d19 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	50                   	push   %eax
  800d06:	6a 0d                	push   $0xd
  800d08:	68 bf 29 80 00       	push   $0x8029bf
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 dc 29 80 00       	push   $0x8029dc
  800d14:	e8 7f 14 00 00       	call   802198 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	57                   	push   %edi
  800d25:	56                   	push   %esi
  800d26:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d27:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d31:	89 d1                	mov    %edx,%ecx
  800d33:	89 d3                	mov    %edx,%ebx
  800d35:	89 d7                	mov    %edx,%edi
  800d37:	89 d6                	mov    %edx,%esi
  800d39:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	57                   	push   %edi
  800d44:	56                   	push   %esi
  800d45:	53                   	push   %ebx
  800d46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4e:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	89 df                	mov    %ebx,%edi
  800d5b:	89 de                	mov    %ebx,%esi
  800d5d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5f:	85 c0                	test   %eax,%eax
  800d61:	7e 17                	jle    800d7a <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d63:	83 ec 0c             	sub    $0xc,%esp
  800d66:	50                   	push   %eax
  800d67:	6a 0f                	push   $0xf
  800d69:	68 bf 29 80 00       	push   $0x8029bf
  800d6e:	6a 23                	push   $0x23
  800d70:	68 dc 29 80 00       	push   $0x8029dc
  800d75:	e8 1e 14 00 00       	call   802198 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800d7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	57                   	push   %edi
  800d86:	56                   	push   %esi
  800d87:	53                   	push   %ebx
  800d88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d90:	b8 10 00 00 00       	mov    $0x10,%eax
  800d95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d98:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9b:	89 df                	mov    %ebx,%edi
  800d9d:	89 de                	mov    %ebx,%esi
  800d9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da1:	85 c0                	test   %eax,%eax
  800da3:	7e 17                	jle    800dbc <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da5:	83 ec 0c             	sub    $0xc,%esp
  800da8:	50                   	push   %eax
  800da9:	6a 10                	push   $0x10
  800dab:	68 bf 29 80 00       	push   $0x8029bf
  800db0:	6a 23                	push   $0x23
  800db2:	68 dc 29 80 00       	push   $0x8029dc
  800db7:	e8 dc 13 00 00       	call   802198 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  800dbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	56                   	push   %esi
  800dc8:	53                   	push   %ebx
  800dc9:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dcc:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800dce:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dd2:	75 25                	jne    800df9 <pgfault+0x35>
  800dd4:	89 d8                	mov    %ebx,%eax
  800dd6:	c1 e8 0c             	shr    $0xc,%eax
  800dd9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800de0:	f6 c4 08             	test   $0x8,%ah
  800de3:	75 14                	jne    800df9 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800de5:	83 ec 04             	sub    $0x4,%esp
  800de8:	68 ec 29 80 00       	push   $0x8029ec
  800ded:	6a 1e                	push   $0x1e
  800def:	68 80 2a 80 00       	push   $0x802a80
  800df4:	e8 9f 13 00 00       	call   802198 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800df9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800dff:	e8 ee fc ff ff       	call   800af2 <sys_getenvid>
  800e04:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800e06:	83 ec 04             	sub    $0x4,%esp
  800e09:	6a 07                	push   $0x7
  800e0b:	68 00 f0 7f 00       	push   $0x7ff000
  800e10:	50                   	push   %eax
  800e11:	e8 1a fd ff ff       	call   800b30 <sys_page_alloc>
	if (r < 0)
  800e16:	83 c4 10             	add    $0x10,%esp
  800e19:	85 c0                	test   %eax,%eax
  800e1b:	79 12                	jns    800e2f <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800e1d:	50                   	push   %eax
  800e1e:	68 18 2a 80 00       	push   $0x802a18
  800e23:	6a 33                	push   $0x33
  800e25:	68 80 2a 80 00       	push   $0x802a80
  800e2a:	e8 69 13 00 00       	call   802198 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800e2f:	83 ec 04             	sub    $0x4,%esp
  800e32:	68 00 10 00 00       	push   $0x1000
  800e37:	53                   	push   %ebx
  800e38:	68 00 f0 7f 00       	push   $0x7ff000
  800e3d:	e8 e5 fa ff ff       	call   800927 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800e42:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e49:	53                   	push   %ebx
  800e4a:	56                   	push   %esi
  800e4b:	68 00 f0 7f 00       	push   $0x7ff000
  800e50:	56                   	push   %esi
  800e51:	e8 1d fd ff ff       	call   800b73 <sys_page_map>
	if (r < 0)
  800e56:	83 c4 20             	add    $0x20,%esp
  800e59:	85 c0                	test   %eax,%eax
  800e5b:	79 12                	jns    800e6f <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800e5d:	50                   	push   %eax
  800e5e:	68 3c 2a 80 00       	push   $0x802a3c
  800e63:	6a 3b                	push   $0x3b
  800e65:	68 80 2a 80 00       	push   $0x802a80
  800e6a:	e8 29 13 00 00       	call   802198 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800e6f:	83 ec 08             	sub    $0x8,%esp
  800e72:	68 00 f0 7f 00       	push   $0x7ff000
  800e77:	56                   	push   %esi
  800e78:	e8 38 fd ff ff       	call   800bb5 <sys_page_unmap>
	if (r < 0)
  800e7d:	83 c4 10             	add    $0x10,%esp
  800e80:	85 c0                	test   %eax,%eax
  800e82:	79 12                	jns    800e96 <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800e84:	50                   	push   %eax
  800e85:	68 60 2a 80 00       	push   $0x802a60
  800e8a:	6a 40                	push   $0x40
  800e8c:	68 80 2a 80 00       	push   $0x802a80
  800e91:	e8 02 13 00 00       	call   802198 <_panic>
}
  800e96:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e99:	5b                   	pop    %ebx
  800e9a:	5e                   	pop    %esi
  800e9b:	5d                   	pop    %ebp
  800e9c:	c3                   	ret    

00800e9d <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	57                   	push   %edi
  800ea1:	56                   	push   %esi
  800ea2:	53                   	push   %ebx
  800ea3:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800ea6:	68 c4 0d 80 00       	push   $0x800dc4
  800eab:	e8 2e 13 00 00       	call   8021de <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800eb0:	b8 07 00 00 00       	mov    $0x7,%eax
  800eb5:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800eb7:	83 c4 10             	add    $0x10,%esp
  800eba:	85 c0                	test   %eax,%eax
  800ebc:	0f 88 64 01 00 00    	js     801026 <fork+0x189>
  800ec2:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800ec7:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800ecc:	85 c0                	test   %eax,%eax
  800ece:	75 21                	jne    800ef1 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ed0:	e8 1d fc ff ff       	call   800af2 <sys_getenvid>
  800ed5:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eda:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800edd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ee2:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  800ee7:	ba 00 00 00 00       	mov    $0x0,%edx
  800eec:	e9 3f 01 00 00       	jmp    801030 <fork+0x193>
  800ef1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ef4:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800ef6:	89 d8                	mov    %ebx,%eax
  800ef8:	c1 e8 16             	shr    $0x16,%eax
  800efb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f02:	a8 01                	test   $0x1,%al
  800f04:	0f 84 bd 00 00 00    	je     800fc7 <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800f0a:	89 d8                	mov    %ebx,%eax
  800f0c:	c1 e8 0c             	shr    $0xc,%eax
  800f0f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f16:	f6 c2 01             	test   $0x1,%dl
  800f19:	0f 84 a8 00 00 00    	je     800fc7 <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  800f1f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f26:	a8 04                	test   $0x4,%al
  800f28:	0f 84 99 00 00 00    	je     800fc7 <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800f2e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f35:	f6 c4 04             	test   $0x4,%ah
  800f38:	74 17                	je     800f51 <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800f3a:	83 ec 0c             	sub    $0xc,%esp
  800f3d:	68 07 0e 00 00       	push   $0xe07
  800f42:	53                   	push   %ebx
  800f43:	57                   	push   %edi
  800f44:	53                   	push   %ebx
  800f45:	6a 00                	push   $0x0
  800f47:	e8 27 fc ff ff       	call   800b73 <sys_page_map>
  800f4c:	83 c4 20             	add    $0x20,%esp
  800f4f:	eb 76                	jmp    800fc7 <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f51:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f58:	a8 02                	test   $0x2,%al
  800f5a:	75 0c                	jne    800f68 <fork+0xcb>
  800f5c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f63:	f6 c4 08             	test   $0x8,%ah
  800f66:	74 3f                	je     800fa7 <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f68:	83 ec 0c             	sub    $0xc,%esp
  800f6b:	68 05 08 00 00       	push   $0x805
  800f70:	53                   	push   %ebx
  800f71:	57                   	push   %edi
  800f72:	53                   	push   %ebx
  800f73:	6a 00                	push   $0x0
  800f75:	e8 f9 fb ff ff       	call   800b73 <sys_page_map>
		if (r < 0)
  800f7a:	83 c4 20             	add    $0x20,%esp
  800f7d:	85 c0                	test   %eax,%eax
  800f7f:	0f 88 a5 00 00 00    	js     80102a <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f85:	83 ec 0c             	sub    $0xc,%esp
  800f88:	68 05 08 00 00       	push   $0x805
  800f8d:	53                   	push   %ebx
  800f8e:	6a 00                	push   $0x0
  800f90:	53                   	push   %ebx
  800f91:	6a 00                	push   $0x0
  800f93:	e8 db fb ff ff       	call   800b73 <sys_page_map>
  800f98:	83 c4 20             	add    $0x20,%esp
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fa2:	0f 4f c1             	cmovg  %ecx,%eax
  800fa5:	eb 1c                	jmp    800fc3 <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  800fa7:	83 ec 0c             	sub    $0xc,%esp
  800faa:	6a 05                	push   $0x5
  800fac:	53                   	push   %ebx
  800fad:	57                   	push   %edi
  800fae:	53                   	push   %ebx
  800faf:	6a 00                	push   $0x0
  800fb1:	e8 bd fb ff ff       	call   800b73 <sys_page_map>
  800fb6:	83 c4 20             	add    $0x20,%esp
  800fb9:	85 c0                	test   %eax,%eax
  800fbb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fc0:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	78 67                	js     80102e <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  800fc7:	83 c6 01             	add    $0x1,%esi
  800fca:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fd0:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  800fd6:	0f 85 1a ff ff ff    	jne    800ef6 <fork+0x59>
  800fdc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  800fdf:	83 ec 04             	sub    $0x4,%esp
  800fe2:	6a 07                	push   $0x7
  800fe4:	68 00 f0 bf ee       	push   $0xeebff000
  800fe9:	57                   	push   %edi
  800fea:	e8 41 fb ff ff       	call   800b30 <sys_page_alloc>
	if (r < 0)
  800fef:	83 c4 10             	add    $0x10,%esp
		return r;
  800ff2:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  800ff4:	85 c0                	test   %eax,%eax
  800ff6:	78 38                	js     801030 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800ff8:	83 ec 08             	sub    $0x8,%esp
  800ffb:	68 25 22 80 00       	push   $0x802225
  801000:	57                   	push   %edi
  801001:	e8 75 fc ff ff       	call   800c7b <sys_env_set_pgfault_upcall>
	if (r < 0)
  801006:	83 c4 10             	add    $0x10,%esp
		return r;
  801009:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  80100b:	85 c0                	test   %eax,%eax
  80100d:	78 21                	js     801030 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  80100f:	83 ec 08             	sub    $0x8,%esp
  801012:	6a 02                	push   $0x2
  801014:	57                   	push   %edi
  801015:	e8 dd fb ff ff       	call   800bf7 <sys_env_set_status>
	if (r < 0)
  80101a:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  80101d:	85 c0                	test   %eax,%eax
  80101f:	0f 48 f8             	cmovs  %eax,%edi
  801022:	89 fa                	mov    %edi,%edx
  801024:	eb 0a                	jmp    801030 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  801026:	89 c2                	mov    %eax,%edx
  801028:	eb 06                	jmp    801030 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  80102a:	89 c2                	mov    %eax,%edx
  80102c:	eb 02                	jmp    801030 <fork+0x193>
  80102e:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  801030:	89 d0                	mov    %edx,%eax
  801032:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801035:	5b                   	pop    %ebx
  801036:	5e                   	pop    %esi
  801037:	5f                   	pop    %edi
  801038:	5d                   	pop    %ebp
  801039:	c3                   	ret    

0080103a <sfork>:

// Challenge!
int
sfork(void)
{
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
  80103d:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801040:	68 8b 2a 80 00       	push   $0x802a8b
  801045:	68 c9 00 00 00       	push   $0xc9
  80104a:	68 80 2a 80 00       	push   $0x802a80
  80104f:	e8 44 11 00 00       	call   802198 <_panic>

00801054 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801057:	8b 45 08             	mov    0x8(%ebp),%eax
  80105a:	05 00 00 00 30       	add    $0x30000000,%eax
  80105f:	c1 e8 0c             	shr    $0xc,%eax
}
  801062:	5d                   	pop    %ebp
  801063:	c3                   	ret    

00801064 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801067:	8b 45 08             	mov    0x8(%ebp),%eax
  80106a:	05 00 00 00 30       	add    $0x30000000,%eax
  80106f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801074:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801079:	5d                   	pop    %ebp
  80107a:	c3                   	ret    

0080107b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80107b:	55                   	push   %ebp
  80107c:	89 e5                	mov    %esp,%ebp
  80107e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801081:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801086:	89 c2                	mov    %eax,%edx
  801088:	c1 ea 16             	shr    $0x16,%edx
  80108b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801092:	f6 c2 01             	test   $0x1,%dl
  801095:	74 11                	je     8010a8 <fd_alloc+0x2d>
  801097:	89 c2                	mov    %eax,%edx
  801099:	c1 ea 0c             	shr    $0xc,%edx
  80109c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010a3:	f6 c2 01             	test   $0x1,%dl
  8010a6:	75 09                	jne    8010b1 <fd_alloc+0x36>
			*fd_store = fd;
  8010a8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8010af:	eb 17                	jmp    8010c8 <fd_alloc+0x4d>
  8010b1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010b6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010bb:	75 c9                	jne    801086 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010bd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010c3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010c8:	5d                   	pop    %ebp
  8010c9:	c3                   	ret    

008010ca <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010d0:	83 f8 1f             	cmp    $0x1f,%eax
  8010d3:	77 36                	ja     80110b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010d5:	c1 e0 0c             	shl    $0xc,%eax
  8010d8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010dd:	89 c2                	mov    %eax,%edx
  8010df:	c1 ea 16             	shr    $0x16,%edx
  8010e2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010e9:	f6 c2 01             	test   $0x1,%dl
  8010ec:	74 24                	je     801112 <fd_lookup+0x48>
  8010ee:	89 c2                	mov    %eax,%edx
  8010f0:	c1 ea 0c             	shr    $0xc,%edx
  8010f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010fa:	f6 c2 01             	test   $0x1,%dl
  8010fd:	74 1a                	je     801119 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801102:	89 02                	mov    %eax,(%edx)
	return 0;
  801104:	b8 00 00 00 00       	mov    $0x0,%eax
  801109:	eb 13                	jmp    80111e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80110b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801110:	eb 0c                	jmp    80111e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801112:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801117:	eb 05                	jmp    80111e <fd_lookup+0x54>
  801119:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80111e:	5d                   	pop    %ebp
  80111f:	c3                   	ret    

00801120 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
  801123:	83 ec 08             	sub    $0x8,%esp
  801126:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801129:	ba 20 2b 80 00       	mov    $0x802b20,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80112e:	eb 13                	jmp    801143 <dev_lookup+0x23>
  801130:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801133:	39 08                	cmp    %ecx,(%eax)
  801135:	75 0c                	jne    801143 <dev_lookup+0x23>
			*dev = devtab[i];
  801137:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80113c:	b8 00 00 00 00       	mov    $0x0,%eax
  801141:	eb 2e                	jmp    801171 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801143:	8b 02                	mov    (%edx),%eax
  801145:	85 c0                	test   %eax,%eax
  801147:	75 e7                	jne    801130 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801149:	a1 08 40 80 00       	mov    0x804008,%eax
  80114e:	8b 40 48             	mov    0x48(%eax),%eax
  801151:	83 ec 04             	sub    $0x4,%esp
  801154:	51                   	push   %ecx
  801155:	50                   	push   %eax
  801156:	68 a4 2a 80 00       	push   $0x802aa4
  80115b:	e8 48 f0 ff ff       	call   8001a8 <cprintf>
	*dev = 0;
  801160:	8b 45 0c             	mov    0xc(%ebp),%eax
  801163:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801169:	83 c4 10             	add    $0x10,%esp
  80116c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801171:	c9                   	leave  
  801172:	c3                   	ret    

00801173 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801173:	55                   	push   %ebp
  801174:	89 e5                	mov    %esp,%ebp
  801176:	56                   	push   %esi
  801177:	53                   	push   %ebx
  801178:	83 ec 10             	sub    $0x10,%esp
  80117b:	8b 75 08             	mov    0x8(%ebp),%esi
  80117e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801181:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801184:	50                   	push   %eax
  801185:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80118b:	c1 e8 0c             	shr    $0xc,%eax
  80118e:	50                   	push   %eax
  80118f:	e8 36 ff ff ff       	call   8010ca <fd_lookup>
  801194:	83 c4 08             	add    $0x8,%esp
  801197:	85 c0                	test   %eax,%eax
  801199:	78 05                	js     8011a0 <fd_close+0x2d>
	    || fd != fd2)
  80119b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80119e:	74 0c                	je     8011ac <fd_close+0x39>
		return (must_exist ? r : 0);
  8011a0:	84 db                	test   %bl,%bl
  8011a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8011a7:	0f 44 c2             	cmove  %edx,%eax
  8011aa:	eb 41                	jmp    8011ed <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011ac:	83 ec 08             	sub    $0x8,%esp
  8011af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b2:	50                   	push   %eax
  8011b3:	ff 36                	pushl  (%esi)
  8011b5:	e8 66 ff ff ff       	call   801120 <dev_lookup>
  8011ba:	89 c3                	mov    %eax,%ebx
  8011bc:	83 c4 10             	add    $0x10,%esp
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	78 1a                	js     8011dd <fd_close+0x6a>
		if (dev->dev_close)
  8011c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011c9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	74 0b                	je     8011dd <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011d2:	83 ec 0c             	sub    $0xc,%esp
  8011d5:	56                   	push   %esi
  8011d6:	ff d0                	call   *%eax
  8011d8:	89 c3                	mov    %eax,%ebx
  8011da:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011dd:	83 ec 08             	sub    $0x8,%esp
  8011e0:	56                   	push   %esi
  8011e1:	6a 00                	push   $0x0
  8011e3:	e8 cd f9 ff ff       	call   800bb5 <sys_page_unmap>
	return r;
  8011e8:	83 c4 10             	add    $0x10,%esp
  8011eb:	89 d8                	mov    %ebx,%eax
}
  8011ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011f0:	5b                   	pop    %ebx
  8011f1:	5e                   	pop    %esi
  8011f2:	5d                   	pop    %ebp
  8011f3:	c3                   	ret    

008011f4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011f4:	55                   	push   %ebp
  8011f5:	89 e5                	mov    %esp,%ebp
  8011f7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fd:	50                   	push   %eax
  8011fe:	ff 75 08             	pushl  0x8(%ebp)
  801201:	e8 c4 fe ff ff       	call   8010ca <fd_lookup>
  801206:	83 c4 08             	add    $0x8,%esp
  801209:	85 c0                	test   %eax,%eax
  80120b:	78 10                	js     80121d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80120d:	83 ec 08             	sub    $0x8,%esp
  801210:	6a 01                	push   $0x1
  801212:	ff 75 f4             	pushl  -0xc(%ebp)
  801215:	e8 59 ff ff ff       	call   801173 <fd_close>
  80121a:	83 c4 10             	add    $0x10,%esp
}
  80121d:	c9                   	leave  
  80121e:	c3                   	ret    

0080121f <close_all>:

void
close_all(void)
{
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	53                   	push   %ebx
  801223:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801226:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80122b:	83 ec 0c             	sub    $0xc,%esp
  80122e:	53                   	push   %ebx
  80122f:	e8 c0 ff ff ff       	call   8011f4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801234:	83 c3 01             	add    $0x1,%ebx
  801237:	83 c4 10             	add    $0x10,%esp
  80123a:	83 fb 20             	cmp    $0x20,%ebx
  80123d:	75 ec                	jne    80122b <close_all+0xc>
		close(i);
}
  80123f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801242:	c9                   	leave  
  801243:	c3                   	ret    

00801244 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	57                   	push   %edi
  801248:	56                   	push   %esi
  801249:	53                   	push   %ebx
  80124a:	83 ec 2c             	sub    $0x2c,%esp
  80124d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801250:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801253:	50                   	push   %eax
  801254:	ff 75 08             	pushl  0x8(%ebp)
  801257:	e8 6e fe ff ff       	call   8010ca <fd_lookup>
  80125c:	83 c4 08             	add    $0x8,%esp
  80125f:	85 c0                	test   %eax,%eax
  801261:	0f 88 c1 00 00 00    	js     801328 <dup+0xe4>
		return r;
	close(newfdnum);
  801267:	83 ec 0c             	sub    $0xc,%esp
  80126a:	56                   	push   %esi
  80126b:	e8 84 ff ff ff       	call   8011f4 <close>

	newfd = INDEX2FD(newfdnum);
  801270:	89 f3                	mov    %esi,%ebx
  801272:	c1 e3 0c             	shl    $0xc,%ebx
  801275:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80127b:	83 c4 04             	add    $0x4,%esp
  80127e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801281:	e8 de fd ff ff       	call   801064 <fd2data>
  801286:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801288:	89 1c 24             	mov    %ebx,(%esp)
  80128b:	e8 d4 fd ff ff       	call   801064 <fd2data>
  801290:	83 c4 10             	add    $0x10,%esp
  801293:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801296:	89 f8                	mov    %edi,%eax
  801298:	c1 e8 16             	shr    $0x16,%eax
  80129b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012a2:	a8 01                	test   $0x1,%al
  8012a4:	74 37                	je     8012dd <dup+0x99>
  8012a6:	89 f8                	mov    %edi,%eax
  8012a8:	c1 e8 0c             	shr    $0xc,%eax
  8012ab:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012b2:	f6 c2 01             	test   $0x1,%dl
  8012b5:	74 26                	je     8012dd <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012b7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012be:	83 ec 0c             	sub    $0xc,%esp
  8012c1:	25 07 0e 00 00       	and    $0xe07,%eax
  8012c6:	50                   	push   %eax
  8012c7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012ca:	6a 00                	push   $0x0
  8012cc:	57                   	push   %edi
  8012cd:	6a 00                	push   $0x0
  8012cf:	e8 9f f8 ff ff       	call   800b73 <sys_page_map>
  8012d4:	89 c7                	mov    %eax,%edi
  8012d6:	83 c4 20             	add    $0x20,%esp
  8012d9:	85 c0                	test   %eax,%eax
  8012db:	78 2e                	js     80130b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012e0:	89 d0                	mov    %edx,%eax
  8012e2:	c1 e8 0c             	shr    $0xc,%eax
  8012e5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012ec:	83 ec 0c             	sub    $0xc,%esp
  8012ef:	25 07 0e 00 00       	and    $0xe07,%eax
  8012f4:	50                   	push   %eax
  8012f5:	53                   	push   %ebx
  8012f6:	6a 00                	push   $0x0
  8012f8:	52                   	push   %edx
  8012f9:	6a 00                	push   $0x0
  8012fb:	e8 73 f8 ff ff       	call   800b73 <sys_page_map>
  801300:	89 c7                	mov    %eax,%edi
  801302:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801305:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801307:	85 ff                	test   %edi,%edi
  801309:	79 1d                	jns    801328 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80130b:	83 ec 08             	sub    $0x8,%esp
  80130e:	53                   	push   %ebx
  80130f:	6a 00                	push   $0x0
  801311:	e8 9f f8 ff ff       	call   800bb5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801316:	83 c4 08             	add    $0x8,%esp
  801319:	ff 75 d4             	pushl  -0x2c(%ebp)
  80131c:	6a 00                	push   $0x0
  80131e:	e8 92 f8 ff ff       	call   800bb5 <sys_page_unmap>
	return r;
  801323:	83 c4 10             	add    $0x10,%esp
  801326:	89 f8                	mov    %edi,%eax
}
  801328:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80132b:	5b                   	pop    %ebx
  80132c:	5e                   	pop    %esi
  80132d:	5f                   	pop    %edi
  80132e:	5d                   	pop    %ebp
  80132f:	c3                   	ret    

00801330 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801330:	55                   	push   %ebp
  801331:	89 e5                	mov    %esp,%ebp
  801333:	53                   	push   %ebx
  801334:	83 ec 14             	sub    $0x14,%esp
  801337:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80133a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133d:	50                   	push   %eax
  80133e:	53                   	push   %ebx
  80133f:	e8 86 fd ff ff       	call   8010ca <fd_lookup>
  801344:	83 c4 08             	add    $0x8,%esp
  801347:	89 c2                	mov    %eax,%edx
  801349:	85 c0                	test   %eax,%eax
  80134b:	78 6d                	js     8013ba <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80134d:	83 ec 08             	sub    $0x8,%esp
  801350:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801353:	50                   	push   %eax
  801354:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801357:	ff 30                	pushl  (%eax)
  801359:	e8 c2 fd ff ff       	call   801120 <dev_lookup>
  80135e:	83 c4 10             	add    $0x10,%esp
  801361:	85 c0                	test   %eax,%eax
  801363:	78 4c                	js     8013b1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801365:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801368:	8b 42 08             	mov    0x8(%edx),%eax
  80136b:	83 e0 03             	and    $0x3,%eax
  80136e:	83 f8 01             	cmp    $0x1,%eax
  801371:	75 21                	jne    801394 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801373:	a1 08 40 80 00       	mov    0x804008,%eax
  801378:	8b 40 48             	mov    0x48(%eax),%eax
  80137b:	83 ec 04             	sub    $0x4,%esp
  80137e:	53                   	push   %ebx
  80137f:	50                   	push   %eax
  801380:	68 e5 2a 80 00       	push   $0x802ae5
  801385:	e8 1e ee ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  80138a:	83 c4 10             	add    $0x10,%esp
  80138d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801392:	eb 26                	jmp    8013ba <read+0x8a>
	}
	if (!dev->dev_read)
  801394:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801397:	8b 40 08             	mov    0x8(%eax),%eax
  80139a:	85 c0                	test   %eax,%eax
  80139c:	74 17                	je     8013b5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80139e:	83 ec 04             	sub    $0x4,%esp
  8013a1:	ff 75 10             	pushl  0x10(%ebp)
  8013a4:	ff 75 0c             	pushl  0xc(%ebp)
  8013a7:	52                   	push   %edx
  8013a8:	ff d0                	call   *%eax
  8013aa:	89 c2                	mov    %eax,%edx
  8013ac:	83 c4 10             	add    $0x10,%esp
  8013af:	eb 09                	jmp    8013ba <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b1:	89 c2                	mov    %eax,%edx
  8013b3:	eb 05                	jmp    8013ba <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013ba:	89 d0                	mov    %edx,%eax
  8013bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013bf:	c9                   	leave  
  8013c0:	c3                   	ret    

008013c1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013c1:	55                   	push   %ebp
  8013c2:	89 e5                	mov    %esp,%ebp
  8013c4:	57                   	push   %edi
  8013c5:	56                   	push   %esi
  8013c6:	53                   	push   %ebx
  8013c7:	83 ec 0c             	sub    $0xc,%esp
  8013ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013cd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013d5:	eb 21                	jmp    8013f8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013d7:	83 ec 04             	sub    $0x4,%esp
  8013da:	89 f0                	mov    %esi,%eax
  8013dc:	29 d8                	sub    %ebx,%eax
  8013de:	50                   	push   %eax
  8013df:	89 d8                	mov    %ebx,%eax
  8013e1:	03 45 0c             	add    0xc(%ebp),%eax
  8013e4:	50                   	push   %eax
  8013e5:	57                   	push   %edi
  8013e6:	e8 45 ff ff ff       	call   801330 <read>
		if (m < 0)
  8013eb:	83 c4 10             	add    $0x10,%esp
  8013ee:	85 c0                	test   %eax,%eax
  8013f0:	78 10                	js     801402 <readn+0x41>
			return m;
		if (m == 0)
  8013f2:	85 c0                	test   %eax,%eax
  8013f4:	74 0a                	je     801400 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013f6:	01 c3                	add    %eax,%ebx
  8013f8:	39 f3                	cmp    %esi,%ebx
  8013fa:	72 db                	jb     8013d7 <readn+0x16>
  8013fc:	89 d8                	mov    %ebx,%eax
  8013fe:	eb 02                	jmp    801402 <readn+0x41>
  801400:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801402:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801405:	5b                   	pop    %ebx
  801406:	5e                   	pop    %esi
  801407:	5f                   	pop    %edi
  801408:	5d                   	pop    %ebp
  801409:	c3                   	ret    

0080140a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	53                   	push   %ebx
  80140e:	83 ec 14             	sub    $0x14,%esp
  801411:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801414:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801417:	50                   	push   %eax
  801418:	53                   	push   %ebx
  801419:	e8 ac fc ff ff       	call   8010ca <fd_lookup>
  80141e:	83 c4 08             	add    $0x8,%esp
  801421:	89 c2                	mov    %eax,%edx
  801423:	85 c0                	test   %eax,%eax
  801425:	78 68                	js     80148f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801427:	83 ec 08             	sub    $0x8,%esp
  80142a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142d:	50                   	push   %eax
  80142e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801431:	ff 30                	pushl  (%eax)
  801433:	e8 e8 fc ff ff       	call   801120 <dev_lookup>
  801438:	83 c4 10             	add    $0x10,%esp
  80143b:	85 c0                	test   %eax,%eax
  80143d:	78 47                	js     801486 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80143f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801442:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801446:	75 21                	jne    801469 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801448:	a1 08 40 80 00       	mov    0x804008,%eax
  80144d:	8b 40 48             	mov    0x48(%eax),%eax
  801450:	83 ec 04             	sub    $0x4,%esp
  801453:	53                   	push   %ebx
  801454:	50                   	push   %eax
  801455:	68 01 2b 80 00       	push   $0x802b01
  80145a:	e8 49 ed ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  80145f:	83 c4 10             	add    $0x10,%esp
  801462:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801467:	eb 26                	jmp    80148f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801469:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80146c:	8b 52 0c             	mov    0xc(%edx),%edx
  80146f:	85 d2                	test   %edx,%edx
  801471:	74 17                	je     80148a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801473:	83 ec 04             	sub    $0x4,%esp
  801476:	ff 75 10             	pushl  0x10(%ebp)
  801479:	ff 75 0c             	pushl  0xc(%ebp)
  80147c:	50                   	push   %eax
  80147d:	ff d2                	call   *%edx
  80147f:	89 c2                	mov    %eax,%edx
  801481:	83 c4 10             	add    $0x10,%esp
  801484:	eb 09                	jmp    80148f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801486:	89 c2                	mov    %eax,%edx
  801488:	eb 05                	jmp    80148f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80148a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80148f:	89 d0                	mov    %edx,%eax
  801491:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801494:	c9                   	leave  
  801495:	c3                   	ret    

00801496 <seek>:

int
seek(int fdnum, off_t offset)
{
  801496:	55                   	push   %ebp
  801497:	89 e5                	mov    %esp,%ebp
  801499:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80149c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80149f:	50                   	push   %eax
  8014a0:	ff 75 08             	pushl  0x8(%ebp)
  8014a3:	e8 22 fc ff ff       	call   8010ca <fd_lookup>
  8014a8:	83 c4 08             	add    $0x8,%esp
  8014ab:	85 c0                	test   %eax,%eax
  8014ad:	78 0e                	js     8014bd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014af:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014b5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014bd:	c9                   	leave  
  8014be:	c3                   	ret    

008014bf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014bf:	55                   	push   %ebp
  8014c0:	89 e5                	mov    %esp,%ebp
  8014c2:	53                   	push   %ebx
  8014c3:	83 ec 14             	sub    $0x14,%esp
  8014c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014cc:	50                   	push   %eax
  8014cd:	53                   	push   %ebx
  8014ce:	e8 f7 fb ff ff       	call   8010ca <fd_lookup>
  8014d3:	83 c4 08             	add    $0x8,%esp
  8014d6:	89 c2                	mov    %eax,%edx
  8014d8:	85 c0                	test   %eax,%eax
  8014da:	78 65                	js     801541 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014dc:	83 ec 08             	sub    $0x8,%esp
  8014df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e2:	50                   	push   %eax
  8014e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e6:	ff 30                	pushl  (%eax)
  8014e8:	e8 33 fc ff ff       	call   801120 <dev_lookup>
  8014ed:	83 c4 10             	add    $0x10,%esp
  8014f0:	85 c0                	test   %eax,%eax
  8014f2:	78 44                	js     801538 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014fb:	75 21                	jne    80151e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014fd:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801502:	8b 40 48             	mov    0x48(%eax),%eax
  801505:	83 ec 04             	sub    $0x4,%esp
  801508:	53                   	push   %ebx
  801509:	50                   	push   %eax
  80150a:	68 c4 2a 80 00       	push   $0x802ac4
  80150f:	e8 94 ec ff ff       	call   8001a8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801514:	83 c4 10             	add    $0x10,%esp
  801517:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80151c:	eb 23                	jmp    801541 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80151e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801521:	8b 52 18             	mov    0x18(%edx),%edx
  801524:	85 d2                	test   %edx,%edx
  801526:	74 14                	je     80153c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801528:	83 ec 08             	sub    $0x8,%esp
  80152b:	ff 75 0c             	pushl  0xc(%ebp)
  80152e:	50                   	push   %eax
  80152f:	ff d2                	call   *%edx
  801531:	89 c2                	mov    %eax,%edx
  801533:	83 c4 10             	add    $0x10,%esp
  801536:	eb 09                	jmp    801541 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801538:	89 c2                	mov    %eax,%edx
  80153a:	eb 05                	jmp    801541 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80153c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801541:	89 d0                	mov    %edx,%eax
  801543:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801546:	c9                   	leave  
  801547:	c3                   	ret    

00801548 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801548:	55                   	push   %ebp
  801549:	89 e5                	mov    %esp,%ebp
  80154b:	53                   	push   %ebx
  80154c:	83 ec 14             	sub    $0x14,%esp
  80154f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801552:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801555:	50                   	push   %eax
  801556:	ff 75 08             	pushl  0x8(%ebp)
  801559:	e8 6c fb ff ff       	call   8010ca <fd_lookup>
  80155e:	83 c4 08             	add    $0x8,%esp
  801561:	89 c2                	mov    %eax,%edx
  801563:	85 c0                	test   %eax,%eax
  801565:	78 58                	js     8015bf <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801567:	83 ec 08             	sub    $0x8,%esp
  80156a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156d:	50                   	push   %eax
  80156e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801571:	ff 30                	pushl  (%eax)
  801573:	e8 a8 fb ff ff       	call   801120 <dev_lookup>
  801578:	83 c4 10             	add    $0x10,%esp
  80157b:	85 c0                	test   %eax,%eax
  80157d:	78 37                	js     8015b6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80157f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801582:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801586:	74 32                	je     8015ba <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801588:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80158b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801592:	00 00 00 
	stat->st_isdir = 0;
  801595:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80159c:	00 00 00 
	stat->st_dev = dev;
  80159f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015a5:	83 ec 08             	sub    $0x8,%esp
  8015a8:	53                   	push   %ebx
  8015a9:	ff 75 f0             	pushl  -0x10(%ebp)
  8015ac:	ff 50 14             	call   *0x14(%eax)
  8015af:	89 c2                	mov    %eax,%edx
  8015b1:	83 c4 10             	add    $0x10,%esp
  8015b4:	eb 09                	jmp    8015bf <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b6:	89 c2                	mov    %eax,%edx
  8015b8:	eb 05                	jmp    8015bf <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015bf:	89 d0                	mov    %edx,%eax
  8015c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c4:	c9                   	leave  
  8015c5:	c3                   	ret    

008015c6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015c6:	55                   	push   %ebp
  8015c7:	89 e5                	mov    %esp,%ebp
  8015c9:	56                   	push   %esi
  8015ca:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015cb:	83 ec 08             	sub    $0x8,%esp
  8015ce:	6a 00                	push   $0x0
  8015d0:	ff 75 08             	pushl  0x8(%ebp)
  8015d3:	e8 d6 01 00 00       	call   8017ae <open>
  8015d8:	89 c3                	mov    %eax,%ebx
  8015da:	83 c4 10             	add    $0x10,%esp
  8015dd:	85 c0                	test   %eax,%eax
  8015df:	78 1b                	js     8015fc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015e1:	83 ec 08             	sub    $0x8,%esp
  8015e4:	ff 75 0c             	pushl  0xc(%ebp)
  8015e7:	50                   	push   %eax
  8015e8:	e8 5b ff ff ff       	call   801548 <fstat>
  8015ed:	89 c6                	mov    %eax,%esi
	close(fd);
  8015ef:	89 1c 24             	mov    %ebx,(%esp)
  8015f2:	e8 fd fb ff ff       	call   8011f4 <close>
	return r;
  8015f7:	83 c4 10             	add    $0x10,%esp
  8015fa:	89 f0                	mov    %esi,%eax
}
  8015fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ff:	5b                   	pop    %ebx
  801600:	5e                   	pop    %esi
  801601:	5d                   	pop    %ebp
  801602:	c3                   	ret    

00801603 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801603:	55                   	push   %ebp
  801604:	89 e5                	mov    %esp,%ebp
  801606:	56                   	push   %esi
  801607:	53                   	push   %ebx
  801608:	89 c6                	mov    %eax,%esi
  80160a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80160c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801613:	75 12                	jne    801627 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801615:	83 ec 0c             	sub    $0xc,%esp
  801618:	6a 01                	push   $0x1
  80161a:	e8 e5 0c 00 00       	call   802304 <ipc_find_env>
  80161f:	a3 00 40 80 00       	mov    %eax,0x804000
  801624:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801627:	6a 07                	push   $0x7
  801629:	68 00 50 80 00       	push   $0x805000
  80162e:	56                   	push   %esi
  80162f:	ff 35 00 40 80 00    	pushl  0x804000
  801635:	e8 76 0c 00 00       	call   8022b0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80163a:	83 c4 0c             	add    $0xc,%esp
  80163d:	6a 00                	push   $0x0
  80163f:	53                   	push   %ebx
  801640:	6a 00                	push   $0x0
  801642:	e8 02 0c 00 00       	call   802249 <ipc_recv>
}
  801647:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80164a:	5b                   	pop    %ebx
  80164b:	5e                   	pop    %esi
  80164c:	5d                   	pop    %ebp
  80164d:	c3                   	ret    

0080164e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80164e:	55                   	push   %ebp
  80164f:	89 e5                	mov    %esp,%ebp
  801651:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801654:	8b 45 08             	mov    0x8(%ebp),%eax
  801657:	8b 40 0c             	mov    0xc(%eax),%eax
  80165a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80165f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801662:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801667:	ba 00 00 00 00       	mov    $0x0,%edx
  80166c:	b8 02 00 00 00       	mov    $0x2,%eax
  801671:	e8 8d ff ff ff       	call   801603 <fsipc>
}
  801676:	c9                   	leave  
  801677:	c3                   	ret    

00801678 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801678:	55                   	push   %ebp
  801679:	89 e5                	mov    %esp,%ebp
  80167b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80167e:	8b 45 08             	mov    0x8(%ebp),%eax
  801681:	8b 40 0c             	mov    0xc(%eax),%eax
  801684:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801689:	ba 00 00 00 00       	mov    $0x0,%edx
  80168e:	b8 06 00 00 00       	mov    $0x6,%eax
  801693:	e8 6b ff ff ff       	call   801603 <fsipc>
}
  801698:	c9                   	leave  
  801699:	c3                   	ret    

0080169a <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80169a:	55                   	push   %ebp
  80169b:	89 e5                	mov    %esp,%ebp
  80169d:	53                   	push   %ebx
  80169e:	83 ec 04             	sub    $0x4,%esp
  8016a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8016aa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016af:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8016b9:	e8 45 ff ff ff       	call   801603 <fsipc>
  8016be:	85 c0                	test   %eax,%eax
  8016c0:	78 2c                	js     8016ee <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016c2:	83 ec 08             	sub    $0x8,%esp
  8016c5:	68 00 50 80 00       	push   $0x805000
  8016ca:	53                   	push   %ebx
  8016cb:	e8 5d f0 ff ff       	call   80072d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016d0:	a1 80 50 80 00       	mov    0x805080,%eax
  8016d5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016db:	a1 84 50 80 00       	mov    0x805084,%eax
  8016e0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016e6:	83 c4 10             	add    $0x10,%esp
  8016e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f1:	c9                   	leave  
  8016f2:	c3                   	ret    

008016f3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016f3:	55                   	push   %ebp
  8016f4:	89 e5                	mov    %esp,%ebp
  8016f6:	83 ec 0c             	sub    $0xc,%esp
  8016f9:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8016ff:	8b 52 0c             	mov    0xc(%edx),%edx
  801702:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801708:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80170d:	50                   	push   %eax
  80170e:	ff 75 0c             	pushl  0xc(%ebp)
  801711:	68 08 50 80 00       	push   $0x805008
  801716:	e8 a4 f1 ff ff       	call   8008bf <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80171b:	ba 00 00 00 00       	mov    $0x0,%edx
  801720:	b8 04 00 00 00       	mov    $0x4,%eax
  801725:	e8 d9 fe ff ff       	call   801603 <fsipc>

}
  80172a:	c9                   	leave  
  80172b:	c3                   	ret    

0080172c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80172c:	55                   	push   %ebp
  80172d:	89 e5                	mov    %esp,%ebp
  80172f:	56                   	push   %esi
  801730:	53                   	push   %ebx
  801731:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801734:	8b 45 08             	mov    0x8(%ebp),%eax
  801737:	8b 40 0c             	mov    0xc(%eax),%eax
  80173a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80173f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801745:	ba 00 00 00 00       	mov    $0x0,%edx
  80174a:	b8 03 00 00 00       	mov    $0x3,%eax
  80174f:	e8 af fe ff ff       	call   801603 <fsipc>
  801754:	89 c3                	mov    %eax,%ebx
  801756:	85 c0                	test   %eax,%eax
  801758:	78 4b                	js     8017a5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80175a:	39 c6                	cmp    %eax,%esi
  80175c:	73 16                	jae    801774 <devfile_read+0x48>
  80175e:	68 34 2b 80 00       	push   $0x802b34
  801763:	68 3b 2b 80 00       	push   $0x802b3b
  801768:	6a 7c                	push   $0x7c
  80176a:	68 50 2b 80 00       	push   $0x802b50
  80176f:	e8 24 0a 00 00       	call   802198 <_panic>
	assert(r <= PGSIZE);
  801774:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801779:	7e 16                	jle    801791 <devfile_read+0x65>
  80177b:	68 5b 2b 80 00       	push   $0x802b5b
  801780:	68 3b 2b 80 00       	push   $0x802b3b
  801785:	6a 7d                	push   $0x7d
  801787:	68 50 2b 80 00       	push   $0x802b50
  80178c:	e8 07 0a 00 00       	call   802198 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801791:	83 ec 04             	sub    $0x4,%esp
  801794:	50                   	push   %eax
  801795:	68 00 50 80 00       	push   $0x805000
  80179a:	ff 75 0c             	pushl  0xc(%ebp)
  80179d:	e8 1d f1 ff ff       	call   8008bf <memmove>
	return r;
  8017a2:	83 c4 10             	add    $0x10,%esp
}
  8017a5:	89 d8                	mov    %ebx,%eax
  8017a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017aa:	5b                   	pop    %ebx
  8017ab:	5e                   	pop    %esi
  8017ac:	5d                   	pop    %ebp
  8017ad:	c3                   	ret    

008017ae <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017ae:	55                   	push   %ebp
  8017af:	89 e5                	mov    %esp,%ebp
  8017b1:	53                   	push   %ebx
  8017b2:	83 ec 20             	sub    $0x20,%esp
  8017b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017b8:	53                   	push   %ebx
  8017b9:	e8 36 ef ff ff       	call   8006f4 <strlen>
  8017be:	83 c4 10             	add    $0x10,%esp
  8017c1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017c6:	7f 67                	jg     80182f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017c8:	83 ec 0c             	sub    $0xc,%esp
  8017cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ce:	50                   	push   %eax
  8017cf:	e8 a7 f8 ff ff       	call   80107b <fd_alloc>
  8017d4:	83 c4 10             	add    $0x10,%esp
		return r;
  8017d7:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017d9:	85 c0                	test   %eax,%eax
  8017db:	78 57                	js     801834 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017dd:	83 ec 08             	sub    $0x8,%esp
  8017e0:	53                   	push   %ebx
  8017e1:	68 00 50 80 00       	push   $0x805000
  8017e6:	e8 42 ef ff ff       	call   80072d <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ee:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8017fb:	e8 03 fe ff ff       	call   801603 <fsipc>
  801800:	89 c3                	mov    %eax,%ebx
  801802:	83 c4 10             	add    $0x10,%esp
  801805:	85 c0                	test   %eax,%eax
  801807:	79 14                	jns    80181d <open+0x6f>
		fd_close(fd, 0);
  801809:	83 ec 08             	sub    $0x8,%esp
  80180c:	6a 00                	push   $0x0
  80180e:	ff 75 f4             	pushl  -0xc(%ebp)
  801811:	e8 5d f9 ff ff       	call   801173 <fd_close>
		return r;
  801816:	83 c4 10             	add    $0x10,%esp
  801819:	89 da                	mov    %ebx,%edx
  80181b:	eb 17                	jmp    801834 <open+0x86>
	}

	return fd2num(fd);
  80181d:	83 ec 0c             	sub    $0xc,%esp
  801820:	ff 75 f4             	pushl  -0xc(%ebp)
  801823:	e8 2c f8 ff ff       	call   801054 <fd2num>
  801828:	89 c2                	mov    %eax,%edx
  80182a:	83 c4 10             	add    $0x10,%esp
  80182d:	eb 05                	jmp    801834 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80182f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801834:	89 d0                	mov    %edx,%eax
  801836:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801839:	c9                   	leave  
  80183a:	c3                   	ret    

0080183b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80183b:	55                   	push   %ebp
  80183c:	89 e5                	mov    %esp,%ebp
  80183e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801841:	ba 00 00 00 00       	mov    $0x0,%edx
  801846:	b8 08 00 00 00       	mov    $0x8,%eax
  80184b:	e8 b3 fd ff ff       	call   801603 <fsipc>
}
  801850:	c9                   	leave  
  801851:	c3                   	ret    

00801852 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801852:	55                   	push   %ebp
  801853:	89 e5                	mov    %esp,%ebp
  801855:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801858:	68 67 2b 80 00       	push   $0x802b67
  80185d:	ff 75 0c             	pushl  0xc(%ebp)
  801860:	e8 c8 ee ff ff       	call   80072d <strcpy>
	return 0;
}
  801865:	b8 00 00 00 00       	mov    $0x0,%eax
  80186a:	c9                   	leave  
  80186b:	c3                   	ret    

0080186c <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80186c:	55                   	push   %ebp
  80186d:	89 e5                	mov    %esp,%ebp
  80186f:	53                   	push   %ebx
  801870:	83 ec 10             	sub    $0x10,%esp
  801873:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801876:	53                   	push   %ebx
  801877:	e8 c1 0a 00 00       	call   80233d <pageref>
  80187c:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  80187f:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801884:	83 f8 01             	cmp    $0x1,%eax
  801887:	75 10                	jne    801899 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801889:	83 ec 0c             	sub    $0xc,%esp
  80188c:	ff 73 0c             	pushl  0xc(%ebx)
  80188f:	e8 c0 02 00 00       	call   801b54 <nsipc_close>
  801894:	89 c2                	mov    %eax,%edx
  801896:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801899:	89 d0                	mov    %edx,%eax
  80189b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80189e:	c9                   	leave  
  80189f:	c3                   	ret    

008018a0 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8018a0:	55                   	push   %ebp
  8018a1:	89 e5                	mov    %esp,%ebp
  8018a3:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8018a6:	6a 00                	push   $0x0
  8018a8:	ff 75 10             	pushl  0x10(%ebp)
  8018ab:	ff 75 0c             	pushl  0xc(%ebp)
  8018ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b1:	ff 70 0c             	pushl  0xc(%eax)
  8018b4:	e8 78 03 00 00       	call   801c31 <nsipc_send>
}
  8018b9:	c9                   	leave  
  8018ba:	c3                   	ret    

008018bb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
  8018be:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8018c1:	6a 00                	push   $0x0
  8018c3:	ff 75 10             	pushl  0x10(%ebp)
  8018c6:	ff 75 0c             	pushl  0xc(%ebp)
  8018c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cc:	ff 70 0c             	pushl  0xc(%eax)
  8018cf:	e8 f1 02 00 00       	call   801bc5 <nsipc_recv>
}
  8018d4:	c9                   	leave  
  8018d5:	c3                   	ret    

008018d6 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8018d6:	55                   	push   %ebp
  8018d7:	89 e5                	mov    %esp,%ebp
  8018d9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8018dc:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8018df:	52                   	push   %edx
  8018e0:	50                   	push   %eax
  8018e1:	e8 e4 f7 ff ff       	call   8010ca <fd_lookup>
  8018e6:	83 c4 10             	add    $0x10,%esp
  8018e9:	85 c0                	test   %eax,%eax
  8018eb:	78 17                	js     801904 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8018ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f0:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8018f6:	39 08                	cmp    %ecx,(%eax)
  8018f8:	75 05                	jne    8018ff <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8018fa:	8b 40 0c             	mov    0xc(%eax),%eax
  8018fd:	eb 05                	jmp    801904 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8018ff:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801904:	c9                   	leave  
  801905:	c3                   	ret    

00801906 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801906:	55                   	push   %ebp
  801907:	89 e5                	mov    %esp,%ebp
  801909:	56                   	push   %esi
  80190a:	53                   	push   %ebx
  80190b:	83 ec 1c             	sub    $0x1c,%esp
  80190e:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801910:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801913:	50                   	push   %eax
  801914:	e8 62 f7 ff ff       	call   80107b <fd_alloc>
  801919:	89 c3                	mov    %eax,%ebx
  80191b:	83 c4 10             	add    $0x10,%esp
  80191e:	85 c0                	test   %eax,%eax
  801920:	78 1b                	js     80193d <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801922:	83 ec 04             	sub    $0x4,%esp
  801925:	68 07 04 00 00       	push   $0x407
  80192a:	ff 75 f4             	pushl  -0xc(%ebp)
  80192d:	6a 00                	push   $0x0
  80192f:	e8 fc f1 ff ff       	call   800b30 <sys_page_alloc>
  801934:	89 c3                	mov    %eax,%ebx
  801936:	83 c4 10             	add    $0x10,%esp
  801939:	85 c0                	test   %eax,%eax
  80193b:	79 10                	jns    80194d <alloc_sockfd+0x47>
		nsipc_close(sockid);
  80193d:	83 ec 0c             	sub    $0xc,%esp
  801940:	56                   	push   %esi
  801941:	e8 0e 02 00 00       	call   801b54 <nsipc_close>
		return r;
  801946:	83 c4 10             	add    $0x10,%esp
  801949:	89 d8                	mov    %ebx,%eax
  80194b:	eb 24                	jmp    801971 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80194d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801953:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801956:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801958:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80195b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801962:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801965:	83 ec 0c             	sub    $0xc,%esp
  801968:	50                   	push   %eax
  801969:	e8 e6 f6 ff ff       	call   801054 <fd2num>
  80196e:	83 c4 10             	add    $0x10,%esp
}
  801971:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801974:	5b                   	pop    %ebx
  801975:	5e                   	pop    %esi
  801976:	5d                   	pop    %ebp
  801977:	c3                   	ret    

00801978 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801978:	55                   	push   %ebp
  801979:	89 e5                	mov    %esp,%ebp
  80197b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80197e:	8b 45 08             	mov    0x8(%ebp),%eax
  801981:	e8 50 ff ff ff       	call   8018d6 <fd2sockid>
		return r;
  801986:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801988:	85 c0                	test   %eax,%eax
  80198a:	78 1f                	js     8019ab <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80198c:	83 ec 04             	sub    $0x4,%esp
  80198f:	ff 75 10             	pushl  0x10(%ebp)
  801992:	ff 75 0c             	pushl  0xc(%ebp)
  801995:	50                   	push   %eax
  801996:	e8 12 01 00 00       	call   801aad <nsipc_accept>
  80199b:	83 c4 10             	add    $0x10,%esp
		return r;
  80199e:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019a0:	85 c0                	test   %eax,%eax
  8019a2:	78 07                	js     8019ab <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8019a4:	e8 5d ff ff ff       	call   801906 <alloc_sockfd>
  8019a9:	89 c1                	mov    %eax,%ecx
}
  8019ab:	89 c8                	mov    %ecx,%eax
  8019ad:	c9                   	leave  
  8019ae:	c3                   	ret    

008019af <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8019af:	55                   	push   %ebp
  8019b0:	89 e5                	mov    %esp,%ebp
  8019b2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b8:	e8 19 ff ff ff       	call   8018d6 <fd2sockid>
  8019bd:	85 c0                	test   %eax,%eax
  8019bf:	78 12                	js     8019d3 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8019c1:	83 ec 04             	sub    $0x4,%esp
  8019c4:	ff 75 10             	pushl  0x10(%ebp)
  8019c7:	ff 75 0c             	pushl  0xc(%ebp)
  8019ca:	50                   	push   %eax
  8019cb:	e8 2d 01 00 00       	call   801afd <nsipc_bind>
  8019d0:	83 c4 10             	add    $0x10,%esp
}
  8019d3:	c9                   	leave  
  8019d4:	c3                   	ret    

008019d5 <shutdown>:

int
shutdown(int s, int how)
{
  8019d5:	55                   	push   %ebp
  8019d6:	89 e5                	mov    %esp,%ebp
  8019d8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019db:	8b 45 08             	mov    0x8(%ebp),%eax
  8019de:	e8 f3 fe ff ff       	call   8018d6 <fd2sockid>
  8019e3:	85 c0                	test   %eax,%eax
  8019e5:	78 0f                	js     8019f6 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8019e7:	83 ec 08             	sub    $0x8,%esp
  8019ea:	ff 75 0c             	pushl  0xc(%ebp)
  8019ed:	50                   	push   %eax
  8019ee:	e8 3f 01 00 00       	call   801b32 <nsipc_shutdown>
  8019f3:	83 c4 10             	add    $0x10,%esp
}
  8019f6:	c9                   	leave  
  8019f7:	c3                   	ret    

008019f8 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019f8:	55                   	push   %ebp
  8019f9:	89 e5                	mov    %esp,%ebp
  8019fb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801a01:	e8 d0 fe ff ff       	call   8018d6 <fd2sockid>
  801a06:	85 c0                	test   %eax,%eax
  801a08:	78 12                	js     801a1c <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801a0a:	83 ec 04             	sub    $0x4,%esp
  801a0d:	ff 75 10             	pushl  0x10(%ebp)
  801a10:	ff 75 0c             	pushl  0xc(%ebp)
  801a13:	50                   	push   %eax
  801a14:	e8 55 01 00 00       	call   801b6e <nsipc_connect>
  801a19:	83 c4 10             	add    $0x10,%esp
}
  801a1c:	c9                   	leave  
  801a1d:	c3                   	ret    

00801a1e <listen>:

int
listen(int s, int backlog)
{
  801a1e:	55                   	push   %ebp
  801a1f:	89 e5                	mov    %esp,%ebp
  801a21:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a24:	8b 45 08             	mov    0x8(%ebp),%eax
  801a27:	e8 aa fe ff ff       	call   8018d6 <fd2sockid>
  801a2c:	85 c0                	test   %eax,%eax
  801a2e:	78 0f                	js     801a3f <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801a30:	83 ec 08             	sub    $0x8,%esp
  801a33:	ff 75 0c             	pushl  0xc(%ebp)
  801a36:	50                   	push   %eax
  801a37:	e8 67 01 00 00       	call   801ba3 <nsipc_listen>
  801a3c:	83 c4 10             	add    $0x10,%esp
}
  801a3f:	c9                   	leave  
  801a40:	c3                   	ret    

00801a41 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801a41:	55                   	push   %ebp
  801a42:	89 e5                	mov    %esp,%ebp
  801a44:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a47:	ff 75 10             	pushl  0x10(%ebp)
  801a4a:	ff 75 0c             	pushl  0xc(%ebp)
  801a4d:	ff 75 08             	pushl  0x8(%ebp)
  801a50:	e8 3a 02 00 00       	call   801c8f <nsipc_socket>
  801a55:	83 c4 10             	add    $0x10,%esp
  801a58:	85 c0                	test   %eax,%eax
  801a5a:	78 05                	js     801a61 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801a5c:	e8 a5 fe ff ff       	call   801906 <alloc_sockfd>
}
  801a61:	c9                   	leave  
  801a62:	c3                   	ret    

00801a63 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801a63:	55                   	push   %ebp
  801a64:	89 e5                	mov    %esp,%ebp
  801a66:	53                   	push   %ebx
  801a67:	83 ec 04             	sub    $0x4,%esp
  801a6a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801a6c:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801a73:	75 12                	jne    801a87 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801a75:	83 ec 0c             	sub    $0xc,%esp
  801a78:	6a 02                	push   $0x2
  801a7a:	e8 85 08 00 00       	call   802304 <ipc_find_env>
  801a7f:	a3 04 40 80 00       	mov    %eax,0x804004
  801a84:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801a87:	6a 07                	push   $0x7
  801a89:	68 00 60 80 00       	push   $0x806000
  801a8e:	53                   	push   %ebx
  801a8f:	ff 35 04 40 80 00    	pushl  0x804004
  801a95:	e8 16 08 00 00       	call   8022b0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801a9a:	83 c4 0c             	add    $0xc,%esp
  801a9d:	6a 00                	push   $0x0
  801a9f:	6a 00                	push   $0x0
  801aa1:	6a 00                	push   $0x0
  801aa3:	e8 a1 07 00 00       	call   802249 <ipc_recv>
}
  801aa8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aab:	c9                   	leave  
  801aac:	c3                   	ret    

00801aad <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801aad:	55                   	push   %ebp
  801aae:	89 e5                	mov    %esp,%ebp
  801ab0:	56                   	push   %esi
  801ab1:	53                   	push   %ebx
  801ab2:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801ab5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801abd:	8b 06                	mov    (%esi),%eax
  801abf:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ac4:	b8 01 00 00 00       	mov    $0x1,%eax
  801ac9:	e8 95 ff ff ff       	call   801a63 <nsipc>
  801ace:	89 c3                	mov    %eax,%ebx
  801ad0:	85 c0                	test   %eax,%eax
  801ad2:	78 20                	js     801af4 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801ad4:	83 ec 04             	sub    $0x4,%esp
  801ad7:	ff 35 10 60 80 00    	pushl  0x806010
  801add:	68 00 60 80 00       	push   $0x806000
  801ae2:	ff 75 0c             	pushl  0xc(%ebp)
  801ae5:	e8 d5 ed ff ff       	call   8008bf <memmove>
		*addrlen = ret->ret_addrlen;
  801aea:	a1 10 60 80 00       	mov    0x806010,%eax
  801aef:	89 06                	mov    %eax,(%esi)
  801af1:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801af4:	89 d8                	mov    %ebx,%eax
  801af6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af9:	5b                   	pop    %ebx
  801afa:	5e                   	pop    %esi
  801afb:	5d                   	pop    %ebp
  801afc:	c3                   	ret    

00801afd <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801afd:	55                   	push   %ebp
  801afe:	89 e5                	mov    %esp,%ebp
  801b00:	53                   	push   %ebx
  801b01:	83 ec 08             	sub    $0x8,%esp
  801b04:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801b07:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0a:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801b0f:	53                   	push   %ebx
  801b10:	ff 75 0c             	pushl  0xc(%ebp)
  801b13:	68 04 60 80 00       	push   $0x806004
  801b18:	e8 a2 ed ff ff       	call   8008bf <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b1d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801b23:	b8 02 00 00 00       	mov    $0x2,%eax
  801b28:	e8 36 ff ff ff       	call   801a63 <nsipc>
}
  801b2d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b30:	c9                   	leave  
  801b31:	c3                   	ret    

00801b32 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b32:	55                   	push   %ebp
  801b33:	89 e5                	mov    %esp,%ebp
  801b35:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b38:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801b40:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b43:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801b48:	b8 03 00 00 00       	mov    $0x3,%eax
  801b4d:	e8 11 ff ff ff       	call   801a63 <nsipc>
}
  801b52:	c9                   	leave  
  801b53:	c3                   	ret    

00801b54 <nsipc_close>:

int
nsipc_close(int s)
{
  801b54:	55                   	push   %ebp
  801b55:	89 e5                	mov    %esp,%ebp
  801b57:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5d:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801b62:	b8 04 00 00 00       	mov    $0x4,%eax
  801b67:	e8 f7 fe ff ff       	call   801a63 <nsipc>
}
  801b6c:	c9                   	leave  
  801b6d:	c3                   	ret    

00801b6e <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	53                   	push   %ebx
  801b72:	83 ec 08             	sub    $0x8,%esp
  801b75:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801b78:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7b:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801b80:	53                   	push   %ebx
  801b81:	ff 75 0c             	pushl  0xc(%ebp)
  801b84:	68 04 60 80 00       	push   $0x806004
  801b89:	e8 31 ed ff ff       	call   8008bf <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801b8e:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801b94:	b8 05 00 00 00       	mov    $0x5,%eax
  801b99:	e8 c5 fe ff ff       	call   801a63 <nsipc>
}
  801b9e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ba1:	c9                   	leave  
  801ba2:	c3                   	ret    

00801ba3 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801ba3:	55                   	push   %ebp
  801ba4:	89 e5                	mov    %esp,%ebp
  801ba6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bac:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801bb1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bb4:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801bb9:	b8 06 00 00 00       	mov    $0x6,%eax
  801bbe:	e8 a0 fe ff ff       	call   801a63 <nsipc>
}
  801bc3:	c9                   	leave  
  801bc4:	c3                   	ret    

00801bc5 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801bc5:	55                   	push   %ebp
  801bc6:	89 e5                	mov    %esp,%ebp
  801bc8:	56                   	push   %esi
  801bc9:	53                   	push   %ebx
  801bca:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801bcd:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801bd5:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801bdb:	8b 45 14             	mov    0x14(%ebp),%eax
  801bde:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801be3:	b8 07 00 00 00       	mov    $0x7,%eax
  801be8:	e8 76 fe ff ff       	call   801a63 <nsipc>
  801bed:	89 c3                	mov    %eax,%ebx
  801bef:	85 c0                	test   %eax,%eax
  801bf1:	78 35                	js     801c28 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801bf3:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801bf8:	7f 04                	jg     801bfe <nsipc_recv+0x39>
  801bfa:	39 c6                	cmp    %eax,%esi
  801bfc:	7d 16                	jge    801c14 <nsipc_recv+0x4f>
  801bfe:	68 73 2b 80 00       	push   $0x802b73
  801c03:	68 3b 2b 80 00       	push   $0x802b3b
  801c08:	6a 62                	push   $0x62
  801c0a:	68 88 2b 80 00       	push   $0x802b88
  801c0f:	e8 84 05 00 00       	call   802198 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801c14:	83 ec 04             	sub    $0x4,%esp
  801c17:	50                   	push   %eax
  801c18:	68 00 60 80 00       	push   $0x806000
  801c1d:	ff 75 0c             	pushl  0xc(%ebp)
  801c20:	e8 9a ec ff ff       	call   8008bf <memmove>
  801c25:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801c28:	89 d8                	mov    %ebx,%eax
  801c2a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c2d:	5b                   	pop    %ebx
  801c2e:	5e                   	pop    %esi
  801c2f:	5d                   	pop    %ebp
  801c30:	c3                   	ret    

00801c31 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c31:	55                   	push   %ebp
  801c32:	89 e5                	mov    %esp,%ebp
  801c34:	53                   	push   %ebx
  801c35:	83 ec 04             	sub    $0x4,%esp
  801c38:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3e:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801c43:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c49:	7e 16                	jle    801c61 <nsipc_send+0x30>
  801c4b:	68 94 2b 80 00       	push   $0x802b94
  801c50:	68 3b 2b 80 00       	push   $0x802b3b
  801c55:	6a 6d                	push   $0x6d
  801c57:	68 88 2b 80 00       	push   $0x802b88
  801c5c:	e8 37 05 00 00       	call   802198 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c61:	83 ec 04             	sub    $0x4,%esp
  801c64:	53                   	push   %ebx
  801c65:	ff 75 0c             	pushl  0xc(%ebp)
  801c68:	68 0c 60 80 00       	push   $0x80600c
  801c6d:	e8 4d ec ff ff       	call   8008bf <memmove>
	nsipcbuf.send.req_size = size;
  801c72:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801c78:	8b 45 14             	mov    0x14(%ebp),%eax
  801c7b:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801c80:	b8 08 00 00 00       	mov    $0x8,%eax
  801c85:	e8 d9 fd ff ff       	call   801a63 <nsipc>
}
  801c8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c8d:	c9                   	leave  
  801c8e:	c3                   	ret    

00801c8f <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801c95:	8b 45 08             	mov    0x8(%ebp),%eax
  801c98:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801c9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ca0:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801ca5:	8b 45 10             	mov    0x10(%ebp),%eax
  801ca8:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801cad:	b8 09 00 00 00       	mov    $0x9,%eax
  801cb2:	e8 ac fd ff ff       	call   801a63 <nsipc>
}
  801cb7:	c9                   	leave  
  801cb8:	c3                   	ret    

00801cb9 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801cb9:	55                   	push   %ebp
  801cba:	89 e5                	mov    %esp,%ebp
  801cbc:	56                   	push   %esi
  801cbd:	53                   	push   %ebx
  801cbe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801cc1:	83 ec 0c             	sub    $0xc,%esp
  801cc4:	ff 75 08             	pushl  0x8(%ebp)
  801cc7:	e8 98 f3 ff ff       	call   801064 <fd2data>
  801ccc:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801cce:	83 c4 08             	add    $0x8,%esp
  801cd1:	68 a0 2b 80 00       	push   $0x802ba0
  801cd6:	53                   	push   %ebx
  801cd7:	e8 51 ea ff ff       	call   80072d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801cdc:	8b 46 04             	mov    0x4(%esi),%eax
  801cdf:	2b 06                	sub    (%esi),%eax
  801ce1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ce7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cee:	00 00 00 
	stat->st_dev = &devpipe;
  801cf1:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801cf8:	30 80 00 
	return 0;
}
  801cfb:	b8 00 00 00 00       	mov    $0x0,%eax
  801d00:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d03:	5b                   	pop    %ebx
  801d04:	5e                   	pop    %esi
  801d05:	5d                   	pop    %ebp
  801d06:	c3                   	ret    

00801d07 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d07:	55                   	push   %ebp
  801d08:	89 e5                	mov    %esp,%ebp
  801d0a:	53                   	push   %ebx
  801d0b:	83 ec 0c             	sub    $0xc,%esp
  801d0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d11:	53                   	push   %ebx
  801d12:	6a 00                	push   $0x0
  801d14:	e8 9c ee ff ff       	call   800bb5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d19:	89 1c 24             	mov    %ebx,(%esp)
  801d1c:	e8 43 f3 ff ff       	call   801064 <fd2data>
  801d21:	83 c4 08             	add    $0x8,%esp
  801d24:	50                   	push   %eax
  801d25:	6a 00                	push   $0x0
  801d27:	e8 89 ee ff ff       	call   800bb5 <sys_page_unmap>
}
  801d2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d2f:	c9                   	leave  
  801d30:	c3                   	ret    

00801d31 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d31:	55                   	push   %ebp
  801d32:	89 e5                	mov    %esp,%ebp
  801d34:	57                   	push   %edi
  801d35:	56                   	push   %esi
  801d36:	53                   	push   %ebx
  801d37:	83 ec 1c             	sub    $0x1c,%esp
  801d3a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d3d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d3f:	a1 08 40 80 00       	mov    0x804008,%eax
  801d44:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d47:	83 ec 0c             	sub    $0xc,%esp
  801d4a:	ff 75 e0             	pushl  -0x20(%ebp)
  801d4d:	e8 eb 05 00 00       	call   80233d <pageref>
  801d52:	89 c3                	mov    %eax,%ebx
  801d54:	89 3c 24             	mov    %edi,(%esp)
  801d57:	e8 e1 05 00 00       	call   80233d <pageref>
  801d5c:	83 c4 10             	add    $0x10,%esp
  801d5f:	39 c3                	cmp    %eax,%ebx
  801d61:	0f 94 c1             	sete   %cl
  801d64:	0f b6 c9             	movzbl %cl,%ecx
  801d67:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d6a:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801d70:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d73:	39 ce                	cmp    %ecx,%esi
  801d75:	74 1b                	je     801d92 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801d77:	39 c3                	cmp    %eax,%ebx
  801d79:	75 c4                	jne    801d3f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d7b:	8b 42 58             	mov    0x58(%edx),%eax
  801d7e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d81:	50                   	push   %eax
  801d82:	56                   	push   %esi
  801d83:	68 a7 2b 80 00       	push   $0x802ba7
  801d88:	e8 1b e4 ff ff       	call   8001a8 <cprintf>
  801d8d:	83 c4 10             	add    $0x10,%esp
  801d90:	eb ad                	jmp    801d3f <_pipeisclosed+0xe>
	}
}
  801d92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d98:	5b                   	pop    %ebx
  801d99:	5e                   	pop    %esi
  801d9a:	5f                   	pop    %edi
  801d9b:	5d                   	pop    %ebp
  801d9c:	c3                   	ret    

00801d9d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d9d:	55                   	push   %ebp
  801d9e:	89 e5                	mov    %esp,%ebp
  801da0:	57                   	push   %edi
  801da1:	56                   	push   %esi
  801da2:	53                   	push   %ebx
  801da3:	83 ec 28             	sub    $0x28,%esp
  801da6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801da9:	56                   	push   %esi
  801daa:	e8 b5 f2 ff ff       	call   801064 <fd2data>
  801daf:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801db1:	83 c4 10             	add    $0x10,%esp
  801db4:	bf 00 00 00 00       	mov    $0x0,%edi
  801db9:	eb 4b                	jmp    801e06 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801dbb:	89 da                	mov    %ebx,%edx
  801dbd:	89 f0                	mov    %esi,%eax
  801dbf:	e8 6d ff ff ff       	call   801d31 <_pipeisclosed>
  801dc4:	85 c0                	test   %eax,%eax
  801dc6:	75 48                	jne    801e10 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801dc8:	e8 44 ed ff ff       	call   800b11 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801dcd:	8b 43 04             	mov    0x4(%ebx),%eax
  801dd0:	8b 0b                	mov    (%ebx),%ecx
  801dd2:	8d 51 20             	lea    0x20(%ecx),%edx
  801dd5:	39 d0                	cmp    %edx,%eax
  801dd7:	73 e2                	jae    801dbb <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801dd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ddc:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801de0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801de3:	89 c2                	mov    %eax,%edx
  801de5:	c1 fa 1f             	sar    $0x1f,%edx
  801de8:	89 d1                	mov    %edx,%ecx
  801dea:	c1 e9 1b             	shr    $0x1b,%ecx
  801ded:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801df0:	83 e2 1f             	and    $0x1f,%edx
  801df3:	29 ca                	sub    %ecx,%edx
  801df5:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801df9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801dfd:	83 c0 01             	add    $0x1,%eax
  801e00:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e03:	83 c7 01             	add    $0x1,%edi
  801e06:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e09:	75 c2                	jne    801dcd <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e0b:	8b 45 10             	mov    0x10(%ebp),%eax
  801e0e:	eb 05                	jmp    801e15 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e10:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e18:	5b                   	pop    %ebx
  801e19:	5e                   	pop    %esi
  801e1a:	5f                   	pop    %edi
  801e1b:	5d                   	pop    %ebp
  801e1c:	c3                   	ret    

00801e1d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e1d:	55                   	push   %ebp
  801e1e:	89 e5                	mov    %esp,%ebp
  801e20:	57                   	push   %edi
  801e21:	56                   	push   %esi
  801e22:	53                   	push   %ebx
  801e23:	83 ec 18             	sub    $0x18,%esp
  801e26:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e29:	57                   	push   %edi
  801e2a:	e8 35 f2 ff ff       	call   801064 <fd2data>
  801e2f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e31:	83 c4 10             	add    $0x10,%esp
  801e34:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e39:	eb 3d                	jmp    801e78 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e3b:	85 db                	test   %ebx,%ebx
  801e3d:	74 04                	je     801e43 <devpipe_read+0x26>
				return i;
  801e3f:	89 d8                	mov    %ebx,%eax
  801e41:	eb 44                	jmp    801e87 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e43:	89 f2                	mov    %esi,%edx
  801e45:	89 f8                	mov    %edi,%eax
  801e47:	e8 e5 fe ff ff       	call   801d31 <_pipeisclosed>
  801e4c:	85 c0                	test   %eax,%eax
  801e4e:	75 32                	jne    801e82 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e50:	e8 bc ec ff ff       	call   800b11 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e55:	8b 06                	mov    (%esi),%eax
  801e57:	3b 46 04             	cmp    0x4(%esi),%eax
  801e5a:	74 df                	je     801e3b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e5c:	99                   	cltd   
  801e5d:	c1 ea 1b             	shr    $0x1b,%edx
  801e60:	01 d0                	add    %edx,%eax
  801e62:	83 e0 1f             	and    $0x1f,%eax
  801e65:	29 d0                	sub    %edx,%eax
  801e67:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e6f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e72:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e75:	83 c3 01             	add    $0x1,%ebx
  801e78:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e7b:	75 d8                	jne    801e55 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e7d:	8b 45 10             	mov    0x10(%ebp),%eax
  801e80:	eb 05                	jmp    801e87 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e82:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e8a:	5b                   	pop    %ebx
  801e8b:	5e                   	pop    %esi
  801e8c:	5f                   	pop    %edi
  801e8d:	5d                   	pop    %ebp
  801e8e:	c3                   	ret    

00801e8f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e8f:	55                   	push   %ebp
  801e90:	89 e5                	mov    %esp,%ebp
  801e92:	56                   	push   %esi
  801e93:	53                   	push   %ebx
  801e94:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e9a:	50                   	push   %eax
  801e9b:	e8 db f1 ff ff       	call   80107b <fd_alloc>
  801ea0:	83 c4 10             	add    $0x10,%esp
  801ea3:	89 c2                	mov    %eax,%edx
  801ea5:	85 c0                	test   %eax,%eax
  801ea7:	0f 88 2c 01 00 00    	js     801fd9 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ead:	83 ec 04             	sub    $0x4,%esp
  801eb0:	68 07 04 00 00       	push   $0x407
  801eb5:	ff 75 f4             	pushl  -0xc(%ebp)
  801eb8:	6a 00                	push   $0x0
  801eba:	e8 71 ec ff ff       	call   800b30 <sys_page_alloc>
  801ebf:	83 c4 10             	add    $0x10,%esp
  801ec2:	89 c2                	mov    %eax,%edx
  801ec4:	85 c0                	test   %eax,%eax
  801ec6:	0f 88 0d 01 00 00    	js     801fd9 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ecc:	83 ec 0c             	sub    $0xc,%esp
  801ecf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ed2:	50                   	push   %eax
  801ed3:	e8 a3 f1 ff ff       	call   80107b <fd_alloc>
  801ed8:	89 c3                	mov    %eax,%ebx
  801eda:	83 c4 10             	add    $0x10,%esp
  801edd:	85 c0                	test   %eax,%eax
  801edf:	0f 88 e2 00 00 00    	js     801fc7 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ee5:	83 ec 04             	sub    $0x4,%esp
  801ee8:	68 07 04 00 00       	push   $0x407
  801eed:	ff 75 f0             	pushl  -0x10(%ebp)
  801ef0:	6a 00                	push   $0x0
  801ef2:	e8 39 ec ff ff       	call   800b30 <sys_page_alloc>
  801ef7:	89 c3                	mov    %eax,%ebx
  801ef9:	83 c4 10             	add    $0x10,%esp
  801efc:	85 c0                	test   %eax,%eax
  801efe:	0f 88 c3 00 00 00    	js     801fc7 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f04:	83 ec 0c             	sub    $0xc,%esp
  801f07:	ff 75 f4             	pushl  -0xc(%ebp)
  801f0a:	e8 55 f1 ff ff       	call   801064 <fd2data>
  801f0f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f11:	83 c4 0c             	add    $0xc,%esp
  801f14:	68 07 04 00 00       	push   $0x407
  801f19:	50                   	push   %eax
  801f1a:	6a 00                	push   $0x0
  801f1c:	e8 0f ec ff ff       	call   800b30 <sys_page_alloc>
  801f21:	89 c3                	mov    %eax,%ebx
  801f23:	83 c4 10             	add    $0x10,%esp
  801f26:	85 c0                	test   %eax,%eax
  801f28:	0f 88 89 00 00 00    	js     801fb7 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f2e:	83 ec 0c             	sub    $0xc,%esp
  801f31:	ff 75 f0             	pushl  -0x10(%ebp)
  801f34:	e8 2b f1 ff ff       	call   801064 <fd2data>
  801f39:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f40:	50                   	push   %eax
  801f41:	6a 00                	push   $0x0
  801f43:	56                   	push   %esi
  801f44:	6a 00                	push   $0x0
  801f46:	e8 28 ec ff ff       	call   800b73 <sys_page_map>
  801f4b:	89 c3                	mov    %eax,%ebx
  801f4d:	83 c4 20             	add    $0x20,%esp
  801f50:	85 c0                	test   %eax,%eax
  801f52:	78 55                	js     801fa9 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f54:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f5d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f62:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f69:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f72:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f74:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f77:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f7e:	83 ec 0c             	sub    $0xc,%esp
  801f81:	ff 75 f4             	pushl  -0xc(%ebp)
  801f84:	e8 cb f0 ff ff       	call   801054 <fd2num>
  801f89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f8c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f8e:	83 c4 04             	add    $0x4,%esp
  801f91:	ff 75 f0             	pushl  -0x10(%ebp)
  801f94:	e8 bb f0 ff ff       	call   801054 <fd2num>
  801f99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f9c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f9f:	83 c4 10             	add    $0x10,%esp
  801fa2:	ba 00 00 00 00       	mov    $0x0,%edx
  801fa7:	eb 30                	jmp    801fd9 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801fa9:	83 ec 08             	sub    $0x8,%esp
  801fac:	56                   	push   %esi
  801fad:	6a 00                	push   $0x0
  801faf:	e8 01 ec ff ff       	call   800bb5 <sys_page_unmap>
  801fb4:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801fb7:	83 ec 08             	sub    $0x8,%esp
  801fba:	ff 75 f0             	pushl  -0x10(%ebp)
  801fbd:	6a 00                	push   $0x0
  801fbf:	e8 f1 eb ff ff       	call   800bb5 <sys_page_unmap>
  801fc4:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801fc7:	83 ec 08             	sub    $0x8,%esp
  801fca:	ff 75 f4             	pushl  -0xc(%ebp)
  801fcd:	6a 00                	push   $0x0
  801fcf:	e8 e1 eb ff ff       	call   800bb5 <sys_page_unmap>
  801fd4:	83 c4 10             	add    $0x10,%esp
  801fd7:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801fd9:	89 d0                	mov    %edx,%eax
  801fdb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fde:	5b                   	pop    %ebx
  801fdf:	5e                   	pop    %esi
  801fe0:	5d                   	pop    %ebp
  801fe1:	c3                   	ret    

00801fe2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801fe2:	55                   	push   %ebp
  801fe3:	89 e5                	mov    %esp,%ebp
  801fe5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fe8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801feb:	50                   	push   %eax
  801fec:	ff 75 08             	pushl  0x8(%ebp)
  801fef:	e8 d6 f0 ff ff       	call   8010ca <fd_lookup>
  801ff4:	83 c4 10             	add    $0x10,%esp
  801ff7:	85 c0                	test   %eax,%eax
  801ff9:	78 18                	js     802013 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ffb:	83 ec 0c             	sub    $0xc,%esp
  801ffe:	ff 75 f4             	pushl  -0xc(%ebp)
  802001:	e8 5e f0 ff ff       	call   801064 <fd2data>
	return _pipeisclosed(fd, p);
  802006:	89 c2                	mov    %eax,%edx
  802008:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200b:	e8 21 fd ff ff       	call   801d31 <_pipeisclosed>
  802010:	83 c4 10             	add    $0x10,%esp
}
  802013:	c9                   	leave  
  802014:	c3                   	ret    

00802015 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802015:	55                   	push   %ebp
  802016:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802018:	b8 00 00 00 00       	mov    $0x0,%eax
  80201d:	5d                   	pop    %ebp
  80201e:	c3                   	ret    

0080201f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80201f:	55                   	push   %ebp
  802020:	89 e5                	mov    %esp,%ebp
  802022:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802025:	68 bf 2b 80 00       	push   $0x802bbf
  80202a:	ff 75 0c             	pushl  0xc(%ebp)
  80202d:	e8 fb e6 ff ff       	call   80072d <strcpy>
	return 0;
}
  802032:	b8 00 00 00 00       	mov    $0x0,%eax
  802037:	c9                   	leave  
  802038:	c3                   	ret    

00802039 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802039:	55                   	push   %ebp
  80203a:	89 e5                	mov    %esp,%ebp
  80203c:	57                   	push   %edi
  80203d:	56                   	push   %esi
  80203e:	53                   	push   %ebx
  80203f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802045:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80204a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802050:	eb 2d                	jmp    80207f <devcons_write+0x46>
		m = n - tot;
  802052:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802055:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802057:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80205a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80205f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802062:	83 ec 04             	sub    $0x4,%esp
  802065:	53                   	push   %ebx
  802066:	03 45 0c             	add    0xc(%ebp),%eax
  802069:	50                   	push   %eax
  80206a:	57                   	push   %edi
  80206b:	e8 4f e8 ff ff       	call   8008bf <memmove>
		sys_cputs(buf, m);
  802070:	83 c4 08             	add    $0x8,%esp
  802073:	53                   	push   %ebx
  802074:	57                   	push   %edi
  802075:	e8 fa e9 ff ff       	call   800a74 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80207a:	01 de                	add    %ebx,%esi
  80207c:	83 c4 10             	add    $0x10,%esp
  80207f:	89 f0                	mov    %esi,%eax
  802081:	3b 75 10             	cmp    0x10(%ebp),%esi
  802084:	72 cc                	jb     802052 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802086:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802089:	5b                   	pop    %ebx
  80208a:	5e                   	pop    %esi
  80208b:	5f                   	pop    %edi
  80208c:	5d                   	pop    %ebp
  80208d:	c3                   	ret    

0080208e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80208e:	55                   	push   %ebp
  80208f:	89 e5                	mov    %esp,%ebp
  802091:	83 ec 08             	sub    $0x8,%esp
  802094:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802099:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80209d:	74 2a                	je     8020c9 <devcons_read+0x3b>
  80209f:	eb 05                	jmp    8020a6 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8020a1:	e8 6b ea ff ff       	call   800b11 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8020a6:	e8 e7 e9 ff ff       	call   800a92 <sys_cgetc>
  8020ab:	85 c0                	test   %eax,%eax
  8020ad:	74 f2                	je     8020a1 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8020af:	85 c0                	test   %eax,%eax
  8020b1:	78 16                	js     8020c9 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8020b3:	83 f8 04             	cmp    $0x4,%eax
  8020b6:	74 0c                	je     8020c4 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8020b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020bb:	88 02                	mov    %al,(%edx)
	return 1;
  8020bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8020c2:	eb 05                	jmp    8020c9 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020c4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020c9:	c9                   	leave  
  8020ca:	c3                   	ret    

008020cb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020cb:	55                   	push   %ebp
  8020cc:	89 e5                	mov    %esp,%ebp
  8020ce:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8020d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020d7:	6a 01                	push   $0x1
  8020d9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020dc:	50                   	push   %eax
  8020dd:	e8 92 e9 ff ff       	call   800a74 <sys_cputs>
}
  8020e2:	83 c4 10             	add    $0x10,%esp
  8020e5:	c9                   	leave  
  8020e6:	c3                   	ret    

008020e7 <getchar>:

int
getchar(void)
{
  8020e7:	55                   	push   %ebp
  8020e8:	89 e5                	mov    %esp,%ebp
  8020ea:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020ed:	6a 01                	push   $0x1
  8020ef:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020f2:	50                   	push   %eax
  8020f3:	6a 00                	push   $0x0
  8020f5:	e8 36 f2 ff ff       	call   801330 <read>
	if (r < 0)
  8020fa:	83 c4 10             	add    $0x10,%esp
  8020fd:	85 c0                	test   %eax,%eax
  8020ff:	78 0f                	js     802110 <getchar+0x29>
		return r;
	if (r < 1)
  802101:	85 c0                	test   %eax,%eax
  802103:	7e 06                	jle    80210b <getchar+0x24>
		return -E_EOF;
	return c;
  802105:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802109:	eb 05                	jmp    802110 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80210b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802110:	c9                   	leave  
  802111:	c3                   	ret    

00802112 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802112:	55                   	push   %ebp
  802113:	89 e5                	mov    %esp,%ebp
  802115:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802118:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80211b:	50                   	push   %eax
  80211c:	ff 75 08             	pushl  0x8(%ebp)
  80211f:	e8 a6 ef ff ff       	call   8010ca <fd_lookup>
  802124:	83 c4 10             	add    $0x10,%esp
  802127:	85 c0                	test   %eax,%eax
  802129:	78 11                	js     80213c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80212b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80212e:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802134:	39 10                	cmp    %edx,(%eax)
  802136:	0f 94 c0             	sete   %al
  802139:	0f b6 c0             	movzbl %al,%eax
}
  80213c:	c9                   	leave  
  80213d:	c3                   	ret    

0080213e <opencons>:

int
opencons(void)
{
  80213e:	55                   	push   %ebp
  80213f:	89 e5                	mov    %esp,%ebp
  802141:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802144:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802147:	50                   	push   %eax
  802148:	e8 2e ef ff ff       	call   80107b <fd_alloc>
  80214d:	83 c4 10             	add    $0x10,%esp
		return r;
  802150:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802152:	85 c0                	test   %eax,%eax
  802154:	78 3e                	js     802194 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802156:	83 ec 04             	sub    $0x4,%esp
  802159:	68 07 04 00 00       	push   $0x407
  80215e:	ff 75 f4             	pushl  -0xc(%ebp)
  802161:	6a 00                	push   $0x0
  802163:	e8 c8 e9 ff ff       	call   800b30 <sys_page_alloc>
  802168:	83 c4 10             	add    $0x10,%esp
		return r;
  80216b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80216d:	85 c0                	test   %eax,%eax
  80216f:	78 23                	js     802194 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802171:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802177:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80217a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80217c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80217f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802186:	83 ec 0c             	sub    $0xc,%esp
  802189:	50                   	push   %eax
  80218a:	e8 c5 ee ff ff       	call   801054 <fd2num>
  80218f:	89 c2                	mov    %eax,%edx
  802191:	83 c4 10             	add    $0x10,%esp
}
  802194:	89 d0                	mov    %edx,%eax
  802196:	c9                   	leave  
  802197:	c3                   	ret    

00802198 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802198:	55                   	push   %ebp
  802199:	89 e5                	mov    %esp,%ebp
  80219b:	56                   	push   %esi
  80219c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80219d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8021a0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8021a6:	e8 47 e9 ff ff       	call   800af2 <sys_getenvid>
  8021ab:	83 ec 0c             	sub    $0xc,%esp
  8021ae:	ff 75 0c             	pushl  0xc(%ebp)
  8021b1:	ff 75 08             	pushl  0x8(%ebp)
  8021b4:	56                   	push   %esi
  8021b5:	50                   	push   %eax
  8021b6:	68 cc 2b 80 00       	push   $0x802bcc
  8021bb:	e8 e8 df ff ff       	call   8001a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8021c0:	83 c4 18             	add    $0x18,%esp
  8021c3:	53                   	push   %ebx
  8021c4:	ff 75 10             	pushl  0x10(%ebp)
  8021c7:	e8 8b df ff ff       	call   800157 <vcprintf>
	cprintf("\n");
  8021cc:	c7 04 24 b4 26 80 00 	movl   $0x8026b4,(%esp)
  8021d3:	e8 d0 df ff ff       	call   8001a8 <cprintf>
  8021d8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8021db:	cc                   	int3   
  8021dc:	eb fd                	jmp    8021db <_panic+0x43>

008021de <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8021de:	55                   	push   %ebp
  8021df:	89 e5                	mov    %esp,%ebp
  8021e1:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8021e4:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8021eb:	75 2e                	jne    80221b <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8021ed:	e8 00 e9 ff ff       	call   800af2 <sys_getenvid>
  8021f2:	83 ec 04             	sub    $0x4,%esp
  8021f5:	68 07 0e 00 00       	push   $0xe07
  8021fa:	68 00 f0 bf ee       	push   $0xeebff000
  8021ff:	50                   	push   %eax
  802200:	e8 2b e9 ff ff       	call   800b30 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802205:	e8 e8 e8 ff ff       	call   800af2 <sys_getenvid>
  80220a:	83 c4 08             	add    $0x8,%esp
  80220d:	68 25 22 80 00       	push   $0x802225
  802212:	50                   	push   %eax
  802213:	e8 63 ea ff ff       	call   800c7b <sys_env_set_pgfault_upcall>
  802218:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80221b:	8b 45 08             	mov    0x8(%ebp),%eax
  80221e:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802223:	c9                   	leave  
  802224:	c3                   	ret    

00802225 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802225:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802226:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80222b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80222d:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  802230:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  802234:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  802238:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  80223b:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  80223e:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  80223f:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  802242:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  802243:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  802244:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802248:	c3                   	ret    

00802249 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802249:	55                   	push   %ebp
  80224a:	89 e5                	mov    %esp,%ebp
  80224c:	56                   	push   %esi
  80224d:	53                   	push   %ebx
  80224e:	8b 75 08             	mov    0x8(%ebp),%esi
  802251:	8b 45 0c             	mov    0xc(%ebp),%eax
  802254:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  802257:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802259:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80225e:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  802261:	83 ec 0c             	sub    $0xc,%esp
  802264:	50                   	push   %eax
  802265:	e8 76 ea ff ff       	call   800ce0 <sys_ipc_recv>

	if (from_env_store != NULL)
  80226a:	83 c4 10             	add    $0x10,%esp
  80226d:	85 f6                	test   %esi,%esi
  80226f:	74 14                	je     802285 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  802271:	ba 00 00 00 00       	mov    $0x0,%edx
  802276:	85 c0                	test   %eax,%eax
  802278:	78 09                	js     802283 <ipc_recv+0x3a>
  80227a:	8b 15 08 40 80 00    	mov    0x804008,%edx
  802280:	8b 52 74             	mov    0x74(%edx),%edx
  802283:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802285:	85 db                	test   %ebx,%ebx
  802287:	74 14                	je     80229d <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802289:	ba 00 00 00 00       	mov    $0x0,%edx
  80228e:	85 c0                	test   %eax,%eax
  802290:	78 09                	js     80229b <ipc_recv+0x52>
  802292:	8b 15 08 40 80 00    	mov    0x804008,%edx
  802298:	8b 52 78             	mov    0x78(%edx),%edx
  80229b:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  80229d:	85 c0                	test   %eax,%eax
  80229f:	78 08                	js     8022a9 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8022a1:	a1 08 40 80 00       	mov    0x804008,%eax
  8022a6:	8b 40 70             	mov    0x70(%eax),%eax
}
  8022a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022ac:	5b                   	pop    %ebx
  8022ad:	5e                   	pop    %esi
  8022ae:	5d                   	pop    %ebp
  8022af:	c3                   	ret    

008022b0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022b0:	55                   	push   %ebp
  8022b1:	89 e5                	mov    %esp,%ebp
  8022b3:	57                   	push   %edi
  8022b4:	56                   	push   %esi
  8022b5:	53                   	push   %ebx
  8022b6:	83 ec 0c             	sub    $0xc,%esp
  8022b9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8022c2:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8022c4:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8022c9:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  8022cc:	ff 75 14             	pushl  0x14(%ebp)
  8022cf:	53                   	push   %ebx
  8022d0:	56                   	push   %esi
  8022d1:	57                   	push   %edi
  8022d2:	e8 e6 e9 ff ff       	call   800cbd <sys_ipc_try_send>

		if (err < 0) {
  8022d7:	83 c4 10             	add    $0x10,%esp
  8022da:	85 c0                	test   %eax,%eax
  8022dc:	79 1e                	jns    8022fc <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8022de:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022e1:	75 07                	jne    8022ea <ipc_send+0x3a>
				sys_yield();
  8022e3:	e8 29 e8 ff ff       	call   800b11 <sys_yield>
  8022e8:	eb e2                	jmp    8022cc <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8022ea:	50                   	push   %eax
  8022eb:	68 f0 2b 80 00       	push   $0x802bf0
  8022f0:	6a 49                	push   $0x49
  8022f2:	68 fd 2b 80 00       	push   $0x802bfd
  8022f7:	e8 9c fe ff ff       	call   802198 <_panic>
		}

	} while (err < 0);

}
  8022fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022ff:	5b                   	pop    %ebx
  802300:	5e                   	pop    %esi
  802301:	5f                   	pop    %edi
  802302:	5d                   	pop    %ebp
  802303:	c3                   	ret    

00802304 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802304:	55                   	push   %ebp
  802305:	89 e5                	mov    %esp,%ebp
  802307:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80230a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80230f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802312:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802318:	8b 52 50             	mov    0x50(%edx),%edx
  80231b:	39 ca                	cmp    %ecx,%edx
  80231d:	75 0d                	jne    80232c <ipc_find_env+0x28>
			return envs[i].env_id;
  80231f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802322:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802327:	8b 40 48             	mov    0x48(%eax),%eax
  80232a:	eb 0f                	jmp    80233b <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80232c:	83 c0 01             	add    $0x1,%eax
  80232f:	3d 00 04 00 00       	cmp    $0x400,%eax
  802334:	75 d9                	jne    80230f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802336:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80233b:	5d                   	pop    %ebp
  80233c:	c3                   	ret    

0080233d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80233d:	55                   	push   %ebp
  80233e:	89 e5                	mov    %esp,%ebp
  802340:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802343:	89 d0                	mov    %edx,%eax
  802345:	c1 e8 16             	shr    $0x16,%eax
  802348:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80234f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802354:	f6 c1 01             	test   $0x1,%cl
  802357:	74 1d                	je     802376 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802359:	c1 ea 0c             	shr    $0xc,%edx
  80235c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802363:	f6 c2 01             	test   $0x1,%dl
  802366:	74 0e                	je     802376 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802368:	c1 ea 0c             	shr    $0xc,%edx
  80236b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802372:	ef 
  802373:	0f b7 c0             	movzwl %ax,%eax
}
  802376:	5d                   	pop    %ebp
  802377:	c3                   	ret    
  802378:	66 90                	xchg   %ax,%ax
  80237a:	66 90                	xchg   %ax,%ax
  80237c:	66 90                	xchg   %ax,%ax
  80237e:	66 90                	xchg   %ax,%ax

00802380 <__udivdi3>:
  802380:	55                   	push   %ebp
  802381:	57                   	push   %edi
  802382:	56                   	push   %esi
  802383:	53                   	push   %ebx
  802384:	83 ec 1c             	sub    $0x1c,%esp
  802387:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80238b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80238f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802393:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802397:	85 f6                	test   %esi,%esi
  802399:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80239d:	89 ca                	mov    %ecx,%edx
  80239f:	89 f8                	mov    %edi,%eax
  8023a1:	75 3d                	jne    8023e0 <__udivdi3+0x60>
  8023a3:	39 cf                	cmp    %ecx,%edi
  8023a5:	0f 87 c5 00 00 00    	ja     802470 <__udivdi3+0xf0>
  8023ab:	85 ff                	test   %edi,%edi
  8023ad:	89 fd                	mov    %edi,%ebp
  8023af:	75 0b                	jne    8023bc <__udivdi3+0x3c>
  8023b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8023b6:	31 d2                	xor    %edx,%edx
  8023b8:	f7 f7                	div    %edi
  8023ba:	89 c5                	mov    %eax,%ebp
  8023bc:	89 c8                	mov    %ecx,%eax
  8023be:	31 d2                	xor    %edx,%edx
  8023c0:	f7 f5                	div    %ebp
  8023c2:	89 c1                	mov    %eax,%ecx
  8023c4:	89 d8                	mov    %ebx,%eax
  8023c6:	89 cf                	mov    %ecx,%edi
  8023c8:	f7 f5                	div    %ebp
  8023ca:	89 c3                	mov    %eax,%ebx
  8023cc:	89 d8                	mov    %ebx,%eax
  8023ce:	89 fa                	mov    %edi,%edx
  8023d0:	83 c4 1c             	add    $0x1c,%esp
  8023d3:	5b                   	pop    %ebx
  8023d4:	5e                   	pop    %esi
  8023d5:	5f                   	pop    %edi
  8023d6:	5d                   	pop    %ebp
  8023d7:	c3                   	ret    
  8023d8:	90                   	nop
  8023d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023e0:	39 ce                	cmp    %ecx,%esi
  8023e2:	77 74                	ja     802458 <__udivdi3+0xd8>
  8023e4:	0f bd fe             	bsr    %esi,%edi
  8023e7:	83 f7 1f             	xor    $0x1f,%edi
  8023ea:	0f 84 98 00 00 00    	je     802488 <__udivdi3+0x108>
  8023f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8023f5:	89 f9                	mov    %edi,%ecx
  8023f7:	89 c5                	mov    %eax,%ebp
  8023f9:	29 fb                	sub    %edi,%ebx
  8023fb:	d3 e6                	shl    %cl,%esi
  8023fd:	89 d9                	mov    %ebx,%ecx
  8023ff:	d3 ed                	shr    %cl,%ebp
  802401:	89 f9                	mov    %edi,%ecx
  802403:	d3 e0                	shl    %cl,%eax
  802405:	09 ee                	or     %ebp,%esi
  802407:	89 d9                	mov    %ebx,%ecx
  802409:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80240d:	89 d5                	mov    %edx,%ebp
  80240f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802413:	d3 ed                	shr    %cl,%ebp
  802415:	89 f9                	mov    %edi,%ecx
  802417:	d3 e2                	shl    %cl,%edx
  802419:	89 d9                	mov    %ebx,%ecx
  80241b:	d3 e8                	shr    %cl,%eax
  80241d:	09 c2                	or     %eax,%edx
  80241f:	89 d0                	mov    %edx,%eax
  802421:	89 ea                	mov    %ebp,%edx
  802423:	f7 f6                	div    %esi
  802425:	89 d5                	mov    %edx,%ebp
  802427:	89 c3                	mov    %eax,%ebx
  802429:	f7 64 24 0c          	mull   0xc(%esp)
  80242d:	39 d5                	cmp    %edx,%ebp
  80242f:	72 10                	jb     802441 <__udivdi3+0xc1>
  802431:	8b 74 24 08          	mov    0x8(%esp),%esi
  802435:	89 f9                	mov    %edi,%ecx
  802437:	d3 e6                	shl    %cl,%esi
  802439:	39 c6                	cmp    %eax,%esi
  80243b:	73 07                	jae    802444 <__udivdi3+0xc4>
  80243d:	39 d5                	cmp    %edx,%ebp
  80243f:	75 03                	jne    802444 <__udivdi3+0xc4>
  802441:	83 eb 01             	sub    $0x1,%ebx
  802444:	31 ff                	xor    %edi,%edi
  802446:	89 d8                	mov    %ebx,%eax
  802448:	89 fa                	mov    %edi,%edx
  80244a:	83 c4 1c             	add    $0x1c,%esp
  80244d:	5b                   	pop    %ebx
  80244e:	5e                   	pop    %esi
  80244f:	5f                   	pop    %edi
  802450:	5d                   	pop    %ebp
  802451:	c3                   	ret    
  802452:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802458:	31 ff                	xor    %edi,%edi
  80245a:	31 db                	xor    %ebx,%ebx
  80245c:	89 d8                	mov    %ebx,%eax
  80245e:	89 fa                	mov    %edi,%edx
  802460:	83 c4 1c             	add    $0x1c,%esp
  802463:	5b                   	pop    %ebx
  802464:	5e                   	pop    %esi
  802465:	5f                   	pop    %edi
  802466:	5d                   	pop    %ebp
  802467:	c3                   	ret    
  802468:	90                   	nop
  802469:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802470:	89 d8                	mov    %ebx,%eax
  802472:	f7 f7                	div    %edi
  802474:	31 ff                	xor    %edi,%edi
  802476:	89 c3                	mov    %eax,%ebx
  802478:	89 d8                	mov    %ebx,%eax
  80247a:	89 fa                	mov    %edi,%edx
  80247c:	83 c4 1c             	add    $0x1c,%esp
  80247f:	5b                   	pop    %ebx
  802480:	5e                   	pop    %esi
  802481:	5f                   	pop    %edi
  802482:	5d                   	pop    %ebp
  802483:	c3                   	ret    
  802484:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802488:	39 ce                	cmp    %ecx,%esi
  80248a:	72 0c                	jb     802498 <__udivdi3+0x118>
  80248c:	31 db                	xor    %ebx,%ebx
  80248e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802492:	0f 87 34 ff ff ff    	ja     8023cc <__udivdi3+0x4c>
  802498:	bb 01 00 00 00       	mov    $0x1,%ebx
  80249d:	e9 2a ff ff ff       	jmp    8023cc <__udivdi3+0x4c>
  8024a2:	66 90                	xchg   %ax,%ax
  8024a4:	66 90                	xchg   %ax,%ax
  8024a6:	66 90                	xchg   %ax,%ax
  8024a8:	66 90                	xchg   %ax,%ax
  8024aa:	66 90                	xchg   %ax,%ax
  8024ac:	66 90                	xchg   %ax,%ax
  8024ae:	66 90                	xchg   %ax,%ax

008024b0 <__umoddi3>:
  8024b0:	55                   	push   %ebp
  8024b1:	57                   	push   %edi
  8024b2:	56                   	push   %esi
  8024b3:	53                   	push   %ebx
  8024b4:	83 ec 1c             	sub    $0x1c,%esp
  8024b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8024bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8024bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024c7:	85 d2                	test   %edx,%edx
  8024c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8024cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024d1:	89 f3                	mov    %esi,%ebx
  8024d3:	89 3c 24             	mov    %edi,(%esp)
  8024d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024da:	75 1c                	jne    8024f8 <__umoddi3+0x48>
  8024dc:	39 f7                	cmp    %esi,%edi
  8024de:	76 50                	jbe    802530 <__umoddi3+0x80>
  8024e0:	89 c8                	mov    %ecx,%eax
  8024e2:	89 f2                	mov    %esi,%edx
  8024e4:	f7 f7                	div    %edi
  8024e6:	89 d0                	mov    %edx,%eax
  8024e8:	31 d2                	xor    %edx,%edx
  8024ea:	83 c4 1c             	add    $0x1c,%esp
  8024ed:	5b                   	pop    %ebx
  8024ee:	5e                   	pop    %esi
  8024ef:	5f                   	pop    %edi
  8024f0:	5d                   	pop    %ebp
  8024f1:	c3                   	ret    
  8024f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024f8:	39 f2                	cmp    %esi,%edx
  8024fa:	89 d0                	mov    %edx,%eax
  8024fc:	77 52                	ja     802550 <__umoddi3+0xa0>
  8024fe:	0f bd ea             	bsr    %edx,%ebp
  802501:	83 f5 1f             	xor    $0x1f,%ebp
  802504:	75 5a                	jne    802560 <__umoddi3+0xb0>
  802506:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80250a:	0f 82 e0 00 00 00    	jb     8025f0 <__umoddi3+0x140>
  802510:	39 0c 24             	cmp    %ecx,(%esp)
  802513:	0f 86 d7 00 00 00    	jbe    8025f0 <__umoddi3+0x140>
  802519:	8b 44 24 08          	mov    0x8(%esp),%eax
  80251d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802521:	83 c4 1c             	add    $0x1c,%esp
  802524:	5b                   	pop    %ebx
  802525:	5e                   	pop    %esi
  802526:	5f                   	pop    %edi
  802527:	5d                   	pop    %ebp
  802528:	c3                   	ret    
  802529:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802530:	85 ff                	test   %edi,%edi
  802532:	89 fd                	mov    %edi,%ebp
  802534:	75 0b                	jne    802541 <__umoddi3+0x91>
  802536:	b8 01 00 00 00       	mov    $0x1,%eax
  80253b:	31 d2                	xor    %edx,%edx
  80253d:	f7 f7                	div    %edi
  80253f:	89 c5                	mov    %eax,%ebp
  802541:	89 f0                	mov    %esi,%eax
  802543:	31 d2                	xor    %edx,%edx
  802545:	f7 f5                	div    %ebp
  802547:	89 c8                	mov    %ecx,%eax
  802549:	f7 f5                	div    %ebp
  80254b:	89 d0                	mov    %edx,%eax
  80254d:	eb 99                	jmp    8024e8 <__umoddi3+0x38>
  80254f:	90                   	nop
  802550:	89 c8                	mov    %ecx,%eax
  802552:	89 f2                	mov    %esi,%edx
  802554:	83 c4 1c             	add    $0x1c,%esp
  802557:	5b                   	pop    %ebx
  802558:	5e                   	pop    %esi
  802559:	5f                   	pop    %edi
  80255a:	5d                   	pop    %ebp
  80255b:	c3                   	ret    
  80255c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802560:	8b 34 24             	mov    (%esp),%esi
  802563:	bf 20 00 00 00       	mov    $0x20,%edi
  802568:	89 e9                	mov    %ebp,%ecx
  80256a:	29 ef                	sub    %ebp,%edi
  80256c:	d3 e0                	shl    %cl,%eax
  80256e:	89 f9                	mov    %edi,%ecx
  802570:	89 f2                	mov    %esi,%edx
  802572:	d3 ea                	shr    %cl,%edx
  802574:	89 e9                	mov    %ebp,%ecx
  802576:	09 c2                	or     %eax,%edx
  802578:	89 d8                	mov    %ebx,%eax
  80257a:	89 14 24             	mov    %edx,(%esp)
  80257d:	89 f2                	mov    %esi,%edx
  80257f:	d3 e2                	shl    %cl,%edx
  802581:	89 f9                	mov    %edi,%ecx
  802583:	89 54 24 04          	mov    %edx,0x4(%esp)
  802587:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80258b:	d3 e8                	shr    %cl,%eax
  80258d:	89 e9                	mov    %ebp,%ecx
  80258f:	89 c6                	mov    %eax,%esi
  802591:	d3 e3                	shl    %cl,%ebx
  802593:	89 f9                	mov    %edi,%ecx
  802595:	89 d0                	mov    %edx,%eax
  802597:	d3 e8                	shr    %cl,%eax
  802599:	89 e9                	mov    %ebp,%ecx
  80259b:	09 d8                	or     %ebx,%eax
  80259d:	89 d3                	mov    %edx,%ebx
  80259f:	89 f2                	mov    %esi,%edx
  8025a1:	f7 34 24             	divl   (%esp)
  8025a4:	89 d6                	mov    %edx,%esi
  8025a6:	d3 e3                	shl    %cl,%ebx
  8025a8:	f7 64 24 04          	mull   0x4(%esp)
  8025ac:	39 d6                	cmp    %edx,%esi
  8025ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025b2:	89 d1                	mov    %edx,%ecx
  8025b4:	89 c3                	mov    %eax,%ebx
  8025b6:	72 08                	jb     8025c0 <__umoddi3+0x110>
  8025b8:	75 11                	jne    8025cb <__umoddi3+0x11b>
  8025ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8025be:	73 0b                	jae    8025cb <__umoddi3+0x11b>
  8025c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8025c4:	1b 14 24             	sbb    (%esp),%edx
  8025c7:	89 d1                	mov    %edx,%ecx
  8025c9:	89 c3                	mov    %eax,%ebx
  8025cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8025cf:	29 da                	sub    %ebx,%edx
  8025d1:	19 ce                	sbb    %ecx,%esi
  8025d3:	89 f9                	mov    %edi,%ecx
  8025d5:	89 f0                	mov    %esi,%eax
  8025d7:	d3 e0                	shl    %cl,%eax
  8025d9:	89 e9                	mov    %ebp,%ecx
  8025db:	d3 ea                	shr    %cl,%edx
  8025dd:	89 e9                	mov    %ebp,%ecx
  8025df:	d3 ee                	shr    %cl,%esi
  8025e1:	09 d0                	or     %edx,%eax
  8025e3:	89 f2                	mov    %esi,%edx
  8025e5:	83 c4 1c             	add    $0x1c,%esp
  8025e8:	5b                   	pop    %ebx
  8025e9:	5e                   	pop    %esi
  8025ea:	5f                   	pop    %edi
  8025eb:	5d                   	pop    %ebp
  8025ec:	c3                   	ret    
  8025ed:	8d 76 00             	lea    0x0(%esi),%esi
  8025f0:	29 f9                	sub    %edi,%ecx
  8025f2:	19 d6                	sbb    %edx,%esi
  8025f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025fc:	e9 18 ff ff ff       	jmp    802519 <__umoddi3+0x69>
