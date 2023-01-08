
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
  80003a:	68 a0 25 80 00       	push   $0x8025a0
  80003f:	e8 64 01 00 00       	call   8001a8 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 d0 0d 00 00       	call   800e19 <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 18 26 80 00       	push   $0x802618
  800058:	e8 4b 01 00 00       	call   8001a8 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 c8 25 80 00       	push   $0x8025c8
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
  800099:	c7 04 24 f0 25 80 00 	movl   $0x8025f0,(%esp)
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
  800101:	e8 95 10 00 00       	call   80119b <close_all>
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
  80020b:	e8 f0 20 00 00       	call   802300 <__udivdi3>
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
  80024e:	e8 dd 21 00 00       	call   802430 <__umoddi3>
  800253:	83 c4 14             	add    $0x14,%esp
  800256:	0f be 80 40 26 80 00 	movsbl 0x802640(%eax),%eax
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
  800352:	ff 24 85 80 27 80 00 	jmp    *0x802780(,%eax,4)
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
  800416:	8b 14 85 e0 28 80 00 	mov    0x8028e0(,%eax,4),%edx
  80041d:	85 d2                	test   %edx,%edx
  80041f:	75 18                	jne    800439 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800421:	50                   	push   %eax
  800422:	68 58 26 80 00       	push   $0x802658
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
  80043a:	68 cd 2a 80 00       	push   $0x802acd
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
  80045e:	b8 51 26 80 00       	mov    $0x802651,%eax
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
  800ad9:	68 3f 29 80 00       	push   $0x80293f
  800ade:	6a 23                	push   $0x23
  800ae0:	68 5c 29 80 00       	push   $0x80295c
  800ae5:	e8 2a 16 00 00       	call   802114 <_panic>

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
  800b5a:	68 3f 29 80 00       	push   $0x80293f
  800b5f:	6a 23                	push   $0x23
  800b61:	68 5c 29 80 00       	push   $0x80295c
  800b66:	e8 a9 15 00 00       	call   802114 <_panic>

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
  800b9c:	68 3f 29 80 00       	push   $0x80293f
  800ba1:	6a 23                	push   $0x23
  800ba3:	68 5c 29 80 00       	push   $0x80295c
  800ba8:	e8 67 15 00 00       	call   802114 <_panic>

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
  800bde:	68 3f 29 80 00       	push   $0x80293f
  800be3:	6a 23                	push   $0x23
  800be5:	68 5c 29 80 00       	push   $0x80295c
  800bea:	e8 25 15 00 00       	call   802114 <_panic>

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
  800c20:	68 3f 29 80 00       	push   $0x80293f
  800c25:	6a 23                	push   $0x23
  800c27:	68 5c 29 80 00       	push   $0x80295c
  800c2c:	e8 e3 14 00 00       	call   802114 <_panic>

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
  800c62:	68 3f 29 80 00       	push   $0x80293f
  800c67:	6a 23                	push   $0x23
  800c69:	68 5c 29 80 00       	push   $0x80295c
  800c6e:	e8 a1 14 00 00       	call   802114 <_panic>

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
  800ca4:	68 3f 29 80 00       	push   $0x80293f
  800ca9:	6a 23                	push   $0x23
  800cab:	68 5c 29 80 00       	push   $0x80295c
  800cb0:	e8 5f 14 00 00       	call   802114 <_panic>

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
  800d08:	68 3f 29 80 00       	push   $0x80293f
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 5c 29 80 00       	push   $0x80295c
  800d14:	e8 fb 13 00 00       	call   802114 <_panic>

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

00800d40 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	56                   	push   %esi
  800d44:	53                   	push   %ebx
  800d45:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d48:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800d4a:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d4e:	75 25                	jne    800d75 <pgfault+0x35>
  800d50:	89 d8                	mov    %ebx,%eax
  800d52:	c1 e8 0c             	shr    $0xc,%eax
  800d55:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d5c:	f6 c4 08             	test   $0x8,%ah
  800d5f:	75 14                	jne    800d75 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800d61:	83 ec 04             	sub    $0x4,%esp
  800d64:	68 6c 29 80 00       	push   $0x80296c
  800d69:	6a 1e                	push   $0x1e
  800d6b:	68 00 2a 80 00       	push   $0x802a00
  800d70:	e8 9f 13 00 00       	call   802114 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800d75:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800d7b:	e8 72 fd ff ff       	call   800af2 <sys_getenvid>
  800d80:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800d82:	83 ec 04             	sub    $0x4,%esp
  800d85:	6a 07                	push   $0x7
  800d87:	68 00 f0 7f 00       	push   $0x7ff000
  800d8c:	50                   	push   %eax
  800d8d:	e8 9e fd ff ff       	call   800b30 <sys_page_alloc>
	if (r < 0)
  800d92:	83 c4 10             	add    $0x10,%esp
  800d95:	85 c0                	test   %eax,%eax
  800d97:	79 12                	jns    800dab <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800d99:	50                   	push   %eax
  800d9a:	68 98 29 80 00       	push   $0x802998
  800d9f:	6a 33                	push   $0x33
  800da1:	68 00 2a 80 00       	push   $0x802a00
  800da6:	e8 69 13 00 00       	call   802114 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800dab:	83 ec 04             	sub    $0x4,%esp
  800dae:	68 00 10 00 00       	push   $0x1000
  800db3:	53                   	push   %ebx
  800db4:	68 00 f0 7f 00       	push   $0x7ff000
  800db9:	e8 69 fb ff ff       	call   800927 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800dbe:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800dc5:	53                   	push   %ebx
  800dc6:	56                   	push   %esi
  800dc7:	68 00 f0 7f 00       	push   $0x7ff000
  800dcc:	56                   	push   %esi
  800dcd:	e8 a1 fd ff ff       	call   800b73 <sys_page_map>
	if (r < 0)
  800dd2:	83 c4 20             	add    $0x20,%esp
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	79 12                	jns    800deb <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800dd9:	50                   	push   %eax
  800dda:	68 bc 29 80 00       	push   $0x8029bc
  800ddf:	6a 3b                	push   $0x3b
  800de1:	68 00 2a 80 00       	push   $0x802a00
  800de6:	e8 29 13 00 00       	call   802114 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800deb:	83 ec 08             	sub    $0x8,%esp
  800dee:	68 00 f0 7f 00       	push   $0x7ff000
  800df3:	56                   	push   %esi
  800df4:	e8 bc fd ff ff       	call   800bb5 <sys_page_unmap>
	if (r < 0)
  800df9:	83 c4 10             	add    $0x10,%esp
  800dfc:	85 c0                	test   %eax,%eax
  800dfe:	79 12                	jns    800e12 <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800e00:	50                   	push   %eax
  800e01:	68 e0 29 80 00       	push   $0x8029e0
  800e06:	6a 40                	push   $0x40
  800e08:	68 00 2a 80 00       	push   $0x802a00
  800e0d:	e8 02 13 00 00       	call   802114 <_panic>
}
  800e12:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e15:	5b                   	pop    %ebx
  800e16:	5e                   	pop    %esi
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    

00800e19 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	57                   	push   %edi
  800e1d:	56                   	push   %esi
  800e1e:	53                   	push   %ebx
  800e1f:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800e22:	68 40 0d 80 00       	push   $0x800d40
  800e27:	e8 2e 13 00 00       	call   80215a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e2c:	b8 07 00 00 00       	mov    $0x7,%eax
  800e31:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800e33:	83 c4 10             	add    $0x10,%esp
  800e36:	85 c0                	test   %eax,%eax
  800e38:	0f 88 64 01 00 00    	js     800fa2 <fork+0x189>
  800e3e:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800e43:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800e48:	85 c0                	test   %eax,%eax
  800e4a:	75 21                	jne    800e6d <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e4c:	e8 a1 fc ff ff       	call   800af2 <sys_getenvid>
  800e51:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e56:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e59:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e5e:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  800e63:	ba 00 00 00 00       	mov    $0x0,%edx
  800e68:	e9 3f 01 00 00       	jmp    800fac <fork+0x193>
  800e6d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e70:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800e72:	89 d8                	mov    %ebx,%eax
  800e74:	c1 e8 16             	shr    $0x16,%eax
  800e77:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e7e:	a8 01                	test   $0x1,%al
  800e80:	0f 84 bd 00 00 00    	je     800f43 <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800e86:	89 d8                	mov    %ebx,%eax
  800e88:	c1 e8 0c             	shr    $0xc,%eax
  800e8b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e92:	f6 c2 01             	test   $0x1,%dl
  800e95:	0f 84 a8 00 00 00    	je     800f43 <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  800e9b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ea2:	a8 04                	test   $0x4,%al
  800ea4:	0f 84 99 00 00 00    	je     800f43 <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800eaa:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800eb1:	f6 c4 04             	test   $0x4,%ah
  800eb4:	74 17                	je     800ecd <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800eb6:	83 ec 0c             	sub    $0xc,%esp
  800eb9:	68 07 0e 00 00       	push   $0xe07
  800ebe:	53                   	push   %ebx
  800ebf:	57                   	push   %edi
  800ec0:	53                   	push   %ebx
  800ec1:	6a 00                	push   $0x0
  800ec3:	e8 ab fc ff ff       	call   800b73 <sys_page_map>
  800ec8:	83 c4 20             	add    $0x20,%esp
  800ecb:	eb 76                	jmp    800f43 <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800ecd:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ed4:	a8 02                	test   $0x2,%al
  800ed6:	75 0c                	jne    800ee4 <fork+0xcb>
  800ed8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800edf:	f6 c4 08             	test   $0x8,%ah
  800ee2:	74 3f                	je     800f23 <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800ee4:	83 ec 0c             	sub    $0xc,%esp
  800ee7:	68 05 08 00 00       	push   $0x805
  800eec:	53                   	push   %ebx
  800eed:	57                   	push   %edi
  800eee:	53                   	push   %ebx
  800eef:	6a 00                	push   $0x0
  800ef1:	e8 7d fc ff ff       	call   800b73 <sys_page_map>
		if (r < 0)
  800ef6:	83 c4 20             	add    $0x20,%esp
  800ef9:	85 c0                	test   %eax,%eax
  800efb:	0f 88 a5 00 00 00    	js     800fa6 <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f01:	83 ec 0c             	sub    $0xc,%esp
  800f04:	68 05 08 00 00       	push   $0x805
  800f09:	53                   	push   %ebx
  800f0a:	6a 00                	push   $0x0
  800f0c:	53                   	push   %ebx
  800f0d:	6a 00                	push   $0x0
  800f0f:	e8 5f fc ff ff       	call   800b73 <sys_page_map>
  800f14:	83 c4 20             	add    $0x20,%esp
  800f17:	85 c0                	test   %eax,%eax
  800f19:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f1e:	0f 4f c1             	cmovg  %ecx,%eax
  800f21:	eb 1c                	jmp    800f3f <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  800f23:	83 ec 0c             	sub    $0xc,%esp
  800f26:	6a 05                	push   $0x5
  800f28:	53                   	push   %ebx
  800f29:	57                   	push   %edi
  800f2a:	53                   	push   %ebx
  800f2b:	6a 00                	push   $0x0
  800f2d:	e8 41 fc ff ff       	call   800b73 <sys_page_map>
  800f32:	83 c4 20             	add    $0x20,%esp
  800f35:	85 c0                	test   %eax,%eax
  800f37:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f3c:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	78 67                	js     800faa <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  800f43:	83 c6 01             	add    $0x1,%esi
  800f46:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f4c:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  800f52:	0f 85 1a ff ff ff    	jne    800e72 <fork+0x59>
  800f58:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  800f5b:	83 ec 04             	sub    $0x4,%esp
  800f5e:	6a 07                	push   $0x7
  800f60:	68 00 f0 bf ee       	push   $0xeebff000
  800f65:	57                   	push   %edi
  800f66:	e8 c5 fb ff ff       	call   800b30 <sys_page_alloc>
	if (r < 0)
  800f6b:	83 c4 10             	add    $0x10,%esp
		return r;
  800f6e:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  800f70:	85 c0                	test   %eax,%eax
  800f72:	78 38                	js     800fac <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800f74:	83 ec 08             	sub    $0x8,%esp
  800f77:	68 a1 21 80 00       	push   $0x8021a1
  800f7c:	57                   	push   %edi
  800f7d:	e8 f9 fc ff ff       	call   800c7b <sys_env_set_pgfault_upcall>
	if (r < 0)
  800f82:	83 c4 10             	add    $0x10,%esp
		return r;
  800f85:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  800f87:	85 c0                	test   %eax,%eax
  800f89:	78 21                	js     800fac <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  800f8b:	83 ec 08             	sub    $0x8,%esp
  800f8e:	6a 02                	push   $0x2
  800f90:	57                   	push   %edi
  800f91:	e8 61 fc ff ff       	call   800bf7 <sys_env_set_status>
	if (r < 0)
  800f96:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	0f 48 f8             	cmovs  %eax,%edi
  800f9e:	89 fa                	mov    %edi,%edx
  800fa0:	eb 0a                	jmp    800fac <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  800fa2:	89 c2                	mov    %eax,%edx
  800fa4:	eb 06                	jmp    800fac <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800fa6:	89 c2                	mov    %eax,%edx
  800fa8:	eb 02                	jmp    800fac <fork+0x193>
  800faa:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  800fac:	89 d0                	mov    %edx,%eax
  800fae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fb1:	5b                   	pop    %ebx
  800fb2:	5e                   	pop    %esi
  800fb3:	5f                   	pop    %edi
  800fb4:	5d                   	pop    %ebp
  800fb5:	c3                   	ret    

00800fb6 <sfork>:

// Challenge!
int
sfork(void)
{
  800fb6:	55                   	push   %ebp
  800fb7:	89 e5                	mov    %esp,%ebp
  800fb9:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fbc:	68 0b 2a 80 00       	push   $0x802a0b
  800fc1:	68 c9 00 00 00       	push   $0xc9
  800fc6:	68 00 2a 80 00       	push   $0x802a00
  800fcb:	e8 44 11 00 00       	call   802114 <_panic>

00800fd0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd6:	05 00 00 00 30       	add    $0x30000000,%eax
  800fdb:	c1 e8 0c             	shr    $0xc,%eax
}
  800fde:	5d                   	pop    %ebp
  800fdf:	c3                   	ret    

