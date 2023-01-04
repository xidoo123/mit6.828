
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
  80003c:	e8 00 0e 00 00       	call   800e41 <fork>
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
  800054:	68 60 21 80 00       	push   $0x802160
  800059:	e8 53 01 00 00       	call   8001b1 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 f6 0f 00 00       	call   801062 <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 7c 0f 00 00       	call   800ffb <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 72 0a 00 00       	call   800afb <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 76 21 80 00       	push   $0x802176
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
  8000a9:	e8 b4 0f 00 00       	call   801062 <ipc_send>
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
  80010a:	e8 ab 11 00 00       	call   8012ba <close_all>
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
  800214:	e8 a7 1c 00 00       	call   801ec0 <__udivdi3>
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
  800257:	e8 94 1d 00 00       	call   801ff0 <__umoddi3>
  80025c:	83 c4 14             	add    $0x14,%esp
  80025f:	0f be 80 93 21 80 00 	movsbl 0x802193(%eax),%eax
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
  80035b:	ff 24 85 e0 22 80 00 	jmp    *0x8022e0(,%eax,4)
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
  80041f:	8b 14 85 40 24 80 00 	mov    0x802440(,%eax,4),%edx
  800426:	85 d2                	test   %edx,%edx
  800428:	75 18                	jne    800442 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80042a:	50                   	push   %eax
  80042b:	68 ab 21 80 00       	push   $0x8021ab
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
  800443:	68 5d 26 80 00       	push   $0x80265d
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
  800467:	b8 a4 21 80 00       	mov    $0x8021a4,%eax
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
  800ae2:	68 9f 24 80 00       	push   $0x80249f
  800ae7:	6a 23                	push   $0x23
  800ae9:	68 bc 24 80 00       	push   $0x8024bc
  800aee:	e8 d9 12 00 00       	call   801dcc <_panic>

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
  800b63:	68 9f 24 80 00       	push   $0x80249f
  800b68:	6a 23                	push   $0x23
  800b6a:	68 bc 24 80 00       	push   $0x8024bc
  800b6f:	e8 58 12 00 00       	call   801dcc <_panic>

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
  800ba5:	68 9f 24 80 00       	push   $0x80249f
  800baa:	6a 23                	push   $0x23
  800bac:	68 bc 24 80 00       	push   $0x8024bc
  800bb1:	e8 16 12 00 00       	call   801dcc <_panic>

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
  800be7:	68 9f 24 80 00       	push   $0x80249f
  800bec:	6a 23                	push   $0x23
  800bee:	68 bc 24 80 00       	push   $0x8024bc
  800bf3:	e8 d4 11 00 00       	call   801dcc <_panic>

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
  800c29:	68 9f 24 80 00       	push   $0x80249f
  800c2e:	6a 23                	push   $0x23
  800c30:	68 bc 24 80 00       	push   $0x8024bc
  800c35:	e8 92 11 00 00       	call   801dcc <_panic>

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
  800c6b:	68 9f 24 80 00       	push   $0x80249f
  800c70:	6a 23                	push   $0x23
  800c72:	68 bc 24 80 00       	push   $0x8024bc
  800c77:	e8 50 11 00 00       	call   801dcc <_panic>

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
  800cad:	68 9f 24 80 00       	push   $0x80249f
  800cb2:	6a 23                	push   $0x23
  800cb4:	68 bc 24 80 00       	push   $0x8024bc
  800cb9:	e8 0e 11 00 00       	call   801dcc <_panic>

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
  800d11:	68 9f 24 80 00       	push   $0x80249f
  800d16:	6a 23                	push   $0x23
  800d18:	68 bc 24 80 00       	push   $0x8024bc
  800d1d:	e8 aa 10 00 00       	call   801dcc <_panic>

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
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
  800d30:	83 ec 0c             	sub    $0xc,%esp
  800d33:	8b 75 08             	mov    0x8(%ebp),%esi
	void *addr = (void *) utf->utf_fault_va;
  800d36:	8b 1e                	mov    (%esi),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800d38:	f6 46 04 02          	testb  $0x2,0x4(%esi)
  800d3c:	75 25                	jne    800d63 <pgfault+0x39>
  800d3e:	89 d8                	mov    %ebx,%eax
  800d40:	c1 e8 0c             	shr    $0xc,%eax
  800d43:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d4a:	f6 c4 08             	test   $0x8,%ah
  800d4d:	75 14                	jne    800d63 <pgfault+0x39>
		panic("pgfault: not due to a write or a COW page");
  800d4f:	83 ec 04             	sub    $0x4,%esp
  800d52:	68 cc 24 80 00       	push   $0x8024cc
  800d57:	6a 1e                	push   $0x1e
  800d59:	68 60 25 80 00       	push   $0x802560
  800d5e:	e8 69 10 00 00       	call   801dcc <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800d63:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800d69:	e8 8d fd ff ff       	call   800afb <sys_getenvid>
  800d6e:	89 c7                	mov    %eax,%edi

	if ( (uint32_t)addr ==  0xeebfd000) {
  800d70:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  800d76:	75 31                	jne    800da9 <pgfault+0x7f>
		cprintf("[hit %e]\n", utf->utf_err);
  800d78:	83 ec 08             	sub    $0x8,%esp
  800d7b:	ff 76 04             	pushl  0x4(%esi)
  800d7e:	68 6b 25 80 00       	push   $0x80256b
  800d83:	e8 29 f4 ff ff       	call   8001b1 <cprintf>
		cprintf("[hit 0x%x]\n", utf->utf_eip);
  800d88:	83 c4 08             	add    $0x8,%esp
  800d8b:	ff 76 28             	pushl  0x28(%esi)
  800d8e:	68 75 25 80 00       	push   $0x802575
  800d93:	e8 19 f4 ff ff       	call   8001b1 <cprintf>
		cprintf("[hit %d]\n", envid);
  800d98:	83 c4 08             	add    $0x8,%esp
  800d9b:	57                   	push   %edi
  800d9c:	68 81 25 80 00       	push   $0x802581
  800da1:	e8 0b f4 ff ff       	call   8001b1 <cprintf>
  800da6:	83 c4 10             	add    $0x10,%esp
	}

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800da9:	83 ec 04             	sub    $0x4,%esp
  800dac:	6a 07                	push   $0x7
  800dae:	68 00 f0 7f 00       	push   $0x7ff000
  800db3:	57                   	push   %edi
  800db4:	e8 80 fd ff ff       	call   800b39 <sys_page_alloc>
	if (r < 0)
  800db9:	83 c4 10             	add    $0x10,%esp
  800dbc:	85 c0                	test   %eax,%eax
  800dbe:	79 12                	jns    800dd2 <pgfault+0xa8>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800dc0:	50                   	push   %eax
  800dc1:	68 f8 24 80 00       	push   $0x8024f8
  800dc6:	6a 39                	push   $0x39
  800dc8:	68 60 25 80 00       	push   $0x802560
  800dcd:	e8 fa 0f 00 00       	call   801dcc <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800dd2:	83 ec 04             	sub    $0x4,%esp
  800dd5:	68 00 10 00 00       	push   $0x1000
  800dda:	53                   	push   %ebx
  800ddb:	68 00 f0 7f 00       	push   $0x7ff000
  800de0:	e8 4b fb ff ff       	call   800930 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800de5:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800dec:	53                   	push   %ebx
  800ded:	57                   	push   %edi
  800dee:	68 00 f0 7f 00       	push   $0x7ff000
  800df3:	57                   	push   %edi
  800df4:	e8 83 fd ff ff       	call   800b7c <sys_page_map>
	if (r < 0)
  800df9:	83 c4 20             	add    $0x20,%esp
  800dfc:	85 c0                	test   %eax,%eax
  800dfe:	79 12                	jns    800e12 <pgfault+0xe8>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800e00:	50                   	push   %eax
  800e01:	68 1c 25 80 00       	push   $0x80251c
  800e06:	6a 41                	push   $0x41
  800e08:	68 60 25 80 00       	push   $0x802560
  800e0d:	e8 ba 0f 00 00       	call   801dcc <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800e12:	83 ec 08             	sub    $0x8,%esp
  800e15:	68 00 f0 7f 00       	push   $0x7ff000
  800e1a:	57                   	push   %edi
  800e1b:	e8 9e fd ff ff       	call   800bbe <sys_page_unmap>
	if (r < 0)
  800e20:	83 c4 10             	add    $0x10,%esp
  800e23:	85 c0                	test   %eax,%eax
  800e25:	79 12                	jns    800e39 <pgfault+0x10f>
        panic("pgfault: page unmap failed: %e\n", r);
  800e27:	50                   	push   %eax
  800e28:	68 40 25 80 00       	push   $0x802540
  800e2d:	6a 46                	push   $0x46
  800e2f:	68 60 25 80 00       	push   $0x802560
  800e34:	e8 93 0f 00 00       	call   801dcc <_panic>
}
  800e39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3c:	5b                   	pop    %ebx
  800e3d:	5e                   	pop    %esi
  800e3e:	5f                   	pop    %edi
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    

