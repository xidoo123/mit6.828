
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
  80003a:	68 e0 25 80 00       	push   $0x8025e0
  80003f:	e8 64 01 00 00       	call   8001a8 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 12 0e 00 00       	call   800e5b <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 58 26 80 00       	push   $0x802658
  800058:	e8 4b 01 00 00       	call   8001a8 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 08 26 80 00       	push   $0x802608
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
  800099:	c7 04 24 30 26 80 00 	movl   $0x802630,(%esp)
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
  800101:	e8 d7 10 00 00       	call   8011dd <close_all>
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
  80020b:	e8 30 21 00 00       	call   802340 <__udivdi3>
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
  80024e:	e8 1d 22 00 00       	call   802470 <__umoddi3>
  800253:	83 c4 14             	add    $0x14,%esp
  800256:	0f be 80 80 26 80 00 	movsbl 0x802680(%eax),%eax
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
  800352:	ff 24 85 c0 27 80 00 	jmp    *0x8027c0(,%eax,4)
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
  800416:	8b 14 85 20 29 80 00 	mov    0x802920(,%eax,4),%edx
  80041d:	85 d2                	test   %edx,%edx
  80041f:	75 18                	jne    800439 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800421:	50                   	push   %eax
  800422:	68 98 26 80 00       	push   $0x802698
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
  80043a:	68 0d 2b 80 00       	push   $0x802b0d
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
  80045e:	b8 91 26 80 00       	mov    $0x802691,%eax
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
  800ad9:	68 7f 29 80 00       	push   $0x80297f
  800ade:	6a 23                	push   $0x23
  800ae0:	68 9c 29 80 00       	push   $0x80299c
  800ae5:	e8 6c 16 00 00       	call   802156 <_panic>

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
  800b5a:	68 7f 29 80 00       	push   $0x80297f
  800b5f:	6a 23                	push   $0x23
  800b61:	68 9c 29 80 00       	push   $0x80299c
  800b66:	e8 eb 15 00 00       	call   802156 <_panic>

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
  800b9c:	68 7f 29 80 00       	push   $0x80297f
  800ba1:	6a 23                	push   $0x23
  800ba3:	68 9c 29 80 00       	push   $0x80299c
  800ba8:	e8 a9 15 00 00       	call   802156 <_panic>

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
  800bde:	68 7f 29 80 00       	push   $0x80297f
  800be3:	6a 23                	push   $0x23
  800be5:	68 9c 29 80 00       	push   $0x80299c
  800bea:	e8 67 15 00 00       	call   802156 <_panic>

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
  800c20:	68 7f 29 80 00       	push   $0x80297f
  800c25:	6a 23                	push   $0x23
  800c27:	68 9c 29 80 00       	push   $0x80299c
  800c2c:	e8 25 15 00 00       	call   802156 <_panic>

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
  800c62:	68 7f 29 80 00       	push   $0x80297f
  800c67:	6a 23                	push   $0x23
  800c69:	68 9c 29 80 00       	push   $0x80299c
  800c6e:	e8 e3 14 00 00       	call   802156 <_panic>

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
  800ca4:	68 7f 29 80 00       	push   $0x80297f
  800ca9:	6a 23                	push   $0x23
  800cab:	68 9c 29 80 00       	push   $0x80299c
  800cb0:	e8 a1 14 00 00       	call   802156 <_panic>

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
  800d08:	68 7f 29 80 00       	push   $0x80297f
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 9c 29 80 00       	push   $0x80299c
  800d14:	e8 3d 14 00 00       	call   802156 <_panic>

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
  800d69:	68 7f 29 80 00       	push   $0x80297f
  800d6e:	6a 23                	push   $0x23
  800d70:	68 9c 29 80 00       	push   $0x80299c
  800d75:	e8 dc 13 00 00       	call   802156 <_panic>

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

00800d82 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	56                   	push   %esi
  800d86:	53                   	push   %ebx
  800d87:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d8a:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800d8c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d90:	75 25                	jne    800db7 <pgfault+0x35>
  800d92:	89 d8                	mov    %ebx,%eax
  800d94:	c1 e8 0c             	shr    $0xc,%eax
  800d97:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d9e:	f6 c4 08             	test   $0x8,%ah
  800da1:	75 14                	jne    800db7 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800da3:	83 ec 04             	sub    $0x4,%esp
  800da6:	68 ac 29 80 00       	push   $0x8029ac
  800dab:	6a 1e                	push   $0x1e
  800dad:	68 40 2a 80 00       	push   $0x802a40
  800db2:	e8 9f 13 00 00       	call   802156 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800db7:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800dbd:	e8 30 fd ff ff       	call   800af2 <sys_getenvid>
  800dc2:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800dc4:	83 ec 04             	sub    $0x4,%esp
  800dc7:	6a 07                	push   $0x7
  800dc9:	68 00 f0 7f 00       	push   $0x7ff000
  800dce:	50                   	push   %eax
  800dcf:	e8 5c fd ff ff       	call   800b30 <sys_page_alloc>
	if (r < 0)
  800dd4:	83 c4 10             	add    $0x10,%esp
  800dd7:	85 c0                	test   %eax,%eax
  800dd9:	79 12                	jns    800ded <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800ddb:	50                   	push   %eax
  800ddc:	68 d8 29 80 00       	push   $0x8029d8
  800de1:	6a 33                	push   $0x33
  800de3:	68 40 2a 80 00       	push   $0x802a40
  800de8:	e8 69 13 00 00       	call   802156 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800ded:	83 ec 04             	sub    $0x4,%esp
  800df0:	68 00 10 00 00       	push   $0x1000
  800df5:	53                   	push   %ebx
  800df6:	68 00 f0 7f 00       	push   $0x7ff000
  800dfb:	e8 27 fb ff ff       	call   800927 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800e00:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e07:	53                   	push   %ebx
  800e08:	56                   	push   %esi
  800e09:	68 00 f0 7f 00       	push   $0x7ff000
  800e0e:	56                   	push   %esi
  800e0f:	e8 5f fd ff ff       	call   800b73 <sys_page_map>
	if (r < 0)
  800e14:	83 c4 20             	add    $0x20,%esp
  800e17:	85 c0                	test   %eax,%eax
  800e19:	79 12                	jns    800e2d <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800e1b:	50                   	push   %eax
  800e1c:	68 fc 29 80 00       	push   $0x8029fc
  800e21:	6a 3b                	push   $0x3b
  800e23:	68 40 2a 80 00       	push   $0x802a40
  800e28:	e8 29 13 00 00       	call   802156 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800e2d:	83 ec 08             	sub    $0x8,%esp
  800e30:	68 00 f0 7f 00       	push   $0x7ff000
  800e35:	56                   	push   %esi
  800e36:	e8 7a fd ff ff       	call   800bb5 <sys_page_unmap>
	if (r < 0)
  800e3b:	83 c4 10             	add    $0x10,%esp
  800e3e:	85 c0                	test   %eax,%eax
  800e40:	79 12                	jns    800e54 <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800e42:	50                   	push   %eax
  800e43:	68 20 2a 80 00       	push   $0x802a20
  800e48:	6a 40                	push   $0x40
  800e4a:	68 40 2a 80 00       	push   $0x802a40
  800e4f:	e8 02 13 00 00       	call   802156 <_panic>
}
  800e54:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e57:	5b                   	pop    %ebx
  800e58:	5e                   	pop    %esi
  800e59:	5d                   	pop    %ebp
  800e5a:	c3                   	ret    

00800e5b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e5b:	55                   	push   %ebp
  800e5c:	89 e5                	mov    %esp,%ebp
  800e5e:	57                   	push   %edi
  800e5f:	56                   	push   %esi
  800e60:	53                   	push   %ebx
  800e61:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800e64:	68 82 0d 80 00       	push   $0x800d82
  800e69:	e8 2e 13 00 00       	call   80219c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e6e:	b8 07 00 00 00       	mov    $0x7,%eax
  800e73:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800e75:	83 c4 10             	add    $0x10,%esp
  800e78:	85 c0                	test   %eax,%eax
  800e7a:	0f 88 64 01 00 00    	js     800fe4 <fork+0x189>
  800e80:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800e85:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800e8a:	85 c0                	test   %eax,%eax
  800e8c:	75 21                	jne    800eaf <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e8e:	e8 5f fc ff ff       	call   800af2 <sys_getenvid>
  800e93:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e98:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e9b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ea0:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  800ea5:	ba 00 00 00 00       	mov    $0x0,%edx
  800eaa:	e9 3f 01 00 00       	jmp    800fee <fork+0x193>
  800eaf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800eb2:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800eb4:	89 d8                	mov    %ebx,%eax
  800eb6:	c1 e8 16             	shr    $0x16,%eax
  800eb9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ec0:	a8 01                	test   $0x1,%al
  800ec2:	0f 84 bd 00 00 00    	je     800f85 <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800ec8:	89 d8                	mov    %ebx,%eax
  800eca:	c1 e8 0c             	shr    $0xc,%eax
  800ecd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ed4:	f6 c2 01             	test   $0x1,%dl
  800ed7:	0f 84 a8 00 00 00    	je     800f85 <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  800edd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ee4:	a8 04                	test   $0x4,%al
  800ee6:	0f 84 99 00 00 00    	je     800f85 <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800eec:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ef3:	f6 c4 04             	test   $0x4,%ah
  800ef6:	74 17                	je     800f0f <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800ef8:	83 ec 0c             	sub    $0xc,%esp
  800efb:	68 07 0e 00 00       	push   $0xe07
  800f00:	53                   	push   %ebx
  800f01:	57                   	push   %edi
  800f02:	53                   	push   %ebx
  800f03:	6a 00                	push   $0x0
  800f05:	e8 69 fc ff ff       	call   800b73 <sys_page_map>
  800f0a:	83 c4 20             	add    $0x20,%esp
  800f0d:	eb 76                	jmp    800f85 <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f0f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f16:	a8 02                	test   $0x2,%al
  800f18:	75 0c                	jne    800f26 <fork+0xcb>
  800f1a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f21:	f6 c4 08             	test   $0x8,%ah
  800f24:	74 3f                	je     800f65 <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f26:	83 ec 0c             	sub    $0xc,%esp
  800f29:	68 05 08 00 00       	push   $0x805
  800f2e:	53                   	push   %ebx
  800f2f:	57                   	push   %edi
  800f30:	53                   	push   %ebx
  800f31:	6a 00                	push   $0x0
  800f33:	e8 3b fc ff ff       	call   800b73 <sys_page_map>
		if (r < 0)
  800f38:	83 c4 20             	add    $0x20,%esp
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	0f 88 a5 00 00 00    	js     800fe8 <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f43:	83 ec 0c             	sub    $0xc,%esp
  800f46:	68 05 08 00 00       	push   $0x805
  800f4b:	53                   	push   %ebx
  800f4c:	6a 00                	push   $0x0
  800f4e:	53                   	push   %ebx
  800f4f:	6a 00                	push   $0x0
  800f51:	e8 1d fc ff ff       	call   800b73 <sys_page_map>
  800f56:	83 c4 20             	add    $0x20,%esp
  800f59:	85 c0                	test   %eax,%eax
  800f5b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f60:	0f 4f c1             	cmovg  %ecx,%eax
  800f63:	eb 1c                	jmp    800f81 <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  800f65:	83 ec 0c             	sub    $0xc,%esp
  800f68:	6a 05                	push   $0x5
  800f6a:	53                   	push   %ebx
  800f6b:	57                   	push   %edi
  800f6c:	53                   	push   %ebx
  800f6d:	6a 00                	push   $0x0
  800f6f:	e8 ff fb ff ff       	call   800b73 <sys_page_map>
  800f74:	83 c4 20             	add    $0x20,%esp
  800f77:	85 c0                	test   %eax,%eax
  800f79:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f7e:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  800f81:	85 c0                	test   %eax,%eax
  800f83:	78 67                	js     800fec <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  800f85:	83 c6 01             	add    $0x1,%esi
  800f88:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f8e:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  800f94:	0f 85 1a ff ff ff    	jne    800eb4 <fork+0x59>
  800f9a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  800f9d:	83 ec 04             	sub    $0x4,%esp
  800fa0:	6a 07                	push   $0x7
  800fa2:	68 00 f0 bf ee       	push   $0xeebff000
  800fa7:	57                   	push   %edi
  800fa8:	e8 83 fb ff ff       	call   800b30 <sys_page_alloc>
	if (r < 0)
  800fad:	83 c4 10             	add    $0x10,%esp
		return r;
  800fb0:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	78 38                	js     800fee <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800fb6:	83 ec 08             	sub    $0x8,%esp
  800fb9:	68 e3 21 80 00       	push   $0x8021e3
  800fbe:	57                   	push   %edi
  800fbf:	e8 b7 fc ff ff       	call   800c7b <sys_env_set_pgfault_upcall>
	if (r < 0)
  800fc4:	83 c4 10             	add    $0x10,%esp
		return r;
  800fc7:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  800fc9:	85 c0                	test   %eax,%eax
  800fcb:	78 21                	js     800fee <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  800fcd:	83 ec 08             	sub    $0x8,%esp
  800fd0:	6a 02                	push   $0x2
  800fd2:	57                   	push   %edi
  800fd3:	e8 1f fc ff ff       	call   800bf7 <sys_env_set_status>
	if (r < 0)
  800fd8:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	0f 48 f8             	cmovs  %eax,%edi
  800fe0:	89 fa                	mov    %edi,%edx
  800fe2:	eb 0a                	jmp    800fee <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  800fe4:	89 c2                	mov    %eax,%edx
  800fe6:	eb 06                	jmp    800fee <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800fe8:	89 c2                	mov    %eax,%edx
  800fea:	eb 02                	jmp    800fee <fork+0x193>
  800fec:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  800fee:	89 d0                	mov    %edx,%eax
  800ff0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ff3:	5b                   	pop    %ebx
  800ff4:	5e                   	pop    %esi
  800ff5:	5f                   	pop    %edi
  800ff6:	5d                   	pop    %ebp
  800ff7:	c3                   	ret    

00800ff8 <sfork>:

// Challenge!
int
sfork(void)
{
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
  800ffb:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800ffe:	68 4b 2a 80 00       	push   $0x802a4b
  801003:	68 c9 00 00 00       	push   $0xc9
  801008:	68 40 2a 80 00       	push   $0x802a40
  80100d:	e8 44 11 00 00       	call   802156 <_panic>

00801012 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801015:	8b 45 08             	mov    0x8(%ebp),%eax
  801018:	05 00 00 00 30       	add    $0x30000000,%eax
  80101d:	c1 e8 0c             	shr    $0xc,%eax
}
  801020:	5d                   	pop    %ebp
  801021:	c3                   	ret    

00801022 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801022:	55                   	push   %ebp
  801023:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801025:	8b 45 08             	mov    0x8(%ebp),%eax
  801028:	05 00 00 00 30       	add    $0x30000000,%eax
  80102d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801032:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801037:	5d                   	pop    %ebp
  801038:	c3                   	ret    

00801039 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80103f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801044:	89 c2                	mov    %eax,%edx
  801046:	c1 ea 16             	shr    $0x16,%edx
  801049:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801050:	f6 c2 01             	test   $0x1,%dl
  801053:	74 11                	je     801066 <fd_alloc+0x2d>
  801055:	89 c2                	mov    %eax,%edx
  801057:	c1 ea 0c             	shr    $0xc,%edx
  80105a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801061:	f6 c2 01             	test   $0x1,%dl
  801064:	75 09                	jne    80106f <fd_alloc+0x36>
			*fd_store = fd;
  801066:	89 01                	mov    %eax,(%ecx)
			return 0;
  801068:	b8 00 00 00 00       	mov    $0x0,%eax
  80106d:	eb 17                	jmp    801086 <fd_alloc+0x4d>
  80106f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801074:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801079:	75 c9                	jne    801044 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80107b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801081:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801086:	5d                   	pop    %ebp
  801087:	c3                   	ret    

00801088 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801088:	55                   	push   %ebp
  801089:	89 e5                	mov    %esp,%ebp
  80108b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80108e:	83 f8 1f             	cmp    $0x1f,%eax
  801091:	77 36                	ja     8010c9 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801093:	c1 e0 0c             	shl    $0xc,%eax
  801096:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80109b:	89 c2                	mov    %eax,%edx
  80109d:	c1 ea 16             	shr    $0x16,%edx
  8010a0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010a7:	f6 c2 01             	test   $0x1,%dl
  8010aa:	74 24                	je     8010d0 <fd_lookup+0x48>
  8010ac:	89 c2                	mov    %eax,%edx
  8010ae:	c1 ea 0c             	shr    $0xc,%edx
  8010b1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010b8:	f6 c2 01             	test   $0x1,%dl
  8010bb:	74 1a                	je     8010d7 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010c0:	89 02                	mov    %eax,(%edx)
	return 0;
  8010c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c7:	eb 13                	jmp    8010dc <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010ce:	eb 0c                	jmp    8010dc <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010d5:	eb 05                	jmp    8010dc <fd_lookup+0x54>
  8010d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010dc:	5d                   	pop    %ebp
  8010dd:	c3                   	ret    

008010de <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	83 ec 08             	sub    $0x8,%esp
  8010e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010e7:	ba e0 2a 80 00       	mov    $0x802ae0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8010ec:	eb 13                	jmp    801101 <dev_lookup+0x23>
  8010ee:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8010f1:	39 08                	cmp    %ecx,(%eax)
  8010f3:	75 0c                	jne    801101 <dev_lookup+0x23>
			*dev = devtab[i];
  8010f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ff:	eb 2e                	jmp    80112f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801101:	8b 02                	mov    (%edx),%eax
  801103:	85 c0                	test   %eax,%eax
  801105:	75 e7                	jne    8010ee <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801107:	a1 08 40 80 00       	mov    0x804008,%eax
  80110c:	8b 40 48             	mov    0x48(%eax),%eax
  80110f:	83 ec 04             	sub    $0x4,%esp
  801112:	51                   	push   %ecx
  801113:	50                   	push   %eax
  801114:	68 64 2a 80 00       	push   $0x802a64
  801119:	e8 8a f0 ff ff       	call   8001a8 <cprintf>
	*dev = 0;
  80111e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801121:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801127:	83 c4 10             	add    $0x10,%esp
  80112a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80112f:	c9                   	leave  
  801130:	c3                   	ret    

00801131 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801131:	55                   	push   %ebp
  801132:	89 e5                	mov    %esp,%ebp
  801134:	56                   	push   %esi
  801135:	53                   	push   %ebx
  801136:	83 ec 10             	sub    $0x10,%esp
  801139:	8b 75 08             	mov    0x8(%ebp),%esi
  80113c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80113f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801142:	50                   	push   %eax
  801143:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801149:	c1 e8 0c             	shr    $0xc,%eax
  80114c:	50                   	push   %eax
  80114d:	e8 36 ff ff ff       	call   801088 <fd_lookup>
  801152:	83 c4 08             	add    $0x8,%esp
  801155:	85 c0                	test   %eax,%eax
  801157:	78 05                	js     80115e <fd_close+0x2d>
	    || fd != fd2)
  801159:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80115c:	74 0c                	je     80116a <fd_close+0x39>
		return (must_exist ? r : 0);
  80115e:	84 db                	test   %bl,%bl
  801160:	ba 00 00 00 00       	mov    $0x0,%edx
  801165:	0f 44 c2             	cmove  %edx,%eax
  801168:	eb 41                	jmp    8011ab <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80116a:	83 ec 08             	sub    $0x8,%esp
  80116d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801170:	50                   	push   %eax
  801171:	ff 36                	pushl  (%esi)
  801173:	e8 66 ff ff ff       	call   8010de <dev_lookup>
  801178:	89 c3                	mov    %eax,%ebx
  80117a:	83 c4 10             	add    $0x10,%esp
  80117d:	85 c0                	test   %eax,%eax
  80117f:	78 1a                	js     80119b <fd_close+0x6a>
		if (dev->dev_close)
  801181:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801184:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801187:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80118c:	85 c0                	test   %eax,%eax
  80118e:	74 0b                	je     80119b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801190:	83 ec 0c             	sub    $0xc,%esp
  801193:	56                   	push   %esi
  801194:	ff d0                	call   *%eax
  801196:	89 c3                	mov    %eax,%ebx
  801198:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80119b:	83 ec 08             	sub    $0x8,%esp
  80119e:	56                   	push   %esi
  80119f:	6a 00                	push   $0x0
  8011a1:	e8 0f fa ff ff       	call   800bb5 <sys_page_unmap>
	return r;
  8011a6:	83 c4 10             	add    $0x10,%esp
  8011a9:	89 d8                	mov    %ebx,%eax
}
  8011ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011ae:	5b                   	pop    %ebx
  8011af:	5e                   	pop    %esi
  8011b0:	5d                   	pop    %ebp
  8011b1:	c3                   	ret    

008011b2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011b2:	55                   	push   %ebp
  8011b3:	89 e5                	mov    %esp,%ebp
  8011b5:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011bb:	50                   	push   %eax
  8011bc:	ff 75 08             	pushl  0x8(%ebp)
  8011bf:	e8 c4 fe ff ff       	call   801088 <fd_lookup>
  8011c4:	83 c4 08             	add    $0x8,%esp
  8011c7:	85 c0                	test   %eax,%eax
  8011c9:	78 10                	js     8011db <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8011cb:	83 ec 08             	sub    $0x8,%esp
  8011ce:	6a 01                	push   $0x1
  8011d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8011d3:	e8 59 ff ff ff       	call   801131 <fd_close>
  8011d8:	83 c4 10             	add    $0x10,%esp
}
  8011db:	c9                   	leave  
  8011dc:	c3                   	ret    

008011dd <close_all>:

void
close_all(void)
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
  8011e0:	53                   	push   %ebx
  8011e1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011e4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011e9:	83 ec 0c             	sub    $0xc,%esp
  8011ec:	53                   	push   %ebx
  8011ed:	e8 c0 ff ff ff       	call   8011b2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8011f2:	83 c3 01             	add    $0x1,%ebx
  8011f5:	83 c4 10             	add    $0x10,%esp
  8011f8:	83 fb 20             	cmp    $0x20,%ebx
  8011fb:	75 ec                	jne    8011e9 <close_all+0xc>
		close(i);
}
  8011fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801200:	c9                   	leave  
  801201:	c3                   	ret    

00801202 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801202:	55                   	push   %ebp
  801203:	89 e5                	mov    %esp,%ebp
  801205:	57                   	push   %edi
  801206:	56                   	push   %esi
  801207:	53                   	push   %ebx
  801208:	83 ec 2c             	sub    $0x2c,%esp
  80120b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80120e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801211:	50                   	push   %eax
  801212:	ff 75 08             	pushl  0x8(%ebp)
  801215:	e8 6e fe ff ff       	call   801088 <fd_lookup>
  80121a:	83 c4 08             	add    $0x8,%esp
  80121d:	85 c0                	test   %eax,%eax
  80121f:	0f 88 c1 00 00 00    	js     8012e6 <dup+0xe4>
		return r;
	close(newfdnum);
  801225:	83 ec 0c             	sub    $0xc,%esp
  801228:	56                   	push   %esi
  801229:	e8 84 ff ff ff       	call   8011b2 <close>

	newfd = INDEX2FD(newfdnum);
  80122e:	89 f3                	mov    %esi,%ebx
  801230:	c1 e3 0c             	shl    $0xc,%ebx
  801233:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801239:	83 c4 04             	add    $0x4,%esp
  80123c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80123f:	e8 de fd ff ff       	call   801022 <fd2data>
  801244:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801246:	89 1c 24             	mov    %ebx,(%esp)
  801249:	e8 d4 fd ff ff       	call   801022 <fd2data>
  80124e:	83 c4 10             	add    $0x10,%esp
  801251:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801254:	89 f8                	mov    %edi,%eax
  801256:	c1 e8 16             	shr    $0x16,%eax
  801259:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801260:	a8 01                	test   $0x1,%al
  801262:	74 37                	je     80129b <dup+0x99>
  801264:	89 f8                	mov    %edi,%eax
  801266:	c1 e8 0c             	shr    $0xc,%eax
  801269:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801270:	f6 c2 01             	test   $0x1,%dl
  801273:	74 26                	je     80129b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801275:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80127c:	83 ec 0c             	sub    $0xc,%esp
  80127f:	25 07 0e 00 00       	and    $0xe07,%eax
  801284:	50                   	push   %eax
  801285:	ff 75 d4             	pushl  -0x2c(%ebp)
  801288:	6a 00                	push   $0x0
  80128a:	57                   	push   %edi
  80128b:	6a 00                	push   $0x0
  80128d:	e8 e1 f8 ff ff       	call   800b73 <sys_page_map>
  801292:	89 c7                	mov    %eax,%edi
  801294:	83 c4 20             	add    $0x20,%esp
  801297:	85 c0                	test   %eax,%eax
  801299:	78 2e                	js     8012c9 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80129b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80129e:	89 d0                	mov    %edx,%eax
  8012a0:	c1 e8 0c             	shr    $0xc,%eax
  8012a3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012aa:	83 ec 0c             	sub    $0xc,%esp
  8012ad:	25 07 0e 00 00       	and    $0xe07,%eax
  8012b2:	50                   	push   %eax
  8012b3:	53                   	push   %ebx
  8012b4:	6a 00                	push   $0x0
  8012b6:	52                   	push   %edx
  8012b7:	6a 00                	push   $0x0
  8012b9:	e8 b5 f8 ff ff       	call   800b73 <sys_page_map>
  8012be:	89 c7                	mov    %eax,%edi
  8012c0:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8012c3:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012c5:	85 ff                	test   %edi,%edi
  8012c7:	79 1d                	jns    8012e6 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012c9:	83 ec 08             	sub    $0x8,%esp
  8012cc:	53                   	push   %ebx
  8012cd:	6a 00                	push   $0x0
  8012cf:	e8 e1 f8 ff ff       	call   800bb5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012d4:	83 c4 08             	add    $0x8,%esp
  8012d7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012da:	6a 00                	push   $0x0
  8012dc:	e8 d4 f8 ff ff       	call   800bb5 <sys_page_unmap>
	return r;
  8012e1:	83 c4 10             	add    $0x10,%esp
  8012e4:	89 f8                	mov    %edi,%eax
}
  8012e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012e9:	5b                   	pop    %ebx
  8012ea:	5e                   	pop    %esi
  8012eb:	5f                   	pop    %edi
  8012ec:	5d                   	pop    %ebp
  8012ed:	c3                   	ret    

008012ee <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012ee:	55                   	push   %ebp
  8012ef:	89 e5                	mov    %esp,%ebp
  8012f1:	53                   	push   %ebx
  8012f2:	83 ec 14             	sub    $0x14,%esp
  8012f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012fb:	50                   	push   %eax
  8012fc:	53                   	push   %ebx
  8012fd:	e8 86 fd ff ff       	call   801088 <fd_lookup>
  801302:	83 c4 08             	add    $0x8,%esp
  801305:	89 c2                	mov    %eax,%edx
  801307:	85 c0                	test   %eax,%eax
  801309:	78 6d                	js     801378 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80130b:	83 ec 08             	sub    $0x8,%esp
  80130e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801311:	50                   	push   %eax
  801312:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801315:	ff 30                	pushl  (%eax)
  801317:	e8 c2 fd ff ff       	call   8010de <dev_lookup>
  80131c:	83 c4 10             	add    $0x10,%esp
  80131f:	85 c0                	test   %eax,%eax
  801321:	78 4c                	js     80136f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801323:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801326:	8b 42 08             	mov    0x8(%edx),%eax
  801329:	83 e0 03             	and    $0x3,%eax
  80132c:	83 f8 01             	cmp    $0x1,%eax
  80132f:	75 21                	jne    801352 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801331:	a1 08 40 80 00       	mov    0x804008,%eax
  801336:	8b 40 48             	mov    0x48(%eax),%eax
  801339:	83 ec 04             	sub    $0x4,%esp
  80133c:	53                   	push   %ebx
  80133d:	50                   	push   %eax
  80133e:	68 a5 2a 80 00       	push   $0x802aa5
  801343:	e8 60 ee ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  801348:	83 c4 10             	add    $0x10,%esp
  80134b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801350:	eb 26                	jmp    801378 <read+0x8a>
	}
	if (!dev->dev_read)
  801352:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801355:	8b 40 08             	mov    0x8(%eax),%eax
  801358:	85 c0                	test   %eax,%eax
  80135a:	74 17                	je     801373 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80135c:	83 ec 04             	sub    $0x4,%esp
  80135f:	ff 75 10             	pushl  0x10(%ebp)
  801362:	ff 75 0c             	pushl  0xc(%ebp)
  801365:	52                   	push   %edx
  801366:	ff d0                	call   *%eax
  801368:	89 c2                	mov    %eax,%edx
  80136a:	83 c4 10             	add    $0x10,%esp
  80136d:	eb 09                	jmp    801378 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80136f:	89 c2                	mov    %eax,%edx
  801371:	eb 05                	jmp    801378 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801373:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801378:	89 d0                	mov    %edx,%eax
  80137a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137d:	c9                   	leave  
  80137e:	c3                   	ret    