00800fe0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800fe3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe6:	05 00 00 00 30       	add    $0x30000000,%eax
  800feb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ff0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ff5:	5d                   	pop    %ebp
  800ff6:	c3                   	ret    

00800ff7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ffd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801002:	89 c2                	mov    %eax,%edx
  801004:	c1 ea 16             	shr    $0x16,%edx
  801007:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80100e:	f6 c2 01             	test   $0x1,%dl
  801011:	74 11                	je     801024 <fd_alloc+0x2d>
  801013:	89 c2                	mov    %eax,%edx
  801015:	c1 ea 0c             	shr    $0xc,%edx
  801018:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80101f:	f6 c2 01             	test   $0x1,%dl
  801022:	75 09                	jne    80102d <fd_alloc+0x36>
			*fd_store = fd;
  801024:	89 01                	mov    %eax,(%ecx)
			return 0;
  801026:	b8 00 00 00 00       	mov    $0x0,%eax
  80102b:	eb 17                	jmp    801044 <fd_alloc+0x4d>
  80102d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801032:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801037:	75 c9                	jne    801002 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801039:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80103f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801044:	5d                   	pop    %ebp
  801045:	c3                   	ret    

00801046 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801046:	55                   	push   %ebp
  801047:	89 e5                	mov    %esp,%ebp
  801049:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80104c:	83 f8 1f             	cmp    $0x1f,%eax
  80104f:	77 36                	ja     801087 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801051:	c1 e0 0c             	shl    $0xc,%eax
  801054:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801059:	89 c2                	mov    %eax,%edx
  80105b:	c1 ea 16             	shr    $0x16,%edx
  80105e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801065:	f6 c2 01             	test   $0x1,%dl
  801068:	74 24                	je     80108e <fd_lookup+0x48>
  80106a:	89 c2                	mov    %eax,%edx
  80106c:	c1 ea 0c             	shr    $0xc,%edx
  80106f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801076:	f6 c2 01             	test   $0x1,%dl
  801079:	74 1a                	je     801095 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80107b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80107e:	89 02                	mov    %eax,(%edx)
	return 0;
  801080:	b8 00 00 00 00       	mov    $0x0,%eax
  801085:	eb 13                	jmp    80109a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801087:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80108c:	eb 0c                	jmp    80109a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80108e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801093:	eb 05                	jmp    80109a <fd_lookup+0x54>
  801095:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80109a:	5d                   	pop    %ebp
  80109b:	c3                   	ret    

0080109c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	83 ec 08             	sub    $0x8,%esp
  8010a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010a5:	ba a0 2a 80 00       	mov    $0x802aa0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8010aa:	eb 13                	jmp    8010bf <dev_lookup+0x23>
  8010ac:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8010af:	39 08                	cmp    %ecx,(%eax)
  8010b1:	75 0c                	jne    8010bf <dev_lookup+0x23>
			*dev = devtab[i];
  8010b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010bd:	eb 2e                	jmp    8010ed <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8010bf:	8b 02                	mov    (%edx),%eax
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	75 e7                	jne    8010ac <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8010c5:	a1 08 40 80 00       	mov    0x804008,%eax
  8010ca:	8b 40 48             	mov    0x48(%eax),%eax
  8010cd:	83 ec 04             	sub    $0x4,%esp
  8010d0:	51                   	push   %ecx
  8010d1:	50                   	push   %eax
  8010d2:	68 24 2a 80 00       	push   $0x802a24
  8010d7:	e8 cc f0 ff ff       	call   8001a8 <cprintf>
	*dev = 0;
  8010dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010df:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8010e5:	83 c4 10             	add    $0x10,%esp
  8010e8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010ed:	c9                   	leave  
  8010ee:	c3                   	ret    

008010ef <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8010ef:	55                   	push   %ebp
  8010f0:	89 e5                	mov    %esp,%ebp
  8010f2:	56                   	push   %esi
  8010f3:	53                   	push   %ebx
  8010f4:	83 ec 10             	sub    $0x10,%esp
  8010f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8010fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801100:	50                   	push   %eax
  801101:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801107:	c1 e8 0c             	shr    $0xc,%eax
  80110a:	50                   	push   %eax
  80110b:	e8 36 ff ff ff       	call   801046 <fd_lookup>
  801110:	83 c4 08             	add    $0x8,%esp
  801113:	85 c0                	test   %eax,%eax
  801115:	78 05                	js     80111c <fd_close+0x2d>
	    || fd != fd2)
  801117:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80111a:	74 0c                	je     801128 <fd_close+0x39>
		return (must_exist ? r : 0);
  80111c:	84 db                	test   %bl,%bl
  80111e:	ba 00 00 00 00       	mov    $0x0,%edx
  801123:	0f 44 c2             	cmove  %edx,%eax
  801126:	eb 41                	jmp    801169 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801128:	83 ec 08             	sub    $0x8,%esp
  80112b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80112e:	50                   	push   %eax
  80112f:	ff 36                	pushl  (%esi)
  801131:	e8 66 ff ff ff       	call   80109c <dev_lookup>
  801136:	89 c3                	mov    %eax,%ebx
  801138:	83 c4 10             	add    $0x10,%esp
  80113b:	85 c0                	test   %eax,%eax
  80113d:	78 1a                	js     801159 <fd_close+0x6a>
		if (dev->dev_close)
  80113f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801142:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801145:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80114a:	85 c0                	test   %eax,%eax
  80114c:	74 0b                	je     801159 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80114e:	83 ec 0c             	sub    $0xc,%esp
  801151:	56                   	push   %esi
  801152:	ff d0                	call   *%eax
  801154:	89 c3                	mov    %eax,%ebx
  801156:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801159:	83 ec 08             	sub    $0x8,%esp
  80115c:	56                   	push   %esi
  80115d:	6a 00                	push   $0x0
  80115f:	e8 51 fa ff ff       	call   800bb5 <sys_page_unmap>
	return r;
  801164:	83 c4 10             	add    $0x10,%esp
  801167:	89 d8                	mov    %ebx,%eax
}
  801169:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80116c:	5b                   	pop    %ebx
  80116d:	5e                   	pop    %esi
  80116e:	5d                   	pop    %ebp
  80116f:	c3                   	ret    

00801170 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801176:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801179:	50                   	push   %eax
  80117a:	ff 75 08             	pushl  0x8(%ebp)
  80117d:	e8 c4 fe ff ff       	call   801046 <fd_lookup>
  801182:	83 c4 08             	add    $0x8,%esp
  801185:	85 c0                	test   %eax,%eax
  801187:	78 10                	js     801199 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801189:	83 ec 08             	sub    $0x8,%esp
  80118c:	6a 01                	push   $0x1
  80118e:	ff 75 f4             	pushl  -0xc(%ebp)
  801191:	e8 59 ff ff ff       	call   8010ef <fd_close>
  801196:	83 c4 10             	add    $0x10,%esp
}
  801199:	c9                   	leave  
  80119a:	c3                   	ret    

0080119b <close_all>:

void
close_all(void)
{
  80119b:	55                   	push   %ebp
  80119c:	89 e5                	mov    %esp,%ebp
  80119e:	53                   	push   %ebx
  80119f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011a2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011a7:	83 ec 0c             	sub    $0xc,%esp
  8011aa:	53                   	push   %ebx
  8011ab:	e8 c0 ff ff ff       	call   801170 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8011b0:	83 c3 01             	add    $0x1,%ebx
  8011b3:	83 c4 10             	add    $0x10,%esp
  8011b6:	83 fb 20             	cmp    $0x20,%ebx
  8011b9:	75 ec                	jne    8011a7 <close_all+0xc>
		close(i);
}
  8011bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011be:	c9                   	leave  
  8011bf:	c3                   	ret    

008011c0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
  8011c3:	57                   	push   %edi
  8011c4:	56                   	push   %esi
  8011c5:	53                   	push   %ebx
  8011c6:	83 ec 2c             	sub    $0x2c,%esp
  8011c9:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011cc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011cf:	50                   	push   %eax
  8011d0:	ff 75 08             	pushl  0x8(%ebp)
  8011d3:	e8 6e fe ff ff       	call   801046 <fd_lookup>
  8011d8:	83 c4 08             	add    $0x8,%esp
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	0f 88 c1 00 00 00    	js     8012a4 <dup+0xe4>
		return r;
	close(newfdnum);
  8011e3:	83 ec 0c             	sub    $0xc,%esp
  8011e6:	56                   	push   %esi
  8011e7:	e8 84 ff ff ff       	call   801170 <close>

	newfd = INDEX2FD(newfdnum);
  8011ec:	89 f3                	mov    %esi,%ebx
  8011ee:	c1 e3 0c             	shl    $0xc,%ebx
  8011f1:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8011f7:	83 c4 04             	add    $0x4,%esp
  8011fa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011fd:	e8 de fd ff ff       	call   800fe0 <fd2data>
  801202:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801204:	89 1c 24             	mov    %ebx,(%esp)
  801207:	e8 d4 fd ff ff       	call   800fe0 <fd2data>
  80120c:	83 c4 10             	add    $0x10,%esp
  80120f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801212:	89 f8                	mov    %edi,%eax
  801214:	c1 e8 16             	shr    $0x16,%eax
  801217:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80121e:	a8 01                	test   $0x1,%al
  801220:	74 37                	je     801259 <dup+0x99>
  801222:	89 f8                	mov    %edi,%eax
  801224:	c1 e8 0c             	shr    $0xc,%eax
  801227:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80122e:	f6 c2 01             	test   $0x1,%dl
  801231:	74 26                	je     801259 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801233:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80123a:	83 ec 0c             	sub    $0xc,%esp
  80123d:	25 07 0e 00 00       	and    $0xe07,%eax
  801242:	50                   	push   %eax
  801243:	ff 75 d4             	pushl  -0x2c(%ebp)
  801246:	6a 00                	push   $0x0
  801248:	57                   	push   %edi
  801249:	6a 00                	push   $0x0
  80124b:	e8 23 f9 ff ff       	call   800b73 <sys_page_map>
  801250:	89 c7                	mov    %eax,%edi
  801252:	83 c4 20             	add    $0x20,%esp
  801255:	85 c0                	test   %eax,%eax
  801257:	78 2e                	js     801287 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801259:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80125c:	89 d0                	mov    %edx,%eax
  80125e:	c1 e8 0c             	shr    $0xc,%eax
  801261:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801268:	83 ec 0c             	sub    $0xc,%esp
  80126b:	25 07 0e 00 00       	and    $0xe07,%eax
  801270:	50                   	push   %eax
  801271:	53                   	push   %ebx
  801272:	6a 00                	push   $0x0
  801274:	52                   	push   %edx
  801275:	6a 00                	push   $0x0
  801277:	e8 f7 f8 ff ff       	call   800b73 <sys_page_map>
  80127c:	89 c7                	mov    %eax,%edi
  80127e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801281:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801283:	85 ff                	test   %edi,%edi
  801285:	79 1d                	jns    8012a4 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801287:	83 ec 08             	sub    $0x8,%esp
  80128a:	53                   	push   %ebx
  80128b:	6a 00                	push   $0x0
  80128d:	e8 23 f9 ff ff       	call   800bb5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801292:	83 c4 08             	add    $0x8,%esp
  801295:	ff 75 d4             	pushl  -0x2c(%ebp)
  801298:	6a 00                	push   $0x0
  80129a:	e8 16 f9 ff ff       	call   800bb5 <sys_page_unmap>
	return r;
  80129f:	83 c4 10             	add    $0x10,%esp
  8012a2:	89 f8                	mov    %edi,%eax
}
  8012a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012a7:	5b                   	pop    %ebx
  8012a8:	5e                   	pop    %esi
  8012a9:	5f                   	pop    %edi
  8012aa:	5d                   	pop    %ebp
  8012ab:	c3                   	ret    

008012ac <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012ac:	55                   	push   %ebp
  8012ad:	89 e5                	mov    %esp,%ebp
  8012af:	53                   	push   %ebx
  8012b0:	83 ec 14             	sub    $0x14,%esp
  8012b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b9:	50                   	push   %eax
  8012ba:	53                   	push   %ebx
  8012bb:	e8 86 fd ff ff       	call   801046 <fd_lookup>
  8012c0:	83 c4 08             	add    $0x8,%esp
  8012c3:	89 c2                	mov    %eax,%edx
  8012c5:	85 c0                	test   %eax,%eax
  8012c7:	78 6d                	js     801336 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c9:	83 ec 08             	sub    $0x8,%esp
  8012cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012cf:	50                   	push   %eax
  8012d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d3:	ff 30                	pushl  (%eax)
  8012d5:	e8 c2 fd ff ff       	call   80109c <dev_lookup>
  8012da:	83 c4 10             	add    $0x10,%esp
  8012dd:	85 c0                	test   %eax,%eax
  8012df:	78 4c                	js     80132d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8012e1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012e4:	8b 42 08             	mov    0x8(%edx),%eax
  8012e7:	83 e0 03             	and    $0x3,%eax
  8012ea:	83 f8 01             	cmp    $0x1,%eax
  8012ed:	75 21                	jne    801310 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8012ef:	a1 08 40 80 00       	mov    0x804008,%eax
  8012f4:	8b 40 48             	mov    0x48(%eax),%eax
  8012f7:	83 ec 04             	sub    $0x4,%esp
  8012fa:	53                   	push   %ebx
  8012fb:	50                   	push   %eax
  8012fc:	68 65 2a 80 00       	push   $0x802a65
  801301:	e8 a2 ee ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  801306:	83 c4 10             	add    $0x10,%esp
  801309:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80130e:	eb 26                	jmp    801336 <read+0x8a>
	}
	if (!dev->dev_read)
  801310:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801313:	8b 40 08             	mov    0x8(%eax),%eax
  801316:	85 c0                	test   %eax,%eax
  801318:	74 17                	je     801331 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80131a:	83 ec 04             	sub    $0x4,%esp
  80131d:	ff 75 10             	pushl  0x10(%ebp)
  801320:	ff 75 0c             	pushl  0xc(%ebp)
  801323:	52                   	push   %edx
  801324:	ff d0                	call   *%eax
  801326:	89 c2                	mov    %eax,%edx
  801328:	83 c4 10             	add    $0x10,%esp
  80132b:	eb 09                	jmp    801336 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80132d:	89 c2                	mov    %eax,%edx
  80132f:	eb 05                	jmp    801336 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801331:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801336:	89 d0                	mov    %edx,%eax
  801338:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80133b:	c9                   	leave  
  80133c:	c3                   	ret    