00800e41 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	57                   	push   %edi
  800e45:	56                   	push   %esi
  800e46:	53                   	push   %ebx
  800e47:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800e4a:	68 2a 0d 80 00       	push   $0x800d2a
  800e4f:	e8 be 0f 00 00       	call   801e12 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e54:	b8 07 00 00 00       	mov    $0x7,%eax
  800e59:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800e5b:	83 c4 10             	add    $0x10,%esp
  800e5e:	85 c0                	test   %eax,%eax
  800e60:	0f 88 67 01 00 00    	js     800fcd <fork+0x18c>
  800e66:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800e6b:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800e70:	85 c0                	test   %eax,%eax
  800e72:	75 21                	jne    800e95 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e74:	e8 82 fc ff ff       	call   800afb <sys_getenvid>
  800e79:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e7e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e81:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e86:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  800e8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e90:	e9 42 01 00 00       	jmp    800fd7 <fork+0x196>
  800e95:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e98:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800e9a:	89 d8                	mov    %ebx,%eax
  800e9c:	c1 e8 16             	shr    $0x16,%eax
  800e9f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ea6:	a8 01                	test   $0x1,%al
  800ea8:	0f 84 c0 00 00 00    	je     800f6e <fork+0x12d>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800eae:	89 d8                	mov    %ebx,%eax
  800eb0:	c1 e8 0c             	shr    $0xc,%eax
  800eb3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800eba:	f6 c2 01             	test   $0x1,%dl
  800ebd:	0f 84 ab 00 00 00    	je     800f6e <fork+0x12d>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
  800ec3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eca:	a9 02 08 00 00       	test   $0x802,%eax
  800ecf:	0f 84 99 00 00 00    	je     800f6e <fork+0x12d>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800ed5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800edc:	f6 c4 04             	test   $0x4,%ah
  800edf:	74 17                	je     800ef8 <fork+0xb7>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800ee1:	83 ec 0c             	sub    $0xc,%esp
  800ee4:	68 07 0e 00 00       	push   $0xe07
  800ee9:	53                   	push   %ebx
  800eea:	57                   	push   %edi
  800eeb:	53                   	push   %ebx
  800eec:	6a 00                	push   $0x0
  800eee:	e8 89 fc ff ff       	call   800b7c <sys_page_map>
  800ef3:	83 c4 20             	add    $0x20,%esp
  800ef6:	eb 76                	jmp    800f6e <fork+0x12d>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800ef8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800eff:	a8 02                	test   $0x2,%al
  800f01:	75 0c                	jne    800f0f <fork+0xce>
  800f03:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f0a:	f6 c4 08             	test   $0x8,%ah
  800f0d:	74 3f                	je     800f4e <fork+0x10d>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f0f:	83 ec 0c             	sub    $0xc,%esp
  800f12:	68 05 08 00 00       	push   $0x805
  800f17:	53                   	push   %ebx
  800f18:	57                   	push   %edi
  800f19:	53                   	push   %ebx
  800f1a:	6a 00                	push   $0x0
  800f1c:	e8 5b fc ff ff       	call   800b7c <sys_page_map>
		if (r < 0)
  800f21:	83 c4 20             	add    $0x20,%esp
  800f24:	85 c0                	test   %eax,%eax
  800f26:	0f 88 a5 00 00 00    	js     800fd1 <fork+0x190>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f2c:	83 ec 0c             	sub    $0xc,%esp
  800f2f:	68 05 08 00 00       	push   $0x805
  800f34:	53                   	push   %ebx
  800f35:	6a 00                	push   $0x0
  800f37:	53                   	push   %ebx
  800f38:	6a 00                	push   $0x0
  800f3a:	e8 3d fc ff ff       	call   800b7c <sys_page_map>
  800f3f:	83 c4 20             	add    $0x20,%esp
  800f42:	85 c0                	test   %eax,%eax
  800f44:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f49:	0f 4f c1             	cmovg  %ecx,%eax
  800f4c:	eb 1c                	jmp    800f6a <fork+0x129>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  800f4e:	83 ec 0c             	sub    $0xc,%esp
  800f51:	6a 05                	push   $0x5
  800f53:	53                   	push   %ebx
  800f54:	57                   	push   %edi
  800f55:	53                   	push   %ebx
  800f56:	6a 00                	push   $0x0
  800f58:	e8 1f fc ff ff       	call   800b7c <sys_page_map>
  800f5d:	83 c4 20             	add    $0x20,%esp
  800f60:	85 c0                	test   %eax,%eax
  800f62:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f67:	0f 4f c1             	cmovg  %ecx,%eax
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  800f6a:	85 c0                	test   %eax,%eax
  800f6c:	78 67                	js     800fd5 <fork+0x194>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  800f6e:	83 c6 01             	add    $0x1,%esi
  800f71:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f77:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  800f7d:	0f 85 17 ff ff ff    	jne    800e9a <fork+0x59>
  800f83:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  800f86:	83 ec 04             	sub    $0x4,%esp
  800f89:	6a 07                	push   $0x7
  800f8b:	68 00 f0 bf ee       	push   $0xeebff000
  800f90:	57                   	push   %edi
  800f91:	e8 a3 fb ff ff       	call   800b39 <sys_page_alloc>
	if (r < 0)
  800f96:	83 c4 10             	add    $0x10,%esp
		return r;
  800f99:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	78 38                	js     800fd7 <fork+0x196>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800f9f:	83 ec 08             	sub    $0x8,%esp
  800fa2:	68 59 1e 80 00       	push   $0x801e59
  800fa7:	57                   	push   %edi
  800fa8:	e8 d7 fc ff ff       	call   800c84 <sys_env_set_pgfault_upcall>
	if (r < 0)
  800fad:	83 c4 10             	add    $0x10,%esp
		return r;
  800fb0:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	78 21                	js     800fd7 <fork+0x196>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  800fb6:	83 ec 08             	sub    $0x8,%esp
  800fb9:	6a 02                	push   $0x2
  800fbb:	57                   	push   %edi
  800fbc:	e8 3f fc ff ff       	call   800c00 <sys_env_set_status>
	if (r < 0)
  800fc1:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	0f 48 f8             	cmovs  %eax,%edi
  800fc9:	89 fa                	mov    %edi,%edx
  800fcb:	eb 0a                	jmp    800fd7 <fork+0x196>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  800fcd:	89 c2                	mov    %eax,%edx
  800fcf:	eb 06                	jmp    800fd7 <fork+0x196>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800fd1:	89 c2                	mov    %eax,%edx
  800fd3:	eb 02                	jmp    800fd7 <fork+0x196>
  800fd5:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  800fd7:	89 d0                	mov    %edx,%eax
  800fd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fdc:	5b                   	pop    %ebx
  800fdd:	5e                   	pop    %esi
  800fde:	5f                   	pop    %edi
  800fdf:	5d                   	pop    %ebp
  800fe0:	c3                   	ret    

00800fe1 <sfork>:

// Challenge!
int
sfork(void)
{
  800fe1:	55                   	push   %ebp
  800fe2:	89 e5                	mov    %esp,%ebp
  800fe4:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fe7:	68 8b 25 80 00       	push   $0x80258b
  800fec:	68 ce 00 00 00       	push   $0xce
  800ff1:	68 60 25 80 00       	push   $0x802560
  800ff6:	e8 d1 0d 00 00       	call   801dcc <_panic>

00800ffb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	56                   	push   %esi
  800fff:	53                   	push   %ebx
  801000:	8b 75 08             	mov    0x8(%ebp),%esi
  801003:	8b 45 0c             	mov    0xc(%ebp),%eax
  801006:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801009:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  80100b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801010:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801013:	83 ec 0c             	sub    $0xc,%esp
  801016:	50                   	push   %eax
  801017:	e8 cd fc ff ff       	call   800ce9 <sys_ipc_recv>

	if (from_env_store != NULL)
  80101c:	83 c4 10             	add    $0x10,%esp
  80101f:	85 f6                	test   %esi,%esi
  801021:	74 14                	je     801037 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801023:	ba 00 00 00 00       	mov    $0x0,%edx
  801028:	85 c0                	test   %eax,%eax
  80102a:	78 09                	js     801035 <ipc_recv+0x3a>
  80102c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801032:	8b 52 74             	mov    0x74(%edx),%edx
  801035:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801037:	85 db                	test   %ebx,%ebx
  801039:	74 14                	je     80104f <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  80103b:	ba 00 00 00 00       	mov    $0x0,%edx
  801040:	85 c0                	test   %eax,%eax
  801042:	78 09                	js     80104d <ipc_recv+0x52>
  801044:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80104a:	8b 52 78             	mov    0x78(%edx),%edx
  80104d:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  80104f:	85 c0                	test   %eax,%eax
  801051:	78 08                	js     80105b <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801053:	a1 04 40 80 00       	mov    0x804004,%eax
  801058:	8b 40 70             	mov    0x70(%eax),%eax
}
  80105b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80105e:	5b                   	pop    %ebx
  80105f:	5e                   	pop    %esi
  801060:	5d                   	pop    %ebp
  801061:	c3                   	ret    

00801062 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801062:	55                   	push   %ebp
  801063:	89 e5                	mov    %esp,%ebp
  801065:	57                   	push   %edi
  801066:	56                   	push   %esi
  801067:	53                   	push   %ebx
  801068:	83 ec 0c             	sub    $0xc,%esp
  80106b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80106e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801071:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801074:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801076:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80107b:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  80107e:	ff 75 14             	pushl  0x14(%ebp)
  801081:	53                   	push   %ebx
  801082:	56                   	push   %esi
  801083:	57                   	push   %edi
  801084:	e8 3d fc ff ff       	call   800cc6 <sys_ipc_try_send>

		if (err < 0) {
  801089:	83 c4 10             	add    $0x10,%esp
  80108c:	85 c0                	test   %eax,%eax
  80108e:	79 1e                	jns    8010ae <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801090:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801093:	75 07                	jne    80109c <ipc_send+0x3a>
				sys_yield();
  801095:	e8 80 fa ff ff       	call   800b1a <sys_yield>
  80109a:	eb e2                	jmp    80107e <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  80109c:	50                   	push   %eax
  80109d:	68 a1 25 80 00       	push   $0x8025a1
  8010a2:	6a 49                	push   $0x49
  8010a4:	68 ae 25 80 00       	push   $0x8025ae
  8010a9:	e8 1e 0d 00 00       	call   801dcc <_panic>
		}

	} while (err < 0);

}
  8010ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b1:	5b                   	pop    %ebx
  8010b2:	5e                   	pop    %esi
  8010b3:	5f                   	pop    %edi
  8010b4:	5d                   	pop    %ebp
  8010b5:	c3                   	ret    

008010b6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8010b6:	55                   	push   %ebp
  8010b7:	89 e5                	mov    %esp,%ebp
  8010b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8010bc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8010c1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8010c4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8010ca:	8b 52 50             	mov    0x50(%edx),%edx
  8010cd:	39 ca                	cmp    %ecx,%edx
  8010cf:	75 0d                	jne    8010de <ipc_find_env+0x28>
			return envs[i].env_id;
  8010d1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010d4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010d9:	8b 40 48             	mov    0x48(%eax),%eax
  8010dc:	eb 0f                	jmp    8010ed <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8010de:	83 c0 01             	add    $0x1,%eax
  8010e1:	3d 00 04 00 00       	cmp    $0x400,%eax
  8010e6:	75 d9                	jne    8010c1 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8010e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010ed:	5d                   	pop    %ebp
  8010ee:	c3                   	ret    

008010ef <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010ef:	55                   	push   %ebp
  8010f0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f5:	05 00 00 00 30       	add    $0x30000000,%eax
  8010fa:	c1 e8 0c             	shr    $0xc,%eax
}
  8010fd:	5d                   	pop    %ebp
  8010fe:	c3                   	ret    

008010ff <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801102:	8b 45 08             	mov    0x8(%ebp),%eax
  801105:	05 00 00 00 30       	add    $0x30000000,%eax
  80110a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80110f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801114:	5d                   	pop    %ebp
  801115:	c3                   	ret    

00801116 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801116:	55                   	push   %ebp
  801117:	89 e5                	mov    %esp,%ebp
  801119:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80111c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801121:	89 c2                	mov    %eax,%edx
  801123:	c1 ea 16             	shr    $0x16,%edx
  801126:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80112d:	f6 c2 01             	test   $0x1,%dl
  801130:	74 11                	je     801143 <fd_alloc+0x2d>
  801132:	89 c2                	mov    %eax,%edx
  801134:	c1 ea 0c             	shr    $0xc,%edx
  801137:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80113e:	f6 c2 01             	test   $0x1,%dl
  801141:	75 09                	jne    80114c <fd_alloc+0x36>
			*fd_store = fd;
  801143:	89 01                	mov    %eax,(%ecx)
			return 0;
  801145:	b8 00 00 00 00       	mov    $0x0,%eax
  80114a:	eb 17                	jmp    801163 <fd_alloc+0x4d>
  80114c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801151:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801156:	75 c9                	jne    801121 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801158:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80115e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801163:	5d                   	pop    %ebp
  801164:	c3                   	ret    

00801165 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801165:	55                   	push   %ebp
  801166:	89 e5                	mov    %esp,%ebp
  801168:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80116b:	83 f8 1f             	cmp    $0x1f,%eax
  80116e:	77 36                	ja     8011a6 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801170:	c1 e0 0c             	shl    $0xc,%eax
  801173:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801178:	89 c2                	mov    %eax,%edx
  80117a:	c1 ea 16             	shr    $0x16,%edx
  80117d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801184:	f6 c2 01             	test   $0x1,%dl
  801187:	74 24                	je     8011ad <fd_lookup+0x48>
  801189:	89 c2                	mov    %eax,%edx
  80118b:	c1 ea 0c             	shr    $0xc,%edx
  80118e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801195:	f6 c2 01             	test   $0x1,%dl
  801198:	74 1a                	je     8011b4 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80119a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80119d:	89 02                	mov    %eax,(%edx)
	return 0;
  80119f:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a4:	eb 13                	jmp    8011b9 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ab:	eb 0c                	jmp    8011b9 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b2:	eb 05                	jmp    8011b9 <fd_lookup+0x54>
  8011b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011b9:	5d                   	pop    %ebp
  8011ba:	c3                   	ret    

