
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
  80003a:	68 40 21 80 00       	push   $0x802140
  80003f:	e8 64 01 00 00       	call   8001a8 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 ef 0d 00 00       	call   800e38 <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 b8 21 80 00       	push   $0x8021b8
  800058:	e8 4b 01 00 00       	call   8001a8 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 68 21 80 00       	push   $0x802168
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
  800099:	c7 04 24 90 21 80 00 	movl   $0x802190,(%esp)
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
  8000d2:	a3 04 40 80 00       	mov    %eax,0x804004

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
  800101:	e8 b7 10 00 00       	call   8011bd <close_all>
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
  80020b:	e8 a0 1c 00 00       	call   801eb0 <__udivdi3>
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
  80024e:	e8 8d 1d 00 00       	call   801fe0 <__umoddi3>
  800253:	83 c4 14             	add    $0x14,%esp
  800256:	0f be 80 e0 21 80 00 	movsbl 0x8021e0(%eax),%eax
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
  800352:	ff 24 85 20 23 80 00 	jmp    *0x802320(,%eax,4)
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
  800416:	8b 14 85 80 24 80 00 	mov    0x802480(,%eax,4),%edx
  80041d:	85 d2                	test   %edx,%edx
  80041f:	75 18                	jne    800439 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800421:	50                   	push   %eax
  800422:	68 f8 21 80 00       	push   $0x8021f8
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
  80043a:	68 89 26 80 00       	push   $0x802689
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
  80045e:	b8 f1 21 80 00       	mov    $0x8021f1,%eax
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
  800ad9:	68 df 24 80 00       	push   $0x8024df
  800ade:	6a 23                	push   $0x23
  800ae0:	68 fc 24 80 00       	push   $0x8024fc
  800ae5:	e8 e5 11 00 00       	call   801ccf <_panic>

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
  800b5a:	68 df 24 80 00       	push   $0x8024df
  800b5f:	6a 23                	push   $0x23
  800b61:	68 fc 24 80 00       	push   $0x8024fc
  800b66:	e8 64 11 00 00       	call   801ccf <_panic>

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
  800b9c:	68 df 24 80 00       	push   $0x8024df
  800ba1:	6a 23                	push   $0x23
  800ba3:	68 fc 24 80 00       	push   $0x8024fc
  800ba8:	e8 22 11 00 00       	call   801ccf <_panic>

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
  800bde:	68 df 24 80 00       	push   $0x8024df
  800be3:	6a 23                	push   $0x23
  800be5:	68 fc 24 80 00       	push   $0x8024fc
  800bea:	e8 e0 10 00 00       	call   801ccf <_panic>

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
  800c20:	68 df 24 80 00       	push   $0x8024df
  800c25:	6a 23                	push   $0x23
  800c27:	68 fc 24 80 00       	push   $0x8024fc
  800c2c:	e8 9e 10 00 00       	call   801ccf <_panic>

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
  800c62:	68 df 24 80 00       	push   $0x8024df
  800c67:	6a 23                	push   $0x23
  800c69:	68 fc 24 80 00       	push   $0x8024fc
  800c6e:	e8 5c 10 00 00       	call   801ccf <_panic>

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
  800ca4:	68 df 24 80 00       	push   $0x8024df
  800ca9:	6a 23                	push   $0x23
  800cab:	68 fc 24 80 00       	push   $0x8024fc
  800cb0:	e8 1a 10 00 00       	call   801ccf <_panic>

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
  800d08:	68 df 24 80 00       	push   $0x8024df
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 fc 24 80 00       	push   $0x8024fc
  800d14:	e8 b6 0f 00 00       	call   801ccf <_panic>

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

00800d21 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	57                   	push   %edi
  800d25:	56                   	push   %esi
  800d26:	53                   	push   %ebx
  800d27:	83 ec 0c             	sub    $0xc,%esp
  800d2a:	8b 75 08             	mov    0x8(%ebp),%esi
	void *addr = (void *) utf->utf_fault_va;
  800d2d:	8b 1e                	mov    (%esi),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800d2f:	f6 46 04 02          	testb  $0x2,0x4(%esi)
  800d33:	75 25                	jne    800d5a <pgfault+0x39>
  800d35:	89 d8                	mov    %ebx,%eax
  800d37:	c1 e8 0c             	shr    $0xc,%eax
  800d3a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d41:	f6 c4 08             	test   $0x8,%ah
  800d44:	75 14                	jne    800d5a <pgfault+0x39>
		panic("pgfault: not due to a write or a COW page");
  800d46:	83 ec 04             	sub    $0x4,%esp
  800d49:	68 0c 25 80 00       	push   $0x80250c
  800d4e:	6a 1e                	push   $0x1e
  800d50:	68 a0 25 80 00       	push   $0x8025a0
  800d55:	e8 75 0f 00 00       	call   801ccf <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800d5a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800d60:	e8 8d fd ff ff       	call   800af2 <sys_getenvid>
  800d65:	89 c7                	mov    %eax,%edi

	if ( (uint32_t)addr ==  0xeebfd000) {
  800d67:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  800d6d:	75 31                	jne    800da0 <pgfault+0x7f>
		cprintf("[hit %e]\n", utf->utf_err);
  800d6f:	83 ec 08             	sub    $0x8,%esp
  800d72:	ff 76 04             	pushl  0x4(%esi)
  800d75:	68 ab 25 80 00       	push   $0x8025ab
  800d7a:	e8 29 f4 ff ff       	call   8001a8 <cprintf>
		cprintf("[hit 0x%x]\n", utf->utf_eip);
  800d7f:	83 c4 08             	add    $0x8,%esp
  800d82:	ff 76 28             	pushl  0x28(%esi)
  800d85:	68 b5 25 80 00       	push   $0x8025b5
  800d8a:	e8 19 f4 ff ff       	call   8001a8 <cprintf>
		cprintf("[hit %d]\n", envid);
  800d8f:	83 c4 08             	add    $0x8,%esp
  800d92:	57                   	push   %edi
  800d93:	68 c1 25 80 00       	push   $0x8025c1
  800d98:	e8 0b f4 ff ff       	call   8001a8 <cprintf>
  800d9d:	83 c4 10             	add    $0x10,%esp
	}

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800da0:	83 ec 04             	sub    $0x4,%esp
  800da3:	6a 07                	push   $0x7
  800da5:	68 00 f0 7f 00       	push   $0x7ff000
  800daa:	57                   	push   %edi
  800dab:	e8 80 fd ff ff       	call   800b30 <sys_page_alloc>
	if (r < 0)
  800db0:	83 c4 10             	add    $0x10,%esp
  800db3:	85 c0                	test   %eax,%eax
  800db5:	79 12                	jns    800dc9 <pgfault+0xa8>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800db7:	50                   	push   %eax
  800db8:	68 38 25 80 00       	push   $0x802538
  800dbd:	6a 39                	push   $0x39
  800dbf:	68 a0 25 80 00       	push   $0x8025a0
  800dc4:	e8 06 0f 00 00       	call   801ccf <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800dc9:	83 ec 04             	sub    $0x4,%esp
  800dcc:	68 00 10 00 00       	push   $0x1000
  800dd1:	53                   	push   %ebx
  800dd2:	68 00 f0 7f 00       	push   $0x7ff000
  800dd7:	e8 4b fb ff ff       	call   800927 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800ddc:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800de3:	53                   	push   %ebx
  800de4:	57                   	push   %edi
  800de5:	68 00 f0 7f 00       	push   $0x7ff000
  800dea:	57                   	push   %edi
  800deb:	e8 83 fd ff ff       	call   800b73 <sys_page_map>
	if (r < 0)
  800df0:	83 c4 20             	add    $0x20,%esp
  800df3:	85 c0                	test   %eax,%eax
  800df5:	79 12                	jns    800e09 <pgfault+0xe8>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800df7:	50                   	push   %eax
  800df8:	68 5c 25 80 00       	push   $0x80255c
  800dfd:	6a 41                	push   $0x41
  800dff:	68 a0 25 80 00       	push   $0x8025a0
  800e04:	e8 c6 0e 00 00       	call   801ccf <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800e09:	83 ec 08             	sub    $0x8,%esp
  800e0c:	68 00 f0 7f 00       	push   $0x7ff000
  800e11:	57                   	push   %edi
  800e12:	e8 9e fd ff ff       	call   800bb5 <sys_page_unmap>
	if (r < 0)
  800e17:	83 c4 10             	add    $0x10,%esp
  800e1a:	85 c0                	test   %eax,%eax
  800e1c:	79 12                	jns    800e30 <pgfault+0x10f>
        panic("pgfault: page unmap failed: %e\n", r);
  800e1e:	50                   	push   %eax
  800e1f:	68 80 25 80 00       	push   $0x802580
  800e24:	6a 46                	push   $0x46
  800e26:	68 a0 25 80 00       	push   $0x8025a0
  800e2b:	e8 9f 0e 00 00       	call   801ccf <_panic>
}
  800e30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e33:	5b                   	pop    %ebx
  800e34:	5e                   	pop    %esi
  800e35:	5f                   	pop    %edi
  800e36:	5d                   	pop    %ebp
  800e37:	c3                   	ret    