0080133d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80133d:	55                   	push   %ebp
  80133e:	89 e5                	mov    %esp,%ebp
  801340:	57                   	push   %edi
  801341:	56                   	push   %esi
  801342:	53                   	push   %ebx
  801343:	83 ec 0c             	sub    $0xc,%esp
  801346:	8b 7d 08             	mov    0x8(%ebp),%edi
  801349:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80134c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801351:	eb 21                	jmp    801374 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801353:	83 ec 04             	sub    $0x4,%esp
  801356:	89 f0                	mov    %esi,%eax
  801358:	29 d8                	sub    %ebx,%eax
  80135a:	50                   	push   %eax
  80135b:	89 d8                	mov    %ebx,%eax
  80135d:	03 45 0c             	add    0xc(%ebp),%eax
  801360:	50                   	push   %eax
  801361:	57                   	push   %edi
  801362:	e8 45 ff ff ff       	call   8012ac <read>
		if (m < 0)
  801367:	83 c4 10             	add    $0x10,%esp
  80136a:	85 c0                	test   %eax,%eax
  80136c:	78 10                	js     80137e <readn+0x41>
			return m;
		if (m == 0)
  80136e:	85 c0                	test   %eax,%eax
  801370:	74 0a                	je     80137c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801372:	01 c3                	add    %eax,%ebx
  801374:	39 f3                	cmp    %esi,%ebx
  801376:	72 db                	jb     801353 <readn+0x16>
  801378:	89 d8                	mov    %ebx,%eax
  80137a:	eb 02                	jmp    80137e <readn+0x41>
  80137c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80137e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801381:	5b                   	pop    %ebx
  801382:	5e                   	pop    %esi
  801383:	5f                   	pop    %edi
  801384:	5d                   	pop    %ebp
  801385:	c3                   	ret    

00801386 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
  801389:	53                   	push   %ebx
  80138a:	83 ec 14             	sub    $0x14,%esp
  80138d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801390:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801393:	50                   	push   %eax
  801394:	53                   	push   %ebx
  801395:	e8 ac fc ff ff       	call   801046 <fd_lookup>
  80139a:	83 c4 08             	add    $0x8,%esp
  80139d:	89 c2                	mov    %eax,%edx
  80139f:	85 c0                	test   %eax,%eax
  8013a1:	78 68                	js     80140b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a3:	83 ec 08             	sub    $0x8,%esp
  8013a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a9:	50                   	push   %eax
  8013aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ad:	ff 30                	pushl  (%eax)
  8013af:	e8 e8 fc ff ff       	call   80109c <dev_lookup>
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	85 c0                	test   %eax,%eax
  8013b9:	78 47                	js     801402 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013be:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013c2:	75 21                	jne    8013e5 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013c4:	a1 08 40 80 00       	mov    0x804008,%eax
  8013c9:	8b 40 48             	mov    0x48(%eax),%eax
  8013cc:	83 ec 04             	sub    $0x4,%esp
  8013cf:	53                   	push   %ebx
  8013d0:	50                   	push   %eax
  8013d1:	68 81 2a 80 00       	push   $0x802a81
  8013d6:	e8 cd ed ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  8013db:	83 c4 10             	add    $0x10,%esp
  8013de:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013e3:	eb 26                	jmp    80140b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8013e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013e8:	8b 52 0c             	mov    0xc(%edx),%edx
  8013eb:	85 d2                	test   %edx,%edx
  8013ed:	74 17                	je     801406 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8013ef:	83 ec 04             	sub    $0x4,%esp
  8013f2:	ff 75 10             	pushl  0x10(%ebp)
  8013f5:	ff 75 0c             	pushl  0xc(%ebp)
  8013f8:	50                   	push   %eax
  8013f9:	ff d2                	call   *%edx
  8013fb:	89 c2                	mov    %eax,%edx
  8013fd:	83 c4 10             	add    $0x10,%esp
  801400:	eb 09                	jmp    80140b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801402:	89 c2                	mov    %eax,%edx
  801404:	eb 05                	jmp    80140b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801406:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80140b:	89 d0                	mov    %edx,%eax
  80140d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801410:	c9                   	leave  
  801411:	c3                   	ret    

00801412 <seek>:

int
seek(int fdnum, off_t offset)
{
  801412:	55                   	push   %ebp
  801413:	89 e5                	mov    %esp,%ebp
  801415:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801418:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80141b:	50                   	push   %eax
  80141c:	ff 75 08             	pushl  0x8(%ebp)
  80141f:	e8 22 fc ff ff       	call   801046 <fd_lookup>
  801424:	83 c4 08             	add    $0x8,%esp
  801427:	85 c0                	test   %eax,%eax
  801429:	78 0e                	js     801439 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80142b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80142e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801431:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801434:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801439:	c9                   	leave  
  80143a:	c3                   	ret    

0080143b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80143b:	55                   	push   %ebp
  80143c:	89 e5                	mov    %esp,%ebp
  80143e:	53                   	push   %ebx
  80143f:	83 ec 14             	sub    $0x14,%esp
  801442:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801445:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801448:	50                   	push   %eax
  801449:	53                   	push   %ebx
  80144a:	e8 f7 fb ff ff       	call   801046 <fd_lookup>
  80144f:	83 c4 08             	add    $0x8,%esp
  801452:	89 c2                	mov    %eax,%edx
  801454:	85 c0                	test   %eax,%eax
  801456:	78 65                	js     8014bd <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801458:	83 ec 08             	sub    $0x8,%esp
  80145b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80145e:	50                   	push   %eax
  80145f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801462:	ff 30                	pushl  (%eax)
  801464:	e8 33 fc ff ff       	call   80109c <dev_lookup>
  801469:	83 c4 10             	add    $0x10,%esp
  80146c:	85 c0                	test   %eax,%eax
  80146e:	78 44                	js     8014b4 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801470:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801473:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801477:	75 21                	jne    80149a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801479:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80147e:	8b 40 48             	mov    0x48(%eax),%eax
  801481:	83 ec 04             	sub    $0x4,%esp
  801484:	53                   	push   %ebx
  801485:	50                   	push   %eax
  801486:	68 44 2a 80 00       	push   $0x802a44
  80148b:	e8 18 ed ff ff       	call   8001a8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801490:	83 c4 10             	add    $0x10,%esp
  801493:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801498:	eb 23                	jmp    8014bd <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80149a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80149d:	8b 52 18             	mov    0x18(%edx),%edx
  8014a0:	85 d2                	test   %edx,%edx
  8014a2:	74 14                	je     8014b8 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014a4:	83 ec 08             	sub    $0x8,%esp
  8014a7:	ff 75 0c             	pushl  0xc(%ebp)
  8014aa:	50                   	push   %eax
  8014ab:	ff d2                	call   *%edx
  8014ad:	89 c2                	mov    %eax,%edx
  8014af:	83 c4 10             	add    $0x10,%esp
  8014b2:	eb 09                	jmp    8014bd <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b4:	89 c2                	mov    %eax,%edx
  8014b6:	eb 05                	jmp    8014bd <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8014b8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8014bd:	89 d0                	mov    %edx,%eax
  8014bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c2:	c9                   	leave  
  8014c3:	c3                   	ret    

008014c4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014c4:	55                   	push   %ebp
  8014c5:	89 e5                	mov    %esp,%ebp
  8014c7:	53                   	push   %ebx
  8014c8:	83 ec 14             	sub    $0x14,%esp
  8014cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d1:	50                   	push   %eax
  8014d2:	ff 75 08             	pushl  0x8(%ebp)
  8014d5:	e8 6c fb ff ff       	call   801046 <fd_lookup>
  8014da:	83 c4 08             	add    $0x8,%esp
  8014dd:	89 c2                	mov    %eax,%edx
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	78 58                	js     80153b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e3:	83 ec 08             	sub    $0x8,%esp
  8014e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e9:	50                   	push   %eax
  8014ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ed:	ff 30                	pushl  (%eax)
  8014ef:	e8 a8 fb ff ff       	call   80109c <dev_lookup>
  8014f4:	83 c4 10             	add    $0x10,%esp
  8014f7:	85 c0                	test   %eax,%eax
  8014f9:	78 37                	js     801532 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8014fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014fe:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801502:	74 32                	je     801536 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801504:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801507:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80150e:	00 00 00 
	stat->st_isdir = 0;
  801511:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801518:	00 00 00 
	stat->st_dev = dev;
  80151b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801521:	83 ec 08             	sub    $0x8,%esp
  801524:	53                   	push   %ebx
  801525:	ff 75 f0             	pushl  -0x10(%ebp)
  801528:	ff 50 14             	call   *0x14(%eax)
  80152b:	89 c2                	mov    %eax,%edx
  80152d:	83 c4 10             	add    $0x10,%esp
  801530:	eb 09                	jmp    80153b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801532:	89 c2                	mov    %eax,%edx
  801534:	eb 05                	jmp    80153b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801536:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80153b:	89 d0                	mov    %edx,%eax
  80153d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801540:	c9                   	leave  
  801541:	c3                   	ret    

00801542 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801542:	55                   	push   %ebp
  801543:	89 e5                	mov    %esp,%ebp
  801545:	56                   	push   %esi
  801546:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801547:	83 ec 08             	sub    $0x8,%esp
  80154a:	6a 00                	push   $0x0
  80154c:	ff 75 08             	pushl  0x8(%ebp)
  80154f:	e8 d6 01 00 00       	call   80172a <open>
  801554:	89 c3                	mov    %eax,%ebx
  801556:	83 c4 10             	add    $0x10,%esp
  801559:	85 c0                	test   %eax,%eax
  80155b:	78 1b                	js     801578 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80155d:	83 ec 08             	sub    $0x8,%esp
  801560:	ff 75 0c             	pushl  0xc(%ebp)
  801563:	50                   	push   %eax
  801564:	e8 5b ff ff ff       	call   8014c4 <fstat>
  801569:	89 c6                	mov    %eax,%esi
	close(fd);
  80156b:	89 1c 24             	mov    %ebx,(%esp)
  80156e:	e8 fd fb ff ff       	call   801170 <close>
	return r;
  801573:	83 c4 10             	add    $0x10,%esp
  801576:	89 f0                	mov    %esi,%eax
}
  801578:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80157b:	5b                   	pop    %ebx
  80157c:	5e                   	pop    %esi
  80157d:	5d                   	pop    %ebp
  80157e:	c3                   	ret    

0080157f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80157f:	55                   	push   %ebp
  801580:	89 e5                	mov    %esp,%ebp
  801582:	56                   	push   %esi
  801583:	53                   	push   %ebx
  801584:	89 c6                	mov    %eax,%esi
  801586:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801588:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80158f:	75 12                	jne    8015a3 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801591:	83 ec 0c             	sub    $0xc,%esp
  801594:	6a 01                	push   $0x1
  801596:	e8 e5 0c 00 00       	call   802280 <ipc_find_env>
  80159b:	a3 00 40 80 00       	mov    %eax,0x804000
  8015a0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015a3:	6a 07                	push   $0x7
  8015a5:	68 00 50 80 00       	push   $0x805000
  8015aa:	56                   	push   %esi
  8015ab:	ff 35 00 40 80 00    	pushl  0x804000
  8015b1:	e8 76 0c 00 00       	call   80222c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8015b6:	83 c4 0c             	add    $0xc,%esp
  8015b9:	6a 00                	push   $0x0
  8015bb:	53                   	push   %ebx
  8015bc:	6a 00                	push   $0x0
  8015be:	e8 02 0c 00 00       	call   8021c5 <ipc_recv>
}
  8015c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c6:	5b                   	pop    %ebx
  8015c7:	5e                   	pop    %esi
  8015c8:	5d                   	pop    %ebp
  8015c9:	c3                   	ret    

008015ca <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8015ca:	55                   	push   %ebp
  8015cb:	89 e5                	mov    %esp,%ebp
  8015cd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8015d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d3:	8b 40 0c             	mov    0xc(%eax),%eax
  8015d6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8015db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015de:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8015e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e8:	b8 02 00 00 00       	mov    $0x2,%eax
  8015ed:	e8 8d ff ff ff       	call   80157f <fsipc>
}
  8015f2:	c9                   	leave  
  8015f3:	c3                   	ret    

008015f4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8015f4:	55                   	push   %ebp
  8015f5:	89 e5                	mov    %esp,%ebp
  8015f7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801600:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801605:	ba 00 00 00 00       	mov    $0x0,%edx
  80160a:	b8 06 00 00 00       	mov    $0x6,%eax
  80160f:	e8 6b ff ff ff       	call   80157f <fsipc>
}
  801614:	c9                   	leave  
  801615:	c3                   	ret    

00801616 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
  801619:	53                   	push   %ebx
  80161a:	83 ec 04             	sub    $0x4,%esp
  80161d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801620:	8b 45 08             	mov    0x8(%ebp),%eax
  801623:	8b 40 0c             	mov    0xc(%eax),%eax
  801626:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80162b:	ba 00 00 00 00       	mov    $0x0,%edx
  801630:	b8 05 00 00 00       	mov    $0x5,%eax
  801635:	e8 45 ff ff ff       	call   80157f <fsipc>
  80163a:	85 c0                	test   %eax,%eax
  80163c:	78 2c                	js     80166a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80163e:	83 ec 08             	sub    $0x8,%esp
  801641:	68 00 50 80 00       	push   $0x805000
  801646:	53                   	push   %ebx
  801647:	e8 e1 f0 ff ff       	call   80072d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80164c:	a1 80 50 80 00       	mov    0x805080,%eax
  801651:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801657:	a1 84 50 80 00       	mov    0x805084,%eax
  80165c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801662:	83 c4 10             	add    $0x10,%esp
  801665:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80166a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166d:	c9                   	leave  
  80166e:	c3                   	ret    