008011bb <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011bb:	55                   	push   %ebp
  8011bc:	89 e5                	mov    %esp,%ebp
  8011be:	83 ec 08             	sub    $0x8,%esp
  8011c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011c4:	ba 34 26 80 00       	mov    $0x802634,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011c9:	eb 13                	jmp    8011de <dev_lookup+0x23>
  8011cb:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011ce:	39 08                	cmp    %ecx,(%eax)
  8011d0:	75 0c                	jne    8011de <dev_lookup+0x23>
			*dev = devtab[i];
  8011d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8011dc:	eb 2e                	jmp    80120c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011de:	8b 02                	mov    (%edx),%eax
  8011e0:	85 c0                	test   %eax,%eax
  8011e2:	75 e7                	jne    8011cb <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011e4:	a1 04 40 80 00       	mov    0x804004,%eax
  8011e9:	8b 40 48             	mov    0x48(%eax),%eax
  8011ec:	83 ec 04             	sub    $0x4,%esp
  8011ef:	51                   	push   %ecx
  8011f0:	50                   	push   %eax
  8011f1:	68 b8 25 80 00       	push   $0x8025b8
  8011f6:	e8 b6 ef ff ff       	call   8001b1 <cprintf>
	*dev = 0;
  8011fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011fe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801204:	83 c4 10             	add    $0x10,%esp
  801207:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80120c:	c9                   	leave  
  80120d:	c3                   	ret    

0080120e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80120e:	55                   	push   %ebp
  80120f:	89 e5                	mov    %esp,%ebp
  801211:	56                   	push   %esi
  801212:	53                   	push   %ebx
  801213:	83 ec 10             	sub    $0x10,%esp
  801216:	8b 75 08             	mov    0x8(%ebp),%esi
  801219:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80121c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80121f:	50                   	push   %eax
  801220:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801226:	c1 e8 0c             	shr    $0xc,%eax
  801229:	50                   	push   %eax
  80122a:	e8 36 ff ff ff       	call   801165 <fd_lookup>
  80122f:	83 c4 08             	add    $0x8,%esp
  801232:	85 c0                	test   %eax,%eax
  801234:	78 05                	js     80123b <fd_close+0x2d>
	    || fd != fd2)
  801236:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801239:	74 0c                	je     801247 <fd_close+0x39>
		return (must_exist ? r : 0);
  80123b:	84 db                	test   %bl,%bl
  80123d:	ba 00 00 00 00       	mov    $0x0,%edx
  801242:	0f 44 c2             	cmove  %edx,%eax
  801245:	eb 41                	jmp    801288 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801247:	83 ec 08             	sub    $0x8,%esp
  80124a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124d:	50                   	push   %eax
  80124e:	ff 36                	pushl  (%esi)
  801250:	e8 66 ff ff ff       	call   8011bb <dev_lookup>
  801255:	89 c3                	mov    %eax,%ebx
  801257:	83 c4 10             	add    $0x10,%esp
  80125a:	85 c0                	test   %eax,%eax
  80125c:	78 1a                	js     801278 <fd_close+0x6a>
		if (dev->dev_close)
  80125e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801261:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801264:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801269:	85 c0                	test   %eax,%eax
  80126b:	74 0b                	je     801278 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80126d:	83 ec 0c             	sub    $0xc,%esp
  801270:	56                   	push   %esi
  801271:	ff d0                	call   *%eax
  801273:	89 c3                	mov    %eax,%ebx
  801275:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801278:	83 ec 08             	sub    $0x8,%esp
  80127b:	56                   	push   %esi
  80127c:	6a 00                	push   $0x0
  80127e:	e8 3b f9 ff ff       	call   800bbe <sys_page_unmap>
	return r;
  801283:	83 c4 10             	add    $0x10,%esp
  801286:	89 d8                	mov    %ebx,%eax
}
  801288:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80128b:	5b                   	pop    %ebx
  80128c:	5e                   	pop    %esi
  80128d:	5d                   	pop    %ebp
  80128e:	c3                   	ret    

0080128f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801295:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801298:	50                   	push   %eax
  801299:	ff 75 08             	pushl  0x8(%ebp)
  80129c:	e8 c4 fe ff ff       	call   801165 <fd_lookup>
  8012a1:	83 c4 08             	add    $0x8,%esp
  8012a4:	85 c0                	test   %eax,%eax
  8012a6:	78 10                	js     8012b8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012a8:	83 ec 08             	sub    $0x8,%esp
  8012ab:	6a 01                	push   $0x1
  8012ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8012b0:	e8 59 ff ff ff       	call   80120e <fd_close>
  8012b5:	83 c4 10             	add    $0x10,%esp
}
  8012b8:	c9                   	leave  
  8012b9:	c3                   	ret    

008012ba <close_all>:

void
close_all(void)
{
  8012ba:	55                   	push   %ebp
  8012bb:	89 e5                	mov    %esp,%ebp
  8012bd:	53                   	push   %ebx
  8012be:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012c1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012c6:	83 ec 0c             	sub    $0xc,%esp
  8012c9:	53                   	push   %ebx
  8012ca:	e8 c0 ff ff ff       	call   80128f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012cf:	83 c3 01             	add    $0x1,%ebx
  8012d2:	83 c4 10             	add    $0x10,%esp
  8012d5:	83 fb 20             	cmp    $0x20,%ebx
  8012d8:	75 ec                	jne    8012c6 <close_all+0xc>
		close(i);
}
  8012da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012dd:	c9                   	leave  
  8012de:	c3                   	ret    

008012df <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012df:	55                   	push   %ebp
  8012e0:	89 e5                	mov    %esp,%ebp
  8012e2:	57                   	push   %edi
  8012e3:	56                   	push   %esi
  8012e4:	53                   	push   %ebx
  8012e5:	83 ec 2c             	sub    $0x2c,%esp
  8012e8:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012eb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012ee:	50                   	push   %eax
  8012ef:	ff 75 08             	pushl  0x8(%ebp)
  8012f2:	e8 6e fe ff ff       	call   801165 <fd_lookup>
  8012f7:	83 c4 08             	add    $0x8,%esp
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	0f 88 c1 00 00 00    	js     8013c3 <dup+0xe4>
		return r;
	close(newfdnum);
  801302:	83 ec 0c             	sub    $0xc,%esp
  801305:	56                   	push   %esi
  801306:	e8 84 ff ff ff       	call   80128f <close>

	newfd = INDEX2FD(newfdnum);
  80130b:	89 f3                	mov    %esi,%ebx
  80130d:	c1 e3 0c             	shl    $0xc,%ebx
  801310:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801316:	83 c4 04             	add    $0x4,%esp
  801319:	ff 75 e4             	pushl  -0x1c(%ebp)
  80131c:	e8 de fd ff ff       	call   8010ff <fd2data>
  801321:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801323:	89 1c 24             	mov    %ebx,(%esp)
  801326:	e8 d4 fd ff ff       	call   8010ff <fd2data>
  80132b:	83 c4 10             	add    $0x10,%esp
  80132e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801331:	89 f8                	mov    %edi,%eax
  801333:	c1 e8 16             	shr    $0x16,%eax
  801336:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80133d:	a8 01                	test   $0x1,%al
  80133f:	74 37                	je     801378 <dup+0x99>
  801341:	89 f8                	mov    %edi,%eax
  801343:	c1 e8 0c             	shr    $0xc,%eax
  801346:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80134d:	f6 c2 01             	test   $0x1,%dl
  801350:	74 26                	je     801378 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801352:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801359:	83 ec 0c             	sub    $0xc,%esp
  80135c:	25 07 0e 00 00       	and    $0xe07,%eax
  801361:	50                   	push   %eax
  801362:	ff 75 d4             	pushl  -0x2c(%ebp)
  801365:	6a 00                	push   $0x0
  801367:	57                   	push   %edi
  801368:	6a 00                	push   $0x0
  80136a:	e8 0d f8 ff ff       	call   800b7c <sys_page_map>
  80136f:	89 c7                	mov    %eax,%edi
  801371:	83 c4 20             	add    $0x20,%esp
  801374:	85 c0                	test   %eax,%eax
  801376:	78 2e                	js     8013a6 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801378:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80137b:	89 d0                	mov    %edx,%eax
  80137d:	c1 e8 0c             	shr    $0xc,%eax
  801380:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801387:	83 ec 0c             	sub    $0xc,%esp
  80138a:	25 07 0e 00 00       	and    $0xe07,%eax
  80138f:	50                   	push   %eax
  801390:	53                   	push   %ebx
  801391:	6a 00                	push   $0x0
  801393:	52                   	push   %edx
  801394:	6a 00                	push   $0x0
  801396:	e8 e1 f7 ff ff       	call   800b7c <sys_page_map>
  80139b:	89 c7                	mov    %eax,%edi
  80139d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013a0:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013a2:	85 ff                	test   %edi,%edi
  8013a4:	79 1d                	jns    8013c3 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013a6:	83 ec 08             	sub    $0x8,%esp
  8013a9:	53                   	push   %ebx
  8013aa:	6a 00                	push   $0x0
  8013ac:	e8 0d f8 ff ff       	call   800bbe <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013b1:	83 c4 08             	add    $0x8,%esp
  8013b4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013b7:	6a 00                	push   $0x0
  8013b9:	e8 00 f8 ff ff       	call   800bbe <sys_page_unmap>
	return r;
  8013be:	83 c4 10             	add    $0x10,%esp
  8013c1:	89 f8                	mov    %edi,%eax
}
  8013c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c6:	5b                   	pop    %ebx
  8013c7:	5e                   	pop    %esi
  8013c8:	5f                   	pop    %edi
  8013c9:	5d                   	pop    %ebp
  8013ca:	c3                   	ret    

008013cb <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013cb:	55                   	push   %ebp
  8013cc:	89 e5                	mov    %esp,%ebp
  8013ce:	53                   	push   %ebx
  8013cf:	83 ec 14             	sub    $0x14,%esp
  8013d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d8:	50                   	push   %eax
  8013d9:	53                   	push   %ebx
  8013da:	e8 86 fd ff ff       	call   801165 <fd_lookup>
  8013df:	83 c4 08             	add    $0x8,%esp
  8013e2:	89 c2                	mov    %eax,%edx
  8013e4:	85 c0                	test   %eax,%eax
  8013e6:	78 6d                	js     801455 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e8:	83 ec 08             	sub    $0x8,%esp
  8013eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ee:	50                   	push   %eax
  8013ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f2:	ff 30                	pushl  (%eax)
  8013f4:	e8 c2 fd ff ff       	call   8011bb <dev_lookup>
  8013f9:	83 c4 10             	add    $0x10,%esp
  8013fc:	85 c0                	test   %eax,%eax
  8013fe:	78 4c                	js     80144c <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801400:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801403:	8b 42 08             	mov    0x8(%edx),%eax
  801406:	83 e0 03             	and    $0x3,%eax
  801409:	83 f8 01             	cmp    $0x1,%eax
  80140c:	75 21                	jne    80142f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80140e:	a1 04 40 80 00       	mov    0x804004,%eax
  801413:	8b 40 48             	mov    0x48(%eax),%eax
  801416:	83 ec 04             	sub    $0x4,%esp
  801419:	53                   	push   %ebx
  80141a:	50                   	push   %eax
  80141b:	68 f9 25 80 00       	push   $0x8025f9
  801420:	e8 8c ed ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  801425:	83 c4 10             	add    $0x10,%esp
  801428:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80142d:	eb 26                	jmp    801455 <read+0x8a>
	}
	if (!dev->dev_read)
  80142f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801432:	8b 40 08             	mov    0x8(%eax),%eax
  801435:	85 c0                	test   %eax,%eax
  801437:	74 17                	je     801450 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801439:	83 ec 04             	sub    $0x4,%esp
  80143c:	ff 75 10             	pushl  0x10(%ebp)
  80143f:	ff 75 0c             	pushl  0xc(%ebp)
  801442:	52                   	push   %edx
  801443:	ff d0                	call   *%eax
  801445:	89 c2                	mov    %eax,%edx
  801447:	83 c4 10             	add    $0x10,%esp
  80144a:	eb 09                	jmp    801455 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80144c:	89 c2                	mov    %eax,%edx
  80144e:	eb 05                	jmp    801455 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801450:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801455:	89 d0                	mov    %edx,%eax
  801457:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80145a:	c9                   	leave  
  80145b:	c3                   	ret    