00800e38 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e38:	55                   	push   %ebp
  800e39:	89 e5                	mov    %esp,%ebp
  800e3b:	57                   	push   %edi
  800e3c:	56                   	push   %esi
  800e3d:	53                   	push   %ebx
  800e3e:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800e41:	68 21 0d 80 00       	push   $0x800d21
  800e46:	e8 ca 0e 00 00       	call   801d15 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e4b:	b8 07 00 00 00       	mov    $0x7,%eax
  800e50:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800e52:	83 c4 10             	add    $0x10,%esp
  800e55:	85 c0                	test   %eax,%eax
  800e57:	0f 88 67 01 00 00    	js     800fc4 <fork+0x18c>
  800e5d:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800e62:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800e67:	85 c0                	test   %eax,%eax
  800e69:	75 21                	jne    800e8c <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e6b:	e8 82 fc ff ff       	call   800af2 <sys_getenvid>
  800e70:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e75:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e78:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e7d:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  800e82:	ba 00 00 00 00       	mov    $0x0,%edx
  800e87:	e9 42 01 00 00       	jmp    800fce <fork+0x196>
  800e8c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e8f:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800e91:	89 d8                	mov    %ebx,%eax
  800e93:	c1 e8 16             	shr    $0x16,%eax
  800e96:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e9d:	a8 01                	test   $0x1,%al
  800e9f:	0f 84 c0 00 00 00    	je     800f65 <fork+0x12d>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800ea5:	89 d8                	mov    %ebx,%eax
  800ea7:	c1 e8 0c             	shr    $0xc,%eax
  800eaa:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800eb1:	f6 c2 01             	test   $0x1,%dl
  800eb4:	0f 84 ab 00 00 00    	je     800f65 <fork+0x12d>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
  800eba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ec1:	a9 02 08 00 00       	test   $0x802,%eax
  800ec6:	0f 84 99 00 00 00    	je     800f65 <fork+0x12d>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800ecc:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ed3:	f6 c4 04             	test   $0x4,%ah
  800ed6:	74 17                	je     800eef <fork+0xb7>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800ed8:	83 ec 0c             	sub    $0xc,%esp
  800edb:	68 07 0e 00 00       	push   $0xe07
  800ee0:	53                   	push   %ebx
  800ee1:	57                   	push   %edi
  800ee2:	53                   	push   %ebx
  800ee3:	6a 00                	push   $0x0
  800ee5:	e8 89 fc ff ff       	call   800b73 <sys_page_map>
  800eea:	83 c4 20             	add    $0x20,%esp
  800eed:	eb 76                	jmp    800f65 <fork+0x12d>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800eef:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ef6:	a8 02                	test   $0x2,%al
  800ef8:	75 0c                	jne    800f06 <fork+0xce>
  800efa:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f01:	f6 c4 08             	test   $0x8,%ah
  800f04:	74 3f                	je     800f45 <fork+0x10d>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f06:	83 ec 0c             	sub    $0xc,%esp
  800f09:	68 05 08 00 00       	push   $0x805
  800f0e:	53                   	push   %ebx
  800f0f:	57                   	push   %edi
  800f10:	53                   	push   %ebx
  800f11:	6a 00                	push   $0x0
  800f13:	e8 5b fc ff ff       	call   800b73 <sys_page_map>
		if (r < 0)
  800f18:	83 c4 20             	add    $0x20,%esp
  800f1b:	85 c0                	test   %eax,%eax
  800f1d:	0f 88 a5 00 00 00    	js     800fc8 <fork+0x190>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f23:	83 ec 0c             	sub    $0xc,%esp
  800f26:	68 05 08 00 00       	push   $0x805
  800f2b:	53                   	push   %ebx
  800f2c:	6a 00                	push   $0x0
  800f2e:	53                   	push   %ebx
  800f2f:	6a 00                	push   $0x0
  800f31:	e8 3d fc ff ff       	call   800b73 <sys_page_map>
  800f36:	83 c4 20             	add    $0x20,%esp
  800f39:	85 c0                	test   %eax,%eax
  800f3b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f40:	0f 4f c1             	cmovg  %ecx,%eax
  800f43:	eb 1c                	jmp    800f61 <fork+0x129>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  800f45:	83 ec 0c             	sub    $0xc,%esp
  800f48:	6a 05                	push   $0x5
  800f4a:	53                   	push   %ebx
  800f4b:	57                   	push   %edi
  800f4c:	53                   	push   %ebx
  800f4d:	6a 00                	push   $0x0
  800f4f:	e8 1f fc ff ff       	call   800b73 <sys_page_map>
  800f54:	83 c4 20             	add    $0x20,%esp
  800f57:	85 c0                	test   %eax,%eax
  800f59:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f5e:	0f 4f c1             	cmovg  %ecx,%eax
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  800f61:	85 c0                	test   %eax,%eax
  800f63:	78 67                	js     800fcc <fork+0x194>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  800f65:	83 c6 01             	add    $0x1,%esi
  800f68:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f6e:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  800f74:	0f 85 17 ff ff ff    	jne    800e91 <fork+0x59>
  800f7a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  800f7d:	83 ec 04             	sub    $0x4,%esp
  800f80:	6a 07                	push   $0x7
  800f82:	68 00 f0 bf ee       	push   $0xeebff000
  800f87:	57                   	push   %edi
  800f88:	e8 a3 fb ff ff       	call   800b30 <sys_page_alloc>
	if (r < 0)
  800f8d:	83 c4 10             	add    $0x10,%esp
		return r;
  800f90:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  800f92:	85 c0                	test   %eax,%eax
  800f94:	78 38                	js     800fce <fork+0x196>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800f96:	83 ec 08             	sub    $0x8,%esp
  800f99:	68 5c 1d 80 00       	push   $0x801d5c
  800f9e:	57                   	push   %edi
  800f9f:	e8 d7 fc ff ff       	call   800c7b <sys_env_set_pgfault_upcall>
	if (r < 0)
  800fa4:	83 c4 10             	add    $0x10,%esp
		return r;
  800fa7:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	78 21                	js     800fce <fork+0x196>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  800fad:	83 ec 08             	sub    $0x8,%esp
  800fb0:	6a 02                	push   $0x2
  800fb2:	57                   	push   %edi
  800fb3:	e8 3f fc ff ff       	call   800bf7 <sys_env_set_status>
	if (r < 0)
  800fb8:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  800fbb:	85 c0                	test   %eax,%eax
  800fbd:	0f 48 f8             	cmovs  %eax,%edi
  800fc0:	89 fa                	mov    %edi,%edx
  800fc2:	eb 0a                	jmp    800fce <fork+0x196>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  800fc4:	89 c2                	mov    %eax,%edx
  800fc6:	eb 06                	jmp    800fce <fork+0x196>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800fc8:	89 c2                	mov    %eax,%edx
  800fca:	eb 02                	jmp    800fce <fork+0x196>
  800fcc:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  800fce:	89 d0                	mov    %edx,%eax
  800fd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fd3:	5b                   	pop    %ebx
  800fd4:	5e                   	pop    %esi
  800fd5:	5f                   	pop    %edi
  800fd6:	5d                   	pop    %ebp
  800fd7:	c3                   	ret    

00800fd8 <sfork>:

// Challenge!
int
sfork(void)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fde:	68 cb 25 80 00       	push   $0x8025cb
  800fe3:	68 ce 00 00 00       	push   $0xce
  800fe8:	68 a0 25 80 00       	push   $0x8025a0
  800fed:	e8 dd 0c 00 00       	call   801ccf <_panic>

00800ff2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ff2:	55                   	push   %ebp
  800ff3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ff5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff8:	05 00 00 00 30       	add    $0x30000000,%eax
  800ffd:	c1 e8 0c             	shr    $0xc,%eax
}
  801000:	5d                   	pop    %ebp
  801001:	c3                   	ret    

00801002 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801005:	8b 45 08             	mov    0x8(%ebp),%eax
  801008:	05 00 00 00 30       	add    $0x30000000,%eax
  80100d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801012:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801017:	5d                   	pop    %ebp
  801018:	c3                   	ret    

00801019 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801019:	55                   	push   %ebp
  80101a:	89 e5                	mov    %esp,%ebp
  80101c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80101f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801024:	89 c2                	mov    %eax,%edx
  801026:	c1 ea 16             	shr    $0x16,%edx
  801029:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801030:	f6 c2 01             	test   $0x1,%dl
  801033:	74 11                	je     801046 <fd_alloc+0x2d>
  801035:	89 c2                	mov    %eax,%edx
  801037:	c1 ea 0c             	shr    $0xc,%edx
  80103a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801041:	f6 c2 01             	test   $0x1,%dl
  801044:	75 09                	jne    80104f <fd_alloc+0x36>
			*fd_store = fd;
  801046:	89 01                	mov    %eax,(%ecx)
			return 0;
  801048:	b8 00 00 00 00       	mov    $0x0,%eax
  80104d:	eb 17                	jmp    801066 <fd_alloc+0x4d>
  80104f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801054:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801059:	75 c9                	jne    801024 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80105b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801061:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801066:	5d                   	pop    %ebp
  801067:	c3                   	ret    

00801068 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801068:	55                   	push   %ebp
  801069:	89 e5                	mov    %esp,%ebp
  80106b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80106e:	83 f8 1f             	cmp    $0x1f,%eax
  801071:	77 36                	ja     8010a9 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801073:	c1 e0 0c             	shl    $0xc,%eax
  801076:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80107b:	89 c2                	mov    %eax,%edx
  80107d:	c1 ea 16             	shr    $0x16,%edx
  801080:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801087:	f6 c2 01             	test   $0x1,%dl
  80108a:	74 24                	je     8010b0 <fd_lookup+0x48>
  80108c:	89 c2                	mov    %eax,%edx
  80108e:	c1 ea 0c             	shr    $0xc,%edx
  801091:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801098:	f6 c2 01             	test   $0x1,%dl
  80109b:	74 1a                	je     8010b7 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80109d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010a0:	89 02                	mov    %eax,(%edx)
	return 0;
  8010a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a7:	eb 13                	jmp    8010bc <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010ae:	eb 0c                	jmp    8010bc <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010b0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010b5:	eb 05                	jmp    8010bc <fd_lookup+0x54>
  8010b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010bc:	5d                   	pop    %ebp
  8010bd:	c3                   	ret    

008010be <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010be:	55                   	push   %ebp
  8010bf:	89 e5                	mov    %esp,%ebp
  8010c1:	83 ec 08             	sub    $0x8,%esp
  8010c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010c7:	ba 60 26 80 00       	mov    $0x802660,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8010cc:	eb 13                	jmp    8010e1 <dev_lookup+0x23>
  8010ce:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8010d1:	39 08                	cmp    %ecx,(%eax)
  8010d3:	75 0c                	jne    8010e1 <dev_lookup+0x23>
			*dev = devtab[i];
  8010d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010d8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010da:	b8 00 00 00 00       	mov    $0x0,%eax
  8010df:	eb 2e                	jmp    80110f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8010e1:	8b 02                	mov    (%edx),%eax
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	75 e7                	jne    8010ce <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8010e7:	a1 04 40 80 00       	mov    0x804004,%eax
  8010ec:	8b 40 48             	mov    0x48(%eax),%eax
  8010ef:	83 ec 04             	sub    $0x4,%esp
  8010f2:	51                   	push   %ecx
  8010f3:	50                   	push   %eax
  8010f4:	68 e4 25 80 00       	push   $0x8025e4
  8010f9:	e8 aa f0 ff ff       	call   8001a8 <cprintf>
	*dev = 0;
  8010fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801101:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801107:	83 c4 10             	add    $0x10,%esp
  80110a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80110f:	c9                   	leave  
  801110:	c3                   	ret    

00801111 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801111:	55                   	push   %ebp
  801112:	89 e5                	mov    %esp,%ebp
  801114:	56                   	push   %esi
  801115:	53                   	push   %ebx
  801116:	83 ec 10             	sub    $0x10,%esp
  801119:	8b 75 08             	mov    0x8(%ebp),%esi
  80111c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80111f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801122:	50                   	push   %eax
  801123:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801129:	c1 e8 0c             	shr    $0xc,%eax
  80112c:	50                   	push   %eax
  80112d:	e8 36 ff ff ff       	call   801068 <fd_lookup>
  801132:	83 c4 08             	add    $0x8,%esp
  801135:	85 c0                	test   %eax,%eax
  801137:	78 05                	js     80113e <fd_close+0x2d>
	    || fd != fd2)
  801139:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80113c:	74 0c                	je     80114a <fd_close+0x39>
		return (must_exist ? r : 0);
  80113e:	84 db                	test   %bl,%bl
  801140:	ba 00 00 00 00       	mov    $0x0,%edx
  801145:	0f 44 c2             	cmove  %edx,%eax
  801148:	eb 41                	jmp    80118b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80114a:	83 ec 08             	sub    $0x8,%esp
  80114d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801150:	50                   	push   %eax
  801151:	ff 36                	pushl  (%esi)
  801153:	e8 66 ff ff ff       	call   8010be <dev_lookup>
  801158:	89 c3                	mov    %eax,%ebx
  80115a:	83 c4 10             	add    $0x10,%esp
  80115d:	85 c0                	test   %eax,%eax
  80115f:	78 1a                	js     80117b <fd_close+0x6a>
		if (dev->dev_close)
  801161:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801164:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801167:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80116c:	85 c0                	test   %eax,%eax
  80116e:	74 0b                	je     80117b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801170:	83 ec 0c             	sub    $0xc,%esp
  801173:	56                   	push   %esi
  801174:	ff d0                	call   *%eax
  801176:	89 c3                	mov    %eax,%ebx
  801178:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80117b:	83 ec 08             	sub    $0x8,%esp
  80117e:	56                   	push   %esi
  80117f:	6a 00                	push   $0x0
  801181:	e8 2f fa ff ff       	call   800bb5 <sys_page_unmap>
	return r;
  801186:	83 c4 10             	add    $0x10,%esp
  801189:	89 d8                	mov    %ebx,%eax
}
  80118b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80118e:	5b                   	pop    %ebx
  80118f:	5e                   	pop    %esi
  801190:	5d                   	pop    %ebp
  801191:	c3                   	ret    

00801192 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801192:	55                   	push   %ebp
  801193:	89 e5                	mov    %esp,%ebp
  801195:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801198:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80119b:	50                   	push   %eax
  80119c:	ff 75 08             	pushl  0x8(%ebp)
  80119f:	e8 c4 fe ff ff       	call   801068 <fd_lookup>
  8011a4:	83 c4 08             	add    $0x8,%esp
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	78 10                	js     8011bb <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8011ab:	83 ec 08             	sub    $0x8,%esp
  8011ae:	6a 01                	push   $0x1
  8011b0:	ff 75 f4             	pushl  -0xc(%ebp)
  8011b3:	e8 59 ff ff ff       	call   801111 <fd_close>
  8011b8:	83 c4 10             	add    $0x10,%esp
}
  8011bb:	c9                   	leave  
  8011bc:	c3                   	ret    