0080166f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80166f:	55                   	push   %ebp
  801670:	89 e5                	mov    %esp,%ebp
  801672:	83 ec 0c             	sub    $0xc,%esp
  801675:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801678:	8b 55 08             	mov    0x8(%ebp),%edx
  80167b:	8b 52 0c             	mov    0xc(%edx),%edx
  80167e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801684:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801689:	50                   	push   %eax
  80168a:	ff 75 0c             	pushl  0xc(%ebp)
  80168d:	68 08 50 80 00       	push   $0x805008
  801692:	e8 28 f2 ff ff       	call   8008bf <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801697:	ba 00 00 00 00       	mov    $0x0,%edx
  80169c:	b8 04 00 00 00       	mov    $0x4,%eax
  8016a1:	e8 d9 fe ff ff       	call   80157f <fsipc>

}
  8016a6:	c9                   	leave  
  8016a7:	c3                   	ret    

008016a8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016a8:	55                   	push   %ebp
  8016a9:	89 e5                	mov    %esp,%ebp
  8016ab:	56                   	push   %esi
  8016ac:	53                   	push   %ebx
  8016ad:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b3:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016bb:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c6:	b8 03 00 00 00       	mov    $0x3,%eax
  8016cb:	e8 af fe ff ff       	call   80157f <fsipc>
  8016d0:	89 c3                	mov    %eax,%ebx
  8016d2:	85 c0                	test   %eax,%eax
  8016d4:	78 4b                	js     801721 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8016d6:	39 c6                	cmp    %eax,%esi
  8016d8:	73 16                	jae    8016f0 <devfile_read+0x48>
  8016da:	68 b4 2a 80 00       	push   $0x802ab4
  8016df:	68 bb 2a 80 00       	push   $0x802abb
  8016e4:	6a 7c                	push   $0x7c
  8016e6:	68 d0 2a 80 00       	push   $0x802ad0
  8016eb:	e8 24 0a 00 00       	call   802114 <_panic>
	assert(r <= PGSIZE);
  8016f0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016f5:	7e 16                	jle    80170d <devfile_read+0x65>
  8016f7:	68 db 2a 80 00       	push   $0x802adb
  8016fc:	68 bb 2a 80 00       	push   $0x802abb
  801701:	6a 7d                	push   $0x7d
  801703:	68 d0 2a 80 00       	push   $0x802ad0
  801708:	e8 07 0a 00 00       	call   802114 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80170d:	83 ec 04             	sub    $0x4,%esp
  801710:	50                   	push   %eax
  801711:	68 00 50 80 00       	push   $0x805000
  801716:	ff 75 0c             	pushl  0xc(%ebp)
  801719:	e8 a1 f1 ff ff       	call   8008bf <memmove>
	return r;
  80171e:	83 c4 10             	add    $0x10,%esp
}
  801721:	89 d8                	mov    %ebx,%eax
  801723:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801726:	5b                   	pop    %ebx
  801727:	5e                   	pop    %esi
  801728:	5d                   	pop    %ebp
  801729:	c3                   	ret    

0080172a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80172a:	55                   	push   %ebp
  80172b:	89 e5                	mov    %esp,%ebp
  80172d:	53                   	push   %ebx
  80172e:	83 ec 20             	sub    $0x20,%esp
  801731:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801734:	53                   	push   %ebx
  801735:	e8 ba ef ff ff       	call   8006f4 <strlen>
  80173a:	83 c4 10             	add    $0x10,%esp
  80173d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801742:	7f 67                	jg     8017ab <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801744:	83 ec 0c             	sub    $0xc,%esp
  801747:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80174a:	50                   	push   %eax
  80174b:	e8 a7 f8 ff ff       	call   800ff7 <fd_alloc>
  801750:	83 c4 10             	add    $0x10,%esp
		return r;
  801753:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801755:	85 c0                	test   %eax,%eax
  801757:	78 57                	js     8017b0 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801759:	83 ec 08             	sub    $0x8,%esp
  80175c:	53                   	push   %ebx
  80175d:	68 00 50 80 00       	push   $0x805000
  801762:	e8 c6 ef ff ff       	call   80072d <strcpy>
	fsipcbuf.open.req_omode = mode;
  801767:	8b 45 0c             	mov    0xc(%ebp),%eax
  80176a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80176f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801772:	b8 01 00 00 00       	mov    $0x1,%eax
  801777:	e8 03 fe ff ff       	call   80157f <fsipc>
  80177c:	89 c3                	mov    %eax,%ebx
  80177e:	83 c4 10             	add    $0x10,%esp
  801781:	85 c0                	test   %eax,%eax
  801783:	79 14                	jns    801799 <open+0x6f>
		fd_close(fd, 0);
  801785:	83 ec 08             	sub    $0x8,%esp
  801788:	6a 00                	push   $0x0
  80178a:	ff 75 f4             	pushl  -0xc(%ebp)
  80178d:	e8 5d f9 ff ff       	call   8010ef <fd_close>
		return r;
  801792:	83 c4 10             	add    $0x10,%esp
  801795:	89 da                	mov    %ebx,%edx
  801797:	eb 17                	jmp    8017b0 <open+0x86>
	}

	return fd2num(fd);
  801799:	83 ec 0c             	sub    $0xc,%esp
  80179c:	ff 75 f4             	pushl  -0xc(%ebp)
  80179f:	e8 2c f8 ff ff       	call   800fd0 <fd2num>
  8017a4:	89 c2                	mov    %eax,%edx
  8017a6:	83 c4 10             	add    $0x10,%esp
  8017a9:	eb 05                	jmp    8017b0 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017ab:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8017b0:	89 d0                	mov    %edx,%eax
  8017b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b5:	c9                   	leave  
  8017b6:	c3                   	ret    

008017b7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c2:	b8 08 00 00 00       	mov    $0x8,%eax
  8017c7:	e8 b3 fd ff ff       	call   80157f <fsipc>
}
  8017cc:	c9                   	leave  
  8017cd:	c3                   	ret    

008017ce <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	56                   	push   %esi
  8017d2:	53                   	push   %ebx
  8017d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8017d6:	83 ec 0c             	sub    $0xc,%esp
  8017d9:	ff 75 08             	pushl  0x8(%ebp)
  8017dc:	e8 ff f7 ff ff       	call   800fe0 <fd2data>
  8017e1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8017e3:	83 c4 08             	add    $0x8,%esp
  8017e6:	68 e7 2a 80 00       	push   $0x802ae7
  8017eb:	53                   	push   %ebx
  8017ec:	e8 3c ef ff ff       	call   80072d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8017f1:	8b 46 04             	mov    0x4(%esi),%eax
  8017f4:	2b 06                	sub    (%esi),%eax
  8017f6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8017fc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801803:	00 00 00 
	stat->st_dev = &devpipe;
  801806:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80180d:	30 80 00 
	return 0;
}
  801810:	b8 00 00 00 00       	mov    $0x0,%eax
  801815:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801818:	5b                   	pop    %ebx
  801819:	5e                   	pop    %esi
  80181a:	5d                   	pop    %ebp
  80181b:	c3                   	ret    

0080181c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	53                   	push   %ebx
  801820:	83 ec 0c             	sub    $0xc,%esp
  801823:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801826:	53                   	push   %ebx
  801827:	6a 00                	push   $0x0
  801829:	e8 87 f3 ff ff       	call   800bb5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80182e:	89 1c 24             	mov    %ebx,(%esp)
  801831:	e8 aa f7 ff ff       	call   800fe0 <fd2data>
  801836:	83 c4 08             	add    $0x8,%esp
  801839:	50                   	push   %eax
  80183a:	6a 00                	push   $0x0
  80183c:	e8 74 f3 ff ff       	call   800bb5 <sys_page_unmap>
}
  801841:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801844:	c9                   	leave  
  801845:	c3                   	ret    

00801846 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
  801849:	57                   	push   %edi
  80184a:	56                   	push   %esi
  80184b:	53                   	push   %ebx
  80184c:	83 ec 1c             	sub    $0x1c,%esp
  80184f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801852:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801854:	a1 08 40 80 00       	mov    0x804008,%eax
  801859:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80185c:	83 ec 0c             	sub    $0xc,%esp
  80185f:	ff 75 e0             	pushl  -0x20(%ebp)
  801862:	e8 52 0a 00 00       	call   8022b9 <pageref>
  801867:	89 c3                	mov    %eax,%ebx
  801869:	89 3c 24             	mov    %edi,(%esp)
  80186c:	e8 48 0a 00 00       	call   8022b9 <pageref>
  801871:	83 c4 10             	add    $0x10,%esp
  801874:	39 c3                	cmp    %eax,%ebx
  801876:	0f 94 c1             	sete   %cl
  801879:	0f b6 c9             	movzbl %cl,%ecx
  80187c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80187f:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801885:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801888:	39 ce                	cmp    %ecx,%esi
  80188a:	74 1b                	je     8018a7 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80188c:	39 c3                	cmp    %eax,%ebx
  80188e:	75 c4                	jne    801854 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801890:	8b 42 58             	mov    0x58(%edx),%eax
  801893:	ff 75 e4             	pushl  -0x1c(%ebp)
  801896:	50                   	push   %eax
  801897:	56                   	push   %esi
  801898:	68 ee 2a 80 00       	push   $0x802aee
  80189d:	e8 06 e9 ff ff       	call   8001a8 <cprintf>
  8018a2:	83 c4 10             	add    $0x10,%esp
  8018a5:	eb ad                	jmp    801854 <_pipeisclosed+0xe>
	}
}
  8018a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018ad:	5b                   	pop    %ebx
  8018ae:	5e                   	pop    %esi
  8018af:	5f                   	pop    %edi
  8018b0:	5d                   	pop    %ebp
  8018b1:	c3                   	ret    

008018b2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018b2:	55                   	push   %ebp
  8018b3:	89 e5                	mov    %esp,%ebp
  8018b5:	57                   	push   %edi
  8018b6:	56                   	push   %esi
  8018b7:	53                   	push   %ebx
  8018b8:	83 ec 28             	sub    $0x28,%esp
  8018bb:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8018be:	56                   	push   %esi
  8018bf:	e8 1c f7 ff ff       	call   800fe0 <fd2data>
  8018c4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018c6:	83 c4 10             	add    $0x10,%esp
  8018c9:	bf 00 00 00 00       	mov    $0x0,%edi
  8018ce:	eb 4b                	jmp    80191b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8018d0:	89 da                	mov    %ebx,%edx
  8018d2:	89 f0                	mov    %esi,%eax
  8018d4:	e8 6d ff ff ff       	call   801846 <_pipeisclosed>
  8018d9:	85 c0                	test   %eax,%eax
  8018db:	75 48                	jne    801925 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8018dd:	e8 2f f2 ff ff       	call   800b11 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8018e2:	8b 43 04             	mov    0x4(%ebx),%eax
  8018e5:	8b 0b                	mov    (%ebx),%ecx
  8018e7:	8d 51 20             	lea    0x20(%ecx),%edx
  8018ea:	39 d0                	cmp    %edx,%eax
  8018ec:	73 e2                	jae    8018d0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8018ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018f1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8018f5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8018f8:	89 c2                	mov    %eax,%edx
  8018fa:	c1 fa 1f             	sar    $0x1f,%edx
  8018fd:	89 d1                	mov    %edx,%ecx
  8018ff:	c1 e9 1b             	shr    $0x1b,%ecx
  801902:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801905:	83 e2 1f             	and    $0x1f,%edx
  801908:	29 ca                	sub    %ecx,%edx
  80190a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80190e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801912:	83 c0 01             	add    $0x1,%eax
  801915:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801918:	83 c7 01             	add    $0x1,%edi
  80191b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80191e:	75 c2                	jne    8018e2 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801920:	8b 45 10             	mov    0x10(%ebp),%eax
  801923:	eb 05                	jmp    80192a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801925:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80192a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80192d:	5b                   	pop    %ebx
  80192e:	5e                   	pop    %esi
  80192f:	5f                   	pop    %edi
  801930:	5d                   	pop    %ebp
  801931:	c3                   	ret    

00801932 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801932:	55                   	push   %ebp
  801933:	89 e5                	mov    %esp,%ebp
  801935:	57                   	push   %edi
  801936:	56                   	push   %esi
  801937:	53                   	push   %ebx
  801938:	83 ec 18             	sub    $0x18,%esp
  80193b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80193e:	57                   	push   %edi
  80193f:	e8 9c f6 ff ff       	call   800fe0 <fd2data>
  801944:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801946:	83 c4 10             	add    $0x10,%esp
  801949:	bb 00 00 00 00       	mov    $0x0,%ebx
  80194e:	eb 3d                	jmp    80198d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801950:	85 db                	test   %ebx,%ebx
  801952:	74 04                	je     801958 <devpipe_read+0x26>
				return i;
  801954:	89 d8                	mov    %ebx,%eax
  801956:	eb 44                	jmp    80199c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801958:	89 f2                	mov    %esi,%edx
  80195a:	89 f8                	mov    %edi,%eax
  80195c:	e8 e5 fe ff ff       	call   801846 <_pipeisclosed>
  801961:	85 c0                	test   %eax,%eax
  801963:	75 32                	jne    801997 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801965:	e8 a7 f1 ff ff       	call   800b11 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80196a:	8b 06                	mov    (%esi),%eax
  80196c:	3b 46 04             	cmp    0x4(%esi),%eax
  80196f:	74 df                	je     801950 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801971:	99                   	cltd   
  801972:	c1 ea 1b             	shr    $0x1b,%edx
  801975:	01 d0                	add    %edx,%eax
  801977:	83 e0 1f             	and    $0x1f,%eax
  80197a:	29 d0                	sub    %edx,%eax
  80197c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801981:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801984:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801987:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80198a:	83 c3 01             	add    $0x1,%ebx
  80198d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801990:	75 d8                	jne    80196a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801992:	8b 45 10             	mov    0x10(%ebp),%eax
  801995:	eb 05                	jmp    80199c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801997:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80199c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80199f:	5b                   	pop    %ebx
  8019a0:	5e                   	pop    %esi
  8019a1:	5f                   	pop    %edi
  8019a2:	5d                   	pop    %ebp
  8019a3:	c3                   	ret    

