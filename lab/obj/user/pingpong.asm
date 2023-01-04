
obj/user/pingpong.debug:     file format elf32-i386


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
  80002c:	e8 8d 00 00 00       	call   8000be <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 c2 0d 00 00       	call   800e03 <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 27                	je     80006f <umain+0x3c>
  800048:	89 c3                	mov    %eax,%ebx
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 ac 0a 00 00       	call   800afb <sys_getenvid>
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	53                   	push   %ebx
  800053:	50                   	push   %eax
  800054:	68 20 21 80 00       	push   $0x802120
  800059:	e8 53 01 00 00       	call   8001b1 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 b8 0f 00 00       	call   801024 <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 3e 0f 00 00       	call   800fbd <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 72 0a 00 00       	call   800afb <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 36 21 80 00       	push   $0x802136
  800091:	e8 1b 01 00 00       	call   8001b1 <cprintf>
		if (i == 10)
  800096:	83 c4 20             	add    $0x20,%esp
  800099:	83 fb 0a             	cmp    $0xa,%ebx
  80009c:	74 18                	je     8000b6 <umain+0x83>
			return;
		i++;
  80009e:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	53                   	push   %ebx
  8000a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a9:	e8 76 0f 00 00       	call   801024 <ipc_send>
		if (i == 10)
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	83 fb 0a             	cmp    $0xa,%ebx
  8000b4:	75 bc                	jne    800072 <umain+0x3f>
			return;
	}

}
  8000b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
  8000c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c9:	e8 2d 0a 00 00       	call   800afb <sys_getenvid>
  8000ce:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000db:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e0:	85 db                	test   %ebx,%ebx
  8000e2:	7e 07                	jle    8000eb <libmain+0x2d>
		binaryname = argv[0];
  8000e4:	8b 06                	mov    (%esi),%eax
  8000e6:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000eb:	83 ec 08             	sub    $0x8,%esp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	e8 3e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f5:	e8 0a 00 00 00       	call   800104 <exit>
}
  8000fa:	83 c4 10             	add    $0x10,%esp
  8000fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80010a:	e8 6d 11 00 00       	call   80127c <close_all>
	sys_env_destroy(0);
  80010f:	83 ec 0c             	sub    $0xc,%esp
  800112:	6a 00                	push   $0x0
  800114:	e8 a1 09 00 00       	call   800aba <sys_env_destroy>
}
  800119:	83 c4 10             	add    $0x10,%esp
  80011c:	c9                   	leave  
  80011d:	c3                   	ret    

0080011e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	53                   	push   %ebx
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800128:	8b 13                	mov    (%ebx),%edx
  80012a:	8d 42 01             	lea    0x1(%edx),%eax
  80012d:	89 03                	mov    %eax,(%ebx)
  80012f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800132:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800136:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013b:	75 1a                	jne    800157 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80013d:	83 ec 08             	sub    $0x8,%esp
  800140:	68 ff 00 00 00       	push   $0xff
  800145:	8d 43 08             	lea    0x8(%ebx),%eax
  800148:	50                   	push   %eax
  800149:	e8 2f 09 00 00       	call   800a7d <sys_cputs>
		b->idx = 0;
  80014e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800154:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800157:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800169:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800170:	00 00 00 
	b.cnt = 0;
  800173:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017d:	ff 75 0c             	pushl  0xc(%ebp)
  800180:	ff 75 08             	pushl  0x8(%ebp)
  800183:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800189:	50                   	push   %eax
  80018a:	68 1e 01 80 00       	push   $0x80011e
  80018f:	e8 54 01 00 00       	call   8002e8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800194:	83 c4 08             	add    $0x8,%esp
  800197:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80019d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a3:	50                   	push   %eax
  8001a4:	e8 d4 08 00 00       	call   800a7d <sys_cputs>

	return b.cnt;
}
  8001a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001af:	c9                   	leave  
  8001b0:	c3                   	ret    

008001b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ba:	50                   	push   %eax
  8001bb:	ff 75 08             	pushl  0x8(%ebp)
  8001be:	e8 9d ff ff ff       	call   800160 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    

008001c5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	57                   	push   %edi
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	83 ec 1c             	sub    $0x1c,%esp
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	89 d6                	mov    %edx,%esi
  8001d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001db:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001de:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ec:	39 d3                	cmp    %edx,%ebx
  8001ee:	72 05                	jb     8001f5 <printnum+0x30>
  8001f0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f3:	77 45                	ja     80023a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f5:	83 ec 0c             	sub    $0xc,%esp
  8001f8:	ff 75 18             	pushl  0x18(%ebp)
  8001fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8001fe:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800201:	53                   	push   %ebx
  800202:	ff 75 10             	pushl  0x10(%ebp)
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020b:	ff 75 e0             	pushl  -0x20(%ebp)
  80020e:	ff 75 dc             	pushl  -0x24(%ebp)
  800211:	ff 75 d8             	pushl  -0x28(%ebp)
  800214:	e8 67 1c 00 00       	call   801e80 <__udivdi3>
  800219:	83 c4 18             	add    $0x18,%esp
  80021c:	52                   	push   %edx
  80021d:	50                   	push   %eax
  80021e:	89 f2                	mov    %esi,%edx
  800220:	89 f8                	mov    %edi,%eax
  800222:	e8 9e ff ff ff       	call   8001c5 <printnum>
  800227:	83 c4 20             	add    $0x20,%esp
  80022a:	eb 18                	jmp    800244 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022c:	83 ec 08             	sub    $0x8,%esp
  80022f:	56                   	push   %esi
  800230:	ff 75 18             	pushl  0x18(%ebp)
  800233:	ff d7                	call   *%edi
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	eb 03                	jmp    80023d <printnum+0x78>
  80023a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023d:	83 eb 01             	sub    $0x1,%ebx
  800240:	85 db                	test   %ebx,%ebx
  800242:	7f e8                	jg     80022c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800244:	83 ec 08             	sub    $0x8,%esp
  800247:	56                   	push   %esi
  800248:	83 ec 04             	sub    $0x4,%esp
  80024b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024e:	ff 75 e0             	pushl  -0x20(%ebp)
  800251:	ff 75 dc             	pushl  -0x24(%ebp)
  800254:	ff 75 d8             	pushl  -0x28(%ebp)
  800257:	e8 54 1d 00 00       	call   801fb0 <__umoddi3>
  80025c:	83 c4 14             	add    $0x14,%esp
  80025f:	0f be 80 53 21 80 00 	movsbl 0x802153(%eax),%eax
  800266:	50                   	push   %eax
  800267:	ff d7                	call   *%edi
}
  800269:	83 c4 10             	add    $0x10,%esp
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800277:	83 fa 01             	cmp    $0x1,%edx
  80027a:	7e 0e                	jle    80028a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027c:	8b 10                	mov    (%eax),%edx
  80027e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800281:	89 08                	mov    %ecx,(%eax)
  800283:	8b 02                	mov    (%edx),%eax
  800285:	8b 52 04             	mov    0x4(%edx),%edx
  800288:	eb 22                	jmp    8002ac <getuint+0x38>
	else if (lflag)
  80028a:	85 d2                	test   %edx,%edx
  80028c:	74 10                	je     80029e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80028e:	8b 10                	mov    (%eax),%edx
  800290:	8d 4a 04             	lea    0x4(%edx),%ecx
  800293:	89 08                	mov    %ecx,(%eax)
  800295:	8b 02                	mov    (%edx),%eax
  800297:	ba 00 00 00 00       	mov    $0x0,%edx
  80029c:	eb 0e                	jmp    8002ac <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80029e:	8b 10                	mov    (%eax),%edx
  8002a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a3:	89 08                	mov    %ecx,(%eax)
  8002a5:	8b 02                	mov    (%edx),%eax
  8002a7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b8:	8b 10                	mov    (%eax),%edx
  8002ba:	3b 50 04             	cmp    0x4(%eax),%edx
  8002bd:	73 0a                	jae    8002c9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002bf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c2:	89 08                	mov    %ecx,(%eax)
  8002c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c7:	88 02                	mov    %al,(%edx)
}
  8002c9:	5d                   	pop    %ebp
  8002ca:	c3                   	ret    

008002cb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d4:	50                   	push   %eax
  8002d5:	ff 75 10             	pushl  0x10(%ebp)
  8002d8:	ff 75 0c             	pushl  0xc(%ebp)
  8002db:	ff 75 08             	pushl  0x8(%ebp)
  8002de:	e8 05 00 00 00       	call   8002e8 <vprintfmt>
	va_end(ap);
}
  8002e3:	83 c4 10             	add    $0x10,%esp
  8002e6:	c9                   	leave  
  8002e7:	c3                   	ret    

008002e8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	57                   	push   %edi
  8002ec:	56                   	push   %esi
  8002ed:	53                   	push   %ebx
  8002ee:	83 ec 2c             	sub    $0x2c,%esp
  8002f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002fa:	eb 12                	jmp    80030e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002fc:	85 c0                	test   %eax,%eax
  8002fe:	0f 84 89 03 00 00    	je     80068d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800304:	83 ec 08             	sub    $0x8,%esp
  800307:	53                   	push   %ebx
  800308:	50                   	push   %eax
  800309:	ff d6                	call   *%esi
  80030b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80030e:	83 c7 01             	add    $0x1,%edi
  800311:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800315:	83 f8 25             	cmp    $0x25,%eax
  800318:	75 e2                	jne    8002fc <vprintfmt+0x14>
  80031a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80031e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800325:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80032c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800333:	ba 00 00 00 00       	mov    $0x0,%edx
  800338:	eb 07                	jmp    800341 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80033d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800341:	8d 47 01             	lea    0x1(%edi),%eax
  800344:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800347:	0f b6 07             	movzbl (%edi),%eax
  80034a:	0f b6 c8             	movzbl %al,%ecx
  80034d:	83 e8 23             	sub    $0x23,%eax
  800350:	3c 55                	cmp    $0x55,%al
  800352:	0f 87 1a 03 00 00    	ja     800672 <vprintfmt+0x38a>
  800358:	0f b6 c0             	movzbl %al,%eax
  80035b:	ff 24 85 a0 22 80 00 	jmp    *0x8022a0(,%eax,4)
  800362:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800365:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800369:	eb d6                	jmp    800341 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80036e:	b8 00 00 00 00       	mov    $0x0,%eax
  800373:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800376:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800379:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80037d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800380:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800383:	83 fa 09             	cmp    $0x9,%edx
  800386:	77 39                	ja     8003c1 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800388:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80038b:	eb e9                	jmp    800376 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80038d:	8b 45 14             	mov    0x14(%ebp),%eax
  800390:	8d 48 04             	lea    0x4(%eax),%ecx
  800393:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800396:	8b 00                	mov    (%eax),%eax
  800398:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80039e:	eb 27                	jmp    8003c7 <vprintfmt+0xdf>
  8003a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a3:	85 c0                	test   %eax,%eax
  8003a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003aa:	0f 49 c8             	cmovns %eax,%ecx
  8003ad:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b3:	eb 8c                	jmp    800341 <vprintfmt+0x59>
  8003b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003b8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003bf:	eb 80                	jmp    800341 <vprintfmt+0x59>
  8003c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003c4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003c7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003cb:	0f 89 70 ff ff ff    	jns    800341 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003d1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003de:	e9 5e ff ff ff       	jmp    800341 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003e9:	e9 53 ff ff ff       	jmp    800341 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f1:	8d 50 04             	lea    0x4(%eax),%edx
  8003f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f7:	83 ec 08             	sub    $0x8,%esp
  8003fa:	53                   	push   %ebx
  8003fb:	ff 30                	pushl  (%eax)
  8003fd:	ff d6                	call   *%esi
			break;
  8003ff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800402:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800405:	e9 04 ff ff ff       	jmp    80030e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040a:	8b 45 14             	mov    0x14(%ebp),%eax
  80040d:	8d 50 04             	lea    0x4(%eax),%edx
  800410:	89 55 14             	mov    %edx,0x14(%ebp)
  800413:	8b 00                	mov    (%eax),%eax
  800415:	99                   	cltd   
  800416:	31 d0                	xor    %edx,%eax
  800418:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041a:	83 f8 0f             	cmp    $0xf,%eax
  80041d:	7f 0b                	jg     80042a <vprintfmt+0x142>
  80041f:	8b 14 85 00 24 80 00 	mov    0x802400(,%eax,4),%edx
  800426:	85 d2                	test   %edx,%edx
  800428:	75 18                	jne    800442 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80042a:	50                   	push   %eax
  80042b:	68 6b 21 80 00       	push   $0x80216b
  800430:	53                   	push   %ebx
  800431:	56                   	push   %esi
  800432:	e8 94 fe ff ff       	call   8002cb <printfmt>
  800437:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80043d:	e9 cc fe ff ff       	jmp    80030e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800442:	52                   	push   %edx
  800443:	68 fd 25 80 00       	push   $0x8025fd
  800448:	53                   	push   %ebx
  800449:	56                   	push   %esi
  80044a:	e8 7c fe ff ff       	call   8002cb <printfmt>
  80044f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800452:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800455:	e9 b4 fe ff ff       	jmp    80030e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80045a:	8b 45 14             	mov    0x14(%ebp),%eax
  80045d:	8d 50 04             	lea    0x4(%eax),%edx
  800460:	89 55 14             	mov    %edx,0x14(%ebp)
  800463:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800465:	85 ff                	test   %edi,%edi
  800467:	b8 64 21 80 00       	mov    $0x802164,%eax
  80046c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80046f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800473:	0f 8e 94 00 00 00    	jle    80050d <vprintfmt+0x225>
  800479:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80047d:	0f 84 98 00 00 00    	je     80051b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	ff 75 d0             	pushl  -0x30(%ebp)
  800489:	57                   	push   %edi
  80048a:	e8 86 02 00 00       	call   800715 <strnlen>
  80048f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800492:	29 c1                	sub    %eax,%ecx
  800494:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800497:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80049a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80049e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004a4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a6:	eb 0f                	jmp    8004b7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004a8:	83 ec 08             	sub    $0x8,%esp
  8004ab:	53                   	push   %ebx
  8004ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8004af:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b1:	83 ef 01             	sub    $0x1,%edi
  8004b4:	83 c4 10             	add    $0x10,%esp
  8004b7:	85 ff                	test   %edi,%edi
  8004b9:	7f ed                	jg     8004a8 <vprintfmt+0x1c0>
  8004bb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004be:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004c1:	85 c9                	test   %ecx,%ecx
  8004c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c8:	0f 49 c1             	cmovns %ecx,%eax
  8004cb:	29 c1                	sub    %eax,%ecx
  8004cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d6:	89 cb                	mov    %ecx,%ebx
  8004d8:	eb 4d                	jmp    800527 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004da:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004de:	74 1b                	je     8004fb <vprintfmt+0x213>
  8004e0:	0f be c0             	movsbl %al,%eax
  8004e3:	83 e8 20             	sub    $0x20,%eax
  8004e6:	83 f8 5e             	cmp    $0x5e,%eax
  8004e9:	76 10                	jbe    8004fb <vprintfmt+0x213>
					putch('?', putdat);
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	ff 75 0c             	pushl  0xc(%ebp)
  8004f1:	6a 3f                	push   $0x3f
  8004f3:	ff 55 08             	call   *0x8(%ebp)
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	eb 0d                	jmp    800508 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	ff 75 0c             	pushl  0xc(%ebp)
  800501:	52                   	push   %edx
  800502:	ff 55 08             	call   *0x8(%ebp)
  800505:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800508:	83 eb 01             	sub    $0x1,%ebx
  80050b:	eb 1a                	jmp    800527 <vprintfmt+0x23f>
  80050d:	89 75 08             	mov    %esi,0x8(%ebp)
  800510:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800513:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800516:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800519:	eb 0c                	jmp    800527 <vprintfmt+0x23f>
  80051b:	89 75 08             	mov    %esi,0x8(%ebp)
  80051e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800521:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800524:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800527:	83 c7 01             	add    $0x1,%edi
  80052a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80052e:	0f be d0             	movsbl %al,%edx
  800531:	85 d2                	test   %edx,%edx
  800533:	74 23                	je     800558 <vprintfmt+0x270>
  800535:	85 f6                	test   %esi,%esi
  800537:	78 a1                	js     8004da <vprintfmt+0x1f2>
  800539:	83 ee 01             	sub    $0x1,%esi
  80053c:	79 9c                	jns    8004da <vprintfmt+0x1f2>
  80053e:	89 df                	mov    %ebx,%edi
  800540:	8b 75 08             	mov    0x8(%ebp),%esi
  800543:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800546:	eb 18                	jmp    800560 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800548:	83 ec 08             	sub    $0x8,%esp
  80054b:	53                   	push   %ebx
  80054c:	6a 20                	push   $0x20
  80054e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800550:	83 ef 01             	sub    $0x1,%edi
  800553:	83 c4 10             	add    $0x10,%esp
  800556:	eb 08                	jmp    800560 <vprintfmt+0x278>
  800558:	89 df                	mov    %ebx,%edi
  80055a:	8b 75 08             	mov    0x8(%ebp),%esi
  80055d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800560:	85 ff                	test   %edi,%edi
  800562:	7f e4                	jg     800548 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800564:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800567:	e9 a2 fd ff ff       	jmp    80030e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056c:	83 fa 01             	cmp    $0x1,%edx
  80056f:	7e 16                	jle    800587 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 50 08             	lea    0x8(%eax),%edx
  800577:	89 55 14             	mov    %edx,0x14(%ebp)
  80057a:	8b 50 04             	mov    0x4(%eax),%edx
  80057d:	8b 00                	mov    (%eax),%eax
  80057f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800582:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800585:	eb 32                	jmp    8005b9 <vprintfmt+0x2d1>
	else if (lflag)
  800587:	85 d2                	test   %edx,%edx
  800589:	74 18                	je     8005a3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80058b:	8b 45 14             	mov    0x14(%ebp),%eax
  80058e:	8d 50 04             	lea    0x4(%eax),%edx
  800591:	89 55 14             	mov    %edx,0x14(%ebp)
  800594:	8b 00                	mov    (%eax),%eax
  800596:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800599:	89 c1                	mov    %eax,%ecx
  80059b:	c1 f9 1f             	sar    $0x1f,%ecx
  80059e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a1:	eb 16                	jmp    8005b9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8d 50 04             	lea    0x4(%eax),%edx
  8005a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ac:	8b 00                	mov    (%eax),%eax
  8005ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b1:	89 c1                	mov    %eax,%ecx
  8005b3:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005bc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005bf:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005c8:	79 74                	jns    80063e <vprintfmt+0x356>
				putch('-', putdat);
  8005ca:	83 ec 08             	sub    $0x8,%esp
  8005cd:	53                   	push   %ebx
  8005ce:	6a 2d                	push   $0x2d
  8005d0:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005d8:	f7 d8                	neg    %eax
  8005da:	83 d2 00             	adc    $0x0,%edx
  8005dd:	f7 da                	neg    %edx
  8005df:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005e2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005e7:	eb 55                	jmp    80063e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005e9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ec:	e8 83 fc ff ff       	call   800274 <getuint>
			base = 10;
  8005f1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005f6:	eb 46                	jmp    80063e <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8005f8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fb:	e8 74 fc ff ff       	call   800274 <getuint>
			base = 8;
  800600:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800605:	eb 37                	jmp    80063e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800607:	83 ec 08             	sub    $0x8,%esp
  80060a:	53                   	push   %ebx
  80060b:	6a 30                	push   $0x30
  80060d:	ff d6                	call   *%esi
			putch('x', putdat);
  80060f:	83 c4 08             	add    $0x8,%esp
  800612:	53                   	push   %ebx
  800613:	6a 78                	push   $0x78
  800615:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8d 50 04             	lea    0x4(%eax),%edx
  80061d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800620:	8b 00                	mov    (%eax),%eax
  800622:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800627:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80062a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80062f:	eb 0d                	jmp    80063e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800631:	8d 45 14             	lea    0x14(%ebp),%eax
  800634:	e8 3b fc ff ff       	call   800274 <getuint>
			base = 16;
  800639:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80063e:	83 ec 0c             	sub    $0xc,%esp
  800641:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800645:	57                   	push   %edi
  800646:	ff 75 e0             	pushl  -0x20(%ebp)
  800649:	51                   	push   %ecx
  80064a:	52                   	push   %edx
  80064b:	50                   	push   %eax
  80064c:	89 da                	mov    %ebx,%edx
  80064e:	89 f0                	mov    %esi,%eax
  800650:	e8 70 fb ff ff       	call   8001c5 <printnum>
			break;
  800655:	83 c4 20             	add    $0x20,%esp
  800658:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065b:	e9 ae fc ff ff       	jmp    80030e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800660:	83 ec 08             	sub    $0x8,%esp
  800663:	53                   	push   %ebx
  800664:	51                   	push   %ecx
  800665:	ff d6                	call   *%esi
			break;
  800667:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80066d:	e9 9c fc ff ff       	jmp    80030e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800672:	83 ec 08             	sub    $0x8,%esp
  800675:	53                   	push   %ebx
  800676:	6a 25                	push   $0x25
  800678:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80067a:	83 c4 10             	add    $0x10,%esp
  80067d:	eb 03                	jmp    800682 <vprintfmt+0x39a>
  80067f:	83 ef 01             	sub    $0x1,%edi
  800682:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800686:	75 f7                	jne    80067f <vprintfmt+0x397>
  800688:	e9 81 fc ff ff       	jmp    80030e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80068d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800690:	5b                   	pop    %ebx
  800691:	5e                   	pop    %esi
  800692:	5f                   	pop    %edi
  800693:	5d                   	pop    %ebp
  800694:	c3                   	ret    