008011bd <close_all>:

void
close_all(void)
{
  8011bd:	55                   	push   %ebp
  8011be:	89 e5                	mov    %esp,%ebp
  8011c0:	53                   	push   %ebx
  8011c1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011c4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011c9:	83 ec 0c             	sub    $0xc,%esp
  8011cc:	53                   	push   %ebx
  8011cd:	e8 c0 ff ff ff       	call   801192 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8011d2:	83 c3 01             	add    $0x1,%ebx
  8011d5:	83 c4 10             	add    $0x10,%esp
  8011d8:	83 fb 20             	cmp    $0x20,%ebx
  8011db:	75 ec                	jne    8011c9 <close_all+0xc>
		close(i);
}
  8011dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011e0:	c9                   	leave  
  8011e1:	c3                   	ret    

008011e2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
  8011e5:	57                   	push   %edi
  8011e6:	56                   	push   %esi
  8011e7:	53                   	push   %ebx
  8011e8:	83 ec 2c             	sub    $0x2c,%esp
  8011eb:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011ee:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011f1:	50                   	push   %eax
  8011f2:	ff 75 08             	pushl  0x8(%ebp)
  8011f5:	e8 6e fe ff ff       	call   801068 <fd_lookup>
  8011fa:	83 c4 08             	add    $0x8,%esp
  8011fd:	85 c0                	test   %eax,%eax
  8011ff:	0f 88 c1 00 00 00    	js     8012c6 <dup+0xe4>
		return r;
	close(newfdnum);
  801205:	83 ec 0c             	sub    $0xc,%esp
  801208:	56                   	push   %esi
  801209:	e8 84 ff ff ff       	call   801192 <close>

	newfd = INDEX2FD(newfdnum);
  80120e:	89 f3                	mov    %esi,%ebx
  801210:	c1 e3 0c             	shl    $0xc,%ebx
  801213:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801219:	83 c4 04             	add    $0x4,%esp
  80121c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80121f:	e8 de fd ff ff       	call   801002 <fd2data>
  801224:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801226:	89 1c 24             	mov    %ebx,(%esp)
  801229:	e8 d4 fd ff ff       	call   801002 <fd2data>
  80122e:	83 c4 10             	add    $0x10,%esp
  801231:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801234:	89 f8                	mov    %edi,%eax
  801236:	c1 e8 16             	shr    $0x16,%eax
  801239:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801240:	a8 01                	test   $0x1,%al
  801242:	74 37                	je     80127b <dup+0x99>
  801244:	89 f8                	mov    %edi,%eax
  801246:	c1 e8 0c             	shr    $0xc,%eax
  801249:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801250:	f6 c2 01             	test   $0x1,%dl
  801253:	74 26                	je     80127b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801255:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80125c:	83 ec 0c             	sub    $0xc,%esp
  80125f:	25 07 0e 00 00       	and    $0xe07,%eax
  801264:	50                   	push   %eax
  801265:	ff 75 d4             	pushl  -0x2c(%ebp)
  801268:	6a 00                	push   $0x0
  80126a:	57                   	push   %edi
  80126b:	6a 00                	push   $0x0
  80126d:	e8 01 f9 ff ff       	call   800b73 <sys_page_map>
  801272:	89 c7                	mov    %eax,%edi
  801274:	83 c4 20             	add    $0x20,%esp
  801277:	85 c0                	test   %eax,%eax
  801279:	78 2e                	js     8012a9 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80127b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80127e:	89 d0                	mov    %edx,%eax
  801280:	c1 e8 0c             	shr    $0xc,%eax
  801283:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80128a:	83 ec 0c             	sub    $0xc,%esp
  80128d:	25 07 0e 00 00       	and    $0xe07,%eax
  801292:	50                   	push   %eax
  801293:	53                   	push   %ebx
  801294:	6a 00                	push   $0x0
  801296:	52                   	push   %edx
  801297:	6a 00                	push   $0x0
  801299:	e8 d5 f8 ff ff       	call   800b73 <sys_page_map>
  80129e:	89 c7                	mov    %eax,%edi
  8012a0:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8012a3:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012a5:	85 ff                	test   %edi,%edi
  8012a7:	79 1d                	jns    8012c6 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012a9:	83 ec 08             	sub    $0x8,%esp
  8012ac:	53                   	push   %ebx
  8012ad:	6a 00                	push   $0x0
  8012af:	e8 01 f9 ff ff       	call   800bb5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012b4:	83 c4 08             	add    $0x8,%esp
  8012b7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012ba:	6a 00                	push   $0x0
  8012bc:	e8 f4 f8 ff ff       	call   800bb5 <sys_page_unmap>
	return r;
  8012c1:	83 c4 10             	add    $0x10,%esp
  8012c4:	89 f8                	mov    %edi,%eax
}
  8012c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c9:	5b                   	pop    %ebx
  8012ca:	5e                   	pop    %esi
  8012cb:	5f                   	pop    %edi
  8012cc:	5d                   	pop    %ebp
  8012cd:	c3                   	ret    

008012ce <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012ce:	55                   	push   %ebp
  8012cf:	89 e5                	mov    %esp,%ebp
  8012d1:	53                   	push   %ebx
  8012d2:	83 ec 14             	sub    $0x14,%esp
  8012d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012db:	50                   	push   %eax
  8012dc:	53                   	push   %ebx
  8012dd:	e8 86 fd ff ff       	call   801068 <fd_lookup>
  8012e2:	83 c4 08             	add    $0x8,%esp
  8012e5:	89 c2                	mov    %eax,%edx
  8012e7:	85 c0                	test   %eax,%eax
  8012e9:	78 6d                	js     801358 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012eb:	83 ec 08             	sub    $0x8,%esp
  8012ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f1:	50                   	push   %eax
  8012f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f5:	ff 30                	pushl  (%eax)
  8012f7:	e8 c2 fd ff ff       	call   8010be <dev_lookup>
  8012fc:	83 c4 10             	add    $0x10,%esp
  8012ff:	85 c0                	test   %eax,%eax
  801301:	78 4c                	js     80134f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801303:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801306:	8b 42 08             	mov    0x8(%edx),%eax
  801309:	83 e0 03             	and    $0x3,%eax
  80130c:	83 f8 01             	cmp    $0x1,%eax
  80130f:	75 21                	jne    801332 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801311:	a1 04 40 80 00       	mov    0x804004,%eax
  801316:	8b 40 48             	mov    0x48(%eax),%eax
  801319:	83 ec 04             	sub    $0x4,%esp
  80131c:	53                   	push   %ebx
  80131d:	50                   	push   %eax
  80131e:	68 25 26 80 00       	push   $0x802625
  801323:	e8 80 ee ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  801328:	83 c4 10             	add    $0x10,%esp
  80132b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801330:	eb 26                	jmp    801358 <read+0x8a>
	}
	if (!dev->dev_read)
  801332:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801335:	8b 40 08             	mov    0x8(%eax),%eax
  801338:	85 c0                	test   %eax,%eax
  80133a:	74 17                	je     801353 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80133c:	83 ec 04             	sub    $0x4,%esp
  80133f:	ff 75 10             	pushl  0x10(%ebp)
  801342:	ff 75 0c             	pushl  0xc(%ebp)
  801345:	52                   	push   %edx
  801346:	ff d0                	call   *%eax
  801348:	89 c2                	mov    %eax,%edx
  80134a:	83 c4 10             	add    $0x10,%esp
  80134d:	eb 09                	jmp    801358 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80134f:	89 c2                	mov    %eax,%edx
  801351:	eb 05                	jmp    801358 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801353:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801358:	89 d0                	mov    %edx,%eax
  80135a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80135d:	c9                   	leave  
  80135e:	c3                   	ret    

0080135f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80135f:	55                   	push   %ebp
  801360:	89 e5                	mov    %esp,%ebp
  801362:	57                   	push   %edi
  801363:	56                   	push   %esi
  801364:	53                   	push   %ebx
  801365:	83 ec 0c             	sub    $0xc,%esp
  801368:	8b 7d 08             	mov    0x8(%ebp),%edi
  80136b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80136e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801373:	eb 21                	jmp    801396 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801375:	83 ec 04             	sub    $0x4,%esp
  801378:	89 f0                	mov    %esi,%eax
  80137a:	29 d8                	sub    %ebx,%eax
  80137c:	50                   	push   %eax
  80137d:	89 d8                	mov    %ebx,%eax
  80137f:	03 45 0c             	add    0xc(%ebp),%eax
  801382:	50                   	push   %eax
  801383:	57                   	push   %edi
  801384:	e8 45 ff ff ff       	call   8012ce <read>
		if (m < 0)
  801389:	83 c4 10             	add    $0x10,%esp
  80138c:	85 c0                	test   %eax,%eax
  80138e:	78 10                	js     8013a0 <readn+0x41>
			return m;
		if (m == 0)
  801390:	85 c0                	test   %eax,%eax
  801392:	74 0a                	je     80139e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801394:	01 c3                	add    %eax,%ebx
  801396:	39 f3                	cmp    %esi,%ebx
  801398:	72 db                	jb     801375 <readn+0x16>
  80139a:	89 d8                	mov    %ebx,%eax
  80139c:	eb 02                	jmp    8013a0 <readn+0x41>
  80139e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013a3:	5b                   	pop    %ebx
  8013a4:	5e                   	pop    %esi
  8013a5:	5f                   	pop    %edi
  8013a6:	5d                   	pop    %ebp
  8013a7:	c3                   	ret    

008013a8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013a8:	55                   	push   %ebp
  8013a9:	89 e5                	mov    %esp,%ebp
  8013ab:	53                   	push   %ebx
  8013ac:	83 ec 14             	sub    $0x14,%esp
  8013af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b5:	50                   	push   %eax
  8013b6:	53                   	push   %ebx
  8013b7:	e8 ac fc ff ff       	call   801068 <fd_lookup>
  8013bc:	83 c4 08             	add    $0x8,%esp
  8013bf:	89 c2                	mov    %eax,%edx
  8013c1:	85 c0                	test   %eax,%eax
  8013c3:	78 68                	js     80142d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c5:	83 ec 08             	sub    $0x8,%esp
  8013c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013cb:	50                   	push   %eax
  8013cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013cf:	ff 30                	pushl  (%eax)
  8013d1:	e8 e8 fc ff ff       	call   8010be <dev_lookup>
  8013d6:	83 c4 10             	add    $0x10,%esp
  8013d9:	85 c0                	test   %eax,%eax
  8013db:	78 47                	js     801424 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013e4:	75 21                	jne    801407 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013e6:	a1 04 40 80 00       	mov    0x804004,%eax
  8013eb:	8b 40 48             	mov    0x48(%eax),%eax
  8013ee:	83 ec 04             	sub    $0x4,%esp
  8013f1:	53                   	push   %ebx
  8013f2:	50                   	push   %eax
  8013f3:	68 41 26 80 00       	push   $0x802641
  8013f8:	e8 ab ed ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  8013fd:	83 c4 10             	add    $0x10,%esp
  801400:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801405:	eb 26                	jmp    80142d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801407:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80140a:	8b 52 0c             	mov    0xc(%edx),%edx
  80140d:	85 d2                	test   %edx,%edx
  80140f:	74 17                	je     801428 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801411:	83 ec 04             	sub    $0x4,%esp
  801414:	ff 75 10             	pushl  0x10(%ebp)
  801417:	ff 75 0c             	pushl  0xc(%ebp)
  80141a:	50                   	push   %eax
  80141b:	ff d2                	call   *%edx
  80141d:	89 c2                	mov    %eax,%edx
  80141f:	83 c4 10             	add    $0x10,%esp
  801422:	eb 09                	jmp    80142d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801424:	89 c2                	mov    %eax,%edx
  801426:	eb 05                	jmp    80142d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801428:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80142d:	89 d0                	mov    %edx,%eax
  80142f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801432:	c9                   	leave  
  801433:	c3                   	ret    