0080137f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
  801382:	57                   	push   %edi
  801383:	56                   	push   %esi
  801384:	53                   	push   %ebx
  801385:	83 ec 0c             	sub    $0xc,%esp
  801388:	8b 7d 08             	mov    0x8(%ebp),%edi
  80138b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80138e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801393:	eb 21                	jmp    8013b6 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801395:	83 ec 04             	sub    $0x4,%esp
  801398:	89 f0                	mov    %esi,%eax
  80139a:	29 d8                	sub    %ebx,%eax
  80139c:	50                   	push   %eax
  80139d:	89 d8                	mov    %ebx,%eax
  80139f:	03 45 0c             	add    0xc(%ebp),%eax
  8013a2:	50                   	push   %eax
  8013a3:	57                   	push   %edi
  8013a4:	e8 45 ff ff ff       	call   8012ee <read>
		if (m < 0)
  8013a9:	83 c4 10             	add    $0x10,%esp
  8013ac:	85 c0                	test   %eax,%eax
  8013ae:	78 10                	js     8013c0 <readn+0x41>
			return m;
		if (m == 0)
  8013b0:	85 c0                	test   %eax,%eax
  8013b2:	74 0a                	je     8013be <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013b4:	01 c3                	add    %eax,%ebx
  8013b6:	39 f3                	cmp    %esi,%ebx
  8013b8:	72 db                	jb     801395 <readn+0x16>
  8013ba:	89 d8                	mov    %ebx,%eax
  8013bc:	eb 02                	jmp    8013c0 <readn+0x41>
  8013be:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c3:	5b                   	pop    %ebx
  8013c4:	5e                   	pop    %esi
  8013c5:	5f                   	pop    %edi
  8013c6:	5d                   	pop    %ebp
  8013c7:	c3                   	ret    

008013c8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013c8:	55                   	push   %ebp
  8013c9:	89 e5                	mov    %esp,%ebp
  8013cb:	53                   	push   %ebx
  8013cc:	83 ec 14             	sub    $0x14,%esp
  8013cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d5:	50                   	push   %eax
  8013d6:	53                   	push   %ebx
  8013d7:	e8 ac fc ff ff       	call   801088 <fd_lookup>
  8013dc:	83 c4 08             	add    $0x8,%esp
  8013df:	89 c2                	mov    %eax,%edx
  8013e1:	85 c0                	test   %eax,%eax
  8013e3:	78 68                	js     80144d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e5:	83 ec 08             	sub    $0x8,%esp
  8013e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013eb:	50                   	push   %eax
  8013ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ef:	ff 30                	pushl  (%eax)
  8013f1:	e8 e8 fc ff ff       	call   8010de <dev_lookup>
  8013f6:	83 c4 10             	add    $0x10,%esp
  8013f9:	85 c0                	test   %eax,%eax
  8013fb:	78 47                	js     801444 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801400:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801404:	75 21                	jne    801427 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801406:	a1 08 40 80 00       	mov    0x804008,%eax
  80140b:	8b 40 48             	mov    0x48(%eax),%eax
  80140e:	83 ec 04             	sub    $0x4,%esp
  801411:	53                   	push   %ebx
  801412:	50                   	push   %eax
  801413:	68 c1 2a 80 00       	push   $0x802ac1
  801418:	e8 8b ed ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  80141d:	83 c4 10             	add    $0x10,%esp
  801420:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801425:	eb 26                	jmp    80144d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801427:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80142a:	8b 52 0c             	mov    0xc(%edx),%edx
  80142d:	85 d2                	test   %edx,%edx
  80142f:	74 17                	je     801448 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801431:	83 ec 04             	sub    $0x4,%esp
  801434:	ff 75 10             	pushl  0x10(%ebp)
  801437:	ff 75 0c             	pushl  0xc(%ebp)
  80143a:	50                   	push   %eax
  80143b:	ff d2                	call   *%edx
  80143d:	89 c2                	mov    %eax,%edx
  80143f:	83 c4 10             	add    $0x10,%esp
  801442:	eb 09                	jmp    80144d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801444:	89 c2                	mov    %eax,%edx
  801446:	eb 05                	jmp    80144d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801448:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80144d:	89 d0                	mov    %edx,%eax
  80144f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801452:	c9                   	leave  
  801453:	c3                   	ret    

00801454 <seek>:

int
seek(int fdnum, off_t offset)
{
  801454:	55                   	push   %ebp
  801455:	89 e5                	mov    %esp,%ebp
  801457:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80145a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80145d:	50                   	push   %eax
  80145e:	ff 75 08             	pushl  0x8(%ebp)
  801461:	e8 22 fc ff ff       	call   801088 <fd_lookup>
  801466:	83 c4 08             	add    $0x8,%esp
  801469:	85 c0                	test   %eax,%eax
  80146b:	78 0e                	js     80147b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80146d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801470:	8b 55 0c             	mov    0xc(%ebp),%edx
  801473:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801476:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80147b:	c9                   	leave  
  80147c:	c3                   	ret    

0080147d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80147d:	55                   	push   %ebp
  80147e:	89 e5                	mov    %esp,%ebp
  801480:	53                   	push   %ebx
  801481:	83 ec 14             	sub    $0x14,%esp
  801484:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801487:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80148a:	50                   	push   %eax
  80148b:	53                   	push   %ebx
  80148c:	e8 f7 fb ff ff       	call   801088 <fd_lookup>
  801491:	83 c4 08             	add    $0x8,%esp
  801494:	89 c2                	mov    %eax,%edx
  801496:	85 c0                	test   %eax,%eax
  801498:	78 65                	js     8014ff <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80149a:	83 ec 08             	sub    $0x8,%esp
  80149d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a0:	50                   	push   %eax
  8014a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a4:	ff 30                	pushl  (%eax)
  8014a6:	e8 33 fc ff ff       	call   8010de <dev_lookup>
  8014ab:	83 c4 10             	add    $0x10,%esp
  8014ae:	85 c0                	test   %eax,%eax
  8014b0:	78 44                	js     8014f6 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014b9:	75 21                	jne    8014dc <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014bb:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014c0:	8b 40 48             	mov    0x48(%eax),%eax
  8014c3:	83 ec 04             	sub    $0x4,%esp
  8014c6:	53                   	push   %ebx
  8014c7:	50                   	push   %eax
  8014c8:	68 84 2a 80 00       	push   $0x802a84
  8014cd:	e8 d6 ec ff ff       	call   8001a8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014d2:	83 c4 10             	add    $0x10,%esp
  8014d5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014da:	eb 23                	jmp    8014ff <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8014dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014df:	8b 52 18             	mov    0x18(%edx),%edx
  8014e2:	85 d2                	test   %edx,%edx
  8014e4:	74 14                	je     8014fa <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014e6:	83 ec 08             	sub    $0x8,%esp
  8014e9:	ff 75 0c             	pushl  0xc(%ebp)
  8014ec:	50                   	push   %eax
  8014ed:	ff d2                	call   *%edx
  8014ef:	89 c2                	mov    %eax,%edx
  8014f1:	83 c4 10             	add    $0x10,%esp
  8014f4:	eb 09                	jmp    8014ff <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f6:	89 c2                	mov    %eax,%edx
  8014f8:	eb 05                	jmp    8014ff <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8014fa:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8014ff:	89 d0                	mov    %edx,%eax
  801501:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801504:	c9                   	leave  
  801505:	c3                   	ret    

00801506 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801506:	55                   	push   %ebp
  801507:	89 e5                	mov    %esp,%ebp
  801509:	53                   	push   %ebx
  80150a:	83 ec 14             	sub    $0x14,%esp
  80150d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801510:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801513:	50                   	push   %eax
  801514:	ff 75 08             	pushl  0x8(%ebp)
  801517:	e8 6c fb ff ff       	call   801088 <fd_lookup>
  80151c:	83 c4 08             	add    $0x8,%esp
  80151f:	89 c2                	mov    %eax,%edx
  801521:	85 c0                	test   %eax,%eax
  801523:	78 58                	js     80157d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801525:	83 ec 08             	sub    $0x8,%esp
  801528:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152b:	50                   	push   %eax
  80152c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152f:	ff 30                	pushl  (%eax)
  801531:	e8 a8 fb ff ff       	call   8010de <dev_lookup>
  801536:	83 c4 10             	add    $0x10,%esp
  801539:	85 c0                	test   %eax,%eax
  80153b:	78 37                	js     801574 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80153d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801540:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801544:	74 32                	je     801578 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801546:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801549:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801550:	00 00 00 
	stat->st_isdir = 0;
  801553:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80155a:	00 00 00 
	stat->st_dev = dev;
  80155d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801563:	83 ec 08             	sub    $0x8,%esp
  801566:	53                   	push   %ebx
  801567:	ff 75 f0             	pushl  -0x10(%ebp)
  80156a:	ff 50 14             	call   *0x14(%eax)
  80156d:	89 c2                	mov    %eax,%edx
  80156f:	83 c4 10             	add    $0x10,%esp
  801572:	eb 09                	jmp    80157d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801574:	89 c2                	mov    %eax,%edx
  801576:	eb 05                	jmp    80157d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801578:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80157d:	89 d0                	mov    %edx,%eax
  80157f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801582:	c9                   	leave  
  801583:	c3                   	ret    

00801584 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801584:	55                   	push   %ebp
  801585:	89 e5                	mov    %esp,%ebp
  801587:	56                   	push   %esi
  801588:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801589:	83 ec 08             	sub    $0x8,%esp
  80158c:	6a 00                	push   $0x0
  80158e:	ff 75 08             	pushl  0x8(%ebp)
  801591:	e8 d6 01 00 00       	call   80176c <open>
  801596:	89 c3                	mov    %eax,%ebx
  801598:	83 c4 10             	add    $0x10,%esp
  80159b:	85 c0                	test   %eax,%eax
  80159d:	78 1b                	js     8015ba <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80159f:	83 ec 08             	sub    $0x8,%esp
  8015a2:	ff 75 0c             	pushl  0xc(%ebp)
  8015a5:	50                   	push   %eax
  8015a6:	e8 5b ff ff ff       	call   801506 <fstat>
  8015ab:	89 c6                	mov    %eax,%esi
	close(fd);
  8015ad:	89 1c 24             	mov    %ebx,(%esp)
  8015b0:	e8 fd fb ff ff       	call   8011b2 <close>
	return r;
  8015b5:	83 c4 10             	add    $0x10,%esp
  8015b8:	89 f0                	mov    %esi,%eax
}
  8015ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015bd:	5b                   	pop    %ebx
  8015be:	5e                   	pop    %esi
  8015bf:	5d                   	pop    %ebp
  8015c0:	c3                   	ret    

008015c1 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
  8015c4:	56                   	push   %esi
  8015c5:	53                   	push   %ebx
  8015c6:	89 c6                	mov    %eax,%esi
  8015c8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015ca:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015d1:	75 12                	jne    8015e5 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015d3:	83 ec 0c             	sub    $0xc,%esp
  8015d6:	6a 01                	push   $0x1
  8015d8:	e8 e5 0c 00 00       	call   8022c2 <ipc_find_env>
  8015dd:	a3 00 40 80 00       	mov    %eax,0x804000
  8015e2:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015e5:	6a 07                	push   $0x7
  8015e7:	68 00 50 80 00       	push   $0x805000
  8015ec:	56                   	push   %esi
  8015ed:	ff 35 00 40 80 00    	pushl  0x804000
  8015f3:	e8 76 0c 00 00       	call   80226e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8015f8:	83 c4 0c             	add    $0xc,%esp
  8015fb:	6a 00                	push   $0x0
  8015fd:	53                   	push   %ebx
  8015fe:	6a 00                	push   $0x0
  801600:	e8 02 0c 00 00       	call   802207 <ipc_recv>
}
  801605:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801608:	5b                   	pop    %ebx
  801609:	5e                   	pop    %esi
  80160a:	5d                   	pop    %ebp
  80160b:	c3                   	ret    

0080160c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80160c:	55                   	push   %ebp
  80160d:	89 e5                	mov    %esp,%ebp
  80160f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801612:	8b 45 08             	mov    0x8(%ebp),%eax
  801615:	8b 40 0c             	mov    0xc(%eax),%eax
  801618:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80161d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801620:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801625:	ba 00 00 00 00       	mov    $0x0,%edx
  80162a:	b8 02 00 00 00       	mov    $0x2,%eax
  80162f:	e8 8d ff ff ff       	call   8015c1 <fsipc>
}
  801634:	c9                   	leave  
  801635:	c3                   	ret    

00801636 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801636:	55                   	push   %ebp
  801637:	89 e5                	mov    %esp,%ebp
  801639:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80163c:	8b 45 08             	mov    0x8(%ebp),%eax
  80163f:	8b 40 0c             	mov    0xc(%eax),%eax
  801642:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801647:	ba 00 00 00 00       	mov    $0x0,%edx
  80164c:	b8 06 00 00 00       	mov    $0x6,%eax
  801651:	e8 6b ff ff ff       	call   8015c1 <fsipc>
}
  801656:	c9                   	leave  
  801657:	c3                   	ret    