00800695 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800695:	55                   	push   %ebp
  800696:	89 e5                	mov    %esp,%ebp
  800698:	83 ec 18             	sub    $0x18,%esp
  80069b:	8b 45 08             	mov    0x8(%ebp),%eax
  80069e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006a4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006a8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b2:	85 c0                	test   %eax,%eax
  8006b4:	74 26                	je     8006dc <vsnprintf+0x47>
  8006b6:	85 d2                	test   %edx,%edx
  8006b8:	7e 22                	jle    8006dc <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ba:	ff 75 14             	pushl  0x14(%ebp)
  8006bd:	ff 75 10             	pushl  0x10(%ebp)
  8006c0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c3:	50                   	push   %eax
  8006c4:	68 ae 02 80 00       	push   $0x8002ae
  8006c9:	e8 1a fc ff ff       	call   8002e8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d7:	83 c4 10             	add    $0x10,%esp
  8006da:	eb 05                	jmp    8006e1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e1:	c9                   	leave  
  8006e2:	c3                   	ret    

008006e3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e3:	55                   	push   %ebp
  8006e4:	89 e5                	mov    %esp,%ebp
  8006e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ec:	50                   	push   %eax
  8006ed:	ff 75 10             	pushl  0x10(%ebp)
  8006f0:	ff 75 0c             	pushl  0xc(%ebp)
  8006f3:	ff 75 08             	pushl  0x8(%ebp)
  8006f6:	e8 9a ff ff ff       	call   800695 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006fb:	c9                   	leave  
  8006fc:	c3                   	ret    

008006fd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
  800700:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800703:	b8 00 00 00 00       	mov    $0x0,%eax
  800708:	eb 03                	jmp    80070d <strlen+0x10>
		n++;
  80070a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80070d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800711:	75 f7                	jne    80070a <strlen+0xd>
		n++;
	return n;
}
  800713:	5d                   	pop    %ebp
  800714:	c3                   	ret    

00800715 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800715:	55                   	push   %ebp
  800716:	89 e5                	mov    %esp,%ebp
  800718:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80071b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80071e:	ba 00 00 00 00       	mov    $0x0,%edx
  800723:	eb 03                	jmp    800728 <strnlen+0x13>
		n++;
  800725:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800728:	39 c2                	cmp    %eax,%edx
  80072a:	74 08                	je     800734 <strnlen+0x1f>
  80072c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800730:	75 f3                	jne    800725 <strnlen+0x10>
  800732:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800734:	5d                   	pop    %ebp
  800735:	c3                   	ret    

00800736 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	53                   	push   %ebx
  80073a:	8b 45 08             	mov    0x8(%ebp),%eax
  80073d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800740:	89 c2                	mov    %eax,%edx
  800742:	83 c2 01             	add    $0x1,%edx
  800745:	83 c1 01             	add    $0x1,%ecx
  800748:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80074c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80074f:	84 db                	test   %bl,%bl
  800751:	75 ef                	jne    800742 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800753:	5b                   	pop    %ebx
  800754:	5d                   	pop    %ebp
  800755:	c3                   	ret    

00800756 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	53                   	push   %ebx
  80075a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80075d:	53                   	push   %ebx
  80075e:	e8 9a ff ff ff       	call   8006fd <strlen>
  800763:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800766:	ff 75 0c             	pushl  0xc(%ebp)
  800769:	01 d8                	add    %ebx,%eax
  80076b:	50                   	push   %eax
  80076c:	e8 c5 ff ff ff       	call   800736 <strcpy>
	return dst;
}
  800771:	89 d8                	mov    %ebx,%eax
  800773:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800776:	c9                   	leave  
  800777:	c3                   	ret    

00800778 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	56                   	push   %esi
  80077c:	53                   	push   %ebx
  80077d:	8b 75 08             	mov    0x8(%ebp),%esi
  800780:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800783:	89 f3                	mov    %esi,%ebx
  800785:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800788:	89 f2                	mov    %esi,%edx
  80078a:	eb 0f                	jmp    80079b <strncpy+0x23>
		*dst++ = *src;
  80078c:	83 c2 01             	add    $0x1,%edx
  80078f:	0f b6 01             	movzbl (%ecx),%eax
  800792:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800795:	80 39 01             	cmpb   $0x1,(%ecx)
  800798:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079b:	39 da                	cmp    %ebx,%edx
  80079d:	75 ed                	jne    80078c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80079f:	89 f0                	mov    %esi,%eax
  8007a1:	5b                   	pop    %ebx
  8007a2:	5e                   	pop    %esi
  8007a3:	5d                   	pop    %ebp
  8007a4:	c3                   	ret    

008007a5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	56                   	push   %esi
  8007a9:	53                   	push   %ebx
  8007aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b0:	8b 55 10             	mov    0x10(%ebp),%edx
  8007b3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b5:	85 d2                	test   %edx,%edx
  8007b7:	74 21                	je     8007da <strlcpy+0x35>
  8007b9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007bd:	89 f2                	mov    %esi,%edx
  8007bf:	eb 09                	jmp    8007ca <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c1:	83 c2 01             	add    $0x1,%edx
  8007c4:	83 c1 01             	add    $0x1,%ecx
  8007c7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ca:	39 c2                	cmp    %eax,%edx
  8007cc:	74 09                	je     8007d7 <strlcpy+0x32>
  8007ce:	0f b6 19             	movzbl (%ecx),%ebx
  8007d1:	84 db                	test   %bl,%bl
  8007d3:	75 ec                	jne    8007c1 <strlcpy+0x1c>
  8007d5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007d7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007da:	29 f0                	sub    %esi,%eax
}
  8007dc:	5b                   	pop    %ebx
  8007dd:	5e                   	pop    %esi
  8007de:	5d                   	pop    %ebp
  8007df:	c3                   	ret    

008007e0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007e9:	eb 06                	jmp    8007f1 <strcmp+0x11>
		p++, q++;
  8007eb:	83 c1 01             	add    $0x1,%ecx
  8007ee:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f1:	0f b6 01             	movzbl (%ecx),%eax
  8007f4:	84 c0                	test   %al,%al
  8007f6:	74 04                	je     8007fc <strcmp+0x1c>
  8007f8:	3a 02                	cmp    (%edx),%al
  8007fa:	74 ef                	je     8007eb <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fc:	0f b6 c0             	movzbl %al,%eax
  8007ff:	0f b6 12             	movzbl (%edx),%edx
  800802:	29 d0                	sub    %edx,%eax
}
  800804:	5d                   	pop    %ebp
  800805:	c3                   	ret    

00800806 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	53                   	push   %ebx
  80080a:	8b 45 08             	mov    0x8(%ebp),%eax
  80080d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800810:	89 c3                	mov    %eax,%ebx
  800812:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800815:	eb 06                	jmp    80081d <strncmp+0x17>
		n--, p++, q++;
  800817:	83 c0 01             	add    $0x1,%eax
  80081a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80081d:	39 d8                	cmp    %ebx,%eax
  80081f:	74 15                	je     800836 <strncmp+0x30>
  800821:	0f b6 08             	movzbl (%eax),%ecx
  800824:	84 c9                	test   %cl,%cl
  800826:	74 04                	je     80082c <strncmp+0x26>
  800828:	3a 0a                	cmp    (%edx),%cl
  80082a:	74 eb                	je     800817 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082c:	0f b6 00             	movzbl (%eax),%eax
  80082f:	0f b6 12             	movzbl (%edx),%edx
  800832:	29 d0                	sub    %edx,%eax
  800834:	eb 05                	jmp    80083b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800836:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80083b:	5b                   	pop    %ebx
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	8b 45 08             	mov    0x8(%ebp),%eax
  800844:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800848:	eb 07                	jmp    800851 <strchr+0x13>
		if (*s == c)
  80084a:	38 ca                	cmp    %cl,%dl
  80084c:	74 0f                	je     80085d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80084e:	83 c0 01             	add    $0x1,%eax
  800851:	0f b6 10             	movzbl (%eax),%edx
  800854:	84 d2                	test   %dl,%dl
  800856:	75 f2                	jne    80084a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800858:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	8b 45 08             	mov    0x8(%ebp),%eax
  800865:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800869:	eb 03                	jmp    80086e <strfind+0xf>
  80086b:	83 c0 01             	add    $0x1,%eax
  80086e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800871:	38 ca                	cmp    %cl,%dl
  800873:	74 04                	je     800879 <strfind+0x1a>
  800875:	84 d2                	test   %dl,%dl
  800877:	75 f2                	jne    80086b <strfind+0xc>
			break;
	return (char *) s;
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	57                   	push   %edi
  80087f:	56                   	push   %esi
  800880:	53                   	push   %ebx
  800881:	8b 7d 08             	mov    0x8(%ebp),%edi
  800884:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800887:	85 c9                	test   %ecx,%ecx
  800889:	74 36                	je     8008c1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80088b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800891:	75 28                	jne    8008bb <memset+0x40>
  800893:	f6 c1 03             	test   $0x3,%cl
  800896:	75 23                	jne    8008bb <memset+0x40>
		c &= 0xFF;
  800898:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80089c:	89 d3                	mov    %edx,%ebx
  80089e:	c1 e3 08             	shl    $0x8,%ebx
  8008a1:	89 d6                	mov    %edx,%esi
  8008a3:	c1 e6 18             	shl    $0x18,%esi
  8008a6:	89 d0                	mov    %edx,%eax
  8008a8:	c1 e0 10             	shl    $0x10,%eax
  8008ab:	09 f0                	or     %esi,%eax
  8008ad:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008af:	89 d8                	mov    %ebx,%eax
  8008b1:	09 d0                	or     %edx,%eax
  8008b3:	c1 e9 02             	shr    $0x2,%ecx
  8008b6:	fc                   	cld    
  8008b7:	f3 ab                	rep stos %eax,%es:(%edi)
  8008b9:	eb 06                	jmp    8008c1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008be:	fc                   	cld    
  8008bf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c1:	89 f8                	mov    %edi,%eax
  8008c3:	5b                   	pop    %ebx
  8008c4:	5e                   	pop    %esi
  8008c5:	5f                   	pop    %edi
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    

008008c8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	57                   	push   %edi
  8008cc:	56                   	push   %esi
  8008cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d6:	39 c6                	cmp    %eax,%esi
  8008d8:	73 35                	jae    80090f <memmove+0x47>
  8008da:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008dd:	39 d0                	cmp    %edx,%eax
  8008df:	73 2e                	jae    80090f <memmove+0x47>
		s += n;
		d += n;
  8008e1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e4:	89 d6                	mov    %edx,%esi
  8008e6:	09 fe                	or     %edi,%esi
  8008e8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ee:	75 13                	jne    800903 <memmove+0x3b>
  8008f0:	f6 c1 03             	test   $0x3,%cl
  8008f3:	75 0e                	jne    800903 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008f5:	83 ef 04             	sub    $0x4,%edi
  8008f8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008fb:	c1 e9 02             	shr    $0x2,%ecx
  8008fe:	fd                   	std    
  8008ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800901:	eb 09                	jmp    80090c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800903:	83 ef 01             	sub    $0x1,%edi
  800906:	8d 72 ff             	lea    -0x1(%edx),%esi
  800909:	fd                   	std    
  80090a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80090c:	fc                   	cld    
  80090d:	eb 1d                	jmp    80092c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090f:	89 f2                	mov    %esi,%edx
  800911:	09 c2                	or     %eax,%edx
  800913:	f6 c2 03             	test   $0x3,%dl
  800916:	75 0f                	jne    800927 <memmove+0x5f>
  800918:	f6 c1 03             	test   $0x3,%cl
  80091b:	75 0a                	jne    800927 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80091d:	c1 e9 02             	shr    $0x2,%ecx
  800920:	89 c7                	mov    %eax,%edi
  800922:	fc                   	cld    
  800923:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800925:	eb 05                	jmp    80092c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800927:	89 c7                	mov    %eax,%edi
  800929:	fc                   	cld    
  80092a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80092c:	5e                   	pop    %esi
  80092d:	5f                   	pop    %edi
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    

00800930 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800933:	ff 75 10             	pushl  0x10(%ebp)
  800936:	ff 75 0c             	pushl  0xc(%ebp)
  800939:	ff 75 08             	pushl  0x8(%ebp)
  80093c:	e8 87 ff ff ff       	call   8008c8 <memmove>
}
  800941:	c9                   	leave  
  800942:	c3                   	ret    