0080145c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80145c:	55                   	push   %ebp
  80145d:	89 e5                	mov    %esp,%ebp
  80145f:	57                   	push   %edi
  801460:	56                   	push   %esi
  801461:	53                   	push   %ebx
  801462:	83 ec 0c             	sub    $0xc,%esp
  801465:	8b 7d 08             	mov    0x8(%ebp),%edi
  801468:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80146b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801470:	eb 21                	jmp    801493 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801472:	83 ec 04             	sub    $0x4,%esp
  801475:	89 f0                	mov    %esi,%eax
  801477:	29 d8                	sub    %ebx,%eax
  801479:	50                   	push   %eax
  80147a:	89 d8                	mov    %ebx,%eax
  80147c:	03 45 0c             	add    0xc(%ebp),%eax
  80147f:	50                   	push   %eax
  801480:	57                   	push   %edi
  801481:	e8 45 ff ff ff       	call   8013cb <read>
		if (m < 0)
  801486:	83 c4 10             	add    $0x10,%esp
  801489:	85 c0                	test   %eax,%eax
  80148b:	78 10                	js     80149d <readn+0x41>
			return m;
		if (m == 0)
  80148d:	85 c0                	test   %eax,%eax
  80148f:	74 0a                	je     80149b <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801491:	01 c3                	add    %eax,%ebx
  801493:	39 f3                	cmp    %esi,%ebx
  801495:	72 db                	jb     801472 <readn+0x16>
  801497:	89 d8                	mov    %ebx,%eax
  801499:	eb 02                	jmp    80149d <readn+0x41>
  80149b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80149d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014a0:	5b                   	pop    %ebx
  8014a1:	5e                   	pop    %esi
  8014a2:	5f                   	pop    %edi
  8014a3:	5d                   	pop    %ebp
  8014a4:	c3                   	ret    

008014a5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014a5:	55                   	push   %ebp
  8014a6:	89 e5                	mov    %esp,%ebp
  8014a8:	53                   	push   %ebx
  8014a9:	83 ec 14             	sub    $0x14,%esp
  8014ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014b2:	50                   	push   %eax
  8014b3:	53                   	push   %ebx
  8014b4:	e8 ac fc ff ff       	call   801165 <fd_lookup>
  8014b9:	83 c4 08             	add    $0x8,%esp
  8014bc:	89 c2                	mov    %eax,%edx
  8014be:	85 c0                	test   %eax,%eax
  8014c0:	78 68                	js     80152a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014c2:	83 ec 08             	sub    $0x8,%esp
  8014c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c8:	50                   	push   %eax
  8014c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014cc:	ff 30                	pushl  (%eax)
  8014ce:	e8 e8 fc ff ff       	call   8011bb <dev_lookup>
  8014d3:	83 c4 10             	add    $0x10,%esp
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	78 47                	js     801521 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014dd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014e1:	75 21                	jne    801504 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014e3:	a1 04 40 80 00       	mov    0x804004,%eax
  8014e8:	8b 40 48             	mov    0x48(%eax),%eax
  8014eb:	83 ec 04             	sub    $0x4,%esp
  8014ee:	53                   	push   %ebx
  8014ef:	50                   	push   %eax
  8014f0:	68 15 26 80 00       	push   $0x802615
  8014f5:	e8 b7 ec ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  8014fa:	83 c4 10             	add    $0x10,%esp
  8014fd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801502:	eb 26                	jmp    80152a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801504:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801507:	8b 52 0c             	mov    0xc(%edx),%edx
  80150a:	85 d2                	test   %edx,%edx
  80150c:	74 17                	je     801525 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80150e:	83 ec 04             	sub    $0x4,%esp
  801511:	ff 75 10             	pushl  0x10(%ebp)
  801514:	ff 75 0c             	pushl  0xc(%ebp)
  801517:	50                   	push   %eax
  801518:	ff d2                	call   *%edx
  80151a:	89 c2                	mov    %eax,%edx
  80151c:	83 c4 10             	add    $0x10,%esp
  80151f:	eb 09                	jmp    80152a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801521:	89 c2                	mov    %eax,%edx
  801523:	eb 05                	jmp    80152a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801525:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80152a:	89 d0                	mov    %edx,%eax
  80152c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80152f:	c9                   	leave  
  801530:	c3                   	ret    

00801531 <seek>:

int
seek(int fdnum, off_t offset)
{
  801531:	55                   	push   %ebp
  801532:	89 e5                	mov    %esp,%ebp
  801534:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801537:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80153a:	50                   	push   %eax
  80153b:	ff 75 08             	pushl  0x8(%ebp)
  80153e:	e8 22 fc ff ff       	call   801165 <fd_lookup>
  801543:	83 c4 08             	add    $0x8,%esp
  801546:	85 c0                	test   %eax,%eax
  801548:	78 0e                	js     801558 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80154a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80154d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801550:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801553:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801558:	c9                   	leave  
  801559:	c3                   	ret    

0080155a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80155a:	55                   	push   %ebp
  80155b:	89 e5                	mov    %esp,%ebp
  80155d:	53                   	push   %ebx
  80155e:	83 ec 14             	sub    $0x14,%esp
  801561:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801564:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801567:	50                   	push   %eax
  801568:	53                   	push   %ebx
  801569:	e8 f7 fb ff ff       	call   801165 <fd_lookup>
  80156e:	83 c4 08             	add    $0x8,%esp
  801571:	89 c2                	mov    %eax,%edx
  801573:	85 c0                	test   %eax,%eax
  801575:	78 65                	js     8015dc <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801577:	83 ec 08             	sub    $0x8,%esp
  80157a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157d:	50                   	push   %eax
  80157e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801581:	ff 30                	pushl  (%eax)
  801583:	e8 33 fc ff ff       	call   8011bb <dev_lookup>
  801588:	83 c4 10             	add    $0x10,%esp
  80158b:	85 c0                	test   %eax,%eax
  80158d:	78 44                	js     8015d3 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80158f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801592:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801596:	75 21                	jne    8015b9 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801598:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80159d:	8b 40 48             	mov    0x48(%eax),%eax
  8015a0:	83 ec 04             	sub    $0x4,%esp
  8015a3:	53                   	push   %ebx
  8015a4:	50                   	push   %eax
  8015a5:	68 d8 25 80 00       	push   $0x8025d8
  8015aa:	e8 02 ec ff ff       	call   8001b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015af:	83 c4 10             	add    $0x10,%esp
  8015b2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015b7:	eb 23                	jmp    8015dc <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015bc:	8b 52 18             	mov    0x18(%edx),%edx
  8015bf:	85 d2                	test   %edx,%edx
  8015c1:	74 14                	je     8015d7 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015c3:	83 ec 08             	sub    $0x8,%esp
  8015c6:	ff 75 0c             	pushl  0xc(%ebp)
  8015c9:	50                   	push   %eax
  8015ca:	ff d2                	call   *%edx
  8015cc:	89 c2                	mov    %eax,%edx
  8015ce:	83 c4 10             	add    $0x10,%esp
  8015d1:	eb 09                	jmp    8015dc <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d3:	89 c2                	mov    %eax,%edx
  8015d5:	eb 05                	jmp    8015dc <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015d7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015dc:	89 d0                	mov    %edx,%eax
  8015de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e1:	c9                   	leave  
  8015e2:	c3                   	ret    

008015e3 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015e3:	55                   	push   %ebp
  8015e4:	89 e5                	mov    %esp,%ebp
  8015e6:	53                   	push   %ebx
  8015e7:	83 ec 14             	sub    $0x14,%esp
  8015ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f0:	50                   	push   %eax
  8015f1:	ff 75 08             	pushl  0x8(%ebp)
  8015f4:	e8 6c fb ff ff       	call   801165 <fd_lookup>
  8015f9:	83 c4 08             	add    $0x8,%esp
  8015fc:	89 c2                	mov    %eax,%edx
  8015fe:	85 c0                	test   %eax,%eax
  801600:	78 58                	js     80165a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801602:	83 ec 08             	sub    $0x8,%esp
  801605:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801608:	50                   	push   %eax
  801609:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160c:	ff 30                	pushl  (%eax)
  80160e:	e8 a8 fb ff ff       	call   8011bb <dev_lookup>
  801613:	83 c4 10             	add    $0x10,%esp
  801616:	85 c0                	test   %eax,%eax
  801618:	78 37                	js     801651 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80161a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80161d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801621:	74 32                	je     801655 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801623:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801626:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80162d:	00 00 00 
	stat->st_isdir = 0;
  801630:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801637:	00 00 00 
	stat->st_dev = dev;
  80163a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801640:	83 ec 08             	sub    $0x8,%esp
  801643:	53                   	push   %ebx
  801644:	ff 75 f0             	pushl  -0x10(%ebp)
  801647:	ff 50 14             	call   *0x14(%eax)
  80164a:	89 c2                	mov    %eax,%edx
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	eb 09                	jmp    80165a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801651:	89 c2                	mov    %eax,%edx
  801653:	eb 05                	jmp    80165a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801655:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80165a:	89 d0                	mov    %edx,%eax
  80165c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165f:	c9                   	leave  
  801660:	c3                   	ret    

00801661 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801661:	55                   	push   %ebp
  801662:	89 e5                	mov    %esp,%ebp
  801664:	56                   	push   %esi
  801665:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801666:	83 ec 08             	sub    $0x8,%esp
  801669:	6a 00                	push   $0x0
  80166b:	ff 75 08             	pushl  0x8(%ebp)
  80166e:	e8 d6 01 00 00       	call   801849 <open>
  801673:	89 c3                	mov    %eax,%ebx
  801675:	83 c4 10             	add    $0x10,%esp
  801678:	85 c0                	test   %eax,%eax
  80167a:	78 1b                	js     801697 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80167c:	83 ec 08             	sub    $0x8,%esp
  80167f:	ff 75 0c             	pushl  0xc(%ebp)
  801682:	50                   	push   %eax
  801683:	e8 5b ff ff ff       	call   8015e3 <fstat>
  801688:	89 c6                	mov    %eax,%esi
	close(fd);
  80168a:	89 1c 24             	mov    %ebx,(%esp)
  80168d:	e8 fd fb ff ff       	call   80128f <close>
	return r;
  801692:	83 c4 10             	add    $0x10,%esp
  801695:	89 f0                	mov    %esi,%eax
}
  801697:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80169a:	5b                   	pop    %ebx
  80169b:	5e                   	pop    %esi
  80169c:	5d                   	pop    %ebp
  80169d:	c3                   	ret    

0080169e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80169e:	55                   	push   %ebp
  80169f:	89 e5                	mov    %esp,%ebp
  8016a1:	56                   	push   %esi
  8016a2:	53                   	push   %ebx
  8016a3:	89 c6                	mov    %eax,%esi
  8016a5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016a7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016ae:	75 12                	jne    8016c2 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016b0:	83 ec 0c             	sub    $0xc,%esp
  8016b3:	6a 01                	push   $0x1
  8016b5:	e8 fc f9 ff ff       	call   8010b6 <ipc_find_env>
  8016ba:	a3 00 40 80 00       	mov    %eax,0x804000
  8016bf:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016c2:	6a 07                	push   $0x7
  8016c4:	68 00 50 80 00       	push   $0x805000
  8016c9:	56                   	push   %esi
  8016ca:	ff 35 00 40 80 00    	pushl  0x804000
  8016d0:	e8 8d f9 ff ff       	call   801062 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016d5:	83 c4 0c             	add    $0xc,%esp
  8016d8:	6a 00                	push   $0x0
  8016da:	53                   	push   %ebx
  8016db:	6a 00                	push   $0x0
  8016dd:	e8 19 f9 ff ff       	call   800ffb <ipc_recv>
}
  8016e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016e5:	5b                   	pop    %ebx
  8016e6:	5e                   	pop    %esi
  8016e7:	5d                   	pop    %ebp
  8016e8:	c3                   	ret    

008016e9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016e9:	55                   	push   %ebp
  8016ea:	89 e5                	mov    %esp,%ebp
  8016ec:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f2:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016fd:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801702:	ba 00 00 00 00       	mov    $0x0,%edx
  801707:	b8 02 00 00 00       	mov    $0x2,%eax
  80170c:	e8 8d ff ff ff       	call   80169e <fsipc>
}
  801711:	c9                   	leave  
  801712:	c3                   	ret    