00801658 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801658:	55                   	push   %ebp
  801659:	89 e5                	mov    %esp,%ebp
  80165b:	53                   	push   %ebx
  80165c:	83 ec 04             	sub    $0x4,%esp
  80165f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801662:	8b 45 08             	mov    0x8(%ebp),%eax
  801665:	8b 40 0c             	mov    0xc(%eax),%eax
  801668:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80166d:	ba 00 00 00 00       	mov    $0x0,%edx
  801672:	b8 05 00 00 00       	mov    $0x5,%eax
  801677:	e8 45 ff ff ff       	call   8015c1 <fsipc>
  80167c:	85 c0                	test   %eax,%eax
  80167e:	78 2c                	js     8016ac <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801680:	83 ec 08             	sub    $0x8,%esp
  801683:	68 00 50 80 00       	push   $0x805000
  801688:	53                   	push   %ebx
  801689:	e8 9f f0 ff ff       	call   80072d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80168e:	a1 80 50 80 00       	mov    0x805080,%eax
  801693:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801699:	a1 84 50 80 00       	mov    0x805084,%eax
  80169e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016a4:	83 c4 10             	add    $0x10,%esp
  8016a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016af:	c9                   	leave  
  8016b0:	c3                   	ret    

008016b1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016b1:	55                   	push   %ebp
  8016b2:	89 e5                	mov    %esp,%ebp
  8016b4:	83 ec 0c             	sub    $0xc,%esp
  8016b7:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8016bd:	8b 52 0c             	mov    0xc(%edx),%edx
  8016c0:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8016c6:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8016cb:	50                   	push   %eax
  8016cc:	ff 75 0c             	pushl  0xc(%ebp)
  8016cf:	68 08 50 80 00       	push   $0x805008
  8016d4:	e8 e6 f1 ff ff       	call   8008bf <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8016d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016de:	b8 04 00 00 00       	mov    $0x4,%eax
  8016e3:	e8 d9 fe ff ff       	call   8015c1 <fsipc>

}
  8016e8:	c9                   	leave  
  8016e9:	c3                   	ret    

008016ea <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	56                   	push   %esi
  8016ee:	53                   	push   %ebx
  8016ef:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016fd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801703:	ba 00 00 00 00       	mov    $0x0,%edx
  801708:	b8 03 00 00 00       	mov    $0x3,%eax
  80170d:	e8 af fe ff ff       	call   8015c1 <fsipc>
  801712:	89 c3                	mov    %eax,%ebx
  801714:	85 c0                	test   %eax,%eax
  801716:	78 4b                	js     801763 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801718:	39 c6                	cmp    %eax,%esi
  80171a:	73 16                	jae    801732 <devfile_read+0x48>
  80171c:	68 f4 2a 80 00       	push   $0x802af4
  801721:	68 fb 2a 80 00       	push   $0x802afb
  801726:	6a 7c                	push   $0x7c
  801728:	68 10 2b 80 00       	push   $0x802b10
  80172d:	e8 24 0a 00 00       	call   802156 <_panic>
	assert(r <= PGSIZE);
  801732:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801737:	7e 16                	jle    80174f <devfile_read+0x65>
  801739:	68 1b 2b 80 00       	push   $0x802b1b
  80173e:	68 fb 2a 80 00       	push   $0x802afb
  801743:	6a 7d                	push   $0x7d
  801745:	68 10 2b 80 00       	push   $0x802b10
  80174a:	e8 07 0a 00 00       	call   802156 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80174f:	83 ec 04             	sub    $0x4,%esp
  801752:	50                   	push   %eax
  801753:	68 00 50 80 00       	push   $0x805000
  801758:	ff 75 0c             	pushl  0xc(%ebp)
  80175b:	e8 5f f1 ff ff       	call   8008bf <memmove>
	return r;
  801760:	83 c4 10             	add    $0x10,%esp
}
  801763:	89 d8                	mov    %ebx,%eax
  801765:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801768:	5b                   	pop    %ebx
  801769:	5e                   	pop    %esi
  80176a:	5d                   	pop    %ebp
  80176b:	c3                   	ret    

0080176c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80176c:	55                   	push   %ebp
  80176d:	89 e5                	mov    %esp,%ebp
  80176f:	53                   	push   %ebx
  801770:	83 ec 20             	sub    $0x20,%esp
  801773:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801776:	53                   	push   %ebx
  801777:	e8 78 ef ff ff       	call   8006f4 <strlen>
  80177c:	83 c4 10             	add    $0x10,%esp
  80177f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801784:	7f 67                	jg     8017ed <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801786:	83 ec 0c             	sub    $0xc,%esp
  801789:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80178c:	50                   	push   %eax
  80178d:	e8 a7 f8 ff ff       	call   801039 <fd_alloc>
  801792:	83 c4 10             	add    $0x10,%esp
		return r;
  801795:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801797:	85 c0                	test   %eax,%eax
  801799:	78 57                	js     8017f2 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80179b:	83 ec 08             	sub    $0x8,%esp
  80179e:	53                   	push   %ebx
  80179f:	68 00 50 80 00       	push   $0x805000
  8017a4:	e8 84 ef ff ff       	call   80072d <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ac:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8017b9:	e8 03 fe ff ff       	call   8015c1 <fsipc>
  8017be:	89 c3                	mov    %eax,%ebx
  8017c0:	83 c4 10             	add    $0x10,%esp
  8017c3:	85 c0                	test   %eax,%eax
  8017c5:	79 14                	jns    8017db <open+0x6f>
		fd_close(fd, 0);
  8017c7:	83 ec 08             	sub    $0x8,%esp
  8017ca:	6a 00                	push   $0x0
  8017cc:	ff 75 f4             	pushl  -0xc(%ebp)
  8017cf:	e8 5d f9 ff ff       	call   801131 <fd_close>
		return r;
  8017d4:	83 c4 10             	add    $0x10,%esp
  8017d7:	89 da                	mov    %ebx,%edx
  8017d9:	eb 17                	jmp    8017f2 <open+0x86>
	}

	return fd2num(fd);
  8017db:	83 ec 0c             	sub    $0xc,%esp
  8017de:	ff 75 f4             	pushl  -0xc(%ebp)
  8017e1:	e8 2c f8 ff ff       	call   801012 <fd2num>
  8017e6:	89 c2                	mov    %eax,%edx
  8017e8:	83 c4 10             	add    $0x10,%esp
  8017eb:	eb 05                	jmp    8017f2 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017ed:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8017f2:	89 d0                	mov    %edx,%eax
  8017f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f7:	c9                   	leave  
  8017f8:	c3                   	ret    

008017f9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017f9:	55                   	push   %ebp
  8017fa:	89 e5                	mov    %esp,%ebp
  8017fc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801804:	b8 08 00 00 00       	mov    $0x8,%eax
  801809:	e8 b3 fd ff ff       	call   8015c1 <fsipc>
}
  80180e:	c9                   	leave  
  80180f:	c3                   	ret    

00801810 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801816:	68 27 2b 80 00       	push   $0x802b27
  80181b:	ff 75 0c             	pushl  0xc(%ebp)
  80181e:	e8 0a ef ff ff       	call   80072d <strcpy>
	return 0;
}
  801823:	b8 00 00 00 00       	mov    $0x0,%eax
  801828:	c9                   	leave  
  801829:	c3                   	ret    

0080182a <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80182a:	55                   	push   %ebp
  80182b:	89 e5                	mov    %esp,%ebp
  80182d:	53                   	push   %ebx
  80182e:	83 ec 10             	sub    $0x10,%esp
  801831:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801834:	53                   	push   %ebx
  801835:	e8 c1 0a 00 00       	call   8022fb <pageref>
  80183a:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  80183d:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801842:	83 f8 01             	cmp    $0x1,%eax
  801845:	75 10                	jne    801857 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801847:	83 ec 0c             	sub    $0xc,%esp
  80184a:	ff 73 0c             	pushl  0xc(%ebx)
  80184d:	e8 c0 02 00 00       	call   801b12 <nsipc_close>
  801852:	89 c2                	mov    %eax,%edx
  801854:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801857:	89 d0                	mov    %edx,%eax
  801859:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80185c:	c9                   	leave  
  80185d:	c3                   	ret    

0080185e <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801864:	6a 00                	push   $0x0
  801866:	ff 75 10             	pushl  0x10(%ebp)
  801869:	ff 75 0c             	pushl  0xc(%ebp)
  80186c:	8b 45 08             	mov    0x8(%ebp),%eax
  80186f:	ff 70 0c             	pushl  0xc(%eax)
  801872:	e8 78 03 00 00       	call   801bef <nsipc_send>
}
  801877:	c9                   	leave  
  801878:	c3                   	ret    

00801879 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
  80187c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80187f:	6a 00                	push   $0x0
  801881:	ff 75 10             	pushl  0x10(%ebp)
  801884:	ff 75 0c             	pushl  0xc(%ebp)
  801887:	8b 45 08             	mov    0x8(%ebp),%eax
  80188a:	ff 70 0c             	pushl  0xc(%eax)
  80188d:	e8 f1 02 00 00       	call   801b83 <nsipc_recv>
}
  801892:	c9                   	leave  
  801893:	c3                   	ret    

00801894 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801894:	55                   	push   %ebp
  801895:	89 e5                	mov    %esp,%ebp
  801897:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80189a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80189d:	52                   	push   %edx
  80189e:	50                   	push   %eax
  80189f:	e8 e4 f7 ff ff       	call   801088 <fd_lookup>
  8018a4:	83 c4 10             	add    $0x10,%esp
  8018a7:	85 c0                	test   %eax,%eax
  8018a9:	78 17                	js     8018c2 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8018ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ae:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8018b4:	39 08                	cmp    %ecx,(%eax)
  8018b6:	75 05                	jne    8018bd <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8018b8:	8b 40 0c             	mov    0xc(%eax),%eax
  8018bb:	eb 05                	jmp    8018c2 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8018bd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8018c2:	c9                   	leave  
  8018c3:	c3                   	ret    

008018c4 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8018c4:	55                   	push   %ebp
  8018c5:	89 e5                	mov    %esp,%ebp
  8018c7:	56                   	push   %esi
  8018c8:	53                   	push   %ebx
  8018c9:	83 ec 1c             	sub    $0x1c,%esp
  8018cc:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8018ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d1:	50                   	push   %eax
  8018d2:	e8 62 f7 ff ff       	call   801039 <fd_alloc>
  8018d7:	89 c3                	mov    %eax,%ebx
  8018d9:	83 c4 10             	add    $0x10,%esp
  8018dc:	85 c0                	test   %eax,%eax
  8018de:	78 1b                	js     8018fb <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8018e0:	83 ec 04             	sub    $0x4,%esp
  8018e3:	68 07 04 00 00       	push   $0x407
  8018e8:	ff 75 f4             	pushl  -0xc(%ebp)
  8018eb:	6a 00                	push   $0x0
  8018ed:	e8 3e f2 ff ff       	call   800b30 <sys_page_alloc>
  8018f2:	89 c3                	mov    %eax,%ebx
  8018f4:	83 c4 10             	add    $0x10,%esp
  8018f7:	85 c0                	test   %eax,%eax
  8018f9:	79 10                	jns    80190b <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8018fb:	83 ec 0c             	sub    $0xc,%esp
  8018fe:	56                   	push   %esi
  8018ff:	e8 0e 02 00 00       	call   801b12 <nsipc_close>
		return r;
  801904:	83 c4 10             	add    $0x10,%esp
  801907:	89 d8                	mov    %ebx,%eax
  801909:	eb 24                	jmp    80192f <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80190b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801911:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801914:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801916:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801919:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801920:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801923:	83 ec 0c             	sub    $0xc,%esp
  801926:	50                   	push   %eax
  801927:	e8 e6 f6 ff ff       	call   801012 <fd2num>
  80192c:	83 c4 10             	add    $0x10,%esp
}
  80192f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801932:	5b                   	pop    %ebx
  801933:	5e                   	pop    %esi
  801934:	5d                   	pop    %ebp
  801935:	c3                   	ret    

00801936 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80193c:	8b 45 08             	mov    0x8(%ebp),%eax
  80193f:	e8 50 ff ff ff       	call   801894 <fd2sockid>
		return r;
  801944:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801946:	85 c0                	test   %eax,%eax
  801948:	78 1f                	js     801969 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80194a:	83 ec 04             	sub    $0x4,%esp
  80194d:	ff 75 10             	pushl  0x10(%ebp)
  801950:	ff 75 0c             	pushl  0xc(%ebp)
  801953:	50                   	push   %eax
  801954:	e8 12 01 00 00       	call   801a6b <nsipc_accept>
  801959:	83 c4 10             	add    $0x10,%esp
		return r;
  80195c:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80195e:	85 c0                	test   %eax,%eax
  801960:	78 07                	js     801969 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801962:	e8 5d ff ff ff       	call   8018c4 <alloc_sockfd>
  801967:	89 c1                	mov    %eax,%ecx
}
  801969:	89 c8                	mov    %ecx,%eax
  80196b:	c9                   	leave  
  80196c:	c3                   	ret    

0080196d <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80196d:	55                   	push   %ebp
  80196e:	89 e5                	mov    %esp,%ebp
  801970:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801973:	8b 45 08             	mov    0x8(%ebp),%eax
  801976:	e8 19 ff ff ff       	call   801894 <fd2sockid>
  80197b:	85 c0                	test   %eax,%eax
  80197d:	78 12                	js     801991 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  80197f:	83 ec 04             	sub    $0x4,%esp
  801982:	ff 75 10             	pushl  0x10(%ebp)
  801985:	ff 75 0c             	pushl  0xc(%ebp)
  801988:	50                   	push   %eax
  801989:	e8 2d 01 00 00       	call   801abb <nsipc_bind>
  80198e:	83 c4 10             	add    $0x10,%esp
}
  801991:	c9                   	leave  
  801992:	c3                   	ret    

00801993 <shutdown>:

int
shutdown(int s, int how)
{
  801993:	55                   	push   %ebp
  801994:	89 e5                	mov    %esp,%ebp
  801996:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801999:	8b 45 08             	mov    0x8(%ebp),%eax
  80199c:	e8 f3 fe ff ff       	call   801894 <fd2sockid>
  8019a1:	85 c0                	test   %eax,%eax
  8019a3:	78 0f                	js     8019b4 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8019a5:	83 ec 08             	sub    $0x8,%esp
  8019a8:	ff 75 0c             	pushl  0xc(%ebp)
  8019ab:	50                   	push   %eax
  8019ac:	e8 3f 01 00 00       	call   801af0 <nsipc_shutdown>
  8019b1:	83 c4 10             	add    $0x10,%esp
}
  8019b4:	c9                   	leave  
  8019b5:	c3                   	ret    

008019b6 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bf:	e8 d0 fe ff ff       	call   801894 <fd2sockid>
  8019c4:	85 c0                	test   %eax,%eax
  8019c6:	78 12                	js     8019da <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8019c8:	83 ec 04             	sub    $0x4,%esp
  8019cb:	ff 75 10             	pushl  0x10(%ebp)
  8019ce:	ff 75 0c             	pushl  0xc(%ebp)
  8019d1:	50                   	push   %eax
  8019d2:	e8 55 01 00 00       	call   801b2c <nsipc_connect>
  8019d7:	83 c4 10             	add    $0x10,%esp
}
  8019da:	c9                   	leave  
  8019db:	c3                   	ret    

008019dc <listen>:

int
listen(int s, int backlog)
{
  8019dc:	55                   	push   %ebp
  8019dd:	89 e5                	mov    %esp,%ebp
  8019df:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e5:	e8 aa fe ff ff       	call   801894 <fd2sockid>
  8019ea:	85 c0                	test   %eax,%eax
  8019ec:	78 0f                	js     8019fd <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8019ee:	83 ec 08             	sub    $0x8,%esp
  8019f1:	ff 75 0c             	pushl  0xc(%ebp)
  8019f4:	50                   	push   %eax
  8019f5:	e8 67 01 00 00       	call   801b61 <nsipc_listen>
  8019fa:	83 c4 10             	add    $0x10,%esp
}
  8019fd:	c9                   	leave  
  8019fe:	c3                   	ret    

008019ff <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8019ff:	55                   	push   %ebp
  801a00:	89 e5                	mov    %esp,%ebp
  801a02:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a05:	ff 75 10             	pushl  0x10(%ebp)
  801a08:	ff 75 0c             	pushl  0xc(%ebp)
  801a0b:	ff 75 08             	pushl  0x8(%ebp)
  801a0e:	e8 3a 02 00 00       	call   801c4d <nsipc_socket>
  801a13:	83 c4 10             	add    $0x10,%esp
  801a16:	85 c0                	test   %eax,%eax
  801a18:	78 05                	js     801a1f <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801a1a:	e8 a5 fe ff ff       	call   8018c4 <alloc_sockfd>
}
  801a1f:	c9                   	leave  
  801a20:	c3                   	ret    

00801a21 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801a21:	55                   	push   %ebp
  801a22:	89 e5                	mov    %esp,%ebp
  801a24:	53                   	push   %ebx
  801a25:	83 ec 04             	sub    $0x4,%esp
  801a28:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801a2a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801a31:	75 12                	jne    801a45 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801a33:	83 ec 0c             	sub    $0xc,%esp
  801a36:	6a 02                	push   $0x2
  801a38:	e8 85 08 00 00       	call   8022c2 <ipc_find_env>
  801a3d:	a3 04 40 80 00       	mov    %eax,0x804004
  801a42:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801a45:	6a 07                	push   $0x7
  801a47:	68 00 60 80 00       	push   $0x806000
  801a4c:	53                   	push   %ebx
  801a4d:	ff 35 04 40 80 00    	pushl  0x804004
  801a53:	e8 16 08 00 00       	call   80226e <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801a58:	83 c4 0c             	add    $0xc,%esp
  801a5b:	6a 00                	push   $0x0
  801a5d:	6a 00                	push   $0x0
  801a5f:	6a 00                	push   $0x0
  801a61:	e8 a1 07 00 00       	call   802207 <ipc_recv>
}
  801a66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a69:	c9                   	leave  
  801a6a:	c3                   	ret    

00801a6b <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	56                   	push   %esi
  801a6f:	53                   	push   %ebx
  801a70:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801a73:	8b 45 08             	mov    0x8(%ebp),%eax
  801a76:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801a7b:	8b 06                	mov    (%esi),%eax
  801a7d:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801a82:	b8 01 00 00 00       	mov    $0x1,%eax
  801a87:	e8 95 ff ff ff       	call   801a21 <nsipc>
  801a8c:	89 c3                	mov    %eax,%ebx
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	78 20                	js     801ab2 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801a92:	83 ec 04             	sub    $0x4,%esp
  801a95:	ff 35 10 60 80 00    	pushl  0x806010
  801a9b:	68 00 60 80 00       	push   $0x806000
  801aa0:	ff 75 0c             	pushl  0xc(%ebp)
  801aa3:	e8 17 ee ff ff       	call   8008bf <memmove>
		*addrlen = ret->ret_addrlen;
  801aa8:	a1 10 60 80 00       	mov    0x806010,%eax
  801aad:	89 06                	mov    %eax,(%esi)
  801aaf:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801ab2:	89 d8                	mov    %ebx,%eax
  801ab4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab7:	5b                   	pop    %ebx
  801ab8:	5e                   	pop    %esi
  801ab9:	5d                   	pop    %ebp
  801aba:	c3                   	ret    

00801abb <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	53                   	push   %ebx
  801abf:	83 ec 08             	sub    $0x8,%esp
  801ac2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801ac5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac8:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801acd:	53                   	push   %ebx
  801ace:	ff 75 0c             	pushl  0xc(%ebp)
  801ad1:	68 04 60 80 00       	push   $0x806004
  801ad6:	e8 e4 ed ff ff       	call   8008bf <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801adb:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801ae1:	b8 02 00 00 00       	mov    $0x2,%eax
  801ae6:	e8 36 ff ff ff       	call   801a21 <nsipc>
}
  801aeb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aee:	c9                   	leave  
  801aef:	c3                   	ret    

00801af0 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801af0:	55                   	push   %ebp
  801af1:	89 e5                	mov    %esp,%ebp
  801af3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801af6:	8b 45 08             	mov    0x8(%ebp),%eax
  801af9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801afe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b01:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801b06:	b8 03 00 00 00       	mov    $0x3,%eax
  801b0b:	e8 11 ff ff ff       	call   801a21 <nsipc>
}
  801b10:	c9                   	leave  
  801b11:	c3                   	ret    

00801b12 <nsipc_close>:

int
nsipc_close(int s)
{
  801b12:	55                   	push   %ebp
  801b13:	89 e5                	mov    %esp,%ebp
  801b15:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b18:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801b20:	b8 04 00 00 00       	mov    $0x4,%eax
  801b25:	e8 f7 fe ff ff       	call   801a21 <nsipc>
}
  801b2a:	c9                   	leave  
  801b2b:	c3                   	ret    

00801b2c <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b2c:	55                   	push   %ebp
  801b2d:	89 e5                	mov    %esp,%ebp
  801b2f:	53                   	push   %ebx
  801b30:	83 ec 08             	sub    $0x8,%esp
  801b33:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801b36:	8b 45 08             	mov    0x8(%ebp),%eax
  801b39:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801b3e:	53                   	push   %ebx
  801b3f:	ff 75 0c             	pushl  0xc(%ebp)
  801b42:	68 04 60 80 00       	push   $0x806004
  801b47:	e8 73 ed ff ff       	call   8008bf <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801b4c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801b52:	b8 05 00 00 00       	mov    $0x5,%eax
  801b57:	e8 c5 fe ff ff       	call   801a21 <nsipc>
}
  801b5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b5f:	c9                   	leave  
  801b60:	c3                   	ret    

00801b61 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801b61:	55                   	push   %ebp
  801b62:	89 e5                	mov    %esp,%ebp
  801b64:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801b67:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801b6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b72:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801b77:	b8 06 00 00 00       	mov    $0x6,%eax
  801b7c:	e8 a0 fe ff ff       	call   801a21 <nsipc>
}
  801b81:	c9                   	leave  
  801b82:	c3                   	ret    

00801b83 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801b83:	55                   	push   %ebp
  801b84:	89 e5                	mov    %esp,%ebp
  801b86:	56                   	push   %esi
  801b87:	53                   	push   %ebx
  801b88:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801b93:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801b99:	8b 45 14             	mov    0x14(%ebp),%eax
  801b9c:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ba1:	b8 07 00 00 00       	mov    $0x7,%eax
  801ba6:	e8 76 fe ff ff       	call   801a21 <nsipc>
  801bab:	89 c3                	mov    %eax,%ebx
  801bad:	85 c0                	test   %eax,%eax
  801baf:	78 35                	js     801be6 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801bb1:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801bb6:	7f 04                	jg     801bbc <nsipc_recv+0x39>
  801bb8:	39 c6                	cmp    %eax,%esi
  801bba:	7d 16                	jge    801bd2 <nsipc_recv+0x4f>
  801bbc:	68 33 2b 80 00       	push   $0x802b33
  801bc1:	68 fb 2a 80 00       	push   $0x802afb
  801bc6:	6a 62                	push   $0x62
  801bc8:	68 48 2b 80 00       	push   $0x802b48
  801bcd:	e8 84 05 00 00       	call   802156 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801bd2:	83 ec 04             	sub    $0x4,%esp
  801bd5:	50                   	push   %eax
  801bd6:	68 00 60 80 00       	push   $0x806000
  801bdb:	ff 75 0c             	pushl  0xc(%ebp)
  801bde:	e8 dc ec ff ff       	call   8008bf <memmove>
  801be3:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801be6:	89 d8                	mov    %ebx,%eax
  801be8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801beb:	5b                   	pop    %ebx
  801bec:	5e                   	pop    %esi
  801bed:	5d                   	pop    %ebp
  801bee:	c3                   	ret    

00801bef <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801bef:	55                   	push   %ebp
  801bf0:	89 e5                	mov    %esp,%ebp
  801bf2:	53                   	push   %ebx
  801bf3:	83 ec 04             	sub    $0x4,%esp
  801bf6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801bf9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfc:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801c01:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c07:	7e 16                	jle    801c1f <nsipc_send+0x30>
  801c09:	68 54 2b 80 00       	push   $0x802b54
  801c0e:	68 fb 2a 80 00       	push   $0x802afb
  801c13:	6a 6d                	push   $0x6d
  801c15:	68 48 2b 80 00       	push   $0x802b48
  801c1a:	e8 37 05 00 00       	call   802156 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c1f:	83 ec 04             	sub    $0x4,%esp
  801c22:	53                   	push   %ebx
  801c23:	ff 75 0c             	pushl  0xc(%ebp)
  801c26:	68 0c 60 80 00       	push   $0x80600c
  801c2b:	e8 8f ec ff ff       	call   8008bf <memmove>
	nsipcbuf.send.req_size = size;
  801c30:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801c36:	8b 45 14             	mov    0x14(%ebp),%eax
  801c39:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801c3e:	b8 08 00 00 00       	mov    $0x8,%eax
  801c43:	e8 d9 fd ff ff       	call   801a21 <nsipc>
}
  801c48:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c4b:	c9                   	leave  
  801c4c:	c3                   	ret    

00801c4d <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801c4d:	55                   	push   %ebp
  801c4e:	89 e5                	mov    %esp,%ebp
  801c50:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801c53:	8b 45 08             	mov    0x8(%ebp),%eax
  801c56:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801c5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c5e:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801c63:	8b 45 10             	mov    0x10(%ebp),%eax
  801c66:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801c6b:	b8 09 00 00 00       	mov    $0x9,%eax
  801c70:	e8 ac fd ff ff       	call   801a21 <nsipc>
}
  801c75:	c9                   	leave  
  801c76:	c3                   	ret    

00801c77 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c77:	55                   	push   %ebp
  801c78:	89 e5                	mov    %esp,%ebp
  801c7a:	56                   	push   %esi
  801c7b:	53                   	push   %ebx
  801c7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c7f:	83 ec 0c             	sub    $0xc,%esp
  801c82:	ff 75 08             	pushl  0x8(%ebp)
  801c85:	e8 98 f3 ff ff       	call   801022 <fd2data>
  801c8a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c8c:	83 c4 08             	add    $0x8,%esp
  801c8f:	68 60 2b 80 00       	push   $0x802b60
  801c94:	53                   	push   %ebx
  801c95:	e8 93 ea ff ff       	call   80072d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c9a:	8b 46 04             	mov    0x4(%esi),%eax
  801c9d:	2b 06                	sub    (%esi),%eax
  801c9f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ca5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cac:	00 00 00 
	stat->st_dev = &devpipe;
  801caf:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801cb6:	30 80 00 
	return 0;
}
  801cb9:	b8 00 00 00 00       	mov    $0x0,%eax
  801cbe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cc1:	5b                   	pop    %ebx
  801cc2:	5e                   	pop    %esi
  801cc3:	5d                   	pop    %ebp
  801cc4:	c3                   	ret    

00801cc5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cc5:	55                   	push   %ebp
  801cc6:	89 e5                	mov    %esp,%ebp
  801cc8:	53                   	push   %ebx
  801cc9:	83 ec 0c             	sub    $0xc,%esp
  801ccc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ccf:	53                   	push   %ebx
  801cd0:	6a 00                	push   $0x0
  801cd2:	e8 de ee ff ff       	call   800bb5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cd7:	89 1c 24             	mov    %ebx,(%esp)
  801cda:	e8 43 f3 ff ff       	call   801022 <fd2data>
  801cdf:	83 c4 08             	add    $0x8,%esp
  801ce2:	50                   	push   %eax
  801ce3:	6a 00                	push   $0x0
  801ce5:	e8 cb ee ff ff       	call   800bb5 <sys_page_unmap>
}
  801cea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ced:	c9                   	leave  
  801cee:	c3                   	ret    