00800943 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	56                   	push   %esi
  800947:	53                   	push   %ebx
  800948:	8b 45 08             	mov    0x8(%ebp),%eax
  80094b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094e:	89 c6                	mov    %eax,%esi
  800950:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800953:	eb 1a                	jmp    80096f <memcmp+0x2c>
		if (*s1 != *s2)
  800955:	0f b6 08             	movzbl (%eax),%ecx
  800958:	0f b6 1a             	movzbl (%edx),%ebx
  80095b:	38 d9                	cmp    %bl,%cl
  80095d:	74 0a                	je     800969 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80095f:	0f b6 c1             	movzbl %cl,%eax
  800962:	0f b6 db             	movzbl %bl,%ebx
  800965:	29 d8                	sub    %ebx,%eax
  800967:	eb 0f                	jmp    800978 <memcmp+0x35>
		s1++, s2++;
  800969:	83 c0 01             	add    $0x1,%eax
  80096c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80096f:	39 f0                	cmp    %esi,%eax
  800971:	75 e2                	jne    800955 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800973:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800978:	5b                   	pop    %ebx
  800979:	5e                   	pop    %esi
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	53                   	push   %ebx
  800980:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800983:	89 c1                	mov    %eax,%ecx
  800985:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800988:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80098c:	eb 0a                	jmp    800998 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80098e:	0f b6 10             	movzbl (%eax),%edx
  800991:	39 da                	cmp    %ebx,%edx
  800993:	74 07                	je     80099c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800995:	83 c0 01             	add    $0x1,%eax
  800998:	39 c8                	cmp    %ecx,%eax
  80099a:	72 f2                	jb     80098e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80099c:	5b                   	pop    %ebx
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	57                   	push   %edi
  8009a3:	56                   	push   %esi
  8009a4:	53                   	push   %ebx
  8009a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ab:	eb 03                	jmp    8009b0 <strtol+0x11>
		s++;
  8009ad:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b0:	0f b6 01             	movzbl (%ecx),%eax
  8009b3:	3c 20                	cmp    $0x20,%al
  8009b5:	74 f6                	je     8009ad <strtol+0xe>
  8009b7:	3c 09                	cmp    $0x9,%al
  8009b9:	74 f2                	je     8009ad <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009bb:	3c 2b                	cmp    $0x2b,%al
  8009bd:	75 0a                	jne    8009c9 <strtol+0x2a>
		s++;
  8009bf:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c2:	bf 00 00 00 00       	mov    $0x0,%edi
  8009c7:	eb 11                	jmp    8009da <strtol+0x3b>
  8009c9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009ce:	3c 2d                	cmp    $0x2d,%al
  8009d0:	75 08                	jne    8009da <strtol+0x3b>
		s++, neg = 1;
  8009d2:	83 c1 01             	add    $0x1,%ecx
  8009d5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009da:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e0:	75 15                	jne    8009f7 <strtol+0x58>
  8009e2:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e5:	75 10                	jne    8009f7 <strtol+0x58>
  8009e7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009eb:	75 7c                	jne    800a69 <strtol+0xca>
		s += 2, base = 16;
  8009ed:	83 c1 02             	add    $0x2,%ecx
  8009f0:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f5:	eb 16                	jmp    800a0d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009f7:	85 db                	test   %ebx,%ebx
  8009f9:	75 12                	jne    800a0d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009fb:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a00:	80 39 30             	cmpb   $0x30,(%ecx)
  800a03:	75 08                	jne    800a0d <strtol+0x6e>
		s++, base = 8;
  800a05:	83 c1 01             	add    $0x1,%ecx
  800a08:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a12:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a15:	0f b6 11             	movzbl (%ecx),%edx
  800a18:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a1b:	89 f3                	mov    %esi,%ebx
  800a1d:	80 fb 09             	cmp    $0x9,%bl
  800a20:	77 08                	ja     800a2a <strtol+0x8b>
			dig = *s - '0';
  800a22:	0f be d2             	movsbl %dl,%edx
  800a25:	83 ea 30             	sub    $0x30,%edx
  800a28:	eb 22                	jmp    800a4c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a2a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a2d:	89 f3                	mov    %esi,%ebx
  800a2f:	80 fb 19             	cmp    $0x19,%bl
  800a32:	77 08                	ja     800a3c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a34:	0f be d2             	movsbl %dl,%edx
  800a37:	83 ea 57             	sub    $0x57,%edx
  800a3a:	eb 10                	jmp    800a4c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a3c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a3f:	89 f3                	mov    %esi,%ebx
  800a41:	80 fb 19             	cmp    $0x19,%bl
  800a44:	77 16                	ja     800a5c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a46:	0f be d2             	movsbl %dl,%edx
  800a49:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a4c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a4f:	7d 0b                	jge    800a5c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a51:	83 c1 01             	add    $0x1,%ecx
  800a54:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a58:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a5a:	eb b9                	jmp    800a15 <strtol+0x76>

	if (endptr)
  800a5c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a60:	74 0d                	je     800a6f <strtol+0xd0>
		*endptr = (char *) s;
  800a62:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a65:	89 0e                	mov    %ecx,(%esi)
  800a67:	eb 06                	jmp    800a6f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a69:	85 db                	test   %ebx,%ebx
  800a6b:	74 98                	je     800a05 <strtol+0x66>
  800a6d:	eb 9e                	jmp    800a0d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a6f:	89 c2                	mov    %eax,%edx
  800a71:	f7 da                	neg    %edx
  800a73:	85 ff                	test   %edi,%edi
  800a75:	0f 45 c2             	cmovne %edx,%eax
}
  800a78:	5b                   	pop    %ebx
  800a79:	5e                   	pop    %esi
  800a7a:	5f                   	pop    %edi
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	57                   	push   %edi
  800a81:	56                   	push   %esi
  800a82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a83:	b8 00 00 00 00       	mov    $0x0,%eax
  800a88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8e:	89 c3                	mov    %eax,%ebx
  800a90:	89 c7                	mov    %eax,%edi
  800a92:	89 c6                	mov    %eax,%esi
  800a94:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a96:	5b                   	pop    %ebx
  800a97:	5e                   	pop    %esi
  800a98:	5f                   	pop    %edi
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <sys_cgetc>:

int
sys_cgetc(void)
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
  800aa6:	b8 01 00 00 00       	mov    $0x1,%eax
  800aab:	89 d1                	mov    %edx,%ecx
  800aad:	89 d3                	mov    %edx,%ebx
  800aaf:	89 d7                	mov    %edx,%edi
  800ab1:	89 d6                	mov    %edx,%esi
  800ab3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ab5:	5b                   	pop    %ebx
  800ab6:	5e                   	pop    %esi
  800ab7:	5f                   	pop    %edi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	57                   	push   %edi
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
  800ac0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ac8:	b8 03 00 00 00       	mov    $0x3,%eax
  800acd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad0:	89 cb                	mov    %ecx,%ebx
  800ad2:	89 cf                	mov    %ecx,%edi
  800ad4:	89 ce                	mov    %ecx,%esi
  800ad6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ad8:	85 c0                	test   %eax,%eax
  800ada:	7e 17                	jle    800af3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800adc:	83 ec 0c             	sub    $0xc,%esp
  800adf:	50                   	push   %eax
  800ae0:	6a 03                	push   $0x3
  800ae2:	68 5f 24 80 00       	push   $0x80245f
  800ae7:	6a 23                	push   $0x23
  800ae9:	68 7c 24 80 00       	push   $0x80247c
  800aee:	e8 9b 12 00 00       	call   801d8e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800af3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	57                   	push   %edi
  800aff:	56                   	push   %esi
  800b00:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b01:	ba 00 00 00 00       	mov    $0x0,%edx
  800b06:	b8 02 00 00 00       	mov    $0x2,%eax
  800b0b:	89 d1                	mov    %edx,%ecx
  800b0d:	89 d3                	mov    %edx,%ebx
  800b0f:	89 d7                	mov    %edx,%edi
  800b11:	89 d6                	mov    %edx,%esi
  800b13:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <sys_yield>:

void
sys_yield(void)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	57                   	push   %edi
  800b1e:	56                   	push   %esi
  800b1f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b20:	ba 00 00 00 00       	mov    $0x0,%edx
  800b25:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b2a:	89 d1                	mov    %edx,%ecx
  800b2c:	89 d3                	mov    %edx,%ebx
  800b2e:	89 d7                	mov    %edx,%edi
  800b30:	89 d6                	mov    %edx,%esi
  800b32:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
  800b3f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b42:	be 00 00 00 00       	mov    $0x0,%esi
  800b47:	b8 04 00 00 00       	mov    $0x4,%eax
  800b4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b52:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b55:	89 f7                	mov    %esi,%edi
  800b57:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b59:	85 c0                	test   %eax,%eax
  800b5b:	7e 17                	jle    800b74 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5d:	83 ec 0c             	sub    $0xc,%esp
  800b60:	50                   	push   %eax
  800b61:	6a 04                	push   $0x4
  800b63:	68 5f 24 80 00       	push   $0x80245f
  800b68:	6a 23                	push   $0x23
  800b6a:	68 7c 24 80 00       	push   $0x80247c
  800b6f:	e8 1a 12 00 00       	call   801d8e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b77:	5b                   	pop    %ebx
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
  800b82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b85:	b8 05 00 00 00       	mov    $0x5,%eax
  800b8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b90:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b93:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b96:	8b 75 18             	mov    0x18(%ebp),%esi
  800b99:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9b:	85 c0                	test   %eax,%eax
  800b9d:	7e 17                	jle    800bb6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9f:	83 ec 0c             	sub    $0xc,%esp
  800ba2:	50                   	push   %eax
  800ba3:	6a 05                	push   $0x5
  800ba5:	68 5f 24 80 00       	push   $0x80245f
  800baa:	6a 23                	push   $0x23
  800bac:	68 7c 24 80 00       	push   $0x80247c
  800bb1:	e8 d8 11 00 00       	call   801d8e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
  800bc4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bcc:	b8 06 00 00 00       	mov    $0x6,%eax
  800bd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd7:	89 df                	mov    %ebx,%edi
  800bd9:	89 de                	mov    %ebx,%esi
  800bdb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bdd:	85 c0                	test   %eax,%eax
  800bdf:	7e 17                	jle    800bf8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be1:	83 ec 0c             	sub    $0xc,%esp
  800be4:	50                   	push   %eax
  800be5:	6a 06                	push   $0x6
  800be7:	68 5f 24 80 00       	push   $0x80245f
  800bec:	6a 23                	push   $0x23
  800bee:	68 7c 24 80 00       	push   $0x80247c
  800bf3:	e8 96 11 00 00       	call   801d8e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfb:	5b                   	pop    %ebx
  800bfc:	5e                   	pop    %esi
  800bfd:	5f                   	pop    %edi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	57                   	push   %edi
  800c04:	56                   	push   %esi
  800c05:	53                   	push   %ebx
  800c06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0e:	b8 08 00 00 00       	mov    $0x8,%eax
  800c13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c16:	8b 55 08             	mov    0x8(%ebp),%edx
  800c19:	89 df                	mov    %ebx,%edi
  800c1b:	89 de                	mov    %ebx,%esi
  800c1d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1f:	85 c0                	test   %eax,%eax
  800c21:	7e 17                	jle    800c3a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c23:	83 ec 0c             	sub    $0xc,%esp
  800c26:	50                   	push   %eax
  800c27:	6a 08                	push   $0x8
  800c29:	68 5f 24 80 00       	push   $0x80245f
  800c2e:	6a 23                	push   $0x23
  800c30:	68 7c 24 80 00       	push   $0x80247c
  800c35:	e8 54 11 00 00       	call   801d8e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5f                   	pop    %edi
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    

00800c42 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c50:	b8 09 00 00 00       	mov    $0x9,%eax
  800c55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c58:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5b:	89 df                	mov    %ebx,%edi
  800c5d:	89 de                	mov    %ebx,%esi
  800c5f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c61:	85 c0                	test   %eax,%eax
  800c63:	7e 17                	jle    800c7c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c65:	83 ec 0c             	sub    $0xc,%esp
  800c68:	50                   	push   %eax
  800c69:	6a 09                	push   $0x9
  800c6b:	68 5f 24 80 00       	push   $0x80245f
  800c70:	6a 23                	push   $0x23
  800c72:	68 7c 24 80 00       	push   $0x80247c
  800c77:	e8 12 11 00 00       	call   801d8e <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	53                   	push   %ebx
  800c8a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c92:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9d:	89 df                	mov    %ebx,%edi
  800c9f:	89 de                	mov    %ebx,%esi
  800ca1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	7e 17                	jle    800cbe <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca7:	83 ec 0c             	sub    $0xc,%esp
  800caa:	50                   	push   %eax
  800cab:	6a 0a                	push   $0xa
  800cad:	68 5f 24 80 00       	push   $0x80245f
  800cb2:	6a 23                	push   $0x23
  800cb4:	68 7c 24 80 00       	push   $0x80247c
  800cb9:	e8 d0 10 00 00       	call   801d8e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccc:	be 00 00 00 00       	mov    $0x0,%esi
  800cd1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800cf2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cff:	89 cb                	mov    %ecx,%ebx
  800d01:	89 cf                	mov    %ecx,%edi
  800d03:	89 ce                	mov    %ecx,%esi
  800d05:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d07:	85 c0                	test   %eax,%eax
  800d09:	7e 17                	jle    800d22 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0b:	83 ec 0c             	sub    $0xc,%esp
  800d0e:	50                   	push   %eax
  800d0f:	6a 0d                	push   $0xd
  800d11:	68 5f 24 80 00       	push   $0x80245f
  800d16:	6a 23                	push   $0x23
  800d18:	68 7c 24 80 00       	push   $0x80247c
  800d1d:	e8 6c 10 00 00       	call   801d8e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
  800d2f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d32:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800d34:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d38:	75 25                	jne    800d5f <pgfault+0x35>
  800d3a:	89 d8                	mov    %ebx,%eax
  800d3c:	c1 e8 0c             	shr    $0xc,%eax
  800d3f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d46:	f6 c4 08             	test   $0x8,%ah
  800d49:	75 14                	jne    800d5f <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800d4b:	83 ec 04             	sub    $0x4,%esp
  800d4e:	68 8c 24 80 00       	push   $0x80248c
  800d53:	6a 1e                	push   $0x1e
  800d55:	68 20 25 80 00       	push   $0x802520
  800d5a:	e8 2f 10 00 00       	call   801d8e <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800d5f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800d65:	e8 91 fd ff ff       	call   800afb <sys_getenvid>
  800d6a:	89 c6                	mov    %eax,%esi

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800d6c:	83 ec 04             	sub    $0x4,%esp
  800d6f:	6a 07                	push   $0x7
  800d71:	68 00 f0 7f 00       	push   $0x7ff000
  800d76:	50                   	push   %eax
  800d77:	e8 bd fd ff ff       	call   800b39 <sys_page_alloc>
	if (r < 0)
  800d7c:	83 c4 10             	add    $0x10,%esp
  800d7f:	85 c0                	test   %eax,%eax
  800d81:	79 12                	jns    800d95 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800d83:	50                   	push   %eax
  800d84:	68 b8 24 80 00       	push   $0x8024b8
  800d89:	6a 31                	push   $0x31
  800d8b:	68 20 25 80 00       	push   $0x802520
  800d90:	e8 f9 0f 00 00       	call   801d8e <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800d95:	83 ec 04             	sub    $0x4,%esp
  800d98:	68 00 10 00 00       	push   $0x1000
  800d9d:	53                   	push   %ebx
  800d9e:	68 00 f0 7f 00       	push   $0x7ff000
  800da3:	e8 88 fb ff ff       	call   800930 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800da8:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800daf:	53                   	push   %ebx
  800db0:	56                   	push   %esi
  800db1:	68 00 f0 7f 00       	push   $0x7ff000
  800db6:	56                   	push   %esi
  800db7:	e8 c0 fd ff ff       	call   800b7c <sys_page_map>
	if (r < 0)
  800dbc:	83 c4 20             	add    $0x20,%esp
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	79 12                	jns    800dd5 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800dc3:	50                   	push   %eax
  800dc4:	68 dc 24 80 00       	push   $0x8024dc
  800dc9:	6a 39                	push   $0x39
  800dcb:	68 20 25 80 00       	push   $0x802520
  800dd0:	e8 b9 0f 00 00       	call   801d8e <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800dd5:	83 ec 08             	sub    $0x8,%esp
  800dd8:	68 00 f0 7f 00       	push   $0x7ff000
  800ddd:	56                   	push   %esi
  800dde:	e8 db fd ff ff       	call   800bbe <sys_page_unmap>
	if (r < 0)
  800de3:	83 c4 10             	add    $0x10,%esp
  800de6:	85 c0                	test   %eax,%eax
  800de8:	79 12                	jns    800dfc <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800dea:	50                   	push   %eax
  800deb:	68 00 25 80 00       	push   $0x802500
  800df0:	6a 3e                	push   $0x3e
  800df2:	68 20 25 80 00       	push   $0x802520
  800df7:	e8 92 0f 00 00       	call   801d8e <_panic>
}
  800dfc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800dff:	5b                   	pop    %ebx
  800e00:	5e                   	pop    %esi
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    