00801434 <seek>:

int
seek(int fdnum, off_t offset)
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80143a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80143d:	50                   	push   %eax
  80143e:	ff 75 08             	pushl  0x8(%ebp)
  801441:	e8 22 fc ff ff       	call   801068 <fd_lookup>
  801446:	83 c4 08             	add    $0x8,%esp
  801449:	85 c0                	test   %eax,%eax
  80144b:	78 0e                	js     80145b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80144d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801450:	8b 55 0c             	mov    0xc(%ebp),%edx
  801453:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801456:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80145b:	c9                   	leave  
  80145c:	c3                   	ret    

0080145d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80145d:	55                   	push   %ebp
  80145e:	89 e5                	mov    %esp,%ebp
  801460:	53                   	push   %ebx
  801461:	83 ec 14             	sub    $0x14,%esp
  801464:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801467:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80146a:	50                   	push   %eax
  80146b:	53                   	push   %ebx
  80146c:	e8 f7 fb ff ff       	call   801068 <fd_lookup>
  801471:	83 c4 08             	add    $0x8,%esp
  801474:	89 c2                	mov    %eax,%edx
  801476:	85 c0                	test   %eax,%eax
  801478:	78 65                	js     8014df <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80147a:	83 ec 08             	sub    $0x8,%esp
  80147d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801480:	50                   	push   %eax
  801481:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801484:	ff 30                	pushl  (%eax)
  801486:	e8 33 fc ff ff       	call   8010be <dev_lookup>
  80148b:	83 c4 10             	add    $0x10,%esp
  80148e:	85 c0                	test   %eax,%eax
  801490:	78 44                	js     8014d6 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801492:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801495:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801499:	75 21                	jne    8014bc <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80149b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014a0:	8b 40 48             	mov    0x48(%eax),%eax
  8014a3:	83 ec 04             	sub    $0x4,%esp
  8014a6:	53                   	push   %ebx
  8014a7:	50                   	push   %eax
  8014a8:	68 04 26 80 00       	push   $0x802604
  8014ad:	e8 f6 ec ff ff       	call   8001a8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014b2:	83 c4 10             	add    $0x10,%esp
  8014b5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014ba:	eb 23                	jmp    8014df <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8014bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014bf:	8b 52 18             	mov    0x18(%edx),%edx
  8014c2:	85 d2                	test   %edx,%edx
  8014c4:	74 14                	je     8014da <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014c6:	83 ec 08             	sub    $0x8,%esp
  8014c9:	ff 75 0c             	pushl  0xc(%ebp)
  8014cc:	50                   	push   %eax
  8014cd:	ff d2                	call   *%edx
  8014cf:	89 c2                	mov    %eax,%edx
  8014d1:	83 c4 10             	add    $0x10,%esp
  8014d4:	eb 09                	jmp    8014df <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d6:	89 c2                	mov    %eax,%edx
  8014d8:	eb 05                	jmp    8014df <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8014da:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8014df:	89 d0                	mov    %edx,%eax
  8014e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e4:	c9                   	leave  
  8014e5:	c3                   	ret    

008014e6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014e6:	55                   	push   %ebp
  8014e7:	89 e5                	mov    %esp,%ebp
  8014e9:	53                   	push   %ebx
  8014ea:	83 ec 14             	sub    $0x14,%esp
  8014ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f3:	50                   	push   %eax
  8014f4:	ff 75 08             	pushl  0x8(%ebp)
  8014f7:	e8 6c fb ff ff       	call   801068 <fd_lookup>
  8014fc:	83 c4 08             	add    $0x8,%esp
  8014ff:	89 c2                	mov    %eax,%edx
  801501:	85 c0                	test   %eax,%eax
  801503:	78 58                	js     80155d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801505:	83 ec 08             	sub    $0x8,%esp
  801508:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150b:	50                   	push   %eax
  80150c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150f:	ff 30                	pushl  (%eax)
  801511:	e8 a8 fb ff ff       	call   8010be <dev_lookup>
  801516:	83 c4 10             	add    $0x10,%esp
  801519:	85 c0                	test   %eax,%eax
  80151b:	78 37                	js     801554 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80151d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801520:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801524:	74 32                	je     801558 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801526:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801529:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801530:	00 00 00 
	stat->st_isdir = 0;
  801533:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80153a:	00 00 00 
	stat->st_dev = dev;
  80153d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801543:	83 ec 08             	sub    $0x8,%esp
  801546:	53                   	push   %ebx
  801547:	ff 75 f0             	pushl  -0x10(%ebp)
  80154a:	ff 50 14             	call   *0x14(%eax)
  80154d:	89 c2                	mov    %eax,%edx
  80154f:	83 c4 10             	add    $0x10,%esp
  801552:	eb 09                	jmp    80155d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801554:	89 c2                	mov    %eax,%edx
  801556:	eb 05                	jmp    80155d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801558:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80155d:	89 d0                	mov    %edx,%eax
  80155f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801562:	c9                   	leave  
  801563:	c3                   	ret    

00801564 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801564:	55                   	push   %ebp
  801565:	89 e5                	mov    %esp,%ebp
  801567:	56                   	push   %esi
  801568:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801569:	83 ec 08             	sub    $0x8,%esp
  80156c:	6a 00                	push   $0x0
  80156e:	ff 75 08             	pushl  0x8(%ebp)
  801571:	e8 d6 01 00 00       	call   80174c <open>
  801576:	89 c3                	mov    %eax,%ebx
  801578:	83 c4 10             	add    $0x10,%esp
  80157b:	85 c0                	test   %eax,%eax
  80157d:	78 1b                	js     80159a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80157f:	83 ec 08             	sub    $0x8,%esp
  801582:	ff 75 0c             	pushl  0xc(%ebp)
  801585:	50                   	push   %eax
  801586:	e8 5b ff ff ff       	call   8014e6 <fstat>
  80158b:	89 c6                	mov    %eax,%esi
	close(fd);
  80158d:	89 1c 24             	mov    %ebx,(%esp)
  801590:	e8 fd fb ff ff       	call   801192 <close>
	return r;
  801595:	83 c4 10             	add    $0x10,%esp
  801598:	89 f0                	mov    %esi,%eax
}
  80159a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80159d:	5b                   	pop    %ebx
  80159e:	5e                   	pop    %esi
  80159f:	5d                   	pop    %ebp
  8015a0:	c3                   	ret    

008015a1 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015a1:	55                   	push   %ebp
  8015a2:	89 e5                	mov    %esp,%ebp
  8015a4:	56                   	push   %esi
  8015a5:	53                   	push   %ebx
  8015a6:	89 c6                	mov    %eax,%esi
  8015a8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015aa:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015b1:	75 12                	jne    8015c5 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015b3:	83 ec 0c             	sub    $0xc,%esp
  8015b6:	6a 01                	push   $0x1
  8015b8:	e8 7e 08 00 00       	call   801e3b <ipc_find_env>
  8015bd:	a3 00 40 80 00       	mov    %eax,0x804000
  8015c2:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015c5:	6a 07                	push   $0x7
  8015c7:	68 00 50 80 00       	push   $0x805000
  8015cc:	56                   	push   %esi
  8015cd:	ff 35 00 40 80 00    	pushl  0x804000
  8015d3:	e8 0f 08 00 00       	call   801de7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8015d8:	83 c4 0c             	add    $0xc,%esp
  8015db:	6a 00                	push   $0x0
  8015dd:	53                   	push   %ebx
  8015de:	6a 00                	push   $0x0
  8015e0:	e8 9b 07 00 00       	call   801d80 <ipc_recv>
}
  8015e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015e8:	5b                   	pop    %ebx
  8015e9:	5e                   	pop    %esi
  8015ea:	5d                   	pop    %ebp
  8015eb:	c3                   	ret    

008015ec <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
  8015ef:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8015f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8015f8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8015fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801600:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801605:	ba 00 00 00 00       	mov    $0x0,%edx
  80160a:	b8 02 00 00 00       	mov    $0x2,%eax
  80160f:	e8 8d ff ff ff       	call   8015a1 <fsipc>
}
  801614:	c9                   	leave  
  801615:	c3                   	ret    

00801616 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
  801619:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80161c:	8b 45 08             	mov    0x8(%ebp),%eax
  80161f:	8b 40 0c             	mov    0xc(%eax),%eax
  801622:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801627:	ba 00 00 00 00       	mov    $0x0,%edx
  80162c:	b8 06 00 00 00       	mov    $0x6,%eax
  801631:	e8 6b ff ff ff       	call   8015a1 <fsipc>
}
  801636:	c9                   	leave  
  801637:	c3                   	ret    

00801638 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801638:	55                   	push   %ebp
  801639:	89 e5                	mov    %esp,%ebp
  80163b:	53                   	push   %ebx
  80163c:	83 ec 04             	sub    $0x4,%esp
  80163f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801642:	8b 45 08             	mov    0x8(%ebp),%eax
  801645:	8b 40 0c             	mov    0xc(%eax),%eax
  801648:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80164d:	ba 00 00 00 00       	mov    $0x0,%edx
  801652:	b8 05 00 00 00       	mov    $0x5,%eax
  801657:	e8 45 ff ff ff       	call   8015a1 <fsipc>
  80165c:	85 c0                	test   %eax,%eax
  80165e:	78 2c                	js     80168c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801660:	83 ec 08             	sub    $0x8,%esp
  801663:	68 00 50 80 00       	push   $0x805000
  801668:	53                   	push   %ebx
  801669:	e8 bf f0 ff ff       	call   80072d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80166e:	a1 80 50 80 00       	mov    0x805080,%eax
  801673:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801679:	a1 84 50 80 00       	mov    0x805084,%eax
  80167e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801684:	83 c4 10             	add    $0x10,%esp
  801687:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80168c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80168f:	c9                   	leave  
  801690:	c3                   	ret    

00801691 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801691:	55                   	push   %ebp
  801692:	89 e5                	mov    %esp,%ebp
  801694:	83 ec 0c             	sub    $0xc,%esp
  801697:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80169a:	8b 55 08             	mov    0x8(%ebp),%edx
  80169d:	8b 52 0c             	mov    0xc(%edx),%edx
  8016a0:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8016a6:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8016ab:	50                   	push   %eax
  8016ac:	ff 75 0c             	pushl  0xc(%ebp)
  8016af:	68 08 50 80 00       	push   $0x805008
  8016b4:	e8 06 f2 ff ff       	call   8008bf <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8016b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016be:	b8 04 00 00 00       	mov    $0x4,%eax
  8016c3:	e8 d9 fe ff ff       	call   8015a1 <fsipc>

}
  8016c8:	c9                   	leave  
  8016c9:	c3                   	ret    

008016ca <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	56                   	push   %esi
  8016ce:	53                   	push   %ebx
  8016cf:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016dd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e8:	b8 03 00 00 00       	mov    $0x3,%eax
  8016ed:	e8 af fe ff ff       	call   8015a1 <fsipc>
  8016f2:	89 c3                	mov    %eax,%ebx
  8016f4:	85 c0                	test   %eax,%eax
  8016f6:	78 4b                	js     801743 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8016f8:	39 c6                	cmp    %eax,%esi
  8016fa:	73 16                	jae    801712 <devfile_read+0x48>
  8016fc:	68 70 26 80 00       	push   $0x802670
  801701:	68 77 26 80 00       	push   $0x802677
  801706:	6a 7c                	push   $0x7c
  801708:	68 8c 26 80 00       	push   $0x80268c
  80170d:	e8 bd 05 00 00       	call   801ccf <_panic>
	assert(r <= PGSIZE);
  801712:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801717:	7e 16                	jle    80172f <devfile_read+0x65>
  801719:	68 97 26 80 00       	push   $0x802697
  80171e:	68 77 26 80 00       	push   $0x802677
  801723:	6a 7d                	push   $0x7d
  801725:	68 8c 26 80 00       	push   $0x80268c
  80172a:	e8 a0 05 00 00       	call   801ccf <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80172f:	83 ec 04             	sub    $0x4,%esp
  801732:	50                   	push   %eax
  801733:	68 00 50 80 00       	push   $0x805000
  801738:	ff 75 0c             	pushl  0xc(%ebp)
  80173b:	e8 7f f1 ff ff       	call   8008bf <memmove>
	return r;
  801740:	83 c4 10             	add    $0x10,%esp
}
  801743:	89 d8                	mov    %ebx,%eax
  801745:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801748:	5b                   	pop    %ebx
  801749:	5e                   	pop    %esi
  80174a:	5d                   	pop    %ebp
  80174b:	c3                   	ret    