00801713 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801719:	8b 45 08             	mov    0x8(%ebp),%eax
  80171c:	8b 40 0c             	mov    0xc(%eax),%eax
  80171f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801724:	ba 00 00 00 00       	mov    $0x0,%edx
  801729:	b8 06 00 00 00       	mov    $0x6,%eax
  80172e:	e8 6b ff ff ff       	call   80169e <fsipc>
}
  801733:	c9                   	leave  
  801734:	c3                   	ret    

00801735 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801735:	55                   	push   %ebp
  801736:	89 e5                	mov    %esp,%ebp
  801738:	53                   	push   %ebx
  801739:	83 ec 04             	sub    $0x4,%esp
  80173c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80173f:	8b 45 08             	mov    0x8(%ebp),%eax
  801742:	8b 40 0c             	mov    0xc(%eax),%eax
  801745:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80174a:	ba 00 00 00 00       	mov    $0x0,%edx
  80174f:	b8 05 00 00 00       	mov    $0x5,%eax
  801754:	e8 45 ff ff ff       	call   80169e <fsipc>
  801759:	85 c0                	test   %eax,%eax
  80175b:	78 2c                	js     801789 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80175d:	83 ec 08             	sub    $0x8,%esp
  801760:	68 00 50 80 00       	push   $0x805000
  801765:	53                   	push   %ebx
  801766:	e8 cb ef ff ff       	call   800736 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80176b:	a1 80 50 80 00       	mov    0x805080,%eax
  801770:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801776:	a1 84 50 80 00       	mov    0x805084,%eax
  80177b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801781:	83 c4 10             	add    $0x10,%esp
  801784:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801789:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80178c:	c9                   	leave  
  80178d:	c3                   	ret    

0080178e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80178e:	55                   	push   %ebp
  80178f:	89 e5                	mov    %esp,%ebp
  801791:	83 ec 0c             	sub    $0xc,%esp
  801794:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801797:	8b 55 08             	mov    0x8(%ebp),%edx
  80179a:	8b 52 0c             	mov    0xc(%edx),%edx
  80179d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8017a3:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017a8:	50                   	push   %eax
  8017a9:	ff 75 0c             	pushl  0xc(%ebp)
  8017ac:	68 08 50 80 00       	push   $0x805008
  8017b1:	e8 12 f1 ff ff       	call   8008c8 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8017b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017bb:	b8 04 00 00 00       	mov    $0x4,%eax
  8017c0:	e8 d9 fe ff ff       	call   80169e <fsipc>

}
  8017c5:	c9                   	leave  
  8017c6:	c3                   	ret    

008017c7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	56                   	push   %esi
  8017cb:	53                   	push   %ebx
  8017cc:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d2:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017da:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e5:	b8 03 00 00 00       	mov    $0x3,%eax
  8017ea:	e8 af fe ff ff       	call   80169e <fsipc>
  8017ef:	89 c3                	mov    %eax,%ebx
  8017f1:	85 c0                	test   %eax,%eax
  8017f3:	78 4b                	js     801840 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017f5:	39 c6                	cmp    %eax,%esi
  8017f7:	73 16                	jae    80180f <devfile_read+0x48>
  8017f9:	68 44 26 80 00       	push   $0x802644
  8017fe:	68 4b 26 80 00       	push   $0x80264b
  801803:	6a 7c                	push   $0x7c
  801805:	68 60 26 80 00       	push   $0x802660
  80180a:	e8 bd 05 00 00       	call   801dcc <_panic>
	assert(r <= PGSIZE);
  80180f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801814:	7e 16                	jle    80182c <devfile_read+0x65>
  801816:	68 6b 26 80 00       	push   $0x80266b
  80181b:	68 4b 26 80 00       	push   $0x80264b
  801820:	6a 7d                	push   $0x7d
  801822:	68 60 26 80 00       	push   $0x802660
  801827:	e8 a0 05 00 00       	call   801dcc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80182c:	83 ec 04             	sub    $0x4,%esp
  80182f:	50                   	push   %eax
  801830:	68 00 50 80 00       	push   $0x805000
  801835:	ff 75 0c             	pushl  0xc(%ebp)
  801838:	e8 8b f0 ff ff       	call   8008c8 <memmove>
	return r;
  80183d:	83 c4 10             	add    $0x10,%esp
}
  801840:	89 d8                	mov    %ebx,%eax
  801842:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801845:	5b                   	pop    %ebx
  801846:	5e                   	pop    %esi
  801847:	5d                   	pop    %ebp
  801848:	c3                   	ret    

00801849 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801849:	55                   	push   %ebp
  80184a:	89 e5                	mov    %esp,%ebp
  80184c:	53                   	push   %ebx
  80184d:	83 ec 20             	sub    $0x20,%esp
  801850:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801853:	53                   	push   %ebx
  801854:	e8 a4 ee ff ff       	call   8006fd <strlen>
  801859:	83 c4 10             	add    $0x10,%esp
  80185c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801861:	7f 67                	jg     8018ca <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801863:	83 ec 0c             	sub    $0xc,%esp
  801866:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801869:	50                   	push   %eax
  80186a:	e8 a7 f8 ff ff       	call   801116 <fd_alloc>
  80186f:	83 c4 10             	add    $0x10,%esp
		return r;
  801872:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801874:	85 c0                	test   %eax,%eax
  801876:	78 57                	js     8018cf <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801878:	83 ec 08             	sub    $0x8,%esp
  80187b:	53                   	push   %ebx
  80187c:	68 00 50 80 00       	push   $0x805000
  801881:	e8 b0 ee ff ff       	call   800736 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801886:	8b 45 0c             	mov    0xc(%ebp),%eax
  801889:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80188e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801891:	b8 01 00 00 00       	mov    $0x1,%eax
  801896:	e8 03 fe ff ff       	call   80169e <fsipc>
  80189b:	89 c3                	mov    %eax,%ebx
  80189d:	83 c4 10             	add    $0x10,%esp
  8018a0:	85 c0                	test   %eax,%eax
  8018a2:	79 14                	jns    8018b8 <open+0x6f>
		fd_close(fd, 0);
  8018a4:	83 ec 08             	sub    $0x8,%esp
  8018a7:	6a 00                	push   $0x0
  8018a9:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ac:	e8 5d f9 ff ff       	call   80120e <fd_close>
		return r;
  8018b1:	83 c4 10             	add    $0x10,%esp
  8018b4:	89 da                	mov    %ebx,%edx
  8018b6:	eb 17                	jmp    8018cf <open+0x86>
	}

	return fd2num(fd);
  8018b8:	83 ec 0c             	sub    $0xc,%esp
  8018bb:	ff 75 f4             	pushl  -0xc(%ebp)
  8018be:	e8 2c f8 ff ff       	call   8010ef <fd2num>
  8018c3:	89 c2                	mov    %eax,%edx
  8018c5:	83 c4 10             	add    $0x10,%esp
  8018c8:	eb 05                	jmp    8018cf <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018ca:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018cf:	89 d0                	mov    %edx,%eax
  8018d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d4:	c9                   	leave  
  8018d5:	c3                   	ret    

008018d6 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018d6:	55                   	push   %ebp
  8018d7:	89 e5                	mov    %esp,%ebp
  8018d9:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e1:	b8 08 00 00 00       	mov    $0x8,%eax
  8018e6:	e8 b3 fd ff ff       	call   80169e <fsipc>
}
  8018eb:	c9                   	leave  
  8018ec:	c3                   	ret    

008018ed <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018ed:	55                   	push   %ebp
  8018ee:	89 e5                	mov    %esp,%ebp
  8018f0:	56                   	push   %esi
  8018f1:	53                   	push   %ebx
  8018f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018f5:	83 ec 0c             	sub    $0xc,%esp
  8018f8:	ff 75 08             	pushl  0x8(%ebp)
  8018fb:	e8 ff f7 ff ff       	call   8010ff <fd2data>
  801900:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801902:	83 c4 08             	add    $0x8,%esp
  801905:	68 77 26 80 00       	push   $0x802677
  80190a:	53                   	push   %ebx
  80190b:	e8 26 ee ff ff       	call   800736 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801910:	8b 46 04             	mov    0x4(%esi),%eax
  801913:	2b 06                	sub    (%esi),%eax
  801915:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80191b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801922:	00 00 00 
	stat->st_dev = &devpipe;
  801925:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80192c:	30 80 00 
	return 0;
}
  80192f:	b8 00 00 00 00       	mov    $0x0,%eax
  801934:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801937:	5b                   	pop    %ebx
  801938:	5e                   	pop    %esi
  801939:	5d                   	pop    %ebp
  80193a:	c3                   	ret    

0080193b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80193b:	55                   	push   %ebp
  80193c:	89 e5                	mov    %esp,%ebp
  80193e:	53                   	push   %ebx
  80193f:	83 ec 0c             	sub    $0xc,%esp
  801942:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801945:	53                   	push   %ebx
  801946:	6a 00                	push   $0x0
  801948:	e8 71 f2 ff ff       	call   800bbe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80194d:	89 1c 24             	mov    %ebx,(%esp)
  801950:	e8 aa f7 ff ff       	call   8010ff <fd2data>
  801955:	83 c4 08             	add    $0x8,%esp
  801958:	50                   	push   %eax
  801959:	6a 00                	push   $0x0
  80195b:	e8 5e f2 ff ff       	call   800bbe <sys_page_unmap>
}
  801960:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801963:	c9                   	leave  
  801964:	c3                   	ret    

00801965 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801965:	55                   	push   %ebp
  801966:	89 e5                	mov    %esp,%ebp
  801968:	57                   	push   %edi
  801969:	56                   	push   %esi
  80196a:	53                   	push   %ebx
  80196b:	83 ec 1c             	sub    $0x1c,%esp
  80196e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801971:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801973:	a1 04 40 80 00       	mov    0x804004,%eax
  801978:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80197b:	83 ec 0c             	sub    $0xc,%esp
  80197e:	ff 75 e0             	pushl  -0x20(%ebp)
  801981:	e8 f7 04 00 00       	call   801e7d <pageref>
  801986:	89 c3                	mov    %eax,%ebx
  801988:	89 3c 24             	mov    %edi,(%esp)
  80198b:	e8 ed 04 00 00       	call   801e7d <pageref>
  801990:	83 c4 10             	add    $0x10,%esp
  801993:	39 c3                	cmp    %eax,%ebx
  801995:	0f 94 c1             	sete   %cl
  801998:	0f b6 c9             	movzbl %cl,%ecx
  80199b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80199e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8019a4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019a7:	39 ce                	cmp    %ecx,%esi
  8019a9:	74 1b                	je     8019c6 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8019ab:	39 c3                	cmp    %eax,%ebx
  8019ad:	75 c4                	jne    801973 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019af:	8b 42 58             	mov    0x58(%edx),%eax
  8019b2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019b5:	50                   	push   %eax
  8019b6:	56                   	push   %esi
  8019b7:	68 7e 26 80 00       	push   $0x80267e
  8019bc:	e8 f0 e7 ff ff       	call   8001b1 <cprintf>
  8019c1:	83 c4 10             	add    $0x10,%esp
  8019c4:	eb ad                	jmp    801973 <_pipeisclosed+0xe>
	}
}
  8019c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019cc:	5b                   	pop    %ebx
  8019cd:	5e                   	pop    %esi
  8019ce:	5f                   	pop    %edi
  8019cf:	5d                   	pop    %ebp
  8019d0:	c3                   	ret    