00800e03 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
  800e06:	57                   	push   %edi
  800e07:	56                   	push   %esi
  800e08:	53                   	push   %ebx
  800e09:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800e0c:	68 2a 0d 80 00       	push   $0x800d2a
  800e11:	e8 be 0f 00 00       	call   801dd4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e16:	b8 07 00 00 00       	mov    $0x7,%eax
  800e1b:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800e1d:	83 c4 10             	add    $0x10,%esp
  800e20:	85 c0                	test   %eax,%eax
  800e22:	0f 88 67 01 00 00    	js     800f8f <fork+0x18c>
  800e28:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800e2d:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800e32:	85 c0                	test   %eax,%eax
  800e34:	75 21                	jne    800e57 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e36:	e8 c0 fc ff ff       	call   800afb <sys_getenvid>
  800e3b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e40:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e43:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e48:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  800e4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e52:	e9 42 01 00 00       	jmp    800f99 <fork+0x196>
  800e57:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e5a:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800e5c:	89 d8                	mov    %ebx,%eax
  800e5e:	c1 e8 16             	shr    $0x16,%eax
  800e61:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e68:	a8 01                	test   $0x1,%al
  800e6a:	0f 84 c0 00 00 00    	je     800f30 <fork+0x12d>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800e70:	89 d8                	mov    %ebx,%eax
  800e72:	c1 e8 0c             	shr    $0xc,%eax
  800e75:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e7c:	f6 c2 01             	test   $0x1,%dl
  800e7f:	0f 84 ab 00 00 00    	je     800f30 <fork+0x12d>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
  800e85:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e8c:	a9 02 08 00 00       	test   $0x802,%eax
  800e91:	0f 84 99 00 00 00    	je     800f30 <fork+0x12d>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800e97:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800e9e:	f6 c4 04             	test   $0x4,%ah
  800ea1:	74 17                	je     800eba <fork+0xb7>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800ea3:	83 ec 0c             	sub    $0xc,%esp
  800ea6:	68 07 0e 00 00       	push   $0xe07
  800eab:	53                   	push   %ebx
  800eac:	57                   	push   %edi
  800ead:	53                   	push   %ebx
  800eae:	6a 00                	push   $0x0
  800eb0:	e8 c7 fc ff ff       	call   800b7c <sys_page_map>
  800eb5:	83 c4 20             	add    $0x20,%esp
  800eb8:	eb 76                	jmp    800f30 <fork+0x12d>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800eba:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ec1:	a8 02                	test   $0x2,%al
  800ec3:	75 0c                	jne    800ed1 <fork+0xce>
  800ec5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ecc:	f6 c4 08             	test   $0x8,%ah
  800ecf:	74 3f                	je     800f10 <fork+0x10d>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800ed1:	83 ec 0c             	sub    $0xc,%esp
  800ed4:	68 05 08 00 00       	push   $0x805
  800ed9:	53                   	push   %ebx
  800eda:	57                   	push   %edi
  800edb:	53                   	push   %ebx
  800edc:	6a 00                	push   $0x0
  800ede:	e8 99 fc ff ff       	call   800b7c <sys_page_map>
		if (r < 0)
  800ee3:	83 c4 20             	add    $0x20,%esp
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	0f 88 a5 00 00 00    	js     800f93 <fork+0x190>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800eee:	83 ec 0c             	sub    $0xc,%esp
  800ef1:	68 05 08 00 00       	push   $0x805
  800ef6:	53                   	push   %ebx
  800ef7:	6a 00                	push   $0x0
  800ef9:	53                   	push   %ebx
  800efa:	6a 00                	push   $0x0
  800efc:	e8 7b fc ff ff       	call   800b7c <sys_page_map>
  800f01:	83 c4 20             	add    $0x20,%esp
  800f04:	85 c0                	test   %eax,%eax
  800f06:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f0b:	0f 4f c1             	cmovg  %ecx,%eax
  800f0e:	eb 1c                	jmp    800f2c <fork+0x129>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  800f10:	83 ec 0c             	sub    $0xc,%esp
  800f13:	6a 05                	push   $0x5
  800f15:	53                   	push   %ebx
  800f16:	57                   	push   %edi
  800f17:	53                   	push   %ebx
  800f18:	6a 00                	push   $0x0
  800f1a:	e8 5d fc ff ff       	call   800b7c <sys_page_map>
  800f1f:	83 c4 20             	add    $0x20,%esp
  800f22:	85 c0                	test   %eax,%eax
  800f24:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f29:	0f 4f c1             	cmovg  %ecx,%eax
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	78 67                	js     800f97 <fork+0x194>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  800f30:	83 c6 01             	add    $0x1,%esi
  800f33:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f39:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  800f3f:	0f 85 17 ff ff ff    	jne    800e5c <fork+0x59>
  800f45:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  800f48:	83 ec 04             	sub    $0x4,%esp
  800f4b:	6a 07                	push   $0x7
  800f4d:	68 00 f0 bf ee       	push   $0xeebff000
  800f52:	57                   	push   %edi
  800f53:	e8 e1 fb ff ff       	call   800b39 <sys_page_alloc>
	if (r < 0)
  800f58:	83 c4 10             	add    $0x10,%esp
		return r;
  800f5b:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	78 38                	js     800f99 <fork+0x196>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800f61:	83 ec 08             	sub    $0x8,%esp
  800f64:	68 1b 1e 80 00       	push   $0x801e1b
  800f69:	57                   	push   %edi
  800f6a:	e8 15 fd ff ff       	call   800c84 <sys_env_set_pgfault_upcall>
	if (r < 0)
  800f6f:	83 c4 10             	add    $0x10,%esp
		return r;
  800f72:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  800f74:	85 c0                	test   %eax,%eax
  800f76:	78 21                	js     800f99 <fork+0x196>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  800f78:	83 ec 08             	sub    $0x8,%esp
  800f7b:	6a 02                	push   $0x2
  800f7d:	57                   	push   %edi
  800f7e:	e8 7d fc ff ff       	call   800c00 <sys_env_set_status>
	if (r < 0)
  800f83:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  800f86:	85 c0                	test   %eax,%eax
  800f88:	0f 48 f8             	cmovs  %eax,%edi
  800f8b:	89 fa                	mov    %edi,%edx
  800f8d:	eb 0a                	jmp    800f99 <fork+0x196>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  800f8f:	89 c2                	mov    %eax,%edx
  800f91:	eb 06                	jmp    800f99 <fork+0x196>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f93:	89 c2                	mov    %eax,%edx
  800f95:	eb 02                	jmp    800f99 <fork+0x196>
  800f97:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  800f99:	89 d0                	mov    %edx,%eax
  800f9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f9e:	5b                   	pop    %ebx
  800f9f:	5e                   	pop    %esi
  800fa0:	5f                   	pop    %edi
  800fa1:	5d                   	pop    %ebp
  800fa2:	c3                   	ret    

00800fa3 <sfork>:

// Challenge!
int
sfork(void)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fa9:	68 2b 25 80 00       	push   $0x80252b
  800fae:	68 c6 00 00 00       	push   $0xc6
  800fb3:	68 20 25 80 00       	push   $0x802520
  800fb8:	e8 d1 0d 00 00       	call   801d8e <_panic>

00800fbd <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800fbd:	55                   	push   %ebp
  800fbe:	89 e5                	mov    %esp,%ebp
  800fc0:	56                   	push   %esi
  800fc1:	53                   	push   %ebx
  800fc2:	8b 75 08             	mov    0x8(%ebp),%esi
  800fc5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fc8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  800fcb:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  800fcd:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800fd2:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  800fd5:	83 ec 0c             	sub    $0xc,%esp
  800fd8:	50                   	push   %eax
  800fd9:	e8 0b fd ff ff       	call   800ce9 <sys_ipc_recv>

	if (from_env_store != NULL)
  800fde:	83 c4 10             	add    $0x10,%esp
  800fe1:	85 f6                	test   %esi,%esi
  800fe3:	74 14                	je     800ff9 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  800fe5:	ba 00 00 00 00       	mov    $0x0,%edx
  800fea:	85 c0                	test   %eax,%eax
  800fec:	78 09                	js     800ff7 <ipc_recv+0x3a>
  800fee:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800ff4:	8b 52 74             	mov    0x74(%edx),%edx
  800ff7:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  800ff9:	85 db                	test   %ebx,%ebx
  800ffb:	74 14                	je     801011 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  800ffd:	ba 00 00 00 00       	mov    $0x0,%edx
  801002:	85 c0                	test   %eax,%eax
  801004:	78 09                	js     80100f <ipc_recv+0x52>
  801006:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80100c:	8b 52 78             	mov    0x78(%edx),%edx
  80100f:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801011:	85 c0                	test   %eax,%eax
  801013:	78 08                	js     80101d <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801015:	a1 04 40 80 00       	mov    0x804004,%eax
  80101a:	8b 40 70             	mov    0x70(%eax),%eax
}
  80101d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801020:	5b                   	pop    %ebx
  801021:	5e                   	pop    %esi
  801022:	5d                   	pop    %ebp
  801023:	c3                   	ret    

00801024 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	57                   	push   %edi
  801028:	56                   	push   %esi
  801029:	53                   	push   %ebx
  80102a:	83 ec 0c             	sub    $0xc,%esp
  80102d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801030:	8b 75 0c             	mov    0xc(%ebp),%esi
  801033:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801036:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801038:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80103d:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801040:	ff 75 14             	pushl  0x14(%ebp)
  801043:	53                   	push   %ebx
  801044:	56                   	push   %esi
  801045:	57                   	push   %edi
  801046:	e8 7b fc ff ff       	call   800cc6 <sys_ipc_try_send>

		if (err < 0) {
  80104b:	83 c4 10             	add    $0x10,%esp
  80104e:	85 c0                	test   %eax,%eax
  801050:	79 1e                	jns    801070 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801052:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801055:	75 07                	jne    80105e <ipc_send+0x3a>
				sys_yield();
  801057:	e8 be fa ff ff       	call   800b1a <sys_yield>
  80105c:	eb e2                	jmp    801040 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  80105e:	50                   	push   %eax
  80105f:	68 41 25 80 00       	push   $0x802541
  801064:	6a 49                	push   $0x49
  801066:	68 4e 25 80 00       	push   $0x80254e
  80106b:	e8 1e 0d 00 00       	call   801d8e <_panic>
		}

	} while (err < 0);

}
  801070:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801073:	5b                   	pop    %ebx
  801074:	5e                   	pop    %esi
  801075:	5f                   	pop    %edi
  801076:	5d                   	pop    %ebp
  801077:	c3                   	ret    

00801078 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
  80107b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80107e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801083:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801086:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80108c:	8b 52 50             	mov    0x50(%edx),%edx
  80108f:	39 ca                	cmp    %ecx,%edx
  801091:	75 0d                	jne    8010a0 <ipc_find_env+0x28>
			return envs[i].env_id;
  801093:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801096:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80109b:	8b 40 48             	mov    0x48(%eax),%eax
  80109e:	eb 0f                	jmp    8010af <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8010a0:	83 c0 01             	add    $0x1,%eax
  8010a3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8010a8:	75 d9                	jne    801083 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8010aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010af:	5d                   	pop    %ebp
  8010b0:	c3                   	ret    

008010b1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010b1:	55                   	push   %ebp
  8010b2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b7:	05 00 00 00 30       	add    $0x30000000,%eax
  8010bc:	c1 e8 0c             	shr    $0xc,%eax
}
  8010bf:	5d                   	pop    %ebp
  8010c0:	c3                   	ret    

008010c1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010c1:	55                   	push   %ebp
  8010c2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c7:	05 00 00 00 30       	add    $0x30000000,%eax
  8010cc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010d1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010d6:	5d                   	pop    %ebp
  8010d7:	c3                   	ret    

008010d8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010d8:	55                   	push   %ebp
  8010d9:	89 e5                	mov    %esp,%ebp
  8010db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010de:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010e3:	89 c2                	mov    %eax,%edx
  8010e5:	c1 ea 16             	shr    $0x16,%edx
  8010e8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010ef:	f6 c2 01             	test   $0x1,%dl
  8010f2:	74 11                	je     801105 <fd_alloc+0x2d>
  8010f4:	89 c2                	mov    %eax,%edx
  8010f6:	c1 ea 0c             	shr    $0xc,%edx
  8010f9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801100:	f6 c2 01             	test   $0x1,%dl
  801103:	75 09                	jne    80110e <fd_alloc+0x36>
			*fd_store = fd;
  801105:	89 01                	mov    %eax,(%ecx)
			return 0;
  801107:	b8 00 00 00 00       	mov    $0x0,%eax
  80110c:	eb 17                	jmp    801125 <fd_alloc+0x4d>
  80110e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801113:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801118:	75 c9                	jne    8010e3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80111a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801120:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801125:	5d                   	pop    %ebp
  801126:	c3                   	ret    

00801127 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801127:	55                   	push   %ebp
  801128:	89 e5                	mov    %esp,%ebp
  80112a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80112d:	83 f8 1f             	cmp    $0x1f,%eax
  801130:	77 36                	ja     801168 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801132:	c1 e0 0c             	shl    $0xc,%eax
  801135:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80113a:	89 c2                	mov    %eax,%edx
  80113c:	c1 ea 16             	shr    $0x16,%edx
  80113f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801146:	f6 c2 01             	test   $0x1,%dl
  801149:	74 24                	je     80116f <fd_lookup+0x48>
  80114b:	89 c2                	mov    %eax,%edx
  80114d:	c1 ea 0c             	shr    $0xc,%edx
  801150:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801157:	f6 c2 01             	test   $0x1,%dl
  80115a:	74 1a                	je     801176 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80115c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80115f:	89 02                	mov    %eax,(%edx)
	return 0;
  801161:	b8 00 00 00 00       	mov    $0x0,%eax
  801166:	eb 13                	jmp    80117b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801168:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80116d:	eb 0c                	jmp    80117b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80116f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801174:	eb 05                	jmp    80117b <fd_lookup+0x54>
  801176:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80117b:	5d                   	pop    %ebp
  80117c:	c3                   	ret    

0080117d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80117d:	55                   	push   %ebp
  80117e:	89 e5                	mov    %esp,%ebp
  801180:	83 ec 08             	sub    $0x8,%esp
  801183:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801186:	ba d4 25 80 00       	mov    $0x8025d4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80118b:	eb 13                	jmp    8011a0 <dev_lookup+0x23>
  80118d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801190:	39 08                	cmp    %ecx,(%eax)
  801192:	75 0c                	jne    8011a0 <dev_lookup+0x23>
			*dev = devtab[i];
  801194:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801197:	89 01                	mov    %eax,(%ecx)
			return 0;
  801199:	b8 00 00 00 00       	mov    $0x0,%eax
  80119e:	eb 2e                	jmp    8011ce <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011a0:	8b 02                	mov    (%edx),%eax
  8011a2:	85 c0                	test   %eax,%eax
  8011a4:	75 e7                	jne    80118d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8011ab:	8b 40 48             	mov    0x48(%eax),%eax
  8011ae:	83 ec 04             	sub    $0x4,%esp
  8011b1:	51                   	push   %ecx
  8011b2:	50                   	push   %eax
  8011b3:	68 58 25 80 00       	push   $0x802558
  8011b8:	e8 f4 ef ff ff       	call   8001b1 <cprintf>
	*dev = 0;
  8011bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011c0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011c6:	83 c4 10             	add    $0x10,%esp
  8011c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011ce:	c9                   	leave  
  8011cf:	c3                   	ret    

008011d0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
  8011d3:	56                   	push   %esi
  8011d4:	53                   	push   %ebx
  8011d5:	83 ec 10             	sub    $0x10,%esp
  8011d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8011db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e1:	50                   	push   %eax
  8011e2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011e8:	c1 e8 0c             	shr    $0xc,%eax
  8011eb:	50                   	push   %eax
  8011ec:	e8 36 ff ff ff       	call   801127 <fd_lookup>
  8011f1:	83 c4 08             	add    $0x8,%esp
  8011f4:	85 c0                	test   %eax,%eax
  8011f6:	78 05                	js     8011fd <fd_close+0x2d>
	    || fd != fd2)
  8011f8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011fb:	74 0c                	je     801209 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011fd:	84 db                	test   %bl,%bl
  8011ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801204:	0f 44 c2             	cmove  %edx,%eax
  801207:	eb 41                	jmp    80124a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801209:	83 ec 08             	sub    $0x8,%esp
  80120c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80120f:	50                   	push   %eax
  801210:	ff 36                	pushl  (%esi)
  801212:	e8 66 ff ff ff       	call   80117d <dev_lookup>
  801217:	89 c3                	mov    %eax,%ebx
  801219:	83 c4 10             	add    $0x10,%esp
  80121c:	85 c0                	test   %eax,%eax
  80121e:	78 1a                	js     80123a <fd_close+0x6a>
		if (dev->dev_close)
  801220:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801223:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801226:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80122b:	85 c0                	test   %eax,%eax
  80122d:	74 0b                	je     80123a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80122f:	83 ec 0c             	sub    $0xc,%esp
  801232:	56                   	push   %esi
  801233:	ff d0                	call   *%eax
  801235:	89 c3                	mov    %eax,%ebx
  801237:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80123a:	83 ec 08             	sub    $0x8,%esp
  80123d:	56                   	push   %esi
  80123e:	6a 00                	push   $0x0
  801240:	e8 79 f9 ff ff       	call   800bbe <sys_page_unmap>
	return r;
  801245:	83 c4 10             	add    $0x10,%esp
  801248:	89 d8                	mov    %ebx,%eax
}
  80124a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80124d:	5b                   	pop    %ebx
  80124e:	5e                   	pop    %esi
  80124f:	5d                   	pop    %ebp
  801250:	c3                   	ret    