0080174c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	53                   	push   %ebx
  801750:	83 ec 20             	sub    $0x20,%esp
  801753:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801756:	53                   	push   %ebx
  801757:	e8 98 ef ff ff       	call   8006f4 <strlen>
  80175c:	83 c4 10             	add    $0x10,%esp
  80175f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801764:	7f 67                	jg     8017cd <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801766:	83 ec 0c             	sub    $0xc,%esp
  801769:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176c:	50                   	push   %eax
  80176d:	e8 a7 f8 ff ff       	call   801019 <fd_alloc>
  801772:	83 c4 10             	add    $0x10,%esp
		return r;
  801775:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801777:	85 c0                	test   %eax,%eax
  801779:	78 57                	js     8017d2 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80177b:	83 ec 08             	sub    $0x8,%esp
  80177e:	53                   	push   %ebx
  80177f:	68 00 50 80 00       	push   $0x805000
  801784:	e8 a4 ef ff ff       	call   80072d <strcpy>
	fsipcbuf.open.req_omode = mode;
  801789:	8b 45 0c             	mov    0xc(%ebp),%eax
  80178c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801791:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801794:	b8 01 00 00 00       	mov    $0x1,%eax
  801799:	e8 03 fe ff ff       	call   8015a1 <fsipc>
  80179e:	89 c3                	mov    %eax,%ebx
  8017a0:	83 c4 10             	add    $0x10,%esp
  8017a3:	85 c0                	test   %eax,%eax
  8017a5:	79 14                	jns    8017bb <open+0x6f>
		fd_close(fd, 0);
  8017a7:	83 ec 08             	sub    $0x8,%esp
  8017aa:	6a 00                	push   $0x0
  8017ac:	ff 75 f4             	pushl  -0xc(%ebp)
  8017af:	e8 5d f9 ff ff       	call   801111 <fd_close>
		return r;
  8017b4:	83 c4 10             	add    $0x10,%esp
  8017b7:	89 da                	mov    %ebx,%edx
  8017b9:	eb 17                	jmp    8017d2 <open+0x86>
	}

	return fd2num(fd);
  8017bb:	83 ec 0c             	sub    $0xc,%esp
  8017be:	ff 75 f4             	pushl  -0xc(%ebp)
  8017c1:	e8 2c f8 ff ff       	call   800ff2 <fd2num>
  8017c6:	89 c2                	mov    %eax,%edx
  8017c8:	83 c4 10             	add    $0x10,%esp
  8017cb:	eb 05                	jmp    8017d2 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017cd:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8017d2:	89 d0                	mov    %edx,%eax
  8017d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d7:	c9                   	leave  
  8017d8:	c3                   	ret    

008017d9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017d9:	55                   	push   %ebp
  8017da:	89 e5                	mov    %esp,%ebp
  8017dc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017df:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e4:	b8 08 00 00 00       	mov    $0x8,%eax
  8017e9:	e8 b3 fd ff ff       	call   8015a1 <fsipc>
}
  8017ee:	c9                   	leave  
  8017ef:	c3                   	ret    

008017f0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
  8017f3:	56                   	push   %esi
  8017f4:	53                   	push   %ebx
  8017f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8017f8:	83 ec 0c             	sub    $0xc,%esp
  8017fb:	ff 75 08             	pushl  0x8(%ebp)
  8017fe:	e8 ff f7 ff ff       	call   801002 <fd2data>
  801803:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801805:	83 c4 08             	add    $0x8,%esp
  801808:	68 a3 26 80 00       	push   $0x8026a3
  80180d:	53                   	push   %ebx
  80180e:	e8 1a ef ff ff       	call   80072d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801813:	8b 46 04             	mov    0x4(%esi),%eax
  801816:	2b 06                	sub    (%esi),%eax
  801818:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80181e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801825:	00 00 00 
	stat->st_dev = &devpipe;
  801828:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80182f:	30 80 00 
	return 0;
}
  801832:	b8 00 00 00 00       	mov    $0x0,%eax
  801837:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80183a:	5b                   	pop    %ebx
  80183b:	5e                   	pop    %esi
  80183c:	5d                   	pop    %ebp
  80183d:	c3                   	ret    

0080183e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80183e:	55                   	push   %ebp
  80183f:	89 e5                	mov    %esp,%ebp
  801841:	53                   	push   %ebx
  801842:	83 ec 0c             	sub    $0xc,%esp
  801845:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801848:	53                   	push   %ebx
  801849:	6a 00                	push   $0x0
  80184b:	e8 65 f3 ff ff       	call   800bb5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801850:	89 1c 24             	mov    %ebx,(%esp)
  801853:	e8 aa f7 ff ff       	call   801002 <fd2data>
  801858:	83 c4 08             	add    $0x8,%esp
  80185b:	50                   	push   %eax
  80185c:	6a 00                	push   $0x0
  80185e:	e8 52 f3 ff ff       	call   800bb5 <sys_page_unmap>
}
  801863:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801866:	c9                   	leave  
  801867:	c3                   	ret    

00801868 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	57                   	push   %edi
  80186c:	56                   	push   %esi
  80186d:	53                   	push   %ebx
  80186e:	83 ec 1c             	sub    $0x1c,%esp
  801871:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801874:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801876:	a1 04 40 80 00       	mov    0x804004,%eax
  80187b:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80187e:	83 ec 0c             	sub    $0xc,%esp
  801881:	ff 75 e0             	pushl  -0x20(%ebp)
  801884:	e8 eb 05 00 00       	call   801e74 <pageref>
  801889:	89 c3                	mov    %eax,%ebx
  80188b:	89 3c 24             	mov    %edi,(%esp)
  80188e:	e8 e1 05 00 00       	call   801e74 <pageref>
  801893:	83 c4 10             	add    $0x10,%esp
  801896:	39 c3                	cmp    %eax,%ebx
  801898:	0f 94 c1             	sete   %cl
  80189b:	0f b6 c9             	movzbl %cl,%ecx
  80189e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8018a1:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8018a7:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8018aa:	39 ce                	cmp    %ecx,%esi
  8018ac:	74 1b                	je     8018c9 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8018ae:	39 c3                	cmp    %eax,%ebx
  8018b0:	75 c4                	jne    801876 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018b2:	8b 42 58             	mov    0x58(%edx),%eax
  8018b5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018b8:	50                   	push   %eax
  8018b9:	56                   	push   %esi
  8018ba:	68 aa 26 80 00       	push   $0x8026aa
  8018bf:	e8 e4 e8 ff ff       	call   8001a8 <cprintf>
  8018c4:	83 c4 10             	add    $0x10,%esp
  8018c7:	eb ad                	jmp    801876 <_pipeisclosed+0xe>
	}
}
  8018c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018cf:	5b                   	pop    %ebx
  8018d0:	5e                   	pop    %esi
  8018d1:	5f                   	pop    %edi
  8018d2:	5d                   	pop    %ebp
  8018d3:	c3                   	ret    

008018d4 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018d4:	55                   	push   %ebp
  8018d5:	89 e5                	mov    %esp,%ebp
  8018d7:	57                   	push   %edi
  8018d8:	56                   	push   %esi
  8018d9:	53                   	push   %ebx
  8018da:	83 ec 28             	sub    $0x28,%esp
  8018dd:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8018e0:	56                   	push   %esi
  8018e1:	e8 1c f7 ff ff       	call   801002 <fd2data>
  8018e6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018e8:	83 c4 10             	add    $0x10,%esp
  8018eb:	bf 00 00 00 00       	mov    $0x0,%edi
  8018f0:	eb 4b                	jmp    80193d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8018f2:	89 da                	mov    %ebx,%edx
  8018f4:	89 f0                	mov    %esi,%eax
  8018f6:	e8 6d ff ff ff       	call   801868 <_pipeisclosed>
  8018fb:	85 c0                	test   %eax,%eax
  8018fd:	75 48                	jne    801947 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8018ff:	e8 0d f2 ff ff       	call   800b11 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801904:	8b 43 04             	mov    0x4(%ebx),%eax
  801907:	8b 0b                	mov    (%ebx),%ecx
  801909:	8d 51 20             	lea    0x20(%ecx),%edx
  80190c:	39 d0                	cmp    %edx,%eax
  80190e:	73 e2                	jae    8018f2 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801910:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801913:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801917:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80191a:	89 c2                	mov    %eax,%edx
  80191c:	c1 fa 1f             	sar    $0x1f,%edx
  80191f:	89 d1                	mov    %edx,%ecx
  801921:	c1 e9 1b             	shr    $0x1b,%ecx
  801924:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801927:	83 e2 1f             	and    $0x1f,%edx
  80192a:	29 ca                	sub    %ecx,%edx
  80192c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801930:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801934:	83 c0 01             	add    $0x1,%eax
  801937:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80193a:	83 c7 01             	add    $0x1,%edi
  80193d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801940:	75 c2                	jne    801904 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801942:	8b 45 10             	mov    0x10(%ebp),%eax
  801945:	eb 05                	jmp    80194c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801947:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80194c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80194f:	5b                   	pop    %ebx
  801950:	5e                   	pop    %esi
  801951:	5f                   	pop    %edi
  801952:	5d                   	pop    %ebp
  801953:	c3                   	ret    

00801954 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	57                   	push   %edi
  801958:	56                   	push   %esi
  801959:	53                   	push   %ebx
  80195a:	83 ec 18             	sub    $0x18,%esp
  80195d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801960:	57                   	push   %edi
  801961:	e8 9c f6 ff ff       	call   801002 <fd2data>
  801966:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801968:	83 c4 10             	add    $0x10,%esp
  80196b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801970:	eb 3d                	jmp    8019af <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801972:	85 db                	test   %ebx,%ebx
  801974:	74 04                	je     80197a <devpipe_read+0x26>
				return i;
  801976:	89 d8                	mov    %ebx,%eax
  801978:	eb 44                	jmp    8019be <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80197a:	89 f2                	mov    %esi,%edx
  80197c:	89 f8                	mov    %edi,%eax
  80197e:	e8 e5 fe ff ff       	call   801868 <_pipeisclosed>
  801983:	85 c0                	test   %eax,%eax
  801985:	75 32                	jne    8019b9 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801987:	e8 85 f1 ff ff       	call   800b11 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80198c:	8b 06                	mov    (%esi),%eax
  80198e:	3b 46 04             	cmp    0x4(%esi),%eax
  801991:	74 df                	je     801972 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801993:	99                   	cltd   
  801994:	c1 ea 1b             	shr    $0x1b,%edx
  801997:	01 d0                	add    %edx,%eax
  801999:	83 e0 1f             	and    $0x1f,%eax
  80199c:	29 d0                	sub    %edx,%eax
  80199e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8019a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019a6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8019a9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019ac:	83 c3 01             	add    $0x1,%ebx
  8019af:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019b2:	75 d8                	jne    80198c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8019b7:	eb 05                	jmp    8019be <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019b9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019c1:	5b                   	pop    %ebx
  8019c2:	5e                   	pop    %esi
  8019c3:	5f                   	pop    %edi
  8019c4:	5d                   	pop    %ebp
  8019c5:	c3                   	ret    