008019a4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8019a4:	55                   	push   %ebp
  8019a5:	89 e5                	mov    %esp,%ebp
  8019a7:	56                   	push   %esi
  8019a8:	53                   	push   %ebx
  8019a9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8019ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019af:	50                   	push   %eax
  8019b0:	e8 42 f6 ff ff       	call   800ff7 <fd_alloc>
  8019b5:	83 c4 10             	add    $0x10,%esp
  8019b8:	89 c2                	mov    %eax,%edx
  8019ba:	85 c0                	test   %eax,%eax
  8019bc:	0f 88 2c 01 00 00    	js     801aee <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019c2:	83 ec 04             	sub    $0x4,%esp
  8019c5:	68 07 04 00 00       	push   $0x407
  8019ca:	ff 75 f4             	pushl  -0xc(%ebp)
  8019cd:	6a 00                	push   $0x0
  8019cf:	e8 5c f1 ff ff       	call   800b30 <sys_page_alloc>
  8019d4:	83 c4 10             	add    $0x10,%esp
  8019d7:	89 c2                	mov    %eax,%edx
  8019d9:	85 c0                	test   %eax,%eax
  8019db:	0f 88 0d 01 00 00    	js     801aee <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8019e1:	83 ec 0c             	sub    $0xc,%esp
  8019e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019e7:	50                   	push   %eax
  8019e8:	e8 0a f6 ff ff       	call   800ff7 <fd_alloc>
  8019ed:	89 c3                	mov    %eax,%ebx
  8019ef:	83 c4 10             	add    $0x10,%esp
  8019f2:	85 c0                	test   %eax,%eax
  8019f4:	0f 88 e2 00 00 00    	js     801adc <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019fa:	83 ec 04             	sub    $0x4,%esp
  8019fd:	68 07 04 00 00       	push   $0x407
  801a02:	ff 75 f0             	pushl  -0x10(%ebp)
  801a05:	6a 00                	push   $0x0
  801a07:	e8 24 f1 ff ff       	call   800b30 <sys_page_alloc>
  801a0c:	89 c3                	mov    %eax,%ebx
  801a0e:	83 c4 10             	add    $0x10,%esp
  801a11:	85 c0                	test   %eax,%eax
  801a13:	0f 88 c3 00 00 00    	js     801adc <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a19:	83 ec 0c             	sub    $0xc,%esp
  801a1c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a1f:	e8 bc f5 ff ff       	call   800fe0 <fd2data>
  801a24:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a26:	83 c4 0c             	add    $0xc,%esp
  801a29:	68 07 04 00 00       	push   $0x407
  801a2e:	50                   	push   %eax
  801a2f:	6a 00                	push   $0x0
  801a31:	e8 fa f0 ff ff       	call   800b30 <sys_page_alloc>
  801a36:	89 c3                	mov    %eax,%ebx
  801a38:	83 c4 10             	add    $0x10,%esp
  801a3b:	85 c0                	test   %eax,%eax
  801a3d:	0f 88 89 00 00 00    	js     801acc <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a43:	83 ec 0c             	sub    $0xc,%esp
  801a46:	ff 75 f0             	pushl  -0x10(%ebp)
  801a49:	e8 92 f5 ff ff       	call   800fe0 <fd2data>
  801a4e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a55:	50                   	push   %eax
  801a56:	6a 00                	push   $0x0
  801a58:	56                   	push   %esi
  801a59:	6a 00                	push   $0x0
  801a5b:	e8 13 f1 ff ff       	call   800b73 <sys_page_map>
  801a60:	89 c3                	mov    %eax,%ebx
  801a62:	83 c4 20             	add    $0x20,%esp
  801a65:	85 c0                	test   %eax,%eax
  801a67:	78 55                	js     801abe <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a69:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a72:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a77:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a7e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a84:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a87:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a89:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a8c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a93:	83 ec 0c             	sub    $0xc,%esp
  801a96:	ff 75 f4             	pushl  -0xc(%ebp)
  801a99:	e8 32 f5 ff ff       	call   800fd0 <fd2num>
  801a9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801aa1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801aa3:	83 c4 04             	add    $0x4,%esp
  801aa6:	ff 75 f0             	pushl  -0x10(%ebp)
  801aa9:	e8 22 f5 ff ff       	call   800fd0 <fd2num>
  801aae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ab1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ab4:	83 c4 10             	add    $0x10,%esp
  801ab7:	ba 00 00 00 00       	mov    $0x0,%edx
  801abc:	eb 30                	jmp    801aee <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801abe:	83 ec 08             	sub    $0x8,%esp
  801ac1:	56                   	push   %esi
  801ac2:	6a 00                	push   $0x0
  801ac4:	e8 ec f0 ff ff       	call   800bb5 <sys_page_unmap>
  801ac9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801acc:	83 ec 08             	sub    $0x8,%esp
  801acf:	ff 75 f0             	pushl  -0x10(%ebp)
  801ad2:	6a 00                	push   $0x0
  801ad4:	e8 dc f0 ff ff       	call   800bb5 <sys_page_unmap>
  801ad9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801adc:	83 ec 08             	sub    $0x8,%esp
  801adf:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae2:	6a 00                	push   $0x0
  801ae4:	e8 cc f0 ff ff       	call   800bb5 <sys_page_unmap>
  801ae9:	83 c4 10             	add    $0x10,%esp
  801aec:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801aee:	89 d0                	mov    %edx,%eax
  801af0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af3:	5b                   	pop    %ebx
  801af4:	5e                   	pop    %esi
  801af5:	5d                   	pop    %ebp
  801af6:	c3                   	ret    

00801af7 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801afd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b00:	50                   	push   %eax
  801b01:	ff 75 08             	pushl  0x8(%ebp)
  801b04:	e8 3d f5 ff ff       	call   801046 <fd_lookup>
  801b09:	83 c4 10             	add    $0x10,%esp
  801b0c:	85 c0                	test   %eax,%eax
  801b0e:	78 18                	js     801b28 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b10:	83 ec 0c             	sub    $0xc,%esp
  801b13:	ff 75 f4             	pushl  -0xc(%ebp)
  801b16:	e8 c5 f4 ff ff       	call   800fe0 <fd2data>
	return _pipeisclosed(fd, p);
  801b1b:	89 c2                	mov    %eax,%edx
  801b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b20:	e8 21 fd ff ff       	call   801846 <_pipeisclosed>
  801b25:	83 c4 10             	add    $0x10,%esp
}
  801b28:	c9                   	leave  
  801b29:	c3                   	ret    

00801b2a <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b2a:	55                   	push   %ebp
  801b2b:	89 e5                	mov    %esp,%ebp
  801b2d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801b30:	68 06 2b 80 00       	push   $0x802b06
  801b35:	ff 75 0c             	pushl  0xc(%ebp)
  801b38:	e8 f0 eb ff ff       	call   80072d <strcpy>
	return 0;
}
  801b3d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b42:	c9                   	leave  
  801b43:	c3                   	ret    

00801b44 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	53                   	push   %ebx
  801b48:	83 ec 10             	sub    $0x10,%esp
  801b4b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b4e:	53                   	push   %ebx
  801b4f:	e8 65 07 00 00       	call   8022b9 <pageref>
  801b54:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801b57:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801b5c:	83 f8 01             	cmp    $0x1,%eax
  801b5f:	75 10                	jne    801b71 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801b61:	83 ec 0c             	sub    $0xc,%esp
  801b64:	ff 73 0c             	pushl  0xc(%ebx)
  801b67:	e8 c0 02 00 00       	call   801e2c <nsipc_close>
  801b6c:	89 c2                	mov    %eax,%edx
  801b6e:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801b71:	89 d0                	mov    %edx,%eax
  801b73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b76:	c9                   	leave  
  801b77:	c3                   	ret    

00801b78 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b78:	55                   	push   %ebp
  801b79:	89 e5                	mov    %esp,%ebp
  801b7b:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b7e:	6a 00                	push   $0x0
  801b80:	ff 75 10             	pushl  0x10(%ebp)
  801b83:	ff 75 0c             	pushl  0xc(%ebp)
  801b86:	8b 45 08             	mov    0x8(%ebp),%eax
  801b89:	ff 70 0c             	pushl  0xc(%eax)
  801b8c:	e8 78 03 00 00       	call   801f09 <nsipc_send>
}
  801b91:	c9                   	leave  
  801b92:	c3                   	ret    

00801b93 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b99:	6a 00                	push   $0x0
  801b9b:	ff 75 10             	pushl  0x10(%ebp)
  801b9e:	ff 75 0c             	pushl  0xc(%ebp)
  801ba1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba4:	ff 70 0c             	pushl  0xc(%eax)
  801ba7:	e8 f1 02 00 00       	call   801e9d <nsipc_recv>
}
  801bac:	c9                   	leave  
  801bad:	c3                   	ret    

00801bae <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801bae:	55                   	push   %ebp
  801baf:	89 e5                	mov    %esp,%ebp
  801bb1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801bb4:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801bb7:	52                   	push   %edx
  801bb8:	50                   	push   %eax
  801bb9:	e8 88 f4 ff ff       	call   801046 <fd_lookup>
  801bbe:	83 c4 10             	add    $0x10,%esp
  801bc1:	85 c0                	test   %eax,%eax
  801bc3:	78 17                	js     801bdc <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc8:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801bce:	39 08                	cmp    %ecx,(%eax)
  801bd0:	75 05                	jne    801bd7 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801bd2:	8b 40 0c             	mov    0xc(%eax),%eax
  801bd5:	eb 05                	jmp    801bdc <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801bd7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801bdc:	c9                   	leave  
  801bdd:	c3                   	ret    

00801bde <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801bde:	55                   	push   %ebp
  801bdf:	89 e5                	mov    %esp,%ebp
  801be1:	56                   	push   %esi
  801be2:	53                   	push   %ebx
  801be3:	83 ec 1c             	sub    $0x1c,%esp
  801be6:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801be8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801beb:	50                   	push   %eax
  801bec:	e8 06 f4 ff ff       	call   800ff7 <fd_alloc>
  801bf1:	89 c3                	mov    %eax,%ebx
  801bf3:	83 c4 10             	add    $0x10,%esp
  801bf6:	85 c0                	test   %eax,%eax
  801bf8:	78 1b                	js     801c15 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801bfa:	83 ec 04             	sub    $0x4,%esp
  801bfd:	68 07 04 00 00       	push   $0x407
  801c02:	ff 75 f4             	pushl  -0xc(%ebp)
  801c05:	6a 00                	push   $0x0
  801c07:	e8 24 ef ff ff       	call   800b30 <sys_page_alloc>
  801c0c:	89 c3                	mov    %eax,%ebx
  801c0e:	83 c4 10             	add    $0x10,%esp
  801c11:	85 c0                	test   %eax,%eax
  801c13:	79 10                	jns    801c25 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801c15:	83 ec 0c             	sub    $0xc,%esp
  801c18:	56                   	push   %esi
  801c19:	e8 0e 02 00 00       	call   801e2c <nsipc_close>
		return r;
  801c1e:	83 c4 10             	add    $0x10,%esp
  801c21:	89 d8                	mov    %ebx,%eax
  801c23:	eb 24                	jmp    801c49 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801c25:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c2e:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801c30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c33:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801c3a:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801c3d:	83 ec 0c             	sub    $0xc,%esp
  801c40:	50                   	push   %eax
  801c41:	e8 8a f3 ff ff       	call   800fd0 <fd2num>
  801c46:	83 c4 10             	add    $0x10,%esp
}
  801c49:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c4c:	5b                   	pop    %ebx
  801c4d:	5e                   	pop    %esi
  801c4e:	5d                   	pop    %ebp
  801c4f:	c3                   	ret    

00801c50 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c50:	55                   	push   %ebp
  801c51:	89 e5                	mov    %esp,%ebp
  801c53:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c56:	8b 45 08             	mov    0x8(%ebp),%eax
  801c59:	e8 50 ff ff ff       	call   801bae <fd2sockid>
		return r;
  801c5e:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c60:	85 c0                	test   %eax,%eax
  801c62:	78 1f                	js     801c83 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c64:	83 ec 04             	sub    $0x4,%esp
  801c67:	ff 75 10             	pushl  0x10(%ebp)
  801c6a:	ff 75 0c             	pushl  0xc(%ebp)
  801c6d:	50                   	push   %eax
  801c6e:	e8 12 01 00 00       	call   801d85 <nsipc_accept>
  801c73:	83 c4 10             	add    $0x10,%esp
		return r;
  801c76:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c78:	85 c0                	test   %eax,%eax
  801c7a:	78 07                	js     801c83 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801c7c:	e8 5d ff ff ff       	call   801bde <alloc_sockfd>
  801c81:	89 c1                	mov    %eax,%ecx
}
  801c83:	89 c8                	mov    %ecx,%eax
  801c85:	c9                   	leave  
  801c86:	c3                   	ret    

00801c87 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c87:	55                   	push   %ebp
  801c88:	89 e5                	mov    %esp,%ebp
  801c8a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c90:	e8 19 ff ff ff       	call   801bae <fd2sockid>
  801c95:	85 c0                	test   %eax,%eax
  801c97:	78 12                	js     801cab <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801c99:	83 ec 04             	sub    $0x4,%esp
  801c9c:	ff 75 10             	pushl  0x10(%ebp)
  801c9f:	ff 75 0c             	pushl  0xc(%ebp)
  801ca2:	50                   	push   %eax
  801ca3:	e8 2d 01 00 00       	call   801dd5 <nsipc_bind>
  801ca8:	83 c4 10             	add    $0x10,%esp
}
  801cab:	c9                   	leave  
  801cac:	c3                   	ret    