008019d1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019d1:	55                   	push   %ebp
  8019d2:	89 e5                	mov    %esp,%ebp
  8019d4:	57                   	push   %edi
  8019d5:	56                   	push   %esi
  8019d6:	53                   	push   %ebx
  8019d7:	83 ec 28             	sub    $0x28,%esp
  8019da:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019dd:	56                   	push   %esi
  8019de:	e8 1c f7 ff ff       	call   8010ff <fd2data>
  8019e3:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019e5:	83 c4 10             	add    $0x10,%esp
  8019e8:	bf 00 00 00 00       	mov    $0x0,%edi
  8019ed:	eb 4b                	jmp    801a3a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019ef:	89 da                	mov    %ebx,%edx
  8019f1:	89 f0                	mov    %esi,%eax
  8019f3:	e8 6d ff ff ff       	call   801965 <_pipeisclosed>
  8019f8:	85 c0                	test   %eax,%eax
  8019fa:	75 48                	jne    801a44 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019fc:	e8 19 f1 ff ff       	call   800b1a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a01:	8b 43 04             	mov    0x4(%ebx),%eax
  801a04:	8b 0b                	mov    (%ebx),%ecx
  801a06:	8d 51 20             	lea    0x20(%ecx),%edx
  801a09:	39 d0                	cmp    %edx,%eax
  801a0b:	73 e2                	jae    8019ef <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a10:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a14:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a17:	89 c2                	mov    %eax,%edx
  801a19:	c1 fa 1f             	sar    $0x1f,%edx
  801a1c:	89 d1                	mov    %edx,%ecx
  801a1e:	c1 e9 1b             	shr    $0x1b,%ecx
  801a21:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a24:	83 e2 1f             	and    $0x1f,%edx
  801a27:	29 ca                	sub    %ecx,%edx
  801a29:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a2d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a31:	83 c0 01             	add    $0x1,%eax
  801a34:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a37:	83 c7 01             	add    $0x1,%edi
  801a3a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a3d:	75 c2                	jne    801a01 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a3f:	8b 45 10             	mov    0x10(%ebp),%eax
  801a42:	eb 05                	jmp    801a49 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a44:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a4c:	5b                   	pop    %ebx
  801a4d:	5e                   	pop    %esi
  801a4e:	5f                   	pop    %edi
  801a4f:	5d                   	pop    %ebp
  801a50:	c3                   	ret    

00801a51 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a51:	55                   	push   %ebp
  801a52:	89 e5                	mov    %esp,%ebp
  801a54:	57                   	push   %edi
  801a55:	56                   	push   %esi
  801a56:	53                   	push   %ebx
  801a57:	83 ec 18             	sub    $0x18,%esp
  801a5a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a5d:	57                   	push   %edi
  801a5e:	e8 9c f6 ff ff       	call   8010ff <fd2data>
  801a63:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a65:	83 c4 10             	add    $0x10,%esp
  801a68:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a6d:	eb 3d                	jmp    801aac <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a6f:	85 db                	test   %ebx,%ebx
  801a71:	74 04                	je     801a77 <devpipe_read+0x26>
				return i;
  801a73:	89 d8                	mov    %ebx,%eax
  801a75:	eb 44                	jmp    801abb <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a77:	89 f2                	mov    %esi,%edx
  801a79:	89 f8                	mov    %edi,%eax
  801a7b:	e8 e5 fe ff ff       	call   801965 <_pipeisclosed>
  801a80:	85 c0                	test   %eax,%eax
  801a82:	75 32                	jne    801ab6 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a84:	e8 91 f0 ff ff       	call   800b1a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a89:	8b 06                	mov    (%esi),%eax
  801a8b:	3b 46 04             	cmp    0x4(%esi),%eax
  801a8e:	74 df                	je     801a6f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a90:	99                   	cltd   
  801a91:	c1 ea 1b             	shr    $0x1b,%edx
  801a94:	01 d0                	add    %edx,%eax
  801a96:	83 e0 1f             	and    $0x1f,%eax
  801a99:	29 d0                	sub    %edx,%eax
  801a9b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801aa0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aa3:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801aa6:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aa9:	83 c3 01             	add    $0x1,%ebx
  801aac:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801aaf:	75 d8                	jne    801a89 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ab1:	8b 45 10             	mov    0x10(%ebp),%eax
  801ab4:	eb 05                	jmp    801abb <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ab6:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801abb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801abe:	5b                   	pop    %ebx
  801abf:	5e                   	pop    %esi
  801ac0:	5f                   	pop    %edi
  801ac1:	5d                   	pop    %ebp
  801ac2:	c3                   	ret    

00801ac3 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ac3:	55                   	push   %ebp
  801ac4:	89 e5                	mov    %esp,%ebp
  801ac6:	56                   	push   %esi
  801ac7:	53                   	push   %ebx
  801ac8:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801acb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ace:	50                   	push   %eax
  801acf:	e8 42 f6 ff ff       	call   801116 <fd_alloc>
  801ad4:	83 c4 10             	add    $0x10,%esp
  801ad7:	89 c2                	mov    %eax,%edx
  801ad9:	85 c0                	test   %eax,%eax
  801adb:	0f 88 2c 01 00 00    	js     801c0d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ae1:	83 ec 04             	sub    $0x4,%esp
  801ae4:	68 07 04 00 00       	push   $0x407
  801ae9:	ff 75 f4             	pushl  -0xc(%ebp)
  801aec:	6a 00                	push   $0x0
  801aee:	e8 46 f0 ff ff       	call   800b39 <sys_page_alloc>
  801af3:	83 c4 10             	add    $0x10,%esp
  801af6:	89 c2                	mov    %eax,%edx
  801af8:	85 c0                	test   %eax,%eax
  801afa:	0f 88 0d 01 00 00    	js     801c0d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b00:	83 ec 0c             	sub    $0xc,%esp
  801b03:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b06:	50                   	push   %eax
  801b07:	e8 0a f6 ff ff       	call   801116 <fd_alloc>
  801b0c:	89 c3                	mov    %eax,%ebx
  801b0e:	83 c4 10             	add    $0x10,%esp
  801b11:	85 c0                	test   %eax,%eax
  801b13:	0f 88 e2 00 00 00    	js     801bfb <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b19:	83 ec 04             	sub    $0x4,%esp
  801b1c:	68 07 04 00 00       	push   $0x407
  801b21:	ff 75 f0             	pushl  -0x10(%ebp)
  801b24:	6a 00                	push   $0x0
  801b26:	e8 0e f0 ff ff       	call   800b39 <sys_page_alloc>
  801b2b:	89 c3                	mov    %eax,%ebx
  801b2d:	83 c4 10             	add    $0x10,%esp
  801b30:	85 c0                	test   %eax,%eax
  801b32:	0f 88 c3 00 00 00    	js     801bfb <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b38:	83 ec 0c             	sub    $0xc,%esp
  801b3b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b3e:	e8 bc f5 ff ff       	call   8010ff <fd2data>
  801b43:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b45:	83 c4 0c             	add    $0xc,%esp
  801b48:	68 07 04 00 00       	push   $0x407
  801b4d:	50                   	push   %eax
  801b4e:	6a 00                	push   $0x0
  801b50:	e8 e4 ef ff ff       	call   800b39 <sys_page_alloc>
  801b55:	89 c3                	mov    %eax,%ebx
  801b57:	83 c4 10             	add    $0x10,%esp
  801b5a:	85 c0                	test   %eax,%eax
  801b5c:	0f 88 89 00 00 00    	js     801beb <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b62:	83 ec 0c             	sub    $0xc,%esp
  801b65:	ff 75 f0             	pushl  -0x10(%ebp)
  801b68:	e8 92 f5 ff ff       	call   8010ff <fd2data>
  801b6d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b74:	50                   	push   %eax
  801b75:	6a 00                	push   $0x0
  801b77:	56                   	push   %esi
  801b78:	6a 00                	push   $0x0
  801b7a:	e8 fd ef ff ff       	call   800b7c <sys_page_map>
  801b7f:	89 c3                	mov    %eax,%ebx
  801b81:	83 c4 20             	add    $0x20,%esp
  801b84:	85 c0                	test   %eax,%eax
  801b86:	78 55                	js     801bdd <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b88:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b91:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b96:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b9d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ba3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ba6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ba8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bab:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801bb2:	83 ec 0c             	sub    $0xc,%esp
  801bb5:	ff 75 f4             	pushl  -0xc(%ebp)
  801bb8:	e8 32 f5 ff ff       	call   8010ef <fd2num>
  801bbd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bc0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bc2:	83 c4 04             	add    $0x4,%esp
  801bc5:	ff 75 f0             	pushl  -0x10(%ebp)
  801bc8:	e8 22 f5 ff ff       	call   8010ef <fd2num>
  801bcd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bd0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801bd3:	83 c4 10             	add    $0x10,%esp
  801bd6:	ba 00 00 00 00       	mov    $0x0,%edx
  801bdb:	eb 30                	jmp    801c0d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801bdd:	83 ec 08             	sub    $0x8,%esp
  801be0:	56                   	push   %esi
  801be1:	6a 00                	push   $0x0
  801be3:	e8 d6 ef ff ff       	call   800bbe <sys_page_unmap>
  801be8:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801beb:	83 ec 08             	sub    $0x8,%esp
  801bee:	ff 75 f0             	pushl  -0x10(%ebp)
  801bf1:	6a 00                	push   $0x0
  801bf3:	e8 c6 ef ff ff       	call   800bbe <sys_page_unmap>
  801bf8:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801bfb:	83 ec 08             	sub    $0x8,%esp
  801bfe:	ff 75 f4             	pushl  -0xc(%ebp)
  801c01:	6a 00                	push   $0x0
  801c03:	e8 b6 ef ff ff       	call   800bbe <sys_page_unmap>
  801c08:	83 c4 10             	add    $0x10,%esp
  801c0b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c0d:	89 d0                	mov    %edx,%eax
  801c0f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c12:	5b                   	pop    %ebx
  801c13:	5e                   	pop    %esi
  801c14:	5d                   	pop    %ebp
  801c15:	c3                   	ret    

00801c16 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c16:	55                   	push   %ebp
  801c17:	89 e5                	mov    %esp,%ebp
  801c19:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c1f:	50                   	push   %eax
  801c20:	ff 75 08             	pushl  0x8(%ebp)
  801c23:	e8 3d f5 ff ff       	call   801165 <fd_lookup>
  801c28:	83 c4 10             	add    $0x10,%esp
  801c2b:	85 c0                	test   %eax,%eax
  801c2d:	78 18                	js     801c47 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c2f:	83 ec 0c             	sub    $0xc,%esp
  801c32:	ff 75 f4             	pushl  -0xc(%ebp)
  801c35:	e8 c5 f4 ff ff       	call   8010ff <fd2data>
	return _pipeisclosed(fd, p);
  801c3a:	89 c2                	mov    %eax,%edx
  801c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3f:	e8 21 fd ff ff       	call   801965 <_pipeisclosed>
  801c44:	83 c4 10             	add    $0x10,%esp
}
  801c47:	c9                   	leave  
  801c48:	c3                   	ret    

00801c49 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c49:	55                   	push   %ebp
  801c4a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c4c:	b8 00 00 00 00       	mov    $0x0,%eax
  801c51:	5d                   	pop    %ebp
  801c52:	c3                   	ret    

00801c53 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c53:	55                   	push   %ebp
  801c54:	89 e5                	mov    %esp,%ebp
  801c56:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c59:	68 96 26 80 00       	push   $0x802696
  801c5e:	ff 75 0c             	pushl  0xc(%ebp)
  801c61:	e8 d0 ea ff ff       	call   800736 <strcpy>
	return 0;
}
  801c66:	b8 00 00 00 00       	mov    $0x0,%eax
  801c6b:	c9                   	leave  
  801c6c:	c3                   	ret    