00801251 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801251:	55                   	push   %ebp
  801252:	89 e5                	mov    %esp,%ebp
  801254:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801257:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125a:	50                   	push   %eax
  80125b:	ff 75 08             	pushl  0x8(%ebp)
  80125e:	e8 c4 fe ff ff       	call   801127 <fd_lookup>
  801263:	83 c4 08             	add    $0x8,%esp
  801266:	85 c0                	test   %eax,%eax
  801268:	78 10                	js     80127a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80126a:	83 ec 08             	sub    $0x8,%esp
  80126d:	6a 01                	push   $0x1
  80126f:	ff 75 f4             	pushl  -0xc(%ebp)
  801272:	e8 59 ff ff ff       	call   8011d0 <fd_close>
  801277:	83 c4 10             	add    $0x10,%esp
}
  80127a:	c9                   	leave  
  80127b:	c3                   	ret    

0080127c <close_all>:

void
close_all(void)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	53                   	push   %ebx
  801280:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801283:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801288:	83 ec 0c             	sub    $0xc,%esp
  80128b:	53                   	push   %ebx
  80128c:	e8 c0 ff ff ff       	call   801251 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801291:	83 c3 01             	add    $0x1,%ebx
  801294:	83 c4 10             	add    $0x10,%esp
  801297:	83 fb 20             	cmp    $0x20,%ebx
  80129a:	75 ec                	jne    801288 <close_all+0xc>
		close(i);
}
  80129c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80129f:	c9                   	leave  
  8012a0:	c3                   	ret    

008012a1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012a1:	55                   	push   %ebp
  8012a2:	89 e5                	mov    %esp,%ebp
  8012a4:	57                   	push   %edi
  8012a5:	56                   	push   %esi
  8012a6:	53                   	push   %ebx
  8012a7:	83 ec 2c             	sub    $0x2c,%esp
  8012aa:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012ad:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012b0:	50                   	push   %eax
  8012b1:	ff 75 08             	pushl  0x8(%ebp)
  8012b4:	e8 6e fe ff ff       	call   801127 <fd_lookup>
  8012b9:	83 c4 08             	add    $0x8,%esp
  8012bc:	85 c0                	test   %eax,%eax
  8012be:	0f 88 c1 00 00 00    	js     801385 <dup+0xe4>
		return r;
	close(newfdnum);
  8012c4:	83 ec 0c             	sub    $0xc,%esp
  8012c7:	56                   	push   %esi
  8012c8:	e8 84 ff ff ff       	call   801251 <close>

	newfd = INDEX2FD(newfdnum);
  8012cd:	89 f3                	mov    %esi,%ebx
  8012cf:	c1 e3 0c             	shl    $0xc,%ebx
  8012d2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012d8:	83 c4 04             	add    $0x4,%esp
  8012db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012de:	e8 de fd ff ff       	call   8010c1 <fd2data>
  8012e3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012e5:	89 1c 24             	mov    %ebx,(%esp)
  8012e8:	e8 d4 fd ff ff       	call   8010c1 <fd2data>
  8012ed:	83 c4 10             	add    $0x10,%esp
  8012f0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012f3:	89 f8                	mov    %edi,%eax
  8012f5:	c1 e8 16             	shr    $0x16,%eax
  8012f8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012ff:	a8 01                	test   $0x1,%al
  801301:	74 37                	je     80133a <dup+0x99>
  801303:	89 f8                	mov    %edi,%eax
  801305:	c1 e8 0c             	shr    $0xc,%eax
  801308:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80130f:	f6 c2 01             	test   $0x1,%dl
  801312:	74 26                	je     80133a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801314:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80131b:	83 ec 0c             	sub    $0xc,%esp
  80131e:	25 07 0e 00 00       	and    $0xe07,%eax
  801323:	50                   	push   %eax
  801324:	ff 75 d4             	pushl  -0x2c(%ebp)
  801327:	6a 00                	push   $0x0
  801329:	57                   	push   %edi
  80132a:	6a 00                	push   $0x0
  80132c:	e8 4b f8 ff ff       	call   800b7c <sys_page_map>
  801331:	89 c7                	mov    %eax,%edi
  801333:	83 c4 20             	add    $0x20,%esp
  801336:	85 c0                	test   %eax,%eax
  801338:	78 2e                	js     801368 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80133a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80133d:	89 d0                	mov    %edx,%eax
  80133f:	c1 e8 0c             	shr    $0xc,%eax
  801342:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801349:	83 ec 0c             	sub    $0xc,%esp
  80134c:	25 07 0e 00 00       	and    $0xe07,%eax
  801351:	50                   	push   %eax
  801352:	53                   	push   %ebx
  801353:	6a 00                	push   $0x0
  801355:	52                   	push   %edx
  801356:	6a 00                	push   $0x0
  801358:	e8 1f f8 ff ff       	call   800b7c <sys_page_map>
  80135d:	89 c7                	mov    %eax,%edi
  80135f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801362:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801364:	85 ff                	test   %edi,%edi
  801366:	79 1d                	jns    801385 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801368:	83 ec 08             	sub    $0x8,%esp
  80136b:	53                   	push   %ebx
  80136c:	6a 00                	push   $0x0
  80136e:	e8 4b f8 ff ff       	call   800bbe <sys_page_unmap>
	sys_page_unmap(0, nva);
  801373:	83 c4 08             	add    $0x8,%esp
  801376:	ff 75 d4             	pushl  -0x2c(%ebp)
  801379:	6a 00                	push   $0x0
  80137b:	e8 3e f8 ff ff       	call   800bbe <sys_page_unmap>
	return r;
  801380:	83 c4 10             	add    $0x10,%esp
  801383:	89 f8                	mov    %edi,%eax
}
  801385:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801388:	5b                   	pop    %ebx
  801389:	5e                   	pop    %esi
  80138a:	5f                   	pop    %edi
  80138b:	5d                   	pop    %ebp
  80138c:	c3                   	ret    

0080138d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80138d:	55                   	push   %ebp
  80138e:	89 e5                	mov    %esp,%ebp
  801390:	53                   	push   %ebx
  801391:	83 ec 14             	sub    $0x14,%esp
  801394:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801397:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80139a:	50                   	push   %eax
  80139b:	53                   	push   %ebx
  80139c:	e8 86 fd ff ff       	call   801127 <fd_lookup>
  8013a1:	83 c4 08             	add    $0x8,%esp
  8013a4:	89 c2                	mov    %eax,%edx
  8013a6:	85 c0                	test   %eax,%eax
  8013a8:	78 6d                	js     801417 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013aa:	83 ec 08             	sub    $0x8,%esp
  8013ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b0:	50                   	push   %eax
  8013b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b4:	ff 30                	pushl  (%eax)
  8013b6:	e8 c2 fd ff ff       	call   80117d <dev_lookup>
  8013bb:	83 c4 10             	add    $0x10,%esp
  8013be:	85 c0                	test   %eax,%eax
  8013c0:	78 4c                	js     80140e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013c2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013c5:	8b 42 08             	mov    0x8(%edx),%eax
  8013c8:	83 e0 03             	and    $0x3,%eax
  8013cb:	83 f8 01             	cmp    $0x1,%eax
  8013ce:	75 21                	jne    8013f1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013d0:	a1 04 40 80 00       	mov    0x804004,%eax
  8013d5:	8b 40 48             	mov    0x48(%eax),%eax
  8013d8:	83 ec 04             	sub    $0x4,%esp
  8013db:	53                   	push   %ebx
  8013dc:	50                   	push   %eax
  8013dd:	68 99 25 80 00       	push   $0x802599
  8013e2:	e8 ca ed ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  8013e7:	83 c4 10             	add    $0x10,%esp
  8013ea:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013ef:	eb 26                	jmp    801417 <read+0x8a>
	}
	if (!dev->dev_read)
  8013f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013f4:	8b 40 08             	mov    0x8(%eax),%eax
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	74 17                	je     801412 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013fb:	83 ec 04             	sub    $0x4,%esp
  8013fe:	ff 75 10             	pushl  0x10(%ebp)
  801401:	ff 75 0c             	pushl  0xc(%ebp)
  801404:	52                   	push   %edx
  801405:	ff d0                	call   *%eax
  801407:	89 c2                	mov    %eax,%edx
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	eb 09                	jmp    801417 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80140e:	89 c2                	mov    %eax,%edx
  801410:	eb 05                	jmp    801417 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801412:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801417:	89 d0                	mov    %edx,%eax
  801419:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80141c:	c9                   	leave  
  80141d:	c3                   	ret    

0080141e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	57                   	push   %edi
  801422:	56                   	push   %esi
  801423:	53                   	push   %ebx
  801424:	83 ec 0c             	sub    $0xc,%esp
  801427:	8b 7d 08             	mov    0x8(%ebp),%edi
  80142a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80142d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801432:	eb 21                	jmp    801455 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801434:	83 ec 04             	sub    $0x4,%esp
  801437:	89 f0                	mov    %esi,%eax
  801439:	29 d8                	sub    %ebx,%eax
  80143b:	50                   	push   %eax
  80143c:	89 d8                	mov    %ebx,%eax
  80143e:	03 45 0c             	add    0xc(%ebp),%eax
  801441:	50                   	push   %eax
  801442:	57                   	push   %edi
  801443:	e8 45 ff ff ff       	call   80138d <read>
		if (m < 0)
  801448:	83 c4 10             	add    $0x10,%esp
  80144b:	85 c0                	test   %eax,%eax
  80144d:	78 10                	js     80145f <readn+0x41>
			return m;
		if (m == 0)
  80144f:	85 c0                	test   %eax,%eax
  801451:	74 0a                	je     80145d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801453:	01 c3                	add    %eax,%ebx
  801455:	39 f3                	cmp    %esi,%ebx
  801457:	72 db                	jb     801434 <readn+0x16>
  801459:	89 d8                	mov    %ebx,%eax
  80145b:	eb 02                	jmp    80145f <readn+0x41>
  80145d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80145f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801462:	5b                   	pop    %ebx
  801463:	5e                   	pop    %esi
  801464:	5f                   	pop    %edi
  801465:	5d                   	pop    %ebp
  801466:	c3                   	ret    

00801467 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801467:	55                   	push   %ebp
  801468:	89 e5                	mov    %esp,%ebp
  80146a:	53                   	push   %ebx
  80146b:	83 ec 14             	sub    $0x14,%esp
  80146e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801471:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801474:	50                   	push   %eax
  801475:	53                   	push   %ebx
  801476:	e8 ac fc ff ff       	call   801127 <fd_lookup>
  80147b:	83 c4 08             	add    $0x8,%esp
  80147e:	89 c2                	mov    %eax,%edx
  801480:	85 c0                	test   %eax,%eax
  801482:	78 68                	js     8014ec <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801484:	83 ec 08             	sub    $0x8,%esp
  801487:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148a:	50                   	push   %eax
  80148b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80148e:	ff 30                	pushl  (%eax)
  801490:	e8 e8 fc ff ff       	call   80117d <dev_lookup>
  801495:	83 c4 10             	add    $0x10,%esp
  801498:	85 c0                	test   %eax,%eax
  80149a:	78 47                	js     8014e3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80149c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80149f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014a3:	75 21                	jne    8014c6 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014a5:	a1 04 40 80 00       	mov    0x804004,%eax
  8014aa:	8b 40 48             	mov    0x48(%eax),%eax
  8014ad:	83 ec 04             	sub    $0x4,%esp
  8014b0:	53                   	push   %ebx
  8014b1:	50                   	push   %eax
  8014b2:	68 b5 25 80 00       	push   $0x8025b5
  8014b7:	e8 f5 ec ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  8014bc:	83 c4 10             	add    $0x10,%esp
  8014bf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014c4:	eb 26                	jmp    8014ec <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014c9:	8b 52 0c             	mov    0xc(%edx),%edx
  8014cc:	85 d2                	test   %edx,%edx
  8014ce:	74 17                	je     8014e7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014d0:	83 ec 04             	sub    $0x4,%esp
  8014d3:	ff 75 10             	pushl  0x10(%ebp)
  8014d6:	ff 75 0c             	pushl  0xc(%ebp)
  8014d9:	50                   	push   %eax
  8014da:	ff d2                	call   *%edx
  8014dc:	89 c2                	mov    %eax,%edx
  8014de:	83 c4 10             	add    $0x10,%esp
  8014e1:	eb 09                	jmp    8014ec <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e3:	89 c2                	mov    %eax,%edx
  8014e5:	eb 05                	jmp    8014ec <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014e7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014ec:	89 d0                	mov    %edx,%eax
  8014ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f1:	c9                   	leave  
  8014f2:	c3                   	ret    

008014f3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014f3:	55                   	push   %ebp
  8014f4:	89 e5                	mov    %esp,%ebp
  8014f6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014f9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014fc:	50                   	push   %eax
  8014fd:	ff 75 08             	pushl  0x8(%ebp)
  801500:	e8 22 fc ff ff       	call   801127 <fd_lookup>
  801505:	83 c4 08             	add    $0x8,%esp
  801508:	85 c0                	test   %eax,%eax
  80150a:	78 0e                	js     80151a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80150c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80150f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801512:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801515:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80151a:	c9                   	leave  
  80151b:	c3                   	ret    

0080151c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80151c:	55                   	push   %ebp
  80151d:	89 e5                	mov    %esp,%ebp
  80151f:	53                   	push   %ebx
  801520:	83 ec 14             	sub    $0x14,%esp
  801523:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801526:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801529:	50                   	push   %eax
  80152a:	53                   	push   %ebx
  80152b:	e8 f7 fb ff ff       	call   801127 <fd_lookup>
  801530:	83 c4 08             	add    $0x8,%esp
  801533:	89 c2                	mov    %eax,%edx
  801535:	85 c0                	test   %eax,%eax
  801537:	78 65                	js     80159e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801539:	83 ec 08             	sub    $0x8,%esp
  80153c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80153f:	50                   	push   %eax
  801540:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801543:	ff 30                	pushl  (%eax)
  801545:	e8 33 fc ff ff       	call   80117d <dev_lookup>
  80154a:	83 c4 10             	add    $0x10,%esp
  80154d:	85 c0                	test   %eax,%eax
  80154f:	78 44                	js     801595 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801551:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801554:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801558:	75 21                	jne    80157b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80155a:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80155f:	8b 40 48             	mov    0x48(%eax),%eax
  801562:	83 ec 04             	sub    $0x4,%esp
  801565:	53                   	push   %ebx
  801566:	50                   	push   %eax
  801567:	68 78 25 80 00       	push   $0x802578
  80156c:	e8 40 ec ff ff       	call   8001b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801571:	83 c4 10             	add    $0x10,%esp
  801574:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801579:	eb 23                	jmp    80159e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80157b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80157e:	8b 52 18             	mov    0x18(%edx),%edx
  801581:	85 d2                	test   %edx,%edx
  801583:	74 14                	je     801599 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801585:	83 ec 08             	sub    $0x8,%esp
  801588:	ff 75 0c             	pushl  0xc(%ebp)
  80158b:	50                   	push   %eax
  80158c:	ff d2                	call   *%edx
  80158e:	89 c2                	mov    %eax,%edx
  801590:	83 c4 10             	add    $0x10,%esp
  801593:	eb 09                	jmp    80159e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801595:	89 c2                	mov    %eax,%edx
  801597:	eb 05                	jmp    80159e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801599:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80159e:	89 d0                	mov    %edx,%eax
  8015a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a3:	c9                   	leave  
  8015a4:	c3                   	ret    