008019c6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8019c6:	55                   	push   %ebp
  8019c7:	89 e5                	mov    %esp,%ebp
  8019c9:	56                   	push   %esi
  8019ca:	53                   	push   %ebx
  8019cb:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8019ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019d1:	50                   	push   %eax
  8019d2:	e8 42 f6 ff ff       	call   801019 <fd_alloc>
  8019d7:	83 c4 10             	add    $0x10,%esp
  8019da:	89 c2                	mov    %eax,%edx
  8019dc:	85 c0                	test   %eax,%eax
  8019de:	0f 88 2c 01 00 00    	js     801b10 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019e4:	83 ec 04             	sub    $0x4,%esp
  8019e7:	68 07 04 00 00       	push   $0x407
  8019ec:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ef:	6a 00                	push   $0x0
  8019f1:	e8 3a f1 ff ff       	call   800b30 <sys_page_alloc>
  8019f6:	83 c4 10             	add    $0x10,%esp
  8019f9:	89 c2                	mov    %eax,%edx
  8019fb:	85 c0                	test   %eax,%eax
  8019fd:	0f 88 0d 01 00 00    	js     801b10 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a03:	83 ec 0c             	sub    $0xc,%esp
  801a06:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a09:	50                   	push   %eax
  801a0a:	e8 0a f6 ff ff       	call   801019 <fd_alloc>
  801a0f:	89 c3                	mov    %eax,%ebx
  801a11:	83 c4 10             	add    $0x10,%esp
  801a14:	85 c0                	test   %eax,%eax
  801a16:	0f 88 e2 00 00 00    	js     801afe <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a1c:	83 ec 04             	sub    $0x4,%esp
  801a1f:	68 07 04 00 00       	push   $0x407
  801a24:	ff 75 f0             	pushl  -0x10(%ebp)
  801a27:	6a 00                	push   $0x0
  801a29:	e8 02 f1 ff ff       	call   800b30 <sys_page_alloc>
  801a2e:	89 c3                	mov    %eax,%ebx
  801a30:	83 c4 10             	add    $0x10,%esp
  801a33:	85 c0                	test   %eax,%eax
  801a35:	0f 88 c3 00 00 00    	js     801afe <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a3b:	83 ec 0c             	sub    $0xc,%esp
  801a3e:	ff 75 f4             	pushl  -0xc(%ebp)
  801a41:	e8 bc f5 ff ff       	call   801002 <fd2data>
  801a46:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a48:	83 c4 0c             	add    $0xc,%esp
  801a4b:	68 07 04 00 00       	push   $0x407
  801a50:	50                   	push   %eax
  801a51:	6a 00                	push   $0x0
  801a53:	e8 d8 f0 ff ff       	call   800b30 <sys_page_alloc>
  801a58:	89 c3                	mov    %eax,%ebx
  801a5a:	83 c4 10             	add    $0x10,%esp
  801a5d:	85 c0                	test   %eax,%eax
  801a5f:	0f 88 89 00 00 00    	js     801aee <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a65:	83 ec 0c             	sub    $0xc,%esp
  801a68:	ff 75 f0             	pushl  -0x10(%ebp)
  801a6b:	e8 92 f5 ff ff       	call   801002 <fd2data>
  801a70:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a77:	50                   	push   %eax
  801a78:	6a 00                	push   $0x0
  801a7a:	56                   	push   %esi
  801a7b:	6a 00                	push   $0x0
  801a7d:	e8 f1 f0 ff ff       	call   800b73 <sys_page_map>
  801a82:	89 c3                	mov    %eax,%ebx
  801a84:	83 c4 20             	add    $0x20,%esp
  801a87:	85 c0                	test   %eax,%eax
  801a89:	78 55                	js     801ae0 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a8b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a94:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a99:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801aa0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801aa6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aa9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801aab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aae:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ab5:	83 ec 0c             	sub    $0xc,%esp
  801ab8:	ff 75 f4             	pushl  -0xc(%ebp)
  801abb:	e8 32 f5 ff ff       	call   800ff2 <fd2num>
  801ac0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ac3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ac5:	83 c4 04             	add    $0x4,%esp
  801ac8:	ff 75 f0             	pushl  -0x10(%ebp)
  801acb:	e8 22 f5 ff ff       	call   800ff2 <fd2num>
  801ad0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ad3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ad6:	83 c4 10             	add    $0x10,%esp
  801ad9:	ba 00 00 00 00       	mov    $0x0,%edx
  801ade:	eb 30                	jmp    801b10 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ae0:	83 ec 08             	sub    $0x8,%esp
  801ae3:	56                   	push   %esi
  801ae4:	6a 00                	push   $0x0
  801ae6:	e8 ca f0 ff ff       	call   800bb5 <sys_page_unmap>
  801aeb:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801aee:	83 ec 08             	sub    $0x8,%esp
  801af1:	ff 75 f0             	pushl  -0x10(%ebp)
  801af4:	6a 00                	push   $0x0
  801af6:	e8 ba f0 ff ff       	call   800bb5 <sys_page_unmap>
  801afb:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801afe:	83 ec 08             	sub    $0x8,%esp
  801b01:	ff 75 f4             	pushl  -0xc(%ebp)
  801b04:	6a 00                	push   $0x0
  801b06:	e8 aa f0 ff ff       	call   800bb5 <sys_page_unmap>
  801b0b:	83 c4 10             	add    $0x10,%esp
  801b0e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b10:	89 d0                	mov    %edx,%eax
  801b12:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b15:	5b                   	pop    %ebx
  801b16:	5e                   	pop    %esi
  801b17:	5d                   	pop    %ebp
  801b18:	c3                   	ret    

00801b19 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b22:	50                   	push   %eax
  801b23:	ff 75 08             	pushl  0x8(%ebp)
  801b26:	e8 3d f5 ff ff       	call   801068 <fd_lookup>
  801b2b:	83 c4 10             	add    $0x10,%esp
  801b2e:	85 c0                	test   %eax,%eax
  801b30:	78 18                	js     801b4a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b32:	83 ec 0c             	sub    $0xc,%esp
  801b35:	ff 75 f4             	pushl  -0xc(%ebp)
  801b38:	e8 c5 f4 ff ff       	call   801002 <fd2data>
	return _pipeisclosed(fd, p);
  801b3d:	89 c2                	mov    %eax,%edx
  801b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b42:	e8 21 fd ff ff       	call   801868 <_pipeisclosed>
  801b47:	83 c4 10             	add    $0x10,%esp
}
  801b4a:	c9                   	leave  
  801b4b:	c3                   	ret    

00801b4c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b4f:	b8 00 00 00 00       	mov    $0x0,%eax
  801b54:	5d                   	pop    %ebp
  801b55:	c3                   	ret    

00801b56 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b56:	55                   	push   %ebp
  801b57:	89 e5                	mov    %esp,%ebp
  801b59:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b5c:	68 c2 26 80 00       	push   $0x8026c2
  801b61:	ff 75 0c             	pushl  0xc(%ebp)
  801b64:	e8 c4 eb ff ff       	call   80072d <strcpy>
	return 0;
}
  801b69:	b8 00 00 00 00       	mov    $0x0,%eax
  801b6e:	c9                   	leave  
  801b6f:	c3                   	ret    

00801b70 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b70:	55                   	push   %ebp
  801b71:	89 e5                	mov    %esp,%ebp
  801b73:	57                   	push   %edi
  801b74:	56                   	push   %esi
  801b75:	53                   	push   %ebx
  801b76:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b7c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b81:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b87:	eb 2d                	jmp    801bb6 <devcons_write+0x46>
		m = n - tot;
  801b89:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b8c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801b8e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801b91:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801b96:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b99:	83 ec 04             	sub    $0x4,%esp
  801b9c:	53                   	push   %ebx
  801b9d:	03 45 0c             	add    0xc(%ebp),%eax
  801ba0:	50                   	push   %eax
  801ba1:	57                   	push   %edi
  801ba2:	e8 18 ed ff ff       	call   8008bf <memmove>
		sys_cputs(buf, m);
  801ba7:	83 c4 08             	add    $0x8,%esp
  801baa:	53                   	push   %ebx
  801bab:	57                   	push   %edi
  801bac:	e8 c3 ee ff ff       	call   800a74 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bb1:	01 de                	add    %ebx,%esi
  801bb3:	83 c4 10             	add    $0x10,%esp
  801bb6:	89 f0                	mov    %esi,%eax
  801bb8:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bbb:	72 cc                	jb     801b89 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801bbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc0:	5b                   	pop    %ebx
  801bc1:	5e                   	pop    %esi
  801bc2:	5f                   	pop    %edi
  801bc3:	5d                   	pop    %ebp
  801bc4:	c3                   	ret    

00801bc5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bc5:	55                   	push   %ebp
  801bc6:	89 e5                	mov    %esp,%ebp
  801bc8:	83 ec 08             	sub    $0x8,%esp
  801bcb:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801bd0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bd4:	74 2a                	je     801c00 <devcons_read+0x3b>
  801bd6:	eb 05                	jmp    801bdd <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801bd8:	e8 34 ef ff ff       	call   800b11 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801bdd:	e8 b0 ee ff ff       	call   800a92 <sys_cgetc>
  801be2:	85 c0                	test   %eax,%eax
  801be4:	74 f2                	je     801bd8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801be6:	85 c0                	test   %eax,%eax
  801be8:	78 16                	js     801c00 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801bea:	83 f8 04             	cmp    $0x4,%eax
  801bed:	74 0c                	je     801bfb <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801bef:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bf2:	88 02                	mov    %al,(%edx)
	return 1;
  801bf4:	b8 01 00 00 00       	mov    $0x1,%eax
  801bf9:	eb 05                	jmp    801c00 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801bfb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c00:	c9                   	leave  
  801c01:	c3                   	ret    

00801c02 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c02:	55                   	push   %ebp
  801c03:	89 e5                	mov    %esp,%ebp
  801c05:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c08:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c0e:	6a 01                	push   $0x1
  801c10:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c13:	50                   	push   %eax
  801c14:	e8 5b ee ff ff       	call   800a74 <sys_cputs>
}
  801c19:	83 c4 10             	add    $0x10,%esp
  801c1c:	c9                   	leave  
  801c1d:	c3                   	ret    

00801c1e <getchar>:

int
getchar(void)
{
  801c1e:	55                   	push   %ebp
  801c1f:	89 e5                	mov    %esp,%ebp
  801c21:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c24:	6a 01                	push   $0x1
  801c26:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c29:	50                   	push   %eax
  801c2a:	6a 00                	push   $0x0
  801c2c:	e8 9d f6 ff ff       	call   8012ce <read>
	if (r < 0)
  801c31:	83 c4 10             	add    $0x10,%esp
  801c34:	85 c0                	test   %eax,%eax
  801c36:	78 0f                	js     801c47 <getchar+0x29>
		return r;
	if (r < 1)
  801c38:	85 c0                	test   %eax,%eax
  801c3a:	7e 06                	jle    801c42 <getchar+0x24>
		return -E_EOF;
	return c;
  801c3c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c40:	eb 05                	jmp    801c47 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c42:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c47:	c9                   	leave  
  801c48:	c3                   	ret    

00801c49 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c49:	55                   	push   %ebp
  801c4a:	89 e5                	mov    %esp,%ebp
  801c4c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c52:	50                   	push   %eax
  801c53:	ff 75 08             	pushl  0x8(%ebp)
  801c56:	e8 0d f4 ff ff       	call   801068 <fd_lookup>
  801c5b:	83 c4 10             	add    $0x10,%esp
  801c5e:	85 c0                	test   %eax,%eax
  801c60:	78 11                	js     801c73 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c65:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c6b:	39 10                	cmp    %edx,(%eax)
  801c6d:	0f 94 c0             	sete   %al
  801c70:	0f b6 c0             	movzbl %al,%eax
}
  801c73:	c9                   	leave  
  801c74:	c3                   	ret    

00801c75 <opencons>:

int
opencons(void)
{
  801c75:	55                   	push   %ebp
  801c76:	89 e5                	mov    %esp,%ebp
  801c78:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c7e:	50                   	push   %eax
  801c7f:	e8 95 f3 ff ff       	call   801019 <fd_alloc>
  801c84:	83 c4 10             	add    $0x10,%esp
		return r;
  801c87:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c89:	85 c0                	test   %eax,%eax
  801c8b:	78 3e                	js     801ccb <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c8d:	83 ec 04             	sub    $0x4,%esp
  801c90:	68 07 04 00 00       	push   $0x407
  801c95:	ff 75 f4             	pushl  -0xc(%ebp)
  801c98:	6a 00                	push   $0x0
  801c9a:	e8 91 ee ff ff       	call   800b30 <sys_page_alloc>
  801c9f:	83 c4 10             	add    $0x10,%esp
		return r;
  801ca2:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ca4:	85 c0                	test   %eax,%eax
  801ca6:	78 23                	js     801ccb <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ca8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801cbd:	83 ec 0c             	sub    $0xc,%esp
  801cc0:	50                   	push   %eax
  801cc1:	e8 2c f3 ff ff       	call   800ff2 <fd2num>
  801cc6:	89 c2                	mov    %eax,%edx
  801cc8:	83 c4 10             	add    $0x10,%esp
}
  801ccb:	89 d0                	mov    %edx,%eax
  801ccd:	c9                   	leave  
  801cce:	c3                   	ret    

00801ccf <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ccf:	55                   	push   %ebp
  801cd0:	89 e5                	mov    %esp,%ebp
  801cd2:	56                   	push   %esi
  801cd3:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801cd4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801cd7:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801cdd:	e8 10 ee ff ff       	call   800af2 <sys_getenvid>
  801ce2:	83 ec 0c             	sub    $0xc,%esp
  801ce5:	ff 75 0c             	pushl  0xc(%ebp)
  801ce8:	ff 75 08             	pushl  0x8(%ebp)
  801ceb:	56                   	push   %esi
  801cec:	50                   	push   %eax
  801ced:	68 d0 26 80 00       	push   $0x8026d0
  801cf2:	e8 b1 e4 ff ff       	call   8001a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801cf7:	83 c4 18             	add    $0x18,%esp
  801cfa:	53                   	push   %ebx
  801cfb:	ff 75 10             	pushl  0x10(%ebp)
  801cfe:	e8 54 e4 ff ff       	call   800157 <vcprintf>
	cprintf("\n");
  801d03:	c7 04 24 d4 21 80 00 	movl   $0x8021d4,(%esp)
  801d0a:	e8 99 e4 ff ff       	call   8001a8 <cprintf>
  801d0f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d12:	cc                   	int3   
  801d13:	eb fd                	jmp    801d12 <_panic+0x43>

00801d15 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d15:	55                   	push   %ebp
  801d16:	89 e5                	mov    %esp,%ebp
  801d18:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d1b:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d22:	75 2e                	jne    801d52 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801d24:	e8 c9 ed ff ff       	call   800af2 <sys_getenvid>
  801d29:	83 ec 04             	sub    $0x4,%esp
  801d2c:	68 07 0e 00 00       	push   $0xe07
  801d31:	68 00 f0 bf ee       	push   $0xeebff000
  801d36:	50                   	push   %eax
  801d37:	e8 f4 ed ff ff       	call   800b30 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801d3c:	e8 b1 ed ff ff       	call   800af2 <sys_getenvid>
  801d41:	83 c4 08             	add    $0x8,%esp
  801d44:	68 5c 1d 80 00       	push   $0x801d5c
  801d49:	50                   	push   %eax
  801d4a:	e8 2c ef ff ff       	call   800c7b <sys_env_set_pgfault_upcall>
  801d4f:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d52:	8b 45 08             	mov    0x8(%ebp),%eax
  801d55:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801d5a:	c9                   	leave  
  801d5b:	c3                   	ret    

00801d5c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801d5c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801d5d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801d62:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801d64:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  801d67:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  801d6b:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  801d6f:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  801d72:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  801d75:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  801d76:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  801d79:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  801d7a:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  801d7b:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  801d7f:	c3                   	ret    

00801d80 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d80:	55                   	push   %ebp
  801d81:	89 e5                	mov    %esp,%ebp
  801d83:	56                   	push   %esi
  801d84:	53                   	push   %ebx
  801d85:	8b 75 08             	mov    0x8(%ebp),%esi
  801d88:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801d8e:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801d90:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801d95:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801d98:	83 ec 0c             	sub    $0xc,%esp
  801d9b:	50                   	push   %eax
  801d9c:	e8 3f ef ff ff       	call   800ce0 <sys_ipc_recv>

	if (from_env_store != NULL)
  801da1:	83 c4 10             	add    $0x10,%esp
  801da4:	85 f6                	test   %esi,%esi
  801da6:	74 14                	je     801dbc <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801da8:	ba 00 00 00 00       	mov    $0x0,%edx
  801dad:	85 c0                	test   %eax,%eax
  801daf:	78 09                	js     801dba <ipc_recv+0x3a>
  801db1:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801db7:	8b 52 74             	mov    0x74(%edx),%edx
  801dba:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801dbc:	85 db                	test   %ebx,%ebx
  801dbe:	74 14                	je     801dd4 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801dc0:	ba 00 00 00 00       	mov    $0x0,%edx
  801dc5:	85 c0                	test   %eax,%eax
  801dc7:	78 09                	js     801dd2 <ipc_recv+0x52>
  801dc9:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801dcf:	8b 52 78             	mov    0x78(%edx),%edx
  801dd2:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801dd4:	85 c0                	test   %eax,%eax
  801dd6:	78 08                	js     801de0 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801dd8:	a1 04 40 80 00       	mov    0x804004,%eax
  801ddd:	8b 40 70             	mov    0x70(%eax),%eax
}
  801de0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801de3:	5b                   	pop    %ebx
  801de4:	5e                   	pop    %esi
  801de5:	5d                   	pop    %ebp
  801de6:	c3                   	ret    

00801de7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801de7:	55                   	push   %ebp
  801de8:	89 e5                	mov    %esp,%ebp
  801dea:	57                   	push   %edi
  801deb:	56                   	push   %esi
  801dec:	53                   	push   %ebx
  801ded:	83 ec 0c             	sub    $0xc,%esp
  801df0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801df3:	8b 75 0c             	mov    0xc(%ebp),%esi
  801df6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801df9:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801dfb:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e00:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801e03:	ff 75 14             	pushl  0x14(%ebp)
  801e06:	53                   	push   %ebx
  801e07:	56                   	push   %esi
  801e08:	57                   	push   %edi
  801e09:	e8 af ee ff ff       	call   800cbd <sys_ipc_try_send>

		if (err < 0) {
  801e0e:	83 c4 10             	add    $0x10,%esp
  801e11:	85 c0                	test   %eax,%eax
  801e13:	79 1e                	jns    801e33 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801e15:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e18:	75 07                	jne    801e21 <ipc_send+0x3a>
				sys_yield();
  801e1a:	e8 f2 ec ff ff       	call   800b11 <sys_yield>
  801e1f:	eb e2                	jmp    801e03 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801e21:	50                   	push   %eax
  801e22:	68 f4 26 80 00       	push   $0x8026f4
  801e27:	6a 49                	push   $0x49
  801e29:	68 01 27 80 00       	push   $0x802701
  801e2e:	e8 9c fe ff ff       	call   801ccf <_panic>
		}

	} while (err < 0);

}
  801e33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e36:	5b                   	pop    %ebx
  801e37:	5e                   	pop    %esi
  801e38:	5f                   	pop    %edi
  801e39:	5d                   	pop    %ebp
  801e3a:	c3                   	ret    

00801e3b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e3b:	55                   	push   %ebp
  801e3c:	89 e5                	mov    %esp,%ebp
  801e3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801e41:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801e46:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801e49:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e4f:	8b 52 50             	mov    0x50(%edx),%edx
  801e52:	39 ca                	cmp    %ecx,%edx
  801e54:	75 0d                	jne    801e63 <ipc_find_env+0x28>
			return envs[i].env_id;
  801e56:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e59:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e5e:	8b 40 48             	mov    0x48(%eax),%eax
  801e61:	eb 0f                	jmp    801e72 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e63:	83 c0 01             	add    $0x1,%eax
  801e66:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e6b:	75 d9                	jne    801e46 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801e6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e72:	5d                   	pop    %ebp
  801e73:	c3                   	ret    

00801e74 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e74:	55                   	push   %ebp
  801e75:	89 e5                	mov    %esp,%ebp
  801e77:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e7a:	89 d0                	mov    %edx,%eax
  801e7c:	c1 e8 16             	shr    $0x16,%eax
  801e7f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e86:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e8b:	f6 c1 01             	test   $0x1,%cl
  801e8e:	74 1d                	je     801ead <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e90:	c1 ea 0c             	shr    $0xc,%edx
  801e93:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e9a:	f6 c2 01             	test   $0x1,%dl
  801e9d:	74 0e                	je     801ead <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e9f:	c1 ea 0c             	shr    $0xc,%edx
  801ea2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ea9:	ef 
  801eaa:	0f b7 c0             	movzwl %ax,%eax
}
  801ead:	5d                   	pop    %ebp
  801eae:	c3                   	ret    
  801eaf:	90                   	nop