00801c6d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c6d:	55                   	push   %ebp
  801c6e:	89 e5                	mov    %esp,%ebp
  801c70:	57                   	push   %edi
  801c71:	56                   	push   %esi
  801c72:	53                   	push   %ebx
  801c73:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c79:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c7e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c84:	eb 2d                	jmp    801cb3 <devcons_write+0x46>
		m = n - tot;
  801c86:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c89:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c8b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c8e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c93:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c96:	83 ec 04             	sub    $0x4,%esp
  801c99:	53                   	push   %ebx
  801c9a:	03 45 0c             	add    0xc(%ebp),%eax
  801c9d:	50                   	push   %eax
  801c9e:	57                   	push   %edi
  801c9f:	e8 24 ec ff ff       	call   8008c8 <memmove>
		sys_cputs(buf, m);
  801ca4:	83 c4 08             	add    $0x8,%esp
  801ca7:	53                   	push   %ebx
  801ca8:	57                   	push   %edi
  801ca9:	e8 cf ed ff ff       	call   800a7d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cae:	01 de                	add    %ebx,%esi
  801cb0:	83 c4 10             	add    $0x10,%esp
  801cb3:	89 f0                	mov    %esi,%eax
  801cb5:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cb8:	72 cc                	jb     801c86 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801cba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cbd:	5b                   	pop    %ebx
  801cbe:	5e                   	pop    %esi
  801cbf:	5f                   	pop    %edi
  801cc0:	5d                   	pop    %ebp
  801cc1:	c3                   	ret    

00801cc2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cc2:	55                   	push   %ebp
  801cc3:	89 e5                	mov    %esp,%ebp
  801cc5:	83 ec 08             	sub    $0x8,%esp
  801cc8:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ccd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cd1:	74 2a                	je     801cfd <devcons_read+0x3b>
  801cd3:	eb 05                	jmp    801cda <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801cd5:	e8 40 ee ff ff       	call   800b1a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801cda:	e8 bc ed ff ff       	call   800a9b <sys_cgetc>
  801cdf:	85 c0                	test   %eax,%eax
  801ce1:	74 f2                	je     801cd5 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ce3:	85 c0                	test   %eax,%eax
  801ce5:	78 16                	js     801cfd <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ce7:	83 f8 04             	cmp    $0x4,%eax
  801cea:	74 0c                	je     801cf8 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801cec:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cef:	88 02                	mov    %al,(%edx)
	return 1;
  801cf1:	b8 01 00 00 00       	mov    $0x1,%eax
  801cf6:	eb 05                	jmp    801cfd <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801cf8:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801cfd:	c9                   	leave  
  801cfe:	c3                   	ret    

00801cff <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801cff:	55                   	push   %ebp
  801d00:	89 e5                	mov    %esp,%ebp
  801d02:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d05:	8b 45 08             	mov    0x8(%ebp),%eax
  801d08:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d0b:	6a 01                	push   $0x1
  801d0d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d10:	50                   	push   %eax
  801d11:	e8 67 ed ff ff       	call   800a7d <sys_cputs>
}
  801d16:	83 c4 10             	add    $0x10,%esp
  801d19:	c9                   	leave  
  801d1a:	c3                   	ret    

00801d1b <getchar>:

int
getchar(void)
{
  801d1b:	55                   	push   %ebp
  801d1c:	89 e5                	mov    %esp,%ebp
  801d1e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d21:	6a 01                	push   $0x1
  801d23:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d26:	50                   	push   %eax
  801d27:	6a 00                	push   $0x0
  801d29:	e8 9d f6 ff ff       	call   8013cb <read>
	if (r < 0)
  801d2e:	83 c4 10             	add    $0x10,%esp
  801d31:	85 c0                	test   %eax,%eax
  801d33:	78 0f                	js     801d44 <getchar+0x29>
		return r;
	if (r < 1)
  801d35:	85 c0                	test   %eax,%eax
  801d37:	7e 06                	jle    801d3f <getchar+0x24>
		return -E_EOF;
	return c;
  801d39:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d3d:	eb 05                	jmp    801d44 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d3f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d44:	c9                   	leave  
  801d45:	c3                   	ret    

00801d46 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d46:	55                   	push   %ebp
  801d47:	89 e5                	mov    %esp,%ebp
  801d49:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d4f:	50                   	push   %eax
  801d50:	ff 75 08             	pushl  0x8(%ebp)
  801d53:	e8 0d f4 ff ff       	call   801165 <fd_lookup>
  801d58:	83 c4 10             	add    $0x10,%esp
  801d5b:	85 c0                	test   %eax,%eax
  801d5d:	78 11                	js     801d70 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d62:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d68:	39 10                	cmp    %edx,(%eax)
  801d6a:	0f 94 c0             	sete   %al
  801d6d:	0f b6 c0             	movzbl %al,%eax
}
  801d70:	c9                   	leave  
  801d71:	c3                   	ret    

00801d72 <opencons>:

int
opencons(void)
{
  801d72:	55                   	push   %ebp
  801d73:	89 e5                	mov    %esp,%ebp
  801d75:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d7b:	50                   	push   %eax
  801d7c:	e8 95 f3 ff ff       	call   801116 <fd_alloc>
  801d81:	83 c4 10             	add    $0x10,%esp
		return r;
  801d84:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d86:	85 c0                	test   %eax,%eax
  801d88:	78 3e                	js     801dc8 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d8a:	83 ec 04             	sub    $0x4,%esp
  801d8d:	68 07 04 00 00       	push   $0x407
  801d92:	ff 75 f4             	pushl  -0xc(%ebp)
  801d95:	6a 00                	push   $0x0
  801d97:	e8 9d ed ff ff       	call   800b39 <sys_page_alloc>
  801d9c:	83 c4 10             	add    $0x10,%esp
		return r;
  801d9f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801da1:	85 c0                	test   %eax,%eax
  801da3:	78 23                	js     801dc8 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801da5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dae:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801dba:	83 ec 0c             	sub    $0xc,%esp
  801dbd:	50                   	push   %eax
  801dbe:	e8 2c f3 ff ff       	call   8010ef <fd2num>
  801dc3:	89 c2                	mov    %eax,%edx
  801dc5:	83 c4 10             	add    $0x10,%esp
}
  801dc8:	89 d0                	mov    %edx,%eax
  801dca:	c9                   	leave  
  801dcb:	c3                   	ret    

00801dcc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801dcc:	55                   	push   %ebp
  801dcd:	89 e5                	mov    %esp,%ebp
  801dcf:	56                   	push   %esi
  801dd0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801dd1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801dd4:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801dda:	e8 1c ed ff ff       	call   800afb <sys_getenvid>
  801ddf:	83 ec 0c             	sub    $0xc,%esp
  801de2:	ff 75 0c             	pushl  0xc(%ebp)
  801de5:	ff 75 08             	pushl  0x8(%ebp)
  801de8:	56                   	push   %esi
  801de9:	50                   	push   %eax
  801dea:	68 a4 26 80 00       	push   $0x8026a4
  801def:	e8 bd e3 ff ff       	call   8001b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801df4:	83 c4 18             	add    $0x18,%esp
  801df7:	53                   	push   %ebx
  801df8:	ff 75 10             	pushl  0x10(%ebp)
  801dfb:	e8 60 e3 ff ff       	call   800160 <vcprintf>
	cprintf("\n");
  801e00:	c7 04 24 89 25 80 00 	movl   $0x802589,(%esp)
  801e07:	e8 a5 e3 ff ff       	call   8001b1 <cprintf>
  801e0c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e0f:	cc                   	int3   
  801e10:	eb fd                	jmp    801e0f <_panic+0x43>

00801e12 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e12:	55                   	push   %ebp
  801e13:	89 e5                	mov    %esp,%ebp
  801e15:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e18:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e1f:	75 2e                	jne    801e4f <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801e21:	e8 d5 ec ff ff       	call   800afb <sys_getenvid>
  801e26:	83 ec 04             	sub    $0x4,%esp
  801e29:	68 07 0e 00 00       	push   $0xe07
  801e2e:	68 00 f0 bf ee       	push   $0xeebff000
  801e33:	50                   	push   %eax
  801e34:	e8 00 ed ff ff       	call   800b39 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801e39:	e8 bd ec ff ff       	call   800afb <sys_getenvid>
  801e3e:	83 c4 08             	add    $0x8,%esp
  801e41:	68 59 1e 80 00       	push   $0x801e59
  801e46:	50                   	push   %eax
  801e47:	e8 38 ee ff ff       	call   800c84 <sys_env_set_pgfault_upcall>
  801e4c:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e52:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e57:	c9                   	leave  
  801e58:	c3                   	ret    

00801e59 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e59:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e5a:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e5f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e61:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  801e64:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  801e68:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  801e6c:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  801e6f:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  801e72:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  801e73:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  801e76:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  801e77:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  801e78:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  801e7c:	c3                   	ret    

00801e7d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e7d:	55                   	push   %ebp
  801e7e:	89 e5                	mov    %esp,%ebp
  801e80:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e83:	89 d0                	mov    %edx,%eax
  801e85:	c1 e8 16             	shr    $0x16,%eax
  801e88:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e8f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e94:	f6 c1 01             	test   $0x1,%cl
  801e97:	74 1d                	je     801eb6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e99:	c1 ea 0c             	shr    $0xc,%edx
  801e9c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ea3:	f6 c2 01             	test   $0x1,%dl
  801ea6:	74 0e                	je     801eb6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ea8:	c1 ea 0c             	shr    $0xc,%edx
  801eab:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801eb2:	ef 
  801eb3:	0f b7 c0             	movzwl %ax,%eax
}
  801eb6:	5d                   	pop    %ebp
  801eb7:	c3                   	ret    
  801eb8:	66 90                	xchg   %ax,%ax
  801eba:	66 90                	xchg   %ax,%ax
  801ebc:	66 90                	xchg   %ax,%ax
  801ebe:	66 90                	xchg   %ax,%ax