008015a5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015a5:	55                   	push   %ebp
  8015a6:	89 e5                	mov    %esp,%ebp
  8015a8:	53                   	push   %ebx
  8015a9:	83 ec 14             	sub    $0x14,%esp
  8015ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b2:	50                   	push   %eax
  8015b3:	ff 75 08             	pushl  0x8(%ebp)
  8015b6:	e8 6c fb ff ff       	call   801127 <fd_lookup>
  8015bb:	83 c4 08             	add    $0x8,%esp
  8015be:	89 c2                	mov    %eax,%edx
  8015c0:	85 c0                	test   %eax,%eax
  8015c2:	78 58                	js     80161c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c4:	83 ec 08             	sub    $0x8,%esp
  8015c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ca:	50                   	push   %eax
  8015cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ce:	ff 30                	pushl  (%eax)
  8015d0:	e8 a8 fb ff ff       	call   80117d <dev_lookup>
  8015d5:	83 c4 10             	add    $0x10,%esp
  8015d8:	85 c0                	test   %eax,%eax
  8015da:	78 37                	js     801613 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015df:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015e3:	74 32                	je     801617 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015e5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015e8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015ef:	00 00 00 
	stat->st_isdir = 0;
  8015f2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015f9:	00 00 00 
	stat->st_dev = dev;
  8015fc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801602:	83 ec 08             	sub    $0x8,%esp
  801605:	53                   	push   %ebx
  801606:	ff 75 f0             	pushl  -0x10(%ebp)
  801609:	ff 50 14             	call   *0x14(%eax)
  80160c:	89 c2                	mov    %eax,%edx
  80160e:	83 c4 10             	add    $0x10,%esp
  801611:	eb 09                	jmp    80161c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801613:	89 c2                	mov    %eax,%edx
  801615:	eb 05                	jmp    80161c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801617:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80161c:	89 d0                	mov    %edx,%eax
  80161e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801621:	c9                   	leave  
  801622:	c3                   	ret    

00801623 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801623:	55                   	push   %ebp
  801624:	89 e5                	mov    %esp,%ebp
  801626:	56                   	push   %esi
  801627:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801628:	83 ec 08             	sub    $0x8,%esp
  80162b:	6a 00                	push   $0x0
  80162d:	ff 75 08             	pushl  0x8(%ebp)
  801630:	e8 d6 01 00 00       	call   80180b <open>
  801635:	89 c3                	mov    %eax,%ebx
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	85 c0                	test   %eax,%eax
  80163c:	78 1b                	js     801659 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80163e:	83 ec 08             	sub    $0x8,%esp
  801641:	ff 75 0c             	pushl  0xc(%ebp)
  801644:	50                   	push   %eax
  801645:	e8 5b ff ff ff       	call   8015a5 <fstat>
  80164a:	89 c6                	mov    %eax,%esi
	close(fd);
  80164c:	89 1c 24             	mov    %ebx,(%esp)
  80164f:	e8 fd fb ff ff       	call   801251 <close>
	return r;
  801654:	83 c4 10             	add    $0x10,%esp
  801657:	89 f0                	mov    %esi,%eax
}
  801659:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80165c:	5b                   	pop    %ebx
  80165d:	5e                   	pop    %esi
  80165e:	5d                   	pop    %ebp
  80165f:	c3                   	ret    

00801660 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801660:	55                   	push   %ebp
  801661:	89 e5                	mov    %esp,%ebp
  801663:	56                   	push   %esi
  801664:	53                   	push   %ebx
  801665:	89 c6                	mov    %eax,%esi
  801667:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801669:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801670:	75 12                	jne    801684 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801672:	83 ec 0c             	sub    $0xc,%esp
  801675:	6a 01                	push   $0x1
  801677:	e8 fc f9 ff ff       	call   801078 <ipc_find_env>
  80167c:	a3 00 40 80 00       	mov    %eax,0x804000
  801681:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801684:	6a 07                	push   $0x7
  801686:	68 00 50 80 00       	push   $0x805000
  80168b:	56                   	push   %esi
  80168c:	ff 35 00 40 80 00    	pushl  0x804000
  801692:	e8 8d f9 ff ff       	call   801024 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801697:	83 c4 0c             	add    $0xc,%esp
  80169a:	6a 00                	push   $0x0
  80169c:	53                   	push   %ebx
  80169d:	6a 00                	push   $0x0
  80169f:	e8 19 f9 ff ff       	call   800fbd <ipc_recv>
}
  8016a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a7:	5b                   	pop    %ebx
  8016a8:	5e                   	pop    %esi
  8016a9:	5d                   	pop    %ebp
  8016aa:	c3                   	ret    

008016ab <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016bf:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c9:	b8 02 00 00 00       	mov    $0x2,%eax
  8016ce:	e8 8d ff ff ff       	call   801660 <fsipc>
}
  8016d3:	c9                   	leave  
  8016d4:	c3                   	ret    

008016d5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016db:	8b 45 08             	mov    0x8(%ebp),%eax
  8016de:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8016eb:	b8 06 00 00 00       	mov    $0x6,%eax
  8016f0:	e8 6b ff ff ff       	call   801660 <fsipc>
}
  8016f5:	c9                   	leave  
  8016f6:	c3                   	ret    

008016f7 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	53                   	push   %ebx
  8016fb:	83 ec 04             	sub    $0x4,%esp
  8016fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801701:	8b 45 08             	mov    0x8(%ebp),%eax
  801704:	8b 40 0c             	mov    0xc(%eax),%eax
  801707:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80170c:	ba 00 00 00 00       	mov    $0x0,%edx
  801711:	b8 05 00 00 00       	mov    $0x5,%eax
  801716:	e8 45 ff ff ff       	call   801660 <fsipc>
  80171b:	85 c0                	test   %eax,%eax
  80171d:	78 2c                	js     80174b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80171f:	83 ec 08             	sub    $0x8,%esp
  801722:	68 00 50 80 00       	push   $0x805000
  801727:	53                   	push   %ebx
  801728:	e8 09 f0 ff ff       	call   800736 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80172d:	a1 80 50 80 00       	mov    0x805080,%eax
  801732:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801738:	a1 84 50 80 00       	mov    0x805084,%eax
  80173d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801743:	83 c4 10             	add    $0x10,%esp
  801746:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80174b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80174e:	c9                   	leave  
  80174f:	c3                   	ret    

00801750 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801750:	55                   	push   %ebp
  801751:	89 e5                	mov    %esp,%ebp
  801753:	83 ec 0c             	sub    $0xc,%esp
  801756:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801759:	8b 55 08             	mov    0x8(%ebp),%edx
  80175c:	8b 52 0c             	mov    0xc(%edx),%edx
  80175f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801765:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80176a:	50                   	push   %eax
  80176b:	ff 75 0c             	pushl  0xc(%ebp)
  80176e:	68 08 50 80 00       	push   $0x805008
  801773:	e8 50 f1 ff ff       	call   8008c8 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801778:	ba 00 00 00 00       	mov    $0x0,%edx
  80177d:	b8 04 00 00 00       	mov    $0x4,%eax
  801782:	e8 d9 fe ff ff       	call   801660 <fsipc>

}
  801787:	c9                   	leave  
  801788:	c3                   	ret    

00801789 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801789:	55                   	push   %ebp
  80178a:	89 e5                	mov    %esp,%ebp
  80178c:	56                   	push   %esi
  80178d:	53                   	push   %ebx
  80178e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801791:	8b 45 08             	mov    0x8(%ebp),%eax
  801794:	8b 40 0c             	mov    0xc(%eax),%eax
  801797:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80179c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a7:	b8 03 00 00 00       	mov    $0x3,%eax
  8017ac:	e8 af fe ff ff       	call   801660 <fsipc>
  8017b1:	89 c3                	mov    %eax,%ebx
  8017b3:	85 c0                	test   %eax,%eax
  8017b5:	78 4b                	js     801802 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017b7:	39 c6                	cmp    %eax,%esi
  8017b9:	73 16                	jae    8017d1 <devfile_read+0x48>
  8017bb:	68 e4 25 80 00       	push   $0x8025e4
  8017c0:	68 eb 25 80 00       	push   $0x8025eb
  8017c5:	6a 7c                	push   $0x7c
  8017c7:	68 00 26 80 00       	push   $0x802600
  8017cc:	e8 bd 05 00 00       	call   801d8e <_panic>
	assert(r <= PGSIZE);
  8017d1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017d6:	7e 16                	jle    8017ee <devfile_read+0x65>
  8017d8:	68 0b 26 80 00       	push   $0x80260b
  8017dd:	68 eb 25 80 00       	push   $0x8025eb
  8017e2:	6a 7d                	push   $0x7d
  8017e4:	68 00 26 80 00       	push   $0x802600
  8017e9:	e8 a0 05 00 00       	call   801d8e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017ee:	83 ec 04             	sub    $0x4,%esp
  8017f1:	50                   	push   %eax
  8017f2:	68 00 50 80 00       	push   $0x805000
  8017f7:	ff 75 0c             	pushl  0xc(%ebp)
  8017fa:	e8 c9 f0 ff ff       	call   8008c8 <memmove>
	return r;
  8017ff:	83 c4 10             	add    $0x10,%esp
}
  801802:	89 d8                	mov    %ebx,%eax
  801804:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801807:	5b                   	pop    %ebx
  801808:	5e                   	pop    %esi
  801809:	5d                   	pop    %ebp
  80180a:	c3                   	ret    

0080180b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80180b:	55                   	push   %ebp
  80180c:	89 e5                	mov    %esp,%ebp
  80180e:	53                   	push   %ebx
  80180f:	83 ec 20             	sub    $0x20,%esp
  801812:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801815:	53                   	push   %ebx
  801816:	e8 e2 ee ff ff       	call   8006fd <strlen>
  80181b:	83 c4 10             	add    $0x10,%esp
  80181e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801823:	7f 67                	jg     80188c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801825:	83 ec 0c             	sub    $0xc,%esp
  801828:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80182b:	50                   	push   %eax
  80182c:	e8 a7 f8 ff ff       	call   8010d8 <fd_alloc>
  801831:	83 c4 10             	add    $0x10,%esp
		return r;
  801834:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801836:	85 c0                	test   %eax,%eax
  801838:	78 57                	js     801891 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80183a:	83 ec 08             	sub    $0x8,%esp
  80183d:	53                   	push   %ebx
  80183e:	68 00 50 80 00       	push   $0x805000
  801843:	e8 ee ee ff ff       	call   800736 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801848:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801850:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801853:	b8 01 00 00 00       	mov    $0x1,%eax
  801858:	e8 03 fe ff ff       	call   801660 <fsipc>
  80185d:	89 c3                	mov    %eax,%ebx
  80185f:	83 c4 10             	add    $0x10,%esp
  801862:	85 c0                	test   %eax,%eax
  801864:	79 14                	jns    80187a <open+0x6f>
		fd_close(fd, 0);
  801866:	83 ec 08             	sub    $0x8,%esp
  801869:	6a 00                	push   $0x0
  80186b:	ff 75 f4             	pushl  -0xc(%ebp)
  80186e:	e8 5d f9 ff ff       	call   8011d0 <fd_close>
		return r;
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	89 da                	mov    %ebx,%edx
  801878:	eb 17                	jmp    801891 <open+0x86>
	}

	return fd2num(fd);
  80187a:	83 ec 0c             	sub    $0xc,%esp
  80187d:	ff 75 f4             	pushl  -0xc(%ebp)
  801880:	e8 2c f8 ff ff       	call   8010b1 <fd2num>
  801885:	89 c2                	mov    %eax,%edx
  801887:	83 c4 10             	add    $0x10,%esp
  80188a:	eb 05                	jmp    801891 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80188c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801891:	89 d0                	mov    %edx,%eax
  801893:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801896:	c9                   	leave  
  801897:	c3                   	ret    

00801898 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
  80189b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80189e:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a3:	b8 08 00 00 00       	mov    $0x8,%eax
  8018a8:	e8 b3 fd ff ff       	call   801660 <fsipc>
}
  8018ad:	c9                   	leave  
  8018ae:	c3                   	ret    

008018af <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018af:	55                   	push   %ebp
  8018b0:	89 e5                	mov    %esp,%ebp
  8018b2:	56                   	push   %esi
  8018b3:	53                   	push   %ebx
  8018b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018b7:	83 ec 0c             	sub    $0xc,%esp
  8018ba:	ff 75 08             	pushl  0x8(%ebp)
  8018bd:	e8 ff f7 ff ff       	call   8010c1 <fd2data>
  8018c2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018c4:	83 c4 08             	add    $0x8,%esp
  8018c7:	68 17 26 80 00       	push   $0x802617
  8018cc:	53                   	push   %ebx
  8018cd:	e8 64 ee ff ff       	call   800736 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018d2:	8b 46 04             	mov    0x4(%esi),%eax
  8018d5:	2b 06                	sub    (%esi),%eax
  8018d7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018dd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018e4:	00 00 00 
	stat->st_dev = &devpipe;
  8018e7:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018ee:	30 80 00 
	return 0;
}
  8018f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f9:	5b                   	pop    %ebx
  8018fa:	5e                   	pop    %esi
  8018fb:	5d                   	pop    %ebp
  8018fc:	c3                   	ret    

008018fd <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018fd:	55                   	push   %ebp
  8018fe:	89 e5                	mov    %esp,%ebp
  801900:	53                   	push   %ebx
  801901:	83 ec 0c             	sub    $0xc,%esp
  801904:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801907:	53                   	push   %ebx
  801908:	6a 00                	push   $0x0
  80190a:	e8 af f2 ff ff       	call   800bbe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80190f:	89 1c 24             	mov    %ebx,(%esp)
  801912:	e8 aa f7 ff ff       	call   8010c1 <fd2data>
  801917:	83 c4 08             	add    $0x8,%esp
  80191a:	50                   	push   %eax
  80191b:	6a 00                	push   $0x0
  80191d:	e8 9c f2 ff ff       	call   800bbe <sys_page_unmap>
}
  801922:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801925:	c9                   	leave  
  801926:	c3                   	ret    

00801927 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801927:	55                   	push   %ebp
  801928:	89 e5                	mov    %esp,%ebp
  80192a:	57                   	push   %edi
  80192b:	56                   	push   %esi
  80192c:	53                   	push   %ebx
  80192d:	83 ec 1c             	sub    $0x1c,%esp
  801930:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801933:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801935:	a1 04 40 80 00       	mov    0x804004,%eax
  80193a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80193d:	83 ec 0c             	sub    $0xc,%esp
  801940:	ff 75 e0             	pushl  -0x20(%ebp)
  801943:	e8 f7 04 00 00       	call   801e3f <pageref>
  801948:	89 c3                	mov    %eax,%ebx
  80194a:	89 3c 24             	mov    %edi,(%esp)
  80194d:	e8 ed 04 00 00       	call   801e3f <pageref>
  801952:	83 c4 10             	add    $0x10,%esp
  801955:	39 c3                	cmp    %eax,%ebx
  801957:	0f 94 c1             	sete   %cl
  80195a:	0f b6 c9             	movzbl %cl,%ecx
  80195d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801960:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801966:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801969:	39 ce                	cmp    %ecx,%esi
  80196b:	74 1b                	je     801988 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80196d:	39 c3                	cmp    %eax,%ebx
  80196f:	75 c4                	jne    801935 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801971:	8b 42 58             	mov    0x58(%edx),%eax
  801974:	ff 75 e4             	pushl  -0x1c(%ebp)
  801977:	50                   	push   %eax
  801978:	56                   	push   %esi
  801979:	68 1e 26 80 00       	push   $0x80261e
  80197e:	e8 2e e8 ff ff       	call   8001b1 <cprintf>
  801983:	83 c4 10             	add    $0x10,%esp
  801986:	eb ad                	jmp    801935 <_pipeisclosed+0xe>
	}
}
  801988:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80198b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80198e:	5b                   	pop    %ebx
  80198f:	5e                   	pop    %esi
  801990:	5f                   	pop    %edi
  801991:	5d                   	pop    %ebp
  801992:	c3                   	ret    

00801993 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801993:	55                   	push   %ebp
  801994:	89 e5                	mov    %esp,%ebp
  801996:	57                   	push   %edi
  801997:	56                   	push   %esi
  801998:	53                   	push   %ebx
  801999:	83 ec 28             	sub    $0x28,%esp
  80199c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80199f:	56                   	push   %esi
  8019a0:	e8 1c f7 ff ff       	call   8010c1 <fd2data>
  8019a5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019a7:	83 c4 10             	add    $0x10,%esp
  8019aa:	bf 00 00 00 00       	mov    $0x0,%edi
  8019af:	eb 4b                	jmp    8019fc <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019b1:	89 da                	mov    %ebx,%edx
  8019b3:	89 f0                	mov    %esi,%eax
  8019b5:	e8 6d ff ff ff       	call   801927 <_pipeisclosed>
  8019ba:	85 c0                	test   %eax,%eax
  8019bc:	75 48                	jne    801a06 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019be:	e8 57 f1 ff ff       	call   800b1a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019c3:	8b 43 04             	mov    0x4(%ebx),%eax
  8019c6:	8b 0b                	mov    (%ebx),%ecx
  8019c8:	8d 51 20             	lea    0x20(%ecx),%edx
  8019cb:	39 d0                	cmp    %edx,%eax
  8019cd:	73 e2                	jae    8019b1 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019d2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019d6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019d9:	89 c2                	mov    %eax,%edx
  8019db:	c1 fa 1f             	sar    $0x1f,%edx
  8019de:	89 d1                	mov    %edx,%ecx
  8019e0:	c1 e9 1b             	shr    $0x1b,%ecx
  8019e3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019e6:	83 e2 1f             	and    $0x1f,%edx
  8019e9:	29 ca                	sub    %ecx,%edx
  8019eb:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019ef:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019f3:	83 c0 01             	add    $0x1,%eax
  8019f6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019f9:	83 c7 01             	add    $0x1,%edi
  8019fc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019ff:	75 c2                	jne    8019c3 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a01:	8b 45 10             	mov    0x10(%ebp),%eax
  801a04:	eb 05                	jmp    801a0b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a06:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a0e:	5b                   	pop    %ebx
  801a0f:	5e                   	pop    %esi
  801a10:	5f                   	pop    %edi
  801a11:	5d                   	pop    %ebp
  801a12:	c3                   	ret    