00801cef <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801cef:	55                   	push   %ebp
  801cf0:	89 e5                	mov    %esp,%ebp
  801cf2:	57                   	push   %edi
  801cf3:	56                   	push   %esi
  801cf4:	53                   	push   %ebx
  801cf5:	83 ec 1c             	sub    $0x1c,%esp
  801cf8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801cfb:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801cfd:	a1 08 40 80 00       	mov    0x804008,%eax
  801d02:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d05:	83 ec 0c             	sub    $0xc,%esp
  801d08:	ff 75 e0             	pushl  -0x20(%ebp)
  801d0b:	e8 eb 05 00 00       	call   8022fb <pageref>
  801d10:	89 c3                	mov    %eax,%ebx
  801d12:	89 3c 24             	mov    %edi,(%esp)
  801d15:	e8 e1 05 00 00       	call   8022fb <pageref>
  801d1a:	83 c4 10             	add    $0x10,%esp
  801d1d:	39 c3                	cmp    %eax,%ebx
  801d1f:	0f 94 c1             	sete   %cl
  801d22:	0f b6 c9             	movzbl %cl,%ecx
  801d25:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d28:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801d2e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d31:	39 ce                	cmp    %ecx,%esi
  801d33:	74 1b                	je     801d50 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801d35:	39 c3                	cmp    %eax,%ebx
  801d37:	75 c4                	jne    801cfd <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d39:	8b 42 58             	mov    0x58(%edx),%eax
  801d3c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d3f:	50                   	push   %eax
  801d40:	56                   	push   %esi
  801d41:	68 67 2b 80 00       	push   $0x802b67
  801d46:	e8 5d e4 ff ff       	call   8001a8 <cprintf>
  801d4b:	83 c4 10             	add    $0x10,%esp
  801d4e:	eb ad                	jmp    801cfd <_pipeisclosed+0xe>
	}
}
  801d50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d56:	5b                   	pop    %ebx
  801d57:	5e                   	pop    %esi
  801d58:	5f                   	pop    %edi
  801d59:	5d                   	pop    %ebp
  801d5a:	c3                   	ret    

00801d5b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d5b:	55                   	push   %ebp
  801d5c:	89 e5                	mov    %esp,%ebp
  801d5e:	57                   	push   %edi
  801d5f:	56                   	push   %esi
  801d60:	53                   	push   %ebx
  801d61:	83 ec 28             	sub    $0x28,%esp
  801d64:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d67:	56                   	push   %esi
  801d68:	e8 b5 f2 ff ff       	call   801022 <fd2data>
  801d6d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d6f:	83 c4 10             	add    $0x10,%esp
  801d72:	bf 00 00 00 00       	mov    $0x0,%edi
  801d77:	eb 4b                	jmp    801dc4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d79:	89 da                	mov    %ebx,%edx
  801d7b:	89 f0                	mov    %esi,%eax
  801d7d:	e8 6d ff ff ff       	call   801cef <_pipeisclosed>
  801d82:	85 c0                	test   %eax,%eax
  801d84:	75 48                	jne    801dce <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d86:	e8 86 ed ff ff       	call   800b11 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d8b:	8b 43 04             	mov    0x4(%ebx),%eax
  801d8e:	8b 0b                	mov    (%ebx),%ecx
  801d90:	8d 51 20             	lea    0x20(%ecx),%edx
  801d93:	39 d0                	cmp    %edx,%eax
  801d95:	73 e2                	jae    801d79 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d9a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d9e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801da1:	89 c2                	mov    %eax,%edx
  801da3:	c1 fa 1f             	sar    $0x1f,%edx
  801da6:	89 d1                	mov    %edx,%ecx
  801da8:	c1 e9 1b             	shr    $0x1b,%ecx
  801dab:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801dae:	83 e2 1f             	and    $0x1f,%edx
  801db1:	29 ca                	sub    %ecx,%edx
  801db3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801db7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801dbb:	83 c0 01             	add    $0x1,%eax
  801dbe:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dc1:	83 c7 01             	add    $0x1,%edi
  801dc4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801dc7:	75 c2                	jne    801d8b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801dc9:	8b 45 10             	mov    0x10(%ebp),%eax
  801dcc:	eb 05                	jmp    801dd3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dce:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801dd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dd6:	5b                   	pop    %ebx
  801dd7:	5e                   	pop    %esi
  801dd8:	5f                   	pop    %edi
  801dd9:	5d                   	pop    %ebp
  801dda:	c3                   	ret    

00801ddb <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ddb:	55                   	push   %ebp
  801ddc:	89 e5                	mov    %esp,%ebp
  801dde:	57                   	push   %edi
  801ddf:	56                   	push   %esi
  801de0:	53                   	push   %ebx
  801de1:	83 ec 18             	sub    $0x18,%esp
  801de4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801de7:	57                   	push   %edi
  801de8:	e8 35 f2 ff ff       	call   801022 <fd2data>
  801ded:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801def:	83 c4 10             	add    $0x10,%esp
  801df2:	bb 00 00 00 00       	mov    $0x0,%ebx
  801df7:	eb 3d                	jmp    801e36 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801df9:	85 db                	test   %ebx,%ebx
  801dfb:	74 04                	je     801e01 <devpipe_read+0x26>
				return i;
  801dfd:	89 d8                	mov    %ebx,%eax
  801dff:	eb 44                	jmp    801e45 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e01:	89 f2                	mov    %esi,%edx
  801e03:	89 f8                	mov    %edi,%eax
  801e05:	e8 e5 fe ff ff       	call   801cef <_pipeisclosed>
  801e0a:	85 c0                	test   %eax,%eax
  801e0c:	75 32                	jne    801e40 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e0e:	e8 fe ec ff ff       	call   800b11 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e13:	8b 06                	mov    (%esi),%eax
  801e15:	3b 46 04             	cmp    0x4(%esi),%eax
  801e18:	74 df                	je     801df9 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e1a:	99                   	cltd   
  801e1b:	c1 ea 1b             	shr    $0x1b,%edx
  801e1e:	01 d0                	add    %edx,%eax
  801e20:	83 e0 1f             	and    $0x1f,%eax
  801e23:	29 d0                	sub    %edx,%eax
  801e25:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e2d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e30:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e33:	83 c3 01             	add    $0x1,%ebx
  801e36:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e39:	75 d8                	jne    801e13 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e3b:	8b 45 10             	mov    0x10(%ebp),%eax
  801e3e:	eb 05                	jmp    801e45 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e40:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e48:	5b                   	pop    %ebx
  801e49:	5e                   	pop    %esi
  801e4a:	5f                   	pop    %edi
  801e4b:	5d                   	pop    %ebp
  801e4c:	c3                   	ret    

00801e4d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e4d:	55                   	push   %ebp
  801e4e:	89 e5                	mov    %esp,%ebp
  801e50:	56                   	push   %esi
  801e51:	53                   	push   %ebx
  801e52:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e55:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e58:	50                   	push   %eax
  801e59:	e8 db f1 ff ff       	call   801039 <fd_alloc>
  801e5e:	83 c4 10             	add    $0x10,%esp
  801e61:	89 c2                	mov    %eax,%edx
  801e63:	85 c0                	test   %eax,%eax
  801e65:	0f 88 2c 01 00 00    	js     801f97 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e6b:	83 ec 04             	sub    $0x4,%esp
  801e6e:	68 07 04 00 00       	push   $0x407
  801e73:	ff 75 f4             	pushl  -0xc(%ebp)
  801e76:	6a 00                	push   $0x0
  801e78:	e8 b3 ec ff ff       	call   800b30 <sys_page_alloc>
  801e7d:	83 c4 10             	add    $0x10,%esp
  801e80:	89 c2                	mov    %eax,%edx
  801e82:	85 c0                	test   %eax,%eax
  801e84:	0f 88 0d 01 00 00    	js     801f97 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e8a:	83 ec 0c             	sub    $0xc,%esp
  801e8d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e90:	50                   	push   %eax
  801e91:	e8 a3 f1 ff ff       	call   801039 <fd_alloc>
  801e96:	89 c3                	mov    %eax,%ebx
  801e98:	83 c4 10             	add    $0x10,%esp
  801e9b:	85 c0                	test   %eax,%eax
  801e9d:	0f 88 e2 00 00 00    	js     801f85 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ea3:	83 ec 04             	sub    $0x4,%esp
  801ea6:	68 07 04 00 00       	push   $0x407
  801eab:	ff 75 f0             	pushl  -0x10(%ebp)
  801eae:	6a 00                	push   $0x0
  801eb0:	e8 7b ec ff ff       	call   800b30 <sys_page_alloc>
  801eb5:	89 c3                	mov    %eax,%ebx
  801eb7:	83 c4 10             	add    $0x10,%esp
  801eba:	85 c0                	test   %eax,%eax
  801ebc:	0f 88 c3 00 00 00    	js     801f85 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ec2:	83 ec 0c             	sub    $0xc,%esp
  801ec5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ec8:	e8 55 f1 ff ff       	call   801022 <fd2data>
  801ecd:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ecf:	83 c4 0c             	add    $0xc,%esp
  801ed2:	68 07 04 00 00       	push   $0x407
  801ed7:	50                   	push   %eax
  801ed8:	6a 00                	push   $0x0
  801eda:	e8 51 ec ff ff       	call   800b30 <sys_page_alloc>
  801edf:	89 c3                	mov    %eax,%ebx
  801ee1:	83 c4 10             	add    $0x10,%esp
  801ee4:	85 c0                	test   %eax,%eax
  801ee6:	0f 88 89 00 00 00    	js     801f75 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eec:	83 ec 0c             	sub    $0xc,%esp
  801eef:	ff 75 f0             	pushl  -0x10(%ebp)
  801ef2:	e8 2b f1 ff ff       	call   801022 <fd2data>
  801ef7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801efe:	50                   	push   %eax
  801eff:	6a 00                	push   $0x0
  801f01:	56                   	push   %esi
  801f02:	6a 00                	push   $0x0
  801f04:	e8 6a ec ff ff       	call   800b73 <sys_page_map>
  801f09:	89 c3                	mov    %eax,%ebx
  801f0b:	83 c4 20             	add    $0x20,%esp
  801f0e:	85 c0                	test   %eax,%eax
  801f10:	78 55                	js     801f67 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f12:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f1b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f20:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f27:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f30:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f32:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f35:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f3c:	83 ec 0c             	sub    $0xc,%esp
  801f3f:	ff 75 f4             	pushl  -0xc(%ebp)
  801f42:	e8 cb f0 ff ff       	call   801012 <fd2num>
  801f47:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f4a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f4c:	83 c4 04             	add    $0x4,%esp
  801f4f:	ff 75 f0             	pushl  -0x10(%ebp)
  801f52:	e8 bb f0 ff ff       	call   801012 <fd2num>
  801f57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f5a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f5d:	83 c4 10             	add    $0x10,%esp
  801f60:	ba 00 00 00 00       	mov    $0x0,%edx
  801f65:	eb 30                	jmp    801f97 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f67:	83 ec 08             	sub    $0x8,%esp
  801f6a:	56                   	push   %esi
  801f6b:	6a 00                	push   $0x0
  801f6d:	e8 43 ec ff ff       	call   800bb5 <sys_page_unmap>
  801f72:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f75:	83 ec 08             	sub    $0x8,%esp
  801f78:	ff 75 f0             	pushl  -0x10(%ebp)
  801f7b:	6a 00                	push   $0x0
  801f7d:	e8 33 ec ff ff       	call   800bb5 <sys_page_unmap>
  801f82:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f85:	83 ec 08             	sub    $0x8,%esp
  801f88:	ff 75 f4             	pushl  -0xc(%ebp)
  801f8b:	6a 00                	push   $0x0
  801f8d:	e8 23 ec ff ff       	call   800bb5 <sys_page_unmap>
  801f92:	83 c4 10             	add    $0x10,%esp
  801f95:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f97:	89 d0                	mov    %edx,%eax
  801f99:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f9c:	5b                   	pop    %ebx
  801f9d:	5e                   	pop    %esi
  801f9e:	5d                   	pop    %ebp
  801f9f:	c3                   	ret    

00801fa0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801fa0:	55                   	push   %ebp
  801fa1:	89 e5                	mov    %esp,%ebp
  801fa3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fa6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fa9:	50                   	push   %eax
  801faa:	ff 75 08             	pushl  0x8(%ebp)
  801fad:	e8 d6 f0 ff ff       	call   801088 <fd_lookup>
  801fb2:	83 c4 10             	add    $0x10,%esp
  801fb5:	85 c0                	test   %eax,%eax
  801fb7:	78 18                	js     801fd1 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fb9:	83 ec 0c             	sub    $0xc,%esp
  801fbc:	ff 75 f4             	pushl  -0xc(%ebp)
  801fbf:	e8 5e f0 ff ff       	call   801022 <fd2data>
	return _pipeisclosed(fd, p);
  801fc4:	89 c2                	mov    %eax,%edx
  801fc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc9:	e8 21 fd ff ff       	call   801cef <_pipeisclosed>
  801fce:	83 c4 10             	add    $0x10,%esp
}
  801fd1:	c9                   	leave  
  801fd2:	c3                   	ret    

00801fd3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fd3:	55                   	push   %ebp
  801fd4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fd6:	b8 00 00 00 00       	mov    $0x0,%eax
  801fdb:	5d                   	pop    %ebp
  801fdc:	c3                   	ret    

00801fdd <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fdd:	55                   	push   %ebp
  801fde:	89 e5                	mov    %esp,%ebp
  801fe0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801fe3:	68 7f 2b 80 00       	push   $0x802b7f
  801fe8:	ff 75 0c             	pushl  0xc(%ebp)
  801feb:	e8 3d e7 ff ff       	call   80072d <strcpy>
	return 0;
}
  801ff0:	b8 00 00 00 00       	mov    $0x0,%eax
  801ff5:	c9                   	leave  
  801ff6:	c3                   	ret    