00801eb0 <__udivdi3>:
  801eb0:	55                   	push   %ebp
  801eb1:	57                   	push   %edi
  801eb2:	56                   	push   %esi
  801eb3:	53                   	push   %ebx
  801eb4:	83 ec 1c             	sub    $0x1c,%esp
  801eb7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801ebb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801ebf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ec3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ec7:	85 f6                	test   %esi,%esi
  801ec9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ecd:	89 ca                	mov    %ecx,%edx
  801ecf:	89 f8                	mov    %edi,%eax
  801ed1:	75 3d                	jne    801f10 <__udivdi3+0x60>
  801ed3:	39 cf                	cmp    %ecx,%edi
  801ed5:	0f 87 c5 00 00 00    	ja     801fa0 <__udivdi3+0xf0>
  801edb:	85 ff                	test   %edi,%edi
  801edd:	89 fd                	mov    %edi,%ebp
  801edf:	75 0b                	jne    801eec <__udivdi3+0x3c>
  801ee1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ee6:	31 d2                	xor    %edx,%edx
  801ee8:	f7 f7                	div    %edi
  801eea:	89 c5                	mov    %eax,%ebp
  801eec:	89 c8                	mov    %ecx,%eax
  801eee:	31 d2                	xor    %edx,%edx
  801ef0:	f7 f5                	div    %ebp
  801ef2:	89 c1                	mov    %eax,%ecx
  801ef4:	89 d8                	mov    %ebx,%eax
  801ef6:	89 cf                	mov    %ecx,%edi
  801ef8:	f7 f5                	div    %ebp
  801efa:	89 c3                	mov    %eax,%ebx
  801efc:	89 d8                	mov    %ebx,%eax
  801efe:	89 fa                	mov    %edi,%edx
  801f00:	83 c4 1c             	add    $0x1c,%esp
  801f03:	5b                   	pop    %ebx
  801f04:	5e                   	pop    %esi
  801f05:	5f                   	pop    %edi
  801f06:	5d                   	pop    %ebp
  801f07:	c3                   	ret    
  801f08:	90                   	nop
  801f09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f10:	39 ce                	cmp    %ecx,%esi
  801f12:	77 74                	ja     801f88 <__udivdi3+0xd8>
  801f14:	0f bd fe             	bsr    %esi,%edi
  801f17:	83 f7 1f             	xor    $0x1f,%edi
  801f1a:	0f 84 98 00 00 00    	je     801fb8 <__udivdi3+0x108>
  801f20:	bb 20 00 00 00       	mov    $0x20,%ebx
  801f25:	89 f9                	mov    %edi,%ecx
  801f27:	89 c5                	mov    %eax,%ebp
  801f29:	29 fb                	sub    %edi,%ebx
  801f2b:	d3 e6                	shl    %cl,%esi
  801f2d:	89 d9                	mov    %ebx,%ecx
  801f2f:	d3 ed                	shr    %cl,%ebp
  801f31:	89 f9                	mov    %edi,%ecx
  801f33:	d3 e0                	shl    %cl,%eax
  801f35:	09 ee                	or     %ebp,%esi
  801f37:	89 d9                	mov    %ebx,%ecx
  801f39:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f3d:	89 d5                	mov    %edx,%ebp
  801f3f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f43:	d3 ed                	shr    %cl,%ebp
  801f45:	89 f9                	mov    %edi,%ecx
  801f47:	d3 e2                	shl    %cl,%edx
  801f49:	89 d9                	mov    %ebx,%ecx
  801f4b:	d3 e8                	shr    %cl,%eax
  801f4d:	09 c2                	or     %eax,%edx
  801f4f:	89 d0                	mov    %edx,%eax
  801f51:	89 ea                	mov    %ebp,%edx
  801f53:	f7 f6                	div    %esi
  801f55:	89 d5                	mov    %edx,%ebp
  801f57:	89 c3                	mov    %eax,%ebx
  801f59:	f7 64 24 0c          	mull   0xc(%esp)
  801f5d:	39 d5                	cmp    %edx,%ebp
  801f5f:	72 10                	jb     801f71 <__udivdi3+0xc1>
  801f61:	8b 74 24 08          	mov    0x8(%esp),%esi
  801f65:	89 f9                	mov    %edi,%ecx
  801f67:	d3 e6                	shl    %cl,%esi
  801f69:	39 c6                	cmp    %eax,%esi
  801f6b:	73 07                	jae    801f74 <__udivdi3+0xc4>
  801f6d:	39 d5                	cmp    %edx,%ebp
  801f6f:	75 03                	jne    801f74 <__udivdi3+0xc4>
  801f71:	83 eb 01             	sub    $0x1,%ebx
  801f74:	31 ff                	xor    %edi,%edi
  801f76:	89 d8                	mov    %ebx,%eax
  801f78:	89 fa                	mov    %edi,%edx
  801f7a:	83 c4 1c             	add    $0x1c,%esp
  801f7d:	5b                   	pop    %ebx
  801f7e:	5e                   	pop    %esi
  801f7f:	5f                   	pop    %edi
  801f80:	5d                   	pop    %ebp
  801f81:	c3                   	ret    
  801f82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f88:	31 ff                	xor    %edi,%edi
  801f8a:	31 db                	xor    %ebx,%ebx
  801f8c:	89 d8                	mov    %ebx,%eax
  801f8e:	89 fa                	mov    %edi,%edx
  801f90:	83 c4 1c             	add    $0x1c,%esp
  801f93:	5b                   	pop    %ebx
  801f94:	5e                   	pop    %esi
  801f95:	5f                   	pop    %edi
  801f96:	5d                   	pop    %ebp
  801f97:	c3                   	ret    
  801f98:	90                   	nop
  801f99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fa0:	89 d8                	mov    %ebx,%eax
  801fa2:	f7 f7                	div    %edi
  801fa4:	31 ff                	xor    %edi,%edi
  801fa6:	89 c3                	mov    %eax,%ebx
  801fa8:	89 d8                	mov    %ebx,%eax
  801faa:	89 fa                	mov    %edi,%edx
  801fac:	83 c4 1c             	add    $0x1c,%esp
  801faf:	5b                   	pop    %ebx
  801fb0:	5e                   	pop    %esi
  801fb1:	5f                   	pop    %edi
  801fb2:	5d                   	pop    %ebp
  801fb3:	c3                   	ret    
  801fb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fb8:	39 ce                	cmp    %ecx,%esi
  801fba:	72 0c                	jb     801fc8 <__udivdi3+0x118>
  801fbc:	31 db                	xor    %ebx,%ebx
  801fbe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801fc2:	0f 87 34 ff ff ff    	ja     801efc <__udivdi3+0x4c>
  801fc8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801fcd:	e9 2a ff ff ff       	jmp    801efc <__udivdi3+0x4c>
  801fd2:	66 90                	xchg   %ax,%ax
  801fd4:	66 90                	xchg   %ax,%ax
  801fd6:	66 90                	xchg   %ax,%ax
  801fd8:	66 90                	xchg   %ax,%ax
  801fda:	66 90                	xchg   %ax,%ax
  801fdc:	66 90                	xchg   %ax,%ax
  801fde:	66 90                	xchg   %ax,%ax

00801fe0 <__umoddi3>:
  801fe0:	55                   	push   %ebp
  801fe1:	57                   	push   %edi
  801fe2:	56                   	push   %esi
  801fe3:	53                   	push   %ebx
  801fe4:	83 ec 1c             	sub    $0x1c,%esp
  801fe7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801feb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801fef:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ff3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ff7:	85 d2                	test   %edx,%edx
  801ff9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ffd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802001:	89 f3                	mov    %esi,%ebx
  802003:	89 3c 24             	mov    %edi,(%esp)
  802006:	89 74 24 04          	mov    %esi,0x4(%esp)
  80200a:	75 1c                	jne    802028 <__umoddi3+0x48>
  80200c:	39 f7                	cmp    %esi,%edi
  80200e:	76 50                	jbe    802060 <__umoddi3+0x80>
  802010:	89 c8                	mov    %ecx,%eax
  802012:	89 f2                	mov    %esi,%edx
  802014:	f7 f7                	div    %edi
  802016:	89 d0                	mov    %edx,%eax
  802018:	31 d2                	xor    %edx,%edx
  80201a:	83 c4 1c             	add    $0x1c,%esp
  80201d:	5b                   	pop    %ebx
  80201e:	5e                   	pop    %esi
  80201f:	5f                   	pop    %edi
  802020:	5d                   	pop    %ebp
  802021:	c3                   	ret    
  802022:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802028:	39 f2                	cmp    %esi,%edx
  80202a:	89 d0                	mov    %edx,%eax
  80202c:	77 52                	ja     802080 <__umoddi3+0xa0>
  80202e:	0f bd ea             	bsr    %edx,%ebp
  802031:	83 f5 1f             	xor    $0x1f,%ebp
  802034:	75 5a                	jne    802090 <__umoddi3+0xb0>
  802036:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80203a:	0f 82 e0 00 00 00    	jb     802120 <__umoddi3+0x140>
  802040:	39 0c 24             	cmp    %ecx,(%esp)
  802043:	0f 86 d7 00 00 00    	jbe    802120 <__umoddi3+0x140>
  802049:	8b 44 24 08          	mov    0x8(%esp),%eax
  80204d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802051:	83 c4 1c             	add    $0x1c,%esp
  802054:	5b                   	pop    %ebx
  802055:	5e                   	pop    %esi
  802056:	5f                   	pop    %edi
  802057:	5d                   	pop    %ebp
  802058:	c3                   	ret    
  802059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802060:	85 ff                	test   %edi,%edi
  802062:	89 fd                	mov    %edi,%ebp
  802064:	75 0b                	jne    802071 <__umoddi3+0x91>
  802066:	b8 01 00 00 00       	mov    $0x1,%eax
  80206b:	31 d2                	xor    %edx,%edx
  80206d:	f7 f7                	div    %edi
  80206f:	89 c5                	mov    %eax,%ebp
  802071:	89 f0                	mov    %esi,%eax
  802073:	31 d2                	xor    %edx,%edx
  802075:	f7 f5                	div    %ebp
  802077:	89 c8                	mov    %ecx,%eax
  802079:	f7 f5                	div    %ebp
  80207b:	89 d0                	mov    %edx,%eax
  80207d:	eb 99                	jmp    802018 <__umoddi3+0x38>
  80207f:	90                   	nop
  802080:	89 c8                	mov    %ecx,%eax
  802082:	89 f2                	mov    %esi,%edx
  802084:	83 c4 1c             	add    $0x1c,%esp
  802087:	5b                   	pop    %ebx
  802088:	5e                   	pop    %esi
  802089:	5f                   	pop    %edi
  80208a:	5d                   	pop    %ebp
  80208b:	c3                   	ret    
  80208c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802090:	8b 34 24             	mov    (%esp),%esi
  802093:	bf 20 00 00 00       	mov    $0x20,%edi
  802098:	89 e9                	mov    %ebp,%ecx
  80209a:	29 ef                	sub    %ebp,%edi
  80209c:	d3 e0                	shl    %cl,%eax
  80209e:	89 f9                	mov    %edi,%ecx
  8020a0:	89 f2                	mov    %esi,%edx
  8020a2:	d3 ea                	shr    %cl,%edx
  8020a4:	89 e9                	mov    %ebp,%ecx
  8020a6:	09 c2                	or     %eax,%edx
  8020a8:	89 d8                	mov    %ebx,%eax
  8020aa:	89 14 24             	mov    %edx,(%esp)
  8020ad:	89 f2                	mov    %esi,%edx
  8020af:	d3 e2                	shl    %cl,%edx
  8020b1:	89 f9                	mov    %edi,%ecx
  8020b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8020bb:	d3 e8                	shr    %cl,%eax
  8020bd:	89 e9                	mov    %ebp,%ecx
  8020bf:	89 c6                	mov    %eax,%esi
  8020c1:	d3 e3                	shl    %cl,%ebx
  8020c3:	89 f9                	mov    %edi,%ecx
  8020c5:	89 d0                	mov    %edx,%eax
  8020c7:	d3 e8                	shr    %cl,%eax
  8020c9:	89 e9                	mov    %ebp,%ecx
  8020cb:	09 d8                	or     %ebx,%eax
  8020cd:	89 d3                	mov    %edx,%ebx
  8020cf:	89 f2                	mov    %esi,%edx
  8020d1:	f7 34 24             	divl   (%esp)
  8020d4:	89 d6                	mov    %edx,%esi
  8020d6:	d3 e3                	shl    %cl,%ebx
  8020d8:	f7 64 24 04          	mull   0x4(%esp)
  8020dc:	39 d6                	cmp    %edx,%esi
  8020de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020e2:	89 d1                	mov    %edx,%ecx
  8020e4:	89 c3                	mov    %eax,%ebx
  8020e6:	72 08                	jb     8020f0 <__umoddi3+0x110>
  8020e8:	75 11                	jne    8020fb <__umoddi3+0x11b>
  8020ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8020ee:	73 0b                	jae    8020fb <__umoddi3+0x11b>
  8020f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8020f4:	1b 14 24             	sbb    (%esp),%edx
  8020f7:	89 d1                	mov    %edx,%ecx
  8020f9:	89 c3                	mov    %eax,%ebx
  8020fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8020ff:	29 da                	sub    %ebx,%edx
  802101:	19 ce                	sbb    %ecx,%esi
  802103:	89 f9                	mov    %edi,%ecx
  802105:	89 f0                	mov    %esi,%eax
  802107:	d3 e0                	shl    %cl,%eax
  802109:	89 e9                	mov    %ebp,%ecx
  80210b:	d3 ea                	shr    %cl,%edx
  80210d:	89 e9                	mov    %ebp,%ecx
  80210f:	d3 ee                	shr    %cl,%esi
  802111:	09 d0                	or     %edx,%eax
  802113:	89 f2                	mov    %esi,%edx
  802115:	83 c4 1c             	add    $0x1c,%esp
  802118:	5b                   	pop    %ebx
  802119:	5e                   	pop    %esi
  80211a:	5f                   	pop    %edi
  80211b:	5d                   	pop    %ebp
  80211c:	c3                   	ret    
  80211d:	8d 76 00             	lea    0x0(%esi),%esi
  802120:	29 f9                	sub    %edi,%ecx
  802122:	19 d6                	sbb    %edx,%esi
  802124:	89 74 24 04          	mov    %esi,0x4(%esp)
  802128:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80212c:	e9 18 ff ff ff       	jmp    802049 <__umoddi3+0x69>