00801a13 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a13:	55                   	push   %ebp
  801a14:	89 e5                	mov    %esp,%ebp
  801a16:	57                   	push   %edi
  801a17:	56                   	push   %esi
  801a18:	53                   	push   %ebx
  801a19:	83 ec 18             	sub    $0x18,%esp
  801a1c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a1f:	57                   	push   %edi
  801a20:	e8 9c f6 ff ff       	call   8010c1 <fd2data>
  801a25:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a27:	83 c4 10             	add    $0x10,%esp
  801a2a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a2f:	eb 3d                	jmp    801a6e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a31:	85 db                	test   %ebx,%ebx
  801a33:	74 04                	je     801a39 <devpipe_read+0x26>
				return i;
  801a35:	89 d8                	mov    %ebx,%eax
  801a37:	eb 44                	jmp    801a7d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a39:	89 f2                	mov    %esi,%edx
  801a3b:	89 f8                	mov    %edi,%eax
  801a3d:	e8 e5 fe ff ff       	call   801927 <_pipeisclosed>
  801a42:	85 c0                	test   %eax,%eax
  801a44:	75 32                	jne    801a78 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a46:	e8 cf f0 ff ff       	call   800b1a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a4b:	8b 06                	mov    (%esi),%eax
  801a4d:	3b 46 04             	cmp    0x4(%esi),%eax
  801a50:	74 df                	je     801a31 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a52:	99                   	cltd   
  801a53:	c1 ea 1b             	shr    $0x1b,%edx
  801a56:	01 d0                	add    %edx,%eax
  801a58:	83 e0 1f             	and    $0x1f,%eax
  801a5b:	29 d0                	sub    %edx,%eax
  801a5d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a65:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a68:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a6b:	83 c3 01             	add    $0x1,%ebx
  801a6e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a71:	75 d8                	jne    801a4b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a73:	8b 45 10             	mov    0x10(%ebp),%eax
  801a76:	eb 05                	jmp    801a7d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a78:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a80:	5b                   	pop    %ebx
  801a81:	5e                   	pop    %esi
  801a82:	5f                   	pop    %edi
  801a83:	5d                   	pop    %ebp
  801a84:	c3                   	ret    

00801a85 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a85:	55                   	push   %ebp
  801a86:	89 e5                	mov    %esp,%ebp
  801a88:	56                   	push   %esi
  801a89:	53                   	push   %ebx
  801a8a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a8d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a90:	50                   	push   %eax
  801a91:	e8 42 f6 ff ff       	call   8010d8 <fd_alloc>
  801a96:	83 c4 10             	add    $0x10,%esp
  801a99:	89 c2                	mov    %eax,%edx
  801a9b:	85 c0                	test   %eax,%eax
  801a9d:	0f 88 2c 01 00 00    	js     801bcf <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aa3:	83 ec 04             	sub    $0x4,%esp
  801aa6:	68 07 04 00 00       	push   $0x407
  801aab:	ff 75 f4             	pushl  -0xc(%ebp)
  801aae:	6a 00                	push   $0x0
  801ab0:	e8 84 f0 ff ff       	call   800b39 <sys_page_alloc>
  801ab5:	83 c4 10             	add    $0x10,%esp
  801ab8:	89 c2                	mov    %eax,%edx
  801aba:	85 c0                	test   %eax,%eax
  801abc:	0f 88 0d 01 00 00    	js     801bcf <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ac2:	83 ec 0c             	sub    $0xc,%esp
  801ac5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ac8:	50                   	push   %eax
  801ac9:	e8 0a f6 ff ff       	call   8010d8 <fd_alloc>
  801ace:	89 c3                	mov    %eax,%ebx
  801ad0:	83 c4 10             	add    $0x10,%esp
  801ad3:	85 c0                	test   %eax,%eax
  801ad5:	0f 88 e2 00 00 00    	js     801bbd <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801adb:	83 ec 04             	sub    $0x4,%esp
  801ade:	68 07 04 00 00       	push   $0x407
  801ae3:	ff 75 f0             	pushl  -0x10(%ebp)
  801ae6:	6a 00                	push   $0x0
  801ae8:	e8 4c f0 ff ff       	call   800b39 <sys_page_alloc>
  801aed:	89 c3                	mov    %eax,%ebx
  801aef:	83 c4 10             	add    $0x10,%esp
  801af2:	85 c0                	test   %eax,%eax
  801af4:	0f 88 c3 00 00 00    	js     801bbd <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801afa:	83 ec 0c             	sub    $0xc,%esp
  801afd:	ff 75 f4             	pushl  -0xc(%ebp)
  801b00:	e8 bc f5 ff ff       	call   8010c1 <fd2data>
  801b05:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b07:	83 c4 0c             	add    $0xc,%esp
  801b0a:	68 07 04 00 00       	push   $0x407
  801b0f:	50                   	push   %eax
  801b10:	6a 00                	push   $0x0
  801b12:	e8 22 f0 ff ff       	call   800b39 <sys_page_alloc>
  801b17:	89 c3                	mov    %eax,%ebx
  801b19:	83 c4 10             	add    $0x10,%esp
  801b1c:	85 c0                	test   %eax,%eax
  801b1e:	0f 88 89 00 00 00    	js     801bad <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b24:	83 ec 0c             	sub    $0xc,%esp
  801b27:	ff 75 f0             	pushl  -0x10(%ebp)
  801b2a:	e8 92 f5 ff ff       	call   8010c1 <fd2data>
  801b2f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b36:	50                   	push   %eax
  801b37:	6a 00                	push   $0x0
  801b39:	56                   	push   %esi
  801b3a:	6a 00                	push   $0x0
  801b3c:	e8 3b f0 ff ff       	call   800b7c <sys_page_map>
  801b41:	89 c3                	mov    %eax,%ebx
  801b43:	83 c4 20             	add    $0x20,%esp
  801b46:	85 c0                	test   %eax,%eax
  801b48:	78 55                	js     801b9f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b4a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b53:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b58:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b5f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b65:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b68:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b6d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b74:	83 ec 0c             	sub    $0xc,%esp
  801b77:	ff 75 f4             	pushl  -0xc(%ebp)
  801b7a:	e8 32 f5 ff ff       	call   8010b1 <fd2num>
  801b7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b82:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b84:	83 c4 04             	add    $0x4,%esp
  801b87:	ff 75 f0             	pushl  -0x10(%ebp)
  801b8a:	e8 22 f5 ff ff       	call   8010b1 <fd2num>
  801b8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b92:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b95:	83 c4 10             	add    $0x10,%esp
  801b98:	ba 00 00 00 00       	mov    $0x0,%edx
  801b9d:	eb 30                	jmp    801bcf <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b9f:	83 ec 08             	sub    $0x8,%esp
  801ba2:	56                   	push   %esi
  801ba3:	6a 00                	push   $0x0
  801ba5:	e8 14 f0 ff ff       	call   800bbe <sys_page_unmap>
  801baa:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801bad:	83 ec 08             	sub    $0x8,%esp
  801bb0:	ff 75 f0             	pushl  -0x10(%ebp)
  801bb3:	6a 00                	push   $0x0
  801bb5:	e8 04 f0 ff ff       	call   800bbe <sys_page_unmap>
  801bba:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801bbd:	83 ec 08             	sub    $0x8,%esp
  801bc0:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc3:	6a 00                	push   $0x0
  801bc5:	e8 f4 ef ff ff       	call   800bbe <sys_page_unmap>
  801bca:	83 c4 10             	add    $0x10,%esp
  801bcd:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801bcf:	89 d0                	mov    %edx,%eax
  801bd1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bd4:	5b                   	pop    %ebx
  801bd5:	5e                   	pop    %esi
  801bd6:	5d                   	pop    %ebp
  801bd7:	c3                   	ret    

00801bd8 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
  801bdb:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bde:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be1:	50                   	push   %eax
  801be2:	ff 75 08             	pushl  0x8(%ebp)
  801be5:	e8 3d f5 ff ff       	call   801127 <fd_lookup>
  801bea:	83 c4 10             	add    $0x10,%esp
  801bed:	85 c0                	test   %eax,%eax
  801bef:	78 18                	js     801c09 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bf1:	83 ec 0c             	sub    $0xc,%esp
  801bf4:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf7:	e8 c5 f4 ff ff       	call   8010c1 <fd2data>
	return _pipeisclosed(fd, p);
  801bfc:	89 c2                	mov    %eax,%edx
  801bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c01:	e8 21 fd ff ff       	call   801927 <_pipeisclosed>
  801c06:	83 c4 10             	add    $0x10,%esp
}
  801c09:	c9                   	leave  
  801c0a:	c3                   	ret    

00801c0b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c0b:	55                   	push   %ebp
  801c0c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c0e:	b8 00 00 00 00       	mov    $0x0,%eax
  801c13:	5d                   	pop    %ebp
  801c14:	c3                   	ret    

00801c15 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c15:	55                   	push   %ebp
  801c16:	89 e5                	mov    %esp,%ebp
  801c18:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c1b:	68 36 26 80 00       	push   $0x802636
  801c20:	ff 75 0c             	pushl  0xc(%ebp)
  801c23:	e8 0e eb ff ff       	call   800736 <strcpy>
	return 0;
}
  801c28:	b8 00 00 00 00       	mov    $0x0,%eax
  801c2d:	c9                   	leave  
  801c2e:	c3                   	ret    

00801c2f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c2f:	55                   	push   %ebp
  801c30:	89 e5                	mov    %esp,%ebp
  801c32:	57                   	push   %edi
  801c33:	56                   	push   %esi
  801c34:	53                   	push   %ebx
  801c35:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c3b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c40:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c46:	eb 2d                	jmp    801c75 <devcons_write+0x46>
		m = n - tot;
  801c48:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c4b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c4d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c50:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c55:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c58:	83 ec 04             	sub    $0x4,%esp
  801c5b:	53                   	push   %ebx
  801c5c:	03 45 0c             	add    0xc(%ebp),%eax
  801c5f:	50                   	push   %eax
  801c60:	57                   	push   %edi
  801c61:	e8 62 ec ff ff       	call   8008c8 <memmove>
		sys_cputs(buf, m);
  801c66:	83 c4 08             	add    $0x8,%esp
  801c69:	53                   	push   %ebx
  801c6a:	57                   	push   %edi
  801c6b:	e8 0d ee ff ff       	call   800a7d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c70:	01 de                	add    %ebx,%esi
  801c72:	83 c4 10             	add    $0x10,%esp
  801c75:	89 f0                	mov    %esi,%eax
  801c77:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c7a:	72 cc                	jb     801c48 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c7f:	5b                   	pop    %ebx
  801c80:	5e                   	pop    %esi
  801c81:	5f                   	pop    %edi
  801c82:	5d                   	pop    %ebp
  801c83:	c3                   	ret    

00801c84 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c84:	55                   	push   %ebp
  801c85:	89 e5                	mov    %esp,%ebp
  801c87:	83 ec 08             	sub    $0x8,%esp
  801c8a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c8f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c93:	74 2a                	je     801cbf <devcons_read+0x3b>
  801c95:	eb 05                	jmp    801c9c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c97:	e8 7e ee ff ff       	call   800b1a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c9c:	e8 fa ed ff ff       	call   800a9b <sys_cgetc>
  801ca1:	85 c0                	test   %eax,%eax
  801ca3:	74 f2                	je     801c97 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ca5:	85 c0                	test   %eax,%eax
  801ca7:	78 16                	js     801cbf <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ca9:	83 f8 04             	cmp    $0x4,%eax
  801cac:	74 0c                	je     801cba <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801cae:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cb1:	88 02                	mov    %al,(%edx)
	return 1;
  801cb3:	b8 01 00 00 00       	mov    $0x1,%eax
  801cb8:	eb 05                	jmp    801cbf <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801cba:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801cbf:	c9                   	leave  
  801cc0:	c3                   	ret    

00801cc1 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801cc1:	55                   	push   %ebp
  801cc2:	89 e5                	mov    %esp,%ebp
  801cc4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cc7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cca:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ccd:	6a 01                	push   $0x1
  801ccf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cd2:	50                   	push   %eax
  801cd3:	e8 a5 ed ff ff       	call   800a7d <sys_cputs>
}
  801cd8:	83 c4 10             	add    $0x10,%esp
  801cdb:	c9                   	leave  
  801cdc:	c3                   	ret    

00801cdd <getchar>:

int
getchar(void)
{
  801cdd:	55                   	push   %ebp
  801cde:	89 e5                	mov    %esp,%ebp
  801ce0:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ce3:	6a 01                	push   $0x1
  801ce5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ce8:	50                   	push   %eax
  801ce9:	6a 00                	push   $0x0
  801ceb:	e8 9d f6 ff ff       	call   80138d <read>
	if (r < 0)
  801cf0:	83 c4 10             	add    $0x10,%esp
  801cf3:	85 c0                	test   %eax,%eax
  801cf5:	78 0f                	js     801d06 <getchar+0x29>
		return r;
	if (r < 1)
  801cf7:	85 c0                	test   %eax,%eax
  801cf9:	7e 06                	jle    801d01 <getchar+0x24>
		return -E_EOF;
	return c;
  801cfb:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cff:	eb 05                	jmp    801d06 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d01:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d06:	c9                   	leave  
  801d07:	c3                   	ret    

00801d08 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d08:	55                   	push   %ebp
  801d09:	89 e5                	mov    %esp,%ebp
  801d0b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d11:	50                   	push   %eax
  801d12:	ff 75 08             	pushl  0x8(%ebp)
  801d15:	e8 0d f4 ff ff       	call   801127 <fd_lookup>
  801d1a:	83 c4 10             	add    $0x10,%esp
  801d1d:	85 c0                	test   %eax,%eax
  801d1f:	78 11                	js     801d32 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d24:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d2a:	39 10                	cmp    %edx,(%eax)
  801d2c:	0f 94 c0             	sete   %al
  801d2f:	0f b6 c0             	movzbl %al,%eax
}
  801d32:	c9                   	leave  
  801d33:	c3                   	ret    

00801d34 <opencons>:

int
opencons(void)
{
  801d34:	55                   	push   %ebp
  801d35:	89 e5                	mov    %esp,%ebp
  801d37:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d3a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d3d:	50                   	push   %eax
  801d3e:	e8 95 f3 ff ff       	call   8010d8 <fd_alloc>
  801d43:	83 c4 10             	add    $0x10,%esp
		return r;
  801d46:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d48:	85 c0                	test   %eax,%eax
  801d4a:	78 3e                	js     801d8a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d4c:	83 ec 04             	sub    $0x4,%esp
  801d4f:	68 07 04 00 00       	push   $0x407
  801d54:	ff 75 f4             	pushl  -0xc(%ebp)
  801d57:	6a 00                	push   $0x0
  801d59:	e8 db ed ff ff       	call   800b39 <sys_page_alloc>
  801d5e:	83 c4 10             	add    $0x10,%esp
		return r;
  801d61:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d63:	85 c0                	test   %eax,%eax
  801d65:	78 23                	js     801d8a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d67:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d70:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d75:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d7c:	83 ec 0c             	sub    $0xc,%esp
  801d7f:	50                   	push   %eax
  801d80:	e8 2c f3 ff ff       	call   8010b1 <fd2num>
  801d85:	89 c2                	mov    %eax,%edx
  801d87:	83 c4 10             	add    $0x10,%esp
}
  801d8a:	89 d0                	mov    %edx,%eax
  801d8c:	c9                   	leave  
  801d8d:	c3                   	ret    

00801d8e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d8e:	55                   	push   %ebp
  801d8f:	89 e5                	mov    %esp,%ebp
  801d91:	56                   	push   %esi
  801d92:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d93:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d96:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d9c:	e8 5a ed ff ff       	call   800afb <sys_getenvid>
  801da1:	83 ec 0c             	sub    $0xc,%esp
  801da4:	ff 75 0c             	pushl  0xc(%ebp)
  801da7:	ff 75 08             	pushl  0x8(%ebp)
  801daa:	56                   	push   %esi
  801dab:	50                   	push   %eax
  801dac:	68 44 26 80 00       	push   $0x802644
  801db1:	e8 fb e3 ff ff       	call   8001b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801db6:	83 c4 18             	add    $0x18,%esp
  801db9:	53                   	push   %ebx
  801dba:	ff 75 10             	pushl  0x10(%ebp)
  801dbd:	e8 9e e3 ff ff       	call   800160 <vcprintf>
	cprintf("\n");
  801dc2:	c7 04 24 2f 26 80 00 	movl   $0x80262f,(%esp)
  801dc9:	e8 e3 e3 ff ff       	call   8001b1 <cprintf>
  801dce:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801dd1:	cc                   	int3   
  801dd2:	eb fd                	jmp    801dd1 <_panic+0x43>