00801cad <shutdown>:

int
shutdown(int s, int how)
{
  801cad:	55                   	push   %ebp
  801cae:	89 e5                	mov    %esp,%ebp
  801cb0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cb3:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb6:	e8 f3 fe ff ff       	call   801bae <fd2sockid>
  801cbb:	85 c0                	test   %eax,%eax
  801cbd:	78 0f                	js     801cce <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801cbf:	83 ec 08             	sub    $0x8,%esp
  801cc2:	ff 75 0c             	pushl  0xc(%ebp)
  801cc5:	50                   	push   %eax
  801cc6:	e8 3f 01 00 00       	call   801e0a <nsipc_shutdown>
  801ccb:	83 c4 10             	add    $0x10,%esp
}
  801cce:	c9                   	leave  
  801ccf:	c3                   	ret    

00801cd0 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cd0:	55                   	push   %ebp
  801cd1:	89 e5                	mov    %esp,%ebp
  801cd3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cd6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd9:	e8 d0 fe ff ff       	call   801bae <fd2sockid>
  801cde:	85 c0                	test   %eax,%eax
  801ce0:	78 12                	js     801cf4 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801ce2:	83 ec 04             	sub    $0x4,%esp
  801ce5:	ff 75 10             	pushl  0x10(%ebp)
  801ce8:	ff 75 0c             	pushl  0xc(%ebp)
  801ceb:	50                   	push   %eax
  801cec:	e8 55 01 00 00       	call   801e46 <nsipc_connect>
  801cf1:	83 c4 10             	add    $0x10,%esp
}
  801cf4:	c9                   	leave  
  801cf5:	c3                   	ret    

00801cf6 <listen>:

int
listen(int s, int backlog)
{
  801cf6:	55                   	push   %ebp
  801cf7:	89 e5                	mov    %esp,%ebp
  801cf9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cfc:	8b 45 08             	mov    0x8(%ebp),%eax
  801cff:	e8 aa fe ff ff       	call   801bae <fd2sockid>
  801d04:	85 c0                	test   %eax,%eax
  801d06:	78 0f                	js     801d17 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801d08:	83 ec 08             	sub    $0x8,%esp
  801d0b:	ff 75 0c             	pushl  0xc(%ebp)
  801d0e:	50                   	push   %eax
  801d0f:	e8 67 01 00 00       	call   801e7b <nsipc_listen>
  801d14:	83 c4 10             	add    $0x10,%esp
}
  801d17:	c9                   	leave  
  801d18:	c3                   	ret    

00801d19 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801d19:	55                   	push   %ebp
  801d1a:	89 e5                	mov    %esp,%ebp
  801d1c:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801d1f:	ff 75 10             	pushl  0x10(%ebp)
  801d22:	ff 75 0c             	pushl  0xc(%ebp)
  801d25:	ff 75 08             	pushl  0x8(%ebp)
  801d28:	e8 3a 02 00 00       	call   801f67 <nsipc_socket>
  801d2d:	83 c4 10             	add    $0x10,%esp
  801d30:	85 c0                	test   %eax,%eax
  801d32:	78 05                	js     801d39 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801d34:	e8 a5 fe ff ff       	call   801bde <alloc_sockfd>
}
  801d39:	c9                   	leave  
  801d3a:	c3                   	ret    

00801d3b <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d3b:	55                   	push   %ebp
  801d3c:	89 e5                	mov    %esp,%ebp
  801d3e:	53                   	push   %ebx
  801d3f:	83 ec 04             	sub    $0x4,%esp
  801d42:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d44:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801d4b:	75 12                	jne    801d5f <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d4d:	83 ec 0c             	sub    $0xc,%esp
  801d50:	6a 02                	push   $0x2
  801d52:	e8 29 05 00 00       	call   802280 <ipc_find_env>
  801d57:	a3 04 40 80 00       	mov    %eax,0x804004
  801d5c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d5f:	6a 07                	push   $0x7
  801d61:	68 00 60 80 00       	push   $0x806000
  801d66:	53                   	push   %ebx
  801d67:	ff 35 04 40 80 00    	pushl  0x804004
  801d6d:	e8 ba 04 00 00       	call   80222c <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d72:	83 c4 0c             	add    $0xc,%esp
  801d75:	6a 00                	push   $0x0
  801d77:	6a 00                	push   $0x0
  801d79:	6a 00                	push   $0x0
  801d7b:	e8 45 04 00 00       	call   8021c5 <ipc_recv>
}
  801d80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d83:	c9                   	leave  
  801d84:	c3                   	ret    

00801d85 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d85:	55                   	push   %ebp
  801d86:	89 e5                	mov    %esp,%ebp
  801d88:	56                   	push   %esi
  801d89:	53                   	push   %ebx
  801d8a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d90:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d95:	8b 06                	mov    (%esi),%eax
  801d97:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d9c:	b8 01 00 00 00       	mov    $0x1,%eax
  801da1:	e8 95 ff ff ff       	call   801d3b <nsipc>
  801da6:	89 c3                	mov    %eax,%ebx
  801da8:	85 c0                	test   %eax,%eax
  801daa:	78 20                	js     801dcc <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801dac:	83 ec 04             	sub    $0x4,%esp
  801daf:	ff 35 10 60 80 00    	pushl  0x806010
  801db5:	68 00 60 80 00       	push   $0x806000
  801dba:	ff 75 0c             	pushl  0xc(%ebp)
  801dbd:	e8 fd ea ff ff       	call   8008bf <memmove>
		*addrlen = ret->ret_addrlen;
  801dc2:	a1 10 60 80 00       	mov    0x806010,%eax
  801dc7:	89 06                	mov    %eax,(%esi)
  801dc9:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801dcc:	89 d8                	mov    %ebx,%eax
  801dce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dd1:	5b                   	pop    %ebx
  801dd2:	5e                   	pop    %esi
  801dd3:	5d                   	pop    %ebp
  801dd4:	c3                   	ret    

00801dd5 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801dd5:	55                   	push   %ebp
  801dd6:	89 e5                	mov    %esp,%ebp
  801dd8:	53                   	push   %ebx
  801dd9:	83 ec 08             	sub    $0x8,%esp
  801ddc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801ddf:	8b 45 08             	mov    0x8(%ebp),%eax
  801de2:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801de7:	53                   	push   %ebx
  801de8:	ff 75 0c             	pushl  0xc(%ebp)
  801deb:	68 04 60 80 00       	push   $0x806004
  801df0:	e8 ca ea ff ff       	call   8008bf <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801df5:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801dfb:	b8 02 00 00 00       	mov    $0x2,%eax
  801e00:	e8 36 ff ff ff       	call   801d3b <nsipc>
}
  801e05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e08:	c9                   	leave  
  801e09:	c3                   	ret    

00801e0a <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801e0a:	55                   	push   %ebp
  801e0b:	89 e5                	mov    %esp,%ebp
  801e0d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e10:	8b 45 08             	mov    0x8(%ebp),%eax
  801e13:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801e18:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e1b:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801e20:	b8 03 00 00 00       	mov    $0x3,%eax
  801e25:	e8 11 ff ff ff       	call   801d3b <nsipc>
}
  801e2a:	c9                   	leave  
  801e2b:	c3                   	ret    

00801e2c <nsipc_close>:

int
nsipc_close(int s)
{
  801e2c:	55                   	push   %ebp
  801e2d:	89 e5                	mov    %esp,%ebp
  801e2f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801e32:	8b 45 08             	mov    0x8(%ebp),%eax
  801e35:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801e3a:	b8 04 00 00 00       	mov    $0x4,%eax
  801e3f:	e8 f7 fe ff ff       	call   801d3b <nsipc>
}
  801e44:	c9                   	leave  
  801e45:	c3                   	ret    

00801e46 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e46:	55                   	push   %ebp
  801e47:	89 e5                	mov    %esp,%ebp
  801e49:	53                   	push   %ebx
  801e4a:	83 ec 08             	sub    $0x8,%esp
  801e4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801e50:	8b 45 08             	mov    0x8(%ebp),%eax
  801e53:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801e58:	53                   	push   %ebx
  801e59:	ff 75 0c             	pushl  0xc(%ebp)
  801e5c:	68 04 60 80 00       	push   $0x806004
  801e61:	e8 59 ea ff ff       	call   8008bf <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801e66:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801e6c:	b8 05 00 00 00       	mov    $0x5,%eax
  801e71:	e8 c5 fe ff ff       	call   801d3b <nsipc>
}
  801e76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e79:	c9                   	leave  
  801e7a:	c3                   	ret    

00801e7b <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801e7b:	55                   	push   %ebp
  801e7c:	89 e5                	mov    %esp,%ebp
  801e7e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801e81:	8b 45 08             	mov    0x8(%ebp),%eax
  801e84:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801e89:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e8c:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801e91:	b8 06 00 00 00       	mov    $0x6,%eax
  801e96:	e8 a0 fe ff ff       	call   801d3b <nsipc>
}
  801e9b:	c9                   	leave  
  801e9c:	c3                   	ret    

00801e9d <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e9d:	55                   	push   %ebp
  801e9e:	89 e5                	mov    %esp,%ebp
  801ea0:	56                   	push   %esi
  801ea1:	53                   	push   %ebx
  801ea2:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801ea5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801ead:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801eb3:	8b 45 14             	mov    0x14(%ebp),%eax
  801eb6:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ebb:	b8 07 00 00 00       	mov    $0x7,%eax
  801ec0:	e8 76 fe ff ff       	call   801d3b <nsipc>
  801ec5:	89 c3                	mov    %eax,%ebx
  801ec7:	85 c0                	test   %eax,%eax
  801ec9:	78 35                	js     801f00 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801ecb:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801ed0:	7f 04                	jg     801ed6 <nsipc_recv+0x39>
  801ed2:	39 c6                	cmp    %eax,%esi
  801ed4:	7d 16                	jge    801eec <nsipc_recv+0x4f>
  801ed6:	68 12 2b 80 00       	push   $0x802b12
  801edb:	68 bb 2a 80 00       	push   $0x802abb
  801ee0:	6a 62                	push   $0x62
  801ee2:	68 27 2b 80 00       	push   $0x802b27
  801ee7:	e8 28 02 00 00       	call   802114 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801eec:	83 ec 04             	sub    $0x4,%esp
  801eef:	50                   	push   %eax
  801ef0:	68 00 60 80 00       	push   $0x806000
  801ef5:	ff 75 0c             	pushl  0xc(%ebp)
  801ef8:	e8 c2 e9 ff ff       	call   8008bf <memmove>
  801efd:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801f00:	89 d8                	mov    %ebx,%eax
  801f02:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f05:	5b                   	pop    %ebx
  801f06:	5e                   	pop    %esi
  801f07:	5d                   	pop    %ebp
  801f08:	c3                   	ret    

00801f09 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801f09:	55                   	push   %ebp
  801f0a:	89 e5                	mov    %esp,%ebp
  801f0c:	53                   	push   %ebx
  801f0d:	83 ec 04             	sub    $0x4,%esp
  801f10:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801f13:	8b 45 08             	mov    0x8(%ebp),%eax
  801f16:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801f1b:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801f21:	7e 16                	jle    801f39 <nsipc_send+0x30>
  801f23:	68 33 2b 80 00       	push   $0x802b33
  801f28:	68 bb 2a 80 00       	push   $0x802abb
  801f2d:	6a 6d                	push   $0x6d
  801f2f:	68 27 2b 80 00       	push   $0x802b27
  801f34:	e8 db 01 00 00       	call   802114 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801f39:	83 ec 04             	sub    $0x4,%esp
  801f3c:	53                   	push   %ebx
  801f3d:	ff 75 0c             	pushl  0xc(%ebp)
  801f40:	68 0c 60 80 00       	push   $0x80600c
  801f45:	e8 75 e9 ff ff       	call   8008bf <memmove>
	nsipcbuf.send.req_size = size;
  801f4a:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801f50:	8b 45 14             	mov    0x14(%ebp),%eax
  801f53:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801f58:	b8 08 00 00 00       	mov    $0x8,%eax
  801f5d:	e8 d9 fd ff ff       	call   801d3b <nsipc>
}
  801f62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f65:	c9                   	leave  
  801f66:	c3                   	ret    

00801f67 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801f67:	55                   	push   %ebp
  801f68:	89 e5                	mov    %esp,%ebp
  801f6a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801f6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f70:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801f75:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f78:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801f7d:	8b 45 10             	mov    0x10(%ebp),%eax
  801f80:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801f85:	b8 09 00 00 00       	mov    $0x9,%eax
  801f8a:	e8 ac fd ff ff       	call   801d3b <nsipc>
}
  801f8f:	c9                   	leave  
  801f90:	c3                   	ret    

00801f91 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f91:	55                   	push   %ebp
  801f92:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f94:	b8 00 00 00 00       	mov    $0x0,%eax
  801f99:	5d                   	pop    %ebp
  801f9a:	c3                   	ret    

00801f9b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f9b:	55                   	push   %ebp
  801f9c:	89 e5                	mov    %esp,%ebp
  801f9e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801fa1:	68 3f 2b 80 00       	push   $0x802b3f
  801fa6:	ff 75 0c             	pushl  0xc(%ebp)
  801fa9:	e8 7f e7 ff ff       	call   80072d <strcpy>
	return 0;
}
  801fae:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb3:	c9                   	leave  
  801fb4:	c3                   	ret    