00801ec0 <__udivdi3>:
  801ec0:	55                   	push   %ebp
  801ec1:	57                   	push   %edi
  801ec2:	56                   	push   %esi
  801ec3:	53                   	push   %ebx
  801ec4:	83 ec 1c             	sub    $0x1c,%esp
  801ec7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801ecb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801ecf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ed3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ed7:	85 f6                	test   %esi,%esi
  801ed9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801edd:	89 ca                	mov    %ecx,%edx
  801edf:	89 f8                	mov    %edi,%eax
  801ee1:	75 3d                	jne    801f20 <__udivdi3+0x60>
  801ee3:	39 cf                	cmp    %ecx,%edi
  801ee5:	0f 87 c5 00 00 00    	ja     801fb0 <__udivdi3+0xf0>
  801eeb:	85 ff                	test   %edi,%edi
  801eed:	89 fd                	mov    %edi,%ebp
  801eef:	75 0b                	jne    801efc <__udivdi3+0x3c>
  801ef1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ef6:	31 d2                	xor    %edx,%edx
  801ef8:	f7 f7                	div    %edi
  801efa:	89 c5                	mov    %eax,%ebp
  801efc:	89 c8                	mov    %ecx,%eax
  801efe:	31 d2                	xor    %edx,%edx
  801f00:	f7 f5                	div    %ebp
  801f02:	89 c1                	mov    %eax,%ecx
  801f04:	89 d8                	mov    %ebx,%eax
  801f06:	89 cf                	mov    %ecx,%edi
  801f08:	f7 f5                	div    %ebp
  801f0a:	89 c3                	mov    %eax,%ebx
  801f0c:	89 d8                	mov    %ebx,%eax
  801f0e:	89 fa                	mov    %edi,%edx
  801f10:	83 c4 1c             	add    $0x1c,%esp
  801f13:	5b                   	pop    %ebx
  801f14:	5e                   	pop    %esi
  801f15:	5f                   	pop    %edi
  801f16:	5d                   	pop    %ebp
  801f17:	c3                   	ret    
  801f18:	90                   	nop
  801f19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f20:	39 ce                	cmp    %ecx,%esi
  801f22:	77 74                	ja     801f98 <__udivdi3+0xd8>
  801f24:	0f bd fe             	bsr    %esi,%edi
  801f27:	83 f7 1f             	xor    $0x1f,%edi
  801f2a:	0f 84 98 00 00 00    	je     801fc8 <__udivdi3+0x108>
  801f30:	bb 20 00 00 00       	mov    $0x20,%ebx
  801f35:	89 f9                	mov    %edi,%ecx
  801f37:	89 c5                	mov    %eax,%ebp
  801f39:	29 fb                	sub    %edi,%ebx
  801f3b:	d3 e6                	shl    %cl,%esi
  801f3d:	89 d9                	mov    %ebx,%ecx
  801f3f:	d3 ed                	shr    %cl,%ebp
  801f41:	89 f9                	mov    %edi,%ecx
  801f43:	d3 e0                	shl    %cl,%eax
  801f45:	09 ee                	or     %ebp,%esi
  801f47:	89 d9                	mov    %ebx,%ecx
  801f49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f4d:	89 d5                	mov    %edx,%ebp
  801f4f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f53:	d3 ed                	shr    %cl,%ebp
  801f55:	89 f9                	mov    %edi,%ecx
  801f57:	d3 e2                	shl    %cl,%edx
  801f59:	89 d9                	mov    %ebx,%ecx
  801f5b:	d3 e8                	shr    %cl,%eax
  801f5d:	09 c2                	or     %eax,%edx
  801f5f:	89 d0                	mov    %edx,%eax
  801f61:	89 ea                	mov    %ebp,%edx
  801f63:	f7 f6                	div    %esi
  801f65:	89 d5                	mov    %edx,%ebp
  801f67:	89 c3                	mov    %eax,%ebx
  801f69:	f7 64 24 0c          	mull   0xc(%esp)
  801f6d:	39 d5                	cmp    %edx,%ebp
  801f6f:	72 10                	jb     801f81 <__udivdi3+0xc1>
  801f71:	8b 74 24 08          	mov    0x8(%esp),%esi
  801f75:	89 f9                	mov    %edi,%ecx
  801f77:	d3 e6                	shl    %cl,%esi
  801f79:	39 c6                	cmp    %eax,%esi
  801f7b:	73 07                	jae    801f84 <__udivdi3+0xc4>
  801f7d:	39 d5                	cmp    %edx,%ebp
  801f7f:	75 03                	jne    801f84 <__udivdi3+0xc4>
  801f81:	83 eb 01             	sub    $0x1,%ebx
  801f84:	31 ff                	xor    %edi,%edi
  801f86:	89 d8                	mov    %ebx,%eax
  801f88:	89 fa                	mov    %edi,%edx
  801f8a:	83 c4 1c             	add    $0x1c,%esp
  801f8d:	5b                   	pop    %ebx
  801f8e:	5e                   	pop    %esi
  801f8f:	5f                   	pop    %edi
  801f90:	5d                   	pop    %ebp
  801f91:	c3                   	ret    
  801f92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f98:	31 ff                	xor    %edi,%edi
  801f9a:	31 db                	xor    %ebx,%ebx
  801f9c:	89 d8                	mov    %ebx,%eax
  801f9e:	89 fa                	mov    %edi,%edx
  801fa0:	83 c4 1c             	add    $0x1c,%esp
  801fa3:	5b                   	pop    %ebx
  801fa4:	5e                   	pop    %esi
  801fa5:	5f                   	pop    %edi
  801fa6:	5d                   	pop    %ebp
  801fa7:	c3                   	ret    
  801fa8:	90                   	nop
  801fa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fb0:	89 d8                	mov    %ebx,%eax
  801fb2:	f7 f7                	div    %edi
  801fb4:	31 ff                	xor    %edi,%edi
  801fb6:	89 c3                	mov    %eax,%ebx
  801fb8:	89 d8                	mov    %ebx,%eax
  801fba:	89 fa                	mov    %edi,%edx
  801fbc:	83 c4 1c             	add    $0x1c,%esp
  801fbf:	5b                   	pop    %ebx
  801fc0:	5e                   	pop    %esi
  801fc1:	5f                   	pop    %edi
  801fc2:	5d                   	pop    %ebp
  801fc3:	c3                   	ret    
  801fc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fc8:	39 ce                	cmp    %ecx,%esi
  801fca:	72 0c                	jb     801fd8 <__udivdi3+0x118>
  801fcc:	31 db                	xor    %ebx,%ebx
  801fce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801fd2:	0f 87 34 ff ff ff    	ja     801f0c <__udivdi3+0x4c>
  801fd8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801fdd:	e9 2a ff ff ff       	jmp    801f0c <__udivdi3+0x4c>
  801fe2:	66 90                	xchg   %ax,%ax
  801fe4:	66 90                	xchg   %ax,%ax
  801fe6:	66 90                	xchg   %ax,%ax
  801fe8:	66 90                	xchg   %ax,%ax
  801fea:	66 90                	xchg   %ax,%ax
  801fec:	66 90                	xchg   %ax,%ax
  801fee:	66 90                	xchg   %ax,%ax

00801ff0 <__umoddi3>:
  801ff0:	55                   	push   %ebp
  801ff1:	57                   	push   %edi
  801ff2:	56                   	push   %esi
  801ff3:	53                   	push   %ebx
  801ff4:	83 ec 1c             	sub    $0x1c,%esp
  801ff7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801ffb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801fff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802003:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802007:	85 d2                	test   %edx,%edx
  802009:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80200d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802011:	89 f3                	mov    %esi,%ebx
  802013:	89 3c 24             	mov    %edi,(%esp)
  802016:	89 74 24 04          	mov    %esi,0x4(%esp)
  80201a:	75 1c                	jne    802038 <__umoddi3+0x48>
  80201c:	39 f7                	cmp    %esi,%edi
  80201e:	76 50                	jbe    802070 <__umoddi3+0x80>
  802020:	89 c8                	mov    %ecx,%eax
  802022:	89 f2                	mov    %esi,%edx
  802024:	f7 f7                	div    %edi
  802026:	89 d0                	mov    %edx,%eax
  802028:	31 d2                	xor    %edx,%edx
  80202a:	83 c4 1c             	add    $0x1c,%esp
  80202d:	5b                   	pop    %ebx
  80202e:	5e                   	pop    %esi
  80202f:	5f                   	pop    %edi
  802030:	5d                   	pop    %ebp
  802031:	c3                   	ret    
  802032:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802038:	39 f2                	cmp    %esi,%edx
  80203a:	89 d0                	mov    %edx,%eax
  80203c:	77 52                	ja     802090 <__umoddi3+0xa0>
  80203e:	0f bd ea             	bsr    %edx,%ebp
  802041:	83 f5 1f             	xor    $0x1f,%ebp
  802044:	75 5a                	jne    8020a0 <__umoddi3+0xb0>
  802046:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80204a:	0f 82 e0 00 00 00    	jb     802130 <__umoddi3+0x140>
  802050:	39 0c 24             	cmp    %ecx,(%esp)
  802053:	0f 86 d7 00 00 00    	jbe    802130 <__umoddi3+0x140>
  802059:	8b 44 24 08          	mov    0x8(%esp),%eax
  80205d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802061:	83 c4 1c             	add    $0x1c,%esp
  802064:	5b                   	pop    %ebx
  802065:	5e                   	pop    %esi
  802066:	5f                   	pop    %edi
  802067:	5d                   	pop    %ebp
  802068:	c3                   	ret    
  802069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802070:	85 ff                	test   %edi,%edi
  802072:	89 fd                	mov    %edi,%ebp
  802074:	75 0b                	jne    802081 <__umoddi3+0x91>
  802076:	b8 01 00 00 00       	mov    $0x1,%eax
  80207b:	31 d2                	xor    %edx,%edx
  80207d:	f7 f7                	div    %edi
  80207f:	89 c5                	mov    %eax,%ebp
  802081:	89 f0                	mov    %esi,%eax
  802083:	31 d2                	xor    %edx,%edx
  802085:	f7 f5                	div    %ebp
  802087:	89 c8                	mov    %ecx,%eax
  802089:	f7 f5                	div    %ebp
  80208b:	89 d0                	mov    %edx,%eax
  80208d:	eb 99                	jmp    802028 <__umoddi3+0x38>
  80208f:	90                   	nop
  802090:	89 c8                	mov    %ecx,%eax
  802092:	89 f2                	mov    %esi,%edx
  802094:	83 c4 1c             	add    $0x1c,%esp
  802097:	5b                   	pop    %ebx
  802098:	5e                   	pop    %esi
  802099:	5f                   	pop    %edi
  80209a:	5d                   	pop    %ebp
  80209b:	c3                   	ret    
  80209c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020a0:	8b 34 24             	mov    (%esp),%esi
  8020a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8020a8:	89 e9                	mov    %ebp,%ecx
  8020aa:	29 ef                	sub    %ebp,%edi
  8020ac:	d3 e0                	shl    %cl,%eax
  8020ae:	89 f9                	mov    %edi,%ecx
  8020b0:	89 f2                	mov    %esi,%edx
  8020b2:	d3 ea                	shr    %cl,%edx
  8020b4:	89 e9                	mov    %ebp,%ecx
  8020b6:	09 c2                	or     %eax,%edx
  8020b8:	89 d8                	mov    %ebx,%eax
  8020ba:	89 14 24             	mov    %edx,(%esp)
  8020bd:	89 f2                	mov    %esi,%edx
  8020bf:	d3 e2                	shl    %cl,%edx
  8020c1:	89 f9                	mov    %edi,%ecx
  8020c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8020cb:	d3 e8                	shr    %cl,%eax
  8020cd:	89 e9                	mov    %ebp,%ecx
  8020cf:	89 c6                	mov    %eax,%esi
  8020d1:	d3 e3                	shl    %cl,%ebx
  8020d3:	89 f9                	mov    %edi,%ecx
  8020d5:	89 d0                	mov    %edx,%eax
  8020d7:	d3 e8                	shr    %cl,%eax
  8020d9:	89 e9                	mov    %ebp,%ecx
  8020db:	09 d8                	or     %ebx,%eax
  8020dd:	89 d3                	mov    %edx,%ebx
  8020df:	89 f2                	mov    %esi,%edx
  8020e1:	f7 34 24             	divl   (%esp)
  8020e4:	89 d6                	mov    %edx,%esi
  8020e6:	d3 e3                	shl    %cl,%ebx
  8020e8:	f7 64 24 04          	mull   0x4(%esp)
  8020ec:	39 d6                	cmp    %edx,%esi
  8020ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020f2:	89 d1                	mov    %edx,%ecx
  8020f4:	89 c3                	mov    %eax,%ebx
  8020f6:	72 08                	jb     802100 <__umoddi3+0x110>
  8020f8:	75 11                	jne    80210b <__umoddi3+0x11b>
  8020fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8020fe:	73 0b                	jae    80210b <__umoddi3+0x11b>
  802100:	2b 44 24 04          	sub    0x4(%esp),%eax
  802104:	1b 14 24             	sbb    (%esp),%edx
  802107:	89 d1                	mov    %edx,%ecx
  802109:	89 c3                	mov    %eax,%ebx
  80210b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80210f:	29 da                	sub    %ebx,%edx
  802111:	19 ce                	sbb    %ecx,%esi
  802113:	89 f9                	mov    %edi,%ecx
  802115:	89 f0                	mov    %esi,%eax
  802117:	d3 e0                	shl    %cl,%eax
  802119:	89 e9                	mov    %ebp,%ecx
  80211b:	d3 ea                	shr    %cl,%edx
  80211d:	89 e9                	mov    %ebp,%ecx
  80211f:	d3 ee                	shr    %cl,%esi
  802121:	09 d0                	or     %edx,%eax
  802123:	89 f2                	mov    %esi,%edx
  802125:	83 c4 1c             	add    $0x1c,%esp
  802128:	5b                   	pop    %ebx
  802129:	5e                   	pop    %esi
  80212a:	5f                   	pop    %edi
  80212b:	5d                   	pop    %ebp
  80212c:	c3                   	ret    
  80212d:	8d 76 00             	lea    0x0(%esi),%esi
  802130:	29 f9                	sub    %edi,%ecx
  802132:	19 d6                	sbb    %edx,%esi
  802134:	89 74 24 04          	mov    %esi,0x4(%esp)
  802138:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80213c:	e9 18 ff ff ff       	jmp    802059 <__umoddi3+0x69>