00801dd4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801dd4:	55                   	push   %ebp
  801dd5:	89 e5                	mov    %esp,%ebp
  801dd7:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801dda:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801de1:	75 2e                	jne    801e11 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801de3:	e8 13 ed ff ff       	call   800afb <sys_getenvid>
  801de8:	83 ec 04             	sub    $0x4,%esp
  801deb:	68 07 0e 00 00       	push   $0xe07
  801df0:	68 00 f0 bf ee       	push   $0xeebff000
  801df5:	50                   	push   %eax
  801df6:	e8 3e ed ff ff       	call   800b39 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801dfb:	e8 fb ec ff ff       	call   800afb <sys_getenvid>
  801e00:	83 c4 08             	add    $0x8,%esp
  801e03:	68 1b 1e 80 00       	push   $0x801e1b
  801e08:	50                   	push   %eax
  801e09:	e8 76 ee ff ff       	call   800c84 <sys_env_set_pgfault_upcall>
  801e0e:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e11:	8b 45 08             	mov    0x8(%ebp),%eax
  801e14:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e19:	c9                   	leave  
  801e1a:	c3                   	ret    

00801e1b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e1b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e1c:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e21:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e23:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  801e26:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  801e2a:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  801e2e:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  801e31:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  801e34:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  801e35:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  801e38:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  801e39:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  801e3a:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  801e3e:	c3                   	ret    

00801e3f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e3f:	55                   	push   %ebp
  801e40:	89 e5                	mov    %esp,%ebp
  801e42:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e45:	89 d0                	mov    %edx,%eax
  801e47:	c1 e8 16             	shr    $0x16,%eax
  801e4a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e51:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e56:	f6 c1 01             	test   $0x1,%cl
  801e59:	74 1d                	je     801e78 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e5b:	c1 ea 0c             	shr    $0xc,%edx
  801e5e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e65:	f6 c2 01             	test   $0x1,%dl
  801e68:	74 0e                	je     801e78 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e6a:	c1 ea 0c             	shr    $0xc,%edx
  801e6d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e74:	ef 
  801e75:	0f b7 c0             	movzwl %ax,%eax
}
  801e78:	5d                   	pop    %ebp
  801e79:	c3                   	ret    
  801e7a:	66 90                	xchg   %ax,%ax
  801e7c:	66 90                	xchg   %ax,%ax
  801e7e:	66 90                	xchg   %ax,%ax

00801e80 <__udivdi3>:
  801e80:	55                   	push   %ebp
  801e81:	57                   	push   %edi
  801e82:	56                   	push   %esi
  801e83:	53                   	push   %ebx
  801e84:	83 ec 1c             	sub    $0x1c,%esp
  801e87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801e8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801e8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801e93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e97:	85 f6                	test   %esi,%esi
  801e99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e9d:	89 ca                	mov    %ecx,%edx
  801e9f:	89 f8                	mov    %edi,%eax
  801ea1:	75 3d                	jne    801ee0 <__udivdi3+0x60>
  801ea3:	39 cf                	cmp    %ecx,%edi
  801ea5:	0f 87 c5 00 00 00    	ja     801f70 <__udivdi3+0xf0>
  801eab:	85 ff                	test   %edi,%edi
  801ead:	89 fd                	mov    %edi,%ebp
  801eaf:	75 0b                	jne    801ebc <__udivdi3+0x3c>
  801eb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801eb6:	31 d2                	xor    %edx,%edx
  801eb8:	f7 f7                	div    %edi
  801eba:	89 c5                	mov    %eax,%ebp
  801ebc:	89 c8                	mov    %ecx,%eax
  801ebe:	31 d2                	xor    %edx,%edx
  801ec0:	f7 f5                	div    %ebp
  801ec2:	89 c1                	mov    %eax,%ecx
  801ec4:	89 d8                	mov    %ebx,%eax
  801ec6:	89 cf                	mov    %ecx,%edi
  801ec8:	f7 f5                	div    %ebp
  801eca:	89 c3                	mov    %eax,%ebx
  801ecc:	89 d8                	mov    %ebx,%eax
  801ece:	89 fa                	mov    %edi,%edx
  801ed0:	83 c4 1c             	add    $0x1c,%esp
  801ed3:	5b                   	pop    %ebx
  801ed4:	5e                   	pop    %esi
  801ed5:	5f                   	pop    %edi
  801ed6:	5d                   	pop    %ebp
  801ed7:	c3                   	ret    
  801ed8:	90                   	nop
  801ed9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ee0:	39 ce                	cmp    %ecx,%esi
  801ee2:	77 74                	ja     801f58 <__udivdi3+0xd8>
  801ee4:	0f bd fe             	bsr    %esi,%edi
  801ee7:	83 f7 1f             	xor    $0x1f,%edi
  801eea:	0f 84 98 00 00 00    	je     801f88 <__udivdi3+0x108>
  801ef0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ef5:	89 f9                	mov    %edi,%ecx
  801ef7:	89 c5                	mov    %eax,%ebp
  801ef9:	29 fb                	sub    %edi,%ebx
  801efb:	d3 e6                	shl    %cl,%esi
  801efd:	89 d9                	mov    %ebx,%ecx
  801eff:	d3 ed                	shr    %cl,%ebp
  801f01:	89 f9                	mov    %edi,%ecx
  801f03:	d3 e0                	shl    %cl,%eax
  801f05:	09 ee                	or     %ebp,%esi
  801f07:	89 d9                	mov    %ebx,%ecx
  801f09:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f0d:	89 d5                	mov    %edx,%ebp
  801f0f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f13:	d3 ed                	shr    %cl,%ebp
  801f15:	89 f9                	mov    %edi,%ecx
  801f17:	d3 e2                	shl    %cl,%edx
  801f19:	89 d9                	mov    %ebx,%ecx
  801f1b:	d3 e8                	shr    %cl,%eax
  801f1d:	09 c2                	or     %eax,%edx
  801f1f:	89 d0                	mov    %edx,%eax
  801f21:	89 ea                	mov    %ebp,%edx
  801f23:	f7 f6                	div    %esi
  801f25:	89 d5                	mov    %edx,%ebp
  801f27:	89 c3                	mov    %eax,%ebx
  801f29:	f7 64 24 0c          	mull   0xc(%esp)
  801f2d:	39 d5                	cmp    %edx,%ebp
  801f2f:	72 10                	jb     801f41 <__udivdi3+0xc1>
  801f31:	8b 74 24 08          	mov    0x8(%esp),%esi
  801f35:	89 f9                	mov    %edi,%ecx
  801f37:	d3 e6                	shl    %cl,%esi
  801f39:	39 c6                	cmp    %eax,%esi
  801f3b:	73 07                	jae    801f44 <__udivdi3+0xc4>
  801f3d:	39 d5                	cmp    %edx,%ebp
  801f3f:	75 03                	jne    801f44 <__udivdi3+0xc4>
  801f41:	83 eb 01             	sub    $0x1,%ebx
  801f44:	31 ff                	xor    %edi,%edi
  801f46:	89 d8                	mov    %ebx,%eax
  801f48:	89 fa                	mov    %edi,%edx
  801f4a:	83 c4 1c             	add    $0x1c,%esp
  801f4d:	5b                   	pop    %ebx
  801f4e:	5e                   	pop    %esi
  801f4f:	5f                   	pop    %edi
  801f50:	5d                   	pop    %ebp
  801f51:	c3                   	ret    
  801f52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f58:	31 ff                	xor    %edi,%edi
  801f5a:	31 db                	xor    %ebx,%ebx
  801f5c:	89 d8                	mov    %ebx,%eax
  801f5e:	89 fa                	mov    %edi,%edx
  801f60:	83 c4 1c             	add    $0x1c,%esp
  801f63:	5b                   	pop    %ebx
  801f64:	5e                   	pop    %esi
  801f65:	5f                   	pop    %edi
  801f66:	5d                   	pop    %ebp
  801f67:	c3                   	ret    
  801f68:	90                   	nop
  801f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f70:	89 d8                	mov    %ebx,%eax
  801f72:	f7 f7                	div    %edi
  801f74:	31 ff                	xor    %edi,%edi
  801f76:	89 c3                	mov    %eax,%ebx
  801f78:	89 d8                	mov    %ebx,%eax
  801f7a:	89 fa                	mov    %edi,%edx
  801f7c:	83 c4 1c             	add    $0x1c,%esp
  801f7f:	5b                   	pop    %ebx
  801f80:	5e                   	pop    %esi
  801f81:	5f                   	pop    %edi
  801f82:	5d                   	pop    %ebp
  801f83:	c3                   	ret    
  801f84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f88:	39 ce                	cmp    %ecx,%esi
  801f8a:	72 0c                	jb     801f98 <__udivdi3+0x118>
  801f8c:	31 db                	xor    %ebx,%ebx
  801f8e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801f92:	0f 87 34 ff ff ff    	ja     801ecc <__udivdi3+0x4c>
  801f98:	bb 01 00 00 00       	mov    $0x1,%ebx
  801f9d:	e9 2a ff ff ff       	jmp    801ecc <__udivdi3+0x4c>
  801fa2:	66 90                	xchg   %ax,%ax
  801fa4:	66 90                	xchg   %ax,%ax
  801fa6:	66 90                	xchg   %ax,%ax
  801fa8:	66 90                	xchg   %ax,%ax
  801faa:	66 90                	xchg   %ax,%ax
  801fac:	66 90                	xchg   %ax,%ax
  801fae:	66 90                	xchg   %ax,%ax

00801fb0 <__umoddi3>:
  801fb0:	55                   	push   %ebp
  801fb1:	57                   	push   %edi
  801fb2:	56                   	push   %esi
  801fb3:	53                   	push   %ebx
  801fb4:	83 ec 1c             	sub    $0x1c,%esp
  801fb7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801fbb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801fbf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801fc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fc7:	85 d2                	test   %edx,%edx
  801fc9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801fcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fd1:	89 f3                	mov    %esi,%ebx
  801fd3:	89 3c 24             	mov    %edi,(%esp)
  801fd6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fda:	75 1c                	jne    801ff8 <__umoddi3+0x48>
  801fdc:	39 f7                	cmp    %esi,%edi
  801fde:	76 50                	jbe    802030 <__umoddi3+0x80>
  801fe0:	89 c8                	mov    %ecx,%eax
  801fe2:	89 f2                	mov    %esi,%edx
  801fe4:	f7 f7                	div    %edi
  801fe6:	89 d0                	mov    %edx,%eax
  801fe8:	31 d2                	xor    %edx,%edx
  801fea:	83 c4 1c             	add    $0x1c,%esp
  801fed:	5b                   	pop    %ebx
  801fee:	5e                   	pop    %esi
  801fef:	5f                   	pop    %edi
  801ff0:	5d                   	pop    %ebp
  801ff1:	c3                   	ret    
  801ff2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ff8:	39 f2                	cmp    %esi,%edx
  801ffa:	89 d0                	mov    %edx,%eax
  801ffc:	77 52                	ja     802050 <__umoddi3+0xa0>
  801ffe:	0f bd ea             	bsr    %edx,%ebp
  802001:	83 f5 1f             	xor    $0x1f,%ebp
  802004:	75 5a                	jne    802060 <__umoddi3+0xb0>
  802006:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80200a:	0f 82 e0 00 00 00    	jb     8020f0 <__umoddi3+0x140>
  802010:	39 0c 24             	cmp    %ecx,(%esp)
  802013:	0f 86 d7 00 00 00    	jbe    8020f0 <__umoddi3+0x140>
  802019:	8b 44 24 08          	mov    0x8(%esp),%eax
  80201d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802021:	83 c4 1c             	add    $0x1c,%esp
  802024:	5b                   	pop    %ebx
  802025:	5e                   	pop    %esi
  802026:	5f                   	pop    %edi
  802027:	5d                   	pop    %ebp
  802028:	c3                   	ret    
  802029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802030:	85 ff                	test   %edi,%edi
  802032:	89 fd                	mov    %edi,%ebp
  802034:	75 0b                	jne    802041 <__umoddi3+0x91>
  802036:	b8 01 00 00 00       	mov    $0x1,%eax
  80203b:	31 d2                	xor    %edx,%edx
  80203d:	f7 f7                	div    %edi
  80203f:	89 c5                	mov    %eax,%ebp
  802041:	89 f0                	mov    %esi,%eax
  802043:	31 d2                	xor    %edx,%edx
  802045:	f7 f5                	div    %ebp
  802047:	89 c8                	mov    %ecx,%eax
  802049:	f7 f5                	div    %ebp
  80204b:	89 d0                	mov    %edx,%eax
  80204d:	eb 99                	jmp    801fe8 <__umoddi3+0x38>
  80204f:	90                   	nop
  802050:	89 c8                	mov    %ecx,%eax
  802052:	89 f2                	mov    %esi,%edx
  802054:	83 c4 1c             	add    $0x1c,%esp
  802057:	5b                   	pop    %ebx
  802058:	5e                   	pop    %esi
  802059:	5f                   	pop    %edi
  80205a:	5d                   	pop    %ebp
  80205b:	c3                   	ret    
  80205c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802060:	8b 34 24             	mov    (%esp),%esi
  802063:	bf 20 00 00 00       	mov    $0x20,%edi
  802068:	89 e9                	mov    %ebp,%ecx
  80206a:	29 ef                	sub    %ebp,%edi
  80206c:	d3 e0                	shl    %cl,%eax
  80206e:	89 f9                	mov    %edi,%ecx
  802070:	89 f2                	mov    %esi,%edx
  802072:	d3 ea                	shr    %cl,%edx
  802074:	89 e9                	mov    %ebp,%ecx
  802076:	09 c2                	or     %eax,%edx
  802078:	89 d8                	mov    %ebx,%eax
  80207a:	89 14 24             	mov    %edx,(%esp)
  80207d:	89 f2                	mov    %esi,%edx
  80207f:	d3 e2                	shl    %cl,%edx
  802081:	89 f9                	mov    %edi,%ecx
  802083:	89 54 24 04          	mov    %edx,0x4(%esp)
  802087:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80208b:	d3 e8                	shr    %cl,%eax
  80208d:	89 e9                	mov    %ebp,%ecx
  80208f:	89 c6                	mov    %eax,%esi
  802091:	d3 e3                	shl    %cl,%ebx
  802093:	89 f9                	mov    %edi,%ecx
  802095:	89 d0                	mov    %edx,%eax
  802097:	d3 e8                	shr    %cl,%eax
  802099:	89 e9                	mov    %ebp,%ecx
  80209b:	09 d8                	or     %ebx,%eax
  80209d:	89 d3                	mov    %edx,%ebx
  80209f:	89 f2                	mov    %esi,%edx
  8020a1:	f7 34 24             	divl   (%esp)
  8020a4:	89 d6                	mov    %edx,%esi
  8020a6:	d3 e3                	shl    %cl,%ebx
  8020a8:	f7 64 24 04          	mull   0x4(%esp)
  8020ac:	39 d6                	cmp    %edx,%esi
  8020ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020b2:	89 d1                	mov    %edx,%ecx
  8020b4:	89 c3                	mov    %eax,%ebx
  8020b6:	72 08                	jb     8020c0 <__umoddi3+0x110>
  8020b8:	75 11                	jne    8020cb <__umoddi3+0x11b>
  8020ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8020be:	73 0b                	jae    8020cb <__umoddi3+0x11b>
  8020c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8020c4:	1b 14 24             	sbb    (%esp),%edx
  8020c7:	89 d1                	mov    %edx,%ecx
  8020c9:	89 c3                	mov    %eax,%ebx
  8020cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8020cf:	29 da                	sub    %ebx,%edx
  8020d1:	19 ce                	sbb    %ecx,%esi
  8020d3:	89 f9                	mov    %edi,%ecx
  8020d5:	89 f0                	mov    %esi,%eax
  8020d7:	d3 e0                	shl    %cl,%eax
  8020d9:	89 e9                	mov    %ebp,%ecx
  8020db:	d3 ea                	shr    %cl,%edx
  8020dd:	89 e9                	mov    %ebp,%ecx
  8020df:	d3 ee                	shr    %cl,%esi
  8020e1:	09 d0                	or     %edx,%eax
  8020e3:	89 f2                	mov    %esi,%edx
  8020e5:	83 c4 1c             	add    $0x1c,%esp
  8020e8:	5b                   	pop    %ebx
  8020e9:	5e                   	pop    %esi
  8020ea:	5f                   	pop    %edi
  8020eb:	5d                   	pop    %ebp
  8020ec:	c3                   	ret    
  8020ed:	8d 76 00             	lea    0x0(%esi),%esi
  8020f0:	29 f9                	sub    %edi,%ecx
  8020f2:	19 d6                	sbb    %edx,%esi
  8020f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020fc:	e9 18 ff ff ff       	jmp    802019 <__umoddi3+0x69>