00801fb5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fb5:	55                   	push   %ebp
  801fb6:	89 e5                	mov    %esp,%ebp
  801fb8:	57                   	push   %edi
  801fb9:	56                   	push   %esi
  801fba:	53                   	push   %ebx
  801fbb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fc1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fc6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fcc:	eb 2d                	jmp    801ffb <devcons_write+0x46>
		m = n - tot;
  801fce:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fd1:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801fd3:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801fd6:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801fdb:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fde:	83 ec 04             	sub    $0x4,%esp
  801fe1:	53                   	push   %ebx
  801fe2:	03 45 0c             	add    0xc(%ebp),%eax
  801fe5:	50                   	push   %eax
  801fe6:	57                   	push   %edi
  801fe7:	e8 d3 e8 ff ff       	call   8008bf <memmove>
		sys_cputs(buf, m);
  801fec:	83 c4 08             	add    $0x8,%esp
  801fef:	53                   	push   %ebx
  801ff0:	57                   	push   %edi
  801ff1:	e8 7e ea ff ff       	call   800a74 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ff6:	01 de                	add    %ebx,%esi
  801ff8:	83 c4 10             	add    $0x10,%esp
  801ffb:	89 f0                	mov    %esi,%eax
  801ffd:	3b 75 10             	cmp    0x10(%ebp),%esi
  802000:	72 cc                	jb     801fce <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802002:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802005:	5b                   	pop    %ebx
  802006:	5e                   	pop    %esi
  802007:	5f                   	pop    %edi
  802008:	5d                   	pop    %ebp
  802009:	c3                   	ret    

0080200a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80200a:	55                   	push   %ebp
  80200b:	89 e5                	mov    %esp,%ebp
  80200d:	83 ec 08             	sub    $0x8,%esp
  802010:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802015:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802019:	74 2a                	je     802045 <devcons_read+0x3b>
  80201b:	eb 05                	jmp    802022 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80201d:	e8 ef ea ff ff       	call   800b11 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802022:	e8 6b ea ff ff       	call   800a92 <sys_cgetc>
  802027:	85 c0                	test   %eax,%eax
  802029:	74 f2                	je     80201d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80202b:	85 c0                	test   %eax,%eax
  80202d:	78 16                	js     802045 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80202f:	83 f8 04             	cmp    $0x4,%eax
  802032:	74 0c                	je     802040 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802034:	8b 55 0c             	mov    0xc(%ebp),%edx
  802037:	88 02                	mov    %al,(%edx)
	return 1;
  802039:	b8 01 00 00 00       	mov    $0x1,%eax
  80203e:	eb 05                	jmp    802045 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802040:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802045:	c9                   	leave  
  802046:	c3                   	ret    

00802047 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802047:	55                   	push   %ebp
  802048:	89 e5                	mov    %esp,%ebp
  80204a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80204d:	8b 45 08             	mov    0x8(%ebp),%eax
  802050:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802053:	6a 01                	push   $0x1
  802055:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802058:	50                   	push   %eax
  802059:	e8 16 ea ff ff       	call   800a74 <sys_cputs>
}
  80205e:	83 c4 10             	add    $0x10,%esp
  802061:	c9                   	leave  
  802062:	c3                   	ret    

00802063 <getchar>:

int
getchar(void)
{
  802063:	55                   	push   %ebp
  802064:	89 e5                	mov    %esp,%ebp
  802066:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802069:	6a 01                	push   $0x1
  80206b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80206e:	50                   	push   %eax
  80206f:	6a 00                	push   $0x0
  802071:	e8 36 f2 ff ff       	call   8012ac <read>
	if (r < 0)
  802076:	83 c4 10             	add    $0x10,%esp
  802079:	85 c0                	test   %eax,%eax
  80207b:	78 0f                	js     80208c <getchar+0x29>
		return r;
	if (r < 1)
  80207d:	85 c0                	test   %eax,%eax
  80207f:	7e 06                	jle    802087 <getchar+0x24>
		return -E_EOF;
	return c;
  802081:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802085:	eb 05                	jmp    80208c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802087:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80208c:	c9                   	leave  
  80208d:	c3                   	ret    

0080208e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80208e:	55                   	push   %ebp
  80208f:	89 e5                	mov    %esp,%ebp
  802091:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802094:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802097:	50                   	push   %eax
  802098:	ff 75 08             	pushl  0x8(%ebp)
  80209b:	e8 a6 ef ff ff       	call   801046 <fd_lookup>
  8020a0:	83 c4 10             	add    $0x10,%esp
  8020a3:	85 c0                	test   %eax,%eax
  8020a5:	78 11                	js     8020b8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020aa:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8020b0:	39 10                	cmp    %edx,(%eax)
  8020b2:	0f 94 c0             	sete   %al
  8020b5:	0f b6 c0             	movzbl %al,%eax
}
  8020b8:	c9                   	leave  
  8020b9:	c3                   	ret    

008020ba <opencons>:

int
opencons(void)
{
  8020ba:	55                   	push   %ebp
  8020bb:	89 e5                	mov    %esp,%ebp
  8020bd:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020c3:	50                   	push   %eax
  8020c4:	e8 2e ef ff ff       	call   800ff7 <fd_alloc>
  8020c9:	83 c4 10             	add    $0x10,%esp
		return r;
  8020cc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020ce:	85 c0                	test   %eax,%eax
  8020d0:	78 3e                	js     802110 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020d2:	83 ec 04             	sub    $0x4,%esp
  8020d5:	68 07 04 00 00       	push   $0x407
  8020da:	ff 75 f4             	pushl  -0xc(%ebp)
  8020dd:	6a 00                	push   $0x0
  8020df:	e8 4c ea ff ff       	call   800b30 <sys_page_alloc>
  8020e4:	83 c4 10             	add    $0x10,%esp
		return r;
  8020e7:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020e9:	85 c0                	test   %eax,%eax
  8020eb:	78 23                	js     802110 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020ed:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8020f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020fb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802102:	83 ec 0c             	sub    $0xc,%esp
  802105:	50                   	push   %eax
  802106:	e8 c5 ee ff ff       	call   800fd0 <fd2num>
  80210b:	89 c2                	mov    %eax,%edx
  80210d:	83 c4 10             	add    $0x10,%esp
}
  802110:	89 d0                	mov    %edx,%eax
  802112:	c9                   	leave  
  802113:	c3                   	ret    

00802114 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802114:	55                   	push   %ebp
  802115:	89 e5                	mov    %esp,%ebp
  802117:	56                   	push   %esi
  802118:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802119:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80211c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802122:	e8 cb e9 ff ff       	call   800af2 <sys_getenvid>
  802127:	83 ec 0c             	sub    $0xc,%esp
  80212a:	ff 75 0c             	pushl  0xc(%ebp)
  80212d:	ff 75 08             	pushl  0x8(%ebp)
  802130:	56                   	push   %esi
  802131:	50                   	push   %eax
  802132:	68 4c 2b 80 00       	push   $0x802b4c
  802137:	e8 6c e0 ff ff       	call   8001a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80213c:	83 c4 18             	add    $0x18,%esp
  80213f:	53                   	push   %ebx
  802140:	ff 75 10             	pushl  0x10(%ebp)
  802143:	e8 0f e0 ff ff       	call   800157 <vcprintf>
	cprintf("\n");
  802148:	c7 04 24 34 26 80 00 	movl   $0x802634,(%esp)
  80214f:	e8 54 e0 ff ff       	call   8001a8 <cprintf>
  802154:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802157:	cc                   	int3   
  802158:	eb fd                	jmp    802157 <_panic+0x43>

0080215a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80215a:	55                   	push   %ebp
  80215b:	89 e5                	mov    %esp,%ebp
  80215d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802160:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802167:	75 2e                	jne    802197 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  802169:	e8 84 e9 ff ff       	call   800af2 <sys_getenvid>
  80216e:	83 ec 04             	sub    $0x4,%esp
  802171:	68 07 0e 00 00       	push   $0xe07
  802176:	68 00 f0 bf ee       	push   $0xeebff000
  80217b:	50                   	push   %eax
  80217c:	e8 af e9 ff ff       	call   800b30 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802181:	e8 6c e9 ff ff       	call   800af2 <sys_getenvid>
  802186:	83 c4 08             	add    $0x8,%esp
  802189:	68 a1 21 80 00       	push   $0x8021a1
  80218e:	50                   	push   %eax
  80218f:	e8 e7 ea ff ff       	call   800c7b <sys_env_set_pgfault_upcall>
  802194:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802197:	8b 45 08             	mov    0x8(%ebp),%eax
  80219a:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80219f:	c9                   	leave  
  8021a0:	c3                   	ret    

008021a1 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8021a1:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8021a2:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8021a7:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8021a9:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  8021ac:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  8021b0:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  8021b4:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  8021b7:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  8021ba:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  8021bb:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  8021be:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  8021bf:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  8021c0:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  8021c4:	c3                   	ret    

008021c5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021c5:	55                   	push   %ebp
  8021c6:	89 e5                	mov    %esp,%ebp
  8021c8:	56                   	push   %esi
  8021c9:	53                   	push   %ebx
  8021ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8021cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021d0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8021d3:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8021d5:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8021da:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8021dd:	83 ec 0c             	sub    $0xc,%esp
  8021e0:	50                   	push   %eax
  8021e1:	e8 fa ea ff ff       	call   800ce0 <sys_ipc_recv>

	if (from_env_store != NULL)
  8021e6:	83 c4 10             	add    $0x10,%esp
  8021e9:	85 f6                	test   %esi,%esi
  8021eb:	74 14                	je     802201 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8021ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8021f2:	85 c0                	test   %eax,%eax
  8021f4:	78 09                	js     8021ff <ipc_recv+0x3a>
  8021f6:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8021fc:	8b 52 74             	mov    0x74(%edx),%edx
  8021ff:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802201:	85 db                	test   %ebx,%ebx
  802203:	74 14                	je     802219 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802205:	ba 00 00 00 00       	mov    $0x0,%edx
  80220a:	85 c0                	test   %eax,%eax
  80220c:	78 09                	js     802217 <ipc_recv+0x52>
  80220e:	8b 15 08 40 80 00    	mov    0x804008,%edx
  802214:	8b 52 78             	mov    0x78(%edx),%edx
  802217:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  802219:	85 c0                	test   %eax,%eax
  80221b:	78 08                	js     802225 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  80221d:	a1 08 40 80 00       	mov    0x804008,%eax
  802222:	8b 40 70             	mov    0x70(%eax),%eax
}
  802225:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802228:	5b                   	pop    %ebx
  802229:	5e                   	pop    %esi
  80222a:	5d                   	pop    %ebp
  80222b:	c3                   	ret    

0080222c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80222c:	55                   	push   %ebp
  80222d:	89 e5                	mov    %esp,%ebp
  80222f:	57                   	push   %edi
  802230:	56                   	push   %esi
  802231:	53                   	push   %ebx
  802232:	83 ec 0c             	sub    $0xc,%esp
  802235:	8b 7d 08             	mov    0x8(%ebp),%edi
  802238:	8b 75 0c             	mov    0xc(%ebp),%esi
  80223b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  80223e:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802240:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802245:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  802248:	ff 75 14             	pushl  0x14(%ebp)
  80224b:	53                   	push   %ebx
  80224c:	56                   	push   %esi
  80224d:	57                   	push   %edi
  80224e:	e8 6a ea ff ff       	call   800cbd <sys_ipc_try_send>

		if (err < 0) {
  802253:	83 c4 10             	add    $0x10,%esp
  802256:	85 c0                	test   %eax,%eax
  802258:	79 1e                	jns    802278 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  80225a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80225d:	75 07                	jne    802266 <ipc_send+0x3a>
				sys_yield();
  80225f:	e8 ad e8 ff ff       	call   800b11 <sys_yield>
  802264:	eb e2                	jmp    802248 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  802266:	50                   	push   %eax
  802267:	68 70 2b 80 00       	push   $0x802b70
  80226c:	6a 49                	push   $0x49
  80226e:	68 7d 2b 80 00       	push   $0x802b7d
  802273:	e8 9c fe ff ff       	call   802114 <_panic>
		}

	} while (err < 0);

}
  802278:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80227b:	5b                   	pop    %ebx
  80227c:	5e                   	pop    %esi
  80227d:	5f                   	pop    %edi
  80227e:	5d                   	pop    %ebp
  80227f:	c3                   	ret    

00802280 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802280:	55                   	push   %ebp
  802281:	89 e5                	mov    %esp,%ebp
  802283:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802286:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80228b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80228e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802294:	8b 52 50             	mov    0x50(%edx),%edx
  802297:	39 ca                	cmp    %ecx,%edx
  802299:	75 0d                	jne    8022a8 <ipc_find_env+0x28>
			return envs[i].env_id;
  80229b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80229e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8022a3:	8b 40 48             	mov    0x48(%eax),%eax
  8022a6:	eb 0f                	jmp    8022b7 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022a8:	83 c0 01             	add    $0x1,%eax
  8022ab:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022b0:	75 d9                	jne    80228b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8022b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022b7:	5d                   	pop    %ebp
  8022b8:	c3                   	ret    

008022b9 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022b9:	55                   	push   %ebp
  8022ba:	89 e5                	mov    %esp,%ebp
  8022bc:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022bf:	89 d0                	mov    %edx,%eax
  8022c1:	c1 e8 16             	shr    $0x16,%eax
  8022c4:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8022cb:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022d0:	f6 c1 01             	test   $0x1,%cl
  8022d3:	74 1d                	je     8022f2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8022d5:	c1 ea 0c             	shr    $0xc,%edx
  8022d8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8022df:	f6 c2 01             	test   $0x1,%dl
  8022e2:	74 0e                	je     8022f2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022e4:	c1 ea 0c             	shr    $0xc,%edx
  8022e7:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8022ee:	ef 
  8022ef:	0f b7 c0             	movzwl %ax,%eax
}
  8022f2:	5d                   	pop    %ebp
  8022f3:	c3                   	ret    
  8022f4:	66 90                	xchg   %ax,%ax
  8022f6:	66 90                	xchg   %ax,%ax
  8022f8:	66 90                	xchg   %ax,%ax
  8022fa:	66 90                	xchg   %ax,%ax
  8022fc:	66 90                	xchg   %ax,%ax
  8022fe:	66 90                	xchg   %ax,%ax