00801ff7 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ff7:	55                   	push   %ebp
  801ff8:	89 e5                	mov    %esp,%ebp
  801ffa:	57                   	push   %edi
  801ffb:	56                   	push   %esi
  801ffc:	53                   	push   %ebx
  801ffd:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802003:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802008:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80200e:	eb 2d                	jmp    80203d <devcons_write+0x46>
		m = n - tot;
  802010:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802013:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802015:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802018:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80201d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802020:	83 ec 04             	sub    $0x4,%esp
  802023:	53                   	push   %ebx
  802024:	03 45 0c             	add    0xc(%ebp),%eax
  802027:	50                   	push   %eax
  802028:	57                   	push   %edi
  802029:	e8 91 e8 ff ff       	call   8008bf <memmove>
		sys_cputs(buf, m);
  80202e:	83 c4 08             	add    $0x8,%esp
  802031:	53                   	push   %ebx
  802032:	57                   	push   %edi
  802033:	e8 3c ea ff ff       	call   800a74 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802038:	01 de                	add    %ebx,%esi
  80203a:	83 c4 10             	add    $0x10,%esp
  80203d:	89 f0                	mov    %esi,%eax
  80203f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802042:	72 cc                	jb     802010 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802044:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802047:	5b                   	pop    %ebx
  802048:	5e                   	pop    %esi
  802049:	5f                   	pop    %edi
  80204a:	5d                   	pop    %ebp
  80204b:	c3                   	ret    

0080204c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80204c:	55                   	push   %ebp
  80204d:	89 e5                	mov    %esp,%ebp
  80204f:	83 ec 08             	sub    $0x8,%esp
  802052:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802057:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80205b:	74 2a                	je     802087 <devcons_read+0x3b>
  80205d:	eb 05                	jmp    802064 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80205f:	e8 ad ea ff ff       	call   800b11 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802064:	e8 29 ea ff ff       	call   800a92 <sys_cgetc>
  802069:	85 c0                	test   %eax,%eax
  80206b:	74 f2                	je     80205f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80206d:	85 c0                	test   %eax,%eax
  80206f:	78 16                	js     802087 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802071:	83 f8 04             	cmp    $0x4,%eax
  802074:	74 0c                	je     802082 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802076:	8b 55 0c             	mov    0xc(%ebp),%edx
  802079:	88 02                	mov    %al,(%edx)
	return 1;
  80207b:	b8 01 00 00 00       	mov    $0x1,%eax
  802080:	eb 05                	jmp    802087 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802082:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802087:	c9                   	leave  
  802088:	c3                   	ret    

00802089 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802089:	55                   	push   %ebp
  80208a:	89 e5                	mov    %esp,%ebp
  80208c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80208f:	8b 45 08             	mov    0x8(%ebp),%eax
  802092:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802095:	6a 01                	push   $0x1
  802097:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80209a:	50                   	push   %eax
  80209b:	e8 d4 e9 ff ff       	call   800a74 <sys_cputs>
}
  8020a0:	83 c4 10             	add    $0x10,%esp
  8020a3:	c9                   	leave  
  8020a4:	c3                   	ret    

008020a5 <getchar>:

int
getchar(void)
{
  8020a5:	55                   	push   %ebp
  8020a6:	89 e5                	mov    %esp,%ebp
  8020a8:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020ab:	6a 01                	push   $0x1
  8020ad:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020b0:	50                   	push   %eax
  8020b1:	6a 00                	push   $0x0
  8020b3:	e8 36 f2 ff ff       	call   8012ee <read>
	if (r < 0)
  8020b8:	83 c4 10             	add    $0x10,%esp
  8020bb:	85 c0                	test   %eax,%eax
  8020bd:	78 0f                	js     8020ce <getchar+0x29>
		return r;
	if (r < 1)
  8020bf:	85 c0                	test   %eax,%eax
  8020c1:	7e 06                	jle    8020c9 <getchar+0x24>
		return -E_EOF;
	return c;
  8020c3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020c7:	eb 05                	jmp    8020ce <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020c9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020ce:	c9                   	leave  
  8020cf:	c3                   	ret    

008020d0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020d0:	55                   	push   %ebp
  8020d1:	89 e5                	mov    %esp,%ebp
  8020d3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020d9:	50                   	push   %eax
  8020da:	ff 75 08             	pushl  0x8(%ebp)
  8020dd:	e8 a6 ef ff ff       	call   801088 <fd_lookup>
  8020e2:	83 c4 10             	add    $0x10,%esp
  8020e5:	85 c0                	test   %eax,%eax
  8020e7:	78 11                	js     8020fa <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ec:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8020f2:	39 10                	cmp    %edx,(%eax)
  8020f4:	0f 94 c0             	sete   %al
  8020f7:	0f b6 c0             	movzbl %al,%eax
}
  8020fa:	c9                   	leave  
  8020fb:	c3                   	ret    

008020fc <opencons>:

int
opencons(void)
{
  8020fc:	55                   	push   %ebp
  8020fd:	89 e5                	mov    %esp,%ebp
  8020ff:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802102:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802105:	50                   	push   %eax
  802106:	e8 2e ef ff ff       	call   801039 <fd_alloc>
  80210b:	83 c4 10             	add    $0x10,%esp
		return r;
  80210e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802110:	85 c0                	test   %eax,%eax
  802112:	78 3e                	js     802152 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802114:	83 ec 04             	sub    $0x4,%esp
  802117:	68 07 04 00 00       	push   $0x407
  80211c:	ff 75 f4             	pushl  -0xc(%ebp)
  80211f:	6a 00                	push   $0x0
  802121:	e8 0a ea ff ff       	call   800b30 <sys_page_alloc>
  802126:	83 c4 10             	add    $0x10,%esp
		return r;
  802129:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80212b:	85 c0                	test   %eax,%eax
  80212d:	78 23                	js     802152 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80212f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802135:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802138:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80213a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802144:	83 ec 0c             	sub    $0xc,%esp
  802147:	50                   	push   %eax
  802148:	e8 c5 ee ff ff       	call   801012 <fd2num>
  80214d:	89 c2                	mov    %eax,%edx
  80214f:	83 c4 10             	add    $0x10,%esp
}
  802152:	89 d0                	mov    %edx,%eax
  802154:	c9                   	leave  
  802155:	c3                   	ret    

00802156 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802156:	55                   	push   %ebp
  802157:	89 e5                	mov    %esp,%ebp
  802159:	56                   	push   %esi
  80215a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80215b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80215e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802164:	e8 89 e9 ff ff       	call   800af2 <sys_getenvid>
  802169:	83 ec 0c             	sub    $0xc,%esp
  80216c:	ff 75 0c             	pushl  0xc(%ebp)
  80216f:	ff 75 08             	pushl  0x8(%ebp)
  802172:	56                   	push   %esi
  802173:	50                   	push   %eax
  802174:	68 8c 2b 80 00       	push   $0x802b8c
  802179:	e8 2a e0 ff ff       	call   8001a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80217e:	83 c4 18             	add    $0x18,%esp
  802181:	53                   	push   %ebx
  802182:	ff 75 10             	pushl  0x10(%ebp)
  802185:	e8 cd df ff ff       	call   800157 <vcprintf>
	cprintf("\n");
  80218a:	c7 04 24 74 26 80 00 	movl   $0x802674,(%esp)
  802191:	e8 12 e0 ff ff       	call   8001a8 <cprintf>
  802196:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802199:	cc                   	int3   
  80219a:	eb fd                	jmp    802199 <_panic+0x43>

0080219c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80219c:	55                   	push   %ebp
  80219d:	89 e5                	mov    %esp,%ebp
  80219f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8021a2:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8021a9:	75 2e                	jne    8021d9 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8021ab:	e8 42 e9 ff ff       	call   800af2 <sys_getenvid>
  8021b0:	83 ec 04             	sub    $0x4,%esp
  8021b3:	68 07 0e 00 00       	push   $0xe07
  8021b8:	68 00 f0 bf ee       	push   $0xeebff000
  8021bd:	50                   	push   %eax
  8021be:	e8 6d e9 ff ff       	call   800b30 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8021c3:	e8 2a e9 ff ff       	call   800af2 <sys_getenvid>
  8021c8:	83 c4 08             	add    $0x8,%esp
  8021cb:	68 e3 21 80 00       	push   $0x8021e3
  8021d0:	50                   	push   %eax
  8021d1:	e8 a5 ea ff ff       	call   800c7b <sys_env_set_pgfault_upcall>
  8021d6:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8021d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8021dc:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8021e1:	c9                   	leave  
  8021e2:	c3                   	ret    

008021e3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8021e3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8021e4:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8021e9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8021eb:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  8021ee:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  8021f2:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  8021f6:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  8021f9:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  8021fc:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  8021fd:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  802200:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  802201:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  802202:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802206:	c3                   	ret    

00802207 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802207:	55                   	push   %ebp
  802208:	89 e5                	mov    %esp,%ebp
  80220a:	56                   	push   %esi
  80220b:	53                   	push   %ebx
  80220c:	8b 75 08             	mov    0x8(%ebp),%esi
  80220f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802212:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  802215:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802217:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80221c:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  80221f:	83 ec 0c             	sub    $0xc,%esp
  802222:	50                   	push   %eax
  802223:	e8 b8 ea ff ff       	call   800ce0 <sys_ipc_recv>

	if (from_env_store != NULL)
  802228:	83 c4 10             	add    $0x10,%esp
  80222b:	85 f6                	test   %esi,%esi
  80222d:	74 14                	je     802243 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  80222f:	ba 00 00 00 00       	mov    $0x0,%edx
  802234:	85 c0                	test   %eax,%eax
  802236:	78 09                	js     802241 <ipc_recv+0x3a>
  802238:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80223e:	8b 52 74             	mov    0x74(%edx),%edx
  802241:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802243:	85 db                	test   %ebx,%ebx
  802245:	74 14                	je     80225b <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802247:	ba 00 00 00 00       	mov    $0x0,%edx
  80224c:	85 c0                	test   %eax,%eax
  80224e:	78 09                	js     802259 <ipc_recv+0x52>
  802250:	8b 15 08 40 80 00    	mov    0x804008,%edx
  802256:	8b 52 78             	mov    0x78(%edx),%edx
  802259:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  80225b:	85 c0                	test   %eax,%eax
  80225d:	78 08                	js     802267 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  80225f:	a1 08 40 80 00       	mov    0x804008,%eax
  802264:	8b 40 70             	mov    0x70(%eax),%eax
}
  802267:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80226a:	5b                   	pop    %ebx
  80226b:	5e                   	pop    %esi
  80226c:	5d                   	pop    %ebp
  80226d:	c3                   	ret    

0080226e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80226e:	55                   	push   %ebp
  80226f:	89 e5                	mov    %esp,%ebp
  802271:	57                   	push   %edi
  802272:	56                   	push   %esi
  802273:	53                   	push   %ebx
  802274:	83 ec 0c             	sub    $0xc,%esp
  802277:	8b 7d 08             	mov    0x8(%ebp),%edi
  80227a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80227d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  802280:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802282:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802287:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  80228a:	ff 75 14             	pushl  0x14(%ebp)
  80228d:	53                   	push   %ebx
  80228e:	56                   	push   %esi
  80228f:	57                   	push   %edi
  802290:	e8 28 ea ff ff       	call   800cbd <sys_ipc_try_send>

		if (err < 0) {
  802295:	83 c4 10             	add    $0x10,%esp
  802298:	85 c0                	test   %eax,%eax
  80229a:	79 1e                	jns    8022ba <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  80229c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80229f:	75 07                	jne    8022a8 <ipc_send+0x3a>
				sys_yield();
  8022a1:	e8 6b e8 ff ff       	call   800b11 <sys_yield>
  8022a6:	eb e2                	jmp    80228a <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8022a8:	50                   	push   %eax
  8022a9:	68 b0 2b 80 00       	push   $0x802bb0
  8022ae:	6a 49                	push   $0x49
  8022b0:	68 bd 2b 80 00       	push   $0x802bbd
  8022b5:	e8 9c fe ff ff       	call   802156 <_panic>
		}

	} while (err < 0);

}
  8022ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022bd:	5b                   	pop    %ebx
  8022be:	5e                   	pop    %esi
  8022bf:	5f                   	pop    %edi
  8022c0:	5d                   	pop    %ebp
  8022c1:	c3                   	ret    

008022c2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022c2:	55                   	push   %ebp
  8022c3:	89 e5                	mov    %esp,%ebp
  8022c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8022c8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022cd:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8022d0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022d6:	8b 52 50             	mov    0x50(%edx),%edx
  8022d9:	39 ca                	cmp    %ecx,%edx
  8022db:	75 0d                	jne    8022ea <ipc_find_env+0x28>
			return envs[i].env_id;
  8022dd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8022e0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8022e5:	8b 40 48             	mov    0x48(%eax),%eax
  8022e8:	eb 0f                	jmp    8022f9 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022ea:	83 c0 01             	add    $0x1,%eax
  8022ed:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022f2:	75 d9                	jne    8022cd <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8022f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022f9:	5d                   	pop    %ebp
  8022fa:	c3                   	ret    

008022fb <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022fb:	55                   	push   %ebp
  8022fc:	89 e5                	mov    %esp,%ebp
  8022fe:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802301:	89 d0                	mov    %edx,%eax
  802303:	c1 e8 16             	shr    $0x16,%eax
  802306:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80230d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802312:	f6 c1 01             	test   $0x1,%cl
  802315:	74 1d                	je     802334 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802317:	c1 ea 0c             	shr    $0xc,%edx
  80231a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802321:	f6 c2 01             	test   $0x1,%dl
  802324:	74 0e                	je     802334 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802326:	c1 ea 0c             	shr    $0xc,%edx
  802329:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802330:	ef 
  802331:	0f b7 c0             	movzwl %ax,%eax
}
  802334:	5d                   	pop    %ebp
  802335:	c3                   	ret    
  802336:	66 90                	xchg   %ax,%ax
  802338:	66 90                	xchg   %ax,%ax
  80233a:	66 90                	xchg   %ax,%ax
  80233c:	66 90                	xchg   %ax,%ax
  80233e:	66 90                	xchg   %ax,%ax