00802300 <__udivdi3>:
  802300:	55                   	push   %ebp
  802301:	57                   	push   %edi
  802302:	56                   	push   %esi
  802303:	53                   	push   %ebx
  802304:	83 ec 1c             	sub    $0x1c,%esp
  802307:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80230b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80230f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802313:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802317:	85 f6                	test   %esi,%esi
  802319:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80231d:	89 ca                	mov    %ecx,%edx
  80231f:	89 f8                	mov    %edi,%eax
  802321:	75 3d                	jne    802360 <__udivdi3+0x60>
  802323:	39 cf                	cmp    %ecx,%edi
  802325:	0f 87 c5 00 00 00    	ja     8023f0 <__udivdi3+0xf0>
  80232b:	85 ff                	test   %edi,%edi
  80232d:	89 fd                	mov    %edi,%ebp
  80232f:	75 0b                	jne    80233c <__udivdi3+0x3c>
  802331:	b8 01 00 00 00       	mov    $0x1,%eax
  802336:	31 d2                	xor    %edx,%edx
  802338:	f7 f7                	div    %edi
  80233a:	89 c5                	mov    %eax,%ebp
  80233c:	89 c8                	mov    %ecx,%eax
  80233e:	31 d2                	xor    %edx,%edx
  802340:	f7 f5                	div    %ebp
  802342:	89 c1                	mov    %eax,%ecx
  802344:	89 d8                	mov    %ebx,%eax
  802346:	89 cf                	mov    %ecx,%edi
  802348:	f7 f5                	div    %ebp
  80234a:	89 c3                	mov    %eax,%ebx
  80234c:	89 d8                	mov    %ebx,%eax
  80234e:	89 fa                	mov    %edi,%edx
  802350:	83 c4 1c             	add    $0x1c,%esp
  802353:	5b                   	pop    %ebx
  802354:	5e                   	pop    %esi
  802355:	5f                   	pop    %edi
  802356:	5d                   	pop    %ebp
  802357:	c3                   	ret    
  802358:	90                   	nop
  802359:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802360:	39 ce                	cmp    %ecx,%esi
  802362:	77 74                	ja     8023d8 <__udivdi3+0xd8>
  802364:	0f bd fe             	bsr    %esi,%edi
  802367:	83 f7 1f             	xor    $0x1f,%edi
  80236a:	0f 84 98 00 00 00    	je     802408 <__udivdi3+0x108>
  802370:	bb 20 00 00 00       	mov    $0x20,%ebx
  802375:	89 f9                	mov    %edi,%ecx
  802377:	89 c5                	mov    %eax,%ebp
  802379:	29 fb                	sub    %edi,%ebx
  80237b:	d3 e6                	shl    %cl,%esi
  80237d:	89 d9                	mov    %ebx,%ecx
  80237f:	d3 ed                	shr    %cl,%ebp
  802381:	89 f9                	mov    %edi,%ecx
  802383:	d3 e0                	shl    %cl,%eax
  802385:	09 ee                	or     %ebp,%esi
  802387:	89 d9                	mov    %ebx,%ecx
  802389:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80238d:	89 d5                	mov    %edx,%ebp
  80238f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802393:	d3 ed                	shr    %cl,%ebp
  802395:	89 f9                	mov    %edi,%ecx
  802397:	d3 e2                	shl    %cl,%edx
  802399:	89 d9                	mov    %ebx,%ecx
  80239b:	d3 e8                	shr    %cl,%eax
  80239d:	09 c2                	or     %eax,%edx
  80239f:	89 d0                	mov    %edx,%eax
  8023a1:	89 ea                	mov    %ebp,%edx
  8023a3:	f7 f6                	div    %esi
  8023a5:	89 d5                	mov    %edx,%ebp
  8023a7:	89 c3                	mov    %eax,%ebx
  8023a9:	f7 64 24 0c          	mull   0xc(%esp)
  8023ad:	39 d5                	cmp    %edx,%ebp
  8023af:	72 10                	jb     8023c1 <__udivdi3+0xc1>
  8023b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8023b5:	89 f9                	mov    %edi,%ecx
  8023b7:	d3 e6                	shl    %cl,%esi
  8023b9:	39 c6                	cmp    %eax,%esi
  8023bb:	73 07                	jae    8023c4 <__udivdi3+0xc4>
  8023bd:	39 d5                	cmp    %edx,%ebp
  8023bf:	75 03                	jne    8023c4 <__udivdi3+0xc4>
  8023c1:	83 eb 01             	sub    $0x1,%ebx
  8023c4:	31 ff                	xor    %edi,%edi
  8023c6:	89 d8                	mov    %ebx,%eax
  8023c8:	89 fa                	mov    %edi,%edx
  8023ca:	83 c4 1c             	add    $0x1c,%esp
  8023cd:	5b                   	pop    %ebx
  8023ce:	5e                   	pop    %esi
  8023cf:	5f                   	pop    %edi
  8023d0:	5d                   	pop    %ebp
  8023d1:	c3                   	ret    
  8023d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023d8:	31 ff                	xor    %edi,%edi
  8023da:	31 db                	xor    %ebx,%ebx
  8023dc:	89 d8                	mov    %ebx,%eax
  8023de:	89 fa                	mov    %edi,%edx
  8023e0:	83 c4 1c             	add    $0x1c,%esp
  8023e3:	5b                   	pop    %ebx
  8023e4:	5e                   	pop    %esi
  8023e5:	5f                   	pop    %edi
  8023e6:	5d                   	pop    %ebp
  8023e7:	c3                   	ret    
  8023e8:	90                   	nop
  8023e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023f0:	89 d8                	mov    %ebx,%eax
  8023f2:	f7 f7                	div    %edi
  8023f4:	31 ff                	xor    %edi,%edi
  8023f6:	89 c3                	mov    %eax,%ebx
  8023f8:	89 d8                	mov    %ebx,%eax
  8023fa:	89 fa                	mov    %edi,%edx
  8023fc:	83 c4 1c             	add    $0x1c,%esp
  8023ff:	5b                   	pop    %ebx
  802400:	5e                   	pop    %esi
  802401:	5f                   	pop    %edi
  802402:	5d                   	pop    %ebp
  802403:	c3                   	ret    
  802404:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802408:	39 ce                	cmp    %ecx,%esi
  80240a:	72 0c                	jb     802418 <__udivdi3+0x118>
  80240c:	31 db                	xor    %ebx,%ebx
  80240e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802412:	0f 87 34 ff ff ff    	ja     80234c <__udivdi3+0x4c>
  802418:	bb 01 00 00 00       	mov    $0x1,%ebx
  80241d:	e9 2a ff ff ff       	jmp    80234c <__udivdi3+0x4c>
  802422:	66 90                	xchg   %ax,%ax
  802424:	66 90                	xchg   %ax,%ax
  802426:	66 90                	xchg   %ax,%ax
  802428:	66 90                	xchg   %ax,%ax
  80242a:	66 90                	xchg   %ax,%ax
  80242c:	66 90                	xchg   %ax,%ax
  80242e:	66 90                	xchg   %ax,%ax

00802430 <__umoddi3>:
  802430:	55                   	push   %ebp
  802431:	57                   	push   %edi
  802432:	56                   	push   %esi
  802433:	53                   	push   %ebx
  802434:	83 ec 1c             	sub    $0x1c,%esp
  802437:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80243b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80243f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802443:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802447:	85 d2                	test   %edx,%edx
  802449:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80244d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802451:	89 f3                	mov    %esi,%ebx
  802453:	89 3c 24             	mov    %edi,(%esp)
  802456:	89 74 24 04          	mov    %esi,0x4(%esp)
  80245a:	75 1c                	jne    802478 <__umoddi3+0x48>
  80245c:	39 f7                	cmp    %esi,%edi
  80245e:	76 50                	jbe    8024b0 <__umoddi3+0x80>
  802460:	89 c8                	mov    %ecx,%eax
  802462:	89 f2                	mov    %esi,%edx
  802464:	f7 f7                	div    %edi
  802466:	89 d0                	mov    %edx,%eax
  802468:	31 d2                	xor    %edx,%edx
  80246a:	83 c4 1c             	add    $0x1c,%esp
  80246d:	5b                   	pop    %ebx
  80246e:	5e                   	pop    %esi
  80246f:	5f                   	pop    %edi
  802470:	5d                   	pop    %ebp
  802471:	c3                   	ret    
  802472:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802478:	39 f2                	cmp    %esi,%edx
  80247a:	89 d0                	mov    %edx,%eax
  80247c:	77 52                	ja     8024d0 <__umoddi3+0xa0>
  80247e:	0f bd ea             	bsr    %edx,%ebp
  802481:	83 f5 1f             	xor    $0x1f,%ebp
  802484:	75 5a                	jne    8024e0 <__umoddi3+0xb0>
  802486:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80248a:	0f 82 e0 00 00 00    	jb     802570 <__umoddi3+0x140>
  802490:	39 0c 24             	cmp    %ecx,(%esp)
  802493:	0f 86 d7 00 00 00    	jbe    802570 <__umoddi3+0x140>
  802499:	8b 44 24 08          	mov    0x8(%esp),%eax
  80249d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024a1:	83 c4 1c             	add    $0x1c,%esp
  8024a4:	5b                   	pop    %ebx
  8024a5:	5e                   	pop    %esi
  8024a6:	5f                   	pop    %edi
  8024a7:	5d                   	pop    %ebp
  8024a8:	c3                   	ret    
  8024a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024b0:	85 ff                	test   %edi,%edi
  8024b2:	89 fd                	mov    %edi,%ebp
  8024b4:	75 0b                	jne    8024c1 <__umoddi3+0x91>
  8024b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024bb:	31 d2                	xor    %edx,%edx
  8024bd:	f7 f7                	div    %edi
  8024bf:	89 c5                	mov    %eax,%ebp
  8024c1:	89 f0                	mov    %esi,%eax
  8024c3:	31 d2                	xor    %edx,%edx
  8024c5:	f7 f5                	div    %ebp
  8024c7:	89 c8                	mov    %ecx,%eax
  8024c9:	f7 f5                	div    %ebp
  8024cb:	89 d0                	mov    %edx,%eax
  8024cd:	eb 99                	jmp    802468 <__umoddi3+0x38>
  8024cf:	90                   	nop
  8024d0:	89 c8                	mov    %ecx,%eax
  8024d2:	89 f2                	mov    %esi,%edx
  8024d4:	83 c4 1c             	add    $0x1c,%esp
  8024d7:	5b                   	pop    %ebx
  8024d8:	5e                   	pop    %esi
  8024d9:	5f                   	pop    %edi
  8024da:	5d                   	pop    %ebp
  8024db:	c3                   	ret    
  8024dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024e0:	8b 34 24             	mov    (%esp),%esi
  8024e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8024e8:	89 e9                	mov    %ebp,%ecx
  8024ea:	29 ef                	sub    %ebp,%edi
  8024ec:	d3 e0                	shl    %cl,%eax
  8024ee:	89 f9                	mov    %edi,%ecx
  8024f0:	89 f2                	mov    %esi,%edx
  8024f2:	d3 ea                	shr    %cl,%edx
  8024f4:	89 e9                	mov    %ebp,%ecx
  8024f6:	09 c2                	or     %eax,%edx
  8024f8:	89 d8                	mov    %ebx,%eax
  8024fa:	89 14 24             	mov    %edx,(%esp)
  8024fd:	89 f2                	mov    %esi,%edx
  8024ff:	d3 e2                	shl    %cl,%edx
  802501:	89 f9                	mov    %edi,%ecx
  802503:	89 54 24 04          	mov    %edx,0x4(%esp)
  802507:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80250b:	d3 e8                	shr    %cl,%eax
  80250d:	89 e9                	mov    %ebp,%ecx
  80250f:	89 c6                	mov    %eax,%esi
  802511:	d3 e3                	shl    %cl,%ebx
  802513:	89 f9                	mov    %edi,%ecx
  802515:	89 d0                	mov    %edx,%eax
  802517:	d3 e8                	shr    %cl,%eax
  802519:	89 e9                	mov    %ebp,%ecx
  80251b:	09 d8                	or     %ebx,%eax
  80251d:	89 d3                	mov    %edx,%ebx
  80251f:	89 f2                	mov    %esi,%edx
  802521:	f7 34 24             	divl   (%esp)
  802524:	89 d6                	mov    %edx,%esi
  802526:	d3 e3                	shl    %cl,%ebx
  802528:	f7 64 24 04          	mull   0x4(%esp)
  80252c:	39 d6                	cmp    %edx,%esi
  80252e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802532:	89 d1                	mov    %edx,%ecx
  802534:	89 c3                	mov    %eax,%ebx
  802536:	72 08                	jb     802540 <__umoddi3+0x110>
  802538:	75 11                	jne    80254b <__umoddi3+0x11b>
  80253a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80253e:	73 0b                	jae    80254b <__umoddi3+0x11b>
  802540:	2b 44 24 04          	sub    0x4(%esp),%eax
  802544:	1b 14 24             	sbb    (%esp),%edx
  802547:	89 d1                	mov    %edx,%ecx
  802549:	89 c3                	mov    %eax,%ebx
  80254b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80254f:	29 da                	sub    %ebx,%edx
  802551:	19 ce                	sbb    %ecx,%esi
  802553:	89 f9                	mov    %edi,%ecx
  802555:	89 f0                	mov    %esi,%eax
  802557:	d3 e0                	shl    %cl,%eax
  802559:	89 e9                	mov    %ebp,%ecx
  80255b:	d3 ea                	shr    %cl,%edx
  80255d:	89 e9                	mov    %ebp,%ecx
  80255f:	d3 ee                	shr    %cl,%esi
  802561:	09 d0                	or     %edx,%eax
  802563:	89 f2                	mov    %esi,%edx
  802565:	83 c4 1c             	add    $0x1c,%esp
  802568:	5b                   	pop    %ebx
  802569:	5e                   	pop    %esi
  80256a:	5f                   	pop    %edi
  80256b:	5d                   	pop    %ebp
  80256c:	c3                   	ret    
  80256d:	8d 76 00             	lea    0x0(%esi),%esi
  802570:	29 f9                	sub    %edi,%ecx
  802572:	19 d6                	sbb    %edx,%esi
  802574:	89 74 24 04          	mov    %esi,0x4(%esp)
  802578:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80257c:	e9 18 ff ff ff       	jmp    802499 <__umoddi3+0x69>