00802340 <__udivdi3>:
  802340:	55                   	push   %ebp
  802341:	57                   	push   %edi
  802342:	56                   	push   %esi
  802343:	53                   	push   %ebx
  802344:	83 ec 1c             	sub    $0x1c,%esp
  802347:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80234b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80234f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802353:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802357:	85 f6                	test   %esi,%esi
  802359:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80235d:	89 ca                	mov    %ecx,%edx
  80235f:	89 f8                	mov    %edi,%eax
  802361:	75 3d                	jne    8023a0 <__udivdi3+0x60>
  802363:	39 cf                	cmp    %ecx,%edi
  802365:	0f 87 c5 00 00 00    	ja     802430 <__udivdi3+0xf0>
  80236b:	85 ff                	test   %edi,%edi
  80236d:	89 fd                	mov    %edi,%ebp
  80236f:	75 0b                	jne    80237c <__udivdi3+0x3c>
  802371:	b8 01 00 00 00       	mov    $0x1,%eax
  802376:	31 d2                	xor    %edx,%edx
  802378:	f7 f7                	div    %edi
  80237a:	89 c5                	mov    %eax,%ebp
  80237c:	89 c8                	mov    %ecx,%eax
  80237e:	31 d2                	xor    %edx,%edx
  802380:	f7 f5                	div    %ebp
  802382:	89 c1                	mov    %eax,%ecx
  802384:	89 d8                	mov    %ebx,%eax
  802386:	89 cf                	mov    %ecx,%edi
  802388:	f7 f5                	div    %ebp
  80238a:	89 c3                	mov    %eax,%ebx
  80238c:	89 d8                	mov    %ebx,%eax
  80238e:	89 fa                	mov    %edi,%edx
  802390:	83 c4 1c             	add    $0x1c,%esp
  802393:	5b                   	pop    %ebx
  802394:	5e                   	pop    %esi
  802395:	5f                   	pop    %edi
  802396:	5d                   	pop    %ebp
  802397:	c3                   	ret    
  802398:	90                   	nop
  802399:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023a0:	39 ce                	cmp    %ecx,%esi
  8023a2:	77 74                	ja     802418 <__udivdi3+0xd8>
  8023a4:	0f bd fe             	bsr    %esi,%edi
  8023a7:	83 f7 1f             	xor    $0x1f,%edi
  8023aa:	0f 84 98 00 00 00    	je     802448 <__udivdi3+0x108>
  8023b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8023b5:	89 f9                	mov    %edi,%ecx
  8023b7:	89 c5                	mov    %eax,%ebp
  8023b9:	29 fb                	sub    %edi,%ebx
  8023bb:	d3 e6                	shl    %cl,%esi
  8023bd:	89 d9                	mov    %ebx,%ecx
  8023bf:	d3 ed                	shr    %cl,%ebp
  8023c1:	89 f9                	mov    %edi,%ecx
  8023c3:	d3 e0                	shl    %cl,%eax
  8023c5:	09 ee                	or     %ebp,%esi
  8023c7:	89 d9                	mov    %ebx,%ecx
  8023c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023cd:	89 d5                	mov    %edx,%ebp
  8023cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023d3:	d3 ed                	shr    %cl,%ebp
  8023d5:	89 f9                	mov    %edi,%ecx
  8023d7:	d3 e2                	shl    %cl,%edx
  8023d9:	89 d9                	mov    %ebx,%ecx
  8023db:	d3 e8                	shr    %cl,%eax
  8023dd:	09 c2                	or     %eax,%edx
  8023df:	89 d0                	mov    %edx,%eax
  8023e1:	89 ea                	mov    %ebp,%edx
  8023e3:	f7 f6                	div    %esi
  8023e5:	89 d5                	mov    %edx,%ebp
  8023e7:	89 c3                	mov    %eax,%ebx
  8023e9:	f7 64 24 0c          	mull   0xc(%esp)
  8023ed:	39 d5                	cmp    %edx,%ebp
  8023ef:	72 10                	jb     802401 <__udivdi3+0xc1>
  8023f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8023f5:	89 f9                	mov    %edi,%ecx
  8023f7:	d3 e6                	shl    %cl,%esi
  8023f9:	39 c6                	cmp    %eax,%esi
  8023fb:	73 07                	jae    802404 <__udivdi3+0xc4>
  8023fd:	39 d5                	cmp    %edx,%ebp
  8023ff:	75 03                	jne    802404 <__udivdi3+0xc4>
  802401:	83 eb 01             	sub    $0x1,%ebx
  802404:	31 ff                	xor    %edi,%edi
  802406:	89 d8                	mov    %ebx,%eax
  802408:	89 fa                	mov    %edi,%edx
  80240a:	83 c4 1c             	add    $0x1c,%esp
  80240d:	5b                   	pop    %ebx
  80240e:	5e                   	pop    %esi
  80240f:	5f                   	pop    %edi
  802410:	5d                   	pop    %ebp
  802411:	c3                   	ret    
  802412:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802418:	31 ff                	xor    %edi,%edi
  80241a:	31 db                	xor    %ebx,%ebx
  80241c:	89 d8                	mov    %ebx,%eax
  80241e:	89 fa                	mov    %edi,%edx
  802420:	83 c4 1c             	add    $0x1c,%esp
  802423:	5b                   	pop    %ebx
  802424:	5e                   	pop    %esi
  802425:	5f                   	pop    %edi
  802426:	5d                   	pop    %ebp
  802427:	c3                   	ret    
  802428:	90                   	nop
  802429:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802430:	89 d8                	mov    %ebx,%eax
  802432:	f7 f7                	div    %edi
  802434:	31 ff                	xor    %edi,%edi
  802436:	89 c3                	mov    %eax,%ebx
  802438:	89 d8                	mov    %ebx,%eax
  80243a:	89 fa                	mov    %edi,%edx
  80243c:	83 c4 1c             	add    $0x1c,%esp
  80243f:	5b                   	pop    %ebx
  802440:	5e                   	pop    %esi
  802441:	5f                   	pop    %edi
  802442:	5d                   	pop    %ebp
  802443:	c3                   	ret    
  802444:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802448:	39 ce                	cmp    %ecx,%esi
  80244a:	72 0c                	jb     802458 <__udivdi3+0x118>
  80244c:	31 db                	xor    %ebx,%ebx
  80244e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802452:	0f 87 34 ff ff ff    	ja     80238c <__udivdi3+0x4c>
  802458:	bb 01 00 00 00       	mov    $0x1,%ebx
  80245d:	e9 2a ff ff ff       	jmp    80238c <__udivdi3+0x4c>
  802462:	66 90                	xchg   %ax,%ax
  802464:	66 90                	xchg   %ax,%ax
  802466:	66 90                	xchg   %ax,%ax
  802468:	66 90                	xchg   %ax,%ax
  80246a:	66 90                	xchg   %ax,%ax
  80246c:	66 90                	xchg   %ax,%ax
  80246e:	66 90                	xchg   %ax,%ax

00802470 <__umoddi3>:
  802470:	55                   	push   %ebp
  802471:	57                   	push   %edi
  802472:	56                   	push   %esi
  802473:	53                   	push   %ebx
  802474:	83 ec 1c             	sub    $0x1c,%esp
  802477:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80247b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80247f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802483:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802487:	85 d2                	test   %edx,%edx
  802489:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80248d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802491:	89 f3                	mov    %esi,%ebx
  802493:	89 3c 24             	mov    %edi,(%esp)
  802496:	89 74 24 04          	mov    %esi,0x4(%esp)
  80249a:	75 1c                	jne    8024b8 <__umoddi3+0x48>
  80249c:	39 f7                	cmp    %esi,%edi
  80249e:	76 50                	jbe    8024f0 <__umoddi3+0x80>
  8024a0:	89 c8                	mov    %ecx,%eax
  8024a2:	89 f2                	mov    %esi,%edx
  8024a4:	f7 f7                	div    %edi
  8024a6:	89 d0                	mov    %edx,%eax
  8024a8:	31 d2                	xor    %edx,%edx
  8024aa:	83 c4 1c             	add    $0x1c,%esp
  8024ad:	5b                   	pop    %ebx
  8024ae:	5e                   	pop    %esi
  8024af:	5f                   	pop    %edi
  8024b0:	5d                   	pop    %ebp
  8024b1:	c3                   	ret    
  8024b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024b8:	39 f2                	cmp    %esi,%edx
  8024ba:	89 d0                	mov    %edx,%eax
  8024bc:	77 52                	ja     802510 <__umoddi3+0xa0>
  8024be:	0f bd ea             	bsr    %edx,%ebp
  8024c1:	83 f5 1f             	xor    $0x1f,%ebp
  8024c4:	75 5a                	jne    802520 <__umoddi3+0xb0>
  8024c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8024ca:	0f 82 e0 00 00 00    	jb     8025b0 <__umoddi3+0x140>
  8024d0:	39 0c 24             	cmp    %ecx,(%esp)
  8024d3:	0f 86 d7 00 00 00    	jbe    8025b0 <__umoddi3+0x140>
  8024d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024e1:	83 c4 1c             	add    $0x1c,%esp
  8024e4:	5b                   	pop    %ebx
  8024e5:	5e                   	pop    %esi
  8024e6:	5f                   	pop    %edi
  8024e7:	5d                   	pop    %ebp
  8024e8:	c3                   	ret    
  8024e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024f0:	85 ff                	test   %edi,%edi
  8024f2:	89 fd                	mov    %edi,%ebp
  8024f4:	75 0b                	jne    802501 <__umoddi3+0x91>
  8024f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024fb:	31 d2                	xor    %edx,%edx
  8024fd:	f7 f7                	div    %edi
  8024ff:	89 c5                	mov    %eax,%ebp
  802501:	89 f0                	mov    %esi,%eax
  802503:	31 d2                	xor    %edx,%edx
  802505:	f7 f5                	div    %ebp
  802507:	89 c8                	mov    %ecx,%eax
  802509:	f7 f5                	div    %ebp
  80250b:	89 d0                	mov    %edx,%eax
  80250d:	eb 99                	jmp    8024a8 <__umoddi3+0x38>
  80250f:	90                   	nop
  802510:	89 c8                	mov    %ecx,%eax
  802512:	89 f2                	mov    %esi,%edx
  802514:	83 c4 1c             	add    $0x1c,%esp
  802517:	5b                   	pop    %ebx
  802518:	5e                   	pop    %esi
  802519:	5f                   	pop    %edi
  80251a:	5d                   	pop    %ebp
  80251b:	c3                   	ret    
  80251c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802520:	8b 34 24             	mov    (%esp),%esi
  802523:	bf 20 00 00 00       	mov    $0x20,%edi
  802528:	89 e9                	mov    %ebp,%ecx
  80252a:	29 ef                	sub    %ebp,%edi
  80252c:	d3 e0                	shl    %cl,%eax
  80252e:	89 f9                	mov    %edi,%ecx
  802530:	89 f2                	mov    %esi,%edx
  802532:	d3 ea                	shr    %cl,%edx
  802534:	89 e9                	mov    %ebp,%ecx
  802536:	09 c2                	or     %eax,%edx
  802538:	89 d8                	mov    %ebx,%eax
  80253a:	89 14 24             	mov    %edx,(%esp)
  80253d:	89 f2                	mov    %esi,%edx
  80253f:	d3 e2                	shl    %cl,%edx
  802541:	89 f9                	mov    %edi,%ecx
  802543:	89 54 24 04          	mov    %edx,0x4(%esp)
  802547:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80254b:	d3 e8                	shr    %cl,%eax
  80254d:	89 e9                	mov    %ebp,%ecx
  80254f:	89 c6                	mov    %eax,%esi
  802551:	d3 e3                	shl    %cl,%ebx
  802553:	89 f9                	mov    %edi,%ecx
  802555:	89 d0                	mov    %edx,%eax
  802557:	d3 e8                	shr    %cl,%eax
  802559:	89 e9                	mov    %ebp,%ecx
  80255b:	09 d8                	or     %ebx,%eax
  80255d:	89 d3                	mov    %edx,%ebx
  80255f:	89 f2                	mov    %esi,%edx
  802561:	f7 34 24             	divl   (%esp)
  802564:	89 d6                	mov    %edx,%esi
  802566:	d3 e3                	shl    %cl,%ebx
  802568:	f7 64 24 04          	mull   0x4(%esp)
  80256c:	39 d6                	cmp    %edx,%esi
  80256e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802572:	89 d1                	mov    %edx,%ecx
  802574:	89 c3                	mov    %eax,%ebx
  802576:	72 08                	jb     802580 <__umoddi3+0x110>
  802578:	75 11                	jne    80258b <__umoddi3+0x11b>
  80257a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80257e:	73 0b                	jae    80258b <__umoddi3+0x11b>
  802580:	2b 44 24 04          	sub    0x4(%esp),%eax
  802584:	1b 14 24             	sbb    (%esp),%edx
  802587:	89 d1                	mov    %edx,%ecx
  802589:	89 c3                	mov    %eax,%ebx
  80258b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80258f:	29 da                	sub    %ebx,%edx
  802591:	19 ce                	sbb    %ecx,%esi
  802593:	89 f9                	mov    %edi,%ecx
  802595:	89 f0                	mov    %esi,%eax
  802597:	d3 e0                	shl    %cl,%eax
  802599:	89 e9                	mov    %ebp,%ecx
  80259b:	d3 ea                	shr    %cl,%edx
  80259d:	89 e9                	mov    %ebp,%ecx
  80259f:	d3 ee                	shr    %cl,%esi
  8025a1:	09 d0                	or     %edx,%eax
  8025a3:	89 f2                	mov    %esi,%edx
  8025a5:	83 c4 1c             	add    $0x1c,%esp
  8025a8:	5b                   	pop    %ebx
  8025a9:	5e                   	pop    %esi
  8025aa:	5f                   	pop    %edi
  8025ab:	5d                   	pop    %ebp
  8025ac:	c3                   	ret    
  8025ad:	8d 76 00             	lea    0x0(%esi),%esi
  8025b0:	29 f9                	sub    %edi,%ecx
  8025b2:	19 d6                	sbb    %edx,%esi
  8025b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025bc:	e9 18 ff ff ff       	jmp    8024d9 <__umoddi3+0x69>
